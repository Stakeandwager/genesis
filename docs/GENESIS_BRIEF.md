# Genesis — Continuation Brief

2026-10-06 · branch prototype-002a, last commit after 368cd39 (the start-line fix)

Paste this at the start of a new chat.

## What this is

Genesis is a game where the player describes what they want in plain English, an AI turns that into an approved command, and the game builds it. The long-term aim is a downloadable game where players make their own games.

It has a complete play loop: describe a world, it is checked and built, race computer opponents on it, tell it what to change, and race again. It is now ready for its first player tests.

The principle that governs everything: **the AI proposes; Godot constructs, validates and measures.** The AI never writes code and can only request actions the game explicitly exposes. Every attempt, built or refused, is recorded with its reasons.

## Where the project is

| Item | Value |
| --- | --- |
| Project folder | `C:\Users\Owner\Documents\ai-game-builder` |
| Repository | github.com/Stakeandwager/genesis (private) |
| Working branch | prototype-002a |
| Finished and tagged | prototype-001 on main |
| Engine | Godot 4.7.1, GDScript |
| AI | Gemini gemini-3.1-flash-lite (free tier), key in api_key.txt (git-ignored) |
| AI instructions version | 002C-balance-1 (corrections: 002C-closure-feedback-2; edits: 002E-edit-1). Unchanged by 002F and 002G. |
| Track log | `%APPDATA%\Godot\app_userdata\AI_Game_Builder\track_log.jsonl` |
| Saved worlds | `%APPDATA%\Godot\app_userdata\AI_Game_Builder\worlds` |
| Machine | Intel HD Graphics 3000, Compatibility renderer; keep geometry cheap |

## What works today

- **Plain English to worlds.** Racing circuits (sections chained, closed by a solver, checked for crossings) and farms (zones packed, fenced, with lanes). Both are world modules and take exactly the same path through the game.
- **Plans.** One request can build several worlds, e.g. a track around a farm; the AI says "around", never coordinates.
- **A new world replaces the old one**, whichever kind it is. (Before 002F a track built after a farm left the farm on screen.)
- **Refusals with reasons.** Nothing is ever half-built. Refused AI answers (broken JSON, unsupported) are logged too, as FAILED_PARSE or UNSUPPORTED.
- **Closure correction.** When an AI circuit misses the start line, Godot tells the AI where it ended, where every section lands, and whether any straight lengths could close it; the AI gets one correction. `/revise on|off` toggles it.
- **The play loop.** Once a world exists, the AI sees it with the next request, so "make it longer", "add a chicane", "tighter corners" change that world. Godot reports what changed, by measurement.
- **Racing.** `/drive` alone; `/race [1-5]` against computer opponents over 3 laps. Opponents recover when stuck, and are now always put back clear of other cars, so a player who stops on the road no longer traps them.
- **Saved worlds.** `/save`, `/load`, `/worlds`, `/delete`. A world is saved as its description and re-checked on loading. The startup circuit is for driving straight away and cannot be saved; ask for a world first.
- **Player testing sessions (002G).** `/session NAME` tags every log record with the tester; `/session end` prints their results and stores them in the log.
- **Experiments.** `/experiment 20` asks for 20 tracks of each style and summarises the results.

Game commands: `/save`, `/load`, `/worlds`, `/delete`, `/drive`, `/race [n]`, `/view`, `/experiment [n]`, `/stop`, `/status`, `/revise [on|off]`, `/session [name|end]`, `/log`. Raw JSON typed into the box is built directly, without the AI.

## How it is put together

```
PLAYER -> NATURAL LANGUAGE (+ the current world) -> AI INTERPRETER -> COMMAND SYSTEM -> WORLD REGISTRY -> WORLD MODULE
   every world:  VALIDATE -> PRE_CHECK -> SOLVE -> (one correction) -> POST_CHECK -> MEASURE -> BUILD -> RECORD
   racing:       sections    feasibility  closure   closure feedback   separation
   farm:         zones       -            layout    -                  -
   then:         DRIVE / RACE (through drivable_surface()), or change it and go round again
```

The whitelist and the AI's vocabulary are generated from the world registry, so a world cannot be half-added. A world module (`world_module.gd`) must provide command, display_name, prompt_section, validate, solve, measure and build; the optional steps (record_fields, pre_check, solve_record, correction_feedback, post_check, summary) do nothing unless a module provides them. A world a car can drive on reports `"drivable"` from build(); driving and racing reach it only through the controller's `has_drivable()` and `drivable_surface()`.

Racing's rules for the AI still live in `SYSTEM_PROMPT` in `ai_interpreter.gd` (its prompt_section() is empty), so the AI's prompt is byte-identical to before: 4,205 bytes.

| File | Role |
| --- | --- |
| main.gd | Screen, game commands, sessions, driving, racing, play loop and change reports |
| ai_interpreter.gd | Talks to Gemini; standing instructions (including racing's rules), corrections, world context for edits |
| command_parser.gd | The whitelist: PLAN, MODIFY_TRACK, SPAWN_OPPONENTS, CLEAR_WORLD, plus one command per registered world |
| game_controller.gd | Dispatch, the one world pipeline, plans, placement, drivable surface, refusal logging. No racing code. |
| world_module.gd, world_registry.gd | World interface; registry of FarmModule and RacingModule |
| racing_module.gd | Racing as a world module: wraps the racing classes below, and owns the closure feedback text |
| farm_module.gd | The whole farm world in one file |
| section_validator.gd, track_geometry.gd, feasibility_gate.gd, closure_solver.gd, separation_check.gd, track_metrics.gd, circuit_builder.gd | Racing: check, solve (incl. length_reach), measure, build |
| car.gd, checkpoint_tracker.gd, race_director.gd | Driving, lap timing, opponents and race order |
| track_log.gd, session_report.gd | The attempt log (tags records during a session) and the session summary |
| world_store.gd | Saved worlds |
| experiment_runner.gd | Repeated-request experiments |
| track_builder.gd, opponent_builder.gd | Old Prototype 001 ring, still used by CREATE_TRACK without sections. Left in place on purpose. |

## Player testing (what to do next)

Sit each person at the laptop, type `/session their-name`, say only "build something you'd want to play", and watch. When they stop, type `/session end`. The report gives:

- minutes and number of requests;
- time to the first world, and what they asked for;
- worlds built, how many were changes, and whether they made another;
- whether they drove, races started and finished, with places;
- every failed request with its reason, and every thing they asked for that Genesis cannot do.

How it counts: each request once, by its final result (a corrected track counts once; a plan counts once, not per step); `/load` is a load, not a request; the AI being unavailable (HTTP 503 and similar) counts as a failed request and is listed with that reason, so it can be told apart from Genesis's own failures. Every record during the session carries `"session": {"name", "id"}`; the summary is stored as a `session_summary` record.

**Decide the pass mark before the first tester.** A starting suggestion: first world within 3 minutes; no more than 1 in 3 requests failing; at least half drive or race; at least half ask to make another. Then let the results choose between a third world type, opponent difficulty settings, and track variety.

The free Gemini tier returned HTTP 503 ("high demand") twice on 2026-10-06. Retrying a minute later worked. Expect some during sessions.

## Working rules that earned their place

- **Replace whole files, never fragments.** Give each file's exact byte size.
- **Installing new files.** The assistant sends one `files.zip`; it lands as the newest `Downloads\files (N).zip` (N was 27 on 2026-10-06 and goes up by one each time). Extract into a dated folder, check sizes, then copy into scripts:

  ```
  mkdir "%USERPROFILE%\Downloads\genesis-DATE"
  tar -xf "%USERPROFILE%\Downloads\files (N).zip" -C "%USERPROFILE%\Downloads\genesis-DATE"
  dir "%USERPROFILE%\Downloads\genesis-DATE"
  copy /Y "%USERPROFILE%\Downloads\genesis-DATE\*.gd" "C:\Users\Owner\Documents\ai-game-builder\scripts\"
  ```

- **Never put .gd files in the project root.** Godot reads the whole folder; duplicates cause "hides a global script class" errors. The test harness is kept as `.txt` in `docs/harness` for the same reason.
- **Paste commands one at a time.**
- **PowerShell commands need PowerShell.** From Command Prompt, wrap them: `powershell -NoProfile -Command "..."`
- **After adding a script with class_name, Project → Reload Current Project**, check the error counter reads zero, and then `git add scripts` picks up the new `.uid` file too.
- **Commit when something works, one step at a time, and push.**
- **Print before you guess.**
- **Type lists live in one place.** Adding a section type means touching TrackGeometry's lists, the validator, metrics and builder.
- **Old GPUs need real thickness** and a near plane that moves out as the camera pulls back.

## How the assistant checks its work

The owner cannot run tests, so the assistant runs Godot 4.7.1 headless in its own sandbox, from `https://github.com/godotengine/godot/releases/download/4.7.1-stable/Godot_v4.7.1-stable_linux.x86_64.zip`. The harness used for 002F and 002G is in `docs/harness` (see its README). Ask the owner to upload `scripts` and `track_log.jsonl`.

- **Replay.** Every October record's raw command is fed back through the controller and compared. Since 002F the yardstick is **321 of 321** October records (the older "292" came from a shorter log), compared on every field and field order, plus log messages, all 76 closure-feedback texts, and the assembled AI prompt byte for byte. Run it on the unchanged code first.
- **Driving and racing.** A test builds main.gd with a stand-in UI and plays: startup circuit, farm, track, plan around a farm, `/drive`, change while driving, "Changed:" report, save/load, clear, and races on six tracks where every opponent must complete 2 laps. `PARK=1` leaves the player's car parked on the grid.
- **Sessions.** A scripted tester checks every number in the session report and that only session records are tagged.
- **Say plainly what could not be tested**, usually live Gemini answers, the real UI scene, and the feel on the HD 3000.

## What the experiments found

Technical circuits now close 18 of 20, but never with a hairpin: the AI fixes closure by deleting it. Each run asked for 20 tracks per style, identical wording apart from the style word; high speed and balanced were 20 of 20 every time.

| Run (Oct 2026) | Technical built | With a hairpin |
| --- | --- | --- |
| Original instructions | 1 of 20 | 0 |
| Plus one correction | 13 of 20 | 1 |
| Balance rule, no correction | 6 of 20 first try | 1 |
| Balance rule plus length-reach correction | 18 of 20 | 0 |

- **The failure is structural.** Failed designs travel far up the map and barely come back; only the order of turns can fix them.
- **Telling the AI that worked.** With the length-reach check, 12 of 14 corrections succeeded, against 13 of 19 with position feedback alone.
- **Variety is poor.** High speed and balanced are nearly always the same rounded rectangle at different sizes; in 240 tracks the AI never proposed a circle, oval or paperclip, though all are buildable.
- **Edits work well.** "Make it longer", "add a chicane" and "tighter corners" each changed only what was asked.
- **Opponents.** In headless simulations every opponent finishes on rectangle, technical with chicane, round, banked, high-speed and farm-surround tracks, including with the player's car parked on the grid.

## Commits since the last brief

| Commit | What |
| --- | --- |
| after 368cd39 | Opponents are recovered past a stopped car instead of onto it |
| 368cd39 | 002G: `/session NAME` tags the log per tester; `/session end` reports results |
| 6bef259 | 002F steps 3-4: racing goes through the world registry; driving uses `drivable_surface()` |
| 58690d6 | 002F step 2: RacingModule wraps the racing pipeline; registered |
| 407ea61 | 002F step 1: optional world module steps; farm message from `summary()` |

## Known rough edges

- Banked corners act as ramps and throw cars over the barrier: about 23 opponent recoveries per race on a banked square. Opponents recover; the player uses R.
- A plan reports "Plan built" even when one of its steps failed (e.g. a broken second farm). Old behaviour, noted in 002F, not fixed.
- Loops are built but untested with a car.
- The separation check is flat, so a loop passing over itself reads as a crash.
- The solver does not check that a track returns to its starting height.
- Opponent difficulty is untuned; a non-gamer can catch them.
- The AI rewrites the style label on edits ("longer_balanced"); harmless.
- Distant barriers speckle on the HD 3000.
- The free Gemini tier sometimes returns HTTP 503 at busy times.
- No author or timestamp shown on saved worlds yet (the file has a "saved" time; no author).

## Next steps

1. **Write down the pass mark**, then run 5 to 10 testers with `/session`.
2. **Let the results choose** between a third world type, opponent difficulty settings, and track variety.
3. **Banked corners** that hold cars on the road, if testers race on them.
4. **An author on every saved world**, still outstanding.

Work one capability at a time, test it on the real machine, commit, then move on. And keep the rule that makes all of this debuggable: the AI proposes, Godot decides.
