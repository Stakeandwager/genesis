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
- Last commit at the time of writing: 027, the seven limitations in the AI's
  prompt read against the code - two of them were wider than the fact behind
  them - and a restraint in `RefusalCheck` that its own comments described and
  nothing enforced.
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

36 files in `tests/`, of which `replay` and `prompt_test` are tools rather
than suites, leaving **34 suites**, and since 024 every one of them runs —
nothing is skipped as broken. `--all` adds the two slow racing suites.

Last full run (027, Godot 4.7.1 on Linux, headless, in a cloud container):
**suites with something to look at: 0**, both without `--all` and with it.
Not run on the owner's Windows machine.

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
  `DungeonModule.is_shut()`, `BootsTool.top_speed()`, and since 027
  `RefusalCheck.sentences_of()` — the same rule applied to punctuation, after
  two functions disagreed about what a sentence was and one of them won
  silently (TRAPS 16).
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

  **027 did the other half, for the limitations rather than the
  capabilities**, which were the claims with no test behind them at all. All
  seven are now asserted as facts about the code in `tests/limits_test.gd`,
  never as words in the prompt. Two were stated wider than the fact behind
  them and are narrowed; see 027 below and TRAPS 15. What is still unaudited
  by this route is the **capability** half at its width — each one points at a
  live function, but nothing asks whether the function does as much as the
  sentence promises.
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

## 027 — the limitations, read against the code

**Objective.** The task this file named for an unattended run: read the AI
prompt's claims against what the functions actually do, one at a time, and
tighten the test where a claim turns out to be looser than the code. Starting
with the **limitations**, because they were the claims with no test behind
them at all, and because TRAPS 14 — the only entry in that file about a false
statement Genesis made about itself to a player — was a limitation.

**Starting state.** Branch `prototype-002a` at 8d4f8a2 (026). Baseline run,
Godot 4.7.1 headless: suites with something to look at: 0, 33 suites.

**What the audit found.** Five of the seven limitations in WHAT GENESIS REALLY
CANNOT DO are true at exactly the width they are stated: one character (an
ORDER has no field that could name a second), one order at a time, no locks,
one set of equipment, and a farm's size coming out of its zones. Two were
**true about the mechanism and too wide about what a player gets** — which is
a different fault from TRAPS 14's false limitation, and grep does not find it:

- *"A sequence of steps to be done in order is not possible."* **carry is
  itself a staged errand**: the character walks to the thing, picks it up at
  the waypoint where the thing stands, and carries it on to the room. That is
  one ORDER, and it is one of only two goals Genesis has. The sentence invited
  the model to refuse *"take the red key to room 3"* as a sequence — which is
  close to verbatim one of the requests in the owner's 023 session.
- *"No zone of a farm is checked against anything else for overlap, so 'do not
  let the circuit cross the barn' cannot be promised."* Nothing checks, and
  nothing needs to: zones are laid out in rows with a lane between them and
  **cannot overlap each other**. Swept 300 random legal farms — no overlap
  anywhere, tightest gap 6.0 m, exactly `LANE_WIDTH`. So *"do not let the barn
  sit in the pond"* was already true of every farm Genesis builds and would
  have been refused. What really is unchecked is a zone against something
  OUTSIDE the farm, which is the circuit and nothing else.

**And a second fault, in the wall that stands in front of a refusal.**
`RefusalCheck` decides two things per sentence — the negation must come before
the capability word, and a sentence about NUMBER is honest and left alone —
and its comments say so twice. Neither was scoped to a sentence. `_plain()`
replaces every `"."` with a space, and `_denial_in()` then split on `"."`, so
there was always exactly one "sentence": the whole refusal. It had been that
way since 023.

The consequence ran the dangerous way. **One honest clause about number
anywhere silenced the check completely**: *"This game does not include a
physics engine"* is caught, and goes through clean the moment the model also
says, truthfully, *"There are not two characters to compare."* That mixture —
one true limit of number beside one false claim about a capability — is the
likeliest thing a model writes when refusing a hundred-word brief. Every
suite had used single-sentence reasons, which is why nothing saw it.

**Implementation.**

- `scripts/ai_interpreter.gd`: the two limitations narrowed. The prompt now
  says what really cannot be done (a CHAIN OF ORDERS, a step conditional on
  an earlier one) and, in the same breath, that carry is a staged errand and
  must never be refused as a sequence; and that a farm's zones cannot overlap
  each other while a zone against anything outside the farm is unchecked.
- `scripts/refusal_check.gd`: `sentences_of()` now owns what a sentence is,
  in one place, and `_denial_in()` is handed the sentences instead of
  re-deriving them from text another function has already flattened. A full
  stop, an exclamation mark, a question mark and a newline end a sentence; a
  comma and a semicolon do not, because *"does not support A, B, or C"* is one
  list under one negation and splitting it would lose the negation for every
  item but the first — the shape three of 023's six real refusals had. A
  decimal point does not end one either.
- `scripts/refusal_check.gd`: one new capability entry, **fetching and
  carrying**, so a refusal that denies the staged errand is contradicted.
  Narrowing the prompt alone would have been TRAPS 11 again: the instance
  fixed and the class left, with nothing to catch the lie the old wording
  invited if a model makes it anyway.
- `tests/limits_test.gd`, new: all seven limitations as facts about the code,
  plus the multi-sentence refusals, plus two negative wording checks of the
  kind 025 added for "Nothing persists" — so a sentence shown to be too wide
  cannot quietly come back.
- `docs/TRAPS.md`: traps 15 and 16.

No product behaviour changed outside the prompt and the refusal note. Nothing
was touched in a module, a validator, a builder or the ledger.

**Evidence — what was actually run.** Godot 4.7.1
(`4.7.1.stable.official.a13da4feb`), Linux, headless, in a cloud container:

- Baseline before the change: 0 suites with something to look at.
- After: 0 suites with something to look at, with `limits_test` added and
  passing (69 assertions). `--all`, including the two slow racing suites: 0.
- **The new checks were proved able to fail** (TRAPS 6), five ways, each
  reverted afterwards and `cmp` used to confirm the files came back
  byte-identical: the dead sentence split put back (2 failures, both the
  multi-sentence cases); the fetching-and-carrying words removed (1); the two
  over-wide limitations put back in the prompt (3); the farm layout made to
  pack zones on top of each other (2 — 2537 overlaps, tightest gap -0.0 m);
  and a `"who"` field added to the validated goal (2).
- The farm sweep is 300 random legal farms, reported as a sweep. It is a
  sample of the legal space, not a proof over it.

**What the tests did NOT prove.**

- **No model has seen the new prompt.** The two narrowed limitations exist to
  change what Gemini refuses, and a headless harness has no key and no model.
  What is tested is that the sentences say what they now say and that the
  facts behind them hold. Whether the model stops refusing *"take the red key
  to room 3"* can only be seen in the editor with a live key. That is the one
  observation worth having from this commit.
- **`RefusalCheck` is still phrase matching**, and widening what it can see
  widens what it can get wrong. The new entry fires on carry words after a
  negation in the same sentence. The number guard covers *"there is no second
  character to carry anything"*; a phrasing nobody thought of is not covered,
  and the cost is a note the player can disagree with, never an overturned
  verdict.
- Nothing ran on the owner's Windows machine. `run_tests.bat` was not edited
  and not executed; the new suite is picked up by both runners from
  `tests/*.gd` with no list to maintain.
- The **capability** half of the prompt is still only checked for the
  existence of the functions it names, not for whether each does as much as
  its sentence promises. That is the obvious next member of this class.

## Next action

**Still the owner's, and still a minute's work.** The proxy is built (020):
set `GEMINI_API_KEY` in the Netlify site's environment variables, and set
`NETLIFY_AUTH_TOKEN` and `NETLIFY_SITE_ID` as GitHub secrets so a push
deploys. After that, a stranger with the link can type a sentence and get a
world, which is the first time that has ever been true. Nothing the assistant
can do moves this: the key must not be in the repository.

**For the owner's next editor session, and it is two sentences' worth of
typing.** 027 narrowed two limitations specifically to stop the model refusing
things Genesis does. The requests that would show it:

- *"have the character take the red key to room 3"* — in a dungeon with a key
  in it. Before 027 the prompt told the model that a sequence of steps in
  order was impossible; `carry` is exactly that, done inside one order. If
  this still comes back `UNSUPPORTED`, the prompt wording is not enough and
  the next move is an example in the prompt rather than a rule.
- *"a farm with a barn and a pond, and do not let the barn sit in the pond"* —
  which is already true of every farm, and which the old wording invited a
  refusal of.

**Smallest useful assistant task next.** The same class, other half. 027 read
the seven **limitations** against the code and asserted each as a fact. The
**capabilities** are still checked only for the existence of the functions
they name: `log_023_test` proves `BootsTool.stopping_distance` exists, not
that Genesis "predicts a stopping distance from the numbers and then measures
the real one, and reports both" — which is a wider sentence than the function
on its own supports. Eight claims, one at a time, each asserted at the width
the prompt states it or the prompt narrowed. That needs no decision from the
owner.

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

## Which model interprets — owner's question, 2026-10-14

**OWNER:** *"the si behid the thing as i gemini .. why cant we use some other
self . the 503 request is terrible"*

**The 503 itself is fixed, or at least fought, in 026.** Gemini's 503 means
*"this model is overloaded right now"*. Genesis made exactly **one** attempt
and reported the AI as unavailable, which is a transient condition stated as a
verdict — the same mistake as every entry in TRAPS. It now retries 429 and
5xx three times over about four seconds with jittered backoff, says so on
screen while it waits, and records the attempt count beside the answer. It
does **not** retry 400/401/403/404, because those will be wrong on the fourth
attempt too and three copies of the same error is worse than one.

Try that before changing provider. Three attempts over four seconds catches
most of what a single overloaded minute throws at you.

**Can another model be used? Yes, and the architecture is already built for
it.** The AI's only output is a string, which must still pass the command
whitelist, the validators, the feasibility gate and everything else. Nothing
downstream knows or cares which model produced it. That seam is real and has
been since Prototype 001.

What it would actually cost, honestly:

1. **A request/response adapter per provider.** Gemini's body is
   `system_instruction` / `contents` / `generationConfig` and its answer is
   `candidates[0].content.parts`. Every other provider differs. Perhaps 60
   lines each, in `ai_interpreter.gd`, behind the `where_to()` seam that
   already exists.
2. **Gemini 3's thought signatures.** The revision path returns the model's
   own `parts` so the signature comes back with them. That is Gemini-specific
   and would need an equivalent, or disabling, per provider.
3. **A second key, on Netlify only.** `netlify/functions/interpret.js`
   forwards three fields to one model on purpose — "a function that forwards
   whatever it is handed is an open relay with somebody's card behind it".
   A second provider means a second function or an explicit switch, plus a
   second key in the site's environment. Never in the repository.
4. **The ledger splits, and this is the one that matters here.** Every record
   carries `model` and `prompt_version` so that designs stay comparable —
   that is why `PROMPT_VERSION` exists at all. Interpretation measured under
   two different models is two populations, not one. The fields are already
   recorded, so the split is *visible*, but any before-and-after comparison
   across a model change is not a comparison.

**HUMAN DECISION, three options:**

- **(a) Keep Gemini with the retry.** Costs nothing, already built. Worth one
  session of testing before anything else is considered.
- **(b) Add a fallback.** Try Gemini; on repeated 5xx, send the same request
  to a second provider and record which one answered. Best reliability, needs
  a second key and an adapter, and the ledger must be read per model from then
  on.
- **(c) Switch outright.** Simplest code, loses the comparability of
  everything measured so far, and trades a known model's quirks for an unknown
  one's.

Also worth the owner knowing: the model is `gemini-3.1-flash-lite`, the
smallest and cheapest tier. A heavier model would likely be both more reliable
and better at interpretation, at more cost per request. That is a cost
decision, so it is his and not the assistant's.

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
