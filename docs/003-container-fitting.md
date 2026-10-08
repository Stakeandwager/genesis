# 003 — The container problem

A record of a defect, how it was found, and what was changed. Written because
the finding matters more than the fix: the fix is forty lines, the finding is
a property the system did not have.

---

## What the player asked for

```
make me a race track in a farm
```

Four attempts over one session. Every one was refused:

```
PLAN failed: FAILED_SCENE
- step 2 overlaps step 1: they must stand apart, or one must be
  big enough to contain the other with 15 m to spare
no geometry built
```

The AI was not wrong in any of them. It proposed a farm, proposed a circuit,
and marked the circuit `"around": 1`. All legal, all validated, both worlds
solved and measured, then torn down.

Measured afterwards, the four attempts had **two different causes**:

| attempt | farm | circuit | why it failed |
|---|---|---|---|
| 1 | 330 × 290 m | 280 × 380 m | genuinely too small — 120 m short in depth |
| 2 | 530 × 480 m | 290 × 390 m | **would have fitted** — the relationship was dropped |
| 3 | 170 × 160 m | 500 × 500 m | **would have fitted** — the relationship was dropped |
| 4 | 430 × 380 m | 300 × 400 m | genuinely too small — 50 m short in depth |

Both real failures were short in **depth** and fine in width. That is not a
coincidence, and it is the heart of the problem.

---

## Why the AI could not have fixed it

A circuit's depth is its first straight plus two corner radii — 300 + 50 + 50
= 400. Simple, and the AI chose every one of those numbers.

A farm's depth is not chosen by anyone. It exists only after Godot has:

1. sorted the zones by area,
2. packed them into rows at a working width of `sqrt(total area) × 1.35`,
3. put 6 m lanes between them,
4. and added a 12 m margin and a fence.

Attempt 4's six zones happened to pack into two rows, giving 380 m of depth.
Nothing in the request says 380. Nothing the AI could have written would have
let it predict 380. It was being held to a constraint it had no way to
evaluate — exactly the kind of thing the protocol says belongs to Godot and
not to the interpreter.

---

## Two other defects found on the way

**A dropped key.** `"around"` was read only at the step level, but the AI
writes it at the step level *or* inside `parameters`, meaning the same thing
either way. Attempts 2 and 3 had it one level too deep, so the relationship
was silently discarded and the worlds were placed unrelated. Both plans were
sound and both would have built. One word was in the wrong place.

**A readback that lied.** The 003 readback was written to read `"around"`
from both places. The builder still read one. For one run Genesis printed:

```
READBACK: a farm and a race circuit, one inside the other
PLAN failed: step 2 overlaps step 1
```

It described a relationship it was not going to deliver. That is worse than
the original bug: a readback exists so a player can catch Genesis building
the wrong thing, and a readback that overstates what will happen teaches
them to trust a line that is not true.

It was found by the readback contradicting the builder out loud — which is
precisely what the readback was built to make possible. It caught its own
author's mistake on its first day.

---

## What changed

### One reading of a placement

`WorldRegistry.around_of(step)` is now the only place in the project that
reads the key. The builder and the readback both call it, so the sentence a
player is shown and the placement they get cannot diverge again. Verified:
`get("around"` appears in exactly one function.

### Work everything out, then fit, then build

A plan used to build each world as it went, so a world asked to contain
another only learned how big that other world was once both existed. Now:

```
pass 1   prepare every world   validate → check → solve → check → measure
pass 2   fit                   grow whichever world is the container
pass 3   build                 in the order the AI gave
```

`_create_world` was split into `_prepare_world` and `_build_world` so that
single worlds and plan steps still run one pipeline. Two pipelines would
drift apart, which is the same mistake as two readings of `around`.

### Growth belongs to every world, not to the farm

Written once in `WorldModule`, so it holds for every world there will ever
be:

```gdscript
extent(layout)          -> Vector2   how big this world is, before it is built
grow_to(layout, size)   -> bool      put more ground around it
can_grow()              -> bool      false where the shape IS the design
grown(low, high, layout)             apply the growth, about the middle
```

A new world opts in by returning its size from `extent()` and running its own
outer bounds through `grown()`. It opts out by overriding `can_grow()`.

- **Farm** grows by pushing the fence out. The fields never move and never
  change size: the farm the player described is the farm they get, with more
  land around it.
- **Dungeon** grows by pushing the rock out. The rooms stay where the lattice
  put them.
- **Racing** cannot grow. A circuit's shape *is* the design — the straights
  are the lengths the player asked for — so stretching it to fit around
  something else would quietly hand them a different track. It opts out, and
  the other world grows instead.

When neither world holds the other, the bigger is asked to grow first; if it
cannot, the smaller is asked to contain the bigger, which is the same
relationship seen from the other side. Only when both refuse is the plan
refused, and then it reports both sizes.

Growth is capped at `PLAN_MAX_EXTENT` (2000 m), because this runs on an Intel
HD Graphics 3000 and a kilometre of fence is not something it can draw.

### Nothing is hidden

Every growth is recorded on the plan (`record["fitted"]`) and announced.

A plan that still fails now writes each prepared world's record with a valid
proposal and `construction: FAILED`, rather than losing them. Previously a
step could record `VALID / BUILT` for a world that was torn down moments
later.

---

## Proof

Attempt 4 replayed as typed JSON, which bypasses the AI entirely so the input
is identical every time:

```
before   PLAN failed: FAILED_SCENE — step 2 overlaps step 1
after    Plan built in 2 steps: CREATE_FARM, CREATE_TRACK
         Farm grown to 430 by 430 m so the circuit fits inside it
```

The farm was already 430 m wide and needed no help there. It was 380 m deep
against a circuit needing 430, and it grew only in depth. Genesis measured
both worlds, worked out which was the container, and resized it — none of
which the player ever had to know about.

---

## What this makes Genesis able to do

Before, a relationship between two worlds only worked if the player happened
to ask for sizes that fitted. Now the player states the relationship and
Genesis solves the geometry:

```
the player says     "a race track in a farm"
Genesis works out    circuit 300 × 400, farm 430 × 380
Genesis decides      the farm is the container, and is 50 m short in depth
Genesis grows        the farm to 430 × 430
Genesis builds       the circuit inside the farm
```

That generalises to anything either world can be — a dungeon in a farm, a
farm in a dungeon, and whatever world is written next — without touching this
code again.

---

## Honest notes

- **The lost fix.** The `around` correction was written, sent, and never
  installed. When the readback work began, the mirror was reset to the last
  pushed commit and the fix went with it, so it was rebuilt on a version that
  did not have it. That is why the readback and the builder disagreed. The
  repair is structural rather than a patch that has to stay applied.
- **The circuit's extent was mis-derived by hand, twice**, with the axes
  swapped, and an earlier draft of this document reported the misses as 16 m
  and 12 m. They were 120 m and 50 m, both in depth. The correct figures came
  from running the real geometry, not from reasoning about it.
  `TrackGeometry.bounds()` is a copy of `CircuitBuilder`'s own accumulation
  loop — same `sample`, same `advance`, same min/max — so the two agree by
  construction, which is the only reason the growth came out right while the
  prose was wrong.
- **`PARTIAL` construction still has no producer.** A failed plan rolls back
  whole, so the value stays reserved rather than manufactured.
