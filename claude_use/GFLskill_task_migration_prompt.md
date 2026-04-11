# GFLskill 技能系统 Task 迁移指导

## 项目背景

GFL-Castling 是 Steam 游戏 Running With Rifles (RWR) 的少女前线同人模组，使用 AngelScript 编写。项目正在逐步将旧系统迁移到 Task 体系。

### 核心架构

- **Task 体系** (`task_sequencer.as`): `Task` 接口 → `TaskSequencer`（串行）→ `TaskManager`（并行管理多个 Sequencer）。通过 `m_metagame.getTaskManager().newTaskSequencer()` 创建新的 Sequencer，add Task 后由引擎自动 tick。
- **GFLtask.as**: 存放各种 Task 类定义，如 `DelayAntiPersonSnipeRequest`、`event_call_task` 等。
- **GFLskill.as**: 当前的技能执行 Tracker。通过 `handleResultEvent` 接收武器弹头的 `notify_metagame` 回调，创建自定义 tracker 对象并在 `update()` 中手动 tick。**本次迁移的主要目标文件。**
- **gfl_skill_info.as**: 技能 key → index 映射（`gameSkillIndex` dictionary）及各种 tracker 类的定义（`XM8tracker`、`HK416_tracker` 等）。
- **commandskill.as**: `/skill` 命令入口，通过 `handleChatEvent` 分发。与 `kill_event.as` 循环 include，共享全局变量如 `SkillArray`。
- **kill_event.as**: 击杀事件处理，`handleCharacterKillEvent` 中有大量基于武器的特殊逻辑。与 `commandskill.as` 循环 include。

### 编码规范

- 注释使用中文
- 变量命名与现有代码保持一致（`m_` 前缀表示成员变量，`excute` 是项目内固定拼写不要纠正）
- 函数命名保持现有风格
- 版本控制使用 Conventional Commits

## 迁移目标

将 `GFLskill.as` 中基于手动 tracker 数组 + `update()` 遍历的技能实现，迁移为基于 Task 体系的实现。

## 当前 GFLskill 技能的共同模式

所有技能都是同一个模式：

1. `handleResultEvent` 收到 `notify_metagame` 回调
2. 往自定义数组里 push 一个状态对象（如 `XM8tracker`）
3. `GFLskill.update()` 里遍历数组，tick 时间，到点执行一次效果，重复 N 次
4. 次数用完后 `removeAt`

每个 tracker 类字段几乎一样：`m_characterId`、`m_time`、`m_numtime`、`m_factionid`、`m_pos`，差异在执行逻辑。`GFLskill.update()` 里对每种数组分别写近乎相同的 for 循环。

## 迁移方案

### 抽象基类 RepeatEffectTask

在 `GFLtask.as` 中新增：

```angelscript
// 通用重复效果 Task 基类
// 用于替代 GFLskill 中的手动 tracker 数组模式
class RepeatEffectTask : Task {
    protected GameMode@ m_metagame;  // GFLskill 传入 GameMode@，与 M14SkillActiveTask 一致
    protected int m_characterId;
    protected int m_factionId;
    protected Vector3 m_pos;
    protected float m_interval;       // 每次执行间隔（秒）
    protected float m_timeLeft;       // 当前间隔倒计时
    protected int m_remainCount;      // 剩余执行次数

    RepeatEffectTask(GameMode@ metagame, int cId, int fId, 
                     Vector3 pos, float interval, int count) {
        @m_metagame = metagame;
        m_characterId = cId;
        m_factionId = fId;
        m_pos = pos;
        m_interval = interval;
        m_remainCount = count;
    }

    void start() {
        m_timeLeft = m_interval;
    }

    void update(float time) {
        m_timeLeft -= time;
        if (m_timeLeft <= 0) {
            excuteEffect();
            m_remainCount--;
            m_timeLeft = m_interval;
        }
    }

    bool hasEnded() const { 
        return m_remainCount <= 0; 
    }

    // 子类重写此方法实现具体效果
    void excuteEffect() {}
}
```

### 迁移批次（按复杂度排序）

#### 第一批：DOT_tracker

最简单的定时重复效果，在指定位置重复生成弹头。

**现有实现**：`DOT_tracker` 类 + `GFLskill.update()` 中的遍历段落。
**迁移为**：`DOTEffectTask : RepeatEffectTask`，`excuteEffect()` 中在 `m_pos` 生成 projectile。
**额外字段**：`string m_projectile`（弹头 key）。

#### 第二批：XM8tracker

每秒在目标区域附近随机选一个敌人生成爆炸弹头，重复 7 次。

**现有实现**：`XM8tracker` 类 + `GFLskill.update()` 中的遍历段落。
**迁移为**：`XM8SkillTask : RepeatEffectTask`，`excuteEffect()` 中搜索附近敌人、随机选一个、在其位置生成弹头。
**注意**：需要搜索多个阵营的敌人（`getCharactersNearPosition` 遍历非友方阵营）。

#### 第三批：HK416_tracker

对锁定的敌人列表逐个释放延迟爆炸，重复 8 次。

**现有实现**：`HK416_tracker` 类 + `GFLskill.update()` 中的遍历段落。
**迁移为**：`HK416SkillTask : RepeatEffectTask`，`excuteEffect()` 中对 `m_affected` 列表中每个存活敌人生成弹头。
**额外字段**：`array<const XmlElement@> m_affected`（受影响角色列表）。
**注意**：需要在 `excuteEffect()` 中用 `getCharacterInfo` 重新获取角色位置（敌人会移动）。

#### 第四批：UZI_tracker

与 HK416 类似但效果不同。分析实际代码后决定是否复用 HK416 的模式。

#### 不迁移到 RepeatEffectTask 的技能

- **Javelin**（`Javelin_lister`）：多阶段状态机（锁定→爬升→攻顶），不是简单重复效果。**本次暂不迁移，留待后续单独处理。**
- **M14MOD3**：已用独立 Task 实现（`M14SkillActiveTask` + `M14SkillEndTask`），由 kill event 被动驱动而非定时执行。

### M14MOD3 规范化重构（优先级高）

M14MOD3 的技能已经用 Task 体系实现并运作正常，但当前实现有技术债务需要清理：

**现状问题**：
- `m14_active_tasks`、`m14_rocket_reward_players`、`m14_pending_cooldowns` 及 `M14PendingCooldown` 类作为全局变量/类散落在 `commandskill.as` 顶部
- 连锁射击逻辑硬编码在 `kill_event.as` 的 `handleCharacterKillEvent` 中
- 死亡清理逻辑硬编码在 `kill_event.as` 的 `handlePlayerDieEvent` 中
- pending cooldown 的消费逻辑硬编码在 `commandskill.as` 的 `update()` 中

**目标**：将所有 M14 技能状态和逻辑封装到一个独立的 Tracker 中。

**方案**：新建 `m14_skill_tracker.as`，包含 `M14SkillTracker : Tracker` 类。

**M14SkillTracker 职责**：
- 持有 `m14_active_tasks`、`m14_rocket_reward_players`、`m14_pending_cooldowns` 作为成员变量
- `handleCharacterKillEvent`：处理连锁射击逻辑（从 `kill_event.as` 移入）
- `handlePlayerDieEvent`：处理死亡清理（从 `kill_event.as` 移入）
- `update(float time)`：处理 pending cooldown 消费（从 `commandskill.as` 移入）
- 暴露公共方法供 `commandskill.as` 调用：
  - `activate(GameMode@ metagame, int characterId, int playerId, int factionId, SkillModifer@ modifer)` — 创建 Task 并注册状态
  - `bool hasRocketReward(int playerId)` — 检查是否有火箭弹奖励
  - `void consumeRocketReward(int playerId)` — 消费火箭弹奖励
  - `bool isActive(int characterId)` — 检查是否已有激活状态（防重复激活）

**跨 Tracker 通信**：在 `m14_skill_tracker.as` 顶部声明全局引用 `M14SkillTracker@ g_m14Tracker`，构造时赋值。`commandskill.as` include 该文件后通过 `g_m14Tracker` 调用公共方法。与项目中 `g_playerInfo_Buck` 的模式一致。

**commandskill.as 的变化**：
- `excuteM14MOD3Skill` 简化为调用 `g_m14Tracker` 的公共方法，不再直接管理任何 M14 状态
- 移除顶部的 `m14_active_tasks`、`m14_rocket_reward_players`、`m14_pending_cooldowns` 全局数组及 `M14PendingCooldown` 类
- 移除 `update()` 中的 pending cooldown 消费段落

**kill_event.as 的变化**：
- 移除 `handleCharacterKillEvent` 中的 M14 连锁射击段落
- 移除 `handlePlayerDieEvent` 中的 M14 死亡清理段落
- 这些事件由引擎自动分发给 `M14SkillTracker`（作为独立 Tracker 注册）

**注册**：在 gamemode 初始化时 `addTracker(M14SkillTracker(metagame))`，与 `kill_event`、`GFLskill` 等并列。

**Task 类（`M14SkillActiveTask`、`M14SkillEndTask`）保持在 `GFLtask.as` 中不动**，只是它们操作的全局数组从 `commandskill.as` 顶部移动到 `m14_skill_tracker.as` 中（通过全局引用 `g_m14Tracker` 访问成员）。注意 Task 内部凡是直接引用全局数组的地方，需要同步改为通过 `g_m14Tracker` 访问成员变量。

**执行顺序：先做 M14 规范化，再做 RepeatEffectTask 迁移。** M14 已经是 Task 实现，只需挪位置和封装，不涉及逻辑改动，风险最低。

### 每个技能的迁移步骤

1. 在 `GFLtask.as` 中编写新的 Task 子类
2. 修改 `GFLskill.as` 的 `handleResultEvent` 对应 case：从 `XXX_track.insertLast(...)` 改为创建 TaskSequencer 并 add Task
3. 删除 `GFLskill.as` 的 `update()` 中对应的遍历段落
4. 删除 `gfl_skill_info.as` 中对应的 tracker 类定义（如 `XM8tracker`）
5. 删除 `GFLskill.as` 中对应的 tracker 数组声明（如 `array<XM8tracker@> XM8track`）
6. 游戏内测试验证效果一致

### 注意事项

- `handleResultEvent` 的分发逻辑（`gameSkillIndex` dictionary + switch-case）保持不变，只改 case 内部的实现
- 迁移后 `GFLskill.update()` 会逐步变空，最终所有定时逻辑由 TaskManager 管理
- Task 的 `update` 由 `TaskManager.update()` 驱动，后者在 `Metagame.run()` 的主循环中被调用，tick 频率与 `GFLskill.update()` 相同
- AngelScript 不支持 abstract 关键字用于方法（只能用于类），`RepeatEffectTask` 的 `excuteEffect()` 是空实现而非纯虚函数，子类通过重写覆盖
- 已完成的 M14MOD3 Task 实现可作为参考，但注意 M14 不是 RepeatEffectTask 模式

## 需要上传的脚本文件

进行迁移工作时，请上传以下文件：

1. **`GFLtask.as`** — Task 类定义所在，新 Task 子类和 RepeatEffectTask 基类写在这里
2. **`GFLskill.as`** — 迁移的主要目标，需要修改 `handleResultEvent` 和 `update()`
3. **`gfl_skill_info.as`** — tracker 类定义和 `gameSkillIndex`，迁移后需删除旧 tracker 类
4. **`task_sequencer.as`** — Task/TaskSequencer/TaskManager 的基础定义，供参考
5. **`commandskill.as`** — M14 规范化需要修改此文件（移除全局变量、简化 `excuteM14MOD3Skill`、移除 `update()` 中的 pending cooldown 段落），同时提供技能冷却系统（`addCooldown`、`SkillArray` 等）的上下文
6. **`kill_event.as`** — M14 规范化需要修改此文件（移除连锁射击和死亡清理段落）

可选（如果涉及对应技能的调试）：
7. **`GFLhelpers.as`** — 包含 `getCharactersNearPosition`、`CreateDirectProjectile` 等辅助函数

## 验收标准

### M14 规范化
- `commandskill.as` 顶部不再有 M14 相关全局变量和类
- `commandskill.as` 的 `update()` 中不再有 pending cooldown 消费逻辑
- `kill_event.as` 中不再有 M14 连锁射击和死亡清理代码
- 所有 M14 状态和逻辑集中在 `m14_skill_tracker.as` 中
- 技能效果与重构前完全一致
- commit: `refactor: encapsulate M14MOD3 skill into independent tracker`

### GFLskill 技能迁移
- 迁移后的技能效果与迁移前完全一致（弹头类型、伤害、间隔、次数、搜索范围等参数不变）
- `GFLskill.update()` 中对应的手动遍历段落已删除
- `gfl_skill_info.as` 中对应的旧 tracker 类已删除
- 编译无错误无警告
- 每完成一个技能的迁移后提交一次 commit（`refactor: migrate XM8 skill to Task system` 格式）
