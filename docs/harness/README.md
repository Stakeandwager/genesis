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
| ledger_audit_test.gd | Reads the ledger back **off disk** after the fact and audits it: every order resolved once, the carrier's account apart from the verdict, and the last claim about each object checked against the world (Verified Living World, condition 5) | `--fixed-fps 120 -s res://tests/ledger_audit_test.gd` |
| things_said_test.gd | The readback names what is IN the dungeon, so a dungeon with a lamp does not read back like one without (016) | `-s res://tests/things_said_test.gd` |
| false_delivery_test.gd | NPC-DELIVERY-001: six adversarial challenges trying to make Genesis report a delivery it has not earned. Acceptance is **zero false successes** (015) | `--fixed-fps 120 -s res://tests/false_delivery_test.gd` |
| carry_test.gd | One complete errand across all four layers: a thing on the whitelist, built as a body, fetched and carried, and delivery answered by reading the THING'S position out of the scene (015) | `--fixed-fps 120 -s res://tests/carry_test.gd` |
| order_test.gd | The first command that resolves after it is accepted: the goal whitelist, routing over the door graph, and arrival decided from where the character ended up rather than from what it says (014) | `--fixed-fps 120 -s res://tests/order_test.gd` |
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

## 016: a readback that was silent about half the request

In the editor, "build a dungeon with a store and a vault, **with a lamp in the
store**" produced a dungeon with no lamp. The AI dropped the clause.

The system did not lie: the readback said "a dungeon of two rooms joined by a
door, entered through a 10 m store, each one leading to the next" - exactly
what it was about to build, and no lamp in it. The omission was there to be
caught and neither the owner nor the assistant caught it.

But the real defect was worse, and only showed up on looking: **the readback
never mentioned things at all**, so a dungeon built WITH a lamp read back
identically to one without. A line that is silent about part of the request
cannot be used to catch a dropped clause, which is the only reason the line
exists.

The readback now names each thing and the room it is in, and says nothing when
there is nothing - so silence means "there is nothing", which is true. The
prompt also now says a thing the player names must appear in `things`, in the
room they said.

## Auditing the ledger, rather than the code

Every other test here asks whether the code did the right thing.
`ledger_audit_test.gd` asks a different question - **does the ledger say what
happened?** - and answers it the way an outsider would have to: by reading the
records back off disk after the run and checking them.

It separates two things that are easy to blur:

**Structure** - can the record be audited at all, on its own? Every order
resolved exactly once, no outcome pointing at an order that is not there, what
was carried and where it started written down, the carrier's account kept
apart from the verdict, and enough in each outcome to read it without the game
running.

**Agreement** - does the last claim match the world as it stands? Only the
LAST claim about each object can be checked, because the world has moved on
since the earlier ones. Saying which claims an audit can and cannot settle is
part of the audit.

```
red_key:  ledger says DELIVERED (vault),      world says vault
blue_key: ledger says NOT_DELIVERED (entrance), world says entrance
carrier said "stopped walking" against DELIVERED
carrier said "stopped walking" against NOT_DELIVERED
```

The two carrier lines are the point: the same words from the carrier, two
opposite verdicts from the world. Nothing in the ledger reads one as the
other.

Its first run read zero records, because the test guessed the session's id
from its name - and a session's id is its name AND the moment it started. The
fix was to read the id rather than assume it, which is the rule the whole
project runs on, applied to a test.

## NPC-DELIVERY-001

Six attempts to make the ledger lie, and what it said:

| Challenge | Outcome |
| --- | --- |
| 1 normal delivery | `DELIVERED` |
| 2 carrier claims arrival, key never left the entrance | `NOT_DELIVERED` |
| 3 carrier reaches room 3 empty-handed | `NOT_DELIVERED` |
| 4 blue key in room 3, red key elsewhere | `NOT_DELIVERED` |
| 5 corridor walled off after the errand began | `NOT_DELIVERED` |
| 5b the key removed from the world entirely | `INCONCLUSIVE` |
| 6 key moved out of room 3 before the final check | `NOT_DELIVERED` |

**False successes: 0.**

Challenge 5 is the one that changed the code. Its first run reported
`INCONCLUSIVE` for a key stalled in a corridor, which overstated our
ignorance: we knew exactly where that key was, it simply was not in a room.
`INCONCLUSIVE` now means what it says - the thing is not in the world at all -
and 5b exists to prove that case is still reachable.

The implementation detail the brief asked to settle: the check is **room
membership**, not raw coordinates. The test asserts first that no two room
rectangles intersect, so "which room is it in" has exactly one answer.

## The delivery invariant

> A carrier's claim is evidence of an attempted action, not evidence of
> delivery.

Written into the shape of the record, not into anybody's manners:

1. **Before.** The order's own record carries what was to be carried, the room
   it stood in and its coordinates, written before anything moves. Without it
   a delivery cannot be told from a thing that was already there.
2. **During.** The carrier's account lives under `carrier` - what it said, where
   it stopped, how far and how long. The world's answer lives under `outcome`.
   Nothing can read one as the other.
3. **At rest.** The thing's position is read out of the scene once, after the
   character has stopped and set it down - never a coordinate that crossed the
   room on the way past.
4. **Tolerance**, stated rather than numeric: delivered means standing INSIDE
   the destination room's rectangle, by the same `room_of` the module uses for
   everything else.
5. **Three outcomes**, because "cannot tell" is not "failed":
   `DELIVERED`, `NOT_DELIVERED` (and where it actually is), `INCONCLUSIVE`
   (gone from the scene, or standing in no room at all).

## What carry_test.gd found on its first runs

Two faults, both only visible once something had to be picked up.

The character walked to the middle of the room the lamp was in and stopped two
and a half metres short of it. Reaching a room is not reaching what is in it.

Then, with the lamp made the last waypoint, it stalled anyway with the body
pressed against the crate. A route is sampled every half metre along the
corridor and on to the room's centre, so the leg carried points BEYOND where
the lamp stood - and a thing is solid, so walking to them meant walking
through it. The leg is now cut at the point nearest the thing.

Both times the ledger said the errand failed and named where the lamp actually
was. That is the part worth keeping: the carrying code was broken twice and
neither failure could be reported as a success, because delivery is answered
by reading the thing's position out of the scene and the character is never
asked.

## Rules

- Run the replay on the unchanged code first, so the yardstick is known
  (321 of 321 October records on 2026-10-06).
- Change one thing, rerun everything, compare old and new.
- Say plainly what was not tested: live Gemini answers, the real UI scene,
  the feel on the owner's HD 3000.
- `git stash` is how the held-until-tested arrangement goes wrong. Work
  stashed out of the mirror is invisible while the next feature is built on
  top of it, and copying the mirror into a scratch project then clobbers the
  tested copy there too. It happened during 014: boots_tool.gd and
  session_report.gd silently lost 013 and 012, and two suites that had passed
  an hour earlier started failing on missing functions. Pop before building
  anything new, or check `git stash list` first.
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
