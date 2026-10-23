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
