# CLAUDE.md

This file provides guidance to Claude Code when working with code in this repository.

## Project Overview

GFL-Castling is a fan-made mod for *Running With Rifles* (RWR) based on *Girls' Frontline*. It is published on Steam Workshop (ID: 2606099273, App: 270150).

All gameplay logic is written in AngelScript (`.as`) and interpreted at runtime by the RWR engine. There is no standalone build step.

## Running / Testing

There is no build system, test runner, or linter.

The mod is tested by:

1. Copying `packages/GFL_Castling/` (and optionally `packages/optional/`) into the RWR `media/packages/` directory
2. Launching the game and loading the mod in campaign mode

Syntax/runtime issues generally surface through in-game crash logs or broken behavior.

## Architecture

### Entry Point & Game Mode

`scripts/start_invasion.as` is the main campaign entry point declared by `package_config.xml`.

`scripts/my_gamemode.as` defines `MyGameMode`, which extends the vanilla campaign mode and wires together:

- `MyStageConfigurator`
- `MyItemDeliveryConfigurator`
- `MyVehicleDeliveryConfigurator`

There are also alternative entry files such as `start_1.as` to `start_5.as`, `start_campaign.as`, `start_fr1.as`, and `start_fr2.as` for special subsets or modes.

### Script Directories

| Directory | Purpose |
|---|---|
| `scripts/core/` | Shared data tables and helpers |
| `scripts/trackers/` | Runtime gameplay handlers |
| `scripts/delivery/` | Item and vehicle delivery configuration |
| `scripts/gamemodes/` | Campaign / invasion gamemode code |
| `scripts/internal/` | Wrappers around vanilla framework utilities |

### Key Files in `scripts/core/`

- `girl_index.as`: master roster and metadata for T-Dolls
- `GFLparameters.as`: centralized parameters and tunables
- `GFLplayerlist.as`: player/soldier tracking
- `GFLhelpers.as`: common helper functions
- `gfl_skill_info.as`: passive skill index mapping (`notify_script key -> case`)
- `command_skill_info.as`: active skill index mapping (`weapon key -> case`)
- `mod3_doll.as`: Mod 3 upgrade system
- `save_system.as`: persistence
- `enemy_reward.as`: enemy reward / drop logic
- `ServerHelper.as`: server-side helpers

### Key Files in `scripts/trackers/`

- `commandskill.as`: `/skill` command entry, cooldown handling, and active skill dispatch
- `GFLskill.as`: passive skill dispatcher driven by `handleResultEvent`
- `GFLtask.as`: Task implementations
- `event_system.as`: event dispatcher; some implementations have moved to Task, but `GFL_event_array + update()` still exists
- `m14_skill_tracker.as`: dedicated M14 state management
- `javelin_tracker.as`: dedicated Javelin state machine
- `kill_skill.as` / `kill_event.as`: kill-related skill hooks
- `call_event_handler.as`: unit call/spawn system
- `spawn_in_base_call_handler.as`: base spawn mechanics
- `fairy_command.as`: fairy / command unit mechanics
- `penalty_manager.as`, `ban_manager.as`: anti-griefing and server management

### Task System

`scripts/internal/task_sequencer.as` defines:

- `Task`
- `TaskSequencer`
- `TaskManager`

Typical usage:

`m_metagame.getTaskManager().newTaskSequencer()`

then:

`tasker.add(MyTask(...))`

Task implementations live mainly in `scripts/trackers/GFLtask.as`.

### Current Skill-System Status

The skill migration has already progressed significantly:

- `RepeatEffectTask` exists
- `DOT / XM8 / HK416 / UZI` have been migrated to Task
- M14 state has been moved into `m14_skill_tracker.as`
- Javelin state has been moved into `javelin_tracker.as`
- `GFLskill.as::update(float time)` currently exists as an empty lifecycle method

The main remaining old-style system is `event_system.as`, which still uses manual event arrays and an `update()` loop even though several event implementations have already been rewritten as Tasks.

## Conventions

- Comments are written in Chinese
- Member variables use the `m_` prefix
- `excute` is the project's established spelling; do not rename it to `execute`
- Data exchange follows common RWR `XmlElement` / `dictionary` patterns
- Version control follows Conventional Commits when making commits

## Working Docs

`docs/architecture/` and `docs/reports/` should be treated as the primary source of current architecture status.

`claude_use/` contains working notes and historical migration prompts. Some of those files are snapshots from earlier migration phases and may contain outdated statements.
