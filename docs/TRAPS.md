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

## 22. The rule written in the comment above the code that broke it

**Signature:** a readback describes a request fluently, in a sentence with no
number missing, and two requests a player would never confuse come out of it
word for word the same.

**Cause:** `RacingModule.readback` grouped sections by their type and ONE
measurement and said that one measurement. A corner's **angle** - the field
that decides which way the track turns, and the field the prompt says must
add up to +360 or -360 - was never said:

```
{"corner", radius 50, angle  90}   ->  "two 50 m corners"
{"corner", radius 50, angle -120}  ->  "two 50 m corners"
```

Measured across all ten section types and both other readbacks, eleven
fields were silent: a corner's, hairpin's, banked corner's and loop
segment's angle; a chicane's radius and its direction; a crest's and a dip's
grade; and the name, width and depth of **every room of a dungeon after the
first**, which in a chain - the commonest dungeon there is - meant everything
after the entrance.

The comment directly above the match statement records a headless test
catching exactly this for a banked corner's BANK, and says in so many words
that *"a readback that silently drops a piece is the worst kind: not wrong,
just absent, so the player has no way to see that it went missing"*. Bank was
given a phrase. The other eight fields in the same statement were not. The
general rule was written down, in that file, immediately above the code that
went on breaking it - which is TRAPS 11 with the lesson already typed out.

**The grouping made it worse than silence.** Keyed on one measurement, two
sections that differed in any other field fell into one group, and the group
took its name from the first of them. Two uphills at 8% and 14% read back as
*"two 200 m uphills at 8%"*: not a field left out but a **sentence that is
false of half the thing it describes**. Three of the twenty-six failing
assertions were only reachable this way, and every probe that built ONE
section of a type missed them.

**Why no suite saw it:** 36 suites, and the ones that read a circuit's
readback asserted that the numbers they had supplied appeared in it
(`said.contains("250")`). Every one of those assertions passes on a sentence
that drops a field, because the field it drops is not the one being looked
for. No suite had ever asked whether two DIFFERENT requests produce two
different sentences, which is the only property a readback actually has to
have.

**Do:**

- Test a readback by DIFFERENCE, never by content. "The sentence contains
  250" is satisfied by a sentence that says nothing else; "changing this
  field changes the sentence" is the thing a readback is for. The second
  also survives rephrasing, so the suite constrains the fact and not the
  wording (TRAPS 6).
- Enumerate the fields from the validator's own table, not by hand.
  `tests/said_fields_test.gd` walks `SectionValidator.FIELDS` and each tool's
  `defaults()`, so a type that grows a field grows a row on its own and the
  suite fails until the sentence grows with it. A list kept by hand in a test
  is a list that goes stale silently; this is TRAPS 21's "enumerate the
  entrances" on a third axis - enumerate what the sentence must SAY.
- Ask the question of TWO of the thing. A readback that groups says things
  about groups, and a group's name can be false in a way no single instance
  can show.
- When a comment in the file states the general rule, read the code under it
  against the rule before adding anything. The rule being written down is
  not the rule being applied - TRAPS 11 says this about commits, and it is
  just as true one line apart in the same function.

Fixed in 031, in all ten section types and every room of a dungeon, with 26
assertions that fail against the pre-031 readbacks and pass after.

---

## 23. The article rule applied to "the" and not to "a"

**Signature:** the fault TRAPS 10 fixed, in a different file, in the other
article, found while widening the sentence that contains it.

**Cause:** 022 established that a numbered name is a label and takes no
article, and put the rule in `NpcGoals._place()` - which writes **the**.
Nothing ever asked it of **a**. `Readback.article()` writes the indefinite
one, and `DungeonModule`'s readback puts it in front of a room's name and a
thing's name, so the same model output that produced *"the chamber 3"* in an
outcome line produced, measured on the pre-031 code:

```
entered through a room 1
with a key 2 in the hall
```

One fact with two renderings, applied to one of them. `tests/log_022_test.gd`
had seven assertions on this rule and all seven call `NpcGoals`.

**Do:** when a rule is a fact about a WORD, put the fact in one function and
let every rendering read it - `Readback.is_label()`, which `the` and `a` now
both ask. And when a test owns a rule, check that its subjects are every
place the rule holds and not every place the rule was first found: a suite
named after the session that found a fault inherits that session's scope,
the same way a test that quotes the prompt inherits the prompt's (TRAPS 21).

Fixed in 031, in the same commit as trap 22, because widening the dungeon's
sentence would otherwise have printed "a room 1" once per room instead of
once per dungeon.

---

## 24. The body was removed and the success string stayed behind

**Signature:** a command prints a result and nothing in the world changes.
`SPAWN_OPPONENTS count=8` in the log, no cars on the grid. Nothing errors,
nothing is red, and no suite is failing.

**Cause:** 002B replaced Prototype 001's track and opponents with world
modules and took the old builders' bodies out - 89 lines from
`opponent_builder.gd`, 148 from `track_builder.gd` - leaving the function
**signatures** and the **return strings** in place. `spawn()` still returned
`"SPAWN_OPPONENTS count=%d" % count` after the grid that made it true had
been deleted. `build()` still returned `"CREATE_TRACK corners=%d"`.
`modify_corner()` still reported which corner it had made harder. All three
strings go straight to `log_message.emit()`, so they are what a player reads,
and all three are construction-layer claims with nothing behind them - the
exact thing the carrier-delivery rule exists to forbid, one layer down and
with nobody looking.

Nobody was looking for a reason worth stating: **those were the two commands
with no readback at all.** `WorldRegistry.readback` returned the empty string
for `SPAWN_OPPONENTS` and `MODIFY_TRACK`, and inside a plan they printed the
raw JSON token, "a spawn_opponents". The layer whose only job is to describe
the request was silent about precisely the commands whose results were
invented, so there was never a sentence to compare the outcome against.

Dates, because a duration is a claim too: the commands are Prototype 001's
(stages 4-7). **002B gutted the builders on 2026-09-25** and 032 found it on
**2026-10-15** - three weeks for the false success lines, and for however long
the readback layer has existed for the silence, which this entry does not
claim to have measured.

**Do:**

- When a function's body is removed, its return string goes with it. A
  signature kept for a caller returns what is now true, not what used to be.
- **A line that states a count must read the count from what was BUILT, not
  from what was asked.** `"count=%d" % count` is the asked-for number wearing
  a result's clothes. This one is cheap to test and the test is a fact rather
  than a wording: if nothing was placed, the line must not contain the number
  that was requested. `tests/stub_claims_test.gd` asserts exactly that, and
  the first draft of 032's own replacement sentence failed it - *"a Prototype
  001 ring of 4 corners is not built any more"*, true, and still a `4` beside
  a `CREATE_TRACK` in the log.
- When an audit asks a question of a list, ask which list is **authoritative**
  rather than which list is already in hand. 029 enumerated every validator,
  030 every door of one check, 031 every field of `SectionValidator.FIELDS` -
  three audits off a table, and none off `CommandParser.allowed_commands()`,
  which is the list that decides what Genesis can be asked for at all. Two of
  its eleven members had never been described or exercised by anything.

Found and fixed in 032. What to do with the three Prototype 001 stubs
themselves - rebuild them or take them out of the whitelist - is the owner's
and is in HANDOVER under "Human decision needed".

---

## 25. The command that did nothing, and the count that called it a world

**Signature:** a request is accepted, something happens on screen, and the
ledger has no record of it. Separately, a number in the session report is
larger than the thing it names.

**Cause.** Two faults, found by one question asked of one list, and they are
the same fault at two layers: a line that describes something other than what
happened.

*The hole.* `CommandParser.allowed_commands()` admits eleven commands. 032
asked whether each one is DESCRIBED. 033 asked whether each one is
RECORDED, and four were not: `MODIFY_TRACK`, `SPAWN_OPPONENTS`, a
sectionless `CREATE_TRACK`, and `CLEAR_WORLD`. All four wrote a line to the
player's log and nothing to the ledger. Three more exits had the same
problem — the two `has_drivable()` guards and `SPAWN_OPPONENTS`' "build a
track first" — and those are the half of those commands a player actually
meets. Measured headless: an accepted `MODIFY_TRACK` left exactly one new
record, the UNDERSTANDING record about it, whose `about` field named an id
that no record in the ledger carried. So the ledger held a reference to a
record that had never been written, and the layer that exists to judge
whether Genesis understood a request was judging a request the ledger did
not contain.

*The count.* `SessionReport` counted every record with `result == "VALID"` as
a world built. Four of the eleven commands are not worlds — `EQUIP`, `ORDER`,
`SHUT`, `OPEN` — so a session in which the player equipped boots, shut a
door and sent the character on an errand, and built nothing at all, reported
**"Worlds built: 3. Made another: yes"** and **"First world after 1 min 00 s,
from \"give me boots that stop in 2 m\""**. Measured, not inferred. That is a
report the owner reads after a player session, and it had been wrong since
002G. Fixing the hole without fixing the count would have made it worse by
three: `CLEAR_WORLD` taking a world AWAY would have been counted as building
one.

**Do:**

- **A command's record is part of the command.** A handler that can return
  without appending a record has an exit that the ledger cannot see.
  `tests/ledger_said_test.gd` enumerates the whitelist, sends one accepted
  request per command, and fails if no record carries the id that request was
  given — so a command added later cannot be silent, and a command with no row
  in the table is a FAIL and never a skip.
- **A count names what it counts, off the list that defines it.** Which
  commands build a world is read from `WorldRegistry.commands()`, never
  written out in `session_report.gd`, so a world added later counts for free
  and a command that is not a world can never be counted as one. The
  assertions are enumerated from the same two registries, and they assert the
  NUMBER and never the sentence: every word of `SessionReport.describe()` can
  be rewritten and they stay green.
- **An id is the only thing tying the ledger together, so make it where the
  request is made.** Two paths into the controller — `/session NAME` and
  `/load` — set the request's context but not its id, so their records would
  have been filed under whatever the player asked for *before* them. Every
  way in now mints its own.
- **A record Genesis writes about its own housekeeping is not a player's
  request.** `/session NAME` clears the world before the tester's first
  sentence. That clear now leaves a record, which is right — the world did
  go — but counting it put a request in the tester's report that the tester
  never typed. It is counted on its own axis.

**And the one that cost the most time, which was mine:** `Dictionary.merge`
does **not** overwrite a key that is already present. Factoring six copies of
a record's header into one function meant the header set `"command"` first,
so `record.merge(module.record_fields(...))` silently stopped filling it and
**every world record was written with an empty command**. The fast suite was
green. `session_test` — one of the two slow suites, which only run with
`--all` — caught it by counting three worlds as one. A pure extraction is not
automatically safe, and the suite that catches it may be the one that is
skipped by default.

Found and fixed in 033.

---

## 26. The limits were named at the field and not at the box it came in

**Signature:** every field refusal in the project names what a legal value
would be — "and it must be 5 to 60 m" — and the refusal a player is far more
likely to meet first says four words that name nothing: `"doors must be a
list"`.

**Cause.** 028 found refusals that named no limit and fixed them in
`SectionValidator`. 029 widened that to four validators. 030 found the same
fault had three *doors* — out of range, not a number, missing — and closed
all three in all four (TRAPS 21). Every one of those is a refusal about a
FIELD. Nothing had ever asked the same question about the CONTAINER the
fields arrive in, and there were nine of them, all answering with four
words:

```
'rooms' 'doors' 'things' 'zones' 'sections'   "<key> must be a list"
a plan's 'steps'                              "a plan needs a list of steps"
'spec', in all three tools                    "spec must be an object"
```

No count, no shape, no example. `doors` is the sharp one: it is **required,
with no default**, so a dungeon described with no doors at all — which is
what a model sends when the player did not mention doors — is refused with
four words naming nothing to fix. And `spec must be an object` sat three
lines above a refusal for an *unknown* field that lists every legal one, in
the same function, in all three tools.

**Why no test saw it:** `capability_test` has asserted the limit-naming rule
across all five validators since 028, and `container_door_test` did not
exist. The rule being tested was *"a number outside its limits is refused
with the limit named"* — a rule about a number. A list is not a number, so
the suite that owned the rule could not have failed, however many validators
it swept. Trap 21 said: enumerate the ENTRANCES, not just the subjects.
This is the entrance above the ones it enumerated, and the same reasoning
reaches it — the player who gets this sentence has not got as far as a
field.

**And the fault the fix itself introduced, caught by measuring the output
rather than reading the code.** The plan's new refusal needed an example of
a step, and the obvious reading — the first whitelisted command that is not
`PLAN` — produced:

```
'steps' must be a list of 1 to 4 steps, for example
    [{"command": "MODIFY_TRACK", "parameters": {}}]
```

`MODIFY_TRACK` is a Prototype 001 stub that builds nothing, is named nowhere
in the prompt the model is sent, and is item 2 under "Human decision needed".
The refusal would have advertised a command Genesis deliberately withholds,
in a sentence nobody tests — which is **exactly** the regression TRAPS 21's
last paragraph warns about, arriving one door up from where it warned about
it. It was caught by generating the string and reading it, not by reasoning
about the code that produced it.

**Do:**

- When a rule is about what a refusal must SAY, the subjects are every door
  a request can be turned away at, and a container is a door. Trap 11 says
  fix the class; trap 21 says enumerate the entrances; this adds that the
  entrances are not all at the same depth.
- **An example in a refusal is a claim about what Genesis accepts, so render
  it from a value and hand that value back to the validator.** Every example
  Genesis now shows comes out of the module's own `lists()` declaration, and
  `container_door_test` builds a request from those same values and fails
  unless the validator accepts it. An example typed out beside the code is a
  sentence that can go stale; one rendered from the value cannot.
- **Before a refusal names a legal value, ask whether the set of legal
  values is a wall** — trap 21's warning, which bit anyway. The question to
  ask is not "is this value legal" but "is this value OFFERED": `MODIFY_TRACK`
  is whitelisted and withheld at the same time. The suite now asserts that
  every command named in an example appears in
  `AIInterpreter.assembled_prompt()`, and that a circuit's example type comes
  from `OFFERED_TYPES` and never `SECTION_TYPES`.
- **A "this sentence did not appear" assertion passes for free the day the
  sentence changes.** `plan_said_test` had one, and 034 watched it go green
  against both the old wording and the new. Every such check needs a
  positive control in the same loop: make the sentence appear first, from a
  value that should produce it, and only then assert that it does not appear
  for a value that should not.

Found and fixed in 034.

---

## 27. The plural written out by hand, at the other end of the noun

**Signature:** `"2 rooms need at least 1 doors to all be reachable"`.

**Cause.** TRAPS 10 and 23 are the same fault at the front of the noun: an
article put in by hand, found in `the`, fixed, then found again in `a`. The
rule they produced is that **a fact about a word belongs in one function
that every rendering reads** — `Readback.is_label()`. Nothing asked the
same question about the end of the word, and six sentences in the
validators and the dungeon's own measurements wrote the plural by hand.

The reason it survived every suite is worth stating because it is not about
plurals: **a person writing a test for a count writes two.** One is the
boundary nobody reaches for, in the same way that a person writing a test
for a width writes a width and never `null` (trap 20). Two sentences in the
same file already did it correctly — `"%d loop%s" % [loops, "" if loops == 1
else "s"]` — which is how the three counts beside them came to do it wrong:
the rule was known, written out twice, and read from nowhere.

**Do:**

- `Readback.plural(n, singular)` for the digit form, `Readback.count_of()`
  for the word form. Both now, so neither is written out again.
- **Sweep the output, not the sentence.** `container_door_test` collects
  every string the suite caused to be produced and fails on any `1 <word>s`.
  A sentence added later is covered without editing the suite, and a
  sentence reworded does not break it — the opposite of quoting the wording.
- **Produce the count from a state the game can actually reach.** The first
  sweep fabricated a one-room dungeon and flagged `"1 of 1 rooms"`.
  `MIN_ROOMS` is 2, so that is a sentence Genesis cannot produce, and
  asserting about it would have been guarding an assumption rather than
  checking a fact (trap 6). The sweep uses two rooms joined by one door,
  which is the smallest real dungeon and is where every count that can be
  one is one.

Found and fixed in 034, in the same commit as trap 26, because the sentence
that said `"at least 1 doors"` was one of the sentences being rewritten.

---

## 28. The bound stated to the model, and typed out by hand

**Signature:** the prompt tells the model to use *"2 to 24 zones"*. The
validator accepts one, and has since the commit that lowered the minimum
specifically so that one would stop being refused.

**Cause.** `FarmModule.MIN_ZONES` was lowered from 2 to 1 in 003, because
*"build a farm with a barn"* is about the most natural thing a first-time
player can type. The sentence in the AI's prompt was written when the
minimum was 2 and was never read again. From then on the prompt refused on
Genesis's behalf a farm Genesis accepts — and that refusal is invisible,
because it happens in the model, before Genesis ever sees the request.
Nothing in the project could have caught it: a refusal is checked by the
suite, and this is a request that is never made.

This is **TRAPS 15's shape in the prompt rather than in a limitation**: a
bound stated narrower than the truth, costing a player the request the
bound was widened for. It is also **TRAPS 26 one door along**, and in the
same file: `FarmModule.lists()` already declared `low: MIN_ZONES` so that
the *refusal* could not state a limit the check does not enforce, and the
comment above it says exactly that. Two functions below, the *prompt* typed
the same bound out by hand.

Asked of the class rather than of the sentence (trap 11), every numeric
bound in `AIInterpreter.assembled_prompt()` was measured against the
constant that enforces it. Nine agreed. One was wrong — the farm's. And one
was **stated nowhere at all**: a circuit's section count, 2 to 40, appeared
in no sentence the model reads, so a model asked for a long technical
circuit could compose 41 sections and be refused by a limit it had never
been told. That is trap 26's own fault — a door that names nothing — at the
one door that is not a refusal.

The three tool sections had none of this, and the reason is instructive:
`boots_tool.gd` and `car_tool.gd` have always written their bounds with
`%.0f` out of the constants, because a tool's limits were too many to keep
in two places. The worlds' were few enough to type.

**Do:**

- **A bound stated to the MODEL is a claim about Genesis, like a refusal and
  like a limitation.** It is the earliest claim Genesis makes and the only
  one no player ever sees being made, so it is the one most worth reading
  from the code rather than remembering. `Readback.list_rule()` says it to
  the model; `Readback.list_error()` says the same bound to the player; both
  read `lists()`.
- **Ask it of every bound at once.** One sentence was wrong out of eleven,
  and the eleventh was missing. Neither would have been found by reading the
  one HANDOVER named.
- **State the bound, do not only enforce it.** A limit the model is never
  told is a refusal waiting to happen for a reason the player cannot act on.
- The test reads the prompt with a regular expression — *"N to M members"*,
  *"at most N members"* — and compares the numbers with the declaration, so
  it does not care which sentence states the bound or how it is phrased. And
  it hands the validator lists of `low - 1`, `low`, `high` and `high + 1`
  members, so a declaration edited to match a wrong sentence fails too. The
  chain is prompt ⇔ declaration ⇔ validator, and all three links are
  measured.

Found and fixed in 035. `tests/prompt_bounds_test.gd` fails 4 times against
the pre-035 prompt.

---

## 29. The version that was supposed to tell designs apart

**Signature:** `prompt_version` is `"025-what-genesis-does-1"` on records
made under three different prompts.

**Cause.** `PROMPT_VERSION` exists for one reason: interpretation measured
under one prompt is not the same population as interpretation measured under
another, so every ledger record carries the version it was made under and
designs are only compared within one. It had moved nine times in the
project's life, each time by hand, each time because whoever changed the
prompt remembered.

Measured in 035, by extracting the prompt-contributing strings at every
commit from 025 to 034 and hashing them: **three prompts shared one version
string.** 025 and 026 are one prompt of 14470 characters. 027 narrowed two
limitations and made a second, 15030. 028 narrowed the physics capability
and made a third, 15306, which stood until 035. Both of those commits were
*about* the prompt — 027 and 028 are the two sessions that read every
limitation against the code — and both left the version behind.

So the field that exists to keep two populations apart was quietly calling
three of them one, and every before-and-after comparison across 027 or 028
is not a comparison. Nothing was checking it, because no test knew what the
prompt was supposed to be.

**Do:**

- **A version string is a claim, and the thing it versions has to be
  fingerprinted or the claim is just a memory.**
  `AIInterpreter.PROMPT_FINGERPRINT` is the sha256 of
  `assembled_prompt()`; `tests/prompt_bounds_test.gd` fails when they
  disagree and the failure message names the new hash and says to move
  `PROMPT_VERSION` as well. A prompt change now cannot ship under a stale
  version.
- A fingerprint is **not** an assertion about wording, and it is the one
  place that distinction matters in the other direction: it asserts nothing
  about what the prompt says, only that it is the one the version names. Any
  sentence in it may be rewritten; the version moves when it is.
- **The chore is the point.** Every future prompt edit now costs two lines,
  one of which the failure message writes out. That is the price of a ledger
  whose comparisons are real.
- Nothing can be done about the records already made. They are the owner's
  data on the owner's machine, and 035 did not touch them; HANDOVER records
  which character count belongs to which commit range so a reader can split
  them by hand.

Found in 035, while answering the question HANDOVER asked before the farm
fix: *does `PROMPT_VERSION` move with it?* It turned out the question had
been asked twice before and answered no.

---

## 30. The conversion that threw, where no validator stood

**Signature:** a player types a request, Genesis prints nothing at all about
it, and the ledger carries an understanding record pointing at an id no
record carries.

**Cause.** 029 established the mechanism: GDScript's `int()` and `float()`
have no constructor for `null`, `{}` or `[]`. The call does not return a
wrong number — it **throws**, and a throw abandons the rest of the function
and leaves the caller holding the constructor's default. 029 asked "what if
this is not a number" of every numeric field of every **validator** and fixed
all five.

HANDOVER then asked the fourth question off `CommandParser`'s own list, after
described (032), recorded (033) and reachable-from-the-prompt (033): **does
every command have a validator?** The answer is no — and what "no validator"
turns out to MEAN is not a missing function. It is four conversions that
throw, in exactly the places nobody had asked 029's question, because 029
asked it of validators and these commands have none.

Measured headless before anything was changed:

```
MODIFY_TRACK    "corner": {} [] null    NO RECORD AT ALL, and the
                                        understanding record still pointing
                                        at its id - 033's dangling
                                        reference, back
CREATE_TRACK    "corners": {} [] null   a record whose only reason is THE
(sectionless)                           EMPTY STRING, printed to the player
                                        as a blank line, after the world had
                                        already been cleared
PLAN step       "around": {} [] null    the plan refused for the worlds
                                        OVERLAPPING
PLAN step       "offset": {"x": null}   the world built and never positioned
SPAWN_OPPONENTS "count": {} [] null     unreachable: has_track() is always
                                        false, so the guard returns first
```

The third is the one a player pays for. `around` is **in the prompt** — the
model is told to write it — and a value Genesis could not read was silently
taken as 0, both worlds were placed at the origin, and the refusal said
*"step 2 overlaps step 1: they must stand apart, or one must be big enough
to contain the other"*. Every word of that is true and none of it is
actionable: the player asked for one world inside another, and Genesis never
read which. A refusal that describes the CONSEQUENCE of a field it could not
read is trap 18's fault with a sentence in front of it.

**And the safe reading was already in the repository, one function above two
of them.** `TrackBuilder.readback()` has read `corner` through
`Readback.as_number()` since 032, and `OpponentBuilder.readback()` has read
`count` the same way — the function whose callers' comments call it *"the one
place in Genesis that answers the type question"*. The handlers two files
along typed `int()` out by hand. That is **trap 28's shape in a handler
rather than in a prompt**, and trap 26's one door further on: the door that
is not a refusal and not a prompt, but the code that acts.

**Do:**

- **A value from the AI is converted through `Readback.as_number()`, never by
  a bare `int()` or `float()`.** The rule is not "validators check types". It
  is that the type question belongs to one function, and every reader of an
  unchecked value asks it — handlers and builders included.
- **Ask it of every command at once.** Four of eleven, and the list is
  `CommandParser.allowed_commands()`. Not one of the four would have been
  found by reading the command HANDOVER named.
- **Where the value changes what Genesis DOES, refuse and name the field.**
  Where the command builds nothing whatever it is sent, a record with a
  reason that is not the empty string is the whole of what is owed. Those are
  different debts and 036 pays them differently on purpose.
- **One reading of where a field lives.** `around` may be written at the step
  level or inside `parameters` and means the same either way (003), so the
  check reads it through the same `WorldRegistry` function the placement
  uses. A check that looked in one place would pass a step the builder then
  reads from the other.
- The suite asserts a record, a non-empty reason, a resolvable id and **the
  field NAME** — never a sentence. Its table is keyed on the whitelist, so a
  command added later with no row fails rather than passing unexamined.

Found and fixed in 036. `tests/command_schema_test.gd` fails **28 times**
against the pre-036 code.

**A near miss worth recording, because trap 14's rule is what caught it.**
The first draft of 036's own code comment said a plan step's `offset` is *"a
field no prompted request carries"*. Grepping the assembled prompt for the
thing that denies — which trap 14 exists to make automatic — found
`"offset"` in it. It is a **chicane's** sideways step, a different field
behind `SectionValidator`, so the claim was true of the plan step and would
have read as false to anyone who checked. It now says which field it means.
Measured in the same minute: a plan step's `offset` of 150 really does move a
world to x = 150, while the prompt says *"never give coordinates"* — a
working capability the prompt denies, which is trap 17 reversed and is
HANDOVER's "Human decision needed" 8 rather than this commit's to settle.

---

## 31. A sweep at the wrong granularity, and the field that fell through it

**Signature:** a question asked of every member of a list comes back *all
clear*, and the fault is one level down — at the DOORS a field arrives
through, not at the field.

**Cause.** 036 found `offset`: a field the code reads and acts on that the
prompt never offers. HANDOVER named the next task as that question asked of
every field — *for every field any handler or builder reads out of the AI's
parameters, is it named in the assembled prompt, and is it checked by
something?*

Asked exactly that way, **the answer is yes, all 44 of them**, and the sweep
reports nothing. Every field name the assembled prompt mentions has a read
site somewhere in `scripts/`. `intent` has five.

The fault is that a field is not read in one place. It arrives at a DOOR —
one per command the prompt offers it at — and `intent` is offered at **six**
and was read at **three**:

```
CREATE_FARM      "intent": {"style": STYLE}   read, checked, recorded
CREATE_TRACK     "intent": {"style": STYLE}   read, checked, recorded
CREATE_DUNGEON   "intent": {"style": STYLE}   read, checked, recorded
EQUIP car        "intent": {"style": STYLE}   READ NOWHERE
EQUIP boots      "intent": {"style": STYLE}   READ NOWHERE
EQUIP look       "intent": {"style": STYLE}   READ NOWHERE
```

Not in `game_controller._equip`, not in `ToolRegistry`, not in `CarTool`,
`BootsTool` or `LookTool`. So, measured headless before anything was
changed: **no `EQUIP` record in the ledger carried an `intent` key at all**;
`main._on_track_measured` reads `record["intent"]["style"]` for the one line
the player sees, so the panel said **`REQUESTED: not stated`** for every tool
ever asked for while a farm with the identical field said `smallholding`; and
an `intent` that was a string, a list, a number, a bool or `null` was
accepted in silence where the other five doors refuse it and name it.

**This is 036's `offset` reversed, and it is the worse direction.** `offset`
is a field the code reads that the prompt never offers, so no prompted
request reaches it and nothing is lost today — which is why it sat there for
thirty commits. `intent` at an `EQUIP` is a field the **prompt instructs the
model to send**, so it arrives on real requests and goes in the bin.

**Rules.**

- **A sweep's granularity is a claim about where faults live, and it goes
  unchecked like any other.** "Every field is read somewhere" and "every
  field is read where it is sent" are different questions with different
  answers, and the first one is the one that is easy to ask. Before
  believing a clear report, ask what unit it counted — and prefer the unit
  the model actually writes against, which here is one command's skeleton.
- **Both directions, and the prompt's direction first.** A field the code
  reads that the prompt withholds costs nothing until something writes it. A
  field the prompt offers that the code drops is being sent right now, by a
  model that was told to send it.
- **A field the prompt tells the model to send is read where it is sent:
  checked like every other field, and recorded.** Dropping it is worse than
  refusing it, because a refusal is visible and a drop is not.
- **The sixth copy of a sentence is not a fix.** Five doors asked this
  question and each wrote the sentence out by hand with its own example, in a
  project whose own `Readback` comment says *"six copies of a sentence
  diverge, and the one that diverges is the one nobody is reading"*. The
  question is now `Readback.intent_problem()` and the example is rendered
  through `as_json()`, so the six doors cannot drift and the example cannot
  promise a shape the check refuses. Trap 11, at a sentence rather than at a
  behaviour.
- **A record carries what was PROPOSED, before anything is validated.** The
  worlds have always written their record fields first, so a refused request
  says in the ledger what it was refused about. `_equip` now does too.
- The suite **enumerates the doors from `AIInterpreter.assembled_prompt()`**
  by reading its skeletons for the field, so a world or tool added later
  whose skeleton offers `intent` has no row and fails rather than passing
  unexamined — the property that would have caught this in 004, when `EQUIP`
  was written. It asserts the field is NAMED, never what the sentence says,
  and asserts that an **absent** `intent` is still accepted, so it cannot be
  satisfied by making the field required.

Found and fixed in 037. `tests/intent_door_test.gd` fails **39 times**
against the pre-037 code, all of them the three `EQUIP` doors.

**Found in the same reading and deliberately not fixed, because it moves the
prompt.** The boots section tells the model two different things about the
same player sentence. Measured with the functions that enforce it: raising
`footing` to 1.50 takes top speed from 4.48 to **2.00 m/s**, while raising
`brake` to 1200 leaves it at 4.48 and still stops in 0.59 m. The prompt's
`brake` line says *"This does NOT change top speed: someone who wants to
'stop on a sixpence' wants brake raised and nothing else"*; three lines
below, the `Every field may be left out` line says *"someone who wants
'boots that stop on a sixpence' wants footing raised and nothing else"*. The
same quoted phrase, two different fields, and the second costs more than half
the player's walking speed. Beside it: `brake` is **absent from the boots
JSON skeleton** the model copies, while being described in the bullets under
it. That is trap 28's shape and it is HANDOVER's next assistant task, with
its own commit, because a prompt change moves `PROMPT_FINGERPRINT` and
`PROMPT_VERSION` and makes designs non-comparable across it (trap 29).

---

## 32. The suite measured the opposite of what the prompt said, for 33 commits

**Signature:** a sentence in the AI's prompt names a field as the answer to a
player's request, and a green test in the same repository measures that a
different field is the right answer. Both have been true of themselves for
months.

**Cause.** `boots_tool.gd`'s prompt section said *"someone who wants 'boots
that stop on a sixpence' wants footing raised and nothing else"*. That was
written in 010 and was **true then**: `footing` was the only field that
shortened a stop. 013 added `brake`, measured it, and wrote
`behaviour_test`'s claim 5 — *"stopping sharply no longer costs top speed"* —
which asserts in so many words that `brake` does that job and `footing`
charges for it. The sentence was never read again.

Measured in 038 with the functions that enforce both, from **one** speed:

```
ordinary                 top 4.48 m/s   stops in 1.45 m from 4.48 m/s
brake raised to 1200     top 4.48 m/s   stops in 0.59 m from 4.48 m/s
footing raised to 1.50   top 2.00 m/s   stops in 1.09 m from 4.48 m/s
```

So the field the prompt named is **both the dearer answer and the worse
one**: it costs more than half the walking pace and still stops nearly twice
as far. 037's own reading of this compared each spec's stop *from its own top
speed* — 0.29 m for footing against 0.59 m for brake — which makes footing
look sharper and is not a comparison: footing lowers the speed it is then
measured from. A stop is only comparable with another stop from the same
speed.

Beside it, and the reason the wrong sentence could not even be acted on
correctly: **`brake` was absent from the boots JSON skeleton** the model
copies, while being described in the bullets under it. Swept across
`ToolRegistry.tools()`, it was the only field in Genesis that `defaults()`
declared and a skeleton omitted.

**Why nothing caught it.** The capability was asserted in the suite and the
claim was made in the prompt, and **there was no door between them**. 035
built the door for *bounds* (prompt ⇔ declaration ⇔ validator) and this is
the same shape one category along: not what a field is ALLOWED to be, but
which field DOES the thing. A claim of that kind had never been checked by
anything — 027 and 028 read the limitations and capabilities, 030 the
refusals, 035 the bounds, and this sentence is none of those. It is the only
claim in the prompt that tells the model what to **do**.

**Rules.**

- **"Someone who wants X wants FIELD changed" is a claim about Genesis, and
  the field it names is a measurement.** Not a wording question. The field's
  own name is not evidence: `braking` is the right answer for a car and
  `footing` was the wrong one for boots, and both read plausibly.
- **"And nothing else" is the other half of the claim, and it is the half
  that was false.** A field that changes two of the things a tool can
  measure cannot be offered as the answer to a request about one of them.
  `tests/claim_field_test.gd` takes each named field to the end of the range
  the prompt itself states and counts how many of the tool's readings move:
  at most one, or the sentence is not true.
- **A phrase can be claimed twice without being the same string.** *"stop on
  a sixpence"* and *"boots that stop on a sixpence"* are one request and no
  equality test would have put them together. The check is by substring.
- **A consequence stated to the model is rendered from the function that
  produces it**, exactly as 035 made every bound render from its constant
  (trap 28). The numbers in that section now come out of `top_speed()` and
  `stopping_distance()`, so the sentence cannot drift from the arithmetic
  again, and the suite asserts the prompt carries what those functions
  return.
- **A comment that records what was true once says WHEN.** The comment above
  `BootsTool.readback()` said *"'give me boots that stop on a sixpence'
  became footing 1.2, which is right"* — written in 011, left standing
  through the commit that made it wrong, and a reader following it would put
  the fault back. That is trap 22 at a sentence rather than at a rule.
- **When a new field makes an older sentence wrong, the prompt is part of the
  change.** 013 added a field, measured it, and tested it, and the one thing
  it did not do is tell the model.
- And the trap this suite walked into while being written: the sweep's regex
  was case-sensitive, so it found **two** of the three claims and reported
  all clear, because one of them begins a sentence and so begins *"Someone"*.
  That is trap 31 — a sweep is a claim about the unit it counted — inside the
  suite written to hold trap 31, and `prompt_bounds_test` carries a comment
  saying the same thing about *"At most 8 things"*. The failure mode of a
  sweep is silence.

Found and fixed in 038. `tests/claim_field_test.gd` fails **9 times** against
the pre-038 code: one for the missing skeleton field, two for the pair of
phrases that answer the same request differently, one for a claim naming a
field the model cannot send, one for `footing` moving both readings, and four
for the consequences the prompt did not state. The car's claim of the same
shape — *"a car that stops better"* → `braking` — has no closed-form
prediction to read, so it is measured by driving one in
`tests/physics_test.gd`: three cars, same five seconds of throttle, 112.9 m
to 22.95 m/s in **all three**, then stops of 28.42 m, 42.90 m and 74.74 m at
maximum, ordinary and minimum braking. That one was true, and is now measured
rather than inferred from the field's name.

---

## 33. The formula stated to the model, and the one Genesis actually does

**Signature:** the AI's prompt states an arithmetic relation between fields
the model sends — a formula, not a bound — and the function that computes it
does different arithmetic. Every number either side is correct; only the
sentence joining them is wrong.

**Cause.** `boots_tool.gd`'s prompt section said:

```
Top speed is push divided by weight times footing
```

written in 010 and never read again. `BootsTool.top_speed()` returns

```
push / (weight * footing)
```

Read by the arithmetic convention its own words follow — left to right,
division and multiplication of equal precedence — the sentence says
`(push / weight) * footing`. Measured in 039 across the declared ranges, the
two disagree for **every** legal spec:

```
push 240, weight  80, footing 0.67    sentence  2.01    top_speed()  4.48
push 600, weight  50, footing 0.40    sentence  4.80    top_speed() 30.00
push 600, weight 140, footing 0.40    sentence  1.71    top_speed() 10.71
push 240, weight  80, footing 1.50    sentence  4.50    top_speed()  2.00
```

Worst gap 25.2 m/s. But the size of the gap is not the finding. **The
sentence puts `footing` in the numerator**, so it tells the model that
raising footing makes the player faster. Genesis does the opposite, and four
lines above, in the same section, the footing bullet says so in numbers
rendered from the same function: *"at 1.50 an ordinary body walks at 2.00 m/s
rather than 4.48"*. 038 wrote that bullet and did not read this line — the
same thing 013 did when it added `brake`, measured it, and left the sentence
that 038 came back for (trap 32).

**What it cost, and it costs in both directions.** `TOP_SPEED` is 2 to 12 m/s
and *"a spec where every field is legal but the three together are faster or
slower than that is refused"*. So a model doing the stated arithmetic
proposes `push 600, weight 50, footing 0.40` believing it to be 4.80 m/s, and
Genesis refuses it at 30.00; and declines `push 600, weight 140, footing
0.40` believing it to be 1.71 m/s, which Genesis would have accepted at
10.71. That is 035's farm bound — a prompt refusing on Genesis's behalf —
arriving through arithmetic rather than through a stated limit.

**Rules.**

- **A formula stated to the model is a claim about Genesis, and it is checked
  by DOING THE ARITHMETIC.** Not by reading the sentence and agreeing with
  it: 037, 038 and this session all read that section and the first two did
  not see it. `tests/formula_test.gd` reads the clause out of
  `AIInterpreter.assembled_prompt()`, tokenises it, evaluates it for 27 specs
  spanning the declared ranges and compares each with `top_speed()`. The
  sentence may be rephrased freely and the suite stays green; it fails the
  moment the words stop meaning what the code does.
- **An order of operations is part of the claim.** A bound has one reading
  (trap 28); a formula has as many as its punctuation allows. `a divided by b
  times c` has no reading under which it means `a / (b * c)`, and the fix is
  the bracket, not a better adverb. The sentence now reads *"push divided by
  (weight x footing)"* — `x` for multiply, which this prompt already uses for
  a chicane's `2 x R`.
- **A formula carries a worked example rendered from the function**, as a
  bound is rendered from its constant (trap 28) and a consequence from the
  function that produces it (trap 32). The sentence now ends *"the ordinary
  240 N, 80 kg and 0.67 come to 4.48 m/s"*, every number of it out of
  `defaults()` and `top_speed()`, so a reader can check the arithmetic
  against an answer the code supplied.
- **A relation has a DIRECTION, and the direction is the half worth measuring
  on its own.** A formula can be wrong in a way that still produces plausible
  numbers; it cannot be wrong about which way a field pushes without the
  monotonicity failing. The suite asserts, from `top_speed()` and from no
  sentence at all, that more push is faster, more weight is slower and more
  footing is slower — so a rewording that puts `footing` back in the
  numerator fails here as well as in the evaluator.
- **A sentence this cannot parse FAILS.** The failure mode of a sweep is
  silence (trap 31), and an evaluator that shrugs at a clause it does not
  understand is a sweep that reports all clear.
- **Asked of the class, five of the six were right.** The chicane's
  `O at most 2 x R`, its sideways step of exactly `O`, a hairpin carrying the
  track back `2 x radius`, chicanes counting nothing toward the ±360, and
  signed angles turning right and left are all true and are now all measured.
  As in 035, where nine of eleven bounds were sound, the value of the session
  is the one that was not — and the five that were are now held.

Found and fixed in 039. `tests/formula_test.gd` fails **2 times** against the
pre-039 prompt: once for the arithmetic across all 27 specs, once for the
worked example that was not there.

---

## 34. A position in a list, truncated at four doors and refused at the fifth

**Signature:** a question asked of one member of a list was answered properly
once, by one session, and the other members kept the old behaviour — so the
project holds the right rule and applies it in one place.

**Cause.** HANDOVER named the next assistant task as a door for the five
procedural claims 039 had measured by hand. Two of those five turned out to be
members of larger classes, and each class had a fault in it.

**THE CLASS: a reference by POSITION.** *"R is a room's name or its number
counting from 1"* is one of **five** places the prompt tells the model to name
a piece of a world by where it sits in a list:

```
CREATE_DUNGEON  "doors": [[A, B]]      room numbers, 1 for the first
CREATE_DUNGEON  "things": [{"in": R}]  a name or a number counting from 1
ORDER           "room": ROOM           a name or a number counting from 1
SHUT / OPEN     "between": [R, R]      the token ROOM, defined under ORDERS
PLAN            step "around": N       the step number, 1 for the first
```

Asked at the DOOR rather than at the field — 037's unit, because 036's
`offset` sweep came back clear at the field and the fault was one level down —
every one of the five **bound-checks**, which is the half that holds: no
caller can reach a negative index, and in GDScript `array[-1]` is the LAST
element, so an unchecked reference would have answered with the wrong room
rather than refusing.

What did not hold is the shape of the number. A value that is a number but not
a **whole** number was taken by `int()` to the position below it, **in
silence**, at four of the five:

```
things  "in": 2.9          ->  room 2, accepted
doors   [1, 2.9]           ->  the door from room 1 to room 2, accepted
ORDER   "room": 2.9        ->  room 2 (vault), accepted
SHUT    "between": [1,2.9] ->  the door 0-1, accepted
PLAN    "around": 1.5      ->  REFUSED: "'around' must be a whole step
                               number (1 to 1), not 1.5"
```

**The fifth is the one that was already right, and that is the whole lesson.**
036 added the `around` check, reasoned it out, and wrote the sentence; nothing
carried it to the other four, because 036 was asking "does every command have
a validator?" and these four have one. The repository therefore held the
correct rule, stated in a function, for four commits, and applied it to one
member of a list of five. That is trap 11 in its quietest form: not a fault
reappearing in a different word, but a FIX that never reached its own class.

**And what it cost.** A drop, not a refusal. The prompt says of Genesis that
*"it REFUSES rather than clamping. A number outside its limits is refused with
the limit named"* — and truncation is clamping, done without saying so. A
player whose key was put in room 2 when the model wrote 2.9 is never told that
a number was rounded on their behalf, which is trap 31's rule arriving at a
different kind of field: **dropping a value is worse than refusing it, because
a refusal is visible and a drop is not.**

**THE SECOND CLASS: a refusal does not destroy what was there.** *"a new world
replaces whatever was there before"* is one member of a rule Genesis follows
everywhere else. A single world's refusal never reaches `_build_world`, so the
clear is never run; a PLAN refused for its SCHEMA returns before any clearing.
But `_execute_plan` cleared the world **before pass 1**, and pass 1 can refuse:
a plan holding one unbuildable world took the player's standing world away and
then reported that it had built nothing. Measured: a farm of 62 children down
to 0, no geometry built. There were two clears to move, not one — the tidy-up
at the end ran unconditionally too, so moving only the first still destroyed
the world at the end instead of at the beginning.

**Rules.**

- **A reference by position is a whole number, and a value that is not one is
  refused with the range named.** Numbers arrive from `JSON.parse` as floats,
  so `2` is `2.0` and a whole-number check must accept it: the test is
  `number == floor(number)`, never the type.
- **When one session answers a question properly at one door, the answer is
  the class's.** Before writing a new check, grep for the sentence it is about
  — `around_problem` had been in the repository for four commits saying
  exactly what a position may be. The cheap way to find the next fault of a
  kind is to look for where the project has already been right once.
- **One reading, so the five cannot drift.** `Readback.ordinal_index()` answers
  "which position is this, or is it none" for all five doors, and
  `whole_number_rule()` is the clause they all end their refusal with. Each
  door keeps its own locator sentence, because "thing 1: 'key' is in …" and
  "door 3: [1, 2] …" are different sentences to a player, and 037's rule is
  about the sentence that would be written five times, not the locator that
  must be.
- **A refusal does not clear the world.** Clear when a build is certain to
  start, never before it is known whether one can — and tidy up only what this
  request actually put in the scene.
- **A number said back is said as the player wrote it.** Every number is a
  float by the time a refusal prints it, so `Readback.number_said()` prints 0
  as "0" and not "0.0". Trap 10 and 23's family: a sentence stating something
  the request never said.

**Found beside it, and fixed in the same commit.** At the SHUT and OPEN door,
a room NUMBER out of range was refused as though it were a name — *"this
dungeon has no room called '0' (it has hall, vault, crypt)"* — answering with
names a model that had given a number, and naming no range. The other three
room doors all name the range or the count. Trap 18's rule at the one door
nobody had asked it of.

**Found and NOT fixed, because both are already the owner's.**

- A plan refused for **OVERLAPPING** still destroys the standing world. The
  overlap is found in pass 3 by `_place()`, after the clear and after earlier
  steps have been built, so making it safe means knowing every world's
  footprint before building any of them. That is a change to how a plan is
  built: HANDOVER, "Human decision needed" 10. **It is the more reachable of
  the two halves** — two worlds with no `"around"`, which is the shape of the
  prompt's own PLAN skeleton, take that path.
- A **sectionless `CREATE_TRACK`** clears the world and then reports that it
  built nothing. `procedure_test` found this by itself, when the refused
  request it sent each world was `{}`; it has been measured since 032 and is
  "Human decision needed" 2.

Neither is asserted as correct. A suite that guards a fault is trap 14 in its
most literal form, so the two are written into the suite's header with their
measurements and left out of its assertions.

Found and fixed in 040. `tests/procedure_test.gd` fails **38 times** against
the pre-040 code: 36 at the four reference doors that truncated, and 2 for the
plan that destroyed a world it could not replace. It fails **0 times** at
`plan around`, which is the control member of the class and the reason the
class was visible at all.


---

## 35. The rule was carried to five doors and there were thirteen

**Signature:** a refusal names a value **inside** the range the same sentence
says the value is outside. *"room 1: width is 40 m, and must be 4 to 40 m"*,
for a width of 40.4. Every suite is green, including the one written
specifically to assert that a refusal names its limit.

**Cause:** 040 found that a reference by position was truncated in silence at
four doors and refused at the fifth, and the rule it produced has five parts.
The fifth is *"a number said back is said as the player wrote it"*, and it
came with a function - `Readback.number_said()` - so that the five reference
doors could not drift apart again.

**There are thirteen doors in Genesis that say a request's number back, and
040 reached five.** The other eight rendered the same number by hand, in
three different styles, and all three ROUND:

```
dungeon_module    "%.0f" % value                    width 40.4   -> "40"
farm_module       "%.0f" % value                    barn 60.4    -> "60"
car_tool          "%.0f" % number                   grip 20.4    -> "20"
section_validator _tidy(): whole %.0f, <10 %.2f,    length 1000.04 -> "1000.0"
                  else %.1f                         angle 9.996  -> "10.00"
boots_tool        _tidy(): <10 %.2f, else %.0f      footing 1.504 -> "1.50"
                                                    push 599.5   -> "600"
world_registry    String.num(number, 2)             around 1.5004 -> "1.5"
```

A rounded number is not merely untidy. Where the value sits just past a bound,
the rounding lands it **on** the bound, and the refusal then states a number
that satisfies the limit it is refusing. That is trap 18's fault with the
limit present and correct: the player is told what the range is, shown a value
inside it, and given nothing to act on. Reachable at **every one of the five
validators**, measured headless against the pre-041 code.

**And the one reading had the same fault at its own edge.** `number_said()`
ended `String.num(number, 2)`, which rounds to two places, so 1.504 came back
as `"1.50"` against a bound printed `"0.40 to 1.50"` - inside its own range,
at the door the function was written for. So this is not only a fix that
failed to reach its class; the fix was not sufficient where it was applied.
Three of 040's five reference doors say a number wrongly in the pre-041 code
*after* 040 fixed them.

**Why no test saw it, which is the part worth keeping.**
`tests/capability_test.gd` has asserted *"a number outside its limits is
refused with the limit named"* for every bound in all five validators since
028 - trap 11 done properly, the whole class enumerated off the constants.
It probes `limits.y * 10.0 + 7.0` and a value far below the minimum. **Both
probes are effectively whole numbers**, which every rounding style renders
faithfully, so the check could not fail. Trap 6 moved one step back: not an
assertion that cannot fail, but a correct assertion fed the one input that
cannot make it fail. The class was enumerated, the doors were enumerated, the
three entrances of trap 21 were enumerated - and the **values** were the axis
nobody varied.

**Do:**

- **A fix is finished when its rule reaches every door the rule holds at, and
  "every door" is enumerated, not recalled.** Trap 11 says fix the class, not
  the instance. This is the question from the other end, and it is cheaper and
  sharper: *where has this project already been right once, and did the rule
  travel?* 040 wrote five parts of a rule and one of them had eight more
  doors. Grep for the function the fix introduced and count its call sites
  against the places the rule applies.
- **A number out of a request is said through `Readback.number_said()`, and a
  BOUND is not.** They are two different facts and they want two different
  precisions: what the player sent, exactly, and what the limit is, at the
  constant's own natural places. `boots_tool._tidy()` and
  `section_validator._tidy()` survive for the bounds alone and say so in a
  comment, because the same function doing both is how this fault was
  possible.
- **A said-back number is said FAITHFULLY, not to a fixed number of places.**
  Any fixed precision can round a value onto a bound. `String.num(value, -1)`
  says as many places as the number has; the whole-number branch keeps 0 as
  `"0"`, which is what trap 34 asked for in the first place.
- **A probe at the middle of a range tests a different thing from a probe at
  its edge.** When a bound is involved, probe just past it - and once per
  rounding style the code could be using, because the delta that exposes
  `%.0f` is invisible to `%.2f`. `said_number_test` probes every bound at
  0.4, 0.04 and 0.004 past it for that reason.
- **`is_equal_approx` is not how a validator decides a bound.** Its tolerance
  is relative, so it calls 1800.004 equal to 1800 while the validator refuses
  it strictly. The first draft of `said_number_test` used it to guard against
  probing a bound itself and reported four of its own probes as test bugs.
  Decide out-of-range the way the code under test decides it.

**Measured and deliberately NOT asserted, because it is the owner's.** A
READBACK rounds a measurement to whole metres: rooms of 12.4 and 20.5 m read
back *"entered through a 12 m hall, along with a 20 m vault"*, a barn of 30.4
by 20.6 m as *"a 30 by 21 m barn"*. The world really is built at 12.4 m, so
that sentence rounds a true fact rather than misquoting a request, which is
why it is a different question from the refusals - and whether a readback
should say *"a 12.4 m hall"* is a judgement about prose. It is in
`said_number_test`'s header with its measurement and out of its assertions, as
trap 14 requires, and it is HANDOVER's "Human decision needed" 11.

Found and fixed in 041. `tests/said_number_test.gd` fails **146 times**
against the pre-041 code: 139 at the eleven bounded fields of the five
validators, 4 at `number_said()` itself, and **3 at the reference doors 040
built the rule for**.

---

## 36. The sweep could only see one of the two ways a count goes wrong

**Signature:** a measurement panel reads *"8  (4 straight, 4 corner, 0
hairpin, 0 chicane)"*, and the suite written specifically to sweep for a
hand-written plural is green. So is the panel that reads
*"8  (2 straights, 4 corners, 0 hairpins, 0 chicanes)"* for a circuit of
eight pieces.

**Cause.** Trap 27 put the plural in `Readback.plural()` and said the right
thing about how to guard it: *sweep the OUTPUT, not the sentence*, so a
sentence added later is covered without editing the suite.
`container_door_test` does that, with the regex `\b1 [a-z]+s\b`.

**That regex is a count of ONE wearing a plural. A count of TWO wearing a
SINGULAR is the same fault and the regex cannot see it.** It is trap 6 at a
correct assertion, the way trap 35 found it one commit earlier: not an
assertion that cannot fail, but one that cannot fail for half of what it
covers. And the invisible half was the one that was broken, in both panels
that itemise a world:

```
farm, two of a kind     "3   (2 orchard, 1 barn)"      ZONE_TYPES are singular
circuit, any circuit    "8  (4 straight, 4 corner)"    four singular nouns
```

The circuit's was **unconditional**. A closed circuit needs at least two
straights and two corners (`FeasibilityGate`), so those two counts can never
be one, and every circuit Genesis has ever built read *"4 straight"*. The
farm's needs only two zones of a type.

**And the scope was the other half of it.** 034 swept the validators and the
dungeon's measurements. The session summary was not in that sweep, and a
session of ONE request - the commonest session a first-time tester has - read:

```
Session 'tester': 1 minutes, 1 requests.
First world after 1 seconds, from "a farm with a barn".
Understanding: 1 readbacks, 1 with evidence.
  understood: 100% of the 1 that bear on it
```

Four hand-written plurals in the panel the owner reads after a test session,
plus `"1 saved worlds"` at `/worlds`, `"1 of 1 measurements match"` in
`LoadCheck`, and `"1 straight(s) and 1 corner(s)"` in the feasibility gate -
which is the plural written by hand wearing a dodge.

**Found in the same line, and it is not about plurals.** The circuit's
SECTIONS panel named four of the ten types `SectionValidator` accepts, so a
circuit holding an `uphill` measured *"8  (2 straights, 4 corners, 0
hairpins, 0 chicanes)"*: **a total of 8 over an itemisation of 6**, with the
two dropped pieces unnamed beside two printed zeros. A measurement panel
whose own arithmetic is false. Measured: the validator accepts that circuit
(`ok=true`), so it is reachable by any model that sends one, and the prompt
not offering the type is not enforcement (trap 19).

**And the suite's own first draft walked into the fault it is about.**
`String.contains()` is a substring test, so `"1 requests"` contains
`"1 request"`. Measured: with `contains()`, five assertions PASSED against
the pre-042 code they were written to catch - the same one-directional
blindness, one layer up, in the suite auditing it.

**Do:**

- **The one reading is "IS THIS COUNT ONE", not "what is the plural".**
  `Readback.agrees(count, one, many)` answers it and `plural()` is a reader
  of it, because the agreement is not only the noun's: *"the 1 that bear on
  it"* is the same single fact decided a third time, by hand, at a verb.
- **Assert the two counts take DIFFERENT words.** Render the sentence at one
  and at two and fail if the word after the count is the same. That fails on
  a hand-written singular and on a hand-written plural alike, which no regex
  for either one can do.
- **Tie the sentence to the function, not to its wording.** For a panel whose
  counts are enumerable from the code, assert the output is exactly
  `Readback.plural(n, type)` with `n` read from the measurement and the types
  read from `ZONE_TYPES` / `SECTION_TYPES`. Reword `plural()` and it still
  passes; write the agreement by hand again and it fails.
- **A panel that states a total asserts arithmetic.** The counts it itemises
  must sum to the total it prints, checked by summing them - not by reading
  the sentence.
- **Enumerate a panel's categories from the code that accepts them**, never
  by hand. The four types were a copy of `OFFERED_TYPES` with no tie to it;
  `_counted()` walks `SECTION_TYPES` and names a type when it is present or
  offered, so today's line is byte-identical and a type the owner opens
  appears without this function being edited.
- **A whole-word check, never `contains()`, when the thing you are checking
  is a word's ENDING.** The substring passes on the suffix that is the fault.
- **A sentence a suite cannot reach is a sentence nothing is checking.**
  `/worlds`'s line lived inline in `Main._list_worlds()`, a `Node3D` no suite
  can instantiate, so the suite's first draft assembled the string itself and
  asserted on its own output. It is `WorldStore.saved_line()` now.

Found and fixed in 042. `tests/counted_said_test.gd` fails **24 times**
against the pre-042 code: 8 at the farm's panel, 7 at the circuit's (one of
them the arithmetic), 5 at the session summary, and one each at `/worlds`,
the feasibility gate's `(s)`, `LoadCheck`, and the output sweep.

---

## 37. The article had one function, and it could only be reached from one file

**Signature:** *"The key 2 is in the vault."* *"there is no door between the
room 1 and the room 2."* *"a lamp in the room 1."* Trap 10's signature
exactly, twenty-one commits after trap 23 was written to end it, in a file
whose own comment reads *"There is now no other way to name a room in this
file."*

**Cause.** Trap 23's rule is right and was applied to one noun. The fact -
*a numbered name is a label and takes no article* - went into
`Readback.is_label()`, and two functions were made readers of it:
`Readback.article()`, which writes **a**, and `NpcGoals._place()`, which
writes **the**.

`_place()` is a ROOM-naming function, `static`, in `npc_goals.gd`. Nothing
outside that file could call it and nothing in that file called it for
anything but a room. So **the definite article had no reader at all** for
the other things Genesis names, and ten renderings wrote it by hand.
Measured headless before anything was changed:

```
NpcGoals.readback, carry     "to have the key 2 carried to the vault"
NpcGoals.delivery_line x4    "The key 2 is in the vault."
                             "Cannot tell whether the key 2 got to ..."
NpcGoals.validate_door       "there is no door between the room 1
                              and the room 2"
DungeonModule._things_said   "... with a lamp in the room 1"
DungeonModule._room_said     "entered through a 12 m room 1"
GameController x2            "the key 2 is not in the world any more"
```

Six of the ten are in `npc_goals.gd` itself, under that comment. The
comment was written about ROOMS and was false of rooms too: `validate_door`
names two of them two hundred lines above it.

**Why no suite saw it, which is the part worth keeping.** `log_022_test` has
asserted this exact rule on a dungeon readback since 031 - seven assertions,
green every run - and **every room it asks about has a width and depth of
`null`**. That is the one branch of `_room_said()` that calls `article()`;
the branch beside it, the one every measured room takes, wrote *"a"* by
hand. A correct assertion fed the one input that could not make it fail -
trap 6, and the third commit running to find the blind spot in the CHECK
rather than in the code (traps 35 and 36 are the other two).

**And the one function had the fault at its own edge**, as trap 35's did.
`article()` chose between *a* and *an* **by the first letter**, and trap 10's
own rule is to write the rule about the thing that makes it true - which is
the **sound**. A size is rendered in front of a name, so *"a 8 m hall"*, *"a
11 m vault"* and, through `count_of()`, *"a 80 by 20 m barn"* were reachable
in every dungeon readback and every farm readback in the project's life.

**Found in the same line, and not about names.** `SectionValidator._forbid`
writes *"a"* twice in one sentence: *"'radius' is not a uphill setting (a
uphill has length and grade)"*, while `article()` one call away says *"an
uphill"*. The validator accepts `uphill` whatever the prompt offers, and the
prompt not offering a type is not enforcement (trap 19).

**Do:**

- **A function is only a "one reading" if everything that needs it can reach
  it.** `_place()` was the right rule in the wrong place: `static` in a
  module file is not the same as available. The fact and both its articles
  live in `readback.gd` now - `is_label()`, `article()`, `the()` - and
  `_place()` is a reader of `the()`.
- **A rule about a word is a rule about every word that sentence names.**
  Trap 23 asked it of the room and the thing in a dungeon readback and
  stopped there; the errand's thing, the refusal's two rooms, and the room
  after *"in"* in the very sentence trap 23 fixed were all the same fact.
- **Write the rule about the thing that makes it true - and then check the
  function that was supposed to.** Trap 10 says this and `article()` broke
  it: the letter is a proxy for the sound, and the proxy fails wherever a
  number is spoken.
- **A sweep needs both directions.** Trap 36's lesson, and this suite's own
  first draft walked into a third costume of it: `_says()` is a containment
  test, and *"a 12 m room 1"* CONTAINS *"12 m room 1"*, so a check for what
  should be there cannot see what should not. **Measured: twelve assertions
  written to catch this fault passed against the pre-043 code** until each
  one was made to assert the absence of a stray article as well.
- **A sweep built on a guess about grammar will guess wrong.** The first
  draft allowed two words between the article and the number and caught *"a
  track needs 2 to 40 sections"* ten times, because `is_label()` says yes to
  *"track needs 2"*. One word is the narrower claim and it is the one that
  is true.

**Not fixed, and said so rather than quietly:** a word beginning with a
LETTER is still decided by that letter, so *"an hour"* and *"a unicorn"*
come out wrong. That needs how a word is pronounced, which Genesis does not
have and will not get from a rule about spelling. The half that is a NUMBER
is decided by arithmetic, which is why it is the half that is fixed.

Found and fixed in 043. `tests/said_article_test.gd` fails **27 times**
against the pre-043 code.

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
> And a readback that says the same thing about two different requests has
> described neither of them.
> And a command nothing describes is a command nothing is checking.
> And a function that keeps its success string after losing its body reports
> a result it cannot have produced.
> And a command that leaves no record has not been measured, however good
> the line it printed.
> And a count is a claim about what it counted.
> And a refusal that shows an example is promising that the example works.
> And a plural written by hand is a count nobody read back at one.
> And a bound stated to the model is the first claim Genesis makes and the
> only one no player watches it make.
> And a version that does not move has stopped telling anything apart.
> And a number that is not one does not return wrong, it throws, and takes
> the rest of the function with it.
> And a refusal that describes the consequence of a field it could not read
> has told the player about the wrong thing.
> And a field the prompt tells the model to send, read nowhere, is a drop
> rather than a refusal, so nobody sees it at all.
> And a sweep that comes back clear is a claim about the unit it counted.
> And a sentence telling the model which field does the thing is a claim that
> it does, and that it does nothing else, and both halves are measurements.
> And a formula stated to the model is arithmetic Genesis claims to do, down
> to the order it does it in, so it is checked by doing the arithmetic.
> And a reference by position is a whole number, so a value that is not one is
> refused with the range named and never rounded on the player's behalf.
> And a fix that stops at the door it was found at has left its own class
> standing, so the place the project was already right once is where to look
> for the next fault of its kind.
> And a refusal does not take the world away.
> And a number said back is said as the player wrote it, at every door that
> says one and not only the ones the session that wrote the rule was looking
> at.
> And a count and the word after it agree, in both directions, so a sweep
> that can only see one of them is a claim about half a class.
> And a panel that prints a total is doing arithmetic in front of the player,
> so the pieces it names add up to it or the panel is the thing that is
> wrong.
> And the article in front of a name is one fact with two words, so a
> function only one file can reach is not the one reading it was written to
> be - and a rule written about the letter is a guess at the sound.
