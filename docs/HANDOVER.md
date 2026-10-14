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
- Last commit at the time of writing: 024, the suite that was skipped as
  broken for ten releases and was only stale.
- Godot 4.7.1, Compatibility renderer. The owner's machine is an Intel HD 3000
  through ANGLE: no WebGL2, so **the web build cannot be viewed there**.

## How the two of us work

**OWNER, 2026-10-14: the owner is the EDITOR.** The assistant writes; the
owner edits. That is a sharper word than "tester" and it was chosen
deliberately, so it is worth being exact about what it means here:

- **The assistant drafts.** It implements, runs the headless suite, writes the
  docs, and pushes — on its own initiative, every two hours, without being
  asked (see "Work that happens unattended").
- **The owner rules.** He runs it in the Godot editor on real hardware with a
  live API key, and what he reports is the agenda. His logs outrank the
  assistant's judgement about what matters: 022, 023 and 025 were all his
  sessions setting the next piece of work, not the assistant's planning.
- **An editor cuts.** He is the one who decides what is true, what stays, what
  gets dropped, and what Genesis is for. Anything that would change
  architecture, cost or product direction is his, and the assistant writes it
  into "Human decision needed" rather than deciding it.
- **A draft is not a release.** Nothing the assistant pushes is finished work
  until it has been through the editor on real hardware. Every commit says
  what was verified and what was not, so he never has to guess which he is
  reading.

This split exists because of evidence, not courtesy. The owner's machine has
found **eight faults** the assistant's suites did not, including two the
assistant introduced in the same session it was fixing others, and a false
claim about Genesis that had been sitting in these documents for releases and
had been copied into the AI's prompt. The assistant cannot reach that machine,
and a suite written by the same hand as the code inherits its assumptions.

## Work that happens unattended

**OWNER, 2026-10-14: wanted, and wanted tight.** A scheduled task, "Genesis
build loop", fires **every two hours at :23** and starts a fresh session with
no memory of any other. Everything it needs is in this repository, which is
the reason these documents are kept the way they are: they are the only
continuity the project has.

Its standing instruction is to read first (`git log`, PROTOCOL, this file,
TRAPS), then to work in this order of priority: an unaddressed finding from
one of the owner's sessions, then finishing something already started, then
the smallest useful thing on the roadmap.

**It is told to make no commit when there is nothing honestly worth doing**,
and to write down what it considered instead. A thin commit every two hours is
how a repository fills with motion and no progress, and inventing work for a
project whose thesis is *"never confuse an instruction with an
accomplishment"* would be the worst available outcome.

## Run the tests first

```
run_tests.bat "C:\path\to\Godot_v4.7.1-stable_win64.exe"      (Windows)
./run_tests.sh /path/to/Godot_v4.7.1-stable_linux.x86_64      (Linux)
```

34 files in `tests/`, of which `replay` and `prompt_test` are tools rather
than suites, leaving **32 suites**, and since 024 every one of them runs —
nothing is skipped as broken. `--all` adds the two slow racing suites.

Last full run (025, Godot 4.7.1 on Linux, headless, in a cloud container):
**suites with something to look at: 0**. Not run on the owner's Windows
machine.

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
- **A refusal is a claim about Genesis, and gets checked like one.** 023.
  `UNSUPPORTED` was the only command with no validator, and in one session it
  printed three false statements about Genesis's own abilities straight to the
  owner. A false refusal is the mirror of a false success: both are the system
  lying about itself, and the refusal was the cheaper lie because nothing was
  looking. `RefusalCheck` now contradicts a refusal that denies something
  Genesis does — **in a note, never by overturning it, and counted in no
  rate**, because the check is phrase matching and phrase matching is what
  produced traps 9 and 11.

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

  **023 added two more, from the next session, and one of them was mine from
  an hour earlier.** 022 fixed `"actually"` and left the other eight revision
  markers matching anywhere in the input, so `"instead"` did exactly the same
  thing twice in the next session — the instance fixed, the class left alone,
  in the same commit whose own notes said not to. The second was larger: the
  AI refused six requests out of seven and **five of the refusals contained a
  false statement about what Genesis can do.** See TRAPS 11 and 12.

- **The capability statement in the prompt is hand-written prose and can go
  stale.** `tests/log_023_test.gd` asserts that each thing it claims points at
  a function that still exists (`NpcGoals.delivery_line`,
  `BootsTool.stopping_distance`, `DungeonModule.is_shut`,
  `WorldRegistry.around_of`, `TrackLog.next_id`), so a capability cannot be
  deleted while the prompt still promises it. That is partial: it cannot catch
  a claim that was never quite true, only one that has stopped being true.
- **Persistence is partial, and this entry said "none of any kind" for
  releases while `/save` and `/load` were sitting in `main.gd`.** 023 copied
  the claim into the AI's capability list, so Genesis was telling players it
  could not save. 025 corrected all three places. What is actually true:
  - A world's **description** is saved and loaded — rooms, doors, zones, and
    the objects it was built with. The file is a few hundred bytes, goes back
    through the validator on the way in, and a world rebuilt tomorrow uses
    tomorrow's builder.
  - The **state it was left in** is not saved. Equipment goes back to the free
    kit, every door is open again, and a thing that had been carried somewhere
    is back where it started. So nothing can be *owned* yet — that part of the
    old claim stands.
  - Since 025 a load is **verified**: the measurements recorded the day it was
    saved are compared with the measurements taken after it is rebuilt, and
    the outcome is RESTORED, DIFFERENT (naming which measurement moved and
    both numbers) or INCONCLUSIVE. Every outcome, the good one included, says
    what was not saved.
- No guard that perceives anything, no locks, no countdown, no escape
  condition, no stealth. `docs/harness/README.md` lists what THE IMPOSSIBLE
  HEIST would still need.
- Worlds are untextured boxes. No art.
- ~~`report_test.gd` hangs with no output; pre-existing, cause unknown.~~
  **Fixed in 024, and it was never a hang.** It threw a script error on
  `u["rate"]`, a key 012 deleted when it took silence out of the understanding
  score, and a script error in a `SceneTree` aborts `_initialize` before
  `quit()`, so the process ran until the harness killed it at 600 s. Four of
  its five assertions had been right the whole time; the fifth demanded
  `rate == 0.75`, which is the exact arithmetic 012 was written to abolish.
  The suite was stale, not broken, and skipping it meant
  `scripts/session_report.gd` had **no running test for ten releases**. See
  TRAPS 13.
- Prediction and measurement of stopping distance differ by a consistent 5%,
  which is the discrete integration, not the physics. Recorded rather than
  hidden behind the tolerance that passes it.

## 024 — the suite that was skipped as broken, and was only stale

**Objective.** Pick up the one thing the repository said was broken and
nobody had read: `report_test`, on the runner's `BROKEN` list since 014 with
the note "hangs with no output at all; cause unknown".

**Starting state.** Branch `prototype-002a` at 713571a (023). Baseline run,
Godot 4.7.1 headless: suites with something to look at: 0, with `report_test`
skipped — matching what this handover already said.

**What it actually was.** Not a hang. The suite's last assertion read
`u["rate"]`, and **012 deleted `rate`**, replacing the single score with the
range `rate_best`/`rate_worst` when it took silence out of the denominator. The
missing key threw, and a script error in a `SceneTree` aborts `_initialize`
before `quit()` — so the process never exited and the harness killed it at
600 s. The error was on stderr, after a screenful of correct output on stdout,
and the runner reported a killed suite as `no result`. Each of those three
things hid the next one.

The stale assertion is worth naming: it demanded `rate == 0.75`, which is
(confirmed 1 + accepted-by-use 1 + **accepted-by-silence 1**) / judged 4 — the
precise arithmetic 012 exists to abolish, in which a player who answers
nothing scores full marks for saying nothing. Four of the suite's five
assertions were right all along. It was **stale against a rule the code had
deliberately changed**, not broken, and skipping it left
`scripts/session_report.gd` with no running test for ten releases.

**Implementation.** `scripts/` is untouched; no product behaviour changed.

- `tests/report_test.gd` rewritten against the current API: `accepted`,
  `bearing`, `moved_on`, `rate_best`, `rate_worst`. Assertions read keys with
  `get()` and a sentinel, so a key that disappears later is a FAIL line and a
  clean exit rather than another ten-minute hang.
- It now **guards 012's rule instead of merely asserting a number**: it
  summarises the same session twice, with and without the record that was
  accepted by silence, and fails if removing it moves either the denominator
  or the score. It also fails outright if `rate_best` is ever 0.75 again.
- `run_tests.sh`: `BROKEN` is empty. A script error is reported with its file
  and line instead of the bare words `SCRIPT ERROR`, and a suite killed by
  `timeout` now reports `TIMED OUT`, never `no result`.
- `run_tests.bat`: the same unskip, so the fix reaches the owner's machine.
- `tests/replay.gd`: the other script that crashed into an unreached `quit()`
  — `FileAccess.open` returning null on an unset `REPLAY_LOG` — now exits 1
  naming the variable it wants. 0.4 s instead of 600 s. TRAPS 11 says writing
  the general lesson down is not the same as applying it, so the second known
  instance is fixed in the same commit as the first.
- `docs/TRAPS.md`: trap 13.

**Evidence — what was actually run.** Godot 4.7.1 (`4.7.1.stable.official.a13da4feb`),
Linux, headless, in a cloud container:

- Baseline before the change: 0 suites with something to look at,
  `report_test` skipped.
- After: 0 suites with something to look at, `report_test` **runs and passes**,
  in 0.18 s. The full output is identical to the baseline on every other line.
- `--all`, including the two slow racing suites: 0 suites with something to
  look at.
- `report_test` verified both with and without `--fixed-fps 120`, because the
  Linux runner passes it and the Windows runner does not.
- **The new checks were proved able to fail** (TRAPS 6): silence was put back
  into `accepted` and `bearing` in `session_report.gd`, and the suite failed
  with 6 named failures including the differential check. The file was then
  restored and `git diff` confirms it is byte-identical.
- `replay.gd` verified both ways: exits 1 with its message when `REPLAY_LOG`
  is unset, and still completes normally (`REPLAY DONE groups=1`, output file
  written) when it is set.

**What the tests did NOT prove.**

- Nothing here ran on the owner's Windows machine. `run_tests.bat` was edited
  and **has not been executed** — there is no Windows host in this session.
  The change to it is the removal of one `findstr` skip line; the risk is low
  and it is not zero.
- A green suite remains necessary and not sufficient. This commit does not
  change that, and it slightly sharpens the point: the suite that was green
  for ten releases was green partly because one of its members was not
  running.
- `session_report.gd` is now covered, but only over one synthetic session
  carrying one record of each kind. It is not evidence about real sessions.
- No product behaviour was touched, so there is nothing new for the owner to
  find in the editor from this commit.

## Next action

**Still the owner's, and still a minute's work.** The proxy is built (020):
set `GEMINI_API_KEY` in the Netlify site's environment variables, and set
`NETLIFY_AUTH_TOKEN` and `NETLIFY_SITE_ID` as GitHub secrets so a push
deploys. After that, a stranger with the link can type a sentence and get a
world, which is the first time that has ever been true. Nothing the assistant
can do moves this: the key must not be in the repository.

**Smallest useful assistant task next.** 024 found a test that had gone stale
against a rule the code changed under it. That is a class, not an instance,
and the obvious next member is the one this handover already flags: the
capability statement in the AI prompt is hand-written prose, and
`tests/log_023_test.gd` can only catch a claim that has *stopped* being true,
never one that was never quite true. Reading the prompt's claims against what
the functions actually do — one claim at a time, with the test tightened where
a claim turns out to be looser than the code — is a session's work and needs
no decision from the owner.

Worth a look while it is cheap: `sweep_test` still reports that no legal
command reaches `FAILED_UNWALKABLE`, which is TRAPS 6's own example and has
been true since 005.

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
3. ~~Whether work should happen while the owner is away. The assistant does
   not run on its own — nothing happens between messages. Autonomy would
   require a scheduled task, which does not exist.~~
   **Out of date as of 2026-10-14: it exists.** 024 was committed by a
   scheduled run, with nobody watching, from a cloud container. So the factual
   claim in that item is now wrong and is struck rather than quietly edited.

   What that run can and cannot do, stated plainly because it bears on how
   much the commits below are worth:

   - It has the repository, Godot 4.7.1 for Linux and the headless suite. It
     can read, build, test, commit and push.
   - It has **no access to the owner's machine** — no Windows host, no Godot
     editor, no live API key, no GPU. So it cannot run `run_tests.bat`, cannot
     see a readback as a player sees it, and cannot produce the kind of
     evidence that has found eight of the real faults in this project.
   - It cannot ask the owner anything. A question has to wait here until the
     owner reads it, which is why this section matters more under a schedule
     than it did in conversation.

   **OWNER, 2026-10-14: settled, and tightened.** Work should happen while he
   is away, and the loop now fires every two hours rather than nightly. He is
   the editor; the loop drafts. See "How the two of us work" and "Work that
   happens unattended" above.

   The assistant's proposal within that, which the owner has not ruled on
   separately and which the loop currently follows: an unattended run should
   prefer work whose evidence it can actually produce — tests, harness,
   documentation, dead code, stale assertions, the kind of thing 024 was — and
   should be most careful with anything whose only real test is a human at the
   editor. Not because that work matters less, but because an unattended run
   would otherwise have to claim it verified something it cannot reach, and
   that is the one thing this protocol exists to prevent. The commit message
   is where that line is held: what was verified, and what was not.
