# PROJECT_STATE.md — GFL-Castling（异向易位）当前状态

> 层 2：动态状态。**按时间追加，不重写**；冲突处标「以后面的为准」。
> 最后同步：2026-08-04
> ⚠ 查「当前行为」以实际源码为准。本文散文部分记录的是各阶段的设计意图，可能与后续修订漂移。
> 常驻规则见 [CLAUDE.md](CLAUDE.md)；已完成事项的归档见 [HISTORY.md](HISTORY.md)。

---

## 一、分支纪律（最重要，先读这节）

| 分支 | 角色 | 纪律 |
|---|---|---|
| `main` | 发布 / 创意工坊分支 | **故意落后于 `dev`，严禁直接修改，严禁把 dev 同步过去。**（SAIWA 2026-08-04 明确） |
| `dev` | 开发主线 | 所有已采纳的改动最终落到这里 |
| `dev-claude` | **AI 协助工作分支** | Claude 的改动都提交在这里；SAIWA 自己测过之后再由他合并回 `dev` |
| `dev-1.9.0` | 历史版本线 | 本轮未审查 |
| `dev-network` | 网络 / 崩服排查线 | 本轮未审查 |

**工作流**：Claude 在 `dev-claude` 上做 → SAIWA 实机测试（人眼门）→ SAIWA 自行合并到 `dev`。
Claude 不合并、不推送到 `dev`，更不碰 `main`。

已废弃分支：`dev-eventsystem`（2026-08-04 删除。它的 5 个重构提交早已全部并入 `dev`，
`dev..dev-eventsystem` 独有提交数为 0，`origin/dev-eventsystem` 远程也已不存在）。

---

## 二、工具链状态

**没有构建系统、没有测试运行器、没有 linter。** 这是本项目最大的工程约束，
直接决定了四道门里**机器门和测量门目前都跑不了**。

| 门 | 本项目现状 |
|---|---|
| 设计门 | 可执行 —— 改动必须有出处（工单 / 本文 / CLAUDE.md） |
| 机器门 | **不可用**。AngelScript 由 RWR 引擎运行时加载，没有独立编译器 |
| 测量门 | **尚未建立**。见下方第五节 |
| 人眼门 | 唯一实际生效的门 —— 拷进 `media/packages/` 进游戏实跑，看行为和崩溃日志 |

**机器门的临时替代**（2026-08-04 起用）：改动脚本后做「剔除 `//` 注释后的大括号净值」自检，
与 `dev` 上同文件比对，净值都应为 0。

```bash
sed 's|//.*||' <file>.as | tr -cd '{}' | awk '{n=0;for(i=1;i<=length($0);i++){c=substr($0,i,1); if(c=="{")n++; else n--} print n}'
```

**这只能抓到括号失衡，抓不到类型错误、未定义符号、拼写错误。**
它不是机器门，只是比裸眼强一点。真正的验证仍然只能靠进游戏。

---

## 三、代码结构

110 个 `.as` 文件，全部在 `packages/GFL_Castling/scripts/` 下。

```
scripts/
├── start_invasion.as              入口（package_config.xml 声明）
├── gamemodes/invasion/
│   └── gamemode_invasion.as       invasion 模式接线点 + tracker 注册总枢纽
├── core/                          共享数据模型、持久化、玩家信息
│   ├── girl_index.as              人形花名册与元数据
│   ├── GFLparameters.as           集中式可调参数
│   ├── GFLplayerlist.as           玩家/士兵追踪、每玩家技能计数与轻量标记
│   ├── gfl_skill_info.as          人形技能定义（notify key -> 技能号映射）
│   ├── command_skill_info.as      指挥/支援技能定义（weapon -> 技能号映射）
│   └── save_system.as             跨场次持久化
├── trackers/                      运行时玩法追踪器与事件处理
│   ├── GFLtask.as                 共享 Task 实现（技能与事件流的公共底座）
│   ├── GFLskill.as                人形技能的运行时激活/效果逻辑
│   ├── commandskill.as            指挥/支援技能激活、冷却、部分 task 化技能流
│   ├── GFLairstrike.as            空袭/扫射请求队列的消费端（含单帧硬帽）
│   ├── call_event_handler.as      呼叫与刷兵逻辑
│   ├── kill_event.as / kill_skill.as   击杀后行为
│   └── fairy_command.as           妖精机制
├── delivery/                      物品与载具投放配置
└── internal/                      对原版 RWR 框架代码的封装
```

**已退役**：`deleted_asset/script/event_system.as`。
2026-08-04 核实：`scripts/` 目录下 `GFL_event_array` / `GFL_event_system` / `GFL_Event_Index`
**零引用**，确已完全退出 tracker 链。CLAUDE.md 里的对应断言准确，无漂移。

---

## 四、已定标参数（权威值）

**所有数值的唯一出处。** 没有来源的数字，三天后没人敢改。
本节目前只收录了 2026-08-04 这轮审查中实际读到并核对过的参数，**远不完整**，后续按需补。

### 4.1 空袭分发（GFLairstrike.as）

| 参数 | 值 | 位置 | 来源 |
|---|---|---|---|
| `max_airstrike_per_frame` | 10 | [GFLairstrike.as:159](packages/GFL_Castling/scripts/trackers/GFLairstrike.as:159) | 历史遗留，**无实测依据**。见第六节待决事项 |
| 队列遍历方向 | 倒序（LIFO） | [GFLairstrike.as:171](packages/GFL_Castling/scripts/trackers/GFLairstrike.as:171) | 为 `removeAt` 安全而写成倒序，LIFO 是副作用不是设计意图 |
| 预算计数单位 | 队列条目数 | [GFLairstrike.as:174](packages/GFL_Castling/scripts/trackers/GFLairstrike.as:174) | 同上 |

⚠ **`max_airstrike_per_frame` 不能用来推算单帧开销。** 各 case 生成的弹头数差两个数量级
（A10 扫射约 48 发 / 离子炮约 16 发 / S13 火箭舱 5 发，**均为读循环次数推算，未实测**），
所以「每帧 10 个」对应的实际弹头生成量在 50～500 发之间浮动。

### 4.2 OTS14 闪电链（已停用，数值仅供恢复时参考）

| 参数 | 值 | 来源 |
|---|---|---|
| `scanRange` | 30.0 | 停用前 dev 主线值 |
| `m_max_jumps` | 5 | 停用前 dev 主线值。dev-claude 曾改为 9，2026-08-04 决定不保留 |
| `m_jump_interval` | 0.12 | 停用前 dev 主线值 |
| `m_jump_range` | 9.0 | 停用前 dev 主线值。dev-claude 曾改为 15.0，2026-08-04 决定不保留 |
| `m_max_total_chain_distance` | 35.0 | 停用前 dev 主线值 |
| `m_candidate_limit` | 20 | 停用前 dev 主线值 |
| OTS14 技能冷却 | 25 | [commandskill.as](packages/GFL_Castling/scripts/trackers/commandskill.as) `excuteOTS14Skill` |

---

## 五、实测数据

**当前为空。这是本项目目前最大的缺口。**

到 2026-08-04 为止，本项目**没有任何自动化测量**，性能相关的数字全部是读代码推算的。
凡是本文或 CLAUDE.md 中出现的开销数字，若未标注「实测」，一律为推算。

**建议优先建立的第一个测量点**（尚未实施）：

在 `GFLairstrike.update` 出入口打点，每帧记录两个数：

1. 本帧实际调用 `CreateDirectProjectile` / `spawnStaticProjectile` 的次数（真实开销）
2. `Airstrike_strafe` 在 update 结束时的残留长度（积压深度）

理由：现在的 `airstrike_per_frame` 数的是**队列条目**，属于「过程计数」；
真正该拿来推算成本的是弹头生成数。在拿到这组数据之前，
**不要动 `max_airstrike_per_frame` 的取值** —— 按条目数调它是在优化错误的量。

---

## 六、待决事项

1. **GFLairstrike 单帧硬帽的三个问题** —— 卡在没有实测数据，需要 SAIWA 决定是否值得投入
   - **`default` 分支不出队**（[GFLairstrike.as:1257](packages/GFL_Castling/scripts/trackers/GFLairstrike.as:1257)）：
     switch 里每个正常 case 都有 `Airstrike_strafe.removeAt(a)`，唯独 `default` 没有。
     一个 key 对不上任何 case 的条目会永远留在队列里，且因为计数在 switch 之前就 `+1`，
     它每帧白吃 1/10 的分发预算，永不释放，且无日志。
     **当前是否已在漏：否。** 2026-08-04 交叉比对过 `airstrikeIndex` 全部 id 与 switch 全部 case，
     唯一无 case 的 id 是占位用的 `-1`；11 个字符串调用点与 6 个裸 int 调用点（4/8/9/14/15/126）
     全部命中现有 case。**这是给后人埋的陷阱，不是现在的故障。**
   - **预算按条目数而非实际开销计**：见第 4.1 节的警告
   - **倒序遍历导致 LIFO**：持续入队 >10/帧 时早提交的请求会被压在后面，
     玩家观感是「先喊的支援后到」。改 FIFO 需要正序遍历 + 延迟删除，改动量大于前两条
2. **OTS14 闪电链停用后的人眼门** —— 卡在等 SAIWA 实机验证。
   停用改动只做了注释，未跑过游戏。需确认：装备 OTS14 按 `/s` 不报错、不崩溃、
   没有残留的施法动画或音效
3. **`dev-1.9.0` / `dev-network` / `pr/178` 三条分支的定位** —— 本轮未审查，
   不清楚是活跃线还是可废弃

---

## 七、已知问题 / 环境注意

- **无编译器意味着注释掉大段代码是有风险的操作。** 2026-08-04 停用闪电链时，
  只注释了入口（技能分发、notify 映射、case 体），
  `GFLtask.as` 里约 350 行的连锁机制类定义**刻意保留未注释** ——
  入口封死后它们已不可达，留着不影响运行，而大段注释类定义只会平白引入语法风险
- **`main` 落后 `dev` 400+ 个提交是有意的**，不是漏合并。不要「顺手同步一下」
- `claude_use/` 下是按日期命名的历史任务记录，**不是当前状态**。查当前状态看本文

---

## 八、追加记录：2026-08-04 本轮改动

> 以下写于 2026-08-04，与前面各节冲突时以本节为准。

本轮在 `dev-claude` 上完成：

1. **合并 `dev` → `dev-claude`**（196 个提交，无冲突）
2. **删除 `dev-eventsystem` 分支**（独有提交数 0，安全）
3. **停用 OTS14 闪电链**，四处入口注释掉并写明原因与恢复方法：
   - `core/command_skill_info.as` weapon → 技能 98 映射（**先前已注释，非本轮改动**）
   - `trackers/commandskill.as` case 98 施法分发
   - `core/gfl_skill_info.as` `"ots14_chain_scan"` → 68 的 notify 映射
   - `trackers/GFLskill.as` case 68 处理体（[:1765](packages/GFL_Castling/scripts/trackers/GFLskill.as:1765)）
   - 闪电链数值同时回退为 dev 主线值（`m_max_jumps` 9→5、`m_jump_range` 15.0→9.0）
4. **新建本文与 HISTORY.md，增量修订 CLAUDE.md**

**本轮改动的验证程度：只做了括号平衡自检，没有进过游戏。**
机器门和测量门在本项目不可用，人眼门待 SAIWA 执行。

**发现但未处理**（有意留下，理由见第六节）：GFLairstrike 的三个问题。
