# 技能文档化工作——续写指导 Prompt

> 本文档供下一次 Claude Code 会话使用，提供完整上下文和具体任务步骤。

---

## 项目背景

GFL-Castling（异向易位）是 Running With Rifles 的少女前线同人模组，AngelScript 编写，无编译步骤。

**本次任务的目标**：为模组中所有人形的主动技能和被动技能整理一份完整的数据与描述文档，用于游戏设计审查、数值平衡和后续开发参考。

---

## 已完成的工作

### 1. 自动化数据提取脚本
路径：`media/tools/skill_data_extractor.py`

已自动提取并输出到 `media/tools/output/`：
- `skill_case_index.csv` — 所有 case 编号、函数标签、基础冷却、关联被动 case
- `weapon_skill_map.csv` — 390 个武器 key 的主动/被动技能映射
- `tdoll_skill_table.csv` — 906 个人形变种的完整技能表（含 index/skin/mod/weapon/技能 case）
- `all_data.json` — 上述所有数据的 JSON 结构化转储

运行方式：
```bash
cd media/tools
python skill_data_extractor.py   # 无需第三方库
```

### 2. 全量技能分析报告
路径：`media/claude_use/skill_system_report.md`

包含：两套技能系统的完整 case 表、实现类型分析、冷却分布、Task 迁移进度。

### 3. Task 系统迁移进度（截至 2026-04-11）
- ✅ DOT_tracker 已迁移
- ✅ XM8tracker 已迁移
- ✅ HK416_tracker 已迁移
- ✅ UZI_tracker 已迁移
- ✅ M14MOD3 已封装进独立 Tracker
- ❌ Javelin 明确延后（多阶段状态机）

---

## 关键架构说明（必读）

### 两套技能系统

**主动技能**（`commandskill.as`）：
- 入口：`handleChatEvent` → `commandSkillIndex[weaponKey]` → `switch-case` → `excute*Skill()`
- 所有技能都经过 `excuteCooldownCheck` + `addCooldown`
- 冷却公式：`实际冷却 = max(基础冷却 × CDR − CDM, 0.1)`

**被动技能**（`GFLskill.as`）：
- 入口：`handleResultEvent` → `gameSkillIndex[key]` → `switch-case`
- 触发源：主动技能函数通过 `CreateDirectProjectile` 动态创建"技能弹头"，弹头命中时触发
- **不是**武器普通子弹直接触发

### 关键文件路径
```
packages/GFL_Castling/scripts/
├── trackers/
│   ├── commandskill.as        主动技能（5250行）
│   ├── GFLskill.as            被动技能（1896行）
│   ├── GFLtask.as             Task 类定义
│   └── kill_event.as          击杀事件处理
├── core/
│   ├── command_skill_info.as  commandSkillIndex 字典（591行）
│   ├── gfl_skill_info.as      gameSkillIndex 字典（230行）
│   ├── girl_index.as          人形 index 字典（1892行）
│   └── GFLhelpers.as          辅助函数（CreateDirectProjectile等）
└── internal/
    └── task_sequencer.as      Task/TaskSequencer/TaskManager 基础定义
```

---

## 下一步任务：技能描述补充

### 任务目标
生成一份人形技能数据表，格式类似：

```
| 人形（weapon key） | 主动技能 | 冷却 | 效果描述 | 被动技能 | 效果描述 |
```

最终应涵盖所有 97 个主动 case 和 69 个被动 case 的效果描述。

---

### 分批方案（推荐按此顺序）

#### 第 1 批：投射物生成类（约 35 个主动 case）
这类技能逻辑最简单，描述模式相近：创建 N 个 X 弹头于 Y 位置。

**建议描述模板**：
> 在目标位置创建 [N] 个 [弹头类型] 投射物，[范围/伤害特性]。

需要读的函数（在 `commandskill.as` 中按名称搜索）：
- `excuteAN94skill` — AN94
- `excuteFirenadeskill` — Vector等燃烧弹
- `excuteG3mod3skill` — G3 MOD3
- `excuteStg44MOD3skill` — STG44 MOD3
- 等等...

读取 `CreateDirectProjectile` 和 `CreateProjectile_H` 调用，找到弹头 key，再读对应 `.projectile` 文件获取伤害参数。

#### 第 2 批：目标锁定狙击类（约 8 个 case：51/53/43/56/82/86/89/21）
描述模式：搜索范围内最近敌人 → 直接命中。

**建议描述模板**：
> 自动锁定 [范围] 内最近敌人，[瞬间/延迟] 造成 [高额] 伤害。

#### 第 3 批：Task 序列复杂技能（约 25 个 case）
包含多阶段、动画、音效等，需要读 Task 类定义。

**建议描述模板**：
> [触发条件]，[第一阶段效果]；[间隔]后重复 [N] 次，[追加效果]。

重点 case：
- 19（XM8 MOD3）— 读 `GFLtask.as` 中的 `XM8SkillTask`
- 36/37（HK416 MOD3）— 读 `HK416SkillTask`
- 50（UZI MOD3）— 读 `UZISkillTask`
- 84（AEK999）— 读变身 Task

#### 第 4 批：特殊机制技能（M14/标枪/充能等）
- **M14 MOD3**（case 85）：读 `m14_skill_tracker.as`，描述击杀连锁火箭弹机制
- **Javelin**（passive case 10-13）：4 阶段状态机，读 `GFLskill.as` case 10-13
- **SIG MCX**（case 91）：充能机制，读 `excuteSIGMCXSkill`

---

### 操作建议

1. **从 `tools/output/skill_case_index.csv` 出发**，按 case 编号逐个处理
2. 在 `commandskill.as` 中搜索对应函数名（pattern：`void excute{label}skill`）
3. 读函数体 → 提取弹头 key → 读 `.projectile` 文件 → 写描述
4. 被动技能描述直接读 `GFLskill.as` 对应 case 代码
5. 描述用**中文**，简洁清晰，重点说游戏效果（不要照抄代码逻辑）

---

### 输出格式建议

推荐生成 `media/claude_use/skill_descriptions.md`，结构：

```markdown
## 主动技能描述

### case 1 — AN94 MOD3
- **武器**：gkw_an94_mod3.weapon 等（共 8 个变种）
- **冷却**：30s（基础）
- **效果**：...

### case 2 — 燃烧弹系（Vector / Vz61 / Klin / UZI / MP40 / KP31）
- **武器**：gkw_vector.weapon 等（共 N 个变种）
- **冷却**：12s（基础）
- **效果**：...
- **关联被动**：case 14（燃烧弹）
```

---

### 上传给 Claude 的文件清单

进行描述撰写时，按需上传：

| 需要描述的技能类型 | 需要上传的文件 |
|---|---|
| 全部主动技能 | `commandskill.as`、`command_skill_info.as` |
| 被动技能 | `GFLskill.as`、`gfl_skill_info.as` |
| Task 实现的技能 | 还需 `GFLtask.as`、`task_sequencer.as` |
| M14 专项 | 还需 `m14_skill_tracker.as`（如已存在）|
| 弹头伤害参数 | 具体 `.projectile` 文件（按需） |
| 辅助函数参考 | `GFLhelpers.as` |

可以配合 `tools/output/all_data.json` 作为索引，不需要重复解析字典。

---

## 附：编码规范提醒

- 注释写中文
- 变量命名用 `m_` 前缀
- `excute`（不是 execute）是项目固定拼写，不要纠正
- Conventional Commits 格式提交：`docs: add skill descriptions`
