# GFL-Castling 技能系统架构说明

## 目标

本文档用于说明 GFL-Castling 当前技能系统的分层、运行路径、主要技术债务，以及后续重构时应遵循的方向。

本文档面向项目开发者，不面向玩家。

## 背景

GFL-Castling 是 Running With Rifles 的 AngelScript 模组。脚本没有独立构建步骤，运行时由游戏引擎解释执行。

当前技能系统已经形成两条并行但互相关联的执行链：

1. 主动技能系统：玩家输入 `/skill` 后触发。
2. 被动/事件技能系统：技能专用 projectile 触发 `notify_script` 后执行。

项目已经具备一套更规范的 Task 执行框架，但旧式的 tracker 数组 + `update()` 手动遍历模式仍然与其并存。

## 核心文件

### 主动技能

- `packages/GFL_Castling/scripts/trackers/commandskill.as`
- `packages/GFL_Castling/scripts/core/command_skill_info.as`

`commandskill.as` 负责聊天指令入口、冷却判定、技能分发和大量主动技能实现。

`command_skill_info.as` 负责 `weapon key -> active case` 的映射。

### 被动技能

- `packages/GFL_Castling/scripts/trackers/GFLskill.as`
- `packages/GFL_Castling/scripts/core/gfl_skill_info.as`

`GFLskill.as` 负责接收技能 projectile 的 `notify_script` 回调，并按 case 执行二段效果。

`gfl_skill_info.as` 负责 `notify_script key -> passive case` 的映射。

### Task 执行框架

- `packages/GFL_Castling/scripts/internal/task_sequencer.as`
- `packages/GFL_Castling/scripts/trackers/GFLtask.as`

`task_sequencer.as` 定义 `Task`、`TaskSequencer`、`TaskManager`。

`GFLtask.as` 存放项目内的 Task 实现，是后续技能迁移的主要承载位置。

### 相关辅助模块

- `packages/GFL_Castling/scripts/trackers/kill_event.as`
- `packages/GFL_Castling/scripts/trackers/event_system.as`
- `packages/GFL_Castling/scripts/core/GFLhelpers.as`
- `packages/GFL_Castling/scripts/trackers/m14_skill_tracker.as`

这些文件共同参与技能触发、击杀事件联动、定时效果和 M14 特化逻辑。

## 运行路径

### 主动技能路径

运行链路如下：

`/skill` -> `commandskill.as::handleChatEvent` -> `commandSkillIndex[weaponKey]` -> `switch case` -> `excute*Skill()`

主动技能通常会做以下几类事情之一：

1. 直接创建实体或投射物。
2. 直接修改角色、物资或阵营状态。
3. 创建一个或多个 Task 序列。
4. 创建技能专用 projectile，交由被动技能系统继续处理。

### 被动技能路径

运行链路如下：

`CreateDirectProjectile/CreateProjectile_H` -> projectile 命中 -> `<result class="notify_script" key="..."/>` -> `GFLskill.as::handleResultEvent` -> `gameSkillIndex[key]` -> `switch case`

因此，被动技能不是由普通武器子弹直接触发，而是由主动技能过程中的专用 projectile 间接触发。

### Task 路径

运行链路如下：

`m_metagame.getTaskManager().newTaskSequencer()` -> `tasker.add(Task)` -> `TaskManager.update()` -> `TaskSequencer.update()` -> `Task.update()`

Task 框架已经是项目内更稳定的延时、多阶段、串行行为执行模型。

## 当前分层状态

项目当前不是“没有架构”，而是“新旧架构并存”。

### 已经相对稳定的层

- 入口与 gamemode 装配层
- `commandSkillIndex` / `gameSkillIndex` 这类索引层
- `TaskManager` 执行层
- `tools/skill_data_extractor.py` 这类离线分析工具

### 仍然耦合严重的层

- `commandskill.as` 同时承担入口、冷却、状态、分发、实现
- `GFLskill.as` 同时承担事件入口、case 分发、旧 tracker 生命周期管理
- `kill_event.as` 中混入特定技能状态逻辑
- `event_system.as` 仍然存在独立的数组驱动定时逻辑

## 主要技术债务

### 1. 超长 switch/case 逻辑集中

`commandskill.as` 和 `GFLskill.as` 中的大型 `switch/case` 使新增技能、定位技能和修改技能的成本持续升高。

问题不在于有 case，而在于 case 内承载了过多业务细节。

### 2. 旧 tracker 模式与 Task 模式并存

部分技能已经迁移到 Task，但仍有技能保留了：

- 自定义 tracker 类
- 全局数组或成员数组
- `update()` 手动 tick
- 到时执行一次后 `removeAt`

这类逻辑与 Task 的职责重叠，导致系统存在两套并行的“延时行为框架”。

### 3. 技能状态散落

典型例子是 M14 相关状态曾分散在：

- `commandskill.as`
- `kill_event.as`
- Task 类本身

这会造成状态归属不清、调试困难、修改一处要连带检查多处。

### 4. 数据与逻辑混杂

`girl_index.as`、技能映射和一部分行为定义高度耦合。随着角色和皮肤持续增加，超大索引文件会越来越难维护。

### 5. 开发文档和运行时代码容易漂移

项目已经有 `claude_use/` 和 `tools/` 两类高价值开发资产，但如果没有正式沉淀到仓库文档，后续很容易再次出现信息漂移。

## 已确认的重构方向

### 方向一：保留 case 路由，缩小 case 体积

`commandSkillIndex` 和 `gameSkillIndex` 仍然适合作为稳定路由层。

后续重构不需要消灭 `switch/case`，而应当把它们变成“薄分发器”：

- case 只负责参数准备和调用
- 具体行为放到独立函数、独立 Task 或独立 tracker 中

### 方向二：Task 成为唯一主执行模型

凡是“延迟执行”、“重复执行”、“多阶段执行”的技能，都应优先迁移到 Task 体系。

目标不是一次性全部替换，而是让旧 tracker 模式逐步退出主流程。

### 方向三：技能状态归属明确化

每个复杂技能都应明确状态归属：

- 通用状态放公共系统
- 技能专有状态放独立 tracker 或专有管理器
- 不再把专有状态散落在多个大文件顶部

### 方向四：离线工具正式纳入开发工作流

`tools/skill_data_extractor.py` 已经证明该项目非常适合“离线分析 + 运行时脚本”双轨协作。

后续应把以下内容继续工具化：

- 技能 case 覆盖率
- 旧 tracker 与 Task 迁移状态
- 武器、projectile、notify key 映射一致性
- 文档生成或校验

## 当前推荐的执行顺序

### 第一阶段

先清理已经部分迁移完成、但状态仍然分散的技能。

当前最优先的是：

1. M14 相关状态封装
2. 旧 tracker 向 Task 的抽象提炼

### 第二阶段

对重复模式明显的技能进行批量迁移。

优先处理：

- DOT 类
- XM8 类
- HK416 类
- UZI 类

这些技能更容易抽象出通用的重复效果 Task 基类。

### 第三阶段

在主要迁移完成后，再处理更复杂的特殊技能和状态机技能。

例如：

- Javelin
- 充能类技能
- 变身类技能

## 对后续改动的要求

后续进行技能系统改动时，建议遵守以下原则：

1. 注释保持中文。
2. 保持现有命名习惯，例如 `m_` 前缀、`excute` 拼写。
3. 优先新增薄封装，不在大文件里继续堆叠 case 体积。
4. 新增延时行为时，优先考虑 Task，而不是再新增一套数组 + `update()` 遍历逻辑。
5. 新增技能后，同步补充离线工具或文档，避免运行时实现与开发资料脱节。

## 关联文档

- `docs/architecture/task-migration.md`
- `claude_use/GFLskill_task_migration_prompt.md`
- `claude_use/skill_system_report.md`
- `tools/skill_data_extractor.py`
