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
| walker_test.gd | Walks a real `CharacterBody3D` through every doorway and reports which rooms a **moving body** reaches, against what the geometry claims (007) | `--fixed-fps 120 -s res://tests/walker_test.gd` |
| boots_test.gd | The second tool: the registry takes it unchanged, a field out of range is refused, and a spec whose fields are **all legal** but whose combination is absurd is refused by its consequence (010) | `-s res://tests/boots_test.gd` |
| walk_physics_test.gd | Walking is a force on a mass: top speed lands where `push / (mass * drag)` says, a half-pressed stick settles at half of it, and letting go coasts (009) | `--fixed-fps 120 -s res://tests/walk_physics_test.gd` |
| behaviour_test.gd | The third layer: do the boots **do** what the readback promised? Top speed against the stated figure, stopping distance from a controlled speed, and a refused spec leaving the equipped item alone (012) | `--fixed-fps 120 -s res://tests/behaviour_test.gd` |
| silence_test.gd | A player who answers nothing scores nothing, where the old arithmetic scored them 100% (012) | `-s res://tests/silence_test.gd` |
| explore_test.gd | `/explore` played the way the owner plays it: the body lands on the floor, walks out of the entrance, and counts as using the world (008) | `--fixed-fps 120 -s res://tests/explore_test.gd` |

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

## What walker_test.gd found

That prediction was right, and worse than expected. The first run, with a real
`CharacterBody3D` 1.6 m across:

```
a row of five      geometry 5/5, body 1/5   <-- DISAGREES
    door (0, 1) stopped at (-10.4, 2.2, 0.0), stuck 1.6 m short of (-12.0, 0.0)
four off a hall    geometry 5/5, body 1/5   <-- DISAGREES
two rooms          geometry 2/2, body 1/2   <-- DISAGREES
```

**Every doorway in the game was impassable.** A body could leave a room, because
stepping down is free, and could never enter the next one. The `y = 2.2` is the
proof: the capsule is standing on the corridor floor, 0.3 m below the room floor
it is trying to reach, and a `CharacterBody3D` has no step-up.

Two things made this invisible for months. Nothing in the dungeon had collision
at all — every floor and wall was a bare `MeshInstance3D` — so there was no body
to get stuck, and the only reachability anyone could measure was a drawing of
one. And the geometric check treats floors as flat rectangles, so it could not
have seen a step of any size.

The fix was one constant: corridors now sit 2 cm under the room floor rather
than 30 cm. The 2 cm is all that was ever needed to keep room floors drawing on
top where the two overlap.

This is the clearest example in the project of the rule below. The suite was
green. 147 dungeons passed. Nobody could walk through any of them.

## Known broken

`report_test.gd` **hangs** and prints nothing at all, not even the engine
banner. It is not a regression: it does the same against the committed code
with every later change reverted, so it has been broken for some time. A
minimal SceneTree script in the same project runs fine, so the fault is in
that file or in what it calls, not the harness.

Recorded here so nobody spends ten minutes waiting for it again. Everything it
covers - the arithmetic of the /session report - is also covered by
range_test.gd, which passes.

## 013: the model is named, so the prediction means something

The brief that prompted this used `d = v^2 / 2a`, constant deceleration. The
model running was linear drag, `d = v/k`, where a body never formally stops.
Both are reasonable; they are not the same, and a prediction is arithmetic
about nothing until the model is named.

Naming it closed two faults at once. Braking is now a bounded FORCE rather
than more drag, so deceleration is `brake / weight`:

- a heavy body finally takes longer to stop, which drag could never express
  because `velocity * drag` has no mass in it;
- and asking to stop sharply no longer costs top speed, because `footing` has
  stopped doing two jobs.

The game predicts its own stopping distance, in `BootsTool.stopping_distance`,
from the exact solution of `dv/dt = -(b + k*v)`:

```
d = v/k - (b / k^2) * ln(1 + k*v / b)
```

which becomes `v^2 / (2b)` as drag goes to nothing - the schoolbook formula is
the special case, not the model. The prediction lives beside the thing it
predicts, for the reason `around_of()` and `_wall_rects()` exist.

Measured against it, from 2.0 m/s:

```
ordinary       predicted 0.340 m, measured 0.322 m
stops sharply  predicted 0.137 m, measured 0.120 m
heavy          predicted 0.537 m, measured 0.518 m
```

**The measurement is consistently about 5% short of the prediction, in the
same direction every time.** That is not noise and should not be hidden behind
a tolerance: the prediction solves the continuous equation, while the game
applies drag and braking one after the other inside a discrete frame. The bias
is the integration, not the physics, and it would shrink at a higher tick
rate. It is recorded here so that if it ever changes sign or size, somebody
notices.

## What behaviour_test.gd found before 013

The three boots, measured from the same 2.0 m/s on the same ground:

```
ordinary       top 4.48 m/s   stops in 2.80 m / 4.45 s
stops sharply  top 2.14 m/s   stops in 1.33 m / 2.12 s
heavy          top 2.56 m/s   stops in 2.80 m / 4.45 s
```

Every stated figure held and "stop sharply" really does, at 48% of ordinary's
distance. But look at the third row: **a 140 kg body stops in exactly the same
distance as an 80 kg one.** Drag in 009 is `velocity * drag` with no mass term,
so weight changes top speed and nothing else. That is not how momentum works.

The readback is honest about it - "weigh you down" never promised a longer
stop - so this test passes. It is the model that is wrong, not the account of
it, and the two are worth keeping apart.

The criteria are stated in the file BEFORE the run, and they are not invented
there: they are the readback's own claims. A test that defines "stops on a
sixpence" in its own file measures a promise nobody made.

## Rules

- Run the replay on the unchanged code first, so the yardstick is known
  (321 of 321 October records on 2026-10-06).
- Change one thing, rerun everything, compare old and new.
- Say plainly what was not tested: live Gemini answers, the real UI scene,
  the feel on the owner's HD 3000.
- Limits that are not whole numbers must not be written as a `Vector2`. Its
  components are 32-bit, so 0.40 becomes 0.4000000059604645 and a spec asking
  for exactly the documented minimum is refused for being below it. The first
  run of boots_test.gd caught this. BootsTool uses a two-element Array;
  CarTool is still Vector2 and is safe only because every one of its bounds is
  a whole number.
- Read `Engine.physics_ticks_per_second`, never the `--fixed-fps` figure.
  They are different things: Main sets physics to 120 and a scratch project
  leaves it at 60, so assuming 120 halves every measured time. This already
  reported walking as twice as quick as it is, in the first run of
  walk_physics_test.gd.
- A green suite is not evidence that the thing under test is doing anything.
  Ask of each new check whether a legal input could ever make it fail;
  sweep_test.gd exists because the answer was no.
