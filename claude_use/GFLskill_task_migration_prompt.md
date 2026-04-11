# GFLskill Task 迁移提示稿（历史文档）

本文件是技能迁移过程中的阶段性提示稿，保留仅用于回顾当时的改造思路。

## 当前状态说明

截至 2026-04-12，以下结论已经发生变化：

- `M14` 已封装进独立 `m14_skill_tracker.as`
- `Javelin` 已迁移进独立 `javelin_tracker.as`
- `GFLskill.as` 不再维护旧式 Javelin 手动数组
- `GFLskill.as::update(float time)` 当前为空实现

因此，本文件中凡是把 `M14`、`Javelin`、`GFLskill` 旧式 tracker 作为“待迁移对象”的描述，都应视为历史上下文，而不是当前状态。

## 仍然有参考价值的部分

- 当时对 `RepeatEffectTask` 的抽象思路
- 对 `switch/case` 保留为路由层的设计取向
- 对“不要在分发层继续堆叠数组 + update 逻辑”的约束

## 当前应参考的文档

- `docs/architecture/skill-system.md`
- `docs/architecture/task-migration.md`
- `docs/reports/skill-migration-audit-2026-04-11.md`
