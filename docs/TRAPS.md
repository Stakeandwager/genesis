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

## 38. The reading the readbacks could not use

**Signature:** a player types a request naming room 2.9. Genesis prints *"to
send someone to room 2"* and, underneath it, *"there is no room 2.9: a room
number is a whole number, 1 to 3"*. Two sentences about one request,
disagreeing about the number, in the same exchange - and the one the player is
invited to check is the wrong one. Every suite is green, including the one
written specifically to assert that this value is refused rather than
truncated.

**Cause.** Trap 34's rule is right and was applied to one layer. The fact -
*a reference by position is a whole number, and one that is not is refused
with the range named* - went into `Readback.ordinal_index()`, and 040 carried
it to all five of the doors the prompt names. **Every one of those five is a
validator or a handler.**

There are six READBACKS standing beside them that say the same reference back
to the player, and all six went on calling `int()` by hand:

```
ORDER go_to       "room": 2.9     "to send someone to room 2"
ORDER go_to       "room": 0.5     "to send someone to room 0"  (no dungeon
                                   has a room 0)
ORDER carry       "room": 2.9     "to have the key carried to room 2"
SHUT / OPEN       [1, 2.9]        "between the 1 and the 2.9"
MODIFY_TRACK      "corner": 2.9   "to make corner 2 hard"
SPAWN_OPPONENTS   "count": 1.5    "to put an opponent on the track"
CREATE_DUNGEON    "in": 2.9       "with a key in the vault"     (room 2,
                                   named, as though it had been asked for)
PLAN              "around": 1.5   "one inside the other"
```

**And the reason is the SHAPE OF THE ANSWER, not the scope of the file.**
Trap 37 found a one reading that only one file could reach. This one every
file can reach and six callers still could not use: `ordinal_index()` returns
a **resolved index, or -1**, which is precisely what a validator needs and
precisely what a readback must not have. A readback's whole job is to show
what Genesis HEARD, so a dropped or misread clause is visible (trap 8). It has
to say the value the request CARRIED and never the thing that value resolves
to. The one reading was unreachable at the layer that needed it most, and it
was unreachable through its return type.

**Why nothing saw it, which is the part worth keeping.**
`tests/procedure_test.gd` does exactly what 040 set out to do: it probes 1.5,
2.9, `count + 0.5` and 0.5 at all five reference doors and asserts each is
refused, with *"whole"* said and the range named. Seven assertions a door,
green every run since 040. **Every one of them goes through `_resolve()`,
which is the validator.** The suite is correct, its values are the right
values, its class is the whole class - and the LAYER beside it was never
asked. Trap 6 for the fourth commit running, in a fourth costume: 041's blind
spot was the probe's VALUES, 042's was the sweep's DIRECTION, 043's was the
input's SHAPE, and this one is the LAYER. Genesis keeps four evidence layers
apart on purpose (PROTOCOL section 2), and a suite that asks one of them has
not asked the others.

**And a claim in a code comment had been false for three commits.**
`DungeonModule._things_said()` resolved a thing's `"in"` under a comment
reading *"the readback resolves a name the same way the validator does"*. It
was true when it was written. 040 taught the validator to refuse a fraction
and left this line truncating, so the comment became false and stayed false.
Trap 14 at a claim in the code, which is where 043 found one too. The same
line dropped the room altogether for an out-of-range number - *"a key"* for
`"in": 99` - which is the half-silence its own comment said it existed to
prevent.

**Found in the same reading, and not about positions.**

- `NpcGoals.door_readback()` put a room NUMBER through `_place()`, the
  definite article's reader. `is_label()` says - rightly, and says so in its
  own comment - that a bare number is not a label, because there is no name in
  front of it to label. So `[1, 2]` read back as *"between the 1 and the 2"*:
  the number said faithfully and then dressed as a room's name, at the one
  reference door whose sides are not resolved before the sentence is written.
- `TrackBuilder.readback()` left a corner below 1 out of the sentence
  entirely, so `"corner": 0.5` read back **identically** to a request naming
  no corner at all. Two different requests, one sentence, which is trap 31's
  fault and the one thing a readback must never do.
- `WorldRegistry.around_of()` and `around_problem()` disagreed about 1.5 -
  `around_of()` read it as step 1 - and `around_of()` exists **because** two
  readings of that one field drifted apart once already (036). Not reachable
  by a player: the schema pass runs `around_problem()` and returns before
  anything is prepared. Closed anyway, and recorded as a divergence rather
  than a fault.

**Do:**

- **A rule reaches every LAYER it holds at, not only every door.** Trap 35
  asked where a project had already been right once and counted call sites.
  This is the same question with the unit raised: interpretation, validation,
  construction and behaviour are four places a fact can be said, and a fix
  applied in one of them is a quarter of a fix. Enumerate the layers the way
  040 enumerated the doors.
- **A one reading whose RETURN TYPE serves one caller is not one reading.**
  `ordinal_index()` answers "which position is this" and a readback cannot ask
  that question. Where two layers need the same fact in different shapes, each
  gets its own reader of it - `ordinal_index()` and
  `Readback.position_said()` - and neither writes the fact out by hand.
- **A readback says a reference back exactly as it was sent, and resolves it
  only when the value is one the validator would accept.** Said as sent is
  what is owed for a value that cannot be used; the resolved name is the more
  useful sentence for one that can, and both must survive.
- **A value a readback cannot use is said, never dropped.** An out-of-range
  room that disappears from the sentence is the dropped clause the readback
  exists to make visible.
- **Ask of a new suite what its own sweep is blind to, in the same breath as
  writing it.** This suite's sweep matches *"<noun> <truncated>"*, so it
  cannot see the SHUT and OPEN door, whose pre-044 fault wore a name instead
  of a noun. 81 truncations found and not one of them at those two doors. They
  are caught by a different assertion, which is why there are both.
- **A probe whose fixture can collide with its assertion measures the
  fixture.** The first draft put room 1 on the other side of the door and then
  asserted *"room 1"* absent, failing five times against the code it had just
  been written to pass. Third commit running that a new suite walked into the
  fault it is about.

Found and fixed in 044. `tests/said_position_test.gd` fails **63 times**
against the pre-044 code.

---

## 39. The record that said nothing about what was proposed

**Signature:** a player asks for a farm. It is refused - *"zone 1 (barn):
width 500 m is outside 5-60 m"* - and the ledger entry for the refusal carries
`world`, `intent` and `command` and nothing else. No zones. The design that
was refused is not in any field of the record of its refusal. Every suite is
green, including the one written specifically to ask whether every command the
whitelist admits leaves a record.

**Cause.** Trap 25's rule is right and it was applied at every door but two.
**Counted in the unit the whitelist uses** (trap 31, because a count stated in
the wrong unit is how this file's own lists have been short twice): eleven
commands, of which `CLEAR_WORLD` takes no fields and so has nothing to
propose. **Of the remaining ten, EIGHT recorded their proposal and two did
not** - and a ninth door, the sectionless `CREATE_TRACK` that routes to
Prototype 001's ring, recorded `proposed_ring` without being a separate entry
on the list.
The three `proposed_` fields a dungeon record carries were written out BY HAND
in `DungeonModule.record_fields()`, the fourth in `RacingModule`'s copy of the
same lines, and in neither case in `WorldModule` - **the base both of them
extend**. So the third world inherited a `record_fields()` that records the
command and the intent and nothing the request arrived with. Measured headless,
one request per whitelisted command, reading the ledger back off disk:

```
CREATE_DUNGEON           proposed_rooms, proposed_doors, proposed_things, attempt
CREATE_TRACK             proposed_sections, proposed_metrics, attempt
ORDER                    proposed_goal
SHUT / OPEN              proposed_door
EQUIP                    proposed_spec
MODIFY_TRACK             proposed_change
SPAWN_OPPONENTS          proposed_grid
CREATE_TRACK (ringless)  proposed_ring
CREATE_FARM              (nothing)
PLAN                     (nothing)
```

`PLAN` is the second and it is the sharper one, because it has a field that
looks like the missing one: it writes `record["steps"]` on the way OUT, and
that is the steps it **did**. A plan refused at step 2 of 3 left an entry
naming the problem and never the plan. A construction-layer field standing
where an interpretation-layer one was owed is the four layers merged, which is
the one thing they are kept apart for (PROTOCOL section 2).

**And the data was never lost, which is why this is a claim about SHAPE.**
`raw_command` holds the whole JSON answer for every command, so a farm's zones
have always been in the ledger as a string. What a reader going BY FIELD met
was a farm that proposed nothing, next to eight commands that proposed
something - the same argument 036 and 037 both made about `intent` carrying
three shapes, and the one the owner accepted then. Nothing in the repository
reads a `proposed_` field except `proposed_metrics`, so the cost today falls
on a person reading the file. Said that way rather than dressed up as data
loss: a trap entry is a claim too.

**Why nothing saw it, which is the part worth keeping.**
`tests/ledger_said_test.gd` asks the right question of the right list - does
every command in `CommandParser.allowed_commands()` leave a record whose id
the ledger resolves? - and **its own header says what it does not ask**:
*"NOT ASSERTED, deliberately: no wording anywhere... This asserts that the
record EXISTS and that its id ties the ledger together."* It is correct, its
list is the whole list, and the record's CONTENTS were owed to nobody: `grep`
finds `proposed_` in exactly one file under `tests/` before 045, and there it
is a fixture in `session_test`. **Trap 6 for the fifth commit running, and
this one is not one of the four axes 041-044 produced**: 041's blind spot was
the probe's VALUES, 042's the sweep's DIRECTION, 043's the input's SHAPE,
044's the LAYER, and this one is the **QUESTION** - existence asked where
content was owed. A suite that asks whether a thing exists has not asked what
is in it, and the gap is invisible from inside because the suite is right.

**Do:**

- **A record carries what was PROPOSED, in a field, for every command the
  whitelist admits.** `raw_command` is the answer as it arrived and is not a
  substitute: a ledger read by field has to answer the same question for every
  command, or the field is not a field.
- **A fact shared by every member of a class belongs in the base they extend,
  not written out in each one that happens to need it today.** Two
  hand-written copies and an empty base is the shape that produced this, and
  the cost was paid by the one member that did not write its own. The reading
  is `WorldModule.proposal_record()` now, off `lists()` - **the module's own
  declaration of what a request may carry** - so a world added later records
  its proposal without its author writing a line. That half is LATENT: there
  is no fourth world yet, and the fix is for the world that does not exist
  (trap 11, where the class includes the member not yet written).
- **A record of a request is the request as sent, never as resolved.** A 500 m
  zone, a fractional room number, a `zones` that is a string - each is in the
  record exactly as it arrived, because a record that cleaned up the request
  would be evidence of a request nobody made (trap 8, one layer along).
- **An absent list is recorded as an empty list, not as a missing key.** It is
  the shape the two hand-written readers wrote and it is what lets a reader
  meet one shape in a field across every record in the file.
- **Ask of a suite what QUESTION it asked, not only what inputs it used.**
  Existence, shape, value and wording are four questions about one field, and
  a suite that answers one of them says nothing about the other three. This
  suite's own header names the question it asks for the same reason.
- **A code comment that counts its readers is a claim and gets checked like
  one.** `Readback.intent_of()` read *"what WorldModule.record_fields() and
  RacingModule.record_fields() each did by hand... Both readers are now this
  one."* There were three: `DungeonModule.record_fields()` read the field by
  hand with its own `typeof()` test. Behaviourally identical, which is how it
  survived, and false from the commit that wrote it - trap 14 at a code
  comment, where 043 and 044 each found one. The hand-written reader is gone
  and the comment is now true.

Found and fixed in 045. `tests/record_proposal_test.gd` fails **8 times**
against the pre-045 code.

---

## 40. The sentence after a build counted the request, and no suite had ever built anything

**Signature:** a world is built and the player is told what was made - *"
CREATE_DUNGEON built 3 rooms joined by 2 doors"*, *"CREATE_TRACK built a
closed clockwise circuit: 8 sections"*. Every number in both sentences is
correct. Not one of them was read from the world. 53 suites are green,
including the one written for exactly this rule.

**Cause.** Trap 24's rule - *a line that states a count reads the count from
what was BUILT, not from what was asked* - came out of 032, where two
Prototype 001 builders had lost their bodies and kept their success strings.
`tests/stub_claims_test.gd` has held it ever since **for the three functions
that place nothing**. It was never asked of the lines that describe a world
that IS built, and those are the lines a player actually reads.

Read, then measured, before anything was changed:

```
DungeonModule.summary()   plural(metrics["room_count"], "room")
                          <- measure(layout)["room_count"] <- layout["rooms"].size()
RacingModule.summary()    plural(report["section_count"], "section")
                          <- CircuitBuilder.build(): sections.size()
DungeonModule.build()     report["room_count"]: rooms.size()
FarmModule                no summary of its own; states no count at all
```

**HANDOVER had spot-checked racing and called it clean**, on the grounds that
`CircuitBuilder` "adds a road piece for every section it loops over, so the
count is of pieces placed". That reading is the trap in miniature: a count of
LOOP ITERATIONS is not a count of placed nodes, however reliably the two have
agreed. In the same function, `_add_collision()` returns early on an empty
face list - so the builder already has one way to place less than it looped
over, and the count could not have seen it.

**And the same entry said `FarmModule` "overrides neither" `summary()` nor
`metric_lines()`.** It overrides `metric_lines()`, and has since 003 - trap 14
in this project's own handover, found the way every other instance of it was
found, by grepping for the thing the sentence denied.

**Nothing was wrong on any world measured.** Three rooms, three slabs; two
doors, two corridors; eight sections, eight road pieces and eight collision
bodies; three zones, three zone nodes. This is a latent fault and the fix
claims nothing else: what was missing was not a correct number, it was any
tie at all between the number and the thing it counts.

**Why no suite saw it, which is the part worth keeping.** `grep` found
`.summary(` in **three of the 52 suites, and in none of them was a world ever
BUILT.** All three hand the function a dictionary typed into the suite.
`container_door_test`'s fixture states `loops: 1` for a dungeon of two rooms
and one door, where `measure()` computes `doors - rooms + 1 = 0`: not a fault
in that suite, which asserts a plural rule and takes any numbers, and exactly
the evidence - the construction layer's sentence had never been put beside a
construction, so nothing could have noticed where its numbers came from. This
is 044's axis (**what LAYER do the fixtures enter?**) at the one layer whose
answer was *none of them*, and the sixth commit running to find a correct
check with a blind spot.

**Do:**

- **A count in a sentence about a built world is read off the TREE.** Not off
  the request, not off the solved layout, and not off the builder's own loop.
  `WorldModule.mark_piece()` marks a piece where it is placed and
  `WorldModule.placed_pieces()` counts the marked nodes under a node - one
  reading on the base, for the reason traps 10, 23, 37 and 39 each produced:
  a fact written out per world drifts per world. A world added later that
  places its pieces without marking them reports **0** and fails
  `tests/built_count_test.gd`, which is the right direction: a world whose
  sentence nobody has tied to its geometry should be loud, not quietly
  correct.
- **A count read off a tree does not count what is leaving it.**
  `GameController._clear_world_node()` calls `queue_free()` on the old
  world's children and `module.build(world_node, layout)` adds the new
  world's on the next line, so for part of a frame both worlds are in the
  tree. **Measured, not reasoned about:** build a two-room dungeon into a
  node, `queue_free()` its children, build again, and **four** marked nodes
  stand there. A count that ignored `is_queued_for_deletion()` would have told
  the player a two-room dungeon had four rooms - a false line introduced BY
  the fix for false lines. `placed_pieces()` skips them and
  `built_count_test` measures the four.
- **The measurement layer and the construction layer are two facts and both
  are kept.** `measure(layout)` still answers *how many rooms were worked
  out*, which is what the metrics panel states; the build report answers *how
  many rooms stand there*, which is what the summary states. They agree on
  every world today and `built_count_test` fails if they ever part without a
  sentence moving with them. Collapsing them into one number would be the
  four layers merged, which is the one thing they are kept apart for.
- **A suite that calls a sentence has not called the thing the sentence is
  about.** The question to ask a fixture is not only which inputs it uses
  (041), which direction it can match (042), which branch it takes (043),
  which layer it enters (044) or which question it asks (045), but **whether
  the thing under test was ever RUN**. Three suites called `summary()` with a
  hand-typed dictionary and a fourth was needed to build a world.

Found and fixed in 046. `tests/built_count_test.gd` fails **4 times** against
the pre-046 sentences, and does not parse at all against the pre-046 code,
because the base functions it reads do not exist there - recorded that way
rather than stubbed, so the number means the sentence and not the scaffolding.

---

## 41. Five lines in one panel, and four of them walked a door the body could not

**Signature:** the dungeon's measurement panel, nine lines and the longest in
Genesis. Line 8 says *"WALKABLE 4 of 4 rooms reachable by a body 1.6 m
across"*. Line 9, directly under it, says *"WAYS ROUND 1 loop"*. The door
that closes the ring is shut. Line 8 knows. Line 9 does not. 53 suites are
green, and the suite written for the panel feeds it a dictionary typed into
the suite.

**Cause.** `walkable()` decides which doorways a body can use, for the two
reasons a doorway cannot be used: somebody has shut it (018) or no body fits
through it (005). `route()` reads that decision, and so does the body. Four
readings in `measure()` - how deep the deepest room is, which room that is,
how many dead ends there are, how many ways round there are - walked
`layout["doors"]`, the dungeon's full list, because `_reachable()` had been
written for `pre_check()`, where the request is all there is and nothing can
be shut yet. The panel then put both answers side by side without either
knowing the other was there.

Measured headless on a ring of four rooms, before anything was changed, with
the ring-closing door shut:

```
DEEPEST     crypt   2 doors from the entrance     the cell is 3 doors away
DEAD ENDS   0                                     rooms 1 and 4 are dead ends
WALKABLE    4 of 4 rooms reachable                correct, honours the door
WAYS ROUND  1 loop                                there is no way round
summary()   "4 rooms joined by 4 doors, 1 way back round"
route()     1 -> 4: 38 points before, 191 after
```

The body had been told. The sentence had not.

**The second fault was in the list itself, and it is a crash.**
`walkable()["blocked_doors"]` appended a `Vector2i` for a shut door and a
`String` for a doorway no body fits - one list, two types - and `route()` read
every entry as a `Vector2i`. A blocked doorway therefore threw inside
`route()`, which returned `[]`, and the controller reads `[]` as *"There is no
way through to the vault."* A crashed function and a plausible sentence, which
is the pair this project exists to catch. Demonstrated on a hand-built layout
in `tests/panel_built_test.gd`: before 047 a dungeon with one blocked doorway
could not be routed through the doorway that was **clear**.

**Both halves are LATENT and 047 says so.** `measure()` is called in one
place, `GameController._prepare()`, before anything is built; `set_shut()`
only ever runs on a layout that is already standing. So the panel a player
reads was drawn when nothing was shut. And a doorway no body fits does not
occur from a legal request: 4000 random legal ring dungeons were solved this
session, 2597 built and post-checked, and **none** had one - which is
`sweep_test`'s finding arrived at from the other direction. What was wrong was
not a number anyone had seen. It was that four lines about walking were
reading a graph nothing walks.

**Why no suite saw it.** 046 found that the dungeon's panel had never been
produced from a built dungeon - `metric_lines(` appeared in two of 53 suites
and the dungeon's nine lines were fed a dictionary typed into
`container_door_test`, whose `loops: 1` cannot occur. That was handed over as
a starting point. Producing the panel from a measured, built dungeon is what
found this: on a dungeon as built every one of the nine lines agrees with the
geometry exactly, and the fault is one question along - **which doors the
lines walk**, not which numbers they print.

**The fix is the class and not the four lines (trap 11).** One list of the
doorways a body cannot use, as door pairs, with the sentences beside it in
`blocked_why`; one list of the doors a body **can** use, in `usable_doors`,
which `route()` and `measure()` both read so neither builds its own graph; and
the loop count in one function, `loop_count(doors, rooms, components)`, used
by `pre_check()` and `measure()` alike. The formula changed with it: the old
`doors.size() - rooms.size() + 1` was right only because the one graph either
caller had ever been asked about was one `pre_check()` had already proved
connected. A door a body cannot use can split a graph in two, and then `+ 1`
states a way round that is not there.

**The rule.** *A reading that describes getting about reads the graph the
body obeys.* And: *one list, one type* - a list whose entries mean the same
thing in two different shapes will be read correctly by whichever reader was
written beside the shape its author had in mind.

**And the panel is where to look for this class**, because a panel is many
readings printed together: two lines of a panel that answer the same question
from different sources look, on the screen, exactly like two facts.

---

## 42. A flag on the holder, and a net that only caught one word order

**Written from commit `5d36bfb` ("048: fourteen rooms, four rooms, and a net
with a hole in it") and its diff, both read; neither fault was reproduced by
the session that wrote this entry.** It is here because TRAPS is the
project's ledger of what the work has cost and that commit left the documents
untouched, so its own account — which is fuller than this one — lives in
`git log 5d36bfb`. Both faults came off the owner's editor on real hardware
with a live key, 2026-10-16, minutes apart, in code every suite had passed.

**Signature one:** *"CREATE_DUNGEON built 14 rooms joined by 4 doors"*, for a
request of four. The readback said four, and the doors, the corridor length
and the depth in that same sentence were all right. **Only the count of what
was BUILT was wrong.**

**Cause.** `WorldModule.placed_pieces()` walks the tree counting marked nodes
and skips any that is queued for deletion. `queue_free()` marks **only the
node it is called on** — `is_queued_for_deletion()` is false for every child
of that node. `_clear_world_node()` frees `world_node`'s direct children, one
holder per world, so the pieces are always one level BELOW the mark, and the
count walked past the holder's flag and counted everything under it. The ten
extra were the starter circuit `Main` puts in the world so there is something
to drive before anything has been asked for, on its way out in the same
frame: four rooms plus ten outgoing road pieces. `placed_pieces()` now returns
0 for a subtree whose root is going, **before** the recursion rather than
during it.

**Why no suite saw it, which is the part worth keeping.** Every test built
into a FRESH holder. The starter circuit exists only in the running game, so
the harness never had an outgoing world to miscount — and 046 moved this
player-facing sentence onto this count on the strength of *"the two agree on
every dungeon measured so far"*. They did agree, in a harness that could not
disagree. `tests/outgoing_world_test.gd` is the first suite that puts a world
there first, clears it the way the controller clears it, and only then builds.

**Signature two:** the model wrote *"Genesis cannot inspect or report the
current state of the world or character, as it only builds the world and
processes commands"* — false, because a delivery is decided by reading the
thing's position — and `RefusalCheck` printed **nothing**.

**Cause.** It was looking for the phrases *"inspect the world"* and *"world
state"*. The model wrote the same claim in a different word order. That is the
**third** time word order has beaten a phrase list on this project, after
*"actually"* (022) and *"instead"* (023), so a fourth phrase was not the fix:
that capability is now matched as a PAIR of ideas — one word for the act
(inspect, report, query, read, know) and one for the thing (state, world,
position, location, where) — anywhere in the same sentence after a negation,
in either order and not necessarily adjacent. Still negation + act + thing +
not-about-a-number, which is what keeps it quiet: the commit records all 15
honest refusals in `log_023_test` still left alone, including three new
neighbours that use the same vocabulary truthfully.

**The rules.** *A subtree whose root is going away is going away entire, so a
flag on the holder says nothing about the children unless somebody reads it
before the recursion.* And: *a claim survives being reworded and a phrase does
not, so a net made of phrases is a net with the paraphrases missing.* And the
one both halves share, which is 046's lesson arriving from the other
direction: **a harness that cannot reproduce the condition is not evidence
that the condition is handled** — "they agree on everything measured so far"
is a statement about what was measurable.

---

## 43. The farm a plan grew, and the gate that stayed where it was

**Signature:** *"a dungeon with a hall and a vault, inside a farm with a
barn"* — a request this project records as working. The farm comes out 260 m
across instead of 64, because a world asked to hold another puts more ground
round what it holds. Everything in the panel is right. Every zone is where
the player asked for it. **And the farm has no way in.**

**Cause.** `FarmModule.solve()` lays the zones out, puts a fence round the
lot and cuts a gate into the south side, recording the gate as a point in the
layout. `_fence()` exists because that fence can MOVE: a plan calls
`grow_to()`, and `grown()` pushes the boundary out about the middle, so
`build()` must ask where the fence actually goes rather than where
`solve()` put it. The gate was not asked about. `build()` passed `layout["gate"]`
straight to `_add_fence()`, which skips the posts within half a gate's width
of it — and on a farm that had grown, the gate's y was the OLD fence line,
several tens of metres inside the new one, so no post was within half a
gate's width of anything and none was skipped.

Measured headless, a farm of a barn and a wheat field, before anything was
changed:

```
as solved             fence -32..32 by -45..45    gate (0, 45)
                      10 posts on the gate's line, a 16.0 m gap in them
grown to 260 x 260    fence -130..130 both ways   gate (0, 45)
                      0 posts on that line, and no gap anywhere in its 132
```

**This one is not latent.** `grow_to()` is called by
`GameController._prepare()` for any plan that puts one world inside another,
and the farm is the world that grows — racing opts out through `can_grow()`,
so for *"a circuit in a farm"* or *"a dungeon in a farm"* the farm is always
the container. A player who typed either got a farm fenced in on four sides.
What makes it a quiet fault rather than a loud one is that the fence carries
no collision: nothing is physically stopped, so the gate is a thing you can
see and not a thing you pass through. The way in was missing from the
picture, not from the physics.

**And a comment was still claiming it.** The line over `solve()` said *"the
fence is put round the lot and a gate cut into the south side"*, which had
been true of every farm until 003 made the farm a container and false for a
plan's farm ever since — trap 14 again, in a code comment this time, and
found the way trap 14 says to find them: by measuring the thing the sentence
asserts.

**Why no suite saw it.** `capability_test` calls `grow_to()` and checks the
farm reports the bigger extent; nothing built the grown farm and looked at it.
This is trap 40's axis — *does any fixture ever call the thing the sentence is
about?* — at the one thing in the farm's layout that no panel line states.
The audit that found it was the audit of the panel: every line of the farm's
panel and the circuit's panel was put beside a number walked out of the built
tree, all of them agreed, and the question *"what fact does this line read"*
had one answer left over. **The gate is the number nothing in the panel
states, which is exactly why nothing had ever checked it.**

**The fix is the class and not the gate (trap 11).** `_gate()` beside
`_fence()`, and the rule it enforces: *anything a world positions against its
own boundary is read from the boundary that is BUILT.* Audited across both
worlds that can grow — the farm's zones are deliberately left where they are
and never touch the fence, and the dungeon positions its rooms and corridors
against each other and only its `Ground` pad against the grown bounds,
through `grown()` already — so the gate was the one place the rule was
broken, and that audit is the part worth keeping: the class has one member
today and it is written down so a third world does not add a second.

On a farm nobody has grown, `_gate()` returns `layout["gate"]` itself, so no
farm anybody has ever built changes by a centimetre. `tests/panel_geometry_test.gd`
holds it by walking the posts in the tree and measuring the distance between
them — it never asks the module where it put the gate — and it holds the
ungrown farm to the same rule, so a fix to the grown case cannot be bought
with the one that was already right.

**Found in the same reading, and it is a one-reading fault rather than a
wrong number.** `TrackMetrics` carried its own copy of `STRAIGHT_FAMILY` and
`YAW_TYPES`, and the closure solver, the feasibility gate and two suites all
read `TrackGeometry`'s — the feasibility gate's own comment says *"the type
lists come from TrackGeometry, so the gate, the solver and the metrics
agree"*, and the metrics were the one that did not. The copies were
byte-identical, so **nothing was ever mismeasured and 049 claims nothing
else**; what was wrong is that the four panel readings that depend on which
sections are straight and which turn — the straight ratio, the longest and
shortest straight, the direction change — were decided by a list nothing else
in Genesis obeyed, in the file whose own header warns that a new section type
has to be added in four places. One reading (trap 36), and the suite asserts
the CONSEQUENCE rather than the list: enumerated from
`SectionValidator.SECTION_TYPES`, a section of every type is measured on its
own and the panel's classification of it is checked against the geometry's, so
a type added to one list and not the other fails.

**And the fourth copy in the same file was the one with teeth**, which is why
trap 11 says take the class and not the instances you found. `measure()`'s
`counts` dictionary was a literal of all ten types, and `counts.has(t)`
decides whether a section is counted at all — while
`RacingModule._counted()`, which renders the parenthetical after `SECTIONS`,
already enumerates from `SectionValidator.SECTION_TYPES` and reads
`counts.get(type, 0)`. A type added to the validator and not to that literal
would have made the panel say *"0 loop_segments"* on a circuit with one, **on
the same line as a SECTIONS count that included it** — one panel line
disagreeing with itself. It enumerates from `SECTION_TYPES` now, and the
numbers are byte-identical because the literal held all ten.

**The rule.** *A world that can be made bigger re-reads its own boundary
before it draws anything against it.* And, one level up: *the thing nothing
states is the thing nothing has checked* — the farm's panel has eight lines
and every one of them was right; the fault was in the one number in the
layout that no line prints.

---

## 44. The one limitation the prompt left out, and the net that caught the true answer

**Signature, from the owner's editor on 2026-10-16, with a live key, and
recorded in `5d36bfb`'s message:** two questions in one session —
*"show me the dungeon metrics"* and *"where is the red key now"* — came back
as a **SHUT** and an **UNSUPPORTED**. In the same session the checker from
023 met its first real false refusal: *"Genesis cannot inspect or report the
current state of the world or character"*. 048 fixed the net; this entry is
about why the model was writing that sentence at all.

**Cause, and it is in the prompt rather than in a function.** The prompt
gives the model a list of what Genesis can do, a list of what it cannot, and
one binding rule for a refusal:

> REASON must name the part that is missing, **from the list above**, and
> must not deny anything from the list before it.

**There was no entry on the CANNOT list for a question.** Measured: the
assembled prompt contained the word *"question"* 0 times and *"query"* 0
times, in 15846 characters. Directly above, the CAN list says *"It MEASURES
everything it builds"* and *"Never say Genesis cannot do one of them"*. So a
player's question left the model three moves: refuse and name a part that is
not on the list (which is a reason it has to invent, and the invented one
denied a capability), refuse and name a part that is on the list (false for
the same reason), or send the nearest command on the whitelist. **Both
things the owner saw are on that list of three.** A SHUT is what
*"show me the dungeon metrics"* looks like after the model has been told that
every sentence must come back as one of eleven commands and none of them
answers anything.

**And Genesis has both answers already.** `measure(layout)` returns every
number the first question asks for, and `room_of(layout, position)` is how
the second is answered whenever a delivery is judged — the controller takes
the thing node's position, puts it through `room_of()`, and compares. **The
door is what is missing, not the fact**, which is exactly what makes a
refusal that denies the capability false and a refusal that denies the
command true.

**The second fault, and it is 42's lesson from the other side.** 048 widened
that capability's net from a phrase list to a PAIR of ideas — an act word
and a thing word, after a negation, in either order — because *a claim
survives being reworded and a phrase does not*. Measured here before
anything was changed: the widened net **flags refusals that are TRUE**.

```
There is no way to ask Genesis to report the current position of a thing.
                                     FLAGGED  report ... position
There is no command for asking Genesis what it has built; the
measurements are shown in the panel when a world is built.
                                     FLAGGED  measure
Genesis cannot be asked for the measurements of the dungeon that is
standing.                            FLAGGED  measure
```

The first of those is flagged by the entry **whose own rebuttal has said
since 048 that such a refusal is right** — *"What it has no command for is
being ASKED, in so many words, where something is; a refusal about THAT is
right"*. The exception was written in prose and implemented nowhere.

**And the suite was guarding it the same way the prompt was.** `log_023_test`
has asserted since 048 that *"there is no command for asking where a thing
is; the panel shows it"* is left alone — and it was, but only because that
sentence happens to contain no word from either list. The honest-neighbour
list is a phrase list too, and it protected one wording of a claim rather
than the claim.

**The fix is the rule and not a phrase (TRAPS 11).** A capability word that
stands **after** an asking word is not being denied; what is being denied is
the door to it. Order is what keeps it safe, the same way order keeps the
negation frame safe: *"Genesis cannot report where a thing is, so asking is
pointless"* still flags, because the capability word comes first. And the
exception is marked per capability, because it is a fact about which doors
exist and not a rule about English: the question *is there anything the
player can type that produces this on demand?* was asked of all seven
capabilities, and two have no such door (the panel is drawn when a world is
built; a thing's position is read when an errand is judged) while five do
(`ORDER`, `PLAN`, `/save`, `/load`, `/log`, `/worlds`, `/session end`). An
asking word excuses nothing in those five, which `asked_test` asserts in
both directions — *"you cannot ask for one world inside another"* is false
and stays caught.

**`query` is deliberately not an asking word.** It is in the same entry's ACT
list, where it means the act of reading the world rather than the player
asking for something, and *"Genesis cannot query the world state"* is one of
the false refusals this checker exists to catch.

**The rules.** *A net widened to catch a paraphrase of a lie will catch the
truth that is worded the same way, so an exception has to be written as what
makes the true one true — and an honest-neighbour list is a phrase list, so
it proves one wording and not the claim.* And: **the one limitation a prompt
leaves out is the one its refusals will have to invent.** A model bound to
name a missing part from a list cannot refuse honestly outside that list, so
a limitation that is true and absent costs more than one that is stated.

**What was NOT done, and it is the owner's:** no command was added. Whether
Genesis should have a door to a question at all is "Human decision needed"
16.


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
> And a rule reaches every LAYER it holds at and not only every door, because
> a one reading whose return type serves the validator is no reading at all to
> the sentence the player is asked to check.
> And a record of a request is part of the request, so a command whose record
> says nothing about what was proposed has been measured in a field nobody can
> read - and a fact every member of a class needs, written out in the members
> instead of the base, is already missing from the one that did not write it.
> And a suite that asked whether a thing EXISTS has not asked what is in it.
> And a sentence about what was built counts the thing it is standing in front
> of, not the list that asked for it - so a count off a loop is a count off
> the request wearing a result's clothes, and a suite that calls the sentence
> without building the world has measured the wording and nothing else.
> And a reading that describes getting about reads the graph the body obeys,
> so a panel whose lines answer one question from two sources is printing two
> facts that cannot both be true.
> And one list holds one type, because a list whose entries mean the same
> thing in two shapes is read correctly only by the reader written beside the
> shape its author had in mind.
> And a subtree whose root is going away is going away entire, so a flag read
> during the walk instead of before it counts a world on its way out.
> And a claim survives being reworded where a phrase does not, so a net made
> of phrases is missing exactly the paraphrases nobody thought of.
> And a harness that cannot reproduce the condition is not evidence that the
> condition is handled, so "they agree on everything measured so far" is a
> statement about what was measurable.
> And a world that can be made bigger re-reads its own boundary before it
> draws anything against it, because a point fixed to where the edge USED to
> be is not on the edge any more — and the number no line of the panel states
> is the number nothing has ever checked.

---

## 45. The caveat that asked the wrong layer, and the default that was right for the one case it was written for

**Signature:** a plan is refused, and the measurements panel shows a world
that does not exist — ten lines of it, under **`RESULT  Valid dungeon`** in
green, with no caveat and no reason. And, with no plan at all: ask for a car,
and the panel says **`RESULT  Valid circuit`**.

**Cause, and there are three members of one class.** A Genesis record keeps
four evidence layers apart — interpretation, validation, construction,
behaviour — and the measurements panel is the one place they are printed
together. Every line of it is a claim, and each claim has exactly one field
that answers it. `main.gd` read the wrong one three times:

- **The caveat and the REASON asked `result`.** *"(measurements below
  describe the proposal, not a built track)"* is a claim about the
  CONSTRUCTION layer, and `construction` is the field that says BUILT or
  FAILED. A plan works every world out before it builds any of them, so a
  plan refused after a step is worked out emits that step's record with
  `result: VALID` and `construction: FAILED`. Both the caveat and the reason
  were behind `if not valid`, so both were skipped for exactly the record
  they existed for. Measured headless: ten measurement lines of an unbuilt
  dungeon, in green, with neither.
- **The world's name came from a default.** `record.get("world", "circuit")`
  — and `world` is written by `WorldModule.record_fields()`, so it is absent
  from every record that is not a world. `EQUIP`, `ORDER` and `CLEAR_WORLD`
  all reach the panel with `result: VALID`, and all three read *"Valid
  circuit"*. The last is the sharpest: the command whose whole job is to take
  a world away, reported in green as a valid circuit.
- **A verdict was printed for a record that has none.** `record_load_check()`
  writes the only emitted record with no `result` key — it carries an
  `outcome`, because it judges a world that came back off disk rather than a
  proposal. `if valid … else FAILED` has no case for an absent verdict, so a
  load check whose outcome is SAME read **`RESULT  FAILED: `** in red, with an
  empty category where the reason should be.

**Why nothing found it.** Two reasons, and the second is the one worth
carrying. The first is that all four of the panel's decisions were inline in
`main.gd._on_track_measured`, which needs a `RichTextLabel` and a running UI:
the MODULES' lines were reachable and had been measured against built
geometry since 047 and 049, and the decision about WHICH WORLD THE PANEL IS
DESCRIBING was reachable from nothing.

The second is that **the default was never dormant.**
`RacingModule.record_fields()` deliberately omits `world` — racing records
have never carried it, `record_proposal_test` asserts they still don't, and
the owner's ledger stays comparable across releases because it is left alone.
So `"circuit"` fired on EVERY CIRCUIT, where it was right. A default that is
correct for the one case it was written for cannot be found by reading that
case, and the reader who checks it against a circuit comes away satisfied.

**Do:**

- A line that states a verdict names the LAYER it speaks for, and reads that
  layer's field. "Was this built?" is `construction`, whatever `result` says
  about the proposal. The two disagree on a real, reachable record.
- A default in a reader is a claim that the field is optional. Ask which
  records lack it and what the default says about each of them —
  `record.get("world", "circuit")` was a claim that any record without a
  world is a circuit, and seven commands falsified it.
- Test a default against the case it is WRONG for, not the case it was
  written for. Sweeping `CommandParser.allowed_commands()` found all three
  members in one pass; reading the circuit found none of them.
- Absent is not false. A record with no `construction` is not built and a
  record with no `result` has no verdict to print: missing evidence must not
  become success, and that holds for a panel line as much as for a delivery.
- A decision taken inside a UI callback is a decision nothing can measure. If
  a claim is worth caveating, the caveat belongs in a function a suite can
  call, and each line carries the ROLE it plays so the suite can ask whether
  the caveat is there without asserting a sentence.

Found and fixed in 051, in one function: `WorldRegistry.panel_lines()`.
`tests/panel_refused_test.gd` fails **11 times** against the old decisions.

> And a net widened to catch a paraphrase of a lie will catch the truth that
> is worded the same way, so the thing to say is what makes the true one
> true — and the one limitation a prompt leaves out is the one its refusals
> will have to invent.
> And a line that states a verdict reads the layer it speaks for, so a caveat
> about what was BUILT driven from whether the PROPOSAL was valid is skipped
> for exactly the record it exists for — and a default in a reader is a claim
> that the field is optional, right for the one case it was written for and
> unexamined for every other.

## 46. The clearance check that compared against a number with no name on it

**Signature:** none. Nothing is wrong with any farm, and that is the point of
this entry. `FarmModule._check_reachable()` is the farm's version of *"the
circuit must close"* — the module's own header says a farm you cannot drive a
tractor around is refused — and it decided an edge was clear unless a
neighbour stood **within half a metre** of it. `LANE_WIDTH` is **6 m**. The
test admitted a gap **one twelfth** of the thing its own comment calls a
lane, and the number it should have compared against was sitting in the
layout it was handed, read by nothing in the repository.

**How it was found.** Not by reading the check. By asking 049's question of
every key of every world's layout — *who reads this?* — which 051 began and
HANDOVER left as the next task. `lane_width` was the one key `grep` found in
exactly one line: the line that writes it.

**Cause.** A check acquires its threshold when it is written, and 0.5 was
what "flush" meant to whoever wrote the four comparisons. The dimension the
check is about arrived later, in the same dictionary, and nothing connected
them. The project had already been right about this twice:
`SeparationCheck.MIN_SEPARATION` **is** `ROAD_WIDTH + SAFETY_MARGIN`, and the
dungeon walks its corridors with a body `BODY` metres across and reports that
width in `walkable()`. Three clearance checks, one per world; two read the
dimension they are about and one read a literal.

**What it cost: nothing yet, measured rather than assumed.** Over 468 legal
farms swept headless, `solve()` never leaves two zones closer than
**6.0000 m**, so the failure branch is not reachable from any request a
player can send and both thresholds agree on every farm that exists — the
same shape `sweep_test` reports out loud about `FAILED_UNWALKABLE`. What was
wrong is that the guard did not guard what it names: a packing change putting
zones 0.6 m apart would pass it. `limits_test` has asserted since it was
written that the SOLVER leaves a lane; that the CHECK requires one was
asserted nowhere, so the two halves could drift apart without a suite moving.

**And the suite written to catch it could not fail, twice.** The reader sweep
perturbs a layout key and asks whether anything the module does with the
layout changes. Its signature included the built tree, and two things in it
differ between two builds of the SAME layout: a node its builder did not name
is given a generated one with a global counter in it (`@MeshInstance3D@57` —
the farm's fence posts), and a build report that carries a node prints that
node's instance id. So every key "changed something" and the sweep passed
against the pre-052 code it was written to fail against. Found by running it
against that code and reading the result, not by reading the suite.

**Do:**

- A clearance check compares against the dimension it is about, named. If the
  number it needs is in the layout, read it from the layout — a threshold and
  the thing it is a threshold for are one number, in one place.
- Ask who reads a key before deciding what to do with it, and ask it of every
  key, not the suspicious one. A layout in Genesis is an INPUT to the builder
  and not a record of anything: nothing serialises it, so a key with no reader
  is dead weight rather than documentation.
- A guard whose failure branch no legal input can reach is still worth
  keeping, and is worth knowing about. Say which it is — `sweep_test`'s
  VERDICT line is the pattern — because "it has never fired" and "it cannot
  fire" are different facts and only one of them is reassuring.
- **Run a new suite against the code it is supposed to catch.** A suite that
  passes everywhere is a suite that has not been measured. Any identity in a
  signature — a generated node name, an instance id, a timestamp, a hash of
  an object — makes a comparison always-unequal and every assertion built on
  it vacuous.
- A code comment that names two checks when one exists is a false claim about
  Genesis (TRAPS 14, in a comment). The farm's header claimed every lane
  connects to the gate; nothing verifies that. It is true by construction —
  the zones sit 12 m inside the fence, so the ring between them reaches the
  gate — and the header now says so at the width of the check that exists.

Found and fixed in 052, in one function: `FarmModule._check_reachable()`.
`tests/layout_key_test.gd` fails **13 times** against the pre-052 module.

> And a clearance check compares against the dimension it is about, so a
> threshold with no name on it is a guard that does not guard the thing it is
> named for — and a key nothing reads cannot be wrong, which is exactly why
> nobody would notice if it stopped being true.

---

## 47. A sweep that never got past the door before the one it was measuring

**Signature:** a reachability sweep reports that no legal input can reach a
check, and one four-room design reaches it in a single line.

**Cause:** 053 set out to answer, for every refusal category Genesis has,
*can any request a player can send produce it?* The first sweep generated a
"severed" dungeon — a chain with the last room left out — and reported
`FAILED_UNREACHABLE` as out of reach. It is not out of reach at all.
`DungeonModule.validate()` refuses a design with fewer than `rooms - 1`
doors, so every severed design was thrown out ONE STEP EARLIER and
`pre_check()` never saw one. A design that is disconnected *and* has enough
doors — a triangle of three rooms and a fourth with none — is schema-legal
and `pre_check()` refuses it immediately. The sweep had measured the
validator and reported the answer as the pre-check's.

**And the same shape a second time, in a negative fixture.** The first
attempt at *does `FAILED_CORRIDOR` fire when a corridor does cross a room?*
handed `post_check()` three rooms in a row with a door from the first to the
third. It came back refused — and refused as `FAILED_UNWALKABLE`, because
the middle room had no door at all. A fixture that fires the wrong guard
looks exactly like a fixture that works, to any test that only asks whether
something was refused.

**Do:**

- A sweep that is about step N must COUNT how many inputs reached step N, and
  fail if that count is thin. `refusal_reach_test` asserts that 500-odd
  designs got past `validate()` and that a decent share of them were refused
  by `pre_check()`, so a sweep that is really measuring the door before it
  cannot report "unreachable" quietly.
- A negative fixture asserts WHICH category and WHICH step, never just that
  something was refused.
- When a sweep says a branch is unreachable, say WHY in arithmetic over the
  code's own constants, and assert the arithmetic. "The sweep did not find
  one" and "the numbers make it impossible" are different claims, and only
  the second one survives a sweep that missed a shape.
- Ask the second question too: **handed an input that DOES violate it, does
  the check fire?** Of Genesis's twelve world-module refusal categories,
  seven cannot be reached by any legal request, and all seven fire. None is
  dead code. But six of the seven can be shown to be WIRED IN — their
  violating input can be handed to the function the pipeline calls — and one
  cannot: delete the call to `FarmModule._check_reachable()` and all 60
  suites still pass. A guard nothing can reach is also a guard nothing can
  prove is still connected, and where a check LIVES decides which of those
  two it is.

Found in 053, by running the sweep against the code and reading the output.
`tests/refusal_reach_test.gd` fails against thirteen deliberate breakages,
one at a time, and passes against the fourteenth — which is the one it
reports.

> A check cannot be measured through a door that cannot be made to carry the
> thing it checks.

---

## 48. A reachability answer read off the code instead of the running scene

**Signature:** a branch is called unreachable, or a refusal is called the one
a command gives, and a single request in the state a player is actually in
says otherwise. The reading of the code was right about the code.

**Cause:** 054 asked 053's two questions — *can a legal request reach this
refusal, and does it fire when handed a violation?* — of the twenty-eight
branches `GameController`, `main.gd` and `ExperimentRunner` return. The first
pass answered them by reading the functions, and got three wrong, all in the
same direction:

- **`MODIFY_TRACK` and `SPAWN_OPPONENTS` were read as taking their "nothing
  built" branch, and on a fresh session they do not.** `main.gd` stands an
  unrecorded starter circuit in the world at launch so there is something to
  drive before anything has been asked for, and that sets `drivable`. So
  `has_drivable()` is TRUE before any request, both commands answer with
  their composed-track refusal, and their other branches are reachable only
  after the world has been cleared. Nothing in the two functions says this;
  the fact is in a different file, in a call made at startup.
- **`FAILED_SCENE`'s *"the thing is not in any room"* was read as a guard**,
  on the reasoning that a thing is placed in a room and delivered to a room.
  It is reachable. A thing being CARRIED is in a corridor for part of the
  errand — sampled over one errand, the lamp was in room 1, in room 2 and in
  no room at all — and a second order sent at that moment reaches the line.
  It took stepped physics to find, not a closer reading.
- **`SPAWN_OPPONENTS`' count check was read as the refusal a bad count
  gets.** It is unreachable: `has_track()` is always false, so the refusal
  above it returns first. The comment at that line had said so since 036 —
  and the `FAILED_NOTHING_BUILT` line four below it is unreachable for
  exactly the same reason and was never labelled, so a reader counting live
  answers off `NOTHING_BUILT`'s own header got three where two is right.
  That is TRAPS 11 at the scale of two adjacent branches, and TRAPS 14 in a
  comment that states a count. **And the repository already disagreed with
  itself about it**: `stub_claims_test` has asserted since 032 that nothing
  fills `corner_nodes` and says in its header that this is *"the reason
  `SPAWN_OPPONENTS` can never run"*. One file knew; another file's comment
  counted the branch among three live answers, for twenty-two commits.

**Do:**

- A controller branch's reachability is a claim about the SCENE STATE a
  request meets, not about the lines above it. Answer it by sending a
  request, from the state a player is actually in — including the state the
  program puts itself in before any request — and assert the state beside the
  category, because for branches that share a category and a command it is
  the state that selects one.
- Where physics, a timer or an errand in flight can change the state between
  two requests, *unreachable* has to be measured across that, not at rest.
  Sample the state over the whole errand and look for the moment it differs.
- When one member of a pair of adjacent branches is labelled unreachable, ask
  the same of its sibling in the same sitting. The label is cheap; the
  reader's wrong count is not.
- A comment that states how many paths answer to something is a claim about
  the code, and gets checked by reaching each of them (TRAPS 14).

Found in 054, by driving requests through `main.gd` rather than reading
`game_controller.gd`. `tests/controller_reach_test.gd` is 136 assertions and
fails against sixteen deliberate breakages, one at a time — among them a
twelfth whitelisted command with no handler, each of the five guards wired
out of the step that calls it, a branch ADDED to a category that already had
rows, and the starter circuit taken away.

> The code says what a branch does. Only the running program says whether
> anything can get there.

---

## 49. A check tested at its own door and never at the game's

**Signature:** a check has a thorough suite of its own, every assertion
passes, and deleting the line that calls it changes nothing anywhere.

**Cause:** 055 asked HANDOVER's class question — *which checks are called on
input the same function produced, and therefore cannot be proved connected?*
— and measured it the only way it can be measured: take one call site, make
it stop refusing, run every suite, and see whether anything says so.
Fourteen call sites, one at a time.

Ten were held. Four were not, and **only one of the four is the farm's
problem**. `FarmModule._check_reachable()` is 053's: it is called inside
`solve()` on the layout `solve()` has just built, so there is no input that
tells the wired-in guard from the wired-out one, and that is "Human decision
needed" 18. The other three all have a door. Nothing walked it.

- **`LoadCheck.compare()` at `main.gd:618`.** 025 built it because
  *"Loaded 'vault'"* was a claim about a file being opened dressed as a
  claim about a world coming back. Replace the verdict with a constant
  `RESTORED` and all 61 suites pass, `--all` included. `load_check_test` is
  236 lines and calls `LoadCheck.compare()` fourteen times — never once
  through `/load`.
- **`RefusalCheck.quarrel_with()` at `main.gd:298`.** 023's answer to a
  refusal that denies something Genesis does. Hand the caller an empty
  array and all 61 suites pass. `asked_test`, `limits_test` and
  `log_023_test` all call `quarrel_with()` directly.
- **`ToolRegistry.readback()`'s validated branch at `tool_registry.gd:47`.**
  This one is sharper, because a door existed AND the suite walked it — with
  inputs that could not show the difference. `boots_test` reads back
  `{"weight": 130.0}`, which is identical whether it comes from the
  validator or from what was merely heard. Of eight sampled legal specs,
  five differ: *"the ordinary RED car"* against *"the ordinary red car"*.

And one more was held so thinly it is worth its own line: the controller's
**solve step** at `game_controller.gd:1158` is caught by `session_test` and
by nothing else — a suite that takes minutes and runs only under `--all`.

**Do:**

- A unit test proves a check FIRES. Only a request through the door the game
  uses proves it is REACHED. Write both, and do not let the first stand in
  for the second.
- The measurement is cheap and it is the only honest one: delete the call,
  run everything, read the diff. Do it when a check is written, not twenty
  commits later.
- When a check has a door but the inputs sent through it are already in the
  form the check would produce, the door is walked and nothing is tested.
  Choose an input where the two paths visibly differ, and assert that such
  an input exists, or the assertion goes quietly vacuous the day the
  normalisation changes.
- A guard held only by a slow suite is held only on the runs that use
  `--all`.

Found in 055. `tests/check_wiring_test.gd` carries one row per
verdict-returning function in `scripts/`, fails closed on a new one, and
walks the four doors nothing walked.

> A green suite proves the checks fire. It does not prove anything calls
> them.

---

## 50. A measurement taken while another run was writing the same file

**Signature:** a suite fails under a change that cannot possibly affect it,
the same two suites fail under every change, and the failures vanish when
the measurement is repeated.

**Cause:** 055's fourteen wire-outs were first run two and three at a time,
in separate copies of the repository, to save wall-clock. Every copy has the
same `config/name` in `project.godot`, and Godot derives `user://` from it —
so all of them share **one** `user://track_log.jsonl` and **one**
`user://worlds`. Every run was reading another run's ledger.

`ledger_test` and `intent_door_test` duly failed under nearly every change,
and were read as *"the guard is held"*. Four of the fourteen answers were
wrong because of it, all in the flattering direction: `LoadCheck` and
`RefusalCheck` looked connected and are not. The confound was found by
noticing that the two suites catching everything were not in the slow list,
so a `--all` run and a fast run should have agreed about them, and did not.

**Do:**

- Run the suite one at a time. `run_tests.sh` is not safe to run twice at
  once on one machine, and nor is the Windows runner.
- Clear `user://` before every run in a measurement, baseline included. A
  world left over from the previous run is state the next run inherits.
- A result that is the same under every treatment is not a strong signal, it
  is a suspicious one. Ask what the treatments have in common before
  believing it.
- Separating copies of a project does not separate their `user://`. Change
  `config/name` as well, or do not overlap them.

Found in 055, after the first set of answers was thrown away and all
fourteen were re-measured one at a time.

> Two runs of the same project are one ledger.

---

## 51. An override asserted by reflection, which answers for the base class too

**Signature:** an assertion written precisely so that a future case would be
caught passes for a case that should fail it, and has always passed.

**Cause:** 053 declared `WorldModule.solve()`'s `FAILED_LAYOUT` unreachable
because all three world modules override `solve()`, and wrote the assertion
by reflection rather than by listing the three — explicitly so that a fourth
world would be asked the same question without the file being edited:

```gdscript
for entry in (module as Object).get_script().get_script_method_list():
    if str(entry["name"]) == "solve":
        overrides = true
```

`Script.get_script_method_list()` includes the methods a script
**inherits**. Every module reported every `WorldModule` method as its own.
`BootsTool`'s list contains `validate`, `readback`, `defaults` and four more
names twice over — once from the tool, once from the base. The assertion
could not fail, and a fourth world that overrode nothing would have passed
it.

The fact is still true: all three modules really do define `solve()`. What
was not true is that anything was holding it, for twelve releases, and the
comment at `WorldModule.solve()` pointed at the assertion as the guarantee.

**And it was hiding a smaller fact worth having.** `FarmModule` defines
neither `pre_check()` nor `post_check()`: a farm runs the base's, which
refuse nothing. Nothing is wrong today — they are defaults, not stubs — but
the project believed every module had its own, because the only thing it
asked had answered yes.

**Do:**

- To ask whether a script defines a method itself, read the script. The
  reflection list cannot tell an override from a fall-through.
- When an assertion exists to catch a future case, break the present case on
  purpose and watch it fail. Renaming one method found this in a minute.
- An assertion that covers four things with one loop is worth one run with
  each of the four taken away, not one run with all four present.

Found in 055, by running the new suite against thirteen deliberate faults —
the eleventh was renaming `CarTool.validate()`, and the reflection check
stayed green. Corrected in `tests/refusal_reach_test.gd` and
`tests/check_wiring_test.gd` in the same commit (TRAPS 11), and the farm's
two fall-throughs are now written down and asserted.

> Reflection answers for the whole family. It was asked about one member.

---

## 52. A path gated on provenance the harness can never produce

**Signature:** a handler, a branch or a whole feature is wired in, obviously
reachable by reading the code, and wiring it out fails nothing. Every suite
that touches the area calls the pieces directly and passes.

**Cause:** 056 wired out `main.gd:80` —
`controller.revision_requested.connect(_on_revision_requested)` — and all 62
suites passed, `--all` included. The closure revision, the one place Genesis
asks the model to correct itself, was held by nothing.

The reason is one `and` in a guard. The emit at `game_controller.gd:1168`
stands behind `_may_revise()`, and `_may_revise()` requires
`current_source["source"] == "ai"`. That string is written in **one** place in
the project — `AIInterpreter.describe()`, `ai_interpreter.gd:250` — which
`main.gd` reaches only after `interpreter.is_available()` passes. So the path
is gated on the request having come from the model, and **a harness with no
key cannot produce that gate's input at any price**. Raw JSON, which is how
every suite and every measurement in this repository sends a request, is
stamped `{"source": "typed"}` at `main.gd:189`.

This is not the same blind spot as TRAPS 49. There the door existed and
nothing walked it. Here the door is **locked from the production side**, so
no amount of walking the normal door would ever have reached it, and no
reviewer reading the handler would see anything wrong.

**Do:**

- When a call site cannot be reached from any test, ask what **production**
  sets that the harness cannot, rather than looking for a missing test. A
  provenance field, a key's presence, a clock, a platform, a signed build:
  each one is a gate whose closed side is invisible to the whole suite.
- Then ask it of the class and write down the size of the answer. Here:
  `current_source` has two readers in `scripts/`, and one of them is a record
  field, so the closure revision is the **only** behaviour in Genesis gated on
  a request's provenance. Grepped, not remembered. The honest size of this
  class is one.
- A fixture may set such a gate by hand, and must say which field it set and
  what that leaves unverified. 056's sets the provenance label and nothing
  else; everything downstream — the refusal, `_may_revise`, the emit, the
  handler — is the real path, and that the AI is actually asked is still not
  verified and cannot be here.

Found in 056, asking 055's question of the two rows 055 left `NOT_ASKED`. The
other one, `GameController.finish_order`, turned out to be the opposite case:
wiring out its call failed **seven** suites.

> The test could not reach it because production holds the key.

---

## 53. The rule four doors knew, in front of the one door that mattered

**Signature:** a feature is built, tested, documented and deployed, and the
one line that decides whether it runs at all was written before the feature
existed and never revisited. Every test of the feature passes, because every
test asks what it would do and none asks whether it is reached.

**Cause:** 020 moved the API key off the web build. Anything under `res://`
is packed into `index.pck` and can be downloaded, so a web build carrying
`api_key.txt` publishes the key; the browser asks a Netlify function on its
own origin instead, and the function adds the key. Four places in
`ai_interpreter.gd` were taught the rule:

- `where_to()` returns the proxy path on web,
- `is_available()` returns **true** on web whatever the local key is,
- `_post()` attaches no `x-goog-api-key` header on web,
- `_load_key()` does not even look for the file on web.

The fifth place was `_send()`, and it stands **in front of all four**:

```gdscript
	if api_key == "":
		interpretation_failed.emit("No API key found in api_key.txt.")
		return
```

On the web `api_key` is **always** `""` — that is the design, not a fault:
`_load_key()` returns before reading anything, and nothing else in the
project assigns it (grepped, not remembered). So the guard was true on every
web request that has ever been made. `is_available()` said yes, `main.gd`
let the request through, and `_send()` killed it before `_post()` could run.
**The proxy could not be reached at any price**, and the player was told to
check a file that a web build must never carry.

The guard was reachable **only** on the web — on the desktop `main.gd` and
`experiment_runner.gd` both stop at `is_available()` first — and on the web
it was always true. A guard that fires exactly when it must not, and never
when it should.

**Why nothing caught it.** `proxy_test` has existed since 020 and passes. It
asserts where a request *would* go, that only the desktop build attaches a
key, and what the function does with what it receives. **It never asserted
that a request is made.** That is TRAPS 49's lesson at the layer above the
one 49 was about: the suite proved the destination and never the departure.

**Do:**

- When a rule is carried to several places, count them and then grep for the
  thing they have in common. Four call sites of `on_web()` and a fifth
  decision about the same subject is a list with one member missing, and the
  missing one is the one nobody thought of as being about that subject.
- A guard written before a feature existed does not know about the feature.
  When a build target, a transport or a credential moves, read every
  condition that mentions it — including the ones that mention only its
  absence.
- Put the decision in one function that both readers call, and give it the
  thing it branches on as an **argument**. `key_missing_for(web, key)` can be
  asked all four questions in a headless harness; `on_web()` inside the guard
  can be asked only the one the harness happens to be.
- A test that proves where something would go is not a test that it goes.
  Ask the departure question of every path that has a destination test.

Found in 057, while sweeping `main.gd`'s sixteen `connect()` calls and asking
why `_on_interpretation_failed` is held by nothing.

> Four doors knew the rule. The fifth was the one in front.

---

## 54. A panel asserted non-empty, seeded with a placeholder

**Signature:** a widget is asserted to be "not blank" and the assertion
passes with the code that fills it disconnected.

**Cause:** 058 wrote a fixture for the measurements panel, which 057 had
found held by nothing — `main.gd:993` is the only production caller of
`WorldRegistry.panel_lines()`, so `panel_refused_test`, `panel_built_test`
and `panel_geometry_test` all pass with nothing ever drawn. The fixture's
first draft asserted the panel was **blank** before any build, and failed:
`main.gd` stands a starter circuit up in `_ready()` and that build fills it.
The second draft asserted it was **not blank**, which passed — and still
passed with `track_measured.connect` wired out, because
`_build_metrics_panel()` writes a line into the panel at `main.gd:978`
before anything is measured:

```gdscript
_metric("", "Build a composed track to see its measurements.", METRIC_LABEL_COLOUR)
```

So the panel is **never** blank. With the handler disconnected, that one
line is what a player sees for the whole session, under a heading reading
TRACK MEASUREMENTS. **And HANDOVER had been describing the cost of that
missing wire as "the measurements panel permanently blank" since 057.** Not
blank: permanently *wrong*, which is worse, and which the second draft's
assertion could not tell from a real measurement.

**And the same shape was already in this file's own account.** The cure was
not a stronger emptiness test but a test that names the two states apart:
is the **placeholder** gone, and is what replaced it the line
`panel_lines()` actually produced?

**Do:**

- A non-empty assertion on a display is only as strong as the display's
  empty state. Find out what the widget holds before anything runs — a
  placeholder, a heading, a hint, a spinner — and assert against **that**
  string, not against `""`.
- Say which value is expected, not that some value arrived. `contains(want)`
  beats `strip_edges() != ""` every time, and the day `want` changes the
  assertion fails loudly instead of going quiet.
- When a document states the cost of a missing wire, check the cost the same
  way the wire was checked: disconnect it and look at the screen. TRAPS 14,
  applied to a sentence about a widget.
- The placeholder is a string in two files once a test knows it. Read it
  from the source that writes it, or assert the two agree (TRAPS 28).

Found in 058, by running a new suite against thirteen deliberate faults —
the one that mattered was the fourth, `metrics_log.clear()` removed, which
the second draft's assertion did not catch and the corrected one does.
`tests/handler_wiring_test.gd` carries both halves.

> The panel was not blank. It was holding the sentence that says it is.

---

## 55. One fault in a fixture, reported as three

**Signature:** a single wire-out fails assertions in sections of a suite
that have nothing to do with it, and the count of failures is read as the
breadth of the damage.

**Cause:** 058's suite holds three handlers in one file, in sections. The
first section is `_on_interpretation_failed`, and **that handler is the one
that clears `main.revising`** — which `main.gd:166` refuses every typed
request on. Wire its `connect` out and the handler never runs, `revising`
stays true, and every request the rest of the file sends is refused before
it reaches anything. Measured: the first wire-out run scored **ten**
failures across all four sections and read as "the whole file holds this
wire". It does not. With the state a previous section can leave behind
cleared between sections, the same wire-out scores **eight**, all of them in
the two sections about that handler, and the `track_measured` and `equipped`
sections pass — which is the honest answer, and also the proof that those
two sections hold their own wires rather than this one.

The direction of the error is the part worth keeping: it is **flattering**.
A cascade makes a suite look like it holds more than it does, in exactly the
way a shared `user://` made four of 055's answers flattering (TRAPS 50).

**Do:**

- When a fixture has sections, ask what state each one leaves behind, and
  clear the state that gates the next one's input. Then the failure count is
  attributable and each section's pass means something on its own.
- Reset harness state, never a verdict. The fields cleared between sections
  must be ones nothing downstream asserts, and the assertions about them
  must run before the reset.
- A wire-out that fails many sections is a claim about blast radius. Check it
  by making the sections independent, not by counting.
- Three faults, one at a time, is the measurement. One fault and three red
  lines is a number.

Found in 058, between the first and second runs of the same wire-out.

> Ten failures and eight failures were the same fault.

---

## 56. Two writers, one ledger, and the same id

**Signature:** a suite fails under changes that cannot reach it, the failure
count varies between runs of the same change, and a pristine control run of
the same copy passes.

**Cause:** `TrackLog.next_id()` was `"<unix seconds>-<serial>"`, and `serial`
is a static that restarts at 0 in every process. So two processes writing to
one `user://track_log.jsonl` mint **the same ids** whenever they overlap
inside one wall-clock second.

Measured rather than reasoned about: two Godot processes, three records each,
one ledger, twelve paired runs — **every id collided in eight of the
twelve**. The four that did not were pairs that straddled a second boundary.

One ledger with two writers is the normal state of this repository, not an
edge case. Every copy of the project shares one `user://` (TRAPS 50) and
`run_tests.sh` starts sixty-odd processes against it a fraction of a second
apart. `intent_door_test` looks its own record up by id with `_record_for()`,
which returns the **first** match in the file — so when the suite that runs
immediately before it had already written that id, the lookup returned the
**other suite's record** and the assertions about this suite's own request
failed. It failed 8, 8, 7 and 8 under four wire-outs that cannot reach it,
and nothing under three others.

**What it cost beyond the harness**, read off the readers rather than
guessed. The id is the only thing tying a later record to an earlier one:

- `session_report._understanding()` keys evidence by id, so of two records
  sharing one, the report attributes **one's understanding verdict to the
  other** — a true-looking score about the wrong request, in the artefact
  this project exists to keep.
- `game_controller.gd:420` writes a delivery's evidence as
  `"about": <the order's id>`, so a duplicate makes the proof of a delivery
  point at two orders.
- Five suites and `session_report` scan for an id and take the first match.
  Not one of them says anything when there are two.

**And it invalidates part of the method this project measures with.** Every
commit since 055 reports *"the lists were diffed and are identical"*. Those
diffs were taken with a suite in them that can fail this way in roughly two
runs out of three. The claims were true of the runs they describe; the
instrument had a coin flip in it.

**Do:**

- An identifier that has to tell one writer's records from another's must
  carry something **only that writer has**. A clock does not qualify, at any
  granularity: the question is not how precise it is but whether two writers
  can read the same value.
- A per-process counter is not an identity. It is the same counter in every
  process.
- When a suite fails under a treatment that cannot reach it, do not record
  the number. Take a pristine control run of the same copy first — and if
  the count varies between runs of the same treatment, stop measuring and
  find out why, because every answer in that sweep is now suspect.
- Prefer an identifier that **names** the writer over a random salt:
  `OS.get_process_id()` makes a collision impossible *and* makes a record say
  which process wrote it.
- Then ask it of the class and write down the size of the answer, grepped
  rather than remembered. Here it is **three**: the record id (fixed in 059),
  the session id (`main.gd:515`, the tester's name plus a second) and the
  experiment `run_id` (`experiment_runner.gd:62`, a second and nothing else).
  **Two of the three are not fixed.** `ledger_audit_test` already salts its
  session name with `Time.get_ticks_msec()`, which is somebody meeting this
  once and defending one call site against it.

**Reproduced, not inferred.** The pair that produces it is
`handler_wiring_test` then `intent_door_test`, the two that run back to back
in a full run, against one `user://`, repeated ten times. Pre-059: **one of
ten pairs failed and it failed eight**, the same count the sweep kept
seeing, and that run had **13** ids written by both processes where the nine
passing runs had 1. Fixed: **0 of 10**, with records from two distinct
writers in the shared ledger every time. The rate depends on how much the
two writers overlap inside a second; the mechanism does not.

Found in 059, while measuring something else, by noticing that a suite with
no connection to a wire-out kept failing a different number of times.

> The clock is not an identity. Two processes read the same second.

---

## 57. The fixture supplied the names it then proved were there

**Signature:** sixteen suites stand up the program's main node and every one
of them passes. Rename a node in the scene the game actually launches and the
game dies at startup on a null — and not one of the sixty-four suites says a
word.

**Cause:** **nothing in the repository had ever loaded `scenes/main.tscn`.**
Grepped across `tests/` and `scripts/`: no file mentioned a `.tscn` at all.
Every suite that needs `main.gd` builds its own tree by hand in a
`_make_main()` of its own — `Node3D`, a `CanvasLayer` called `UI`, a
`PanelContainer` called `CommandPanel`, a `LineEdit` called `InputBox` — and
names each node exactly what `main.gd`'s `@onready` lines ask for. So the
fixture **supplies** the names and then the suite proves they are there. It is
TRAPS 14 in a fixture rather than in a document: the check guards the
assumption instead of checking the fact.

The scripts resolve **six** node paths against that scene — four `@onready`
in `main.gd`, and `Camera3D` and `Ground/CSGBox3D` read off `world_root` in
`game_controller.gd`. Measured in a throwaway copy by renaming
`BuildButton` to `Build` in the scene: `main.gd:100` throws *"Invalid access
to property or key 'pressed' on a base object of type 'null instance'"*,
which is the game failing at launch, and before 060 every suite was still
green.

**And the hand-built tree was not the scene in a way that is measurable.**
Sixteen files in `tests/` set `box.use_collision = true` on the ground slab.
Nothing in `scripts/` sets `use_collision` anywhere, and the real scene's
`Ground` is a `StaticBody3D` with no `CollisionShape3D` and a `CSGBox3D` with
`use_collision` left false. A 1 m box dropped from y = 6 fell to **y = −42.77
and was still falling** in the real scene, and **rested at y = 0.49** in the
fixture. What that costs today is **nothing**, measured and not argued: all
sixteen were patched to match the scene and every suite run again, and the
lists diffed **identical, line for line**. The two suites that really do need
a floor — `physics_test` and `behaviour_test` — build their own 4000 m
`StaticBody3D` with a real `CollisionShape3D` and were untouched.

**Do:**

- A suite that stands up the program **loads the scene the program launches**,
  resolved through `ProjectSettings` rather than by path, so a suite cannot
  end up holding a scene that is no longer the game's.
- Enumerate the node paths **out of the scripts' own source** — the
  `@onready` lines, the `get_node_or_null` literals — and resolve each one
  against the loaded scene. A list typed by hand covers the paths that
  existed the day it was typed; an enumeration covers the fifth one the day
  it is written.
- Where a fixture must still be hand-built, treat every difference from the
  scene as unmeasured until it is measured. The cheap measurement is to make
  the fixture match and run everything.

Found in 060, by asking where the player's two doors actually are.
`tests/player_door_test.gd` is the first file in the project's history to
load `scenes/main.tscn`.

**061 CLOSED THIS, AND CORRECTED TWO THINGS IN THE ACCOUNT ABOVE.**

- **It was SEVENTEEN suites, not sixteen.** The count above is of files with
  a `_make_main()` of their own. `session_test` has none: it
  `extends "res://tests/drive_test.gd"` and inherits that file's fixture. A
  count of fixtures is not a count of the suites that use one.
- **"Sixteen files in `tests/` set `box.use_collision = true`" is now
  history.** None of them builds a slab at all. Every one of the seventeen
  loads the scene, resolved through
  `ProjectSettings.get_setting("application/run/main_scene")` rather than by
  path, so no suite can hold a scene that is no longer the game's.

What 061 measured, and both halves are worth keeping:

- **No suite's answer rested on the stand-in.** 65 suites before, 65 after,
  `--all`, `user://` cleared first, lists diffed: the only change is one
  assertion count. That is the strong form of what 060 could say about the
  collision alone.
- **But one number moved, and 060's "costs nothing" was about verdicts and
  not about behaviour.** On `drive_test`'s banked square an opponent car that
  came off the road **rested on the stand-in's floor at y = −0.1 after 21
  recoveries**, and against the game's own scene **falls through the world to
  y = −50.2 after 25**. Four runs, two a side, each byte-identical to its
  repeat. The game does not need the floor —
  `race_director.gd:225` counts a car's vertical drop in its off-road
  distance, doubled, so a falling car is recovered like any other — but the
  harness had been hiding the fall for the project's whole life.

So the last line below is right and it is not the whole of it: a fixture that
builds the tree agrees with itself about the TREE, and quietly lends the
simulation a floor as well.

> A fixture that builds the tree cannot test the tree. It can only agree
> with itself.

---

## 58. A node's name decided by what was there before it

**Signature:** an assertion about a node's name passes, and the identical
assertion one build earlier fails. Nothing about the node changed.

**Cause:** `RacingModule.build()` sets `circuit.name = "CircuitBuilder"` and
**then** calls `root.add_child(circuit)`. Godot's `add_child`, with
`force_readable_name` left at its default `false`, replaces the name of a
node that shares one with a **sibling** by a dummy `@Type@id`. And the world
being replaced is still a sibling in that frame: `_clear_world_node()` calls
`queue_free()`, which does not remove it until the frame ends — **the same
fact 048 found underneath a count that said fourteen rooms**.

So the name **alternates**, which is more than "the first build is wrong" —
the reading this session made before measuring. Four builds in one session,
measured:

| build | node name | why |
|-------|-----------|-----|
| startup circuit | `CircuitBuilder` | nothing there to collide with |
| 1 | `@Node3D@49` | the startup circuit still held the name |
| 2 | `CircuitBuilder` | the outgoing one was called `@Node3D@49` |
| 3 | `@Node3D@124` | the outgoing one held the name again |

**Every other circuit a player builds gets a dummy name**, decided by what
the previous world was called and by nothing about this one.

Nothing a player can reach is wrong, and that is asserted rather than
assumed: no file in `scripts/` contains the string `"CircuitBuilder"` except
the module that assigns it, so no production code identifies a world by name
— the controller holds `drivable["node"]` by reference. What reads the name
is `drive_test`, twice. Its positive assertion (`names == ["CircuitBuilder"]`)
passes on the **parity of its own build order**: the world before it is a
farm, whose pieces go straight into `world_node` with no `CircuitBuilder`
among them. Its other one reads the name the other way round — *"the last
child is not called CircuitBuilder, so the farm is on screen"* — which a
dummy name satisfies as readily as a farm does, so it cannot tell the state
it is about from the state it is not (TRAPS 41's shape).

**And the obvious fix does not fix it**, measured rather than assumed: moving
the assignment to **after** `add_child` yields `CircuitBuilder2`, readable
and still not the name. What would fix it is freeing the outgoing world
before adding the new one, or not identifying a world by name at all.

**Do:**

- Identify a node by **reference**, never by name. A suite that wants to know
  which node the game will drive asks the controller for
  `drivable["node"]` and compares identity.
- A name assigned before `add_child` is a request, not a fact. If a name has
  to be stable, assign it after and assert it, or make sure no sibling can
  hold it.
- An assertion about a name is an assertion about **build order**. Ask what
  the world before this one was, and whether the assertion survives the
  other answer.

Found in 060, by this file's own first draft asserting
`standing == ["CircuitBuilder"]` and failing. Left unfixed in `scripts/` on
purpose and recorded under "Human decision needed" 24: it touches a builder
every world in the project goes through, and nothing reads the name.

**061 TOOK THE "Do" ABOVE AT ITS WORD, ON THE TEST SIDE.** `drive_test`'s
**two** readings of a world's node name — the class and not the one
instance 060 commented on (TRAPS 11) — now assert **identity** against
`drivable["node"]`, as `player_door_test` section 1 already did. So
**nothing in this repository identifies a world by name any more**,
production or test, asserted off the files. The paragraph above saying "what
reads the name is `drive_test`, twice" is history. **`scripts/` is
unchanged** and the production question is still the owner's: the name is
still assigned before `add_child` and still usually replaced. What changed
is that no check can hide that any more by passing on its own build-order
parity.

> A node's name is not the node's. It is whatever was free when it arrived.

---

## 59. A guard written against the one idiom its author imagined

**Signature:** a check exists for the express purpose of catching a claim
going stale. The claim goes stale. The check passes.

**Cause:** 060 found that nothing in this repository had ever loaded
`scenes/main.tscn`, and wrote the claim into a suite header. Knowing a header
sentence can rot, it added an enumeration to hold it:

```gdscript
if body.contains(".tscn"):
	loaders.append(name)
_check(loaders.is_empty(),
	"this is the only file in tests/ or scripts/ that names a .tscn")
```

In 061 **seventeen suites began loading that scene**, so the claim was false.
The assertion **would have gone on passing**, because those seventeen reach
the scene through `ProjectSettings.get_setting("application/run/main_scene")`
and name no `.tscn` anywhere. The check did not search for *loading the
scene*. It searched for **the way the author happened to imagine loading the
scene**, and the project found another.

It is TRAPS 14's shape — a claim in a document with nothing behind it — but
one level further in, and therefore harder to see: there *was* something
behind it, and the something could not see the change.

**Its twin in the same commit went the other way, and the contrast is the
lesson.** Section 6 of the same suite asserted *"N other suites build that
slab WITH collision"*, N ≥ 2, holding the other half of 060's finding. 061
took that count to 0 and the assertion **failed when it was run**. The
difference between the two is not care or effort: it is that one was keyed on
a **count of the thing itself** and the other on a **string that happened to
accompany it**.

**And the replacement's first draft walked into the same trap twice.** It
searched `tests/` for `set_script(load("res://scripts/main.gd"))` and for
`.tscn`, and (a) found its own source, because the assertion writes those
strings out, and (b) found all sixteen converted files, because each one's
*comment* names `scenes/main.tscn`. Both failures were read off a run, not a
review.

**Do:**

- Write the guard against **the state**, not against the spelling. "No suite
  stands `main.gd` up by hand" is a fact about the repository; "no file
  contains `.tscn`" is a fact about typing.
- Prefer a guard that is a **count of the subject** over one that is a search
  for a word near it. A count goes to zero when the thing goes away; a search
  only goes to zero when one particular way of writing it goes away.
- Ask of every new guard: **what is the other way this could happen?** If the
  answer is "through a different API", the guard is already too narrow. 060's
  check could not see `ProjectSettings`.
- A file that searches for a string is a file that **contains** that string.
  Skip itself, and say in the comment why.
- A check that fires on a **comment** is checking the wording. Search for
  something only code can contain — a resource path, a call, a node — not a
  filename that a sentence might mention.
- When a guard's claim is overtaken, **replace the guard, do not relax it**,
  and say in the file that the sentence it held has become history
  (TRAPS 14). A guard left passing over a changed fact is worse than no
  guard: it certifies the stale claim.

Found in 061, while retiring the fixtures TRAPS 57 is about — by noticing
that the conversion had falsified 060's sentence and that the suite had not
said so.

> A guard keyed on how a thing is written guards the writing. The project
> will find another way to write it, and the guard will still be green.

---

## 60. A whole layer with nothing able to read it, and the rule kept at two of its three doors

**Signature:** a fault survives a commit written expressly about the function
it lives in, and survives 65 green suites, because the only evidence of it is
on a screen nobody is looking at.

**Cause:** `GameController` has two functions that decide what a player sees
after a build — `_frame_view()`, which pulls the camera back far enough to
hold the world and grows the ground pad under it, and `_restore_view()`, which
puts both back the way `scenes/main.tscn` has them. **Before 062 no suite read
either.** Counted rather than remembered: the word "camera" appeared in **17**
of the 65 files and in exactly **three assertions** — two that a particular
camera is `current`, one that the controller holds a camera at all. Every other
appearance was a comment. Not one read where a camera is, what it is aimed at,
or what it can see.

The rule the two functions keep between them is one sentence: *when a request
leaves the world empty, the view goes back to the scene's own camera and the
scene's own 200 m pad.* Read off every call of `_clear_world_node()` in the
file, there are three paths that empty the world without building another, and
**the rule was kept at two of them**:

| path | |
|---|---|
| `CLEAR_WORLD` | restores |
| a sectionless `CREATE_TRACK` | restores |
| a `PLAN` that fails in pass 3 | **did not** |

So a plan that failed after clearing took the player's world away and left a
camera and a 1452 m ground pad still framed on the circuit that was no longer
there. Reachable with the plan a player meets first: two worlds and no
`"around"`, which `_place()` centres on each other and refuses.

**040 is the commit about that exact function**, and it fixed the half of this
path that was about the world being destroyed. It did not see the other half,
and the reason is not carelessness: **nothing in the repository could express
it.** A missing world is a child count. A camera left in the wrong place is
twelve floats nobody had ever asked for.

**And the measurement nearly asked its question at a size no player has.** A
frustum depends on the aspect ratio, and a headless Godot gives the root window
**64 × 64**. The first draft of the new suite's capability check found three of
the four corners of a world's footprint inside the frustum and the fourth off
the left edge, at every circuit size tried. That is not a finding about Genesis.
At the size `project.godot` configures — 1152 × 648 — all four are inside with
room to spare.

**Do:**

- Ask of every layer, not every function: **what in this project is only ever
  true on a screen, in a log, in a file nobody reads back?** A layer with no
  reader accumulates faults at the rate the code changes, and none of them
  costs a test.
- Most of what looks visual is **arithmetic**. A transform is twelve floats, a
  frustum is a matrix, and `Camera3D.is_position_in_frustum()` answers headless
  without drawing anything. "We cannot test it, it is graphical" is a claim
  about Genesis and gets checked like one (TRAPS 14).
- When a rule is kept in more than one place, **enumerate the places off the
  source** and check every one. Two of three doors is how this fault looked
  from the inside: correct, twice, in the two functions anybody would read.
- **Set the measurement's own conditions from the project's settings, never
  from a literal, and assert they took.** A headless default that no player
  ever meets turns a capability check into a check on the harness (TRAPS 6).
- A guard keyed on **line distance** is a guard on comment length. 062's first
  draft asserted that each `_restore_view()` sat within three lines of a
  `_clear_world_node()`; it passed, and then failed the moment the commit added
  its own restore with a comment above it. Keyed on **function scope** instead,
  it says what it meant to say.

Found in 062, by asking 061's "Next action" — *what in this project is only
ever true on a screen?* — rather than by finding the fault.

> A layer nothing can read is not a layer with no faults. It is a layer whose
> faults have never been counted.

---

## 61. The sun's rotation, written into the three slots the engine ignores

**Signature:** a value that has been wrong since the project's first commit,
in a node every suite stands up and nothing has ever read, and the numbers
that should hold it are sitting one field away, in a field that does nothing.

**Cause:** `scenes/main.tscn` has had this line since `614a1f5`, Prototype
001, and no commit between then and 063 touched it:

```
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, -45, -30, 0)
```

That is an **identity basis** with an **origin of (-45, -30, 0)**, on a
`DirectionalLight3D`. A directional light is infinitely far away: the engine
**ignores its position entirely** and emits along the node's local -Z, so its
rotation is the whole of what it does. With no rotation the sun pointed
**horizontally**, and `N·L` for every horizontal surface in Genesis — the pad
the game starts on, a track's road, a farm's zones, a dungeon's floors — was
**exactly 0.000000**. The three numbers that would have aimed it were in the
one field on that node that changes nothing.

It survived 62 commits, 66 green suites and eight faults found by the owner's
own editor sessions, and the reason is TRAPS 60's reason: **the word
"DirectionalLight" appeared nowhere in `scripts/` or `tests/`.** Not in an
assertion, not in a comment. Neither did "WorldEnvironment" or "ambient".

**Do:**

- For each node in a scene, ask **which of its twelve floats actually do
  anything.** A directional light's position does nothing; a camera's does.
  Three numbers in a slot the engine ignores, on a node whose other slot is
  unset, are a value written into the wrong field — and that is a reading, not
  a guess, because the numbers themselves say what they were for.
- **A hand-ordered `Transform3D` literal in a `.tscn` is the transpose of the
  basis you computed in code.** 063's first fix was going to be written out by
  hand from `Basis.from_euler()`'s own printed axes, which would have installed
  the **inverse** rotation — and the existing line gave no warning, because an
  identity basis is its own transpose. What caught it was asking Godot to
  serialize the scene and reading the line it wrote. Let the engine write the
  twelve floats.
- **"We cannot test it, it is graphical" is a claim about Genesis** (TRAPS 14,
  TRAPS 60). Whether anything is *lit* needs a renderer. Whether the sun can
  reach a floor **at all** is one dot product, and it is the question that was
  wrong.
- State the cost **at the width it is true** (TRAPS 15). The scene's
  `Environment` has a sky background with ambient source BG at full sky
  contribution, so horizontal surfaces were still lit — flatly, from
  everywhere, with no sun term and no shadows. "The screen was black" would
  have been false, and is asserted nowhere.

**And the deliberate fault that caught the new suite's first draft, which is
worth more than the fix.** That draft asked every question of the **running
game**, reasoning that the light a player gets is a stronger subject than the
light the file describes. It is — for a light. It is the **weaker** subject for
a camera, and the suite's class assertion covers both: `_frame_view()` **aims
the live camera on every build**, so with the scene's camera rotation deleted
the draft reported **0 failures** and passed on a camera that had no rotation
in the file at all. Read the live state to find out what a player gets; read
the **file** to find out whether a value is there to be got. A value something
else supplies every frame cannot be found missing by looking at the frame.

Found in 063, by taking 062's "Next action" — *the light and the environment* —
at its word, and finding that one of the two was arithmetic after all.

> A number in a field the engine ignores is not a number with no effect. It is
> a number whose effect was wanted somewhere else.

---

## 62. The rect that is zero in the one place a suite would read it

**Signature:** a new suite asserts something about a `Control`'s size or
position, passes, and would have passed on any layout whatsoever — including
no layout at all.

**Cause:** a `Control` under a `CanvasLayer` gets its rect **as it enters the
tree**, not on a deferred pass, so headless layout is not the problem 063
expected it to be. But there is one window in which every rect reads
`(0, 0)`: before the viewport's first layout pass. That window is
`_initialize()` — which is where a `SceneTree` script begins, and therefore
exactly where a suite written the obvious way does its work. Measured three
ways in one process, Godot 4.7.1 headless, a `CanvasLayer` and a
`PanelContainer` added to the root and read immediately:

| when the node was added | rect read immediately |
|---|---|
| inside `_initialize()`, before the first frame | `(0, 0)` |
| from a deferred call, one frame having begun | `(1152, 120)` |
| later still | `(1152, 120)` |

So `_run.call_deferred()` — the idiom `scene_light_test`, `view_frame_test`
and `scene_ui_test` all open with — is **load-bearing** for anything that
reads a rect, and none of those files said so. A suite that skipped it would
have compared zeros to zeros and reported `failures=0`, which is TRAPS 6 with
the engine supplying the vacuity rather than the schema.

**Do:**

- Never read a `Control`'s rect from `_initialize()`. Defer the body of the
  suite, as these files do, and say in a comment that the deferral is the
  reason the rects are real.
- When a measurement depends on a fact about the engine, **assert the fact in
  the file that depends on it**, both halves — the zero and the non-zero.
  A probe that established it once, in a throwaway copy, is not evidence
  that the committed suite is reading anything.
- The general form: before asserting off a value the engine computes, find the
  conditions under which that value is a default, and check that the suite is
  not standing in one of them.

Found in 065, by writing the wrong assertion first and reading the failure:
the suite's own section 1 claimed the rect needed frames stepped, and failed,
because by then a frame had begun.

---

## 63. The one defence against a shared id was built from a clock

**Signature:** a suite fails a varying number of assertions under changes
that cannot reach it, and a pristine control run of the same copy passes —
TRAPS 56's signature, two releases after TRAPS 56 was written and the record
id was fixed.

**Cause:** 059 fixed one member of a three-member class — `TrackLog.next_id()`
now carries `OS.get_process_id()` — and wrote the rule down for the other two.
What nobody asked was whether the same rule had a **fourth** place to hold:
not the identifiers Genesis mints, but the names the **suite** hands it.

`main.gd:515` mints a session id as `"<name> <datetime to the second>"`, and
`TrackLog.read_session()` returns every record carrying that id out of one
`user://track_log.jsonl` that every copy of this project shares (TRAPS 50).
Three suites start a session. Two used a fixed string — `"handler_wiring"`
and `"Sam Jones"` — so two processes reaching that line inside one wall-clock
second get **the same session id**, and each then reads the other's records
back as its own.

Measured rather than reasoned about: **six paired concurrent runs of
`handler_wiring_test` against one ledger, and in five of the six one of the
pair failed** *"the ledger gained exactly one ai_unavailable event (got 3)"*
and returned early, scoring **44 assertions where a clean run scores 47**.
After the fix, **six of six scored 47 and 0 on both sides.**

**And the one suite that had defended itself did it with a clock.**
`ledger_audit_test` salted its session name with `Time.get_ticks_msec()`,
which is the single thing TRAPS 56 says does not qualify — and it is weaker
here than wall-clock, not stronger: `ticks_msec` counts engine uptime, which
is mostly deterministic startup work, so two processes read from a narrow
window rather than a wide one. Measured over 20 headless runs of this
project, the value at the top of a suite spanned **123..199 ms**, and in 20
samples `129` came up three times and `172` twice.

**Do:**

- When a fault is fixed in the thing a program mints, ask the same question
  of the **names the tests hand it**. The harness is a writer to the same
  ledger, and TRAPS 11 does not stop at the boundary of `scripts/`.
- A salt that is a clock is not a defence. `OS.get_process_id()` cannot
  collide and says which process wrote the record.
- **Hold the rule mechanically, not in prose.** The rule had been written in
  this file and in HANDOVER since 059 and nothing in the repository could
  read either. `record_id_test` sections 8 and 9 now scan `tests/` for every
  session start and `scripts/` for every identifier mint, so a fourth suite
  that starts a session unprotected fails by name and line.
- **A check a comment can satisfy is not a check.** The first version of
  section 8 searched whole files for `OS.get_process_id()` and the first
  deliberate fault — reverting `handler_wiring_test`'s name to its old bare
  string — **passed**, because the comment the fix had just added to that
  suite says the call in prose. Scan code, not comments. The second version
  then counted an assertion *message* (`_check(..., "/session alone reports
  the running session")`) as a session start, which is the same mistake from
  the other side.

Found in 066, by asking what was left of 059's class and discovering that the
two members everybody had been counting were both the owner's — and that a
third, nobody's, was reproducibly broken.

> The harness writes to the ledger too.

---

## 64. The rule was written down, applied to one function, and nine scans read the same raw text

**Signature:** a fix is applied where the fault was found, the general lesson
is written into this file in the same commit, and the next session finds the
same fault in three more places that nobody asked. TRAPS 11's signature,
except that the commit which left the others undone is the one that wrote
TRAPS 11's lesson out again.

**Cause:** 066's first deliberate fault **passed**. Its new scan searched
whole files in `tests/` for `OS.get_process_id()`, and the comment 066 had
just written into `handler_wiring_test` says the call in prose — so reverting
that suite's session name to the bare string the scan exists to catch changed
nothing. 066 narrowed that one function and wrote the lesson down: *"a check
a comment can satisfy is not a check. Scan code, not comments."*

**It narrowed one function.** Nine files in `tests/` read this project's own
source, and 067 asked each of them the same question. **Three more were
satisfied by a comment**, measured one at a time in throwaway copies with
their own `config/name` (TRAPS 50), each flipped from FAIL to PASS by **one
comment line**:

- `handler_wiring_test`'s guard that its `PLACEHOLDER` constant is the string
  `main.gd` writes. Change `main.gd:978` and leave the old text in a comment
  beside it: **47 assertions, failures=0**, on a guard whose whole job is to
  stop that constant drifting into something that matches nothing — which is
  TRAPS 54's fault one layer out.
- `player_door_test`'s guard that no suite reaches the main scene by a path of
  its own — the rule 061 retired the stand-in for. A suite that loads the
  scene from a path it assembles itself is caught **by name**, until one
  comment in it says *"Not read from application/run/main_scene,
  deliberately"*, at which point it is filed as reaching the setting: **67
  assertions, failures=0.**
- `check_wiring_test`'s guard that `BY_HAND`'s row still names a function that
  exists. Rename `quarrel_with()` through `scripts/` and put the row back to
  the old name and it fails; add *"Renamed from func quarrel_with(reason)"* to
  `refusal_check.gd` and **188 assertions, failures=0**, on a staleness guard
  that was itself stale.

**AND "SCAN CODE, NOT COMMENTS" IS THE WRONG RULE, which is the part worth
keeping.** Applied as written it would have **narrowed two checks that are
wide on purpose.** `controller_reach_test` and `refusal_reach_test` both
collect every `FAILED_` name in `scripts/` and assert each has a declared row,
and a name that appears only in a comment **still has to be answered for**,
because somebody reading that comment will go looking for the row. The same
scan's other direction — *"a declared row still names a category the code
returns"* — needs the opposite text, because a category deleted from the code
and left in a comment is exactly the stale row it exists to catch.

**Do:**

- **The rule is about DIRECTION, not habit.** A question about what the code
  **does** is answered from the code, comments stripped. A question about what
  is **mentioned** anywhere reads the raw file. One scan can be asked both;
  `refusal_reach_test._categories_in_source(code_only)` now is, with the two
  texts separated and the reason written at the function.
- **When a fix is applied to the function where the fault was found, count the
  other callers of the same question before the commit closes.** The sweep is
  cheap: `grep` `tests/` for reads of `res://scripts` and `res://tests`.
- **Preserve the line count when stripping.** A scan that reports `file:line`
  is reporting into the stripped text; 066's own fault 2 was a report that
  named a line which started nothing.
- **Hold it mechanically.** `tests/source_scan_test.gd` enumerates every file
  in `tests/` that reads a `.gd` source, asserts each goes through a function
  named `_code_of()`, asserts each **defines** it, and asserts all of those
  definitions are **byte-identical** — nine private copies of one function is
  TRAPS 28's shape, and a drifted copy is a scan blind in a way nothing says.
  It holds this at **file** granularity and says so: it cannot prove that
  every needle inside a member goes through the reader. That half is held by
  the negative controls 067 put beside each fixed scan — prose in, nothing
  out; code in, the needle out — which assert the reader and not the wording.

Found in 067, by asking TRAPS 11's question of the commit that had just
restated TRAPS 11.

**RECURRED IN 082, AND THE SWEEP ABOVE IS WHY IT SURVIVED.** The "Do" on this
page says to count the other callers with a grep of `tests/` for reads of
`res://scripts` and `res://tests`. That sweep, and `source_scan_test` which
mechanises it, both work at **FILE** granularity: they ask whether a file
*has* a `_code_of()`. `handler_wiring_test` has one — it uses it in section 2
— and `_why_two_are_unreachable` in section 5 read the raw text anyway,
dropping WHOLE-LINE comments by hand and letting a comment AFTER code on the
same line through as code. 081 measured the file-vs-function gap and listed
the nine functions; 082 read them. Measured (TRAPS 50, own `config/name`): the
two real `interpretation_failed.emit()` calls were moved out of `_send()` into
a helper, so the asserted fact became **false**.

| treatment | result |
|---|---|
| the move, with `# was interpretation_failed.emit(...) before the move` left behind | **49 assertions, failures=0 — the assertion PASSING on a false fact** |
| the same move with no comment | 49 assertions, failures=1 |

One comment line flipped it from FAIL to PASS, sixteen commits after this page
said not to let that happen. **The direction rule is what makes it serious**:
the assertion is a POSITIVE membership claim — *"`interpretation_failed` is
the only one of the three `_send()` emits"* — so a comment does not merely
widen the net, it **satisfies** the claim. Fixed by routing the read through
`_code_of()` and deleting the hand-rolled skip. The class was then enumerated
mechanically rather than by eye: of the **twenty-one** hand-rolled comment
skips in `tests/` **as this commit found them**, nineteen are inside a
`_code_of()` definition or on a line that has already called one, and
**exactly two** were raw reads —
`handler_wiring_test._why_two_are_unreachable` and
`controller_reach_test._guard_spawn_opponents`. Both fixed in 082; the second
turned out to be hiding a worse fault, which is TRAPS 79. **That twenty-one is
a count taken BEFORE the fix and it will not reproduce**: the fix deletes
three of those lines, so the same grep of `tests/` returns **eighteen** today.
Both numbers were read off `git grep` rather than remembered. Said here
because a bare count in a document is the next session's stale count (TRAPS
24, TRAPS 76), and this one is load-bearing for the arithmetic above.

> A file-granular sweep closes a file-granular question. This one was asked
> of files for fifteen commits and was always about functions.

> The lesson written down in the same commit as the fix is the lesson most
> likely to be applied once.

---

## 65. The bound the model is told in a shape the suite that holds bounds cannot read

**Signature:** a suite exists for the express purpose of comparing every bound
the prompt states against the constant that enforces it. The prompt states
four bounds the suite has never read, and no file in `tests/` names the
constants behind them at all.

**Cause.** `tests/prompt_bounds_test.gd` reads a count statement with two
regular expressions — `N to M <members>` and `(at most|up to|no more than) N
<members>` — and its own header said what that buys: *"it does not matter
which sentence says it or how"*. It does matter. Between them the two patterns
can only match a statement that names a **maximum**, and the prompt stated:

- `at least 2 straights and at least 2 corners or hairpins`
  (`FeasibilityGate.MIN_STRAIGHTS`, `MIN_TURNS`), typed out by hand;
- `exactly +360 (clockwise) or -360 (anticlockwise)` and `adding up to 360`
  (`FeasibilityGate.FULL_TURN`), typed out by hand twice more.

`FULL_TURN`, `MIN_STRAIGHTS` and `MIN_TURNS` appeared in **no file in
`tests/`** — grep, not memory. So the prompt could state any floor it liked.

**Measured rather than reasoned about.** With the prompt reading *"at least 7
straights and at least 9 corners or hairpins"* — a floor stated four times
narrower than the truth, which is TRAPS 28's own fault — and
`PROMPT_FINGERPRINT` moved with it the way every real prompt edit moves it,
**all 69 suites passed: 0 with something to look at.** And the pre-068 reader,
handed the farm's zone floor restated as *"Use at most 24 zones, and at least
9 zones"* against a declared minimum of 1, also reported `failures=0`.

**The fingerprint is not a second net.** `PROMPT_FINGERPRINT` fails on *any*
change to the prompt and its failure says *"move PROMPT_VERSION"*. It is a
change detector. It cannot say the prompt is **wrong**, and the session that
edits a prompt moves it in the same commit — so any claim resting on it is a
claim about nobody having edited the prompt.

**The same number at a fourth door, which is the TRAPS 11 half.**
`FeasibilityGate`'s `FAILED_INFEASIBLE` tells the **player** *"a circuit must
turn exactly +360 or -360 deg"* — typed out by hand, in the file that declares
`FULL_TURN`, eleven lines below it. Fixing the prompt alone would have left
that one.

**And the one that was LIVE, at the player's door, in two sentences one line
apart.** The same gate's floor refusal read *"closing a circuit needs at least
2 straights and 2 **corners**"*, and the count beside it read
`Readback.plural(turns, "corner")`, so a composition of one hairpin was
reported as *"1 corner"*.
`MIN_TURNS` is compared against a count of `TrackGeometry.YAW_TYPES` —
`["corner", "hairpin", "banked_corner"]` — so a **hairpin** answers that door
as well, which the prompt has always said and that sentence did not. Measured:
a composition of `MIN_STRAIGHTS` straights and `MIN_TURNS` hairpins with no
corner at all clears it. **A refusal naming a narrower set than the check
accepts costs the player the design the check would have taken** —
TRAPS 15's shape, at a refusal, in the same file as the hand-typed numbers and
found only because moving them meant reading it. **Both were fixed**: fixing
the rule and leaving the count one line above it would have been TRAPS 11
inside four lines.

**And 068 claimed nothing in `tests/` had ever read those sentences, and that
was false.** The claim rested on a `grep` of `tests/` for `composition has`,
which returns nothing. `counted_said_test` reads that sentence with a needle
built at run time from `Readback.plural(1, "corner")`, so the string a grep
looks for is not in the file — and the suite went **red** on the fix, in the
first full run after it. What it asserts is the agreement between a count and
whatever noun follows it, **with the noun typed in**, so it could not see the
noun being the wrong one; its own header says the suite never types nouns in,
and at that one site it did. **A grep for a sentence finds the suites that
QUOTE it, not the suites that CONSTRUCT it** — which is this trap's own blind
spot one layer out.

**And a third copy of a constant, found by the same question.**
`FeasibilityGate.MAX_ANGLE_ADJUSTMENT` is a second declaration of
`ClosureSolver.MAX_ANGLE_ADJUSTMENT`: the gate decides which net turns are
reachable from **its** copy and states **its** copy to the player, while the
prompt states the solver's. Nothing asserted the two were the same number.
Both are `0.20` today, so nothing is wrong — what was missing is the tie.

**Do:**

- **Ask of every pattern in a suite what member of its class it cannot
  match**, and then feed it that member and watch the suite stay green. Two
  correct patterns can be blind in the same direction; these two were, and the
  direction was *minimum*.
- **A reader that compares one half of a bound must say which half it read.**
  The loop here compared the maximum **unconditionally**, which is why a
  minimum-only shape could not simply be added to the reader: it had to be
  made to compare each half only when the sentence stated it.
- **A guard whose subject is a number has to name the constant.** Not one of
  `FULL_TURN`, `MIN_STRAIGHTS`, `MIN_TURNS` was named anywhere in `tests/`.
  A constant no test names is a constant the prompt can contradict.
- **Count the doors before fixing one.** The full turn was stated in the
  prompt three times and in a player-facing refusal a fourth. TRAPS 11.
- **A change detector is not a truth check.** Say which one a guard is.
- **When a sweep points you at a file, read the file.** 068's live finding was
  not caught by any pattern or sweep: it was two words in a sentence eleven
  lines from a constant 068 was already editing.
- **"Nothing reads this" is a claim, and a grep is not the measurement.** A
  suite that builds its needle from a function does not contain the string.
  Run the suite against the change before writing that sentence down.
- A reader with **no live subject** — the minimum-only pattern matches nothing
  in today's prompt, because `Readback.list_rule()` never writes that shape —
  is a check that cannot fail (TRAPS 6). It is held by a pair of negative
  controls instead: the same wording with the **wrong** floor fails naming the
  number, and with the **right** floor passes.

Found in 068, taking the regex-breadth half of 042's question that 067 left:
*for every sweep in `tests/`, what is the sweep blind to?*

> A suite that reads a claim through a pattern holds the claims that pattern
> can spell. The project will state the next one in the other direction.

---

## 66. A list in a document taken as the class it was a reading of

**Signature:** a handover entry names the members of a fault class with line
numbers, the next session fixes exactly those, and the member that costs a
player the most is not among them.

**Cause:** 068 found that `FeasibilityGate`'s floor refusal said *"corners"*
for a count of `TrackGeometry.YAW_TYPES`, fixed it, and wrote the rest of the
class into HANDOVER as *"three player-facing sentences say corner where the
code means a TURN"* — `feasibility_gate.gd:100`, `racing_module.gd:176`,
`racing_module.gd:584` — and called the remaining work *"three words and a
full run"*.

It was **five sentences in three files**. Grepping `corner` across
`scripts/` rather than opening the three files named found:

- `racing_module.gd:566`, the `SOLVER CHANGE` **panel row**, reading the same
  `max_angle_adjustment` over the same `YAW_TYPES`. All three on the list are
  reached only by a **refusal**; this one is shown on every circuit that was
  **built**, so it is the member of the class a player actually meets.
- `main.gd:845`, *"tightest corner"* for `minimum_radius`, which
  `TrackMetrics` takes over `TrackGeometry.CURVED_TYPES` — corner, hairpin,
  banked_corner, chicane and loop_segment. The same fault over a **wider set**,
  and the one reading of three that had drifted: `racing_module.gd`'s
  `TIGHTEST RADIUS` row and `experiment_runner.gd`'s *"tightest radius"*
  already named that number correctly.

TRAPS 31 already says a list in a document is a reading and not the class.
068 wrote that sentence into its own commit message and then left a list of
three to be taken as the class — which is TRAPS 11's shape applied to the
handover instead of to the code.

**Do:** when a previous session hands over a fault class **with line
numbers**, treat the line numbers as where to start reading and never as the
membership. Re-derive the class from the code — grep the word, then ask of
each hit which set the number beside it is taken over — before fixing any of
the ones named. Where the same quantity is stated in several places, the
places that agree are evidence about the one that does not: three readings
of `minimum_radius` and one of them worded differently is the drifted one,
and nothing but reading all three says which.

And the general rule the class produced, which is worth more than the five
fixes: **a player-facing sentence that names a section type is making a claim
about which sections the number beside it was taken over, and it is true only
if the noun names that whole set.** The solver's angle adjustment is taken
over `YAW_TYPES`, so its noun is *turn*. The tightest radius is taken over
`CURVED_TYPES`, so its noun is *radius* and no type at all.

> A handover that names three members of a class has described three members
> of a class. The next session owes the class a grep, not a patch.

---
## 67. Two patterns named as one, and the widening that would have flagged a true sentence

**Signature:** a handover entry names a sweep's regex and hands it to the next
session as the thing to widen. There are two sweeps, the entry quotes the
wider one's pattern for both, and the narrower one is blind to a whole
spelling. Then the widening the entry asks for turns out to match sentences
that are correct.

**Cause.** 068 opened the regex-breadth axis and 069 handed on three
candidates. The first was written like this: *"`container_door_test`'s and
`counted_said_test`'s `\b1 [a-z_]+s\b` cannot see a plural that does not end
in `s`"*. Two suites, one pattern quoted. Measured in Godot before anything
was touched:

| suite | pattern | `1 dead_ends` |
|---|---|---|
| `container_door_test` | `\b1 [a-z]+s\b` | **BLIND** |
| `counted_said_test` | `\b1 [a-z_]+s\b` | CAUGHT |

The entry quoted the wider pattern for both. `dead_ends` is a key of the very
metrics dictionary `container_door_test`'s sweep runs over, and
`banked_corner` and `loop_segment` reach a panel through
`RacingModule._counted()` whenever the validator accepts a type the prompt
does not offer — which it does, because `SectionValidator` accepts ten types
and `OFFERED_TYPES` holds four.

**And the widening the entry asked for was measured instead of adopted.** To
see `1 saved worlds` — the one spelling of this fault the project has
actually shipped, inline in `Main._list_worlds()`, per `world_store.gd`'s own
comment — the pattern has to allow a space. `\b1 [a-z_]+(?: [a-z_]+)*s\b`
does, and it also matches:

```
1 of them changes to the last world
1 readback that bears on it
```

**Both of those are CORRECT.** The word agreeing with the count is a **verb**,
and at a count of one the singular verb is right. Widening the pattern would
have made the net report two true sentences as faults.

**The false-positive control is what found the live fault.** The second of
those two reads its verb from `Readback.agrees()`. The first decided it by
hand and got it wrong — `session_report.gd:242`, measured by producing the
line at four counts:

```
edits=0  ->  Worlds built: 1 (0 of them changes to the last world).
edits=1  ->  Worlds built: 2 (1 of them changes to the last world).
edits=2  ->  Worlds built: 3 (2 of them changes to the last world).
edits=3  ->  Worlds built: 4 (3 of them changes to the last world).
```

Correct at **one of four**, and the count it is correct at is the one the
comment fourteen lines above it was written about: *"042: the count and the
noun after it are one fact, read from `Readback.plural()` and never written
out again"*. The file states the rule and then breaks it (TRAPS 22's shape),
and `docs/HANDOVER.md` quoted the wrong form as real output.

**The class was nine sites and not one.** Every place that decides *is this
count one* by hand: a plural written at the other end of the noun
(`race_director.gd:106`, `"" if count == 1 else "s"`), a pronoun
(`session_report.gd:291`, `"it"`/`"them"`), a bound's plural beside a constant
(`feasibility_gate.gd:83`, `ai_interpreter.gd:542` and `548`,
`dungeon_module.gd:537`), and **the AI prompt itself** — `racing_module.gd:76`
read its two floors from the constants that enforce them in 068 and left the
plural beside them written out, which is TRAPS 11 inside 068's own fix. All
nine now read `Readback.agrees()` or `Readback.plural()`. Eight produce
byte-identical text and the ninth is the fault.

**And the guard built for it had the same shape of hole, found by the
deliberate faults and not by reading it.** The scan that sweeps `scripts/` for
a hardcoded `%d <plural>` derives its needles from the nouns handed to
`Readback.plural()`. Reverting `dungeon_module.gd`'s ring budget **PASSED**:
that site was the only call in the project passing `"ring"`, so the revert
deleted the fault and the needle that catches it in one edit. **A scan whose
class is derived from the code it is checking is blind to exactly the change
that shrinks the class.** Held instead by a per-site table that names the
reader each site routes through, with the table's weakness stated in it: it
says a sentence is *built* from the reader, not that its word was watched
changing with its count.

**Do:**

- **When a handover quotes a pattern, open every file it names and read the
  pattern there.** Two suites sweeping "the same" thing are two patterns until
  measured. TRAPS 66 said to re-derive a class with line numbers from the
  code; this is the same rule for a class given as a regex.
- **Before widening a pattern, feed the widened version the sentences the
  project already says.** A net that flags a true sentence is worse than a net
  with a hole, because the hole is quiet and the false positive gets the
  assertion deleted.
- **Run the false-positive controls even when the change is a widening you are
  not going to make.** The widening here was rejected, and the controls it
  needed are what found the fault.
- **A count agrees with nouns, verbs and pronouns alike.** 042 put the noun
  behind one reader and swept for nouns. The same single fact — `count == 1` —
  was being decided by hand at a verb and a pronoun, and no sweep for nouns
  can see either.
- **A guard that derives its subject from the code cannot see the code
  shrinking.** Ask of every derived enumeration what happens when the last
  member is deleted, and feed it that deletion.
- **Routing a prompt's plural through the reader does not move the
  fingerprint.** `PROMPT_FINGERPRINT` is the sha256 of the *assembled* prompt,
  so a change that leaves the text byte-identical leaves `PROMPT_VERSION`
  where it is — asserted by `prompt_bounds_test`, which stayed green, not
  claimed. The converse is the warning: it also cannot see this fault, and
  reverting the prompt's plural passes it.

Found in 070, continuing the regex-breadth axis 068 opened at the first of
the three candidates 069 handed on.

> The entry said the pattern could not see a plural without an `s`. It could
> not see a plural with a space either, and the sentence it would have had to
> flag to see one was true.

---

## 68. Every name the fixtures had ever supplied was one word and a number

**Signature:** a suite exists to hold the rule "an article never stands in
front of a numbered name", enumerates the rule's two readers, sweeps every
sentence it produced in both directions, carries 112 assertions — and a
one-character change to the function it is about leaves it green.

**Cause:** `Readback.is_label()` is the one reading of what a label is:

```gdscript
var words := name.replace("_", " ").strip_edges().split(" ", false)
if words.size() < 2:
	return false
return str(words[words.size() - 1]).is_valid_int()
```

Nothing in it says how many words come before the number, and nothing should:
`great hall 2` is as much a label as `room 2`. But **every name any fixture
had ever handed it had exactly one** — `room 2`, `room_2`, `chamber 3`,
`level 2`, `key 2` in `said_article_test`, the same four in `log_022_test`.
So narrowing the function to `words.size() != 2` — one character — left
**all 71 suites green and the `--all` output byte-identical to the
baseline** (md5 `f9b0d8cf50968a31a41d42023deab0ef` both ways), while:

```
the("great_hall_2")        ->  "the great hall 2"
article("great hall 2")    ->  "a great hall 2"
dungeon readback           ->  "entered through a 12 m great hall 2 ...
                                with a spare key 2 in the great hall 2"
```

Three articles on numbered names in one sentence a player reads.

**It is reachable, which is the part that had to be checked rather than
assumed.** `DungeonModule.validate()` lowercases and trims whatever the model
sent for a room's name and stores it with **no shape constraint at all**, so
a room called `great hall 2` — real spaces — comes back `ok=true,
errors=[]` and is rendered verbatim. Both spellings reach a player.

**And the widening the handover asked for was the wrong fix.** The entry said
the sweep's `\b([Tt]he|[Aa]n?) ([a-z_]+) ([0-9]+)\b` "cannot see an article in
front of a two-word numbered label" and asked for it to be widened. The
comment sitting on that pattern had already measured the widening and
rejected it: with two words allowed it matches *"a track needs 2 to 40
sections"*, and the `is_label()` guard behind it **cannot rule that out**,
because `is_label("track needs 2")` is `true`. **A regex over free text
cannot tell a name from a verb**, so no breadth makes it the right
instrument — the second time running that an entry on this axis asked for a
widening that would have flagged a true sentence (TRAPS 67).

**Nothing in `scripts/` was wrong.** Every sentence family in the class was
fed a multi-word numbered name before anything was touched and every one was
already correct, because every one already reads `the()` or `article()`. The
fault was not present; it was **unpreventable**.

**Do:**

- Ask of every fixture list: **which member of the class has it never
  supplied?** Not which value — which *shape*. A list of five names that are
  all one word and a number is a list of one case written five times.
- When a guard's class comes from a pattern, the pattern is a **guess about
  what the subject looks like**. Move the guard onto the subject the suite
  actually has — here, the names the fixtures used — and the guess goes away.
  TRAPS 59, one layer in.
- **The same assertion in two suites is two sites of one fault** (TRAPS 11).
  Grep for the function before fixing the suite you are reading.
- A containment check is load-bearing the moment a multi-word name enters a
  fixture: `great hall 2` contains `hall`, so a per-name sweep reports the
  shorter name bare in a sentence that is correct. Do it **per occurrence**,
  not per line — a sentence with both `the hall` and `great hall 2` must still
  fail on the first. Measured both ways: disabled, 32 false positives;
  enabled, all four genuinely bare names still named.
- **An assertion typed in as a judgement about English is not a fact.** This
  commit's own first draft asserted `"room 2 of 5"` was not a label; it ends
  in a number, so `is_label()` says it is, and the suite caught the fixture
  rather than the code (TRAPS 6, from the other side).

Found in 071, taking the second of the three candidates 068 listed and 070
narrowed to two.

> The suite asked its question of five names and they were the same name
> five times. The function was right; nothing could have told us if it
> stopped being right.

---

## 69. A bound lookup that answers "no bound" and "I could not read it" the same way

**Signature:** a suite exists to check that every bound the prompt states is a
bound the validator accepts. It loops over the fields, looks each one's bound
up in the prompt text, and `continue`s when the pattern does not match. Reword
one bound out of the pattern's shape and the suite does not fail, does not
warn, and prints nothing: the assertions that would have checked it **cease to
exist**.

**Cause.** `claim_field_test.gd`:

```gdscript
var bound := _stated_bound(tool_mod.prompt_section(), field)
if bound.is_empty():
	continue
```

`_stated_bound` returns `[]` for a field with no bound **and** for a bound it
could not parse. The loop cannot tell those apart, so the second is treated as
the first — silently, because there is nothing to print about a field that
legitimately has no bound. Six of the fifteen tool fields are text and
genuinely have none, which is exactly what made the silence look normal.

**Measured rather than argued.** With `brake: %.0f to %.0f newtons` reworded
to `brake: between %.0f and %.0f newtons` and the pre-072 suite restored in
its own throwaway copy, the suite reported **`failures=0`**, and the PASS list
lost four lines (diffed, not eyeballed):

```
- PASS  EQUIP boots: the stated bound 150.0 for 'brake' is accepted
- PASS  EQUIP boots: the stated bound 1200.0 for 'brake' is accepted
- PASS  boots 'brake' at 1200.0 validates, so the claim can be measured
- PASS  "stop on a sixpence" promises nothing else, and 'brake' at 1200.0
        changes 1 of the 2 things boots measure
```

The fourth is **the measurement of the claim the suite was written for** —
038's *"stop on a sixpence"*. A green suite with its headline assertion
deleted.

**And the enumeration was narrower than the class.** Sweeping the sections for
*every* range instead of asking per field found **ten statements across the
three tools, and only nine hang off a field.** The tenth is
`BootsTool.TOP_SPEED` — *"It must come to 2 to 12 metres a second"* — a bound
stated to the model and enforced in `validate()`, which **no loop over
`defaults().keys()` can reach, because top speed is not a field.** A grep of
`tests/` for `TOP_SPEED` returns one hit and it is a comment.

**And the widening the handover asked for had no subject at all.** The entry
said the pattern could not see a bound written with a dash or as *"between N
and M"*. Measured first: **all nine numeric fields state their bound as
`field: N to M`**, and the prompt contains no dash bound and no *"between"*.
The third commit running on this axis where the widening was not the fix
(TRAPS 67, TRAPS 68).

**Do:**

- **A reader that returns the same empty answer for "absent" and "unparsed"
  must not be driven by a loop that skips on empty.** Decide which of the two
  it is from something other than the reader — here, the *type* of the field's
  default — and fail on the one that should not happen.
- **Sweep the subject for every claim it makes; do not ask the code which
  claims it expects to find.** A per-member lookup can only find claims
  attached to a member it already knows about. The ten-versus-nine gap was
  invisible from the field list and obvious from the text.
- **Require every claim found to be accounted for.** The useful assertion is
  not "this field's bound is right" but "every bound in this section is one I
  have read". An unaccounted claim then fails instead of passing in silence,
  and a hand-written exception table becomes safe: it cannot grow stale
  quietly, because a new member fails until it is added.
- **"At least one was measured" is the same trap one loop along.** It is
  satisfied by any member, so the member that drops out is the one you never
  hear about. Count the members you could measure and assert the count.
- **A derived bound needs a check a field bound does not: that its ends are
  REACHABLE.** Narrowing a field's range can put an end of a derived bound out
  of reach while every constant sits exactly where it was, and the player is
  then told about a bound they cannot have. Solve for the values that reach
  it; never type them in.
- **Before widening a pattern, check the widening has a subject.** Three
  entries on this axis in a row asked for breadth, and all three times the
  spelling they named was one the project does not produce while the real hole
  was a layer behind the pattern.

Found in 072, taking the last of the three candidates 069 handed on, which
closes the axis.

> The suite could not tell a field that had no bound from a bound it could
> not read, so the day the bound changed shape it quietly stopped asking.

---

## 70. Ninety-two numbers in a prompt, and a class too big to check one at a time

**Signature:** a class of claims is measured, found to be large, and left open
because the obvious guard would be a table of judgements. The entry sits in
the handover for five commits. Meanwhile the one property that decides which
members *can* be wrong goes unasked, and it is cheap.

**Cause.** 068 counted the numerals in `AIInterpreter.assembled_prompt()` by
script: **92, 41 of them distinct.** It closed four by reading the prompt line
by line against the code and wrote the rest up honestly — *"a good part of the
41 are worked examples and ordinary prose, so the declared half would be a
table of judgements that can go stale"* — then left it. 069 through 072 each
took a narrower axis instead. The entry was still open at 073.

The question 068 asked was **"is this number the constant's number?"**, and it
is the expensive one: it needs a reader per number and a judgement about what
each number means. The question one layer behind it is nearly free:

> was this number **TYPED** into the prompt, or **PRODUCED** by the code?

A number that arrives through a `%`-substitution is the same expression the
prompt is built from, so **it cannot drift from the thing that produced it**. A
number typed into the template can drift from anything. Of the 92, **74 are
substituted and 18 are typed** — so seventy-four of them never needed a
judgement at all, and the table of judgements is eighteen rows and not
forty-one.

**And the fault the distinction is named after is 068's own.** The composition
floors were typed out beside the constants that enforce them, and a prompt
reading *"at least 7 straights and at least 9 corners or hairpins"* — four
times narrower than the truth, with `PROMPT_FINGERPRINT` moved the way a real
prompt edit moves it — passed all 69 suites. That is TRAPS 28's shape, and
035's farm bound before it. The recurring fault in this project's prompt is
**a number typed beside the constant that enforces it.**

**Measured rather than argued.** `tests/prompt_numeral_test.gd` was written to
ask the typed/produced question of the class, and the fault that justifies it
is the one no existing reader can see: *"A circuit may use at most 3
chicanes"* added to the racing section — a limit stated to the model that
nothing enforces. With the fingerprint moved, **`prompt_bounds_test` reports
`failures=0` and `claim_field_test` reports `failures=0`**, and the new file
fails naming the numeral and the line it is typed on. `prompt_bounds_test`
reads counts of a *declared list's members* and the field ranges it names; a
number with no list noun beside it is outside both.

**Do:**

- **When a class is too big to check member by member, ask what makes a member
  capable of being wrong, and check for that property instead.** Here it split
  92 claims into 74 that cannot drift and 18 that can. The expensive question
  only has to be asked of the 18.
- **Answer "where did this number come from?" from the SOURCE, not the
  sentence.** The rendered prompt cannot tell you; the template can, and the
  answer does not move when the prose around the number is rewritten. Four
  prompt sentences reworded with their numbers untouched left the new suite
  green at the same assertion count (TRAPS 6).
- **Prove the scan is reading the right text.** A scan keyed on how the prompt
  happens to be written is TRAPS 59 waiting to happen: the project will find
  another way to write it. Each template is split on its format specifiers and
  every literal fragment required to appear in the rendered section **in
  order**, so a section rebuilt by concatenation fails instead of being
  skipped — measured, with `look_tool`'s template turned into `+` joins:
  **1 failure here, `prompt_bounds_test` green.**
- **Close the enumeration at both ends.** Every file in `scripts/` holding a
  template must be one of the contributors the registries name, and every
  contributor must hold exactly one. A stray template in `readback.gd` fails
  by name. Without that half the scan could only see the files it already knew
  (TRAPS 69).
- **Declare with a COUNT, not with a name.** A numeral declared as prose would
  otherwise launder a bound typed as *"at most 3 doors"* into a file where `3`
  is already declared. The count is asserted in both directions, so a
  declaration that has gone stale fails the day it does — the opposite of a
  count in a comment (TRAPS 24).
- **Where a typed number states a fact, assert the FACT and not the number.**
  The seven typed `1`s promise "numbered from 1"; they are held by handing the
  validators a door `[0, 1]`, a thing in room `0`, and a dungeon whose doors
  avoid room 1. Widening `if a < 1` to `if a < 0` in `dungeon_module.gd` fails
  there. A declaration that only says *"ordinal"* would not have moved.

Found in 073, by reading the entry 068 left rather than the axis 072 closed.
**There was no live fault: all 18 typed numbers were already true.** What
changed is that a nineteenth cannot arrive unexamined, which is the only thing
that would have caught 068 at the commit that wrote it.

> A number the code produces cannot disagree with the code. Only a number
> somebody typed can, so ask which kind it is before asking what it means.

---

## 71. The kind filed under the value, and the count asserted against its own array

**Signature:** a table classifies things and the suite over it is green, but
the classification itself is never asserted — only the thing it hangs off. Or
an assertion reads a literal declared a few lines above it, and its *message*
claims a measurement it never took. Deleting the measured thing leaves the
line green and still claiming it happened.

**Cause, first half.** 073 built `tests/prompt_numeral_test.gd` to ask of
every numeral typed into the prompt: which file, how many times, and **what
kind of number is it** — `BOUND`, `ORDINAL`, `ARITHMETIC` or `PROSE`. The row
was keyed on `(file, numeral)`:

```
"npc_goals.gd": [["1", 3, "ORDINAL"], ...]
```

`npc_goals` types `1` three times. Twice it is the promise that rooms are
numbered from 1 — *"its number counting from 1"* — and once it is the `1`
inside **`room_1`**, a room *name* in the worked example whose entire purpose
is that a name carrying a number is not a position. **The kind belongs to the
occurrence and the key was the value**, so all three went under `ORDINAL`, the
one kind the file measures against the validators. Nothing failed, because
what the suite asserted was the count of the numeral and never the kind of the
occurrence.

**And the file's own prose had it right.** Its header listed the prose
numerals as *"'go to room 2', 'to room 3', and the example's own room_1,
room_2 and its four room_3s"* — eight, with `room_1` among them — and summed
the eighteen as *"one BOUND, two ARITHMETIC, seven ORDINAL and eight PROSE"*.
The table it sat on said **eight ORDINAL and seven PROSE**. 073's own commit
message counted it correctly and said so. The transposition went into the
table, the header, and `HANDOVER.md`, and nothing could catch it because
**the four per-kind totals were a count in a comment** — TRAPS 24's shape in
the file whose header claims to have avoided it. It had avoided it per *row*
and not per *kind*.

**Cause, second half, and it is the same fault with no table at all.**
`tests/refusal_reach_test.gd` ended its guard section with:

```
_check(LAYOUT_BRANCHES.size() == 3, "all three FAILED_LAYOUT branches were fired")
_check(SHARED_WITH_CONTROLLER.size() == 1,
    "and one category name has an owner outside the module pipeline")
```

Both bodies read the length of an array literal declared forty lines above
them. Both messages claim a fact about the run. **Measured:** with branch 3's
block deleted outright, the pre-074 suite reported **98 assertions,
failures=0** — the branch was gone and the suite still counted a passing line
saying all three fired. With `FAILED_UNWALKABLE` renamed in
`game_controller.gd` so the shared name no longer *has* an owner outside the
module pipeline, the pre-074 suite reported **1 failure** — the enumeration's,
not that line's — and the sentence about the owner outside the pipeline passed
while being false.

`controller_reach_test`'s `BRANCHES.size() == 28` is the same shape and is
**not** this trap, because its message claims only what it checks — *"28
controller refusal branches declared"* — and the three assertions under it do
the real work against the source. That is the difference: a guard that says it
is a guard, versus a guard wearing a measurement's words.

**Do:**

- **Key the row on the occurrence when the property belongs to the
  occurrence.** A numeral may now appear on several rows with several kinds,
  and the rows' counts must **sum** to what is typed. Collapsing them was what
  hid `room_1`.
- **Assert the classification, not just the thing classified.** Each kind's
  claim is now checkable: an `ORDINAL` numeral must be the `1` that *"numbered
  from 1"* is about, and no `BOUND`, `ORDINAL` or `ARITHMETIC` occurrence may
  be **welded into an identifier** — the `1` in `room_1` states nothing the
  code can enforce and cannot drift, so it is prose by construction. Restoring
  073's row fails **3** times, the first naming the fault exactly; the same
  fault with the totals edited to agree still fails **2**, so the bare check is
  not a restatement of the totals.
- **Derive a total from the table and assert it.** The four per-kind totals and
  the typed total are read off the rows now. A ninth prose numeral added to the
  prompt *and duly declared on its row* fails **2** times — which is what the
  header's claim *"a ninth cannot appear without this file being edited"*
  needed in order to be true of a number rather than of a sentence.
- **An assertion's message must claim only what its body read.** The branch
  lines now record each branch where it actually fires and assert the fired set
  against the declared one, both directions: deleting a branch fails **2**,
  and a fourth undeclared branch firing fails **2**. The shared-name line now
  reads the source for an owner inside the module pipeline and one outside it.
- **When you cannot measure the fact, say which fact you did measure.** Branch
  2's refusal is read at `FarmModule._check_reachable` and not through
  `solve()`, because `solve()` lays the zones out itself and throws the pinched
  positions away — **measured in 074: `solve({"zones": pinched})` returns
  `ok=true`.** The branch is real and its refusal is measured; that a player
  can reach it is **not** claimed, and `farm_module.gd`'s own comment already
  says so.

Found in 074, by tallying the table 073 wrote rather than reading the sentence
above it. **No file in `scripts/` or `scenes/` was wrong and neither changed.**
The prompt is byte-identical; what changed is one misfiled row in a test table
and two assertions that claimed more than they read.

> A count that sits next to the thing it counts is a comment. Derive it, or
> expect it to be transposed. And an assertion may only say what its body read.

---

## 72. A suite that measured the behaviour and never asked whether the prompt still said it

**Signature:** a suite exists to hold *"the arithmetic the prompt states is
the arithmetic Genesis does"*. Delete one of those statements from the prompt
outright and the suite passes, still printing a PASS line that quotes it.

**Cause.** `tests/formula_test.gd` has two halves and only one of them reads
the prompt. The tool half enumerates its claim from the prompt, parses it as
arithmetic, and asserts the count it found — so a reworded or added tool
formula fails. **Sections 3 to 8 do none of that.** Each quotes a racing rule
in a comment and measures the behaviour behind it against `TrackGeometry`,
`FeasibilityGate` or `SectionValidator`. The sentence is read from nothing.
That is TRAPS 24 one layer along: the body removed and the success string left
behind — except here the body is in `scripts/` and the success string is in
`tests/`, so no sweep of either file alone could see it.

**Measured rather than argued.** Eight deliberate faults, each deleting one
rule from `racing_module.gd`'s template in its own throwaway copy with its own
`config/name` (TRAPS 50), with `PROMPT_FINGERPRINT` moved the way a real
prompt edit moves it, the full suite run each time. **Seven of the eight
passed** — 70 suites, 0 with something to look at, the rule gone from the
prompt:

```
"Sections join end to end ... arrive back at the start line"      0
"A chicane steps the track sideways by O metres ..."              0
"... carries the track back only by its own width, twice ..."     0
"Chicanes do not count."                                          0
"Angles are signed: positive turns right, negative turns left."   0
"Never give a corner, hairpin or chicane a length ..."            0
"The road must never cross itself, and"                           0
"O is more than 0 and at most 2 x R"         prompt_numeral_test: 3
```

**And the one that was held is the one carrying typed numbers, which is the
general shape.** The racing rules are held where they state a NUMBER — by
`prompt_bounds_test` and `prompt_numeral_test`, which read numbers — and held
by nothing where they are PROSE. It is 073's and 074's finding about the
prompt's own numerals seen from the other side: the numbers acquired readers
and the sentences around them never did. A rule with no number in it had no
owner at all.

**Do:**

- **Measuring the behaviour behind a claim is half the claim.** The other half
  is that the claim is still being made. A suite that holds only the first
  half goes on passing after the sentence leaves, and its PASS lines quote the
  sentence, so the next session reads them as evidence it is still there.
- **Enumerate the claims from the subject, structurally.** Read the rule units
  off the RENDERED section — a type declaration, a sentence in the types block
  about all of them, a `- ` bullet under the rules heading — keyed on the JSON
  and the bullet mark, never on English. Then every unit must be claimed by a
  row, so a rule ADDED fails until somebody classifies it, and every row must
  find its unit, so a row gone stale fails rather than passing. Both
  directions, each read off its own array (TRAPS 71).
- **A pointer is not a measurement, and should say so.** A row naming another
  suite asserts that the rule is still stated and that the named suite's
  **code** names the constant the rule is about, read through `_code_of()` so
  a comment cannot answer for it (TRAPS 63). It does not watch that suite
  measure anything, and the header says as much.
- **A needle is wording, and for a prose claim it is the only check there is.**
  A rule reworded while staying true fails here and the row has to be updated.
  That is the right way round: a rule changing shape should stop a session and
  make it re-read. The seven faults above did not stop anything.
- **Writing "measured rather than read" in a header is not a mitigation.**
  039's header said exactly that, honestly, about the half that had no reader
  — and the gap sat there for 36 commits because the sentence described the
  method instead of naming the consequence.

**And the count in the same header was wrong on the day it was written.** It
said *"the other FIVE arithmetic claims"* and listed five, while section 8 of
the same commit measured a sixth. TRAPS 24's shape again, inside the file
whose own fault is a comment standing in for a reader.

Found in 075, taking the live axis's own method — *what has the subject never
supplied?* — and finding that the question one layer behind it was better:
*what has the subject supplied that nothing reads?*

> The suite proved Genesis does the arithmetic and never once asked whether
> Genesis still says it. Seven rules could have left the prompt in silence.

---

## 73. An assertion deleted from a suite that went on printing failures=0

**Signature:** a suite's result line is identical before and after one of its
assertions is removed. The suite passes, the runner's "suites with something to
look at" stays 0, and nothing in the run output has moved. The loss is visible
only in a diff of the full PASS list against a recorded md5.

**Cause.** A result line that reports only how many assertions FAILED cannot
report that one stopped running. `failures=0` is the same string whether a
suite made ninety assertions or none, and **55 of the 72 suites printed
nothing else.** Every commit from 072 on had to work around it: 072's fault was
found by diffing the PASS list and seeing four lines gone, and 073, 074 and 075
each had to diff full output against a recorded md5 to be sure nothing had
silently stopped asserting. 075 gave `formula_test` a count for exactly that
reason — because its change could not otherwise be verified from the result
lists at all — and said plainly in its own "Next action" that fixing one
member of a list is TRAPS 11 and that it had done it.

**Measured rather than argued.** Eleven deliberate deletions, each in its own
throwaway copy of the project with its own `config/name` (TRAPS 50), the suite
run after each. **All eleven stayed `failures=0` and exited 0**, and in every
one the assertion count was the only thing that moved:

```
look_test        one _check call deleted                18 -> 17   failures=0
carry_test       one _check call deleted                21 -> 20   failures=0
session_test     one _check call deleted                18 -> 17   failures=0
judge_test       one row deleted from the case table    21 -> 20   failures=0
report_test      one _eq row deleted                    28 -> 27   failures=0
report_test      one direct if-block deleted            28 -> 27   failures=0
said_fields_test the circuit-whole row deleted         127 -> 126  failures=0
said_fields_test one unmeasured section cut from table 127 -> 126  failures=0
plan_said_test   one _differs row deleted               50 -> 49   failures=0
walk_test        the walls control deleted              11 -> 10   failures=0
tool_test        ONE condition deleted from a loop      21 -> 15   failures=0
```

The last row is the one worth reading twice: **one condition removed from a
six-case loop cost six assertions**, and the suite reported `failures=0` both
times. Nothing short of the count would have said so.

**Do:**

- **A result line states how many assertions RAN, not only how many failed.**
  Both numbers, on the line the runner prints, so a vanished assertion is
  visible in the run output and not only in a diff against a remembered md5.
- **Apply it to every suite, including the ones written tomorrow (TRAPS 11).**
  One suite given a count because that commit happened to need it is not a
  fix; it is a member of a list. 076 did the remaining 55 in one commit
  precisely so the result lines reset once rather than twice.
- **Count the assertion, not the printed line.** A completeness guard that
  passes silently is still an assertion and still counts; a summary line like
  `if bad == 0: print("PASS ...")` is not one and must not. So the count will
  not always equal the number of PASS/FAIL lines, and a suite's header should
  not claim it does.
- **Count at each site that decides pass or fail, so the count is
  path-correct.** A condition inside a loop costs one per iteration, which is
  what made the `tool_test` row above read 21 -> 15 instead of 21 -> 20.
- **Verify a reformatting of the result lines by stripping and diffing, never
  by reading them.** Strip the inserted counts from the after-run output and
  diff against the baseline: it must come back byte-identical. That is the only
  check that distinguishes "the lines all changed because a count was added"
  from "the lines all changed and one verdict moved too".
- **And check that a real failure still gets through the new format.** A change
  to a result line can break the runner's own pass/fail matching, and a green
  run is exactly what that failure looks like. 076 made one `_check` fail on
  purpose and confirmed the runner still reported "suites with something to
  look at: 1" and exited 1. A rewritten early-exit line that had never run was
  made to run, too.
- **A count is not a score.** 529 assertions is not a better suite than 2.
  Nothing about this line should be read as inviting anybody to raise a number.

**And what it does NOT do, said here so the next session does not over-read
it.** Nothing asserts the counts. No suite checks that a result line carries
one, nor that a suite's `asserted` still tracks its assertions. The 71 counts
rest on a per-file reading and on the eleven deletions above, which covered 8
suites of 71. A suite added without a count would be caught by nobody — which
is how this class reached 55 members in the first place.

Found in 076, taking the entry 075 wrote and deliberately left open, and
naming as its own.

> Fifty-five suites could forget an assertion and go on saying failures=0.
> The green was true and it was not the whole truth.

---
## 74. The class was counted in suites, and the fault was in result lines

**Signature:** a class is closed, the commit that closed it says so in detail
and names what it did not do — and the thing it enumerated was one unit larger
than the thing with the fault in it. Every suite has a count; two result lines
still do not. Nothing fails, because the survivors are on paths that do not
run.

**Cause.** 076 fixed TRAPS 73 by walking `tests/` and giving each **suite** an
assertion count. That is the natural unit — one file, one result line — and it
is wrong for three files. A suite that gives up before its body runs prints
its own result line from the early exit, and 076 touched one of those
(`report_test`, which it rewrote and said so) without asking how many there
were. There were three. The two it did not touch were:

```
look_test.gd:32        "LOOK TEST failures=%d"    the picture it could not write
load_check_test.gd:62  "LOAD CHECK failures=%d"   the dungeon it could not measure
```

Both are unreachable on a healthy tree, which is why no run has ever printed
them and why no diff of any PASS list could ever have caught them. **A member
of a class on a path that does not run is still a member**, and the only
reader that can see it is one that reads the code rather than the output.

**And the second one was worse than a missing count.** `_measure()` has two
ways out that return `{}`. One calls `_check(false, ...)` first, so `bad` is 1
and the line read `failures=1`. The other — `measure()` returning nothing at
all — recorded nothing, so the line read **`LOAD CHECK failures=0`** and the
suite called `quit(1)`. `run_tests.sh` reads the **line**, not the exit code.
A load check that had measured nothing whatsoever would have been counted as a
pass. That is missing evidence becoming success, which `PROTOCOL.md` names by
name.

**And the other channel had quietly stopped being connected.** A suite reports
its result twice — the line it prints and the code it exits with. Measured
across every result line in `tests/` — 74 before the scan existed, 75 with its
own — **five suites ended `quit()` or `quit(0)`** below a
line reporting a variable number of failures. Measured rather than argued, in
a throwaway copy with one deliberate `_check(false, ...)` added:

```
layout_key_test, quit()      LAYOUT KEYS 65 assertions, failures=1   -> $? = 0
layout_key_test, quit(bad)   LAYOUT KEYS 65 assertions, failures=1   -> $? = 1
```

Neither runner reads the exit code (`run_tests.sh` uses it only to spot a
timeout, `run_tests.bat` not at all), so nothing was mis-reported in a full
run. What was true is that a person running one suite alone — which this
project's own runner tells you to do when something looks wrong — got `$? = 0`
on a failing suite.

**Do:**

- **Enumerate the class at the granularity of the thing with the fault, not
  the granularity of the file.** "Every suite has a count" and "every result
  line has a count" differ by three files and two faults. Before closing a
  class, write down the unit you counted and ask whether the fault lives in
  that unit or inside it.
- **A path that does not run is still in the class.** Its members cannot be
  found by diffing output against a recorded md5, because they have never
  appeared in any output. Only a reader of the code finds them.
- **A result line and an exit code are two reports of the same thing, and
  both are read by somebody.** Keep them agreeing: `quit(bad)`, not `quit()`.
- **Give a class a reader before declaring it closed.** 076 closed TRAPS 73 by
  hand, 71 files, carefully, and wrote down that nothing asserted the result.
  Eleven lines of scan found seven faults in it the same afternoon. The gap
  between "I did this correctly" and "something checks that it is still done"
  is where the next 55 members will come from.
- **Derive the exclusions, do not list them.** `tests/result_line_test.gd`
  does not carry a list of suites. It asks which files print a result line,
  and asserts that every `.gd` in `tests/` is either one of those or carries a
  row saying why not. A suite added tomorrow is in the class by arriving; a
  tool added tomorrow has to be accounted for. A hand-maintained list of 71
  would have gone stale the way the "Next action" entry in TRAPS 66 did.

Found in 077, reading the paragraph 076 wrote about what it had not done.

> The suites all had a count. The result lines did not, and the result line
> is the thing that gets read.

---

## 75. The count was the alarm, and zero was being read as a pass

**Signature:** every suite prints how many assertions it ran, and nothing
reads the number. A suite prints `0 assertions, failures=0` and the runner
counts it as a pass. Worse and quieter: a row that asserts an **absence**
turns green because the scan behind it read nothing, and the absence is then
quoted as a fact about what Genesis cannot do.

**Cause.** 077 closed the result-line class so that every line says how many
assertions **ran** as well as how many failed — the point being that a line
reporting only failures cannot report that an assertion stopped running. It
then wrote down the live gap: *"nothing holds that `asserted` is incremented
at every site that decides pass or fail."* Reading for that found something
one step earlier. **A count is only an alarm if somebody reads it, and the
loudest reading — zero — was being read as success.** `run_tests.sh` matches
`*failures=0` and `*bad=0` as a pass, so the cleanest-looking line a suite can
print is the line it prints when it measured nothing.

Eleven `DirAccess.open` sites in `tests/`, in nine files. **Measured, not
argued**: each suite was run in a throwaway project with its own `config/name`
(TRAPS 50) with its read pointed at a directory that **exists and is empty**.
Eight sites failed, between 1 and 37 failures apiece. Three did not:

```
loadcheck.gd              LOADCHECK 0 assertions, bad=0   exit 0
controller_reach_test.gd  120 assertions, failures=0      (two sites)
prompt_numeral_test.gd    116 assertions, failures=0      (one site)
```

`loadcheck.gd` is the whole fault in one line: a load check that had loaded
**nothing whatsoever** reported a pass in both channels. It was also the only
one of the eleven that never tested the open for null, and **until 078 it was
named in no document in this repository** — not `TRAPS.md`, not `HANDOVER.md`,
not either runner. **Nothing had ever read it.** This entry and the 078 section
are what changed that, so the sentence is past tense: the commit that found the
fault is the commit that made the claim false, and leaving it in the present
would be TRAPS 14 inside the entry warning about TRAPS 14. Neither runner names
it even now — both find it by globbing `tests/`. This is TRAPS 11 one filename away from
where 077 was working: 077 fixed exactly this fault in `load_check_test.gd`
and did not ask which other suites could pass having measured nothing.

**An empty directory is not a null directory, and a null check does not see
it.** `prompt_numeral_test` had `_check(dir != null, "scripts/ can be read")`
and still passed, because the directory it was handed opened fine and held
nothing.

**The two that PASSED are worse than the one that vanished.** An assertion
that stops running takes the count down with it, and the count is at least
visible to a person reading the list. An assertion that **passes vacuously**
reports a fact. `prompt_numeral_test`'s row says no file in `scripts/` holds a
stray prompt template. `controller_reach_test`'s says nothing in `scripts/`
appends to `corner_nodes` — **and that row is the premise for its claim that
two of the controller's refusal branches are out of a player's reach.** Both
rows are at their greenest when the scan has read the fewest files. The
comment above the second one says *"Grepped, not remembered"*, which is
exactly what it stops being when the grep reads nothing. TRAPS 6 and TRAPS 14
in one assertion: a test guarding an assumption, underwriting a published
claim about what Genesis cannot do.

**Do:**

- **A scan that reads a directory must assert that the read produced
  something.** Otherwise its cleanest result is the one it gives when it has
  looked at nothing. This is not a new rule — `record_id_test` already states
  it: *"at least one suite in `tests/` starts a session, so this section is
  measuring something"*. 078's work was applying it everywhere it holds.
- **Ask of every absence: how wide was the net, and is the width asserted?**
  An absence is worth exactly what the breadth behind it is worth. `X.is_empty()`
  and `strays.is_empty()` prove nothing on their own; pair every one of them
  with a floor on what was searched.
- **A null check is not a floor.** Null means "could not open". Empty means
  "opened and held nothing". The second is the one that passes.
- **Zero is a verdict, not a neutral value.** Any assertion count that can
  reach zero needs a line that turns zero into a failure. Grep your runner
  for what it accepts as a pass before trusting a result line.
- **When a commit fixes a fault, grep for the fault's own words, not its
  file.** 077 wrote *"a load check that had measured nothing whatsoever would
  have been counted as a pass"* and fixed `load_check_test.gd`. `loadcheck.gd`
  was one `ls` away.

Found in 078, reading 077's "Next action" entry for a drifted counter and
finding a zero nobody read.

> The suites all counted their assertions. Nothing asked what it meant when
> the count was none.

---

## 76. The comment that said no count was written in it, and the four counts in the same file

**Signature:** a comment states the size of a class the code **derives**, and
the number is wrong. The commit that notices corrects or strikes the one it is
looking at, writes the rule down in that very comment, and leaves the
siblings — including, in this case, a sentence claiming coverage of a list that
named twelve of fifteen members.

**Cause.** 077 struck a stale count out of `tests/source_scan_test.gd`'s
`KNOWN` comment and wrote the reason into the comment it was editing:

> NO COUNT IS WRITTEN IN THIS SENTENCE. It said "the nine members as of 067"
> while the list held ten, because 075 added formula_test and left the number
> ... a count in a comment beside the array it counts is TRAPS 24's shape and
> the array is right there to be read.

**The same file had four more, and two sibling members of the same class had
one each.** Measured in Godot 4.7.1 at `d42f7ae` before anything was changed —
the class `source_scan_test._class()` derives had **fifteen** members and
`KNOWN` named **twelve** (`PASS  15 files in tests/ read a .gd source out of
this repository (at least 12 expected)`), and `ls tests/*.gd` returned 76 files
and the runner reported 74 suites:

```
source_scan_test.gd  header      "Nine files do."                         15 members
source_scan_test.gd  _code_of    "A tenth suite that scans source ..."    15 members
source_scan_test.gd  section 1   "the nine KNOWN are each asserted"       12 rows
source_scan_test.gd  section 3   "the nine copies of that reader"         15 copies
source_scan_test.gd  section 3   "Nine suites with nine private copies"   15 copies
prompt_numeral_test  _code_of    "the copy in the nine other suites"      14 others
result_line_test     header      "the other ten scanners use"             14 others
result_line_test     header      "It cannot run 72 suites"                74 suites
HANDOVER.md  HDN 30             "now that ten suites carry ... copies"    15 copies
```

Section 3's was the sharpest: the assertion **two lines below it** already
printed `members.size()`, so the run said *"all 15 copies are byte-identical"*
directly underneath a comment that said nine.

**AND THE WORSE HALF IS NOT THE NUMBERS.** The sentence under section 1 read
*"a floor and not an equality, so a tenth scanner does not have to edit this
line — but the nine KNOWN are each asserted below, **so one LEAVING is
noticed**"*. That last clause is a claim about **every** member of the class
and it was true of twelve of fifteen: `agreement_test.gd`,
`prompt_numeral_test.gd` and `source_scan_test.gd` had no row, so each could
stop scanning source and no suite would say so. **Measured in both
directions** (079, each departure in a throwaway project with its own
`config/name`, TRAPS 50): on the tree before the rows, all three departures
scored `SOURCE SCAN 27 assertions, failures=0` — **silent**; with the rows
added, each scores `30 assertions, failures=2` and names itself. A stale count
in prose is an annoyance. A coverage claim that is two thirds true is the
thing the list exists to prevent.

**The right form already existed in this repository**, in
`tests/formula_test.gd` since 075: *"Byte-identical to the definition the
other members of this class carry"*. No number, nothing to go stale. Two of
its siblings were still naming a size.

**Do:**

- **A number in prose about a class the code DERIVES has a shelf life of one
  commit.** Write the phrase that reads the class — "every member of this
  class", "the other members" — not the count. Strike it rather than correct
  it; a corrected count is the next session's stale count.
- **When you strike one, grep the class for its siblings before writing down
  that you struck it.** Striking the instance and stating the general rule in
  the same comment is TRAPS 11 with the lesson already typed out above the
  fault.
- **A comment that claims a list covers a class is a claim to check against
  the class, not to read.** "So one LEAVING is noticed" cost nothing to
  verify: run the suite and compare the two numbers it already prints.
- **Nothing holds this one, and that is said rather than papered over.** A
  suite that forbade a number in a comment would be a test of wording
  (TRAPS 6), and a suite that asserted a particular count would be the trap
  itself in GDScript. What IS held is the fact underneath: `source_scan_test`
  derives its class and prints both sizes on every run, so the numbers are one
  `--script` away whenever a comment is in doubt.

Found in 079, doing the three rows 078 measured and left under "Next action".

> The comment explaining that no count was written in it had four counts in
> the same file, and the list it sat on top of named twelve of fifteen.

---

## 77. A guard keyed by FILE, holding a class whose members are SITES

**Signature:** a suite pins each member of a class with one needle per **file**
and asks `contains()`. Every file with two members has one of them held and
the rest unheld, and the suite reports a pass. The table that lists the class
and the dictionary that pins it were written in the same commit and already
disagreed.

**Cause.** 070 found a sentence that decided a count's agreeing word by hand
and got it wrong at three of four counts, stated the general rule — *a sentence
that states a count and a word that agrees with it must read that agreement
from `Readback.agrees()`* — and applied it at every site it found. Its own
message enumerated them: `session_report.gd:242, :248, :290, :291`,
`race_director.gd:106`, `ai_interpreter.gd:542` and `:548`,
`dungeon_module.gd:537`, `feasibility_gate.gd:83`, and `racing_module.gd:76`,
**the AI prompt** — which it called "TRAPS 11 inside 068's own fix".

Then it built the guard. Deliberate fault 5 had shown the hardcoded-plural
scan goes blind exactly where the fault lives: the needles are derived from
the nouns handed to `Readback.plural()` in `scripts/`, so reverting the only
call passing a given noun deletes the fault and the needle that catches it in
one edit. The answer was `READS_THE_READER`, described in its own comment as
*"a per-site table naming the reader each site routes through"*. **It was keyed
by file, with one needle each, asked with `contains()`** — and the files hold
between one and four sites apiece.

**Measured in 080**, Godot 4.7.1, each fault in a throwaway copy with its own
`config/name` (TRAPS 50), FAIL lines read, on a baseline byte-identical to the
md5 079 recorded:

```
ai_interpreter.gd  second HTTP sentence reverted alone   47 assertions, failures=0  SILENT
ai_interpreter.gd  first  HTTP sentence reverted alone   47 assertions, failures=0  SILENT
ai_interpreter.gd  BOTH reverted                        47 assertions, failures=1  caught
race_director.gd   the "lap" half, NAIVE revert         47 assertions, failures=0  SILENT
racing_module.gd   the PROMPT's two, hiding form        47 assertions, failures=0  SILENT
                   ... and prompt_bounds_test on the
                   same tree                            72 assertions, failures=0  SILENT
```

Three different shapes of the same fault:

- **Two sites, one needle, `contains()`.** `ai_interpreter.gd` carries two of
  the sentences and their needle text is identical. Either one could stop
  reading the reader and the row still passed; only losing **both** failed.
- **Two agreements in one sentence, one of them tabled.** 070 itself replaced
  `"Race: %d laps against %d opponent%s"` with two `Readback.plural()` calls,
  and the table named only the `opponent` half. The `lap` half was silent
  against the **naive** revert — not a hiding one — because `"lap"` is the
  only literal of its kind in `scripts/`, so fault 5's shape applied to a file
  that already had a row.
- **A member of the table with no row at all.** `racing_module.gd:76`, the
  prompt, was in neither the dictionary nor the produced sentences. The prompt
  is byte-identical while both floors are 2, so `PROMPT_FINGERPRINT` cannot see
  it either — 070 recorded *that* half and not the first.

**And the suite's own header did the arithmetic that hid it.** It read *"Four
of the nine sites are held by a SOURCE SCAN ... The five that ARE produced are
produced"*: four plus five is nine, the enumeration in 070's message has ten
entries, and the one the arithmetic dropped is the prompt — the unpinned one.
A paragraph that accounts for every member is read as proof that every member
is accounted for.

**THERE WERE THREE DIFFERENT COUNTS IN PLAY AND NONE OF THEM WAS THE ONE THAT
MATTERED.** Ten table rows; nine sentences (`session_report.gd:290` and `:291`
are two agreements in one sentence); and **thirteen hand-decided agreements**,
because two table rows each name a PAIR and one table row's sentence held a
second agreement the table never named. A pin covers an **agreement**, and no
number anywhere in 070 says thirteen — which is why "six rows against nine
sites" could be read either way for a whole commit without being settled.

**Fixed in 080** by making the key the **site**: the value is a list of
`[needle, least]` rows, one per hand-decided agreement, and the loop counts
occurrences instead of asking whether there is one. All five silent faults now
fail and name the number found (`found 1` against a floor of 2, `found 0`
against a floor of 1). Two must-pass controls pass: a **third** correct HTTP
sentence (the floor is a floor, so a correct arrival does not fail) and the
sentence **reworded** with both reader calls kept (the pin reads the call, not
the wording).

**The right form already existed in this repository**, in a sibling suite:
`tests/prompt_numeral_test.gd`'s `DECLARED` has been `[needle, count, kind]`
rows since 073 — *"`"1"` twice as an ordinal ... once as the character inside
the name `room_1`"* — because that suite's members are **occurrences** and it
was built knowing it. `READS_THE_READER` is the same kind of class and asked
`contains()`.

**And the class was screened rather than assumed (TRAPS 11).** One grep, not a
suite, so treat it as a starting point: of the per-file pin tables in `tests/`,
`check_wiring_test`'s `DECLARED`/`BY_HAND` pin `func <name>(`, which GDScript
cannot declare twice in a file; `source_scan_test`'s `KNOWN` makes a claim that
is genuinely per file (*does this file read a source*); `refusal_reach_test`'s
`DECLARED` is keyed by refusal name; `result_line_test`'s `NO_RESULT_LINE`
names non-suites. **`READS_THE_READER` was the only one whose members were
sites.** That is a screen and not a measurement.

**Do:**

- **Ask what the members of the class are before choosing the key.** If they
  are sites, a file key holds one site per file however many it has. The
  symptom is invisible: every row passes, and the count of rows looks like the
  count of members.
- **`contains()` answers "at least one". Where "how many" is the fact, count.**
  A needle whose occurrences are counted against a floor fails on a departure
  and passes on a correct arrival — which is the direction a stale number
  should go stale in.
- **A sentence can hold two of these, and the table will name one.** Read the
  whole sentence the commit changed, not the one call it was about. 070's
  own diff replaced two hand-written agreements and tabled one.
- **When a commit's message enumerates a class, diff that enumeration against
  the guard it then builds.** Both were written here within one commit, and
  the dictionary both omitted a member of the table (`racing_module.gd`) and
  named one that was never in it (`experiment_runner.gd`).
- **Count the unit a pin COVERS, not the rows, and write the unit down beside
  the number.** Rows, sentences and agreements were ten, nine and thirteen
  here. A session argued about whether six covered nine; neither number was the
  one a pin is measured against, and the arithmetic cannot be checked at all
  until the unit is named.
- **A prose count that balances is not a coverage proof.** "Four held by a
  scan, five produced" summed to the stated nine and left out the tenth. The
  claim to check is "which member is in neither list", and the list is in the
  commit message.

Found in 080, doing the measurement 079 left as the live "Next action" — which
asked whether six rows covered nine sites, and expected the answer might be
"nothing to do".

> The dictionary was described as per-site in its own comment, keyed by file in
> its own code, and the suite had been printing a pass over three unheld
> sentences since the commit that wrote all three.

---

## 78. A one-grep screen, written down as a screen, read as a result

**Signature:** a commit fixes one member of a class, screens the siblings with
a single grep, and writes *"that is a screen and not a measurement"* beside
the answer. The next session reads the answer. The screen was right about two
of the four and wrong about two, and the two it was wrong about had been
printing a pass over a real fault.

**Cause.** 080 fixed `agreement_test`'s `READS_THE_READER` — a table keyed by
FILE over a class whose members are SITES (TRAPS 77) — and then did the thing
TRAPS 11 asks for: it looked for the rest of the class. It found four sibling
per-file pin tables in `tests/` and cleared all four in one paragraph:

> of the per-file pin tables in `tests/`, `check_wiring_test`'s
> `DECLARED`/`BY_HAND` pin `func <name>(`, which GDScript cannot declare twice
> in a file; `source_scan_test`'s `KNOWN` makes a claim that is genuinely per
> file (*does this file read a source*); `refusal_reach_test`'s `DECLARED` is
> keyed by refusal name; `result_line_test`'s `NO_RESULT_LINE` names
> non-suites. **`READS_THE_READER` was the only one whose members were
> sites.**

Every clause in that paragraph is true, and the conclusion is false. **Each
clause answers for the table's KEY and none of them answers for what the
suite then DOES with it.** `source_scan_test`'s `KNOWN` is genuinely per file,
and section 2 of the same suite asks a question about READS with one
`contains()` per file. `refusal_reach_test`'s `DECLARED` is genuinely keyed by
name, and the verdict in the row is a claim about every PLACE that produces
the name.

**Measured in 081**, Godot 4.7.1, each fault in a throwaway copy with its own
`config/name` (TRAPS 50), the suite run alone, on a baseline byte-identical to
the md5 080 recorded:

```
check_wiring_test  2nd verdict function in a file with rows   191 assertions, failures=1  CAUGHT
check_wiring_test  2nd non-verdict check (BY_HAND's class)    190 assertions, failures=0  SILENT
source_scan_test   2nd, RAW read in a file that has _code_of   30 assertions, failures=0  SILENT
source_scan_test   ... the control: raw read, NO _code_of      30 assertions, failures=2  caught
refusal_reach_test 4th FAILED_LAYOUT place in farm_module      105 assertions, failures=0  SILENT
refusal_reach_test FAILED_CORRIDOR gains a controller owner    105 assertions, failures=0  SILENT
result_line_test   2nd result line, carrying no count          329 assertions, failures=3  CAUGHT
```

**Two of the four tables were wrong, and the strongest two are strong for a
reason worth copying.** `check_wiring_test.DECLARED` and
`result_line_test.NO_RESULT_LINE` both derive their class from the source and
assert membership in BOTH directions — a member arriving fails, a row going
stale fails. The two that were silent both hold a hand-written claim that the
derived data could have checked and did not: `source_scan_test._class()
already collects the sites` as `name -> ["file:line", ...]` and section 2
throws them away; `refusal_reach_test._categories_in_source()` already
collects the files per category and nothing compared them with
`SHARED_WITH_CONTROLLER`.

**And the screen's own hedge did not save it.** 080 wrote *"that is a screen
and not a measurement"*, put *"check it, do not trust it"* in its "Next
action", and set out the reasoning so it could be checked. That is as well as
a screen can be labelled, and the label is still an answer in a document: a
paragraph that gives a per-table reason for every table reads as a finding
about every table. This is TRAPS 77's last line one layer out — *a prose
account that balances is not a coverage proof* — with the accounting done in
reasons rather than in numbers.

**Fixed in 081** for `refusal_reach_test`, where the fix is a fact: each row
carries the number of PLACES in `scripts/` that name its category — the
literal, or a const whose declaration IS that literal, the declaration line
itself not counting — asserted against a read of `scripts/`. It is an
EQUALITY and not a floor, and that is the opposite of 080's choice for the
same reason: there the danger was a site LEAVING, here it is a place
ARRIVING that the row's verdict has never been asked of. `SHARED_WITH_CONTROLLER`
is derived as well as declared, and `LAYOUT_BRANCHES`'s size is tied to the
code. Both silent faults now fail and name both numbers; three controls pass
(a category named only in a comment, an existing place reworded, and an
unused const declaration leaving the place count alone).

**Not fixed in 081, and the reason is in the file:** `source_scan_test`'s
section 2. Its heading and message were struck, because what it measures is
that a file HAS a `_code_of()`, not that it uses one. No assertion replaced
them, because the per-function rule was measured before it was believed and
is not a fact about this repository — eleven of the twenty-five text-taking
functions in `tests/` do not name `_code_of()` in the same function, and most
of those are legitimate. An assertion over them would need a hand-written
allow-list: a hand table over a derived class, which is the shape this whole
investigation is about (TRAPS 6).

**Do:**

- **A screen answers about the key. The fault is in what the suite does with
  it.** Read the assertions the table feeds, not only the table. Two of these
  four had a correct key and a claim one layer along that the key could not
  carry.
- **Before hand-writing a claim, ask what the suite has already derived.**
  Both silent tables had the data in a variable, in the same file, and threw
  it away. That is the cheapest fix there is and the easiest to walk past.
- **A hedge is not a measurement, and labelling it does not make the reader
  re-measure.** If a screen is worth writing down, write down what it would
  cost to measure it, and expect the next session to read the conclusion.
- **Ask which direction a count should go stale in, every time, and say
  why.** A floor is right when a member LEAVING is the danger; an equality
  when one ARRIVING is. 080 and 081 are the same shape of fix with opposite
  answers, and neither is the default.
- **When a rule does not hold, measure that too, and say so instead of
  building it.** Eleven exceptions out of twenty-five is the measurement that
  stopped a bad assertion being written; the number is more useful in the file
  than the assertion would have been.

Found in 081, doing the measurement 080 left as the live "Next action" — which
said the screen's reasoning *"is written out in the 080 section so it can be
checked rather than retyped; check it, do not trust it"*, and was right to.

> Four tables, four true sentences about their keys, and two of them had been
> reporting a pass over a fault since the sentence was written.

---

## 79. An absence underwritten by a blacklist of the ways it could be broken

**Signature:** a suite asserts that the code does **not** do something — and
proves it by searching for the two or three spellings of that something its
author happened to think of. The assertion reads as a closure (*"nothing in
`scripts/` does X, so Y is out of reach"*). It is a sieve, and what it catches
is the past.

**Cause.** 082 read the seven unread functions 081 had measured as taking a
`.gd` source without the shared reader, and two of them turned out to be
holding an **absence** this way.

`controller_reach_test._guard_spawn_opponents` asserted *"nothing in
`scripts/` puts a node in `TrackBuilder.corner_nodes`, so `has_track()` is
always false"*, which is the **premise** for the claim that
`SPAWN_OPPONENTS`'s two refusal branches cannot be reached by a player. It
proved it by looking for `corner_nodes.append` and `corner_nodes +=`.
Measured, each in a throwaway copy with its own `config/name` (TRAPS 50):

| injected into `scripts/track_builder.gd` | before | after |
|---|---|---|
| `corner_nodes.push_back(node)` | **SILENT** 139, failures=0 | 140, failures=1 |
| `corner_nodes.insert(0, node)` | silent | 140, failures=1 |
| `corner_nodes.append_array([node])` | silent | 140, failures=1 |
| `corner_nodes.assign([node])` | silent | 140, failures=1 |
| `corner_nodes = [node]` | silent | 140, failures=1 |
| `corner_nodes[0] = node` | silent | 140, failures=1 |
| a **trailing** comment naming the needle | 139, **failures=1** — a FALSE ALARM | 140, failures=0 |

`scene_light_test` asserted *"nothing in `scripts/` makes a light or an
environment of its own, so the scene's are all the game has"* and looked for
`Light3D.new()`, `WorldEnvironment.new()` and `Environment.new()`. A light
added as `ClassDB.instantiate("OmniLight3D")` left it at **26 assertions,
failures=0** — silent, with the closure sentence still printing.

**The two halves are the same mistake.** A blacklist is blind to the fourth
idiom and loud about prose, because both follow from asking *"does this text
contain one of my needles"* instead of *"is every site here one I have
accounted for"*.

**Do:**

- **Hold an absence with a WHITELIST of the safe sites, not a blacklist of
  the unsafe ones.** The safe forms are enumerable, they are usually in one
  file, and each can carry its reason. Anything unrecognised fails and names
  itself, so a new idiom arrives as a failure instead of as silence. The
  whitelist goes stale in the safe direction; the blacklist goes stale in the
  dangerous one.
- **Check that the whitelist is classifying something.** A whitelist that
  matches nothing because the read came back empty is TRAPS 75 one layer out:
  `_check(sites > 0, ...)` beside `_check(scanned > 0, ...)`, because the
  file count and the site count fail for different reasons.
- **Recognise the shapes that cannot be spelled out, with a pattern.** An
  index write and an assignment to the whole array are *shapes*, not
  literals; enumerating their spellings is the mistake again one level down.
  And the declaration needs its own recognition: `var corner_nodes:
  Array[Node3D] = []` carries a `] =` from its TYPE, which an index-write
  pattern reads as a write. That was caught by running it, not by reading it.
- **Where the universe of routes is genuinely open, say so and name what
  covers the rest.** 082 asserted the light/environment ROUTES that are at
  zero today — a name ending `Light3D`, `WorldEnvironment`, `Environment.new(`,
  `ClassDB.instantiate(`, `.instantiate()`, `.tscn` — and wrote down the two
  it does **not** hold: a light duplicated from one already in the tree, and a
  class name assembled at runtime. `.duplicate()` is in legitimate use at
  **seven** places in `scripts/` — on a material, a vector, two dictionaries
  and an array, read rather than characterised from memory — and `load(` at
  **two**, both `Image.load`, so a zero on either would be a false alarm
  rather than a check. Those two are covered by section 3, which
  reads the light a *running* game has. A residual written down is a
  limitation; a residual left out is TRAPS 14.

Found in 082, reading the seven functions 081 left as the live "Next action" —
which had asked only whether a comment could satisfy each one. Two of them
could be satisfied by something much cheaper than a comment: a synonym.

> A blacklist of the ways a thing could be broken is a record of the ways it
> has been broken so far. An absence needs the other list.

---

## 80. Five reads broken at once, and the run read as holding each of them

**Signature:** a commit finds a class of unguarded scans, measures the
consequence with one run that breaks all of them together, and writes down
*"nothing is silent today"*. The run failed, so the class looks covered. Taken
one at a time, most of its members pass in silence — and the one that fired
was covering for the rest.

**Cause.** 082 found that `scan_floor_test._sites()` derived its class from one
idiom of directory read, `DirAccess.open(`, so the seven
`DirAccess.get_files_at(` reads in `tests/` had no row at all. It then asked
what that cost. The measurement it took was **five of `player_door_test`'s six
reads redirected at an empty directory in one edit**: 69 assertions,
**failures=2**. From which: *"So nothing is silent today — `player_door_test`
catches its own empty read incidentally, and that is luck rather than
design."*

**An N-at-once treatment proves that AT LEAST ONE of the N is held.** It cannot
distinguish that from all N being held, and the arithmetic says which is more
likely: five reads redirected produced **two** failures. 082 wrote the warning
itself — *"do not take the failures=2 above as proof the other five are held:
that was five reads redirected at once, which does not say that each is held
on its own"* — and still wrote *"the consequence today is nil"* in the same
entry. The hedge and the conclusion were in the same paragraph, and the
conclusion is the sentence that reads like a finding (TRAPS 78).

**Measured in 083**, Godot 4.7.1, each read redirected **alone** at a
directory that exists and is empty, each in a throwaway copy with its own
`config/name` (TRAPS 50), the suite run alone, on a baseline byte-identical to
the md5 082 recorded:

```
player_door_test :297 tests/      by_setting.size() >= 16     CAUGHT  69, failures=1
player_door_test :349 (variable)  literals.is_empty()         SILENT  69, failures=0
player_door_test :680 tests/      with_collision.is_empty()   SILENT  69, failures=0
player_door_test :688 scripts/    in_scripts.is_empty()       SILENT  69, failures=0
player_door_test :696 tests/      own_floor.size() >= 2       CAUGHT  69, failures=1
player_door_test :762 scripts/    readers.is_empty()          SILENT  69, failures=0
scene_light_test :405 scripts/    scanned > 0 and lines_read  CAUGHT  27, failures=1
```

**Four of the seven were silent, and all four assert an ABSENCE** — at their
greenest when the scan has read nothing, which is TRAPS 75's direction. Two of
the four are in the same function as the one read that fired: `:680` and
`:696` both read `tests/`, so the single edit that emptied `tests/` broke both
and `own_floor.size() >= 2` reported it. That is the whole mechanism. **The
loudest member of a group answers for the group**, and the quiet ones are
invisible for exactly as long as it is in there with them.

**And one of the four underwrote a sentence in its own file.**
`readers.is_empty()` is *"no script but the module that assigns it names
`CircuitBuilder` at all, so no production code identifies a world by name"* —
which is the stated reason the alternating world-node name (048's mechanism)
is said to cost nothing today. An absence proved by reading no scripts is not
an absence (TRAPS 14).

**A SECOND CAUSE, AND IT IS WHY THE WORST OF THE FOUR WAS INVISIBLE TWICE
OVER.** `_sites()` kept a site only if the quoted string on the line began
`res://`. `player_door_test`'s second read is
`for name in DirAccess.get_files_at(dir)` inside
`for dir in ["res://tests", "res://scripts"]` — the path is a **loop
variable**, so there is no quoted string on that line and the site was
dropped in silence. A filter that discards what it cannot classify is TRAPS
79 wearing different clothes: the blacklist decides what fails, and the filter
decides what is never asked. Both go stale in the dangerous direction.

**Fixed in 083.** All four reads carry a floor and each fails by name when
redirected alone; the two that already fired still fire.
`scan_floor_test` now **classifies** every `DirAccess` line in the code of
`tests/` rather than filtering it: `open` and `get_files_at` are reads and are
asked for a row, `remove_absolute` and `make_dir_recursive_absolute` are
writes and are not, a literal path on another filesystem is filed as such, a
path that is an **expression** is admitted and asked for a row like any other,
and **anything else fails and names itself**. The four buckets are asserted to
account for every such line, both reading idioms are asserted to be present,
and the null question is put only to the idiom that has a handle to test —
with the count of sites asked asserted, so the section cannot go quiet by
classifying everything as the kind it does not ask.

**Do:**

- **One treatment, one member.** If a measurement breaks N things, it has
  measured the maximum of the N, not each of them. Redirect one read, run,
  record; then the next. 083's seven runs took minutes and changed the answer
  from *nil* to *four faults*.
- **Compare the failure count with the treatment count before believing the
  run.** Five reads broken and two failures is the arithmetic saying *three of
  these are not held*, in the run that was read as coverage.
- **A group measurement hides the quiet members behind the loud one.** Ask
  which assertion actually fired and which reads it could not have seen. Two
  of 083's four silent reads shared a directory with the one that fired, which
  is the only reason the group run failed at all.
- **A filter is a blacklist of what you thought to look at.** Anything a
  classifier cannot place must fail and name itself, not be dropped. The one
  site whose path was an expression was both the hardest to see and one of the
  four that were silent.
- **Writing the hedge does not discharge it.** The next session reads the
  conclusion. If a measurement is too coarse to support the sentence, do not
  write the sentence — write the measurement that is still owed, and leave the
  question open.

Found in 083, doing the per-read measurement 082 left as the live "Next
action" — which said *"measuring them one at a time is part of the job"*, and
was right.

> Break five things at once and the run tells you that one of them was held.
> It does not tell you which, and it does not tell you about the other four.

---

## 81. The guard that said the file was read, asked one call too late

**Signature:** a suite reads a named source file, the line underneath says
*"the file was read"* and passes, and the file is not there. The read's
failure is caught — if it is caught at all — by something else further down,
which nobody wrote for that purpose.

**Cause.** `FileAccess.get_file_as_string()` returns the **empty string** for a
path that is not there; there is no handle and no null to test. The repository's
shared reader `_code_of()` blanks comment lines and cuts trailing ones, and it
is written as

```gdscript
for raw in source.split("\n"):
	...
	out += (line if hash_at < 0 else line.substr(0, hash_at)) + "\n"
```

`"".split("\n")` is **one empty element**, so an empty source in produces one
`"\n"` out. Measured in Godot 4.7.1 on a built source: raw length **0**,
stripped length **1**, the byte **10**.

So `_check(_code_of(FileAccess.get_file_as_string(path)) != "", "X was read")`
**cannot fail**. The guard is not weak, it is vacuous — the one shape TRAPS 6
is about, in the one line whose whole job was to stop the failure it cannot
see.

`view_frame_test.gd:373` was that line, from 062 until 084. **Measured** (its
one read redirected at a path that does not exist, in a throwaway copy with
its own `config/name`, the suite run alone): **82 assertions, failures=3** —
`clears.size() == 6`, `restores.size() == 3` and `frames.size() == 3` all
reported, and *"game_controller.gd was read"* **PASSED**. Three of the four
assertions that could fail did; the only one that was written to say the read
worked did not. Had those three counts ever been loosened to floors — which is
what a later session does when a count gets in the way — the read would have
gone silent with the guard still green beside it.

**And the same question one idiom over has the opposite answer, which is why
this is easy to miss.** `FileAccess.open(path, FileAccess.READ)` returns
**null** for a missing path, so `_check(file != null, "X can be read")` is
load-bearing. The two idioms read the same in a diff and do not fail the same
way.

> **CORRECTED IN 085 (TRAPS 82).** The sentence above continued *"and the four
> sites in `tests/` that use it were each measured firing by name"*. There are
> **five** `open()` sites in that class, not four, and the fifth —
> `record_id_test.gd:455` — was **not** measured firing by name: its null was a
> branch condition, never asserted, and what fired was `record_body != ""`, a
> check whose message is about something else. Generalising the class by idiom
> is what hid it: the idiom called safe is the one nobody re-checks. Fixed and
> falsified in 085.

**Fixed in 084.** The guard moved to the **raw** read, with the reason asserted
on a built source beside it rather than left in a comment: a path that does not
exist reads as `""`, and `_code_of("")` does not. Re-measured, the same
redirect now gives **84 assertions, failures=4**, the guard naming itself
first. The property is also asserted centrally in `source_scan_test`'s section
4, which is the section that owns the reader — and section 3 there has already
asserted that every copy of `_code_of()` in `tests/` is byte-identical, so a
property proven of one copy is a property of all of them. **Both new controls
were falsified, each in its own copy**: make `view_frame_test`'s `_code_of()`
return `""` for an empty source and that suite fails **84/1** naming the new
assertion; make `source_scan_test`'s do the same and that suite fails **32/2**
- the new assertion, and section 3's byte-identity check naming
`source_scan_test.gd` as the drifted one of the **15** copies.

**Do:**

- **Ask whether the read worked at the read, not after the transform.** Every
  step between the two can turn an empty answer into a non-empty one, and the
  cheapest of them does.
- **Know which idiom you used.** `open()` gives you a null to test;
  `get_file_as_string()` gives you `""`, which is a value that survives being
  processed. A guard copied from one to the other stops working silently.
- **A guard that claims a fact is a claim, so falsify it once.** Point the read
  at a path that does not exist and watch *that line* fail. If something else
  fails instead, the guard is decoration and the suite's real floor is
  wherever the failure actually came from.
- **Count the failures against the assertions that could fail.** Three of four
  firing is the arithmetic saying one of them is not held (TRAPS 80), and the
  one not held was the one with the reassuring message.

Found in 084, while measuring the eight named-file reads 083 left as the live
"Next action" — all eight of which are held. The fault was not in the class
being measured but in the line that said the measurement was unnecessary.

> `_code_of("")` is not `""`. A guard asked after the stripper is a guard
> asked of the stripper.

---

## 82. The table was right, and the sentence under it bucketed a row by the wrong idiom

**Signature:** a commit measures a class one member at a time, writes the
results into a table that is correct row by row, and then writes a paragraph
under the table that sorts the rows into two buckets. One row goes into the
wrong bucket. The table is never read again; the paragraph is, and the
paragraph says a guard exists where none does.

**Cause.** 084 measured the **eight** reads in `tests/` of a single named
`.gd` file by a literal path, each redirected alone at a path that does not
exist. Its table is accurate — `record_id_test.gd:455` is listed with
`record_body != ""`, `mints == 3` as what fires. Its summary paragraph then
split the eight by idiom and got the split wrong in both directions:

> `FileAccess.open(path, READ)` returns **null** for a missing path, so the
> **four** sites that use it are each held by a `!= null` guard written for
> exactly that. `FileAccess.get_file_as_string()` returns the **empty
> string** [...] and the **four** sites that use it are held — all four — by
> an exact count or a positive membership claim further down.

**It is five and three, not four and four**, and the row in the wrong bucket
is `record_id_test.gd:455`, which uses `open()`. Counted mechanically off the
code at `fd290a2`, comment lines blanked first (TRAPS 64):

| idiom | sites | guarded at the read, before 085 |
|---|---|---|
| `FileAccess.open(..., READ)` | **5** | 4 |
| `FileAccess.get_file_as_string()` | **3** | 1 (084's own fix) |

**The consequence is not the arithmetic, it is the clause the arithmetic
carries.** *"The four sites that use it are each held by a `!= null` guard
written for exactly that"* is **false of `record_id_test.gd:455`**: its
`open()` returns a null that is used as a **branch condition** and never
asserted. The read was held only by `record_body != ""`, whose message is
*"the record id's mint asks the OS who this process is"* — so a moved or
renamed `track_log.gd` reported as a **missing capability** rather than as a
missing file. TRAPS 81's own text repeated the error one step further
(*"the four sites in `tests/` that use it were each measured firing by
name"*), which is not true of the fifth.

**Why the wrong bucket was the expensive half.** 084's conclusion —
*"`open()` gives you a null to test, so those are fine; the string idiom is
the dangerous one"* — is a true sentence about the two idioms and a false
sentence about this repository. The idiom that **can** be asked directly is
exactly the idiom nobody checks again, so an unguarded `open()` hides behind
the generalisation that `open()` is the safe one. The one unguarded `open()`
read in `tests/` was invisible for as long as the class was discussed by
idiom instead of site by site.

**Fixed in 085.** All three unguarded reads given a guard written for the
purpose and each falsified alone, in a throwaway copy with its own
`config/name` (TRAPS 50), the suite run alone:

| site | idiom | guard added | redirected alone |
|---|---|---|---|
| `player_door_test.gd` main.gd | string | `main_raw != ""` | 67, failures=**2**, guard named first |
| `player_door_test.gd` game_controller.gd | string | `controller_raw != ""` | 73, failures=**2**, guard named first |
| `record_id_test.gd` track_log.gd | `open()` | `track_log != null` | 23, failures=**3**, guard named first |

The class was then re-derived mechanically rather than re-read: all **8**
named-file reads in `tests/` are now asked at the read, 5 by `!= null` and 3
by a raw `!= ""`.

**Do:**

- **Fix from the table, not from the paragraph.** A per-member measurement is
  worth taking because each row stands alone; a summary that re-sorts the rows
  into buckets throws that away and can only be as good as the sorting. If a
  paragraph and a table disagree, the table is the measurement.
- **A bucket count is a claim about the code, so derive it the way you derived
  the rows** — mechanically, off the code, with comments blanked (TRAPS 24,
  TRAPS 64). 084 counted the rows by running them and counted the buckets by
  reading them.

**AND THIS IS THE SECOND TIME, IN THE OPPOSITE DIRECTION, WHICH IS THE
GENERAL RULE.** TRAPS **71** is the same disagreement with the roles
reversed: `prompt_numeral_test`'s header summed eighteen numerals as *"seven
ORDINAL and eight PROSE"* and **the table it sat on said eight ORDINAL and
seven PROSE**. There the prose was right and the table was wrong; here the
table was right and the prose was wrong. So the rule is not *"trust the
table"* - 085 wrote that sentence first and TRAPS 71 falsifies it. The rule
is:

> **A per-kind summary and the per-row table under it are two counts of the
> same thing, and nothing asserts that they agree unless somebody wrote the
> assertion.**

**THE SECOND HALF OF THAT SENTENCE WAS WRONG WHEN 085 WROTE IT, AND 086
CORRECTED IT BY MEASUREMENT.** It read *"and nothing in this repository
asserts that they agree"*. That is an absence claim about the code, written
without grepping for the thing it denies — TRAPS **14**'s rule, arriving in
the entry that is itself about a prose generalisation nobody derived. **Two
suites assert exactly that agreement**, and both assertions were falsified in
086 rather than read (TRAPS 50, own `config/name`, each suite run alone):

| what asserts it | the fault injected | result |
|---|---|---|
| `prompt_numeral_test.gd:465,468,474` — `KIND_TOTALS` tallied off `DECLARED`'s rows | `KIND_TOTALS` transposed to 8 ORDINAL / 7 PROSE, which is **073's exact fault** | 117 assertions, failures=**2**, naming both kinds and both numbers. Control 117/0 |
| `scan_floor_test.gd:566,568,594` — the four buckets asserted to account for every `DirAccess` call | one line in `agreement_test.gd` made to carry **two** `DirAccess` calls, which `_member_on()` reads as one | 120 assertions, failures=**1**: *"the four buckets account for every DirAccess call in tests/: 24 = 20 read + 3 write + 0 unknown + 0 elsewhere"*. Control 120/0 |

And the first of those was built in **074 as TRAPS 71's own fix** — the trap
085 cited as its precedent — while the second was built in **083, two commits
before 085 wrote the sentence**. So the entry denied a mechanism this
repository had already built twice, once for the very trap it was citing.

Both are claims about the code (TRAPS 24). A suite can hold a table row by
row and still let the sentence above it say something else, because the
sentence is prose and prose is not run. When a commit writes both, it owes
the reader the derivation of the summary **from the table**, mechanically -
not a second reading of the code, and not a tally made while writing.

**WHERE THE TABLE IS IN CODE, THE ASSERTION IS CHEAP AND IS THE ANSWER.** The
pattern is in `prompt_numeral_test` and `scan_floor_test` and does not need
inventing: tally the kind column off the rows, assert the tally against a
declared per-kind total, and assert the totals sum to the row count. What
**cannot** be asserted is a summary written in prose in `HANDOVER.md` or in
this file, and that is the live limitation — not the absence of the mechanism.

**Do:**

- **Derive the summary from the table, in one step you could show.** If the
  buckets cannot be produced by counting the rows, one of the two is wrong and
  the diff between them is the finding.
- **When they disagree, do not pick the one that reads better.** TRAPS 71 and
  TRAPS 82 disagree about which was right, so the only safe move is to
  re-derive both off the code with comment lines blanked (TRAPS 64).
- **Beware the bucket you called safe.** Sorting a class into "the dangerous
  idiom" and "the safe idiom" stops the next session from checking the safe
  one. The exception lives there precisely because nobody looks.
- **"Held by" is not "guarded by".** A null used as an `if` is not an
  assertion, and a downstream check whose message describes something else is
  a coincidence that a later edit can remove without anybody noticing it was
  load-bearing.

Found in 085, by re-deriving 084's class off the code instead of carrying its
summary forward (TRAPS 4, TRAPS 66).

> The row was right. The sentence that counted the rows was wrong, and the
> sentence is what the next session reads.

---
## 83. A classification column nothing reads, under a header that counts it

**Signature:** a suite declares a table with a column that classifies each
row, the file's header states the per-kind answer in prose, and no code in the
repository ever reads the column. Reclassify a row and the suite is green and
the header is false. Or the column *is* read, but only through a
`if kind != "THE_ONE_I_WANT": continue`, so a value nobody anticipated is
dropped in silence and takes that row's assertion with it.

**Cause.** 086 was sent to do a reading: TRAPS 82 had found that 084's
per-kind summary of a measured table was wrong in a way the table was not, and
asked where else this repository generalises a per-member table into kinds and
then reasons about the kinds. The reading came back **clean on all three
candidates named** — 083's seven directory reads re-derived mechanically off
the code agree row for row and bucket for bucket; 073's ORDINAL/PROSE split
was corrected in 074 *and asserted*. What it found instead was one layer down:
**the tables whose kind column lives in code, and what holds them.**

Five tables in `tests/` carry a classification column. Measured off the code,
not read off this file:

| table | kind is one the file knows | per-kind total asserted | per-row kind acted on |
|---|---|---|---|
| `prompt_numeral_test.DECLARED` | yes (`:461`) | yes (`:465`, `:474`) | yes, sections 4–8 |
| `scan_floor_test` sites | yes (`:568`) | yes (`:566`, `:594`) | yes, §3 asks only `open` |
| `check_wiring_test.DECLARED` | yes (`:441`) | no | yes, by fixture |
| `refusal_reach_test.DECLARED` | **no** | **no** | yes, but through a `continue` |
| `controller_reach_test.BRANCHES` | **no** | **no** | **no — never read at all** |

`BRANCHES` is walked **once**, at `_enumeration()`, for `row[0]`. Its third
column — `REACHABLE` / `GUARD` / `NEEDS_KEY`, the whole answer 054 was built
to produce — was read by nothing in `tests/` or `scripts/`, grepped rather
than assumed. The file's header states *"THE ANSWER IS TWENTY-TWO REACHABLE,
FIVE GUARDS, ONE THAT NEEDS A KEY, and all five guards fire when handed a
violation"*. Counted mechanically off the rows: 22, 5 and 1. **Nothing was
wrong. Nothing would have noticed if it became wrong**, which is the finding.

**Measured, both files, each fault alone** (TRAPS 80), in a throwaway copy
with its own `config/name` (TRAPS 50), the suite run alone:

| fault injected | before 086 | after 086 |
|---|---|---|
| `controller_reach_test`: `FAILED_NO_HANDLER`'s row `GUARD` → `REACHABLE` | 140 assertions, failures=**0** — SILENT | 190, failures=**5**, naming both totals and the orphaned fixture |
| `controller_reach_test`: a sixth `GUARD` row with no fixture | — | 193, failures=**3**, naming the row |
| `controller_reach_test`: a kind mistyped `GUARD` → `GAURD` | — | 191, failures=**2**, naming the row and the total |
| `controller_reach_test`: a fixture stops claiming its row | — | 189, failures=**2**, naming the row |
| `refusal_reach_test`: `FAILED_TOO_BIG`'s verdict mistyped `GUARD` → `GAURD` | **124, failures=0** — SILENT, and the assertion count went **down by one** | 161, failures=**2** |
| `refusal_reach_test`: `FAILED_CORRIDOR` `GUARD` → `REACHABLE` | — | 161, failures=**2** |
| `refusal_reach_test`: an owner mistyped `CONTROLLER` → `CONTROLER` | — | 162, failures=**2** |

**THE QUIETEST ONE IS THE MISTYPED VERDICT, AND IT IS TRAPS 73 ARRIVING
THROUGH A CLASSIFIER.** `refusal_reach_test`'s sweep reads the column as
`if str(row[0]) != "MODULE" or str(row[1]) != "GUARD": continue`. A typo makes
the row invisible to that loop, so the guard stops being swept **and its
assertion stops existing** — 125 assertions became 124 with `failures=0`. The
alarm was the count, and the runner reads only the failures (TRAPS 75). One
character turns a swept guard into an unswept one with nothing red.

**Fixed in 086.** Both files: the classification column is a **membership**
(an unknown value fails and names itself, never `continue`), and the per-kind
totals are **tallied off the rows** and asserted against a declared total
whose own sum is asserted against the row count. And in
`controller_reach_test`, the part a tally cannot reach: each fixture in
sections 3 and 4 now **claims the row it fired**, at the end of the fixture
after the measurement, and the claimed set is asserted against the set of rows
the table calls out of reach **in both directions**. 140 → 191 assertions,
125 → 162.

**Do:**

- **A column that classifies is a claim, so something must read it.** If no
  code reads a column, the column is a comment with a comma in it (TRAPS 24).
  Either tally it or delete it; a classification nobody reads is worse than
  none, because the header counts it.
- **Tally it off the rows, never beside them.** `KIND_TOTALS` read off
  `DECLARED` is the pattern; `prompt_numeral_test` has had it since 074 and
  `scan_floor_test` since 083. Copy it rather than inventing it.
- **Classify, do not filter.** `if kind != X: continue` makes every value the
  author did not imagine invisible, and takes that row's assertions with it.
  Assert membership **first**, then filter. 083 learned this about a path
  filter; it is the same fault about a kind.
- **A per-kind tally is not coverage.** It catches a row that moved; it cannot
  catch a row no fixture ever fires. Where a kind means *"a fixture below
  proves this"*, have the fixture name the row and assert the two sets both
  ways — and claim at the END of the fixture, so one that returned early
  claims nothing (TRAPS 81).
- **An absence claim in THIS FILE is a claim about the code.** TRAPS 82's own
  rule sentence said *"nothing in this repository asserts that they agree"*
  while two suites did, one of them built as the fix for the trap that
  sentence was citing. The rule TRAPS 14 states for the AI's prompt — grep for
  the thing a limitation denies before writing it — has no exemption for
  `TRAPS.md`.

Found in 086, by doing the reading 085 asked for, finding the three named
candidates clean, and asking the same question of the tables that live in code
instead of in a document. **No file in `scripts/` or `scenes/` was wrong and
neither changed.** The prompt is byte-identical and `PROMPT_VERSION` did not
move.

> The header counted the column. Nothing else ever looked at it.

---

## 84. A number a header counts, declared as a constant and read by nothing

**Signature:** a suite declares `const SOMETHING_MEASURED := 14` beside a
table, the file's header states the answer in prose — *"FOURTEEN CALL SITES,
TEN HELD, FOUR NOT"* — and no code in the repository ever reads the constant.
The number is a comment with a `const` in front of it. Worse than TRAPS 83's
unread column, because a constant *looks* like something the code uses.

**Cause.** 087 was sent to do the reading HANDOVER left as the live next
action: is `check_wiring_test`'s header 14/10/4 over `DECLARED`, over
`BY_HAND`, or over neither. It is over **neither** — it is over the fourteen
call sites `W01`–`W14` that 055 wired out one at a time, and that table lives
in `docs/HANDOVER.md`, which **no suite can read**. `DECLARED` has 35 rows and
`BY_HAND` one.

Swept mechanically, comment lines blanked, every `const` declaration matched
against every other code line:

| swept | declarations | read by no other code line |
|---|---|---|
| `tests/` | 94 | **2** — `CALL_SITES_MEASURED`, `NOT_HELD_BEFORE_055`, both in `check_wiring_test.gd` |
| `scripts/` + `tests/`, cross-file | 315 | **5** — those two, plus `dungeon_module.DIRS`, `track_builder.SEGMENT_WIDTH` and `SEGMENT_THICKNESS` |

The three in `scripts/` are vestigial values from the 148 lines 002B took out
of `track_builder.gd`, which that file's own header already accounts for. They
were **grepped across the whole repository before being called unused**,
`.tscn` and `project.godot` included, and **were not touched**: deleting
constants in game code on a Prototype 001 path the owner may be about to
delete is his call. So the live class was **two members, both in the one file
HANDOVER had pointed at**.

**And the file named thirteen of the fourteen sites it counted.** `W06`,
`FarmModule._check_reachable`, appeared **nowhere** in `check_wiring_test.gd`
— its row named 053 and not the site. A reader sent by the header to find the
fourteen found thirteen, and nothing said so.

**Measured, each fault alone** (TRAPS 80), in a throwaway copy with its own
`config/name` (TRAPS 50), the suite run alone. Controls: 190/0 before, 217/0
after. **Every row below was re-measured against the file that was actually
committed**, md5 `e4f42e9e2ee80bb31dce7b88ac9cda6a`, after the last
comment-only edit — because the first pass was taken on a snapshot that
differed from it, and a number measured on a file nobody has is not a
measurement. All seven reproduced exactly.

| fault injected | before 087 | after 087 |
|---|---|---|
| `W13` mistyped `W31` on one row | 190, failures=**0** — SILENT | 217, failures=**1**, naming the stray and its row |
| a fifteenth site `W15` appears on a row | 190, failures=**0** — SILENT | 217, failures=**1**, naming it unplaceable |
| `CALL_SITES_MEASURED` says 15 | 190, failures=**0** — SILENT | 218, failures=**2**: the count, and `W15` named as missing |
| `NOT_HELD_BEFORE_055` says 4 | 190, failures=**0** — SILENT | 217, failures=**1** |
| an entry drops out of `NOT_HELD_BEFORE_055_SITES` | — (the array is new) | 215, failures=**1**, on the size and not on the total |
| the farm row loses `W06` — **the state 086 left** | — | 217, failures=**3**: the count, the gap, and the unheld site |
| `W03` removed from **one** of the two rows that name it | 190, failures=**0** | **217, failures=0 — STILL SILENT** |

**THE LAST ROW IS THE ONE WORTH KEEPING, AND IT IS A LIMIT OF THE FIX AND NOT
A WIN.** The tally holds the **set** of labels, so a label lost from one of
several rows that spell it is invisible: the distinct count is still fourteen
and contiguous. That fault was **injected and run** rather than reasoned
about, and the limit is written into the function that has it. The stronger
assertion was **weighed and not built**: a per-row label table is a count
written *beside* the rows rather than read *off* them, which is TRAPS 82's
shape, and it would fail every time a row's sentence was legitimately
reworded.

**And the narrower version was checked before being ruled out**, not assumed
false. *"Every row whose verdict came from a wire-out names a site"* does
**not** hold, counted off the rows: `command_parser.gd:parse` and
`game_controller.gd:record_load_check` carry no label, and 056's two
(`finish_order`, `_on_revision_requested`) are not in 055's fourteen at all.
Asserting it would have failed on correct rows — TRAPS 6 pointing the other
way.

**What the reading also settled, and it was the thing HANDOVER could not:**
the header's three numbers and the two constants are **consistent**, which had
been carried as a *reading* and not a measurement. Ten held and four not are
the fourteen; the tenth held is `W13`, held only by `session_test`, which runs
only with `--all` — so `NOT_HELD_BEFORE_055` counts **five**, the four plus
that one, and `14 - 5 = 9` is the number a **fast** suite held. Not a
disagreement with "ten". The reconciliation is now in the file beside the
numbers.

**Do:**

- **A declared number is a claim, so something must read it.** TRAPS 83's rule
  for a classification column has no exemption for a `const`. Either assert it
  or delete it; a number a header counts and nothing reads is the worse of the
  two, because `const` looks load-bearing.
- **Ask what the number is OVER before asserting anything against it.** The
  honest answer here was "neither of this file's two tables", and a tally over
  `DECLARED`'s verdict column asserted as though it were the 14/10/4 would
  have been TRAPS 6. The map from site to row is many-to-many in both
  directions — one row names **four** sites, and `boots_tool`, `car_tool` and
  `look_tool` each name **two with opposite outcomes** (*"EQUIP's refusal
  (W09) failed controller_reach_test; the readback's branch (W14) was held by
  nothing"*). A tally cannot be derived from that, and the file now says so
  where the next session will look.
- **Tally the labels, not the verdicts.** The set of labels is derivable off
  the rows; a verdict is a measurement taken once by 055's method, and a test
  that asserted one would be asserting a comment.
- **Contiguity, one assertion per member.** `W06 is named by a row` fails by
  name. A bare count one short tells you only that something is missing.
- **Measure the limit of your own guard and write it down.** The `W03` row
  above was found by injecting a fault into the fix, after it was green. A fix
  whose limits were reasoned about rather than run is a fix whose limits are
  unmeasured.

Found in 087, by answering the reading HANDOVER asked for and finding that the
question one layer in — *what reads these two numbers* — had a shorter answer
than the one it was sent to get. **Nothing in `scripts/`, `scenes/`,
`netlify/`, `.github/`, either runner, `project.godot` or
`export_presets.web.cfg` was touched**, read off `git status` rather than
assumed. The prompt is byte-identical and `PROMPT_VERSION` did not move.
**Nothing a player meets changed.**

> The header counted fourteen. The constant said fourteen. The file named
> thirteen, and no line of code had ever asked.

---

## 85. A per-kind tally counts ROWS, so the fixture that drives a row can be deleted in silence

**Signature:** a suite has a classification column that is a membership, and
per-kind totals tallied off the rows and asserted — 086's and 087's fix, done
properly — and it is still green after the block that drives one of those rows
to its refusal has been deleted. The tally counted the rows. Nothing counted
the fixtures.

**Cause.** 088 was sent to do the reading HANDOVER left as the live next
action: read `controller_reach_test`'s 21 `_reaches` calls in section 2
against its 22 `REACHABLE` rows, one at a time, and *"do not relabel
twenty-one fixtures on the assumption that the two numbers should match"*.

**The reading came back "no hole", and the arithmetic that was missing is
this.** Counted off the code, comment lines blanked:

| | rows |
|---|---|
| 21 `_reaches()` calls in section 2 fire | **19** distinct rows |
| …because **two** rows are each driven by **two** probes | `EQUIP: no tool named, or a tool the game lacks` (one site, `game_controller.gd:600`, whose row text names two faults with an "or") and `ORDER: the goal does not check out` (one site, `:237`, probed with no dungeon and with no room) |
| `_reachable_parse()`, which uses no `_reaches()` because the record carries **no command** — the branch's whole point — while `_reaches()` matches on command | **1** |
| `_reachable_plan_placement()`, which uses none either because **two rows arrive from one request** as several records under one id, told apart by result/construction, and `_reaches()` takes the first match and breaks | **2** |
| | **22** |

Every `REACHABLE` row was already driven by a request. HANDOVER was right to
call the one-row gap a measurement and not a finding, and right to ask for the
reading before the relabelling.

**What was missing is anything that would notice.** The row was driven through
a free-text `label` read by nothing — so 086's `answered` mechanism covered the
**6** rows the table calls out of reach, and the **22** it calls reachable were
tied to nothing at all. **And the same hole was in the second file, which is
the part that makes this TRAPS 11 and not a one-file fix**: 086 gave
`refusal_reach_test.DECLARED` the same membership and tally and tied **none**
of its ten MODULE rows to the fixture that drives it.

**Measured, each fault alone** (TRAPS 80), against the **committed 087 files**,
in a throwaway copy with its own `config/name` (TRAPS 50), each suite run
alone. Controls: `controller_reach_test` **191/0** before and **265/0** after;
`refusal_reach_test` **162/0** before and **206/0** after.

| fault injected | before 088 | after 088 |
|---|---|---|
| `controller_reach`: the only probe for a `REACHABLE` row deleted (`CREATE_TRACK`) | **189, failures=0 — SILENT**, and the count went DOWN by two | 261, failures=**2**, naming the row |
| `controller_reach`: a `REACHABLE` row's text reworded in the table only | **191, failures=0 — SILENT** | 264, failures=**3**, naming it from both sides |
| `controller_reach`: a probe names a row the table has not (one typo) | — | 264, failures=**3**, naming the typo and the row left uncovered |
| `controller_reach`: a probe names a real row declared under another category | — | 265, failures=**3** |
| `controller_reach`: `_reachable_parse`'s claim removed, fixture still running | — | 263, failures=**2** |
| `controller_reach`: one of `_reachable_plan_placement`'s two claims removed | — | 263, failures=**2** |
| `controller_reach`: a `GUARD` row reclassified `REACHABLE` (086's own fault) | 190, failures=**5** | 265, failures=**7** — 086's five plus the row named undriven |
| `refusal_reach`: the `FAILED_TOO_BIG` block deleted | **160, failures=0 — SILENT**, count DOWN by two | 201, failures=**2**, naming the row |
| `refusal_reach`: the `FAILED_CLOSURE` named request deleted | **159, failures=0 — SILENT**, count DOWN by three | 200, failures=**2**, naming the row |
| `refusal_reach`: `FAILED_CORRIDOR` `GUARD` -> `REACHABLE` | 161, failures=**2** | 206, failures=**4** — and two of the four are new |
| `refusal_reach`: a sweep exemption naming a row that is not `MODULE`/`REACHABLE` | — (the list was four names typed out) | 207, failures=**1** |
| `controller_reach`: ONE of the TWO probes for the `EQUIP` row deleted | 190, failures=0 | **262, failures=0 — STILL SILENT** |
| `controller_reach`: ONE of the TWO probes for the `ORDER` goal row deleted | 190, failures=0 | **262, failures=0 — STILL SILENT** |

**THE TWO SILENT ROWS ARE THE LIMIT OF THE FIX AND NOT A WIN, AND BOTH
MEMBERS OF THE CLASS WERE RUN RATHER THAN ONE.** The claim is a **set** of
rows, so a row driven by two probes keeps its claim when one probe goes. That
is TRAPS 84's `W03` limit arriving in a second file, it was **injected and run
after the fix was green**, and it was measured on **both** doubly-probed rows
rather than one and generalised (TRAPS 11 the other way round). The stronger
assertion was **weighed and not built**: a declared probe count per row is a
number written *beside* the rows rather than read *off* them, TRAPS 82's
shape, and it would have to be moved by hand every time a probe was
legitimately added.

**And the two counts going DOWN with nothing red is the old enemy.** Three of
the four silent faults above lost assertions — 191 to 189, 162 to 160, 162 to
159 — exactly TRAPS 73's signature, where the alarm is the count and the
runner reads only the failures (TRAPS 75). Every one of them now fails **by
name**.

**Do:**

- **A tally is not coverage.** A per-kind total asserted off the rows catches a
  miscount and a mistyped kind. It cannot catch a row whose fixture went away,
  because a deleted fixture does not change the rows. Two different holes, two
  different assertions.
- **Tie the row to the fixture in both directions, one assertion per row.** A
  row nothing drove fails by name; a fixture driving a row the table does not
  declare, or declares under another kind, fails by name as well. A bare count
  one short tells you only that something is missing (TRAPS 84).
- **Claim what fired, at the end, and only when it fired.** The idiom was
  already in this repository twice — `layout_fired` in `refusal_reach_test`
  since 074, `answered` in `controller_reach_test` since 086 — and it was
  copied rather than reinvented. A claim made before the measurement answers
  for a run that did not happen (TRAPS 81).
- **Read the counts before you believe the gap.** "21 calls against 22 rows"
  looks like a hole and was not one. Two rows carried two probes each and three
  rows were held by fixtures that cannot use the shared helper for a reason in
  the branch itself. The reading cost one session and would have cost
  twenty-one wrong relabellings.
- **"Exactly once" is assertable in one of these two files and not the other,
  and which is a fact to check and not to assume.** `refusal_reach_test` drives
  each row from exactly one fixture, so a doubled claim is a fault there and is
  asserted. `controller_reach_test` has two rows with two legitimate probes, so
  asserting equality of claims to rows would fail on correct rows — TRAPS 6
  pointing the other way.
- **A list of names typed out beside a table is the same fault one level up.**
  The sweep in `refusal_reach_test` looked for four categories by name; it now
  derives them off the rows, less one named exemption whose own row is asserted
  to exist. The derived version caught two faults the typed list did not.

Found in 088, by doing the reading before the relabelling and then asking what
the second file in the same class had.
**Nothing in `scripts/`, `scenes/`, `netlify/`, `.github/`, either runner,
`project.godot` or `export_presets.web.cfg` was touched**, read off
`git status` rather than assumed. The prompt is byte-identical and
`PROMPT_VERSION` did not move. **Nothing a player meets changed.**

> The tally proved the rows were right. Nothing proved anybody had run them.

---

## 86. A refusal with nothing in it, and the two suites that each held half of "it says something"

**Signature:** the repository's own first rule about refusals is *"refuse,
never clamp — and name the limit, at every door"*. Make every refusal that
goes through one of the controller's two record finishers carry an **empty**
reasons array, so that seven of the controller's branches tell a player
nothing at all, and two suites written to hold exactly that property are
**green**.

**Cause.** 088 closed a hole and left a limit: a `REACHABLE` row driven by two
probes keeps its claim when one probe is deleted, because the claim is a set of
rows. It weighed the obvious fix — a declared probe count per row — and
declined it as a number written *beside* the rows rather than read *off* them
(TRAPS 82), and it wrote down the honest next step: **read whether the probes
can be keyed off something the code already has — the request, or the refusal's
own wording — so the claim becomes a measurement rather than a second label.**
089 did that reading. It answers **half yes**, and the fault above was found
while measuring the other half.

**THE READING: THE WORDING TELLS THE PROBES APART, AND GIVES NO DENOMINATOR.**
Measured by sending all four probes of the two doubly-probed rows through
`main.gd` and reading the records, not by reading the code:

| probe | the refusal it drew |
|---|---|
| `EQUIP`, no tool named | `an EQUIP has to say which tool it is for (this game has car, boots, look)` |
| `EQUIP`, a tool the game lacks | `this game has no tool called 'jetpack' (it has car, boots, look)` |
| `ORDER`, no dungeon at all | `there is nobody to order about: build a dungeon first` |
| `ORDER`, no room named | `go_to needs a room (this dungeon has entrance, store, vault)` |

So the wording **does** distinguish them and it is already in the record.
**What it does not give is the number two**, and that number is the whole of
088's limit: to notice that a probe has been *deleted*, something has to know
the row had two. **And the number is derivable for one of the two rows and not
for the other**, which is the part that settles it:

| row | where its sentences come from | distinct sentences the producer can make | the row probes |
|---|---|---|---|
| `EQUIP: no tool named, or a tool the game lacks` | **composed at the site** — two arms of one `if asked_tool == ""` in `game_controller.gd`, both appending to `problems` before one `_finish_failed` | **2** | 2 |
| `ORDER: the goal does not check out` | **passed straight through** — `_finish_failed(record, "FAILED_SCHEMA", checked["errors"])` at `:237`, where `checked` is `NpcGoals.validate()` | **10** (`errors.append` sites counted inside `validate`, lines 47–124) | 2 |

A count derived off the code would have been **right for the first row and
wrong by eight on the second** — TRAPS 11 pointing at the proposed *fix*
rather than at the code. **It was not built.** The same split holds wider:
`SHUT/OPEN: the door does not check out` passes `validate_door`'s **6**
sentences through, `a world's own validator refused it` passes a whole world
module's set, and `EQUIP: the tool's own spec is out of bounds` passes the
tool's. Keying the claim by sentence would not tighten the table; it would
replace it with a class three to five times larger, and **whether the table
should be keyed by SENTENCE rather than by SITE is a question about what the
table is for**, not a tightening of what it already says.

**SO 088'S LIMIT IS STILL OPEN AND IS STILL MEASURED**: with 089 in place,
deleting one of the two probes for the `EQUIP` row gives **289 assertions,
failures=0** — the count falls by four and nothing is red, TRAPS 73's
signature again.

**WHAT THE WORDING DOES BUY, WITH NO DENOMINATOR ANYWHERE, IS THE NEIGHBOUR:
two probes of one row that measure the SAME fault.** That was as silent as
deletion and left no count behind either. It is now an arithmetic over two
numbers **both counted as the probes fire** — distinct row/refusal pairs
against probes — so nothing has to be edited when a probe is legitimately
added or removed, which is the test 088 set for a closure.

**Measured, each fault alone** (TRAPS 80), against the **committed 088 file**,
this suite run alone in a throwaway copy with its own `config/name`
(TRAPS 50). Control **265/0** before and **293/0** after.

| fault injected | before 089 | after 089 |
|---|---|---|
| the `EQUIP` row's second probe pointed at the same empty parameters as its first | **265, failures=0 — SILENT**, and the count did not move at all | 293, failures=**1**, with both numbers in the message |
| the dungeon build moved below the `ORDER` row's second probe, so both probes drew *"there is nobody to order about"* | **265, failures=0 — SILENT**, count unmoved | 293, failures=**1** |
| `_finish_nothing` made to write `reasons = []` — seven controller refusals name nothing | **265, failures=0 — SILENT** (and `command_schema_test` **149, failures=0 — SILENT**) | 293, failures=**7**, each by name |
| the `EQUIP` no-tool refusal alone made to write `reasons = []` | **265, failures=0 — SILENT** (and `command_schema_test` **149/0**) | 293, failures=**3** |
| `_finish_nothing` made to write `reasons = [""]` — a blank sentence | 265, failures=0 here; `command_schema_test` **149, failures=12** | 293, failures=**7** |
| ONE of the TWO probes for the `EQUIP` row deleted (088's own limit) | 265, failures=0 | **289, failures=0 — STILL SILENT** |
| a `REACHABLE` row's text reworded in the table only (088's guard) | — | 291, failures=**3**, still firing |

**AND THE TWO SUITES EACH HELD HALF OF ONE PROPERTY, WHICH IS WHY NEITHER
NOTICED.** `command_schema_test` walks each record's reasons and asserts that
**no reason is the empty string**; an empty *list* has no elements, so the loop
body never runs and the check passes — **TRAPS 75's shape inside an
assertion**, where zero is read as a pass. `controller_reach_test` asserted the
category and the command and never looked at the sentence at all. So *"a blank
sentence"* was caught and *"no sentence"* was not, and the half that was
missing is the one a player meets as a refusal with nothing under it. The new
check in `controller_reach_test` holds **both** shapes, because they are one
class and one line apart (TRAPS 11).

**One claim this session wrote was wrong before it was checked, and is
recorded rather than tidied away.** The predicted count was 265 -> 288, from
21 probes gaining a sentence check. The run said **292**. The reason is that
`_reaches()` is called **25** times, not 21: the four calls inside the GUARD
fixtures of sections 3 and 4 drive refusals too, and the sentence check is in
`_reaches()`. The prediction had counted the probes that *claim* a row instead
of the probes that *fire* one. Nothing was adjusted to match; the gap was read
off the file (`grep -c "await _reaches("` = 25) before anything else was
written.

**Do:**

- **The key that tells two things apart is not the number that says how many
  there should be.** A signature read off the record closes "these two measure
  the same thing". Only a denominator closes "one of them is gone". Do not
  accept the first as the second.
- **Before deriving a count off the code, ask where the sentences are MADE.**
  A door that composes its own refusal can be counted at the door. A door that
  passes a validator's errors through cannot: the validator's set is larger
  than the subset that door reaches, which is TRAPS 47's reachability question
  one layer in. Both shapes sat in the same two-member class here.
- **An assertion that walks a list cannot speak for an empty list.** `for x in
  xs: check(x)` is green on `[]`. If the property is *"there is something, and
  it is sound"*, both halves have to be written down.
- **Hold a property where its absence does damage, not only where it is
  convenient.** "A refusal names what was wrong" is the repository's own rule
  and it had a reader at one door's worth of malformed requests and at none of
  the controller's 28 branches.
- **A guard you have not seen fail is a guard you have not tested (TRAPS 6).**
  Both halves of the new check were injected and run — an empty list and a
  blank sentence — before either was believed.
- **Ask the second file rather than copying the machinery into it.**
  `refusal_reach_test` asserts `fired.size() == wanted.size()`, so every row
  there is driven exactly once and the duplicate-probe class is **empty** in
  that file. Read off its `_driven_coverage()` in this session rather than
  carried forward from 088's commit message (TRAPS 14). Nothing was added
  there, because machinery for a class with no members is what 084 and 085
  each weighed and declined.

Found in 089, by doing the reading 088 left as the live next action and then
asking what the key it turned up could and could not hold.
**Nothing in `scripts/`, `scenes/`, `netlify/`, `.github/`, either runner,
`project.godot` or `export_presets.web.cfg` was touched**, read off
`git status` rather than assumed. The prompt is byte-identical and
`PROMPT_VERSION` did not move. **Nothing a player meets changed** — the
unnamed refusal was INJECTED to measure the gap and the product writes its
sentences today, exactly as it did before this commit.

> Two probes that say the same thing are one probe. Nothing in the record says
> there should have been two.

---

## 87. A row keyed by call site, and the thirty sentences behind it that nobody had counted

**The rule it produced: when one row of a table stands for a function that can
refuse in several different sentences, the row says nothing about how many of
those sentences anything drives — so count them off the code and measure which
are reached, because "the row is covered" and "the refusals under it are
covered" are different claims and the first one hides the second.**

### What was asked, and why it was a reading before it was a change

089 left the live next action as a question about what
`controller_reach_test`'s table is *for*: should its rows be keyed by the
**refusal sentence** rather than by the **call site**? It came with its own
argument against re-keying — several rows are sites that pass a validator's
whole error set through, so keying by sentence would replace 28 rows with a
class three to five times larger, most of it `refusal_reach_test`'s to answer
for — and with an instruction: do the reading, say so either way, and **if the
answer is "the table is right as it is", write that in the file beside the
table so the next session does not re-ask it.**

**THE ANSWER IS "LEAVE IT KEYED BY SITE", and it is written beside the table.**
What the reading bought is not a re-key. It is the arithmetic nobody had done.

### The measurement, which is an execution sweep and not a reading of the code

Every sentence site in the four delegating producers was **instrumented in a
throwaway copy** — each one made to write a marker file naming itself when it
executed — and **all 74 suites were then run one at a time**, with the markers
cleared before each, so the result is per suite and per sentence. Counted off
the code with comment lines blanked (TRAPS 64), the producers behind the
delegating rows make:

| row | its producer | sentences | probed before 090 |
|---|---|---|---|
| `ORDER: the goal does not check out` | `NpcGoals.validate` | **10** | 2 |
| `SHUT/OPEN: the door does not check out` | `NpcGoals.validate_door` | **5** | 1 |
| `EQUIP: the tool's own spec is out of bounds` | the three tools' `validate` | **17** (boots 6, car 5, look 6) | 1 |
| `EQUIP: no tool named, or a tool the game lacks` | composed at the site | **2** | 2 |

**AND TWO OF THOSE NUMBERS WERE WRONG IN HANDOVER, WHICH IS WHY THE UNIT IS
WRITTEN DOWN HERE.** 089's table said `validate_door` makes **6** and the tools
**5/4/3**. Recounted off the code: `validate_door` makes **five** sentences —
three `errors.append` sites and two inline `return`s — and the tools make
**6/5/6**, because 089 counted only the `errors.append` lines inside
`validate()` and those three functions each also refuse through an inline
`return [spec_error()]`, while `_bounded()` and `trouble_with()` each produce
several sentences from one call. Neither correction changes 089's conclusion;
both are recorded rather than tidied away, because a count in a document is
TRAPS 24's shape and the unit it is counted in was never stated.

### The finding: eight of the thirty-one sentences were held by nothing

Of the 32 sentences, 31 are blankable one at a time (the 32nd is the append of
`trouble_with`'s three, which shares a line). **Each was made to say nothing —
one at a time, in a throwaway copy with its own `config/name`, against the
committed 089 tree (TRAPS 50, TRAPS 80)** — and the suites that execute it were
run, plus every suite that reads `scripts/` as text. **The instrumented copy
with no site selected is byte-identical to the uninstrumented control**, so the
instrumentation itself holds nothing.

**EIGHT WERE SILENT.** Four of them were reached by **no suite at all**, and
all four are reachable by a legal request — each was sent through `main.gd`
this session and the record read, not argued from the code:

| sentence | reached by | blanked, before 090 |
|---|---|---|
| `an order needs a goal (it has go_to, carry)` | **nothing** | SILENT |
| `carrying needs something to carry (this dungeon has lamp)` | **nothing** | SILENT |
| `a door joins two different rooms` | **nothing** | SILENT |
| `'...' is only 8 by 8, which is too small to be a face` | **nothing** | SILENT |
| `'x' is not something a character can be asked to do` | `order_test` | SILENT |
| `this dungeon has 3 rooms, so there is no room 9` | `container_door_test`, `procedure_test` | SILENT |
| `there is nothing to carry in this dungeon` | `carry_test` | SILENT |
| `a door is named by the two rooms it joins, for example ...` | `panel_refused_test` | SILENT |

The second four are the sharper half of the lesson: **a suite drove the
sentence and asserted only that the refusal happened.** `carry_test` sends a
carry order into an empty dungeon and checks `ok == false`; `order_test` sends
an invented goal and checks the same. Execution is not holding.

### What was changed, and what was deliberately not

**Three probes in `controller_reach_test` and one in `look_test`** — the four
sentences nothing executed. The three new probes go on the two delegating rows
they belong to, which is what makes them the fix rather than a re-key: the row
stays keyed by site and 089's own arithmetic ties them, because each draws a
**different** refusal and the suite asserts distinct row/refusal pairs against
probes. In `look_test` the picture too small to be a face is the third of
`trouble_with`'s three sentences; the file held two of them, which is TRAPS 11
at the scale of three adjacent lines, and the three are now asserted to be
three **different** sentences each of which says something.

**THE OTHER FOUR WERE NOT CLOSED AND THE REASON IS WRITTEN RATHER THAN
IMPLIED.** Each needs a sentence assertion inside a suite whose subject is
something else — `carry_test` is about an errand, `panel_refused_test` about a
panel — and the honest fix for the class is not four more assertions but one
reader that drives every sentence a delegating validator can make and asserts
each says something distinct, with its count read **off** the producers rather
than written beside them. That is a suite, it is in HANDOVER's next action with
this arithmetic, and 090 did not build it on the way past.

### Measured, each fault alone, controls stated

Against the committed 089 tree: `controller_reach_test` **293/0**, `look_test`
**18/0**, `order_test` **18/0**, `carry_test` **21/0**. After 090: **305/0** and
**23/0**, the others unmoved.

| fault | before 090 | after 090 |
|---|---|---|
| `an order needs a goal` made to say nothing | 293/0 and `order_test` 18/0 — **SILENT** | 305, failures=**1** |
| `carrying needs something to carry` made to say nothing | 293/0 and `carry_test` 21/0 — **SILENT** | 305, failures=**1** |
| `a door joins two different rooms` made to say nothing | 293/0 — **SILENT** | 305, failures=**1** |
| `too small to be a face` made to say nothing | `look_test` 18/0 — **SILENT** | 23, failures=**1** |
| `is not a picture this game can read` made to say nothing | `look_test` 18/0 — **SILENT** | 23, failures=**1** |
| the new ORDER probe pointed at an existing probe's request | — (090's own code) | 305, failures=**1** |

### Two limits, both injected after the fix was green

- **A ROW THAT CARRIES SEVERAL PROBES CAN STILL LOSE ONE IN SILENCE**, which is
  088's limit re-measured rather than carried forward (TRAPS 14): delete one of
  090's three new probes and the suite is **301 assertions, failures=0** — the
  count falls by four and nothing is red, TRAPS 73's signature. **090 made this
  class larger**, three multiply-probed rows where there were two, which is a
  cost of its own and is written into the function that has it.
- **`look_test`'s DISTINCTNESS CHECK HOLDS "TOLD APART", NOT "TOLD CORRECTLY".**
  Injected: `trouble_with`'s "not a picture" sentence made to read *"is only 0
  by 0, which is too small to be a face"*. The suite is **23 assertions,
  failures=0** — correctly, because the two sentences still differ (the path
  in each differs), and distinctness is the property asserted. Naming the right
  fault is not something a distinctness check can hold, and no assertion was
  added pretending otherwise.

Found in 090, by doing the reading 089 left as the live next action and
counting what the answer was about.
**Nothing in `scripts/`, `scenes/`, `netlify/`, `.github/`, either runner,
`project.godot` or `export_presets.web.cfg` was touched**, read off
`git status` rather than assumed. **Nothing a player meets changed**: all four
sentences are written today exactly as they were before this commit, and all
four were already correct when driven — what was missing is anything that would
notice if they stopped being.

> A row that stands for ten sentences is covered by two probes and tells you
> nothing about the other eight. Count them.

---

## 88. Ten rows that said a refusal fired, and the seven whose refusal could say nothing

**Signature:** make any one of the three world modules refuse with an **empty**
`reasons` array — a player is told a build failed and told nothing about why —
and `refusal_reach_test`, the suite written to answer *"does each of these
refusals fire?"*, is **206 assertions, failures=0** for every one of the twelve
places that can do it. For **seven of the twelve**, nothing anywhere else in
the repository notices either.

**Cause.** 089 found that `controller_reach_test` asserted a refusal's
*category* and never its *sentence*, and closed it for the controller's 28
branches (TRAPS 86). Its "Do" list ended with **"ask the second file rather
than copying the machinery into it"**, and the question it asked of
`refusal_reach_test` was the narrow one — whether that file had 088's
duplicate-probe class, which it does not. **The wider question was written into
HANDOVER as the next action and not asked**: `_fires(category, verdict)` in
that file takes the category and the declared verdict, and **never looks at
`reasons` at all**. So the modules' ten MODULE rows were held exactly as the
controller's 28 were before 089 — TRAPS 11, one file at a time, with the entry
that names the class sitting in HANDOVER for two sessions.

**THE UNIT, WRITTEN DOWN BEFORE THE COUNT (TRAPS 24, TRAPS 77).** A **MODULE
REFUSAL SITE** is one place in `scripts/` that puts a non-empty `reasons` array
into a refusal whose category is one of the ten MODULE rows this suite
declares. There are **twelve** sites behind the ten rows, because
`FAILED_LAYOUT` is one row over three branches in two files. Counted off the
code, then each one measured — not read off it.

**THE MEASUREMENT: EACH SITE BLANKED ALONE, THE WHOLE SUITE RUN AGAINST IT.**
Twelve throwaway copies, each with its own `config/name` (TRAPS 50), each with
exactly one site's `reasons` emptied and nothing else changed (the diffs were
read before the runs), each run with `--all` and compared against a control
copy built the same way. **The control was byte-identical to the md5 090
recorded** — `a7809dc41e9adb8d963da70255bdc42d` — so the copying holds nothing
of its own.

| site | the row it is behind | what noticed | verdict |
|---|---|---|---|
| `dungeon pre_check` | `FAILED_UNREACHABLE` | nothing | **SILENT** |
| `dungeon solve` | `FAILED_PLACEMENT` | `agreement_test` (1) | caught |
| `dungeon post_check`, crossings | `FAILED_CORRIDOR` | nothing | **SILENT** |
| `dungeon post_check`, walkable | `FAILED_UNWALKABLE` | nothing | **SILENT** |
| `dungeon post_check`, extent | `FAILED_TOO_BIG` | nothing | **SILENT** |
| `farm solve`, no zones | `FAILED_LAYOUT` br. 1 | nothing | **SILENT** |
| `farm solve`, lane passthrough | `FAILED_LAYOUT` br. 2 | nothing | **SILENT** |
| `world_module solve` | `FAILED_LAYOUT` br. 3 | nothing | **SILENT** |
| `FeasibilityGate`, composition | `FAILED_DEGREES_OF_FREEDOM` | `agreement_test` (3), `counted_said_test` (2), `prompt_bounds_test` (2) | caught |
| `FeasibilityGate`, net turn | `FAILED_INFEASIBLE` | `prompt_bounds_test` (1), `said_set_test` (1) | caught |
| `racing solve` | `FAILED_CLOSURE` | `said_set_test` (2) | caught |
| `SeparationCheck` | `FAILED_SEPARATION` | nothing | **SILENT** |

**THE SHAPE OF THAT COLUMN IS THE PART WORTH READING.** Not one of the five
catches was a suite asking whether a refusal says anything. Read off the four
suites rather than inferred from the counts: `said_set_test`,
`counted_said_test` and `prompt_bounds_test` read the **racing** sentences for
a plural, a noun or a number that the racing **prompt** also states, so they go
red when the sentence is gone; and `agreement_test` is a **source scan** that
asserts `Readback.plural(MAX_RING, "ring")` occurs exactly once in
`dungeon_module.gd`, which is why deleting `FAILED_PLACEMENT`'s two sentences
registers at all — it is the plural idiom being counted, not the refusal being
read. **The whole of the dungeon and the whole of the farm are otherwise
silent.** The property was held **by accident, where it was held at all**.

**THE FIX IS IN THE FUNNEL, NOT AT THE DOORS.** `_fires` is the one function
every row's claim goes through, so the check goes there and the whole class is
held at once rather than nine rows of it (TRAPS 11). It takes `said`, a
Dictionary of **one reasons array per PLACE behind the row, keyed by that
place's name**:

- one entry for the nine rows with a single producing place;
- **three** for `FAILED_LAYOUT`, collected by `_layout_branch()`, which is now
  the only way a branch is recorded as fired, so a name cannot be appended with
  nothing read off it.

**Keyed by place and not flattened into one array, on purpose.** A flattened
array stays non-empty while one branch of three falls silent, which is exactly
the shape 085 measured in a tally that counts rows. Keyed, the failure **names
the branch**: `farm: nothing to lay out: the refusal it drove says something`.

The predicate is **byte-identical to 089's `_says_something` in
`controller_reach_test`**, checked with a diff and not by eye. One class, one
shape: a second shape for the same question is how two files came to hold half
a property each, which is the fault 089 found.

**Measured, each fault alone** (TRAPS 80), against the **final** suite, run
alone in a throwaway copy with its own `config/name` and its own import pass.
Control **219/0** before each.

| fault injected | result |
|---|---|
| each of the eleven blankable sites in turn (all but the lane passthrough) | **219, failures=1**, naming the row or the branch |
| `farm solve`'s lane passthrough blanked | **219, failures=0 — STILL SILENT** (see below) |
| `FAILED_UNREACHABLE`'s two sentences replaced by `[""]` | 219, failures=**1**, `reasons: [""]` |
| `farm: nothing to lay out` made to say `["  "]` | 219, failures=**1**, `reasons: ["  "]` |
| `FAILED_TOO_BIG`'s `_fires` call deleted (088's shape, **re-measured** here rather than carried forward) | **215, failures=2**, by name and by count |
| `base: no solver` recorded with a bare `layout_fired.append` again | **218, failures=1**, naming the arrays out of step |
| `FAILED_TOO_BIG` made to refuse with *"this dungeon is a perfectly reasonable size"* | **219, failures=0 — SILENT**, and correctly: see the limit below |

**WHAT IT DOES NOT HOLD, MEASURED AND NOT INFERRED.**

- **"Says something" is not "says the right thing".** The wrong-sentence
  injection above is green, because the sentence is there and it is not blank.
  This is 089's limit in the sibling file and no assertion was added pretending
  otherwise. What holds the *content* of these sentences is the handful of
  suites in the table's third column, for the racing prompt's wording only.
- **One of the seven silent sites is still silent and it cannot be closed from
  this suite.** `farm_module.solve()` passes `_check_reachable()`'s reasons
  through, and **no fixture can hand `solve()` a pinched layout** — it lays the
  zones out itself and throws the request's coordinates away. The suite drives
  that branch at `_check_reachable` instead and says so in its own comment. The
  branch's refusal **is** held, at the place it can be reached; the
  passthrough line is not, and moving the check into `post_check()` is the
  owner's call and already in HANDOVER.

**One thing this session got wrong and is recorded rather than tidied away.**
The first blank-sentence injection reported the fault it was looking for and
was measuring the wrong line: the substitution replaced the **first**
`"reasons": []` in `dungeon_module.gd`, which is a **successful** return 200
lines above the site. It was found because the FAIL line printed `reasons: []`
where `[""]` was expected — the message named what it read, which is the only
reason the wrong measurement did not become a recorded one. **And a second:**
the first run of a freshly copied project reported three failures instead of
one. Without the import pass `run_tests.sh` does first,
`DirAccess.open("res://scripts")` returns null, `_sites_in_code()` comes back
empty, and two assertions that read `scripts/` fail for a reason that has
nothing to do with the injected fault. Every measurement in the tables above
was re-taken with an import pass of its own.

**Do:**

- **When a session writes "and the same question should be asked of the other
  file" into the handover, that is the task, not a note.** It sat for two
  sessions while two commits worked on the file that had already been fixed.
  089 even wrote the instruction down — *ask the second file* — and asked it
  the narrow question it had in hand.
- **Put the check in the funnel every claim goes through.** One line inside
  `_fires` holds ten rows; ten lines beside ten fixtures hold ten rows until
  the eleventh arrives without one.
- **A row that stands for several places needs one reading per place, keyed by
  the place.** Flatten them and the row stays green while one place falls
  silent; key them and the failure says which.
- **Count the sites before measuring them, and write down what a site is.**
  "Ten rows" and "twelve places" are different numbers for the same class, and
  the gap is entirely `FAILED_LAYOUT`'s three branches.
- **A measurement whose injection you did not read is not a measurement.** Two
  of the ones above were wrong on their first take, and both were caught by
  reading what the failure message *said* against what was injected.

Found in 091, by taking the third live entry in HANDOVER — *"`refusal_reach_test`
does not check that a module's refusal says anything. IT WAS NOT MEASURED, and
that is the first step"* — and measuring it first.
**Nothing in `scripts/`, `scenes/`, `netlify/`, `.github/`, either runner,
`project.godot` or `export_presets.web.cfg` was touched**, read off
`git status` rather than assumed. **Nothing a player meets changed**: every one
of the twelve sentences is written today exactly as it was before this commit,
and all twelve were already correct when driven — the empty arrays were
INJECTED to measure what would notice.

> Ten rows said a refusal fired. Seven of them could have fired with nothing
> in it.

---

## 89. A rule read out of this file, applied over a convention the project had already settled

**Signature:** a session cites a TRAPS number as the reason it did *not* do
something, writes a careful comment explaining the general principle, and a
suite that has held the opposite rule for twenty-odd commits goes red on the
first full run.

**Cause.** 092 needed to read the `match` arms of `_friendly_http_error` out
of `ai_interpreter.gd`. Every other suite in `tests/` that reads `.gd` source
strips comments through a function called `_code_of()`, and each of them
**defines its own byte-identical copy**, because — as `source_scan_test`'s own
header says in so many words — *there is no shared library in `tests/`; every
suite stands alone, which is this project's convention.*

092 did not read that header. It reasoned instead from **TRAPS 86** — *two
files came to hold half a property each because one wrote a second shape of
the other's predicate* — concluded that a second copy of `_code_of()` was
exactly the trap 86 warns about, and wrote a narrower pattern-match with a
comment saying so: *"which is why there is no second copy of another suite's
comment stripper here (TRAPS 86)"*. The comment is wrong, and it is wrong in
the most confident available form: it cites a rule by number.

`source_scan_test` caught it on the first `--all` run, **by name, in two
sentences that say what to do**: *"a file in `tests/` scans this project's
source and has no `_code_of()` at all, so a comment can answer its
questions: `retry_test.gd`"* and *"every file that scans source defines
`_code_of()` itself, because `tests/` has no shared library"*. The prediction
written before that run said only `retry_test` would move, and was wrong.

**The two rules are not in conflict and reading either file would have shown
it.** TRAPS 86 is about two *different* shapes of one predicate drifting
apart. The convention here is **byte-identical** copies, and `source_scan_test`
asserts that byte-identity across all of them — so the thing 86 fears is the
thing this convention is built to prevent. A principle and its implementation
were mistaken for each other.

**Do:**

- **Before citing a TRAPS number as a reason not to do something, grep for
  whether the project already does it.** A rule in this file is a lesson from
  one commit, not a licence to overrule a convention twenty commits have kept.
  The same discipline TRAPS 14 demands of a *limitation* — grep for the thing
  the sentence denies — applies to a *justification*.
- **Write the prediction down before the run anyway.** It was wrong, and that
  is what made the gap legible: a diff of two lines where one was forecast is
  a finding, and a diff nobody forecast is just an outcome.
- **When a suite fails by name and its message says what to do, do that**
  before re-deriving it. `source_scan_test` named the file, named the missing
  function and gave the reason in the same breath.
- **A convention is findable.** It was in the header of the suite that failed,
  three paragraphs long, under the words "WHAT THIS FILE HOLDS".

Found in 092, in its own first full run, against itself.
**Nothing in `scripts/`, `scenes/`, `netlify/`, `.github/`, either runner,
`project.godot` or `export_presets.web.cfg` was touched.**

> The comment explaining why the copy was not made cited a rule by number.
> The rule said the opposite of what the project does.

---

## 90. An exclusion written down honestly, and left standing for twenty-six commits

**Signature:** a suite reads a file that is not GDScript and asserts things
about what it is written to do. Its header says, correctly and in writing, why
the project's comment-stripping reader is the wrong one for that file — and
then reads the raw text anyway. Every one of those reads is answerable by a
comment, and the suite is green.

**Cause:** 067 asked TRAPS 11's question of every source scan in `tests/` —
how many of these can a comment answer — found nine members, measured three
silent and fixed them. It did the honest thing about the one file its reader
did not fit: `netlify/functions/interpret.js` uses `//`, `_code_of()` strips
`#`, so it wrote the exclusion into `source_scan_test`'s header, *"and nothing
about them was measured in 067"*, and into `proxy_test`'s own comment beside
the reads.

**Nothing came back to it.** The sentence was true, it was visible, it named
the gap precisely, and it sat there for twenty-six commits while five
assertions about a *deployed* function rested on it. A stated exclusion reads
like a closed question. It is an open one with a note attached.

**What it was holding up, measured in 093 one fault at a time, each alone in
its own copy with its own `config/name`, the diff read before each run,
against an unpatched control of 26 assertions, failures=0:**

```
the key read pointed at a DIFFERENT env var, old name left in a comment   26/0  SILENT
MAX_BODY and the whole 413 branch DELETED, cap left in a comment          26/0  SILENT
the POST guard DELETED, "POST only" left in a comment                     26/0  SILENT
the field allowlist replaced by `body = sent`, names left in a comment    26/0  SILENT
```

The first was then run through the **whole 74-suite set with `--all`**: the
output was **byte-identical to the baseline**. Nothing in Genesis noticed that
the function reads a different environment variable from the one Genesis tells
a web player to check — the drift 057 built that sentence to make impossible.
The last replaces the field allowlist with `body = sent`, which is the open
relay the file's own header says it must never be: *"a function that forwards
whatever it is handed is an open relay with somebody's credit card behind
it."*

**Do:**

- **A stated exclusion is a live entry, not a closed one.** When a reason is
  written down for not checking something, it belongs where the next session
  reads what is still open, not only beside the check it excuses. 067's note
  was honest and that is exactly why nobody re-read it.
- **The direction decides the reader, and a blanket fix breaks the one read
  that was already right.** Of the five reads, four ask what the code DOES and
  belong behind a stripper; the fifth asks whether a key is MENTIONED
  ANYWHERE, and a key in a comment is still a published key. Measured: a fake
  `AIza`-prefixed key in a comment gives **failures=1** on the raw read and
  would pass in silence through the stripper. Applying "scan code, not
  comments" to all five would have *introduced* a fault while fixing four.
  That is `source_scan_test`'s own DIRECTION rule, and it is the reason it is
  phrased as a direction and not as a habit.
- **Name the second reader so it cannot answer the first one's question.**
  `source_scan_test` decides a file has a reader of its own by grepping for
  the substring `_code_of(`. A function called `_js_code_of` **contains that
  substring**, so a file carrying only it would satisfy that check while
  having no `_code_of()` at all. It is called `_js_without_comments()` for
  that reason, and the reason is written beside it.

**And the new check has the same derived-count limit, written down rather than
discovered later.** It reads the statuses off `interpret.js` and drives each,
so a status *removed* from the function takes two assertions with it: change
`status: 413` to a status the file already returns and `proxy_test` is **42
assertions, failures=0** against a control of **44/0** — TRAPS 73's signature,
a count that falls in silence. That is the same limit 092 recorded about its
own arm reader, and the same answer applies: a declared list of required
statuses would be TRAPS 82's shape and would have to be moved by hand every
time the function legitimately changed. **Recorded as an open limit, not as a
fix.**

Found in 093, by following 092's own "Next action" to its answer and reading
what was beside it.
**Nothing in `scripts/`, `scenes/`, `netlify/`, `.github/`, either runner,
`project.godot` or `export_presets.web.cfg` was touched.**

> The reader did not fit the file, so the suite read the raw text and said so.
> The note was true for twenty-six commits and held nothing for any of them.

---

## 91. The condition could not be written as a list, and the subject was already declaring it

**The rule it produced: when a property must hold for some cases and not
others, and you cannot say in advance which, look for a field the subject
already sets to declare what it is — and hold it to that. A list of "these
ones must" is a second label beside the code (TRAPS 82); a flag the code
itself writes is a measurement. But a sweep keyed off that flag is bounded by
what the run actually drives, so count the requests as well as the records.**

### What was open, and why it stayed open for two commits

089 measured it and left it. `command_schema_test` walks each record's reasons
and asserts that none is the empty string; **an empty LIST has no elements, so
the loop body never runs and the check passes** — TRAPS 75's shape inside an
assertion. With `_finish_nothing` writing `reasons = []`, seven of the
controller's refusals tell a player nothing at all and this suite is **149
assertions, failures=0**, while the same file catches `reasons = [""]` with
**12** failures. The full table is in TRAPS 86.

**Re-measured in 094 against the committed 093 tree rather than carried
forward** (TRAPS 14): `_finish_nothing` writing `[]`, the pre-change suite is
**149 assertions, failures=0** — still silent, exactly as recorded.

Both 089 and 090 declined to close it, and the reason was good. This suite
**cannot demand that every probe refuse**: three of these commands build
nothing whatever they are sent, which its own header says, so a bare non-empty
assertion per probe is a false alarm on correct code. The obvious alternative
is a list of which probes must refuse, which is a number written beside the
table rather than read off it.

### The thing that dissolved it, which 090 found by reading and did not build

**The condition does not have to be stated. It is already in the record.** A
record whose `category` begins with `FAILED_` has refused, **by its own
report**, and a refusal carrying no sentence is the fault. A command that
answers some other way never writes such a record and is never asked a
question. Nothing is written down beside the probes, and nothing has to move
when a probe is legitimately added or removed.

### Measured before it was asserted, because an invariant argued for is a guard over an assumption (TRAPS 6)

**THE LEDGER, over every record every suite writes.** All 74 suites were run
one at a time with the lines each appended to `user://track_log.jsonl`
captured per suite: **671 records, 146 of them `FAILED_`, eight distinct
`FAILED_` categories, and ZERO carrying no sentence.** 36 of the 146 are
`command_schema_test`'s own run, which is where the new assertion count comes
from — counted, not guessed.

| category | records | silent |
|---|---|---|
| `FAILED_SCHEMA` | 87 | 0 |
| `FAILED_SCENE` | 31 | 0 |
| `FAILED_NOTHING_BUILT` | 15 | 0 |
| `FAILED_CLOSURE` | 4 | 0 |
| `FAILED_PARSE` | 4 | 0 |
| `FAILED_UNWALKABLE` | 3 | 0 |
| `FAILED_AI` | 1 | 0 |
| `FAILED_NO_HANDLER` | 1 | 0 |

**THE PRODUCERS, read off the code.** All **37** places in `scripts/` that
write `"ok": false` were read one at a time. **Twenty-six carry an `errors` or
`reasons` array**, and every one of those is either a **literal non-empty
array**, guarded by `if not <list>.is_empty()`, or returns a list whose own
`ok` was **derived from `<list>.is_empty()`** — so no validator in Genesis can
answer `ok=false` with nothing to say today. **The other eleven are a
different shape, counted rather than waved at**: four `{"ok": false}` internal
signals in `_prepare_world`, written after `_finish_failed` has already put the
record in the ledger; six `WorldStore` returns carrying a `"message"` that
never becomes a record's reasons; and `CommandParser.parse`'s result
**initializer**, which is not a return at all and whose refusal travels as one
`"error"` string. **So the new assertion is a guard against drift and not a
fault-finder, and saying otherwise would be a claim this session cannot
make** — and the eleventh is where the finding under its own heading below
came from.


### Measured, each fault alone, in its own copy with its own `config/name`

TRAPS 50, TRAPS 80, each copy given its own `--headless --import` (TRAPS 88),
every diff read before its run. Control **186 assertions, failures=0**.

| injection | before 094 | after 094 |
|---|---|---|
| `_finish_nothing` writes `reasons = []` | **149/0 — SILENT** | 186, failures=**14**, each named |
| `_finish_failed` writes `reasons = []` | 149/0 | 186, failures=**44** |
| `_finish_nothing` writes `reasons = [""]` | 149, failures=12 | 186, failures=**26** |
| the sweep's scope broken so it reads no records | — (094's own code) | **150**, failures=**1**, naming both numbers |
| `NpcGoals.validate` answers `ok=false` with `errors = []` | — | **186/0 — SILENT HERE**, and `controller_reach_test` **305, failures=4** |

**AND THE CATCH IS ATTRIBUTED RATHER THAN ASSUMED.** The predicate has two
halves — there IS a sentence, and it is not blank. With the first half removed
and the `[]` fault in place, the suite is **186 assertions, failures=0**: the
non-empty half is precisely what does the work, measured rather than argued.

### The limit, which is the second half of the rule and was found by injecting against it

**A SWEEP OVER THE RECORDS A RUN PRODUCES IS BOUNDED BY THE REQUESTS THE RUN
SENDS.** The fifth row above is the one worth keeping. A validator made to
refuse with nothing to say is **invisible to this suite**, and the reason is
not the sweep: it is the probe table. `ORDER`, `SHUT`, `OPEN`, `EQUIP`,
`CLEAR_WORLD` and the three `CREATE_` commands all carry `"fields": []`, so
this suite sends them **only sound requests** and their validators' refusal
paths are never driven at all. The sweep reads 36 records and is wide over
every one of them; the class it can speak for is the one the table drives.
That door is held in `controller_reach_test`, which drives those branches and
caught the same injection at **305, failures=4** — so the property is held
across three files (`controller_reach_test` for the controller's 28 branches,
`refusal_reach_test` for the modules' twelve, this file for the malformed-field
class per whitelisted command) and **no machinery was copied between them**.
This is TRAPS 47's reachability question one layer in, asked of a sweep instead
of a check.

**And the per-record count is derived, so it can fall.** If the probes stop
refusing, the 36 assertions go with them — TRAPS 73's signature. That is why
`schema_refusals` is counted **as the probes fire** and the sweep asserts it
read at least that many: the fourth row above is that assertion failing, with
both numbers in the message.

### AND THE ELEVENTH RETURN HAD A REFUSAL WITH NOTHING IN IT BEHIND IT, REACHABLE TODAY, HELD BY NOTHING

**This is a fault in the product and it is NOT fixed in 094.** It was found by
reading the one `"ok": false` site that is not a validator, and it was
**driven** rather than argued — sent through `main.gd` in a throwaway copy and
the record read off the ledger:

| what the AI answers | `parse()`'s `error` | the record's `reasons` |
|---|---|---|
| `{"command": "UNSUPPORTED", "parameters": {"reason": ""}}` | `""` | **`[""]`** |
| `{"command": "UNSUPPORTED", "parameters": {"reason": "   "}}` | `"   "` | whitespace only |
| `{"command": "UNSUPPORTED", "parameters": {"reason": null}}` | `"<null>"` | **`["<null>"]`** |
| `{"command": "UNSUPPORTED", "parameters": {}}` | `"no reason given"` | correct |
| `{"command": "UNSUPPORTED"}` | `"no reason given"` | correct |

**THE CAUSE IS THE DEFAULT, AND IT IS THE WHOLE RULE.**
`str(data["parameters"].get("reason", reason))` substitutes *"no reason given"*
when the key is **ABSENT**. It does nothing when the key is **PRESENT AND
EMPTY**, and `str(null)` in GDScript is the six-character string `<null>`. So
the one refusal a player meets when Genesis says it cannot do something at all
can arrive blank, or can read `<null>`.

**NOTHING HOLDS IT, grepped rather than assumed.** Eight files in `tests/`
name `UNSUPPORTED`. `controller_reach_test` counts the **site** in `main.gd`
and says in its own message that it is not a `FAILED_` category;
`check_wiring_test` asserts the record carries a quarrel with the refusal;
`session_test` sends one with the reason `"no boats"`. **No suite sends an
empty one and no suite reads that record's sentence.**

**AND 094'S OWN NEW SWEEP DOES NOT CATCH IT**, which is the honest reason it
is written here as a finding and not as a fix: the category of that record is
`UNSUPPORTED`, not `FAILED_`, so the condition read off the record excludes it
by construction. Widening the condition would be an absence assertion over a
set this suite drives **zero** members of (TRAPS 75), so nothing was widened.

**AND IT IS NOT FIXED HERE BECAUSE THE CLASS HAS NOT BEEN ASKED (TRAPS 11).**
One grep for `get("<key>", "<string literal>")` found **thirteen** other code
sites in `scripts/` with that shape — the enumeration is in HANDOVER's first
live "Next action", and that number is **what the grep found and not the
class**, because the pattern cannot see a default held in a variable or spread
over two lines. For each the question is whether an empty or null value is
reachable and whether a player reads the result (TRAPS 47). Fixing the one found first and leaving the fifteen is the exact
shape this file has a trap about. The measurement above is the hard part and it
is done; the class sweep is the next session's first task.

Found in 094, by taking 090's second live "Next action" — a reading that had
been done and a change that had not been made — and doing the measurement it
named as the precondition before writing the assertion.
**Nothing in `scripts/`, `scenes/`, `netlify/`, `.github/`, either runner,
`project.godot` or `export_presets.web.cfg` was touched**, read off
`git status` rather than assumed. **Nothing a player meets changed**: every
refusal Genesis writes today says what it said before this commit, and what
was missing is anything that would notice if one stopped.

> A list of which cases must refuse is a label. The record saying "I refused"
> is a measurement. The sweep that reads it is still only as wide as the
> requests you send.

---

## 92. A guard that answers the empty string, where `str(null)` is six characters

**Signature:** a world is built, validated and recorded, with something in it
called `<null>`.

**Cause:** 094 found one default that answered a missing key and not a present
and empty one — `CommandParser`'s *"no reason given"* — wrote the general rule
down, and deliberately did not fix the instance (TRAPS 11). It handed over the
grep it had used, `get("<key>", "<string literal>")`, thirteen sites it had
found, and a warning in writing that **the number was what the grep found and
not the class**, because that pattern cannot see a default held in a variable
or spread over two lines.

095 widened the reading, and the widening found two things rather than one.

**The first was the one the entry predicted**: defaults held in an identifier
or an expression. `CommandParser`'s own fault is one of those —
`get("reason", reason)` — and `LookTool` reads `get("skin", DEFAULT_SKIN)`
twice. A parse of **every** `.get()` in `scripts/` (324 with a default, read
across line breaks, classified by the KIND of the default) finds them; a grep
for a quoted literal cannot.

**The second was not predicted by anything, and it is the trap.** There are
not two ways a text field can say nothing, there are four, and the fourth is
not an empty string at all:

| the value | `str()` of it | an `== ""` guard |
|---|---|---|
| absent | — | a default stands in, correctly |
| `""` | `""` | caught |
| `"   "` | `"   "` | caught **only if** the site stripped first |
| `null` | **`<null>`** | **passes straight through as a WORD** |

`str(null)` in GDScript is the six-character string `<null>`. So **a site
written `if label == ""` lets a null through as a name.** One grep for that
shape in `scripts/` returns 27 lines; the ones reading an AI-supplied text
field were read one at a time, and **five let a null through as a word,
measured by driving them** — the dungeon's room name and thing name, the track
readback's difficulty, and boots' and the car's nickname. A sixth of the same
shape, the thing label in the dungeon's own readback, was changed by the same
rule and is **not separately measured**, which is said rather than rounded up.
Every one of those sites has an **empty** default, which put them outside
094's grep class entirely. The two halves of the class do not overlap.

**What that cost, measured by driving the validators rather than reading them
(TRAPS 48), before a line was changed:**

| driven | before 095 |
|---|---|
| a dungeon whose room is named `null` | **`validate` ok=TRUE, and the room is KEPT as `<null>`** |
| a thing named `null` | **ok=TRUE, kept as `<null>`** — while a thing named `""` is correctly refused *"thing 1: no name"* one branch above it |
| boots or a car with `"nickname": null` | **ok=TRUE, kept, and said back as *"called `<null>`"*** |
| `TrackBuilder.readback` with `"difficulty": null` | *"to make corner 1 `<null>`"* |
| a boots/car/look spec whose colour, paint or skin is `""` | *"the ordinary&nbsp;&nbsp;boots"*, *"the ordinary&nbsp;&nbsp;car"*, *"a plain&nbsp;&nbsp;head"*, off the **refused-spec** readback path |
| `CommandParser`'s UNSUPPORTED reason, `""` or `null` | blank, or `<null>` — 094's finding, the same rule one site along |

**Nothing in `scripts/` or `tests/` contained the substring `<null>` at all**,
grepped rather than assumed, so nothing could have noticed any of it. A player
could be shown a room, a thing, a car and a pair of boots named after an engine
debug spelling, in a game whose whole thesis is that it says what it actually
did.

**And one of those rows was argued away in 095's own notes before the suite
found it.** The reading said the tools' text fields were safe from `null`
because `ToolRegistry._same_kind()` drops a value of the wrong type rather than
laying it over the defaults. That is **true of the refused-spec readback path
and false of the validator**, which reaches `str(asked["nickname"])` behind a
`has()` check and keeps the result. TRAPS 47 exactly — the door measured was
the one in front of the door that mattered — and it was caught because the
suite was written to drive the class rather than the five sites the reading had
convinced itself of.

**Do:**

- **Ask what a value that is PRESENT and says NOTHING means, and answer all
  four forms in one reader.** `Readback.said()` and `Readback.said_or()` are
  that reader, and they sit next to `Readback.measure()`, which has been the
  one reading for a *number* behind a key since 036. Genesis had the number
  half of this and not the text half, so thirteen readers each decided for
  themselves.
- **A reader is one reader even when the sites disagree about policy.**
  `said()` returns what a value *says* — stripped, or `""` when there is
  nothing there — so every site's existing `== ""` branch answers all four
  forms **without changing its own policy**: the dungeon still renames a
  nameless room `room_1`, still refuses a nameless thing, and the track
  readback still says *"to change corner 1"*. One reader, thirteen unchanged
  decisions. That is what makes a class fix smaller than thirteen instance
  fixes rather than larger.
- **`said_or()` returns a value that DOES say something exactly as it was
  sent**, edges and all. Every site using it is a readback, whose whole job is
  to show what was heard; tidying a player's words there would be TRAPS 8.
- **Assert the property, never the wording.** *"The readback says 'a room'"*
  passes against a site that was never fixed, because the absent key always
  said that. What `tests/says_nothing_test.gd` asserts is an **equality
  between measured outputs** — *a value that says nothing is answered exactly
  as an absent key is answered* — with the expected sentence taken from the
  same code in the same run by asking the same function with the key left out.
  A default whose wording legitimately changes moves nothing; a site that stops
  answering one of the four forms fails by name.
- **And add the assertion that needs no enumeration at all.** Collect every
  sentence the run produced and assert that none of them contains `<null>`.
  That one check would have caught all five sites without knowing what they
  were, and it has a denominator, because an empty collection passes it in
  silence (TRAPS 75).
- **Keep the rows keyed off the producer** (TRAPS 82). The tool rows are read
  off each tool's own `defaults()` — every key whose default is a String — so a
  tool that gains a text field is driven from the moment it gains it, and no
  list in the suite has to be moved by hand.

**What 095 deliberately did NOT change, so that the boundary is a stated one
and not a gap.** A value that says nothing and is **refused either way** —
`"mode": null` answered *"mode '`<null>`' is not available"*, `"goal": null`,
`"crop": null`, a colour or skin that is not on the whitelist — is a **refusal
quoting what was sent**, not a kept name, and its wording is the owner's. The
sites that KEEP a value, or SAY one back as Genesis's own, are the class this
commit closed. The refusal-wording half is named in HANDOVER with the
measurement beside it.

Found in 095, by taking the first live "Next action" and doing the widening it
asked for before trusting the count it carried. `tests/says_nothing_test.gd`
fails by name against eleven deliberate breakages, one at a time, each in its
own copy with its own `config/name`, against a control of 51 assertions and
no failures.

> A default answers a key that is not there. Four things can be there and say
> nothing, and in this language one of them is six characters long.

## 93. The claim was written in the same commit as the fix, and six sentences went on saying it

**Signature:** a document says a class is closed. The code says it is closed
at the sites somebody listed. Nothing had asked the class.

**Cause.** 095 did good work and wrote one sentence too wide. It found the
says-nothing class, built one reader for it (`Readback.said()`), fixed
thirteen sites, built a suite that drives the class rather than the sites —
and then wrote, in its commit message and in HANDOVER:

> a readback can no longer say `<null>` or leave a hole where a word should be

**That was false when it was written.** Five readback sites still said it, in
six distinct sentences:

| the sentence a player read, after 095 | where |
|---|---|
| *"a farm with a 40 m `<null>` and a 20 m barn"* | `farm_module.gd` readback, zone type |
| *"a farm with a 40 m `<null>` field and a 20 m barn"* | the same function, the crop |
| *"a farm with a 40 m wheat field and a 20 m `<null>`"* | the same site, second zone |
| *"...90 deg right and a `<null>`"* | `racing_module.gd` readback, section type |
| *"to shut the door between the `<null>` and the vault"* | `npc_goals.gd` `_side_said` |
| *"to have the `<null>` carried to room 2"* | `npc_goals.gd` `readback`, the thing |

Every one is the **same shape 095 fixed four times** — `str(x.get(k, ""))`
read into an `== ""` guard — at sites that were not on the list. A sixth
readback site, the carry readback's `room`, was changed by the same rule and
is **not** separately measured: a bare null is already answered *"somewhere"*
there, and only a null nested in what was sent reaches the quote. That shape is
**81 lines** of `scripts/` before 096 and 72 after, grepped both times rather
than remembered, so the class was never going to be closed by reading it site
by site; and 095's own entry
says, correctly, that its thirteen were *"what one grep found rather than the
class"*. The commit then described the class as closed anyway.

**And the refusal half was undercounted the same way.** HANDOVER named **six**
rows — eight sites, since one row covered colour, paint and skin. Driving the
doors found **twelve**: the section type, the zone type and the dungeon's room
and thing names were not on the list. One of the nine could not be seen by the check 095 had written at
all — `CommandParser` puts the command through `to_upper()`, so the sentence is
*"Rejected command: `<NULL>`"*, and a screen looking for the lower-case
spelling passes it in silence. **Measured: revert that one site and
`says_nothing_test` is 72 assertions, failures=1 with a case-insensitive
screen and 72, failures=0 — SILENT — with the one 095 shipped.** TRAPS 78,
inside the suite written to catch exactly this.

**What closed it: the same sweep, with a denominator, instead of a longer
list.** `says_nothing_test` section 7 drives every registered module, every
registered tool, the orders, the doors and the parser; poisons **one leaf of
the request at a time**, nested fields included; collects every sentence; and
asks one question of all of them. Measured over the identical sweep, with the
twenty call sites reverted and the reader left in place: **47 leaking
occurrences, 30 distinct sentences** before — twenty of them refusals and ten
readbacks — and **0** after, out of **204** sentences driven, with the
eighteen call sites reverted and the new reader left in place (the suite
cannot run against pre-096 `scripts/` at all: `spelled()` did not exist, so it
is a Parse Error there). A module the registry declares and this file has no fixture
for is a **failure and not a skip**, so a new world cannot arrive undriven.

**And the figure that had been wrong since 094, in twelve places.**
`str(null)` is `<null>`, which is **six** characters. Two docs, this file,
`readback.gd`, two tool comments, `command_parser.gd` and
`says_nothing_test.gd` all said five. It changed no behaviour and nobody had
rechecked it for two commits. `str(null).length() == 6` is now an assertion.

**Do:**

- **When a fix closes a class, let the CHECK say so, not the commit message.**
  095's suite was the right instrument and it was pointed at five sites. If
  the claim is about the class, the check has to be about the class — a sweep
  with a denominator, keyed off the registries, that nobody has to extend.
- **Screen for the fault in every form it can reach a player in.** A spelling
  that goes through `to_upper()` on the way is the same fault. One grep's
  worth of screen is TRAPS 78 whether it is in a suite or in a session's
  notes.
- **Re-measure the figure the last commit wrote down, and say so when it was
  wrong.** Six characters, not five, measured with `String.length()`. TRAPS 14
  does not only apply to capabilities.
- **Separate the SPELLING of a quoted value from the BRANCH that quotes it.**
  `Readback.spelled()` changes what six characters say and never which
  sentence fires, which is why it needed no decision from the owner while
  routing those doors through `said()` still does.

**Don't:**

- **Don't write "can no longer" about a class you fixed by list.** Write how
  many you drove, and which reading found them.
- **Don't take a count out of the last entry.** 095 wrote its thirteen down
  *with the warning that it was a grep's count and not the class*, and the
  warning was right both times: the refusal half was six in the document and
  nine in the code.

Found in 096, by driving the half 095 measured and left, and finding that the
half 095 had reported closed was not. `tests/says_nothing_test.gd` was put
through **twenty-one deliberate breakages**, one at a time, each in its own
copy with its own `config/name` and its own `--headless --import`, against a
control of **72 assertions, failures=0**. It names **eighteen** of them. The
three it does not are each written down rather than rounded up: the narrow
screen on its own (correctly silent — there is nothing left to see once the
code is fixed, which is why the screen is attributed by reverting a site
WITH it), and emptying one of the sweep's five door groups, because the
denominator is a floor over the whole collection and not one per group.

> The commit that fixes five sites can say five. Only a check that drives the
> class can say the class.

## 94. The wall one commit went through, named as a wall two years of commits later

**Signature:** a document says a sweep cannot be built, names a code reading to
do instead, and a suite in the same repository has been doing exactly that
sweep's hard part for forty commits.

**Cause.** 096's second live "Next action" said that
`says_nothing_test`'s execution sweep drives **nothing** in `main.gd` or
`game_controller.gd`, and gave the reason:

> because neither can be instantiated by a suite — `GameController` is a
> `Node3D`, which is the wall 043 and 044 both hit

It then prescribed, in place of a sweep, *"asking which of their sentences any
existing suite can already reach"* — a reading — and added that it *"may come
back 'nothing a player meets', and that is a reason to read rather than to
build"*.

**`tests/controller_reach_test.gd` has stood `main.gd` up and driven real JSON
requests through it since 054.** Its `_make_main()` loads the scene through
`ProjectSettings` and adds it to the root; the twelve sections above it send
requests and read the records back off the ledger. The wall was real when 043
and 044 hit it and **054 went through it.** The sentence was true when the
reason behind it was first written down, and nobody rechecked it against the
file that had disproved it — which is **TRAPS 14's exact shape pointed at this
project's own harness** rather than at the game's capabilities.

**What it cost, measured.** The sweep that entry said could not be built is
~160 lines, most of them borrowed: `_make_main()` and `_send()` from the suite
that already had them, `_one_null_each()` from `says_nothing_test`. Driven,
with one leaf of every request the whitelist admits set to null at a time, it
collected **1814 sentences** and found **three distinct ones a player meets
carrying the engine's own debug spelling**, at doors 096 had closed the
identical class at eighteen other sites of:

| the sentence a player read, after 096 | where |
|---|---|
| *"this game has no tool called '`<null>`' (it has car, boots, look)"* | `game_controller.gd` `_equip` |
| *"step 1: '`<NULL>`' is not a command this game has"* | `game_controller.gd` `_execute_plan` |
| *"a `<null>`"* | `world_registry.gd` `_plan_readback`, through `_doing`'s fallback |

The third is a **readback and not a refusal**, which is TRAPS 93's shape a
third time: 095 said readbacks could no longer say it, 096 found five sites
that still did, and this is a sixth, one door along, in the one line a player
reads before anything is validated.

**And the upper-cased one was invisible to a case-sensitive screen, again.**
Measured: revert that one site and screen for the lower-case spelling only and
`controller_reach_test` is **330 assertions, failures=0 — SILENT**; screen
case-insensitively and it is **330, failures=1**, naming the sentence. TRAPS 78
reproduced at a new door by a check written in the commit that recorded it.

**Do:**

- **A limitation about the TEST HARNESS is a claim about Genesis and gets
  checked like one.** Before writing *"no suite can reach X"*, grep `tests/`
  for a suite that already reaches it. One grep for `instantiate()` would have
  found `_make_main()`.
- **Name the commit a wall was hit in.** 043 and 044 hit it; 054 went through
  it. A reason carried forward without its date outlives the fact.
- **When a driving instrument exists, the reading is not the method.** The
  sweep answered in one session what the reading would have argued about, and
  it answers again next session without anybody reading anything.

**Don't:**

- **Don't let the previous entry's reason stand because the previous entry was
  careful.** 096 was careful, wrote its own limits down, and was wrong about
  this one. Its warning that the reading *"may come back nothing a player
  meets"* was the part that made the reading look sufficient.

Found in 097, by taking 096's second live entry and discovering that its
premise was false. Both widened suites were put through **eleven deliberate
breakages**, one at a time, each in its own copy with its own `config/name` and
its own `--headless --import`, against controls of **330** and **108**
assertions, failures=0. Ten are named by the sentence or the thing they break;
the eleventh is the narrow screen, correctly silent on its own.

> A wall one commit went through is not a wall. Check which commit you are
> standing in.

---

## 95. The door that validated three things over six fields

**Signature:** a function whose whole job is to decide whether a file is
damaged checks the type of some of its fields, and every reader downstream
assumes the type of all of them.

**Cause.** `WorldStore.load_world()` is the only door between a save file a
player can edit by hand and every reader of that file. It checked three
things:

> `typeof(data) != TYPE_DICTIONARY or not data.has("command") or typeof(data.get("parameters")) != TYPE_DICTIONARY`

The file has **six** fields. `name`, `saved` and `request` were not type
checked at all, `metrics` was not type checked at the door, and `command` was
checked for **presence and not for type** — which is TRAPS 92's distinction
(*a guard that answers the absent key does not answer the present wrong one*)
moved from a default to a damage check.

**What that let through, driven through the real `main.gd` in 098 before
anything was changed:**

| the hand-edited field | what Genesis did with it |
|---|---|
| `"command": null` | *"'`<NULL>`' is not a command this game has. The saved world cannot be built."* |
| `"command": 7` | *"'`7.0`' is not a command this game has."* — a JSON integer read back to the player in GDScript's float spelling |
| `"command": []` | *"'`[]`' is not a command this game has."* |
| `"name": null` | ledger record `request` **`"load <null>"`**, and the next prompt the model is sent: *The player asked for: "load `<null>`"* |
| `"name": 12` | *"load 12.0"*, and the same prompt line |
| `"saved": null` | the record's own `source` field carried `"saved": null` |
| `"metrics": null` | **the load check was skipped in silence** |

**The last two rows are the ones a spelling fix would not have reached.** The
`name` row leaves the engine altogether: a null spelled the engine's way is
put into the request line of a record and then into the **prompt**, so a
hand-edited file writes six characters of GDScript debug output into what
Genesis tells the model the player asked for. And the `metrics` row is not a
wording fault at all — loading is the only build whose right answer was
written down in advance, and a `metrics` of the wrong type made
`main.gd`'s `typeof(recorded) == TYPE_DICTIONARY` guard skip the comparison
**and say nothing about having skipped it**, which is PROTOCOL section 2's
*missing evidence must not become success* at the one door built to prevent it.

**Do:**

- **Count the fields the door hands on, then count the fields it checks.** The
  fault is visible as two numbers and needed no reading of the readers.
- **Check the type when the field is PRESENT, and let an absent one through.**
  Every field but `command` has a working default at its reader, and an older
  file that lacks one must still load. Section 3 of `world_file_test` removes
  each field in turn and requires the file to still load, so a later
  tightening into *"all six are required"* fails by the name of the field it
  would have broken.
- **Derive the field list from the function, not from a test.** Section 1
  calls `save_world()` for real, reads the file back off disk, and asserts that
  the declared types are exactly the keys and types it wrote — so a seventh
  field added to `save_world()` fails **by its own name** (TRAPS 82). Measured:
  adding `"engine": "4.7.1"` to `save_world()` gave 174 assertions,
  **failures=9**, the first of them *"save_world writes 'engine', so load_world
  declares a type for it"*.

**Don't:**

- **Don't fix the spelling at the reader when the door is one line away.** The
  reader was `str(world["command"]).to_upper()` in `main.gd`, and 098's first
  instinct — the one HANDOVER's entry had already argued out of — was to fix
  that `str()`. It would have left `name`, `saved` and `metrics` untouched, and
  the prompt would still have been fed `<null>`.
- **Don't replace a check without counting the questions it answered.** The
  check 098 replaced was `typeof(data.get("parameters")) != TYPE_DICTIONARY`,
  which answers **two** questions at once: is `parameters` there, and is it a
  dictionary. `data.get()` on a missing key returns `null`, so absence failed
  it too. 098's first draft replaced it with a type check that fired only on a
  field that was **present**, and a save file with no `parameters` key began to
  load — into `main.gd:599`'s `world["parameters"]`, which reads **by index**.
  Driven: `SCRIPT ERROR: Invalid access to property or key 'parameters' on a
  base object of type 'Dictionary'`, `_load_world` abandoned mid-function, and
  the status label left reading *"Status: No API key. Raw JSON only."* — the
  class 030 and 036 closed, reintroduced by the commit about damage checking.
  **A `.get()` with a default inside a condition is a presence check wearing a
  type check's clothes.** Split them: `REQUIRED` for the fields a reader
  indexes by name, `FIELD_TYPES` for every field's type when present.
- **Don't let a new suite's section decide for itself which answer is right.**
  Section 3 of `world_file_test` **passed on that regression**, because its
  first version treated every field but `command` as optional — it guarded the
  assumption that only `command` is indexed instead of checking which fields
  are. It now takes the answer from `WorldStore.REQUIRED` and asserts both
  directions and the split, measured: the presence check removed is
  **212 assertions, failures=2**, naming `command` and `parameters`.
- **Don't trust a new suite's own green.** Both silence-floors in
  `world_file_test` were **measured silent before they were written**: the
  collection in section 4 made to collect nothing gave 88 assertions,
  **failures=0 — SILENT**, and the poison list emptied gave 28,
  **failures=0 — SILENT**. That is 096's hole and 097's fix, found a third time
  in the suite written to close a different fault. Both now fail by field name:
  18 and 12 failures.
- **Don't screen for a leaked value case-sensitively.** TRAPS 78 a fourth
  time, attributed rather than assumed: with the old check restored, the
  case-insensitive screen is **186 assertions, failures=42** and the
  case-sensitive one is **186, failures=41**. The single assertion only the
  case-insensitive screen catches is `'command'` as null — *"'`<NULL>`' is not
  a command this game has"*, upper-cased on the way by `to_upper()`.

**Nine deliberate breakages** against a control of **212** assertions,
failures=0, each alone in its own copy with its own `config/name` and its own
`--headless --import` (TRAPS 50, 80, 88). Seven fail by the name of the field
or the thing they break; the weakest is `REQUIRED` made to be every field,
which gives **216, failures=1** - the split assertion and not a field name,
because when every field is required every removal is correctly refused and
only the shape of the split is wrong. That asymmetry is recorded rather than
rounded up: over-tightening is caught by one assertion, under-tightening by
four.

Found in 098, by taking HANDOVER's second live entry as of 097 and doing what
it said to do first: **driving it** rather than reading it. The entry had the
`command` row right and had done the reading behind it; driving it found the
`name` row reaching the prompt, the `saved` row, and the `metrics` row, none
of which a reading of `main.gd:584` would have reached.

> Count the fields the door hands on. Then count the fields it checks.

---

## 96. A runtime type error abandons the FUNCTION, and the caller reads the empty result as an answer

**Signature:** a report comes out blank, a count comes out zero, a thing that
was built is not counted as built — and the game says it worked. The only
sign is a `SCRIPT ERROR` line in output nobody is reading.

**Cause.** In GDScript a failed typed assignment, a bad `int()` or `bool()`
constructor, and a failed `as` cast are all **non-fatal**. They print an error
and **abandon the function at that line**. The function then returns its
return type's default, and the caller cannot tell that apart from a real
answer:

| the function's return type | what the caller is handed |
|---|---|
| `-> Dictionary` | `{}` |
| `-> Array` | `[]` |
| `-> bool` | `false` |
| `-> String` | `""` |

**Measured, driven through the real `/session end` in 099** with one byte of a
hand-edited `user://track_log.jsonl` changed (`"reasons": "a string"`):

- `SessionReport.summarise()` abandoned at its typed read and returned `{}`.
- `main.gd` merged that `{}` into the `session_summary` record and wrote it:
  **four keys**, no numbers at all, against twenty-three for the same session
  undamaged.
- `SessionReport.describe()` was then handed the `{}` and abandoned on its own
  **first line**, returning `""`.
- the history panel got the request line and **a blank**; the status label read
  *"Session 'x' ended. Results in the history panel."*; the request was
  recorded as **`"ok"`**.

One wrong byte turned a whole testing session into an empty report that said
it had succeeded. That is PROTOCOL section 2's *missing evidence must not
become success*, at the one artefact a testing session exists to produce.

**Do:**

- **Read which FUNCTION the backtrace names, not which process survived.** The
  error says `at: summarise (res://scripts/session_report.gd:120)`. The
  question is what `summarise`'s caller then did with the default.
- **Count the class by the assumption, not by the construct.** `int(x)`,
  `bool(x)`, `var a: Array = x` and `(x as Array)` are **four spellings of one
  assumption**. HANDOVER's entry asking for this work counted *"three of the 24
  reads assign the result to a typed `Array`"* — true, and it was the boundary
  of one GDScript construct rather than of the fault. Driven, the class was
  **five**: the two the entry missed were `int(r.get("player_place", 0))` and
  `bool(r.get("revision_pending", false))`, and `bool()` breaks on **every**
  non-numeric type including `String`, which is the commonest thing a hand edit
  leaves behind.
- **Make the floor "does the result still carry what it carries when nothing is
  wrong", not "did it crash".** `record_type_test` asserts that a damaged
  session's summary has **the same key set** as an undamaged one's. That is the
  assertion that fails on every row of the table before the fix; a crash
  assertion would have passed, because nothing crashed.
- **Keep the error channel as a reader.** `run_tests.sh` greps for
  `SCRIPT ERROR` and reports it **instead of** the result line. One of the five
  sites — `(r.get("steps", []) as Array)`, inside `_builds_a_world()` — is
  caught by **nothing else behavioural**: the error abandons that helper, which
  returns `false`, so a PLAN that built a world silently stops counting as one
  while the summary survives whole. Measured: reverting that one read alone
  gives **388 assertions, failures=2**, both from a source scan, and **8
  `SCRIPT ERROR` lines** where the control has **0**.

**Don't:**

- **Don't write "would throw" in a document for a fault you have not driven.**
  The entry that asked for this work predicted a throw. A throw would have been
  *better*: it is visible. What happened instead was a silent empty artefact
  reported as a success, which is a different fault with a different fix and a
  different test.
- **Don't treat a wrong type as something to refuse at the door when the
  reader already has a default.** Each of the five reads already named what to
  do with an **absent** field. A field of a type the game does not write is the
  same thing to a reader that cannot use it, so it is read as that default —
  and `FIELD_TYPES` is **one table** that both the fallback and the damage
  count ask, so a field the report falls back on is exactly a field the report
  counts.
- **Don't let the fallback be the whole fix.** Silently reading damage as
  absence trades a loud empty report for a quietly wrong one: a damaged
  `revision_pending` makes a correction count as a request, and a damaged
  `steps` loses a world. The summary carries the count and the report names the
  fields. Measured: deleting those two lines from `describe()` gives
  **failures=40**.

> A GDScript type error does not stop the program. It stops the function, and
> hands its caller an empty answer that looks like an answer.

---

## 97. A suite that writes its own ids into the shared ledger

**Signature:** `record_id_test` goes `failures=0` to `failures=2` on the
**second** full run in one container, naming ids that "name nobody", and the
suite that caused it passes both times.

**Cause.** `user://track_log.jsonl` is shared by every copy of this project
(TRAPS 50) and is **not** cleared between runs unless you clear it.
`TrackLog.append()` mints an id **only for a record that has not got one**, so
a suite that hands it records carrying hand-written ids writes those ids
verbatim — the same ones again on the next run. That breaks **two** invariants
`record_id_test` holds over the whole file: ids are unique, and every id names
the process that wrote it (`<unix>-<pid>-<serial>`, which is TRAPS 059's fix).

**Measured rather than reasoned.** 099's first draft of `record_type_test`
appended a hand-written session whose records were named `"r1".."r4"`. The
first full run was clean. The **second**, in the same container with `user://`
not cleared, gave `record_id_test` **failures=2**. The same two runs of the
tree *without* that suite stayed at **failures=0** both times, which is how the
cause was attributed rather than guessed at.

**Do:**

- **Erase the id and let `TrackLog` mint it**, then read the minted id back out
  of the dictionary — `append()` writes it in by reference — and remap any
  `about` that pointed at the old name.
- **Use `TrackLog.next_id()` and never a clock for anything that has to be
  unique.** The same draft built its session id from
  `Time.get_unix_time_from_system()`, and two runs of the suite inside one
  second shared it. That is TRAPS 059 again, in the harness this time.
- **Give the suite the floor itself** rather than relying on another suite to
  notice: `record_type_test` now asserts that every id it wrote appears
  **exactly once** in the ledger. Said plainly, because it is a weak floor:
  with a fresh `user://` it is **silent** — the duplicate only exists on a
  second run. Measured: putting the hand-written ids back gives
  **388, failures=0** on a fresh `user://` and **388, failures=1** on the
  second run of the same copy.
- **Append; never truncate.** Opening `TrackLog.PATH` with `FileAccess.WRITE`
  to set up a test takes 62 other suites' records with it.

**Don't:**

- **Don't conclude "a repeat run is just dirty" without measuring the tree
  without your change.** That two-run control is what separated "my suite did
  this" from "this container does this".

> A ledger is shared, and it outlives the run. An id a test writes by hand is
> an id a second run writes twice.

---

## 98. The class was closed by a grep over one directory, and the rule was not about a directory

**Signature:** a commit finds a class of unguarded reads, closes it properly
at every member, and writes *"THE CLASS WAS CLOSED BY GREP"* with the grep
quoted. The grep is correct and its scope is `scripts/`. The rule it states —
*a reader of a record that came off a file converts rather than assumes* — has
nothing to do with which directory the reader is in, and there is a second
member in `tests/` where the same fault costs a **hang**.

**Cause.** 099 closed `session_report.gd`'s five reads of a ledger record and
asked the class question carefully, twice: *"`scripts/` has exactly one
consumer of the ledger — `read_session` and `TrackLog.PATH` over `scripts/`
name `main.gd:545` and nothing else"*, and then named
`experiment_runner.gd:114` as carrying the same shape and **deliberately** not
changed, because its record is a signal payload built in-process. Both
statements are true and the second is the right call.

**`tests/replay.gd` reads a record file whose path comes from the
environment.** `REPLAY_LOG` names it, so it is not even the ledger this game
wrote: it is whatever file the owner pointed the tool at. Three fields go
straight into conversions that cannot answer a wrong type —
`controller.current_source` and `controller.current_experiment` are typed
`Dictionary` **members**, and `attempt` went through `int()`.

**AND THE COST HERE IS NOT THE COST THERE, WHICH IS WHY IT IS WORTH ITS OWN
TRAP.** In `session_report` the error abandoned `summarise()` and the caller
read the empty result as an answer (TRAPS 96). Here it abandons
`_initialize()`, and **a script error in a `SceneTree` aborts `_initialize`
before `quit()` is ever reached** — so the tool does not fail, it **hangs
until the harness's 600-second timeout**. That is the fault TRAPS 13 exists
for, and **the comment thirty lines below the three reads describes it in this
same file**, about a different field:

> *"`REPLAY_LOG` unset, or naming a file that is not there, used to reach
> `f.eof_reached()` on a null and throw — and a script error in a `SceneTree`
> aborts `_initialize` before `quit()`, so this tool hung until the harness's
> 600 s timeout instead of failing."*

**Measured on `867d89b`**, each field alone in its own throwaway copy with its
own `config/name`, three fields against six types — **eleven of eighteen runs
came back `rc=124` with nothing written**:

| field | `null` | a string | an array | a number | a dictionary |
|---|---|---|---|---|---|
| `source` | **hung** | **hung** | **hung** | **hung** | ok (right type) |
| `experiment` | **hung** | **hung** | **hung** | **hung** | ok (right type) |
| `attempt` | **hung** | `rc=0` — **and replayed every group as attempt 0**, because `int("x")` is 0 | **hung** | ok | **hung** |

All eighteen finish `rc=0` with zero script errors after, and a replay of an
**undamaged** record is byte-identical before and after once ids and
timestamps are normalised — checked rather than assumed.

**Do:**

- **When a commit writes "the class was closed by grep", read the grep's
  scope against the rule's own words.** If the rule says *a file*, the scope
  is every reader of a file, not every reader in one directory.
- **`tests/` is not out of scope for a rule about reading files.** It holds
  tools the owner runs by hand, and this project has already lost a session to
  one of them hanging.
- **Ask what a type error abandons at each site, because the answer differs.**
  Abandoning a `-> Dictionary` gives the caller `{}` to misread; abandoning
  `_initialize` in a `SceneTree` skips `quit()` and looks exactly like a hang.

> A grep has a scope. A rule does not.

---

## 99. The class was closed by sweeping for the IDIOM, and the fourth member was a bare index

**Signature:** a commit fixes a class of unguarded reads of a record that came
off a file, puts the fields in a table, routes them through one reader, writes
*"ONE TABLE AND ONE READER, so the three cannot be held at two of three"* and
names TRAPS 11. The count is wrong. The sweep that produced it looked for the
**shape being fixed** — `r.get("field", default)` — and the missing member was
read as **`r["field"]` behind a `has()` guard**, which is a different idiom for
the same act.

**Cause.** 099a closed three fields in `tests/replay.gd` —
`source`, `experiment`, `attempt` — and each of the three it found was a
`.get()` or a conversion. The fourth, `revision_of`, was two lines of a
different shape:

```gdscript
if first.has("revision_of"):
    attempt["revision_of"] = first["revision_of"]
```

**Nothing threw at the door, which is why it survived a session that was
looking straight at it.** `current_attempt` is a typed `Dictionary` and the
dictionary assigned to it is well-typed whatever is inside, so the file ran.
The value threw **one process later, in `scripts/`**, at
`racing_module.gd:151`'s `record["revision_of"].get("proposed_metrics", {})`,
reached because `game_controller.gd:656-657` copies it onto the record.

**Measured on `e1c9b6d` before anything was changed**, one real October
`CREATE_TRACK` record carrying a real `revision_of` (attempt 2), each type
alone in its own throwaway copy with its own `config/name` — **five of five
wrong types came back `rc=124` with nothing written**, the same cost as the
three fields 099a had just fixed:

| `revision_of` holds | result |
|---|---|
| a dictionary (control) | `rc=0`, `REPLAY_OUT` 20,281 bytes |
| `null` | **`rc=124`, nothing written** |
| a string | **`rc=124`, nothing written** |
| an array | **`rc=124`, nothing written** |
| a number | **`rc=124`, nothing written** |
| a bool | **`rc=124`, nothing written** |

**And the backtrace names the site, so the attribution is read and not
inferred.** First error `Nonexistent function 'get'` at
`RacingModule.pre_check (res://scripts/racing_module.gd:151)`; the error
abandons `pre_check`, the caller reads the `{}` it is handed as an answer
(TRAPS 96's shape, one function along), and the second error is
`GameController._prepare_world (game_controller.gd:1196)` on `['ok']`.
`_initialize` never reaches `quit()`, so the tool hangs.

**Do:**

- **Enumerate the class by the FIELD, not by the idiom.** "Which fields of
  this record does this file read" has a fixed answer; "which `.get()` calls
  are there" is a question about syntax and will miss `r[f]`, `f in r`, a
  destructure, or a `has()` guard with an index under it.
- **A suite that closes such a class must ask for BOTH shapes, off the record
  variable the code actually uses.** `tests/field_type_test.gd` derives the
  variable names from the `_field(<var>, "<name>"` matches themselves and
  then asserts that neither `<var>.get("<name>"` nor `<var>["<name>"]`
  appears — so a rename moves the check instead of bypassing it. The bare
  index put back at the call site is one of five injected faults it catches.
- **"Nothing threw at the door" is not evidence the door is safe.** Ask where
  the value is read with a type assumed, which may be a different file and a
  different process.

> The grep in 098 had a scope. This one had a shape.

---

## 100. `set()` on a typed member does not throw, so an assignment is not a check

**Signature:** a suite wants to know that the value a reader returns can be
held by the typed member it is assigned to. It makes the assignment for real —
which is the right instinct, because it asks the engine instead of asking the
suite's own arithmetic — and then looks for an error. There is none. The
assertion passes while the member holds something else entirely.

**Cause.** Measured in 100 in Godot 4.7.1, not reasoned about.
`Object.set("current_source", "x")` where the declaration is
`var current_source: Dictionary = {}` prints **no error and no warning**, does
not throw, and **silently keeps the previous value**. The deliberate fault
that found it was `FIELD_TYPES["source"]` widened to admit `TYPE_STRING`, so
the reader began passing strings through to a `Dictionary` member. The suite
caught it at **189 assertions, failures=2** — and both failures came from
assertions that read the member BACK afterwards, not from the assignment:

```
FAIL  every type FIELD_TYPES admits for "source" is the type current_source
      is declared as: String vs Dictionary
FAIL  current_source accepted what _field() returned for a "source" holding
      a String
```

**This is the opposite of the sibling case in the same file, which is why
both are written down.** `(value as Dictionary).get(...)` on a non-Dictionary
**does** raise: *"Invalid cast: could not convert value to 'Dictionary'"*,
measured at `field_type_test.gd:208` when the bare index was injected back
into `replay.gd`. **And what it abandons is the FUNCTION, not the process**
(TRAPS 96), which was also measured rather than assumed: `_run()` carried on
into the next section, so that injection printed **`FIELD TYPE 160
assertions, failures=3` AND a `SCRIPT ERROR`**, and `run_tests.sh` reports
the `SCRIPT ERROR` line because it tests for that before it reads the result
line. Run from `_initialize` directly rather than from a deferred `_run`, the
same cast never reaches `quit()` at all: a one-file probe came back
**`rc=124`** with the same `SCRIPT ERROR` and no end-of-run line (TRAPS 13).

So of the two ways a suite can ask the engine about a type, one is loud and
one is silent, and a suite that uses the silent one without a read-back is
TRAPS 81's vacuous guard.

**Do:**

- **Assign, then read the member back and assert its TYPE.** `typeof(obj.get(
  member)) == typeof(value)` is the assertion; the assignment alone is not.
- **Do not reason about which engine operations throw. Inject the fault and
  read the output.** The first draft of the comment above this suite's
  section 4 said the assignment "would throw here", in writing, and it was
  wrong — corrected only because the injection was run (TRAPS 14).
- **Say which failure mode a suite has, in the suite.** A reader of
  `failures=0` is entitled to know whether a break shows up as a FAIL, a
  `SCRIPT ERROR`, or a timeout.

> Nothing was raised, nothing was written, and the member kept what it had.

---

## 101. The destructive act was above the gate that refuses the work

**Signature:** a tool is run with a variable unset or a path mistyped. It
refuses, says exactly what is missing, exits 1 — and a file it was never going
to write has already been deleted. Nothing in the error mentions it.

**Cause.** `tests/replay.gd` deleted `user://track_log.jsonl` as the **fourth
statement** of `_initialize()`, and its two guards — `REPLAY_LOG` must name a
readable file, `REPLAY_OUT` must name somewhere to write — were **twenty lines
below it**. The deletion is wanted on the path that works: produced records
are counted by line offset into a ledger that has to start empty. It is wanted
nowhere else, and on three of the three refusal paths it happened anyway.

**MEASURED on `3f7ae94` before anything was changed**, each probe a throwaway
copy of the repository with its own `config/name` and its own `user://`
holding a planted 52-line ledger (TRAPS 50, 80, 88):

| invocation | result | the ledger afterwards |
|---|---|---|
| `REPLAY_LOG` unset, `REPLAY_OUT` unset | `rc=1`, *"needs REPLAY_LOG"* | **GONE** |
| `REPLAY_LOG` naming a missing file | `rc=1`, *"cannot open"* | **GONE** |
| `REPLAY_LOG` good, `REPLAY_OUT` unset | `rc=1`, *"needs REPLAY_OUT"* | **GONE** |
| both good (control) | `rc=0`, `groups=42 damaged=0` | present, rewritten by the replay |

**And it is the owner's own ledger, not a scratch file**, which is read off
`docs/harness/run.sh.txt` rather than assumed: that script builds its
throwaway project with `config/name="AI_Game_Builder"` — **the same name as
`project.godot`** — so `user://` is the directory the game itself writes to.
The documented way to run this tool therefore points it at the real ledger,
and a typo in `REPLAY_OUT` cost the session history that
`scripts/session_report.gd` reads for `/session`.

**Why no suite saw it.** `replay.gd` is on `run_tests.sh`'s `NOT_A_SUITE`
list, so neither runner drives it; and the only thing a suite can hold about
an irreversible act is its **position**. 100 had already written down that
these guards were held by nothing and named the next step as *"ask of each
remaining part whether it can be made a function of its inputs"* — the fault
surfaced on asking it of the **gate**, because the answer required reading
what ran before the gate and what ran after it.

**The class, swept rather than assumed** (TRAPS 11). The rule is **a
destructive act waits until the work is known to be possible**. Every
`DirAccess` deletion in the repository, read one at a time — four sites:
`scripts/world_store.gd:119` (`remove_world`) **refuses first and then
deletes**, the correct order already; `tests/look_test.gd:168` deletes a
fixture it made itself; `tests/session_test.gd:30` clears the ledger it is
about to write into and has no gate that can refuse. And every
`OS.get_environment` site the same way — six, in two files:
`drive_test`'s `PARK` and `ONLY_PLAN` are **options** and cannot refuse. So
`replay.gd`'s two are the only gates in the repository and **the class has one
member**, which is said with the sweep that establishes it.

**Do:**

- **Put every irreversible act below the gate**, and keep everything above it
  a read. In `replay.gd` the only statements before the refusal are now the
  three `OS.get_environment` reads and the gate's own
  `FileAccess.open(..., READ)`; the deletion is the first thing after it.
- **Make the gate's decision a function of its inputs.** `_refusal(log_in,
  out_path, log_readable) -> String` is pure, so a suite can ask it all eight
  combinations and assert that **exactly one is allowed to proceed** — the
  capability, not the three sentences (TRAPS 6, TRAPS 14).
- **Hold the position in a suite and label it as a guard.**
  `tests/field_type_test.gd` section 7 reads the source, finds the gate's
  `return`, and asserts every destructive idiom in the file is below it —
  classified from a whitelist of idioms that is itself asserted to have
  matched something (TRAPS 75, 79). It is a guard against future change; the
  four probes above are the measurement.
- **Ask of a refusal what it has already done.** "It exits 1 and says what is
  missing" is not the whole of what a refused run does.

> It said exactly what was wrong, and the file was already gone.

---

## 102. The readback that said nothing, and the suite named for it that counted the sentences it collected

**Signature:** a request Genesis cannot read is refused with a clear sentence
and the line above it — *"I understand: you want ..."* — is simply absent. The
**same step wrapped in a PLAN** gets that line. Every suite is green,
including the one whose whole subject is a readback that says nothing.

**Cause, two halves, and the second is the expensive one.**

**The code.** `WorldRegistry.readback()` returned the empty string for three
of the eleven commands the whitelist admits whenever the one key that says
WHAT was asked for could not be read — `EQUIP`'s `tool`, `ORDER`'s `goal`,
`PLAN`'s `steps`. `main.gd`'s `_show_readback()` **returns on an empty line**,
so nothing was printed, nothing was recorded in the history panel, and
`awaiting_readback` was never set, which also means the understanding layer
never judged the request. The sibling door one function below —
`_doing()`, which describes a step inside a plan — **already had the
fallback**, `"a tool"` and `"an order"`, since 022. So the identical EQUIP read
back as *"a tool"* inside a plan and as silence on its own.

This is 032's fault one condition in. 032 found `SPAWN_OPPONENTS` and
`MODIFY_TRACK` with *"no readback AT ALL as a single command —
WorldRegistry.readback returned the empty string"* and gave both a sentence.
That was a command whose readback was empty for **every** request. These three
were empty only for a request Genesis **cannot read** — and every suite built
around 032's class, `plan_said_test` included, drives requests it can.

**The check.** `tests/says_nothing_test.gd` exists for exactly this. Its group
(f) **drove these very inputs** — every command the whitelist admits, one leaf
nulled at a time — and asked:

```gdscript
_check(said_in_this_run.size() > before_command,
    "driving %s's readback with a null in it said something" % command)
```

`_record()` appends the empty string like any other, so **a door that said
nothing at all satisfied "said something"**. Six groups were written that way,
and section 5's screen — *no sentence contains `"<null>"`* — passes on an empty
string too. **Measured: with the fault present and that floor in place, 108
assertions, failures=0, silent.** With the floor replaced by a per-row question
about the CONTENT, 177 assertions, failures=1, naming
`{"spec":{"colour":"brown"},"tool":null}`.

So the suite written to find a readback that says nothing could not see one,
because it counted the collection and not the content. Found by driving
`main.gd` and reading the history panel, not by any suite.

**And it was reached through a tool nothing checked.** 101's live entry said
`prompt_test` is checked by nothing and that before writing *"it cannot be
checked"* anywhere, grep for what that denies. The grep found three
descriptions of it and two were false — it prints one of the three registry
sections of the AI's prompt and no world — and **running it printed a blank
line**: its fourth probe is `{"tool":"hovercraft","spec":{}}`, under a heading
reading *"EQUIP readbacks as the player would see them"*. The blank was this
fault, in the one place in the repository that displays it.

**Do:**

- **A readback says something about every request the parser admits.** A part
  it could not read gets a WORD, never silence. Driven over all eleven
  commands, 171 rows, the only three that could say nothing were these three;
  the other eight already kept the rule — *"to shut a door"*, *"to make a
  corner hard"*, *"to put opponents on the track"*, *"to send someone
  somewhere"*.
- **Count what was SAID, not what was collected.** Any check of the form
  `collected.size() > before` is satisfied by an empty entry. If the question
  is "did this say anything", ask it of the strings.
- **A per-group floor is the wrong shape for a door that owes a line per
  request.** It is right for a validator — a refusal is owed once per request,
  not once per field — and wrong for the readback, because the other leaves of
  the same request keep producing sentences and hold the floor up. Group (f)
  asks per row now; the five validator groups keep the floor, with the reason
  written beside it.
- **Spoil the subject in every form, not only as null.** Guarded against null
  alone, 29 of this suite's assertions still fail: absent, `""`, `"   "`, a
  word, a number, `[]` and `{}` all emptied the same readback. `null` is one
  ninth of the class.
- **Take the fallback word from the door that already says it.** `"a tool"`
  and `"an order"` are what `_doing()` has said since 022, so correcting the
  silence invented no wording. They live in one table now, read by both doors
  and by the suite, so the two can never say different things about one step
  again.

> It refused the request in a full sentence, and never said what it had heard.
