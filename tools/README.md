# GFL-Castling Dev Tools

Utility scripts for mod development and data analysis.
These are **not** part of the shipped mod — they live outside `packages/`.

---

## skill_data_extractor.py

Extracts and cross-references all T-Doll skill data from the AngelScript source
and weapon XML files, outputting structured tables for analysis or documentation.

### What it reads

| Source file | Data extracted |
|---|---|
| `core/girl_index.as` | `tdoll_complex_index` — every T-Doll variant → weapon key |
| `core/command_skill_info.as` | `commandSkillIndex` — weapon key → active skill case |
| `core/gfl_skill_info.as` | `gameSkillIndex` — notify_script key → passive skill case |
| `trackers/commandskill.as` | Case labels (`excute*Skill` names) + base cooldown times |
| `trackers/GFLskill.as` | Case labels (inline Chinese comments) |
| `weapons/*.weapon` | Which projectile files each weapon uses |
| `weapons/*.projectile` | Which `notify_script` keys each projectile fires |

### What it writes (to `tools/output/`)

| File | Description |
|---|---|
| `skill_case_index.csv` | Master list of all active/passive case numbers with labels and cooldowns |
| `weapon_skill_map.csv` | Per weapon key: active case + passive notify keys |
| `tdoll_skill_table.csv` | Per T-Doll variant (index/skin/mod): full skill info |
| `all_data.json` | Complete structured dump of all the above |

### How to run

Requires Python 3.8+. Currently uses stdlib only, so no packages need to be installed.
A `.venv` is recommended for future extensibility — set it up once:

```bash
cd media/tools

# First time: create the venv
python -m venv .venv

# Activate (Windows)
.venv\Scripts\activate
# Activate (Git Bash / WSL)
source .venv/Scripts/activate

# Install packages (currently none, but ready for future use)
pip install -r requirements.txt

# Run
python skill_data_extractor.py
```

The `.venv/` and `output/` directories are gitignored — regenerate locally as needed.

### Column reference

**tdoll_skill_table.csv**

| Column | Meaning |
|---|---|
| `tdoll_index` | Numeric T-Doll ID (same as `modded_key` index) |
| `skin_id` | Skin variant ID (0 = default) |
| `mod` | Upgrade tier: `none`, `mod3`, `only`, `only_exp`, etc. |
| `weapon_key` | The `.weapon` file key used by this variant |
| `active_case` | Case number in `commandskill.as` switch block (empty = no active skill) |
| `active_label` | Extracted function name label for the active skill |
| `active_cooldown_base_s` | Base cooldown in seconds before CDR/CDM modifiers |
| `passive_skill_keys` | Pipe-separated `notify_script` keys fired by this weapon's projectiles |
| `passive_cases` | Corresponding `GFLskill.as` case numbers for those keys |

### Notes

- **Base cooldown** is the first `addCooldown(key, N, ...)` call found in the skill
  function body. Actual in-game cooldown = `max(N * CDR - CDM, 0.1)` where CDR/CDM
  come from the player's equipped items.
- A weapon with no entry in `commandSkillIndex` has no active `/skill` command.
- A weapon with no `notify_script` in its projectile files has no passive event skill.
- Some projectile-level skills (fairy commands, NPC boss abilities) are included in
  the passive table but have no associated T-Doll variant.
