# 2026-04-12｜非当前任务｜技能文档续写提示稿（历史文档）

本文档原本用于指导一次阶段性的技能说明补全文档工作，现保留为历史提示稿。

## 当前状态说明

截至 2026-04-12，本文中以下判断已过时：

- 把 `Javelin` 视为“明确延后”的对象
- 把 `Javelin` 视为 `GFLskill.as` 内部残留状态机
- 把 `M14` 视为待拆分为独立 tracker
- 把 `event_system.as` 视为当前 live 主链文件

当前代码中：

- `Javelin` 已由 `javelin_tracker.as` 独立管理
- `M14` 已完成状态归位，当前落点为 `commandskill.as + GFLtask.as + kill_event.as + GFLplayerlist.as`
- `event_system.as` 位于 `deleted_asset/`，属于历史文件
- 当前更值得持续整理的是 `commandskill.as` 与 `call_event_handler.as`

## 保留原因

这份提示稿仍可用于回顾技能文档化工作的拆分思路，但不应继续作为当前迁移进度说明使用。

## 当前应参考的文档

- `docs/architecture/skill-system.md`
- `docs/architecture/task-migration.md`
- `docs/reports/skill-migration-audit-2026-04-11.md`
