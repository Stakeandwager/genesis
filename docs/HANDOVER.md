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
- Last commit at the time of writing: **037**, the question this file named
  as the next assistant task — *036's `offset` finding asked of every field
  rather than of the one it was found at*. Asked field by field the answer is
  **yes, all 44 of them**, and that answer is worthless: every field name the
  assembled prompt mentions has a read site somewhere. The fault is one door
  along. **`intent` is offered by six of the prompt's JSON skeletons and was
  read at three.** The three `EQUIP` skeletons were read nowhere — not in
  `_equip`, not in `ToolRegistry`, not in any of the three tools — so a style
  the model sent *exactly as instructed* was dropped in silence: **no `EQUIP`
  record in the ledger carried an `intent` key at all**, the measurements
  panel said `REQUESTED: not stated` for every tool ever asked for while a
  farm with the identical field said `smallholding`, and an `intent` that was
  a string, a list, a number, a bool or `null` was accepted where the other
  five doors refuse it and name it. **This is 036's `offset` reversed and it
  is the worse direction**: `offset` is a field the code reads that the prompt
  never offers, so nothing reaches it; this is a field the prompt INSTRUCTS
  the model to send. The sentence now lives in `Readback.intent_problem()` and
  all six doors read it, because a sixth hand-written copy would have been
  fixing the instance (TRAPS 11). 43 suites passed before and 44 after,
  `--all` included; the new suite fails 39 times against the pre-037 code, all
  of them the three `EQUIP` doors. The prompt is byte-identical, so
  `PROMPT_VERSION` did not move. Found while measuring and left for its own
  commit: **the boots prompt tells the model two different things about the
  same player sentence** — see 037 below and TRAPS 31.
- The commit before it: **036**, the question that file named
  as the next assistant task — *does every command have a validator?* — and
  the answer is no, four of eleven. What that MEANS is the finding: not a
  missing function but **four conversions that throw**. `int()` and `float()`
  have no constructor for `null`, `{}` or `[]`, so the call abandons the
  function (029's mechanism, in the places 029 could not reach, because 029
  asked of validators and these commands have none). `MODIFY_TRACK` with a
  non-numeric `corner` left **no record at all** while the understanding
  layer still wrote one pointing at its id — 033's dangling reference back
  again. A sectionless `CREATE_TRACK` left a record whose only reason was
  **the empty string**, after clearing the world. And `around`, which **the
  prompt tells the model to write**, was silently read as 0 and the plan
  refused for the worlds *overlapping* — a true sentence about geometry for a
  request whose fault was a field. The safe reading was already one function
  above two of them (`TrackBuilder.readback()` has used
  `Readback.as_number()` since 032). 42 suites passed before and 43 after,
  `--all` included; the new suite fails 28 times against the pre-036 code.
  The prompt is byte-identical, so `PROMPT_VERSION` did not move. See 036
  below and TRAPS 30.
- The commit before it: **035**, the task that file named next
  — the farm prompt stating a bound the code does not have — asked of every
  bound in the prompt rather than of the one sentence. Nine of eleven were
  right. The farm's told the model to *"Use 2 to 24 zones"* while
  `MIN_ZONES` has been 1 since 003 lowered it so that *"a farm with a barn"*
  would stop being refused, so the prompt refused on Genesis's behalf a farm
  Genesis accepts — in the model, before Genesis ever sees the request. And
  a circuit's section count, 2 to 40, was **stated nowhere**, so a long
  circuit could be refused by a limit the model was never told. Found while
  answering this file's own question *"does `PROMPT_VERSION` move with it?"*:
  it had not moved since 025, and **three different prompts had been
  recorded under one version string** — 027 and 028 each changed what the
  model is told and left the version behind, so every comparison across them
  is not a comparison. 41 suites passed before and 42 after, `--all`
  included; the new suite fails 4 times against the pre-035 prompt. See 035
  below and TRAPS 28 and 29.
- The commit before it: **034**, the question 033 left as the
  next assistant task, asked of the whole class rather than the four
  instances it named. Every refusal in Genesis about a FIELD names what a
  legal value would be; nothing had ever asked the same of the CONTAINER the
  fields arrive in, and **nine doors answered with four words** — five lists
  in the world validators, a plan's `steps`, and `spec` in all three tools.
  `doors` is required with no default, so a dungeon described without doors
  was refused with four words naming nothing to fix. Found while fixing it:
  the plural at one (`"at least 1 doors"`, `"this dungeon has 1 rooms"`), and
  a fault the fix itself introduced — the plan's new example advertised
  `MODIFY_TRACK`, a withheld stub, which is TRAPS 21's closing warning
  arriving one door up. 40 suites passed before and 41 after, `--all`
  included; the new suite fails 30 times against the old sentences. See 034
  below and TRAPS 26 and 27.
- The commit before it: **033**, the next question off the same
  list 032 used, and a different kind of question: not what Genesis SAYS
  about a command but whether the command is in the LEDGER afterwards. Four
  of the eleven commands in `CommandParser.allowed_commands()` wrote no
  record at all, and each one still produced an understanding record pointing
  at an id no record carried. Found beside it: `SessionReport` counted every
  valid record as a world, so a session of boots and doors reported three
  worlds built and quoted a request for boots as the first one. 39 suites
  passed before and 40 after, `--all` included; the two changed suites fail
  10 times against the pre-033 code. See 033 below and TRAPS 25.
- The commit before it: 032, the plan readback 031 did not
  reach - asked of every command the whitelist allows rather than every field
  of one, and it turned up something larger than a readback. Two of the eleven
  commands in `CommandParser.allowed_commands()` had **no readback at all**,
  and the reason is that they do nothing and said they had: 002B removed
  Prototype 001's track and opponents and left the builders' success strings
  behind, so `SPAWN_OPPONENTS` logged `count=8` with no car on the grid. 37
  suites passed before and 39 after, `--all` included; the two new suites fail
  11 times against the pre-032 code. See 032 below and TRAPS 24. **What to do
  with the three Prototype 001 stubs is the owner's** and is under "Human
  decision needed".
- The commit before it: 031, the readback audit HANDOVER has
  named as the next assistant task since 028. The question 028 asked of the
  prompt's capabilities - is the sentence as wide as the thing it describes -
  asked of every field of every readback, by DIFFERENCE rather than by
  content. Eleven fields were silent, eight of them in a circuit (four types'
  angle, a chicane's radius and direction, a crest's and a dip's grade) and
  three in a dungeon (the name, width and depth of every room after the
  first). 36 suites passed before and 37 after, `--all` included; the new
  suite fails 26 times against the pre-031 readbacks. See 031 below and
  TRAPS 22 and 23.
- The commit before it: 030, the refusal-wording list 029 left
  open, done whole - and one thing in it that is not about wording. A bounded
  field can be refused three ways (out of range, not a number, missing) and
  028 and 029 had both looked at one of them. Twelve refusals in four of the
  five validators named no legal value, with the limits in scope on the line
  that wrote the sentence. 36 suites passed before and 36 after; the new
  assertions fail 109 times against the pre-030 messages. See 030 below and
  TRAPS 21.
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

46 files in `tests/`, of which `replay` and `prompt_test` are tools rather
than suites, leaving **44 suites**, and since 024 every one of them runs —
nothing is skipped as broken. `--all` adds the two slow racing suites.

Last full run (037, Godot 4.7.1 on Linux, headless, in a cloud container):
**suites with something to look at: 0**, both without `--all` and with it,
`drive_test` and `session_test` included. 037's new suite is
`intent_door_test` (39 failures against the pre-037 code); 036's is
`command_schema_test` (28 failures against the pre-036 code); 035's is
`prompt_bounds_test` (4 failures against the pre-035 prompt); 034's is
`container_door_test` (30 failures against the pre-034 sentences). Not run on
the owner's Windows machine. `run_tests.bat` needed no edit for any of the
four: no name matches any of its `findstr` patterns — `prompt_bounds_test`
does not contain the literal `prompt_test`, and `intent_door_test` contains
none of the physics names — so all four run there without `--fixed-fps`,
which is what they get here too, and `command_schema_test` and
`intent_door_test` were each run both with it and without and pass either
way — checked rather than assumed (TRAPS 4).

**Run `--all` before believing a green suite.** 033 introduced a fault that
the 38 fast suites all passed and `session_test` caught — see TRAPS 25's last
paragraph. The two slow suites are the only ones that drive a whole scripted
session, so they are the only ones that read the report's numbers back.

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
  `DungeonModule.is_shut()`, `BootsTool.top_speed()`, since 027
  `RefusalCheck.sentences_of()` — the same rule applied to punctuation, after
  two functions disagreed about what a sentence was and one of them won
  silently (TRAPS 16) — and since 028 `SectionValidator._range_error()`, the
  same rule applied to the words of a refusal, after the one function that
  knew a bound turned out to be the one function that never said it
  (TRAPS 18).
- **Refuse, never clamp — and name the limit, at every door.** A spec outside
  its limits is refused with the limit named, in every validator, because a
  refusal has two jobs: stop the build, and tell the player what would be
  allowed. Since 030 that holds for all three ways a field can be refused —
  out of range, not a number, and left out — and for the refusals whose legal
  values are a list rather than a range. 028 and 029 both did the first door
  only; see TRAPS 21. `BootsTool`
  also refuses a combination whose fields are each legal. Since 028 the
  circuit does it too, and a bound is never computed from a number that has
  already been refused.
- **A readback must not be silent about part of the request**, or it cannot
  catch a dropped clause, which is the only thing it is for. Since 031 that
  is a measured property and not an intention: a readback names every field
  its validator accepts, and `tests/said_fields_test.gd` changes one field
  at a time and fails if the sentence does not change. It enumerates the
  fields out of `SectionValidator.FIELDS` and each tool's `defaults()`, so a
  type that grows a field fails the suite until the sentence grows with it.
  Eleven fields were silent when the question was first asked; see 031 and
  TRAPS 22. Since 032 the same holds **one layer up**: every command the
  whitelist allows reads back, and every world names how many pieces it is
  made of in the short line a plan uses — which is the only line a player sees
  for a multi-world request. `tests/plan_said_test.gd` enumerates from
  `CommandParser.allowed_commands()` and `WorldRegistry.modules()`, so a
  command or a world added later cannot be silent. Two commands had no
  readback at all when the question was first asked; see 032 and TRAPS 24.
- **What a builder reports must be read from what it built.** 032. Three
  Prototype 001 builders kept their success strings after 002B removed their
  bodies, so `"SPAWN_OPPONENTS count=8"` was the asked-for number wearing a
  result's clothes. A line that states a count reads it from what was placed,
  never from what was requested, and `tests/stub_claims_test.gd` asserts the
  tie rather than the wording: if nothing was placed, the line must not
  contain the number asked for. This is the carrier-delivery rule above,
  applied to a function reporting on itself.
- **Every command the whitelist admits leaves a record, and every count
  names what it counts.** 033. Four of the eleven commands in
  `CommandParser.allowed_commands()` wrote no ledger record at all — they
  wrote a line to the player's log and nothing else — so the understanding
  layer wrote records pointing at ids the ledger did not contain. A handler
  that can return without appending a record has an exit the ledger cannot
  see, and `tests/ledger_said_test.gd` enumerates the whitelist and fails if
  one does. The other half of the same rule: which commands build a world is
  read from `WorldRegistry.commands()` and never written out in
  `session_report.gd`, because "worlds built" had been every valid record
  since 002G — boots included. See 033 and TRAPS 25.
- **A refusal names a legal value at every door, and the container is a
  door.** 034. 028, 029 and 030 made every refusal about a FIELD name its
  limits, through all three of its entrances. The CONTAINERS those fields
  arrive in — five lists in the world validators, a plan's `steps`, `spec`
  in all three tools — all answered with four words that named no count, no
  shape and no example. Each list is now declared by the world that owns it
  (`WorldModule.lists()`: key, member word, bounds, required, and a sample
  that is a real legal list), the refusal is written from that declaration
  by `Readback.list_error()`, and `tests/container_door_test.gd` builds a
  request out of every sample and **fails unless the validator accepts it**.
  So the example a player is shown is not a sentence that can go stale: it
  is rendered from a value that is checked. The same suite asserts that no
  example names a command the prompt withholds, after 034's own first
  attempt offered `MODIFY_TRACK`. See 034 and TRAPS 26.
- **A fact about a word lives in one function, at both ends of the noun.**
  034. TRAPS 10 and 23 established this for the article in front of a name
  and put it in `Readback.is_label()`. The plural on the end was still
  written by hand in six sentences, and three of them were wrong at a count
  of one — `"2 rooms need at least 1 doors"`, `"this dungeon has 1 rooms"`,
  `"deepest room 1 doors in"`. `Readback.plural()` is the digit form and
  `count_of()` the word form, and `container_door_test` sweeps every
  sentence the suite produced for a count of one followed by a plural,
  rather than quoting any of them. See TRAPS 27.
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

- **A green suite had never been asked what happens to a value that is not a
  number**, and the answer was different in each file. Found and fixed in
  029: `DungeonModule.validate` returned `ok: true` with an empty error list
  for a room whose width was `null`, `{}` or `[20, 20]`, and built it 0 m
  across; a door pair holding an object made `validate` return `{}` with no
  `ok` key at all, which `game_controller` indexes directly; and all three
  world readbacks returned the empty string. 35 suites passed before and 35
  after. The faults were not found by the owner — they were found by asking
  one question of every validator at once rather than of one file. See
  TRAPS 20.

  **What that says about the other eight:** this one was reachable from
  ordinary model output and had been reachable for the project's whole life,
  and the reason no suite saw it is that a person writing a test for a width
  writes a width. There is no reason to think it is the last of its kind, and
  the cheap way to find the next is to pick a question that has only ever been
  asked of one file and ask it of all of them.
- **A green suite had never been asked what a refusal says when a field is
  MISSING or is the wrong type**, only when it is out of range. Found and
  fixed in 030: twelve refusals in four of the five validators named no legal
  value, with the bound in scope on the line that wrote the sentence. 36
  suites passed before and 36 after, and `capability_test` had been asserting
  the limit-naming rule across all five validators since 028 — through one of
  its three doors. See 030 below and TRAPS 21.

  **What that says about the method:** 029's lesson was to ask one question of
  every file instead of one file. This one needed the other axis — every way
  IN to the same check, not every file the check lives in. A rule about what a
  refusal must say is a rule about missing, wrong-type and out-of-range alike,
  and a test that quotes the prompt's sentence inherits the prompt's scope.
- **A green suite had never asked whether two DIFFERENT requests read back
  differently**, which is the only property a readback actually has to have.
  Found and fixed in 031: eleven fields were silent, including a corner's
  angle — the field that decides which way the track turns — and every room
  of a dungeon after the first. 36 suites passed before and 37 after. The
  suites that read a circuit's readback asserted that the numbers they had
  supplied appeared in it, and every one of those assertions passes on a
  sentence that drops a different field. See 031 below and TRAPS 22.

  **What that says about the method:** 029 asked one question of every file,
  030 asked every way in to one check, and this one asked what the sentence
  must SAY — enumerated from the validator's own table rather than by hand.
  Three of the twenty-six failures were reachable only by building TWO
  sections of a type: a readback that groups says things about groups, and a
  group keyed on one measurement took its name from the first member and was
  false of the rest.
- **A green suite had never asked whether every COMMAND the whitelist allows
  reads back**, only whether every field of one command does. Found and fixed
  in 032: two of the eleven commands in `CommandParser.allowed_commands()` had
  no readback at all, and two of the three worlds were silent in a plan about
  how many pieces they are made of. 37 suites passed before and 39 after. See
  032 below and TRAPS 24.

  **And what the silence was hiding, which is the part that matters.** The two
  commands with no readback do nothing and said they had: 002B removed
  Prototype 001's track and opponents and left the builders' success strings
  behind, so `SPAWN_OPPONENTS` logged `count=8` with no car placed, and
  `MODIFY_TRACK` — the one of them a player can reach — reported which corner
  it had made harder without touching anything. Those lines go to the player's
  log. **That is a construction-layer claim with no measurement behind it** —
  the thing this project's first rule forbids — and 37 green suites sat around
  it. It is not added to the count of eight below: that count is the owner's
  editor sessions specifically, and this one, like 029, 030 and 031, the
  assistant found by asking one question of a whole list. The claims are gone;
  the three stubs still do nothing, and that is the owner's.

- **A green suite had never asked whether every command the whitelist allows
  is RECORDED**, only whether every one is described. Found and fixed in 033:
  four of the eleven wrote no ledger record at all — `MODIFY_TRACK`,
  `SPAWN_OPPONENTS`, a sectionless `CREATE_TRACK` and `CLEAR_WORLD` — and
  three further exits with them, including the two `has_drivable()` guards,
  which are the half of those commands a player actually meets. 39 suites
  passed before and 40 after. Each of the four still produced an
  UNDERSTANDING record whose `about` named an id no record carried, so the
  ledger held a reference to a record that was never written. See 033 and
  TRAPS 25.

  **And what was beside it, which is the part a person reads.**
  `SessionReport` counted every record with `result == "VALID"` as a world
  built. Four of the eleven commands are not worlds, so a session of one
  `EQUIP`, one `SHUT` and one `ORDER`, with no world in it at all, reported
  *"Worlds built: 3. Made another: yes"* and *"First world after 1 min 00 s,
  from \"give me boots that stop in 2 m\""*. Measured, not inferred. That is
  the report the owner reads after a player testing session and it had been
  wrong since 002G. It is **not** added to the count of eight below: that
  count is the owner's editor sessions, and this, like 029 to 032, the
  assistant found by asking one question of a whole list.

  **What that says about the method:** 032's refinement was to pick the list
  that decides what Genesis can be asked for. 033's is that the same list
  answers more than one question. `CommandParser.allowed_commands()` had been
  asked "is it described?" and not "is it recorded?", and the second question
  found a hole in the ledger — the artefact the whole project is for — that
  37 green suites had sat around. The next questions to ask of that same
  list are in "Smallest useful assistant task next".

- **A green suite had never asked what a refusal says when the CONTAINER is
  wrong**, only when a field inside it is. Found and fixed in 034: nine
  doors — `rooms`, `doors`, `things`, `zones`, `sections`, a plan's `steps`
  and `spec` in all three tools — named no count, no shape and no example,
  while the field refusals one level in say *"and it must be 5 to 60 m"*.
  40 suites passed before and 41 after. See 034 below and TRAPS 26.

  **What that says about the method, and it is the fourth variation on it.**
  029 asked one question of every file. 030 asked every way IN to one check.
  031 asked what the sentence must SAY, enumerated from the validator's own
  table. 032 and 033 asked two different questions of the one list that
  decides what Genesis can be asked for. This one asked the same question at
  a different DEPTH: `capability_test` had swept the limit-naming rule across
  all five validators since 028 and could not have failed, because the rule
  it owns is about a number and a list is not a number. The suite was right
  and complete about the subject it had, and the subject was one level too
  deep. A player who sees *"doors must be a list"* never reaches a field at
  all.

  **And 034 introduced one of its own, which is the part worth reading.**
  The plan's new refusal needed an example step, and the obvious reading of
  the whitelist produced `MODIFY_TRACK` — a stub that builds nothing and is
  named nowhere in the prompt the model is sent. A refusal written to name a
  legal value had named a **withheld** one, which is precisely what TRAPS
  21's last paragraph warns about, one door above where it warned. It was
  caught by generating the sentence and reading it rather than by reasoning
  about the code, and the suite now asserts the rule: every command named in
  an example appears in `AIInterpreter.assembled_prompt()`.

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
  them and are narrowed; see 027 below and TRAPS 15.

  **028 closed the capability half**, which this entry used to name as the
  outstanding gap. All eight are read against the functions behind them in
  `tests/capability_test.gd`, at the width the prompt states them. One was
  wider than the code in two ways and the same sentence was in `RefusalCheck`
  as well; the circuit's refusals named no limit at all, which is a different
  claim in the same list. See 028 below and TRAPS 17 and 18.
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
- **That comparison happens in the suite, not in the game, and until 028 the
  prompt said otherwise.** `tests/behaviour_test.gd` measures a real stop
  against `BootsTool.stopping_distance`; nothing a player can reach does. The
  only stopping distance a player is ever shown is the predicted one, when the
  boots go on. And a **car** has bounded braking but no predicted stopping
  distance at all. Both halves are now asserted, including the absences, so
  the prompt cannot drift back; see TRAPS 17.

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

## 028 — the capabilities, read against the code

**Objective.** The task this file named: 027 read the seven **limitations**
against the code and asserted each as a fact; the eight **capabilities** were
still checked only for the existence of the functions they name. Read each one
at the width the prompt states it, and tighten whichever end is wrong — the
sentence, or the code.

**Starting state.** Branch `prototype-002a` at 6454673 (027). Baseline run,
Godot 4.7.1 headless: suites with something to look at: 0, 34 suites, both
without `--all` and with it.

**What the audit found.** Six of the eight are true at the width stated, and
two were checked and are worth naming as verified rather than assumed: the
four measurements the prompt names by name all come back as numbers
(`corridor_length`, `deepest`, `total_length`, `minimum_separation`), and a
container really is grown to hold what it is given and says so to the player.
Two things were wrong, in opposite directions.

**One: a capability stated wider than the code, in two places.** *"Genesis
predicts a stopping distance from the numbers and then measures the real one,
and reports both."* The prediction is real and a player is told it when the
boots go on. The measurement against it is real too — and it lives in
`tests/behaviour_test.gd`, which **a player cannot reach**. Nothing in the
game measures a real stop. And the sentence says *"a car and boots"*, while
only boots have a `stopping_distance()` at all; a car has bounded braking and
nothing that turns it into a distance. The owner's 023 session asked for
precisely this, for two cars: *"measure their stopping distances ... compare
the measured results with predictions from the model."*

`RefusalCheck` carried the same sentence in its rebuttal for "measurement and
physics", so a player who correctly doubted the measured stop would have been
told by Genesis that they were understating it. That is TRAPS 14 one layer up:
in 023 the prompt told the lie the checker could not catch; here the checker
told it too. Narrowing the prompt alone would have left it (TRAPS 11), so both
are narrowed in this commit.

**Two: the circuit was the one world whose refusals named no limit.** The same
list of capabilities says *"It REFUSES rather than clamping. A number outside
its limits is refused with the limit named."* Four validators do exactly that.
`SectionValidator` said *"section 1 (straight): length out of range"* — eleven
bounds, no limit named on any of them. The limits lived in a single range test
and the sentence was written by hand at each call site, so the one function
that knew the bound was the one that never said it.

Nothing saw it because `tool_test` and `boots_test` ask whether a bad number
is **refused**; exactly one assertion in 34 suites asked what the player was
**told**, for one field of one tool. A refusal has two jobs and the suite was
testing one. Worth knowing why that file and no other: its header reads
*"Prototype 002B — Universal Track Geometry & Vertical Axis (user's build)"*.
It came from another prototype and never picked up this one's conventions.

**Implementation.**

- `scripts/section_validator.gd`: `_range_error()` now owns both the decision
  and the words, with `_bound()` and `_tidy()` beside it, and the eleven
  hand-written messages are gone — the `around_of()` rule applied to a
  refusal. A player now reads *"section 1 (straight): length is 5000 m, and
  must be 20 to 1000 m"*. Signed angles say *"either direction"* because they
  are bounded on size; **bank is not**, since its range starts at 0 and
  reading it as a size would quietly admit a negative bank.
- `scripts/section_validator.gd`: a chicane's offset bound is twice its
  radius, and the check ran even when the radius had just been refused — a
  radius of -145 produced *"at most twice the radius, which is -290 m here"*.
  It now runs only when the radius is sound, which is the rule `BootsTool`
  already states for the same reason.
- `scripts/ai_interpreter.gd`: the physics capability narrowed to what a
  player gets, and it names the two things Genesis does NOT do in the same
  breath — the 027 pattern, because the true and false halves were a clause
  apart.
- `scripts/refusal_check.gd`: the same claim narrowed in the rebuttal. Its
  last clause says which half of such a refusal is right, because phrase
  matching cannot tell them apart and should not try.
- `tests/capability_test.gd`, new: 165 assertions. Every bound in all five
  validators probed above and below, with the refusal required to name both
  limits — bounds read from the constants, never typed into the test, so they
  cannot go stale (TRAPS 13). The four named measurements built and read. The
  narrowed claim asserted as facts **including its absences**: the suite fails
  if a car ever grows a `stopping_distance`, because at that moment the prompt
  would be understating Genesis.
- `docs/TRAPS.md`: traps 17, 18 and 19.

No module, builder, ledger or solver was touched. The only product-visible
change is that a circuit's refusals now say what the limit is.

**Evidence — what was actually run.** Godot 4.7.1
(`4.7.1.stable.official.a13da4feb`), Linux, headless, in a cloud container:

- Baseline before: 0 suites with something to look at, 34 suites, with
  `--all` as well.
- After: 0 with something to look at, 35 suites, `capability_test` passing
  with 165 assertions, with `--all` as well — `drive_test` and `session_test`,
  the two slow racing suites that actually drive the circuit, both pass.
- **The new checks were proved able to fail** (TRAPS 6), six ways, each
  reverted and `cmp` used to confirm the files came back byte-identical: the
  nameless refusal restored (20 failures); the over-wide prompt sentence
  restored (2); the over-wide `RefusalCheck` rebuttal restored (2); the
  chicane offset computed from a refused radius (1, quoting the -290 m); bank
  read as a magnitude (2, including a negative bank being accepted); and the
  limits rendered to three decimals so a player reads a different number (21).
- **Two failures in the first run of the new suite were the test's fault, not
  the code's**, and both are recorded in the suite where they happened. It
  probed below a corner's minimum angle with a large negative number — which
  is a legal left turn, because that bound is on size — and it read the wrong
  error out of a list of two. A harness that calls the code broken is the
  failure mode this project is least able to see, so the comments say so.

**What the tests did NOT prove.**

- **No model has seen the narrowed prompt.** The point of narrowing it is to
  stop the model promising a braking experiment, and a headless harness has no
  key and no model. What is tested is that the facts behind the sentence hold.
- **No player has seen the new refusals.** They are better sentences by the
  standard the other four validators set; whether a circuit refusal now reads
  well in the editor is an observation only the owner can make.
- The six section types the prompt withholds were investigated and
  **deliberately left alone** — see TRAPS 19 and "Human decision needed" below.
- Nothing ran on the owner's Windows machine. `run_tests.bat` was not edited
  and not executed; the new suite is picked up by both runners from
  `tests/*.gd` with no list to maintain.
- `sweep_test` still reports that no legal command reaches
  `FAILED_UNWALKABLE`, unchanged and still TRAPS 6's own example.

## 029 — what a validator does with a value that is not a number

**Objective.** HANDOVER named the next assistant task as the readback audit,
and two smaller ones, the first being that `SectionValidator`'s `_forbid`,
`missing` and `must be a number` messages name a field but not what a legal
value would be. Starting on that one — the smallest, and the leftover of 028 —
meant reading every refusal in every validator against the rule 028 set. That
read found something else, in the same place, that is not about wording.

**What was wrong.** `DungeonModule._side()` was the only numeric reader in
Genesis that never asked `typeof()` before converting. Every number in a
request arrives through `JSON.parse`, and `float()` has no constructor for
`null`, an object or a list: it throws, and the throw abandons the rest of the
function. Measured, before the fix:

| request | what `validate` returned |
| --- | --- |
| room width `null`, `{}` or `[20, 20]` | **`ok: true`, `errors: []`**, room 0 m across |
| a door pair holding `{}` or `null` | **`{}`** — no `ok`, no `errors` |
| room width `"10"` | accepted as 10 m |
| room width `"ten"` | refused as *"width is 0 m"* — a number nobody typed |

And all three world readbacks — dungeon, farm, circuit — returned **the empty
string** for the first three, because they read raw request numbers the same
way. A player who mistyped one section of a circuit was told nothing about any
of it.

The first row is this project's central claim failing in the quietest way
available: not a validator that was wrong, a validator that called a spec
sound without having read it. The second is worse in a different direction,
because `game_controller` indexes `check["ok"]` directly.

**Why no suite saw it.** Every suite hands its validators numbers, because the
person writing a test for a width writes a width. 35 suites passed before and
35 after. `SectionValidator`, `FarmModule`, `CarTool` and `BootsTool` all check
`typeof()` and always did — and so does `_things_said()`, two hundred lines
down `dungeon_module.gd`. So this is TRAPS 18 one layer deeper: not a file that
missed the project's conventions, a function that missed its own file's.

**Implementation.** `Readback.as_number()` and `Readback.measure()` are now the
one place that decides whether a value out of a request is a number —
`readback.gd` is a leaf everything already depends on. **That sentence was
wider than the code when it was written, and 030 made it true rather than
editing it away.** 029 changed `DungeonModule` and the three readbacks; the
other four validators went on hand-rolling the same `typeof()` pair, so the
"one place" was one validator out of five. The behaviour was identical either
way, which is why nothing caught it — this is the claim-wider-than-the-code
fault of TRAPS 15 and 17 in a commit message, one commit after TRAPS 20. `_side()` and the door
reader use them and refuse rather than clamp (the old `clampf` was inert only
because an error happened to be appended beside it). All three readbacks use
them, and a measurement that is not a number is **left out** rather than
printed as 0: `Readback.size_of()` returns `""`, and a circuit says "a
straight" where it would have said "a 0 m straight". A string is no longer a
number anywhere, which is a change — the other four validators already refused
`"10"`.

**Evidence.** Godot 4.7.1 (4.7.1.stable.official.a13da4feb) headless, Linux,
in a cloud container. Baseline before the change: 35 suites, 0 with something
to look at, with `--all` as well. After: **36 suites, 0 with something to look
at, with `--all` as well**, `drive_test` and `session_test` included.

`tests/request_types_test.gd` is new and passes **267 assertions**: all six
values that are not numbers (`null`, `{}`, `[1, 2]`, `true`, `"ten"`, `"10"`)
put through every numeric field of all five validators, with the field lists
read out of the code — section shapes built from the bounds constants, tool
fields taken from `defaults()` — so a field added later is probed without the
suite being edited (TRAPS 13). Each refusal is checked for an `ok` key, a
false verdict and the field's name, because a thrown conversion returns a
dictionary that no assertion about `errors` would notice. No readback may be
empty, and **no readback may state a digit the request did not contain**,
which is how "a 0 by 10 m barn" is caught without testing a word of the
wording. The sound case is asserted too — a suite proving things are refused
would pass if everything were refused.

Run against the pre-fix code the new suite fails **36 times**: 16 the dungeon's
own refusals, 12 a circuit's readback, 6 a farm's, 3 a dungeon's. The scripts
were then restored and `cmp` used to confirm all four files came back
byte-identical.

**NOT VERIFIED.** No model has produced any of these inputs in this session —
a headless harness has no key and no model, so what is tested is what the code
does with JSON of each shape, not how often a model writes it. `null` for an
unknown field is the one worth the owner watching for; the others are
inferences about model output, not observations. No player has seen the new
sentences: *"a dungeon of two rooms joined by a door, entered through a vault"*
reads correctly to me and the judgement about whether a missing size reads as
deliberate or as a bug is the owner's. Nothing ran on Windows; `run_tests.bat`
was not edited and not executed. No module, builder, solver or ledger logic
was touched beyond the readers named above, and `sweep_test` still reports
that no legal command reaches `FAILED_UNWALKABLE`.

**A claim in this file was wrong, and is corrected rather than quietly
edited.** Under "Next action", 028 wrote: *"A refusal is now actionable in
every validator but one place."* That is not true. Reading all five against
the rule turned up the same shape in four of them:

- `CarTool` and `BootsTool` both say bare *"`power` must be a number"* with
  no range, though the range is in scope on that very line.
- `FarmModule` says *"zone 1 (barn): missing 'width'"* and *"zone 1 has no
  type"* with no range and no list of types — while its *unknown* type error
  does list them.
- `SectionValidator` says *"section 1: unknown type 'x'"* naming none of the
  ten, and `_forbid` says *"'bank' is not a straight setting"* without saying
  what a straight's settings are.
- `DungeonModule`'s own missing/not-a-number messages now name the bound,
  because 029 was rewriting those lines anyway.

So the wording task is larger than 028 recorded and is still open; it is
restated under "Next action". The fact that a sentence in this file overstated
how finished something was, one commit after TRAPS 15 and 17 were written about
exactly that, is worth more than the wording itself.

---

## 030 — a refusal has three doors, and two of them said nothing

**Objective.** The list 029 left open and told the next session to do whole:
a refusal that names no legal value, in four validators rather than the one
028 had recorded. Reading all five against the rule — rather than the four
files HANDOVER named — turned up an axis neither 028 nor 029 had noticed.

**Starting state.** Branch `prototype-002a` at daeb2fd (029). Baseline run,
Godot 4.7.1 headless: suites with something to look at: 0, with `--all` as
well. 36 suites.

**What it actually was.** Not four files. **Three doors.** A bounded field can
be refused in three ways, and 028 fixed one of them and 029 audited the same
one:

```
out of range    room 1: width is 500 m, and must be 4 to 40 m     tested, named
not a number    power must be a number                            named nothing
missing         zone 1 (barn): missing 'width'                    named nothing
```

Measured before the change, in a cloud container on Godot 4.7.1:

```
CarTool           power must be a number
BootsTool         push must be a number
FarmModule        zone 1 (barn): missing 'width'
                  zone 1 (barn): 'width' must be a number
                  zone 1 has no type
SectionValidator  section 1 (straight): missing 'length'
                  section 1 (straight): 'length' must be a number
                  section 1 (straight): 'bank' is not a straight setting
                  section 1 (corner): do not supply 'length'
                  section 1 has no type
                  section 1: unknown type 'loop'
                  intent must be an object
```

Twelve, in four of the five validators. `CarTool._bounded` had `limits` in
scope and used them in the range branch and not in the branch three lines
above it. `SectionValidator._number` did not take the limits at all, so the
range refusal could name a bound that the missing refusal structurally could
not. And the two silent doors are the ones a MODEL walks through: `null` for a
field it had nothing to say about, or a field simply left out. Out of range is
a player asking for a 2 km straight; these two are ordinary model output, which
is trap 20's input arriving at a different layer.

`tests/capability_test.gd` had asserted the limit-naming claim for every bound
in all five validators since 028 — TRAPS 11 done properly on the axis 028 knew
about — and saw none of this, because the claim it quotes from the prompt is
about one door. **The whole class was probed through a third of its
entrances.** That is TRAPS 21.

**The one place where the obvious fix would have been a regression.**
`SectionValidator`'s unknown-type refusal names no types, and the obvious
repair is to list `SECTION_TYPES`. That would have printed all ten to the
player — including the six TRAPS 19 records as deliberately withheld, because
`docs/GENESIS_BRIEF.md` says banked corners throw cars over the barrier, loops
are untested with a car, the separation check reads a loop over itself as a
crash, and the solver does not check return-to-height. The wall lived only in
the prompt; a refusal nobody was testing would have gone round it.

So the refusal names `OFFERED_TYPES` — the four the prompt offers — and that
constant carries the reason, where the restriction is, which is what TRAPS 19
asked for. **Nothing about which types are offered has changed**, and the
question of whether to open the six is still the owner's: item 1 under "Human
decision needed" below, untouched.

**Implementation.** No module, builder, solver, ledger or prompt logic
changed. `PROMPT_VERSION` is untouched and the AI's prompt is byte-identical.

- `scripts/car_tool.gd`, `scripts/boots_tool.gd`: the not-a-number refusal
  names the bound, from the same `limits` the range refusal reads.
- `scripts/farm_module.gd`: `_number()` now takes the limits the caller has
  already worked out (a building's 5–60 m, a field's 20–300 m), so both its
  refusals name them. `zone N has no type` lists `ZONE_TYPES`, which the
  unknown-type refusal beside it has always done.
- `scripts/section_validator.gd`: `_span()` builds the "20 to 1000 m" phrase
  once and `_range_error()`, the missing refusal and the not-a-number refusal
  all read it, so three refusals about one field cannot disagree about its
  bound. The range refusal's text is unchanged, byte for byte. A chicane's
  offset, the one bound that is not a constant, names the rule instead: *more
  than 0 and at most twice the radius*.
- A new `FIELDS` table says what each section type is made of. `_forbid()`
  derives the forbidden set from it instead of being handed a hand-written
  list at each call site, and the refusal now says what the type DOES have:
  *"'length' is not a corner setting (a corner has radius and angle)"*. It
  also absorbs the four separate `do not supply 'length'` checks, which
  refused the same thing in different words. The forbidden set is unchanged
  for all ten types, which `_the_fields_table_is_a_fact()` asserts.
- `intent must be an object` gains the example that `FarmModule` and
  `DungeonModule` have always given.
- **All four validators now read numbers through `Readback.as_number()`.**
  029's commit and this file both said that function was already "the single
  place that decides whether a value out of a request is a number, in the
  validators and the readbacks alike". It was not: only `DungeonModule._side`
  and the three readbacks used it, and the other four hand-rolled the same
  `typeof()` pair. The claim was wider than the code — the fault 027 and 028
  were written about — one commit after TRAPS 20. It is true now. Behaviour
  is unchanged: the hand-rolled checks and `as_number()` agree on every value.
- `tests/capability_test.gd`: four new sections, 364 new assertions.
- `docs/TRAPS.md`: trap 21.

**Evidence — what was actually run.** Godot 4.7.1
(`4.7.1.stable.official.a13da4feb`), Linux, headless, in a cloud container:

- Baseline before: **0 suites with something to look at**, without `--all` and
  with it, all 36 suites.
- After: **0 suites with something to look at**, without `--all` and with it,
  `drive_test` and `session_test` included.
- Every one of the twelve refusals above was printed before and after by a
  throwaway probe. The table in the 030 section of `capability_test.gd` is
  that output, not a reconstruction.
- `capability_test` grew from 165 assertions to 529. Against the four
  validators carrying their **pre-030 messages** it fails **109 times**:
  23 a bound not named with the field left out, 32 a bound not named with the
  field `null`, 49 a forbidden field refused without saying what the type has,
  3 an enumerated list not named, 2 a chicane's offset not tied to its radius.
  The four scripts were then restored and `cmp` confirmed all four
  byte-identical to the versions the suite was run against.

**What that measurement is, exactly, because it is not the usual one.** The
suite reads `SectionValidator.FIELDS` and `OFFERED_TYPES`, which 030
introduced, so it cannot run against the pre-030 file verbatim — the
comparison was made against those files with only their MESSAGE STRINGS
reverted. So the 109 measures what 030 claims to have changed, the sentences,
and not the refactor that made them possible. Said plainly here because
"fails N times against the old code" has meant something stricter in 028 and
029 and should not quietly come to mean something looser.

**NOT VERIFIED.** No model produced any of these inputs in this session: a
headless harness has no key and no model, so what is tested is what the code
says to JSON of each shape, not how often a model writes it. **No player has
read any of these sentences**, and that is the part a test cannot do. Three
are worth the owner's eye, and HANDOVER names the requests under Next action.
Nothing ran on Windows; `run_tests.bat` was not edited and not executed. The
AI's prompt and `PROMPT_VERSION` are unchanged, so nothing about what the
model is told has moved. Two of the four new test sections are **guards, not
findings**, and say so where they stand — the table 030 introduced, and a wall
that was never breached.

**What was deliberately NOT changed, so nobody re-litigates it.** Applying the
rule to the whole class means ruling on the messages that look thin and are
not. `"spec must be an object"`, `"zones must be a list"`, `"rooms must be a
list"`, `"section N is not an object"`: each names what a legal value would
be — an object, a list — so each satisfies the rule as written. `DungeonModule`'s
`"thing N: no name"` is the one real judgement call left: any name is legal, so
there is no list to give, and an example is the most it could offer. Left alone.

---

## 031 — the sentence that described two different circuits the same way

**Objective.** The readback audit this file has named as the next assistant
task since 028, and which 029 and 030 both left: *for each thing a readback
says, is the sentence as wide as the thing it describes?* It is the layer
the owner's sessions have found most of the real faults in — four of the
five in 022 were a readback describing something other than the request.

**Starting state.** Branch `prototype-002a` at bf2ea0c (030). Baseline,
Godot 4.7.1 headless in a cloud container: 36 suites, **suites with
something to look at: 0**, matching what this file already said.

**What the question turned out to be.** Not "does the sentence mention this
field" — that is a wording, and a test for it breaks when the line is
rephrased and passes when a field is dropped. The property a readback
actually has to have is a **difference**: change one field of the request
and the sentence must change, or the readback cannot catch a dropped clause,
which is the only thing it is for.

Asked that way, of every field of every readback in Genesis, measured on the
pre-031 code:

```
circuit   corner        angle       both read "a 50 m corner"
circuit   hairpin       angle       both read "a 20 m hairpin"
circuit   banked_corner angle       both read "... banked at 12 deg"
circuit   loop_segment  angle       both read "a 30 m loop"
circuit   chicane       radius      both read "a 12 m chicane"
circuit   chicane       direction   both read "a 12 m chicane"
circuit   crest         grade       both read "a 200 m crest"
circuit   dip           grade       both read "a 200 m dip"
dungeon   room 2+       name        the room was not in the sentence
dungeon   room 2+       width       at all - only the entrance was
dungeon   room 2+       depth
```

Eleven, and the farm, the car, the boots, the look tool and a dungeon's
things were sound. A corner's angle is the field that decides which way the
track turns and the one the prompt says must add up to +360 or -360; a
player asking for two 90 deg right-handers and one asking for two 120 deg
left-handers got the identical line. For a dungeon the readback named ONE
room of however many were asked for, so in a chain — the commonest dungeon
there is — everything after the entrance was absent.

**The grouping made three of them worse than silence.** Sections were
grouped by type and one measurement, and the group took its name from its
first member, so two uphills at 8% and 14% read back as *"two 200 m uphills
at 8%"* — not a field left out but a sentence **false of half the thing it
describes**. Those three (an uphill's grade, a downhill's grade, a banked
corner's bank) are said correctly for one section and lost for two, and no
probe that builds one section of a type can see them.

**Why no suite saw any of it.** 36 suites, and the ones that read a
circuit's readback assert that the numbers they supplied appear in it —
`said.contains("250")`. Every such assertion passes on a sentence that drops
a *different* field. The rule was also written in English directly above the
code that broke it: the comment on that match statement records a headless
test catching the same fault for a banked corner's BANK and says *"a
readback that silently drops a piece is the worst kind: not wrong, just
absent"*. Bank was given a phrase; the other eight fields in the same
statement were not. TRAPS 22.

**Implementation.** No validator, builder, solver, ledger or physics was
touched, and nothing about what is accepted or refused has changed.

- `scripts/racing_module.gd`: a corner, hairpin, banked corner and loop
  segment say their angle; a chicane says its radius and its direction; a
  crest and a dip say their grade. The **group key is the whole sentence**
  rather than the type and one number, so two pieces are one group only when
  everything said about them is the same. An angle is signed and bounded on
  its size — `SectionValidator` says "positive turns right, negative left" —
  so the sign is said as the word it means: *"a 50 m corner, 90 deg right"*,
  *"a 12 m chicane to the left, 40 m radius"*. A loop is the exception and
  says *"over 180 deg"* with no direction, because `TrackGeometry.advance()`
  gives a loop segment no yaw at all; its sign is kept, because `sin()` is
  odd and a negative loop angle carries the track backwards.
- `scripts/dungeon_module.gd`: every room is in the sentence, not only the
  entrance — *"entered through a 12 m hall, along with a 20 m vault and a
  16 m crypt"* — through one `_room_said()` that the entrance and the rest
  both read, so the two cannot drift into describing a room differently
  (which is how "the room 2" came back a release after it was fixed). No
  order and no direction is claimed for them: the readback runs before
  anything is validated, so "beyond it" or "then" would be a statement about
  a layout nothing has solved. Capped at six like every other list. The hub
  clause gains the comma the new clause in front of it needs.
- `scripts/readback.gd` and `scripts/npc_goals.gd`: **TRAPS 23**, found by
  widening the dungeon's sentence. 022 established that a numbered name is a
  label and takes no article and put the rule in `NpcGoals._place()`, which
  writes *the*. Nothing had asked it of *a*, and the pre-031 dungeon readback
  said *"entered through a room 1"* and *"with a key 2 in the hall"* —
  measured, not inferred. The fact now lives in `Readback.is_label()` and
  both articles read it. Widening the sentence without this would have
  printed the fault once per room instead of once per dungeon.
- `tests/said_fields_test.gd` (new): the rule as a fact. For every type in
  `SectionValidator.FIELDS`, every field of that type, every room of a
  dungeon, every zone field of a farm and every key of each tool's
  `defaults()`, it changes one field and fails if the sentence does not
  change — and fails, rather than skipping, when a field has no second value
  listed, so a type that grows a field cannot grow it silently. It asserts
  nothing about wording, so every line in this commit can be rephrased and
  the suite stays green.
- `tests/log_022_test.gd`: the indefinite half of its own article rule.

**Evidence.** Godot 4.7.1 (4.7.1.stable.official.a13da4feb) headless, Linux,
in a cloud container.

- Baseline before the change: 36 suites, **0 with something to look at**.
- After: **37 suites, 0 with something to look at**, both without `--all`
  and with it, `drive_test` and `session_test` included.
- `said_fields_test` run against the **pre-031 scripts restored from
  bf2ea0c**: **26 failures** — 19 in the circuit (the eight fields above,
  each once for one section and once for two, plus the three only two
  sections can show) and 7 in the dungeon. The scripts were then put back
  and `cmp` confirmed all four byte-identical to the versions the suite
  passed against.
- That measurement is **stronger than 030's**, which could not run against
  the old files because it read a constant the same commit introduced. This
  suite reads only `SectionValidator.FIELDS` and each tool's `defaults()`,
  both of which existed before 031, so it ran against the old code verbatim.

**Limitations — what the tests did NOT prove.**

- **No model produced any of these requests.** A headless harness has no key
  and no model; what is measured is what the code says to JSON of each shape.
- **No player has read any of these sentences**, which is the part a test
  cannot do. They are longer than they were. Whether *"a closed circuit with
  two 400 m straights, two 50 m corners, 120 deg left, a 20 m hairpin, 150
  deg right and a 12 m chicane to the left, 40 m radius"* reads as help or
  as noise is the owner's call; see Next action.
- Nothing ran on Windows; `run_tests.bat` was not edited and not executed.
- **The AI's prompt and `PROMPT_VERSION` are byte-identical.** A readback is
  output, not instruction: nothing the model is told has moved.
- The six withheld section types (TRAPS 19) now have fuller sentences too.
  Nothing about which types are OFFERED has changed, and no refusal names
  them.
- `said_fields_test` is a guard for everything it covers outside the circuit
  and the dungeon's rooms. The farm, the car, the boots, the look tool and a
  dungeon's things have always passed it, and the suite's header says which
  assertions were findings and which were guards (TRAPS 6).

**One thing noticed and deliberately not fixed.** `Readback.join_capped()`
writes *"a, b, c, d, e and f and 2 more"* — two "and"s, because it joins the
six it shows and then appends the remainder. It is pre-existing, it is
shared by the farm and the circuit as well, and it is a wording rather than
a dropped field. 031 makes a capped dungeon list likelier to be seen, so it
is recorded here rather than folded into a commit about something else.

---

---

## 032 — the two commands nothing described, and what that was hiding

**Objective.** The task this file named as the next assistant one: the plan
readback, which 031 did not reach. 031 asked, of every field of every world's
long readback, *does the sentence change when the field does*. This asks the
same question one layer up, and off the other list — not every field of one
command, but **every command `CommandParser.allowed_commands()` admits**.

**Starting state.** Branch `prototype-002a` at 0dadcf0 (031). Baseline run,
Godot 4.7.1 headless: suites with something to look at: 0, 37 suites.

**Why the plan layer and not just the single-command one.** `WorldRegistry.readback`
sends a `PLAN` to `_plan_readback` and never to a world's long readback. So
for a multi-world request the short line is the **only** description a player
is ever shown, and a field silent there is a field said nowhere.

### What the audit found, measured headless before anything was changed

**Two of the eleven whitelisted commands had no readback AT ALL.**
`WorldRegistry.readback` returned the empty string for `SPAWN_OPPONENTS` and
`MODIFY_TRACK`, and inside a plan they printed the raw JSON token — *"a
dungeon of two rooms, then a spawn_opponents"*, underscore and all. Eight
opponents and two read back identically; corner 1 made hard and corner 3 made
easy read back identically.

**Two worlds were silent about how many pieces they are made of.** Inside a
plan, a farm of two zones and a farm of twenty both read *"a farm"*, and a
four-section circuit and a twelve-section one both read *"a race circuit"* —
`RacingModule.readback_short` ignored its parameters entirely. The dungeon was
the only world of the three that counted its rooms. One member of a list
right and two wrong is TRAPS 11's shape.

**And then the thing worth the owner's attention. The two commands with no
readback do nothing, and said they had.** 002B replaced Prototype 001's track
and opponents with world modules and removed the old builders' bodies — 89
lines from `opponent_builder.gd`, 148 from `track_builder.gd` — leaving the
function **signatures and their return strings**. Measured, Godot 4.7.1
headless:

```
OpponentBuilder.spawn(8, ...)           "SPAWN_OPPONENTS count=8"
                                        0 children, opponents.size() == 0
TrackBuilder.build({"corners": 4})      "CREATE_TRACK corners=4"
                                        0 children, has_track() false
TrackBuilder.modify_corner(2, "hard")   "MODIFY_TRACK corner=2 difficulty=hard"
                                        0 children before, 0 after
```

All three strings go straight to `log_message.emit()`, so they are what a
player reads. Each is a **construction-layer claim with no measurement behind
it**, which is the one thing this project's first rule forbids. `corner_nodes`
is declared, cleared and read in `track_builder.gd` and **appended to nowhere
in the repository**, so `has_track()` can never be true — which is also why
`SPAWN_OPPONENTS` can never run at all, and `MODIFY_TRACK` is the one of the
three a player actually reaches.

The silence and the false line had the same cause and hid each other: the
layer whose only job is to describe a request was silent about exactly the
commands whose outcomes were invented, so there was never a sentence to
compare a result against. TRAPS 24.

**`SPAWN_OPPONENTS` and `MODIFY_TRACK` are in no part of the AI's prompt** —
checked against `AIInterpreter.SYSTEM_PROMPT`, 7573 characters, which does not
contain either word, nor "opponent" at all. So the model is not being told
about them; they are reachable because the whitelist admits them, and
`_execute_plan` admits any whitelisted command as a step.

### Implementation

- `scripts/world_module.gd`: a world now declares `pieces()` — `["zones",
  "zone"]` for a farm — and `readback_short()` is the one implementation that
  reads it, naming the count. A new world gets the count for free, and a world
  that is not a list of pieces returns `[]` and is named alone.
- `farm_module.gd`, `racing_module.gd`, `dungeon_module.gd`: each declares its
  own pieces, by the same key its validator reads. The racing and dungeon
  `readback_short()` overrides are **deleted** — the dungeon's said what
  `WorldModule`'s now says, and racing's spelled its own name a second time
  (*"a race circuit"* against a `display_name()` of *"circuit"*), which is
  TRAPS 16's shape waiting for the release where one of them is reworded.
  **A circuit in a plan now reads "a circuit of six sections", not "a race
  circuit"** — a wording change the owner can reverse by changing
  `display_name()`, which is now the one place a world is named.
- `track_builder.gd`, `opponent_builder.gd`: each gains a `static readback()`
  beside the fields it reads, so the sentence and the code reading `count` /
  `corner` / `difficulty` cannot drift apart. `WorldRegistry.readback` and
  `_doing` both call those same functions, so a plan describes these commands
  exactly as well as a single command does.
- The same three builder functions **stop reporting success**. Each now says
  what happened, which is nothing, and the asked-for count is deliberately
  not in the line.
- `world_registry.gd`: `CLEAR_WORLD`'s sentence was written out in full in
  **both** `readback()` and `_doing()` — the two functions this commit
  extends. They agreed and nothing was making them. It is now the one const
  `CLEARED`, read by both: fixing two commands with no sentence while leaving
  a third written twice would be the instance and not the class (TRAPS 11).
- `tests/plan_said_test.gd`, new: enumerated from
  `CommandParser.allowed_commands()` and `WorldRegistry.modules()`, so a
  command added to the whitelist or a world added to the registry **adds a row
  on its own and fails the suite until its sentence tells two requests apart**.
  A command with no pair listed is a FAIL and never a skip.
- `tests/stub_claims_test.gd`, new: ties each builder's reported line to its
  own measurement — if nothing was placed, the line must not state the number
  that was asked for.
- `docs/TRAPS.md`: trap 24.

### Evidence — what was actually run

Godot 4.7.1 (`4.7.1.stable.official.a13da4feb`), Linux, headless, in a cloud
container.

- Baseline before the change: **0 suites with something to look at**, 37
  suites.
- After: **0 with something to look at**, 39 suites, both without `--all` and
  with it — `drive_test` and `session_test` included and both passing.
- **The new checks were proved able to fail, against the old code itself**
  (TRAPS 6). The seven changed scripts were restored to 0dadcf0 and the new
  suites run against them: `plan_said_test` fails **8** times (the two
  commands with no readback as single commands, the same two inside a plan,
  and the farm's and circuit's piece count at both layers — four faults,
  caught twice each, which is the point of asserting at both layers),
  `stub_claims_test` fails **3** of the 3 assertions in its first group. The
  scripts were then put back and `cmp` confirms all seven byte-identical to
  the versions the suite passed against.
  - One honest qualification on that measurement: `plan_said_test` reads
    `module.pieces()`, which did not exist before this commit, so the copy run
    against the old code carried the three keys as a literal instead. That one
    line differed; every assertion was the committed suite's. The
    `stub_claims_test` measurement needed no such change and ran verbatim.
- **The suite caught the commit's own first draft.** `TrackBuilder.build`'s
  replacement line read *"a Prototype 001 ring of 4 corners is not built any
  more"* — true, and still a `4` beside a `CREATE_TRACK` in the player's log.
  `stub_claims_test` failed it, and the count came out of the sentence. That
  is the difference between asserting a fact and asserting a wording.
- The dead-code claims above are measurements, not greps: a `TrackBuilder` and
  an `OpponentBuilder` were instantiated and their builders called, and the
  child counts, `corner_nodes.size()` and `has_track()` read afterwards.

### What the tests did NOT prove

- **No model produced any of these requests.** A headless harness has no key
  and no model, so what is measured is what the code says to JSON of each
  shape.
- **No player has read any of these sentences.** A circuit inside a plan reads
  differently than it did, and whether *"a circuit of four sections and a
  dungeon of two rooms, side by side"* is better than *"a race circuit and a
  dungeon of two rooms"* is the owner's call; the request that shows it is
  under Next action.
- **A plan still does not name a world's MEASUREMENTS, deliberately.** A farm
  whose barn is 20 m and one whose barn is 50 m still read alike inside a
  plan. A plan's meaning is mostly how its worlds are RELATED and a line long
  enough to bury that is a line nobody finishes, so the count is the one field
  the short line carries. That is a limitation, `plan_said_test`'s header says
  so, and widening it is the owner's.
- **Nothing was fixed about what the three Prototype 001 stubs DO.** They
  still do nothing; they have stopped claiming otherwise. In particular
  `TrackBuilder.build` still `clear()`s first, so a sectionless `CREATE_TRACK`
  **takes the player's world away and then reports that it built nothing**.
  Changing that is a change to behaviour on a path the owner may be about to
  delete, so it is recorded and not touched.
- Nothing ran on Windows; `run_tests.bat` was not edited and not executed.
- **The AI's prompt and `PROMPT_VERSION` are byte-identical.** A readback is
  output, not instruction, and no validator, builder, solver, ledger or
  physics was touched, so nothing about what is accepted or refused has moved.
- `sweep_test` still reports that no legal command reaches
  `FAILED_UNWALKABLE`, unchanged by this commit.

**What that says about the method.** 029 asked one question of every
validator, 030 asked every way IN to one check, 031 asked every field of
`SectionValidator.FIELDS`. Three audits driven off a table — and none of them
off `CommandParser.allowed_commands()`, which is the list that decides what
Genesis can be asked for at all. Two of its eleven members had never been
described by anything, and that silence was the reason a false success line
sat in the log for three weeks with 37 green suites around it. The next
question of this kind should start by asking which list is **authoritative**,
not which list is already in hand.

## 033 — the four commands that left no record, and the count that called boots a world

**Objective.** HANDOVER named the next assistant task as asking one more
question of `CommandParser.allowed_commands()`, the list that decides what
Genesis can be asked for, and named the question: **does every command record
a ledger entry?** 032 had asked whether every command is *described*. This is
a different layer: not what Genesis says about a request, but whether the
request is in the ledger afterwards. The ledger is the artefact this project
exists to produce, so a request that was accepted, acted on and left no trace
in it is a hole in the product rather than in a convenience.

**Starting state.** Branch `prototype-002a` at a633b8a (032). Baseline run,
Godot 4.7.1 (`4.7.1.stable.official.a13da4feb`) headless, Linux, in a cloud
container: **0 suites with something to look at**, 37 run and the two slow
racing suites skipped — matching what this file already said.

### FOUR OF ELEVEN WROTE NO RECORD, AND SEVEN EXITS IN ALL

Measured, not inferred. Each command was sent as accepted JSON through
`main._execute_json`, exactly the path a player's sentence takes, and the
ledger was read back off disk afterwards:

```
  CREATE_DUNGEON / FARM / TRACK(sections)   record under the request's id
  ORDER / SHUT / OPEN / EQUIP / PLAN        record under the request's id
  MODIFY_TRACK                              NO RECORD
  SPAWN_OPPONENTS                           NO RECORD
  CREATE_TRACK without a sections list      NO RECORD
  CLEAR_WORLD                               NO RECORD
```

A refused request was recorded; an *accepted* one on those four paths was
not. Seven exits in all, because three of them are guards rather than
builders — the two `has_drivable()` checks in `execute()` and
`SPAWN_OPPONENTS`' "build a track first" — and those are the half of those
commands a player actually meets, since `TrackBuilder.corner_nodes` is
appended to nowhere in the repository (re-checked this session, not taken
from 032) and so `has_track()` can never be true.

**And what the hole did to the layer above it.** Every one of those four
still showed a readback and still had an id minted for it, so the next
request wrote an UNDERSTANDING record with `"about"` set to that id — and no
record in the ledger carried it. Measured: three dangling references in one
eleven-request run. The layer whose whole job is to judge whether Genesis
understood a request was judging requests the ledger did not contain.

### THE COUNT BESIDE IT, WHICH IS THE PART A PERSON READS

`SessionReport.summarise` counted every record with `result == "VALID"` as a
world built. Four of the eleven commands are not worlds. Measured, with
records written by hand so that what was summarised is exactly what was
shown:

```
  a session of one EQUIP, one SHUT and one ORDER - no world at all -
    Worlds built: 3 (0 of them changes to the last world). Made another: yes.
    First world after 1 min 00 s, from "give me boots that stop in 2 m".
```

Wrong since 002G, and it is the report the owner reads after a player testing
session. It also meant the two halves of this commit could not be separated:
giving `CLEAR_WORLD` a record without fixing the count would have made
*taking a world away* read as building one.

### WHAT CHANGED

- **One reading of a record's own header.** The nine fields every record
  opens with were written out in full in six places and 033 was about to add
  four more. `GameController._new_record(command)` is now the one of them.
- **`_finish_nothing(record, category, line)`**, beside `_finish_failed`.
  The line the player reads and the reason in the record are the **same
  string**, passed in by the function that produced it, so the two cannot
  drift apart. Nothing is worded in that function. It is kept apart from
  `_finish_failed` because that writes its own multi-line announcement, and
  032 measured and wrote the three builders' sentences deliberately.
- **Each of the seven exits now ends in exactly one place**, so there is one
  record per request and no way out without one. The two guards moved out of
  `execute()` and into their handlers for that reason: a refusal is a result.
- `CLEAR_WORLD` records `construction: "CLEARED"`. Not `BUILT` — nothing was
  built; a world was taken away, which is the whole job of the command.
- Two new categories, `FAILED_NOTHING_BUILT` (the request was well formed and
  the world was the right kind; there is no implementation behind the name)
  and `FAILED_NO_HANDLER` (a guard, labelled as one: unreachable from any
  legal input, because every whitelisted command has a case).
- **`worlds_built` counts worlds**, read off `WorldRegistry.commands()` and
  never written out in `session_report.gd`, so a world added later counts for
  free. `seconds_to_first_world`, `first_world_request` and `made_another`
  follow it. A `PLAN` is judged by the steps it actually built, which its own
  record lists, so a plan of a dungeon and an errand is a world and a plan of
  two orders is not. The requests that worked and were not worlds are not
  discarded: they are reported as `done_otherwise`, on their own line.
- **An id is minted where the request is made.** `/session NAME` and `/load`
  set the controller's context but not its id, so their records were filed
  under whatever the player asked for before them. Both now mint one.
- **A record Genesis writes about its own housekeeping is not a player's
  request.** `/session NAME` clears the world before the tester's first
  sentence; that clear now leaves a record, and is counted as `by_genesis`
  rather than as a request the tester never typed.

### EVIDENCE — WHAT WAS ACTUALLY RUN

Godot 4.7.1 (`4.7.1.stable.official.a13da4feb`), Linux, headless, in a cloud
container.

- Baseline before the change: **0** suites with something to look at (37 run);
  with `--all`, **0** (39 run, `drive_test` and `session_test` included).
- After: **0** without `--all` and **0** with it, 40 suites, nothing skipped
  but the two tools.
- **The new checks were proved able to fail** (TRAPS 6). The three changed
  scripts were restored to a633b8a and the suites run against them:
  `ledger_said_test` fails **5** times (the four commands plus the dangling
  `about` references, which are reported as one failure naming all of them)
  and `report_test`'s new group fails **5**. The scripts were then put back
  and `cmp` confirms all three byte-identical to the versions the suite
  passed against.
- `ledger_said_test` drives the real `main.gd` and checks the Controller
  lines: the dungeon, the order, both doors, the boots, the farm, the
  circuit and the plan all **succeed**, so the success paths are what is
  measured and not a run of refusals.

**A fault this commit introduced, caught by a suite that is skipped by
default.** Factoring the six record headers into one function is a pure
extraction, and it broke every world record. `Dictionary.merge` does **not**
overwrite a key that is already present, so with `"command"` set by the new
header, `record.merge(module.record_fields(...))` silently stopped filling
it and every world record went to disk with an empty command. All 38 fast
suites passed. `session_test`, one of the two that only run with `--all`,
caught it by counting three worlds as one. Fixed by passing
`module.command()` in. Every other `.merge(` call in the repository was then
checked for the same collision — four of them, none colliding. TRAPS 25.

### WHAT THE TESTS DID NOT PROVE

- **No model produced any of these requests.** A headless harness has no key
  and no model, so what is measured is what the code does with JSON of each
  shape.
- **No player has read any of these records or any of these report lines.**
  Whether *"Other requests that worked: 3"* is the right way to say what used
  to be miscounted as worlds is a judgement a test cannot make, and the
  request that shows it is under Next action.
- **Nothing about what Genesis builds has changed.** No validator, solver,
  readback, prompt or piece of physics was touched; `PROMPT_VERSION` and the
  prompt are byte-identical. The three Prototype 001 stubs still do nothing,
  and a sectionless `CREATE_TRACK` **still clears the world before
  discovering it has nothing to build** — that is "Human decision needed" 2
  and was deliberately left alone again. What is new is that the ledger now
  says the world went.
- **Ids are not unique, and that is measured rather than assumed.** A plan's
  own record and the records of each of its steps all carry the plan's id,
  because `_prepare_world` reuses `current_record_id`. Measured: a two-world
  plan writes three records under one id. `ledger_said_test` therefore
  asserts that an id **resolves**, which is the property the understanding
  layer needs, and never that it is unique. Whether a plan's steps should
  carry ids of their own, pointing at the plan, is a question for the owner
  rather than a fault to fix quietly.
- **The `has_drivable()` guard on `MODIFY_TRACK` is recorded but was not
  reached in the suite's run** — the plan before it had replaced the circuit
  with a farm. Both branches go through the same `_finish_nothing`, so what
  is unproved is the branch and not the recording.
- Nothing ran on Windows. `run_tests.bat` needed no edit: it matches
  `ledger` as a substring, so the new suite already gets `--fixed-fps 120`
  there. `run_tests.sh`'s `TIMED` list was updated by hand.

## 034 — the limits named at the field and not at the box it came in

**Objective.** The task 033 left at the top of "Smallest useful assistant
task next": a refusal that names no legal value at the one door 030 did not
reach, the top-level list itself. Asked of the class rather than of the four
instances HANDOVER named.

**Starting state.** Branch `prototype-002a` at a8472f3 (033). Baseline run,
Godot 4.7.1 (4.7.1.stable.official.a13da4feb) headless, Linux, cloud
container: **suites with something to look at: 0**, with `--all`, 40 suites.

**What it actually was: nine doors, not four.** HANDOVER named four. Grep
found a fifth in the same function as two of them, and reading outwards
found four more in two files nobody had connected to the question. All
measured headless before anything was changed, each sentence generated and
read rather than inferred from the source:

```
DungeonModule.validate({})                     "rooms must be a list"
DungeonModule.validate({rooms:[r]})            "doors must be a list"
DungeonModule.validate({..., things: 7})       "things must be a list"
FarmModule.validate({})                        "zones must be a list"
SectionValidator.validate({})                  "sections must be a list"
GameController._execute_plan({})               "a plan needs a list of steps"
CarTool.validate({spec: 5})                    "spec must be an object"
BootsTool.validate({spec: 5})                  "spec must be an object"
LookTool.validate({spec: 5})                   "spec must be an object"
```

Not one names a count, a shape or an example, next to field refusals one
level in that say *"zone 1 (barn): missing 'width', and it must be 5 to 60
m"*. Every bound was in scope on the line that wrote the sentence.

Three of them are worth naming individually:

- **`doors` is required with no default.** So *"a dungeon with a hall and a
  vault"*, described by a model that said nothing about doors because the
  player said nothing about doors, is refused with four words naming nothing
  to fix.
- **`spec must be an object` sat three lines above a refusal for an UNKNOWN
  field that lists every legal one**, in the same function, in all three
  tools. One function, two refusals, one of them helpful: TRAPS 11 inside a
  single file.
- **`things` was not on anyone's list** because it is the one optional list
  in the project, so it does not refuse a request outright. It said the same
  four words.

**The seventh door, which was already right**, and is the house style the
rest were brought up to: `NpcGoals.validate_door()` answers *"a door is named
by the two rooms it joins, for example {"between": ["hall", "vault"]} (this
dungeon has hall, vault)"*. The fix was not an invention.

**Implementation.** No behaviour changed. Nothing about what Genesis builds,
accepts or refuses is different — only what it says when it refuses.

- `WorldModule.lists()`, overridden by the three worlds, declares every
  top-level list a request may carry: the key, the word for one member, the
  bounds, whether it is required, and a **sample that is a complete legal
  list**. `list_of(key)` reads one entry.
- `Readback.list_error()` writes the sentence from that declaration and
  `Readback.member_error()` writes the one for a single bad member, so the
  six list doors cannot drift apart — the rule `around_of()` and
  `_range_error()` exist for.
- `Readback.as_json()` renders the example from the declared VALUE rather
  than having it typed out beside the code, so the sentence cannot promise a
  shape the validator would reject.
- `SectionValidator.list_entry()` is the circuit's declaration, and its
  example type is read from `OFFERED_TYPES` with `FIELDS` supplying the
  field name — the wall of TRAPS 19, at the door TRAPS 21 warned it could
  leak through.
- `GameController.plan_list()` and `plan_example_step()` do the same for the
  sixth door, and are static so a test can read them without standing up a
  scene.
- `ToolModule.spec_error()` writes the tools' version from `defaults()`,
  which is the one place that knows what a tool has and is already what the
  unknown-field refusal reads. `BootsTool` overrides `has_phrase()` because
  it is the one tool with a plural name.
- `AIInterpreter.assembled_prompt()` is a pure extraction of four lines that
  were inside `ask()`, so a test can ask what the model is actually told.
  Measured at **15474 characters**, which is the number 033 arrived at from
  a scratch script — the extraction is confirmed by agreeing with a
  measurement taken before it existed.
- `Readback.plural()` for the digit form of a count, applied to every
  hand-written plural in the validators and in the dungeon's own
  measurements.

**What the doors say now**, measured, headless, every line generated and
read:

```
'rooms' must be a list of 2 to 24 rooms, for example
    [{"name": "hall", "width": 12, "depth": 12}]
'doors' must be a list of up to 48 doors, for example [[1, 2]]
'things' must be a list of up to 8 things, for example
    [{"name": "lamp", "in": 1}]
'zones' must be a list of 1 to 24 zones, for example
    [{"type": "barn", "width": 20, "depth": 20}]
'sections' must be a list of 2 to 40 sections, for example
    [{"type": "straight", "length": 200}]
'steps' must be a list of 1 to 4 steps, for example
    [{"command": "CREATE_FARM", "parameters":
      {"zones": [{"type": "barn", "width": 20, "depth": 20}]}}]
room 2 must be an object, for example {"name": "hall", ...}
door 1 must be a pair of room numbers, for example [1, 2]
'spec' must be an object (a car has power, braking, steering, grip,
    paint, nickname)
'spec' must be an object (boots have push, weight, footing, turning,
    brake, colour, nickname)
'spec' must be an object (a look has face, skin)
```

**A FAULT THIS COMMIT INTRODUCED AND CAUGHT BY READING ITS OWN OUTPUT.** The
plan's example step was first written as "the first whitelisted command that
is not PLAN", which is the obvious reading and returns `MODIFY_TRACK` — a
Prototype 001 stub that builds nothing, appears nowhere in the 15474-character
prompt the model receives, and is item 2 under "Human decision needed". The
refusal would have advertised a command Genesis deliberately withholds, in
the one sentence nobody tests. That is TRAPS 21's closing warning arriving
one door above where it was written. The example is now built from the first
world module and its own declared samples, so it is a step that would
actually build something, and `container_door_test` asserts that every
command named in any example appears in the assembled prompt. TRAPS 26.

**Found beside it: the plural at a count of one.** Measured, not inferred:

```
before   2 rooms need at least 1 doors to all be reachable (got 0)
after    2 rooms need at least 1 door to all be reachable (got 0)
before   this dungeon has 1 rooms, so there is no room 5
after    this dungeon has 1 room, so there is no room 5
```

HANDOVER asked for this of "every `Readback`-less count in the validators".
Asking it of the dungeon's measurements too found four more that can reach
one — the busiest room's door count, `DEEPEST`, `PLACED`'s slot count, and
the summary's door count. Two sentences in the same file already did it
correctly by hand (`"%d loop%s"`), which is how the counts beside them came
to do it wrong. All of them read `Readback.plural()` now. TRAPS 27.

**Evidence.** Godot 4.7.1 (4.7.1.stable.official.a13da4feb) headless, Linux,
in a cloud container.

- Baseline: 40 suites, **0 with something to look at**, with `--all`.
- After: 41 suites, **0 without `--all` and 0 with it**, `drive_test` and
  `session_test` included. TRAPS 25's lesson applied: the `--all` run is the
  one that catches an extraction fault, and this commit is mostly extraction.
- The new suite run against the OLD sentences, with the declarations left in
  place so it parses: `container_door_test` **fails 30 times**. The eight
  changed scripts were then restored and `cmp` confirms every one
  byte-identical to the version the suite passed against.
- `plan_said_test`'s new positive control run the same way: **fails 3
  times**. That control exists because the assertion beside it — "this
  sentence did NOT appear" — went green against both the old wording and the
  new, which is a check that stops checking the moment the sentence it
  quotes changes. 034 watched it do exactly that and fixed it.

**Limitations — what this does NOT establish.**

- **No model produced any of these requests, and no player has read any of
  these sentences.** A headless harness has no key and no model. Whether
  *"'rooms' must be a list of 2 to 24 rooms, for example [{"name": "hall",
  "width": 12, "depth": 12}]"* reads as help or as a wall of JSON is a
  judgement a test cannot make, and it is the only part of 034 a person has
  to look at. It is under Next action.
- **Nothing about what Genesis builds, accepts or refuses has changed.** No
  validator logic, solver, readback, physics or prompt text was touched;
  `PROMPT_VERSION` is untouched and the assembled prompt measures the same
  15474 characters as before the extraction. What changed is the wording of
  eleven refusals and six counts.
- **`doors` is still required with no default**, which is the thing that
  makes its refusal the sharp one. 034 fixed what it SAYS and deliberately
  did not change what it accepts: whether a dungeon with no doors described
  should be refused at all, or should fall through to the reachability check
  (*"2 rooms need at least 1 door to all be reachable (got 0)"*, which is a
  better sentence still), is a question about what Genesis accepts rather
  than about what it says. New "Human decision needed" 7.
- **The examples are not claimed to be the best ones to show.** They are
  claimed to be legal, and that claim is measured: the suite assembles a
  request out of every declared sample and fails unless the validator
  accepts it.
- **Nothing ran on Windows.** `run_tests.bat` needed no edit — checked, not
  assumed: `container_door_test` matches none of its `findstr` patterns, so
  it runs there with the same arguments it gets here.
- **The plural sweep covers the sentences this suite causes to be produced**,
  which is most of the validators and the dungeon's measurements, and not
  every string in the project. The two `"%d of %d rooms"` sites were fixed
  anyway, on reasoning rather than measurement: `MIN_ROOMS` is 2 today so
  they cannot be wrong, but `MIN_ZONES` was lowered from 2 to 1 in 003 for
  exactly the reason `MIN_ROOMS` might be, and a plural that is correct
  because of a bound in another file is a plural waiting to be wrong. Said
  plainly because it is reasoning and not evidence.

---

## 035 — a bound stated to the model, and a version that named three prompts

**Objective.** HANDOVER named the next assistant task as one sentence: the
farm prompt states *"Use 2 to 24 zones"* and `FarmModule.MIN_ZONES` is 1. It
also said the question of whether `PROMPT_VERSION` moves with it was worth a
minute's thought first. Both were done, in that order, and the second turned
out to be the larger finding.

**The bound, asked of the class rather than of the sentence (TRAPS 11).**
Every numeric bound in `AIInterpreter.assembled_prompt()` was measured
against the constant that enforces it, headless, by asking the validator
rather than by reading the source:

```
farm zones         prompt "Use 2 to 24 zones"      validator accepts 1   WRONG
circuit sections   prompt says nothing             validator 2 to 40     MISSING
dungeon rooms      prompt "2 to 24 rooms"          validator 2 to 24     ok
dungeon doors      prompt "at most 48 doors"       validator up to 48    ok
dungeon things     prompt "At most 8."             validator up to 8     ok
plan steps         prompt "Up to 4 steps."         MAX_PLAN_STEPS 4       ok
room sides, zone sides, every section range, the solver's 20%,
the road's 18 m                                                           ok
```

**The farm's is the one that costs a player a request**, and it costs it
invisibly. 003 lowered `MIN_ZONES` to 1 because *"build a farm with a barn"*
is about the most natural thing a first-time player can type, and 003 changed
the minimum specifically so it would stop being refused. The prompt then told
the model not to send one — so the refusal happens **in the model, before
Genesis ever sees the request**, which is why no suite could have caught it:
a refusal gets checked, and this is a request that is never made.

**The circuit's is the one nothing had ever asked.** A section count of 2 to
40 appeared in no sentence the model reads. A model asked for a long
technical circuit could compose 41 sections and be refused by a limit it had
never been told — trap 26's fault (a door that names nothing) at the one door
that is not a refusal. The prompt now says *"Use 2 to 40 sections: at least 2
straights and at least 2 corners or hairpins"*, which is the existing rule
line with the count in front of it.

**WHAT CHANGED.** Nothing Genesis builds, accepts or refuses. Every bound
every validator enforces is the same number it was. What changed is what the
model is **told**, in four lines, and where those sentences get their numbers:

```
- Use 2 to 24 zones.                     + Use 1 to 24 zones.
- Use at least 2 straights and at        + Use 2 to 40 sections: at least 2
  least 2 corners or hairpins.             straights and at least 2 corners
                                           or hairpins.
- ... may not be the name of a room.     + ... may not be the name of a room.
  At most 8.                               At most 8 things.
- Use 2 to 24 rooms and at most 48       + Use 2 to 24 rooms and up to 48
  doors.                                   doors.
```

The assembled prompt goes from **15474 to 15497 characters** and those four
lines are the whole difference — every other byte is identical, which is the
evidence that the eleven generated bounds reproduce what was typed out by
hand. `Readback.list_rule()` writes a declared list's bound for the model the
way `list_error()` writes it for the player; both read `lists()`, and
`list_error()` now calls `list_rule()` so there is one branch rather than two.
The three world modules' prompt sections interpolate every bound from its
constant, the way `boots_tool.gd` and `car_tool.gd` always have — which is
why the tools had none of this fault.

**And the version, which is the larger half.** The question *"does
`PROMPT_VERSION` move?"* was answered by measuring what it had done so far:
the prompt-contributing strings were extracted at every commit from 025 to
034 and hashed.

```
025, 026                      14470 characters   025-what-genesis-does-1
027 (limitations narrowed)    15030 characters   025-what-genesis-does-1
028 (physics narrowed) .. 034 15306 characters   025-what-genesis-does-1
```

**Three prompts, one version string.** `PROMPT_VERSION` exists so that
interpretation measured under one prompt is not compared with interpretation
measured under another — that is why every ledger record carries it. 027 and
028 were both *about* the prompt and both left it behind, so every
before-and-after comparison across either is not a comparison. Nothing was
checking it, because no test knew what the prompt was supposed to be.

`AIInterpreter.PROMPT_FINGERPRINT` is now the sha256 of `assembled_prompt()`
and `prompt_bounds_test` fails when they disagree, naming the new hash and
saying to move `PROMPT_VERSION` as well. `PROMPT_VERSION` is now
`035-bounds-from-the-code-1`. It is a fingerprint and not an assertion about
wording: it says only that the prompt the model receives is the one the
version names.

**Evidence.** Godot 4.7.1 (4.7.1.stable.official.a13da4feb) headless, Linux,
in a cloud container.

- Baseline: 41 suites, **0 with something to look at**, with `--all`.
- After: 42 suites, **0 without `--all` and 0 with it**, `drive_test` and
  `session_test` included.
- `prompt_bounds_test` run against the pre-035 prompt sections, with
  `readback.gd` and `ai_interpreter.gd` left in place so it parses:
  **fails 4 times** — the farm's stated minimum of 2 against a declared 1,
  the circuit's count stated nowhere, the dungeon's `things` bound naming no
  noun for its 8, and the fingerprint, which prints the old prompt's hash.
  The three modules were then restored and `cmp` confirms every one
  byte-identical to the version the suite passed against.
- The prompt was dumped before and after and diffed: **four lines, 15474 to
  15497 characters.** Measured, not reasoned.

**What the new suite asserts, and what it does not.** Its strongest
assertion is not about the prompt's words. For every list any world declares,
it hands the validator `low - 1`, `low`, `high` and `high + 1` members and
requires exactly the first and last to be refused **for their count** — so a
declaration edited to match a wrong sentence fails as surely as a sentence
that misstates a declaration. The chain is prompt ⇔ declaration ⇔ validator
and all three links are measured. The prompt side is read with a regular
expression over *"N to M members"* and *"at most N members"*, so no sentence
is quoted and any of them may be rewritten. The lists are enumerated from
`WorldRegistry.modules()`, so a world added later is covered without editing
the suite.

**Limitations — what this does NOT establish.**

- **No model has read the new prompt.** A headless harness has no key and no
  model. Whether telling the model a circuit's section count changes what it
  composes, and whether a one-zone farm now actually gets built when asked
  for, are the two things only the owner's editor session can show. They are
  under Next action.
- **Nothing about what Genesis accepts or refuses has moved.** No validator,
  solver, builder, readback or ledger was touched. A one-zone farm validated
  before 035 and validates after; what changed is that the model is no longer
  told not to ask.
- **The records already made cannot be fixed.** They are on the owner's
  machine and 035 did not go near them. The character counts above are
  recorded so that a reader can split them by hand: a record under
  `025-what-genesis-does-1` was made under one of three prompts, and only the
  commit date tells which.
- **The `things` sentence previously named no noun**, and calling that a
  fault is a judgement rather than a measurement. *"At most 8."* sits
  directly after the `THING:` line, so a model almost certainly read it
  correctly. It now says *"At most 8 things."* because a bound that names
  what it counts is the rule everywhere else in the prompt — said plainly
  because it is reasoning and not evidence.
- **One number still stands for two constants.** The prompt says the solver
  may move an angle and a straight's length *"by up to 20%"*, and those are
  `MAX_ANGLE_ADJUSTMENT` and `MAX_LENGTH_ADJUSTMENT`, both 0.20. The suite
  fails if they ever differ, at which point the sentence has to name them
  separately rather than quietly describe one of them as both.
- **Nothing ran on Windows.** `run_tests.bat` needed no edit — checked, not
  assumed: `prompt_bounds_test` matches none of its `findstr` patterns, and
  in particular does not contain the literal `prompt_test`, so it is not
  skipped as a tool (TRAPS 4).
- **The sweep covers numeric bounds and the two value lists nothing else
  held** (a farm's zone types and its crops, now read from `ZONE_TYPES` and
  `CROP_COLOURS`). The circuit's four offered types were already held by
  `capability_test` and are not asserted twice. What is *not* swept is the
  prompt's prose claims about mechanism — those are `capability_test`'s and
  `limits_test`'s ground, and 027 and 028 did that reading.

---

## 036 — the commands with no validator, and what that turned out to mean

**Objective.** The question this file named as the next assistant task: *does
every command have a validator?* — the fourth question off
`CommandParser.allowed_commands()` after described (032), recorded (033) and
reachable-from-the-prompt (033).

**Starting state.** Branch `prototype-002a`, commit 035. 42 suites, 0 with
something to look at, `--all` included — measured before anything was
changed, not remembered.

### The answer, and why it is not a missing function

Four of the eleven commands have no validator between the AI's parameters and
the code that uses them. Stated that way it sounds like a gap in a diagram.
What it MEANS was measured headless, by sending each command the six values a
model writes where a number belongs:

```
MODIFY_TRACK     "corner": {} [] null    NO RECORD AT ALL
                 game_controller.gd:1225
CREATE_TRACK     "corners": {} [] null   a record whose only reason is
(sectionless)    track_builder.gd:26     THE EMPTY STRING
PLAN step        "around": {} [] null    the plan refused for the worlds
                 world_registry.gd:56    OVERLAPPING
PLAN step        "offset": {"x": null}   the world built, never positioned
                 game_controller.gd:914
SPAWN_OPPONENTS  "count": {} [] null     unreachable (has_track() is always
                 game_controller.gd:1246 false; the guard returns first)
```

029's mechanism, in the places 029 could not reach. `int()` and `float()`
have no constructor for `null`, `{}` or `[]`: the call throws, and a throw
abandons the function and leaves the caller holding the default. 029 asked
"what if this is not a number" of every numeric field of every **validator**.
These four commands have no validator, so nobody asked.

**`MODIFY_TRACK` is 033's fault returning.** The throw lands after
`_new_record()` and before `_finish_nothing()`, so the request left no record
at all — while `main.gd` still wrote an understanding record pointing at its
id. 033 fixed exactly that dangling reference for four commands; a value that
is not a number put one of them back. The player saw **nothing**: no log
line, no refusal, no record.

**The sectionless `CREATE_TRACK` is 029's shape in a builder.**
`TrackBuilder.build()` returns a `String`, so the abandoned call handed back
`""`, `_finish_nothing` recorded `reasons: [""]` and the player got a blank
line — after `clear()` had already taken their world away.

**`around` is the one a player pays for, and it is in the prompt.** The model
is TOLD to write `"around": N`. A value Genesis could not read was taken as
0, both worlds were placed at the origin, and the plan came back refused for
*"step 2 overlaps step 1: they must stand apart, or one must be big enough to
contain the other with 15 m to spare"*. True, and about the wrong thing: the
player asked for one world inside another and Genesis never read which. Found
beside it, same field, same sentence: an `around` naming a LATER step or
itself was also silently not centred and also refused for overlapping —
`_place()` centres on `plan_footprints[N - 1]`, which holds only the worlds
already placed, so only an earlier step can ever be surrounded, and nothing
said so.

**And the safe reading was already here, one function above two of them.**
`TrackBuilder.readback()` has read `corner` through `Readback.as_number()`
since 032; `OpponentBuilder.readback()` has read `count` the same way. The
validators' own comments call that function *"the one place in Genesis that
answers the type question"*. The handlers two files along typed `int()` out
by hand — TRAPS 28's shape in a handler rather than in a prompt.

### Implementation

Asked of the class and not the instance (TRAPS 11). Every conversion of an
AI-supplied value that no validator stands in front of now goes through
`Readback.as_number()` / `Readback.measure()`. The sweep that found them is
recorded so the next reader need not repeat it: every `int(` and `float(`
applied to a `.get()` in `scripts/` was read, and all but these five take
values that have already been through a validator (a clean `spec`, validated
`sections`, builder metrics) or are internal (`current_attempt`, set by
`main.gd`, never by the AI).

- `world_registry.gd` — `around_of()` no longer throws. `around_given()`
  returns the value **unconverted**, so a caller can tell missing from not-a-
  number from out-of-range; `around_problem()` is the one check, beside the
  one reading, because the field may be written at the step level or inside
  `parameters` and a check looking in one place would pass a step the builder
  reads from the other.
- `game_controller.gd` — `_modify_track` and `_spawn_opponents` refuse a
  non-numeric `corner` / `count` naming the field; `_execute_plan` runs
  `around_problem()` over every step; `_place` reads `offset`'s `x` and `z`
  safely; `PLAN` now refuses a non-object `intent`, which all three world
  validators and `SectionValidator` already did and the fifth door did not —
  so a ledger record can no longer carry a string where every other record
  carries an object.
- `track_builder.gd` — `corners` read safely, so the sentence the function
  was always going to return actually gets returned.

**Where the value changes what Genesis does, it refuses and names the field.
Where the command builds nothing whatever it is sent, the debt is a record
with a reason that is not the empty string.** Those are paid differently on
purpose. `MODIFY_TRACK`, `SPAWN_OPPONENTS` and the sectionless `CREATE_TRACK`
build nothing either way, so none of this changes what Genesis makes.

**What was deliberately NOT changed.** The sectionless `CREATE_TRACK` still
`clear()`s before discovering it has nothing to build. That is "Human
decision needed" 2(b), 032 and 033 both left it, and so does this: the world
still goes, and what changed is only that the player is now told why.

### Evidence — what was actually run

Godot 4.7.1 (`4.7.1.stable.official.a13da4feb`) headless, Linux, in a cloud
container.

- **Baseline, before any change, `--all`: 42 suites, 0 with something to look
  at.** `drive_test` and `session_test` included.
- **After, `--all`: 43 suites, 0 with something to look at.** Also run
  without `--all`: 0.
- **`command_schema_test` fails 28 times against the pre-036 code.** Measured
  the way 035 measured its own: `game_controller.gd` and `track_builder.gd`
  reverted to 035, and `around_of()` put back to the throwing `int()` while
  `around_problem()`/`around_given()` were left in place so the suite parses.
  The 28: 3 missing records (`MODIFY_TRACK`), 3 empty reasons (the ring), 20
  for `around` refused as a scene fault rather than a shape fault and naming
  the consequence instead of the field, 1 for `around_of` returning 1 from
  `int(true)`, and 1 dangling-id check covering the three vanished records.
- **The probe that found all this was run before and after** and is in the
  session log rather than the repository: 20 `SCRIPT ERROR: Invalid call.
  Nonexistent 'int'/'float' constructor` lines before the change, across four
  sites (`_modify_track` 3, `_place` 2, `TrackBuilder.build` 3,
  `around_of` 12 — three call sites per request). **0 after.**
- **The prompt is byte-identical**: 15497 characters, `PROMPT_FINGERPRINT`
  matches, so `PROMPT_VERSION` stays `035-bounds-from-the-code-1` and
  `prompt_bounds_test` passes. Checked rather than assumed — 036 touches what
  Genesis DOES with a field, not what the model is told about it. And the
  prompt's own sentence about `around` (*"N is the number of the earlier
  step"*) is now what the code enforces, which it was not: the code allowed
  forward references and 0.
- **`run_tests.bat` needed no edit, checked rather than assumed (TRAPS 4).**
  `command_schema_test` matches none of its `findstr` patterns, so it is not
  skipped as a tool and does not get `--fixed-fps 120` on Windows — and it
  was run here **without** `--fixed-fps` as well, and passes. It is not in
  `run_tests.sh`'s `TIMED` list for the same reason: it awaits process frames
  only, never a physics frame.

### What the tests did NOT prove

- **NO MODEL HAS SENT ANY OF THESE REQUESTS.** Every malformed value in this
  commit was typed by hand into `_handle_request`. A headless harness has no
  key and no model. Whether a model actually writes `"around": null` is
  exactly the thing only the owner's editor session can show, and the premise
  that it does is 029's, measured there and inherited here rather than
  re-established.
- Nothing ran on Windows.
- **Two of the five sites are guards and not findings (TRAPS 6).**
  `_spawn_opponents` cannot be reached with a bad `count` while
  `has_track()` is always false, and `_place`'s `offset` is reached by no
  prompted request. They were fixed because the fault is the class; they
  measured nothing.
- **The records already written cannot be fixed.** The ledger on the owner's
  machine may contain understanding records pointing at ids no record
  carries, from any `MODIFY_TRACK` whose `corner` was not a number. 036 did
  not go near them.
- **One judgement, labelled as one.** That a plan step whose `around`
  Genesis cannot read should be refused for its SHAPE rather than built and
  then refused for overlapping is a design decision, not a measurement. It
  follows 029's and 030's convention for every other numeric field, and it
  changes what Genesis does with one shape of request: a **single-step** plan
  carrying a stray `around` used to build (the field was silently ignored)
  and is now refused. No other accepted request changed — the four
  multi-world cases were already refused, for the wrong reason.
- `capability_test`, `drive_test`, `session_test`, `plan_said_test` and
  `log_023_test` all pass unchanged, and every `around` in them is `1` on
  step 2, so the "earlier step" rule was checked against every existing use
  rather than assumed compatible.

TRAPS 30 records the fault, the rule, and the near miss that trap 14 caught.

## 037 — the field the prompt asks for six times, and read at three doors

**Objective.** The question this file named as the next assistant task:
036's `offset` finding asked of every field rather than of the one it was
found at. *For every field any handler or builder reads out of the AI's
parameters, is it named in the assembled prompt, and is it checked by
something?*

**Starting state.** Branch `prototype-002a`, commit 036. 43 suites, 0 with
something to look at, `--all` included — measured before anything was
changed, not remembered.

### The question had to be asked at the DOOR, not at the field

Asked field by field, the answer is *yes, all of them*, and that answer is
worthless. Every one of the **44 field names the assembled prompt mentions**
— enumerated from the prompt by reading the quoted keys out of its JSON
skeletons, not written out by hand — has a read site somewhere in
`scripts/`. A sweep at that granularity reports all clear.

The fault is one door along. `intent` is offered by **six** of the prompt's
skeletons — every world and all three tools, which makes it the field the
model is told to send more often than any other — and it was read at
**three**. The three `EQUIP` skeletons were not read anywhere: not in
`game_controller._equip`, not in `ToolRegistry`, not in `CarTool`,
`BootsTool` or `LookTool`. A field can have five honest readers and a sixth
door where it falls on the floor, and only a per-door reading sees it.

That is **036's `offset` reversed, and it is the worse direction**. `offset`
is a field the code reads that the prompt never offers, so no prompted
request reaches it and nothing is lost today. `intent` at an `EQUIP` is a
field the **prompt instructs the model to send**, so it arrives on real
requests — and went in the bin.

### What that cost, measured headless rather than inferred

```
EQUIP car   {"intent": {"style": "rally_car"}}   record has NO "intent" KEY
EQUIP boots {"intent": [1, 2]}                   accepted, result VALID
EQUIP look  {"intent": 7}                        accepted, result VALID
CREATE_FARM {"intent": "smallholding"}           refused, field named
```

- **No `EQUIP` record in the ledger carried an `intent` key at all.** The
  style a player described for a tool was absent from the one artefact this
  project exists to keep. Every record before 037 is like this and 037 did
  not go near them; they are on the owner's machine and they are his.
- **`main._on_track_measured` reads `record["intent"]["style"]`** for the
  `REQUESTED` line the player sees, and `_equip` emits `track_measured`. So
  the panel said **`REQUESTED: not stated`** for every tool ever asked for,
  while a farm carrying the identical field said `smallholding`. Measured
  side by side, both lines in the probe output.
- **An `intent` that was a string, a list, a number, a bool or `null` was
  accepted in silence** at all three tools, while the other five doors
  refused it and named the field. This is the sixth door to the field 036
  called the fifth.

### What changed, asked of the class and not the instance (TRAPS 11)

The five doors that did ask the question each wrote the sentence out by hand
with its own example — which is the shape `Readback.list_error()` was
created to stop, in the file whose own comment says *"six copies of a
sentence diverge, and the one that diverges is the one nobody is reading"*.
Adding a sixth copy would have been fixing the instance.

So the question is now asked in one place and the six doors read from it:

- **`Readback.intent_problem(parameters, example)`** — `""`, or the refusal.
  The example is rendered through `as_json()` from a real value, for the
  reason `member_error()` renders its own: an example typed out beside a
  check is an example nothing checks. The suite parses the example back out
  of the sentence and asserts the check accepts it.
- **`Readback.intent_of(parameters)`** — the same field read for the
  RECORD, substituting `{}` for a non-object. This was
  `WorldModule.record_fields()` and `RacingModule.record_fields()` doing it
  by hand; both now read this.
- `FarmModule`, `DungeonModule`, `SectionValidator` and `PLAN` call
  `intent_problem`. **Their sentences are byte-identical to what they were**
  — checked by diff, not assumed — so nothing a player reads changed at
  those four doors and no suite assertion about them moved.
- **`_equip` is the new door.** It records `Readback.intent_of(parameters)`
  before validating anything, so a refused `EQUIP` says in the ledger what
  it was refused about, which is what the worlds have always done; and it
  refuses a non-object naming the field.
- **`_equip` now answers both faults rather than the first.** A spec whose
  `intent` is a string and whose `tool` is missing is told about two things.
  `SectionValidator` has done this for a section's `length` and `grade`
  since it was written; this function returned on the first.

**One example for the `EQUIP` door rather than one per tool**, because what
the sentence has to show is the SHAPE of the field, and a player who sent a
string needs that whether they asked for a car or for boots.

**Not changed, deliberately: the prompt.** It is **byte-identical** — 15497
characters, `PROMPT_FINGERPRINT` matches, `PROMPT_VERSION` stays at
`035-bounds-from-the-code-1` — checked rather than assumed (TRAPS 29),
because 037 changes what Genesis DOES with a field and not what the model is
told. The prompt's own instruction to send `intent` with every `EQUIP` is
now a thing Genesis acts on, which it was not.

### Evidence

- Godot 4.7.1 (`4.7.1.stable.official.a13da4feb`) headless, Linux, in a
  cloud container. **Baseline 43 suites, 0 with something to look at, with
  `--all`. After: 44 suites, 0 without `--all` and 0 with it**, `drive_test`
  and `session_test` included.
- `intent_door_test` **fails 39 times against the pre-037 code**,
  measured the way 035 and 036 measured theirs: the six changed scripts
  reverted to 036 with `Readback`'s two new functions left in place so the
  suite parses. All 39 are the three `EQUIP` doors, 13 apiece — 3 for the
  record (no key, no style, no key when intent is absent) and 10 for the
  five non-object values that were accepted. **The three world doors and
  `PLAN` pass against the pre-037 code as well**, which is the point: their
  behaviour did not change, only where their sentence lives.
- `run_tests.bat` needed no edit (TRAPS 4): `intent_door_test` matches none
  of its `findstr` patterns, so it runs there without `--fixed-fps` — which
  is what it gets here too, and it was run **both ways** and passes either.
- The suite's doors are **enumerated from `AIInterpreter.assembled_prompt()`**
  by reading its skeletons for the field, so a world or tool added later
  whose skeleton offers `intent` has no row and **FAILS rather than passing
  unexamined**. That is the property that would have caught this in 004,
  when `EQUIP` was written.
- It asserts the field is NAMED in the refusal and never what the sentence
  says, so every refusal in Genesis may be rewritten without touching it.
  It asserts that an **absent** `intent` is still accepted at all six doors,
  so it cannot be satisfied by making the field required.

### Not verified

- **NO MODEL HAS SENT ANY OF THESE REQUESTS.** Every one was typed by hand
  into `_handle_request`; a headless harness has no key and no model.
  Whether a model actually writes `"intent": {"style": ...}` on an `EQUIP`
  is the premise this inherits from the prompt telling it to, and only the
  owner's editor session can show it. **This is the half that matters most
  here**, because the whole finding is about a field arriving on real
  requests.
- Nothing ran on Windows.
- **The ledger records already on the owner's disk cannot be fixed.** Any
  `EQUIP` record there has no `intent` key, so no before-and-after of
  described styles across 037 is possible for tools.
- **One judgement, labelled as one.** That a non-object `intent` at an
  `EQUIP` should be REFUSED rather than quietly recorded as `{}` is a
  design decision, not a measurement. It follows what all five other doors
  do and what 036 decided for `PLAN`, and it changes what Genesis accepts:
  an `EQUIP` whose `intent` is a string used to build and is now refused.
  The record-carrying half of 037 is additive and changes nothing that was
  accepted.
- `plan_said_test`, `tool_test`, `boots_test`, `look_test`,
  `ledger_said_test`, `ledger_audit_test` and `session_test` all pass
  unchanged, so the new `intent` key on `EQUIP` records was checked against
  every existing reader of those records rather than assumed harmless.

### Found while measuring it, and left for its own commit

**The boots prompt tells the model two different things about the same
player sentence.** Measured, not inferred, with `BootsTool.top_speed()` and
`BootsTool.stopping_distance()`:

```
ordinary                 top 4.48 m/s   stops in 1.45 m from its own top
footing raised to 1.50   top 2.00 m/s   stops in 0.29 m
brake raised to 1200     top 4.48 m/s   stops in 0.59 m
```

The prompt's `brake` line says *"This does NOT change top speed: someone who
wants to 'stop on a sixpence' wants brake raised and nothing else."* Three
lines below it, the `Every field may be left out` line says *"someone who
wants 'boots that stop on a sixpence' wants footing raised and nothing
else."* **The same quoted player phrase, two different fields**, and the
second costs the player more than half their walking speed — which is
exactly what the first sentence warns against. Beside it: `brake` is
**absent from the boots JSON skeleton** the model copies, while being
described in the bullets under it, so a model following the skeleton never
sends the field the bullet tells it to raise.

That is TRAPS 28's shape — a sentence in the prompt the code contradicts —
and it is **not folded in here**, for the reason 030 gave for not folding in
035's farm bound: it is a prompt change, so it moves `PROMPT_FINGERPRINT`
and `PROMPT_VERSION` and makes designs non-comparable across it. It wants
its own commit and it is the next assistant task below.

**And two refusal examples name a style shape the prompt forbids.** The
prompt says a style is *"a short lowercase label with underscores"*.
`SectionValidator`'s example is `{"style": "a street circuit"}` and `PLAN`'s
is `{"style": "a farm with a circuit round it"}` — both with spaces.
Nothing refuses a style, so neither example is illegal to Genesis; they just
show the model a shape its instructions rule out. Cosmetic, one word each,
and recorded rather than swept because 037's own rule is that the sentence
lives in one place and the examples are the callers' to choose.

TRAPS 31 records the fault and the rule.

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

028 adds a third, and it is one line:

- *"a circuit with a 2 km straight"* — any out-of-range circuit will do. The
  refusal should now name the limit, the way a car's and a dungeon's always
  have: *"section 1 (straight): length is 2000 m, and must be 20 to 1000 m"*.
  Before 028 it said *"length out of range"* and left the player to guess.
  Worth one glance to confirm it reads as well in the editor as it does in a
  test, since that sentence is the whole point of the change.

029 adds one more, and it is a single line:

- *"a dungeon with a hall 12 m across and a vault"* — then, separately, a
  request the model is likely to answer with a missing measurement. What
  changed is what Genesis says when a measurement does not arrive as a
  number: the readback now names the room **without a size** ("entered
  through a vault") instead of returning an empty line, and the refusal says
  *"room 1: width must be a number, 4 to 40 m"*. Whether a missing size reads
  as deliberate or as a bug is a judgement a test cannot make, and it is the
  only part of 029 that a person has to look at.

And one worth watching rather than typing: 028 narrowed the physics capability
so the model stops promising a measured braking experiment. If a request like
023's two-car brief now comes back refused **with the right reason** — one set
of equipment at a time, and no measured stop — that is the narrowing working.
If it still comes back claiming Genesis has no physics, that is the old 023
fault and `RefusalCheck` should be catching it.

030 adds a fourth, and it is also one line:

- *"a farm with a barn"*, then *"a circuit with a straight and a bank of 10
  degrees"*. What changed is what Genesis says when a measurement is left out
  or arrives as something that is not a number: *"zone 1 (barn): missing
  'width', and it must be 5 to 60 m"*, *"section 1 (straight): 'bank' is not
  a straight setting (a straight has length)"*, and, for a type the model
  invents, *"section 1: unknown type 'loop' (a circuit is built from
  straight, corner, hairpin, chicane)"*. Whether those read as help or as
  noise is the only part of 030 a person has to judge. **Check the last one
  especially**: it is a second place the four-of-ten restriction now lives,
  and if the owner ever opens the six withheld types, `OFFERED_TYPES` in
  `section_validator.gd` moves with the prompt or the suite fails.

031 adds a fifth, and it is the only part of 031 a person has to judge:

- *"a circuit with two long straights and two 90 degree right-handers"*, and
  then *"a dungeon with a hall, a vault and a crypt"*. Both read back longer
  than they did. The circuit now says which way every corner turns and how
  far — *"two 400 m straights and two 50 m corners, 90 deg right"* — and the
  dungeon names every room rather than the entrance alone — *"entered through
  a 12 m hall, along with a 20 m vault and a 16 m crypt"*. Before 031 the two
  circuits in that first sentence and a circuit of two 120 deg LEFT-handers
  read back identically, which is the fault; the question a test cannot
  answer is whether the cure reads as help or as clutter. **The worst case to
  look at is a varied circuit**, where every piece differs and the line
  becomes a comma-heavy list: a six-piece one is in the 031 section above,
  verbatim. If it reads as noise, the fix is shorter phrasing and NOT a
  dropped field — `said_fields_test` will hold the line either way, because
  it asserts that the sentences differ and never what they say.

032 adds a sixth, and this one is the only part of 032 a person has to
judge:

- *"a dungeon with a hall and a vault, inside a race circuit"* — any plan with
  two worlds. Each world now says how many pieces it is made of: *"a circuit
  of four sections and a dungeon of two rooms, one inside the other"*. Before
  032 the circuit said *"a race circuit"* whatever was in it, and a farm said
  *"a farm"*. **The word "race" is gone from that line** — a plan now names a
  world through `display_name()`, which is the one function that names a
  world, and racing's was already "circuit". If *"a race circuit of four
  sections"* reads better, the fix is `display_name()` and every layer moves
  with it. The judgement is whether the counts help or just lengthen the line.

And one worth typing because it is a false claim a player could have hit:
*"make me a race track"* with no sections described. That hits Prototype
001's stub, which until 032 **cleared the world and then said "CREATE_TRACK
corners=4"**. It now says it built nothing — but it still clears first, so
the world still goes. See "Human decision needed" 3.

033 adds a seventh, and it is the only part of 033 a person has to judge,
because it is a line in a report rather than a line in the game:

- Run a short `/session` — *"/session dave"*, then boots, then a door in a
  dungeon, then `/session end` — and read the summary. Before 033 that
  reported *"Worlds built: 2. Made another: yes"* and *"First world after
  40 s"* quoting the request for boots. It now reports no world, and the two
  requests that worked under **"Other requests that worked: 2"**. Whether
  that line is worth having, or whether those requests should be named some
  other way, is the judgement; the count itself is now measured and
  `report_test` holds it either way. Also worth one glance: the session's
  own housekeeping clear no longer shows up as a request the tester typed,
  so the request count should match what was actually typed.

034 adds an eighth, and it is the only part of 034 a person has to judge,
because what changed is a sentence and the suite can only prove it is true:

- *"a dungeon with a hall and a vault"*, and say nothing about doors. Before
  034 that was refused with the four words *"doors must be a list"*. It now
  says *"'doors' must be a list of up to 48 doors, for example [[1, 2]]"*.
  Then *"a farm"* with nothing in it, and *"give me a car"* with something
  that is not a spec, for the other two shapes. **The judgement is whether a
  JSON example in a refusal reads as help or as a wall**, since the player
  who meets this sentence is the one who has not got as far as a field. If
  it reads as noise the fix is the phrasing or dropping the example, and
  `container_door_test` holds the line either way: it asserts the example
  parses to the value the module declared and that the validator accepts it,
  never what the sentence says. Worth one glance at
  *"'rooms' must be a list of 2 to 24 rooms, for example [{"name": "hall",
  "width": 12, "depth": 12}]"* in particular — it is the longest of them.
- And one line worth typing because it is what the four words used to hide:
  ask for a dungeon and describe no doors. If the model now supplies
  `"doors": []` having read the refusal, the reachability check answers
  *"2 rooms need at least 1 door to all be reachable (got 0)"* — which is the
  sentence that should probably have been there all along. See "Human
  decision needed" 7.

035 adds a ninth, and this one is two sentences and a look at a report:

- *"a farm with a barn"*, and nothing else. Before 035 the prompt told the
  model to use 2 to 24 zones, so a one-zone farm was the model's to refuse
  even though Genesis accepts one and 003 lowered the minimum so it would.
  **The thing to watch is whether a single barn now gets built**, rather than
  coming back as a farm with a barn and a yard the player never asked for, or
  as `UNSUPPORTED`. If it still arrives with a second zone, the prompt wording
  is not enough and the next move is an example rather than a bound.
- *"a long technical circuit with lots of corners"* — anything that invites a
  big section list. The prompt now states *"Use 2 to 40 sections"*, which it
  never did. Whether that stops a 41-section proposal, or just makes the
  circuits blander, is the judgement; a refusal that says *"a track needs 2 to
  40 sections (got 41)"* was always there and was never announced.
- And one worth knowing rather than typing, because it is about the ledger and
  not the game: **`prompt_version` is no longer comparable across 027 and
  028.** Records made from 025 to 034 all say `025-what-genesis-does-1` and
  were made under three different prompts (14470, 15030 and 15306 characters;
  the boundaries are commits 027 and 028). Any before-and-after reading across
  those is not a before-and-after. From 035 the version moves whenever the
  prompt does, because a suite now fails if it does not. Nothing was done to
  the records themselves — they are on your machine and they are yours.

036 adds a tenth, and it is two sentences and one thing worth knowing:

- *"a dungeon with a hall and a vault, inside a farm with a barn"* — any plan
  with two worlds, one inside the other. That still works and should read
  exactly as it did. **What is new is what happens when the model gets the
  `around` field wrong**, and the sentence to look at is the refusal: it now
  says *"step 2: 'around' is 2, and it must be an earlier step (1 to 1)"* or
  *"step 2: 'around' must be a whole number, the step this world goes around
  (1 to 1)"*. Before 036 any of those came back as *"step 2 overlaps step 1:
  they must stand apart, or one must be big enough to contain the other with
  15 m to spare"* — true, and about the wrong thing. **The judgement is
  whether "1 to 1" reads as helpful or as absurd** in a two-step plan, since
  that is the commonest plan there is. If it reads badly the fix is the
  phrasing in `WorldRegistry.around_problem()` and `command_schema_test`
  holds the line either way: it asserts that the field is NAMED and that the
  refusal is a shape fault, never what the sentence says.
- And one worth typing because it used to be silent: *"make me a race
  track"*, then anything that makes the model send a `MODIFY_TRACK`. If a
  model ever wrote `"corner": null`, Genesis printed **nothing at all** — no
  line, no refusal, no record — and the ledger kept an understanding record
  pointing at an id no record carried. It now says *"'corner' must be a
  number, the corner to change"*. Unlikely to be reachable by typing, since
  the prompt does not mention `MODIFY_TRACK` at all, and recorded here
  because the silence was the fault.
- And one worth knowing rather than typing: **any understanding record in
  your ledger whose `about` id matches no record** is almost certainly this
  — a `MODIFY_TRACK` whose `corner` was not a number, from any release before
  036. The records are yours and 036 did not touch them.

037 adds an eleventh, and it is one sentence and one glance at a panel:

- **Ask for a tool with a style in it** — *"give me a rally car"*, *"boots
  for climbing"*, anything that makes the model write
  `"intent": {"style": ...}` on an `EQUIP`, which all three `EQUIP`
  skeletons in its prompt tell it to. Before 037 that field was read
  nowhere: the ledger record for the car carried **no `intent` key at all**
  and the measurements panel said **`REQUESTED: not stated`**. It should now
  say the style the model wrote, the way it has always done for a farm.
  **The judgement is whether the style a model puts there is worth having**
  — whether *"rally_car"* or whatever it writes reads as a useful record of
  what the player described, or as noise in the panel. That is the half a
  test cannot answer, because no model has sent one of these requests; every
  request in `intent_door_test` was typed by hand.
- And one worth typing because it used to be accepted in silence: an `EQUIP`
  whose intent is not an object. Unlikely from a model following the prompt,
  and the point is that Genesis now says *"intent must be an object, for
  example {"style": "lightweight"}"* instead of building the thing and
  dropping the field. `intent_door_test` holds the line either way: it
  asserts the field is NAMED, never what the sentence says.

**Smallest useful assistant task next.** The ledger question (033), the
container-door question (034), the prompt-bound question (035) and the
validator question (036) are all **done**. Candidates, in the order the
assistant would take them:

- ~~**A refusal that names no legal value, at the one door 030 did not
  reach: the top-level list itself.**~~ **Done in 034**, and it was nine
  doors rather than the four listed here: `things` and the three tools'
  `spec` were in the same class and not on the list. The plural beside it
  (*"1 doors"*) is done too, swept across the validators and the dungeon's
  measurements rather than fixed where it was found. Left here struck
  rather than deleted, because the next reader should see that a list in
  this file of four instances was a list of nine.

  The original entry, as 033 wrote it: *Measured this session while writing
  033's suite, headless, and not inferred.* 030 made every *field* refusal
  name its limits through all three doors. The *lists those fields live in*
  were not touched, and all three worlds answer the same way:

  ```
  DungeonModule.validate({rooms: [...]})         "doors must be a list"
  DungeonModule.validate({doors: []})            "rooms must be a list"
  FarmModule.validate({})                        "zones must be a list"
  RacingModule.validate({})                      "sections must be a list"
  ```

  Each is a first-return that names no legal value, gives no example and
  says nothing about what a member looks like — next to field refusals that
  say *"and it must be 5 to 60 m"*. `doors` is the sharp one: it is
  **required**, with no default, so *"a dungeon with a hall and a vault"*
  with no doors described is refused with four words. This is TRAPS 21's
  shape one level up, it is the same four-validator sweep 030 ran, and the
  limits are all in scope on the line that writes the sentence.

  Found beside it, in the same reading: *"2 rooms need at least 1 doors to
  all be reachable (got 0)"* — **"1 doors"**, which is TRAPS 10 and 23's
  family (the article and the plural put in by hand). Worth fixing in the
  same commit as the instance above, and worth asking of every
  `Readback`-less count in the validators rather than of that one.
- ~~**The farm prompt states a bound the code does not have.**~~ **Done in
  035**, and like 034 it was wider than this entry said. Asked of every
  bound in the prompt rather than of the farm's, one more was wrong by
  omission: a circuit's section count, 2 to 40, was stated nowhere, so a
  long circuit could be refused by a limit the model was never told. And the
  "minute's thought" this file asked for first — does `PROMPT_VERSION` move?
  — found that it had failed to move twice already, so three prompts were
  recorded under one version. Left struck rather than deleted, because the
  next reader should see that a question about one sentence was a question
  about eleven and a version string. See 035 above and TRAPS 28 and 29. The
  long entry below is the original, as 030 wrote it.
- **Is every command reachable from the prompt? ASKED AND ANSWERED, so
  nobody need ask again.** Measured this session against the assembled
  prompt the model actually receives — `SYSTEM_PROMPT` plus the three
  registries' sections, **15474 characters at the time** (15497 since 035,
  which changed four lines of it; 032's "7573 characters" is
  `SYSTEM_PROMPT` the constant on its own, which is what it measured; both
  numbers are right about different strings, and this one is the one the
  model sees). Every whitelisted command is named in it except
  `MODIFY_TRACK` and `SPAWN_OPPONENTS`, which are named nowhere, and the
  word "opponent" does not appear in the assembled prompt at all — so 032's
  claim holds at the wider width too. There are **no** commands the model is
  never told about beyond the two already known, and both are under "Human
  decision needed" 2.
- ~~**Does every command have a validator?**~~ **Done in 036**, and the
  answer was no — four of eleven — but the useful part is what "no
  validator" turned out to mean: **four conversions that throw**, abandoning
  the function and leaving the caller holding `int()`'s default. One of them
  put 033's dangling ledger reference back; one recorded the empty string as
  its reason; one refused a plan for the worlds *overlapping* when the real
  fault was a field the prompt tells the model to write. Left struck rather
  than deleted, because the next reader should see that a question phrased
  as "is there a validator" was answered by a crash. See 036 and TRAPS 30.

  The original entry, as 033 wrote it: *The question 023 asked of
  `UNSUPPORTED` alone, asked of the whole list. Not yet measured, and the
  natural fourth question of `CommandParser.allowed_commands()` after
  described (032), recorded (033) and reachable-from-the-prompt (033).*

Two smaller ones, either of which is a single session:

- ~~**The farm prompt states a bound the code does not have, and it is the
  narrow direction.**~~ **Done in 035.** The original, as 030 wrote it, kept
  because the last paragraph of it is the question that turned out to matter
  most: Found while reading the validators for 030 and
  **measured, not inferred**: `FarmModule.MIN_ZONES` is 1, and the prompt
  says *"Use 2 to 24 zones"*. A one-zone farm validates with an empty error
  list — `capability_test` has built one since 028. The comment on
  `MIN_ZONES` says why it is 1: *"build a farm with a barn" is about the most
  natural thing a first-time player can type*, and 003 changed the minimum
  specifically so it would stop being refused. The prompt then tells the
  model to use two. This is TRAPS 15's shape in the prompt rather than in a
  limitation — a bound stated narrower than the truth, which costs a player
  the request the bound was widened for. Not fixed in 030 because that is a
  prompt change and 030 deliberately left the prompt byte-identical; it wants
  its own commit, and the question of whether `PROMPT_VERSION` moves with it
  is worth a minute's thought first, since every record carries it and the
  ledger compares designs by it. *(035's answer: yes, and it should have
  moved twice before — see TRAPS 29.)*
- ~~**The silent drop, asked of every field the way 036 asked of every
  command.**~~ **Done in 037**, and the useful part is that the question as
  this entry phrased it — *per FIELD* — answers *yes, all 44 of them* and
  finds nothing. Asked per DOOR it found `intent`: offered by six of the
  prompt's skeletons, read at three, and the three that read it nowhere are
  the three the prompt instructs the model to send it with. Left struck
  rather than deleted, because the next reader should see that the
  granularity of the sweep was the whole difference between a clear report
  and a finding. See 037 and TRAPS 31.

  The original entry, as 036 wrote it: *036's `offset` finding is the shape:
  a field the code READS and acts on, that the prompt never offers, refused
  by nothing and reported nowhere. `silence_test` exists and this is not what
  it covers. The question is cheap and the list is enumerable: for every
  field any handler or builder reads out of the AI's parameters, is it named
  in the assembled prompt, and is it checked by something?
  `prompt_bounds_test` already walks the prompt with a regular expression and
  `WorldRegistry.modules()` already enumerates the declarations, so both ends
  of the comparison exist. Expect the answer to be wider than `offset` — that
  is what 034, 035 and 036 each found when the same question was asked of a
  whole list.*
- **The boots prompt tells the model two different things about the same
  player sentence, and this is the next task.** Found while measuring 037 and
  **measured, not inferred**, with the functions that enforce it:

  ```
  ordinary                 top 4.48 m/s   stops in 1.45 m from its own top
  footing raised to 1.50   top 2.00 m/s   stops in 0.29 m
  brake raised to 1200     top 4.48 m/s   stops in 0.59 m
  ```

  The `brake` line says *"This does NOT change top speed: someone who wants
  to 'stop on a sixpence' wants brake raised and nothing else."* Three lines
  below it the `Every field may be left out` line says *"someone who wants
  'boots that stop on a sixpence' wants footing raised and nothing else."*
  The same quoted player phrase, two different fields, and the second costs
  the player **more than half their walking speed** — the thing the first
  sentence exists to warn against. Beside it, in the same section: `brake` is
  **absent from the boots JSON skeleton** the model copies while being
  described in the bullets under it, so a model following the skeleton never
  sends the field the bullet tells it to raise.

  This is TRAPS 28's shape — a sentence in the prompt the code contradicts —
  and it wants its own commit because it moves the prompt, and so
  `PROMPT_FINGERPRINT` and `PROMPT_VERSION` with it, which makes designs
  non-comparable across it. 030 gave the same reason for not folding in
  035's farm bound. **Worth asking of the class and not these two
  sentences**: every "someone who wants X wants FIELD changed and nothing
  else" sentence in the prompt names a field, and whether that field is the
  one that does X is a measurement, not a wording question. `CarTool`'s is
  *"a car that stops better"* → `braking`, which is right; the two boots
  ones are the finding. `prompt_bounds_test` already walks the prompt and
  already fails when `PROMPT_FINGERPRINT` does not move, so the second half
  is in place before the first is written.
- **Ask one more question of every file at once.** 029's finding came from
  asking "what if this is not a number" of all five validators rather than
  one, and it had been true for the project's whole life. Candidates in the
  same shape, cheap to run: what does each validator do with a field given
  **twice**, or with a deeply nested object, or with a string where a *name*
  rather than a number is expected?

  **`inf` was the obvious next one and it is already sound - checked in 029,
  so nobody need check it again.** `JSON.parse('{"w": 1e400}')` returns
  `inf`, which IS a float, so every `typeof()` check in Genesis passes it
  through - but every bound then refuses it, because `inf` is greater than
  any upper limit. A dungeon answers *"room 1: width is inf m, and must be 4
  to 40 m"*: the sentence is ugly and the refusal is correct. A JSON `NaN`
  literal is rejected by the parser outright, and a float `NAN` that reaches
  a validator is refused as "must be a number", which is what it is.
- Worth a look while it is cheap: `sweep_test` still reports that no legal
  command reaches `FAILED_UNWALKABLE`, which is TRAPS 6's own example and has
  been true since 005.
- Cheap and cosmetic, recorded by 031 and left alone by it:
  `Readback.join_capped()` writes *"... e and f and 2 more"*, two "and"s in
  one clause. Shared by the farm, the circuit and now a dungeon's rooms.

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
   across a model change is not a comparison. **035 found that this is only
   now true of `prompt_version`**: it had not moved since 025 and three
   prompts were recorded under it, so the mechanism this paragraph relies on
   was working for `model` and not for the prompt. A suite holds it from 035
   on (TRAPS 29).

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

1. **The six section types the prompt withholds — the owner's call, and there
   is no hurry.** Found and deliberately left alone in 028; the full account is
   TRAPS 19. `SectionValidator` accepts ten section types. The prompt offers
   **four** and says "only these four". The other six — uphill, downhill,
   crest, dip, banked_corner, loop_segment — validate, measure, close and
   build: a vertical circuit of two uphills and two downhills closes with a
   height closure error of 0.0, and `circuit_builder.gd` has a colour for each
   of them.

   It reads exactly like a stale prompt. It is not. `docs/GENESIS_BRIEF.md`,
   under "Known rough edges", says banked corners throw cars over the barrier
   (~23 opponent recoveries a race), loops are built but untested with a car,
   the separation check is flat so a loop over itself reads as a crash, and
   the solver does not check that a track returns to its starting height.
   Those are the same six. "Only these four" is the one thing between a
   player's sentence and a known defect.

   So this is not an assistant's fix: it is **what to do with a finished
   vertical axis that nothing will drive safely yet**, which is product
   direction and cost. The options, for the record:

   - **(a) Leave it.** Costs nothing. The vertical axis stays unreachable.
   - **(b) Fix the four rough edges first**, then open the types. Honest, and
     the largest of them (banked corners as ramps) is a physics problem, not
     a wording one.
   - **(c) Open the ones that are sound**, if any are. The slopes are the
     candidates — uphill, downhill, crest, dip — and the blocker named for
     them is the solver not checking return-to-height, which is narrower than
     a car being launched. Would need the owner to drive one first.

   Whichever it is, the restriction needs its reason written where the
   restriction is. Right now it is enforced in `racing_module.gd` and
   explained three directories away.

2. **The three Prototype 001 stubs: rebuild them, or take them out of the
   whitelist?** Found and measured in 032, where only their false success
   lines were fixed. The facts, all measured headless rather than inferred:

   - `CommandParser.allowed_commands()` admits `SPAWN_OPPONENTS` and
     `MODIFY_TRACK`, and `CREATE_TRACK` **without** a `sections` list routes
     to Prototype 001's ring. All three build nothing. `corner_nodes` is
     appended to nowhere in the repository, so `TrackBuilder.has_track()` can
     never be true — which makes `SPAWN_OPPONENTS` unreachable (its handler
     guards on it) and `MODIFY_TRACK` the one a player meets.
   - **The AI's prompt mentions none of them** — 7573 characters, and not the
     word "opponent" anywhere. So the model is not being told about them. They
     are reachable because the whitelist admits them, and `_execute_plan`
     admits any whitelisted command as a plan step.
   - A composed circuit already has its own grid (`RaceDirector`, ~23
     opponent recoveries a race per `GENESIS_BRIEF.md`), so the *capability*
     is not missing from Genesis — only from the Prototype 001 path.
   - **One of them still destroys something.** `TrackBuilder.build` calls
     `clear()` before it discovers it has nothing to build, so a sectionless
     `CREATE_TRACK` takes the player's world away and then reports that it
     built nothing. 032 fixed the report and left the behaviour, because
     changing it is a change to what Genesis does on a path that may be about
     to be deleted.
   - **033 added the records and left that behaviour alone again.** All four
     of these paths now write a ledger record saying what happened, which is
     nothing, so a sectionless `CREATE_TRACK` taking the world away is at
     least in the record. The `clear()` is still there and is still option
     (b) below.

   The options, for the record:

   - **(a) Take all three out of the whitelist.** Cheapest, and it removes
     the world-clearing fault with them. `MODIFY_TRACK`'s own guard message
     says *"composed tracks are changed with MODIFY_SECTION, which comes in a
     later step"*, so there is a roadmap intent here that this would drop.
   - **(b) Leave them and fix only the clearing**, so a sectionless
     `CREATE_TRACK` refuses before touching the world. Smallest honest change,
     keeps the names reserved for the later step.
   - **(c) Rebuild them against the composed circuit**, i.e. make
     `SPAWN_OPPONENTS` put cars on a real circuit's grid and `MODIFY_TRACK`
     become the `MODIFY_SECTION` its guard already promises. The most work and
     the only option that makes the commands mean anything.

   This is product direction and the assistant has not chosen. What it did
   choose, and would undo on request, is that the three now report what they
   did rather than what they used to do.

3. **Commit authorship.** Commits since 2026-10-10 are authored by
   "Claude Opus 5"; before that by the owner with the assistant as co-author.
   The protocol asks for a record of what the AI contributed and what the human
   accepted, which the current arrangement gives accurately. The owner has not
   ruled on which they want.
4. ~~Whether scripts may be pushed before the owner has run them.~~
   **OWNER, 2026-10-14: settled.** The owner's job is testing. The assistant
   builds, tests headlessly and pushes - scripts included. The owner pulls,
   runs it on real hardware with a real API key, and reports what happened.
   Hand-pasting files is not testing; it was the owner acting as a file
   transfer protocol.

   In exchange, **every commit states what was verified and what was not**, so
   the owner never has to guess whether a change has been near real hardware.
   The standing caveat stands: a green suite is necessary and not sufficient.
5. ~~Whether work should happen while the owner is away. The assistant does
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

6. **Should a plan's steps have ids of their own?** Measured in 033, not
   inferred: a plan's own record and the records of each of its steps all
   carry the **same** id, because `_prepare_world` reuses
   `current_record_id`. A two-world plan writes three records under one id.

   Nothing is broken by it today. `SessionReport._is_plan_step` tells the
   steps apart by re-reading `raw_command`, and the understanding layer only
   needs an id to **resolve**, which it does. But it means the ledger cannot
   answer "which record is this evidence about?" by id alone when a plan is
   involved, and an outside auditor — the thing `ledger_audit_test` is
   written to imitate — would have to know that rule to read the file.

   The options, for the record:

   - **(a) Leave it.** Costs nothing now. The rule stays implicit, and
     `_is_plan_step`'s string re-parse stays the only thing that knows it.
   - **(b) Give each step its own id and a `step_of` field pointing at the
     plan.** Makes the ledger self-describing and lets `_is_plan_step` read
     a field instead of re-parsing JSON. It changes the shape of records
     already on disk in the owner's `user://` log, which is why it is his.
   - **(c) Keep one id and add an explicit `plan_step: N` field**, so the
     relationship is stated rather than inferred, without changing what an
     id means.

   `ledger_said_test` deliberately asserts only that an id resolves, so it
   stays green under all three.

7. **Should `doors` be required, now that the refusal says what to supply?**
   Raised by 034, which fixed what that door SAYS and deliberately did not
   change what it accepts. Measured, not inferred: `DungeonModule.validate`
   returns at the second line if `doors` is absent or is not a list, so a
   dungeon described with rooms and no doors never reaches the reachability
   check at the bottom of the same function.

   That check is the better sentence. *"2 rooms need at least 1 door to all
   be reachable (got 0)"* tells a player what is wrong with their dungeon;
   *"'doors' must be a list of up to 48 doors, for example [[1, 2]]"* tells
   them what is wrong with their JSON. The second is a large improvement on
   the four words that were there, and it is still a sentence about the
   format rather than about the world.

   The options, for the record:

   - **(a) Leave it.** `doors` stays required. Costs nothing; the refusal is
     now actionable, which it was not before 034.
   - **(b) Default `doors` to `[]`**, so a dungeon described without them
     falls through to the reachability check and is refused for the reason
     that actually matters. One line, and it changes which refusal a player
     meets — which is why it is here and not in a commit.
   - **(c) Default it to `[]` and have the dungeon JOIN the rooms itself**
     when none are described. That is a change to what Genesis BUILDS from
     a given request, not to what it says, and it is the owner's by a wider
     margin than the other two.

   The assistant would take (b) and has not, because it is a change to what
   Genesis accepts.

8. **A plan step can place a world by coordinate, and the prompt says it
   cannot.** Found in 036 while fixing the conversion that threw there, and
   measured rather than inferred: a step written
   `{"command": "CREATE_FARM", "offset": {"x": 150, "z": 0}, ...}` really
   does put that farm at x = 150. `_place()` has read the field since 003.

   The prompt says *"The game works out where everything goes; **never give
   coordinates**"*, and it never names the field. (The one line in the
   assembled prompt containing the word `offset` is a **chicane's** sideways
   step — a different field, behind `SectionValidator`. That distinction cost
   a false sentence in 036's own code comment before trap 14's rule caught
   it, which is recorded at the end of TRAPS 30.)

   So this is **TRAPS 17 reversed**: not a capability stated wider than the
   code, but a working capability the prompt denies. Nothing is broken today
   — no prompted request carries the field, so no player reaches it — and
   that is exactly why it has sat there for thirty commits.

   The options, for the record:

   - **(a) Leave it.** Costs nothing. An undocumented placement field stays
     reachable by anything that writes JSON directly, including the
     assistant's own tests.
   - **(b) Refuse it.** A step carrying `offset` is refused naming the
     field, so the code and the prompt agree. One check, beside
     `around_problem()`. It makes the prompt's sentence true.
   - **(c) Offer it in the prompt.** The opposite answer: coordinates become
     a thing a player may ask for, and the sentence that forbids them goes.
     That is a change to what Genesis is for — the AI proposing geometry
     rather than describing intent — which is why this is here and not in a
     commit.

   The assistant would take (b), because the prompt's claim should be true,
   and has not, because (c) is a real alternative and the choice between
   them is product direction.
