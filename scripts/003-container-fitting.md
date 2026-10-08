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

The AI was not wrong. It proposed a farm, proposed a circuit, and marked the
circuit `"around": 1`. All of it legal, all of it validated, both worlds
solved and measured. The plan was then torn down because the two worlds were
close in size and neither held the other.

Measured, the misses were small:

| attempt | farm | circuit | short by |
|---|---|---|---|
| 1 | 330 × 290 m | 392 × 312 m | 16 m |
| 2 | 530 × 480 m | 402 × 302 m | — (see below) |
| 3 | 170 × 160 m | 512 × 512 m | — (see below) |
| 4 | 430 × 380 m | — | 12 m |

Attempt 4 failed on **twelve metres of grass**. The farm's fence margin is
12 m a side. It needed 18.

---

## Why the AI could not fix it

The AI writes a list of zones. It never sees a farm's size, because the size
does not exist until Godot has:

1. sorted the zones by area,
2. packed them into rows at a working width of `sqrt(total area) × 1.35`,
3. put 6 m lanes between them,
4. and added a 12 m margin and a fence.

No amount of care at the language end can predict that. The AI was being
held to a constraint it had no way to evaluate — which is exactly the kind of
thing the protocol says belongs to Godot, not to the interpreter.

---

## Two other defects found on the way

**A dropped key.** `"around"` was read only at the step level, but the AI
writes it at the step level *or* inside `parameters`, meaning the same thing
either way. Attempt 2 had it one level too deep, so the relationship was
silently discarded and the worlds were placed unrelated. The plan was sound;
one word was in the wrong place. (Attempt 3, same cause.)

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

This was found by the readback contradicting the builder out loud — which is
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
extent(layout)    -> Vector2    how big this world is, before it is built
grow_to(layout, size) -> bool   put more ground around it
can_grow()        -> bool       false where the shape IS the design
grown(low, high, layout)        apply the growth, about the middle
```

A new world opts in by returning its size from `extent()` and running its
own outer bounds through `grown()`. It opts out by overriding `can_grow()`.

- **Farm** grows by pushing the fence out. The fields never move and never
  change size: the farm the player described is the farm they get, with more
  land around it.
- **Dungeon** grows by pushing the rock out. The rooms stay where the lattice
  put them.
- **Racing** cannot grow. A circuit's shape *is* the design — the straights
  are the lengths the player asked for — so stretching it to fit around
  something else would quietly hand them a different track. It opts out, and
  the other world grows instead.

When neither world can hold the other, the smaller one is asked to contain
the bigger, which is the same relationship seen from the other side. Only
when both refuse is the plan refused, and then it says both sizes.

Growth is capped at `PLAN_MAX_EXTENT` (2000 m), because this runs on an
Intel HD Graphics 3000 and a kilometre of fence is not a thing it can draw.

### Nothing is hidden

Every growth is recorded on the plan (`record["fitted"]`) and announced:

```
Plan built in 2 steps: CREATE_FARM, CREATE_TRACK
Farm grown to 430 by 430 m so the circuit fits inside it
```

Godot changing what the AI proposed is drift, and drift is measured here as
it is everywhere else in this project.

A plan that still fails now writes each prepared world's record with a valid
proposal and `construction: FAILED`, rather than losing them. Previously a
step could record `VALID / BUILT` for a world that was torn down moments
later.

---

## What this makes Genesis able to do

Before, a relationship between two worlds only worked if the player happened
to ask for sizes that fitted. Now the player states the relationship and
Genesis solves the geometry:

```
the player says     "a race track in a farm"
Genesis works out    circuit 400 × 300, farm 430 × 380
Genesis decides      the farm is the container, and is 25 m short
Genesis grows        the farm to 430 × 430
Genesis builds       the circuit inside the farm
```

The player never learns that a farm comes out 430 m across, and never should
have to. That generalises to anything either world can be: a dungeon inside
a farm, a farm inside a dungeon, and whatever world is written next, without
touching this code again.

---

## Honest notes

- The lost fix. The `around` correction was written, sent, and never
  installed. When the readback work began, the mirror was reset to the last
  pushed commit and the fix went with it — so it was rebuilt on a version
  that did not have it. That is why the readback and the builder disagreed.
  The repair is structural rather than a patch that has to stay applied.
- The circuit's extent was not independently re-derived. `TrackGeometry.bounds()`
  is a copy of `CircuitBuilder`'s own accumulation loop — same `sample`, same
  `advance`, same min/max — so the two agree by construction. Two throwaway
  hand-derivations of the box disagreed with each other at 3am; neither is in
  this codebase, and neither needed to be.
- `PARTIAL` construction still has no producer. A failed plan rolls back
  whole, so the value stays reserved rather than manufactured.
