# Genesis

Describe a world. It gets built. Then the game tells you whether it did what
it said.

```
> build a dungeon with a store and a vault, with a lamp in the store
  a dungeon of two rooms joined by a door, entered through a 10 m store,
  each one leading to the next, with a lamp in the store

> take the lamp to the vault
  to have the lamp carried to the vault
  Sending someone to the vault.
  The lamp is in the vault.
```

That last line is not the character's opinion. It is the lamp's position, read
out of the world after the character set it down.

**The work is on the `prototype-002a` branch.** `main` is Prototype 001 and is
a month old.

## The idea

```
PLAYER -> NATURAL LANGUAGE -> AI INTERPRETATION -> STRUCTURED COMMAND -> GODOT ACTION
```

The AI interprets and proposes. It never writes code, never invents a command,
and is held to a whitelist. Godot validates, builds and measures. If the AI
asks for something that does not exist, it is refused before anything is built.

Four things are recorded separately and never merged:

| Layer | The question |
| --- | --- |
| Interpretation | What did Genesis understand? |
| Validation | Was that permitted? |
| Construction | Did it get built? |
| Behaviour | Did the result do what was promised? |

The fourth is the one most systems skip. Genesis says back what it understood
*before* it builds — "brown boots that stop sharply, though they only walk at
2.1 m/s" — and then measures whether the body really stops in that distance.
The sentence is a falsifiable claim, and it is checked.

## What it does

Three kinds of world, all described in words: farms, racing circuits,
dungeons. Circuits can be driven and raced. Dungeons can be walked on foot,
contain objects that can be picked up and carried, have doors that can be shut
while somebody is walking through them, and hold a character who can be
ordered about in plain English.

Equipment is described too — a car, boots, a face. A spec outside its limits
is **refused with the limit named, never quietly clamped**.

## Run the tests

```
run_tests.bat "C:\path\to\Godot_v4.7.1-stable_win64.exe"      Windows
./run_tests.sh /path/to/Godot_v4.7.1-stable_linux.x86_64      Linux
```

44 suites, run against the scripts beside them, so what is tested is what is
committed. `--all` adds the two slow racing suites, and it is worth the wait:
they are the only ones that drive a whole scripted session, and in 033 one of
them caught a fault that all 38 fast suites passed. Nothing is skipped as
broken. (This number had said 33 since the suite count passed it; it is
counted rather than remembered — `ls tests/*.gd` less `replay` and
`prompt_test`, which are tools and have no verdict to give.)

Among them: six adversarial challenges that try to make the ledger report a
delivery it has not earned (`false_delivery_test.gd`, zero false successes), a
test that reads the ledger back off disk and audits it against the world
(`ledger_audit_test.gd`), one that asserts something **cannot** happen
(`sweep_test.gd`), and two written entirely from play sessions' logs rather
than from the code, quoting the sentences that came out wrong
(`log_022_test.gd`, `log_023_test.gd`).

A refusal is checked too. `UNSUPPORTED` used to be the one answer nothing
validated — the AI wrote a sentence and Genesis printed it — and a session
that refused six requests out of seven got five of the reasons wrong about
Genesis's own abilities. A false refusal is the mirror of a false success, so
now it gets contradicted (`refusal_check.gd`).

So is a load. A save file records what Genesis measured the day a world was
built; loading rebuilds it and measures again, and nothing used to compare the
two. Now a world that comes back different is reported as different, with the
measurement named and both numbers (`load_check.gd`).

## What is not true yet

- **No stranger has ever used it.** Every session so far is the owner's.
- The worlds are untextured boxes. There is no art.
- A world can be saved and loaded, and the load is checked against the
  measurements taken the day it was saved. But only the *description* is kept:
  equipment, shut doors and anything that had been carried do not come back,
  so nothing can be owned yet.
- No guard perceives anything, no locks, no countdown, no escape.
- The web build has no AI until an API key is set on the host.

`docs/HANDOVER.md` carries the current state, what is verified and what is
not. `docs/TRAPS.md` carries the mistakes that have already cost time.
`docs/PROTOCOL.md` is how the work is done.

## Built with

Godot 4.7.1, GDScript, Gemini for interpretation. Prototype, not a product.
