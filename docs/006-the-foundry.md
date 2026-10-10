# 006 — The Foundry

A decision recorded before it is acted on, rather than after. The question was
how to incorporate the Foundry — the place a player gets the tools they will
use — into Genesis. The answer is that it needs no incorporating: the Foundry
is Genesis running a second time, and the economy is a number substituted into
a check that already runs.

---

## The finding

Genesis already refuses a car with 5000 power, because a car's power is bounded
at 400–1800 and the spec is validated, not clamped. That refusal is the whole
mechanism an economy needs.

**Ownership is a second, narrower bound belonging to a player.**

A player who has bought nothing is bounded at 400–900. A player who has bought
the performance pack is bounded at 400–1800. A spec is validated against the
tighter of the two ranges. Everything downstream is untouched: the same
validator, the same refusal, the same wording, the same record. The free player
is told

```
the maximum power for a car is 900
```

in the same sentence the paid player is told `1800`. There is no shop inside
the command loop, no second vocabulary, no new refusal machinery, and nothing
in the engine knows what money is.

## Why this works, and why it was not designed

004 added `ToolModule` and `ToolRegistry` as siblings of `WorldModule` and
`WorldRegistry`, for the narrow reason that a player should be able to describe
a car. The consequence was larger than the reason: worlds and tools turned out
to be the same kind of object.

Both are described in ordinary language. Both are interpreted into a structured
command drawn from a whitelist. Both are validated and **refused rather than
corrected**. Both are read back in the player's own words before anything is
built. Both are measured afterwards.

The tool layer was the second instance that proved the interface was not
secretly about worlds, in the same way the dungeon was the third world that
proved the world interface was not secretly about racing. Entitlement is the
third thing that fits the same shape, and that is the evidence it is the right
shape rather than a convenient one.

## What is missing, in order

**1. The kit does not survive the session.** Nothing can be owned, so there is
no difference between a free player and a paid one — there is no player at all,
only a process. Same shape as `world_store.gd`. No server required. This blocks
everything else and is the smallest piece.

**2. A tool cannot be asked for inside a world request.** As the owner put it:

> i want to race in a farm, the track farm, the car pops up — now what kind of
> car

Today `EQUIP` is its own command, so that sentence is two requests. A plan step
must be able to carry a tool. That is a change to `PLAN`, not to the tool layer.

**3. Entitlement bounds.** The easy part, once 1 and 2 exist.

## The rule this must not break

The readback-and-refusal layer is valuable because it has never lied. The
moment a refusal is also a sales pitch, that layer acquires a reason to
mislead — to refuse slightly early, to state a limit as tighter than it is, to
make the free car feel worse than it is. This is how a system of this kind
rots, and it rots invisibly, because every individual refusal still looks
honest.

So, written into the architecture now, while it costs nothing:

> **A refusal states the limit and stops.**
>
> Any offer attached to it lives outside the command loop, in the interface,
> where a player can tell the difference between the engine stating a fact and
> the product selling them something.

A validator that shares a code path with an upsell cannot be sold to anyone who
needs to trust it.

## Against the three products

**Genesis Creator.** The Foundry is the monetisation surface and the trial
boundary. The free kit *is* the trial, which is better than a timed one because
nothing ever stops working.

**Genesis Verify.** Commercially irrelevant, architecturally load-bearing. The
product is not "a thing that checks dungeons", it is "a thing that checks
whether a generated artefact satisfies a stated requirement", and the tool
layer is the second data point for that claim.

**Genesis Engine.** The Foundry *is* the product. Entitlement bounds and
enterprise permissioning are one feature with two customers:

> this operator may configure this vehicle within these limits

is a training-simulation requirement, not a game economy. Built to sell paint,
licensed as access control.

## What this does not fix

Genesis builds grey boxes. A scene editor with an asset library, a behaviour
system and artists produces a village; the distance between the two is mostly
art, and no amount of interpreter quality closes it. What Genesis has that such
an editor does not is a record of what was asked, what was understood, what was
built, and what remains uncertain. That is the thing to sell. The boxes are
not.
