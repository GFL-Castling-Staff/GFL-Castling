# HISTORY.md — GFL-Castling（异向易位）归档

> 层 3：已完成事项的归档。**只追加，不修改历史条目。**
> 当前状态见 [PROJECT_STATE.md](PROJECT_STATE.md)；常驻规则见 [CLAUDE.md](CLAUDE.md)。
>
> 本文建立于 2026-08-04，早于该日期的条目是从 git 历史与既有文档回溯整理的，
> 只记录**已核实**的部分。凡未核实的一律不写，宁缺毋编。

---

## 2026-04-05 ～ 2026-04-12 · event_system → Task 体系迁移

**背景**：`trackers/event_system.as` 是早期用于容纳「持续性请求」的系统 ——
一个全局数组 `GFL_event_array` + 每帧 `update` 遍历 + 一个巨型 switch 分发到
各 `excute*` 函数。文件头部很早就写了「已逐步废弃，请使用 task 替代」，
但迁移一直没做完。

**迁移过程**（5 个提交，2026-04-05，作者 SAIWA）：

| 提交 | 内容 |
|---|---|
| `3781bc710` | 增援妖精重构 |
| `c13e1fb02` | ac130 重构 |
| `863f0d170` | 干扰者、闪电风暴、ump45mod3、奶箱重构 |
| `9077b81cc` | 炮击妖精重构 |
| `a734541ae` | 原版勇士妖精重构 |

`GFLtask.as` 增加约 775 行，新建 8 个 Task 类替代原有的 `excute*` 函数：

`Event_call_yaoren_fairy` / `Event_call_rampage_fairy_ac130` / `Skill_SF_Intruder_Spawn` /
`Skill_Lightning_Storm` / `Skill_HK416_Heal` / `Skill_UMP45MOD3_Smoke` /
`Event_call_bomb_fairy` / `Event_call_warrior_fairy_apache`

加上更早迁走的 `Skill_Fairy_Snipe`（狙击妖精）与 `Skill_M200_Snipe`，
原 event_system 的 10 个事件类型全部有了 Task 版本。

**收尾**：`8d6a7a5a0`（2026-04-12）「[Refactor]正式弃用 event_system」，
文件移入 `deleted_asset/script/event_system.as`。

**验收状态**：✅ 已核实（2026-08-04）。`scripts/` 目录下
`GFL_event_array` / `GFL_event_system` / `GFL_Event_Index` 零引用，确已完全退出 tracker 链。

**中途的修订**：`dev-eventsystem` 分叉点上曾遗留一个未切换的入队点 ——
`call_event_handler.as` 里玩家的「炮击妖精」呼叫（case 6）仍在用旧的
`GFL_event_array.insertLast(...bomb_fairy...)`，而同名的「炮击妖精重构」提交
只转换了另外 4 处次级触发路径。该遗漏在后续提交中已收尾，`dev` 上不存在。

**技术债结清**：原 event_system 的 `default: break;` 不出队问题（条目 key 对不上任何 case
时永不删除、每帧空转）随文件退役一并消失。

---

## 2026-04-11 ～ 2026-04-12 · 技能系统迁移盘点

产出三份层 4 文档，仍然有效，见 CLAUDE.md 的参考文档索引：

- [docs/architecture/skill-system.md](docs/architecture/skill-system.md) —— 技能系统分层与运行路径
- [docs/architecture/skill-implementation-guidelines.md](docs/architecture/skill-implementation-guidelines.md) —— 新增/维护技能的推荐写法
- [docs/architecture/task-migration.md](docs/architecture/task-migration.md) —— Task 迁移路线与阶段
- [docs/reports/skill-migration-audit-2026-04-11.md](docs/reports/skill-migration-audit-2026-04-11.md) —— 迁移真实落地状态盘点

**当时的结论**：项目没有必须立刻推进的系统级大迁移；不要为单个技能新建独立 tracker，
优先复用 `GFLplayerlist.as` / `commandskill.as` / `kill_event.as` / `GFLtask.as`。
这条结论已经提炼进 CLAUDE.md 的「Refactor Guardrails」。

---

## 2026-04-12 · OTS14 闪电链开发（后于 2026-08-04 停用）

**做了什么**：为 OTS-14「闪电」突击步枪实现连锁闪电技能，
在 `GFLtask.as` 中建立了一套可复用的连锁效果机制
（`ChainDamageProfile` / `ChainVisualProfile` / `ChainEffectDefinition` /
`ChainExecutionContext` / `ChainTask` / `DelayChainBootstrapTask` /
`startChainEffectFromCandidates`）。

**踩的坑（这部分是本次开发最有价值的产出，已提炼进 CLAUDE.md「Query Handling Notes」）**：

1. **异步 `characters` make_query 不可靠**
   —— 症状：发出去没有对应的 `query_result` 回来。
   根因：项目内没有找到该用法可工作的样本，同步 `players` / `character id=...` 查询正常。
   正确做法：把 nearby 查询当同步阻塞调用用。
2. **同步 nearby 查询在错误的上下文里会卡死**
   —— 症状：运行时死锁。根因：`getCharactersNearPosition(...)` 放进通用 task
   或 bootstrap task 里依然可能挂住，换位置不解决问题。
   正确做法：只在已验证安全的事件上下文（`notify_script` 处理）里做**一次**快照，
   后续跳跃全部走内存快照，不再发查询。
3. **逐跳自定义特效弹头会导致原生崩溃**
   —— 症状：纯伤害跳跃稳定，加上每跳的自定义命中特效弹头后反复原生崩溃。
   正确做法：改用保守的 `particle.projectile` / `para_heal_effect_on_target` 结构。

排查过程的完整记录保存在 `claude_use/2026-04-12_*.md` 五份文件里。

**最终验证通过的范式**（这是本项目做连锁/弹跳/重索敌类效果的唯一参考实现）：

```
commandskill.as 只负责施法门禁 / 动画 / 起始弹头
      ↓
起始弹头触发 notify_script
      ↓
GFLskill.as 处理 notify，做一次同步 getCharactersNearPosition 快照
      ↓
后续跳跃全部从内存快照推进，不再发 nearby 查询
```

---

## 2026-08-04 · OTS14 闪电链停用

**决定**：SAIWA 决定闪电链在后续更新中不再使用。

**做法**：注释入口而非删除代码。三处（第四处先前已注释）：

| 位置 | 内容 | 本轮改动 |
|---|---|---|
| `core/command_skill_info.as` | OTS14 三个 weapon → 技能 98 的映射 | 先前已注释，非本轮 |
| `trackers/commandskill.as` | case 98 施法分发 | ✅ 本轮注释 |
| `core/gfl_skill_info.as` | `"ots14_chain_scan"` → 68 的 notify 映射 | ✅ 本轮注释 |
| `trackers/GFLskill.as` | case 68 处理体 | ✅ 本轮注释 |

同时把 `dev-claude` 上那次「闪电链小加强」（`2bfbd2ee0`，`m_max_jumps` 5→9、
`m_jump_range` 9.0→15.0）回退为 dev 主线值，SAIWA 决定不保留。

**刻意没做的事**：`GFLtask.as` 里约 350 行的连锁机制类定义**未注释**。
入口封死后它们已不可达，留着不影响运行；而本项目没有编译器和 linter，
大段注释类定义只会平白引入语法风险。该权衡已写进代码注释与 PROJECT_STATE.md。

**为什么不删**：这是目前唯一验证通过的连锁效果范式，上面三个坑都是真金白银换来的。
将来做同类效果照抄即可，不要重新趟一遍。

**验收状态**：🟡 **未完成**。只做了括号平衡自检，**没有进过游戏**。
人眼门待 SAIWA 执行：装备 OTS14 按 `/s` 应不报错、不崩溃、无残留动画音效。

---

## 2026-08-04 · 分支清理与文档体系建立

- **删除 `dev-eventsystem`**：`dev..dev-eventsystem` 独有提交数为 0，
  5 个重构提交早已全部并入 `dev`，`origin/dev-eventsystem` 远程也已不存在。
- **合并 `dev` → `dev-claude`**：196 个提交，无冲突。
- **建立层 2 / 层 3 文档**：新建 `PROJECT_STATE.md` 与本文，增量修订 `CLAUDE.md`。
  此前项目只有层 1（CLAUDE.md）和层 4（docs/），缺动态状态与归档。
