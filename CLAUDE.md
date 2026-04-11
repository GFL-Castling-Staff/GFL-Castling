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
- **`gfl_skill_info.as`** — Definitions for each T-Doll's unique special skill.
- **`command_skill_info.as`** — Definitions for command/support abilities.
- **`mod3_doll.as`** — Mod 3 (third-tier upgrade) system for T-Dolls.
- **`save_system.as`** — Persistence of game state between sessions.
- **`enemy_reward.as`** — Enemy drop/reward logic.

### Key Files in `scripts/trackers/`

- **`event_system.as`** — Central event dispatcher; most gameplay logic hooks in here.
- **`GFLskill.as`** — Runtime skill activation and effect application.
- **`kill_skill.as`** / **`kill_event.as`** — On-kill triggers.
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

### AngelScript Conventions

- The mod `#include`s both `path://media/packages/vanilla/scripts` and `path://media/packages/GFL_Castling/scripts`, so vanilla RWR classes and helpers are available.
- `_log()` is the vanilla logging utility used throughout (from `scripts/internal/`).
- Data is exchanged via `XmlElement` / `dictionary` objects following RWR conventions.
