# GFL-Castling 技能系统架构说明

## 目标

本文档用于说明当前技能系统的分层、运行路径、主要技术债，以及后续改造时应遵循的方向。

## 背景

GFL-Castling 是基于 AngelScript 的 RWR 模组。脚本没有独立构建步骤，运行时由游戏引擎解释执行。

当前技能相关逻辑主要分为三条链路：

1. 主动技能系统：玩家输入 `/skill` 后触发
2. 被动/事件技能系统：技能专用 projectile 命中后通过 `notify_script` 触发
3. Task 系统：承担延时、重复、多阶段行为执行

项目已经建立起稳定的 Task 基础设施，但仍保留部分旧式 `array + update()` 结构，主要集中在 `commandskill.as` 与 `call_event_handler.as`。

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
- `M14SkillActiveTask`
- `M14SkillEndTask`
- 若干由旧事件系统思路沉淀下来的 Task 实现

### 相关辅助模块

- `packages/GFL_Castling/scripts/trackers/kill_event.as`
- `packages/GFL_Castling/scripts/trackers/call_event_handler.as`
- `packages/GFL_Castling/scripts/core/GFLhelpers.as`
- `packages/GFL_Castling/scripts/core/GFLplayerlist.as`

这些文件共同参与技能触发、击杀联动、定时效果和玩家状态管理。

### 历史文件

- `deleted_asset/script/event_system.as`

该文件保留为历史参考，不在当前 live tracker 链中。

## 运行路径

### P22 两次施放三向支援

P22 的主动 `case 6` 先记录瞄准位置 A，放置轮廓外透明的小号 G&K / GRIFFIN 盾形脉冲信标；再根据第二次玩家位置 P、A 和第二次瞄准位置 B 选择左、中、右。B 只用于选分支，A 是支援目标。

- 左：从玩家处向 A 抛出闪光弹，碰撞后闪光并给附近玩家补充白名单投掷物；受补给者显示手雷++，本人听到奖励提示音。
- 中：B 在 A 周围半径 10 米内时，在 A 周围 15 米恢复 10 次装备损耗；直接复用已有绿环和 dev 的小号青色治疗十字，保留类固醇音效。圈外才相对 P->A 判左右。
- 右：向 A 抛出烟雾弹，碰撞后释放原有烟雾弹载荷。两种投掷均可能被掩体提前截住。
- 状态归属 `GFL_playerInfo.m_p22Selection`，`P22SelectionTimeoutTask` 计时并发送短信标脉冲，不做引擎查询。6 秒超时撤销选择，不消耗技能或进入冷却；死亡、断线和角色/阵营/主武器变化也清理选择。
- 中、左通过 `p22_support.projectile -> notify_script -> GFLskill.as` 做单次范围查询，在回调内读取受益者实时位置和投掷栏，调用现有 `healCharacter` / `GrenadeSupply`。主动入口和超时 Task 不做附近角色查询。

参数、资源和入局测试步骤见 [P22 三向支援说明](../design/p22-directional-support.md)。

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

### M14MOD3 路径

M14MOD3 当前不是独立 tracker 路径，而是：

- `commandskill.as` 负责技能入口
- `GFLtask.as` 负责技能生效期与结束清理
- `kill_event.as` 负责击杀联动
- `GFLplayerlist.as` 负责轻量 tag 状态

这意味着 M14 已完成状态归位，但落点是现有玩家状态与 Task 链路，而不是单独的 `m14_skill_tracker.as`。

### Task 路径

`m_metagame.getTaskManager().newTaskSequencer()` -> `tasker.add(Task)` -> `TaskManager.update()` -> `TaskSequencer.update()` -> `Task.update()`

Task 体系已成为项目内较稳定的延时、多阶段、串行行为执行模型。

## 当前分层状态

项目当前不是“没有架构”，而是“新旧结构并存，但主线方向已明确”。

### 相对稳定的层

- gamemode 装配层
- `commandSkillIndex` / `gameSkillIndex`
- `TaskManager`
- `javelin_tracker.as`
- `GFLplayerlist.as`
- `tools/skill_data_extractor.py`

### 仍然耦合较重的层

- `commandskill.as` 同时承担入口、冷却、状态、分发、实现
- `call_event_handler.as` 仍保留较厚的分发与冷却更新逻辑
- `kill_event.as` 中仍混有部分技能联动实现

### 已明显收敛的层

- `GFLskill.as` 已不再承担旧式 tracker 数组生命周期管理
- `gfl_skill_info.as` 已基本回到“索引定义”职责
- `Javelin` 已有明确状态归属
- `M14` 已有明确状态归属，但未拆成独立 tracker

## 主要技术债

### 1. 超长 switch/case 仍然集中

`commandskill.as` 与 `GFLskill.as` 仍有大型 `switch/case`。问题不在于存在 case，而在于 case 内仍承载较多业务细节。

### 2. 冷却与计时逻辑仍集中在 commandskill.as

`commandskill.as` 中仍维护：

- `SkillArray`
- `TimerArray`
- 对应的 `update()` 倒计时逻辑

这部分仍有进一步抽离空间。

### 3. call_event_handler.as 仍保留旧式 update 驱动

`call_event_handler.as` 仍保留：

- 运行时冷却数组
- `update()` 内手动倒计时
- 大量按 case 分发创建 Task 的逻辑

它比历史 `event_system.as` 更接近当前 live 代码里的收敛对象。

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

### 方向三：优先收敛 live 旧式分发层

当前更值得继续处理的是：

- `commandskill.as`
- `call_event_handler.as`
- `kill_event.as` 中偏重的技能联动片段

历史 `event_system.as` 仍可作为参考，但不应再被视为当前 live 收敛目标。

## 当前推荐的执行顺序

### 第一阶段

先修正文档，使开发资料与代码状态一致。

### 第二阶段

继续处理 `commandskill.as` 与 `call_event_handler.as` 的骨架收敛。

### 第三阶段

继续削薄 `GFLskill.as`、`kill_event.as` 和其他大型分发文件。

## 维护约定

为了不打断现有制作节奏，当前不要求对 `commandskill.as`、`call_event_handler.as`、`kill_event.as` 做一次性重构，但建议按以下边界继续维护。

### commandskill.as

可以继续承担：

- `/skill` 入口
- 冷却检查与基础提示
- 简单主动技能的直接实现
- 对 Task、辅助函数或其他模块的分发调用

不建议继续新增：

- 多阶段状态机的大段实现
- 需要长期运行时状态的专属数组
- 依赖击杀事件或复杂外部联动的大段逻辑

经验规则：

- 简单、一次性、即时生效的主动技能，继续写在 `commandskill.as` 是可接受的
- 复杂技能至少应先提成同文件小函数；若已有持续状态、击杀联动、延时链路，再考虑放到 Task 或其他模块

### call_event_handler.as

可以继续承担：

- 事件入口
- 轻量的参数整理与分发
- 创建 TaskSequencer 并启动已有 Task
- 通用的冷却或调用限制检查

不建议继续新增：

- 大段专属业务实现
- 难以复用的技能私有状态
- 与其他系统强耦合的长逻辑分支

经验规则：

- 若一个 call/event 分支只是“校验后启动已有 Task”，可以继续留在这里
- 若一个分支已经开始包含专属状态、专属清理、专属 update 思路，应优先外提

### kill_event.as

可以继续承担：

- `character_kill` 事件入口
- 击杀后的早期筛选
- 轻量的奖励、清理与分发调用
- 对已有技能模块的 on-kill 转发

不建议继续新增：

- 完整技能实现直接堆在事件分支里
- 多技能共享状态与专属状态混写
- 清理逻辑、奖励逻辑、技能逻辑相互穿插的大段代码

经验规则：

- `kill_event.as` 可以继续作为总入口
- 但复杂击杀联动应逐步变成“入口筛选 + 调用小函数/Task/专用模块”的形式

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
