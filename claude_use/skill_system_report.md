# GFL-Castling 技能系统全量分析报告

> 生成日期：2026-04-11  
> 数据来源：`skill_data_extractor.py` 自动提取 + 人工核对  
> 覆盖文件：`commandskill.as`、`GFLskill.as`、`command_skill_info.as`、`gfl_skill_info.as`、`girl_index.as`、`weapons/*.projectile`

---

## 一、总览

| 指标 | 数量 |
|---|---|
| 人形变种总数（含皮肤/mod） | 906 |
| 有主动技能（`/skill` 命令）的变种 | 299 / 906（33%） |
| 主动技能触发被动事件处理的变种 | 58 / 906（6%） |
| 主动技能 case 编号范围 | 0–97（commandskill.as） |
| 被动/事件技能 case 编号范围 | 0–67（GFLskill.as） |
| 主动技能 case 总数 | 97 个（含已注释掉的 case 30） |
| 被动技能 case 总数 | 69 个 |
| 主动 case 同时关联被动 case 的数量 | 18 个 |

### 两套技能系统的触发路径

```
【主动技能系统】commandskill.as
  玩家输入 /skill
    → handleChatEvent
    → commandSkillIndex[weaponKey] → case N
    → excute*Skill() 函数
    → 直接效果 或 创建技能弹头 或 Task 序列

【被动技能系统】GFLskill.as
  commandskill.as 主动技能函数 创建 "技能弹头"（*.projectile）
    → 弹头命中 → <result class="notify_script" key="xxx"/>
    → handleResultEvent
    → gameSkillIndex[key] → case N
    → 执行二次效果
```

> **注意**：被动技能不由武器普通子弹触发，而是由主动技能函数动态创建的专用弹头触发。
> 因此"主动 + 被动"组合是一个整体技能的两个阶段，而非两个独立技能。

---

## 二、主动技能系统（commandskill.as）

共 **97 个有效 case**（case 0 为空占位，case 30 已注释禁用）。

冷却计算公式：`实际冷却 = max(基础冷却 × CDR − CDM, 0.1秒)`  
其中 CDR（冷却倍率）、CDM（冷却减值）来自玩家装备。

### 完整 case 列表

| case | 函数标签 | 基础冷却(s) | 关联被动 case | 说明 |
|------|---------|-----------|-------------|------|
| 0 | — | — | — | 空占位 |
| 1 | AN94 | 30 | — | AN94 MOD3 |
| 2 | Firenade | 12 | 14（燃烧弹） | SMG 燃烧弹系（Vector/Vz61/Klin/UZI/MP40/KP31等） |
| 3 | Justice | 20 | — | FF_JUSTICE 敌方单位技能 |
| 4 | MP5 | 25 | — | MP5 护甲装置 |
| 5 | MP5MOD3 | 25 | — | MP5 MOD3 护甲装置（升级版） |
| 6 | P22 | 12 | — | P22 手枪技能 |
| 7 | HS2000 | 12 | — | HS2000 手枪技能 |
| 8 | Intruder | 45 | — | FF_干扰者 敌方召唤技能 |
| 9 | Agent | 60 | — | FF_特工 敌方召唤技能 |
| 10 | Destroyer | 25 | — | FF_破坏者 敌方技能 |
| 11 | Excutioner | 15 | — | FF_刽子手 敌方技能（按武器分支） |
| 12 | Baibaozi | 15 | — | FF_白憨憨（白教白涩）敌方技能 |
| 13 | G3mod3 | 20 | 19（G3榴弹） | G3 MOD3 榴弹 |
| 14 | UMP45 | 20 | — | UMP45 护甲装置 |
| 15 | M870 | 30 | — | M870 霰弹枪技能 |
| 16 | PP19 | 45 | — | PP19 |
| 17 | PP19（MOD3模式） | 45 | — | PP19 MOD3（调用同一函数带 true 参数） |
| 18 | AK15MOD3 | 20 | — | AK-15 MOD3 |
| 19 | XM8MOD3 | 15 | 7（XM8技能） | XM8 MOD3 |
| 20 | Stg44MOD3 | 15 | 15（STG44炎风暴） | STG44 MOD3 |
| 21 | WerlodMod | 20 | — | Welrod MOD3 无声狙击 |
| 22 | FnFal | 30 | — | FN FAL |
| 23 | M4SOPMODIIMOD3 | 16 | 4（SOPMOD散射榴弹） | M4 SOPMOD II MOD3 |
| 24 | PPSH41 | 15 | — | PPSH-41 |
| 25 | PPSH41MOD3 | 15 | — | PPSH-41 MOD3 |
| 26 | FO12 | 60 | — | FO-12 霰弹枪 |
| 27 | Flashbang | 12 | — | 闪光弹系（Type79/UMP9/MAB38/64式/M16A1/M9） |
| 28 | UMP9 | 60 | 5（白鸮轰鸣） | UMP9 MOD3 |
| 29 | Mab38 | 16 | 14（燃烧弹） | MAB38 MOD3 |
| ~~30~~ | ~~AK12SE~~ | ~~120~~ | — | **已禁用**（注释掉） |
| 31 | PPKMOD3 | 90 | — | PPK MOD3 |
| 32 | MLE | 20 | — | Ribeyroles（利贝罗勒）MOD3 治疗 |
| 33 | MG4MOD3 | 90 | — | MG4 MOD3 |
| 34 | LiuRF | 300 | — | 刘氏步枪 协同攻击（超长冷却） |
| 35 | SAT8 | 15 | 29（SAT8 pizza） | SAT8 |
| 36 | HK416mod3 | 16 | 8（HK416寄生榴弹） | HK416 MOD3 |
| 37 | HK416mod3（3401皮肤） | 16 | 8（HK416寄生榴弹） | HK416 3401皮肤专属版本 |
| 38 | Grenade | 15 | — | SMG 手雷系（Sten/M3/SAF） |
| 39 | Alchemist | 25 | 23（炼金术师脚本榴弹） | FF_炼金术师 大限 |
| 40 | 88type | 20 | — | 汉阳造 88式（普通） |
| 41 | 88type（MOD3） | 20 | — | 汉阳造 88式 MOD3（充能雷） |
| 42 | 88typeGUNDAM | 40 | — | 汉阳造高达（6503皮肤）攻顶火箭 |
| 43 | M200 | 45 | — | M200 无言杀意 |
| 44 | CZ75 | 15 | — | CZ75 |
| 46 | G41Only | 15 | — | G41 Only专属版本 |
| 47 | UMP45MOD3 | 20 | 28（烟雾弹） | UMP45 MOD3 |
| 48 | Weaver | 25 | 32（衔尾蛇脚本榴弹） | FF_衔尾蛇 |
| 49 | M1928A1 | 45 | — | 汤普森 M1928A1 |
| 50 | UZImod3 | 15 | 33（UZI燃烧弹） | UZI MOD3 燃烧链接 |
| 51 | SniperSkill_Antiperson | 20 | — | 狙击锁人版（M1903/M1/M1891/M21/PSG1/QBU88/SV98/SUPER SASS/Thunder/98K/SCAR-H/Contender） |
| 52 | Carcano1938 | 5 | — | Carcano M1938（极短冷却，5s） |
| 53 | SniperSkill_Pos | 60 | — | 狙击坐标版（M99/PTRD/NTW20/RT20/M82A1/Gepard M1） |
| 54 | F1 | 15 | — | F1（含 F1 MOD3） |
| 55 | BBSRobot | 15 | — | 波波沙机甲 BBS |
| 56 | SVDEX | 12 | — | SVD EX |
| 57 | HK416Agent | 30 | 39（hk416 medic aid） | 特工416 奶箱版 |
| 58 | Erma | 300 | — | Erma（超长冷却，300s） |
| 59 | 64typemod3 | 20 | — | 64式 MOD3 |
| 60 | ZasM21 | 20 | — | Zas M21 |
| 61 | C96MOD | 120 | — | C96 MOD |
| 62 | _AGS30_ | 30 | — | AGS-30 |
| 63 | _QLZ04_Skill_Smoke | 20 | — | QLZ04 烟雾弹 |
| 64 | _QLZ04_Skill_Fire | 20 | 14（燃烧弹） | QLZ04 燃烧弹 |
| 65 | Werlod | 20 | — | Welrod 普通版 |
| 66 | PA15 | 20 | — | PA15（多个皮肤） |
| 67 | NagantM1895 | 300 | — | Nagant M1895 MOD3（超长冷却） |
| 68 | MosinNagant | 15 | — | 莫辛-纳甘 |
| 69 | Kar98k | 25 | — | Kar98k MOD3 |
| 70 | GM6Lynx | 30 | — | GM6 Lynx |
| 71 | M1911 | 30 | — | M1911 |
| 72 | M1911mod3 | 30 | — | M1911 MOD3 |
| 73 | Hunter | 30 | — | FF_猎手 boss 技能 |
| 74 | Dreamer | 30 | — | FF_梦想家 boss 技能 |
| 75 | StenSterling | 15 | — | Sten MOD3 / Sterling |
| 76 | MAC10 | 30 | — | MAC-10 |
| 77 | Owen | 60 | — | Owen SMG |
| 78 | M1897MOD3 | 15 | — | M1897 MOD3 |
| 79 | Type82 | 15 | — | 82式步枪 |
| 80 | Gsh18 | 45 | — | GSH-18 MOD3（医疗） |
| 81 | Fedorov | 90 | — | 费多罗夫 |
| 82 | Tac50 | 90 | — | TAC-50 |
| 83 | OBRMod3 | 30 | — | OBR MOD3 刀片投射 |
| 84 | AEK999 | 300 | — | AEK-999（超长冷却，含 Task 变身机制） |
| 85 | M14MOD3 | *特殊* | — | M14 MOD3（火箭弹奖励系统，独立 Tracker 管理） |
| 86 | Delisle | 30 | — | De Lisle 卡宾枪 |
| 87 | 56typeRifle | 30 | — | 56式步枪 MOD3 |
| 88 | Evo3 | 30 | 62（evo3毒气弹） | Evo3 MOD3 |
| 89 | SSG3000 | 45 | — | SSG 3000 |
| 90 | QBZ95 | 40 | — | QBZ-95 |
| 91 | SIGMCX | 10 | — | SIG MCX（充能系统，5档） |
| 92 | ZasM21mod3 | 30 | — | Zas M21 MOD3 |
| 93 | Webley | 120 | — | Webley 左轮 |
| 94 | NytoBlack | 1.5 | — | FF_涅托黑（极短冷却，敌方用） |
| 95 | Scarecrow | 20 | — | FF_稻草人 |
| 96 | G36 | 30 | 66（G36毒奶） | G36 MOD3 |
| 97 | MP7 | 30 | — | MP7 |

### 冷却时间分布

| 区间 | 数量 | 代表武器 |
|---|---|---|
| ≤ 5s | 2 | Carcano(5s)、NytoBlack(1.5s) |
| 6–15s | 22 | XM8/HK416/UZI/PPSH/Sten/SAT8 等 |
| 16–30s | 40 | 大多数 AR/SMG/HG |
| 31–60s | 20 | AN94/M870/PP19/FO12/UMP9等 |
| 61–120s | 6 | PPKMOD3/MG4/C96/Fedorov/TAC50/Webley |
| 300s | 4 | LiuRF/Erma/NagantM1895/AEK999 |
| 特殊 | 1 | M14MOD3（由击杀事件驱动，无固定冷却） |

---

## 三、被动技能系统（GFLskill.as）

共 **69 个 case**（含 case 0 空占位，case 43 已注释禁用）。

触发方式：特定技能弹头命中时，弹头的 `<result class="notify_script" key="..."/>` 触发 `handleResultEvent`，通过 `gameSkillIndex` 字典分发到对应 case。

### 完整 case 列表

| case | notify_script key | 说明 | 所属主动 case |
|------|-----------------|------|-------------|
| 0 | （空） | 占位 | — |
| 1 | aa_spawn | 生成防空炮 | 非技能触发 |
| 2 | aa_destroy | 摧毁防空炮 | 非技能触发 |
| 3 | RO635_skill | RO635技能（**已弃用**） | — |
| 4 | SOPMOD_skill | SOPMOD II 散射榴弹 | 主动 23 |
| 5 | ump9_skill | UMP9 白鸮轰鸣 | 主动 28 |
| 6 | repair_fairy | 维修妖精（范围修复） | 妖精系统 |
| 7 | xm8_skill | XM8 技能（定时范围爆炸） | 主动 19 |
| 8 | 416_skill | HK416 寄生榴弹 | 主动 36/37 |
| 9 | kcco_smartgrenade_scan | KCCO 智能雷扫描（NPC用） | NPC |
| 10 | javelin_launch_for_sb_ai | 标枪 AI 版锁定 | NPC |
| 11 | javelin_launch_for_player | 标枪玩家版锁定+射出 | — |
| 12 | javelin_uprise | 标枪垂直爬升阶段 | — |
| 13 | javelin_strike | 标枪垂直攻顶阶段 | — |
| 14 | VV_skill | 燃烧弹 | 主动 2/29/64 |
| 15 | stg44_skill | STG44 炎风暴 | 主动 20 |
| 16 | banzai100 | 刺雷半载 | — |
| 17 | roarer | 白教白憨憨普攻砸地 | NPC |
| 18 | roarer_skill | 白教白憨憨技能搓球砸地 | NPC |
| 19 | g3_skill | G3 榴弹 | 主动 13 |
| 20 | smasher_skill | 大僵尸技能 | NPC |
| 21 | rf_liu | 刘氏步枪协同攻击 | 主动 34 |
| 22 | kcco_sniper_scan | KCCO 狙击手脚本榴弹 | NPC |
| 23 | ff_alchemist_skill_scan | 玩家炼金术师脚本榴弹 | 主动 39 |
| 24 | fc_defence_1 | 防御妖精1 | 妖精系统 |
| 25 | fc_defence_2 | 防御妖精2 | 妖精系统 |
| 26 | moth_destroy | 趋光者坠毁（**已失效**） | — |
| 27 | g41_scan | G41 智能手雷 | — |
| 28 | ump45mod3_skill | UMP45 MOD3 烟雾弹 | 主动 47 |
| 29 | sat8_pizza | SAT8 披萨 | 主动 35 |
| 30 | spawn_aek999 | AEK999 召唤机甲 | 主动 84 |
| 31 | spawn_wheelchair | 召唤轮椅 | — |
| 32 | ff_weaver_skill_scan | 玩家衔尾蛇脚本榴弹 | 主动 48 |
| 33 | uzi_firenade | UZI MOD3 燃烧弹 | 主动 50 |
| 34 | gsh18_medic | GSH18 庸医弹药 | 主动 80 |
| 35 | mle_skill_heal | 利贝罗勒（MLE）治疗 | 主动 32 |
| 36 | spawn_mortar_truck | 生成孤儿号迫击炮卡车 | — |
| 37 | spawn_lightning_storm_1_min | 生成一分钟闪电风暴 | — |
| 38 | para_acid | 白教腐蚀区域 | NPC |
| 39 | gk_medaid_hk416 | HK416 特工版医疗 | 主动 57 |
| 40 | para_heal | 白教指挥士回甲 | NPC |
| 41 | pa15_skill | PA15 技能 | 主动 66 |
| 42 | sf_boss_intruder_skill | 敌方干扰者技能 | NPC |
| ~~43~~ | ~~（地雷妖精）~~ | **已注释禁用** | — |
| 44 | sfw_aegis_selfheal | 铁血圣盾自愈 | NPC |
| 45 | c96_skill | C96 技能 | — |
| 46 | sf_boss_excutioner_skill | 敌方刽子手跳劈 | NPC |
| 47 | sf_boss_alchemist_skill | 敌方炼金术师大限 | NPC |
| 48 | spawn_pathfinder | 侦察中枢生成 | — |
| 49 | sf_boss_destroyer_skill | 敌方破坏者指尖风 | NPC |
| 50 | sf_boss_dreamer_skill | 敌方梦想家激光扫射 | NPC |
| 51 | kcco_smartgrenade_player_scan | KCCO 智能雷（玩家版） | — |
| 52 | spawn_orbital_strike | 轨道炮轰炸 | — |
| 53 | para_nytro_support | 涅托辅翼回甲+摇人 | NPC |
| 54 | nyto_spawn_trigger | 召唤随机涅托 | NPC |
| 55 | sf_boss_hunter_skill | 猎手困兽狙击 | NPC |
| 56 | sf_boss_oroborus_skill | 衔尾蛇热毒坠落 | NPC |
| 57 | fedorov_medkit | 菲德洛夫医疗箱 | 主动 81 |
| 58 | obr_knife_1 | OBR 刀片第一阶段 | 主动 83 |
| 59 | obr_knife_2 | OBR 刀片第二阶段 | 主动 83 |
| 60 | ammunition_supply | 弹药箱补给 | — |
| 61 | goliath_explode | 歌莉娅自爆 | NPC |
| 62 | evo3_skill | Evo3 毒气弹 | 主动 88 |
| 63 | manticore_summon | 人马座投空 | — |
| 64 | spawn_gager_knight | 计量官降落初始化 | — |
| 65 | spawn_gager_knight_land | 计量官着地 | — |
| 66 | G36_SKILL | G36 MOD3 毒奶 | 主动 96 |
| 67 | kcco_minotauros_rockets | 弥诺陶洛斯导弹 | NPC |

---

## 四、实现模式分析

### 主动技能实现类型

| 类型 | 数量 | 说明 |
|---|---|---|
| 纯投射物生成 | ~35 | `CreateDirectProjectile` / `CreateProjectile_H` |
| Task 序列（异步） | ~25 | `TaskSequencer.add()` 创建异步任务链 |
| 直接效果 | ~15 | 直接修改状态/库存/护甲 |
| 目标锁定狙击 | ~8 | 搜索最近敌人 + 在其位置生成弹头 |
| 单位召唤 | ~5 | 生成临时 NPC 单位 |
| 医疗/治疗 | ~5 | 回复 HP 或更新库存 |
| 特殊系统 | 2 | M14（击杀奖励）、AEK999（变身Task） |

### 被动技能实现类型

| 类型 | 数量 | 说明 |
|---|---|---|
| 投射物生成 | ~42 (61%) | 直接创建弹头，最常见 |
| 单位生成 | ~12 (17%) | 生成增援或敌方单位 |
| 医疗/库存修改 | ~8 (12%) | 回复 HP 或更新玩家装备 |
| Task 序列 | ~3 (4%) | XM8、HK416（迁移后）、刘氏步枪 |
| 状态机（多阶段） | 1 | Javelin 标枪（case 10-13，4阶段） |

---

## 五、特殊机制说明

### M14 MOD3（case 85）
- **不使用 addCooldown**，由独立 `M14SkillTracker` 管理所有状态
- 通过击杀事件（`handleCharacterKillEvent`）驱动连锁射击
- 已迁移至独立 Tracker（commit `8b757fe71`）

### 标枪 Javelin（passive case 10–13）
- **4 阶段状态机**：AI锁定 → 玩家锁定+射出 → 垂直爬升 → 垂直攻顶
- 明确标注为"不在当前迁移范围内，留待后续单独处理"

### SIG MCX（case 91）
- **充能系统**：5 档充能，`charge_recover_5` 模式
- 基础冷却仅 10s，但充能机制限制了连续使用

### AEK999（case 84）
- **超长 300s 冷却** + Task 变身机制
- 主动技能创建 `spawn_aek999` 弹头，触发 GFLskill case 30 召唤机甲

---

## 六、Task 迁移进度

| 技能 | 迁移状态 | Commit |
|---|---|---|
| DOT_tracker | ✅ 已迁移 | `52b8fb7d8` |
| XM8tracker | ✅ 已迁移 | `d575d6cf2` |
| HK416_tracker | ✅ 已迁移 | `376b2dbfb` |
| UZI_tracker | ✅ 已迁移 | `a0344ab35` |
| M14MOD3 规范化 | ✅ 已完成 | `8b757fe71` |
| Javelin | ❌ 明确延后 | 多阶段状态机，单独处理 |

---

## 七、待完成工作

1. **补充每个技能的游戏效果描述**（共约 160 条，主被动合计）
   - 建议按实现类型分批：投射物型最多，可批量起草
2. **数据参数补充**：伤害数值、效果范围、弹头 key 等（需读 `.projectile` XML）
3. **Javelin 标枪**技能的详细拆解和迁移方案
4. **basic_command_handler.as** 有未提交改动，待确认用途
