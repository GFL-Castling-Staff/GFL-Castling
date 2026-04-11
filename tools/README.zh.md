# GFL-Castling 开发工具

模组开发和数据分析用的辅助脚本。
这些文件**不属于发布的 mod 内容**，存放在 `packages/` 目录之外。

---

## skill_data_extractor.py

从 AngelScript 源码和武器 XML 文件中提取所有人形技能数据，交叉关联后输出结构化表格，用于分析或编写文档。

### 读取的文件

| 源文件 | 提取内容 |
|---|---|
| `core/girl_index.as` | `tdoll_complex_index` — 人形变种 → weapon key 映射 |
| `core/command_skill_info.as` | `commandSkillIndex` — weapon key → 主动技能 case 编号 |
| `core/gfl_skill_info.as` | `gameSkillIndex` — notify_script key → 被动技能 case 编号 |
| `trackers/commandskill.as` | case 标签（`excute*Skill` 函数名）+ 基础冷却时间 |
| `trackers/GFLskill.as` | case 标签（代码中的中文行内注释） |
| `weapons/*.projectile` | 各弹头文件携带的 `notify_script` key |

### 输出文件（写入 `tools/output/`）

| 文件 | 内容 |
|---|---|
| `skill_case_index.csv` | 所有主动/被动 case 编号的主索引，含标签和冷却时间 |
| `weapon_skill_map.csv` | 每个 weapon key 的主动/被动技能映射 |
| `tdoll_skill_table.csv` | 每个人形变种（index/skin/mod）的完整技能信息 |
| `all_data.json` | 上述所有内容的 JSON 结构化转储 |

### 运行方式

需要 Python 3.8+，当前只用标准库，无需安装第三方包。
建议建一个 `.venv` 虚拟环境，方便以后扩展：

```bash
cd media/tools

# 首次使用：建立虚拟环境
python -m venv .venv

# 激活（Windows CMD / PowerShell）
.venv\Scripts\activate
# 激活（Git Bash / WSL）
source .venv/Scripts/activate

# 安装依赖（目前为空，预备未来扩展用）
pip install -r requirements.txt

# 运行脚本
python skill_data_extractor.py
```

`.venv/` 和 `output/` 目录已加入 `.gitignore`，不会入库，按需本地重新生成。

### 字段说明

**tdoll_skill_table.csv**

| 字段 | 含义 |
|---|---|
| `tdoll_index` | 人形数字 ID（与 `modded_key` 中的 index 一致） |
| `skin_id` | 皮肤 ID（0 = 默认皮肤） |
| `mod` | 改造版本：`none`、`mod3`、`only`、`only_exp` 等 |
| `weapon_key` | 该变种使用的 `.weapon` 文件 key |
| `active_case` | `commandskill.as` switch 块中的 case 编号（空 = 无主动技能） |
| `active_label` | 从函数名提取的主动技能标签 |
| `active_cooldown_base_s` | 基础冷却时间（秒），CDR/CDM 修正前的原始值 |
| `passive_cases` | 该武器触发的被动技能 case 编号（竖线分隔） |
| `passive_labels` | 对应被动 case 的标签（竖线分隔） |

### 注意事项

- **基础冷却**取自技能函数体内第一个 `addCooldown(key, N, ...)` 调用。实际游戏冷却 = `max(N × CDR − CDM, 0.1)`，CDR/CDM 来自玩家装备。
- weapon key 不在 `commandSkillIndex` 中 → 该武器无 `/skill` 主动技能。
- 被动技能不由武器普通子弹触发，而是由主动技能函数动态创建的"技能弹头"触发。
- 部分被动 case（妖精指令、NPC boss 技能）没有对应的人形变种，但仍会出现在被动技能索引表中。
