# Genesis — Continuation Brief

2026-10-05 · branch prototype-002a, commit 7eb2730

Paste this at the start of a new chat.

## What this is

Genesis is a game where the player describes what they want in plain English, an AI turns that into an approved command, and the game builds it. The long-term aim is a downloadable game where players make their own games.

It now has a complete play loop: describe a world, it is checked and built, race computer opponents on it, tell it what to change, and race again.

The principle that governs everything: **the AI proposes; Godot constructs, validates and measures.** The AI never writes code and can only request actions the game explicitly exposes. Every attempt, built or refused, is recorded with its reasons.

## Where the project is

| Item | Value |
| --- | --- |
| Project folder | `C:\Users\Owner\Documents\ai-game-builder` |
| Repository | github.com/Stakeandwager/genesis (private) |
| Working branch | prototype-002a, last commit 7eb2730 |
| Finished and tagged | prototype-001 on main |
| Engine | Godot 4.7.1, GDScript |
| AI | Gemini gemini-3.1-flash-lite, key in api_key.txt (git-ignored) |
| AI instructions version | 002C-balance-1 (corrections: 002C-closure-feedback-2; edits: 002E-edit-1) |
| Track log | `%APPDATA%\Godot\app_userdata\AI_Game_Builder\track_log.jsonl` |
| Machine | Intel HD Graphics 3000, Compatibility renderer; keep geometry cheap |

## What works today

- **Plain English to worlds.** Racing circuits (sections chained, closed by a solver, checked for crossings) and farms (zones packed, fenced, with lanes).
- **Plans.** One request can build several worlds, e.g. a track around a farm; the AI says "around", never coordinates.
- **Refusals with reasons.** Nothing is ever half-built. Refused AI answers (broken JSON, unsupported) are logged too, as FAILED_PARSE or UNSUPPORTED.
- **Closure correction.** When an AI circuit misses the start line, Godot tells the AI where it ended, where every section lands, and whether any straight lengths could close the layout at all; the AI gets one correction. `/revise on|off` toggles it.
- **The play loop.** Once a world exists, the AI sees it with the next request, so "make it longer", "add a chicane", "tighter corners" change that world. Godot reports what changed, by measurement. Changing while driving puts the car back at the start line.
- **Racing.** `/drive` to drive alone; `/race [1-5]` races computer opponents over 3 laps. Opponents drive the same physics car, brake for corners, keep their own lanes, have different skills, and recover when stuck. Results go to the track log as `race_result`.
- **Saved worlds.** `/save`, `/load`, `/worlds`, `/delete`. A world is saved as its description and re-checked on loading.
- **Experiments.** `/experiment 20` asks for 20 tracks of each style and summarises first-try results, corrections, rescues and whether rescued designs kept their pieces.

Game commands: `/save`, `/load`, `/worlds`, `/delete`, `/drive`, `/race [n]`, `/view`, `/experiment [n]`, `/stop`, `/status`, `/revise [on|off]`, `/log`. Raw JSON typed into the box is built directly, without the AI.

## How it is put together

```
PLAYER -> NATURAL LANGUAGE (+ the current world) -> AI INTERPRETER -> COMMAND SYSTEM -> WORLD REGISTRY
   RACING: VALIDATE -> FEASIBILITY -> SOLVE -> (one correction) -> SEPARATION -> MEASURE -> BUILD -> RECORD
   FARM:   VALIDATE -> LAYOUT -> MEASURE -> BUILD -> RECORD
   then:   DRIVE / RACE, or change it and go round again
```

The whitelist and the AI's vocabulary are generated from the world registry, so a world cannot be half-added. Turning and straight section types are listed once, in TrackGeometry (`YAW_TYPES`, `STRAIGHT_FAMILY`); the gate, solver and length check read those lists.

| File | Role |
| --- | --- |
| main.gd | Screen, game commands, driving, racing, play loop and change reports |
| ai_interpreter.gd | Talks to Gemini; standing instructions, corrections, world context for edits |
| command_parser.gd | The whitelist |
| game_controller.gd | Dispatch, plans, placement, closure feedback text, refusal logging |
| world_module.gd, world_registry.gd, world_store.gd, track_log.gd | World interface, registry, saved worlds, attempt log |
| section_validator.gd, track_geometry.gd, feasibility_gate.gd, closure_solver.gd, separation_check.gd, track_metrics.gd, circuit_builder.gd | Racing: check, solve (incl. length_reach), measure, build |
| car.gd, checkpoint_tracker.gd, race_director.gd | Driving, lap timing, opponents and race order |
| experiment_runner.gd | Repeated-request experiments |
| farm_module.gd | The whole farm world in one file |
| track_builder.gd, opponent_builder.gd | Old Prototype 001 ring, still used by CREATE_TRACK without sections |

## Working rules that earned their place

- **Replace whole files, never fragments.**
- **Installing new files.** Several files download as the newest `Downloads\files (N).zip`; one file downloads alone, renamed `name (1).gd` if the name exists. Extract into a dated folder, check sizes against the assistant's list, then copy into scripts:

  ```
  mkdir "%USERPROFILE%\Downloads\genesis-DATE"
  tar -xf "%USERPROFILE%\Downloads\files (N).zip" -C "%USERPROFILE%\Downloads\genesis-DATE"
  copy /Y "%USERPROFILE%\Downloads\genesis-DATE\*.gd" "C:\Users\Owner\Documents\ai-game-builder\scripts\"
  ```

- **Never put .gd files in the project root.** Godot reads the whole folder; duplicates cause "hides a global script class" errors.
- **Paste commands one at a time.** Pasted JSON or stray keys run as commands and break the next line.
- **PowerShell commands need PowerShell.** From Command Prompt, wrap them: `powershell -NoProfile -Command "..."`
- **After adding a script with class_name, Project → Reload Current Project.**
- **Check the error counter reads zero before running.**
- **Commit when something works, one step at a time, and push.**
- **Print before you guess.**
- **Type lists live in one place.** Adding a section type means touching TrackGeometry's lists, the validator, metrics and builder.
- **Old GPUs need real thickness** and a near plane that moves out as the camera pulls back.

## What the experiments found

Technical circuits now close 18 of 20, but never with a hairpin: the AI fixes closure by deleting it. Each run asked for 20 tracks per style, identical wording apart from the style word; high speed and balanced were 20 of 20 every time.

| Run (Oct 2026) | Technical built | With a hairpin |
| --- | --- | --- |
| Original instructions | 1 of 20 | 0 |
| Plus one correction | 13 of 20 | 1 |
| Balance rule, no correction | 6 of 20 first try | 1 |
| Balance rule plus length-reach correction | 18 of 20 | 0 |

- **September's 9 of 20 used a 50% solver limit.** Under today's 20% limit, technical designs miss by 160 to 580 m before adjustment, not tens of metres.
- **The failure is structural.** Failed designs travel far up the map and barely come back. With every straight free from 20 to 1,000 m, 12 of 13 failed layouts still cannot close: only the order of turns can fix them.
- **Telling the AI that worked.** With the length-reach check, 12 of 14 corrections succeeded, against 13 of 19 with position feedback alone.
- **Variety is poor.** High speed and balanced are nearly always the same rounded rectangle at different sizes; in 240 tracks the AI never proposed a circle, oval or paperclip, though all are buildable.
- **Edits work well.** "Make it longer", "add a chicane" and "tighter corners" each changed only what was asked; the chicane was placed inside a straight, so the track still closed.
- **Opponents.** In headless simulations all opponents finished on rectangle, technical, round, high-speed and banked tracks; a non-gamer could catch them.

## Commits since the last brief, and known rough edges

| Commit | What |
| --- | --- |
| 7eb2730 | 002E play loop: change the world you are in; Godot reports what changed |
| b089408 | 002D opponents (/race); driving uses the track's real position |
| e37b785 | Cleanup: banked corners count as turns; shared type lists; separation display |
| 7c478e7 | Length-reach check in correction feedback |
| b7e5664 | Balance rule in the AI's instructions |
| f117ce1 | Closure correction; refused AI answers logged |

Known rough edges:

- Banked corners act as ramps and can throw cars over the barrier; opponents recover, the player uses R.
- Loops are built but untested with a car.
- The separation check is flat, so a loop passing over itself reads as a crash.
- The solver does not check that a track returns to its starting height.
- Racing is still special-cased in game_controller.gd rather than a world module.
- Opponent difficulty is untuned; a non-gamer can catch them.
- The AI rewrites the style label on edits ("longer_balanced"); harmless.
- Distant barriers speckle on the HD 3000.

## Next steps

1. **Wrap racing as a world module**, so the special-case racing code in game_controller.gd disappears and every world takes one path. A careful refactor: replay the logged October designs afterwards and confirm identical results.
2. **Player testing with 5 to 10 people.** Sit them at the laptop, say only "build something you'd want to play", and watch. Record time to first world, failed requests, what they asked for that Genesis can't do, whether they drive or race, and whether they ask to make another. Decide the pass mark beforehand. A `/session name` command, tagging every log record with the tester, would make each person's results easy to pull out.
3. **Then let testers decide** between a third world type, opponent difficulty settings, and track variety.
4. **An author and a timestamp on every saved world**, still outstanding.

## What to ask the assistant for

Work one capability at a time, test it on the real machine, commit, then move on. Give complete replacement files with their byte sizes. Check new code in Godot 4.7.1 headless before handing it over, including physics simulations where driving is involved, and replay logged designs after any change to checking or solving. Say plainly what could not be tested, usually the live Gemini responses.

And keep the rule that makes all of this debuggable: the AI proposes, Godot decides.
