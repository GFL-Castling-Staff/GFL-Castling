# 2026-04-12｜非当前任务｜GFL-Castling 技能系统全量分析报告（历史快照）

> 原始版本生成日期：2026-04-11

本文档保留为阶段性分析快照，不再作为当前 live 代码状态说明。

## 当前状态修正

截至 2026-04-12，下列旧结论已经失效：

- `M14MOD3` 并非由独立 `M14SkillTracker` 管理
- `Javelin` 并非“明确延后”，而是已迁移到独立 `javelin_tracker.as`
- `event_system.as` 并非当前 live tracker 文件，而是保留在 `deleted_asset/` 中的历史实现

当前 live 代码中：

- `M14` 主要落在 `commandskill.as + GFLtask.as + kill_event.as + GFLplayerlist.as`
- `Javelin` 主要落在 `GFLskill.as + javelin_tracker.as`
- `DOT / XM8 / HK416 / UZI` 已落入 `RepeatEffectTask` 体系
- 当前更值得继续整理的对象是 `commandskill.as`、`call_event_handler.as`、`kill_event.as`

## 仍可参考的内容

- 技能总量统计与 `case` 覆盖范围
- 主动/被动技能的分类思路
- 文档补充时的拆分方法

## 当前应参考的文档

- `CLAUDE.md`
- `docs/architecture/skill-system.md`
- `docs/architecture/task-migration.md`
- `docs/reports/skill-migration-audit-2026-04-11.md`
