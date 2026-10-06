# Genesis test harness

The headless tests the assistant used for 002F and 002G. They are stored as
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

drive_test.gd and session_test.gd need the files in tests/ to keep their
names: session_test.gd extends drive_test.gd.

## Rules

- Run the replay on the unchanged code first, so the yardstick is known
  (321 of 321 October records on 2026-10-06).
- Change one thing, rerun everything, compare old and new.
- Say plainly what was not tested: live Gemini answers, the real UI scene,
  the feel on the owner's HD 3000.
