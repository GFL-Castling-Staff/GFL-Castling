# 技能系统迁移盘点

日期：2026-04-12

> 说明：该文件沿用原报告路径，但内容已按当前代码现状更新。

## 目标

确认技能系统迁移在当前代码中的真实落地状态，并指出仍然存在的文档偏差与剩余技术债。

重点核对：

1. `M14` 是否已经完成状态归位
2. `RepeatEffectTask` 是否已经稳定落地
3. `DOT / XM8 / HK416 / UZI` 是否已经迁移到 Task
4. `Javelin` 是否还属于 `GFLskill.as` 的旧式残留
5. 当前 live 链路中最值得继续收敛的对象是什么

## 结论概览

当前状态可以概括为：

- `M14` 状态归位：已落地，但不是独立 tracker
- `RepeatEffectTask`：已落地
- `DOT / XM8 / HK416 / UZI`：已落地
- `Javelin`：已从 `GFLskill.as` 中拆出，迁移为独立 `javelin_tracker.as`
- `GFLskill.as`：`update(float time)` 仍保留生命周期接口，但函数体已为空
- `event_system.as`：已退出 live tracker 链，保留在 `deleted_asset/` 中作为历史文件
- `commandskill.as` 与 `call_event_handler.as`：仍是当前 live 中更值得继续收敛的旧式分发层

因此，当前真正需要收尾的重点已经不再是 `Javelin`，而是：

1. 文档与提示稿的过期描述清理
2. `commandskill.as` 与 `call_event_handler.as` 的旧式状态/分发逻辑收敛
3. `kill_event.as` 中技能联动片段继续瘦身

## 已落地项目

### 1. M14 已完成状态归位

代码证据：

- `packages/GFL_Castling/scripts/trackers/commandskill.as`
- `packages/GFL_Castling/scripts/trackers/GFLtask.as`
- `packages/GFL_Castling/scripts/trackers/kill_event.as`
- `packages/GFL_Castling/scripts/core/GFLplayerlist.as`

当前状态：

- `commandskill.as` 负责 M14 技能入口
- `GFLtask.as` 中存在 `M14SkillActiveTask` 与 `M14SkillEndTask`
- `kill_event.as` 中保留 M14 击杀联动与死亡清理
- `GFLplayerlist.as` 中的玩家 tag 承担轻量状态归属

结论：

`M14` 已完成状态归位，但落点是现有 Task 和玩家状态链路，而不是独立 `m14_skill_tracker.as`。

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
- `packages/GFL_Castling/scripts/gamemodes/invasion/gamemode_invasion.as`

当前状态：

- `GFLskill.as` 已 `#include "javelin_tracker.as"`
- passive case 10-13 已改为转发到 `g_javelinTracker`
- `GFLskill.as::update(float time)` 已为空，不再承担 Javelin 状态维护
- `gamemode_invasion.as` 已直接装配 `JavelinTracker(this)`

这说明 `Javelin` 已经不再是 `GFLskill.as` 的旧式残留，而是独立管理的专用 Tracker。

## 当前 live 中仍然存在的旧模式

### 1. commandskill.as 仍保留旧式冷却与计时数组

代码证据：

- `packages/GFL_Castling/scripts/trackers/commandskill.as`

当前仍可见：

- `array<SkillTrigger@> SkillArray`
- `array<SkillEffectTimer@> TimerArray`
- `update(float time)` 中手动倒计时与移除

这说明主动技能入口层仍然偏厚。

### 2. call_event_handler.as 仍保留 update 驱动的运行时状态

代码证据：

- `packages/GFL_Castling/scripts/trackers/call_event_handler.as`

当前仍可见：

- 运行时冷却数组
- `update(float time)` 中手动倒计时
- 大量在分发层内直接创建 `TaskSequencer`

这部分比历史 `event_system.as` 更接近当前 live 中的下一收敛目标。

### 3. kill_event.as 中仍混有技能联动实现

代码证据：

- `packages/GFL_Castling/scripts/trackers/kill_event.as`

当前仍可见：

- 针对部分技能的击杀联动逻辑
- M14 相关联动和清理逻辑

这说明部分技能行为虽然已完成归位，但文件层面仍然偏厚。

## 关于 event_system.as 的准确结论

代码证据：

- `deleted_asset/script/event_system.as`
- `packages/GFL_Castling/scripts/gamemodes/invasion/gamemode_invasion.as`

当前状态：

- `event_system.as` 仍保留历史实现，包括 `GFL_Event_Index`、`GFL_event_array` 与 `update()` 驱动
- 但该文件已经不在当前 live tracker 装配链中
- 文档中若仍将其描述为 live `trackers/event_system.as`，属于过期信息

因此更准确的描述是：

`event_system.as` 现在是历史参考文件，而不是当前运行链中的主收敛对象。

## 当前主要技术债

### 1. 分发层仍然偏厚

以下文件仍然较重：

- `commandskill.as`
- `GFLskill.as`
- `call_event_handler.as`
- `kill_event.as`

它们的问题已不再是“没有架构”，而是“分发层内仍有较多业务实现”。

### 2. 文档漂移已经成为实际问题

本次已确认并修正的偏差主要集中在：

- 把 `M14` 误写为独立 `m14_skill_tracker.as`
- 把历史 `event_system.as` 误写为 live 文件
- 把当前主要收敛目标误判为 `Javelin` 或 `event_system.as`

## 推荐的文档处理方式

### 建议作为当前开发指引维护

- `CLAUDE.md`
- `docs/architecture/skill-system.md`
- `docs/architecture/task-migration.md`

### 建议保留但明确视作历史材料

- `claude_use/GFLskill_task_migration_prompt.md`
- `claude_use/skill_doc_continuation_prompt.md`
- `claude_use/skill_system_report.md`

## 当前判断

从实际代码看，技能迁移主线已经完成了大半，尤其是 `GFLskill` 和 `Javelin` 这条线已经基本收束。

现在最需要的不是继续围绕 `Javelin` 或历史 `event_system.as` 做计划，而是：

1. 继续收敛 `commandskill.as`
2. 继续收敛 `call_event_handler.as`
3. 逐步削薄 `kill_event.as`
4. 保持文档与 live 代码状态同步

## 备注

本次盘点基于静态代码检查，没有在游戏内做行为回归验证，因此这里只确认结构落地情况，不替代实机测试。
