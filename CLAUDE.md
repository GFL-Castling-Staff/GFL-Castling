This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

GFL-Castling (异向易位) is a fan-made mod for *Running With Rifles* (RWR) based on *Girls' Frontline*. It is published on Steam Workshop (ID: 2606099273, App: 270150). Most gameplay logic is written in AngelScript (`.as` files) and loaded by the RWR engine at runtime.

## Running / Testing

There is no build system, test runner, or linter.

Typical validation flow:
1. Copy `packages/GFL_Castling/` into the game's `media/packages/` directory.
2. Launch RWR and start the mod from the campaign menu.
3. Use in-game behavior and crash logs to validate script changes.

## Architecture

### Entry Points

- `packages/GFL_Castling/scripts/start_invasion.as` is the main campaign entry point declared by `package_config.xml`.
- `packages/GFL_Castling/scripts/gamemodes/invasion/gamemode_invasion.as` is the live invasion gamemode wiring point and the main tracker registration hub.

### Script Directories

| Directory | Purpose |
| --- | --- |
| `packages/GFL_Castling/scripts/core/` | Shared data models, helpers, persistence, player info |
| `packages/GFL_Castling/scripts/trackers/` | Runtime gameplay trackers and event handlers |
| `packages/GFL_Castling/scripts/gamemodes/` | Campaign and invasion gamemode classes |
| `packages/GFL_Castling/scripts/delivery/` | Item and vehicle delivery configuration |
| `packages/GFL_Castling/scripts/internal/` | Wrappers around vanilla RWR framework code |

### Important Core Files

- `core/girl_index.as`: master roster and character metadata.
- `core/GFLparameters.as`: centralized tunable gameplay parameters.
- `core/GFLplayerlist.as`: player/soldier tracking plus per-player skill counters and lightweight tags.
- `core/gfl_skill_info.as`: T-Doll skill definitions.
- `core/command_skill_info.as`: command/support skill definitions.
- `core/save_system.as`: persistence between sessions.

### Important Tracker Files

- `trackers/GFLskill.as`: runtime skill activation/effect logic for the remaining GFL skill flows.
- `trackers/commandskill.as`: command/support skill activation, cooldown handling, and several task-backed skill flows including the current M14MOD3 path.
- `trackers/GFLtask.as`: shared task implementations used by skill and event flows.
- `trackers/kill_event.as` / `trackers/kill_skill.as`: on-kill behavior and skill-related kill handling.
- `trackers/call_event_handler.as`: call-in and spawn logic.
- `trackers/fairy_command.as`: fairy mechanics.
- `trackers/javelin_tracker.as`: dedicated Javelin tracker extracted from the older monolithic skill path.

### Retired / Historical Files

- `deleted_asset/script/event_system.as`: retired event-system implementation. It is no longer part of the live tracker chain.

## Current Implementation Notes

- The codebase is in an ongoing migration away from older monolithic tracker/update-array patterns toward task-backed flows where it makes sense.
- Not every system should become its own tracker. Reuse existing player-state infrastructure such as `GFLplayerlist.as` when a feature only needs per-player flags/counters.
- M14MOD3 currently uses the existing `commandskill.as` / `kill_event.as` / `GFLtask.as` path with player tags stored in `GFL_playerInfo`; it is not using a standalone `M14SkillTracker`.

## AngelScript / RWR Notes

- The mod includes both vanilla RWR scripts and mod scripts, so many engine classes/helpers are available through shared include chains.
- `_log()` is the common logging helper.
- Runtime data exchange uses `XmlElement`, `dictionary`, and engine tracker/task APIs following RWR conventions.
