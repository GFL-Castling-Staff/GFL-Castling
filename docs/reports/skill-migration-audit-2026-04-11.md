# 技能系统迁移盘点

日期：2026-04-11

## 目标

本文档用于盘点当前技能系统迁移的真实落地状态，重点核对以下几条结论是否已经在代码中体现：

1. M14 是否已经完成状态归位。
2. `RepeatEffectTask` 是否已经建立。
3. DOT、XM8、HK416、UZI 是否已经迁移到 Task。
4. `GFLskill.as` 是否还保留旧式手动状态。
5. 当前剩余技术债务主要集中在哪里。

## 结论概览

当前迁移状态可以概括为：

- M14 状态归位：已落地
- `RepeatEffectTask` 抽象：已落地
- DOT / XM8 / HK416 / UZI 迁移：已落地
- `GFLskill.as` 旧式 `update()`：仍保留，但已大幅收缩
- 剩余明确未迁移对象：Javelin

因此，项目当前已经跨过“迁移方向不明确”的阶段，进入“只剩少数旧模式收尾和分发层瘦身”的阶段。

## 已落地项

### 1. M14 已完成独立 Tracker 化

代码证据：

- `packages/GFL_Castling/scripts/trackers/m14_skill_tracker.as`
- `packages/GFL_Castling/scripts/trackers/commandskill.as`

当前状态：

- 已存在独立的 `M14SkillTracker`
- 已存在全局引用 `g_m14Tracker`
- `m14_active_tasks`
- `m14_rocket_reward_players`
- `m14_pending_cooldowns`

以上状态已经集中在 `m14_skill_tracker.as` 中管理，而不再散落在 `commandskill.as` 顶部。

同时，`commandskill.as` 中已经改为通过 `g_m14Tracker` 调用：

- `hasRocketReward`
- `consumeRocketReward`
- `isActive`
- `activate`

这说明 M14 的状态归属和入口边界已经明显收敛。

### 2. RepeatEffectTask 已建立

代码证据：

- `packages/GFL_Castling/scripts/trackers/GFLtask.as`

当前状态：

- 已存在 `RepeatEffectTask`
- 已建立基于该基类的多个技能 Task

这说明“重复效果统一抽象”的路线不再停留在文档层，而是已经成为代码中的公共模式。

### 3. DOT / XM8 / HK416 / UZI 已迁移到 Task

代码证据：

- `packages/GFL_Castling/scripts/trackers/GFLtask.as`

当前已存在：

- `DOTEffectTask`
- `HK416SkillTask`
- `UZISkillTask`
- `XM8SkillTask`

这与迁移文档中的优先级顺序一致，说明第一批重复模式技能已经完成迁移。

### 4. gfl_skill_info.as 已大幅瘦身

代码证据：

- `packages/GFL_Castling/scripts/core/gfl_skill_info.as`

当前状态：

- 文件主要保留 `gameSkillIndex`
- 旧式 tracker 类基本已移除
- 目前仍可见的旧结构主要是 `Javelin_lister`

这说明之前“tracker 定义散落在 gfl_skill_info.as” 的问题已经基本被解决。

## 仍然存在的旧模式

### 1. Javelin 仍然依赖手动状态数组

代码证据：

- `packages/GFL_Castling/scripts/trackers/GFLskill.as`
- `packages/GFL_Castling/scripts/core/gfl_skill_info.as`

当前仍存在：

- `protected array<Javelin_lister@> Javelin_list;`
- `Javelin_list.insertLast(...)`
- `Javelin_list.removeAt(...)`
- `GFLskill.as::update(float time)` 中对 `Javelin_list` 的手动 tick
- `gfl_skill_info.as` 中仍保留 `class Javelin_lister`

这说明 Javelin 仍然是当前 `GFLskill.as` 中最明显的旧式残留。

### 2. GFLskill.as 仍保留 update 生命周期

代码证据：

- `packages/GFL_Castling/scripts/trackers/GFLskill.as`

当前情况：

- `GFLskill.as` 仍有 `update(float time)`
- 该 `update()` 目前主要服务于 Javelin 的寿命与清理

这说明 `GFLskill` 还没有彻底变成“纯事件分发器”，但已经接近这个状态。

## 当前主要技术债务

### 1. Javelin 尚未纳入统一 Task 路线

Javelin 不是简单的重复效果，而是多阶段状态机。它不适合直接套用 `RepeatEffectTask`，因此被保留到后续处理是合理的。

但从当前代码状态来看，它也已经成为 `GFLskill.as` 保留 `update()` 的主要原因。

如果后续想继续收缩 `GFLskill.as`，Javelin 是最优先的剩余对象。

### 2. 分发层仍然偏厚

虽然大量重复逻辑已经迁移到 Task，但以下文件仍然比较厚：

- `commandskill.as`
- `GFLskill.as`
- `event_system.as`

它们的问题已不再是“没有架构”，而是“业务实现仍有很多直接写在分发层里”。

后续更适合做的，是把这些大文件继续薄化，而不是再引入新的平行框架。

### 3. event_system.as 仍然使用旧式事件数组

`event_system.as` 仍然维持：

- `dictionary GFL_Event_Index`
- `array<GFL_event@> GFL_event_array`
- `update()` 手动遍历和倒计时

这套机制在职责上和 Task 有一定重叠，是技能系统之外的另一块潜在收敛点。

## 推荐的下一步

### 第一优先级

处理 Javelin。

目标不是强行套入 `RepeatEffectTask`，而是判断它更适合：

1. 拆成多个串行 Task。
2. 做成一个专用的状态机 Task。
3. 保留独立 tracker，但从 `GFLskill.as` 中再进一步解耦。

### 第二优先级

继续瘦身 `commandskill.as` 和 `GFLskill.as`。

建议方向：

- case 保留
- case 内实现继续外提
- 让文件承担“分发器”而不是“业务仓库”

### 第三优先级

把迁移状态工具化。

当前文档已经能说明迁移结论，但仍然依赖人工核对。后续可以在 `tools/` 中补一个状态扫描脚本，自动识别：

- 哪些技能仍依赖旧 tracker
- 哪些技能已经切换到 Task
- 哪些文件仍持有技能专有状态

## 当前判断

从代码实况看，迁移文档描述的大方向基本已经实现，不是纸面计划。

剩余问题已经从“架构方向不明”缩小为“少数特例未完成”和“分发层还偏厚”。这意味着后续重构可以更聚焦，也更适合小步快跑。

## 备注

本次盘点只基于静态代码检查，没有在游戏内进行行为回归测试，因此这里只能确认结构落地情况，不能替代实机验证。
