# Traps

Things that have cost real time on this project, written down so they cost it
once. Each entry is the **signature** you will actually see, then the cause,
then what to do. Added to whenever something bites.

These are not Genesis defects. They are defects in how the work gets done —
which have been more expensive than the defects in the code.

---

## 1. A shallow clone gets the wrong month's code

**Signature:** the code you are reading does not match what the owner
describes, and nothing in it is obviously broken. Files you were told about
are missing.

**Cause:** `git clone --depth 1` fetches the default branch only. On this
repository that is `main`, which is a month behind. The work lives on
`prototype-002a`.

**Do:** clone with the branch named, or fetch it explicitly.

```
git clone -b prototype-002a https://github.com/Stakeandwager/genesis
```

An hour went into reasoning about Prototype 001 as though it were current.

---

## 2. A stale working copy, confidently described

**Signature:** commands are handed over for work that is already committed and
pushed. `git commit` reports **1 file changed** where eleven were expected.

**Cause:** an assistant's mirror of the repository was behind the owner's, and
the state of the repository was asserted from memory rather than read.

What actually happened on 2026-10-10: 004 and the removal of the dead
interpreter were already on the remote as `387325c` and `f0d641a`. Commands
for 004 were issued anyway, so `git add scripts` picked up **005** and
committed it under 004's message. Nothing was lost — the message was amended
before pushing — but the whole sequence was avoidable.

**Do:** read `git log --oneline -6` and `git status` **before** writing a
commit message, never after.

This is the same failure as the `around` bug in `003-container-fitting.md`:
the thing that acts and the thing that describes read from different sources.
There the fix was `WorldRegistry.around_of()`. Here the fix is the same rule
applied to a person: do not describe a state you have not just read.

---

## 3. A blocked push, retried instead of reported

**Signature:** a long gap with little to show for it. `git push` returns

```
remote: access denied by the git proxy: ... is not in this session's
authorized repository set
fatal: ... The requested URL returned error: 403
```

**Cause:** an assistant session is not always authorised to write to the
owner's GitHub. The failure is a permission boundary, not a transient error,
so retrying cannot succeed. A stop-hook that checks for unpushed commits will
keep prompting, and the loop is: commit locally → push → 403 → clean up →
commit locally again.

**Do:** on the first 403, stop. Say the push cannot happen from here, and hand
over a patch instead of files:

```
git format-patch -1 HEAD --stdout > NAME.patch
```

The owner applies it with one command, and the authorship and message survive
intact:

```
git am "C:\Users\Owner\Downloads\NAME.patch"
```

`git am --abort` puts everything back if it will not apply.

**Also do:** leave no local commit behind in a mirror that cannot push. A
commit sitting in an unpushable copy is the cause of trap 2 next time.

---

## 4. `findstr` treats spaces as OR

**Signature:** a search for an exact phrase returns most of the file.

**Cause:** `findstr /n "POND_HEIGHT :="` searches for `POND_HEIGHT` **or**
`:=`.

**Do:** use `/c:` for a literal string.

```
findstr /n /c:"POND_HEIGHT :=" scripts\farm_module.gd
```

---

## 5. Expected output shown as something to paste

**Signature:** the owner pastes two readbacks into the input box as one line,
or pastes an expected result back into the game.

**Cause:** an assistant put *what you should see* in a code block. In this
conversation a code block has meant *type this*, every time, for weeks.

**Do:** inputs in code blocks, one per block, one at a time. Expected output
in prose.

---

## 6. A green suite that tests nothing

**Signature:** every test passes, including a new one, and the feature it
covers has never once failed.

**Cause:** the check cannot be reached by any legal input. 005's physical
reachability check passed 147 of 147 dungeons and could not have failed any of
them: the tightest room the schema allows leaves a body 0.8 m of slack.

**Do:** for each new check, ask whether a legal input could ever make it fail,
and write the test that answers it. `docs/harness/sweep_test.gd.txt` is the
pattern. A check that cannot fail is a guard against future change — worth
keeping, worth labelling, not worth counting as a measurement.

---

## 7. A test that needs a file it does not make

**Signature:** a suite passes on the machine it was written on and fails
everywhere else, with an error that blames the code.

**Cause:** `look_test` asked for `res://testface.png`. That picture existed on
the machine where 021 was written, made by hand, and was never committed. On a
clean checkout the assertion failed for 021's entire life and reported *"there
is no file at ..."* — which reads exactly like a fault in `LookTool`, because
it is the message `LookTool` is supposed to produce.

**Do:** a suite makes every artefact it needs and removes it afterwards. If a
test needs a picture, it writes a picture. The question to ask of any new test
is not "does it pass" but "does it pass on a machine that has never seen this
project".

---

## 8. The readback described the defaults instead of the request

**Signature:** a refused request is said back as something the player never
mentioned, and the sentence is perfectly fluent.

**Cause:** `ToolRegistry.readback` fell back to `tool.defaults()` whenever the
spec was invalid. Asked for a face from a file that was not there, Genesis
said **"a plain tan head"** — true of the defaults, and a flat untruth about
the request. 011 and 016 were the same fault in different clothes: a readback
that is silent about, or wrong about, part of the request cannot catch a
dropped clause, which is the only thing it is for.

**Do:** a readback is built from what was ASKED, laid over the defaults, and
never from the defaults alone. Describing a request is not accepting it; the
refusal still follows and nothing is built from what was said back.

---

## 9. A verdict manufactured from a common word

**Signature:** the understanding layer scores verdicts nobody gave it, and
they go into the report as evidence.

**Cause:** `REVISE` matched `"actually"` anywhere in the input. Two of eight
requests in one session were scored `REVISED` for *"confirm delivery only if
the key itself is **actually** in room 3"* and *"test whether they
**actually** do it"*. Neither is a revision; neither mentions the readback it
was scored against. A tester uses that word constantly, which is why the
fault appeared the first time a tester used Genesis properly.

**Do:** a word that is a marker in one position and prose in another is only a
marker in that position. `REVISE_OPENERS` counts only at the start of a clause
of the first sentence, and position is judged on the raw input, because
stripping the commas destroys the only thing being measured. An invented
verdict is worse than no verdict: the report counts it.

---

## 10. The article put in by hand, again

**Signature:** "Got to **the room 2**." "Fetching the red key to **the chamber
3**."

**Cause:** 019 moved the article into `_place()` and fixed the carry path.
`outcome_line` kept its own `"the %s"` and said "the room 2" again a release
later. And `_place()` only knew names beginning `"room "`, so when the AI
called the rooms `chamber_1..4` the one correct function was wrong too.

**Do:** when a phrasing rule moves into one function, delete every other way
of saying it in the same file, in the same commit. And write the rule about
the thing that makes it true — a **numbered** name takes no article — not
about the one example in front of you.

---

## 11. Fixing the instance instead of the class

**Signature:** the same fault reappears in the next session, in a different
word, and the commit that fixed the first one has a comment explaining the
general rule.

**Cause:** 022 found that `"actually"` was being read as a change of mind in
the middle of a sentence, put it behind a position test, and left the other
eight markers matching anywhere in the input — on the reasoning that those
were unambiguous. The very next session scored two more false `REVISED`
verdicts on *"record the revised intention **instead**"* and *"explain which
part is unsupported **instead** of pretending it passed"*. The same fault, one
word along. TRAPS 9 was written in that same commit and says, in so many
words, not to do this.

**Do:** when a fault is found in one member of a list, the fix is to the list.
Ask what the correct rule is for every member, state it, and apply it to all
of them — then look for the members where the rule needs a second form
(`"actually"` must start a clause; `"instead"` is clause-*final*, so it needs
to be matched anywhere in the sentence but never as `"instead of"`). Writing
down the general lesson is not the same as applying it.

---

## 12. The command with no validator

**Signature:** the AI's sentence appears on the player's screen word for word,
and it is false about Genesis.

**Cause:** every command goes through a wall — a world through its module, a
tool through its bounds, an order through the rooms that exist, a plan through
whether the outer world can hold the inner one. `UNSUPPORTED` went through
nothing. In one session that printed *"this game does not include a physics
engine"*, *"only supports static world generation without ... history
tracking"*, and *"cannot provide runtime inspection or verification of
world-state attributes"* — to the owner, unchallenged, about a project whose
entire purpose is measurement, a ledger, and verification from the world.

A refusal is a **claim about Genesis**. A false success says something happened
that did not; a false refusal says something is impossible that is not. Both
are the system lying about itself, and the second was far cheaper to produce,
because nothing was looking.

**Do:** `RefusalCheck` reads a refusal's reason and tells the player when it
denies something Genesis demonstrably does. It does not overturn the refusal,
and no rate counts it — that restraint is deliberate, because this is phrase
matching and traps 9 and 11 are two consecutive sessions of phrase matching
producing confident nonsense. The deeper fix is upstream: the prompt now
states what Genesis does and what it really cannot do, because the model was
refusing for want of being told.

---

## 13. A suite skipped as broken, and never read again

**Signature:** a suite sits on the runner's `BROKEN` list with a one-line
cause that nobody has checked. The line says it "hangs with no output at all".
Run it by hand and it hangs, which seems to confirm it.

**Cause:** two faults wearing each other as a disguise.

`report_test` asserted `u["rate"]`. **012 deleted `rate`** and replaced it with
a range, `rate_best` and `rate_worst`, when it took silence out of the
understanding score. The assertion threw.

And **a script error in a `SceneTree` aborts `_initialize` before `quit()`**,
so the process never exits. The harness waited its full 600 s and was killed.
That is the "hang": not a loop, an unreached `quit()`. The error itself was on
**stderr, after a screenful of correct output on stdout**, so a glance at the
tail of a killed run shows nothing — and the runner reported a killed suite as
`no result`, which named neither the timeout nor the error.

The suite was correct about four of its five assertions the whole time. The
fifth demanded `rate == 0.75`, which is **exactly the arithmetic 012 exists to
abolish**: confirmed 1 + accepted-by-use 1 + accepted-by-silence 1, over
judged 4. A player who answered nothing scored full marks for saying nothing.
So the suite was not broken. It was **stale against a rule the code had
deliberately changed**, and skipping it hid both the staleness and the fact
that `session_report.gd` had no running test for ten releases.

**Do:**

- A suite that cannot run is a **claim about the code**, and gets checked like
  a refusal does. Before adding anything to `BROKEN`, run it alone, keep
  stdout and stderr apart, and read the error. One minute, against ten
  releases of no coverage.
- Never diagnose from a killed run's tail. `timeout` kills at the limit and
  the useful line is usually above it, often on the other stream.
- In a `SceneTree` test, **a missing key must be a FAIL line, not a crash**.
  Read with `get()` and a sentinel and count the failure. A crash costs the
  whole timeout and tells the next person nothing.
- When a rule changes, the tests that assert the old number are part of the
  change. 012 changed the score and left an assertion demanding the number it
  had just abolished.

Fixed in 024. `BROKEN` is now empty, the runner prints the actual error and
says `TIMED OUT` rather than `no result`, and `replay.gd` — the other script
that crashed into this same unreached `quit()` — exits 1 naming the
environment variable it wants.

---

## 14. A limitation nobody rechecked, then taught to the AI

**Signature:** Genesis tells a player it cannot do something that has worked
for releases, and the sentence can be traced back to a document.

**Cause:** `HANDOVER.md` said *"No persistence of any kind: equipment, worlds
and objects do not survive a restart"*. `/save` and `/load` were in `main.gd`
the whole time, saving a world's description through the validator. The line
was written when it was true and never rechecked.

023 then copied it into the AI's capability list as *"Nothing persists …
nothing can be saved and reloaded"* — in the same commit that built
`RefusalCheck` to catch the AI making exactly that kind of false claim. The
checker could not catch it, because the prompt was the thing telling the lie.

And `log_023_test` asserted the prompt contained those words, so **the suite
was guarding the false claim rather than finding it.** That is the standing
caveat in HANDOVER — *the tests are written by the same hand as the code and
inherit its assumptions* — arriving in the most literal form available.

**Do:**

- A limitation is a claim about Genesis, like a refusal and like a skipped
  test. Before writing one into the prompt, `grep` for the feature it denies.
  One search would have found `WorldStore`.
- When a limitation goes into the prompt, the test asserts the **capability
  it describes**, not the words. "The prompt says nothing persists" tests
  nothing; "`/save` then `/load` returns the same measurements" tests the
  claim.
- State limits at the width they are actually true. *"A world comes back as it
  was built, not as it was left"* is both honest and more useful than either
  "nothing persists" or "worlds persist".

Fixed in 025, in all three places: the prompt, `HANDOVER.md` and the README.

---

## 15. A limitation stated wider than it is true

**Signature:** the limitation is not false. Every word of it is defensible
about the mechanism, and it still makes Genesis refuse something ordinary,
because the sentence a player hears is wider than the fact behind it.

**Cause:** two of the seven limitations in the AI's prompt, found by 027
reading each one against the code instead of against itself.

*"A sequence of steps to be done in order is not possible."* True of a chain
of ORDERS, which is what it was written about. But **carry is itself a staged
errand** - the character walks to the thing, picks it up at the waypoint where
the thing stands, and carries it on to the room. That is a sequence of steps
done in order, inside one order, and it is one of only two goals Genesis has.
The sentence invited the model to refuse *"take the red key to room 3"* as a
sequence, and the owner's own 023 session asked for exactly that.

*"No zone of a farm is checked against anything else for overlap, so 'do not
let the circuit cross the barn' cannot be promised."* True about **checking**
and false about the **outcome**. Zones are laid out in rows with a lane
between them and cannot overlap each other at all - 300 random legal farms,
no overlap, the tightest gap exactly one lane. So *"do not let the barn sit in
the pond"* is already true of every farm Genesis builds, and would have been
refused. What is genuinely unchecked is a zone against something OUTSIDE the
farm, which is the circuit and nothing else.

**Do:**

- TRAPS 14 says grep for the feature a limitation denies. That catches a
  limitation that is **false**. This is the one that is **true and too wide**,
  and grep does not catch it, because the feature it denies does not exist
  under that name. The question to ask instead is: *what would a player get if
  they asked for this anyway?* For the farm the answer was "exactly what they
  asked for". That is the test.
- Say what is impossible, then say what is NOT, in the same breath, when the
  two are a word apart. The prompt now says a chain of orders is impossible
  **and** that carry is a staged errand and must never be refused as a
  sequence.
- A limitation that explains its own mechanism is the suspicious kind. "No
  zone is CHECKED for overlap" describes the implementation; "zones never
  overlap" describes the world the player gets. Only the second is a claim
  worth putting in front of a player, and they pointed opposite ways.

Narrowed in 027. `tests/limits_test.gd` now asserts all seven limitations as
facts about the code - a save file that carries no door state, a kit with one
slot per tool, a goal with no way to name a character, a farm measured at the
size its zones make it - rather than as sentences in the prompt.

---

## 16. A restraint described in the comments and scoped to nothing

**Signature:** a check behaves correctly on every input anyone has tried, and
its comments explain a rule it is not applying. The rule is real, it is
written down twice, and no line of code enforces it.

**Cause:** `RefusalCheck` decides two things per SENTENCE, and says so: the
negation must come **before** the capability word, and a sentence that is
about NUMBER ("verification of two NPCs is not possible") is honest and left
alone. Both rules read a sentence at a time:

```
for sentence in said.split(".", false):
```

But `said` had been through `_plain()` first, and `_plain()` **replaces every
"." with a space**. So the split returned one element - the whole refusal -
and both rules had been running over the entire reason since 023.

The consequence ran the dangerous way. One honest clause about number
*anywhere* silenced the check completely:

```
"This game does not include a physics engine or simulation tools."
    -> caught
"There are not two characters to compare. This game does not include a
 physics engine or simulation tools."
    -> nothing
```

That second shape - one true limit of number beside one false claim about a
capability - is the likeliest thing a model writes when it refuses a
hundred-word brief, and 023's whole lesson was that those briefs are the
realistic input. Every suite had used single-sentence reasons, so nothing saw
it.

**Do:**

- When two functions have to agree about what a delimiter means, one of them
  owns it. `sentences_of()` now decides what a sentence is, in one place, and
  `_denial_in()` is handed the sentences rather than re-deriving them from
  text another function has already flattened. This is `around_of()` and
  `_wall_rects()` again, for punctuation.
- A rule scoped to a unit must be tested with **more than one of that unit**.
  A per-sentence rule tested only on single sentences is tested on the one
  input that cannot tell whether the scoping works.
- A comment describing a restraint is a claim about the code, and goes
  unchecked for the same reason a skipped test and a limitation do: it reads
  like documentation rather than like an assertion.

Fixed in 027, with the multi-sentence cases in `tests/limits_test.gd`.

---

## 17. A capability stated wider than the code, and the checker agreeing

**Signature:** the function the claim names is right there and still works, so
every existence test passes. The sentence around the function promises more
than the function does, and nothing is wrong with any single word of it.

**Cause:** trap 15 in the mirror. Two of the seven LIMITATIONS were too wide,
which made Genesis refuse things it can do. One of the eight CAPABILITIES was
too wide, which is the more expensive direction: it makes Genesis **accept**
and promise what it cannot do, and the model does the promising.

*"Genesis predicts a stopping distance from the numbers and then measures the
real one, and reports both."* Three claims. The first is true, and a player is
told the prediction when the boots go on. The second is true only of
`tests/behaviour_test.gd`, which measures a real stop against that very
prediction and which **a player cannot reach** - nothing in the game does it.
And the sentence puts *"a car and boots"* in front of all of it, while only
BOOTS have a `stopping_distance()` at all; a car has bounded braking and
nothing that turns it into a distance.

The owner's 023 session asked for exactly this, for two CARS: *"measure their
stopping distances ... compare the measured results with predictions from the
model."* With the old wording the model was being told Genesis does that.

**And `RefusalCheck` carried the same sentence.** Its rebuttal for
"measurement and physics" said *"It predicts a stopping distance from the
numbers and then measures the real one"* - so a player who correctly refused
to believe in the measured stop would have been told, by the file built to
catch Genesis understating itself, that they were understating it. A checker
is not outside the claims it checks. That is trap 14 exactly, one layer up:
in 023 the prompt told the lie the checker could not catch, and here the
checker told it too.

**Do:**

- An existence test is not a width test. "The function the claim names still
  exists" catches a capability that has been **deleted** and nothing else.
  Ask instead: *what would a player get if they asked for precisely this
  sentence?* For the measured stop the answer was "nothing", and for a car's
  stopping distance it was "nothing at all".
- Count the claims in the sentence, not the sentences. That one had three and
  was testing as one.
- When a capability is narrowed, narrow every rebuttal that repeats it, in the
  same commit. `RefusalCheck.CAPABILITIES` is a second copy of the prompt's
  claims and goes stale the same way (trap 11).
- An **absence** is a capability claim and is the kind nobody checks. Where a
  claim rests on something not existing, assert that too: `tests/capability_test.gd`
  fails if a car ever grows a `stopping_distance`, because at that moment the
  prompt would be understating Genesis.

Narrowed in 028, in both places, with the facts asserted in
`tests/capability_test.gd`.

---

## 18. A refusal that names no limit, and 34 green suites that never asked

**Signature:** out-of-range specs are refused, every validator test passes,
and a player who asked for a 2 km straight is told *"section 1 (straight):
length out of range"* and has no idea what to type instead.

**Cause:** `SectionValidator` refused eleven different bounds and named none
of them. Every other validator in Genesis names its limit, in the same shape,
and the prompt states it as a fact about the game: *"It REFUSES rather than
clamping. A number outside its limits is refused with the limit named."*

```
CarTool         power is 5000, and a car's power must be 400 to 1800
BootsTool       push is 5000, and boots' push must be 120 to 600
FarmModule      zone 1 (barn): width 500 m is outside 5-60 m
DungeonModule   room 1: width is 500 m, and must be 4 to 40 m
SectionValidator   length out of range
```

The limits lived in a single range test and the sentence was written out by
hand at every call site, so **the one function that knew the bound was the one
function that never said it** - the thing that acts and the thing that
describes reading from different places, which is the fault `around_of()` was
written to settle.

Why no test saw it: `tool_test` and `boots_test` ask whether a bad number is
**refused**. Only one assertion in the whole suite asked what the player was
**told**, for one field of one tool. A refusal has two jobs - stop the build,
and tell the player what would be allowed - and the suite was testing one of
them. The circuit is a third of the worlds Genesis builds.

It is also worth knowing WHY that file and no other. Its header reads
*"Prototype 002B - Universal Track Geometry & Vertical Axis (user's build)"*.
It arrived from another prototype and never picked up the conventions of the
one it landed in. **A file does not inherit a project's rules by being moved
into its folder**, and nothing in a green suite will tell you which file
missed them.

**And a refusal must name a limit that is real.** A chicane's offset is bounded
by twice its radius, and the check ran even when the radius had just been
refused: a radius of -145 produced *"offset is 5 m, and must be ... at most
twice the radius, which is -290 m here"*. `BootsTool` already states the rule
this breaks - a spec already being refused for a bad number does not also need
telling what that number would have done.

**Do:**

- Ask of every refusal not "was it refused" but "could the player act on
  what they were told". Assert the limit is in the message, and read the
  bound from the constant rather than typing it into the test, or the
  assertion goes stale the day the limit moves (trap 13).
- Test the claim across the whole class. The sentence in the prompt is about
  every bounded number in Genesis, so `tests/capability_test.gd` probes every
  bound in all five validators, above and below, not the one that was found
  wanting (trap 11).
- Never compute a bound from a number you have already refused.
- When a file comes in from elsewhere, read it against the conventions of the
  project it has joined. Nobody else will.

Fixed in 028.

---

## 19. A gap between two files that is deliberate and says so nowhere

**Signature:** the validator accepts ten things and the prompt offers four.
It reads exactly like a stale prompt, and the fix looks obvious, free and
overdue.

**Cause:** `SectionValidator.SECTION_TYPES` has ten members. The prompt says
*"SECTION TYPES (only these four, with exactly these fields)"* and names
straight, corner, hairpin and chicane. The other six - uphill, downhill,
crest, dip, banked_corner, loop_segment - validate, measure, close and build,
each with its own colour in `circuit_builder.gd` and its own geometry in
`track_geometry.gd`. A vertical circuit of two uphills and two downhills
closes and measures: climb 20.0 m, descent 20.0 m, height closure error 0.0.

So the obvious reading is that the prompt is behind the code, and the obvious
fix is to tell the model about the other six.

**It is not behind the code. It is holding a line, and the reason is in a
third file.** `docs/GENESIS_BRIEF.md`, under "Known rough edges":

- *Banked corners act as ramps and throw cars over the barrier: about 23
  opponent recoveries per race on a banked square.*
- *Loops are built but untested with a car.*
- *The separation check is flat, so a loop passing over itself reads as a
  crash.*
- *The solver does not check that a track returns to its starting height.*

Those are precisely the six. "Only these four" is the one thing standing
between a player's sentence and a known car-launching defect, and exposing
them would have been a regression dressed as a documentation fix - with a
green suite, because `drive_test` drives the types the prompt does not offer.

**Do:**

- Before closing a gap between two files, find out whether it is a gap or a
  wall. The question is not "which file is out of date" but "what happens to a
  player if I make them agree".
- A deliberate restriction needs its reason written where the restriction is.
  Trap 16 was a rule described in the comments and scoped to nothing; this is
  a rule enforced in one file and explained in another, three directories
  away, which is the same fault from the other end.
- A capability that works is not a capability that is ready. Validated,
  measured and built is three of four; the fourth is whether it behaves, and
  for these six the brief says it does not.

Not changed in 028, deliberately. Recorded so the next session does not
"fix" it.

---

## 20. The validator that approved what it never read

**Signature:** `validate()` returns `ok: true` and an empty error list for a
room 0 metres across, and 35 green suites agree with it.

**Cause:** every number in a request arrives through `JSON.parse`, so it can
be any type JSON has. `"width": null`, `"width": {}` and `"width": [20, 20]`
are ordinary output from a model - null for a field it has nothing to say
about, an object or a list for one whose shape it misread - and
`CommandParser` passes `parameters` through without looking inside.

GDScript's `float()` has **no constructor** for those three. It does not
return a wrong number. It THROWS, and a throw inside a function abandons the
rest of that function and leaves the caller holding whatever its variable was
initialised to. So the damage never looks like a bad measurement:

```
DungeonModule.validate, room width null/{}/[]   ok=TRUE, errors=[], width 0.0
DungeonModule.validate, a door pair holding {}  {} - no "ok" key at all
DungeonModule / FarmModule / RacingModule
  .readback on any of those three               "" - the empty string
```

The first is this project's central claim failing in the quietest possible
way: not a validator that was wrong, a validator that reported a spec sound
without having read it. The second is worse in a different direction -
`game_controller` indexes `check["ok"]` directly, so there is no verdict to
read. The third is trap 8 from the other end: the readback exists so a player
can catch Genesis building the wrong thing correctly, and it said nothing at
all.

`DungeonModule._side()` was the only numeric reader in Genesis that did not
ask `typeof()` first. `SectionValidator._number`, `FarmModule._number` and
both tools' `_bounded` all did - and so did `_things_said()`, **two hundred
lines down the same file**. So this is trap 18's shape one layer deeper: not
a file that missed the project's conventions, a FUNCTION that missed its own
file's.

It also made that one validator disagree with the other four about what a
number is. `"10"` was accepted as 10 m; `"ten"` was refused as *"width is 0 m"*
- a measurement the player never typed, which is trap 8 again, inside a
refusal.

**Why nothing saw it:** every suite hands its validators numbers, because the
person writing a test for a width writes a width. Thirty-five suites passed
before the fix and thirty-five passed after. The question had never been asked
of any field in Genesis, and the answer was not uniform - which is exactly the
kind of fault that is invisible one file at a time and obvious when the whole
class is asked at once.

**Do:**

- A value out of a request is read through **one function that checks its
  type** - `Readback.as_number()` / `Readback.measure()` - in the validator
  and in the readback alike. `float()` is never called on something that came
  from JSON.
- A string is not a number, even one that parses. `float("10")` is 10 and
  `float("ten")` is 0, so a reader that takes the first silently takes the
  second as a request for nothing.
- Probe the whole class, not the field that was found wanting (trap 11).
  `tests/request_types_test.gd` puts all six non-numbers through every
  numeric field of all five validators, reading the field lists out of the
  code so a field added later is probed without the suite being edited.
- Ask of a refusal test not only "was it refused" but **"is there an `ok` in
  the answer at all"**. A thrown conversion returns a dictionary with no
  verdict in it, which no assertion about `errors` will ever notice.
- When a readback cannot read a measurement, it leaves the measurement out
  and keeps the thing. Never 0.

Fixed in 029.

---

## 21. One fault fixed at one of its three doors

**Signature:** the fault was found, named, written into TRAPS, and fixed - and
the next session finds it again in the same function, two lines up. Every
suite is green both times.

**Cause:** 028 found that `SectionValidator` refused eleven bounds and named
none of them, and fixed it. 029 noticed the fix had been written too narrowly
and corrected HANDOVER, listing four validators that still refused without
naming a legal value. What neither noticed is that a bounded field can be
refused **three** ways, and both of them had looked at one:

```
out of range   room 1: width is 500 m, and must be 4 to 40 m    <- tested
not a number   power must be a number                           <- named nothing
missing        zone 1 (barn): missing 'width'                   <- named nothing
```

Twelve refusals, in four of the five validators, with the limits sitting in
scope on the line that wrote the sentence. `CarTool._bounded` knew `limits`;
it used them in the range branch and not in the branch three lines above.
`SectionValidator._number` did not take the limits at all, so the range
refusal named a bound the missing refusal could not.

And the two doors that named nothing are the ones a MODEL is more likely to
walk through than a player. Out of range is a player asking for a 2 km
straight. `null` and a field left out are ordinary model output for a field it
had nothing to say about - which is exactly the input trap 20 was written
about, arriving at a different layer.

**Why no test saw it:** `tests/capability_test.gd` asserted the claim "a
number outside its limits is refused with the limit named" for every bound in
all five validators, which is TRAPS 11 done properly - and still saw none of
this, because the claim it was testing is about ONE of the three doors. The
whole class was probed through a third of its entrances. 165 assertions in that suite and 34 green ones around it, and the thing nobody asked was not "which validator" but "which
way in".

**Do:**

- When a check has several entrances, enumerate the entrances before
  enumerating the subjects. Trap 11 says fix the class, not the instance; this
  is the axis trap 11 does not mention. A field can be missing, be the wrong
  type, or be out of range, and a rule about what a refusal must say is a rule
  about all three.
- A test that quotes a claim from the prompt inherits the claim's scope. "A
  number outside its limits is refused with the limit named" is narrower than
  "a refusal names what a legal value would be", and testing the first to the
  letter is how the second went unchecked. Ask what the rule behind the
  sentence is, and test that.
- The obvious fix to a nameless refusal is to make it name everything the
  validator accepts, and in one place here that would have been a regression:
  `SectionValidator` accepts ten section types and the player is deliberately
  offered four (trap 19). Listing `SECTION_TYPES` in the refusal would have
  advertised the six withheld types in the one sentence nobody was testing.
  **Before making a message name the legal values, find out whether the set of
  legal values is a wall.** `OFFERED_TYPES` now carries the four and the
  reason, where the restriction is, as trap 19 asked.

Fixed in 030, in all four validators and at all three doors, with 109
assertions that fail against the pre-030 messages.

---

> A successful build is not evidence of successful understanding.
> A passing test is not evidence that anything was tested.
> A fluent sentence is not evidence that anything was understood.
> A refusal is a claim, and gets checked like one.
> A skipped test is a claim too, and goes unchecked the longest.
> So is a limitation, and that one gets written into the documents.
> So is a capability, and that one gets promised to a player.
> And a number in a request is a claim that it is one.
> And a refusal that names no legal value is half a claim, at whichever
> door the player came in by.
