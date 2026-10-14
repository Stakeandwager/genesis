# Genesis — handover

Written so another session can resume from the repository rather than from
invented history. Kept current at each meaningful intersection, as
`docs/PROTOCOL.md` requires.

**Owner's decisions are marked OWNER. Everything else is an assistant proposal
that the owner has not ruled on.** Do not promote one to the other.

---

## Starting state

- Branch: `prototype-002a`. `main` is a month-old Prototype 001 and is NOT the
  work — a shallow clone gets the wrong code (`docs/TRAPS.md`, trap 1).
- Last commit at the time of writing: 022, the five faults from the owner's
  editor session.
- Godot 4.7.1, Compatibility renderer. The owner's machine is an Intel HD 3000
  through ANGLE: no WebGL2, so **the web build cannot be viewed there**.

## How the two of us work

**OWNER.** The owner tests; the assistant builds. The assistant implements,
runs the headless suite and pushes. The owner pulls, runs it in the Godot
editor on real hardware with a live API key, and reports what happened.

This split exists because of evidence, not preference: the owner's machine has
found faults the assistant's 29 suites did not, three times in one day, and
the assistant cannot reach that machine.

## Run the tests first

```
run_tests.bat "C:\path\to\Godot_v4.7.1-stable_win64.exe"      (Windows)
./run_tests.sh /path/to/Godot_v4.7.1-stable_linux.x86_64      (Linux)
```

31 suites in `tests/`, run against the scripts beside them. `--all` adds the
slow racing suites. Last full run: **suites with something to look at: 0**.
`report_test` is skipped as known broken; `replay` and `prompt_test` are tools,
not suites.

## What Genesis is

**OWNER.** A player's sentence becomes a world they can act in, and the system
measures whether it did what it claimed:

```
PLAYER -> NATURAL LANGUAGE -> AI INTERPRETATION -> STRUCTURED COMMAND -> GODOT ACTION
```

The AI interprets and proposes. It never writes code, never invents a command,
and is held to a whitelist. Godot validates, builds and measures.

**OWNER.** Four evidence layers are kept apart and never merged:
interpretation, validation, construction, behaviour.

## What exists

Three worlds — farm, racing circuit, dungeon — all described in words. A
circuit can be driven and raced. A dungeon can be walked on foot (`/explore`),
contains objects that can be carried, has doors that can be shut mid-errand,
and holds one character who can be ordered about in plain English.

Two tools in the Foundry: a car and boots, each a bounded spec the player
describes and the validator refuses rather than clamps.

The record keeps: what was asked, what Genesis understood, whether the proposal
was valid, whether it was built, what the carrier attempted, what the world
verified, and what remains uncertain.

## Rules that have earned their place

- **One reading.** Anything that both acts and describes must read from the
  same function, or the two diverge and the description becomes a lie.
  `WorldRegistry.around_of()`, `DungeonModule._wall_rects()`,
  `DungeonModule.is_shut()`, `BootsTool.top_speed()`.
- **Refuse, never clamp.** A spec outside its limits is refused with the limit
  named. `BootsTool` also refuses a combination whose fields are each legal.
- **A readback must not be silent about part of the request**, or it cannot
  catch a dropped clause, which is the only thing it is for.
- **Silence is not agreement.** `ACCEPTED_BY_SILENCE` is recorded and excluded
  from the understanding score.
- **A carrier's claim is evidence of an attempt, not of delivery.** Delivery is
  read from the thing's position in the world. There is no code path by which a
  character reports its own success.
- **"Cannot tell" means cannot tell.** `INCONCLUSIVE` is only for a thing that
  is not in the world; a thing in the wrong place is a known failure.

## Limitations — unverified or absent

- **Nothing has been tested by anybody but the owner.** No stranger has used
  Genesis. The external-usability claim is entirely unmeasured.
- **The web build still has no AI until the key is set on Netlify.** The proxy
  is built (`netlify/functions/interpret.js`, 020) and the browser asks it
  instead of Google, but it reads `GEMINI_API_KEY` from the Netlify site's
  environment and nobody has set one. Until that is done a visitor gets raw
  JSON only. Setting it is the owner's, on the Netlify site, never in the
  repository. **Not verified end to end**: the function is JavaScript and
  cannot be run by the Godot harness, so what is tested is what it is written
  to do, not a round trip through a live browser.
- **The assistant's test suite is written by the same hand as the code** and
  inherits its assumptions. It has now missed **eight** real faults that the
  owner's editor found, five of them in a single session (022). Treat a green
  suite as necessary, never sufficient.

  The five are worth stating together, because they are one pattern. None was
  a crash. Everything in that session RAN — a key was fetched, carried and
  verified from its own position. What came out wrong were **sentences**: a
  readback describing the defaults instead of the request, two `REVISED`
  verdicts invented from the word "actually", a plan readback that could not
  describe half of what it had just built, "the room 2", and a refusal that
  named no fixable fault. Four of the five were a layer whose only job is to
  describe the request describing something else instead. A suite written
  against the implementation cannot see those, because the implementation is
  where the wrong sentence comes from. `tests/log_022_test.gd` is written
  against the owner's log instead, quoting it.
- No persistence of any kind: equipment, worlds and objects do not survive a
  restart, so nothing can be owned.
- No guard that perceives anything, no locks, no countdown, no escape
  condition, no stealth. `docs/harness/README.md` lists what THE IMPOSSIBLE
  HEIST would still need.
- Worlds are untextured boxes. No art.
- `report_test.gd` hangs with no output; pre-existing, cause unknown.
- Prediction and measurement of stopping distance differ by a consistent 5%,
  which is the discrete integration, not the physics. Recorded rather than
  hidden behind the tolerance that passes it.

## Next action

The proxy is built (020). The next step belongs to the owner and takes a
minute: set `GEMINI_API_KEY` in the Netlify site's environment variables, and
set `NETLIFY_AUTH_TOKEN` and `NETLIFY_SITE_ID` as GitHub secrets so a push
deploys. After that, a stranger with the link can type a sentence and get a
world, which is the first time that has ever been true.

## A likeness from a photo (021 and beyond)

**OWNER, 2026-10-14: wanted, all three stages.** Appearance was already a
solved category - every tool splits its spec into what changes WHAT YOU CAN DO
(bounded, refused, measured) and what changes HOW YOU LOOK (free, unlimited).
A face is the second kind, so it needed no new idea.

**Stage 1 is built (021).** `LookTool` is the third tool and the first with no
bounded capabilities at all, which is worth having for its own sake: it proves
the interface is about describing things rather than limiting them. The body
has a head, and a picture from the player's own computer goes on the front of
it. A file that is absent, or is not a picture, is refused with the reason -
the same wall a car's power goes through, applied to a file.

**The photo stays on the machine.** It is read off disk, turned into a texture
and drawn. Nothing is uploaded, nothing is stored by Genesis, and no template,
measurement or identity is derived from it. The spec carries a PATH, never an
image, and the readback never says the path back - half a file path is usually
somebody's name. That keeps this cosmetic rather than biometric, and the line
is far easier to hold from the start than to walk back across later.

**Stage 2 - a head shaped like yours.** NOT BUILT, and it needs a decision
before it can be. Single-image face reconstruction needs either a hosted
service, which means the photo leaves the machine and the cosmetic/biometric
line above is crossed, or a local model, which Godot cannot host and the
owner's HD 3000 cannot run. There is no third option. HUMAN DECISION: which of
those two costs is acceptable, or whether stage 2 waits for different hardware.

**Stage 3 - yours, animated.** NOT BUILT, and it is not code. A rigged
humanoid with a walk cycle is authored art - Synty, Quaternius, Mixamo or
similar. HUMAN DECISION: which assets to licence. Once they exist the wiring
is a session's work.

**Also not decided:** face recognition as a LOGIN was raised and argued
against. It answers the *identity* leg of ownership at the highest possible
price: harder than an email login, less reliable, and it makes the LLC a
biometric data controller under BIPA, the Texas statute and GDPR special
category rules. Ordinary accounts do the same job for nothing.

## Human decision needed

1. **Commit authorship.** Commits since 2026-10-10 are authored by
   "Claude Opus 5"; before that by the owner with the assistant as co-author.
   The protocol asks for a record of what the AI contributed and what the human
   accepted, which the current arrangement gives accurately. The owner has not
   ruled on which they want.
2. ~~Whether scripts may be pushed before the owner has run them.~~
   **OWNER, 2026-10-14: settled.** The owner's job is testing. The assistant
   builds, tests headlessly and pushes - scripts included. The owner pulls,
   runs it on real hardware with a real API key, and reports what happened.
   Hand-pasting files is not testing; it was the owner acting as a file
   transfer protocol.

   In exchange, **every commit states what was verified and what was not**, so
   the owner never has to guess whether a change has been near real hardware.
   The standing caveat stands: a green suite is necessary and not sufficient.
3. **Whether work should happen while the owner is away.** The assistant does
   not run on its own — nothing happens between messages. Autonomy would
   require a scheduled task, which does not exist.
