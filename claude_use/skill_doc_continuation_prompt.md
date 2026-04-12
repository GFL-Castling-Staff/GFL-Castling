# 技能文档续写提示稿（历史文档）

本文件原本用于指导一次阶段性的技能描述补全文档工作。

## 当前状态说明

截至 2026-04-12，本文件中以下表述已经过期：

- “Javelin 明确延后”
- 任何把 `Javelin` 视为 `GFLskill.as` 内部残留状态机的描述
- 任何仍把 `M14` 视为待抽离为独立 tracker 的描述
- 任何仍把 `event_system.as` 视为当前 live 主链文件的描述

当前代码中：

- `Javelin` 已由 `javelin_tracker.as` 独立管理
- `M14` 已完成状态归位，但落在 `commandskill.as + GFLtask.as + kill_event.as + GFLplayerlist.as`
- `event_system.as` 位于 `deleted_asset/`，属于历史文件
- 当前更值得继续收敛的是 `commandskill.as` 与 `call_event_handler.as`

## 保留原因

这份提示稿仍可用于回顾技能文档化工作的拆分思路，但不应继续作为“当前迁移进度说明”使用。

## 当前应参考的文档

- `docs/architecture/skill-system.md`
- `docs/architecture/task-migration.md`
- `docs/reports/skill-migration-audit-2026-04-11.md`
