This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

GFL-Castling (异向易位) is a fan-made mod for *Running With Rifles* (RWR) based on *Girls' Frontline*. It is published on Steam Workshop (ID: 2606099273, App: 270150). Most gameplay logic is written in AngelScript (`.as` files) and loaded by the RWR engine at runtime.

## Branch Discipline (read this first)

| Branch | Role | Rule |
|---|---|---|
| `main` | Release / Steam Workshop branch | **Intentionally kept behind `dev`. Never modify it directly, and never "sync" `dev` into it.** |
| `dev` | Development mainline | Where accepted changes land |
| `dev-claude` | **AI-assisted work branch** | Claude commits here; SAIWA tests in-game, then merges to `dev` himself |
| `dev-1.9.0`, `dev-network` | Historical / network-debug lines | Not audited as of 2026-08-04 |

Workflow: Claude works on `dev-claude` → SAIWA validates in-game → SAIWA merges to `dev`.
Claude does not merge to `dev`, does not push to `dev`, and never touches `main`.

`main` being 400+ commits behind `dev` is deliberate, not a missed merge.

## Running / Testing

There is no build system, test runner, or linter. **This is the project's biggest engineering
constraint**: there is no compile step, so type errors, undefined symbols, and typos surface
only at runtime inside the game.

Typical validation flow:
1. Copy `packages/GFL_Castling/` into the game's `media/packages/` directory.
2. Launch RWR and start the mod from the campaign menu.
3. Use in-game behavior and crash logs to validate script changes.

**Brace-balance self-check** (weak substitute for a compiler; use after commenting out or
moving blocks of AngelScript). Strip `//` comments, then the net brace count must be 0,
same as on `dev`:

```bash
sed 's|//.*||' <file>.as | tr -cd '{}' | awk '{n=0;for(i=1;i<=length($0);i++){c=substr($0,i,1); if(c=="{")n++; else n--} print n}'
```

This catches unbalanced braces only. It is **not** a compile check — do not report a change
as verified on the strength of it. Only an in-game run counts.

Because large comment-outs cannot be compile-checked, prefer **disabling entry points**
(a dispatch `case`, a key→id mapping) over commenting out class definitions. See the OTS14
chain-lightning shutdown for the worked example.

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

- `deleted_asset/script/event_system.as`: retired event-system implementation. It is no longer part of the live tracker chain. Verified 2026-08-04: `GFL_event_array` / `GFL_event_system` / `GFL_Event_Index` have zero references under `scripts/`.
- **OTS14 chain lightning: disabled 2026-08-04**, not deleted. Four entry points are commented out (`command_skill_info.as` weapon→skill-98 mapping, `commandskill.as` case 98, `gfl_skill_info.as` `"ots14_chain_scan"`→68, `GFLskill.as` case 68). The ~350-line chain machinery in `GFLtask.as` is deliberately left uncommented — unreachable once the entries are closed, and mass-commenting class definitions with no compiler is a needless risk. **Do not delete it**: it is the only verified pattern for chain/bounce effects (see Query Handling Notes). Restore instructions are in the `GFLskill.as` case 68 comment block.

## Current Implementation Notes

- The codebase is in an ongoing migration away from older monolithic tracker/update-array patterns toward task-backed flows where it makes sense.
- Not every system should become its own tracker. Reuse existing player-state infrastructure such as `GFLplayerlist.as` when a feature only needs per-player flags/counters.
- M14MOD3 currently uses the existing `commandskill.as` / `kill_event.as` / `GFLtask.as` path with player tags stored in `GFL_playerInfo`; it is not using a standalone `M14SkillTracker`.

### Airstrike dispatch throttle (known open issues)

`trackers/GFLairstrike.as` consumes the `Airstrike_strafe` request queue with a hard per-frame
cap (`max_airstrike_per_frame = 10`). Three known problems, all still open as of 2026-08-04:

- **`default:` does not dequeue.** Every normal `case` calls `Airstrike_strafe.removeAt(a)`;
  `default:` does not. An entry whose key matches no case stays in the queue forever, and
  because the counter increments *before* the switch, it silently eats 1/10 of the dispatch
  budget every frame with no log. Verified not currently firing (every id in `airstrikeIndex`
  and every call site maps to a live case), so this is a **trap for future edits**: adding a
  dict entry without adding its `case` triggers it silently.
- **The budget counts queue entries, not work.** Per-case cost spans two orders of magnitude
  (A10 strafe ≈48 projectiles, ion cannon ≈16, S13 pod 5 — *estimated from loop counts, not
  measured*). So `max_airstrike_per_frame` cannot be used to derive per-frame cost.
  **Do not tune it before instrumenting actual projectile spawns per frame.**
- **Backward iteration makes it LIFO.** Under sustained load >10/frame, older requests get
  starved behind newer ones.

Estimation discipline: this project has **no performance measurements at all**. Any cost
number not explicitly labelled 实测 is an estimate — label it as such.

## Refactor Guardrails

- Before creating a new standalone tracker for a single skill, first check whether the state can live in existing systems such as `GFLplayerlist.as`, `commandskill.as`, `kill_event.as`, or `GFLtask.as`.
- If a skill still uses the shared command-skill path, preserve the normal safety checks and interaction expectations: validate `character is null` before calling `canCastSkill(character)`, keep active-state feedback clear, and avoid silent no-op branches when the player presses `/s`.
- Prefer ending a task by applying cooldown directly at the task end when the cooldown is conceptually tied to that task's completion. Do not introduce extra pending arrays or whole trackers unless they solve a real coordination problem.
- When listening to global events such as `character_kill`, filter as early as possible. Dedicated skill logic should avoid doing unnecessary work for unrelated kills.
- Reuse existing player-state containers for per-player flags or rewards when the state is lightweight. Reserve ad-hoc arrays for short-lived runtime objects that truly need their own lifecycle.
- When reverting or porting projectile logic, verify the referenced projectile keys still exist and that the damage model matches the original behavior. A direct-hit projectile and a spawn-on-impact projectile are not interchangeable.

## AngelScript / RWR Notes

- The mod includes both vanilla RWR scripts and mod scripts, so many engine classes/helpers are available through shared include chains.
- `_log()` is the common logging helper.
- Runtime data exchange uses `XmlElement`, `dictionary`, and engine tracker/task APIs following RWR conventions.
- New `.projectile` files must be registered in `packages/GFL_Castling/weapons/useable_projectiles.xml` as `<projectile file="filename.projectile" />` before they can be spawned at runtime.

## Query Handling Notes

- Treat `getCharactersNearPosition(...)` and other helpers built on `getComms().query(...)` as synchronous/blocking queries.
- Do not assume `send(make_query class="characters" ...)` is a reliable asynchronous nearby-character path. Current project evidence for OTS14 showed:
  - synchronous `players` / `character id=...` queries respond normally
  - asynchronous `characters` make_query did not return a matching `query_result`
  - no confirmed working sample of asynchronous `characters` make_query was found in `_ori_RunningWithRifles`
- Do not assume moving a nearby-character sync query into a generic task or bootstrap task is enough. OTS14 testing showed `getCharactersNearPosition(...)` could still hang there depending on context.
- For chain, bounce, or reacquire-style effects, prefer a proven event context over forcing queries through `/skill` or task update. The currently verified safe pattern is:
  1. `commandskill.as` only handles cast gating / animation / starter spawn
  2. a starter projectile triggers `notify_script`
  3. `GFLskill.as` handles the notify event and performs one synchronous `getCharactersNearPosition(...)` snapshot
  4. later hops run from an in-memory snapshot without more nearby-character queries
- Pure in-memory follow-up is considered viable for short-lived chain effects when:
  - the chain lifetime is short
  - the candidate list is capped
  - slightly stale target positions are acceptable
- For repeated per-hop visuals, be careful with extra visual-only projectiles:
  - OTS14 was stable with damage-only hops
  - a custom per-hop hit-effect projectile repeatedly caused native crashes
  - switching that hit-effect projectile to a conservative `particle.projectile` / `para_heal_effect_on_target` style structure fixed stability
- Existing reference patterns:
  - `trackers/GFLskill.as` case `58/59` (`OBR knife`) for projectile -> notify -> reacquire chaining
  - `trackers/GFLtask.as` `UZISkillTask` for fixed-count repeat execution on a prelocked target list
  - OTS14 for `notify_script -> one snapshot -> ChainTask` plus a stable particle-style per-hop hit effect (disabled 2026-08-04 but kept as the reference implementation)

## Document Index

Layered docs. Read on demand — do not read them all up front.

| Layer | File | What it holds | When to read |
|---|---|---|---|
| 1 | `CLAUDE.md` (this file) | Standing rules, architecture contracts, engine gotchas | Every cold start |
| 2 | [PROJECT_STATE.md](PROJECT_STATE.md) | Current state, calibrated parameters, measurements, open decisions | Every cold start — **read the last sections first, they are the newest** |
| 3 | [HISTORY.md](HISTORY.md) | Completed work, why designs were revised, settled tech debt | When you need to know why something is the way it is |
| 4 | [docs/architecture/skill-system.md](docs/architecture/skill-system.md) | Skill system layering and runtime paths | Before touching skill dispatch |
| 4 | [docs/architecture/skill-implementation-guidelines.md](docs/architecture/skill-implementation-guidelines.md) | How to write a new skill | Before adding a skill |
| 4 | [docs/architecture/task-migration.md](docs/architecture/task-migration.md) | Task migration route and stage | Before refactoring a tracker into tasks |
| 4 | [docs/reports/skill-migration-audit-2026-04-11.md](docs/reports/skill-migration-audit-2026-04-11.md) | Audit of what actually landed | When docs and code seem to disagree |
| — | `claude_use/*.md` | Dated per-task working records | Historical context only — **not current state** |

### Doc discipline

- `PROJECT_STATE.md` is **append-only**. Where a new entry conflicts with an older one, mark
  "以后面的为准" rather than deleting the old one — the evolution is itself information.
- **Behavioural claims must be checked against source.** Docs are written at design time and
  code changes at implementation time, so they drift. Never restate a doc's prose description
  of "how this runs" without reading the code. Correct drift on the spot when you find it.
- Estimates and measurements are different words. Say which one you have.
