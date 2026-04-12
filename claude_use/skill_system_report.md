# GFL-Castling 技能系统全量分析报告（历史快照）

> 原始版本生成日期：2026-04-11

本文件保留为阶段性分析快照，不再作为当前 live 代码状态说明使用。

## 当前状态更正

截至 2026-04-12，下列旧结论已经失效：

- `M14MOD3` 并非由独立 `M14SkillTracker` 管理
- `Javelin` 并非“明确延后”，而是已经迁移到独立 `javelin_tracker.as`
- `event_system.as` 并非当前 live tracker 文件，而是保留在 `deleted_asset/` 中的历史实现

当前 live 代码里：

- `M14` 走 `commandskill.as + GFLtask.as + kill_event.as + GFLplayerlist.as`
- `Javelin` 走 `GFLskill.as + javelin_tracker.as`
- `DOT / XM8 / HK416 / UZI` 已落在 `RepeatEffectTask` 体系
- 当前更值得继续收敛的对象是 `commandskill.as`、`call_event_handler.as`、`kill_event.as`

## 仍可参考的内容

- 技能总量统计与 case 覆盖范围
- 主动/被动技能分类方式
- 文档补充的拆分思路

## 当前应参考的文档

- `CLAUDE.md`
- `docs/architecture/skill-system.md`
- `docs/architecture/task-migration.md`
- `docs/reports/skill-migration-audit-2026-04-11.md`
