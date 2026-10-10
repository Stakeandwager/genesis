# Genesis test harness

The headless tests the assistant used from 002F onward. They are stored as
.txt so Godot never loads them from the project. To use them, copy each one
back to its real name in a scratch project, never into this project.

## Set up (Linux sandbox)

1. Download Godot 4.7.1 for Linux:
   https://github.com/godotengine/godot/releases/download/4.7.1-stable/Godot_v4.7.1-stable_linux.x86_64.zip
2. Make a scratch project: project.godot, a scripts folder with all of the
   owner's scripts, and a tests folder with these files renamed to .gd.
   run.sh does all of this; edit its paths first.
3. `--headless --import`, then run each test with `-s res://tests/NAME.gd`.

## The tests

| File | What it checks | How to run |
| --- | --- | --- |
| loadcheck.gd | Every script in scripts/ loads and can instantiate | `-s res://tests/loadcheck.gd` |
| replay.gd | Feeds every October record's raw_command back through the controller and writes what it produced | `REPLAY_LOG=track_log.jsonl REPLAY_OUT=out.json -s res://tests/replay.gd` |
| compare.py | Compares a replay with the logged results, and two replays with each other (every field, field order, log messages, closure feedback, the AI prompt) | `python3 compare.py new.json [old.json]` |
| drive_test.gd | Builds main.gd with a stand-in UI and plays the game: worlds, plans, /drive, edits, save/load, races on six tracks | `--fixed-fps 120 -s res://tests/drive_test.gd`; `PARK=1` leaves the player's car on the grid; `ONLY_PLAN=4` repeats the farm-surround race |
| session_test.gd | A scripted tester; checks every number in the /session report and the tagging | `--fixed-fps 120 -s res://tests/session_test.gd` |
| prompt_test.gd | The AI's prompt is built from the registry and names every world | `-s res://tests/prompt_test.gd` |
| report_test.gd | The /session report's arithmetic | `-s res://tests/report_test.gd` |
| judge_test.gd | Every understanding verdict: confirmed, corrected, disputed, revised, accepted by use, accepted by silence (003) | `-s res://tests/judge_test.gd` |
| range_test.gd | The reported understanding **range** rather than a single rate, including the unattributable bare "no" (003) | `-s res://tests/range_test.gd` |
| shape_test.gd | The dungeon readback names the shape the player asked for: chain, hub, hub part way along a chain (002I) | `-s res://tests/shape_test.gd` |
| farm_test.gd | A one-zone farm builds; zero and thirty are still refused (004) | `-s res://tests/farm_test.gd` |
| tool_test.gd | A car spec reads back in the player's words; out-of-range values are **refused, not clamped**; the free kit is exactly the old hard-coded car (004) | `-s res://tests/tool_test.gd` |
| physics_test.gd | A described spec reaches the physics: a feeble car travels less than an ordinary one, which travels less than a powerful one (004) | `--fixed-fps 120 -s res://tests/physics_test.gd` |
| walk_test.gd | Logical and physical reachability agree on five shapes; a room with no openings has four solid walls (005) | `-s res://tests/walk_test.gd` |
| walk_negative.gd | The physical check **can fail**: a sealed doorway is detected and its coordinate named (005) | `-s res://tests/walk_negative.gd` |
| sweep_test.gd | Whether any *legal command* can reach `FAILED_UNWALKABLE` — 147 dungeons across the whole legal space (005) | `-s res://tests/sweep_test.gd` |

drive_test.gd and session_test.gd need the files in tests/ to keep their
names: session_test.gd extends drive_test.gd.

## What sweep_test.gd found, and why it is kept

It is the only test here that asserts something **cannot** happen, and the
first run answered its question against us:

```
SWEEP  tried 147, solved 147, logical and physical disagreed 0 times
TIGHTEST  a 4.0 m room with 0.8 m walls leaves 2.4 m of floor;
          a body is 1.6 m, so 0.8 m to spare
VERDICT   no legal command reaches FAILED_UNWALKABLE.
```

The tightest room the schema allows still leaves a body 0.8 m of slack, so
physical reachability cannot currently disagree with the door graph. 005's
physical check is therefore a **guard against a future change** to
`WALL_THICK`, `CORRIDOR` or `MIN_SIDE`, not a live measurement of the player's
world. Recording logical and physical separately presently records the same
number twice, and the record should not imply otherwise.

The sweep also turned up why the two will eventually disagree: room floors sit
at `ROOM_HEIGHT = 1.6` and corridors at `CORRIDOR_HEIGHT = 1.3`, so **every
doorway is a 0.3 m step up**, and the geometric check treats floors as flat
rectangles and cannot see height at all. It would call a three-metre cliff
walkable. A moving body is a different instrument, and the first time it
disagrees with the geometry is the first real measurement.

## Rules

- Run the replay on the unchanged code first, so the yardstick is known
  (321 of 321 October records on 2026-10-06).
- Change one thing, rerun everything, compare old and new.
- Say plainly what was not tested: live Gemini answers, the real UI scene,
  the feel on the owner's HD 3000.
- A green suite is not evidence that the thing under test is doing anything.
  Ask of each new check whether a legal input could ever make it fail;
  sweep_test.gd exists because the answer was no.
