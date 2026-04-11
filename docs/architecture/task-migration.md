# GFL-Castling 技能系统 Task 迁移路线

## 目标

本文档用于记录技能系统从“手动 tracker 数组 + update 遍历”迁移到 Task 体系的总体路线，并说明当前已经完成到什么阶段。

## 当前状态

截至 2026-04-12，可以明确确认：

- `M14MOD3` 已封装进独立 `m14_skill_tracker.as`
- `RepeatEffectTask` 已建立
- `DOT / XM8 / HK416 / UZI` 已迁移到 Task
- `Javelin` 已迁移为独立 `javelin_tracker.as`
- `GFLskill.as` 保留 `switch` 分发，但 `update(float time)` 已为空

因此，`GFLskill` 方向的主迁移工作已经基本完成。

## 迁移原则

### 保持外部路由稳定

迁移过程中，以下入口应尽量保持不变：

- `commandskill.as` 中的 `commandSkillIndex + switch`
- `GFLskill.as` 中的 `gameSkillIndex + switch`

重点是缩小 `case` 内部体积，而不是推翻现有路由结构。

### 保持技能效果一致

迁移目标是收敛实现方式，不是重做玩法。

应尽量保持：

- 弹头类型
- 触发时机
- 伤害与范围
- 执行次数
- 间隔时间
- 搜索范围
- 额外音效与视觉效果

### 优先收敛延时/多阶段逻辑

凡是“延时执行”“重复执行”“多阶段执行”的技能，应优先进入：

- `Task`
- 独立 `Tracker`
- 或专用状态管理模块

避免继续在大型分发文件中堆叠新的数组 + `update()` 逻辑。

## 已完成阶段

### 第一阶段：状态归位

已完成：

- `M14MOD3` 状态从分散文件中收束到独立 `m14_skill_tracker.as`

### 第二阶段：重复效果抽象

已完成：

- 建立 `RepeatEffectTask`

### 第三阶段：批量迁移重复模式技能

已完成：

1. `DOT`
2. `XM8`
3. `HK416`
4. `UZI`

### 第四阶段：复杂状态机技能

已完成：

- `Javelin`

说明：

`Javelin` 最终没有被强行套进 `RepeatEffectTask`，而是按其副手武器输入链路与多阶段状态机特性，落到独立 `javelin_tracker.as`。这符合“按职责收敛”的目标。

## 当前剩余工作

`GFLskill` 主线之外，当前更值得继续推进的，是与 Task 方向存在重叠的其他旧式系统。

### 1. event_system.as

当前状态：

- 保留 `GFL_event_array`
- 保留 `GFL_event_system::update(float time)` 手动倒计时
- 部分事件执行体已经迁移为 Task

这说明 `event_system.as` 处于“部分 Task 化、骨架未迁移完成”的状态。

### 2. 分发层瘦身

以下文件仍偏厚：

- `commandskill.as`
- `GFLskill.as`
- `event_system.as`

后续应继续把 case 内实现外提，使这些文件更像“分发器”而不是“业务仓库”。

## 建议的下一步

### 优先级一：收敛 event_system.as

建议先确认 `event_system.as` 的长期目标：

1. 保留事件入口，但把状态管理拆出去
2. 分拆为多个专用 Tracker
3. 或逐步过渡为 Task / Tracker 混合模型

### 优先级二：继续削薄分发层

重点不是删除 `switch`，而是让 `switch` 只负责：

- 参数准备
- 分发调用
- 轻量的入口校验

### 优先级三：同步文档与分析工具

每次迁移完成后，应同步更新：

- `docs/architecture/`
- `claude_use/` 中的历史提示稿状态说明
- `tools/` 中的离线分析输出或校验脚本

## 完成标准

一个技能或子系统完成迁移后，应尽量满足：

1. 运行效果与迁移前一致
2. 原有手动数组与 `update()` 片段已被移除或显著收缩
3. 主要状态有明确归属
4. 分发层没有引入新的耦合

## 当前结论

`GFLskill` 的核心迁移路线已经兑现，本文档不再把 `Javelin` 视为待迁移对象。

后续若继续推进 Task 化，真正更值得处理的是：

- `event_system.as`
- 分发层瘦身
- 文档与代码状态对齐
