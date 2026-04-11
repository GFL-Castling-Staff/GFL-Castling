# GFL-Castling 技能系统架构说明

## 目标

本文档用于说明当前技能系统的分层、运行路径、主要技术债，以及后续改造时应遵循的方向。

## 背景

GFL-Castling 是基于 AngelScript 的 RWR 模组。脚本没有独立构建步骤，运行时由游戏引擎解释执行。

当前技能相关逻辑主要分为三条链路：

1. 主动技能系统：玩家输入 `/skill` 后触发
2. 被动/事件技能系统：技能专用 projectile 命中后通过 `notify_script` 触发
3. Task 系统：承担延时、重复、多阶段行为执行

项目已经建立起稳定的 Task 基础设施，但仍保留部分旧式 `array + update()` 结构，主要集中在 `commandskill.as` 与 `event_system.as`。

## 核心文件

### 主动技能

- `packages/GFL_Castling/scripts/trackers/commandskill.as`
- `packages/GFL_Castling/scripts/core/command_skill_info.as`

`commandskill.as` 负责聊天指令入口、冷却判断、技能分发与大量主动技能实现。

`command_skill_info.as` 负责 `weapon key -> active case` 映射。

### 被动技能

- `packages/GFL_Castling/scripts/trackers/GFLskill.as`
- `packages/GFL_Castling/scripts/core/gfl_skill_info.as`
- `packages/GFL_Castling/scripts/trackers/javelin_tracker.as`

`GFLskill.as` 负责接收技能 projectile 的 `notify_script` 回调，并按 `case` 执行二段效果。

`gfl_skill_info.as` 当前主要承担 `notify_script key -> passive case` 映射。

`javelin_tracker.as` 已作为独立模块接管 Javelin 的多阶段状态管理。

### Task 执行框架

- `packages/GFL_Castling/scripts/internal/task_sequencer.as`
- `packages/GFL_Castling/scripts/trackers/GFLtask.as`

`task_sequencer.as` 定义 `Task`、`TaskSequencer`、`TaskManager`。

`GFLtask.as` 存放项目内的 Task 实现，包括：

- `RepeatEffectTask`
- `DOTEffectTask`
- `XM8SkillTask`
- `HK416SkillTask`
- `UZISkillTask`
- 各类原 `event_system` 事件对应的 Task

### 相关辅助模块

- `packages/GFL_Castling/scripts/trackers/kill_event.as`
- `packages/GFL_Castling/scripts/trackers/event_system.as`
- `packages/GFL_Castling/scripts/core/GFLhelpers.as`
- `packages/GFL_Castling/scripts/trackers/m14_skill_tracker.as`

这些文件共同参与技能触发、击杀联动、定时效果和专用状态管理。

## 运行路径

### 主动技能路径

`/skill` -> `commandskill.as::handleChatEvent` -> `commandSkillIndex[weaponKey]` -> `switch case` -> `excute*Skill()`

主动技能通常会做以下几类事情之一：

1. 直接创建实体或投射物
2. 直接修改角色、物资或阵营状态
3. 创建一个或多个 Task 序列
4. 创建技能专用 projectile，由被动技能系统继续处理

### 被动技能路径

`CreateDirectProjectile/CreateProjectile_H` -> projectile 命中 -> `<result class="notify_script" key="..."/>` -> `GFLskill.as::handleResultEvent` -> `gameSkillIndex[key]` -> `switch case`

因此，被动技能并不是由普通武器子弹直接触发，而是由主动技能过程中创建的技能专用 projectile 间接触发。

### Javelin 路径

Javelin 相关被动 case 10-13 目前已改为：

- `GFLskill.as` 负责接收 `notify_script`
- `javelin_tracker.as` 负责锁定、爬升、攻顶等阶段状态

也就是说，Javelin 不再依赖 `GFLskill.as` 内部手动数组。

### Task 路径

`m_metagame.getTaskManager().newTaskSequencer()` -> `tasker.add(Task)` -> `TaskManager.update()` -> `TaskSequencer.update()` -> `Task.update()`

Task 体系已成为项目内较稳定的延时、多阶段、串行行为执行模型。

## 当前分层状态

项目当前不是“没有架构”，而是“新旧结构并存，但主线方向已明确”。

### 相对稳定的层

- gamemode 装配层
- `commandSkillIndex` / `gameSkillIndex`
- `TaskManager`
- `m14_skill_tracker.as`
- `javelin_tracker.as`
- `tools/skill_data_extractor.py`

### 仍然耦合较重的层

- `commandskill.as` 同时承担入口、冷却、状态、分发、实现
- `event_system.as` 仍保留数组驱动的定时逻辑
- `call_event_handler.as` 等文件仍直接操作 `GFL_event_array`

### 已明显收敛的层

- `GFLskill.as` 已不再承担旧式 tracker 数组生命周期管理
- `gfl_skill_info.as` 已基本回到“索引定义”职责
- `M14` 与 `Javelin` 已有明确状态归属

## 主要技术债

### 1. 超长 switch/case 仍然集中

`commandskill.as` 与 `GFLskill.as` 仍有大型 `switch/case`。问题不在于存在 case，而在于 case 内仍承载较多业务细节。

### 2. 旧式事件数组与 Task 并存

`event_system.as` 仍保留：

- `dictionary GFL_Event_Index`
- `array<GFL_event@> GFL_event_array`
- `update()` 手动倒计时和清理

虽然部分事件执行体已经迁移为 Task，但调度骨架尚未统一。

### 3. 冷却与计时逻辑仍集中在 commandskill.as

`commandskill.as` 中仍维护：

- `SkillArray`
- `TimerArray`
- 对应的 `update()` 倒计时逻辑

这部分仍有进一步抽离空间。

### 4. 文档与运行时代码容易漂移

项目已有 `docs/`、`claude_use/` 与 `tools/` 三类高价值开发资产，但如果不及时同步，过期描述会直接误导后续维护。

## 已确认的改造方向

### 方向一：保留 case 路由，缩小 case 体积

`commandSkillIndex` 与 `gameSkillIndex` 仍适合作为稳定路由层。

后续应把它们收敛为“薄分发器”：

- case 只负责准备参数和调用
- 具体行为放到独立函数、Task 或专用 Tracker 中

### 方向二：Task 与专用 Tracker 并行使用

目标不是“所有内容都必须进通用 Task 基类”，而是让状态归属更清晰。

适合重复/延时/串行执行的逻辑优先进 Task。

像 `Javelin` 这种有独立输入链路与阶段状态的技能，使用专用 Tracker 也是合理方案。

### 方向三：继续收敛 event_system.as

`event_system.as` 已不再是“纯旧系统”，但也还没有完成迁移。

更准确的目标是：

- 保留入口兼容性
- 逐步减少对 `GFL_event_array` 的直接依赖
- 把事件状态与执行逻辑继续拆出

## 当前推荐的执行顺序

### 第一阶段

先修正文档，使开发资料与代码状态一致。

### 第二阶段

继续处理 `event_system.as` 的骨架收敛。

### 第三阶段

继续削薄 `commandskill.as`、`GFLskill.as` 和其他大型分发文件。

## 对后续改动的要求

1. 注释保持中文
2. 保持现有命名习惯，如 `m_` 前缀、`excute` 固定拼写
3. 新增延时行为时优先考虑 Task 或专用 Tracker
4. 不在大文件中继续新增新的数组 + `update()` 轮询模式
5. 改动运行时代码后同步更新文档或分析工具

## 关联文档

- `docs/architecture/task-migration.md`
- `docs/reports/skill-migration-audit-2026-04-11.md`
- `claude_use/GFLskill_task_migration_prompt.md`
- `claude_use/skill_system_report.md`
- `tools/skill_data_extractor.py`
