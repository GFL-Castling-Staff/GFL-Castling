# 2026-11-01｜AngelScript `atomicInc` 引用计数断言崩溃｜排查与修复报告

- 报告人：Zoo
- 项目：GFL-Castling（Running With Rifles 模组，包名 `media/packages/GFL_Castling`）
- 引擎：RWR 1.98.1（Ogre 1.7.x）+ AngelScript 2.x
- 触发场景：服务器端，玩家反复「取武器 → 售卖 → 图鉴录入」，约上百次操作后崩溃

---

## 一、崩溃现象

### 1.1 断言原文

```
rwr_server: ../../angelscript/sdk/angelscript/source/as_atomic.cpp:68:
asDWORD asCAtomic::atomicInc(): Assertion `value < 1000000' failed.
Aborted (core dumped)
```

对应源码：

```cpp
asDWORD asCAtomic::atomicInc()
{
    // A very high ref count is highly unlikely. It most likely a problem with
    // memory that has been overwritten or is being accessed after it was deleted.
    asASSERT(value < 1000000);

    return asAtomicInc((int&)value);
}
```

### 1.2 这个断言的真实含义（关键认知）

它检查的是 **AngelScript 对象的引用计数（`referenceCount`）字段**，不是任何业务逻辑的数值。

引擎注释已经写明两种成因：

1. 内存被越界写覆盖
2. 对象被释放后仍被访问（use-after-free）

也就是说 —— **这不是"某个变量算错了"，而是"堆上已有内存被破坏"**。断言只是在某次 `AddRef` 时踩中地雷，崩点往往远离真正的肇事点。

这个认知决定了后面的整个排查方向：不能只盯着日志最后一行找逻辑错误，而要去找**未定义行为**。

---

## 二、日志证据链

### 2.1 服务器日志 `rwr_server_laststart.log`（122191 行）

崩溃点非常精确。最后一行是：

```
09:43:04: SCRIPT: sending: TagName=command alert=0.000 class=notify
          key=Doll logged success ... %doll_num text=588
```

对应代码 [`ItemDropEvent.as`](packages/GFL_Castling/scripts/trackers/ItemDropEvent.as) 图鉴录入路径：

```angelscript
newdata.addWeapon(loggerKey);
dictionary a;
a["%doll_key"] = "" + loggerKey;
a["%doll_num"] = "" + newdata.getAllNum();
notify(m_metagame, "Doll logged success", a, "misc", pId, false, "", 1.0);  // ← 日志最后一行
string filename = ("save_" + profile_hash +".xml" );
writeXML(m_metagame,filename,PlayerProfileSave(newdata));                    // ← 崩溃在此
```

判断依据：`writeXML` 内部第一句就是

```angelscript
_log("  sending: " + message.toStringWithFloats(), 1);
```

而这一行 **没有出现在日志里**。所以崩溃发生在 `notify` 之后、`send` 之前，即 `PlayerProfileSave` 构建 588 个 XML 节点的过程中。

### 2.2 消息队列不是泄漏（一次误判与纠正）

初看日志中 `queue size 19 / 21 / 23` 反复出现，一度怀疑 [`comms.as`](packages/GFL_Castling/scripts/internal/comms.as) 的 `m_receivedMessages` 单调堆积导致内存压力。

提取全日志 1413 条 `queue size` 记录后，结论相反：

```
08:41:22: queue size 177
08:41:22: queue size 181   ← 峰值，地图切换加载期事件爆发
08:41:23: queue size 148
08:41:24: queue size 100
08:41:24: queue size  60
08:41:25: queue size  31
```

崩溃前最后 10 秒：

```
09:42:54: queue size 20 → 19 → 18 → ... → 5 → 4 → 3 → 2 → 1
09:42:56: queue size 3 → 2 → 1
09:43:04: queue size 1     ← 最后一条，健康
```

`comms.as` 打的是**消费前**的 size，取完 `removeAt(0)` 立刻减一。`size=1` 反复出现说明「刚积压 1 个就被取走」，是队列高效工作的稳定态，不是泄漏。

**结论：队列正常，不做任何"加长度上限丢最旧"的改动。** 那个改动会丢弃 `character_kill`、`item_drop_event`、`chat_event`，直接破坏击杀统计、掉落判定和 `/` 指令响应。

> 教训：日志里的 "queue size 20" 是某一段的瞬时值，不代表全程。判断是否泄漏必须看**完整时间序列的收敛性**，而不是抽样几个点。

---

## 三、定位到的三类真实缺陷

### 3.1 `readXML` 无界自我递归（最危险）

原实现 [`save_system.as`](packages/GFL_Castling/scripts/core/save_system.as)：

```angelscript
const XmlElement@ readXML(const Metagame@ metagame, string filename){
    XmlElement@ query = XmlElement(makeQuery(...));
    const XmlElement@ xml = metagame.getComms().query(query);
    if(xml is null){
        writeXML(metagame,filename,XmlElement(filename));
        @xml = readXML(metagame,filename);   // 无任何重试上限
    }
    return xml;
}
```

`query()` 返回 null 存在**两类无法自愈**的路径（见 [`comms.as`](packages/GFL_Castling/scripts/internal/comms.as)）：

1. `_quitSignalReceived` 已置位 → 直接 `return null`
2. 循环中收到 `user_quit_event` → `break` → `result` 保持 null

这两种情况下**每次递归都必然再拿到 null**，递归无限展开 → 栈溢出 → 覆盖堆区。

这正是断言注释所说的"内存被覆盖"。而且图鉴录入每次操作都要调 `readFile` 一次，上百次操作把触发窗口放大到不可忽视。

### 3.2 `removeAt(findQueueIndex(...))` 缺 `-1` 保护

`findQueueIndex` 找不到时返回 `-1`，但 10 处调用点直接 `removeAt`：

```angelscript
m_craftQueue.removeAt(findQueueIndex(pId, call_key));   // 可能 removeAt(-1)
```

涉及分支：`call_confirm`（2 处）、`call_dev`（4 处）、`call_update`（1 处）、`mod3`（2 处）、`truecore`（1 处）、`blackcard`（1 处）。

`removeAt(-1)` 在 AngelScript 中是**未定义行为**，会直接破坏 `array<T@>` 内部指针 —— 与断言的"内存被写坏"特征完全吻合。

失配路径真实存在：`getQueueByStartString` 用 `startsWith` 前缀匹配，而 `findQueueIndex` 用**精确等值**匹配；`resetQueueTypeString` 又会给 `m_typekey` 追加后缀（如 `_update`）。再加上 `update()` 超时清理与事件处理存在同帧竞态，完全可能「拿到 key 却查不到索引」。

### 3.3 `dictionary` 下标未判存在

```angelscript
int jud_num = int(itemDropFileIndex[itemKey]);   // itemKey 可能不在表里
```

`itemDropFileIndex` 只登记了 `carry_item` 类 key。玩家在军械库（`target_container_type_id == 1`）取**武器**时，`itemKey` 是 `gkw_xxx.weapon`，不在表中。AngelScript 的 `dictionary::opIndex` 对缺失 key 抛异常，会中断整个 `handleItemDropEvent`，使 `m_craftQueue` 停在半完成状态。

---

## 四、性能瓶颈（用户明确要求优化）

### 4.1 问题：`FindWeapon` 是 O(n) 线性扫描，整体是 O(n²)

图鉴录入热路径：

```angelscript
player_data@ newdata = loadProfile(...);   // 解析 588 条武器
if(newdata.FindWeapon(loggerKey))          // 逐条字符串比较
```

`FindWeapon` 与 `addWeapon` 都是 `for` + 字符串比较。解析 588 条武器时，每次 `addWeapon` 都要扫一遍已加入的：

- 单次录入 `addWeapon` 约 **588×588/2 ≈ 17 万次**字符串比较
- `PlayerProfileLoad` + `PlayerProfileSave` 各自再来一遍

这是一次录入的量级。复杂度 O(n²)，随存档增长加速恶化。

### 4.2 优化方案：同步成员索引

[`save_system.as`](packages/GFL_Castling/scripts/core/save_system.as) 新增：

```angelscript
array<string> m_weapons={};        // 保持原有写出顺序，XML 输出完全不变
dictionary m_weapon_index;         // 与 m_weapons 同步的成员索引
```

```angelscript
void addWeapon(const string key)
{
    if (key == "") { return; }
    if (m_weapon_index.exists(key)) { return; }
    m_weapon_index.set(key, true);
    m_weapons.insertLast(key);
}

bool FindWeapon(const string weaponToFind)
{
    return m_weapon_index.exists(weaponToFind);
}
```

索引同步的完整性核对（`m_weapons` 共 3 处写入点）：

| 位置 | 操作 | 处理 |
|---|---|---|
| `addWeapon` | 追加 | 同步 `set` |
| `formatWeaponList` | 整体替换 `m_weapons = new_weapons` | 先 `deleteAll` 再重建 |
| `rebuildWeaponIndex`（新增） | 供外部整体替换后手动同步 | — |

`m_weapons` 没有任何 `removeAt`/`resize` 调用，不存在漏同步路径。

### 4.3 XmlElement 追加与遍历优化

[`helpers.as`](packages/GFL_Castling/scripts/internal/helpers.as)：

```angelscript
// 取一次 Children 句柄，供三个函数复用，避免每次追加都 exists + get 两次字典查找
array<dictionary>@ getOrCreateChildren() {
    array<dictionary>@ childrenData = null;
    if (m_data.exists("Children") && m_data.get("Children", @childrenData) && childrenData !is null) {
        return childrenData;
    }
    @childrenData = array<dictionary>();
    m_data.set("Children", @childrenData);
    return childrenData;
}

void appendChild(const XmlElement@ child) {
    array<dictionary>@ childrenData = getOrCreateChildren();
    childrenData.insertLast(child.toDictionary());
}

void appendChilds(array<const XmlElement@> childs) {
    if (childs.size() <= 0) { return; }
    array<dictionary>@ childrenData = getOrCreateChildren();
    childrenData.reserve(childrenData.size() + childs.size());
    for(uint i=0;i<childs.size();++i){
        const XmlElement@ child = childs[i];
        if (child is null) { continue; }
        childrenData.insertLast(child.toDictionary());
    }
}

// 预估子节点数量，避免大批量 appendChild 时反复扩容
void reserveChildren(uint count) {
    getOrCreateChildren().reserve(count);
}
```

顺带修掉一个隐患：原 `appendChild` 的 `else` 分支在 `childrenData` 为 null 时会执行 `m_data.set("Children", @childrenData)`，**覆盖并丢弃已存在的子节点**。新实现只在真正不存在时创建。

`PlayerProfileSave` 配套预分配：

```angelscript
subroot_0.reserveChildren(player_info.m_weapons.length());          // 588 → 一次扩容
subroot_2.reserveChildren(player_info.m_unlocked_call.length());
subroot_3.reserveChildren(player_info.m_tdoll_intimacy.length());
root.reserveChildren(4);
```

原来逐条 `insertLast` 触发 array 多次倍增扩容 + 元素搬迁，588 条约需 11 次；现在 1 次。

`getElementsByTagName` 修正预留策略：原为固定 `reserve(128)`，解析 588 条时不够用且超出部分全部浪费；改为按 `childrenData.size()` 精确预留。

`PlayerProfileLoad` 预热容器：`m_weapons.reserve(...)`、`m_unlocked_call.reserve(...)`、`m_tdoll_intimacy.reserve(...)`。

### 4.4 收益

单次录入的字符串比较次数：

- **优化前**：`addWeapon` 约 17 万次 + `FindWeapon` 约 588 次
- **优化后**：约 588 次 dictionary 哈希查找 + 1 次

关键在**复杂度**而非常数：原实现 O(n²)，598 条已是瓶颈，玩家继续录入到 1000+ 时加速恶化。现在整体 O(n)。

---

## 五、语义决策：读取失败必须中止，绝不写入

这是本次最重要的一个设计判断，值得单独记录。

### 5.1 曾被否决的中间方案

最初为了让 `readFile` 永不返回 null（从而 23 个调用方零改动），曾采用「读取失败时返回一份内存中的空 `player_data`」。

**这个方案是错的。** 后果是：某玩家存档读取失败时，会以"什么都没解锁"的状态被读入，随后的 `writeXML` **把空数据写回存档**，覆盖原有 588 条记录。

### 5.2 最终方案

明确区分「通信失败」与「文件为空」两种 null：

```angelscript
// 单次查询，失败返回 null。旧实现的递归自我调用在 query 持续失败时会无限展开打穿堆栈。
const XmlElement@ readXML(const Metagame@ metagame, string filename){
    XmlElement@ query = XmlElement(makeQuery(...));
    const XmlElement@ xml = metagame.getComms().query(query);
    if (xml is null) {
        _log("WARN: readXML query failed: " + filename, -1);
    }
    return xml;
}

// 返回存档根节点。返回 null 表示读取失败，调用方必须判空并中止，禁止在失败状态下写入。
const XmlElement@ readFile(const Metagame@ metagame,string name, string profile_hash){
    string filename = ("save_" + profile_hash +".xml" );

    const XmlElement@ xml = readXML(metagame, filename);
    if (xml is null) {
        // 通信层读取失败（例如已收到退出信号），不允许写入，直接失败
        _log("WARN: readFile read failed, abort: " + filename, -1);
        return null;
    }

    const XmlElement@ root = xml.getFirstChild();
    if (root !is null) {
        return root;
    }

    // 存档存在但没有内容：为首次进入的玩家创建初始存档
    _log("readFile is null,create");
    writeXML(metagame,filename,PlayerProfileSave(player_data(name,profile_hash)));

    const XmlElement@ xml_retry = readXML(metagame, filename);
    if (xml_retry is null) {
        _log("WARN: readFile reread failed, abort: " + filename, -1);
        return null;
    }
    return xml_retry.getFirstChild();
}

// 读取并解析玩家存档。返回 null 表示失败，调用方必须判空并中止，禁止写入。
player_data@ loadProfile(const Metagame@ metagame, string name, string profile_hash){
    const XmlElement@ root = readFile(metagame, name, profile_hash);
    if (root is null) {
        return null;
    }
    return PlayerProfileLoad(root);
}
```

语义对照：

| 场景 | 判定 | 行为 |
|---|---|---|
| `readXML` 返回 null（通信失败） | 错误 | **不写入**，返回 null |
| `readXML` 成功但 `getFirstChild()` 为 null（文件存在但空） | 新玩家建档 | 写初始存档，重读 |
| 建档后重读仍失败 | 错误 | **不写入**，返回 null |

「文件存在但为空」仍会写初始存档 —— 这是新玩家的正常建档流程，区别于错误路径。

### 5.3 调用方迁移

`loadProfile` 把「读 + 解析 + 判空」合并为一步。全部 23 处 `PlayerProfileLoad(readFile(...))` 已迁移，并逐一补判空：

| 文件 | 处数 | 失败处理 |
|---|---|---|
| [`ItemDropEvent.as`](packages/GFL_Castling/scripts/trackers/ItemDropEvent.as) | 7 | `return` |
| [`save_system.as`](packages/GFL_Castling/scripts/core/save_system.as) | 9 | `return` |
| [`call_event_handler.as`](packages/GFL_Castling/scripts/trackers/call_event_handler.as) | 5 | 4 处 `break`、1 处退武器后 `return` |
| [`GFLplayerlist.as`](packages/GFL_Castling/scripts/core/GFLplayerlist.as) | 2 | `return` |

已用正则 `PlayerProfileLoad\(\s*readFile` 确认零残留。

特别说明 [`call_event_handler.as`](packages/GFL_Castling/scripts/trackers/call_event_handler.as) 的 M1A1 召唤流程：读取失败时**先把武器退还玩家再 return**，不会出现"扣了武器却没扣费"的半完成状态。

---

## 六、`removeAt(-1)` 防护：统一辅助函数

不在 10 处各写一遍判断，而是收编为一个函数：

```angelscript
// 安全移除队列项：findQueueIndex 返回 -1 时 removeAt(-1) 属未定义行为会破坏数组，这里统一拦掉
bool removeQueueEntry(int pId,string type){
    int index = findQueueIndex(pId,type);
    if(index < 0){
        _log("WARN: ItemDropEvent: queue entry not found, pid=" + pId + " key=" + type);
        return false;
    }
    m_craftQueue.removeAt(index);
    return true;
}
```

调用点改为单行 `removeQueueEntry(pId, call_key);`，逻辑分支与原先完全一致，无新增嵌套。

失败分支保留 `WARN` 日志 —— 它同时是诊断信号：若崩溃复现且出现该日志，说明竞态路径真实存在。

**无需改动的两处：**

- `ItemDropEvent.as` 中 `if(index == -1 ) return;` 之后的那处，已有前置保护
- `update()` 里的 `m_craftQueue.removeAt(a)`，用的是倒序循环下标 `a`，恒在 `[0, size-1]` 内

---

## 七、实测验证

### 7.1 测试条件

- 客户端日志 `rwr_game.log`，489114 行
- 11 次成功录入 + 大量重复拦截

### 7.2 决定性证据：存档文件内容正确

```
10:23:15  campaign178.save   weapons=587   size=36774   ← 测试前
10:38:53  campaign179.save   weapons=598   size=37251   ← 测试后
```

`campaign179.save/save_ID3580998501.xml` 实际武器节点数 **598**，与日志最后的 `%doll_num text=598` 完全一致。

这一条同时验证了 `reserveChildren` 预分配、`appendChild` 重构、`m_weapon_index` 索引改造都没有丢节点。

> 排查提示：`savegames` 目录下有大量历史存档（campaign0/1/101/81/82 等，mtime 为 2025 年），里面 `weapons` 只有 2 条甚至 0 条，容易误判为数据丢失。**核对时必须按 mtime 过滤当天文件**。

### 7.3 录入计数序列

```
588, 589, 590, 591, 592, 593, 594, 595, 596, 597, 598
```

11 次成功，严格连续无跳号。证明：

- `m_weapon_index.set` 与 `m_weapons.insertLast` 完全同步
- `FindWeapon` 的 `exists` 判断准确
- 期间大量 `Doll logged already` 正确拦截重复，说明索引去重生效

### 7.4 新增防护一次都没触发

| 检查项 | 命中次数 |
|---|---|
| `WARN: readXML query failed` | 0 |
| `WARN: readFile read failed` | 0 |
| `WARN: readFile reread failed` | 0 |
| `WARN: ItemDropEvent: queue entry not found` | 0 |
| `Script exception` | 0 |
| `Assertion` | 0 |

`removeAt(-1)` 防护在 `call_confirm` / `call_dev` / `mod3` / `truecore` / `blackcard` 五条分支上都未触发，说明正常运行下索引匹配是成功的 —— 防护处于备用状态，符合预期。

### 7.5 日志结尾为正常退出

```
10:38:57: SCRIPT: received: TagName=character_kill ...   ← 最后一批战斗事件
10:38:58: SCRIPT: received: TagName=pause_event state=1  ← 暂停（正常退出流程）
10:38:58: server access, url=http://rwr.../get_player_counts.php
```

`pause_event state=1` 是正常暂停/退出信号，之后没有 `atomicInc` 断言，也没有 `Aborted (core dumped)`。

### 7.6 一处正常路径日志

```
10:35:11: SCRIPT:readFile is null,create
```

这是**旧代码就有的**日志，表示"存档存在但内容为空 → 新玩家首次建档"。本次改造特意保留了它，因为区分它与"读取失败"正是核心目的。

---

## 八、结论与后续

### 8.1 已完成

| 项 | 文件 | 性质 |
|---|---|---|
| `readXML` 无界递归消除 | [`save_system.as`](packages/GFL_Castling/scripts/core/save_system.as) | 稳定性 |
| 读取失败即中止、绝不写入 | [`save_system.as`](packages/GFL_Castling/scripts/core/save_system.as) + 4 文件 23 处调用方 | 数据安全 |
| `removeAt(-1)` 防护 ×10 | [`ItemDropEvent.as`](packages/GFL_Castling/scripts/trackers/ItemDropEvent.as) | 稳定性 |
| 武器查找 O(n²) → O(n) | [`save_system.as`](packages/GFL_Castling/scripts/core/save_system.as) | 性能 |
| `appendChild` 去重查找 + 预分配 | [`helpers.as`](packages/GFL_Castling/scripts/internal/helpers.as) | 性能 |
| 清理未使用变量 `format_string` | [`ItemDropEvent.as`](packages/GFL_Castling/scripts/trackers/ItemDropEvent.as) | 清洁度 |

### 8.2 诚实评价：断言是否已被根治

**不能保证。** 理由：

1. 上次崩溃需要"上百次操作"才触发，本次只做了 11 次录入，样本量不足以证明不会复现
2. 已修的三项确实都是**真实的未定义行为源**（该修，且必须修），但其中是否有本次断言的直接肇事者，无法从日志反推确认
3. 断言崩点落在 `PlayerProfileSave` 内，而我修改的路径中，`readXML` 递归在那条链路上并未触发（前面每次 `loadProfile` 都成功返回了 588 条数据，说明 query 一直是通的）

更准确的说法是：**消除了三个确定存在的内存破坏源 + 显著降低堆压力，但没有拿到"就是这一行"的铁证。**

### 8.3 若再次复现，推荐的插桩方案

在 [`ItemDropEvent.as`](packages/GFL_Castling/scripts/trackers/ItemDropEvent.as) 录入分支插入阶段标记：

```angelscript
newdata.addWeapon(loggerKey);
_log("LOG-A n=" + newdata.getAllNum());
dictionary a;
a["%doll_key"] = "" + loggerKey;
a["%doll_num"] = "" + newdata.getAllNum();
notify(m_metagame, "Doll logged success", a, "misc", pId, false, "", 1.0);
_log("LOG-B");
string filename = ("save_" + profile_hash +".xml" );
XmlElement@ saved = PlayerProfileSave(newdata);
_log("LOG-C");
writeXML(m_metagame,filename,saved);
_log("LOG-D");
```

下次复现时，最后出现的标记直接锁定范围：

- 停在 A→B：`notify` 的 dictionary 传递
- 停在 B→C：`PlayerProfileSave` 的 588 次 `appendChild`（当前最可疑）
- 停在 C→D：`writeXML` 内部的 `send`

### 8.4 排查方法论沉淀

本次有两条经验值得复用：

1. **`atomicInc` 断言不等于业务逻辑错误。** 它指向内存被破坏，应优先找 `removeAt(-1)`、空句柄解引用、递归无界、`dictionary` 缺失 key 这类未定义行为，而不是对着崩溃行的业务代码反复看。

2. **判断内存/队列泄漏必须看完整时间序列。** 我曾仅凭抽样几行 `queue size 21` 就判定"单调堆积"，提取全部 1413 条后才发现是健康的收敛曲线。这个误判差点导致一个会破坏击杀统计的错误改动。

3. **核对存档数据必须按 mtime 过滤。** `savegames` 下有几十个历史 campaign 目录，直接取样会看到 2025 年的旧文件而误判为数据丢失。

---

## 九、涉及文件清单

**核心改动**

- [`packages/GFL_Castling/scripts/core/save_system.as`](packages/GFL_Castling/scripts/core/save_system.as)
  - `readXML` / `readFile` / 新增 `loadProfile`
  - `player_data`：新增 `m_weapon_index`，改写 `addWeapon` / `FindWeapon` / `formatWeaponList`，新增 `rebuildWeaponIndex`
  - `PlayerProfileSave`：`reserveChildren` 预分配
  - `PlayerProfileLoad`：容器 `reserve` 预热
  - 9 处调用方迁移至 `loadProfile` + 判空

- [`packages/GFL_Castling/scripts/internal/helpers.as`](packages/GFL_Castling/scripts/internal/helpers.as)
  - 新增 `getOrCreateChildren` / `reserveChildren`
  - 改写 `appendChild` / `appendChilds`
  - `getElementsByTagName` 预留策略修正

- [`packages/GFL_Castling/scripts/trackers/ItemDropEvent.as`](packages/GFL_Castling/scripts/trackers/ItemDropEvent.as)
  - 新增 `removeQueueEntry`
  - 10 处 `removeAt(findQueueIndex(...))` 替换
  - 7 处调用方迁移至 `loadProfile` + 判空
  - 清理未使用变量

- [`packages/GFL_Castling/scripts/trackers/call_event_handler.as`](packages/GFL_Castling/scripts/trackers/call_event_handler.as)
  - 5 处调用方迁移至 `loadProfile` + 判空

- [`packages/GFL_Castling/scripts/core/GFLplayerlist.as`](packages/GFL_Castling/scripts/core/GFLplayerlist.as)
  - 2 处调用方迁移至 `loadProfile` + 判空

**未改动**

- [`packages/GFL_Castling/scripts/internal/comms.as`](packages/GFL_Castling/scripts/internal/comms.as) —— 消息队列经实测健康，不做任何"丢最旧"限制
