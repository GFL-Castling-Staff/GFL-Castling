#!/usr/bin/env python3
"""
skill_data_extractor.py
=======================
Extracts T-Doll × skill mapping data from GFL-Castling AngelScript and XML files.

Outputs (written to ./output/):
  weapon_skill_map.csv   — per weapon key: active skill case, cooldowns, passive skill keys
  tdoll_skill_table.csv  — per T-Doll variant: index/skin/mod, weapon, active+passive skill info
  skill_case_index.csv   — master reference of all case numbers for both skill systems
  all_data.json          — complete structured dump of everything above

Run:
  cd media/tools
  python skill_data_extractor.py

Requirements: Python 3.8+, no third-party packages needed.
"""

import re
import csv
import json
import xml.etree.ElementTree as ET
from pathlib import Path
from collections import defaultdict

# ---------------------------------------------------------------------------
# Paths
# ---------------------------------------------------------------------------

REPO_ROOT   = Path(__file__).parent.parent
SCRIPTS     = REPO_ROOT / "packages/GFL_Castling/scripts"
CORE        = SCRIPTS / "core"
TRACKERS    = SCRIPTS / "trackers"
WEAPONS_DIR = REPO_ROOT / "packages/GFL_Castling/weapons"
OUTPUT_DIR  = Path(__file__).parent / "output"


# ---------------------------------------------------------------------------
# Helpers: AngelScript parser primitives
# ---------------------------------------------------------------------------

def read(path: Path) -> str:
    return path.read_text(encoding="utf-8", errors="replace")


def parse_as_dict_str_to_int(text: str, dict_name: str) -> dict[str, int]:
    """Parse  dictionary NAME = { {"key", int_value}, ... };  from AngelScript."""
    pattern = rf'dictionary\s+{re.escape(dict_name)}\s*=\s*\{{(.*?)\}};'
    m = re.search(pattern, text, re.DOTALL)
    if not m:
        return {}
    body = m.group(1)
    pairs = re.findall(r'\{\s*"([^"]*)"\s*,\s*(-?\d+)\s*\}', body)
    return {k: int(v) for k, v in pairs}


def parse_modded_key(key: str) -> tuple[int, str, str]:
    """
    Parse the computed modded_key string:
      "123-skin_456-mod_mod3"  ->  (123, "456", "mod3")
      "123-skin_0-mod_none"    ->  (123, "0", "none")
    """
    m = re.match(r'^(\d+)-skin_(\w+)-mod_(\w+)$', key)
    if m:
        return int(m.group(1)), m.group(2), m.group(3)
    return (-1, "", "")


def parse_tdoll_complex_index_custom(text: str) -> dict[str, str]:
    """
    Parse girl_index.as's tdoll_complex_index which uses modded_key(N[,S[,"M"]]).toString()
    as dictionary keys rather than string literals.

    AngelScript modded_key constructor:
        modded_key(int index, int skin=0, string mod="none")
        toString() -> "{index}-skin_{skin}-mod_{mod}"

    Handled entry formats:
        {modded_key(1).toString(),           "gkw_m1873.weapon"}
        {modded_key(1,301).toString(),        "gkw_m1873_301.weapon"}
        {modded_key(1,0,"mod3").toString(),   "gkw_m1873mod3.weapon"}
    """
    # Match: {modded_key( index [, skin [, "mod"]] ).toString(), "weapon_key"}
    pattern = re.compile(
        r'\{modded_key\(\s*(\d+)'          # index (required)
        r'(?:\s*,\s*(\d+)'                 # , skin  (optional)
        r'(?:\s*,\s*"([^"]*)")?'           # , "mod" (optional)
        r')?\s*\)\.toString\(\)\s*,'
        r'\s*"([^"]+)"\s*\}',
        re.DOTALL,
    )
    result: dict[str, str] = {}
    for m in pattern.finditer(text):
        index = m.group(1)
        skin  = m.group(2) or "0"
        mod   = m.group(3) or "none"
        wkey  = m.group(4)
        computed_key = f"{index}-skin_{skin}-mod_{mod}"
        result[computed_key] = wkey
    return result


# ---------------------------------------------------------------------------
# Step 1: Parse commandSkillIndex  weapon_key → active_case
# ---------------------------------------------------------------------------

def get_command_skill_index() -> dict[str, int]:
    text = read(CORE / "command_skill_info.as")
    return parse_as_dict_str_to_int(text, "commandSkillIndex")


# ---------------------------------------------------------------------------
# Step 2: Parse gameSkillIndex  notify_script_key → passive_case
# ---------------------------------------------------------------------------

def get_game_skill_index() -> dict[str, int]:
    text = read(CORE / "gfl_skill_info.as")
    return parse_as_dict_str_to_int(text, "gameSkillIndex")


# ---------------------------------------------------------------------------
# Step 3: Parse tdoll_complex_index  modded_key_str → weapon_key
# ---------------------------------------------------------------------------

def get_tdoll_complex_index() -> dict[str, str]:
    """
    girl_index.as uses modded_key(N[,S[,"M"]]).toString() as keys, not string literals.
    We evaluate the constructor arguments to compute the equivalent string key.
    """
    text = read(CORE / "girl_index.as")
    return parse_tdoll_complex_index_custom(text)


# ---------------------------------------------------------------------------
# Step 4: Scan .projectile files  projectile_filename → list[notify_script_key]
# ---------------------------------------------------------------------------

def get_projectile_to_notify_keys() -> dict[str, list[str]]:
    """
    Parse every .projectile XML file and collect notify_script keys.
    These correspond to entries in gameSkillIndex.
    """
    result: dict[str, list[str]] = defaultdict(list)

    for pf in WEAPONS_DIR.glob("*.projectile"):
        keys: list[str] = []
        try:
            tree = ET.parse(pf)
        except ET.ParseError:
            continue
        root = tree.getroot()
        for elem in root.iter("result"):
            if elem.get("class") == "notify_script":
                k = elem.get("key", "")
                if k:
                    keys.append(k)
        if keys:
            result[pf.name] = keys

    return dict(result)


# ---------------------------------------------------------------------------
# Step 5: Parse commandskill.as excute*Skill bodies for projectile creation calls
#         active_case → list[passive_case]
#
# Architecture note:
#   Passive GFLskill events are NOT triggered by the weapon's own bullets.
#   Instead, each active skill function dynamically creates "skill projectiles"
#   via CreateDirectProjectile / CreateProjectile_H.  Those projectiles carry
#   a <result class="notify_script" key="..."/> that fires GFLskill.handleResultEvent.
#
#   Chain:  excute*Skill() → CreateDirectProjectile("xxx.projectile", ...)
#           → projectile's notify_script key → gameSkillIndex[key] → GFLskill case
# ---------------------------------------------------------------------------

def get_active_to_passive_cases(
    proj_to_keys: dict[str, list[str]],
    game_idx: dict[str, int],
) -> dict[int, list[int]]:
    """
    For each active case in commandskill.as, return the GFLskill passive case numbers
    that it triggers indirectly through skill projectile creation.
    """
    text = read(TRACKERS / "commandskill.as")

    # Build: case_num → full function name (e.g. "excuteXM8MOD3skill")
    func_pattern = re.compile(r'case\s+(\d+)\s*:\s*\{(excute\w+?)\s*\(')
    case_to_func: dict[int, str] = {}
    for m in func_pattern.finditer(text):
        n, fn = int(m.group(1)), m.group(2)
        if n not in case_to_func:
            case_to_func[n] = fn

    # Regex to find projectile file names in CreateDirectProjectile / CreateProjectile_H calls
    # Signatures:
    #   CreateDirectProjectile(metagame, from, to, "file.projectile", charId, faction, speed)
    #   CreateProjectile_H(metagame, from, to, "file.projectile", charId, faction, angle, dist)
    create_proj_re = re.compile(
        r'Create(?:Direct)?Projectile(?:_H)?\s*\([^"]*"([^"]+\.projectile)"'
    )

    result: dict[int, list[int]] = {}
    for case_num, func_name in case_to_func.items():
        # Locate the function body (heuristic: scan from definition to next top-level closing brace)
        fn_def_re = re.compile(
            rf'\bvoid\s+{re.escape(func_name)}\b[^{{]*\{{',
            re.DOTALL
        )
        fn_m = fn_def_re.search(text)
        if not fn_m:
            continue

        # Walk forward counting braces to find the function body end
        start = fn_m.end()
        depth = 1
        pos = start
        while pos < len(text) and depth > 0:
            ch = text[pos]
            if ch == '{':
                depth += 1
            elif ch == '}':
                depth -= 1
            pos += 1
        body = text[start:pos - 1]

        passive_cases: list[int] = []
        for pm in create_proj_re.finditer(body):
            proj_file = pm.group(1)
            for nk in proj_to_keys.get(proj_file, []):
                pc = game_idx.get(nk)
                if pc is not None and pc >= 0 and pc not in passive_cases:
                    passive_cases.append(pc)

        if passive_cases:
            result[case_num] = passive_cases

    return result


# ---------------------------------------------------------------------------
# Step 7: Extract cooldown data from commandskill.as
# ---------------------------------------------------------------------------

def get_cooldown_map() -> dict[str, float]:
    """
    Parse  addCooldown("KEY", seconds, ...)  calls in commandskill.as.
    Returns the *first* (base) cooldown found per key string.
    """
    text = read(TRACKERS / "commandskill.as")
    # Signature: addCooldown(string key, float time, int cId, SkillModifer@ modifer, ...)
    pattern = re.compile(r'addCooldown\s*\(\s*"([^"]+)"\s*,\s*([\d.]+)')
    result: dict[str, float] = {}
    for m in pattern.finditer(text):
        key, raw_time = m.group(1), m.group(2)
        if key not in result:
            result[key] = float(raw_time)
    return result


# ---------------------------------------------------------------------------
# Step 8: Extract case → human label from both skill files
# ---------------------------------------------------------------------------

def get_case_labels_commandskill() -> dict[int, str]:
    """
    Read the excute*skill function names from the switch-case block,
    and strip the 'excute' prefix and 'skill' suffix for a cleaner label.
    Pattern:  case N:{excuteFooSkill(...);}
    """
    text = read(TRACKERS / "commandskill.as")
    pattern = re.compile(r'case\s+(\d+)\s*:\s*\{excute(\w+?)\s*\(')
    result: dict[int, str] = {}
    for m in pattern.finditer(text):
        case_num = int(m.group(1))
        raw = m.group(2)          # e.g. "AN94skill", "FnFalskill", "MLEskill"
        # Strip trailing "skill" (case-insensitive)
        label = re.sub(r'(?i)skill$', '', raw).strip()
        if case_num not in result:
            result[case_num] = label
    return result


def get_case_labels_gflskill() -> dict[int, str]:
    """
    Extract the inline comment after each 'case N:' in GFLskill.as.
    The format is: case N: {// 中文描述
    i.e. the comment comes after the opening brace, NOT directly after the colon.
    """
    text = read(TRACKERS / "GFLskill.as")
    # Match 'case N:' optionally followed by '{' and then '// comment'
    pattern = re.compile(r'case\s+(\d+)\s*:\s*\{?\s*//\s*(.+)')
    result: dict[int, str] = {}
    for m in pattern.finditer(text):
        case_num = int(m.group(1))
        comment = m.group(2).strip()
        if case_num not in result:
            result[case_num] = comment
    return result


# ---------------------------------------------------------------------------
# Step 9: Derive a representative cooldown per active-skill case
#         by joining commandSkillIndex ↔ addCooldown key strings
# ---------------------------------------------------------------------------

def get_case_to_cooldown() -> dict[int, float | None]:
    """
    Map each active-skill case number to a representative base cooldown (seconds).
    Scans the body of each excute*Skill function for addCooldown("key", seconds, ...) calls.
    Returns the first (primary) cooldown found; returns None if no addCooldown call exists.
    """
    text = read(TRACKERS / "commandskill.as")

    # Build case_num → full_function_name including "excute" prefix
    # Pattern: case N:{excuteFooSkill(...);}
    func_pattern = re.compile(r'case\s+(\d+)\s*:\s*\{(excute\w+?)\s*\(')
    case_to_func: dict[int, str] = {}
    for m in func_pattern.finditer(text):
        n, fn = int(m.group(1)), m.group(2)  # fn = "excuteXM8MOD3skill"
        if n not in case_to_func:
            case_to_func[n] = fn

    # For each function, locate its body using brace counting (same as get_active_to_passive_cases)
    case_to_cd: dict[int, float | None] = {}
    for case_num, func_name in case_to_func.items():
        fn_def_re = re.compile(rf'\bvoid\s+{re.escape(func_name)}\b[^{{]*\{{')
        fn_m = fn_def_re.search(text)
        if not fn_m:
            case_to_cd[case_num] = None
            continue

        start = fn_m.end()
        depth, pos = 1, start
        while pos < len(text) and depth > 0:
            ch = text[pos]
            if ch == '{':
                depth += 1
            elif ch == '}':
                depth -= 1
            pos += 1
        body = text[start:pos - 1]

        cd_matches = re.findall(r'addCooldown\s*\(\s*"[^"]+"\s*,\s*([\d.]+)', body)
        case_to_cd[case_num] = float(cd_matches[0]) if cd_matches else None

    return case_to_cd


# ---------------------------------------------------------------------------
# Main: assemble and write outputs
# ---------------------------------------------------------------------------

def main():
    OUTPUT_DIR.mkdir(exist_ok=True)
    print("Reading source files...")

    cmd_idx    = get_command_skill_index()        # weapon_key → active_case
    game_idx   = get_game_skill_index()            # notify_key → passive_case
    tdoll_idx  = get_tdoll_complex_index()         # modded_key_str → weapon_key
    p2k        = get_projectile_to_notify_keys()   # projectile_filename → [notify_key]
    cmd_labels = get_case_labels_commandskill()    # active_case → label
    gfl_labels = get_case_labels_gflskill()        # passive_case → label
    case_to_cd = get_case_to_cooldown()

    # active_case → list[passive_case] (via skill projectile creation in excute* bodies)
    ac_to_pc   = get_active_to_passive_cases(p2k, game_idx)

    # weapon_key → list[passive_case] (derived via commandSkillIndex + ac_to_pc)
    def passive_cases_for_weapon(wk: str) -> list[int]:
        ac = cmd_idx.get(wk)
        if ac is None:
            return []
        return ac_to_pc.get(ac, [])

    print(f"  T-Doll variants parsed             : {len(tdoll_idx)}")
    print(f"  Active skill entries (commandSkillIndex) : {len(cmd_idx)}")
    print(f"  Passive skill entries (gameSkillIndex)   : {len(game_idx)}")
    print(f"  Projectile files with notify_script      : {len(p2k)}")
    print(f"  Active cases with linked passive case    : {len(ac_to_pc)}")

    # ----------------------------------------------------------------
    # Output 1: skill_case_index.csv — master reference
    # ----------------------------------------------------------------
    all_active_cases  = sorted(set(cmd_idx.values()) | set(cmd_labels.keys()))
    all_passive_cases = sorted(set(game_idx.values()) | set(gfl_labels.keys()))

    with open(OUTPUT_DIR / "skill_case_index.csv", "w", newline="", encoding="utf-8") as f:
        w = csv.writer(f)
        w.writerow(["system", "case", "label", "cooldown_base_s", "linked_passive_cases"])
        for c in all_active_cases:
            if c < 0:
                continue
            linked = "|".join(str(pc) for pc in ac_to_pc.get(c, []))
            w.writerow(["active", c, cmd_labels.get(c, ""), case_to_cd.get(c, ""), linked])
        for c in all_passive_cases:
            if c < 0:
                continue
            w.writerow(["passive", c, gfl_labels.get(c, ""), "", ""])

    print(f"\nWrote skill_case_index.csv  ({len(all_active_cases)} active, {len(all_passive_cases)} passive cases)")

    # ----------------------------------------------------------------
    # Output 2: weapon_skill_map.csv — per weapon key
    # ----------------------------------------------------------------
    all_weapon_keys = sorted(k for k in cmd_idx if k and k != "666")

    with open(OUTPUT_DIR / "weapon_skill_map.csv", "w", newline="", encoding="utf-8") as f:
        w = csv.writer(f)
        w.writerow([
            "weapon_key",
            "active_case", "active_label", "active_cooldown_base_s",
            "passive_cases", "passive_labels",
        ])
        for wk in all_weapon_keys:
            ac  = cmd_idx.get(wk, "")
            al  = cmd_labels.get(ac, "") if ac != "" else ""
            acd = case_to_cd.get(ac, "") if ac != "" else ""
            pcs = passive_cases_for_weapon(wk)
            pls = "|".join(gfl_labels.get(pc, "") for pc in pcs)
            w.writerow([wk, ac, al, acd, "|".join(str(pc) for pc in pcs), pls])

    print(f"Wrote weapon_skill_map.csv  ({len(all_weapon_keys)} weapons)")

    # ----------------------------------------------------------------
    # Output 3: tdoll_skill_table.csv — per T-Doll variant (main output)
    # ----------------------------------------------------------------
    with open(OUTPUT_DIR / "tdoll_skill_table.csv", "w", newline="", encoding="utf-8") as f:
        w = csv.writer(f)
        w.writerow([
            "tdoll_index", "skin_id", "mod",
            "weapon_key",
            "active_case", "active_label", "active_cooldown_base_s",
            "passive_cases", "passive_labels",
        ])
        for mk_str, wk in sorted(tdoll_idx.items(), key=lambda x: parse_modded_key(x[0])):
            idx, skin, mod = parse_modded_key(mk_str)
            if idx < 0:
                continue
            ac  = cmd_idx.get(wk, "")
            al  = cmd_labels.get(ac, "") if ac != "" else ""
            acd = case_to_cd.get(ac, "") if ac != "" else ""
            pcs = passive_cases_for_weapon(wk)
            pls = "|".join(gfl_labels.get(pc, "") for pc in pcs)
            w.writerow([idx, skin, mod, wk, ac, al, acd,
                        "|".join(str(pc) for pc in pcs), pls])

    print(f"Wrote tdoll_skill_table.csv  ({len(tdoll_idx)} rows)")

    # ----------------------------------------------------------------
    # Output 4: all_data.json — complete structured dump
    # ----------------------------------------------------------------
    data = {
        "meta": {
            "tdoll_variant_count": len(tdoll_idx),
            "active_skill_case_count": len(all_active_cases),
            "passive_skill_case_count": len(all_passive_cases),
            "weapon_keys_with_active_skill": len(all_weapon_keys),
            "active_cases_with_passive_link": len(ac_to_pc),
        },
        "active_skill_cases": {
            str(c): {
                "label": cmd_labels.get(c, ""),
                "cooldown_base_s": case_to_cd.get(c),
                "linked_passive_cases": ac_to_pc.get(c, []),
                "weapon_keys": [wk for wk, ci in cmd_idx.items() if ci == c and wk],
            }
            for c in all_active_cases if c >= 0
        },
        "passive_skill_cases": {
            str(c): {
                "label": gfl_labels.get(c, ""),
                "notify_script_keys": [nk for nk, ci in game_idx.items() if ci == c],
            }
            for c in all_passive_cases if c >= 0
        },
        "weapon_skill_map": {
            wk: {
                "active_case": cmd_idx.get(wk),
                "active_label": cmd_labels.get(cmd_idx.get(wk, -1), ""),
                "active_cooldown_base_s": case_to_cd.get(cmd_idx.get(wk, -1)),
                "passive_cases": passive_cases_for_weapon(wk),
                "passive_labels": [gfl_labels.get(pc, "") for pc in passive_cases_for_weapon(wk)],
            }
            for wk in all_weapon_keys
        },
    }

    with open(OUTPUT_DIR / "all_data.json", "w", encoding="utf-8") as f:
        json.dump(data, f, ensure_ascii=False, indent=2)

    print(f"Wrote all_data.json")

    # ----------------------------------------------------------------
    # Summary stats
    # ----------------------------------------------------------------
    has_active  = sum(1 for v in tdoll_idx.values() if cmd_idx.get(v, 0) > 0)
    has_passive = sum(1 for v in tdoll_idx.values() if passive_cases_for_weapon(v))
    has_either  = sum(1 for v in tdoll_idx.values()
                      if cmd_idx.get(v, 0) > 0 or passive_cases_for_weapon(v))

    print("\n--- Summary ---")
    print(f"T-Doll variants with active skill       : {has_active} / {len(tdoll_idx)}")
    print(f"T-Doll variants with linked passive case : {has_passive} / {len(tdoll_idx)}")
    print(f"T-Doll variants with any skill           : {has_either} / {len(tdoll_idx)}")
    print(f"\nAll outputs written to: {OUTPUT_DIR.resolve()}")


if __name__ == "__main__":
    main()
