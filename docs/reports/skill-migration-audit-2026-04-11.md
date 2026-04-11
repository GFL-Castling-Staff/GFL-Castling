# 技能系统迁移盘点

日期：2026-04-12

> 说明：该文件沿用原报告路径，但内容已按当前代码现状更新。旧版 2026-04-11 盘点中关于 Javelin 未迁移、`GFLskill.as` 仍依赖 Javelin `update()` 的结论已经失效。

## 目标

确认技能系统迁移在当前代码中的真实落地状态，并指出仍然存在的文档偏差与剩余技术债。

重点核对：

1. `M14` 是否已经完成状态归位
2. `RepeatEffectTask` 是否已经稳定落地
3. `DOT / XM8 / HK416 / UZI` 是否已经迁移到 Task
4. `Javelin` 是否还属于 `GFLskill.as` 的旧式残留
5. `event_system.as` 是否已经整体迁移出旧式事件数组

## 结论概览

当前状态可以概括为：

- `M14` 状态归位：已落地
- `RepeatEffectTask`：已落地
- `DOT / XM8 / HK416 / UZI`：已落地
- `Javelin`：已从 `GFLskill.as` 中拆出，迁移为独立 `javelin_tracker.as`
- `GFLskill.as`：`update(float time)` 仍保留生命周期接口，但函数体已为空
- `event_system.as`：未完成整体迁移，仍保留 `GFL_event_array + update()` 事件队列骨架

因此，当前真正需要收尾的重点已经不再是 `Javelin`，而是：

1. 文档与提示稿的过期描述清理
2. `event_system.as` 的旧式事件队列收敛
3. 分发层继续瘦身

## 已落地项目

### 1. M14 已完成独立 Tracker 归位

代码证据：

- `packages/GFL_Castling/scripts/trackers/m14_skill_tracker.as`
- `packages/GFL_Castling/scripts/trackers/commandskill.as`

当前状态：

- 已存在独立的 `M14SkillTracker`
- `commandskill.as` 已通过 `g_m14Tracker` 调用 M14 相关接口
- `CLAUDE.md` 中“`commandskill.as` 仍持有 M14 全局状态”“`kill_event.as` 仍待抽离 M14 逻辑”的描述已经过期

### 2. RepeatEffectTask 已建立

代码证据：

- `packages/GFL_Castling/scripts/trackers/GFLtask.as`

当前状态：

- 已存在 `RepeatEffectTask`
- 已存在基于该基类的多个技能 Task

### 3. DOT / XM8 / HK416 / UZI 已迁移到 Task

代码证据：

- `packages/GFL_Castling/scripts/trackers/GFLtask.as`
- `packages/GFL_Castling/scripts/trackers/GFLskill.as`

当前状态：

- `DOTEffectTask`
- `HK416SkillTask`
- `UZISkillTask`
- `XM8SkillTask`

均已在代码中可见，且 `GFLskill.as` 中对应 case 已改为创建 Task。

### 4. Javelin 已迁移为独立 Tracker

代码证据：

- `packages/GFL_Castling/scripts/trackers/javelin_tracker.as`
- `packages/GFL_Castling/scripts/trackers/GFLskill.as`

当前状态：

- `GFLskill.as` 已 `#include "javelin_tracker.as"`
- passive case 10-13 已改为转发到：
  - `g_javelinTracker.beginLockForAi(event)`
  - `g_javelinTracker.beginLockForPlayer(event)`
  - `g_javelinTracker.handleUprise(event)`
  - `g_javelinTracker.handleStrike(event)`
- `gfl_skill_info.as` 中已不存在 `Javelin_lister`
- `GFLskill.as::update(float time)` 已为空，不再承担 Javelin 状态维护

这说明 `Javelin` 已经不再是 `GFLskill.as` 的旧式残留，而是独立管理的专用 Tracker。

## 仍然存在的旧模式

### 1. event_system.as 仍保留旧式事件数组骨架

代码证据：

- `packages/GFL_Castling/scripts/trackers/event_system.as`
- `packages/GFL_Castling/scripts/trackers/call_event_handler.as`

当前仍可见：

- `dictionary GFL_Event_Index`
- `array<GFL_event@> GFL_event_array`
- `GFL_event_system::update(float time)` 中手动倒计时与 `removeAt`
- 其他文件直接读写 `GFL_event_array`

这说明 `event_system.as` 并没有整体迁移完成。

### 2. event_system.as 属于“执行体部分 Task 化，调度骨架未迁移”

代码证据：

- `packages/GFL_Castling/scripts/trackers/GFLtask.as`

当前状态：

- `GFLtask.as` 已包含多段注明“原 event_system case”的 Task 实现
- 但 `event_system.as` 仍负责事件存储、计时、分发和生命周期清理

因此更准确的描述是：

`event_system.as` 已经发生了局部 Task 化，但还没有完成从“数组驱动事件系统”到“统一 Task 调度”的整体迁移。

### 3. event_system.as 内仍有独立的 Apache Javelin 状态数组

代码证据：

- `packages/GFL_Castling/scripts/trackers/event_system.as`

当前仍可见：

- `array<Apache_Javelin_lister@> Apache_Javelin_list`
- `insertLast(...)`
- `removeAt(...)`

这块不属于 `GFLskill` 的 Javelin，但仍然属于类似的旧式状态管理模式。

## 当前主要技术债

### 1. event_system.as 的调度骨架仍偏旧

当前最值得继续推进的，不是重新处理 `Javelin`，而是判断 `event_system.as` 是否应该：

1. 继续保留为事件入口，但把事件状态管理进一步外提
2. 拆成多个专用 Tracker
3. 或者逐步改为直接创建 Task / 专用状态对象

### 2. 分发层仍然偏厚

以下文件仍然较重：

- `commandskill.as`
- `GFLskill.as`
- `event_system.as`

它们的问题已不再是“没有架构”，而是“分发层内仍有较多业务实现”。

### 3. 文档漂移已经成为实际问题

当前已确认的文档偏差包括：

- `CLAUDE.md`
- `docs/architecture/task-migration.md`
- `docs/reports/skill-migration-audit-2026-04-11.md` 旧版内容
- `claude_use/GFLskill_task_migration_prompt.md`
- `claude_use/skill_doc_continuation_prompt.md`
- `claude_use/skill_system_report.md` 中关于 Javelin “明确延后”的表述

## 推荐的文档处理方式

### 建议更新

- `CLAUDE.md`
- `docs/architecture/skill-system.md`
- `docs/architecture/task-migration.md`

这些文档承担当前开发指引职责，应该保持与代码一致。

### 建议保留但标注为历史快照

- `claude_use/GFLskill_task_migration_prompt.md`
- `claude_use/skill_doc_continuation_prompt.md`
- `claude_use/skill_system_report.md`

这些文档仍有参考价值，但不应再被视为“当前状态说明”。

## 当前判断

从实际代码看，技能迁移主线已经完成了大半，尤其是 `GFLskill` 这条线比旧文档描述的更靠后。

现在最需要的不是继续围绕 `Javelin` 做计划，而是：

1. 修正文档
2. 判断 `event_system.as` 是否值得继续做系统级收敛
3. 避免后续开发再次参考过时结论

## 备注

本次盘点基于静态代码检查，没有在游戏内做行为回归验证，因此这里只确认结构落地情况，不替代实机测试。
