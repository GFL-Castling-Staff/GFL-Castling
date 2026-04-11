# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

GFL-Castling (异向易位) is a fan-made mod for *Running With Rifles* (RWR) based on the mobile game *Girls' Frontline*. It is published on Steam Workshop (ID: 2606099273, App: 270150). All game logic is written in **AngelScript** (`.as` files), which is interpreted at runtime by the RWR engine — there is no compile step.

## Running / Testing

There is no build system, test runner, or linter. The mod runs by:
1. Copying `packages/GFL_Castling/` (and optionally `packages/optional/`) into your RWR installation's `media/packages/` directory.
2. Launching the game and selecting the mod from the campaign menu.

Scripts are compiled and executed by the RWR engine; syntax errors surface as in-game crash logs. The Steam Workshop upload uses `castling.vdf` with SteamCMD.

## Architecture

### Entry Point & Game Mode

`scripts/start_invasion.as` is the campaign entry point (declared in `package_config.xml`). It instantiates `GameModeCampaign`, then `init()`/`run()`/`uninit()`.

`scripts/my_gamemode.as` defines `MyGameMode`, which extends the vanilla `GameModeCampaign` and wires together three configurators:
- **`MyStageConfigurator`** — map rotation and per-map setup
- **`MyItemDeliveryConfigurator`** — what items spawn and when
- **`MyVehicleDeliveryConfigurator`** — vehicle delivery objectives

Alternative entry points (`start_1.as`–`start_5.as`, `start_campaign.as`, `start_fr1.as`, `start_fr2.as`) exist for specific map subsets or modes.

### Script Directories

| Directory | Purpose |
|---|---|
| `scripts/core/` | Central data and utilities shared across the whole mod |
| `scripts/trackers/` | Event-driven handlers that run during gameplay |
| `scripts/delivery/` | Item/vehicle spawn configuration (very large files) |
| `scripts/gamemodes/` | `campaign/` and `invasion/` gamemode subclasses |
| `scripts/internal/` | Wrappers around vanilla RWR framework (logging, queries) |

### Key Files in `scripts/core/`

- **`girl_index.as`** (~73k lines) — Master roster of all playable characters (T-Dolls) with stats, skills, and metadata. The single largest file in the mod.
- **`GFLparameters.as`** — Centralized numeric parameters: elite enemy definitions, weapon data, tunable constants.
- **`GFLplayerlist.as`** — Player/soldier tracking and management.
- **`GFLhelpers.as`** — Common helper functions used across trackers: `getCharactersNearPosition`, `CreateDirectProjectile`, etc.
- **`gfl_skill_info.as`** — Definitions for each T-Doll's unique special skill; also contains legacy tracker classes (`XM8tracker`, `HK416_tracker`, `UZI_tracker`, `DOT_tracker`, `Javelin_lister`) pending migration to Task system.
- **`command_skill_info.as`** — Definitions for command/support abilities.
- **`mod3_doll.as`** — Mod 3 (third-tier upgrade) system for T-Dolls.
- **`save_system.as`** — Persistence of game state between sessions.
- **`enemy_reward.as`** — Enemy drop/reward logic.
- **`ServerHelper.as`** — Server-side utility helpers.

### Key Files in `scripts/trackers/`

- **`event_system.as`** — Central event dispatcher; most gameplay logic hooks in here.
- **`GFLskill.as`** — Runtime skill activation via `handleResultEvent`; currently uses manual tracker arrays + `update()` loop pattern; being migrated to Task system.
- **`GFLtask.as`** — All Task subclass definitions (e.g. `VestRecoverTask`, `M14SkillActiveTask`, `M14SkillEndTask`). New Tasks go here.
- **`commandskill.as`** — `/skill` chat command entry point; manages skill cooldowns (`addCooldown`, `SkillArray`); currently holds M14 global state (`m14_active_tasks`, `m14_rocket_reward_players`, `m14_pending_cooldowns`).
- **`kill_skill.as`** / **`kill_event.as`** — On-kill triggers; `kill_event.as` also contains M14 chain-shot and death-cleanup logic pending extraction.
- **`call_event_handler.as`** — Unit call/spawn system.
- **`spawn_in_base_call_handler.as`** — Base-spawn mechanics.
- **`fairy_command.as`** — Fairy/command unit special mechanics.
- **`penalty_manager.as`**, **`ban_manager.as`** — Anti-griefing and server management.

### Factions

Four factions defined in `factions/` as XML bundles (`.character`, `.ai`, `.text_lines`, `.models`, `.resources` files):

| Faction | Notes |
|---|---|
| S.F. | Primary/default faction |
| Paradeus | |
| KCCO | |
| URNC | |

### Assets

- `maps/` — 38 playable maps
- `weapons/` — Weapon XML configurations
- `vehicles/` — Vehicle XML configurations
- `models/` — 3D models
- `textures/` — Textures (replaces most vanilla assets)
- `sounds/` — Audio (90%+ of vanilla replaced)
- `languages/` — Localization strings in Chinese (CN, primary) and English (EN)
- `items/` — Carry items and visual items

### Task System

`scripts/internal/task_sequencer.as` defines the Task framework used throughout the mod:
- **`Task`** — interface with `start()`, `update(float time)`, `hasEnded()`
- **`TaskSequencer`** — runs Tasks serially; advance to next when current `hasEnded()`
- **`TaskManager`** — holds multiple Sequencers, all updated in parallel each tick

Usage pattern: `m_metagame.getTaskManager().newTaskSequencer()`, then `tasker.add(MyTask(...))`. Task implementations live in `scripts/trackers/GFLtask.as`.

### AngelScript Conventions

- The mod `#include`s both `path://media/packages/vanilla/scripts` and `path://media/packages/GFL_Castling/scripts`, so vanilla RWR classes and helpers are available.
- `_log()` is the vanilla logging utility used throughout (from `scripts/internal/`).
- Data is exchanged via `XmlElement` / `dictionary` objects following RWR conventions.
- **Comments are written in Chinese.**
- Member variables use the `m_` prefix (e.g. `m_characterId`, `m_metagame`).
- `excute` (not `execute`) is the project's fixed spelling — do not correct it.
- Version control follows **Conventional Commits** (e.g. `refactor: ...`, `feat: ...`, `fix: ...`).

## Claude Working Documents

`claude_use/` — Markdown documents written for Claude to guide specific refactoring tasks. Not part of the shipped mod. Currently contains:
- **`GFLskill_task_migration_prompt.md`** — Plan for migrating `GFLskill.as` manual tracker arrays to the Task system, and for extracting M14 logic into a dedicated tracker.
