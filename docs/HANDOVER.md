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
- **TWO RUNS OF THE UNATTENDED TASK OVERLAPPED ON 2026-10-16**, which is
  worth knowing because it is the first time it has happened and it will
  happen again. The task fires every two hours and starts a fresh session
  with no memory of any other, so both runs read 047 as the last commit and
  both numbered themselves 048. `5d36bfb` pushed first and **keeps 048**; the
  second run rebased onto it and **renumbered itself 049** throughout — its
  subject, its code comments, TRAPS 43 and this file — because its commit had
  not been pushed and nothing shared had to be rewritten. Nothing was
  force-pushed and nothing was lost. The two touched no file in `scripts/` in
  common.

- Last commit at the time of writing: **076**, which closed the class 075
  named as its own TRAPS 11 and did not fix: **55 of the 72 suites printed
  `failures=0` and nothing else, so an assertion could be deleted from any of
  them and the run output would not move.** Only a diff of the full PASS list
  against a recorded md5 would have caught it, which is what 073, 074 and 075
  each had to do.
  **MEASURED, NOT ARGUED: eleven deliberate deletions, each in its own
  throwaway copy with its own `config/name` (TRAPS 50), the suite run after
  each. ALL ELEVEN STAYED `failures=0` AND EXITED 0**, and the assertion count
  was the only thing that moved — one `_check` out of `look_test` (18 -> 17),
  `carry_test` (21 -> 20) and `session_test` (18 -> 17, the inherited-helper
  shape); a row out of `judge_test`'s case table (21 -> 20); an `_eq` row and
  a direct if-block out of `report_test` (28 -> 27 each); two rows out of
  `said_fields_test` (127 -> 126 each); a `_differs` row out of
  `plan_said_test` (50 -> 49); the walls control out of `walk_test` (11 ->
  10); and **one condition out of `tool_test`'s six-case loop, which cost six
  assertions (21 -> 15) and still said `failures=0`.**
  **THREE MUST-PASS CONTROLS PASS at the SAME count** — a PASS/FAIL message
  reworded in `look_test`, `judge_test` and `tool_test` — so the count reads
  the assertions and not the wording (TRAPS 6).
  **WHAT CHANGED.** 55 files in `tests/`, no file added or removed, nothing in
  `scripts/`, `scenes/` or either runner. 39 of the 55 funnel every assertion
  through one `_check(ok, what)` whose body is the only failure site, verified
  per file rather than assumed, and took one mechanical increment. The other
  16 were read in full: `proxy_test` turned out to be the first shape after
  all, `session_test` needed only its print line because it inherits
  `drive_test`'s helper, and the remaining 14 record failures at ad-hoc sites
  where each site that decides pass or fail got its own increment, so the
  count is path-correct. **71 of the 72 suites now print a count**;
  `sweep_test` prints a VERDICT by design and is the whole remainder.
  **THE VERIFICATION IS THE WHOLE OF THE WORK AND IT CAME BACK CLEAN.** Two
  full runs on the final tree, `user://` cleared before each, **byte-identical**
  (md5 `dddf8006012399e50eb9470da9e29af6`), 72 suites, `--all`, 0 with
  something to look at. The 55 new counts were then **stripped** from that
  output and the result **diffed against the baseline: byte-identical**, md5
  `69eb8489ca8e4586238a7a2ad7743a9e` — which is also **the md5 075a recorded
  on the clean pushed tree**, so the record and the container agreed before
  anything was touched and no suite's verdict moved after. **A THIRD full run
  was taken on the clean pushed tree at `1c0df4f`, byte-identical to both, and
  its strip-and-diff byte-identical to the baseline** — see "Run the tests
  first". Two things the
  format change could have broken were measured rather than reasoned about: a
  **genuine failure** still prints, exits 1 and is counted by `run_tests.sh`
  ("suites with something to look at: 1"), and **`report_test`'s early-exit
  line** — a path this commit rewrote that had never run — prints `REPORT TEST
  1 assertions, failures=1` and exits 1. `run_tests.bat` was **read**: it
  matches `failures=`/`bad=` as substrings and computes no verdict, so it
  needs no edit.
  **AND A COUNT IN THIS FILE WAS WRONG BEFORE 076 TOUCHED IT.** "Run the tests
  first" said *"56 of the 72 suites print no assertion count — 15 print one"*
  in the same paragraph that says `formula_test` was given one in 075.
  Measured off 075's own output it was **55 and 16**. TRAPS 24's shape, one
  commit old, in the paragraph that tells you to run the `ls` rather than
  trust it. Corrected.
  **NOT VERIFIED: nothing was rendered, no window was opened, no model was
  asked anything and no request left the container. There is no API key
  here.** The prompt is byte-identical, `PROMPT_FINGERPRINT` did not move and
  `PROMPT_VERSION` stays at `050-no-command-for-a-question-1`. **NOTHING
  ASSERTS THE COUNTS** — no suite checks that a result line carries one, so a
  suite added tomorrow without one would be caught by nobody, which is exactly
  how this class reached 55 members. That is the first entry under "Next
  action" and it is a real gap. No secret was set and no workflow file was
  edited; 064's finding stands and the live site is still `71b065f`. **No new
  "Human decision needed."** New TRAPS 73.
- Before 076: **075**, which asked the live axis's
  question of `tests/formula_test.gd` and found that **the question one layer
  behind it was the better one**. The axis asks *what has the subject never
  supplied?*; measured first, the subject supplies exactly ONE formula clause
  and the pattern sees it, so a widening had no subject — the FOURTH entry on
  that axis in a row with nothing to widen. The question that paid was
  **what has the subject supplied that nothing reads?**
  **THE SUITE THAT HOLDS "THE ARITHMETIC THE PROMPT STATES IS THE ARITHMETIC
  GENESIS DOES" NEVER ASKED WHETHER THE PROMPT STILL STATED IT.** Its tool
  half enumerates its claim from the prompt, parses it as arithmetic and
  asserts the count it found, so a reworded or added tool formula fails.
  **Sections 3 to 8 read the prompt at all.** Each quotes a racing rule in a
  comment and measures the behaviour behind it against `TrackGeometry`,
  `FeasibilityGate` or `SectionValidator`; the sentence is read from nothing.
  **MEASURED, NOT ARGUED: eight deliberate faults, each deleting one rule
  from `racing_module.gd`'s template in its own throwaway copy with its own
  `config/name` (TRAPS 50), `PROMPT_FINGERPRINT` moved the way a real prompt
  edit moves it, the full suite run each time. SEVEN OF THE EIGHT PASSED** —
  70 suites, 0 with something to look at, the rule gone from the prompt:
  *"Sections join end to end ... arrive back at the start line"*, *"A chicane
  steps the track sideways by O metres ..."*, *"... carries the track back
  only by its own width, twice its radius"*, *"Chicanes do not count."*,
  *"Angles are signed: positive turns right, negative turns left."*, *"Never
  give a corner, hairpin or chicane a length ..."* and *"The road must never
  cross itself, and"*. The eighth, the chicane's *"O is more than 0 and at
  most 2 x R"*, failed **3** in `prompt_numeral_test`.
  **THE ONE THAT WAS HELD IS THE ONE CARRYING TYPED NUMBERS, AND THAT IS THE
  GENERAL SHAPE.** The racing rules are held where they state a NUMBER — by
  `prompt_bounds_test` and `prompt_numeral_test`, which read numbers — and
  held by nothing where they are PROSE. It is 073's and 074's finding about
  the prompt's own numerals seen from the other side: the numbers acquired
  readers and the sentences around them never did.
  **WHAT CHANGED.** Two files in `tests/`, no file added or removed, so
  neither runner needed an edit. `formula_test` **failures=0 -> 147
  assertions, failures=0**: every rule unit of the racing section is read off
  the RENDERED section — a type declaration, a sentence in the types block
  about all of them, or a `- ` bullet under the rules heading, keyed on the
  JSON and the bullet mark and never on English — **11 units**, each claimed
  by one of **17 rows**; every row must find its claim in exactly one unit,
  every unit must be claimed, and the six rows saying *"here"* are compared
  with the six measurements that actually registered, **in both directions
  and against each other rather than against a number typed in the file**
  (TRAPS 71). A row naming another suite reads that suite's **code** through
  `_code_of()` for the constant the rule is about, which put `formula_test`
  into 067's source-scanner class — **`source_scan_test` caught that in the
  same run, two FAILs by name**, and it is now its tenth member, **24 -> 25
  assertions**.
  **TWELVE DELIBERATE FAULTS, FAIL LINES READ, EACH FAILING ON THE ASSERTION
  IT SHOULD AND NAMING THE FAULT.** The eight deletions above, every one now
  **1 suite with something to look at** where seven were 0 (d3 is 2, with
  `prompt_numeral_test` beside it). A **new bullet** added to the racing
  rules: **148 assertions, failures=1**, *"unit 12 ... is claimed by a row"* —
  the added-rule direction. The **"angle sign" row deleted**: 145, failures=2,
  *"the measurement ... has a row claiming its rule"* and *"5 rules are
  measured here and 6 measurements ran"*. Its **registration deleted**: 146,
  failures=2, the other direction and the count again. And a row's evidence
  needle set to a string the named suite carries **only in a comment**
  (*"TRAPS 28"*): failures=1, so `_code_of()` is doing the work and a comment
  cannot answer a pointer (TRAPS 63).
  **TWO MUST-PASS CONTROLS PASS, both checked for passing for the RIGHT
  reason.** A **dungeon** sentence reworded with its numbers untouched: green
  at the same **147**. And — the control that matters — the **unclaimed half
  of a claimed bullet** reworded (*"Sections join end to end, in order,
  starting at the start line."* -> *"Sections are joined end to end, in the
  order you give them, from the start line onward."*, while the claimed
  second sentence was left alone): green at the same **147**. So the rows pin
  the CLAIM and not the bullet.
  **AND THE SAME FILE'S OWN COUNT WAS WRONG ON THE DAY IT WAS WRITTEN.** 039's
  header said *"the other FIVE arithmetic claims"* and listed five, while
  section 8 of the same commit measured a sixth — TRAPS 24's shape inside the
  file whose fault is a comment standing in for a reader. Corrected, with the
  sixth listed.
  **NOTHING IN `scripts/` OR `scenes/` CHANGED.** The prompt is
  byte-identical, `PROMPT_FINGERPRINT` did not move and `PROMPT_VERSION` stays
  at `050-no-command-for-a-question-1`. No number and no sentence the model is
  told changed; what changed is that seven of them now have a reader.
  **NOT VERIFIED: nothing was rendered, no window was opened, no model was
  asked anything and no request left the container. There is no API key
  here.** A row naming another suite is a **POINTER and not a measurement** —
  it asserts the rule is still stated and that the named suite's code names
  the constant, and it does not watch that suite measure anything. A needle is
  **wording**: a rule reworded while staying true fails here and the row has
  to be updated, which is the only check available for a prose claim and is
  the right way round. No secret was set and no workflow file was edited;
  064's finding stands and the live site is still `71b065f`. **No new "Human
  decision needed."** New TRAPS 72. **AND ONE CLASS IS LEFT OPEN AND SAID SO
  RATHER THAN HALF-FIXED** — see "Next action": **56 of the 72 suites print no
  assertion count on their result line.**
- Before 075: **074**, which tallied the table 073
  wrote instead of reading the sentence above it, and found **the kind filed
  under the value**. `prompt_numeral_test`'s rows were keyed on
  `(file, numeral)` with the kind read off the row, so every occurrence of a
  numeral in a file got one kind. `npc_goals` types `1` three times: twice as
  the promise that rooms are *"numbered from 1"*, and once as the `1` inside
  **`room_1`** — a room NAME in the worked example whose whole purpose is that
  a name carrying a number is not a position. All three were filed `ORDINAL`,
  the one kind the file measures against the validators, and **nothing failed,
  because the counts were asserted per numeral and the kind was asserted of
  nothing.**
  **THE FILE'S OWN PROSE HAD IT RIGHT AND THE TABLE DID NOT.** Its header
  names the prose numerals as *"'go to room 2', 'to room 3', and the example's
  own room_1, room_2 and its four room_3s"* — eight, `room_1` among them — and
  sums the eighteen as *"one BOUND, two ARITHMETIC, seven ORDINAL and eight
  PROSE"*. The table said **eight ORDINAL and seven PROSE**. 073's commit
  message counted it correctly and said so in as many words; the
  transposition went into the table, the header and this file. Nothing could
  catch it, because **the four per-kind totals were a count in a comment** —
  TRAPS 24's shape inside the file whose header claims to have avoided it. It
  had avoided it per ROW and not per KIND.
  **AND THE SAME FAULT WITH NO TABLE AT ALL, FOUND BY ASKING THE CLASS
  QUESTION (TRAPS 11).** A sweep of `tests/` for an assertion on a constant's
  own length found three. `controller_reach_test`'s `BRANCHES.size() == 28` is
  **not** the fault — its message claims only *"28 declared"* and three
  assertions under it do the real work against the source.
  `refusal_reach_test`'s two are: `LAYOUT_BRANCHES.size() == 3` said *"all
  three FAILED_LAYOUT branches were fired"* and `SHARED_WITH_CONTROLLER.size()
  == 1` said *"one category name has an owner outside the module pipeline"*.
  Both bodies read an array literal declared forty lines above. **Measured,
  not argued:** with branch 3's block deleted outright the **pre-074 suite
  reported 98 assertions, failures=0** — the branch gone and the suite still
  counting a passing line that said all three fired. With
  `FAILED_UNWALKABLE` renamed in `game_controller.gd` so the shared name has
  no owner outside the pipeline, the pre-074 suite reported **1 failure**, the
  enumeration's, while that sentence passed and was false.
  **NOTHING IN `scripts/` OR `scenes/` WAS WRONG AND NEITHER CHANGED.** The
  eighteen typed numbers are the same eighteen and all still true; the three
  FAILED_LAYOUT branches all genuinely fire. The faults were in a test
  table's key and in two assertions' wording. The prompt is byte-identical,
  `PROMPT_FINGERPRINT` did not move and `PROMPT_VERSION` stays at
  `050-no-command-for-a-question-1`.
  **WHAT CHANGED.** Two files in `tests/`, no file added or removed, so
  neither runner needed an edit. `prompt_numeral_test` **97 -> 116
  assertions**: a numeral may now appear on several rows with several kinds
  and the rows' counts must SUM to what is typed; no `BOUND`, `ORDINAL` or
  `ARITHMETIC` occurrence may be **welded into an identifier**, measured off
  the same specifier-stripped text as the count so the two are comparable
  occurrence for occurrence (13 bare, 5 embedded, 18 together — the five are
  the worked example's room names); an `ORDINAL` numeral must be the `1` that
  *"numbered from 1"* is about; and the four per-kind totals and the typed
  total are **read off the rows and asserted**.
  `refusal_reach_test` **99 -> 105**: each FAILED_LAYOUT branch is recorded
  where it actually fires and the fired set asserted against the declared one
  in both directions, and the shared name is read from the source for an owner
  inside the module pipeline and one outside it.
  **SEVEN DELIBERATE FAULTS, each in its own throwaway copy with its own
  `config/name` (TRAPS 50), FAIL lines READ.** 073's row restored: **3**, the
  first naming the fault exactly. A bare prose numeral refiled `ORDINAL`:
  **3**. A ninth prose numeral added to the prompt **and duly declared on its
  row**, fingerprint moved the way a real prompt edit moves it: **2**, with
  `prompt_bounds_test` green — which is what the header's *"a ninth cannot
  appear"* needed to be true of a number rather than of a sentence. A numeral
  welded into an identifier declared `ORDINAL` **with the totals edited to
  agree**: **2**, so the bare check is not a restatement of the totals.
  Branch 3's block deleted: **2** where the pre-074 suite was green at 98. An
  undeclared fourth branch firing: **2**, the other direction. The shared name
  losing its outside owner: **2** against the pre-074 suite's 1.
  **TWO MUST-PASS CONTROLS PASS, both checked for passing for the RIGHT
  reason.** Two prompt sentences reworded with their numbers untouched — the
  dungeon's entrance line and the orders section's one-character line: green
  at the same **116**, so the file still reads where a number came from and
  not how the sentence reads (TRAPS 6). And a **brand-new numeric field on a
  tool, stated through a substitution** (`wobble`, `1 to 9`, in `car_tool.gd`):
  green at **116** with the suite **byte-identical** to the committed one
  (`diff` run, not eyeballed), and the prompt's numeral count **92 -> 95 read
  off the output** — the three new numbers really did arrive, none is typed,
  and `TYPED_TOTAL` correctly did not move.
  **72 suites, `--all`, `user://` cleared first: 0 with something to look at**,
  against a baseline in this container **byte-identical to the md5 073
  recorded** (`0fdf976cb74056e853ae2a8f7b62fcb1`) before anything was touched.
  **NOT VERIFIED: nothing was rendered, no window was opened, no model was
  asked anything and no request left the container. There is no API key
  here.** It is still NOT asserted that the 74 substituted numerals come from
  the RIGHT constant, nor that the eight prose numerals mean anything — what
  holds them is now an assertion on their count and not a sentence. **That a
  player can reach the farm's lane-check branch is NOT claimed**: measured,
  `solve({"zones": pinched})` returns `ok=true`, because `solve()` lays the
  zones out itself and throws the pinched positions away, which
  `farm_module.gd`'s own comment already says and is the owner's to move. No
  secret was set and no workflow file was edited; 064's finding stands and the
  live site is still `71b065f`. **No new "Human decision needed."** New
  TRAPS 71.
- Before 074: **073**, which took the entry 068 left
  open and five commits had stepped around: **"NOT ASSERTED: that every number
  in the prompt is read from the thing that enforces it"**, 92 numerals and 41
  distinct, written up as a table of judgements too large to be worth
  building.
  **IT IS NOT 41 JUDGEMENTS, WHICH IS THE FINDING.** 068's question — *is this
  number the constant's number?* — needs a reader per number. The question one
  layer behind it is nearly free: **was this number TYPED into the prompt, or
  PRODUCED by the code?** A number arriving through a `%`-substitution is the
  same expression the prompt is built from and **cannot drift from what
  produced it**; only a typed one can. Measured before anything was written:
  of the 92, **74 are substituted and 18 are typed.** Seventy-four never
  needed a judgement, and the table is eighteen rows.
  **ALL EIGHTEEN WERE ALREADY TRUE. THERE IS NO LIVE FAULT IN THIS COMMIT**,
  and nothing in `scripts/` or `scenes/` changed. One of the eighteen is a
  bound — *"Up to 4 steps"* — and `prompt_bounds_test` already reads it
  through the plan's declared list; two are the chicane's *"more than 0 and at
  most 2 x R"*, which `formula_test` measures; **seven** are the `1`s that
  promise *"numbered from 1"*, measured here against the validators; and
  **eight** are prose. One, two, seven and eight, counted one at a time off
  the templates rather than apportioned.
  **THAT SPLIT IS RIGHT AND THE TABLE 073 WROTE DISAGREED WITH IT, WHICH IS
  074's FINDING.** The table said eight `ORDINAL` and seven `PROSE`: it keyed
  a row on `(file, numeral)` and read the kind off it, so all three of
  `npc_goals`' typed `1`s went under `ORDINAL` — including the `1` inside
  **`room_1`**, a room *name* in the worked example whose whole point is that
  a name carrying a number is not a position. Nothing failed, because the
  counts were asserted per numeral and the *kind* was asserted of nothing. See
  074 and TRAPS 71.
  **THE FAULT THAT JUSTIFIES THE FILE is the one no existing reader can see:**
  *"A circuit may use at most 3 chicanes"* added to the racing section — a
  limit stated to the model that nothing enforces. With `PROMPT_FINGERPRINT`
  moved the way a real prompt edit moves it, **`prompt_bounds_test` reports
  `failures=0` and `claim_field_test` reports `failures=0`**, and the new file
  fails naming the numeral and the line it is typed on. `prompt_bounds_test`
  reads counts of a declared list's members and the field ranges it names; a
  number with no list noun beside it is outside both.
  **WHAT CHANGED.** One new file in `tests/`,
  `prompt_numeral_test.gd`, **97 assertions**. The contributors are enumerated
  from the registries (a new one is **scanned** without the file being edited
  and **fails until it is classified**); every file in `scripts/` holding a
  template must be one of them and must hold exactly one; each template is **proved** to be its
  section's source by requiring every literal fragment between its format
  specifiers to appear in the rendered section **in order**; every typed
  numeral must be declared **with its count**, asserted both ways. Where a
  typed number states a fact the fact is measured, not declared: the typed
  `1`s against a door `[0, 1]`, a thing in room `0` and a dungeon whose doors
  avoid room 1; the chicane's `0` and `2` at both ends; and the orders
  section's worked example — *"a dungeon whose rooms are called large_hall,
  room_1, room_2, room_3 ... so 'room 3' means room_3 — not the third room in
  the list"* — read **off the prompt** and measured both halves, which nothing
  in `tests/` had ever done: a grep for `large_hall` found two suites,
  `log_022_test` and `log_023_test`, and neither is about this.
  **TEN DELIBERATE FAULTS, each in its own throwaway copy with its own
  `config/name` (TRAPS 50) and with the fingerprint moved, FAIL lines READ.**
  The typed bound above: 1, with `prompt_bounds_test` and `claim_field_test`
  both green. A typed bound reusing an already-declared numeral: 1, green
  elsewhere — which is why the table is keyed on counts. `Up to 4 steps`
  drifted to 6: 3 here and 1 in `prompt_bounds_test`. A section rebuilt by
  concatenation instead of a template: 1, green elsewhere. A stray template in
  `readback.gd`: 1, by name. A typed numeral deleted from the dungeon section:
  1, saying the row is out of date. `if a < 1` widened to `if a < 0` in
  `dungeon_module.gd`: 1. The example reworded so the pattern misses: 2, and
  it **fails rather than skipping** (TRAPS 69). The example changed so name
  and number give the same room: 1, on the assertion that is not a
  restatement. And **068's own fault** — the floors typed by hand: 2 here and
  1 in `prompt_bounds_test`.
  **TWO MUST-PASS CONTROLS PASS, both checked for passing for the RIGHT
  reason.** Four prompt sentences reworded with their numbers untouched: green
  at the same **97**, and the prompt still 92 numerals — so the file reads
  where a number came from and not how the sentence reads (TRAPS 6). A
  **brand-new numeric field on a tool** (`wobble`, `1 to 9`, in
  `car_tool.gd`, stated through a substitution): green at **97**, with the
  prompt's numeral count **92 → 95** read off the output — the three new
  numbers really did arrive, and none of them is typed.
  **71 → 72 suites, `--all`, `user://` cleared first: 0 with something to look
  at**, against a baseline in this container **byte-identical to the md5 072
  recorded** (`f9b0d8cf50968a31a41d42023deab0ef`); the lists were **diffed**
  and the only difference is **one added line**. **Three full runs on the
  change, all byte-identical** (md5 `0fdf976cb74056e853ae2a8f7b62fcb1`), the
  third with nothing changing during it. Neither runner needed an
  edit: `run_tests.sh`'s three lists and `run_tests.bat`'s `findstr`
  substrings were **RUN** against the name rather than eyeballed (TRAPS 4) and
  none matches.
  **NOT VERIFIED: nothing was rendered, no window was opened, no model was
  asked anything and no request left the container. There is no API key
  here.** `PROMPT_VERSION` did not move and the prompt is byte-identical. **It
  is NOT asserted that the 74 substituted numerals come from the RIGHT
  constant** — a substitution cannot drift from its own expression but can be
  wired to the wrong one, and that is `prompt_bounds_test`'s and
  `claim_field_test`'s question. No secret was set and no workflow file was
  edited; 064's finding stands and the live site is still `71b065f`. **No new
  "Human decision needed."** New TRAPS 70.
- Before 073 (see above, corrected in place by 074): **072**, which took the last of the
  three regex-breadth candidates — `claim_field_test`'s `^%s: N to M`, said
  to be unable to see a bound written with a dash or as *"between N and M"* —
  and found that **this time the entry's quote of the pattern was right, and
  the widening it asked for had no subject in the prompt at all.** Measured
  before anything was touched: **every one of the nine numeric tool fields
  states its bound as `field: N to M`.** Not one dash, not one *"between"*.
  Third commit running that this axis asked for a widening that was not the
  fix.
  **THE HOLE WAS THE LOOKUP, NOT THE PATTERN.** The check was written per
  field — find this field's bound, `continue` if the pattern misses — and **a
  lookup that misses is indistinguishable from a field that has no bound.**
  TRAPS 65's shape inside the suite that exists to hold bounds. Measured, not
  argued: with `brake:` reworded to *"between N and M"* and the **pre-072
  suite** restored in its own copy, the suite said **`failures=0`** and its
  PASS list lost **four lines** — including **the measurement of 038's
  *"stop on a sixpence"*, the headline claim the whole suite was written
  for.**
  **AND ONE BOUND WAS UNREACHABLE BY ANY LOOP OVER FIELDS.** Sweeping for
  every range rather than asking per field found **ten across the three
  tools: nine field bounds and one that is not a field's.**
  `BootsTool.TOP_SPEED` — *"It must come to 2 to 12 metres a second"* — is
  stated to the model and enforced in `validate()`, and **a grep of `tests/`
  for `TOP_SPEED` finds one hit and it is a comment.** Nothing had ever read
  it.
  **THE GENERAL RULE:** a suite that checks "every bound the prompt states"
  by looping over a code-derived list of **fields** can only see bounds that
  hang off a field. A bound about a **derived quantity** is in the class and
  invisible to the enumeration. Ask the text which claims it makes, not the
  code which claims it expects. TRAPS 59 and 68, one layer further in.
  **NOTHING IN `scripts/` WAS WRONG AND NO FILE IN `scripts/` OR `scenes/`
  CHANGED.** All nine bounds are accepted at both ends, the top-speed numbers
  are its constant's, and both its ends are reachable and accepted. The fault
  was not present; it was **unpreventable**.
  **WHAT CHANGED.** One file in `tests/`, **79 → 121 assertions**. Every range
  the section states must be **accounted for** — a numeric field's bound or a
  declared derived one — and an unaccounted range **fails**. A numeric field
  stating no bound is a failure, not a skip. The derived bound gets the
  field checks **plus one that is not a restatement: both ends must be
  REACHABLE with legal field values**, the reaching spec solved for from the
  constants rather than typed in. The claim loop's own *"at least one"* is
  now a counted total.
  **SIX DELIBERATE FAULTS, each in its own throwaway copy with its own
  `config/name` (TRAPS 50), FAIL lines READ.** The original fault: **3
  failures** where the pre-072 suite was green. Top-speed reworded: 2.
  Top-speed typed by hand so it drifts from its constant: 2. `TOP_SPEED`
  widened so an end is unreachable while both constants sit still: 1, and it
  is the check that is not a restatement. A stray range added to the car
  prompt: 2. `steering`'s bound deleted: 1.
  **THREE MUST-PASS CONTROLS PASS, two of them checked for passing for the
  RIGHT reason.** The pre-072 comparison above. Prose reworded around the
  bounds with the numbers untouched: green at the same 121, so the suite
  reads facts and not wording. And a **brand-new numeric field added to a
  tool only** (`wobble`, `1 to 9`): green at 128, with the **seven new
  assertions naming `wobble`** — read, not assumed — and the suite not edited.
  **71 suites, `--all`, `user://` cleared first: 0 with something to look
  at.** The baseline in this container before anything was touched was
  **byte-identical to the md5 071 recorded**
  (`f9b0d8cf50968a31a41d42023deab0ef`), and **two full runs on the final tree
  are byte-identical to each other and to it** — expected and said plainly:
  no suite was added and no verdict changed, so the run output cannot move.
  What changed is what can now fail, and the six faults measure that.
  **NOT VERIFIED: nothing was rendered, no window was opened, no model was
  asked anything and no request left the container. There is no API key
  here.** `PROMPT_VERSION` did not move and the prompt is byte-identical. No
  secret was set and no workflow file was edited; 064's finding stands and
  the live site is still `71b065f`. **No new "Human decision needed."**
- Before 072: **071**, which took the second of the
  three regex-breadth candidates — `said_article_test`'s sweep, said by the
  entry below to be unable to see *"an article in front of a two-word
  numbered label"* — and found that **the widening it asked for was again the
  wrong fix, and that the blind spot was not in the pattern but in every
  fixture list behind it.**
  **THE ENTRY'S QUOTE OF THE PATTERN HAD DRIFTED, as the entry itself warned.**
  Read off the file (TRAPS 66): it is `\b([Tt]he|[Aa]n?) ([a-z_]+) ([0-9]+)\b`,
  case-folded in its first letter, where the entry wrote `\b(The|A|An)`.
  **AND THE WIDENING WAS MEASURED AND REJECTED, for the second time running on
  this axis.** The comment already sitting on that pattern had measured it:
  with two words allowed it matches *"a track needs 2 to 40 sections"*, and
  the `is_label()` guard behind it **cannot rule that out**, because
  `is_label("track needs 2")` is `true`. **A regex over free text cannot tell
  a name from a verb**, so no breadth makes it the right instrument. 070's
  entry found the same shape one candidate earlier (TRAPS 67).
  **WHAT THE BLIND SPOT WAS ACTUALLY WORTH, measured before anything was
  touched.** `Readback.is_label()` says a label is a name whose LAST word is a
  number, and says nothing about how many words come before it — correctly,
  because `great hall 2` is as much a label as `room 2`. But **every name any
  fixture had ever handed it had exactly one**: `room 2`, `room_2`,
  `chamber 3`, `level 2`, `key 2`. So narrowing the function from
  `words.size() < 2` to `words.size() != 2` — **one character** — gave
  `the("great_hall_2")` the answer *"the great hall 2"* and put **three
  articles on numbered names into one dungeon readback**, and
  **all 71 suites stayed green with the `--all` output BYTE-IDENTICAL to the
  baseline** (md5 `f9b0d8cf50968a31a41d42023deab0ef` both ways, diffed).
  **IT IS REACHABLE, which was checked and not assumed (TRAPS 14).**
  `DungeonModule.validate()` lowercases and trims whatever name the model sent
  and stores it with **no shape constraint at all**, so a room called
  `great hall 2` — real spaces — validates `ok=true, errors=[]` and is read
  back verbatim. Both spellings are now in the fixtures because the validator
  accepts both.
  **AND NOTHING IN `scripts/` WAS WRONG — NO FILE IN `scripts/` OR `scenes/`
  CHANGED.** Every sentence family in the class was fed a multi-word numbered
  name before anything was touched — `NpcGoals`' ten sentences, the no-door
  refusal, the dungeon readback measured and unmeasured — and **every one was
  already correct**, because every one already reads `the()` or `article()`.
  The fault was not present. It was **unpreventable**, and that is a claim
  about the guard and not about Genesis.
  **THE SAME LIST LIVED IN TWO SUITES (TRAPS 11).** `log_022_test` holds the
  `is_label` fact too, with the same shape of list, and the same one-character
  fault passed it as well. Both are fixed; the fix is not in the suite the
  entry named alone.
  **WHAT CHANGED.** Two files, both in `tests/`. The label fact is asserted
  for multi-word names in both suites; `the()` and `article()` are asserted
  over them; the fixtures put a multi-word numbered name into every sentence
  family, in both spellings; and **the sweep was moved off the pattern and
  onto the names the fixtures actually use** — a `names_used` registry filled
  by the fixtures themselves, so a name added to a fixture is swept without
  anybody editing the sweep. TRAPS 59's rule, one layer in: guard against the
  state, not against the spelling. **The old pattern is kept beside it** as
  the backstop for a numbered name no fixture registered, unchanged, so no
  false positive was introduced.
  **`said_article_test` goes from 112 to 181 assertions**, counted off its own
  PASS lines.
  **TEN DELIBERATE FAULTS, each in its own throwaway copy with its own
  `config/name` (TRAPS 50), FAIL lines read.** `is_label` narrowed to exactly
  two words: **46 failures across the two suites** where it was byte-identical
  green before. `is_label` reading the first word instead of the last: 93 and
  16. `the()` and `article()` each stopped reading `is_label`: 60/7 and 26/2.
  **THE ONE THAT MATTERS MOST is the hand-written article at a single site**
  — `dungeon_module.gd:1653`'s `Readback.the(...)` replaced by `"the " + name`
  — because **both sweeps ran on it in the same output and the old one saw
  half**: the pattern named only `room 1`, the new state-keyed sweep named
  `room 1` **and** `great hall 2`.
  **THREE MUST-PASS CONTROLS PASS.** A sentence's tail reworded (*"is in"* ->
  *"sits in"*) and both suites stay green, so the guard reads the fact and not
  the wording. A **brand-new** multi-word name added to a fixture only
  (`north_wing_4`) is **named by the sweep without the sweep being edited**.
  And the containment helper was measured in both directions: **disabled, 32
  false positives** (`hall` reported bare inside `great hall 2`), so it is
  load-bearing; **enabled, all four genuinely bare names still named**, so it
  masks nothing — which is why it is done per occurrence and not per line.
  **AND THIS COMMIT'S OWN FIRST DRAFT ASSERTED A JUDGEMENT INSTEAD OF A FACT,
  recorded rather than quietly fixed (TRAPS 14).** It typed in that
  `"room 2 of 5"` is not a label. It ends in a number, so `is_label()` says it
  is — defensibly, *"you are in room 2 of 5"* takes no article — and the suite
  failed on the fixture rather than on the code. Replaced with
  `"room 2 exit"`, which tests the actual rule: a number anywhere but the end
  does not make a label.
  **71 suites, `--all`, `user://` cleared first: 0 with something to look
  at.** The baseline in this container before anything was touched was
  **byte-identical to the md5 070 recorded**
  (`f9b0d8cf50968a31a41d42023deab0ef`), and **the after-run is byte-identical
  to it as well** — expected and worth stating plainly: **no suite was added
  and no verdict changed, so the run output cannot move.** What changed is
  what can now fail, and that is measured by the ten faults and not by the
  run. Three full runs on the final tree, all byte-identical.
  **NOT VERIFIED: nothing was rendered, no window was opened, no model was
  asked anything and no request left the container. There is no API key
  here. No secret was set and no workflow file was edited.** 064's finding
  stands: the web build has failed on every push since 14 October and the
  live site is still `71b065f`. New TRAPS 68. **No new "Human decision
  needed."**
- Before 071: **070**, which took the live entry — the
  regex-breadth axis at the first of the three candidates 069 handed on — and
  found that **the entry named one pattern where there were two, and that the
  widening it asked for would have flagged a sentence that was right.**
  **THE TWO SWEEPS WERE NOT THE SAME SWEEP.** The entry read
  *"`container_door_test`'s and `counted_said_test`'s `\b1 [a-z_]+s\b`"* —
  one pattern, quoted for both. Measured in Godot before anything was touched:
  `container_door_test`'s is `\b1 [a-z]+s\b`, with **no underscore in its
  noun class**, and it was **blind** to `1 dead_ends`, `1 banked_corners` and
  `1 loop_segments`, all three of which `counted_said_test`'s pattern catches.
  `dead_ends` is a key of the very metrics dictionary that sweep runs over.
  **AND THE WIDENING WAS MEASURED RATHER THAN ADOPTED.** To see
  `1 saved worlds` — the one spelling of this fault Genesis has actually
  shipped, inline in `Main._list_worlds()`, per `world_store.gd`'s own
  comment — the pattern must allow a space, and the widened form also matches
  *"1 of them changes to the last world"* and *"1 readback that bears on it"*.
  **Both of those are correct**, because the word agreeing with the count is a
  **VERB** and the singular verb is right at one.
  **THE FALSE-POSITIVE CONTROL IS WHAT FOUND THE LIVE FAULT.** The second
  reads its verb from `Readback.agrees()`. The first decided it by hand and
  got it wrong — `session_report.gd:242` — measured by producing the line at
  four counts: *0 of them changes*, *1 of them changes*, *2 of them changes*,
  *3 of them changes*. **Correct at one of four**, and the one it is correct
  at is the one the comment fourteen lines above it was written about (*"042:
  the count and the noun after it are one fact … never written out again"*).
  **This file quoted the wrong form as real output**, at the 033 section.
  **THE GENERAL RULE:** a sentence that states a count and a word that agrees
  with it must read that agreement from `Readback.agrees()` — whether the
  agreeing word is a **noun, a verb or a pronoun**, and whether the count is a
  variable or a constant. 042 put the noun behind that reader and swept for
  nouns; a verb and a pronoun are the same single fact decided elsewhere.
  **NINE SITES, NOT ONE (TRAPS 11).** `session_report.gd` (4 — the verb, the
  drove line, the bare-`"no"` count and the pronoun after it),
  `race_director.gd:106` (a plural written at the other end of the noun),
  `ai_interpreter.gd:542` and `548`, `dungeon_module.gd:537`,
  `feasibility_gate.gd:83`, and **the AI prompt itself**,
  `racing_module.gd:76` — which 068 moved to read its two floors from the
  constants that enforce them and left the plural beside them written out.
  That is **TRAPS 11 inside 068's own fix**.
  **EIGHT OF THE NINE ARE BYTE-IDENTICAL AND THE NINTH IS THE FAULT**, proved
  by printing all eight sentences before and after and diffing:
  no difference. **The prompt is byte-identical and `PROMPT_FINGERPRINT` did
  not move** — `prompt_bounds_test` asserts it, so `PROMPT_VERSION` stays at
  `050-no-command-for-a-question-1` and no interpretation measured under it is
  split.
  **NEW SUITE `tests/agreement_test.gd`, 47 assertions.** Every agreement
  assertion is a **round trip against `Readback.agrees()`**: the word Genesis
  said is read out of the sentence by position and compared **whole** with
  what `agrees()` answers for the count actually passed. No agreeing word is
  typed in as the expected answer (TRAPS 6), and fault 11 below rewords the
  sentence's tail and the suite still passes.
  **FOURTEEN DELIBERATE FAULTS, each in its own throwaway copy with its own
  `config/name` (TRAPS 50), FAIL lines read.** All nine reverts are caught and
  named. **Two must-pass controls pass**: the sentence tail reworded, and a
  new multi-word noun added in `scripts/` covered without the suite being
  edited.
  **AND THE GUARD BUILT FOR IT HAD THE SAME SHAPE OF HOLE, found by the
  faults and not by reading it.** The scan that sweeps for a hardcoded
  `%d <plural>` derives its needles from the nouns handed to
  `Readback.plural()`, and **reverting `dungeon_module.gd`'s ring budget
  PASSED** — that site was the only call passing `"ring"`, so the revert
  deleted the fault and its needle in one edit. **A scan whose class is
  derived from the code it checks is blind to the change that shrinks the
  class.** Held instead by a per-site table naming the reader each site routes
  through, with that table's own weakness written into it: it says a sentence
  is *built* from the reader, not that its word was watched changing.
  **71 suites, `--all`, `user://` cleared first: 0 with something to look
  at.** The baseline in this container before anything was touched was
  **byte-identical to the md5 069 recorded**
  (`304df3c8d47eb0085b131d5d5ad70423`), and the after-run differs from it by
  **exactly one line — the new suite's**. Three full runs on the final tree,
  all byte-identical (`f9b0d8cf50968a31a41d42023deab0ef`).
  **NOT VERIFIED: nothing was rendered, no window was opened, no model was
  asked anything and no request left the container. There is no API key
  here. No secret was set and no workflow file was edited.** 064's finding
  stands: the web build has failed on every push since 14 October and the
  live site is still `71b065f`. New TRAPS 67. **No new "Human decision
  needed."**
- Before 070: **069**, which took HANDOVER's own first
  live entry — **three player-facing sentences say "corner" where the code
  means a TURN**, named with line numbers and called *"three words and a full
  run"*. **IT WAS FIVE SENTENCES IN THREE FILES. The list of three was a
  reading and not the class (TRAPS 31), and the two it missed are the two that
  matter most.**
  **THE MEMBER A PLAYER ACTUALLY MEETS WAS NOT ON THE LIST.**
  `racing_module.gd:566` is the `SOLVER CHANGE` **panel row**, reading the
  same `max_angle_adjustment` over the same `TrackGeometry.YAW_TYPES` as the
  three that were named — and all three of those are reached only by a
  **refusal**, while this one is shown on **every circuit that was built**.
  **AND THE FIFTH IS THE SAME FAULT OVER A WIDER SET.** `main.gd:845` said
  *"tightest corner"* for `minimum_radius`, which `TrackMetrics` takes over
  `TrackGeometry.CURVED_TYPES` — corner, hairpin, banked_corner, chicane and
  loop_segment. It is also **the one reading of three that had drifted**:
  `racing_module.gd`'s `TIGHTEST RADIUS` row and `experiment_runner.gd`'s
  *"tightest radius"* already named that number correctly, so 069's wording is
  taken from them rather than invented.
  **THE GENERAL RULE, which is worth more than the five fixes:** a
  player-facing sentence that names a section type is making a claim about
  which sections the number beside it was taken over, and it is true only if
  the noun names that whole set. The solver's angle adjustment is taken over
  `YAW_TYPES`, so its noun is *turn*; the tightest radius is taken over
  `CURVED_TYPES`, so its noun is *radius* and no type at all.
  **WHAT CHANGED.** Five nouns, in `scripts/feasibility_gate.gd` (1),
  `scripts/racing_module.gd` (3) and `scripts/main.gd` (1), each with the set
  it names written at the site. **No logic changed and the prompt text did not
  change** — `prompt_bounds_test` still asserts `PROMPT_FINGERPRINT` unmoved,
  so `PROMPT_VERSION` stays at `050-no-command-for-a-question-1`.
  **NEW SUITE: `tests/said_set_test.gd`, 31 assertions.** It asserts the
  **fact and not the wording** (TRAPS 6): every fixture is straights and
  hairpins with **no corner in it**, asserted on the sections actually passed
  in, so a sentence using the word *corner* is **false about the thing it
  describes**. Each sentence is also asserted to be **present and to carry its
  number**, because a sentence that vanished would pass a "does not say
  corner" check on its own.
  **NINE DELIBERATE FAULTS, each in its own throwaway copy with its own
  `config/name` (TRAPS 50), FAIL lines read.** All five reverted nouns are
  caught and named. **Fault 6 is the one that matters: `per turn` reworded to
  `per section that turns` PASSES**, so the suite reads the set and not the
  word. Fault 7 (the sentence deleted) fails on the *present* assertion, so it
  is not vacuous. Fault 8 (`hairpin` removed from `YAW_TYPES`) fails 6
  assertions. Fault 9 (`uphill` added to `OFFERED_TYPES`) fails the pin
  described below.
  **AND 069 MEASURED A FAULT THAT WAS NOT ONE, and the claim is recorded
  rather than dropped (TRAPS 14).** Its first fixture helper put both
  straights before both turns, which it then described as a paperclip and
  measured a **160 m closure miss** on — which reads like a solver that breaks
  a circuit that already closes. **It is not.** A paperclip alternates straight
  and turn, and `ClosureSolver` closes the real one **exactly**: proposal
  distance `0.0000`, `ok=true`, zero adjustment, measured. The fixture was
  wrong, not the code. The corrected claim is written into the helper's own
  comment in the suite.
  **70 suites, `--all`, `user://` cleared first: 0 with something to look
  at.** The baseline run in this container before anything was touched was
  **byte-identical to the md5 068 recorded** (`9bb6bd51cf700054e643edd76a4d2780`),
  and the after-run differs from it by **exactly the one new suite line**. Two
  full runs on the final source, both byte-identical
  (`304df3c8d47eb0085b131d5d5ad70423`).
  **NOT VERIFIED: nothing was rendered, no window was opened, no model was
  asked anything and no request left the container. There is no API key here.
  No secret was set and no workflow file was edited.** 064's finding stands:
  the web build has failed on every push since 14 October and the live site is
  still `71b065f`.
  **ONE HALF OF THE SAME CLASS IS DELIBERATELY LEFT, and it is the owner's.**
  All four sentences that name *"turns"* name *"straights"* beside it, and the
  solver length-adjusts every section in `TrackGeometry.STRAIGHT_FAMILY` —
  straight, uphill, downhill, crest and dip. **That is the identical fault one
  word along.** It is latent for exactly one reason: of `YAW_TYPES` two of
  three members are in `SectionValidator.OFFERED_TYPES` and of
  `STRAIGHT_FAMILY` only one of five is, because the four slope types are the
  subject of **"Human decision needed" 1**. Choosing the word a player reads
  for a set the owner has not decided to open is not this session's call. The
  suite **pins the fact** so it cannot be forgotten: it fails if a slope type
  ever becomes offered while those sentences still say *"straights"*. New
  TRAPS 66.
- Before 069: **068**, which took the half of 042's
  question 067 left: **the regex-breadth axis — for every sweep in `tests/`,
  what is the sweep blind to?** Asked of `tests/prompt_bounds_test.gd`, the
  suite TRAPS 28 built to compare every bound the prompt states against the
  constant that enforces it, because its own header claims *"it does not
  matter which sentence says it or how"*. **IT MATTERS.** Its two patterns —
  `N to M <members>` and `(at most|up to|no more than) N <members>` — can
  between them only match a statement naming a **MAXIMUM**, and the prompt
  stated four bounds by hand in the other direction: `at least 2 straights`
  and `at least 2 corners or hairpins` (`FeasibilityGate.MIN_STRAIGHTS`,
  `MIN_TURNS`), and the full turn three times (`FULL_TURN`). **NOT ONE OF
  THOSE THREE CONSTANTS APPEARED IN ANY FILE IN `tests/`** — grep, not memory.
  **MEASURED BEFORE ANYTHING WAS CHANGED, in its own throwaway copy with its
  own `config/name` (TRAPS 50): with the prompt reading *"at least 7 straights
  and at least 9 corners or hairpins"* — a floor stated four times narrower
  than the truth, which is TRAPS 28's own fault — and `PROMPT_FINGERPRINT`
  moved with it the way every real prompt edit moves it, ALL 69 SUITES PASSED,
  0 with something to look at.** The fingerprint is a change detector and
  cannot say a prompt is wrong; the session that edits a prompt moves it in
  the same commit.
  **THREE MORE FINDINGS CAME OUT OF ASKING IT AS A CLASS (TRAPS 11).** The
  full turn was stated a **fourth** time, by hand, to the **player**:
  `FeasibilityGate`'s `FAILED_INFEASIBLE` says *"a circuit must turn exactly
  +360 or -360 deg"*, eleven lines below the `FULL_TURN` that means it. And
  `FeasibilityGate.MAX_ANGLE_ADJUSTMENT` is a **second declaration** of
  `ClosureSolver.MAX_ANGLE_ADJUSTMENT` — the gate decides reachability from
  its own copy and states its own copy to the player, while the prompt states
  the solver's — with nothing asserting the two were the same number. Both are
  `0.20`, so **nothing is wrong today**; what was missing is the tie. And the
  pre-068 reader, handed the farm's floor restated as *"Use at most 24 zones,
  and at least 9 zones"* against a declared minimum of 1, also reported
  `failures=0`.
  **WHAT CHANGED.** Four hand-typed numbers in `scripts/racing_module.gd`'s
  prompt and one in `scripts/feasibility_gate.gd`'s refusal now read their
  constants. **THE PROMPT TEXT IS BYTE-IDENTICAL AND THE FINGERPRINT DID NOT
  MOVE** (`5a15cd39…`, asserted by the suite), so `PROMPT_VERSION` stays where
  it is and no interpretation measured under it is split.
  **AND ONE OF THE FINDINGS IS LIVE, which the rest are not.**
  `FeasibilityGate`'s floor refusal told the player *"closing a circuit needs
  at least 2 straights and 2 **corners**"*, and `MIN_TURNS` is compared
  against a count of `TrackGeometry.YAW_TYPES` — so **a hairpin answers that
  door as well**, as the prompt has always said and that sentence did not.
  Measured: a composition of `MIN_STRAIGHTS` straights and `MIN_TURNS`
  hairpins with no corner at all clears it. **The same two words were wrong
  one line above it**: the
  count beside the rule read `Readback.plural(turns, "corner")`, so a
  composition of one hairpin was reported as *"1 corner"*. Both are fixed —
  fixing one of them would have been TRAPS 11's exact shape — and the same
  count typed out in prose in `racing_module.gd`'s comment now names its
  constants.
  **AND 068'S OWN FIRST CLAIM ABOUT THIS WAS WRONG AND IS LEFT IN THE RECORD
  RATHER THAN QUIETLY FIXED (TRAPS 14).** It wrote *"nothing in `tests/` had
  ever read that sentence"* on the strength of a `grep` for `composition has`
  that found nothing. **`counted_said_test` reads it** — its needle is built
  from `Readback.plural()`, so the string a grep would look for is not in the
  file — and it **went red on the fix**, which is how the claim was caught.
  What it asserts is the agreement between the count and whatever noun
  follows it, with the noun **typed in**, so it could not see the noun being
  the wrong one. Its expectation is updated and both suites say what they
  hold. **A grep for a sentence finds the suites that quote it, not the
  suites that construct it.**
  `prompt_bounds_test` goes from **61 assertions to 72**: a minimum-only
  reader (`at least|no fewer than|a minimum of N <members>`), each half of a
  bound now compared only when the sentence states it, the two composition
  floors and the full turn against their constants, the gate handed
  compositions **at** the floor and one below it, both of the gate's refusal
  sentences read off real verdicts, and the gate's adjustment limit asserted
  equal to the solver's.
  **69 suites, `--all`, `user://` cleared first: 0 with something to look
  at**, against the same 69 at the 067 baseline run in this container with the
  same binary before anything was touched; no file was added, so the list
  length did not move. **Two full runs on the final source, both
  BYTE-IDENTICAL to that baseline** (md5 `9bb6bd51cf700054e643edd76a4d2780`,
  the same md5 067 recorded). **Ten deliberate
  faults, each in its own throwaway
  copy with its own `config/name`, FAIL lines read** — including the one that
  matters: fault 6's wording against the **pre-068** reader is green
  (`failures=0`) and against the new one fails naming the number.
  **NOT VERIFIED: nothing was rendered, no window was opened, no model was
  asked anything and no request left the container. There is no API key here.
  Apart from that refusal wording, every one of 068's findings is LATENT** —
  all four prompt bounds were already stating the truth and the two adjustment
  constants already agree, so nothing else wrong was found anywhere in the
  repository. What changed for those is that seven claims can now fail when
  they should. New TRAPS 65; new "Human decision needed" 31.
  **AND THE CLASS IS NOT CLOSED, which is the next task**: counted by script,
  the assembled prompt holds **92 numerals, 41 of them distinct**, and nothing
  asks of each one which constant produces it. 068 closed the four it found by
  reading the prompt line by line against the code; a guard would close the
  rest. See "Smallest useful assistant task next".
- Before 068: **067**, which asked TRAPS 11's question
  of the commit that had just restated TRAPS 11. **066's FIRST DELIBERATE
  FAULT PASSED**, because its new scan searched whole files for
  `OS.get_process_id()` and the comment 066 had written into
  `handler_wiring_test` says the call in prose. 066 narrowed that one function
  and wrote the lesson into TRAPS: *"scan code, not comments."* **IT NARROWED
  ONE FUNCTION. NINE FILES IN `tests/` READ THIS PROJECT'S OWN SOURCE, AND
  THREE MORE WERE SATISFIED BY A COMMENT** — measured one at a time in
  throwaway copies with their own `config/name` (TRAPS 50), each flipped from
  FAIL to PASS by **one comment line**, and each caught again after the fix:
  `handler_wiring_test`'s guard that its `PLACEHOLDER` is the string `main.gd`
  writes (47 assertions, failures=0, on a false claim);
  `player_door_test`'s guard that no suite reaches the main scene by a path of
  its own, defeated by a comment saying it did **not** use the setting (67,
  failures=0); and `check_wiring_test`'s guard that `BY_HAND`'s row still
  names a function that exists, defeated by *"Renamed from func
  quarrel_with(reason)"* (188, failures=0).
  **AND "SCAN CODE, NOT COMMENTS" TURNED OUT TO BE THE WRONG RULE, which is
  the finding worth more than the fixes.** Applied as written it would have
  **narrowed two checks that are wide on purpose**: `controller_reach_test`
  and `refusal_reach_test` both collect every `FAILED_` name in `scripts/` and
  assert each has a declared row, and a name that appears only in a comment
  still has to be answered for. The rule is about **direction** — a question
  about what the code *does* reads the code; a question about what is
  *mentioned* reads the raw file — and `refusal_reach_test` now asks both of
  one scan with the texts separated. **Measured while splitting it: all 16
  categories are in code, 6 are also in comments, and NONE is comment-only,
  so no answer in the repository changed.**
  **NO FILE IN `scripts/` OR `scenes/` CHANGED.** Nine files in `tests/` now
  read source through one function, `_code_of()`, byte-identical in every
  copy; one new suite, `tests/source_scan_test.gd` (24 assertions), holds the
  class at **file granularity** and says so. **69 suites, `--all`, `user://`
  cleared first: 0 with something to look at**, against 68 at the 066
  baseline, lists **diffed** — four assertion counts moved and one line was
  added, nothing else. Two full runs, **byte-identical**. **Nine deliberate
  faults and two negative controls**, FAIL lines read; fault 6's first
  attempt proved nothing because the injection was incomplete, and is
  recorded that way (TRAPS 55). New TRAPS 64; new "Human decision needed" 30.
  **NOT VERIFIED: nothing was rendered, no model was asked anything, no
  request left the container, and the per-needle half of the rule is NOT
  held** — `source_scan_test` proves a member has the reader and uses it
  somewhere, not that every needle in it goes through it.
- Before 067: **066**, which did two things and the
  first is about this file. **"Next action" item 2 — *hold the four
  `connect()` rows 059 found unheld* — HAD BEEN DONE IN 060**, in
  `tests/player_door_test.gd`, and this section's own 065 entry called it
  "the live next task". One grep of `tests/` for `text_submitted` refutes it.
  TRAPS 14, in the file that is the project's only continuity. It survived
  because the entry named `handler_wiring_test` as "the file to extend" and
  060 satisfied it by writing a **new file** instead, so nobody struck it.
  **An entry here is satisfied when the capability arrives, not when the
  file named in it is touched.**
  The second is **a reproducible fault, and it is the harness's.** 059's id
  class was counted as three — the record id (fixed) and two that are the
  owner's (HD 22). That is a count of what **Genesis** mints, not of where
  the rule holds. `main.gd:515` mints a session id as
  `"<name> <datetime to the second>"` and `read_session()` reads records back
  by it, out of one `user://` every copy of this project shares (TRAPS 50) —
  and **two of the three suites that start a session used a fixed string**,
  while the third defended itself with `Time.get_ticks_msec()`, **a clock,
  which is the one thing TRAPS 56 says does not qualify**. Reproduced, not
  reasoned about: **six paired concurrent runs of `handler_wiring_test`
  against one ledger, and in FIVE of the six one of the pair failed** *"the
  ledger gained exactly one ai_unavailable event (got 3)"* and returned
  early, **44 assertions where a clean run scores 47** — TRAPS 56's
  varying-count signature, the trap that cost 059 a day. **After the fix: six
  of six, 47 and 0 both sides.** All three names now carry
  `OS.get_process_id()`; `record_id_test` gains **sections 8 and 9** (22
  assertions, up from 12) which hold the rule for the class by scanning
  `tests/` and `scripts/`, because until now it lived only in prose.
  **NO FILE IN `scripts/` CHANGED and HD 22 IS NOT ANSWERED**: the product's
  session id and `run_id` are byte-identical, asserted as a labelled
  `OPEN (Human decision 22)` fact so the day the owner moves either, the next
  session is told. **68 suites, `--all`, `user://` cleared first: 0 with
  something to look at**, the same 68 as 065 because no file was added.
  **NINE deliberate faults**, each in its own throwaway copy, FAIL lines read
  — and **the first one PASSED**, because section 8's first version searched
  whole files and the comment the fix had just added says
  `OS.get_process_id()` in prose. A check a comment can satisfy is TRAPS 6
  inside a test. New TRAPS 63; new "Human decision needed" 29, whether a
  suite may delete the shared ledger (`session_test` does, and 066 did not
  change it).
  **NOT VERIFIED: nothing was rendered, no model was asked anything, no
  request left the container, and `session_test` is still not safe to run
  twice at once** — it deletes the ledger, which a session name cannot fix.
- Before 066: **065**, the task 063's "Next action"
  named: **the command panel's anchors and the strings in the scene — the last
  of 061's six visual differences, which are now all read by something.** One
  new test file, `tests/scene_ui_test.gd`, 43 assertions; **no code, no scene
  and no prompt changed.**
  063 warned that a `Control`'s rect might be meaningless headless and said to
  measure it in a throwaway copy before asserting off it. Measured, and the
  answer is **narrower than "frames must be stepped"**: a `Control` gets its
  rect **as it enters the tree**, and the only window in which a rect reads
  `(0, 0)` is before the viewport's first layout pass — i.e. inside
  `_initialize()`, which is where a `SceneTree` script starts and exactly
  where a suite written the obvious way would read it. **So the
  `_run.call_deferred()` idiom these suites open with is load-bearing, and
  none of them said so** (new TRAPS 62). This file's own first draft asserted
  the wrong rule and **failed on its first run**, which is how the right one
  was found.
  **TWO UNDERCOUNTS IN 063'S OWN PARAGRAPH, both TRAPS 11.** The strings are
  **four**, not three — `StatusLabel.text` is set in the scene too, and was
  easy to miss from a list of "strings nothing reads" precisely because
  `main.gd:22` *does* read it. And the panels are **three**, not one:
  `HistoryPanel` and `MetricsPanel` are built in code (`main.gd:916`, `:954`)
  with **absolute offsets from the top**, where the command panel's are
  relative to the **bottom**.
  **THE FINDING IS THAT THE LAYOUT IS CORRECT AND EIGHT PIXELS FROM NOT
  BEING.** `project.godot` sets no window size, so the base viewport is
  1152 x 648; under stretch `canvas_items`/`expand` the logical height
  **floors** at 648 (asked for 500, the viewport came back 1492 x 648), so the
  base size is the tightest the vertical layout can ever be and checking there
  checks everywhere. There the metrics panel ends at y=520 and the command
  panel starts at y=528 — and 528 is 648 minus the panel's **content**
  height, which moves with the font. **Adding one ordinary `Label` to that
  `VBoxContainer` takes the clearance to −19 px and the panels overlap**;
  nothing in the repository would have said so. **Not fixed** — moving a panel
  is a visual judgement and is "Human decision needed" 28.
  **68 SUITES PASSED, `--all`, `user://` CLEARED FIRST**, against 67 at the
  064 baseline, lists **diffed** (baseline re-run with the file moved out,
  not quoted from memory): the only difference is the one added line. Two full
  runs, **byte-identical**. **Eight deliberate faults** were each injected in
  their own throwaway copy and the FAIL lines read.
  **NOT VERIFIED: nothing was rendered and no window was opened**, so whether
  any of this is legible is still unmeasured. And **whether the panels cover
  the world is still not asserted** — now partly answerable, deliberately not
  answered, because it is a judgement about the game.
- Before 065: **064**, which is a **record and not a
  change** — no code, no scene, no test. Asked whether 063's push "went
  through", and the answer is that the only workflow this repository has, the
  `web build`, **has failed on every push since 14 October — 46 of them.** The
  export succeeds in 9 seconds; the **publish** fails because
  `NETLIFY_AUTH_TOKEN` and `NETLIFY_SITE_ID` are empty, so the Netlify CLI
  falls back to an interactive login and times out after five and a half
  minutes. **The live site is still commit `71b065f`, from before 021.** The
  secrets are the owner's and 064 touched nothing. New "Human decision
  needed" 27: whether the suite should run in CI at all, which it never has.
  **065 did not change this and set no secret.**
- Before 064: **063**, the task 062's "Next action"
  named: **the light and the environment, the next two of 061's six visual
  differences.** 062 guessed they would not be measurable the way the camera
  was. **One of them was.** A `DirectionalLight3D` emits along its own local
  -Z and the engine **ignores its position entirely**, so its rotation is the
  whole of what it does — and `scenes/main.tscn` had carried
  `Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, -45, -30, 0)` since the project's
  **first commit**: an identity basis with the three numbers sitting in the
  origin slots, a rotation written into the one field on that node that
  changes nothing. **The sun pointed horizontally.** `rotation_degrees` read
  `(0, 0, 0)`, the direction the light travelled was `(0, 0, -1)`, and `N·L`
  for every horizontal surface in Genesis — the 200 m pad the game starts on,
  a track's road, a farm's zone slabs, a dungeon's floors — was **exactly
  0.000000**. The only surfaces the sun reached were walls facing +Z.
  **STATED AT THE WIDTH IT IS TRUE (TRAPS 15): the screen was not black.** The
  `Environment` has a sky background with ambient source `BG` at full sky
  contribution, so horizontal surfaces were lit flatly by the sky, with no sun
  term and no shadows (`shadow_enabled` is `false`). What was lost is the
  **directional half** of the lighting.
  **THE FIX IS ONE LINE** — the same three numbers moved into the basis — and
  **the twelve floats were written by Godot, not by hand**: a `.tscn`'s
  `Transform3D` literal is the **transpose** of the basis `Basis.from_euler()`
  prints, so the hand-ordered version would have installed the inverse
  rotation, and the old line gave no warning because an identity basis is its
  own transpose. See TRAPS 61.
  **`tests/scene_light_test.gd` is new, 26 assertions, and is the first file
  in this project to read a light or an environment at all** — before it,
  "DirectionalLight", "WorldEnvironment" and "ambient" appeared **nowhere** in
  `scripts/` or `tests/`, not even in a comment. Section 0 is a **labelled
  guard** (every line prefixed `GUARD:`) that the scene has a sun and a sky
  and both are switched on; section 1 is the measurement; section 2 asks the
  rule as a **class** — every node in the scene whose job is decided by which
  way it points, which is the camera as well as the light — and closes it off
  the source, nothing in `scripts/` makes a light or an environment; section 3
  reads the running game after a real build.
  **67 SUITES PASSED, `--all`, `user://` CLEARED FIRST**, against 66 at the
  062 baseline, lists **diffed**: the only difference is the one added line.
  Run alone the suite gives **7 failures before the fix and 0 after**, and
  **eight deliberate faults** were each injected in their own throwaway copy.
  **AND FAULT 8 CAUGHT THIS COMMIT'S FIRST DRAFT, which is worth more than the
  fix.** That draft asked every question of the **running game**. For a light
  that is the stronger subject; for a camera it is the **weaker** one, because
  `_frame_view()` aims the live camera on every build — so with the scene's
  camera rotation deleted the draft reported **0 failures** and its class
  assertion passed on a camera that had no rotation in the file at all. Read
  the live state to find what a player gets; read the **file** to find whether
  a value is there to be got.
  **NOT VERIFIED: nothing was rendered and no window was opened.** Whether the
  scene now looks right is unmeasured and unmeasurable here; the angle and
  `shadow_enabled` are **"Human decision needed" 26**. Read by nothing *as of
  063*: the command panel's anchors and the three strings in the scene —
  **065 DID BOTH AND THIS CLAUSE IS NO LONGER CURRENT**, and it found that the
  strings were four. **That task is DONE; the live next task is the one under
  "Next action" below.** What 063 handed over, kept here as the record of what
  it asked for: those strings and
  anchors — the last of the six — with the warning that a `Control`'s rect
  under a `CanvasLayer` must be measured in a throwaway copy before anything
  is asserted off it.
- Before 063: **062**, the task 061's "Next action"
  named: **what in this project is only ever true on a screen, and can any of
  it be measured headless?** It can, and measuring it found a fault a player
  can reach. `GameController` has two functions that decide what is on screen
  — `_frame_view()` and `_restore_view()` — and **before 062 no suite read
  either**. Counted rather than remembered: the word "camera" appeared in
  **17** of the 65 files and in exactly **three assertions** — two that a
  particular camera is `current` (`explore_test`) and one that the controller
  holds a camera at all (`player_door_test`). Not one read where a camera is,
  what it is pointing at, or what it can see.
  **THE RULE THE TWO KEEP BETWEEN THEM WAS KEPT AT TWO OF ITS THREE DOORS
  (TRAPS 11).** The rule: when a request leaves the world empty, the view goes
  back to the scene's own camera and the scene's own 200 m pad. `CLEAR_WORLD`
  does it, a sectionless `CREATE_TRACK` does it, and **a `PLAN` that fails in
  pass 3 did not** — so a plan that failed after clearing took the player's
  world away and left a camera and a **1452 m pad still framed on the circuit
  that was gone**. Measured in a throwaway copy before a line was changed,
  with the plan a player meets first: two worlds and no `"around"`. **040 is
  the commit about that exact function** and fixed the half of this path that
  was about the world being destroyed; it could not see this half, because
  nothing in the repository could express it. The fix is **one call** inside
  040's own `if cleared_for_building:` guard — inside it, because a plan
  refused before it clears must leave the view alone, which is now asserted
  too.
  **`tests/view_frame_test.gd` is new, 82 assertions, and is the first file in
  this project to read a camera.** It solves `_frame_view`'s span and centre
  back out of the camera and asks whether the pad, `near`, `far` and the
  camera's **aim** agree; it asserts the capability rather than the arithmetic
  as well — every corner of a world's real footprint, off the AABBs standing in
  the scene, is inside the camera's frustum and on the pad; it asks both of
  **every command `WorldRegistry` knows about**; and it counts the emptying
  paths off the source, **exactly** and not as a floor, so a fourth cannot be
  added in silence.
  **66 SUITES PASSED, `--all`, `user://` CLEARED FIRST**, against 65 at the
  061 baseline, lists **diffed**: the only difference is the one added line.
  Run alone, the suite gives **4 failures before the fix and 0 after**, and six
  deliberate faults were each injected in their own throwaway copy to prove
  every class of assertion can fail.
  **AND 061'S OWN GUARD CAUGHT THIS COMMIT'S FIRST DRAFT, TWICE** — an unused
  `SCENE_PATH` constant, and then the comment explaining its removal quoting
  the literal it was about. Both read off a run. TRAPS 59's replacement doing
  the job it was written for, on the first new suite written after it.
  **NOT VERIFIED: nothing was rendered.** Five of 061's six visual differences
  — the light, the environment, the panel's anchors and the three strings — are
  **still unmeasured by anything** *(true at 062; the light and environment
  got a reader in 063 and the last two in 065, so all six are read now — none
  of which makes anything rendered)*; a world inside the frustum of an unlit
  scene is a black screen and nothing here would notice. **Whether the panels
  cover the world is not asserted**: the four `FRAME_*` constants are held to
  be applied consistently, not to be right. The frustum answer is for
  **1152 × 648**, the size `project.godot` configures, set on the root window
  from the setting because a headless Godot gives it 64 × 64 — at which three
  of four footprint corners were inside and the fourth was off the left edge,
  which would have been a finding about the harness. See TRAPS 60.
  **062'S "NEXT ACTION" WAS DONE IN 063**: the light and the environment. Its
  guess that they would be a labelled guard rather than a measurement was half
  right — the environment is a guard, and the light turned out to be
  arithmetic with a fault in it.
- Before 062: **061**, the task this file named as
  the next assistant task: **the sixteen `_make_main()` fixtures, asked as a
  class (TRAPS 11)**. The stand-in is **retired**. A throwaway script walked
  both trees in one process and enumerated **twelve** differences between the
  hand-built tree and `scenes/main.tscn` — a missing light, environment and
  `TitleLabel`; a `Ground` that was a `Node3D` where the scene has a
  `StaticBody3D`; a ground slab a metre lower with collision the scene has
  not got; a slab 400 m across in twelve of the sixteen where the scene's is
  200 m; a camera at a different place and level where the scene's is pitched
  40° down; an unanchored panel; three unset strings; and six nodes at a
  different child index. Rather than measure twelve differences one at a
  time, **every fixture now loads the scene the game launches**, resolved
  through `ProjectSettings.get_setting("application/run/main_scene")` so no
  suite can hold a scene that is no longer the game's.
  **AND THE CLASS WAS SEVENTEEN, NOT SIXTEEN:** `session_test` has no
  `_make_main()` of its own — it `extends "res://tests/drive_test.gd"` and
  inherits that file's fixture. 060's documents and TRAPS 57 both say
  sixteen; the correction is recorded rather than made silently (TRAPS 14).
  **65 suites passed before and 65 after**, `--all` both times, `user://`
  cleared first, lists **diffed**: the only difference is **one line**,
  `player_door_test`'s assertion count, **63 → 67**. No other suite's result
  line moved, including all sixteen whose fixture was replaced — so **no
  suite's answer rested on the stand-in**, which is the strong form of what
  060 could only say about the ground's collision.
  **WHAT IT BUYS, MEASURED THROUGH THE WHOLE RUNNER ON BOTH SIDES:** the
  deliberate fault 060 used — `BuildButton` renamed in the scene, which kills
  the game at launch on a null at `main.gd:100` — is caught by **18 of 65
  suites** on the 061 code and by **1 of 65** on the pre-061 code. One was
  already enough; the reason for the commit is the other direction, that
  seventeen suites now measure against the tree the game has.
  **AND THE STAND-IN'S FLOOR HAD BEEN DOING SOMETHING AFTER ALL.** 060
  measured that turning its collision off changed no suite's answer, and that
  still holds. But on `drive_test`'s **banked square** — the one circuit where
  opponents leave the road — the stand-in gave **21** recoveries with Green
  ending at `(234, −0.1, 67)`, **resting on a slab the game has not got**,
  and the game's own scene gives **25** with Green at `(124, −50.2, −320)`,
  **still falling**. Four runs, two a side, each byte-identical to its
  repeat; the other five circuits identical line for line across all four.
  Every opponent still finishes and no verdict moved. **The production code
  was already right about this**, asserted off the source:
  `race_director.gd:225` counts a car's vertical drop in its off-road
  distance, doubled, so a falling car is recovered like any other. The game
  does not need the floor; the harness was hiding the fall.
  **AND TWO OF 060'S OWN GUARDS HAD TO BE REPLACED, WHICH IS THE PART WORTH
  READING (TRAPS 59).** 060 wrote two enumerations to stop two sentences
  going stale. 061 falsified both sentences and **only one of the two
  noticed.** Section 6's — *"N other suites build that slab WITH
  collision"*, N ≥ 2 — went to 0 and **failed when run**, which is a check
  working; it is turned round to assert that **no** suite gives the ground a
  floor the game has not got. Section 0's — *"this is the only file that
  names a `.tscn`"*, written to guard *"nothing had ever loaded the
  scene"* — **would have gone on passing**, because the seventeen reach the
  scene through `ProjectSettings` and name no `.tscn` at all. A check written
  against the one idiom its author imagined guards the idiom, not the fact.
  It is replaced by the invariant 061 establishes: no suite stands `main.gd`
  up by hand, and every suite that stands it up reaches the scene through the
  setting.
  **AND THE FIRST DRAFT OF THAT REPLACEMENT FAILED FOR ITS OWN REASON**: it
  read `player_door_test`'s own source, where the searched-for strings are
  written out, and reported the suite against itself; and its `.tscn` version
  fired on all sixteen converted files because the **comment** in each names
  `scenes/main.tscn`. Caught by running it, not by reading it, and recorded
  in the suite (TRAPS 6, TRAPS 14).
  **ALSO IN 061, the same question asked of `drive_test`'s two readings of a
  world's node NAME** — HANDOVER's own "second candidate", and the class
  rather than the instance (TRAPS 11). Both now assert **identity** against
  `drivable["node"]`, which is TRAPS 58's own rule and what
  `player_door_test` section 1 already did. So **nothing in this repository
  identifies a world by name any more**, production or test. The mechanism
  and the measured alternation are kept in the comments, not deleted. **The
  production question is untouched and still the owner's**: "Human decision
  needed" 24, corrected there.
  **NOT VERIFIED: nothing was rendered and no window opened**, so the six
  visual differences of the twelve — the light, the environment, the camera's
  place and angle, the panel's anchors and the three strings — are
  **unmeasured by anything** *(true at 061; 062, 063 and 065 gave each of them
  a reader, and none of them a renderer)*; all 061 establishes is that the suites now
  stand up the tree that has them. **No file in `scripts/` was changed** and
  nothing a player can reach behaves differently. No model sent anything, no
  request left the container, the prompt is byte-identical and
  `PROMPT_VERSION` did not move. No world, record or saved file of the
  owner's changed, and `docs/GENESIS_BRIEF.md` was **not edited**.
  **THE NEXT ASSISTANT TASK** is in 061's "Next action": the six differences
  that are only ever true on a screen, and whether one of them — the
  camera's captured transform, which is now the game's pitched camera rather
  than a level stand-in — can be asserted headless as arithmetic.
- Before 061: **060**, the task that file named as
  the next assistant task: **holding the four `connect()` rows of `main.gd`
  that 059 left held by nothing** — `lap_completed`, race `announced`,
  `pressed` and `text_submitted`. **All four are now held**, each through a
  **real emit**: the real button's signal, the real `LineEdit`'s signal, the
  real `CheckpointTracker` counting a lap off the car's own position through
  `main.gd:809`, and the real `RaceDirector`'s three-second countdown running
  out under real physics. Nothing is hand-emitted into a handler.
  **AND ASKING THE TASK'S OWN QUESTION ONE LEVEL OUT FOUND SOMETHING
  LARGER, which is what the commit is about: NOTHING IN THIS REPOSITORY HAD
  EVER LOADED `scenes/main.tscn`.** Grepped across `tests/` and `scripts/`:
  no file mentioned a `.tscn` at all. Sixteen suites stand `main.gd` up by
  building their own tree by hand and **naming the nodes `main.gd`'s
  `@onready` lines ask for** — so the fixture supplies the names it then
  proves are there, which is TRAPS 14 in a fixture rather than in a
  document. The scripts resolve **six** node paths against that scene (four
  `@onready` in `main.gd`, plus `Camera3D` and `Ground/CSGBox3D` read off
  `world_root` in `game_controller.gd`), and **not one of them had ever been
  checked against the scene the game launches**. Measured: rename
  `BuildButton` to `Build` in the scene and `main.gd:100` throws on a null —
  the game dead at startup — and before this commit all 64 suites were still
  green. `tests/player_door_test.gd` is **the first file in the project's
  history to load that scene**, and it resolves the six paths by enumerating
  them out of the scripts' own source, so a seventh is covered the day it is
  written. See TRAPS 57.
  **AND THE FIXTURE IS NOT THE SCENE IN A WAY THAT IS MEASURABLE, AND WHAT
  THAT COSTS TODAY IS NOTHING** — measured, not argued either way. Sixteen
  files in `tests/` set `box.use_collision = true`; nothing in `scripts/`
  sets it anywhere, and the real scene's `Ground` is a `StaticBody3D` with no
  `CollisionShape3D` and a `CSGBox3D` with `use_collision` false. A 1 m box
  dropped from y = 6 **fell to y = −42.77 and was still falling** in the real
  scene and **rested at y = 0.49** in the fixture. All sixteen were then
  patched to match the scene and every suite run again: **64 suites, 0 with
  something to look at, and the list diffed IDENTICAL, line for line.** So no
  suite's answer rests on that floor and this file does not claim one does.
  An earlier draft of the suite header said *"every suite that has ever stood
  a body on the ground has stood it on a floor the game does not have"*; that
  is false — `physics_test` and `behaviour_test` build their own 4000 m
  `StaticBody3D` with a real `CollisionShape3D` — and it is recorded rather
  than deleted (TRAPS 14).
  **AND TWO OF THE SUITE'S OWN ASSERTIONS WERE FALSE ABOUT GENESIS (TRAPS 6,
  TRAPS 14).** Both passed review by reading and both failed when run.
  (a) *"the circuit is the one thing standing in the world"* read the node's
  **name** and expected `CircuitBuilder`, as `drive_test:174` does. It is
  `@Node3D@49`, and **the name ALTERNATES**: `add_child` replaces the name of
  a node that collides with a sibling, and the outgoing world is still a
  sibling in that frame — 048's fact again. Every other circuit a player
  builds gets a dummy name. Nothing in `scripts/` reads it (asserted off the
  source), `drive_test` reads it twice, and **the obvious fix yields
  `CircuitBuilder2`, measured**. Left unfixed on purpose: "Human decision
  needed" 24, and TRAPS 58.
  (b) *"the play loop reported the difference"* expected a `Changed:` line.
  **A raw-JSON request is never an edit**: `main.gd:190` calls
  `_execute_json` and returns, eight lines before `editing_from` is set. So
  the player who debugs with raw JSON is never told what changed. "Human
  decision needed" 25.
  **64 suites passed before and 65 after**, `--all` both times, `user://`
  cleared first, lists **diffed**: the only difference is **one added line**,
  the new suite's. **63 assertions**, failing against **eleven** deliberate
  faults made one at a time, FAIL lines read rather than counted. **No file in
  `scripts/` was changed and nothing a player can reach behaves differently**
  — the only edit outside `tests/player_door_test.gd` is a comment in
  `drive_test`.
  **NOT VERIFIED: nothing was rendered on a screen and no window opened; no
  model sent anything and no request left the container; the prompt is
  byte-identical and `PROMPT_VERSION` did not move. That a MOUSE CLICK emits
  `pressed`, or a RETURN key `text_submitted`, is Godot's and is not held
  here; nor is a player DRIVING to the checkpoints, nor the other emit of
  `race.announced` (the result line in `RaceDirector._finish()`, which needs
  three laps driven by somebody).** See 060 below and TRAPS 57 and 58.
  **THE NEXT ASSISTANT TASK**, and it is the other half of TRAPS 57: the
  **sixteen `_make_main()` fixtures**. Every one of them hand-builds a tree
  that stands in for `scenes/main.tscn`, and 060 measured ONE difference
  (the ground's collision) and found it cost nothing. The rest are
  unmeasured. The question to ask of the class is *what else does the
  hand-built tree have, or lack, that the scene does not* - enumerated by
  diffing one fixture against the scene node by node rather than by reading -
  and then, for each difference, the cheap measurement: make the fixture
  match and run everything. The scene has a `TitleLabel`, a
  `DirectionalLight3D`, a `WorldEnvironment` and an anchored `CommandPanel`
  that no fixture builds, and its `Ground` is a `StaticBody3D` where
  fourteen fixtures use a bare `Node3D`. Whether any of that is load-bearing
  is not known. **A second candidate, smaller:** `drive_test:163` reads a
  node name the other way round - *"the last child is not called
  CircuitBuilder, so the farm is on screen"* - which a dummy name satisfies
  as readily as a farm does (TRAPS 58, TRAPS 41). 060 added a comment there
  and did not change the assertion.
- Before 060: **059**, the task this file named as
  the next assistant task: **the seven `connect()` rows of `main.gd`'s
  sixteen still marked `NOT_ASKED`**. They were measured and **all sixteen
  rows are now measured**, so 057's sweep is finished: `door_changed` is
  **HELD** (`interference_test`, 3 failures, by the assertion that looks for
  the physical door slab — and this file predicted nothing held it, as did
  the session writing this, reading the code); the two **experiment** rows
  need a key and were not faked (TRAPS 52); and **four are held by nothing
  and all four are reachable with no key** — `lap_completed`, race
  `announced`, `pressed` and `text_submitted`. **The last two are the doors
  a player actually uses**: nothing in the project emits either signal,
  grepped, so every suite enters at `_handle_request()` and the suite says
  nothing about whether typing a sentence and pressing Build reaches the
  game at all. **Holding those four is the next assistant task.**
  **BUT THE COMMIT IS ABOUT SOMETHING THE MEASUREMENT TURNED UP.**
  `intent_door_test` failed **8, 8, 7 and 8** under four wire-outs that
  **cannot reach it** — it mentions no experiment, lap or button — and
  nothing under three others or under a pristine control run. The varying
  count is what settles it: a wire-out does not fail a different number of
  assertions each time.
  **THE CAUSE: `TrackLog.next_id()` COULD MINT THE SAME ID IN TWO
  PROCESSES.** It was `"<unix seconds>-<serial>"` and `serial` restarts at 0
  in every process, so two writers on one `user://track_log.jsonl` collide
  whenever they overlap inside one second. **Measured: every id collided in
  8 of 12 paired runs.** One ledger with two writers is the normal state of
  this repository — every copy shares one `user://` (TRAPS 50) and
  `run_tests.sh` starts sixty-odd processes against it a fraction of a
  second apart. Readers take the **first** match and say nothing, so a suite
  looking up its own record got another suite's.
  **AND THE COST IS NOT ONLY THE HARNESS.** The id is the only thing tying a
  later record to an earlier one: `session_report._understanding()` keys
  evidence by id, so of two records sharing one the report attributes **one
  request's understanding verdict to another** — a true-looking score about
  the wrong request, in the artefact this project exists to keep — and
  `game_controller.gd:420` writes a delivery's evidence as `"about": <id>`.
  **The fix is one function**: the writer's own identity is in the id
  (`OS.get_process_id()`), so no clock granularity can make two processes
  agree. Nothing parses the string — grepped, every consumer compares it
  whole — so widening it breaks no reader. **Re-measured on the fixed code:
  12 of 12 pairs landed in the same wall-clock second, the exact condition
  in which the old code collided every time, and 0 collided.**
  **AND IT INVALIDATES PART OF THE METHOD THIS PROJECT MEASURES WITH**, said
  here rather than left to be found: every commit since 055 reports *"the
  lists were diffed and are identical"*, and those diffs were taken with a
  suite in them that can fail this way in roughly two runs out of three.
  Nothing in 055–058 is withdrawn — their answers were read off lists whose
  other 62 lines were stable — but the confidence attached to "identical,
  line for line" was higher than the method earned.
  **THE CLASS IS THREE AND TWO OF THE THREE ARE NOT FIXED (TRAPS 11):** the
  record id (fixed), the **session id** (`main.gd:515`, a tester's name plus
  a second) and the experiment **`run_id`** (`experiment_runner.gd:62`, a
  second and nothing else). Both left deliberately — the session id is in
  reports the owner already has — and named below as the next task.
  **AND THE NEW SUITE'S FIRST DRAFT ASSERTED SOMETHING FALSE**: "no two
  records share an id" failed in a full run, because **a `PLAN` writes three
  records under one id, deliberately**. The honest invariant is that two
  **processes** must never share one. TRAPS 6 and 14, caught by running it.
  `tests/record_id_test.gd`, **12 assertions**, failing against **five**
  deliberate faults made one at a time.
  63 suites passed before and **64** after, `--all` both times, `user://`
  cleared first, lists **diffed**: the only difference is **one added
  line**, the new suite's.
  **NOT VERIFIED: that two real OS processes never collide is asserted by no
  suite** — that needs a second process and a test that races a clock, and
  what stands in its place is the 8-of-12 and 0-of-12 counts taken by hand.
  **Nothing was rendered, no model sent anything, no request left the
  container, and existing records are untouched.** See 059 below and
  TRAPS 56.
- Before 059: **058**, the task that file named as
  the next assistant task: **a fixture for `_on_interpretation_failed`, which
  needs no key and fakes nothing**. Done — **and asked of the whole class
  rather than the one handler named (TRAPS 11)**, because 057's sweep found
  **five** handlers held by nothing and fixing one member of a list is not
  fixing the list. The split is **three and two**:
  `_on_interpretation_failed`, `_on_track_measured` and `_on_equipped` are
  now **held**; `_on_interpretation_ready` and `_on_ai_retrying` are **still
  held by nothing and were not faked** — their only emits sit inside
  `_on_request_completed` and `_try_again`, which need a key (TRAPS 52), and
  the suite asserts that asymmetry off the interpreter's own source so that
  the day a key-free emit appears it says a fixture has become possible.
  `tests/handler_wiring_test.gd`, **47 assertions**. **No file in `scripts/`
  was changed and nothing a player can reach behaves differently.**
  **THE FINDING: `main.gd:177` checks `interpreter.busy` and refuses first**,
  with its own sentence, differing from `ai_interpreter.gd:345`'s by an
  ellipsis instead of a full stop — so the typed-request door never reaches
  the interpreter's busy guard and the handler does not run. **One condition,
  two deciders: 057's shape, and nothing is wrong here** — the player is told
  the right thing, by `main.gd`. Left as a candidate rather than changed,
  because the behaviour is correct and the smallest complete change to
  correct behaviour is none. The suite asserts both halves.
  **AND A SENTENCE IN THIS FILE WAS FALSE**, found by measuring the thing it
  denied: the cost of the unheld panel wire is not "permanently blank" but
  permanently showing a placeholder, and the suite's own second draft
  asserted "not blank" and **passed with the connect wired out**. TRAPS 54.
  The cascade that made one fault read as three is TRAPS 55.
  **AND "fakes nothing" was nearly true, not quite**: `_handle_request()`
  refuses before it can reach `interpret()` with no key, so the door is
  entered one level in with `pending_request` set exactly as
  `_handle_request` sets it — and the ledger assertion the sketch described
  **needs a session**, which the sketch did not say, because
  `TrackLog.event()` returns at its first line outside one. Without that it
  would have asserted the absence of a file write and passed.
  62 suites passed before and **63** after, `--all` both times, `user://`
  cleared first, lists **diffed**: the only difference is **one added line**,
  the new suite's. It fails against **thirteen** deliberate faults made one
  at a time, of which **two found faults in the suite rather than in the
  code**.
  **NOT VERIFIED: nothing was rendered on a screen, no model sent anything,
  no request left the container, and the two handlers that need a key are
  still held by nothing.** See 058 below, TRAPS 54 and TRAPS 55.
- Last commit at the time of writing: **057**, the task this file named as
  the next assistant task: **the sweep of `main.gd`'s sixteen `connect()`
  calls**, of which 056 had measured two. Seven more were measured and the
  sweep was stopped there — **and asking its question of the third one found
  a fault that stops the web build working at all**, which is what this
  commit is about.
  **ON THE WEB, NO AI REQUEST HAS EVER BEEN SENT.** `_send()` refused every
  one of them at `if api_key == ""`, a guard with no `on_web()` exemption,
  and **on the web `api_key` is always `""` by design** — `_load_key()`
  returns before reading anything and nothing else in the project assigns it
  (grepped). `is_available()` answers **true** on the web, so `main.gd` let
  the request through and `_send()` then killed it **before `_post()` could
  run**. The proxy 020 built was unreachable at any price, and the player was
  told to check `api_key.txt`, a file a web build must never carry.
  **THIS IS THE OWNER'S OWN "Next action".** Setting `GEMINI_API_KEY` in the
  Netlify environment would **not** have made the site work, and the error
  would have pointed at the desktop build's key file.
  **FOUR PLACES ALREADY KNEW THE RULE AND THE FIFTH DID NOT** — `where_to()`,
  `is_available()`, `_post()` and `_load_key()`, which are all four of
  `on_web()`'s call sites. The fix is therefore **one function both readers
  call**, `key_missing_for(web, key)`, taking the build as an argument so the
  web case can be measured in a harness that cannot flip
  `OS.has_feature("web")` — not a second `and not on_web()`, which would fix
  the instance and leave the class (TRAPS 11). The same rule applied to the
  401/403 sentence, which named `api_key.txt` on the web too; it now names
  `GEMINI_API_KEY`, **checked against `interpret.js`'s own source**.
  **Why twelve releases of a green suite missed it:** `proxy_test` asserts
  where a request *would* go and what the function does with it, and never
  that a request is **made**. Destination, thoroughly; departure, never.
  **TRAPS 53.**
  62 suites passed before and 62 after, `--all` both times, lists **diffed**
  and **identical** — `proxy_test`'s result line carries no assertion count,
  so the diff cannot show this change; the assertions were counted off the
  printed PASS lines instead, **11 before and 24 after**. The suite fails
  against **eight** deliberate faults made one at a time.
  **NOT VERIFIED: no browser ran and no web export was made.** What is proved
  is the decision for both builds and that the desktop guard still fires
  through the real `interpret()` door. **That a web build now reaches the
  proxy and gets an answer is NOT verified and cannot be here** — it needs
  the owner's machine, a deployed site and the key set. The fix removes a
  blocker that was provably in the way; it does not show that nothing else
  is. See 057 below and TRAPS 53.
  **The sweep's own answers: seven of sixteen measured, five held by
  nothing.** `ordered` is held hard and `log_message` is held by one failure
  in one suite that only `--all` runs; `track_measured`, `equipped`,
  `interpretation_ready`, `interpretation_failed` and `retrying` are held by
  nothing. The pattern is one layer — the handlers that turn a verdict into
  **what the player sees**. `main.gd:993` is the only production caller of
  `WorldRegistry.panel_lines()`, so every panel suite passes with the
  measurements panel never showing a measurement. **This file said
  "permanently blank" until 058 measured it. The panel is never blank:
  `_build_metrics_panel()` seeds it at `main.gd:978` with "Build a composed
  track to see its measurements.", and with the handler disconnected that is
  what a player sees all session, under a heading reading TRACK MEASUREMENTS
  — permanently wrong rather than empty, and an assertion that the panel is
  "not blank" cannot tell the two apart. TRAPS 54.** Nine rows remain
  `NOT_ASKED`.
- Last commit at the time of writing: **056**, the task this file named as
  the next assistant task: **055's question asked of the two rows 055 left
  `NOT_ASKED`** — *if this call stopped working tomorrow, would any suite say
  so?*
  **THE TWO ANSWERS ARE OPPOSITE.** `GameController.finish_order` — the
  delivery verdict, the thing PROTOCOL's *"never accept the carrier's claim
  as proof of delivery"* is about — is held **hard**: wire out its call at
  `main.gd:692` and **seven** suites say so (`false_delivery_test` 5,
  `interference_test` 2, `carry_test`, `ledger_test`, `order_test`,
  `repeat_test`, and `ledger_audit_test` throws). `false_delivery_test`
  reaches it through `main.npc.halt()`, the NPC's own `stopped_walking`
  signal, which is the door the game walks. Nobody had written that down.
  **`main._on_revision_requested` is held by NOTHING** — wire out the
  connect at `main.gd:80` and all 62 suites pass, `--all` included, and the
  diff against the baseline is **empty**.
  **AND IT COULD NOT HAVE BEEN REACHED, which is the finding.** The door is
  locked from the production side, not merely unwalked (TRAPS 49's shape).
  The emit stands behind `_may_revise()`, which requires
  `current_source["source"] == "ai"` — a string written in **one** place in
  Genesis, `AIInterpreter.describe()`, reachable only after
  `interpreter.is_available()` passes. Raw JSON, which is how every suite
  and every measurement in this repository sends a request, is stamped
  `{"source": "typed"}`. **A harness with no key cannot produce that gate's
  input at any price.** Asked of the class and grepped rather than
  remembered: `current_source` has two readers and one is a record field, so
  the closure revision is the **only** behaviour in Genesis gated on a
  request's provenance. The honest size of that class is one. **TRAPS 52.**
  62 suites passed before and 62 after, `--all` both times, lists
  **diffed**: the only difference is `check_wiring_test`'s own line, 179
  assertions to **188**. The new fixture fails against **ten** deliberate
  faults made one at a time, including the one that matters — the handler
  reading the proposal's distance where the closure's belongs, which proves
  the number assertions are not vacuous.
  **What the fixture fakes is one field**, the provenance label; everything
  downstream is the real refusal, the real `_may_revise`, the real emit and
  the real handler. **Not verified: no model sent any of this, and that the
  AI is actually ASKED for a correction is still unverified and cannot be
  checked here** — the handler calls `interpreter.revise()` after a 4 s
  timer and the fixture asserts the state set before that await. **No change
  to anything in `scripts/`.** See 056 below and TRAPS 52.
- The commit before it: **055**, the task that file named as
  the next assistant task: **the class question behind "Human decision
  needed" 18, asked of the whole project** — which checks are called on
  input the same function produced, and therefore cannot be proved
  connected?
  **ASKED STRUCTURALLY IT IS DULL; ASKED 053'S WAY IT IS NOT.** Almost every
  check in Genesis has a public door, and the farm's is the only one that
  does not. The question with answers in it is about the CALL: *if this call
  stopped refusing tomorrow, would any suite say so?* Fourteen call sites,
  each wired out alone in a throwaway copy, every suite run, the result
  lines diffed.
  **TEN HELD, FOUR NOT, AND ONLY ONE OF THE FOUR IS THE FARM'S PROBLEM.**
  `FarmModule._check_reachable()` is 053's and still has no door. The other
  three have a door that nothing walked: **`LoadCheck.compare`** at
  `main.gd:618` — replace the verdict with a constant `RESTORED` and all 61
  suites pass, `--all` included, because `load_check_test` calls it fourteen
  times and never through `/load`; **`RefusalCheck.quarrel_with`** at
  `main.gd:298`, the same shape; and **`ToolRegistry.readback`'s validated
  branch**, where the door WAS walked with inputs that could not show the
  difference — `{"weight": 130.0}` reads back identically either way, while
  five of eight sampled legal specs do not (*"the ordinary RED car"*).
  **And one held only by a suite most runs skip**: the controller's solve
  step is caught by `session_test` and nothing else, and `session_test` runs
  only under `--all`.
  **THE FIRST SET OF ANSWERS WAS WRONG AND THAT IS THE PART TO READ.** The
  runs were done two and three at a time in separate copies, and **every
  copy of this project shares one Godot `user://`** — one ledger, one
  `worlds` folder. Each run was reading another run's ledger; `ledger_test`
  and `intent_door_test` failed under nearly every change and were read as
  *"the guard is held"*. `LoadCheck` and `RefusalCheck` both looked
  connected and are not. Everything was re-measured one at a time with
  `user://` cleared first. **Run the suite one at a time** (TRAPS 50).
  **AND THE NEW SUITE, RUN AGAINST BROKEN CODE, FOUND A FAULT IN 053'S
  WORK.** `Script.get_script_method_list()` includes INHERITED methods, so
  053's *"all three modules override `solve()`"* could not fail — every
  module answered yes to every `WorldModule` method. The fact is still true;
  nothing was holding it, for twelve releases, and `WorldModule.solve()`'s
  own comment named it as the guarantee. It was hiding a smaller fact:
  **`FarmModule` defines neither `pre_check()` nor `post_check()`** and runs
  the base's, which refuse nothing. Corrected in both suites by reading the
  module's own source (TRAPS 51).
  61 suites passed before and 62 after, `--all` in both, lists **diffed**:
  the only difference is `check_wiring_test`, **179 assertions**, which
  fails against **thirteen** deliberate faults made one at a time.
  **Not verified: no model sent any of this, nothing was rendered on a
  screen, and no world, record or saved file of the owner's changes** — the
  only `scripts/` change is comments. Nothing in Genesis behaved wrongly at
  any point: what was found is what the suite was holding, not what the code
  does. See 055 below and TRAPS 49, 50 and 51.
- The commit before it: **054**, the task that file named as
  the next assistant task: **053's two questions asked of the refusals the
  CONTROLLER returns** — can a legal request reach each one, and does each
  one fire when handed a violation?
  **THE SEVEN NAMES ARE TWENTY-EIGHT BRANCHES, AND THAT IS THE FIRST
  ANSWER.** `FAILED_SCHEMA` alone is returned from eleven places,
  `FAILED_SCENE` from nine. 053's hardest lesson was that a table with one
  row per NAME hid two of `FAILED_LAYOUT`'s three branches, so every row in
  the new suite is a BRANCH and the enumeration counts refusal CALL SITES in
  the source rather than distinct names (TRAPS 11).
  **TWENTY-TWO ARE REACHABLE, FIVE ARE GUARDS, AND ALL FIVE FIRE.** No dead
  refusal in the controller either. The guards are `FAILED_NO_HANDLER`
  (every whitelisted command has an unguarded case in `execute()` or a
  module in `WorldRegistry`, walked against the case list READ OFF the
  source), `SPAWN_OPPONENTS`' `FAILED_SCHEMA` and its
  `FAILED_NOTHING_BUILT` (both stand after the `has_track()` refusal, and
  `TrackBuilder.corner_nodes` is appended to nowhere in `scripts/` — grepped,
  not remembered), and two of `ORDER`'s `FAILED_SCENE` branches (no module
  owns the standable world; the thing is not in the world any more).
  **One of the five was already half-asserted and this file says so rather
  than claiming the discovery**: `stub_claims_test` has held since 032 that
  `corner_nodes` is empty before and after a build and that `has_track()` is
  false, and its header calls that *"the reason `SPAWN_OPPONENTS` can never
  run"*. So the project already knew. What 054 adds there is the grep across
  `scripts/` rather than one instance after one build, and the second
  question — handed a track, both of those branches fire.
  **Unlike 053's farm guard, every one of the five can be proved CONNECTED**:
  each has a door that takes the thing it checks, so each was wired out one
  at a time and the suite caught it.
  **THE FINDING IS A COUNT IN A COMMENT.** `FAILED_NOTHING_BUILT`'s own
  header in `game_controller.gd` names *"the three Prototype 001 paths"* as
  the ones that answer to it. Measured: **only two of the three can be
  reached.** `SPAWN_OPPONENTS`' is a guard, for exactly the reason the
  comment four lines above its SCHEMA sibling has given since 036 — and that
  label was put on one member of the pair and never on the other, which is
  TRAPS 11 at the scale of two adjacent branches. Nothing is wrong on any
  request today; what was wrong is that a reader counting live answers off
  the comment got three.
  **AND THE FIRST READING GOT THREE BRANCHES WRONG, WHICH IS TRAPS 48.**
  `main.gd` stands an **unrecorded starter circuit** in the world at launch
  (`show_unrecorded`, `main.gd:135`) so there is something to drive before
  anything is asked for, and that sets `drivable` — so on a fresh session
  `has_drivable()` is TRUE, both `MODIFY_TRACK` and `SPAWN_OPPONENTS` answer
  with their composed-track refusal, and their other branches are reachable
  only after a clear. Measured, not read: **a player's first `MODIFY_TRACK`
  of a session is refused for a track he never asked for**, which is a
  sentence and is now noted under "Human decision needed" 2. And
  `FAILED_SCENE`'s *"the thing is not in any room"* was read as a guard and
  is **reachable**: a carried thing is in a corridor for part of the errand
  — sampled over one errand, the lamp was in room 1, in room 2 and in no
  room at all — so a second order sent at that moment reaches it. It took
  stepped physics to find.
  60 suites passed before and 61 after, `--all` in both, lists **diffed**:
  the only difference is `controller_reach_test`, **136 assertions**, which
  fails against **sixteen** deliberate breakages made one at a time.
  **Not verified: no model sent any of this, nothing was rendered on a
  screen, and no world, record or saved file changes** — the prompt is
  byte-identical and `PROMPT_VERSION` did not move. `FAILED_AI`'s first
  question is **not answered**: it needs a live key and an API that fails.
  See 054 below and TRAPS 48.
- Before that: **053**, the task that file named as
  the next assistant task: **052's question asked of a LIST instead of a
  key — which refusal categories can no legal request reach, and does each
  of those checks fire when handed an input that does violate it?**
  **THE NUMBER IS SEVEN OF TWELVE AND ALL SEVEN FIRE.** `grep` across
  `scripts/` gives sixteen `FAILED_` categories; ten belong to the world
  modules' four-step pipeline, and those ten are **twelve branches**,
  because `FAILED_LAYOUT` is returned from three places for three reasons.
  Five are reachable by a legal request and each has a named one in the
  suite; seven are not, and **every one of the seven still refuses the thing
  it names when handed it**. No dead refusal. The six categories the
  CONTROLLER returns — `FAILED_SCHEMA`, `FAILED_SCENE`,
  `FAILED_NOTHING_BUILT`, `FAILED_NO_HANDLER`, `FAILED_PARSE`, `FAILED_AI` —
  are enumerated and **not asked**, and that is the next task.
  **EACH "NO" IS ARITHMETIC AND NOT A SWEEP RESULT**, because a sweep that
  missed a shape looks exactly like a bound that holds: rings 1..4 hold 80
  slots against at most 23 other rooms; 24 rooms at pitch 46 span at most
  1098 m against a limit of 1400; a corridor runs down a lane 6 m wide and
  is 4 m; `MIN_ZONES` is 1 so an empty farm never reaches `solve()`; all
  three modules override `solve()`, asked by reflection so a fourth world is
  asked too. **This file's own first sweep got one of them wrong** and the
  trap is TRAPS 47: it reported `FAILED_UNREACHABLE` as out of reach because
  its disconnected designs had fewer doors than `validate()`'s floor and
  were thrown out a step EARLIER — a triangle of three rooms and a fourth
  outside it reaches it in one line.
  **AND ONE GUARD CANNOT BE PROVED CONNECTED, WHICH IS THE FINDING.** Delete
  the call to `FarmModule._check_reachable()` from `solve()` and **all 60
  suites still pass** — measured with a full `--all` run. The other six are
  reached through a door that takes the thing they check (`post_check(a
  layout)`, `solve(a content)`), so wiring each of those out is caught, one
  failure each, measured one at a time. The farm's is the only clearance
  check made inside `solve()` on a layout `solve()` just built, and there is
  nowhere to hand a violating one in. Moving it into `post_check()` is
  behaviour-identical and would fix that; it changes which step refuses, so
  it is **"Human decision needed" 18** and was not done.
  **WHAT CHANGED IN THE CODE IS SEVEN COMMENTS** — one at each guard, naming
  the arithmetic and the fixture, which is TRAPS 6's *"worth keeping, worth
  labelling"* applied to the list rather than to the two that already said
  so. `DungeonModule.post_check()`'s header claimed the corridor check
  "cannot happen by construction" and nothing had measured it; it now says
  so with the number beside it, and says the same for the two refusals next
  to it it did not mention at all. 59 suites passed before and 60 after,
  `--all` in both, lists **diffed**; `refusal_reach_test` is **93
  assertions** and fails against **thirteen** deliberate breakages, one at a
  time — and passes against the fourteenth, which is the one it reports.
  **Not verified: no model sent any of this, nothing was rendered on a
  screen, and no world, record or saved file changes** — the prompt is
  byte-identical and `PROMPT_VERSION` did not move. See 053 below, "Human
  decision needed" 18, and TRAPS 47.
- Before that: **052**, the task that file named as
  the next assistant task: **the layout keys nothing reads, enumerated world
  by world** — and the class question it set with it, *is a layout a RECORD
  of what was decided or an INPUT to the builder?*
  **THE CLASS QUESTION IS ANSWERED AND IT IS "AN INPUT", MEASURED:** 051
  established that nothing serialises a layout, so a layout is produced by
  `solve()`, consumed by the module, and does not survive — which makes a key
  with no reader dead weight and not documentation, and makes *give it a
  reader* the choice this repository's own shape asks for.
  **AND THE READER IT WAS GIVEN WAS NOT ASSUMING A LANE WIDTH. IT WAS
  COMPARING AGAINST 0.5.** `FarmModule._check_reachable()` is the farm's
  version of *"the circuit must close"* — the module header says a farm you
  cannot drive a tractor around is refused — and it called an edge clear
  unless a neighbour stood **within half a metre** of it. `LANE_WIDTH` is
  **6 m**, so the test admitted a gap **one twelfth** of the thing its own
  comment calls a lane, and the number it should have read was the dead key
  in the layout it was handed.
  **WHAT IT COST IS NOTHING YET AND THE COMMIT SAYS SO.** Over **468 legal
  farms** swept headless before anything changed, `solve()` never leaves two
  zones closer than **6.0000 m**: the failure branch is **not reachable from
  any request a player can send**, so both thresholds agree on every farm
  that exists and **no farm changes by a centimetre** — re-swept after, 468
  of 468 still solve and none is refused. What was wrong is that the guard
  did not guard what it names. `limits_test` has asserted that the SOLVER
  leaves a lane; that the CHECK requires one was asserted nowhere.
  **THE FIX IS THE CLASS AND THE PROJECT HAD ALREADY BEEN RIGHT TWICE**
  (TRAPS 11, and 040's question — *where has this project already been RIGHT
  once?*). Genesis has three clearance checks, one per world:
  `SeparationCheck.MIN_SEPARATION` **is** `ROAD_WIDTH + SAFETY_MARGIN`, the
  dungeon walks with a body `BODY` metres across and reports that width, and
  the farm's was the one that read a literal. The rule — **a clearance check
  compares against the dimension it is about** — is now asserted at all
  three. The four flush tests became one: an edge has a lane along it when
  the strip of ground one lane deep outside it is clear, which also blocks
  on an overlap the four could only see within half a metre of exact.
  **AND THE SUITE COULD NOT FAIL, TWICE, AND THAT IS THE PART WORTH
  KEEPING.** `layout_key_test` perturbs each layout key and asks whether
  anything the module does with the layout changes. Its signature included
  the built tree, and two things in it differ between two builds of the SAME
  layout: an unnamed node gets a generated name with a global counter
  (`@MeshInstance3D@57` — the farm's fence posts), and a build report that
  carries a node prints that node's instance id. Every key therefore
  "changed something" and the sweep **passed against the pre-052 code it was
  written to fail against**. Found by running it against that code and
  reading the output; the suite now asserts that the same layout signs the
  same way twice, before it asserts anything else.
  58 suites passed before and 59 after, `--all` in both, lists **diffed**:
  the only difference is `layout_key_test`, **64 assertions**, **13 failures**
  against the pre-052 module. **One thing was found and written up rather
  than fixed**: the circuit's `target_turn` survives into the layout to be
  read **for its sign only** — quadruple it and the track is identical,
  negate it and the direction flips — which is 049's predicted
  "wrongly-read field" in its mildest form, and a sweep that only asks *did
  anything change?* would have called it fully read. **Not verified: no model
  sent any of this, nothing was rendered on a screen, and no farm, record or
  saved world changes** — the prompt is byte-identical and `PROMPT_VERSION`
  did not move. See 052 below and TRAPS 46.
- The commit before it: **051**, the task this file named as
  the next assistant task: **the panel beside a REFUSAL**. It asked two
  questions of it — does every line stay inside what the caveat covers, and
  is the caveat shown in every case it is owed — and **both answers were no**.
  The caveat *"(measurements below describe the proposal, not a built track)"*
  is a claim about the CONSTRUCTION layer and was driven by the VALIDATION
  layer, and the two disagree on a real record: a plan works every world out
  before it builds any of them, so a plan refused after a step has been
  worked out emits that step's record with `result: VALID` and
  `construction: FAILED`. Measured headless, a plan whose step 2 will not
  validate: **ten measurement lines of a dungeon that does not exist, under
  `RESULT  Valid dungeon` in green, with no caveat and no reason** — both
  skipped for exactly the record they exist for. Reachable also by two worlds
  with no `"around"`, which is the shape of the prompt's own PLAN skeleton.
  **And the world that was named where there was none**, which needs no plan:
  `record.get("world", "circuit")` stood a Prototype 001 circuit in for every
  record with no `world` key, and `world` is absent from every record that is
  not a world — so `EQUIP` a car, `ORDER` a character and **`CLEAR_WORLD`**
  all read *"RESULT Valid circuit"*, the last being the command whose whole
  job is to take a world away. **The default had never been dormant**, which
  is why reading the circuit would not have found it: racing's record
  deliberately carries no `world` and `record_proposal_test` asserts it, so
  `"circuit"` fired on every circuit, where it was right. **And a verdict was
  printed for a record that has none**: `record_load_check()`'s record has no
  `result` key, so a load check whose outcome was SAME read
  `RESULT  FAILED: ` in red with an empty category. The fix is the rule and
  not the three instances (TRAPS 11): every panel line names the layer it
  speaks for and reads that layer's field, a record with no `construction` is
  not built and one with no `result` has no verdict, and a world is named by
  `display_name()` — so **nothing was added to the circuit's ledger record**,
  which was checked before it was decided. All four decisions moved out of
  `main.gd`'s UI callback into `WorldRegistry.panel_lines()`, which is why
  nothing had ever asked. 57 suites passed before and 58 after, `--all` in
  both, lists diffed; `panel_refused_test` has 90 assertions and **fails 11
  times** against the old decisions; six panels were dumped and diffed before
  and after and **the diff is one line**. **Not verified: no model sent any of
  this, nothing was rendered on a screen, and the green panel of an unbuilt
  world was never DWELT on** — another emit follows in the same frame — so
  that half is latent, while the `EQUIP`/`ORDER`/`CLEAR_WORLD` naming is not.
  **One fault was found and left for its own commit**: a plan refused in pass
  3 appends **two ledger lines under the same id**, one `BUILT` and one
  `FAILED`. See 051 below, TRAPS 45, and "Human decision needed" 17.
- The commit before it: **050**, the task that file named as
  the next assistant task and as **the one that outranked everything else on
  the list, because it was the OWNER'S**: *there is no way to ASK Genesis
  anything*. His machine, 2026-10-16, live key, recorded in `5d36bfb`:
  *"show me the dungeon metrics"* came back a **SHUT** and *"where is the red
  key now"* came back **UNSUPPORTED**. **NO COMMAND WAS ADDED**, as this file
  said twice; what a query door should be is now "Human decision needed" 16,
  with the options measured rather than guessed.
  **GENESIS HAS BOTH ANSWERS AND NO DOOR TO EITHER**, which is the finding
  and is what makes a refusal that denies the capability false:
  `measure(layout)` returns every number the first question asks for, and
  `room_of(layout, position)` is how the second is answered every time a
  delivery is judged. `CommandParser.allowed_commands()` has eleven entries
  and every one of them builds, changes or removes something.
  **THE CAUSE OF BOTH OF HIS ANSWERS IS IN THE PROMPT.** It binds a refusal's
  REASON to *"name the part that is missing, from the list above"* — and that
  list had **no entry for a question**, measured: *"question"* appears **0**
  times in the 15846-character assembled prompt and *"query"* **0** times,
  while the list above it says *"It MEASURES everything it builds"* and
  *"Never say Genesis cannot do one of them"*. A model with a question in
  front of it had three moves: invent a reason, deny a listed capability, or
  send the nearest command on the whitelist. **Both answers the owner got are
  on that list of three, and so is the false refusal 048 caught in the same
  session.** The limitation is now stated, so `PROMPT_VERSION` moves to
  `050-no-command-for-a-question-1` and designs are not comparable across it.
  **AND THE CHECKER CALLED THE TRUE ANSWER FALSE**, which is 048's own fix
  seen from the other side. Measured before anything changed, **three of the
  nine true refusals of a question in the new suite were flagged as
  understating Genesis** — one of them by the entry whose rebuttal has said
  since 048 that *"a refusal about THAT is right"*. The exception was in
  prose and implemented nowhere. **And `log_023_test` was guarding a wording
  rather than a claim**: its honest neighbour *"there is no command for
  asking where a thing is; the panel shows it"* passed only because it
  contains no word from either list; reworded as *"there is no way to ask
  Genesis to report the position of a thing"*, the same true claim was
  caught. **The fix is the rule**: a capability word standing AFTER an asking
  word is not being denied — what is denied is the door to it — and the mark
  is per capability, because *is there anything the player can type that
  produces this on demand?* is a fact about which doors exist. Asked of all
  seven: two have no door (the panel is drawn when a world is built; a
  thing's position is read when an errand is judged) and five do (`ORDER`,
  `PLAN`, `/save`, `/load`, `/log`, `/worlds`, `/session end`), so *"you
  cannot ask for one world inside another"* stays caught, which the new suite
  asserts in both directions. 56 suites passed before and 57 after, `--all`
  in both, lists diffed; `asked_test` **fails 4 times** against the pre-050
  code. **Not verified: no model sent any of this**, nothing was reproduced
  from the owner's screen, and whether the new prompt line stops a question
  becoming a SHUT is his next editor session. See 050 below and TRAPS 44.
- The commit before it: **049**, the task that file named as
  the next assistant task: **the farm's panel and the circuit's panel,
  against the geometry they describe** — 047 asked 046's axis at the
  dungeon's panel and left the other two half asked, and this file said the
  method was 047's and cheap: build the world, walk the tree, count the
  pieces, add up the areas and lengths, and put each number beside the panel
  line that states it. It predicted that the numbers would probably agree and
  that the thing to ask of each line was **what fact it reads**.
  **THE PREDICTION WAS RIGHT ABOUT THE NUMBERS AND 049 CLAIMS NOTHING
  ELSE.** Measured headless before anything changed, **every line of both
  panels agrees with the geometry actually placed.** The circuit's `LENGTH`,
  the line this file singled out as *"known not to follow the world"*, was
  measured off the road surface itself — the centre of every quad of every
  `Section_` mesh in the tree, added up — and came to **1176.91 m** where the
  panel said **1177 m** and `measure()` said 1176.99 m; the 8 cm is the road
  being drawn as chords between samples 4 m apart, and it is a
  discretisation and not a line disagreeing with its world. The farm's eight
  lines agree exactly: 9 zone pieces, 141 × 126 m of `Ground` slab, 0.64 ha
  of worked slab, 484 m² of building, 500 m² of pond, 2400 m² largest, 534 m
  of rail.
  **THE FAULT IS NOT IN EITHER PANEL. IT IS IN THE FARM THE PANEL
  DESCRIBES**, and it was found by asking the audit's own question of the one
  number in the farm's layout that **no panel line states**: the GATE.
  `solve()` cuts the gate into the south side of the fence IT computed and
  records the point; `_fence()` exists precisely because a plan can MOVE that
  fence, and `build()` passed `layout["gate"]` straight through. Measured, a
  farm of a barn and a wheat field: as solved, **10 posts on the gate's line
  with a 16.0 m gap in them**; the same farm grown to 260 × 260 m by
  `grow_to()` — which is what `GameController` calls for *"a dungeon with a
  hall and a vault, inside a farm with a barn"*, a request this file records
  as working — **0 posts on that line and no gap anywhere in its 132.** A
  farm with no way in, with the comment over `solve()` still saying *"a gate
  cut into the south side"* (TRAPS 14, in a code comment).
  **NOT LATENT**, unlike 047's: the farm is the world that grows, because
  racing opts out through `can_grow()`, so every plan that puts a world
  inside a farm got one. What makes it quiet rather than loud is that **the
  fence carries no collision at all** — checked by grep, no `StaticBody3D`
  and no `CollisionShape3D` anywhere in the module — so the way in was
  missing from the picture and not from the physics.
  **The fix is the class**: `_gate()` beside `_fence()`, and the rule
  *anything a world positions against its own boundary is read from the
  boundary that is BUILT*, audited across both worlds that can grow — the
  farm's zones are deliberately left where they are and never touch the
  fence, and the dungeon positions its rooms and corridors against each other
  and only its `Ground` pad against the grown bounds, through `grown()`
  already. **One member today, and written down so a third world does not add
  a second.** On a farm nobody has grown `_gate()` returns `layout["gate"]`
  itself, so **no farm anybody has ever built changes by a centimetre**.
  **Found in the same reading and it is a one-reading fault, not a wrong
  number**: `TrackMetrics` carried its own copy of `STRAIGHT_FAMILY` and
  `YAW_TYPES` where the closure solver, the feasibility gate and two suites
  all read `TrackGeometry`'s — and the feasibility gate's own comment says
  *"the type lists come from TrackGeometry, so the gate, the solver and the
  metrics agree"*. The copies were **byte-identical, so nothing was ever
  mismeasured**; what was wrong is that the four panel readings that depend
  on which sections are straight and which turn were decided by a list
  nothing else obeyed, in the file whose header warns a new type needs four
  files. 54 suites passed before and 55 after, `--all` included; the new
  suite `panel_geometry_test` (119 assertions) **fails twice** against the
  pre-049 gate and **does not parse** against the pre-049 code entire,
  recorded that way rather than stubbed. The prompt is byte-identical, so
  `PROMPT_VERSION` did not move. **Not verified: no model sent any of this**,
  and the rail still runs across the gate on every farm — that is "Human
  decision needed" 15. See 049 below and TRAPS 43.
- Before it: **047**, the task that file named as
  the next assistant task: **the sixth axis applied to `tests/` — which
  suites never RUN the thing they make a claim about?** This file handed over
  a starting point marked MEASURED BY GREP AND NOT A FINDING, and said to
  **start at the dungeon's panel, because it is the longest, and ask of each
  of its nine lines what the number is read from**. Asked, and the reading
  was right about where to look.
  **ON A DUNGEON AS BUILT, NOTHING IN THE PANEL WAS WRONG** — measured
  headless before anything changed, every one of the nine lines agrees with
  the geometry actually placed: 2 `Room_` slabs for *"ROOMS 2"*, 244 m² of
  slab for *"ROOM FLOOR 244 m2"*, 88 m² and 18 m of `Corridor_` slab for
  *"CORRIDOR 18 m long, 88 m2"*, 29 × 12 m of placed floor for *"SIZE 29 m by
  12 m"*. **THE FAULT IS ONE QUESTION ALONG: WHICH DOORS THE LINES WALK.**
  Four of the nine describe getting about — how deep the deepest room is,
  which room that is, how many dead ends, how many ways round — and all four
  walked the dungeon's FULL door list. **WALKABLE, the line directly above
  WAYS ROUND, walks the doors a body can USE**, and so do `route()` and the
  body. Measured on a ring of four rooms with the ring-closing door shut:
  *"WALKABLE 4 of 4 rooms reachable"* on one line and *"WAYS ROUND 1 loop"*
  on the next, with no way round; *"DEAD ENDS 0"* where there were two;
  *"DEEPEST crypt 2 doors from the entrance"* where the cell was 3 away; and
  `route()` 1→4 had gone from 38 points to 191, so **the body had been told
  what the sentence had not**. **THE SECOND FAULT IS A CRASH, NOT A FALSE
  SENTENCE**: `walkable()["blocked_doors"]` appended a `Vector2i` for a shut
  door and a `String` for a doorway no body fits — one list, two types — and
  `route()` read every entry as a `Vector2i`, so a blocked doorway **threw
  inside `route()`**, which returned `[]`, which the controller reads as
  *"There is no way through to the vault."* Demonstrated: before 047 a
  dungeon with one blocked doorway could not be routed through the doorway
  that was **clear**. **BOTH HALVES ARE LATENT AND 047 CLAIMS NOTHING ELSE.**
  `measure()` is called in one place, `GameController._prepare()`, before
  anything is built, and `set_shut()` only ever runs on a standing layout, so
  the panel a player reads was drawn when nothing was shut; and a doorway no
  body fits does not occur from a legal request — **4000 random legal ring
  dungeons solved this session, 2597 built and post-checked, none with one**,
  which is `sweep_test`'s finding from the other direction. **The fix is the
  class**: one list of unusable doorways as door pairs with the sentences
  beside it in `blocked_why`, one `usable_doors` list that `route()` and
  `measure()` both read so neither builds its own graph, and the loop count
  in one function — `loop_count(doors, rooms, components)`, used by
  `pre_check()` and `measure()` alike. The formula moved with it: the old
  `doors.size() - rooms.size() + 1` was right only because the one graph
  either caller had ever seen was one `pre_check()` had already proved
  connected, and a door a body cannot use can split a graph in two. **THE
  SENTENCES DID NOT MOVE**: every panel line and both summaries are
  byte-identical before and after on every dungeon with nothing shut,
  measured. 53 suites passed before and 54 after, `--all` included; the new
  suite `panel_built_test` fails **7 times** and throws twice against the
  pre-047 readings, and does not parse against the pre-047 code at all
  (`loop_count` does not exist there), recorded that way rather than stubbed.
  The prompt is byte-identical (sha256 `c6c2b955...`, held by
  `prompt_bounds_test`), so `PROMPT_VERSION` did not move. **Not verified: no
  model sent any of this**, and the dungeon's DOOR count still counts a shut
  door as joining two rooms, which is deliberate and is "Human decision
  needed". See 047 below and TRAPS 41.
- Beside it, pushed by the other run of the same task minutes earlier:
  **`5d36bfb`, subject "048: fourteen rooms, four rooms, and a net with a
  hole in it"** — and it is the one to read first, because **both its faults
  came off the OWNER'S editor**, on real hardware with a live key,
  2026-10-16, in code the suite had passed. **READ FROM THE COMMIT AND ITS
  DIFF, NOT REPRODUCED BY THE SESSION WRITING THIS**, and that commit changed
  no documents, so its own account — fuller than this one — is in
  `git log 5d36bfb`:
  - *"CREATE_DUNGEON built **14** rooms joined by 4 doors"* for a request of
    four. The readback, the doors, the corridor length and the depth in that
    same sentence were all right; only the count of what was BUILT was wrong.
    `queue_free()` marks only the node it is called on, and
    `_clear_world_node()` frees `world_node`'s direct children — one holder
    per world — so the pieces are a level BELOW the mark and
    `placed_pieces()` walked past the holder's flag. The ten extra were the
    starter circuit, on its way out in the same frame.
    `placed_pieces()` now returns 0 for a subtree whose root is going, before
    the recursion. **This is 046's count, which this file has been quoting
    since 046 on the strength of "the two agree on every dungeon measured so
    far"** — and they did, in a harness where every world is built into a
    fresh holder and nothing is ever on its way out.
    `tests/outgoing_world_test.gd` is the first suite that puts a world there
    first and clears it the way the controller does.
  - `RefusalCheck` met its first real false refusal and said nothing:
    *"Genesis cannot inspect or report the current state of the world or
    character"*, where it was looking for *"inspect the world"* and *"world
    state"*. Third time word order has beaten a phrase list here, after
    022's *"actually"* and 023's *"instead"*, so that capability is matched as
    a PAIR of ideas — an act word and a thing word, anywhere in a sentence
    after a negation, in either order — rather than as a fourth phrase.
  - **And it records something NOT fixed, as a feature rather than a fault:
    there is still no way to ASK Genesis anything.** The owner asked twice in
    that session — *"show me the dungeon metrics"* and *"where is the red key
    now"* — and got a `SHUT` and an `UNSUPPORTED`. That commit names it as the
    next thing worth building and leaves it for the owner. **It is not written
    up anywhere in these documents yet**, which is the first thing the next
    session should fix: it is an owner finding and it outranks anything on the
    candidate list below.
- Before 047: **046**, the task that file named as
  the next assistant task and the last entry on its own list of rules with a
  function left to count: **TRAPS 24's**, *a line that states a count reads it
  from what was BUILT, not from what was asked*. The answer is **only where
  the fault was found, for the sixth commit running**, and this file's own
  starting point was right about where to look and wrong in one of its two
  spot-checks. `stub_claims_test` has held the rule since 032 for the three
  Prototype 001 stubs, **which place nothing**; it was never asked of the
  lines that describe a world that IS built, and those are the lines a player
  reads. Measured headless before anything changed: the dungeon's summary read
  `measure(layout)["room_count"]`, the circuit's read `sections.size()` from
  inside `CircuitBuilder.build()`, the dungeon's build REPORT carried
  `rooms.size()`, and the farm states no count at all. **This file called
  racing's clean** on the grounds that the builder "adds a road piece for
  every section it loops over" — **a count of LOOP ITERATIONS is not a count
  of placed nodes**, and `_add_collision()` in the same function returns early
  on an empty face list, so the builder already has one way to place less than
  it looped over. **And this file said `FarmModule` "overrides neither"
  `summary()` nor `metric_lines()`: it overrides `metric_lines()` and has
  since 003** — TRAPS 14 in this handover, found by grepping for the thing the
  sentence denied. **NOTHING WAS WRONG ON ANY WORLD MEASURED** and 046 claims
  nothing else: 3 rooms/3 slabs, 2 doors/2 corridors, 8 sections/8 road
  pieces/8 collision bodies, 3 zones/3 zone nodes. What was missing was the
  TIE. **Why no suite saw it**: `grep` found `.summary(` in three of the 52
  suites and **in none of them was a world ever BUILT** — all three hand it a
  dictionary typed into the suite, and `container_door_test`'s fixture states
  `loops: 1` where `measure()` would compute 0. That is 044's axis — what
  LAYER do the fixtures enter? — at the one layer whose answer was *none of
  them*. **The fix is one reading on the base**: `WorldModule.mark_piece()`
  marks a piece where it is placed and `WorldModule.placed_pieces()` counts
  the marked nodes off the tree, so a world added later that forgets reports
  **0** and fails rather than being quietly correct. **And the fix for false
  lines nearly introduced one**: the controller `queue_free()`s the old world
  and builds the new one on the next line, so for part of a frame both are in
  the tree — **measured, four marked nodes for a two-room dungeon** — and a
  count that ignored `is_queued_for_deletion()` would have said four rooms.
  52 suites passed before and 53 after, `--all` included; the new suite fails
  **4 times** against the pre-046 sentences and does not parse against the
  pre-046 code at all, recorded that way rather than stubbed. The prompt is
  byte-identical (15846 chars, sha256 `c6c2b955...`), so `PROMPT_VERSION` did
  not move. **Not verified: no model sent any of this**, the farm's silence is
  left as a silence, and the dungeon's DOOR count and the circuit's road
  LENGTH still come from the layout. See 046 below and TRAPS 40.
- Before 046: **045**, the task that file named as
  the next assistant task — *ask every suite in `tests/` what IT cannot see* —
  and **this file's own prediction about where to look was right**: it said to
  expect the readback and the RECORD to be the layers nobody probed, "because
  they return strings rather than verdicts". 044 was the readback. This is the
  record. The rule asked is **TRAPS 25's**, *a command's record is part of the
  command*, which this file listed as *"may well be whole; worth confirming
  rather than assuming"* — **confirmed, and it was not whole**. Measured
  headless before anything changed, one request per whitelisted command read
  back off disk, and counted in the whitelist's own unit (TRAPS 31): eleven
  commands, of which `CLEAR_WORLD` takes no fields and has nothing to propose;
  **of the remaining ten, EIGHT record what they were asked for in a
  `proposed_` field and two record nothing**, with a ninth door — the
  sectionless `CREATE_TRACK` — recording one without being a separate entry on
  the list. A `CREATE_FARM` record carried
  `world`, `intent` and `command` and nothing else, accepted or refused, so
  the ledger entry for *"zone 1 (barn): width 500 m is outside 5–60 m"* did
  not carry the zone. **`PLAN` is the sharper one** because it has a field
  that looks like the missing one: `record["steps"]` is the steps it **did**,
  so a plan refused at step 2 of 3 named the problem and never the plan — a
  construction-layer field where an interpretation-layer one was owed.
  **THE DATA WAS NEVER LOST AND THE COMMIT DOES NOT CLAIM IT WAS**:
  `raw_command` holds the whole JSON answer for every command, checked before
  the claim was written (TRAPS 14), so this is a fault of SHAPE — a reader
  going by field met a farm that proposed nothing — and nothing in the
  repository reads a `proposed_` field except `proposed_metrics`. **Why no
  suite saw it**: `ledger_said_test` asks the right question of the right list
  and **its own header says what it does not ask** — *"This asserts that the
  record EXISTS"* — and `proposed_` appears in exactly one file under `tests/`
  before this commit, as a fixture. **TRAPS 6 for the fifth commit running,
  and this one is not one of the four axes**: 041's blind spot was the probe's
  VALUES, 042's the sweep's DIRECTION, 043's the input's SHAPE, 044's the
  LAYER, and this one is the **QUESTION** — existence asked where content was
  owed. **The fix is the class**: the `proposed_` fields were written out by
  hand in `DungeonModule` and `RacingModule` and in neither case in
  `WorldModule`, the base both extend, which is exactly why the third world
  had none. The reading is now `WorldModule.proposal_record()`, off `lists()`,
  so a world added later records its proposal without its author writing a
  line — **latent, there is no fourth world**. `DungeonModule.record_fields()`
  is deleted and the records are byte-identical; `RacingModule`'s survives for
  the one key it does not write (racing records carry no `world`).
  **A false code comment is now true**: `Readback.intent_of()` claimed "both
  readers are now this one" and there were three. 51 suites passed before and
  52 after, `--all` included; the new suite fails **8 times** against the
  pre-045 code. The prompt is byte-identical (15846 chars, sha256
  `c6c2b955...`), so `PROMPT_VERSION` did not move. **Not verified: no model
  sent any of this**, and `attempt` on a farm is latent because a farm cannot
  revise. See 045 below and TRAPS 39.
- Before 045: **044**, the task that file named as
  the next assistant task — *the same audit, carrying 043's question to the
  rules 043 did not ask*. The rule asked first was **TRAPS 20 and 30's**: *a
  value from the AI is converted through `Readback.as_number()`, never a bare
  `int()` or `float()`*. **That one holds.** Every bare conversion left in
  `scripts/` is either downstream of a validator that rewrote the value as a
  float — `SectionValidator` returns a `clean` array, so `TrackGeometry`'s
  float() calls never see a request — or reads Genesis's own bookkeeping. The
  prediction in this file was that the fourth rule would have the same shape
  as the first three, and **it does, but at the rule one door along**:
  **TRAPS 34's**, *a reference by position is a whole number and one that is
  not is refused with the range named*, put into `Readback.ordinal_index()`
  and carried by 040 to all five doors the prompt names. **The answer is
  "only where the fault was found" FOR THE FOURTH COMMIT RUNNING** — and the
  reason is again sharper than the count. **All five of 040's doors are
  validators or handlers.** Six READBACKS stand beside them saying the same
  reference back, and all six called `int()` by hand. **The one reading was
  unreachable through its RETURN TYPE**, not through its file: `ordinal_index()`
  gives a resolved index or −1, which is what a validator needs and what a
  readback must never have, because a readback says what was HEARD (TRAPS 8).
  Measured headless before anything changed: *"to send someone to room 2"* for
  `"room": 2.9`, *"room 0"* for 0.5 — a room no dungeon has — *"to make corner
  2 hard"* for 2.9, *"an opponent"* for `"count": 1.5`, *"with a key in the
  vault"* for `"in": 2.9`, *"between the 1 and the 2.9"* at SHUT, and *"one
  inside the other"* for a plan refused for its `"around"`. **Next to every
  one of those, in the same exchange, the refusal 040 and 041 built says the
  number exactly** — two sentences about one request disagreeing, and the one
  the player is invited to check is the wrong one. **Why no suite saw it**:
  `procedure_test` probes 1.5, 2.9 and 0.5 at all five doors and asserts each
  is refused with the range named — seven assertions a door, green since 040 —
  and **every one goes through `_resolve()`, which is the validator**. TRAPS 6
  for the fourth commit running and in a fourth costume: 041's blind spot was
  the probe's VALUES, 042's the sweep's DIRECTION, 043's the input's SHAPE,
  this one the **LAYER**. **A claim in a code comment had been false for three
  commits**: `_things_said()` resolved a thing's `"in"` under *"the readback
  resolves a name the same way the validator does"*, true when written and
  made false by 040 (TRAPS 14, as 043 found one). **Found in the same
  reading**: a room NUMBER at SHUT/OPEN went through `_place()` and came out
  dressed as a name (*"the 1"*); a corner below 1 was left out of
  `MODIFY_TRACK`'s sentence, so `"corner": 0.5` read back identically to a
  request naming no corner; and `around_of()` disagreed with `around_problem()`
  about 1.5, in the one function written because two readings of that field
  drifted once already — **not reachable**, the schema pass refuses first, and
  closed anyway. 50 suites passed before and 51 after, `--all` included; the
  new suite fails **63 times** against the pre-044 code. The prompt is
  byte-identical to 043's (15846 chars, sha256 `c6c2b955...`), so
  `PROMPT_VERSION` did not move and designs stay comparable. See 044 below and
  TRAPS 38.
- And before that: **043**, the task that file named as
  the next assistant task — *the same audit, at the rules 042 did not ask*,
  taking the one 042 said it would have taken next. The rule asked is
  **TRAPS 10 and 23's**: *a fact about a WORD lives in one function and
  every rendering reads it*, put into `Readback.is_label()` and read by
  `Readback.article()` (which writes **a**) and `NpcGoals._place()` (which
  writes **the**). The answer is **only where the fault was found, FOR THE
  THIRD COMMIT RUNNING** — and the reason is sharper than the count.
  `_place()` is a ROOM-naming function in `npc_goals.gd`, so **the definite
  article had no reader anything else could reach**, and ten renderings
  wrote it by hand. Measured headless before anything changed: *"to have
  the key 2 carried to the vault"*, *"The key 2 is in the vault."*, *"there
  is no door between the room 1 and the room 2"*, *"a lamp in the room 1"*,
  *"entered through a 12 m room 1"*, and two sentences inside
  `GameController`. **Six of the ten are in the one file whose own comment
  read "There is now no other way to name a room in this file"** — false
  when it was written, false of rooms, and false for twenty-one commits
  (TRAPS 14). **Why no suite saw it**: `log_022_test` has asserted this
  exact rule on a dungeon readback since 031 and every room it asks about
  has a width and depth of `null` — the one branch of `_room_said()` that
  calls `article()`, while the branch beside it, the one every measured room
  takes, wrote *"a"* by hand. TRAPS 6 at a correct assertion, as in 041 and
  042. **And the one function had the fault at its own edge**: `article()`
  chose between *a* and *an* **by the first letter**, and the thing that
  makes an article *an* is the **sound** — so *"a 8 m hall"*, *"a 11 m
  vault"* and, through `count_of()`, *"a 80 by 20 m barn"* were reachable in
  every dungeon and every farm readback Genesis has ever produced. **Found
  in the same line and not about names**: `SectionValidator._forbid` writes
  *"a"* twice by hand — *"'radius' is not a uphill setting (a uphill has
  length and grade)"* — at a type the validator accepts. 49 suites passed
  before and 50 after, `--all` included; the new suite fails **27 times**
  against the pre-043 code. The prompt is byte-identical (15846 chars,
  sha256 `c6c2b955...`), so `PROMPT_VERSION` did not move and designs are
  comparable across this commit. **Not fixed and said so**: a word beginning
  with a LETTER is still decided by that letter, so *"an hour"* and *"a
  unicorn"* come out wrong — that needs pronunciation, which Genesis does
  not have. See 043 below and TRAPS 37.
- And before that: **042**, the task that file named as the
  next assistant task — *the audit 041 began, continued through the rest of
  TRAPS's rules*. The rule asked is **TRAPS 27's**: *a count and the noun
  after it are one fact, read from `Readback.plural()` and never written out
  again*. The answer is **only where the fault was found, AND THE SWEEP THAT
  GUARDS IT CAN ONLY SEE HALF THE FAULT.** `container_door_test` does what
  TRAPS 27 asked and sweeps the OUTPUT, with the regex `\b1 [a-z]+s\b` —
  which is a count of ONE wearing a plural, and is blind by construction to a
  count of TWO wearing a SINGULAR. **That is the half the two itemising
  panels had**, and on a circuit it was unconditional: a closed circuit needs
  at least two straights and two corners, so **every circuit Genesis has ever
  built** read *"8  (4 straight, 4 corner, 0 hairpin, 0 chicane)"*. TRAPS 6 at
  a correct assertion, exactly as 041 found it one commit earlier. Nine
  sentences in six files were outside 034's sweep and seven were wrong,
  measured headless: a session of ONE request — the commonest session a
  first-time tester has — read *"1 minutes, 1 requests"*, *"1 seconds"*, *"1
  readbacks"* and *"the 1 that bear on it"*, plus *"1 saved worlds"* at
  `/worlds`, *"1 of 1 measurements match"* in `LoadCheck` and *"1
  straight(s)"* in the feasibility gate. **Found in the same line and not
  about plurals**: the SECTIONS panel named four of the ten types the
  validator accepts, so a circuit holding an `uphill` measured *"8  (2
  straights, 4 corners, 0 hairpins, 0 chicanes)"* — **a total of 8 over an
  itemisation of 6**, a measurement panel whose own arithmetic is false. **And
  the suite's own first draft walked into the fault it is about**: `contains()`
  is a substring test, so *"1 requests"* contains *"1 request"*, and five
  assertions passed against the pre-042 code they were written to catch. The
  one reading is now `Readback.agrees(count, one, many)` — *is this count one*
  — because the agreement is not only the noun's. 48 suites passed before and
  49 after, `--all` included; the new suite fails **24 times** against the
  pre-042 code. The prompt did not move, so `PROMPT_VERSION` is unchanged and
  designs are comparable across this commit. See 042 below and TRAPS 36.
- The commit before it: **041**, the question that file named as
  the next assistant task — *040's finding asked of every other place a FIX
  has already been written once*. Asked of TRAPS 34's own fifth rule — *"a
  number said back is said as the player wrote it"* — the answer is **only
  where the fault was found**. `Readback.number_said()` was written in 040 for
  the five reference doors; **thirteen doors in Genesis say a request's number
  back and 040 reached five.** The other eight rendered it by hand in three
  styles and **all three round**, so where a value sits just past a bound the
  rounding lands it ON the bound and the refusal names a value that satisfies
  the limit it is refusing: *"room 1: width is 40 m, and must be 4 to 40 m"*
  for a width of 40.4. Reachable at **all five validators**, measured
  headless. **And the one reading had the fault at its own edge**:
  `number_said()` ended `String.num(number, 2)`, so 1.504 came back `"1.50"`
  against a bound printed `"1.50"` — three of 040's own five doors say a
  number wrongly in the pre-041 code *after* 040 fixed them. The precision is
  now faithful and a BOUND is deliberately not said this way (a bound is a
  constant at its own precision, TRAPS 28). **Why no suite saw it**:
  `capability_test` has enumerated every bound in all five validators since
  028 and probes `limits.y * 10 + 7` — effectively whole numbers, which every
  rounding style renders faithfully, so a correct assertion was fed the one
  input that cannot make it fail (TRAPS 6, one step back from the assertion).
  47 suites passed before and 48 after, `--all` included; the new suite fails
  **146 times** against the pre-041 code. The prompt is byte-identical
  (15846 chars, sha256 `c6c2b955...`), so `PROMPT_VERSION` did not move and
  designs are comparable across this commit. New "Human decision needed" 11:
  a READBACK rounds a measurement to whole metres, which is measured, left
  out of the assertions and not fixed. See 041 below and TRAPS 35.
- The commit before it: **040**, the task that file named as
  the next assistant task — *a door for the five procedural claims 039
  measured by hand*, built from the registry and the prompt rather than from
  the quoted five. Two of the five were members of larger classes and each
  class had a fault. **A reference by POSITION is offered at five doors**
  (a dungeon's `doors` pairs, a thing's `in`, an `ORDER`'s `room`, a
  `SHUT`/`OPEN`'s `between`, a plan step's `around`); all five bound-check,
  so nothing can reach GDScript's `array[-1]`, but a number that is not a
  WHOLE number was taken by `int()` to the position below it **in silence at
  four of them**. The fifth, `around`, refused it and named the range — **036
  had written the correct rule four commits earlier and nothing carried it to
  its own class**, which is TRAPS 11 at a fix rather than at a fault. And
  **a refusal does not destroy what was there** is a rule Genesis follows
  everywhere except a PLAN: `_execute_plan` cleared the world before working
  its steps out, so a plan holding one unbuildable world took the standing
  world away and reported that it had built nothing (measured: a farm of 62
  children to 0). Fixed for that case; **still broken for a plan refused for
  OVERLAPPING**, which is the more reachable half and is "Human decision
  needed" 10. 46 suites passed before and 47 after, `--all` included; the new
  suite fails **38 times** against the pre-040 code and **0 times at
  `plan around`**, the control member. The prompt is byte-identical, so
  `PROMPT_VERSION` did not move and designs are comparable across this
  commit. See 040 below and TRAPS 34.
- Before that: **039**, the task that file named as
  the next assistant task — *the procedural sentences, the one kind of prompt
  claim with no door* — asked of the class rather than of the eight sentences
  quoted here (TRAPS 11). The sharpest sub-class is the one that can be
  settled by **doing the arithmetic**: a sentence stating a relation between
  numbers the model sends and a number Genesis computes. There are **six** in
  the assembled prompt and **five were right**. The sixth: *"Top speed is
  push divided by weight times footing"*, written in 010 and never read
  again, while `BootsTool.top_speed()` returns `push / (weight * footing)`.
  Read by the convention its own words follow the sentence disagrees for
  **every** legal spec — worst gap 25.2 m/s — and, which is the finding,
  it puts `footing` in the NUMERATOR, so it told the model that raising
  footing goes FASTER. Four lines above it the footing bullet says the
  opposite in numbers rendered from the same function, and **038 wrote that
  bullet without reading this line** — precisely what 013 did when it added
  `brake` and left the sentence 038 came back for. It costs in both
  directions, like 035's farm bound: `TOP_SPEED` is 2 to 12 m/s and a spec
  outside it is refused, so a model obeying the sentence proposes
  `push 600, weight 50, footing 0.40` believing it 4.80 m/s (Genesis: 30.00,
  refused) and declines `push 600, weight 140, footing 0.40` believing it
  1.71 m/s (Genesis: 10.71, legal). 45 suites passed before and 46 after,
  `--all` included; the new suite fails **2 times** against the pre-039
  prompt. The prompt moved, so `PROMPT_VERSION` is now
  `039-the-arithmetic-it-really-does-1` and **boots designs are not
  comparable across it**. See 039 below and TRAPS 33.
- The commit before it: **038**, the task that file named as
  the next assistant task — *the boots prompt tells the model two different
  things about the same player sentence* — asked of the class rather than of
  those two sentences. The prompt makes **three** claims of the shape
  *"someone who wants X wants FIELD changed and nothing else"*, one per tool
  with fields worth choosing between, and it is a kind of claim nothing in
  Genesis had ever checked: not a bound (035 holds those), not a refusal
  (030), not a capability (028), not a limitation (027), but an instruction
  that a named field is the one that DOES a named thing. One of the three was
  **false**, and the sharp part is why it survived: the sentence was written
  in 010 when `footing` was the only field that shortened a stop, 013 added
  `brake` and **measured that brake does the same job for nothing** —
  `behaviour_test`'s claim 5 has asserted exactly that, green, ever since —
  and the sentence was never read again. **For 33 commits this repository
  held a measurement and a prompt sentence that contradicted each other**,
  because a capability is asserted in the suite and a claim is made in the
  prompt and there was no door between them. Measured from ONE speed, which
  037's own reading did not do: from 4.48 m/s, `brake` at 1200 stops in
  0.59 m and `footing` at 1.50 stops in 1.09 m while costing more than half
  the walking pace — so the field the prompt named is both the dearer answer
  and the worse one. Beside it, `brake` was **absent from the boots JSON
  skeleton** the model copies, the only field in Genesis that `defaults()`
  declared and a skeleton omitted. 44 suites passed before and 45 after,
  `--all` included; the new suite fails **9 times** against the pre-038 code.
  The prompt moved, so `PROMPT_VERSION` is now
  `038-the-field-that-does-it-1` and **boots designs are not comparable
  across it**. See 038 below and TRAPS 32.
- The commit before it: **037**, the question that file named
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

**IT DID NOT RUN BETWEEN 2026-10-17 AND 2026-10-22.** 061 was pushed at
16:05 on the 17th and 062 at the time of writing on the 22nd — **five days
and roughly sixty firings with nothing in the history**. 062 cannot tell from
inside the repository whether the task was paused, failed to start, or ran and
found nothing worth committing without writing that down as it is told to; all
three are possible and the first is the owner's to know. Recorded here because
a session reading `git log` will otherwise read the gap as a decision
somebody made. Nothing was lost: 062 resumed from 061's "Next action" exactly
as the protocol intends.

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

**74** files in `tests/`, of which `replay` and `prompt_test` are tools rather
than suites, leaving **72 suites**, counted with `ls tests/*.gd` rather than
remembered, and since 024 every one of them runs — nothing is skipped as
broken. `--all` adds the two slow racing suites, which are counted in the 72
and are skipped without it.
**THESE TWO NUMBERS WERE STALE BY ONE WHEN 073 READ THEM**, and 073
re-counted rather than carrying them forward: they said 72 files and 70
suites, while `ls tests/*.gd` returned **73** and the 072 baseline run in this
container reported **71** suites. Which commit left them behind is not
recorded and is not guessed at here. A count in a document is TRAPS 24's
shape, and this paragraph is the one place in this file that invites you to
run the `ls` — so run it. **074 ran it: 74 files and 72 suites, which is
what the two numbers above now say.** They are right today and will be wrong
the day somebody adds a file without reading this paragraph; that is the
whole reason the paragraph tells you to count rather than to trust it.

**RUN THEM ONE AT A TIME.** Every copy of this project has the same
`config/name` in `project.godot`, and Godot derives `user://` from it — so
every copy shares one `user://track_log.jsonl` and one `user://worlds`. Two
runs at once, on one machine, read and write each other's ledger and saved
worlds, and suites fail for reasons that have nothing to do with the code.
055 took four answers off such a run before noticing. If a run is being used
as a measurement, clear `user://` before it, baseline included (TRAPS 50).

Last full run (076, Godot 4.7.1 on Linux, `4.7.1.stable.official.a13da4feb`,
headless, in a cloud container, every run sequential with `user://` cleared
first): **suites with something to look at: 0** on all **72**, with `--all`.
`ls tests/*.gd` returned **74** and the run reported **72**, re-counted rather
than carried forward. **THREE full runs, `user://` cleared before each, all
byte-identical** (md5 `dddf8006012399e50eb9470da9e29af6`): two on the final
tree, and a **THIRD on the clean pushed tree at `1c0df4f`**, taken because
076's doc edits landed after the second — exactly as 074a's and 075a's did —
so the md5 demonstrably covers what is on the remote. **The strip-and-diff was
re-run on that third output too and is byte-identical to the baseline**, md5
`69eb8489ca8e4586238a7a2ad7743a9e`.
Checked rather than reasoned about (TRAPS 4): the four `docs/` mentions in
`tests/` — `agreement_test`, `capability_test`, `formula_test` and
`retry_test` — are all prose inside comments, and **every `DirAccess.open` in
`tests/` targets `res://scripts` or `res://tests`** (grepped for `res://docs`
and `"docs/` as well), so no suite can read anything under `docs/` and the doc
edits could not have moved any suite's result.
The baseline in this container before anything was touched was the same on
**72** and was **byte-identical to the md5 075a recorded**
(`69eb8489ca8e4586238a7a2ad7743a9e`). **EVERY RESULT LINE MOVED**, because 076
added an assertion count to 55 of them — so the lists were not diffed raw.
They were compared the way the entry asked: the 55 new counts were **stripped**
from the after-run output and the result **diffed against the baseline**, which
came back **byte-identical** at that same md5. No suite's verdict moved and no
line was added or removed, so neither runner needed an edit: 076 changes the
body of 55 existing files and adds none. `run_tests.bat` was read rather than
assumed — it matches `failures=`/`bad=`/`VERDICT` as substrings and computes no
verdict of its own.
**This is the first comparable baseline for the result lines; 075's is not.**

The run before it (075, Godot 4.7.1 on Linux, `4.7.1.stable.official.a13da4feb`,
headless, in a cloud container, every run sequential with `user://` cleared
first): **suites with something to look at: 0** on all **72**, with `--all`.
`ls tests/*.gd` returned **74** and the run reported **72**, re-counted rather
than carried forward. The baseline in this container before anything was
touched was the same on **72** and was **byte-identical to the md5 074a
recorded** (`d13d97d014eeefea52f43e4076a4fb06`). The lists were **diffed** and
**exactly two lines moved**: `formula_test` `FORMULA failures=0` ->
`FORMULA 147 assertions, failures=0` and `source_scan_test` **24 -> 25
assertions**. No other suite's result line moved and no line was added or
removed, so neither runner needed an edit: 075 changes the body of two
existing files and adds none. **TWO full runs on the final tree, `user://`
cleared before each, byte-identical** (md5
`69eb8489ca8e4586238a7a2ad7743a9e`), and a **THIRD on the clean pushed tree at
`5cefad6`, BYTE-IDENTICAL to both** — taken because the doc edits landed after
the second, exactly as 074a's did, so the md5 above demonstrably covers what is
on the remote. Checked rather than reasoned about (TRAPS 4):
the four `docs/` mentions in `tests/` — `agreement_test`, `capability_test`,
`retry_test` and now `formula_test` — are all prose inside comments, and
**every `DirAccess.open` in `tests/` targets `res://scripts` or
`res://tests`**, so no suite can read anything under `docs/`.

**NOTE ON THE RESULT LINES — AS OF 076 EVERY SUITE CARRIES AN ASSERTION
COUNT.** **71 of the 72 print `<N> assertions, failures=<M>`**; `sweep_test`
prints a VERDICT by design and is the whole remainder. So a vanished assertion
now moves the run output itself, and a diff of the full PASS lists is no
longer the only thing that would catch it. **This reset every result line
once**, which is why the md5 recorded above for 076 is the first comparable
baseline and 075's is not.
**WHAT THIS PARAGRAPH SAID BEFORE, AND WHY IT IS RECORDED RATHER THAN
OVERWRITTEN.** It said *"56 of the 72 suites print no assertion count — 15
print one"* while also saying, two sentences later, that `formula_test` had
been given a count in 075. Both cannot be true. Measured off 075's own
recorded output: **55 printed none and 16 printed one.** 075's "Next action"
said *"the remaining 55"* and was right; this paragraph kept the pre-075 pair
and was the stale one. A count in a document, one commit old, in the one
paragraph here that tells you to run the `ls` rather than trust it — TRAPS 24,
and 076's own small finding about this file.

The run before it (074, measured the same way): **0 with something to look at**
on all **72**, with `--all`.
The baseline in this container before anything was touched was the same on
**72** and was **byte-identical to the md5 073 recorded**
(`0fdf976cb74056e853ae2a8f7b62fcb1`). The lists were **diffed** and the only
differences are **two assertion counts** — `prompt_numeral_test` 97 → 116 and
`refusal_reach_test` 99 → 105. **No other suite's result line moved**, and no
line was added or removed, so neither runner needed an edit: 074 changes the
body of two existing files and nothing about how they run. `ls tests/*.gd`
returned **74** and the run reported **72** suites, which is what the
paragraph above says and was re-run rather than carried forward.
**THREE full runs on the final tree, `user://` cleared before each, all
byte-identical** (md5 `d13d97d014eeefea52f43e4076a4fb06`). Three rather than
two because 074's doc edits landed after the second, and three suites mention
`docs/` — `agreement_test`, `capability_test` and `retry_test`. Checked rather
than reasoned about: all three hits are prose inside comments and **nothing in
`tests/` opens a path under `docs/`** (grepped for `res://docs`, `"docs/` and
`DirAccess.open`). The third run was taken on the **clean, pushed tree**
anyway, so the md5 above covers exactly what is on the remote.

The run before it (073, measured the same way): **0 with something to look at**
on all **72**, with `--all`. Its baseline was the same on
**71** and was **byte-identical to the md5 072 recorded**
(`f9b0d8cf50968a31a41d42023deab0ef`), so the record and the container agreed
before the change. The lists were **diffed**: the only difference is **one
added line**, `prompt_numeral_test`, 97 assertions. **No existing suite's
result line moved** — `source_scan_test`'s included, which is the one to watch,
because 073's file is a **tenth** member of the class that suite holds: it
reads `scripts/` source, so it defines `_code_of()` itself, byte-identical to
the other nine.
`prompt_numeral_test` needs no entry in either runner: `run_tests.sh`'s three
lists match on whole words and `run_tests.bat`'s `findstr` patterns match on
substrings, and **both were RUN** against the name rather than eyeballed
(TRAPS 4) — none matches. It steps no physics and takes under a second.

The run before it (072, measured the same way): **0 with something to look at**
on all **71**, with `--all`, byte-identical to the 071 baseline — which 072
said plainly was expected, since it added no suite and changed no verdict.

The run before that (067, Godot 4.7.1 on Linux, `4.7.1.stable.official.a13da4feb`,
headless, in a cloud container, every run sequential with `user://` cleared
first): **suites with something to look at: 0** on all **69**, with `--all`.
The baseline at 066, measured the same way in the same container with the same
binary before anything was touched, was the same on 68 suites, and the lists
were **diffed**: four assertion counts moved — `check_wiring` 188 → 190,
`handler_wiring` 47 → 49, `player_door` 67 → 69, `refusal_reach` 96 → 99 —
and one line was added, `source_scan_test` 24. **`controller_reach` stayed at
136**, which is the measurement saying that moving its trailing-comment skip
into the shared reader cost no site. Two full runs after the last edit,
**byte-identical** (md5 `9bb6bd51cf700054e643edd76a4d2780`).
`source_scan_test` needs no entry in either runner: `run_tests.sh`'s three
lists and `run_tests.bat`'s `findstr` patterns were **RUN** against the name
rather than eyeballed (TRAPS 4) and none matches, so it runs with no
`--fixed-fps`. It steps no physics and takes under a second.

The run before it (062, Godot 4.7.1 on Linux, `4.7.1.stable.official.a13da4feb`,
headless, in a cloud container with 2 cores, every run sequential with
`user://` cleared first): **suites with something to look at: 0** on all 66,
with `--all`. The baseline at 061, measured the same way in the same
container, was the same on 65 suites, and the lists were **diffed**: the only
difference is **one added line**, `view_frame_test`, 82 assertions. **No
existing suite's result line moved**, `player_door_test`'s included.
`view_frame_test` is new and needs no entry in either runner: it takes no
`--fixed-fps` and is not slow.
**AND IT SETS THE ROOT WINDOW TO `project.godot`'s VIEWPORT SIZE** —
1152 × 648, read from the setting — because a headless Godot gives the root
window 64 × 64 and a frustum depends on the aspect ratio. It asserts the
window took the size before it believes anything that rests on it. See
TRAPS 60.

The run before it (061, Godot 4.7.1 on Linux, `4.7.1.stable.official.a13da4feb`,
headless, in a cloud container with 2 cores, every run sequential with
`user://` cleared first): **suites with something to look at: 0** on all 65,
with `--all`. The baseline at 060, measured the same way in the same
container, was the same on 65 suites, and the lists were **diffed**: the only
difference is **one line**, `player_door_test`'s assertion count, 63 → 67.
**No file was added or removed, so neither runner needed an edit** — 061
changes the body of `_make_main()` in sixteen existing files and nothing
else about how they run.
**AND SEVENTEEN SUITES NOW LOAD `scenes/main.tscn`** rather than building a
stand-in for it: the sixteen with a `_make_main()` of their own, plus
`session_test`, which inherits `drive_test`'s. A broken main scene therefore
breaks seventeen suites and not none; measured, with `BuildButton` renamed,
**18 of 65 report it** (the seventeen plus `player_door_test`) against **1 of
65** before 061. If a run goes mysteriously and uniformly red, read
`scenes/main.tscn` before reading the suites.

The run before it (060, measured the same way):
**suites with something to look at: 0** on all 65, with `--all`. The
baseline at 059, measured the same way in the same container, was the same on
64 suites, and the lists were **diffed**: the only difference is **one added
line**, `player_door_test`'s. 060 adds one file and NEITHER RUNNER NEEDED AN
EDIT - `run_tests.sh`'s TIMED, SLOW and NOT_A_SUITE lists and
`run_tests.bat`'s `findstr` patterns were **RUN** against the name
`player_door_test` rather than eyeballed (TRAPS 4) and none of them matches,
so it runs with no `--fixed-fps`. It takes about 4 s, of which 3 s is the
RaceDirector's real countdown.

The run before it (059, Godot 4.7.1 on Linux —
`4.7.1.stable.official.a13da4feb` — headless, in a cloud container, every
run sequential with `user://` cleared first):
**suites with something to look at: 0** on all 64, with `--all`. The
baseline at 058, measured the same way in the same container, was the same
on 63 suites, and the lists were **diffed**: the only difference is **one
added line**, `record_id_test`'s. 059 adds one file and it is in neither
runner's fixed-rate list — it steps no physics — so neither runner needed an
edit; `run_tests.bat`'s `findstr` patterns were RUN against the name rather
than eyeballed.
**AND READ TRAPS 56 BEFORE TRUSTING ANY DIFF TAKEN BEFORE THIS COMMIT.**
Until 059, `TrackLog.next_id()` could mint the same id in two processes, so
a suite that looks its own record up by id could get another suite's —
`intent_door_test` failed 7 or 8 for that reason under four unrelated
treatments while this sweep was being measured. Every "the lists were
diffed and are identical" since 055 was taken with that coin flip in the
instrument. The fix removes it; the claims those commits make about their
own wire-outs still stand, because their other 62 lines were stable.

The run before it (057, Godot 4.7.1 on Linux —
`4.7.1.stable.official.a13da4feb` — headless, in a cloud container, every
run sequential with `user://` cleared first):
**suites with something to look at: 0** on all 62, with `--all`. The
baseline at 056, measured the same way in the same container, was the same,
and the lists were **diffed: they are identical, line for line.** Said
plainly because it reads like a stronger claim than it is — `proxy_test`'s
result line is `PROXY TEST failures=0` and carries **no assertion count**,
unlike `check_wiring_test`'s, so the diff cannot show 057's new assertions
at all. They were counted by running that suite alone and counting the PASS
lines: **11 before, 24 after**.
057 changes behaviour in exactly one place — the web build's key guard — and
no harness here can run a web build, so what stands in place of a "failures
against the pre-057 code" count is **eight deliberate faults, made one at a
time and the suite re-run against each**: the pre-057 logic restored in
`key_missing_for` (1 failure, and it is the row that is the finding), the
guard re-inlined in `_send` (1), `key_refused_message` losing its web branch
(1), `KEY_ENV_NAME` drifted off the function's own name (1), the key guard
removed from `_send` entirely (2, caught through the real `interpret()`
door), `is_available()` inverted so it disagrees with the function it calls
(1), the desktop sentence no longer naming `api_key.txt` (1), and the guard
emitting its refusal and then posting anyway (1). **It is in neither
runner's fixed-rate list**: it steps no physics, and its name was already in
`run_tests.bat`'s patterns because the file is not new. No file was added,
so neither runner needed an edit.

Last full run (056, Godot 4.7.1 on Linux —
`4.7.1.stable.official.a13da4feb` — headless, in a cloud container, every
run sequential with `user://` cleared first):
**suites with something to look at: 0** on all 62, with `--all`. The
baseline at 055, measured the same way in the same container, was the same
on 62 suites, and the lists were **diffed**: the only difference is
`check_wiring_test`'s own line, **179 assertions to 188**. 056 adds no file,
so neither runner needed an edit, and `run_tests.bat`'s `findstr` patterns
were RUN against the name again rather than assumed unchanged.
056's nine new assertions are a fixture in `check_wiring_test`, and what
stands in place of a "failures against the pre-056 code" count — it changes
no behaviour — is **ten deliberate faults, made one at a time and the suite
re-run against each**: the `revision_requested` connect wired out (7
failures), `_may_revise()` always false (8), the handler never entering the
revising state (1), the closure distance read from the proposal (1), the
second attempt numbered 1 (1), `revision_pending` dropped from the record
(1), the feedback dropped (1), `describe_revision()`'s marker dropped (1),
`CONNECTED_056` removed from `VERDICTS` (1), and racing's
`correction_feedback()` returning empty (8). It passes with
`--fixed-fps 120`, with `--fixed-fps 30` and without any (TRAPS 4).

The run before it (055, Godot 4.7.1 on Linux —
`4.7.1.stable.official.a13da4feb` — headless, in a cloud container, every
run sequential with `user://` cleared first):
**suites with something to look at: 0** on all 62, with `--all`. The
baseline at 054, measured the same way in the same container, was the same
on 61 suites, and the lists were **diffed**: the only difference is
`check_wiring_test`.
055's new suite is `check_wiring_test` (**179 assertions**). It changes no
behaviour, so what stands in place of a "failures against the pre-055 code"
count is **thirteen deliberate faults, made one at a time and the suite
re-run against each**: the `LoadCheck` call wired out (3 failures),
`LoadCheck` made to always say `RESTORED` (2), the `RefusalCheck` call wired
out (1), `RefusalCheck` made to quarrel with everything (1), the controller's
solve refusal wired out (1), the tool readback's validated branch switched
off (3), the tool readback made to fall back to the defaults (6), the farm's
check made public (3), a new verdict-returning function added to a script
with no row (1), a row naming a function that is gone (1), `CarTool.validate`
renamed (3), the farm given a `pre_check` (2), and the farm's `solve` renamed
(3). **It is in neither runner's fixed-rate list**: it steps no physics and
passes with `--fixed-fps 120`, with `--fixed-fps 30` and without any
(TRAPS 4), and its name matches none of `run_tests.bat`'s findstr patterns —
the patterns were RUN against the name, not eyeballed. README said 61 suites
and there are 62, counted with `ls`.

The run before it (054, Godot 4.7.1 on Linux —
`4.7.1.stable.official.a13da4feb` — headless, in a cloud container):
**suites with something to look at: 0** on all 61, with `--all`. The
baseline at 053, measured the same way in the same container, was the same
on 60 suites, and the lists were **diffed**: the only difference is
`controller_reach_test`.
054's new suite is `controller_reach_test` (**136 assertions**). It changes
no behaviour either, so what stands in place of a "failures against the
pre-054 code" count is **sixteen deliberate breakages, made one at a time
and the suite re-run against each**: a twelfth whitelisted command with no
case in `execute()` (2 failures), the `NO_HANDLER` branch wired out (3), a
node put into `TrackBuilder.corner_nodes` (1), **each of the five guards
wired out of the step that calls it** — `NO_HANDLER` (3),
`SPAWN_OPPONENTS`' SCHEMA (2) and its `NOTHING_BUILT` (3), `ORDER`'s
no-module (2) and its thing-gone (2) — the `FAILED_AI` row wired out (3),
`FAILED_PARSE` renamed in the source (7), a branch ADDED to a category that
already had rows (1), the starter circuit taken away (2), and five of the
reachable branches wired out one at a time (1 to 2 failures each). **It is in the
fixed-rate list in BOTH runners**, because it steps physics to carry a
thing: added to `TIMED` in `run_tests.sh` and to the `findstr` line in
`run_tests.bat`, where none of the twelve existing patterns matched the new
name — RUN against it, not eyeballed. It passes with `--fixed-fps 120` and
without (TRAPS 4); it is listed anyway, because what it measures should not
depend on the frame rate it got. README said 60 suites and there are 61,
counted with `ls`.

The run before it (053, Godot 4.7.1 on Linux —
`4.7.1.stable.official.a13da4feb` — headless, in a cloud container):
**suites with something to look at: 0** on all 60, with `--all`. The
baseline at 052, measured the same way in the same container, was the same
on 59 suites, and the lists were **diffed**: the only difference is
`refusal_reach_test`.
053's new suite is `refusal_reach_test` (**93 assertions**). It has no
"failures against the pre-053 code" count, and that is not an omission:
053 changes no behaviour, so there is no fault for it to catch. What stands
in its place is **thirteen deliberate breakages, made one at a time and the
suite re-run against each** — `MAX_EXTENT` 1400→900 (2 failures), `MAX_RING`
4→1 (3), `MIN_ZONES` 1→0 (3), `GAP` 6→0.5 (4), `FAILED_SEPARATION` renamed
in the source (3), and each of the seven guards wired OUT of the step that
calls it (1 each for six of them). **The fourteenth it does not catch** and
reports instead: the farm's lane guard wired out, where all 60 suites pass.
Run with `--fixed-fps 60` and without; passes either way (TRAPS 4).
`run_tests.bat` needed no edit: all sixteen of its `findstr` patterns were
RUN against the name and none matches. README said 59 suites and there are
60, counted with `ls`.

The run before it (052, Godot 4.7.1 on Linux
— `4.7.1.stable.official.a13da4feb` — headless, in a cloud container):
**suites with something to look at: 0** on all 59, with `--all`, so
`drive_test`, `session_test`, 048's `outgoing_world_test`, 049's
`panel_geometry_test`, 050's `asked_test`, 051's `panel_refused_test` and
052's `layout_key_test` all ran and all passed. The baseline at 051, measured
the same way in the same container minutes earlier, was the same on 58
suites, and the suite lists were **diffed** rather than eyeballed: the only
difference is `layout_key_test`.
052's new suite is `layout_key_test` (**64 assertions**; **13 failures**
against the pre-052 `FarmModule`, measured by checking out the committed
module under the new suite and running it — two of them the reader sweep
naming `lane_width` as read by nothing, eleven the lane threshold. It PARSES
against the pre-052 code, because it adds no constant to the module it tests
and calls no function that did not already exist). Run with `--fixed-fps 60`
and without; passes either way (TRAPS 4). `run_tests.bat` needed no edit: all
sixteen of its `findstr` patterns were RUN against the name and none matches.
README said 58 suites and there are 59, counted with `ls`.
051's new suite is `panel_refused_test` (**90 assertions**; **11 failures**
against the old decisions, measured by restoring the three pre-051 readings
inside the new function and running the suite against them — which measures
the FAULT and not the move. It does NOT parse against the pre-051 code
entire, because `WorldRegistry.panel_lines()` and `panel_built()` do not
exist there and the decisions it is about were inline in a UI callback;
recorded that way rather than stubbed, and the restored-readings measurement
is what stands in for a pre-code run);
050's new suite is `asked_test` (**4 failures** against the pre-050 code,
measured by stashing the two script changes and running it against the
committed ones: three true refusals of a question flagged as understating
Genesis, and the `no_command_asks` marks absent. It parses against the
pre-050 code, because it adds no constant and calls no new function);
049's new suite is `panel_geometry_test` (**119 assertions**; 2 failures
against the pre-049 gate, with the rest of 049 in place, and it does NOT
parse against the pre-049 code entire, because `FarmModule.GATE_WIDTH` and
`TrackGeometry.CURVED_TYPES` do not exist there — recorded that way rather
than stubbed);
048's is `outgoing_world_test`, which passes here and whose failure count
against the pre-048 code was not measured by the 049 session — see
`git log 5d36bfb` for what that commit measured;
047's is `panel_built_test` (7 failures and two thrown
`SCRIPT ERROR`s against the pre-047 readings, with the 047 scaffolding in
place; it does not parse against the pre-047 code at all, because
`DungeonModule.loop_count()` does not exist there);
046's is `built_count_test` (30 assertions; 4 failures against the
pre-046 sentences, and it does not parse against the pre-046 code at all,
because the base functions it reads do not exist there);
045's is `record_proposal_test` (8 failures against the pre-045 code);
044's is `said_position_test` (63 failures against the pre-044
code); 043's is `said_article_test` (27 failures against the pre-043 code);
042's is `counted_said_test` (24 failures against the pre-042 code,
61 assertions); 041's is `said_number_test` (146 failures against the pre-041
code, 312 assertions); 040's is `procedure_test` (38 failures against the pre-040 code);
039's is `formula_test` (2 failures against the pre-039 prompt);
038's is `claim_field_test` (9 failures against the pre-038 code);
037's is `intent_door_test` (39 failures against the pre-037 code); 036's is
`command_schema_test` (28 failures against the pre-036 code); 035's is
`prompt_bounds_test` (4 failures against the pre-035 prompt); 034's is
`container_door_test` (30 failures against the pre-034 sentences). Not run on
the owner's Windows machine. `run_tests.bat` needed no edit for any of the
nine: no name matches any of its `findstr` patterns — `prompt_bounds_test`
does not contain the literal `prompt_test`, `intent_door_test` contains none
of the physics names, and `claim_field_test`, `formula_test` and
`procedure_test` match nothing at all, and `said_number_test` contains none of
them either, and `counted_said_test` contains none of them (not `ledger`, not
`session`, not `drive`, not `physics`), and `said_article_test` contains none
of them either, and `said_position_test` contains none of them (not
`order_test`, not `physics`, not `session`) — so all eleven run there without
`--fixed-fps`, which is what they get here too, and `command_schema_test`,
`intent_door_test`, `claim_field_test`, `formula_test`, `procedure_test`,
`said_number_test`, `counted_said_test`, `said_article_test` and
`said_position_test` and `built_count_test` were each run
both with it and
without and pass either way — checked rather than assumed (TRAPS 4).
`panel_built_test` matches none of the `.bat`'s `findstr` patterns either —
not `ledger`, not `session`, not `drive`, not `physics`, not `walker`, not
`order_test`, not `explore` — checked against the file, so it runs there
without `--fixed-fps`, which is what it got here, and it was run both with
`--fixed-fps 60` and without and passes either way. `asked_test` matches none of the `.bat`'s sixteen patterns either —
checked by running every one of them against the name rather than by reading
the list — so it runs there without `--fixed-fps` too, and it was run both
with `--fixed-fps 60` and without and passes either way (TRAPS 4).
`panel_geometry_test` matches
none of them either — checked by running every one of the `.bat`'s sixteen
patterns against the name rather than by reading the list — so it runs there
without `--fixed-fps` too, and it was run both with `--fixed-fps 60` and
without and passes either way (TRAPS 4). `panel_refused_test` matches none of
them either — checked the same way, by running every one of the `.bat`'s
sixteen patterns against the name rather than by reading the list — so it
runs there without `--fixed-fps` too, and it was run both with
`--fixed-fps 60` and without and passes either way (TRAPS 4).
`run_tests.bat` needed no edit. `physics_test` gained 038's car measurement and is already
on both the Linux `TIMED` list and the `.bat`'s `physics` pattern, so it
keeps `--fixed-fps` on both.

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
- **A clearance check compares against the dimension it is about, named.**
  052. Genesis has three — the circuit's `SeparationCheck`, whose threshold
  `MIN_SEPARATION` **is** `ROAD_WIDTH + SAFETY_MARGIN`; the dungeon's
  `walkable()`, which clears a body `BODY` metres across and reports that
  width; and the farm's `_check_reachable()`, which compared against a bare
  `0.5` where a lane is 6 m, with the lane width sitting unread in the layout
  it was handed. A threshold and the thing it is a threshold for are one
  number in one place, and where that number is in the layout it is read from
  the layout. `tests/layout_key_test.gd` asserts all three.
- **A key in a layout is read by something, or it is not written.** 052. A
  layout is an INPUT to the builder and not a record: nothing serialises one,
  so a key no reader can tell the difference about is dead weight rather than
  documentation — and it cannot be wrong, which is why nobody notices when
  what it says stops being true. `tests/layout_key_test.gd` perturbs every
  key of every world's solved layout and asks whether anything the module
  does with the layout changes; a world with no fixture and a key with no
  declared perturbation both fail rather than being skipped.
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
- **A count in a sentence about a built world is read off the TREE, and a
  count read off a tree does not count what is leaving it.** 032 established
  the first half for functions that place nothing (TRAPS 24) and 046 asked it
  of the three worlds that build: all three read their counts from the
  request or the solved layout, and the one HANDOVER had spot-checked as
  "a count of pieces placed" was a count of **loop iterations**. The reading
  is `WorldModule.mark_piece()` at the point a piece is placed and
  `WorldModule.placed_pieces()` over the tree, on the base, so a world added
  later that forgets reports 0 and fails rather than being quietly right. The
  second half is not caution: the controller `queue_free()`s the old world and
  builds the new one on the next line, so **both are in the tree for part of a
  frame** — measured, four marked nodes for a two-room dungeon — and a count
  that ignored `is_queued_for_deletion()` would have been a false line
  introduced by the fix for false lines. The measurement layer keeps its own
  count (`measure(layout)`, which is what the panel states) and
  `tests/built_count_test.gd` fails if the two ever part without a sentence
  moving with them. **And a suite that calls a sentence has not called the
  thing the sentence is about**: `.summary(` was in three of 52 suites and
  none of them had ever built a world. See TRAPS 40.
- **A fact about a word lives in one function, at both ends of the noun —
  and the function has to be reachable from everywhere the fact holds.**
  034, widened in 043. TRAPS 10 and 23 established this for the article in
  front of a name and put it in `Readback.is_label()`; 043 found that the
  DEFINITE article's only reader was `NpcGoals._place()`, a room-naming
  function in a dungeon file, so nine sentences elsewhere wrote *"the"* by
  hand — *"The key 2 is in the vault"*, *"there is no door between the room
  1 and the room 2"*, *"a lamp in the room 1"*. `Readback.the()` is the
  definite article now and `_place()` is a reader of it, so a room, a thing
  and a world are all named the same way. The same commit found that
  `article()` chose between *a* and *an* **by the first letter** when the
  thing that decides it is the **sound**: *"a 8 m hall"*, *"a 11 m vault"*.
  The number half is decided by arithmetic in `Readback._takes_an()`; the
  letter half is unfixed and is a stated limitation rather than a silence.
  `tests/said_article_test.gd` asserts both directions — a numbered name
  loses the article AND an ordinary one keeps it. See TRAPS 37.
- **A fact about a word lives in one function, at both ends of the noun.**
  034. TRAPS 10 and 23 established this for the article in front of a name
  and put it in `Readback.is_label()`. The plural on the end was still
  written by hand in six sentences, and three of them were wrong at a count
  of one — `"2 rooms need at least 1 doors"`, `"this dungeon has 1 rooms"`,
  `"deepest room 1 doors in"`. `Readback.plural()` is the digit form and
  `count_of()` the word form, and `container_door_test` sweeps every
  sentence the suite produced for a count of one followed by a plural,
  rather than quoting any of them. See TRAPS 27.
- **A scan over this project's own source reads the text its question is
  about.** 066 and 067. A question about what the code **does** is answered
  from the code, comments stripped; a question about what is **mentioned**
  anywhere reads the raw file, and which one a scan is asking is decided by
  the direction of its assertion. 066 found a presence check a comment could
  satisfy and fixed one function; 067 found three more in the nine files that
  read source, each flipped from FAIL to PASS by one comment line, and found
  that the blunter rule — *"scan code, not comments"* — would have narrowed
  two checks that are wide on purpose. One reader, `_code_of()`, in every file
  that scans source; `tests/source_scan_test.gd` holds the class, at file
  granularity and saying so. See TRAPS 63 and 64.
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
- **NOTHING HAS EVER BEEN RENDERED IN THIS HARNESS, AND WHAT IS ONLY TRUE ON A
  SCREEN IS MEASURED IN PART.** 062 is the first commit to assert anything
  about the view — the **camera's place and angle** — and 063 the first to read
  the **light and the environment**, which is where it found a sun that had
  pointed along the ground since the project's first commit. Of 061's six
  visual differences the **light** and the **environment** got a reader there,
  as the camera's place and angle had since 062, and **065 added the last two
  — the command panel's anchors and the scene's strings — so ALL SIX NOW HAVE
  A READER.** (The clause that stood here until 065 said those two *"still
  have none"*, which was true when it was written and is the shape of TRAPS 14;
  it is corrected in place rather than left to be read as current.) (061's own
  list is counted two ways in two places — 060 said sixteen fixtures where
  there were seventeen, and the six are named as four things in 062's notes —
  so what is claimed here is the names and not an arithmetic.)
  **AND "ALL SIX ARE READ" IS A STATEMENT ABOUT COVERAGE, NOT ABOUT
  CORRECTNESS ON A SCREEN.** Every one of those readers measures a transform,
  a rect, a dot product or a property. **Nothing in this container has ever
  drawn a pixel**, so "the visual layer is tested" would be false and is not
  claimed (TRAPS 15). What 065 added is 43 assertions about rects and strings
  and **no** evidence that any of it is legible.
  **AND WHAT IS ASSERTED ABOUT THE LIGHT IS NOT THAT ANYTHING IS LIT.** No
  renderer exists in this container. `scene_light_test` asserts that the sun
  can reach a horizontal surface at all — one dot product — and that the
  scene's sky and ambient source are present and switched on; whether the
  result is bright enough to see a dungeon floor by is a renderer's answer and
  nobody has asked it. Related and narrower: whether the panels cover the
  world is not asserted either — the four `FRAME_*` constants in `game_controller.gd`
  are held to be applied consistently, never to be the right numbers, because
  a `CanvasLayer`'s `Control`s are laid out but never drawn headless. That one
  is a judgement the owner can make in a second in the editor, and is the
  "Next action" note under 062.
- **AND THE LIVE SITE HAS NOT BEEN UPDATED SINCE 14 OCTOBER. The `web build`
  workflow has FAILED ON EVERY PUSH SINCE RUN 28, which is 46 consecutive
  failures**, and nothing in these documents said so until 064 went looking.
  Read off the GitHub Actions API rather than remembered:

  | | |
  |---|---|
  | last successful run | **27**, commit `71b065f` (020), 2026-10-14 06:26 |
  | first failure | **28**, *"Deploy with the Netlify CLI, to one URL"*, 06:30 |
  | failures since | **46**, every push, 044 through 063 among them |

  **The export is not what fails.** On 063's own run (73) the steps *"Fetch
  Godot and its web export template"* and *"Import, then export"* both
  **succeeded**, in 9 seconds — so the web export of the current code,
  `scenes/main.tscn` fix included, builds fine. The step that fails is
  *"Publish to Netlify"*, and the log says why in one line: `NETLIFY_AUTH_TOKEN`
  and `NETLIFY_SITE_ID` are **both empty in the job environment**, so the
  Netlify CLI falls back to an **interactive login**, prints an authorize URL
  to a log nobody is reading, waits five and a half minutes and exits 1.
  **So every push for eight days has spent five minutes waiting for a human to
  click a link in a CI log.** Setting those two secrets is the owner's and only
  the owner's — see the note under 020 and "Human decision needed" 19. Until
  then **what a visitor sees is commit `71b065f`**, which predates everything
  from 021 onward.
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
- **A green suite had never asked whether a position in a list is a WHOLE
  number**, nor whether a refused PLAN leaves the world alone. Found and
  fixed in 040: a fractional room reference was truncated to the room below
  it in silence at four of the five doors the prompt offers a position at —
  while the fifth, `around`, had refused it and named the range since 036, so
  the repository held the right rule and applied it to one member of its own
  class. Beside it, `_execute_plan` cleared the world before working its
  steps out, so a plan holding one unbuildable world destroyed the standing
  world and then reported that it had built nothing. 46 suites passed before
  and 47 after. Neither fault was found by the owner: both came of asking a
  claim's question of the whole class rather than of the five sentences
  HANDOVER had quoted. See 040 below and TRAPS 34.

  **What that says about the method:** 029 asked one question of every file,
  030 every way in to one check, 031 what the sentence must say, 037 the door
  rather than the field. This one asked a different axis again — **where has
  this project already been RIGHT once?** A rule that exists in a function and
  is called from one place is cheaper to find than a fault, and it is the same
  fault waiting in every place that does not call it. That question is the
  next assistant task.

- **A green suite had never asked whether the one function that owns a rule
  can be REACHED from everywhere the rule holds**, nor whether `article()`'s
  own choice between *a* and *an* was right. Found and fixed in 043: the
  definite article's only reader was `NpcGoals._place()`, a static
  room-naming function in `npc_goals.gd`, so ten renderings wrote *"the"*
  by hand — six of them in that same file, under a comment claiming there
  was no other way to name a room in it. 49 suites passed before and 50
  after. See 043 below and TRAPS 37.

  **What that says about the method, and it is the third time:** 041 found a
  correct assertion fed the one input that could not make it fail; 042 found
  a correct sweep whose regex could not match half its class; 043 found a
  correct assertion that has only ever been given rooms with a `null` size —
  the one branch of `_room_said()` that was right. **Three commits running,
  the blind spot was in the CHECK and not in the code**, and none of the
  three was found by reading the code under test. The question that found
  all three is *what can this check not see?*

- **A green suite had never asked what a CLEARANCE CHECK COMPARES AGAINST**,
  only whether the thing being checked came out right. Found and fixed in
  052: `FarmModule._check_reachable()` — the check behind the module's claim
  that a farm a tractor cannot get round is refused — tested each edge
  against a bare **0.5 m** where a lane is **6 m**, and the number it should
  have read was a layout key nothing in the repository read at all. 58 suites
  passed before and 59 after. Measured over 468 legal farms, **the failure
  branch is not reachable from any request a player can send**, so nothing a
  player has ever built changes; what was wrong is that the guard did not
  guard the thing it names.

  **What that says about the method, and it is the fifth variation.** 029
  asked one question of every file, 030 every way IN to one check, 031 what
  the sentence must SAY, 037 the door rather than the field, 040 where the
  project had already been RIGHT once. This one asked **what a number in a
  check is a number OF** — and 040's question answered it: two of the three
  clearance checks in Genesis already read the dimension they are about
  (`MIN_SEPARATION` **is** `ROAD_WIDTH + SAFETY_MARGIN`; the dungeon clears
  `BODY`), so the rule existed and one member did not obey it. **And the
  suite written to catch it passed against the code it was written to catch**
  — its signature included a generated node name and an instance id, so every
  comparison was unequal and every assertion vacuous. That is the fourth
  commit running with the blind spot in the CHECK (041, 042, 043, 052), and
  the only thing that found it was running the new suite against the old
  code and reading the output.

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

- **A green suite had never LOADED THE SCENE THE GAME RUNS.** Found in 060:
  no file in `tests/` or `scripts/` mentioned a `.tscn` at all, so
  `scenes/main.tscn` was reached only by `project.godot`'s `run/main_scene`
  and only by the game. Sixteen suites stand `main.gd` up by hand-building a
  tree and **naming each node what `main.gd`'s `@onready` lines ask for** —
  the fixture supplies the names it then proves are there. Six node paths the
  scripts resolve against that scene had never been checked against it.
  Measured: rename `BuildButton` in the scene and `main.gd:100` throws on a
  null, the game dead at launch, while all 64 suites stayed green. 64 suites
  passed before and 65 after. See 060 below and TRAPS 57.

  **What that says about the method, and it is a new axis.** 029 asked one
  question of every file, 030 every way IN to one check, 031 what the
  sentence must say, 037 the door rather than the field, 040 where the
  project had already been right once, 043 what a check cannot see. This one
  asked **what the fixture supplies**. A test double is an assumption written
  down; where it stands in for something the repository actually contains,
  the cheap measurement is to use the real thing instead and see what moves.

  **061 FINISHED IT, AND THE ANSWER TO "WHAT MOVES" IS: NO VERDICT, ONE
  NUMBER.** The stand-in is retired — all seventeen suites that stand
  `main.gd` up now load the scene, resolved through
  `application/run/main_scene`. Twelve differences were enumerated by walking
  both trees in one process rather than by reading either. 65 suites passed
  before and 65 after, lists **diffed**, the only change being
  `player_door_test`'s assertion count: **no suite's answer rested on the
  stand-in**, which is the strong form of what 060 could only say about the
  collision. What did move is a number `drive_test` prints: on the banked
  square an opponent that came off the road **rested on the stand-in's floor
  (21 recoveries) and falls through the world against the game's own scene
  (25)**. Four runs, two a side, each identical to its repeat.

  **And the lesson 061 adds is about the CHECK and not the fixture, which
  makes it the fifth commit of that kind (041, 042, 043, 052, 061).** 060
  wrote two enumerations to keep two sentences honest. 061 falsified both
  sentences; one enumeration failed and one **would have gone on passing**,
  because it searched for the single idiom its author had in mind (`.tscn`
  in a file) and the thing it was guarding happened through another
  (`ProjectSettings`). See TRAPS 59. **Six of the twelve differences are
  visual and nothing here can see any of them**, which is 061's "Next
  action".

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

**070: that transcript is left exactly as 033 measured it, and the verb in it
is wrong.** *"0 of them changes"* is what Genesis said at the time and until
070; the line now reads *"0 of them change"*, because the verb was decided by
hand in `session_report.gd:242` and was only right at a count of one. The
transcript is a record of output and is not corrected here — see the 070
entry in the starting state and TRAPS 67.

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

## 038 — the field the prompt names is the field that does it

**Objective.** The task this file named as the next assistant task: *the
boots prompt tells the model two different things about the same player
sentence*, asked of the class rather than of those two sentences, since
*"every 'someone who wants X wants FIELD changed' sentence in the prompt
names a field, and whether that field is the one that does X is a
measurement"*.

**Starting state.** Branch `prototype-002a`, commit 037. 44 suites, 0 with
something to look at, `--all` included — measured before anything was
changed, not remembered.

### The class, enumerated rather than listed

The assembled prompt makes **three** claims of this shape, found by reading
it with a regular expression rather than by hand:

```
"a car that stops better"            -> braking  changed      car
"stop on a sixpence"                 -> brake    raised       boots
"boots that stop on a sixpence"      -> footing  raised       boots   FALSE
```

One per tool with fields worth choosing between; `look` has none, which is
right, because nothing it carries changes what the player can do.

**This is a kind of claim nothing in Genesis had ever checked.** 027 and 028
read every limitation and capability against the code, 030 made every refusal
name its limits, 035 made every bound read from its constant, 037 asked
whether every field the prompt offers is read where it is sent. A sentence
saying *which field does the thing* is none of those: it is the only claim in
the prompt that tells the model what to **do** rather than what is allowed.

### Why the false one survived, which is the finding

The `footing` sentence was written in **010**, and it was **true then**:
`footing` was the only field that shortened a stop. **013** added `brake`,
measured it, and wrote `behaviour_test`'s claim 5 — *"stopping sharply no
longer costs top speed"* — which asserts in so many words that `brake` does
that job and `footing` charges for it. The sentence was never read again.

So for **33 commits** this repository held a green measurement and a prompt
sentence that contradicted each other, and nothing caught it, **because a
capability is asserted in the suite and a claim is made in the prompt and
there was no door between them**. 035 built that door for bounds — prompt ⇔
declaration ⇔ validator. This is the same door one category along.

### Measured from one speed, which is the part 037 got wrong

With `BootsTool.top_speed()` and `BootsTool.stopping_distance()`, every stop
from the **same** 4.48 m/s:

```
ordinary                 top 4.48 m/s   stops in 1.45 m
brake raised to 1200     top 4.48 m/s   stops in 0.59 m
footing raised to 1.50   top 2.00 m/s   stops in 1.09 m
```

The field the prompt named is **both the dearer answer and the worse one**:
it costs more than half the walking pace and still stops nearly twice as far.
037's table read each spec's stop *from its own top speed* — 0.29 m for
footing against 0.59 m for brake — which makes footing look sharper and is
not a comparison, because footing lowers the speed it is then measured from.
**A stop is only comparable with another stop from the same speed.**

### And the field the model could not send

Swept across `ToolRegistry.tools()` rather than read at boots: `brake` was
the **only** field in Genesis that `defaults()` declared and a prompt
skeleton omitted. It was described in the bullets and absent from the JSON
the model copies, so a model doing what the skeleton told it could not send
the field the bullet told it to raise. Asked of the worlds too: every
declared list is in its own skeleton, so the class has exactly one member.

### What changed

- **The skeleton carries `brake`.** One field, and the sweep above is why it
  is one and not six.
- **The `footing` bullet names what it costs**: *"It costs top speed as well:
  at 1.50 an ordinary body walks at 2.00 m/s rather than 4.48, so raise it
  only when the player asked to move more deliberately."* The readback has
  said this to the player since 011; the model was never told.
- **The `brake` bullet owns the stopping phrase and states the comparison**:
  *"from 4.48 m/s, brake at 1200 stops in 0.59 m where footing at 1.50 stops
  in 1.09 m"*.
- **The `Change only what the player asked about` line names `turning`**, for
  *"boots that turn on the spot"*, so no player phrase is claimed twice.
  Measured: `turning` changes neither reading.
- **Every number in those sentences is RENDERED from `top_speed()` and
  `stopping_distance()`**, never typed. TRAPS 28's rule — a bound stated to
  the model is read from the code, not remembered — applied to a consequence,
  since a sentence about what a field costs is as much a claim as a sentence
  about what it may be.
- **The comment above `BootsTool.readback()` says WHEN it was right.** It
  said *"became footing 1.2, which is right"*, written in 011 and left
  standing through the commit that made it wrong; a reader following it would
  have put the fault back (TRAPS 22).
- `PROMPT_VERSION` is `038-the-field-that-does-it-1` and
  `PROMPT_FINGERPRINT` is the sha256 of the new 15792-character prompt.

### Evidence

**Godot 4.7.1 (`4.7.1.stable.official.a13da4feb`) headless, Linux, in a cloud
container.** Baseline 44 suites, 0 with something to look at, `--all`
included. After: **45 suites, 0 without `--all` and 0 with it**, `drive_test`
and `session_test` included.

`claim_field_test` **fails 9 times against the pre-038 code**, measured the
way 035, 036 and 037 measured their own — the two changed scripts reverted to
037 with the suite left in place — and each failure names a different half of
the fault:

```
1  'brake' is a field and the skeleton offers it
2  "stop on a sixpence" and "boots that stop on a sixpence" name the same field
   (both directions, because the check is symmetric)
1  "stop on a sixpence": 'brake' is in the boots skeleton
1  "boots that stop on a sixpence" promises nothing else, and 'footing' at 1.5
   changes 2 of the 2 things boots measure (walking pace, stopping distance)
4  the boots section states "<each rendered consequence>"
```

**The car's claim is now measured too, by driving one.** It is the one of the
three `claim_field_test` cannot answer: `BootsTool` predicts a stop in closed
form, but a car's stop happens in the physics. `physics_test` gained three
cars, the same five seconds of throttle, then everything the brake has:

```
ordinary      ran 112.9 m to 22.95 m/s, then stopped in 42.90 m
hard brakes   ran 112.9 m to 22.95 m/s, then stopped in 28.42 m
soft brakes   ran 112.9 m to 22.95 m/s, then stopped in 74.74 m
```

Both halves of *"and nothing else"*: the stops order with the field, and the
run to speed is identical to **0.000 m** across all three. That claim was
true, and is now measured rather than inferred from the field's name — which
is all `braking` ever was, a name, and `footing` read just as plausibly.

`claim_field_test` was also run **with** `--fixed-fps 120` and without, and
passes either way (TRAPS 4). `run_tests.bat` needed no edit: the name matches
none of its `findstr` patterns.

### What the suite asserts, and what it does not

- It **enumerates** the claims from `AIInterpreter.assembled_prompt()` and
  the tools from `ToolRegistry.tools()`, so a fourth sentence of this shape,
  or a tool added later, is covered without editing the file — and a sentence
  whose field is not a field of its own tool **fails rather than passing
  unexamined**.
- The measured assertion needs no semantics about what the player's phrase
  means: a claim that says *"and nothing else"* must name a field that, taken
  to the end of the range the prompt itself states, moves **at most one** of
  the readings its tool can take.
- It asserts nothing about wording. Every phrase may be rewritten. A field
  that genuinely does two things may be described honestly — it simply may
  not be described as doing one.
- It picked up, for free, the chain 035 left: **every `LOW to HIGH` bound the
  prompt states for a TOOL's field is accepted by that tool's validator at
  both ends.** 035 measured this for the worlds and skipped the tools because
  the tools render their bounds from their constants, which they do, and
  which says nothing about whether the constants are legal.
- **The trap it walked into while being written, recorded because it is the
  same trap it exists to hold:** the sweep's regex was case-sensitive, so it
  found **two** of the three claims and reported all clear, because one of
  them begins a sentence and so begins *"Someone"*. That is TRAPS 31 — a
  sweep is a claim about the unit it counted — inside the suite written to
  hold TRAPS 31. `prompt_bounds_test` carries a comment saying the same thing
  about *"At most 8 things"*. **The failure mode of a sweep is silence.**

### Not verified

- **NO MODEL HAS READ THE NEW PROMPT.** Every spec in `claim_field_test` was
  typed by hand; a headless harness has no key and no model. Whether telling
  the model that `footing` costs top speed actually stops it choosing
  `footing` for *"boots that stop on a sixpence"* is the half that matters
  most, and only the owner's editor session can show it. **If a model still
  sends `footing`, the wording is not enough and the next move is an example
  rather than a sentence** — which is what 035 said about the farm's zone
  bound and is still unanswered.
- Nothing ran on Windows.
- **`PROMPT_VERSION` moved, so boots designs are not comparable across
  this commit** — and in this case the version string is load-bearing rather
  than bookkeeping: an `EQUIP boots` proposal made under 035–037 came from a
  model that had been told the wrong field and could not send the right one.
  Records already on the owner's disk are his and 038 did not touch them.
- **One judgement, labelled as one.** That the generic line should name
  `turning` rather than restating `brake` is a choice about the prompt, not a
  measurement. The reason is that two sentences owning one player phrase is
  the fault being fixed, and the project's own rule is that a sentence lives
  in one place; `turning` is measured to cost nothing, so the example is
  true, but a different example would have been equally true.
- `boots_test`, `tool_test`, `behaviour_test`, `limits_test`,
  `capability_test`, `prompt_bounds_test`, `ledger_said_test` and
  `session_test` all pass unchanged, so the new skeleton field and the moved
  version were checked against every existing reader rather than assumed
  harmless.

TRAPS 32 records the fault, the rules, and the near miss inside the suite.

## 039 — the arithmetic the prompt states, and the arithmetic Genesis does

**Objective.** HANDOVER named the next assistant task as the one kind of
prompt claim with no door: the PROCEDURAL sentence — a flat statement about
what Genesis will do with a value the model sends — and quoted eight of them.
Asked of the CLASS rather than of that list (TRAPS 11).

### The class, and why the list of eight was not it

The eight quoted sentences are procedural, and six of them were measured this
session and are true (below). But the list was written by reading, and a list
written by reading is a sweep whose unit nobody checked (TRAPS 31). Asked
instead for the sub-class that can be **settled by doing the arithmetic** —
a sentence stating a relation between numbers the model sends and a number
Genesis computes — the assembled prompt holds **six**, found by sweeping it
for arithmetic words rather than by remembering:

```
boots     Top speed is push divided by weight times footing          FALSE
chicane   O is more than 0 and at most 2 x R                         true
chicane   steps the track sideways by O metres, original direction   true
hairpin   carries the track back only by ... twice its radius        true
circuit   angles must add up to +/-360; chicanes do not count        true
circuit   Angles are signed: positive turns right, negative left     true
```

Five of six, which is 035's proportion exactly — nine of eleven bounds were
right there, and the session was worth having for the two that were not.

### The one that was false, and why 038 walked past it

`BootsTool.top_speed()` returns `push / (weight * footing)`. The sentence,
read by the arithmetic convention its own words follow — left to right,
division and multiplication of equal precedence — says
`(push / weight) * footing`. There is no reading of *"a divided by b times
c"* that gives `a / (b * c)`. Measured across the declared ranges, worst gap
**25.2 m/s**:

```
push 240, weight  80, footing 0.67    sentence  2.01    top_speed()  4.48
push 600, weight  50, footing 0.40    sentence  4.80    top_speed() 30.00
push 600, weight 140, footing 0.40    sentence  1.71    top_speed() 10.71
push 240, weight  80, footing 1.50    sentence  4.50    top_speed()  2.00
```

The size of the gap is not the finding. **The sentence puts `footing` in the
numerator**, so it told the model that raising footing makes the player
FASTER. Genesis does the opposite — and four lines above, in the same
section, the footing bullet says so in numbers rendered from the same
function: *"at 1.50 an ordinary body walks at 2.00 m/s rather than 4.48"*.
**038 wrote that bullet and did not read this line.** That is exactly what
013 did when it added `brake`, measured it, and left standing the sentence
038 came back for thirty-three commits later (TRAPS 32). The sentence was
written in 010 — the same commit as the one 038 fixed — and neither 037, 038
nor the first reading of this session noticed it by reading. Only evaluating
it did.

### What it costs, in both directions

`TOP_SPEED` is 2 to 12 m/s and *"a spec where every field is legal but the
three together are faster or slower than that is refused"*. So a model doing
the stated arithmetic:

- proposes `push 600, weight 50, footing 0.40` believing it to be 4.80 m/s,
  and Genesis refuses it at 30.00;
- declines `push 600, weight 140, footing 0.40` believing it to be 1.71 m/s,
  which Genesis would have accepted at 10.71.

That is 035's farm bound — a prompt refusing on Genesis's behalf, in the
model, before Genesis ever sees the request — arriving through arithmetic
rather than through a stated limit.

### What changed

- The sentence now reads *"Top speed is push divided by (weight x footing):
  the ordinary 240 N, 80 kg and 0.67 come to 4.48 m/s. It must come to 2 to
  12 metres a second, and a spec where every field is legal but the three
  together are faster or slower than that is refused."* The bracket is the
  fix, not a better adverb; `x` for multiply is the notation this prompt
  already uses for a chicane's `2 x R`. **Every number in the worked example
  is rendered from `defaults()` and `top_speed()`**, never typed — TRAPS 28's
  rule for a bound, applied to a formula.
- `tests/formula_test.gd`, which is the door. It does not read the sentence
  and agree with it: it **reads the clause out of
  `AIInterpreter.assembled_prompt()`, tokenises it and evaluates it** for 27
  specs spanning the declared ranges, comparing each against `top_speed()`.
  The wording may change freely and the suite stays green; it fails the
  moment the words stop meaning what the code does, and a clause it cannot
  parse FAILS rather than passing.
- `PROMPT_VERSION` is `039-the-arithmetic-it-really-does-1` and
  `PROMPT_FINGERPRINT` is the sha256 of the new 15846-character prompt —
  which `prompt_bounds_test` insisted on rather than anybody remembering.

### What the suite asserts, and what it does not (TRAPS 6, TRAPS 14)

- **FINDING.** The formula clause, evaluated, equals `top_speed()` for all 27
  specs. Fails against the pre-039 prompt.
- **FINDING.** The worked example the prompt states is the number the
  function returns. Fails against the pre-039 prompt, which stated none.
- **MEASUREMENT, not wording.** The DIRECTION, asserted from `top_speed()`
  and from no sentence at all: more push is faster, more weight is slower,
  more footing is slower. A formula can be wrong and still give plausible
  numbers; it cannot be wrong about which way a field pushes without this
  failing. A rewording that puts `footing` back in the numerator fails here
  as well as in the evaluator.
- **GUARDS, and labelled as such (TRAPS 6).** The other five arithmetic
  claims all passed against the pre-039 code and pass now. They are kept
  because they were never measured before and are the reason this session can
  say *five of six were right* rather than *one was wrong*: the chicane's
  `O at most 2 x R` at both ends and outside, its sideways step of exactly
  `O` at three radii in both directions, a hairpin carrying the track back
  `2 x radius`, a chicane counting nothing toward the ±360 (measured by
  difference), signed angles turning right and left, and all three of corner,
  hairpin and chicane refusing a `length` while calculating one.
- The sweep **enumerates the tools from `ToolRegistry.tools()`** and looks
  for a formula clause in each one's own section, so a tool that grows a
  formula has a row and fails rather than passing unexamined, and the count
  is asserted so a formula that is deleted or reworded past recognition is
  caught too.

### Evidence — what was actually run

Godot 4.7.1 headless (`4.7.1.stable.official.a13da4feb`), Linux, in a cloud
container.

- **Baseline, before any change:** 45 suites, **0 with something to look at**.
- **After:** 46 suites, **0 without `--all` and 0 with it**, `drive_test` and
  `session_test` included.
- `formula_test` **fails 2 times** against the pre-039 code, measured the way
  035–038 measured their own: `boots_tool.gd` reverted to 038 with the suite
  left in place. Worst gap 25.2 m/s.
- `formula_test` was run **both with `--fixed-fps 120` and without**, and
  passes either way. `run_tests.bat` needed no edit (TRAPS 4): the name
  matches none of its `findstr` patterns, so it runs there without
  `--fixed-fps` as it does here.
- README said 45 suites and there are 46, counted with `ls` rather than
  remembered.

### Not verified

- **NO MODEL HAS READ THE NEW PROMPT.** Every spec in the suite was typed by
  hand; a headless harness has no key and no model. Whether a model actually
  computed the old formula, and whether it computes the new one correctly, is
  the half that matters most and only the owner's editor session can show it.
  The same caveat 038 left is still unanswered, and this adds to it rather
  than replacing it.
- Nothing ran on Windows.
- **`PROMPT_VERSION` moved, so boots designs are NOT comparable across this
  commit**, and here that is load-bearing rather than bookkeeping: any
  `EQUIP boots` proposal made under 038 came from a model told that raising
  footing makes it faster.
- **The suite measures the six ARITHMETIC claims and no others.** The other
  procedural sentences HANDOVER quoted were measured this session by hand and
  are true (next section), but only three of them — the two chicane claims
  and the signed angles — have a row in a suite. The rest are still undoored.
- The records on the owner's disk are his and 039 did not touch them.

### Measured this session by hand, true, and NOT yet in any suite

Read and measured headless while enumerating the class; recorded here so the
next session does not re-measure them, and so it knows they are unguarded:

- *"Room 1 is the entrance, where the player comes in."* `build()` takes
  `rects[0]`, `_rects()` walks `layout["rooms"]` in the order the model sent
  them, and nothing between `validate()` and `build()` reorders that list.
- *"R is a room's name or its number counting from 1."* Measured: a thing
  with `"in": 2` lands in the second room and one with `"in": "crypt"` in the
  room of that name. All **four** sites that resolve a room this way —
  `DungeonModule._room_index`, `DungeonModule._things_said`,
  `NpcGoals.validate` and `NpcGoals.validate_door` — convert with `- 1` and
  bound-check first, so none of them can reach a negative index (in GDScript
  `array[-1]` is the LAST element, which is how an unchecked one would fail
  silently). `WorldRegistry.around_problem()` holds the fifth, the plan's
  `around`, since 036.
- *"A door joins two different rooms, and the same pair may only be joined
  once."* Both halves refused, each naming the door number.
- *"The game can adjust each angle and each straight length by up to 20% to
  close the loop."* Measured on four circuits: **every** straight and
  **every** corner or hairpin moved in all four — `movable == moved` each
  time — and no adjustment exceeded 20.00%.
- *"a new world replaces whatever was there before, whichever kind it was."*
  Measured over all nine ordered pairs of farm, circuit and dungeon: after
  the second world, `world_node` holds one world's worth of children and
  `drivable`/`standable` describe the second world only. A REFUSED world does
  not clear anything — the clear lives in `_build_world`, which a refusal
  never reaches.

  **040 correction: that last sentence was stated wider than it was true**,
  which is TRAPS 14's shape in this file rather than in the prompt. It is
  true of a SINGLE world. It was false of a PLAN: `_execute_plan` cleared
  the world before working its steps out, so a plan holding one unbuildable
  world took the standing world away and then said it had built nothing —
  measured, a farm of 62 children down to 0. Fixed in 040 for the pass-1
  case. It is **still false** of a plan refused for OVERLAPPING ("Human
  decision needed" 10) and of a sectionless `CREATE_TRACK` ("Human decision
  needed" 2). See 040 below and TRAPS 34.

## 040 — a position in a list, truncated at four doors and refused at the fifth

**Objective.** HANDOVER named the next assistant task as a door for the five
procedural claims 039 measured by hand and recorded as true and unguarded —
built *"the way `formula_test` built one for the six — enumerated from
`WorldRegistry.modules()` and the prompt rather than quoted, since a quoted
list is what this entry got wrong."* Asked that way, two of the five turned
out to be members of larger classes, and each class had a fault in it.

### The class, and the member that was already right

*"R is a room's name or its number counting from 1"* is one of **five** places
the prompt tells the model to name a piece of a world by where it sits in a
list: a dungeon's `doors` pairs, a thing's `in`, an `ORDER`'s `room`, a
`SHUT`/`OPEN`'s `between`, and a plan step's `around`.

Asked at the DOOR rather than at the field (037's unit), **every one
bound-checks** — so nothing can reach a negative index, which matters because
in GDScript `array[-1]` is the LAST element and an unchecked reference would
have answered with the wrong room instead of refusing. That half of 039's
hand measurement is now held by a suite.

What did not hold is the SHAPE of the number. A value that is a number but not
a **whole** number was taken by `int()` to the position below it, in silence,
at four of the five:

```
things  "in": 2.9           ->  room 2, accepted
doors   [1, 2.9]            ->  the door from room 1 to room 2, accepted
ORDER   "room": 2.9         ->  room 2 (vault), accepted
SHUT    "between": [1, 2.9] ->  the door 0-1, accepted
PLAN    "around": 1.5       ->  REFUSED, with the range named
```

**The fifth is the one that was already right, and that is the finding.** 036
added the `around` check, reasoned it out and wrote the sentence; nothing
carried it to the other four, because 036 was asking *"does every command have
a validator?"* and these four have one. So this repository held the correct
rule, written down in a function, for four commits, and applied it to one
member of a list of five — TRAPS 11 in its quietest form: not a fault
reappearing in a different word, but a FIX that never reached its own class.

### What it cost

A drop, not a refusal. The prompt says of Genesis that *"it REFUSES rather
than clamping. A number outside its limits is refused with the limit named"*,
and truncation is clamping done without saying so. A player whose key was put
in room 2 when the model wrote 2.9 is never told a number was rounded for
them. TRAPS 31's rule at a different kind of field: **dropping a value is
worse than refusing it, because a refusal is visible and a drop is not.**

Reachability is honest about itself: nothing in the prompt invites a
fractional room number, so this is not a fault a model is being steered into,
the way 039's formula was. It is the shape 019 found with names — *"every test
had used a number, so nothing had ever exercised it"* — one field along.

### The second class: a refusal does not destroy what was there

*"a new world replaces whatever was there before, whichever kind it was"* is
one member of a rule Genesis follows everywhere else. A single world's refusal
never reaches `_build_world`, so the clear is never run; a PLAN refused for its
SCHEMA returns before any clearing. But `_execute_plan` cleared the world
**before pass 1**, and pass 1 can refuse. Measured headless:

```
a plan refused for its SCHEMA (bad "around")      farm 62 children -> 62   survived
a plan with a step that cannot be worked out      farm 62 children ->  0   GONE
a plan refused for OVERLAPPING (no "around")      farm 62 children ->  0   GONE
```

There were **two** clears to move, not one: the tidy-up at the end ran
unconditionally as well, so moving only the first still destroyed the world at
the end instead of at the beginning.

### What changed

- `Readback.ordinal_index()` is the one reading of *"which position in a list
  is this, or is it none"*, and all five doors ask it. `whole_number_rule()`
  is the clause they all end a refusal with, so the sentence is written once
  (TRAPS 31's rule, the one 037's `intent_problem()` came out of). Each door
  keeps its own locator, because *"thing 1: 'key' is in …"* and *"door 3:
  [1, 2] …"* are different sentences to a player.
- `Readback.number_said()` prints a number out of a request as the player
  wrote it: 0 as "0", not "0.0". Every number arrives from `JSON.parse` as a
  float, so a refusal that prints the raw value tells a player they wrote a
  decimal they did not write — TRAPS 10 and 23's family.
- The plan's clear moved to just before pass 3, where a build is certain to
  start, and the failure tidy-up now clears only if that clear ran.
- **Found beside it and fixed in the same commit:** at the `SHUT`/`OPEN` door
  a room NUMBER out of range was refused as though it were a name — *"this
  dungeon has no room called '0' (it has hall, vault, crypt)"* — answering
  with names a model that had given a number, and naming no range, where the
  other three room doors all name the range or the count. TRAPS 18's rule at
  the one door nobody had asked it of.

**The prompt did not move.** `PROMPT_FINGERPRINT` is unchanged at
`c6c2b955…`, the prompt is the same 15846 characters, and `PROMPT_VERSION` is
still `039-the-arithmetic-it-really-does-1` — verified by running the suite
that insists on it rather than by remembering. **So designs are comparable
across this commit**, boots included.

### What the suite asserts, and what it does not (TRAPS 6, TRAPS 14)

`tests/procedure_test.gd`, 264 assertions, 1.5 seconds. Nothing in it matches
a sentence: every claim is settled by building the thing the sentence
describes and reading what came out, which is the only way these five can be
settled at all — *"the prompt says room 1 is the entrance"* tests nothing.

The units are enumerated, never quoted:

- the reference doors, against a sweep of the assembled prompt for the phrases
  that DEFINE an ordinal, so a prompt that grows a sixth door makes the count
  disagree and the suite FAILS rather than quietly not covering it;
- the room permutations, all six, rather than one reordering — and each room's
  size belongs to its NAME, so if size decided the entrance the same room
  would lead every time. Three different rooms lead;
- the room pairs, every ordered pair, so *"the same pair may only be joined
  once"* is asked of `[1, 2]` then `[2, 1]` — the case a normalisation gets
  wrong — and the pair ONCE is asserted accepted, so the rule is not simply
  refusing everything;
- the adjustable sections, from `TrackGeometry`'s own type families, so
  *"EACH angle and EACH straight length"* is counted rather than assumed: a
  chicane has neither and is correctly not the solver's to move;
- the worlds, every ORDERED PAIR from `WorldRegistry.modules()`, so a fourth
  world has rows here without this file being edited, and a world with no
  buildable request is a failure rather than a gap.

**NOT asserted, deliberately, both the owner's:**

- that a built section stays inside its type's own range. It does not — a 120
  degree corner is built at 136.2. The 20% licence is what the prompt states
  and that is what is asserted; whether the stated range should also bound
  what Genesis BUILDS is "Human decision needed" 9.
- that a plan refused for OVERLAPPING leaves the world standing, and that a
  sectionless `CREATE_TRACK` does. Neither does. Both are left out of the
  assertions rather than asserted as correct, because a suite that guards a
  fault is TRAPS 14 in its most literal form; both are in the suite's header
  with their measurements.

### Evidence — what was actually run

Godot 4.7.1 (`4.7.1.stable.official.a13da4feb`) headless, Linux, in a cloud
container.

- **Baseline, before anything changed:** 46 suites, **0 with something to look
  at**.
- **After:** 47 suites, **0 with something to look at**, both without `--all`
  and with it — `drive_test` and `session_test` included.
- **`procedure_test` fails 38 times against the pre-040 code**, measured the
  way 035-039 measured their own: the five changed scripts reverted to 039
  with the suite left in place. 36 of the 38 are the four reference doors that
  truncated; 2 are the plan that destroyed a world it could not replace. It
  fails **0 times at `plan around`**, which is the control member of the class
  and the reason the class was visible at all.
- The prompt is byte-identical: `prompt_bounds_test` passes, and the
  fingerprint was printed and compared rather than assumed.
- `run_tests.bat` needed no edit (TRAPS 4): `procedure_test` matches none of
  its `findstr` patterns, so it runs there without `--fixed-fps` as it does
  here, and it was run **both ways** and passes either.
- README said 46 suites and there are 47, counted with `ls`.

### Not verified

- **No model has sent any of this.** Every reference in the suite was typed by
  hand; a headless harness has no key and no model. Whether a model ever
  writes a fractional room number is exactly what the harness cannot know —
  and the honest expectation is that it rarely does, which is why this is a
  class fix rather than a fault report.
- **Nothing ran on Windows.**
- **The player-facing half of the plan fix is unverified in the editor.** What
  was measured is `world_node.get_child_count()`, not what a person sees. That
  a plan refused for a bad step now leaves the previous world on screen is the
  kind of thing only the owner's session confirms.
- The suite measures the five claims named above and no others. The other
  three of 039's eight are in `formula_test`.
- The records on the owner's disk are his and 040 did not touch them.

## 041 — the rule was carried to five doors and there were thirteen

**Objective.** The question this file named as the next assistant task:
*040's finding asked of every other place a fix has already been written
once.* 040's value was not a fault that reappeared in a new word — it was a
CORRECT RULE, written out by 036 and never carried to the four other doors of
its own class. TRAPS 11 has always said fix the class; nothing had asked the
reverse, which is cheaper and sharper: **for every fix in TRAPS 1 to 34, is
the rule it produced applied everywhere it holds, or only where the fault was
found?** Enumerated from TRAPS's own entries, which is what 039 found this
file's list of eight had not been.

**Starting state.** Branch `prototype-002a` at 040. 47 suites, 0 with anything
to look at, `--all` included — read by running them, not from this file.

### The first rule asked, and the answer

TRAPS 34 is one commit old and states five rules. Its fifth is *"a number said
back is said as the player wrote it"*, and it came with a function so the five
reference doors could not drift apart again. **Genesis has thirteen doors that
say a request's number back. 040 reached five.** The other eight rendered the
same number by hand, in three styles, and every style ROUNDS:

```
dungeon_module     "%.0f" % value                 width 40.4     -> "40"
farm_module        "%.0f" % value                 barn 60.4      -> "60"
car_tool           "%.0f" % number                grip 20.4      -> "20"
section_validator  _tidy()                        length 1000.04 -> "1000.0"
                                                  angle 9.996    -> "10.00"
boots_tool         _tidy()                        footing 1.504  -> "1.50"
                                                  push 599.5     -> "600"
world_registry     String.num(number, 2)          around 1.5004  -> "1.5"
```

### What it cost, measured headless before anything was changed

A rounded number is not untidy. Where a value sits just past a bound the
rounding lands it **on** the bound, and the refusal then names a value that
satisfies the limit it is refusing. **Reachable at every one of the five
validators:**

```
room width 40.4    room 1: width is 40 m, and must be 4 to 40 m
room width 3.6     room 1: width is 4 m, and must be 4 to 40 m
barn width 60.4    zone 1 (barn): width 60 m is outside 5-60 m
barn width 4.6     zone 1 (barn): width 5 m is outside 5-60 m
length 1000.04     section 1 (straight): length is 1000.0 m, and must be 20 to 1000 m
angle 9.996        section 1 (corner): angle is 10.00 degrees, and must be 10 to 120
radius 300.04      section 1 (corner): radius is 300.0 m, and must be 15 to 300 m
grip 20.4          grip is 20, and a car's grip must be 2 to 20
grip 1.6           grip is 2, and a car's grip must be 2 to 20
braking 30.4       braking is 30, and a car's braking must be 8 to 30
power 1800.4       power is 1800, and a car's power must be 400 to 1800
footing 1.504      footing is 1.50, and boots' footing must be 0.40 to 1.50
push 600.4         push is 600, and boots' push must be 120 to 600
weight 140.4       weight is 140, and boots' weight must be 50 to 140
```

That is TRAPS 18's fault with the limit present and correct: the player is
told the range, shown a value inside it, and given nothing to act on. It is
also what Genesis says of itself in the prompt — *"it REFUSES rather than
clamping"* — denied in the sentence that does the refusing.

### And the one reading had the fault at its own edge

`number_said()` ended `String.num(number, 2)`, which rounds to two places. So
1.504 came back as `"1.50"` against a bound printed `"0.40 to 1.50"`, at the
door the function was written for. **Three of 040's five reference doors say a
number wrongly in the pre-041 code, after 040 fixed them:** a door pair of
`[1, 2.504]` read back *"[1, 2.5]"*, a thing `in: 1.504` read *"in room 1.5"*,
and a plan step `around: 1.5004` read *"not 1.5"*. So this was not only a fix
that failed to reach its class — the fix was not sufficient where it was
applied, and the only reason 040's own suite is green is that its probes were
whole numbers and 2.5.

### Why no suite saw it, which is the part worth keeping

`tests/capability_test.gd` has asserted *"a number outside its limits is
refused with the limit named"* for every bound in all five validators since
028 — TRAPS 11 done properly, the whole class enumerated off the constants,
165 assertions. It probes `limits.y * 10.0 + 7.0` and a value far below the
minimum. **Both probes are effectively whole numbers**, and every rounding
style renders a whole number faithfully, so the check could not fail.

TRAPS 6 one step back from where it is usually found: not an assertion that
cannot fail, but a correct assertion fed the one input that cannot make it
fail. The class was enumerated, the doors were enumerated, TRAPS 21's three
entrances were enumerated — and the **values** were the axis nobody varied.

### What changed

`Readback.number_said()` is the one reading for all thirteen doors and its
precision is now **faithful** (`String.num(number, -1)`), because any fixed
precision can round a value onto a bound. The eight hand-written doors ask it.
A **bound** is deliberately not said this way: a bound is a constant at its
own natural precision (TRAPS 28), which is why boots keep *"0.40 to 1.50"*
while the value between them is said exactly. `boots_tool._tidy()` and
`section_validator._tidy()` survive for bounds alone and each carries a
comment saying so, because one function doing both facts is how this was
possible — and `section_validator._tidy()`'s old comment said *"exact about
what was asked for"*, which is precisely what it must not be used for.

Files: `readback.gd`, `dungeon_module.gd`, `farm_module.gd`, `car_tool.gd`,
`boots_tool.gd`, `section_validator.gd`, `world_registry.gd`.

### What the suite asserts, and what it does not (TRAPS 6, TRAPS 14)

`tests/said_number_test.gd`, 312 assertions, under a second. It takes
`capability_test`'s enumeration — every bound in all five validators, read
from the constants and never typed in — and moves the probes to the **edge**,
at 0.4, 0.04 and 0.004 past each bound, because the delta that exposes
`"%.0f"` is invisible to `"%.2f"`. Of every refusal it asserts two facts and
no wording:

1. the sentence names the number that was **sent**, and
2. that number, read back out of the sentence, is **still outside** the bound
   the same sentence states.

Every sentence in Genesis may be rewritten and both stay green. It also
asserts `number_said()` as a **round trip** rather than as quoted strings, and
carries a positive control for its own "is this number named" check (TRAPS
26), which found that `"room 1:"` really does name the number 1 — the first
control written was wrong, not the checker.

**NOT asserted, deliberately.** A READBACK rounds a measurement to whole
metres, and the world really is built at the asked-for size, so that sentence
rounds a true fact rather than misquoting a request:

```
rooms 12.4 and 20.5 m   "entered through a 12 m hall, along with a 20 m vault"
barn 30.4 by 20.6 m     "a farm with a 30 by 21 m barn"
straights 200.4 m       "two 200 m straights and two 50 m corners, 90 deg right"
```

Whether a readback should say *"a 12.4 m hall"* is a judgement about prose and
it is the owner's: "Human decision needed" 11. It is in the suite's header
with its measurement and **out of its assertions**, because a suite that
guards a fault is TRAPS 14 in its most literal form.

### Evidence — what was actually run

Godot 4.7.1 (`4.7.1.stable.official.a13da4feb`) headless, Linux, in a cloud
container.

- **Baseline, before any change:** 47 suites, **0 with something to look at**,
  without `--all` and with it, `drive_test` and `session_test` included.
- **After:** 48 suites, **0 with something to look at**, both ways.
- `said_number_test` **fails 146 times against the pre-041 code**,
  measured the way 035–040 measured their own: the seven changed scripts
  reverted to 040 with the suite left in place. **139** are the eleven bounded
  fields of the five validators, **4** are `number_said()` itself, and **3**
  are the reference doors 040 built the rule for.
- **The prompt did not move.** `assembled_prompt()` is 15846 characters and
  sha256 `c6c2b9555fa6283c1f4d379c925ba95a15db8000a2d8e3d7d26d4e9010c46e62`,
  matching the declared `PROMPT_FINGERPRINT`; `PROMPT_VERSION` is still
  `039-the-arithmetic-it-really-does-1`. Checked by printing and comparing,
  not by remembering. **So designs are comparable across this commit**, boots
  included.
- `run_tests.bat` needed no edit (TRAPS 4): `said_number_test` matches none of
  its `findstr` patterns, so it runs there without `--fixed-fps` as it does
  here, and it was run both ways and passes either.
- README said 47 suites and there are 48, counted with `ls`.

### Not verified

- **No model has sent any of this.** Every value in the suite was typed by
  hand; a headless harness has no key and no model. Whether a model writes a
  fractional measurement just past a bound is what this harness cannot know —
  which is why this is a class fix and not a fault report.
- **Nothing ran on Windows**, and nothing ran in the editor. What was measured
  is the string a validator returns, not what a person reads on screen.
- The suite measures the bounded numeric fields of the five validators, the
  chicane's computed offset limit, and three of 040's reference doors. It does
  not measure every sentence in Genesis that contains a number.
- The readback rounding above is **measured and not fixed**, and not asserted
  either way.
- The records on the owner's disk are his and 041 did not touch them.

## 042 — the sweep could only see one of the two ways a count goes wrong

**Objective.** The task this file named next: *the audit 041 began, continued
through the rest of TRAPS's rules* — take a rule, find the function the fix
introduced, grep its call sites, count them against the places the rule
holds, and measure what the difference costs before changing anything. The
rule asked here is **TRAPS 27's**: *a count and the noun after it are one
fact, read from `Readback.plural()` or `count_of()` and never written out
again*. It was chosen because this file named it, with the places it thought
were missed. The answer is **only where the fault was found — and the sweep
that guards it can only see half the fault.**

**Starting state.** Branch `prototype-002a` at 041. 48 suites, 0 with anything
to look at, `--all` included — read by running them, not from this file.

### The call-site count, and the two halves of the answer

`Readback.plural()` has 23 call sites in `scripts/` and `count_of()` has 7.
034 swept the validators and the dungeon's measurements. Enumerated against
every sentence in `scripts/` that states a count and then a word (grepped,
not recalled), **nine sentences in six files were outside that sweep and
seven of them were wrong**, measured headless before anything was changed:

```
session summary, ONE request   "Session 'tester': 1 minutes, 1 requests."
                               "First world after 1 seconds, from ..."
                               "Understanding: 1 readbacks, 1 with evidence."
                               "understood: 100% of the 1 that bear on it"
the farm's ZONES panel         "3   (2 orchard, 1 barn)"
the circuit's SECTIONS panel   "8  (4 straight, 4 corner, 0 hairpin, 0 chicane)"
/worlds, one world saved       "1 saved worlds: farm1"
LoadCheck, one measurement     "1 of 1 measurements match"
the feasibility gate           "composition has 1 straight(s) and 1 corner(s)"
```

**WHY THE SWEEP COULD NOT SEE THE WORST OF IT.** `container_door_test` does
what TRAPS 27 asked for and sweeps the OUTPUT rather than any sentence, with
the regex `\b1 [a-z]+s\b`. **That is a count of ONE wearing a plural. A
count of TWO wearing a SINGULAR is the same fault and the regex is blind to
it by construction** — and that is the half the two itemising panels had.
TRAPS 6 at a correct assertion, exactly as 041 found it one commit earlier:
not an assertion that cannot fail, but one that cannot fail for half of what
it covers.

**The circuit's was unconditional.** A closed circuit needs at least two
straights and two corners (`FeasibilityGate`), so those two counts can never
be one — so **every circuit Genesis has ever built** read *"4 straight, 4
corner"*. The farm's needs only two zones of a kind.

**And the agreement is not only the noun's.** *"the 1 that bear on it"* is the
same single fact — is this count one — decided a third time, by hand, at a
VERB. So the one reading is now `Readback.agrees(count, one, many)`, which
answers that question and nothing else, and `plural()` is a reader of it.

### Found in the same line, and it is not about plurals

The circuit's SECTIONS panel named **four of the ten types
`SectionValidator` accepts**, written out by hand with no tie to
`OFFERED_TYPES`. So a circuit holding an `uphill` measured:

```
SECTIONS   8  (2 straights, 4 corners, 0 hairpins, 0 chicanes)
```

**A total of 8 over an itemisation of 6**, with the two dropped pieces
unnamed beside two printed zeros — a measurement panel whose own arithmetic
is false in front of the player. Measured rather than inferred: the validator
accepts that circuit (`ok=true`, no errors), it passes the gate, it closes
and it measures, so it is reachable by any model that sends one. The prompt
not offering the type is not enforcement (TRAPS 19, and the owner's decision
1). `_counted()` now walks `SECTION_TYPES` and names a type when it is
PRESENT or when it is one the prompt offers, which leaves today's line
byte-identical — `OFFERED_TYPES` is in `SECTION_TYPES`'s own order — and
makes a type the owner ever opens appear without that function being edited.

### And the suite's own first draft walked into the fault it is about

`String.contains()` is a substring test, so `"1 requests"` contains
`"1 request"`. **Measured: with `contains()`, five assertions PASSED against
the pre-042 code they were written to catch** — the same one-directional
blindness, one layer up, in the suite auditing it. Every check is a
whole-word one now. Beside it: the first draft ASSEMBLED `/worlds`'s sentence
itself and asserted on its own output, because the sentence lived inline in
`Main._list_worlds()`, a `Node3D` no suite can instantiate. It is
`WorldStore.saved_line()` now and the suite reads it.

### Implementation

- `scripts/readback.gd` — `agrees(count, one, many)`, the one reading of *is
  this count one*; `plural()` rewritten as a reader of it.
- `scripts/session_report.gd` — the four counted sentences, plus the verb.
- `scripts/farm_module.gd` — the ZONES panel's per-type counts.
- `scripts/racing_module.gd` — the SECTIONS panel, through the new
  `_counted()`; the `CREATE_TRACK` summary's section count (`MIN_SECTIONS` is
  2 so it cannot be one today — read through the one function anyway, so a
  bound that moves does not take a sentence with it).
- `scripts/world_store.gd` — `saved_line()`, the one place that says how many
  worlds are saved.
- `scripts/main.gd` — calls it.
- `scripts/load_check.gd` — the noun and the verb both agree with the count.
- `scripts/feasibility_gate.gd` — `"1 straight(s)"` is the plural by hand
  wearing a dodge.
- `scripts/experiment_runner.gd` — four counted sentences. **Nothing in the
  harness reaches them**: the experiment drives a live model. The rule
  applied to its class, not a fault observed.
- `tests/counted_said_test.gd` — new, 61 assertions.

### What the suite asserts, and what it does not (TRAPS 6, TRAPS 14)

- Every counted panel whose counts are enumerable from the code says exactly
  what `Readback.plural()` renders, with the counts read from the measurement
  and the types read from `FarmModule.ZONE_TYPES` and
  `SectionValidator.SECTION_TYPES` — never typed into the suite. Reword
  `plural()` and it still passes; write the agreement by hand again, in
  either direction, and it fails.
- The word after the count **differs** between a count of one and a count of
  two. That is the two-directional property no regex for either direction
  has.
- The circuit's SECTIONS panel **itemises to its own total**, asserted by
  summing the digits, not by reading the sentence.
- `plural()` is a reader of `agrees()`, asserted as a round trip at 0, 1, 2,
  3 and 11, with an irregular plural carried through.
- 034's output sweep, applied to the places 034 did not reach.
- **NOT asserted:** nothing here has been near a model. The experiment
  runner's four sentences are in the class, were changed with it, and are
  reached by nothing in this harness. Whether a save file can hold a single
  measurement is not known here either, so `LoadCheck`'s line is the rule
  applied and not a fault measured. And this covers sentences that state a
  COUNT — it is not a sweep of every sentence containing a number
  (`said_number_test` is that, for the numbers a request carried).

### Evidence — what was actually run

- Godot 4.7.1 (`4.7.1.stable.official.a13da4feb`) headless, Linux, in a cloud
  container. **Baseline before anything changed: 48 suites, 0 with something
  to look at**, both without `--all` and with it, `drive_test` and
  `session_test` included. **After: 49 suites, 0 with something to look at**,
  `--all` included.
- `tests/counted_said_test.gd` (61 assertions, under a minute) **fails 24
  times against the pre-042 code**, measured the way 035–041 measured their
  own: the nine changed scripts reverted to 041 with the suite left in place,
  and the two new functions stubbed at their pre-042 wording so the suite
  parses. 8 of the 24 are the farm's panel, 7 the circuit's (one of them the
  arithmetic), 5 the session summary, and one each `/worlds`, the gate's
  `(s)`, `LoadCheck` and the output sweep.
- **The prompt did not move.** Nothing in this commit touches
  `AIInterpreter.assembled_prompt()` or any `prompt_section()`, so
  `PROMPT_VERSION` is still `039-the-arithmetic-it-really-does-1` and designs
  are comparable across this commit — checked by running
  `prompt_bounds_test`, which fails if the fingerprint and the version
  disagree.
- `run_tests.bat` needed no edit (TRAPS 4): `counted_said_test` matches none
  of its `findstr` patterns — not `ledger`, not `session`, not `drive`, not
  `physics` — so it runs there without `--fixed-fps` as it does here, and it
  was run both ways and passes either. README said 48 suites and there are
  49, counted with `ls tests/*.gd` less the two tools.

### Not verified

- **No model has sent any of this.** Every count in the suite was typed by
  hand. A model sending an `uphill` is what makes the SECTIONS arithmetic
  fault reachable in play, and this harness has no key, so that path is
  argued from the validator's own answer and not observed.
- **Nothing ran on Windows**, and nothing ran in the editor. What was measured
  is the string a function returns, not what a person reads on screen — and
  these are panels, so what a person reads on screen is the whole point of
  them.
- The experiment runner's four sentences were changed and **not run**.
- Whether a save file can hold exactly one measurement is unknown, so
  `LoadCheck`'s sentence is unproven at the count that matters.
- Nothing here asked the same question of the remaining TRAPS rules. See
  "Next action": TRAPS 10 and 23's article rule and TRAPS 20 and 30's
  `as_number()` are still unasked.
- The records on the owner's disk are his and 042 did not touch them.

## 043 — the article had one function, and only one file could reach it

**Objective.** The task this file named as the next assistant task: *the same
audit, at the rules 042 did not ask*, taking the one 042 named as the one it
would have taken next. The rule is **TRAPS 10 and 23's**: *a fact about a
WORD lives in one function and every rendering reads it*. The method, which
has now worked three times: take the rule, find the FUNCTION the fix
introduced, grep its call sites, and count them against the places the rule
holds.

**Starting state.** Branch `prototype-002a` at 042. 49 suites, 0 with
anything to look at, `--all` included, run before anything was changed.

### The call-site count, and why the answer is sharper than the number

The fact is `Readback.is_label()` — *a numbered name is a label and takes no
article*. It has two readers: `Readback.article()`, which writes **a**, and
`NpcGoals._place()`, which writes **the**.

```
Readback.article()   8 call sites, in 6 files
NpcGoals._place()   11 call sites, in 1 file, all of them rooms
```

`_place()` is `static` in `npc_goals.gd`. Nothing outside that file calls it
and nothing inside it calls it for anything but a room — so **the definite
article had no reader that anything else could reach**, and every other
sentence that needed one wrote it out. Grepping every format string in
`scripts/` for an article in front of a substitution gives fifteen; nine of
them render a NAME, and **nine of those ten were measurably wrong at a
numbered name** — the tenth, `GameController`'s *"so the farm fits inside
it"*, names a world, and a world's `display_name()` is never numbered. A
second grep, for an article in front of a NUMBER, adds `_room_said()`'s
measured branch, which no search for `"the %s"` or `"a %s"` can find.
**Ten wrong renderings in all**, measured headless before anything was
changed:

```
NpcGoals.readback, carry        "to have the key 2 carried to the vault"
NpcGoals.delivery_line, x4      "The key 2 is in the vault."
                                "The key 2 did not get to the vault. ..."
                                "Cannot tell whether the key 2 got to ..."
NpcGoals.validate_door          "there is no door between the room 1
                                 and the room 2"
DungeonModule._things_said      "... with a lamp in the room 1"
DungeonModule._room_said        "entered through a 12 m room 1"
GameController, x2              "the key 2 is not in the world any more"
                                "the key 2 is not in any room"
```

**Six of the ten are in `npc_goals.gd`**, the file carrying this comment
since 022:

> There is now no other way to name a room in this file.

It was false when it was written and false of rooms, not only of things:
`validate_door`'s no-door refusal names two rooms by hand two hundred lines
above it. A claim about the code is checked like any other claim (TRAPS 14);
this one went twenty-one commits unchecked.

### Why no suite saw it, which is the part worth keeping

`log_022_test` has asserted this exact rule on a dungeon readback since 031
— seven assertions, green every run — and **every room it asks about has a
width and depth of `null`**:

```gdscript
var unsized := d.readback({"rooms": [
    {"name": "room_1", "width": null, "depth": null},
    {"name": "chamber_2", "width": null, "depth": null}], "doors": [[1, 2]]})
```

`null` is the one branch of `_room_said()` that calls `article()`. The branch
beside it — the one every measured room takes, which is every real room —
wrote *"a"* by hand. A correct assertion fed the one input that could not
make it fail: TRAPS 6, exactly as 041 found it and 042 found it. **Three
commits running the blind spot has been in the check rather than in the
code.**

### And the one reading had the fault at its own edge

As 041's `number_said()` did. `article()` chose between *a* and *an* **by the
first letter**:

```gdscript
return ("an " if word[0] in ["a", "e", "i", "o", "u"] else "a ") + word
```

TRAPS 10's own rule is to write the rule about the thing that makes it true,
and the thing that makes an article *an* is the **sound**. A size is rendered
in front of a name, and a size starts with a digit, so this is reachable in
**every dungeon readback** through `_room_said()` and **every farm readback**
through `count_of()`:

```
"a 8 m hall"      "a 11 m vault"      "a 18 m crypt"
"a 80 by 20 m barn"                   "a 8 by 8 m barn"
```

A room is 4 to 40 m and a farm zone 5 to 60 m, so 8, 11, 18 and 80–89 are all
inside the bounds. `Readback._takes_an()` now decides a leading number by
arithmetic: a leading 8 is always *eight* something (8, 80, 800, 8000), and
*eleven* and *eighteen* survive only on a thousands boundary — 11 and 11000
take *an*, while 110 is "one hundred ten" and 1100 is "one thousand one
hundred" and both take *a*.

### Found in the same line, and not about names

`SectionValidator._forbid` writes *"a"* twice in one sentence:

```
section 1 (uphill): 'radius' is not a uphill setting (a uphill has
length and grade)
```

while `article()` one call away says *"an uphill"*. Measured at every one of
`SECTION_TYPES`: the validator accepts `uphill` whatever the prompt offers,
and the prompt not offering a type is not enforcement (TRAPS 19) — the same
argument 042 used to call the SECTIONS panel's arithmetic reachable.

### Implementation

- `Readback.the()` is the definite article and a second reader of
  `is_label()`. `Readback.sentence_start()` raises the first letter only,
  because Godot's `String.capitalize()` title-cases every word.
- `Readback._takes_an()` decides a leading number by how it is spoken.
- `NpcGoals._place()` is a reader of `the()`; `NpcGoals._thing()` is the
  thing-naming half that had no function at all. All six sentences in that
  file and the no-door refusal read one of them.
- `NpcGoals.missing_thing_line()` holds the two sentences that lived inline
  in `GameController`, a `Node3D` no suite can instantiate — the wall 042 hit
  at `/worlds` and solved the same way.
- `DungeonModule._room_said()`'s measured branch and `_things_said()`'s
  *"in the"* read the one function. `SectionValidator._forbid` reads
  `article()`. `GameController`'s *"so the %s fits inside it"* reads `the()`
  and is byte-identical today, which is the point.
- The false comment in `npc_goals.gd` is corrected in place rather than
  deleted, and says what was false about it.

### What the suite asserts, and what it does not (TRAPS 6, TRAPS 14)

- Every sentence that names a room or a thing contains that name **exactly**
  as `Readback.the()` or `article()` renders it — the article they give, and
  no article they do not. Reword either function and it still passes; write
  one by hand again and it fails.
- **Two-directional**, which is 042's lesson applied to this class: the same
  sentence is produced with a NUMBERED name and with an ORDINARY one, and
  must drop the article for the first and keep it for the second. A function
  that returned the bare name always would pass a one-directional check.
- Which article a leading NUMBER takes, asserted as **facts about English
  typed into the suite** (8, 11, 18, 80, 800, 11000 take *an*; 110, 180, 1100
  take *a*) rather than by re-reading the function under test.
- The chain is asserted at each link: `is_label()` against the fact,
  `the()`/`article()` against `is_label()`, and every sentence against
  `the()`/`article()` — plus a sweep that is independent of all three.
- The section refusal, enumerated from `SectionValidator.SECTION_TYPES` and
  never typed in, so a type the owner opens is covered without editing it.
- **NOT asserted.** Nothing here has been near a model; every name was typed
  by hand. The two `GameController` sentences are reached through the
  function they were moved into and **not** through `GameController`, so what
  is checked is the sentence, not that the controller still passes it the
  right thing. A word beginning with a LETTER is still decided by that
  letter, so *"an hour"* and *"a unicorn"* come out wrong and **nothing here
  claims otherwise**.

### And the suite's own first draft walked into the fault it is about

For the second commit running. `_says()` is a containment test, and
*"a 12 m room 1"* CONTAINS *"12 m room 1"* — so a check for what should be
there cannot see what should not. **Measured: the suite fails 27 times
against the pre-043 code with the absence asserted and 15 times without, so
twelve assertions written to catch this fault passed against it.** Every
name check is `_named_as()` now, which also refuses a stray article.

Beside it, the sweep's first draft allowed two words between the article and
the number and caught *"a track needs 2 to 40 sections"* ten times, because
`is_label()` says yes to *"track needs 2"*. A regex cannot tell a name from a
verb; one word is the narrower claim and it is the one that is true.

### Evidence — what was actually run

- Godot 4.7.1 (`4.7.1.stable.official.a13da4feb`) headless, Linux, in a cloud
  container. **Baseline before anything changed: 49 suites, 0 with something
  to look at**, both without `--all` and with it, `drive_test` and
  `session_test` included. **After: 50 suites, 0 with something to look at**,
  `--all` included.
- `tests/said_article_test.gd` **fails 27 times against the pre-043 code**,
  measured the way 035–042 measured their own: the five changed scripts
  reverted to 042 with the suite left in place, and `Readback.the()`,
  `Readback.sentence_start()` and `NpcGoals.missing_thing_line()` stubbed at
  their pre-043 wording so the suite parses.
- **The prompt did not move.** Nothing here touches
  `AIInterpreter.assembled_prompt()` or any `prompt_section()`: measured at
  **15846 characters, sha256 `c6c2b9555fa6283c1f4d379c925ba95a15db8000a2d8e3d7d26d4e9010c46e62`**,
  which is what 041 and 042 recorded, so `PROMPT_VERSION` is still
  `039-the-arithmetic-it-really-does-1` and designs are comparable across
  this commit. `prompt_bounds_test` passes, which fails if the fingerprint
  and the version disagree.
- `run_tests.bat` needed no edit (TRAPS 4): `said_article_test` matches none
  of its `findstr` patterns — not `ledger`, not `session`, not `drive`, not
  `physics`, not `carry_test`, not `explore`, not `walker`, not `behaviour`,
  not `interference`, not `repeat_test`, not `order_test`, not
  `false_delivery` — so it runs there without `--fixed-fps` as it does here,
  and it was run both ways and passes either. README said 49 suites and there
  are 50, counted with `ls tests/*.gd` less the two tools.

### Not verified

- **No model has sent any of this.** Every name was typed by hand. A model
  naming rooms `room_1..4` is what 022 actually observed, so the numbered
  case is not invented — but no numbered name reached these sentences from a
  live API in this session, because this harness has no key.
- **Nothing ran on Windows** and nothing ran in the editor. What was measured
  is the string a function returns, not what a person reads on screen.
- **The two `GameController` sentences were moved and not driven.**
  `GameController` is a `Node3D`; the suite reaches
  `NpcGoals.missing_thing_line()` directly. That the controller still calls
  it with the right thing and the right reason is read from the diff, not
  measured.
- **The letter half of the article is still wrong and is not claimed
  otherwise.** *"an hour"*, *"a unicorn"*. Reachable: a thing's name comes
  from the model and can be any word.
- **`_takes_an()` is faithful over the numbers Genesis renders** — room,
  zone, section and tool bounds are all under 10000 — and the thousands rule
  above that is argued from how English is spoken rather than measured
  against anything.
- The experiment runner was not run; it drives a live API.
- The records on the owner's disk are his and 043 did not touch them.

## 044 — the reading the readbacks could not use

**Objective.** The task this file named as the next assistant task: *the same
audit, at the rules 043 did not ask, carrying 043's own question to each of
them — can everything that needs this function actually reach it?*

**Starting state.** Branch `prototype-002a` at **043** (`abe38dc`), 50 suites,
0 with something to look at, measured in this session before anything was
changed.

### The rule the file named first, and why it is not the finding

**TRAPS 20 and 30 — `Readback.as_number()`.** *A value from the AI is
converted through as_number(), never a bare int() or float(), handlers and
builders included.* **This one holds.** The call sites were counted and every
bare conversion left in `scripts/` is one of two things:

- **Downstream of a validator that rewrote the value.**
  `SectionValidator.validate()` returns a `clean` array built from
  `_number()`'s floats, and `RacingModule.validate()` hands that array on as
  `content["sections"]`, so `TrackGeometry`, `TrackMetrics`, `ClosureSolver`,
  `FeasibilityGate` and `SeparationCheck` never see a request's value at all.
  The ~60 `float(s["radius"])`-shaped calls in those files are reading
  Genesis's own numbers.
- **Reading Genesis's own bookkeeping**, not a request:
  `int(attempt.get("attempt", 1))`, the session report's counters, a
  dictionary this code just built.

The tools are the one place worth naming, because they are *not* protected by
a validator on every path: `ToolRegistry.readback()` describes a REFUSED spec
through `asked_spec()`, which lays the asked-for fields over the defaults and
drops any whose type differs from the default's (`_same_kind()`). So
`float(spec.get("power", DEFAULT))` in `car_tool` and `boots_tool` reads a
value that has been type-checked — by a hand-written `typeof()` test rather
than by `as_number()`, which is a second reading of the same fact and is
recorded here rather than changed, because the fact it decides is *"is this
the same kind as the default"* and not *"is this a number"*.

**So the predicted shape arrived at the rule one door along.**

### THE CLASS: a reference by position, at the layer that SAYS it back

TRAPS 34's rule — *a reference by position is a whole number, and one that is
not is refused with the range named rather than truncated in silence* — went
into `Readback.ordinal_index()` and 040 carried it to all five doors the
prompt names. **Every one of those five is a validator or a handler.** Six
readbacks stand beside them saying the same reference back to the player, and
all six called `int()` by hand. Measured headless before anything was
changed:

```
ORDER go_to       "room": 2.9     "to send someone to room 2"
ORDER go_to       "room": 0.5     "to send someone to room 0"
ORDER go_to       "room": 99.9    "to send someone to room 99"
ORDER carry       "room": 2.9     "to have the key carried to room 2"
SHUT / OPEN       [1, 2.9]        "between the 1 and the 2.9"
MODIFY_TRACK      "corner": 2.9   "to make corner 2 hard"
SPAWN_OPPONENTS   "count": 1.5    "to put an opponent on the track"
CREATE_DUNGEON    "in": 2.9       "with a key in the vault"
PLAN              "around": 1.5   "one inside the other"
```

**And next to every one of those, in the same exchange, the refusal says the
number exactly**: *"there is no room 2.9: a room number is a whole number, 1
to 3"*, *"thing 1: 'key' is in room 2.9"*, *"'around' must be a whole step
number (1 to 1), not 1.5"*. Two sentences about one request, disagreeing about
the number — and **the one the player is invited to check is the wrong one**,
which turns the readback from the layer that catches a misread clause into the
layer that hides one.

### Why the one reading could not reach them, which is sharper than the count

**The return type, not the file.** 043 found a one reading only one file could
call. `ordinal_index()` is `static` on `Readback` and every file can reach it —
and six callers still could not use it, because it returns a **resolved index,
or −1**. That is exactly what a validator needs and exactly what a readback
must not have: a readback's job is to show what Genesis HEARD so a dropped or
misread clause is visible (TRAPS 8), so it must say the value the request
CARRIED and never the thing that value resolves to. `Readback.position_said()`
is the readback's reader of the same fact, and the two now sit beside each
other with a comment saying why one function cannot serve both.

### Why no suite saw it, which is the part worth keeping

`tests/procedure_test.gd` does exactly what 040 set out to do. It probes 1.5,
2.9, `count + 0.5` and 0.5 at all five reference doors and asserts each is
refused, with *"whole"* said and the range named — seven assertions a door,
green every run since 040. **Every one of them goes through `_resolve()`,
which is the validator.** The suite is correct, its values are the right
values (041's lesson, applied), its class is the whole class (040's) — and the
**LAYER** beside it was never asked.

TRAPS 6 for the **fourth commit running**, in a fourth costume:

| commit | the check was correct, and blind to |
|---|---|
| 041 | the probe's **values** — whole numbers only |
| 042 | the sweep's **direction** — one of two ways a count goes wrong |
| 043 | the input's **shape** — every room it asked about had a `null` size |
| 044 | the **layer** — every probe went through the validator |

Genesis keeps four evidence layers apart on purpose (PROTOCOL section 2). A
suite that asks one of them has not asked the others, and none of these four
was found by reading the code under test.

### And a claim in a code comment had been false for three commits

`DungeonModule._things_said()` resolved a thing's `"in"` under a comment
reading *"the readback resolves a name the same way the validator does"*. It
was **true when it was written**; 040 taught the validator to refuse a
fraction and left this line taking `int()` to it, so the comment became false
and stayed false for three commits. TRAPS 14 at a claim in the code rather
than in a document, which is where 043 found one too. The comment is corrected
in place and says what was false about it. The same line **dropped the room
altogether** for an out-of-range number — *"a key"* for `"in": 99` — which is
the half-silence its own comment said it existed to prevent.

### Found in the same reading, and not about positions

- **`NpcGoals.door_readback()` said a room NUMBER as a NAME.** Both sides went
  through `_place()`, the definite article's reader, and `is_label()` says —
  rightly, and says so in its own comment — that a bare number is not a label,
  because there is no name in front of it to label. So `[1, 2]` read back as
  *"between the 1 and the 2"*. `_side_said()` now sends a number through
  `position_said()` and a name through `_place()`.
- **`TrackBuilder.readback()` left a corner below 1 out of the sentence.** So
  `"corner": 0.5` read back **identically** to a request naming no corner at
  all — two different requests, one sentence, which is 031's fault and the one
  thing a readback must never do. A corner that was not GIVEN is still left
  out (TRAPS 8); one that was given is said, whatever number it was.
- **`around_of()` and `around_problem()` disagreed about 1.5.** `around_of()`
  read it as step 1, in the one function written *because* two readings of
  that field drifted apart once already (036). **Not reachable by a player**:
  the schema pass runs `around_problem()` on every step and returns before
  anything is prepared or placed, so no plan carrying a fraction gets that
  far. Closed anyway, and recorded as a divergence rather than a fault.
- **The plan readback read the resolved position and should read the
  request.** Its comment claimed it used *"the same reading the builder uses,
  so the line cannot promise a relationship the placement will not deliver"*,
  and that was false in both directions: *"one inside the other"* for
  `"around": 1.5`, which the schema pass then refused, and *"side by side"*
  for `"around": null`, which plainly asked for containment. Whether a step
  asked to sit inside an earlier one is a fact about the REQUEST, so it is
  read off the request; whether the step number is usable is the validation
  layer's question and `around_problem()` still answers it.

### Implementation

| file | what changed |
|---|---|
| `readback.gd` | **new** `position_said(value, noun)` — the readback layer's reader of the same fact `ordinal_index()` answers for the validator, deferring to `number_said()` (041) |
| `npc_goals.gd` | `readback()` go_to and carry say the room as sent; **new** `_side_said()` so a numbered door side is a position and a named one a name |
| `track_builder.gd` | `readback()` says the corner as sent, and the `corner < 1.0` guard that merged two requests into one sentence is gone |
| `opponent_builder.gd` | a count that is not whole is said as the number it was, instead of spelled as the one below it |
| `dungeon_module.gd` | `_things_said()` resolves through `ordinal_index()`, says an unusable reference as sent rather than dropping it, and its false comment is corrected |
| `world_registry.gd` | `_plan_readback()` reads whether containment was ASKED for; `around_of()` no longer disagrees with `around_problem()` about a fraction |
| `tests/said_position_test.gd` | **new**, 63 failures against the pre-044 code |
| `README.md` | 50 suites → 51, counted with `ls` |

### What the suite asserts, and what it does not (TRAPS 6, TRAPS 14)

- Each readback names the reference **exactly as sent** AND **does not name
  the position below it** — both directions, because a check for what should
  be there cannot see what should not (TRAPS 36, and 043's own first draft).
  The absence test is a regex with a boundary on both sides: *"room 2.9"*
  contains *"room 2"*.
- **The readback and the refusal for the same request name the same number.**
  This is the property that was broken and it is independent of both
  sentences' wording, so either may be rephrased freely and neither may
  quietly change the value.
- **The legal case did not move**: a room name still reads as the name, a
  whole number still resolves to the room's name at a thing's `"in"`, `2.0`
  still reads *"room 2"* and not *"room 2.0"*, a whole count is still spelled
  in words. Saying a reference back as sent is what is owed for a value that
  cannot be used, not a licence to stop resolving.
- `position_said()` against **facts about numbers typed into the suite**, and
  its agreement with `number_said()`, so neither can be changed alone.
- A **sweep** over all six doors and 29 fractional values apiece, independent
  of every assertion above.

**What this suite's own sweep is blind to**, asked in the same breath as
writing it, which is the question 042 raised about every sweep in `tests/`:
the sweep matches *"<noun> <truncated>"*, so it can only see a door whose
pre-044 sentence used the NOUN. SHUT and OPEN did not — they dressed the
number as a name — so the sweep reports 81 truncations against the pre-044
code and **not one of them is at those two doors**. They are caught by the
assertion that the sentence names the reference *with its noun*, which is why
that assertion is there as well as the sweep.

**And this suite's own first draft measured its fixture**, for the third
commit running that a new suite walked into the fault it is about. The SHUT
and OPEN probes put room 1 on the other side of the door and then asserted
*"room 1"* absent, so nine values a door reported a fault that was the
fixture's: **5 failures against the POST-044 code**, which is a suite
reporting on itself. The other side is a name now.

### Evidence — what was actually run

Godot 4.7.1 (`4.7.1.stable.official.a13da4feb`), headless, Linux, in a cloud
container.

- **Baseline, before any change:** 50 suites, **0 with something to look at**.
- **After:** 51 suites, **0 with something to look at**, both without `--all`
  and with it — `drive_test` and `session_test` included.
- `tests/said_position_test.gd` **fails 63 times against the pre-044 code**,
  measured the way 035–043 measured their own: the six changed scripts
  reverted to `abe38dc` with the suite left in place and `position_said()`
  stubbed at exactly what the six doors did by hand (`"%s %d" % [noun,
  int(number)]`) so it parses.
- `said_position_test` was run **both with `--fixed-fps 120` and without** and
  passes either way (TRAPS 4). `run_tests.bat` needed no edit: the name
  matches none of its `findstr` patterns — not `order_test`, not `physics`,
  not `session`, not `ledger`, not `drive`, not `carry_test` — so it runs
  there without `--fixed-fps`, which is what it gets here.
- **THE PROMPT DID NOT MOVE.** Nothing here touches `assembled_prompt()` or
  any `prompt_section()`. Measured at **15846 characters, sha256
  `c6c2b9555fa6283c1f4d379c925ba95a15db8000a2d8e3d7d26d4e9010c46e62`** — the
  same string 041, 042 and 043 recorded, and measured again against `abe38dc`
  in this session to confirm it. `PROMPT_VERSION` is unchanged at
  `039-the-arithmetic-it-really-does-1`, so designs stay comparable across
  this commit.
- README said 50 suites and there are 51, counted with `ls tests/*.gd` less
  `replay` and `prompt_test`.

### Not verified

- **NO MODEL SENT ANY OF THIS.** Every value was typed by hand. This harness
  has no API key. A model writing a fractional room number is not something
  any log in this repository has observed — what 040 observed is that the
  code accepted one — so the *reachability* of these sentences from a live
  model is unmeasured, and that is the honest limit of the whole class.
- **Nothing ran on Windows and nothing ran in the editor.** What was measured
  is the string a function returns, not what a person reads on screen.
- **Whether the new sentences are better PROSE is not asserted and cannot be.**
  *"to put 2.9 opponents on the track"* is faithful and odd. What the suite
  asserts is that it does not name a count the request never carried. If the
  owner would rather such a request were simply refused, that is a change to
  what Genesis DOES and it is his — see "Human decision needed" 12.
- **The `MODIFY_TRACK` door still has no refusal to agree with.** It has no
  validator (036 established that four of eleven commands do not), so the
  suite records a note rather than an assertion there, and the handler still
  truncates the same value and acts on it — `modify_corner(2, ...)` for 2.9,
  which changes nothing because there is no Prototype 001 ring. That the
  handler should refuse instead is "Human decision needed" 12 as well.
- **`around_of()`'s divergence was latent, and that is a claim about the
  schema pass** — read from the code and from `around_problem()` being called
  for every step before anything is prepared, not from a driven plan carrying
  a fraction past it.
- The two `GameController` paths that read `pending_order["room"]` were not
  driven: `GameController` is a `Node3D` no suite can instantiate. They read
  Genesis's own validated goal dictionary, not a request, so they are outside
  this rule — read from the diff, not measured.
- The experiment runner was not run; it drives a live API.
- The records on the owner's disk are his and 044 did not touch them.

---

## 045 — the record that said nothing about what was proposed

**Objective.** The task this file named: *ask every suite in `tests/` what IT
cannot see*, with the four axes 041–044 produced, and with this file's own
prediction that **the readback and the RECORD would be the layers nobody had
probed, "because they return strings rather than verdicts"**. The readback was
044's. This is the record, and the prediction holds.

**Starting state.** Branch `prototype-002a` at **044** (`ed75bbc`). 51 suites,
0 with something to look at, `--all` included, measured before anything was
changed. Godot 4.7.1 (`4.7.1.stable.official.a13da4feb`) headless, Linux,
cloud container, no API key.

**The rule asked, and this file named it as unconfirmed.** TRAPS 25's — *a
command's record is part of the command*. The candidate list said of it:
*"`ledger_said_test` enumerates the whitelist, so this one may well be whole;
worth confirming rather than assuming."* **Confirmed, and it was not whole.**

**What it cost, measured headless before anything was changed** — one request
per whitelisted command through `main._handle_request`, reading the ledger back
off disk as an outsider would:

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

A farm's record carried `world`, `intent` and `command` and **nothing else,
accepted or refused** — so the ledger entry for *"zone 1 (barn): width 500 m is
outside 5–60 m"* did not carry the zone. **`PLAN` is the sharper one**, because
it has a field that looks like the missing one: it writes `record["steps"]` on
the way out, and that is the steps it **did**. A plan refused at step 2 of 3
left an entry naming the problem and never the plan — a construction-layer
field standing where an interpretation-layer one was owed, which is the four
layers merged (PROTOCOL section 2).

**AND THE DATA WAS NEVER LOST, WHICH IS WHY THIS IS A CLAIM ABOUT SHAPE.**
`raw_command` holds the whole JSON answer for every command, so a farm's zones
have always been in the ledger **as a string**. What a reader going BY FIELD
met was a farm that proposed nothing beside eight commands that proposed
something — the same argument 036 and 037 both made about `intent` carrying
three shapes, and the one the owner accepted then. **Nothing in the repository
reads a `proposed_` field except `proposed_metrics`**, so the cost today falls
on a person reading the file and not on Genesis. Checked before it was written
(TRAPS 14): the claim that the proposal was "nowhere" would have been false,
and `grep` for `raw_command` is what said so.

**Why no suite saw it, which is the part worth keeping.** `ledger_said_test`
asks the right question of the right list — does every command in
`CommandParser.allowed_commands()` leave a record whose id the ledger
resolves? — and **its own header says what it does not ask**: *"NOT ASSERTED,
deliberately: no wording anywhere… This asserts that the record EXISTS."* It
is correct, its list is the whole list, and the record's CONTENTS were owed to
nobody: `grep` finds `proposed_` in exactly one file under `tests/` before
this commit, and there it is a fixture in `session_test`. **TRAPS 6 for the
fifth commit running, and this one is not one of the four axes**: 041's blind
spot was the probe's VALUES, 042's the sweep's DIRECTION, 043's the input's
SHAPE, 044's the LAYER, and this one is the **QUESTION** — existence asked
where content was owed.

**Implementation — the class, not the two doors (TRAPS 11).** The three
`proposed_` fields were written out by hand in `DungeonModule.record_fields()`
and the fourth in `RacingModule`'s copy of the same lines, and in neither case
in `WorldModule`, **the base both of them extend**. So the third world
inherited a `record_fields()` that recorded nothing the request arrived with.

- `scripts/world_module.gd` — new `proposal_record(parameters, attempt)`. It
  reads **`lists()`**, the module's own declaration of what a request may
  carry and the list `container_door_test` already enumerates, and writes
  `proposed_<key>` for each entry, plus `attempt` and `revision_of`.
  `record_fields()` merges it. **A world added later records its proposal
  without its author writing a line** — and that half is LATENT, because there
  is no fourth world yet.
- `scripts/dungeon_module.gd` — `record_fields()` **deleted**. The base
  produces the same record, key for key and value for value.
- `scripts/racing_module.gd` — `record_fields()` kept and reduced to the one
  key it still exists for: racing records have never carried `world` and still
  do not. The proposal and the attempt are the shared reading's.
- `scripts/game_controller.gd` — `_execute_plan` writes `proposed_steps`,
  read through `plan_list()` (the one place that names the key), **above every
  refusal below it**, so a plan refused for its intent, its list shape, its
  length or a bad step records its steps like any other command.

**It also made a false comment true.** `Readback.intent_of()` said *"what
`WorldModule.record_fields()` and `RacingModule.record_fields()` each did by
hand… Both readers are now this one."* There were **three**:
`DungeonModule.record_fields()` read `intent` by hand with its own `typeof()`
test. Behaviourally identical, which is how it survived, and false from the
commit that wrote it — TRAPS 14 at a code comment, where 043 and 044 each
found one. The hand-written reader is gone.

**Evidence.** Godot 4.7.1 headless, Linux, cloud container.

- **Baseline: 51 suites, 0 with something to look at**, `--all` included,
  before anything was changed. **After: 52 suites, 0 either way**,
  `drive_test` and `session_test` included. The only difference in the two
  runs' suite lists is `record_proposal_test`.
- **`tests/record_proposal_test.gd` fails 8 times against the pre-045 code**,
  measured the way 035–044 measured their own: the four changed scripts
  reverted to `ed75bbc` with the suite in place. No stub was needed — the
  suite calls `record_fields()`, which exists either way. The failures are
  CREATE_FARM's and PLAN's proposals, CREATE_FARM's attempt and revision, and
  the three "as sent" assertions about a farm.
- **The dungeon's and the circuit's records are unchanged.** Measured as JSON
  before and after, for four cases each (first attempt, revision, empty
  parameters, non-object intent): `dungeon` and `racing` are **byte-identical
  in both runs**; `farm` gains `proposed_zones`, `attempt` and, on a revision,
  `revision_of`. Godot's `JSON.stringify` sorts keys, so insertion order
  cannot change a written line.
- **The prompt did not move**: 15846 characters, sha256
  `c6c2b9555fa6283c1f4d379c925ba95a15db8000a2d8e3d7d26d4e9010c46e62` —
  identical to 043's and 044's, measured again this session. `PROMPT_VERSION`
  is unchanged and designs stay comparable.
- `record_proposal_test` was run **both with `--fixed-fps 120` and without**
  and passes either way, so it is in neither runner's timed list.
  `run_tests.bat` needed no edit (TRAPS 4): the name matches none of its
  `findstr` patterns.
- README said 51 suites and there are **52**, counted with `ls tests/*.gd`
  less `replay` and `prompt_test`.

**What the suite asserts.** That every command on the whitelist leaves a record
carrying its proposal in a `proposed_` field whose value holds what the request
sent — keyed on `CommandParser.allowed_commands()`, so a command added later
with no row **fails** and is never skipped (the guard 033 put in
`ledger_said_test`, which is the suite this one stands beside), with
`CLEAR_WORLD` the single declared exception, named in the table with its
reason rather than left out of it. That for every module in
`WorldRegistry.modules()` and every entry in its `lists()`, `record_fields()`
carries `proposed_<key>` — so a world that declares a list and forgets to
record it fails without this file being edited. That the value is **as sent**:
a 500 m zone, a room number of 2.9, a `zones` that is the string `"a barn"`,
each in the record exactly as it arrived, and an absent list recorded as an
empty list rather than a missing key. And, in both directions, that the
dungeon's seven fields and the circuit's four are the ones they have always
been, typed out here as facts rather than read from the function under test.

**Limitations — what this does NOT prove, asked in the same breath as writing
the suite.**

- **NO MODEL SENT ANY OF THIS.** Every request was typed by hand; this harness
  has no key. No log in this repository records a model proposing a farm that
  was then audited, so whether the new field is ever *read* is unmeasured.
- **It asserts nothing about `raw_command`**, which carried this data all
  along. A suite proving the zones were "in the ledger" would pass against the
  pre-045 code and prove nothing (TRAPS 6).
- **`attempt` on a farm record is latent.** `FarmModule` has no
  `correction_feedback()`, so `_may_revise()` is false and no farm has ever
  had a second attempt. It is asserted as present and correct, which is a fact
  about the record's shape and not a demonstration that a farm can revise.
  `tests/replay.gd` reads `attempt` off a record with a default of 1, so a
  farm's attempt was previously unrecorded and un-replayable — also latent,
  for the same reason.
- **Whether a field helps a person reading the ledger is not a thing a test
  can answer.** The owner reads these files; see "Next action".
- **The base's half is for a world that does not exist.** A fourth world
  getting its proposal recorded for free is read from the code, not measured.
- `CLEAR_WORLD` records no proposal **deliberately**: it takes no fields, so
  there is no value a record could carry. That is a row in the suite's table,
  not a gap.
- Nothing ran on Windows and nothing ran in the editor. What was measured is
  the record a function returns and the line the ledger holds, not what a
  person reads on screen.
- The records on the owner's disk are his and 045 did not touch them. **Every
  `CREATE_FARM` and `PLAN` record in the ledger before this commit carries no
  `proposed_` field**, so an audit by field across this commit is not a
  before-and-after for those two commands; `raw_command` is the field that
  spans it.

TRAPS 39 records the fault and the rules, including the fifth blind spot —
the QUESTION a suite asked — beside the four axes.

---

## 046 — the sentence after a build counted the request

**Objective.** The task this file named: **TRAPS 24's rule**, *a line that
states a count reads it from what was BUILT, not from what was asked*, asked
of every line that states one. This file called it "the last rule in that list
with a function left to count" and "the one axis of the construction layer
nobody has swept", and handed over a starting point marked **READ AND NOT
MEASURED**. The reading was right about where to look.

**Starting state.** Branch `prototype-002a` at 045, 52 suites, 0 with
something to look at (measured, `--all` included, before anything changed).

### The class, and the answer

`stub_claims_test` has held TRAPS 24's rule since 032 — **for the three
Prototype 001 stubs, which place nothing.** Every other line that states a
count about a world that was built, measured headless before anything changed:

```
DungeonModule.summary()   plural(metrics["room_count"], "room")
                          <- measure(layout)["room_count"] <- layout["rooms"].size()
RacingModule.summary()    plural(report["section_count"], "section")
                          <- CircuitBuilder.build(): sections.size()
DungeonModule.build()     report["room_count"]: rooms.size()
FarmModule                no summary of its own; states no count at all
```

**Only where the fault was found, for the sixth commit running** — and, as in
041 through 045, the reason is sharper than the count.

### Two readings in this file were wrong, and one of them is the trap itself

**This file's spot-check called racing clean**, on the grounds that
`CircuitBuilder` "adds a road piece for every section it loops over, so the
count is of pieces placed". **A count of LOOP ITERATIONS is not a count of
placed nodes**, however reliably the two agree — and in the same function
`_add_collision()` returns early on an empty face list, so the builder already
has one way to place less than it looped over, and `sections.size()` could not
have seen it. This is TRAPS 24's own fault one level up: the asked-for number
wearing a result's clothes, in a reading written down as a clean check.

**And this file said `FarmModule` "overrides neither" `summary()` nor
`metric_lines()`.** It overrides `metric_lines()`, and has since 003. TRAPS 14
in this handover, found the way every other instance has been found — by
grepping for the thing the sentence denied, before relying on it.

### What it cost, which is nothing yet, and the commit says so

Measured headless, one legal world per module, counting the nodes in the tree
against the number the sentence states:

```
dungeon  3 rooms stated     3 Room_ slabs placed
         2 doors stated     2 Corridor_ runs placed
circuit  8 sections stated  8 Section_ pieces, 8 RoadBody_, 16 Barrier_
farm     3 zones measured   3 zone nodes placed
```

**Nothing was wrong on any world measured, and 046 claims nothing else.** This
is a latent fault. What was missing was not a correct number — it was any tie
at all between the number in the sentence and the thing it counts, so a
builder that ever stopped placing a piece would have gone on saying it had.

### Why no suite saw it, which is the part worth keeping

`grep` found `.summary(` in **three of the 52 suites, and in none of them was
a world ever BUILT.** All three hand the function a dictionary typed into the
suite:

```
container_door_test   dungeon.summary({"room_count": 2, "door_count": 1,
                                       "loops": 1, ...}, {})
counted_said_test     r.summary(measured, {"section_count": <from metrics>})
capability_test       BootsTool.summary(spec)   — a tool, not a world
```

`container_door_test`'s fixture states `loops: 1` for a dungeon of two rooms
and one door, where `measure()` computes `doors - rooms + 1 = 0`. That is not
a fault in that suite — it asserts a plural rule and any numbers do — and it
is the evidence: **the construction layer's sentence had never been put beside
a construction**, so nothing could have noticed where its numbers came from.
044's axis (what LAYER do the fixtures enter?) at the one layer whose answer
was *none of them*, and a sixth entry for the table of blind spots:

| axis | the question to ask a suite |
|---|---|
| **values** (041) | are its probes all whole, all mid-range, all the same shape? |
| **direction** (042) | can its regex match only one of the two ways this goes wrong? |
| **input shape** (043) | is every fixture taking the one branch that was already right? |
| **layer** (044) | does every probe enter through the same layer of the four? |
| **question** (045) | does it ask whether a thing EXISTS where what is IN it was owed? |
| **was it RUN** (046) | does any fixture ever call the thing the sentence is about? |

### Implementation — the class and not the two sentences (TRAPS 11)

**One reading, on the base**, for the reason TRAPS 10, 23, 37 and 39 each
produced: a fact written out per world drifts per world.

- `WorldModule.mark_piece(node)` marks a node as one member of the list
  `pieces()` names, **called by the builder on the node it has just added**.
- `WorldModule.placed_pieces(root)` counts the marked nodes under `root`, off
  the tree. The count is of nodes that exist, not of loop iterations.
- Each world's `build()` report carries `"pieces_built": placed_pieces(root)`:
  three one-line additions, plus `_slab()`, `_add_slab()` and `_add_building()`
  returning the node they placed so the loop can mark it.
- `DungeonModule.summary()` and `RacingModule.summary()` state that count.
  The counts beside them — `metrics["room_count"]`, `report["section_count"]` —
  **are left alone**: those are what the world was asked for, which is a
  different fact and the one the measurement panel states. Collapsing them
  would be the four layers merged.
- **A world added later that places its pieces without marking them reports 0
  and FAILS** `built_count_test`. That direction is deliberate: a world whose
  sentence nobody has tied to its geometry is more useful loud than quietly
  correct. This half is **LATENT — there is no fourth world.**

### And the fix for false lines nearly introduced one

`GameController._clear_world_node()` calls `queue_free()` on the old world's
children and `_build_world()` calls `module.build(world_node, layout)` on the
next line. `queue_free()` is deferred, so **for part of a frame both worlds
are in the tree.** Measured rather than reasoned about, in the suite: build a
two-room dungeon into a node, `queue_free()` its children, build again —
**four marked nodes stand there.** A count that ignored
`is_queued_for_deletion()` would have told the player a two-room dungeon had
four rooms. `placed_pieces()` skips them; `built_count_test` measures the four
so the reason the check exists cannot be mistaken for caution.

### What the suite asserts, and what it does not (TRAPS 6, TRAPS 14)

`tests/built_count_test.gd`.

**FINDING, and the assertion that fails against the pre-046 sentences:** the
count a world's summary states follows the TREE. A world is built, one marked
piece is removed from the tree, the count is read again, and the sentence must
state the smaller number — and must no longer state the number the layout
declares. Before 046 the dungeon said *"2 rooms"* with one room standing and
the circuit said *"8 sections"* with seven.

**GUARD**, enumerated off `WorldRegistry.modules()` and each module's own
`lists()` and `pieces()`, so a world added later is covered without this file
being edited: a legal world reports `pieces_built`; that number equals the
pieces counted independently off the tree by the suite's own walk; it equals
the size of the list `pieces()` names; and it equals the count the measurement
layer states. The last of those is the one that catches a silent skip: the two
layers agree on every world today and the suite fails if they ever part.

**GUARD, and not hypothetical:** the clear-then-build measurement above.

**A request that validates is not a request that builds.** The circuit's
declared sample is two straights — a legal list, and not a closed circuit, so
the feasibility gate refuses it. The sample is right for what it is for (the
example inside a refusal at the list door) and wrong here, so the suite
declares a buildable `CREATE_TRACK` request keyed on the command, and **a
module that builds from neither its samples nor a declared row is a FAIL and
never a skip** — the shape `ledger_said_test` and `record_proposal_test` both
use.

**NOT ASSERTED.** Nothing here is about WORDING: every sentence in Genesis can
be rewritten and this stays green, because what is compared is a number in the
sentence against a number counted off the tree. Nothing asserts that the
dungeon's DOOR count or the circuit's road LENGTH comes from the tree — they
do not; see below. Nothing asserts the farm says a count: it says none.

### Evidence — what was actually run

Godot 4.7.1 (`4.7.1.stable.official.a13da4feb`) headless, Linux, in a cloud
container, downloaded this session.

- **Baseline before anything changed:** 52 suites, **0 with something to look
  at**.
- **After:** **53 suites, 0 with something to look at**, `--all` included, so
  `drive_test` and `session_test` both ran and both passed. The only
  difference between the two runs' suite lists is the new one (`diff` of the
  two logs' first columns: one added line).
- `tests/built_count_test.gd` **FAILS 4 TIMES** against the pre-046 sentences,
  measured the way 035–045 measured their own: the two `summary()` readings
  reverted to `metrics["room_count"]` and `report["section_count"]` with
  everything else in place. Against the pre-046 code entire it does not parse,
  because `PIECE_META`, `mark_piece()` and `placed_pieces()` do not exist
  there — **recorded that way rather than stubbed**, so the number means the
  sentence and not the scaffolding.
- **THE SENTENCES DID NOT MOVE.** Measured before and after on the same
  worlds: *"CREATE_DUNGEON built 3 rooms joined by 2 doors, one way round / 52
  m of corridor, deepest room 2 doors in"* and *"CREATE_TRACK built a closed
  clockwise circuit: 8 sections, 1114 m of road"*, word for word. Every panel
  line is byte-identical too.
- **THE PROMPT DID NOT MOVE:** 15846 characters, sha256
  `c6c2b9555fa6283c1f4d379c925ba95a15db8000a2d8e3d7d26d4e9010c46e62`,
  identical to 043's, 044's and 045's and measured again this session, so
  `PROMPT_VERSION` is unchanged and designs stay comparable.
- `run_tests.bat` needed no edit (TRAPS 4): `built_count_test` matches none of
  its `findstr` patterns, checked against the file. README said 52 suites and
  there are 53, counted with `ls`.
- Two fixtures were updated, not weakened: `container_door_test` and
  `counted_said_test` now pass a report carrying `pieces_built`. Without it
  `summary()` throws on the missing key and `run_tests.sh` reports a SCRIPT
  ERROR — **so a caller that does not say how many pieces were built is
  loud**, which is why no default was added.

### Not verified

- **NO MODEL SENT ANY OF THIS.** Every request was built from the modules'
  own declared samples or typed by hand; this harness has no key.
- **Nothing ran on Windows and nothing ran in the editor.**
- **The base's half is latent**: there is no fourth world, so "a world added
  later reports 0 and fails" is read from the code and from the suite's
  enumeration, not from a world that exists.
- **The dungeon's DOOR count is still the layout's**, and so is the circuit's
  road LENGTH. Both are deliberate and neither is quietly left: a door's
  construction is a corridor, and whether *"joined by 2 doors"* should count
  corridors or doors is a question about what the sentence means rather than
  about where its number comes from. Measured incidentally and worth knowing:
  with one section removed from the tree the circuit says *"7 sections, 1114 m
  of road"* — the count follows the tree and the length does not. See "Human
  decision needed" 13.
- **The farm still states no count**, because it has no `summary()` of its
  own. A sentence that states no count cannot state a wrong one, so this is a
  silence and not a falsehood, and giving the farm a sentence is a change to
  what Genesis says rather than to whether what it says is true. The tie is in
  place either way: `FarmModule.build()` reports `pieces_built`, so a farm
  that one day says what it built starts out tied.
- **Whether a piece is the right unit** for every world is unasked. A dungeon
  marks room slabs and not corridors, walls, doors or things; a circuit marks
  road pieces and not barriers or collision bodies; a farm marks one node per
  zone and not the roof of a building. Each follows that world's own
  `pieces()` declaration, which is the list it is built from, and a world
  whose interesting count is something else would need its own.

## 047 — four lines in one panel walked a door the body could not

**Objective.** The task this file named: **the sixth axis applied to
`tests/`** — *which suites never RUN the thing they make a claim about?* —
starting, as this file said to, at **the dungeon's measurement panel, because
it is the longest in Genesis, asking of each of its nine lines what the
number is read from**.

**Starting state.** Branch `prototype-002a` at 046
(`3498237`). 53 suites, 0 with something to look at, `--all` included,
measured here before anything changed. The dungeon's panel had never been
produced from a built dungeon: 046 found `metric_lines(` in two of 53 suites,
with the dungeon's nine lines fed a dictionary typed into
`container_door_test` whose `loops: 1` cannot occur.

**What the reading found, and what it did not.**

**On a dungeon as built, nothing in the panel was wrong, and 047 claims
nothing else.** Every one of the nine lines is `measure(layout)`, and every
one of them agrees with the geometry actually placed — measured headless
before anything changed, by walking the tree:

```
  ROOMS          2   doors 1           2 Room_ slabs
  SIZE           29 m by 12 m          29.0 x 12.0 m of placed floor
  ROOM FLOOR     244 m2                244.0 m2 of Room_ slab
  CORRIDOR       18 m long, 88 m2      18.0 m of run, 88.0 m2 of Corridor_
  LARGEST ROOM   hall   144 m2         the biggest slab, 144.0 m2, named hall
```

**The fault is one question along: which doors the lines walk.** Four of the
nine describe getting about — `deepest`, `deepest_room`, `dead_ends`,
`loops` — and all four walked `layout["doors"]`, the dungeon's full list.
`WALKABLE`, the line directly above `WAYS ROUND`, walks the doors a body can
**use**, and so do `route()` and the body itself. `_reachable()` was written
for `pre_check()`, where the request is all there is and nothing can be shut
yet, and `measure()` called it with the same argument.

Measured on a ring of four rooms, headless, with the ring-closing door shut:

```
  DEEPEST     crypt   2 doors from the entrance    the cell is 3 doors away
  DEAD ENDS   0                                    rooms 1 and 4 are
  WALKABLE    4 of 4 rooms reachable               correct: honours the door
  WAYS ROUND  1 loop                               there is no way round
  summary()   "4 rooms joined by 4 doors, 1 way back round"
  route()     1 -> 4: 38 points open, 191 with the door shut
```

**The body had been told what the sentence had not**, on the line under one
that had got it right.

**The second fault is a crash, not a false sentence.**
`walkable()["blocked_doors"]` appended a `Vector2i` for a shut door and a
`String` for a doorway no body fits — one list, two types — and `route()` read
every entry as a `Vector2i`. A blocked doorway therefore **threw inside
`route()`**, which returned `[]`, and the controller reads `[]` as *"There is
no way through to the vault."* A crashed function and a plausible sentence.
Demonstrated in the suite on a hand-built layout: before 047 a dungeon with
one blocked doorway **could not be routed through the doorway that was
clear**.

**Both halves are LATENT. Neither has reached a player.** `measure()` is
called in exactly one place — `GameController._prepare()` — before anything is
built, and `set_shut()` only ever runs on a layout that is already standing,
so the panel a player reads was drawn when nothing was shut. And a doorway no
body fits does not occur from a legal request: **4000 random legal ring
dungeons were solved headless this session, 2597 of them built and
post-checked, and none had one**, which is `sweep_test`'s finding arrived at
from the other direction. What 047 fixes is a panel that would state the
design the moment anything re-measured a standing dungeon, and a `route()`
that throws the moment a corridor can be blocked.

**Decision — the fix is the class and not the four lines (TRAPS 11).**

- `walkable()` returns **`blocked_doors` as door pairs only**, one type, one
  entry per unusable doorway whichever of the two reasons it is, with the
  sentence for each at the same index in the new **`blocked_why`**.
- It also returns **`usable_doors`**, the doors a body can use. `route()` and
  `measure()` both read it, so the path the body walks and the sentence the
  player reads cannot be built from different graphs. `route()` no longer
  derives the list by subtraction.
- `post_check()` appends `blocked_why` rather than `str()` of each
  `blocked_doors` entry. **Its refusal strings for a blockage are
  byte-identical** to the ones it appended before; a shut door cannot reach it.
- `_reachable()` now also returns **`components`**, and the loop count lives
  in one function, **`loop_count(doors, rooms, components)`**, used by
  `pre_check()` and `measure()` alike. The formula moved with it:
  `doors.size() - rooms.size() + 1` was written out by hand in both places and
  was right only because the one graph either had ever been asked about was
  one `pre_check()` had already proved connected. **A door a body cannot use
  can split a graph in two, and then `+ 1` states a way round that is not
  there.**
- The counts beside them are **left alone**: `door_count` is still the
  dungeon's doors, because a shut door still joins two rooms. That is a
  question about what the sentence MEANS, not a fault, and it is "Human
  decision needed" below.

**Implementation.** `scripts/dungeon_module.gd` — `walkable()`,
`_reachable()`, new `loop_count()`, `pre_check()`, `measure()`,
`post_check()`, `route()`. `tests/panel_built_test.gd` is new.
`tests/sweep_test.gd` and `tests/walk_test.gd` had three diagnostic prints
pointed at `blocked_why`, so their failure messages carry the same sentences
they carried before; **neither assertion was changed and neither was
weakened** — both still check `blocked_doors` is empty. `README.md`: 53 → 54
suites, counted with `ls`.

**Evidence.** Godot 4.7.1 (`4.7.1.stable.official.a13da4feb`) headless, Linux,
in a cloud container. Baseline **53 suites, 0 with something to look at**,
`--all` included. After: **54 suites, 0 with something to look at**, `--all`
included, so `drive_test` and `session_test` both ran and both passed, and the
only difference between the two runs' suite lists is the new one.
`tests/panel_built_test.gd` **fails 7 times and throws twice** against the
pre-047 readings — the four getting-about readings and the blocked-doorway
entry type reverted with the 047 scaffolding left in place, the way 035–046
each measured their own. Against the pre-047 code entire it **does not
parse**, because `loop_count()` does not exist there; recorded that way rather
than stubbed. **The sentences did not move**: the sample dungeon's whole panel
and both summaries are byte-identical before and after, and so is the open
ring's, measured on the same worlds. **The prompt did not move**: sha256
`c6c2b955...`, unchanged since 043, held by `prompt_bounds_test` rather than
by a measurement of mine. Run both with `--fixed-fps 60` and without, passes
either way (TRAPS 4). `run_tests.bat` needed no edit: `panel_built_test`
matches none of its `findstr` patterns, checked against the file.

**Limitations — what the tests did NOT prove.**

- **No model sent any of this.** Every request in the suite is built from the
  module's own declared samples, read off `lists()`, or is the ring typed into
  the suite. This harness has no key.
- **Nothing ran on Windows and nothing ran in the editor.**
- **Both faults are latent**, as above, and the suite says so in its header.
  The blocked-doorway half is held against a **hand-built layout**, labelled
  as such in the suite, because no legal request reaches it.
- **The 2597-dungeon sweep is not a proof** that no legal request can ever
  produce a blocked doorway. It is 2597 random ring dungeons with a fixed
  seed, and it agrees with `sweep_test`.
- **`metrics["walk_blocked"]` is still read by nothing** — not a script, not
  a suite, not a sentence. `measure()` counts how many doorways a body cannot
  use and no panel line states it. Adding one would be adding a sentence, so
  it is left and recorded: "Human decision needed" below.
- **The dungeon's door count, and the shut door's new sentence.** A shut door
  still counts in `door_count`, deliberately. And `blocked_why` now carries
  one new string, *"hall to vault: somebody has shut this door"*, which is
  **not a player-facing line today**: the only reader that prints it is
  `post_check()`, which a shut door cannot reach. If it ever becomes one it
  should go through the article rule (043).
- **The suite asserts no wording.** Where a number has to be shown to have
  reached the panel it is looked for as a substring of the rendered value, so
  every sentence in Genesis can be rewritten and this stays green.
- **No record changed and no ledger field moved.** `blocked_why`,
  `usable_doors` and `components` live in function returns;
  `record["reachability"]["loops"]` is computed by the new function from the
  design graph `pre_check()` has just proved connected, and is the same number
  it was. An audit by field across this commit is not a before-and-after.

**Next action.** See "Next action" below: 046's axis has one question left in
it that this commit only half asked.

---

## 049 — the panel was right, and the gate was not

**Objective.** The task this file named: the farm's panel and the circuit's
panel, against the geometry they describe. 047 tied the dungeon's nine lines
to the slabs in the tree and left the other two panels checked against
nothing — `counted_said_test` feeds both `measure(solved["layout"])`, a
layout and not a construction.

**Starting state.** `prototype-002a` at 047. 54 suites, 0 with something to
look at, `--all` included, measured in this container before anything was
changed. **048 (`5d36bfb`) landed from another run of the same task while
this work was in progress**; 049 was rebased onto it, renumbered, and the
whole suite re-run on the merged tree — 56 suites, 0 with something to look
at. The two commits touch no file in `scripts/` in common.

**What the audit found: both panels are true about the world they describe.**
Measured headless before any change, by building each world and walking the
tree — counting the pieces, adding up the slab areas, and measuring the road
surface from the committed mesh vertices rather than from any function under
test:

```
FARM (9 zones, every zone type)       panel            walked out of the tree
  ZONES                               9                9 marked pieces
  SIZE                                141 m by 126 m   141.0 x 126.0 Ground slab
  ENCLOSED                            1.8 hectares     1.78 ha of that slab
  WORKED LAND                         0.6 ha  (36%)    0.64 ha, 36.0% of it
  CROPS            wheat 0.2, barley 0.2 ha            0.40 ha of crop_ slab
  BUILDINGS                           484 m2           484 m2 of building slab
  WATER                               500 m2           500 m2 of pond slab
  FENCE                               534 m            534 m of rail

CIRCUIT (8 sections, vertical + banked)
  SECTIONS                            8                8 marked road pieces
  LENGTH                              1177 m           1176.91 m of road surface
  STRAIGHT RATIO                      68%              68.0%
  LONGEST STRAIGHT                    200 m            200.02 m
  SHORTEST STRAIGHT                   200 m            199.98 m
```

The circuit's `LENGTH` is the line this file singled out as **read and not
measured** — *"known not to follow the world"*, on the strength of 046's
record that it comes from the layout. **Measured, it follows the world**:
1176.91 m of road surface against 1176.99 m stated, an 8 cm gap in 1177 m.
That is the road being drawn as chords between samples `SAMPLE_SPACING` = 4 m
apart; the arc is always a little longer than the chords that approximate it.
It is a discretisation, not a disagreement, and `panel_geometry_test` states
the tolerance as a fraction with that reason beside it rather than hiding it
in an `is_equal_approx`.

**THE FAULT IS NOT IN EITHER PANEL.** It is in the farm the panel describes,
and the audit's own question is what found it: *what fact does this line
read?* — asked of every line, and then of the one number in the farm's
layout that **no line reads at all**.

**The finding: a farm a plan has grown has no gate.** `FarmModule.solve()`
lays out the zones, fences the lot and cuts a gate into the south side,
recording the gate as a point. `_fence()` exists because that fence can move:
a plan calls `grow_to()` and `grown()` pushes the boundary out about the
middle, so `build()` asks where the fence actually goes. **It did not ask
where the gate goes.** `build()` handed `layout["gate"]` to `_add_fence()`,
which skips the posts within half a gate's width of it — and on a grown farm
that point is the OLD fence line, tens of metres inside the new one, so no
post is near it and none is skipped.

```
a farm of a barn and a wheat field, before 049

  as solved            fence -32..32 by -45..45     gate (0, 45)
                       10 posts on the gate's line, widest gap 16.0 m
  grown to 260 x 260   fence -130..130 both ways    gate (0, 45)
                       0 posts on that line, widest gap 0.0 m in all 132
```

**Reachable by typing, which is why it is a finding and not a note.**
`grow_to()` is called by `GameController._prepare()` for any plan that puts
one world inside another, and the farm is always the container, because
racing opts out through `can_grow()`. *"a dungeon with a hall and a vault,
inside a farm with a barn"* is a request this file records as working (032,
036). What keeps it quiet rather than loud: **the fence carries no
collision** — no `StaticBody3D`, no `CollisionShape3D` anywhere in the
module, checked by grep — so the way in was missing from the picture and not
from the physics. And the comment over `solve()` was still saying *"a gate
cut into the south side"*, false for a plan's farm since 003 made the farm a
container (TRAPS 14, in a code comment).

**Why no suite saw it.** `capability_test` calls `grow_to()` and asserts the
farm reports the bigger extent. **Nothing built the grown farm and looked at
it.** That is 046's axis — *does any fixture ever call the thing the sentence
is about?* — at the one thing in the farm's layout that no sentence states.
Which is the general lesson and it is sharper than the fault: **the number no
panel line prints is the number nothing has ever checked.** The farm's panel
has eight lines, every one of them right.

**Implementation.**

- `scripts/farm_module.gd`: `_gate(layout)` beside `_fence(layout)`, returning
  the gate on the south side of the fence that is being **built**, with the x
  as `solve()` proposed it — growth is about the middle and `solve()` centres
  the farm on the origin, so a gate in the middle of the south side stays in
  the middle of it. `build()` reads it. On a farm nobody has grown it returns
  `layout["gate"]` itself, so **no farm anybody has ever built changes by a
  centimetre** — measured, the ungrown case is unchanged in post count and in
  gap width. The gate's width is now `GATE_WIDTH` on the module rather than a
  local in `_add_fence()`, so the suite can assert the gap is the gate's width
  without typing 12 (TRAPS 31).
- **The rule is the class and not the gate (TRAPS 11):** *anything a world
  positions against its own boundary is read from the boundary that is BUILT.*
  Audited across both worlds that can grow. The farm's zones are deliberately
  left where they are and never touch the fence (that is what growth is for,
  and `panel_geometry_test` asserts it). The dungeon positions its rooms and
  corridors against each other, and only its `Ground` pad against the grown
  bounds — through `grown()` already. **So the gate is the one member, and
  the audit is written into `_gate()`'s comment so a third world does not add
  a second.**
- `scripts/track_metrics.gd` and `scripts/track_geometry.gd`: `TrackMetrics`
  carried its own `STRAIGHT_FAMILY` and `YAW_TYPES`, where
  `closure_solver.gd`, `feasibility_gate.gd` and two suites all read
  `TrackGeometry`'s — and `feasibility_gate.gd`'s own comment says *"the type
  lists come from TrackGeometry, so the gate, the solver and the metrics
  agree"*. **The copies were byte-identical, so nothing was ever mismeasured
  and 049 claims nothing else.** What was wrong is that the four panel
  readings that depend on which sections are straight and which turn — the
  straight ratio, the longest and shortest straight, the direction change —
  were decided by a list nothing else in Genesis obeyed, in the file whose own
  header warns that a new section type has to be added in four places. One
  reading (TRAPS 36). `CURVED_TYPES`, which only `TrackMetrics` had, moved to
  `TrackGeometry` beside the others, because which sections curve is a
  question about geometry. **And a fourth copy in the same file was the one
  with teeth** (TRAPS 11 — the class, not the three it was found at):
  `measure()`'s `counts` dictionary was a literal of all ten types, and
  `counts.has(t)` decides whether a section is counted at all, while
  `RacingModule._counted()` — which renders the parenthetical after
  `SECTIONS` — already enumerates from `SectionValidator.SECTION_TYPES` and
  reads `counts.get(type, 0)`. A type added to the validator and not to that
  literal would have made the panel say *"0 loop_segments"* on a circuit with
  one, **on the same line as a SECTIONS count that included it.** It now
  enumerates from `SECTION_TYPES`. Byte-identical today: the literal held all
  ten.
- `tests/panel_geometry_test.gd`, new, 119 assertions.
- `docs/TRAPS.md` trap 43. `README.md`: 54 suites → 55, counted with `ls`.

**Evidence.**

- **Baseline, before any change**, Godot 4.7.1 headless
  (`4.7.1.stable.official.a13da4feb`), Linux, cloud container, `--all`:
  **54 suites, 0 with something to look at**, `drive_test` and `session_test`
  included.
- **After: 55 suites, 0 with something to look at**, `--all`, both slow
  suites included. The two runs' suite lists were **diffed** and the only
  difference is `panel_geometry_test`.
- `panel_geometry_test` **fails twice** against the pre-049 gate with the rest
  of 049 in place — *"the gap in those posts is at least the gate's width
  (8.1 m, gate is 12.0 m)"* and *"the gap is where the gate was cut, across
  the middle (-125.9 vs 0.0)"*, which is one post spacing on the far corner of
  a 260 m side rather than a gateway. Against the **pre-049 code entire it
  does not parse**, because `FarmModule.GATE_WIDTH` and
  `TrackGeometry.CURVED_TYPES` do not exist there; recorded that way rather
  than stubbed, as 046's and 047's were.
- Run with `--fixed-fps 60` and without, and passes either way (TRAPS 4).
  `run_tests.bat` needed no edit: every one of its sixteen `findstr` patterns
  was run against the name `panel_geometry_test` and none matches, so it runs
  on Windows without `--fixed-fps` as it does here — checked by running the
  patterns, not by reading the list.
- **No sentence moved.** The farm's eight panel lines and the circuit's nine
  are byte-identical before and after, measured on the same worlds, and so is
  the circuit's build sentence (*"CREATE_TRACK built a closed clockwise
  circuit: 8 sections, 1177 m of road"*). **The prompt is byte-identical**, so
  `PROMPT_VERSION` is unchanged — held by `prompt_bounds_test` rather than by
  a measurement of mine.

**Limitations.**

- **NO MODEL SENT ANY OF THIS.** Every request in the new suite is typed into
  it and labelled as such, or read off the module's own `lists()`. This
  harness has no key. Nothing ran on Windows and nothing ran in the editor.
- **The ungrown farm was already right**, and 049 does not claim to have
  fixed anything a player has seen in a single-world farm. What is fixed is
  the farm a PLAN builds, and no plan was run end to end through
  `GameController` in this session: the growth was done through
  `grow_to()`, which is the module API the controller calls, and that is one
  layer in from the request.
- **The rail still runs across the gate**, on every farm, grown or not —
  measured, the rails of a 44 × 44 m farm add up to 176 m, exactly its
  perimeter. So a gate is a gap in a row of posts with a rail through the
  middle of it. What a gate should look like is a sentence about the world and
  it is "Human decision needed" 15, not a commit.
- **The one-reading fix changed no number**, and a before-and-after of any
  circuit measurement across this commit is therefore not a before-and-after
  of anything: the two lists were identical. It is a guard against a type
  added in one place, and the suite asserts the consequence rather than the
  lists.
- **The chord tolerance is a real looseness.** `panel_geometry_test` holds the
  circuit's lengths to 0.5% because the road is drawn as chords. A builder
  that placed a road 0.4% short of the length the panel states would pass. The
  alternative — measuring the arc the way the panel does — would be the suite
  recomputing the thing under test, which is what 046 and 047 were about.
- No record changed and no ledger field moved. The records on the owner's
  disk are his and 049 did not touch them.

**Next action.** See "Next action" below, and note that the first entry there
is no longer 049's: **048 brought an owner finding with it** — there is no
way to ASK Genesis anything — and that outranks the panel work. 049's own
follow-on, the panel beside a REFUSAL and the layout fields no sentence
reads, is the entry under it.

## 050 — the question Genesis has no door to, and the net that called the true answer false

**Objective.** The task this file named as the next assistant task and as the
one that **outranks everything else on the list, because it is the owner's**:
*there is no way to ASK Genesis anything*. Found on his machine on 2026-10-16
with a live key, recorded in `5d36bfb`'s message: *"show me the dungeon
metrics"* came back a **SHUT** and *"where is the red key now"* came back
**UNSUPPORTED**. This file set the shape of the work — read the two refusals
and what produced them, measure which facts are already reachable without a
new command, and write the options into "Human decision needed" — and said
twice, **do not add a command**. None is added. What a query door should be
is a change to what Genesis IS and it is "Human decision needed" 16.

### What the measuring found, headless, before anything changed

**One. Genesis has both answers and no door to either.** `measure(layout)`
returns every number *"show me the dungeon metrics"* asks for, and
`room_of(layout, position)` is how *"where is the red key now"* is answered
every time a delivery is judged — `GameController` takes the thing node's
position, puts it through `room_of()` and compares (`game_controller.gd:260`
and `:366`). `CommandParser.allowed_commands()` has **eleven** entries and
every one builds, changes or removes something. **The missing thing is a
door, not a fact**, which is what makes a refusal that denies the capability
false and a refusal that denies the command true.

**Two, and this is the cause of both of the owner's answers: the prompt left
the model no honest refusal.** It binds a refusal's REASON to *"name the part
that is missing, **from the list above**"*, and that list had no entry for a
question — measured, the assembled prompt contained *"question"* **0** times
and *"query"* **0** times in 15846 characters — while the list above it says
*"It MEASURES everything it builds"* and *"Never say Genesis cannot do one of
them"*. That leaves a model exactly three moves: invent a reason, deny a
listed capability, or send the nearest command on the whitelist. **Both
answers the owner got are on that list of three**, and so is the false
refusal 048 caught in the same session.

**Three. And the checker called the true answer false.** 048 widened that
capability's net from a phrase list to a PAIR of ideas, because a claim
survives rewording and a phrase does not. Measured before anything changed,
**three of the nine true refusals of a question in the new suite were flagged
as understating Genesis**, one of them by the entry whose own rebuttal has
said since 048 that *"a refusal about THAT is right"*. The exception was
written in prose and implemented nowhere. **And `log_023_test` was guarding
the wording rather than the claim**: it has asserted since 048 that *"there
is no command for asking where a thing is; the panel shows it"* is left
alone, and it was — but only because that sentence happens to contain no word
from either list. Reworded as *"there is no way to ask Genesis to report the
position of a thing"*, the same true claim was caught.

### Implementation — the class, not the sentence (TRAPS 11)

- **`refusal_check.gd`**: a capability word standing **after** an asking word
  is not being denied; what is being denied is the door to it. Order is what
  makes it safe, the same way order makes the negation frame safe — *"Genesis
  cannot report where a thing is, so asking is pointless"* still flags,
  because the capability word comes first. For the pair form, **both** halves
  must stand after the asking word.
- **The mark is per capability and the audit is written above the list**, so
  a later entry does not have to guess. The question asked of all seven was
  *is there anything the player can type that produces this on demand?*:
  **measurement** (the panel is drawn when a world is built and nothing
  redraws it) and **verification from the world** (a thing's position is read
  when an errand is judged and at no other moment) have no such door; the
  other five do — `ORDER`, `PLAN` with `around`, `/save`, `/load`, `/log`,
  `/worlds`, `/session end`. An asking word excuses nothing in those five.
- **`query` is deliberately not an asking word.** It is in the same entry's
  ACT list, where it means the act of reading the world, and *"Genesis cannot
  query the world state"* is one of the false refusals this file exists to
  catch.
- **`ai_interpreter.gd`**: the CANNOT list gains the one limitation it did not
  have — Genesis cannot be ASKED anything; there is no command for a
  question; the measurements are shown when a world is BUILT and a thing's
  position is read when an errand is judged; so the reason is *there is no
  command for asking*, never that Genesis cannot measure, cannot read the
  world or cannot report what it finds. It also says that a request for a
  world AND a question about it is still built, with the question named as
  the part dropped — the prompt's existing rule, applied to the new case.
  `PROMPT_VERSION` moves to `050-no-command-for-a-question-1` and
  `PROMPT_FINGERPRINT` with it.

### Evidence — what was actually run

Godot 4.7.1 headless on Linux (`4.7.1.stable.official.a13da4feb`), in a cloud
container. **Baseline at 049: 56 suites, `--all`, suites with something to
look at: 0. After: 57 suites, `--all`, suites with something to look at: 0.**
The suite lists were **diffed** rather than eyeballed and the only difference
is `asked_test`.

`tests/asked_test.gd` **fails 4 times against the pre-050 code** — three true
refusals of a question flagged as understating Genesis, and the marks absent
— measured by stashing the two script changes and running the new suite
against the committed ones. It runs with `--fixed-fps 60` and without and
passes either way (TRAPS 4). `run_tests.bat` needed no edit: all sixteen of
its `findstr` patterns were RUN against the name `asked_test` and none
matches, so it runs there without `--fixed-fps` as it does here.

What the suite asserts is **facts, not wording**: the eleven commands that
answer nothing (read from `CommandParser`, so a twelfth fails it and the
message says to take the limitation out of the prompt and the marks off
`RefusalCheck`); that `measure()` and `room_of()` already answer the owner's
two questions, on a dungeon solved in the suite rather than typed into it;
and the checker's truth table in all three directions — true refusals of a
question left alone, false claims still caught however worded, and an asking
word excusing none of the five capabilities that CAN be asked for.

### What the tests did NOT prove

- **No model sent any of this.** Every refusal in the suite was typed into
  it, except the one quoted from `5d36bfb`. This harness has no key, so
  whether the new prompt line actually stops a model turning a question into
  a SHUT is the owner's editor session and nothing else.
- **Nothing was reproduced from the owner's session.** The SHUT and the
  UNSUPPORTED are read from `5d36bfb`'s commit message. Which of his two
  questions produced the false refusal 048 caught is **not recorded**, and no
  claim is made here about which.
- **The prompt is longer, which is a cost.** 15846 → 16555 characters. Nothing
  measures whether a longer CANNOT list makes the model refuse more.
- **No behaviour changed for a request that is not a question**, and nothing
  measured says otherwise: the 56 suites that passed before pass unchanged,
  including `log_023_test`'s fifteen honest refusals and its four reworded
  lies.
- **A hole stays open and is named rather than widened:** *"you cannot ask
  for a record of what happened"* is caught by nothing, because *"a record
  of"* is not in that entry's word list. Checked against the pre-050 matcher
  as well, so it is a pre-existing gap and not something 050 made. Adding the
  phrase would be the fourth phrase, which is the move 048 decided against.
- **No record moved and no ledger field changed.** But `prompt_version` does:
  a question asked under `050-no-command-for-a-question-1` is not comparable
  with one asked under `039-the-arithmetic-it-really-does-1`, which is what
  that string is for. The records on the owner's disk are his and 050 did not
  touch them.

## 051 — the panel beside a REFUSAL, and the layer each of its lines reads

**Objective.** The task this file named as the next assistant task: *the panel
beside a REFUSAL, and the fields no sentence reads*. 047 and 049 between them
put every panel line of all three worlds beside the geometry it describes,
**for a world that was BUILT**. `main.gd:996` draws the panel from a second
place as well — `record.get("metrics", record.get("proposed_metrics", {}))` —
so a request that was REFUSED gets a panel too, under the line *"(measurements
below describe the proposal, not a built track)"*. This file said nothing in
`tests/` had ever produced that panel, that the caveat is what makes it
honest, and it asked two questions: **does every line stay inside what that
caveat covers, and is the caveat shown in every case it is owed?**

### Both had an answer and both answers were no

**THE CAVEAT IS OWED ON A CONSTRUCTION FAULT AND WAS DRIVEN BY VALIDATION.**
A record keeps Genesis's four evidence layers apart, and the caveat is a
claim about the CONSTRUCTION layer: *"not a built track"*. It was behind
`if not valid`, which is the VALIDATION layer. The two disagree on a real
record: a plan works every world out before it builds any of them, so a plan
refused after a step has been worked out emits that step's record with
`result: VALID` — the proposal was fine — and `construction: FAILED` —
nothing was built. Measured headless before anything changed, a plan whose
step 2 will not validate, step 1 a dungeon of a hall and a vault:

```
RESULT      Valid dungeon                   <- in GREEN
ROOMS       2   doors 1                     <- ten measurement lines of a
SIZE        42 m by 20 m   (slots 26 m)        dungeon that does not exist
ROOM FLOOR  544 m2
...
                                            <- NO caveat
                                            <- NO reason either
```

Both were skipped for exactly the record they exist for. Reachable two ways:
a step that will not validate, and **two worlds with no `"around"`, which is
the shape of the prompt's own PLAN skeleton** — `game_controller.gd`'s own
comment at the pass-3 clear says so.

**AND THE WORLD THAT WAS NAMED WHERE THERE WAS NONE**, which is the half a
player meets with no plan at all. `record.get("world", "circuit")` — and
`world` is written by `WorldModule.record_fields()`, so it is absent from
every record that is not a world. Measured, driven through `GameController`:

```
EQUIP a car   result=VALID   no `world` key   RESULT  Valid circuit
ORDER go_to   result=VALID   no `world` key   RESULT  Valid circuit
CLEAR_WORLD   result=VALID   no `world` key   RESULT  Valid circuit
```

The last is the sharpest: **the command whose whole job is to take a world
AWAY, reported in green as a valid circuit.**

**AND THE DEFAULT HAD NEVER BEEN DORMANT, which is why reading the circuit
would never have found it.** `RacingModule.record_fields()` deliberately
omits `world` — racing records have never carried it, `record_proposal_test`
asserts they still don't, and the owner's ledger stays comparable across
releases because it is left alone. So `"circuit"` fired on **every circuit**,
where it was right. A default that is correct for the one case it was written
for is satisfying to check and tells you nothing.

**AND A VERDICT WAS PRINTED FOR A RECORD THAT HAS NONE.**
`record_load_check()` writes the only emitted record with no `result` key: it
carries an `outcome`, because it judges a world that came back off disk
rather than a proposal. `if valid … else FAILED` has no case for an absent
verdict, so a load check whose outcome was **SAME** read
**`RESULT  FAILED: `** in red, with an empty category where the reason should
be. Pre-existing and identical before 051.

### Why nothing had asked, and it is the part worth keeping

All four of the panel's decisions were inline in `main.gd._on_track_measured`,
which needs a `RichTextLabel` and a running UI. The MODULES' lines were
reachable — `panel_built_test` and `counted_said_test` call `metric_lines()`,
and 047 and 049 measured every one of them against built geometry — and the
decision about **which world the panel is describing** was reachable from
nothing. The audit that found 049's gate asked *who reads this field?*; this
one is the same question asked of a reader instead of a field: **who can
reach this decision?**

### What changed — the rule, not the three instances (TRAPS 11)

`WorldRegistry.panel_lines(record)`, beside `readback()` for the reason
`readback()` is there (`Readback` is a leaf and composing a panel needs the
modules). It returns one entry per line, each carrying the **role** it plays,
and `main.gd` maps a role's kind to a colour and prints. The rule it
implements:

- **RESULT is the validation layer.** *"Valid dungeon"* is a claim about the
  PROPOSAL, so it keeps `result` — and is printed **only when the record has
  one**.
- **The caveat and the REASON are the construction layer**, so both read
  `construction`, through the one function `panel_built()`.
- **A record with no `construction` is not built**, and a record with no
  `result` has no verdict. Missing evidence must not become success — the
  direction PROTOCOL fixes, applied to a panel line.
- **A world is named by `display_name()`**, the one function that names a
  world (032's rule). That covers all three worlds without reading a ledger
  field at all, which is what lets the circuit be named correctly while its
  record still carries no `world`. `world` is the fallback for the one record
  that sets it and has no module — a `PLAN` says *"plan"* — and anything else
  is named by its `command`.

**Nothing was added to the circuit's ledger record**, and that was checked
before it was decided: the omission is deliberate, documented in
`racing_module.gd` and asserted by `record_proposal_test`. Writing `world`
there would have been the obvious fix and the wrong one (TRAPS 14, in the
direction that says grep before changing).

### Evidence — what was actually run

Godot 4.7.1 headless on Linux (`4.7.1.stable.official.a13da4feb`), in a cloud
container.

- **Baseline at 050: 57 suites, `--all`, suites with something to look at: 0.**
- **After 051: 58 suites, `--all`, suites with something to look at: 0**, so
  `drive_test`, `session_test`, `outgoing_world_test`, `panel_geometry_test`,
  `asked_test` and the new `panel_refused_test` all ran and all passed. The
  suite lists were **diffed** rather than eyeballed; the only difference is
  `panel_refused_test`.
- **`tests/panel_refused_test.gd`: 90 assertions, and it fails 11 times
  against the old decisions.** Measured by restoring the three pre-051
  readings inside the new function and running the suite against them, which
  measures the FAULT rather than the move: the caveat and the reason absent
  on the unbuilt plan step, four rows of the construction truth table, the
  absent-`construction` case, `CLEAR_WORLD`, `EQUIP` and `ORDER` all naming a
  circuit, and the load check's invented verdict.
- Run with `--fixed-fps 60` and without; passes either way (TRAPS 4).
- `run_tests.bat` needed no edit: all **sixteen** of its `findstr` patterns
  were RUN against the name `panel_refused_test` rather than read off the
  list, and none matches — so it runs there without `--fixed-fps`, which is
  what it got here.
- README said 57 suites and there are 58, counted with `ls tests/*.gd` less
  `replay` and `prompt_test`.
- **Six panels were dumped line by line before and after — label, value and
  colour kind — and DIFFED**: a dungeon, a farm and a circuit BUILT, and the
  same three REFUSED. **The diff is one line.** Every built panel is
  byte-identical and so are the two refusals that show no measurements; the
  single difference is the refused circuit's caveat, which now reads *"not a
  built circuit"* where it read *"not a built track"*, because the name comes
  from `display_name()`. That is the only sentence 051 changes for a request
  that could already reach the panel — everything else it changes is a line
  that was previously absent, or present and false.

### What the suite asserts, and what it does not (TRAPS 6, TRAPS 14)

**Nothing in it asserts a sentence.** *"The caveat says the measurements
describe a proposal"* tests nothing — it would pass against a panel that
caveated every record and against one that caveated none. So every line
carries its ROLE and the suite asks for roles: is there a caveat, is there a
reason, is there a verdict. About the one thing the panel NAMES it asks
whether the name belongs to this record, never how the sentence is phrased.

It asserts the fault through the real pipeline and not from a record typed
into it: the plan is executed by `GameController` and the unbuilt step's
record is the one `GameController` emitted. The construction verdict is asked
as a **truth table over both fields**, all eight combinations, so neither can
be the one that decides by accident. The command sweep is over
`CommandParser.allowed_commands()` and the worlds over
`WorldRegistry.modules()`, so a twelfth command or a fourth world is asked
the same questions without the file being edited — and a new command with no
request in the suite **fails** rather than being skipped.

### Not verified

- **NO MODEL SENT ANY OF THIS.** Every request in the suite and every request
  in the measuring was typed by hand; this harness has no key. Nothing was
  reproduced from the owner's screen.
- **NOTHING WAS SEEN ON A SCREEN.** The panel was measured through
  `panel_lines()`, which is what `main.gd` now prints, but no `RichTextLabel`
  was rendered and no colour was observed. That the roles map to the colours
  they used to is read from a four-case `match` and asserted only to the
  extent that every kind is one of the four `main.gd` has a branch for.
- **The green panel of an unbuilt world was never DWELT on.** In the running
  game the step records are emitted in the same frame as the plan's own
  refusal, which clears the panel and redraws it, so a player would have seen
  the wrong panel flash rather than sit there. 051 fixes it the way 047 fixed
  a latent fault: the panel is now right whether or not something follows it.
  **What is NOT latent is the EQUIP, ORDER and CLEAR_WORLD naming**, which is
  the last thing drawn and sits there until the next request.
- **A load check's panel now shows one line** — *"REQUESTED not stated"* —
  and whether that is better than a false red FAILED is not a judgement a
  test can make. "Human decision needed" 17(a).
- **No record moved, no ledger field changed and no `prompt_version` moved.**
  The AI prompt was not touched: 051 adds no capability and denies none, so
  there is nothing for it to say. An audit by field across this commit is not
  a before-and-after of anything.
- **AND ONE FAULT WAS FOUND AND LEFT**, measured and written up rather than
  fixed: a plan refused in pass 3 appends **two ledger lines under the same
  id**, one saying `construction: BUILT` and one saying `FAILED`, because the
  clean-up block mutates the same dictionary and appends it again. Four lines
  for two worlds, measured. It breaks this project's own rule that history is
  added to and not rewritten, and `ledger_audit_test` indexes by id so
  nothing would catch it. The three options are "Human decision needed"
  17(c), and the records on the owner's disk were not touched.

## 052 — the layout keys nothing reads, and the clearance that named no dimension

**Objective.** The task this file named as the next assistant task: *for
every world, list the keys its `solve()` writes into the layout, and ask of
each one WHO READS IT* — with the class question set beside it, *is a layout
a RECORD of what was decided or an INPUT to the builder?*, because that
decides whether a key with no reader is dead weight or documentation. 051
enumerated the three layouts by grep and left one key behind:
`FarmModule.solve()` writes `"lane_width"` and `grep` across every file in
the repository finds it in that one line.

**Starting state.** Branch `prototype-002a` at `2b15d17` (051). 58 suites,
`--all`, **0 with something to look at**, measured in this container before
anything was changed.

### The class question, answered rather than argued

051 had already checked the half that decides it: **nothing serialises a
layout.** `WorldStore` saves *"the description that made it"* — `command`,
`parameters`, `metrics` — and `grep` for `layout` in `world_store.gd` and
`track_log.gd` finds nothing. So a layout is produced by `solve()`, consumed
by the module, and does not survive the frame. **It is an INPUT**, a key with
no consumer is dead weight rather than a record of anything, and of the three
choices this file named — drop it, give it a reader, label it — *give it a
reader* is the one the repository's own shape asks for. This file also named
the reader it would be: `_check_reachable()`, reading the lane width it is
checking for rather than assuming one.

### It was not assuming one. It was comparing against 0.5

`FarmModule._check_reachable()` is the farm's version of *"the circuit must
close"*: the module's header says a farm you cannot drive a tractor around is
refused, and this is the check behind that claim. It decided an edge was
clear unless a neighbour stood **within half a metre** of it — four `absf()`
tests against a bare literal with no name on it. `LANE_WIDTH` is **6 m**. The
test admitted a gap **one twelfth** of the thing its own comment calls a
lane, and the number it should have compared against was in the layout it was
handed, read by nothing.

### What it cost, measured headless before anything was changed

**Nothing yet, and this says so rather than dressing it up.** 468 legal farms
were swept — every zone type, random sizes through the legal range, counts
from 1 to the maximum of 24, plus every type at both ends of its range —
and **`solve()` never leaves two zones closer than 6.0000 m**. The failure
branch is **not reachable from any request a player can send**: the only
producer of a farm's zone coordinates is the solver that spaces them, and the
prompt tells the model *"Do not give positions"*. So both thresholds agree on
every farm that exists, and re-swept after the change, **468 of 468 still
solve and none is refused**.

What was wrong is that the guard did not guard what it names. A packing
change that put zones 0.6 m apart would pass it. `limits_test` has asserted
from the other side that the SOLVER leaves a lane; that the CHECK requires
one was asserted nowhere, so the two halves could drift apart without a suite
moving. This is the shape `sweep_test` reports out loud about
`FAILED_UNWALKABLE`, and the farm's is the second known member.

### The fix is the class, and the project had already been right twice

TRAPS 11, by way of 040's question — *where has this project already been
RIGHT once?* Genesis has **three** clearance checks, one per world:

| world   | check                        | compares against |
|---------|------------------------------|------------------|
| circuit | `SeparationCheck`            | `MIN_SEPARATION`, which **is** `ROAD_WIDTH + SAFETY_MARGIN` |
| dungeon | `walkable()`                 | `BODY`, the body's own width, reported back in the result |
| farm    | `_check_reachable()`         | **`0.5`** |

The rule — **a clearance check compares against the dimension it is about** —
now holds at all three, and all three facts are asserted, so the two that
were already right cannot quietly stop being right either.

### Implementation

- `scripts/farm_module.gd`. `_check_reachable()` reads
  `float(layout["lane_width"])` — **no default**, because `solve()` writes the
  key into every layout it returns and a default would be a claim that a
  layout without it is legal (TRAPS 45). The four flush tests became **one
  rule**: an edge has a lane along it when the strip of ground one lane deep
  outside that edge is clear of every other zone, tested with
  `Rect2.intersects()`, which also blocks on an **overlap** — the case the
  four tests could only see when it was within half a metre of exact. A
  `LANE_TOLERANCE` of a centimetre keeps float error on an exactly-a-lane gap
  from reading as blocked.
- The module header. It claimed *"every zone must touch a lane, **and every
  lane must connect to the gate**"* and **nothing checks the second half**
  (TRAPS 14, in a comment). It is true of every farm — the zones sit `MARGIN`
  12 m inside the fence, so the ring between them reaches every lane and the
  gate is cut in it — and it is true **by construction, not by test**. The
  header now says so at the width of the check that exists.
- `README.md`: 58 suites → 59, counted with `ls`.

### The suite, and it could not fail, twice

`tests/layout_key_test.gd`, **64 assertions**. The reader sweep is
mechanical: worlds from `WorldRegistry.modules()`, keys from the layout
`solve()` actually returned, and the reader surface found by **reflection**
over `get_method_list()` — every method of the module taking one `layout`
argument, so a check added to a world later is part of the surface without
this file being edited — plus `build()` into a real tree. Each key is
perturbed and the module asked again. A world with no fixture, and a layout
key with no declared perturbation, **FAIL rather than being skipped**, so a
fourth world and a new key are both asked. `min_extent` is asked on a layout
that has been grown, which is the only kind that carries it.

**And it passed against the pre-052 code it was written to fail against.**
The signature included the built tree, and two things in it differ between
two builds of the SAME layout: a node its builder did not name is given a
generated one with a **global counter** in it (`@MeshInstance3D@57` — the
farm's fence posts), and a build report that carries a node prints that
node's **instance id**. Every key therefore "changed something". Found by
running the suite against the committed module and reading the output, not by
reading the suite. The signature now uses the class name where a builder left
a node unnamed, strips instance ids, and **the first thing the sweep asserts
is that the same layout signs the same way twice** — the check on the check,
and it is there because this suite failed it.

### Evidence — what was actually run

Godot 4.7.1 headless on Linux, `4.7.1.stable.official.a13da4feb`, in a cloud
container.

- **Baseline at 051: 58 suites, `--all`, 0 with something to look at.**
- **After 052: 59 suites, `--all`, 0 with something to look at.** The suite
  lists were **diffed** rather than eyeballed; the only difference is
  `layout_key_test`.
- `layout_key_test` **fails 13 times** against the pre-052 `FarmModule`,
  measured by checking the committed module back out under the new suite:
  **two** are the reader sweep naming `lane_width` — plain and grown — as
  read by nothing, and **eleven** are the lane threshold. It **parses**
  against the pre-052 code, because it adds no constant to the module it
  tests and calls no function that did not already exist.
- Run with `--fixed-fps 60` and without; passes either way (TRAPS 4).
- `run_tests.bat` needed no edit: all sixteen of its `findstr` patterns were
  **run against the name** rather than read, and none matches.
- The farm sweep, 468 legal farms, **before and after**: 468 solve, 0
  refused, narrowest gap between two zones anywhere **6.0000 m**.
- The threshold **moves with the layout**: a 3×3 grid of zones 6 m apart is
  reachable at lane widths 1, 3 and 6 m and **not** at 8, 12 and 24 m, with
  exactly one zone — the middle, the only one with a neighbour on all four
  sides — reported each time.

### What the suite asserts, and what it does not (TRAPS 6, TRAPS 14)

Nothing in it asserts a sentence. *"The comment says a lane"* would pass
against a check comparing to 0.5 and against one comparing to 6. What is
asserted is verdicts and numbers: that the verdict moves when the lane width
in the layout moves, that a gap of 0.6, 1, 3 or 5 m is not a 6 m lane, that
an overlap blocks, that every layout `solve()` returns carries the key the
check reads, and that no legal farm is refused by the stricter threshold.

It does **not** prove that a key is read for the right reason, or that a
reader is correct. It proves something downstream can tell the difference,
which is the one property a dead key does not have.

### Found while measuring it, and written up rather than fixed

**The circuit's `target_turn` is read to one bit.** It reaches the layout and
the only thing that reads it there is `build()`, for its **sign**:
quadrupling it builds the identical track to the millimetre, negating it
flips `direction`. Inside `solve()` the number is the closure target the
solver aims at; in the layout its size is read by nothing. That is not a
fault and nothing is proposed about it — it is written down because 049
predicted *"at least one more dead or wrongly-read field"* and this is what
that prediction turned up on the circuit, and because **a sweep that only
asks "did anything change?" would have called it fully read.** The suite
measures it explicitly instead.

**The farm's fence posts are built as unnamed nodes.** Harmless in the game,
and recorded because it is what made this commit's own suite vacuous.

### Not verified

- **NO MODEL SENT ANY OF THIS.** Every request in the suite and in the
  measuring was typed by hand; this harness has no key, and nothing was
  reproduced from the owner's screen.
- **Nothing was rendered on a screen.** No farm was looked at. What was
  compared is layouts, measurements and built trees, headless.
- **No farm, no record and no saved world changes.** The prompt is
  byte-identical, so `PROMPT_VERSION` did not move and designs stay
  comparable across this commit. Nothing on the owner's disk was touched.
- **The guard is now twelve times stricter and catches nothing today.** That
  it will catch the thing it names if the packing ever changes is asserted
  against hand-built layouts, not against a solver that produces one — by
  construction there is no such solver to run it against.
- Whether `_check_reachable()` belongs in `post_check()`, where
  `WorldModule`'s own comment says a check on a solved layout goes and where
  racing puts its separation check, was **considered and not done**: it would
  be behaviour-identical today (the farm has no `solve_record()` and no
  `correction_feedback()`, so the controller treats both failures the same)
  and it is a move rather than a fix. Left for whoever has a reason.

## Next action

**AS OF 065 THE VISUAL-LAYER AXIS IS CLOSED** — 061's six differences all
have a reader now, which is what 062, 063 and 065 were each one step of.

**066 FOUND THAT ONE OF THE TWO ITEMS BELOW WAS ALREADY DONE, AND THAT THIS
SECTION HAD BEEN SAYING OTHERWISE FOR FIVE COMMITS.** Item 2 — *hold the
four `connect()` rows 059 found unheld* — **was done in 060**, in
`tests/player_door_test.gd`, with all four walked through a real emit. 065's
own sentence here called both items "the live next task". That is TRAPS 14 in
this file: a claim about Genesis that a one-minute grep of `tests/` would
have refuted, left where the next unattended session would read it and spend
its two hours re-doing 060's work. **The lesson, which is the part worth
keeping: 060 satisfied the entry by writing a NEW FILE, where the entry said
`handler_wiring_test` was "the file to extend" — so nobody struck it.** An
entry here is satisfied by the capability arriving, not by the file named in
it being touched. Grep for the capability before trusting the entry.

**For the assistant:**

1. **Finish the id class — it is two thirds undone (TRAPS 11, TRAPS 56).**
   059 fixed the record id and left the **session id** (`main.gd:514-515`, a
   tester's name plus a wall-clock second) and the experiment **`run_id`**
   (`experiment_runner.gd:62`, a second and nothing else) with the same
   fault in them. The rule is stated in the 059 section: *an identifier that
   has to tell one writer's records from another's must carry something only
   that writer has.* Neither is urgent — the session id also carries the
   name, and `run_id` needs a key — and the session id appears in reports
   the owner already has, so **ask before changing its shape**: it is
   "Human decision needed" 22. `ledger_audit_test.gd` already salted its own
   session name, which is somebody meeting this once.

   **066 DID THE HALF OF THIS THAT IS NOT THE OWNER'S, AND IT TURNED OUT TO
   BE A REPRODUCIBLE FAULT RATHER THAN A TIDY-UP.** The product's two
   identifiers are untouched and still "Human decision needed" 22. What 066
   changed is the **harness**: three suites in `tests/` start a session, and
   a session id is `"<name> <datetime to the second>"` out of a `user://`
   every copy of this project shares, so a fixed name is a name a second
   writer can mint too. Measured: **six paired concurrent runs of
   `handler_wiring_test` against one ledger, and in five of the six one of
   the pair failed** *"the ledger gained exactly one ai_unavailable event
   (got 3)"*, scoring 44 assertions where a clean run scores 47 — TRAPS 56's
   varying-count signature, the trap that cost 059 a day. All three names
   now carry `OS.get_process_id()`; after the fix, **six of six paired runs
   scored 47 and 0 both sides**. `record_id_test` sections 8 and 9 hold the
   rule for the class and name the two members that are still the owner's.
   See the 066 section and TRAPS 63.

   **What is LEFT of this item is only the owner's two.** Nothing an
   assistant can honestly do remains.
2. ~~**Hold the four connect rows 059 found unheld, all four reachable with no
   key.** 058 is the method and `handler_wiring_test` is the file to extend.~~
   **DONE IN 060**, in `tests/player_door_test.gd` — a new file rather than
   an extension of `handler_wiring_test`, which is why this entry survived
   five commits after it was satisfied. All four are walked through a real
   emit: the real `Button`'s signal, the real `LineEdit`'s signal, the real
   `CheckpointTracker` counting a lap off the car's own position, and the
   real `RaceDirector`'s countdown under real physics. **Left here rather
   than deleted, with the original text struck, because the sketch below is
   the record of what was asked for and 060's section records what was
   actually built.**
   In rising order of cost:
   - **`lap_completed` (93)** is the cheapest. `update_progress()` is pure
     geometry (`checkpoint_tracker.gd:40`) — walk positions past the twelve
     checkpoints in order and the real signal fires with nothing faked. The
     handler writes a history line a player reads.
   - **`pressed` (100) and `text_submitted` (101)** are **the doors a player
     actually uses**, and nothing in the project emits either signal
     (grepped across `scripts/` and `tests/`). Put a distinctive request in
     `input_box.text`, emit the real signal on the real node, and assert the
     ledger's `record["request"]` carries that exact text — which proves the
     text went from the box through the wire to the controller, not merely
     that something happened (TRAPS 54). Surround it with spaces and the
     `strip_edges()` is proved too. **Note what the harness cannot do**:
     headless has no keyboard, so the signal is emitted by hand; everything
     after it is real. Both handlers read `input_box.text` rather than the
     signal's argument, so they are one behaviour at two doors — worth
     asserting of both, not one (TRAPS 11).
   - **race `announced` (98)** is the dearest: *"GO!"* comes out of
     `_physics_process` once the countdown elapses, so it needs a race
     standing up and physics stepped.
   **And one thing found while measuring and left alone**: of the eight ways
   out of `_handle_request()`, five clear `input_box` and three do not — a
   `/` command, a pending revision and a busy interpreter all leave the text
   in the box. Leaving a refused sentence there is arguably right and
   leaving `/drive` there is arguably not. **Nothing was changed**, because
   the behaviour may well be deliberate and it is a judgement about what the
   box is for: "Human decision needed" 23.

**Still the owner's, and still a minute's work — but it would NOT have
worked before 057, and that is new information.** The proxy is built (020):
set `GEMINI_API_KEY` in the Netlify site's environment variables, and set
`NETLIFY_AUTH_TOKEN` and `NETLIFY_SITE_ID` as GitHub secrets so a push
deploys.

**AND "SO A PUSH DEPLOYS" IS CURRENTLY FALSE, WHICH 064 MEASURED RATHER THAN
ASSUMED.** Those two secrets are empty, and the `web build` workflow has
therefore failed on **every push since run 28** — 46 of them. The export
succeeds; the publish never happens. So the second half of this paragraph is
not an optional extra that would make deploys automatic: **it is the thing
standing between every commit since 021 and the live site.** See the new
bullet under "Limitations — unverified or absent". After that, a stranger with the link can type a sentence and get a
world, which is the first time that has ever been true. Nothing the assistant
can do moves this: the key must not be in the repository.

**What 057 changed about this entry.** Until 057 the browser never sent the
request at all: `_send()` refused it at `if api_key == ""`, and on the web
`api_key` is always `""` by design, so the key in the Netlify environment
would have gone unused and the player would have been told to check
`api_key.txt`. **Setting the variable would have appeared to do nothing.**
That blocker is gone and the request now reaches `/api/interpret`. **It is
still not proved that the round trip works** — no browser ran here and no
web export was made — so the first deploy is a test, not a confirmation, and
the thing to watch is whether a sentence comes back as a world or as an
"AI FAILED" line. If the variable is unset, the function answers 503 with
*"This Genesis has no AI configured"*; see "Human decision needed" 19 for
what Genesis currently does with that, which is not show it.

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

038 adds a twelfth, and it is one sentence typed twice and one look at the
line that comes back:

- **Ask for boots that stop on a sixpence** — those words, or *"boots that
  stop dead"*, anything that makes the model choose between `brake` and
  `footing`. Until 038 the prompt told it, in the last line of the boots
  section, that this wants **`footing`** raised — and `footing` costs more
  than half the walking pace and still stops nearly twice as far from the
  same speed as `brake` does. It also could not have sent `brake` if it had
  wanted to: the field was missing from the JSON skeleton it copies. The
  readback should now come back as boots that *"pull you up short"* with
  **no** *"though they only walk at 2.0 m/s"* on the end of it. **If it still
  arrives with `footing` raised and the walk halved, the wording is not
  enough and the next move is an example in the prompt rather than a
  sentence** — the same answer 035 is still waiting for about the farm's one
  zone.
- And one worth knowing rather than typing: **`prompt_version` is
  `038-the-field-that-does-it-1` from here**, and for boots this one is not
  bookkeeping. Every `EQUIP boots` record in your ledger under
  `035-bounds-from-the-code-1` was proposed by a model that had been told the
  wrong field for a short stop and could not send the right one, so a
  before-and-after of boots designs across this commit is a comparison of two
  different populations — which is exactly what the version string is for.
  The records are yours and 038 did not touch them.

043 adds a thirteenth, and it is one request and one glance at the line that
comes back, because what changed is prose and the owner is the editor:

- **Ask for a dungeon and let the model name the rooms.** 022 is the session
  where it called them `chamber_1..4` rather than `hall` and `vault`, and
  that is the case this is about. Until 043 a measured numbered room read
  *"entered through a 12 m room 1"* and an errand in it read *"The key 2 is
  in the vault."* and *"there is no door between the room 1 and the room 2"*.
  They should now read *"entered through 12 m room 1"*, *"Key 2 is in the
  vault."* and *"there is no door between room 1 and room 2"* — the rule the
  owner already accepted in 022 and 031, applied at the nine doors it had
  never reached. **The judgement is whether a sentence that OPENS on a bare
  label reads as a sentence**: *"Key 2 is in the vault."* is the one worth
  looking at, because it is the only one where the dropped article is the
  first word. If it reads as clipped, the fix is to rephrase that sentence,
  not to put the article back — `said_article_test` holds the line either
  way, because it asserts that the name is rendered as the one function
  renders it and never what the sentence says around it.
- And one worth knowing rather than typing: **a room of 8, 11, 18 or 80–89 m
  now reads *"an 8 m hall"*** instead of *"a 8 m hall"*, in every dungeon and
  every farm readback. A word beginning with a LETTER is still decided by
  that letter, so if the model names a thing *"hourglass"* or *"unicorn"* the
  article will be wrong — that needs pronunciation, Genesis does not have it,
  and it is recorded rather than quietly left (TRAPS 37).

044 adds a tenth, and it is the only part of 044 a person has to judge,
because what changed is a sentence and the suite can only prove it is
faithful:

- *"send the character to room 2.5"* — or anything that makes the model write
  a fractional room number; typing the JSON by hand is quicker if nothing
  does. Before 044 the readback said *"to send someone to room 2"* and the
  refusal underneath it said *"there is no room 2.5"*. It now says *"to send
  someone to room 2.5"*, so the two lines agree. **The judgement is whether
  the odd cases read as honest or as clumsy.** The sharp one is
  `SPAWN_OPPONENTS`: *"to put 2.9 opponents on the track"* is faithful and
  strange, where the old line said *"two opponents"* and was simply wrong. If
  a request like that should be REFUSED rather than said back, that is a
  change to what Genesis does and it is "Human decision needed" 12. Worth one
  glance too at *"with a key in room 99"* for a thing placed out of range —
  before 044 the room vanished from the sentence and it read *"with a key"*.

045 adds a fourteenth, and it is a line in a file rather than a line in the
game, so it is a minute with a text editor rather than the editor:

- **Open your ledger and find a `CREATE_FARM` record made after this commit.**
  It now carries `proposed_zones` — the zones as the model sent them — and
  `attempt`, which it never did. Every other command has recorded its proposal
  since 003 and a farm recorded none, so a refused farm's entry named the
  problem (*"zone 1 (barn): width 500 m is outside 5–60 m"*) without naming the
  design. **The judgement is whether the field is worth having**, because this
  is the one change in 045 that a test cannot weigh: the zones were always in
  `raw_command` as a string, so what the new field buys is a ledger that
  answers the same question the same way for every command, and what it costs
  is the proposal stored twice. If you would rather read `raw_command` and have
  the field dropped, say so and it comes out of
  `WorldModule.proposal_record()` in one place. A `PLAN` record now carries
  `proposed_steps` for the same reason, and that one is the sharper case: a
  plan refused at step 2 of 3 used to leave no record of the plan at all.
- And one worth knowing rather than typing: **an audit by field across this
  commit is not a before-and-after for those two commands.** Every
  `CREATE_FARM` and `PLAN` record already in your ledger carries no
  `proposed_` field; `raw_command` is the field that spans the boundary. The
  records are yours and 045 did not touch them.

046 adds a fifteenth, and it is the shortest one on this list, because the
sentences did not change:

- **There is nothing to type and nothing to look at.** 046 changed where two
  numbers come from, not what they say. *"CREATE_DUNGEON built 3 rooms joined
  by 2 doors"* and *"CREATE_TRACK built a closed clockwise circuit: 8
  sections"* are word for word what they were, measured before and after, and
  every panel line is byte-identical. What changed is that those two counts
  are now read off the built world instead of off the request, so a builder
  that ever stopped placing a piece would say the smaller number instead of
  going on saying it had.
- **The one judgement in 046 is the farm's silence, and it is one line.** A
  built farm says *"Farm built (full measurements in the panel)"* — it has no
  sentence of its own, where a dungeon says what it built and a circuit says
  what it built. A sentence that states no count cannot state a wrong one, so
  this was left rather than invented: whether a farm should say *"CREATE_FARM
  built 3 zones inside 320 m of fence"*, or whatever reads best, is a question
  about what Genesis says and it is yours. The tie is already in place if you
  want it — `FarmModule.build()` reports the count — so it is a sentence and
  not a mechanism.
- And one worth knowing rather than typing: **an audit by field across this
  commit is not a before-and-after.** No record changed and no ledger field
  moved; `pieces_built` lives in the build report, which is passed to the
  sentence and is not written to the ledger. The records on your disk are
  yours and 046 did not touch them.

047 adds a sixteenth, and like 046's it is short, because the sentences did
not change either:

- **There is nothing to type to see 047's fault, and that is the honest
  summary of it.** Both halves are latent: the panel is measured once, before
  anything is built, and a door can only be shut on a dungeon that is already
  standing, so the panel a player reads was drawn when nothing was shut. On
  every dungeon with nothing shut, every panel line and both summaries are
  byte-identical before and after — measured, on the same worlds.
- **One thing worth typing anyway, because it is the fault's own shape.**
  Build a dungeon with a ring in it — *"a dungeon with a hall, a vault, a
  crypt and a cell, each joined to the next and the last joined back to the
  hall"* — then shut the door that closes the ring and **look at the panel**.
  It will not have changed, because nothing re-measures. **If you would
  rather it did**, that is the change worth asking for: the panel would then
  say *"WAYS ROUND none"* and *"DEAD ENDS 2"* the moment the door shut, which
  is what 047 made possible and did not wire up. Re-measuring a standing
  dungeon is a change to when Genesis speaks, so it is yours and not the
  assistant's.
- **And one judgement, which is one line.** `measure()` counts how many
  doorways a body cannot use — `walk_blocked` — and **no panel line states
  it, and nothing in the repository reads it.** With 047 in, a shut door
  silently changes DEAD ENDS and WAYS ROUND; a line saying *"BLOCKED 1
  doorway"* would say why. Adding it is adding a sentence, so it is "Human
  decision needed" 14 rather than a commit.

048 adds a seventeenth, and it is **the one to do first, because it is your
own finding and the fix is to a frame of the running game that no harness
can stand in for.** From `git log 5d36bfb`, not measured here:

- **Ask for a dungeon of four rooms, in a fresh session, and read the
  sentence under the readback.** It said *"CREATE_DUNGEON built 14 rooms
  joined by 4 doors"* on your machine, and the 14 was four rooms plus the ten
  road pieces of the starter circuit on its way out in the same frame. It
  should now say four. **That sentence is the only thing that settles it**:
  what 048 tested is a tree assembled to look like that frame, not the frame.
- And the thing 048 did NOT fix, which it records as a feature rather than a
  fault: **there is still no way to ASK Genesis anything.** *"show me the
  dungeon metrics"* came back `SHUT` and *"where is the red key now"* came
  back `UNSUPPORTED`. That is yours to rule on and it is at the top of the
  assistant's list below.

049 adds an eighteenth, and this one IS worth typing too, because it is the
first fault in several commits that a player could have met:

- **Type a plan that puts one world inside another** — *"a dungeon with a
  hall and a vault, inside a farm with a barn"* — and **look at the farm's
  fence, along the south side.** Before 049 there was no gate: `solve()` cut
  one into the fence it computed, the plan then pushed the fence out to make
  room for the dungeon, and the gate stayed where it was, tens of metres
  inside the new boundary. The farm came out fenced on all four sides. It
  should now have a 16 m gap in the posts, in the middle of the south side,
  on a grown farm as it always had on a plain one. **Nothing else about that
  farm changes**, and a farm with one world in it is byte-identical to what
  it was — measured.
- **The judgement, and it is the only part of 049 a person has to make: the
  RAIL still runs across that gap.** `_add_fence()` puts one rail per side,
  spanning the whole side, and skips only posts near the gate. So a gate is a
  gap in a row of posts with a rail through the middle of it, and that has
  been true of every farm since 003 — 049 did not change it, because what a
  gate should look like is a sentence about the world and not a fix. See
  "Human decision needed" 15: leave it, break the rail at the gate, or build
  an actual gate. **The one thing worth knowing before deciding:** the fence
  has no collision at all, so none of this stops anybody walking in today.
  If the fence is ever given collision, a rail across the only gap is a farm
  nothing can drive into — which is the thing the farm's own header says it
  refuses.
- And one worth knowing rather than typing: **nothing in the panel changed
  and no record moved.** 049 measured both remaining panels against the
  geometry they describe and every line was already right, the circuit's
  road LENGTH included — the line this file had flagged as *"known not to
  follow the world"*. It follows it to within 8 cm in 1177 m, which is the
  road being drawn as chords. An audit by field across this commit is not a
  before-and-after of anything; the records on your disk are yours and 049
  did not touch them.

050 adds a nineteenth, and it is **yours before it is anything else,
because it is your own finding and the only thing that settles it is what a
model sends back**:

- **Ask Genesis a question, in a fresh session with a key.** *"show me the
  dungeon metrics"* and *"where is the red key now"* are the two you asked
  on 2026-10-16; they came back a **SHUT** and an **UNSUPPORTED**. The
  prompt now tells the model the one limitation it did not have — Genesis
  cannot be ASKED anything, there is no command for a question, and the
  reason for refusing one is THAT and never that Genesis cannot measure or
  cannot read the world. **What to watch for, in order:** that the metrics
  question no longer comes back as a SHUT or any other command that changes
  the world; that the refusal names the missing door rather than inventing a
  reason; and that **no "REFUSAL UNDERSTATES" note appears under it**, which
  is the half 050 fixed in the checker. If a question still lands on a
  command, the wording is not enough and the next move is an example in the
  prompt rather than a rule — the same answer 035 and 038 are both still
  waiting for.
- **And the one worth typing beside it:** *"build a dungeon with a hall and
  a vault and tell me how deep it is"*. The prompt's existing rule says not
  to refuse a whole request because one clause is impossible, and the new
  limitation says so again for this case: the dungeon should be BUILT, with
  the question named as the part that was dropped — and the panel then
  states the depth anyway. **If that comes back UNSUPPORTED, the new
  limitation is costing a build**, which is the one way this change could
  make things worse, and it should be narrowed or taken out.
- And one worth knowing rather than typing: **`prompt_version` is
  `050-no-command-for-a-question-1` from here.** Every record in your ledger
  under `039-the-arithmetic-it-really-does-1` was made by a model that had
  not been told this, so a before-and-after of how questions are answered
  across this commit is a comparison of two different populations — which is
  what that string is for. The records are yours and 050 did not touch them.

051 adds a twentieth, and it is two requests and one glance, because what
changed is what the panel says about which world it is describing:

- **Ask for a car, or type `/clear`, and look at the measurements panel.**
  Before 051 it read **`RESULT  Valid circuit`**, in green, for a car, for an
  `ORDER` and for `CLEAR_WORLD` — the command whose whole job is to take a
  world away. It now reads *"Valid EQUIP"*, *"Valid ORDER"*, *"Valid
  CLEAR_WORLD"*. **The judgement is whether naming the command reads better
  than naming nothing**, since that is the half a test cannot answer: a raw
  command name is already in player text elsewhere (*"EQUIP failed:
  FAILED_SCHEMA"*, *"CREATE_DUNGEON built 3 rooms"*), which is why it was
  chosen over inventing a phrase. If *"Valid"* alone reads better it is one
  function — see "Human decision needed" 17(b) — and `panel_refused_test`
  holds the line either way, because it asserts that no record names a world
  it is not about and never what the sentence says.
- **Type a plan whose second step cannot be built** — *"a dungeon with a hall
  and a vault, inside a farm with a barn 500 m wide"* will do it, or any two
  worlds with no *"inside"* or *"around"* between them — and **read the panel
  as the plan is refused.** The panel now admits that the measurements are
  not of a built world and gives the reason; before 051 a refused plan's step
  showed ten measurement lines under a green *"Valid dungeon"* with neither.
  **Worth knowing before you look for it: you probably will not see it
  change**, because the plan's own refusal is drawn over it in the same frame,
  so what was there was a flash. It is fixed for the same reason 047's was:
  the panel should be right whether or not something follows it.
- **And one worth typing because it used to be a red failure:** `/save` a
  world, then `/load` it. A load check whose outcome is SAME read
  **`RESULT  FAILED: `** in red, with an empty category where a reason should
  be — a successful verification reported as a failure, measured. It now
  prints no verdict line at all, which claims nothing, and that leaves the
  panel showing a single line. **What a load check's panel SHOULD say is
  yours**: the record already carries an `outcome`, a `said` and a
  `differences` list, and not one of them has ever been in the panel. "Human
  decision needed" 17(a).
- And two worth knowing rather than typing. **The panel's title still reads
  `TRACK MEASUREMENTS`** for a dungeon and a farm — a static label, not a
  line read from a record, and the same Prototype 001 word the `"circuit"`
  default was, one layer out; one word, yours. And **a refused CIRCUIT's
  caveat now reads *"not a built circuit"*** where it read *"not a built
  track"*, because a world is named by `display_name()`. Six panels were
  dumped and diffed before and after and that is the **only** line that
  changed for a request that could already reach the panel.
- And one that is a FAULT and is being left for you to rule on rather than
  fixed: **a plan refused when its worlds are placed writes two ledger lines
  under the same id**, one saying `construction: BUILT` and one saying
  `FAILED`. Measured, a plan of two dungeons gives four lines for two worlds.
  It breaks this project's own rule that history is added to and not
  rewritten, and nothing would catch it because `ledger_audit_test` indexes
  by id. No record on your disk was touched. Three options, "Human decision
  needed" 17(c).

052 adds a twenty-first, and it is **one glance and nothing to type**,
because what changed cannot be reached from a request:

- **Nothing in any farm moves.** `FarmModule._check_reachable()` — the check
  behind the module's claim that a farm a tractor cannot get round is
  refused — compared each edge against a bare **0.5 m** where a lane is
  **6 m**. It now reads the lane width out of the layout it is checking.
  **Measured both ways over 468 legal farms: the solver never leaves two
  zones closer than 6.0000 m, so no farm a player can ask for is affected
  and none is refused.** The guard is twelve times stricter and catches
  nothing today; what it would catch is a packing change, which is the only
  reason a guard is kept. Nothing to look at, and said here because a
  stricter refusal is the kind of change that should never arrive quietly.
- **One thing found and written up rather than fixed, and it is not a
  fault:** the circuit's `target_turn` reaches the layout and only its SIGN
  is read there — quadrupling it builds the identical track, negating it
  flips `direction`. Worth knowing if a future change wants the closure
  target after solving: the layout carries the number but nothing downstream
  depends on its size.
- And one worth knowing rather than typing: **the farm's fence posts are
  built as unnamed nodes**, so Godot gives each a generated name with a
  global counter in it. Harmless in the game; it is written down because it
  made 052's own new suite pass against the code it was written to catch,
  and the next person to sign a built tree needs to know.

053 adds a twenty-second, and it is **nothing to type and nothing to look
at**, because nothing a player can reach changed:

- **No world, record or saved file moves.** 053 answered a question and
  wrote down the answer. The only code changes are seven comments, one at
  each refusal branch that no legal request can reach, naming the
  arithmetic that puts it out of reach and the fixture that fires it.
- **One thing is yours and it is "Human decision needed" 18**: the farm's
  clearance check is called from inside `solve()`, and that is the one
  guard in Genesis whose wiring no suite can hold to account — deleting the
  call leaves all 60 suites green. Moving it to `post_check()` fixes that
  and changes nothing a player sees; it changes which step refuses, so it
  is yours.
- And one worth knowing rather than typing: **a doorway is always cut to
  the corridor's 4 m**, so `walkable()`'s *"a person 1.6 m across cannot get
  to X"* can never be about a doorway too narrow, at any room size.
  The only thing that makes a body's route fail is a **shut door**.

055 adds a twenty-third, and it is **one request and one glance**, because
what changed is a suite and not a behaviour:

- **Nothing a player can reach changed.** The only `scripts/` change is
  comments in `world_module.gd`. 055 asked which checks can be proved
  CONNECTED, found that four of fourteen call sites were not held by any
  suite, and wrote the fixtures that hold them. Nothing in Genesis behaved
  wrongly at any point.
- **The one thing worth a glance, and it is a sentence rather than a bug.**
  Type a request that gives a tool a named value in the wrong case — a red
  car asked for as `RED`, or black boots as `BLACK`. Genesis says it back
  **normalised**: *"the ordinary red car"*. That is the validator's spec
  being read back, which is right for an accepted request — what will be
  built is a red car — and it is the one readback in Genesis that does not
  say a value back exactly as it was sent. The other four say back what was
  heard, which is 044's rule. If the normalised version reads wrong to you,
  it is `ToolRegistry.readback()` and it is one line;
  `check_wiring_test` holds whichever way it goes, because it asserts which
  spec the sentence was built from and never what the sentence says.
- And one worth knowing rather than typing: **do not run the test suite
  twice at once on the same machine.** Every copy of the project shares one
  Godot `user://`, so the two runs write over each other's ledger and
  saved worlds. 055 took four wrong answers off exactly that before
  noticing (TRAPS 50).

**058 adds a twenty-fourth, and it is nothing to type and nothing to look
at, because nothing a player can reach changed:**

- **No file in `scripts/` was touched.** 058 wrote one test file. Every
  behaviour it asserts is the behaviour that was already there.
- **The one thing worth knowing rather than typing**: with the
  `track_measured` wire disconnected the measurements panel does not go
  blank — it keeps showing *"Build a composed track to see its
  measurements."* under a TRACK MEASUREMENTS heading, for the whole session.
  That is what this file called "permanently blank" from 057 until 058
  measured it (TRAPS 54). Nothing is disconnected today, and the suite now
  says so if it ever is.
- **And two things are yours**, both new: whether this project should own a
  test double for `HTTPRequest`, which is the only way the last two handlers
  can be held ("Human decision needed" 20), and whether the busy sentence
  should be one function or two ("Human decision needed" 21).

**059 adds a twenty-fifth, and one line of it is worth typing:**

- **Nothing a player can reach behaves differently**, except that every new
  ledger record's `id` now has three fields instead of two
  (`<seconds>-<process>-<serial>`). **Existing records are untouched** and
  every reader compares an id whole, so old and new sit in one ledger
  without interpreting each other.
- **Worth one glance in a session report.** Run `/session NAME`, type two or
  three requests, then `/session end`. The understanding score in that
  report is keyed by record id, and until 059 two records sharing an id
  could put one request's verdict against another. Nothing should look
  different — the collision needs two Genesis instances writing one ledger —
  but it is the one player-facing thing the fix touches, and the report is
  yours.
- **And one thing is yours and new: "Human decision needed" 22**, whether
  the other two members of the id class should move too — the session id and
  the experiment `run_id`.

**Smallest useful assistant task next.** The ledger question (033), the
container-door question (034), the prompt-bound question (035), the validator
question (036), the intent-door question (037), the which-field question
(038), the arithmetic question (039) and the five build-it claims (040) are
all **done**. Candidates, in the order the assistant would take them:

- ~~**THE NEXT ONE: the class question behind "Human decision needed" 18 —
  which checks cannot be proved connected?**~~ **DONE IN 055: FOURTEEN CALL
  SITES, TEN HELD, FOUR NOT, AND ONLY ONE OF THE FOUR HAS NO DOOR.** The
  farm's is still the only check in Genesis that nothing can hand a
  violating input. The other three — `LoadCheck.compare`,
  `RefusalCheck.quarrel_with` and `ToolRegistry.readback`'s validated
  branch — had a door that nothing walked, and `tests/check_wiring_test.gd`
  walks it. Left struck rather than deleted because the lesson is the one
  worth carrying: **a unit test proves a check FIRES; only a request through
  the game's own door proves it is REACHED**, and every one of the three had
  a thorough suite of its own. TRAPS 49. Two rows are left `NOT_ASKED` and
  are the next task: `GameController.finish_order` and
  `main._on_revision_requested`.

- ~~**THE NEXT ONE, AND IT OUTRANKS EVERYTHING BELOW IT BECAUSE IT IS THE
  OWNER'S: there is no way to ASK Genesis anything.**~~ **DONE IN 050, AS
  FAR AS IT GOES WITHOUT THE OWNER.** The finding is written up — in the
  starting state, in the 050 section, and in TRAPS 44 — the facts are
  measured, and the options are "Human decision needed" 16. **No command was
  added.** Two things were found in the measuring and both are fixed: the
  prompt's CANNOT list had no entry for a question while binding every
  refusal to name a part FROM that list, which is why the model had to
  invent one or send a command; and `RefusalCheck` flagged three of the nine
  TRUE refusals of a question as understating Genesis, one of them by the
  entry whose own rebuttal says such a refusal is right. Left struck rather
  than deleted because the lesson is the one worth carrying: **the one
  limitation a prompt leaves out is the one its refusals will have to
  invent.** **And one line of the entry below was wrong, which 050 says
  rather than quietly fixing (TRAPS 14): it called both answers *"honest
  refusals of commands that do not exist"*, and a SHUT is not a refusal. It
  is one of the eleven, and `GameController._set_door()` runs on it — a
  question had been turned into an attempt to CHANGE the world. Whether it
  changed anything depends on the parameters the model sent, and `5d36bfb`
  does not record them, so nothing is claimed here about that. The
  UNSUPPORTED was a refusal.** The entry as it stood:
  Found on his machine on
  2026-10-16 and recorded in `5d36bfb`'s message, which is the only place it
  is written down: *"show me the dungeon metrics"* came back `SHUT` and
  *"where is the red key now"* came back `UNSUPPORTED`. Both are honest
  refusals of commands that do not exist — the measurements are already in
  the panel and a thing's position is already how a delivery is decided, so
  **Genesis has the facts and has no door to them.**

  **The first job is to write it up properly**, because it is an owner
  finding sitting in a commit message rather than in these documents, and the
  second is that **what to build is not the assistant's to decide**: a new
  whitelisted command is a change to what Genesis IS. So the shape of the
  work is: read the two refusals and what produced them, measure which facts
  are already reachable without a new command (the panel's lines, `room_of()`,
  `walkable()`, a thing's position), and write the options into "Human
  decision needed" for the owner — a `LOOK`-style query command, a widening
  of an existing one, or nothing at all. **Do not add a command.** 032's three
  Prototype 001 stubs are the standing warning about what a whitelist entry
  that builds nothing costs.

- ~~**THE NEXT ONE: the same two questions asked of the SIX the controller
  returns.**~~ **DONE IN 054: THE SEVEN NAMES ARE TWENTY-EIGHT BRANCHES —
  TWENTY-TWO REACHABLE, FIVE GUARDS, ALL FIVE FIRE, AND ALL FIVE CAN BE
  PROVED CONNECTED.** `FAILED_AI`'s first question needs a key this harness
  does not have and is left unanswered rather than guessed. **The finding
  was a count in a comment**: `FAILED_NOTHING_BUILT`'s header names three
  Prototype 001 paths and only two can be reached. **And this entry's own
  prediction below was right about `FAILED_NO_HANDLER` and wrong about where
  the blind spot would be** — it was not in the check, it was in reading
  reachability off the code instead of the running scene, which is TRAPS 48:
  the starter circuit `main.gd` stands up at launch makes `has_drivable()`
  true before any request, and a carried thing spends part of its errand in
  no room. Left struck rather than deleted, because the prediction is worth
  reading beside what actually happened. The entry as it stood:
  053 answered them for the ten categories the world modules
  return and enumerated these six without asking either:
  `FAILED_SCHEMA`, `FAILED_SCENE`, `FAILED_NOTHING_BUILT`,
  `FAILED_NO_HANDLER`, `FAILED_PARSE` and the AI runner's `FAILED_AI` — plus
  `GameController._order()`'s own `FAILED_UNWALKABLE`, which shares a name
  with the dungeon's and is a different check. `refusal_reach_test` already
  holds a row for each of them marked `NOT_ASKED`, so the work is to move
  those rows and bring the evidence, and the enumeration is already
  mechanical: a seventeenth category cannot be added without the suite
  failing.
  **What makes this one different from 053** is that these are about
  COMMANDS rather than worlds, so the sweep is a walk of the whitelist
  through a scene tree rather than a module pipeline — `command_schema_test`
  and `intent_door_test` both stand `main.gd` up, and that is the pattern.
  **Two of the six already have an answer written in a code comment that
  nothing asserts**, which is the thing to check first and the shape TRAPS
  14 is about: `_spawn_opponents()` says `has_track()` "can never return
  true", and `NOTHING_BUILT`'s own comment says the three Prototype 001
  paths "are the only ones that answer to it". `FAILED_NO_HANDLER` is the
  one to expect an "unreachable" for — it needs a whitelisted command with
  no case in `execute()` — and the second question is then the whole of its
  value. **Expect the blind spot to be in the check**, and run the sweep
  against the code it is written to catch before believing it: 053's first
  sweep reported a reachable category as unreachable because its inputs were
  refused one step earlier (TRAPS 47).

- ~~**which refusals can no legal request reach, and does each
  of those checks catch the thing it names?**~~ **DONE IN 053 FOR THE
  WORLD-MODULE HALF: SEVEN OF TWELVE BRANCHES ARE OUT OF REACH AND ALL
  SEVEN FIRE.** No dead refusal. Each "no" is arithmetic over the module's
  own constants and asserted as such, not a sweep result. **And one guard
  cannot be proved CONNECTED** — delete the call to
  `FarmModule._check_reachable()` and all 60 suites pass — which is "Human
  decision needed" 18. Left struck rather than deleted because the lesson is
  the one worth carrying: **a guard nothing can reach is also a guard
  nothing can prove is still wired in, and where a check LIVES decides which
  of those two it is.** The entry as it stood:
  `sweep_test` has reported since 005 that **no legal command reaches
  `FAILED_UNWALKABLE`** — TRAPS 6's own example — and 052 found the second
  member without looking for it: the farm's reachability branch of
  `FAILED_LAYOUT` cannot be reached either, because the only producer of a
  farm's zone coordinates is the `solve()` that leaves a lane between them.
  **Two of an unknown number, both found by accident.** The method is the
  one 033 used on the whitelist and 052 used on the layout: enumerate every
  category a module can return — `grep` for `"category"` and
  `FAILED_` across `scripts/` — and ask two questions of each, in this
  order, because the second is only interesting when the first says no:
  **(1) can any request a player can send produce it?** Sweep the legal
  space the way `sweep_test` and 052's farm sweep do, and say so either way.
  **(2) handed an input that DOES violate it, does the check fire?** That is
  the half `walk_negative` does for the dungeon and 052 added for the farm,
  and it is the half that tells an unreachable guard apart from a broken
  one. A category nothing can reach and whose check does not fire when
  violated is dead code pretending to be a safety net; one that cannot be
  reached but fires correctly is a guard against a future packing change and
  should be labelled, not deleted. **Expect the answer to be "unreachable"
  more often than it looks**, because the solvers in this project construct
  what the checks then verify, which is the shape both known members have.
  **And expect the blind spot to be in the check**, which it has now been in
  041, 042, 043 and 052: in 052 the new suite's own signature could not fail,
  because it included a generated node name and an instance id. Run every
  new sweep against the code it is written to catch, and read the output.

- ~~**THE REMAINING HALF OF 051'S OWN ENTRY: the layout keys nothing
  reads, enumerated world by world.**~~ **DONE IN 052, AND THE CLASS
  QUESTION IS ANSWERED: A LAYOUT IS AN INPUT.** Nothing serialises one, so a
  key with no reader is dead weight and not documentation, and the choice
  HANDOVER named — give `lane_width` a reader — is the one the repository's
  shape asks for. **The reader was not assuming a lane width; it was
  comparing against 0.5 m**, one twelfth of the lane, and the number it
  should have read was the dead key itself. Measured over 468 legal farms
  before and after: no farm changes, and the failure branch is reachable
  from nothing a player can send. `layout_key_test` now asks the "who reads
  this?" question **mechanically** — worlds from `WorldRegistry.modules()`,
  keys from the layout `solve()` returned, readers found by reflection over
  `get_method_list()` — so a fourth world or a new key is asked without the
  file being edited, and a key with no declared perturbation FAILS rather
  than being skipped. Left struck rather than deleted because the lesson is
  the one worth carrying: **a key nothing reads cannot be wrong, which is
  exactly why nobody would notice if it stopped being true** — and a
  threshold with no name on it is the same fault one layer in. The entry as
  it stood: 051 answered the
  PANEL half of the entry below and left the FIELD half, which the entry
  itself called the cheapest thing on the list: **for every world, list the
  keys its `solve()` writes into the layout, and ask of each one WHO READS
  IT.** 049's fault was in the one key of the farm's layout that no panel
  line states and was found that way. **The enumeration was begun in 051 and
  is written down here rather than left to be redone**, measured by grep
  across every `.gd` in the repository:

  | world   | keys `solve()` writes into the layout                      | read by |
  |---------|------------------------------------------------------------|---------|
  | dungeon | `rooms`, `doors`, `pitch`, `slots`, `things`               | all five read, several places each |
  | farm    | `zones`, `fence_min`, `fence_max`, `gate`, `lane_width`    | **`lane_width` by NOTHING** |
  | circuit | `sections`, `target_turn`                                  | both read |

  plus `min_extent`, which `WorldModule.grown()` adds to a layout a plan has
  grown and which `grown()` itself reads.

  So **the dungeon's and the circuit's layouts have now been enumerated and
  every key of both is read**, which is a finding and not a blank: 049's
  "expect at least one more dead or wrongly-read field" is answered NO for
  those two. The farm's `lane_width` is the one dead key, written by
  `FarmModule.solve()` and read by nothing — `grep` finds it in that one
  line. `LANE_WIDTH` the constant IS used, in `solve()`'s own cursor
  arithmetic, so the lanes really are 6 m; what nothing reads is the key.
  **This is 049's gate one step further on: the gate was read from the wrong
  place, and this is read from nowhere, so there is nothing to be wrong —
  which is exactly why nobody would notice if the farm's lanes stopped being
  6 m.**

  **The work left, and it is small.** Three choices for `lane_width` and the
  thing to do is ask which rule the repository already follows: drop the key
  (the constant is the source of truth and the layout need not carry it), or
  give it a reader (a panel line, or `_check_reachable()` reading the lane
  width it is checking for rather than assuming it), or leave it and label
  it. **Ask the class and not the member (TRAPS 11): the general question is
  whether a layout is a RECORD of what was decided or an INPUT to the
  builder**, because that decides whether a key with no reader is dead weight
  or documentation — and the answer has to hold for all three worlds. Two
  things to check before choosing: whether anything serialises a layout (if
  `/save` or a plan writes one out, a key nothing reads is still in the
  owner's file), and whether `_check_reachable()`'s 0.5 m flush test and the
  lane width are two numbers that should be one.

  **One of those two was checked in 051 and the answer is NO: nothing
  serialises a layout.** `WorldStore` saves *"the description that made it"* —
  `command`, `parameters` and `metrics` — and its own header says so; `grep`
  for `layout` in `world_store.gd` and `track_log.gd` finds nothing. So a
  dead layout key costs nothing in the owner's files today, and whichever way
  `lane_width` goes, no saved world and no ledger line changes. The
  `_check_reachable()` question is still open. And `LANE_WIDTH` the constant
  is read by `limits_test.gd:318`, so the 6 m itself is asserted somewhere
  even though the key is not.

- ~~**The panel beside a REFUSAL, and the fields no sentence
  reads.**~~ **THE PANEL HALF IS DONE IN 051, AND BOTH OF THIS ENTRY'S
  QUESTIONS WERE ANSWERED NO.** The caveat was driven from the validation
  layer and is a claim about the construction layer, so it was skipped for
  exactly the record it exists for; and the panel named a world where the
  record had none, in green, for `EQUIP`, `ORDER` and `CLEAR_WORLD`. The
  field half is the entry above. Left struck rather than deleted because the
  lesson is the one worth carrying: **the question that found it is this
  entry's own question asked of a READER instead of a field — not who reads
  this, but who can REACH this decision.** All four of the panel's decisions
  were inline in a UI callback, which is why the modules' lines had been
  measured against geometry twice and the decision about which world the
  panel describes had never been asked at all. The entry as it stood:
  047 and 049 between them have now put every panel line of all
  three worlds beside the geometry it describes, **for a world that was
  BUILT**. `main.gd:996` draws the panel from a second place as well:

  ```
  var m := record.get("metrics", record.get("proposed_metrics", {}))
  ```

  — so a request that was REFUSED gets a panel too, drawn from
  `proposed_metrics`, under the line *"(measurements below describe the
  proposal, not a built track)"*. **Nothing in `tests/` has ever produced
  that panel**, and it is the one case where the numbers describe, by
  construction, a world that does not exist. The caveat line is what makes it
  honest, so the questions are: does every line stay inside what that caveat
  covers, and is the caveat shown in every case it is owed?

  **MEASURED BY GREP THIS SESSION, AND IT IS A STARTING POINT AND NOT A
  FINDING — read it before believing it:**

  - **`proposed_metrics` is put into a world's record in exactly one
    place**, `racing_module.gd:130`, inside `pre_check()`. The dungeon writes
    none and the farm writes none. (`main.gd:408` copies it into a revision's
    `revision_of`, which is a reader and not a second producer.) So a refused CIRCUIT shows a full panel of
    measurements and **a refused dungeon or farm shows none at all** — the
    `m.is_empty()` branch prints the REASON and returns. That is 046's shape
    exactly: one world states the thing, the others are silent, and a silence
    cannot state a wrong number. Whether the silence is right is the
    question; `record_proposal_test` already notes that `proposed_metrics` is
    the only `proposed_` field anything reads.
  - **The racing panel's last four lines are not in `proposed_metrics` at
    all.** `CLOSURE ERROR`, `SELF-INTERSECTIONS`, `MIN SEPARATION` and
    `SOLVER CHANGE` are appended by `metric_lines()` only `if record.has(...)`
    — so on a refusal they appear or vanish depending on how far the request
    got, and which of those a player sees is a fact about where it failed
    that no line states. Worth asking what each one means when the thing it
    measures was never built.
  - **And the field nothing reads at all.** `FarmModule.solve()` writes
    `"lane_width": LANE_WIDTH` into the layout, and `grep` across every
    `.gd`, `.md`, `.html`, `.cfg`, `.toml`, `.bat` and `.sh` in the
    repository finds `lane_width` in **one place — that line** (and now in
    this paragraph). No panel line, no sentence, no suite, no reader. That is the same class as 049's
    gate one step further on: the gate was at least read by `build()` and
    merely read from the wrong place. This one is read by nothing, so there is
    nothing to be wrong — which is exactly why nobody would notice if the
    farm's lanes ever stopped being 6 m.

  **The method is 049's own lesson, and it is the cheapest thing on this
  list: for every world, list the keys its `solve()` writes into the layout,
  and ask of each one WHO READS IT.** 049's fault was in the one key of the
  farm's layout that no panel line states, and it was found that way and not
  by reading `build()`. The farm's layout has six keys (`zones`,
  `fence_min`, `fence_max`, `gate`, `lane_width`, and `min_extent` when a plan
  has grown it); the dungeon's and the circuit's have not been enumerated.
  **Expect at least one more dead or wrongly-read field**, because the two
  found so far were both in the first layout anyone looked at.

- ~~**The farm's panel and the circuit's panel, against the
  geometry they describe.**~~ **ASKED AND ANSWERED IN 049, AND BOTH PANELS
  WERE RIGHT.** Every line of both agrees with the geometry placed —
  including the circuit's road LENGTH, which this entry called out as *"known
  not to follow the world"* on the strength of 046's note: measured off the
  road surface in the tree it is 1176.91 m against 1177 m stated, and the
  8 cm is chord sampling. **This entry's own prediction was right in both
  halves** — that the numbers would agree, and that the thing to ask was what
  fact each line reads. The fault it turned up was the GATE: the one number
  in the farm's layout that no panel line states, left behind when a plan
  moves the fence. Left struck rather than deleted, like 042's through 046's
  entries, because the lesson is the one worth carrying: **the number no line
  prints is the number nothing has checked.** The entry as it stood:
  047 asked 046's axis at the dungeon's panel and
  left the other two half asked, and the half it left is the numeric half.
  `panel_built_test` now produces **every** module's panel from a world that
  was solved and BUILT, which closes the gap as far as SHAPE goes — no line
  empty, no line stating `nan` — but **only the dungeon's nine lines are tied
  to the slabs in the tree**. The farm's panel and the circuit's are still
  checked against nothing: `counted_said_test` feeds both
  `measure(solved["layout"])`, a layout and not a construction.

  **The method is 047's and it is cheap**: build the world, walk the tree,
  count the pieces and add up their areas and lengths yourself, and put each
  number beside the panel line that states it. 047's dungeon pass took four
  readings and found the fault in none of them — the fault was one question
  along, in WHICH GRAPH four lines walked — so expect the same: the numbers
  will probably agree, and the thing to ask of each line is **what fact it is
  reading, and whether anything else in the same panel answers that question
  from somewhere else.** A panel is many readings printed together, which is
  why it is where this class lives (TRAPS 41).

  **READ AND NOT MEASURED, as a starting point for the next session and not a
  finding:** the circuit's panel states a road LENGTH, which 046 recorded as
  coming from the layout and not the construction (*"with one section removed
  from the tree the circuit says 7 sections, 1114 m of road"*), so the
  circuit's panel has at least one line whose number is known not to follow
  the world. Whether that is the same fault or a different fact is the
  question to ask first.

- ~~**The sixth axis, applied to `tests/` — which suites never RUN
  the thing they make a claim about?**~~ **ASKED AT THE DUNGEON'S PANEL IN
  047.** The answer on the panel's nine lines was that all nine agree with
  the geometry, and the fault was one question along: four of them walked a
  door the body could not. Left struck rather than deleted because the entry
  below is still the right method and is only half spent. The entry as it
  stood: 046 added that axis to the table below
  and found it by accident, in the one layer where the answer was *none of
  them*. The method is the same as 042's and it is cheap: for every suite,
  list the functions it calls and ask **where their arguments came from** — a
  pipeline, or a dictionary typed into the suite. A typed fixture is not wrong
  (a suite about a plural rule takes any numbers) and it is a place where
  nothing is tying a sentence to a fact.

  **MEASURED THIS SESSION, by grep, and it is a starting point and not a
  finding — the next session should read each one before believing any of
  it:**

  - **`.build(` appears in THREE of the 53 suites**: `built_count_test` (new),
    `stub_claims_test` (the three Prototype 001 stubs, which place nothing)
    and `walker_test`. **Two suites in the repository actually place geometry**
    — and `walker_test` builds a dungeon to walk a body through it, so it is
    not looking at what was placed either.
  - **`metric_lines(` appears in TWO**, and the split matters: the farm's
    panel and the circuit's panel are fed `measure(solved["layout"])` in
    `counted_said_test`, and **the dungeon's panel — nine lines, the longest
    in Genesis — is fed a dictionary typed into `container_door_test`**, the
    one whose `loops: 1` cannot occur. So the dungeon's panel has never been
    produced from a measured dungeon.
  - **`.solve(` and `.build(` together appear in TWO**: `built_count_test`
    and `walker_test`. Everything else that looks at a world's output starts
    from a layout or a dictionary, not from a request.

  That is the reading. **What it costs is unmeasured** and that is the next
  session's first job: a panel fed a typed dictionary is a sentence nobody has
  checked against a world, and 046's whole finding was that such a gap hides
  where a number comes from. Start at the dungeon's panel, because it is the
  longest, and ask of each of its nine lines what the number is read from.

- ~~**TRAPS 24 — a line that states a count reads it from what
  was BUILT.**~~ **ASKED AND ANSWERED IN 046, and the answer was NO** — in
  three worlds of three, with the rule held only for the stubs that place
  nothing. Left struck rather than deleted, like 042's through 045's entries,
  because **two of this list's own readings were wrong and the next reader
  should see how**: it called racing's count clean because the builder "adds a
  road piece for every section it loops over" (**a count of loop iterations is
  not a count of placed nodes**, and `_add_collision()` in the same function
  can return early), and it said `FarmModule` "overrides neither" `summary()`
  nor `metric_lines()` when it has overridden `metric_lines()` since 003
  (TRAPS 14, in this file). The entry as it stood, kept because its last
  paragraph is the warning that proved true:

  - **`summary()` is the construction layer's sentence — the line a player
    reads when a world is built — and `grep` finds `.summary(` in THREE of
    the 52 suites (`capability_test`, `container_door_test`,
    `counted_said_test`) and `metric_lines(` in TWO.** That is the thinnest
    layer coverage in `tests/` and it is the layer TRAPS 24's rule is about.
  - **`FarmModule` overrides neither.** A built farm says *"Farm built (full
    measurements in the panel)"* from `WorldModule.summary()`, where a dungeon
    says what it built and a circuit says what it built. A sentence that
    states no count cannot state a wrong one, so this is a silence rather
    than a falsehood — which is exactly the shape 032 found at
    `SPAWN_OPPONENTS` before the false line beside it.
  - **Two spot-checks came back clean and are recorded so nobody re-does
    them.** `RacingModule.summary()` reads `report["section_count"]` from
    `CircuitBuilder.build()`, which adds a road piece for every section it
    loops over, so the count is of pieces placed. `DungeonModule.build()`
    places a slab for every room in the layout unconditionally. Neither is
    the fault; **`DungeonModule.summary()` and `metric_lines()` read
    `measure(layout)`, which measures the SOLVED LAYOUT and not the built
    nodes**, and whether those two can ever disagree is the question that
    was not answered this session.

  **And carry the sixth blind spot with the five.** 041 through 046 each found
  a correct check with a blind spot, and **none of the six was found by
  reading the code under test** — each was found by asking what the CHECK
  could not see:

  | axis | the question to ask a suite |
  |---|---|
  | **values** (041) | are its probes all whole, all mid-range, all the same shape? |
  | **direction** (042) | can its regex match only one of the two ways this goes wrong? |
  | **input shape** (043) | is every fixture taking the one branch that was already right? |
  | **layer** (044) | does every probe enter through the same layer of the four? |
  | **question** (045) | does it ask whether a thing EXISTS where what is IN it was owed? |
  | **was it RUN** (046) | does any fixture ever call the thing the sentence is about? |

  045's was the last one: `ledger_said_test` asks whether every command leaves
  a record and says in its own header that it asks nothing about the contents,
  and the contents were owed to nobody for twelve commits. **Existence, shape,
  value and wording are four questions about one field**, and a suite that
  answers one of them says nothing about the other three.

  The method: `grep` for `RegEx` and `contains(` in `tests/` as 042 proposed,
  **and** for each suite list which of the four evidence layers its fixtures
  actually enter. 044's finding was that `procedure_test` — a correct suite,
  the right class, the right values — reached only the validator, and the
  readback beside it had never been asked by anything. **Expect that to be
  true of more than one suite**, and expect the readback and the record to be
  the layers nobody probed, because they are the two that return strings
  rather than verdicts.

- **THE RULES WITH A FUNCTION LEFT TO COUNT, and one of them is now closed.**
  042 expected the third rule to have the same shape as the first two and it
  did; 043 expected the fourth to be the same and **it was, at the rule one
  door along from the one this list named.** 042 expected the third
  rule to have the same shape as the first two, and it did. 043 asked
  TRAPS 10 and 23's and the answer was *only where the fault was found* for
  the **third time running**, with the blind spot in the CHECK for the third
  time running: 041's assertion was fed the one input that could not make it
  fail, 042's sweep could match only one direction of its class, and 043's
  had only ever been given rooms with a `null` size — the one branch that
  was right. **Expect the fourth to be the same.** The remaining rules with
  a function to count, in the order the assistant would take them:

  - ~~**TRAPS 10 and 23 — `Readback.is_label()` and `article()`.**~~
    **Done in 043**, and the finding was not the call-site count but *why*
    it was short: the definite article's only reader was `NpcGoals._place()`,
    a `static` room-naming function in a module file, so nothing else could
    reach it. **A "one reading" that one file can call is not one reading** —
    worth carrying to the other rules in this list, because it is a question
    none of them has been asked. The same commit found `article()` deciding
    between *a* and *an* by the first LETTER when the sound decides it. Left
    struck rather than deleted, like 042's entry above.
  - ~~**TRAPS 20 and 30 — `Readback.as_number()`.**~~ **ASKED AND ANSWERED
    IN 044, and the answer is that the rule HOLDS** — the first rule in this
    list to come back clean, so nobody need ask again. Every bare conversion
    left in `scripts/` is downstream of a validator that rewrote the value
    (`SectionValidator` returns a `clean` float array, so `TrackGeometry`,
    `TrackMetrics`, `ClosureSolver`, `FeasibilityGate` and `SeparationCheck`
    never see a request) or reads Genesis's own bookkeeping. **One thing was
    noted and not changed:** the tools' readback path for a REFUSED spec
    type-checks through `ToolRegistry._same_kind()` — a hand-written
    `typeof()` test rather than `as_number()` — which is a second reading of
    a neighbouring fact. It decides *"is this the same kind as the default"*,
    not *"is this a number"*, so it is a different question and is left
    alone; a session that wants a sixth door to this rule should start there.
  - ~~**TRAPS 34 — `Readback.ordinal_index()`.**~~ **Done in 044**, and this
    list did not name it: it was reached by carrying 043's question to the
    rule above and finding that the rule above was sound. The finding was not
    a call-site count but that **all five of 040's doors are validators or
    handlers** and the six readbacks beside them could not use the one
    reading **because of its RETURN TYPE** — an index, where a readback needs
    the value as sent. Left struck rather than deleted, like 042's and 043's
    entries, because the next reader should see that the rule which looked
    finished was finished at one layer of four.
  - ~~**TRAPS 27 — `Readback.plural()` and `count_of()`.**~~ **Done in 042**,
    and it was wider than this list said: this entry named "the report, the
    session summary and the farm's panels", and the circuit's panel — the one
    that was wrong on every circuit ever built — was not on the list, nor was
    `/worlds`, nor `LoadCheck`, nor the feasibility gate's `(s)`. A list in
    this file of three places was a list of six files. Left struck rather than
    deleted for that reason.
  - ~~**TRAPS 24 — a count read from what was BUILT.**~~ **ASKED AND ANSWERED
    IN 046, and the answer was NO.** `stub_claims_test` held it for the three
    Prototype 001 stubs, which place nothing; of the three worlds that DO
    build, none read its count from what it had placed — the dungeon's from
    `measure(layout)`, the circuit's from `sections.size()` inside the
    builder, the farm's not stated at all. **Nothing was wrong on any world
    measured**: the fault was the missing tie, not a wrong number. The fix is
    `WorldModule.mark_piece()` and `WorldModule.placed_pieces()` on the base,
    a count read off the tree, and `tests/built_count_test.gd`, which fails 4
    times against the pre-046 sentences. **With this the list is empty** — and
    it ends the way it twice warned it would, with two of its own readings
    wrong (see the struck entry above). The next task is the sixth axis asked
    of `tests/`, at the top of this list.
  - ~~**TRAPS 25 — a command's record is part of the command.**~~ **ASKED
    AND ANSWERED IN 045, and the answer was NO.** Counted in the whitelist's
    own unit (TRAPS 31): of the ten commands that have anything to propose —
    `CLEAR_WORLD` takes no fields — **eight recorded it and two did not**.
    This entry's own guess, *"may well be whole"*, was wrong, and the reason
    it looked whole is the entry worth keeping: `ledger_said_test` enumerates
    the whitelist correctly and asks only whether the record EXISTS. The two
    commands that recorded nothing were `CREATE_FARM` and `PLAN`, the fix went
    into `WorldModule.proposal_record()` off `lists()` rather than into the two
    doors, and `DungeonModule.record_fields()` is gone because the base now
    produces it. Left struck rather than deleted, like 042's, 043's and 044's
    entries, because the next reader should see that a list in this file called
    a rule whole and it was short by two.
  - **And a question 042 raises about the suites themselves, which may be
    worth more than any single rule: for every sweep in `tests/`, what is the
    sweep blind to?** 041 found a correct assertion fed the one input that
    could not make it fail. 042 found a correct sweep whose regex could not
    match half its class. Both were the same shape and neither was found by
    reading the code under test — they were found by asking what the CHECK
    cannot see. `grep` for `RegEx` and for `contains(` in `tests/` and ask of
    each one: what passes this that should not?

    **067 ASKED THIS ALONG ONE AXIS AND THAT AXIS IS CLOSED: can a comment
    answer it?** Nine files in `tests/` read a `.gd` source; eleven of their
    scan sites read raw text and **three were satisfied by a single comment
    line** in the direction that matters, each measured in its own throwaway
    copy before anything was changed. All nine now read through one
    `_code_of()`, and `tests/source_scan_test.gd` holds the class at file
    granularity. **The finding worth more than the fixes is that TRAPS 63's
    own wording — "scan code, not comments" — is the WRONG rule**: applied
    literally it narrows two checks that are wide on purpose, so the rule is
    about the DIRECTION of the assertion. See TRAPS 64 and the 067 section.

    ~~**THE FIRST LIVE ENTRY, AND IT IS SMALL AND MEASURED: three
    player-facing sentences say "corner" where the code means a TURN.**~~
    **DONE IN 069, AND IT WAS FIVE SENTENCES IN THREE FILES, NOT THREE.**
    This entry named `feasibility_gate.gd:100`, `racing_module.gd:176` and
    `racing_module.gd:584` and called the work *"three words and a full run"*.
    A grep of the class found two more, **and they are the two that matter
    most**: `racing_module.gd:566` is the `SOLVER CHANGE` **panel row**, which
    a player meets on every circuit that was BUILT, while all three named here
    are reached only by a refusal; and `main.gd:845` said *"tightest corner"*
    for `minimum_radius`, which `TrackMetrics` takes over
    `TrackGeometry.CURVED_TYPES` — the same fault over a wider set, and the
    one reading of three that had drifted (`racing_module.gd`'s `TIGHTEST
    RADIUS` row and `experiment_runner.gd`'s *"tightest radius"* were already
    right, so the wording came from them and not from invention). Left struck
    rather than deleted because the lesson is the one worth carrying and it is
    about THIS FILE: **a list in a handover is a reading and not the class,
    line numbers included** — TRAPS 31's own rule, applied to the handover
    instead of to the code. TRAPS 66. `tests/said_set_test.gd` holds the
    class, 31 assertions, asserting the set and not the word: fault 6 rewords
    *per turn* to *per section that turns* and PASSES.
    **This entry's own prediction was wrong, in the harmless direction**: it
    said to expect a suite to read one of the three even though `grep` finds
    no reader, and none did — the suite that touches these numbers
    (`procedure_test`) reads `max_angle_adjustment` **numerically**, never its
    sentence. The grep was right this time; what was short was the list.

    **AND ONE HALF OF THE SAME CLASS IS LEFT UNDONE DELIBERATELY, which is
    the first live entry now.** All four sentences that now say *"turns"* say
    *"straights"* beside it, and the solver length-adjusts every section in
    `TrackGeometry.STRAIGHT_FAMILY` — straight, uphill, downhill, crest, dip.
    **Identical fault, one word along (TRAPS 11).** It is latent only because
    `SectionValidator.OFFERED_TYPES` holds two of three `YAW_TYPES` members
    and one of five `STRAIGHT_FAMILY` members, the four slopes being the
    subject of **"Human decision needed" 1**. The word a player reads for a
    set the owner has not decided to open is **his call, not an assistant's**,
    so it is written here and not changed. `said_set_test` pins the fact: it
    fails if a slope type ever becomes offered while those sentences still say
    *"straights"*. **If "Human decision needed" 1 is answered (a) leave it,
    nothing needs doing** — the sentences are already true for every
    composition a player can compose today.

    **070 TOOK THE FIRST OF THE THREE AND IT PAID TWICE OVER.** The entry
    below names *"`container_door_test`'s and `counted_said_test`'s
    `\b1 [a-z_]+s\b`"* — **one pattern, and there are two.**
    `container_door_test`'s is `\b1 [a-z]+s\b`, blind to every plural
    Genesis spells with an underscore, `dead_ends` among them, which is a key
    of the dictionary its own sweep runs over. **And the widening the entry
    asks for was measured and rejected**: it flags *"1 of them changes to the
    last world"* and *"1 readback that bears on it"*, both correct at a count
    of one, because the agreeing word is a **verb**. **That control found a
    live fault** — `session_report.gd:242` decided its verb by hand and was
    right at one count of four — and the class was **nine sites**, the AI
    prompt among them. See the 070 section and TRAPS 67.
    **071 TOOK THE SECOND AND THE ANSWER WAS THE SAME SHAPE AS 070'S.** The
    entry's text for `said_article_test` **had** drifted — the pattern is
    `\b([Tt]he|[Aa]n?) ...`, case-folded in its first letter — and **the
    widening it asked for was again wrong**, for a reason the comment on that
    pattern had already measured: two words allowed matches *"a track needs 2
    to 40 sections"*, and `is_label("track needs 2")` is `true`, so the guard
    behind it cannot rule it out. **A regex over free text cannot tell a name
    from a verb.** The blind spot was **not in the pattern but in every
    fixture list behind it**: every name any fixture had handed `is_label()`
    was one word and a number, so narrowing the function to
    `words.size() != 2` put three articles on numbered names into one dungeon
    readback with **all 71 suites byte-identical green**. Fixed by moving the
    sweep onto the names the fixtures use, in **two** suites, not the one this
    entry named (`log_022_test` held the same list). **Nothing in `scripts/`
    was wrong.** See the 071 section and TRAPS 68.

    **WHAT IS LEFT OF THIS ENTRY IS ONE OF THE THREE**, and the first thing to
    do with it is **open the file and read the pattern there** — the drift has
    now been found in the entry's text twice running (070 for the `\b1 ...s\b`
    pair, 071 for this one). Of the **27 regex sites in `tests/`** that grep
    finds, 068, 070 and 071 between them have asked the question of four.
    **And the axis has now turned up the same answer three times, which is
    worth more than the remaining candidate:** on all three the widening the
    entry asked for was wrong, and twice the real hole was one layer behind
    the pattern — in what the fixtures had ever supplied (071) or in which of
    two patterns was being quoted (070). **Ask what the fixtures have never
    supplied before asking what the pattern cannot match.**
    The entry as it stood, each a guess until it is fed its member. The method has now
    paid in 041, 042, 043, 052, 066, 067 and 068: name the member the pattern
    cannot match, feed it that member, watch the suite stay green. **Expect
    the blind spot to be in the check** — and 069 is one more reason to read
    the class off the code before trusting any enumeration of it, this file's
    own included (TRAPS 66).

    **068 TOOK THE REGEX-BREADTH AXIS AT ONE SUITE AND IT PAID.**
    `prompt_bounds_test`'s two count patterns can between them only match a
    bound that states a **maximum**, and the prompt stated four by hand in the
    other direction — the two composition floors and the full turn — none of
    whose constants (`FeasibilityGate.MIN_STRAIGHTS`, `MIN_TURNS`,
    `FULL_TURN`) appeared in any file in `tests/`. Measured: a prompt reading
    *"at least 7 straights and at least 9 corners or hairpins"*, fingerprint
    moved, passed all 69 suites. Fixed by reading all four from their
    constants (prompt byte-identical) and by nine new assertions, and the same
    question found the full turn stated a fourth time to the player and a
    second declaration of the solver's adjustment limit inside the gate. See
    TRAPS 65 and the 068 entry in the starting state.

    **WHAT IS LEFT, AND IT IS STILL THE LARGER HALF.** 068 asked the question
    of ONE suite's patterns out of the twelve files that compile one. The
    other seventeen `compile()` sites and nine `RegEx.create_from_string()`
    sites have not been asked, and the method is unchanged: for each pattern,
    name the member of its class it cannot match, feed it that member, and
    watch the suite stay green. **The candidates 068 read and did not take**,
    so the next session need not re-read them: `container_door_test`'s and
    `counted_said_test`'s `\b1 [a-z_]+s\b` cannot see a plural that does not
    end in `s` (**taken in 070**); ~~`said_article_test`'s
    `\b(The|A|An) ([a-z_]+) ([0-9]+)\b` cannot see an article in front of a
    **two-word** numbered label~~ (**taken in 071**: the quote had drifted,
    the widening was wrong, and the hole was in the fixtures — TRAPS 68);
    **`claim_field_test`'s `^%s: N to M` cannot see a field bound written with
    a dash or as *"between N and M"* — THE ONE LEFT.** Each is a guess until
    it is fed its member, and two of the three guesses have now been wrong
    about where the hole was.

    **AND A SECOND, WIDER QUESTION 068 MEASURED AND DID NOT ANSWER: which of
    the numbers in the prompt is read from the thing that enforces it?**
    ~~**THE NEXT ONE AFTER THE AXIS ABOVE.**~~ **DONE IN 073, and not the way
    this entry asked for.** The paragraph below says the guard would be "a
    table of judgements that can go stale" and that the 41 would have to be
    separated into enforced bounds, worked examples and prose. 073 did not
    build that table. It asked the question one layer behind it — **was this
    number TYPED into the prompt, or PRODUCED by the code?** — and measured
    that **74 of the 92 are substituted and 18 are typed**, so seventy-four of
    them never needed a judgement and the table is eighteen rows.
    `tests/prompt_numeral_test.gd` holds the 18, declared with their counts,
    with the facts behind them measured rather than declared. **All eighteen
    were already true; there was no live fault.** The entry is left here with
    its original text below rather than deleted, because the paragraph's
    reasoning is the record of why it sat open for five commits — and because
    the lesson is 066's: an entry is satisfied by the capability arriving, not
    by the shape it imagined. Grep for the capability before trusting the
    entry. The half 073 does NOT answer is still this file's and
    `claim_field_test`'s: whether a substituted numeral comes from the
    **right** constant.

    The entry as it stood before 073:
    Counted by script rather than remembered: the assembled prompt holds **92
    numerals, 41 of them distinct**. 068 closed four of them by reading the
    prompt line by line against the code, and `prompt_bounds_test` accounts
    for the bounds it names and no others. A guard that enumerated every
    numeral and required each to be either a constant's formatted value or a
    declared non-bound would close the class the way `source_scan_test` closed
    067's, and it is not small: a good part of the 41 are worked examples
    (*"brake at 1200 stops in 0.59 m"*) and ordinary prose (*"room_1, room_2,
    room_3"*), so the declared half would be a table of judgements that can go
    stale. **Worth doing, worth doing deliberately, and worth reading TRAPS 59
    first** — a guard keyed on how a number is written guards the writing.
    One thing already measured and NOT a finding: a scan of every string
    literal in `scripts/` carrying a digit and a bound word (*at least*, *at
    most*, *up to*, *exactly*, *must be*, …) returns **six** sites after
    068's fix, and all six are structural rather than bounds — *"room 1"*,
    *"(1 to %d)"*, and the chicane's *"more than 0 and at most twice the
    radius"*, whose `2.0 * radius` the prompt spells `2 x R` in words rather
    than as a number.

    The entry as it stood before 068:
    **THE REGEX
    BREADTH AXIS, WHICH IS 042'S OWN FAULT AND WAS NOT LOOKED FOR IN 067.**
    042's sweep was correct and its regex could only match one word order; a
    comment cannot cause that and `_code_of()` does nothing about it. The
    method is the entry's own: `grep` `RegEx.create_from_string` and
    `contains(` in `tests/`, and for each pattern ask what member of its
    class it cannot match — then feed it that member and watch the suite stay
    green. **Expect the blind spot to be in the check**, which it has now
    been in 041, 042, 043, 052, 066 and 067.

  The method, which has now worked twice: **take the rule, find the FUNCTION
  the fix introduced, grep its call sites, and count them against the places
  the rule holds.** Where the count differs, measure what the difference costs
  before changing anything. Enumerate from TRAPS's own entries rather than
  from this list, which is a reading and not the class (TRAPS 31) — 042 is the
  second commit running to find that this file's own list of places was short.

  The entry as 041 wrote it, kept because its last paragraph is the warning
  that proved true twice: 041 asked the question this entry used to pose — *for every fix in
  TRAPS 1 to 34, is the rule it produced applied everywhere it holds?* — and
  it is the right question: asked of **one** rule it found eight unfixed
  doors and a fault in the fix itself. **It asked one rule of the
  thirty-four.** TRAPS 34's fifth, *"a number said back is said as the player
  wrote it"*, chosen because it was the newest and so the least likely to
  have travelled. The other rules have not been asked, and the method that
  worked is cheap and repeatable: **take the rule, find the FUNCTION the fix
  introduced, grep its call sites, and count them against the places the rule
  holds.** Where the count differs, measure what the difference costs before
  changing anything.

  The rules with a function to count, which is where to start:

  - **TRAPS 20 and 30 — `Readback.as_number()`**: *"a value from the AI is
    converted through as_number(), never a bare int() or float()"*, and the
    rule explicitly covers *"handlers and builders included"*. 036 fixed four
    commands. `grep` finds bare `float()` and `int()` calls on request-derived
    values in `closure_solver.gd` (`float(s["length"])`, `float(s["angle"])`,
    `float(section.get("length", ...))`) — **all of them downstream of
    validation, which is why they are candidates and not findings.** The
    question is whether any reader of an **unchecked** value is still doing
    its own conversion. **NOT MEASURED, and the two call sites spot-checked
    this session were sound**: `DungeonModule.record_fields`'s
    `int(attempt.get("attempt", 1))` reads `current_attempt`, which is
    Genesis's own bookkeeping and never a request.
  - **TRAPS 10 and 23 — `Readback.is_label()` and `article()`**: the fact that
    a numbered name takes no article, found twice in two functions. Counted
    against every place a name is rendered with an article in front of it.
  - **TRAPS 27 — `Readback.plural()` and `count_of()`**: *"both now, so
    neither is written out again."* 034 swept the validators and the dungeon's
    measurements. The report, the session summary and the farm's panels were
    not in that sweep.
  - **TRAPS 24 — a count read from what was BUILT**: `stub_claims_test` holds
    it for the three Prototype 001 stubs. Every other line that states a
    count is the class.
  - **TRAPS 25 — a command's record is part of the command**:
    `ledger_said_test` enumerates the whitelist, so this one may well be
    whole; worth confirming rather than assuming.

  **Expect the answer to be "only where the fault was found" more than once**,
  because that is what 041 found at the first rule it asked, and the rule it
  asked was one commit old. Enumerate from TRAPS's own entries rather than
  from this list, which is a reading and not the class (TRAPS 31, and the
  mistake 039 caught in this file's list of eight).

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
- ~~**The boots prompt tells the model two different things about the same
  player sentence.**~~ **Done in 038**, and the useful part is not the
  contradiction but the reason it lasted: 013 added `brake`, MEASURED that it
  does the job for nothing, and wrote the assertion that says so, and the
  sentence telling the model otherwise was never read again. A capability was
  asserted in the suite and a claim was made in the prompt and nothing joined
  them, so the two disagreed, both green, for 33 commits. Left struck rather
  than deleted, because the next reader should see that the entry below
  called `CarTool`'s claim *"right"* on the strength of the field being named
  `braking` — which is all it was, a name, and `footing` read just as
  plausibly. It is now measured by driving a car (`physics_test`). See 038
  and TRAPS 32.

  The original entry, as 037 wrote it, kept because its last paragraph is the
  question that turned out to matter: *Found while measuring 037 and
  **measured, not inferred**, with the functions that enforce it:*

  ```
  ordinary                 top 4.48 m/s   stops in 1.45 m from its own top
  footing raised to 1.50   top 2.00 m/s   stops in 0.29 m
  brake raised to 1200     top 4.48 m/s   stops in 0.59 m
  ```

  *(038's note on that table: those are three stops from three different
  speeds, which is not a comparison. From one speed — 4.48 m/s — footing at
  1.50 takes 1.09 m where brake at 1200 takes 0.59 m.)*

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
- ~~**Every sentence in the prompt that states what Genesis DOES with a
  value, asked the way 038 asked of the three it fixed.**~~ **Done in 039**,
  and the useful part is that the list of eight below was not the class. A
  list written by READING is a sweep whose unit nobody checked (TRAPS 31),
  and three sessions had read that section without seeing what was in it.
  Asked instead for the sub-class that can be settled by DOING THE
  ARITHMETIC, the prompt holds six such sentences and the one that was false
  is not on the list below at all: *"Top speed is push divided by weight
  times footing"*, while `top_speed()` returns `push / (weight * footing)`
  — a sentence that puts `footing` on the wrong side of the division and so
  told the model that raising it goes faster, four lines under the bullet
  038 had just written saying it goes slower. Six of the eight below were
  measured this session and are true; the three that are now in a suite are
  marked. Left struck rather than deleted, because the next reader should
  see that the eight quoted sentences were a reading and the finding was one
  the reading missed. See 039 above and TRAPS 33.

  ~~**Still undoored of the eight below:**~~ **All eight are now doored.**
  The three chicane and signed-angle claims went into `formula_test` in 039;
  the remaining five — *"Room 1 is the entrance"*, *"R is a room's name or
  its number counting from 1"*, *"A door joins two different rooms, and the
  same pair may only be joined once"*, *"The game can adjust each angle and
  each straight length by up to 20%"* and *"a new world replaces whatever
  was there before"* — are `tests/procedure_test.gd` as of **040**, built
  from the registry and the prompt as this entry asked. Asking it that way
  was the whole value: **two of the five were members of larger classes and
  each class had a fault** — a fractional position truncated in silence at
  four of five reference doors, and a plan that destroyed the standing world
  it then failed to replace. See 040 above and TRAPS 34.

  The original entry, as 038 wrote it: *038's finding is that the prompt makes several kinds of claim and
  Genesis has now built a door for four of them: limitations (027),
  capabilities (028), bounds (035) and which-field-does-it (038). **The
  kind with no door left is the procedural one** — a flat statement about
  what Genesis will do with a number the model sends. **NOT MEASURED.**
  These are the sentences, read out of the assembled prompt this session and
  quoted rather than paraphrased:

  - *"Angles are signed: positive turns right, negative turns left."*
  - *"Never give a corner, hairpin or chicane a length; it is calculated."*
  - *"A chicane steps the track sideways by O metres and returns to its
    original direction."*
  - *"Room 1 is the entrance, where the player comes in."*
  - *"R is a room's name or its number counting from 1."*
  - *"The game can adjust each angle and each straight length by up to 20%
    to close the loop"* — the 20% is already held by `prompt_bounds_test`
    against `ClosureSolver`; whether it adjusts **each** rather than some is
    not.
  - *"A door joins two different rooms, and the same pair may only be joined
    once."*
  - *"a new world replaces whatever was there before, whichever kind it
    was."*

  Each is a claim about Genesis and gets checked like one, and every one of
  them is cheap: build the thing the sentence describes and read what comes
  out. Expect the answer to be wider than one sentence, because that is what
  034, 035, 036, 037 and 038 each found when the same question was asked of
  a whole list. **Do not assume any of them is false** — nine of eleven
  bounds were right in 035, and the value of that session was the two that
  were not.* *(039's answer: none of the eight is false. Six were measured
  and are true; the other two — "Never give a corner, hairpin or chicane a
  length" and the 20% adjustment — are true as well. The false one was a
  sentence this list did not contain.)*
- **Two refusal examples show the model a style shape the prompt forbids.**
  Found by 037, still open, and **not** part of 038: measured this session,
  neither string is in the assembled prompt, so it does not move
  `PROMPT_FINGERPRINT` and does not need its own commit for that reason. The
  prompt says a style is *"a short lowercase label with underscores"*;
  `SectionValidator`'s refusal example is `{"style": "a street circuit"}`
  and `PLAN`'s is `{"style": "a farm with a circuit round it"}`, both with
  spaces. Nothing refuses a style, so neither example is illegal to Genesis
  — they just show the model a shape its instructions rule out, in the one
  place (a refusal) where it is most likely to be copied. Cosmetic, one word
  each, and worth folding into whichever commit next touches those two
  files rather than taking on its own.
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

---

## 053 — the refusals no legal request can reach, and which of them can be proved connected

**Objective.** The task this file named as the next assistant task: *052's
question asked of a LIST instead of a key, and the list is the refusal
categories.* Two members were known and both had been found by accident —
`FAILED_UNWALKABLE` by 005, the farm's lane branch of `FAILED_LAYOUT` by 052
— and the question was how many more there are, and whether each of them
catches the thing it names.

**Starting state.** Branch `prototype-002a` at 052 (`7435974`). 59 suites,
`--all`, 0 with something to look at, measured in this container before
anything changed.

### The enumeration, and it is mechanical

`grep` for `FAILED_<NAME>` across `scripts/` gives **sixteen** categories.
Ten of them are returned by the three world modules' four-step pipeline
(`validate -> pre_check -> solve -> post_check`), which is the class this
commit sweeps. Six are the controller's and the parser's — `FAILED_SCHEMA`,
`FAILED_SCENE`, `FAILED_NOTHING_BUILT`, `FAILED_NO_HANDLER`, `FAILED_PARSE`
and the AI runner's `FAILED_AI` — and **neither question is asked of them
here**; they need a scene tree and a whitelist walk rather than a module
sweep, and that is the next task below. `FAILED_UNWALKABLE` has two owners,
the dungeon's `post_check()` and `GameController._order()`; only the first
is swept. The parser's `UNSUPPORTED` is a refusal and is not a `FAILED_`
category at all, so it is outside this entirely — said rather than left to
look covered.

Ten names, but **twelve branches**: `FAILED_LAYOUT` is returned from three
different places for three different reasons, and a table with one row per
NAME would have hidden two of them.

### The answer: seven of twelve cannot be reached, and all seven fire

| branch | where | (1) a legal request? | (2) fires when violated? |
|---|---|---|---|
| `FAILED_UNREACHABLE` | dungeon `pre_check` | **yes** — 3 rooms in a triangle, a 4th outside it | — |
| `FAILED_DEGREES_OF_FREEDOM` | racing `pre_check` | **yes** — two straights and no corner | — |
| `FAILED_INFEASIBLE` | racing `pre_check` | **yes** — two 10° corners, net turn 20° | — |
| `FAILED_CLOSURE` | racing `solve` | **yes** — two 1000 m straights against one of 20 m | — |
| `FAILED_SEPARATION` | racing `post_check` | **yes** — a 13-section composition that closes and runs over itself twice | — |
| `FAILED_PLACEMENT` | dungeon `solve` | no — rings 1..4 hold **80** slots, a dungeon has at most **23** other rooms | **yes** — 200 rooms off one hub |
| `FAILED_CORRIDOR` | dungeon `post_check` | no — **0 crossings** in 516 solved dungeons; a corridor runs down a lane `GAP` (6 m) wide and is 4 m | **yes** — rooms wider than their pitch |
| `FAILED_UNWALKABLE` | dungeon `post_check` | no — 005's answer, unchanged | **yes** — a shut door |
| `FAILED_TOO_BIG` | dungeon `post_check` | no — 24 rooms at pitch 46 span at most **1098 m**, limit **1400**; widest swept 1098.0 | **yes** — slots 20 pitches apart |
| `FAILED_LAYOUT` (no zones) | farm `solve` | no — `MIN_ZONES` is 1, `validate()` refuses first | **yes** — `solve({"zones": []})` |
| `FAILED_LAYOUT` (lane) | farm `solve` | no — narrowest gap over 544 farms exactly **6.0000 m** | **yes** as a function; **see below** |
| `FAILED_LAYOUT` (no solver) | `WorldModule.solve` | no — all three modules override `solve()` | **yes** — the base called direct |

**No dead refusal, and that is the headline.** Every one of the seven
branches no player can reach still catches the thing it names when it is
handed one. Seven guards, not seven pieces of dead code pretending to be a
safety net.

**And the sweep is not the evidence for the first column.** Each *no* is
arithmetic over the module's own constants, asserted as such, because a
sweep that missed a shape looks exactly like a bound that holds — which is
how this session's first sweep got `FAILED_UNREACHABLE` wrong (TRAPS 47).

### The one that cannot be proved connected, which is the finding

**Delete the call to `FarmModule._check_reachable()` from `solve()`, leave
the function sitting there, and all 60 suites still pass.** Measured, with
the full `--all` run, not supposed.

The other six guards are reached through a door that takes the thing they
check: `post_check(a layout)`, or `solve(a content)`. A test hands that door
a violation and the category comes back, so wiring the guard out is caught —
measured one at a time for all six, one failure each. The farm's lane check
is the only one called INSIDE `solve()` on a layout `solve()` has just
built, and `solve()` cannot be made to build a violating one. **There is
nowhere to hand it in.** So its row has two answers: the function refuses a
violation, and the pipeline cannot be shown to call it.

052 considered moving it into `post_check()` — where `WorldModule`'s own
comment says a check on a solved layout goes, and where racing puts its
separation check — and declined it as *behaviour-identical, a move rather
than a fix*. It is still behaviour-identical. It is also the difference
between a guard that can be proved connected and one that cannot, which is a
reason 052 did not have. **Not done here**: it changes where a refusal comes
from, so it is "Human decision needed" 18.

### What changed in the code

Nothing a player can reach. Seven comments, one at each guard, each naming
the arithmetic that puts it out of reach and the fixture that fires it —
which is TRAPS 6's own instruction (*"worth keeping, worth labelling"*)
applied to the whole list rather than to the two members that already said
so. `DungeonModule.post_check()`'s header **claimed** the corridor check
"cannot happen by construction" and nothing had ever measured it; it now
says so with the number beside it, and says the same for the two refusals
next to it that it did not mention at all.

### Evidence — what was actually run

- Godot 4.7.1 headless on Linux (`4.7.1.stable.official.a13da4feb`), in a
  cloud container. **Baseline at 052: 59 suites, `--all`, 0 with something
  to look at. After: 60 suites, `--all`, 0 with something to look at.** The
  lists were **diffed**; the only difference is `refusal_reach_test`.
- `tests/refusal_reach_test.gd`: **93 assertions**. Run with `--fixed-fps 60`
  and without; passes either way (TRAPS 4).
- **It was run against broken code before it was believed** (052's lesson).
  Thirteen deliberate breakages, one at a time: `MAX_EXTENT` 1400→900 (2
  failures), `MAX_RING` 4→1 (3), `MIN_ZONES` 1→0 (3), `GAP` 6→0.5 (4),
  `FAILED_SEPARATION` renamed in the source (3), and each of the seven
  guards wired out of the step that calls it (1 each for six of them).
  **The fourteenth — the farm's lane guard wired out — it does not catch**,
  and that is reported rather than papered over.
- `run_tests.bat` needed no edit: all sixteen of its `findstr` patterns were
  RUN against `refusal_reach_test` and none matches, so it runs there
  without `--fixed-fps`, which is what it gets here.
- README said 59 suites and there are 60, counted with `ls`.

### What the tests did NOT prove

- **No model sent any of this.** Every request in the suite and in the
  measuring was typed by hand; this harness has no key.
- **Nothing was rendered on a screen**, and no world was looked at. What was
  compared is categories, layouts and measurements, headless.
- **No farm, dungeon, track, record or saved world changes.** The prompt is
  byte-identical, `PROMPT_VERSION` did not move, and nothing on the owner's
  disk was touched. The only code changes are comments.
- **The six controller categories are not measured**, and nothing here
  claims they are. They are enumerated, declared `NOT_ASKED`, and named as
  the next task.
- **"Unreachable" is a statement about today's constants**, not a theorem.
  Each one is asserted as arithmetic so that a change to a constant moves
  the suite, which is the most a suite can do.

### Found while measuring, written up rather than fixed

- **`FAILED_UNWALKABLE` has two reasons and only one of them can ever
  happen.** A doorway is cut to the width of the corridor leg that meets it
  — `CORRIDOR` is 4 m, `BODY` is 1.6 m — so *"a person 1.6 m across cannot
  get to X"* for a doorway too narrow cannot be produced by any room size,
  legal or not: rooms of 1, 2, 3 and 4 m were handed to `walkable()` and
  none blocked anything, because a room narrower than the corridor has no
  wall left to block with. The only input that makes `walkable()` refuse is
  a **shut door**, and `set_shut()` only runs on a layout already standing,
  so `post_check()` never sees one. The branch's live work is done by the
  same `walkable()` AFTER the build, where `route()`, the panel and the
  metrics read it.
- **A corridor that crosses a room reports the same sentence once per leg.**
  The fixture that fires `FAILED_CORRIDOR` comes back with *"a to c passes
  through b"* four times. It is in a branch nothing can reach, so it costs
  nothing today; it is written down because the day the branch is reachable
  is the day a player reads it four times.

**Next action.** The same two questions asked of the six controller
categories — see the candidate list.

## 054 — the refusals the controller returns, and the count a comment got wrong

**Objective.** HANDOVER named the next assistant task as 053's two questions
asked of the categories `GameController`, `main.gd` and `ExperimentRunner`
return, which 053 enumerated and declared `NOT_ASKED`: *can any request a
player can send produce this refusal, and handed an input that does violate
it, does the check fire?* 053 said they "need a scene tree and a whitelist
walk rather than a module sweep". They do.

**Starting state.** Branch `prototype-002a` at `ce8050d` (053). 60 suites,
`--all`, 0 with something to look at. `refusal_reach_test` carried six rows
marked `NOT_ASKED`.

### The first answer is the SIZE of the list

Seven names. **Twenty-eight branches.** `FAILED_SCHEMA` is returned from
eleven places, `FAILED_SCENE` from nine, `FAILED_UNWALKABLE` from two (and
those two are the controller's, not the dungeon's — the same name has three
branches across the project), `FAILED_NOTHING_BUILT` from three,
`FAILED_NO_HANDLER`, `FAILED_PARSE` and `FAILED_AI` from one each.

053's hardest-won lesson was that `FAILED_LAYOUT` is returned from three
places for three reasons and *"a table with one row per name would have
hidden two of them"*. So every row in the new suite is a BRANCH, and the
enumeration counts refusal CALL SITES in the three controller files rather
than distinct names — which is also what makes it fail closed: a
twenty-ninth branch added to a category that already has rows is caught by a
count, not by a name.

### The answer: 22 reachable, 5 guards, all 5 fire, 1 needs a key

| | |
|---|---|
| REACHABLE | 22 branches, each driven by a named request through `main.gd` |
| GUARD | 5 branches, no legal request reaches them, all 5 fire when violated |
| NEEDS_KEY | `FAILED_AI` — question 1 cannot be answered in this harness |

**No dead refusal in the controller either.** And unlike 053's farm guard,
**every one of the five can be proved CONNECTED**: each has a door that takes
the thing it checks, so each was wired out of the step that calls it, one at
a time, and the suite caught every one. The five, with the fact that puts
each out of reach:

- **`FAILED_NO_HANDLER`** — `execute()`'s `_` branch. Every command
  `CommandParser.allowed_commands()` admits has either an unguarded case in
  `execute()` or a module in `WorldRegistry`, so `find()` never comes back
  null. Walked over the whitelist against the case list **read off
  `execute()`'s own source**, so a twelfth command admitted without a case
  fails the suite — measured by adding one. `CREATE_TRACK`'s case is
  *guarded* (`when not parameters.has("sections")`), so a sectioned one
  falls through to the `_` branch and is answered by the registry; the walk
  counts a guarded case as no case, which is the only reading that is safe.
  Fired by handing `execute()` a command no case matches.
- **`FAILED_SCHEMA` at `SPAWN_OPPONENTS`** — *"count must be a number"*. It
  stands after the `has_track()` refusal, and `TrackBuilder.corner_nodes` is
  appended to nowhere in `scripts/` — **grepped by the suite, not
  remembered** — so `has_track()` is always false and the refusal above
  returns first. The comment at that line has said so since 036, and
  `stub_claims_test` has asserted the builder's half since 032 — see the
  finding below. Fired by putting two nodes into `corner_nodes`.
- **`FAILED_NOTHING_BUILT` at `SPAWN_OPPONENTS`** — the same reason, four
  lines further down, **and it was not labelled.** See the finding below.
- **`FAILED_SCENE`, `ORDER`'s *"there is nobody to order about here"*** — it
  needs `WorldRegistry.find(standable.command)` to be null while rooms
  exist. Two facts, both asserted. **`DungeonModule` is the only module that
  reports a standable at all** — grepped across `scripts/`, where
  `WorldModule` merely documents the key — and it puts its own `command()`
  in it, which the registry knows; the suite asserts that property of every
  registered module, so a second standable-reporting world is asked too. And
  an `ORDER` sent with nothing standing is refused one step EARLIER by
  `NpcGoals`, as `FAILED_SCHEMA` — *"there is nobody to order about: build a
  dungeon first"*, measured. Fired by setting the standable's command to a word no
  module answers to.
- **`FAILED_SCENE`, `ORDER`'s *"the thing is not in the world any more"*** —
  it needs a thing LISTED in `standable.things` whose node is dead. Asserted
  as the invariant it guards: over a build, a SHUT, an OPEN, an errand in
  progress and a SHUT during one, every thing in the list has a valid node.
  Fired by freeing a node and leaving it listed.

### The finding is a count in a comment

`FAILED_NOTHING_BUILT`'s own header in `game_controller.gd` names **"the
three Prototype 001 paths"** as the ones that answer to it. Measured: **only
two of the three can be reached.** `MODIFY_TRACK`'s and the sectionless
`CREATE_TRACK`'s are reachable and the suite sends one of each.
`SPAWN_OPPONENTS`' is a guard — and the comment at its SCHEMA sibling, four
lines above it, has given exactly that reason since 036. **The label was put
on one member of a pair and never on the other**, which is TRAPS 11 at the
scale of two adjacent branches, and TRAPS 14 in a comment that states a
count.

**And the sharper version of the finding is that the repository already
disagreed with itself.** `stub_claims_test` has said since 032, in its own
header, that `corner_nodes` is never filled and that this is *"the reason
`SPAWN_OPPONENTS` can never run"* — and it asserts it, on the builder.
So one file knew the branch was unreachable while another file's comment
counted it among three live answers, for twenty-two commits. Neither was
reading the other. **The label is not new information; it is the information
arriving where a reader of that category would meet it.** Found by grepping
`tests/` for the thing this file's own first draft denied — it said "nothing
asserted it", and something did (TRAPS 14, in this handover).

**Nothing is wrong on any request today.** The category still has two live
answers and both say what they should. What was wrong is that a reader
counting live answers off that comment would have got three — and the day
someone takes `SPAWN_OPPONENTS` out of the whitelist under "Human decision
needed" 2, the comment would have predicted a change to this category that
would not happen.

### And the first reading got three branches wrong (TRAPS 48)

Each of the three was read off the functions correctly and was wrong about
the running program.

- **The starter circuit.** `main.gd` stands an **unrecorded** circuit in the
  world at launch (`controller.show_unrecorded`, `main.gd:135`) so there is
  something to drive before anything has been asked for, and that sets
  `drivable`. So on a fresh session `has_drivable()` is **TRUE before any
  request**, and both `MODIFY_TRACK` and `SPAWN_OPPONENTS` answer with their
  composed-track branch. Their other branches — `MODIFY_TRACK`'s *"corner
  must be a number"* and *"nothing to change"*, `SPAWN_OPPONENTS`' *"build a
  track first"* — are reachable only after the world has been cleared. All
  of them are REACHABLE rows; the fixtures clear first and say why.
  **What it means for a player is a sentence and not a mechanism**: his
  first `MODIFY_TRACK` of a session is refused for a track he never asked
  for. Noted under "Human decision needed" 2, with the rest of the three
  stubs' future. Not changed.
- **A carried thing stands in no room.** `FAILED_SCENE`'s *"the lamp is not
  in any room"* was read as a guard, on the reasoning that a thing is placed
  in a room and delivered to a room. It is **reachable**: a thing being
  CARRIED is in a corridor for part of the errand. Sampled every 20 frames
  over one errand, the lamp was in room 1 (43 samples), in room 2 (69) and
  **in no room at all (8)**. A second `ORDER` sent at that moment reaches
  the line, and the suite produces exactly that — it waits for a roomless
  frame and sends one. It took stepped physics to find, not a closer read.
- **`SPAWN_OPPONENTS`' count check** was read as the refusal a bad count
  gets. It is a guard, as above.

### Implementation

- **`tests/controller_reach_test.gd`**, new, **136 assertions**. One row per
  branch; the enumeration read off the source; a named request at each
  reachable branch; a violation handed to each guard.
- **Comments at the five guards and at the two branches that were read
  wrong**, in `scripts/game_controller.gd` — TRAPS 6's *"worth keeping,
  worth labelling"*, applied to the rest of the list rather than to the two
  members that already said so (TRAPS 11). `FAILED_NOTHING_BUILT`'s header
  now says which two of its three paths are live. **No behaviour changes
  anywhere.**
- **`tests/refusal_reach_test.gd`**: the six `NOT_ASKED` rows become
  `ASKED_IN_054`, which says where the per-branch answer is rather than
  stating a verdict one row per NAME cannot hold — `FAILED_LAYOUT`'s problem
  one layer out. Its out-of-scope paragraph now points at the new suite, and
  both suites assert from their own side that every `FAILED_` name in
  `scripts/` is answered for by one of them, so a category cannot sit
  between them unanswered.
- **`run_tests.sh` and `run_tests.bat`**: the new suite joins the fixed-rate
  list in both. It steps physics to carry a thing, and none of
  `run_tests.bat`'s twelve `findstr` patterns matched the new name — RUN
  against it, not eyeballed.
- **`README.md`**: said 60 suites; there are 61, counted with `ls`.

### Evidence — what was actually run

- Godot 4.7.1 headless on Linux (`4.7.1.stable.official.a13da4feb`), in a
  cloud container. **Baseline at 053: 60 suites, `--all`, 0 with something
  to look at. After: 61 suites, `--all`, 0 with something to look at.** The
  lists were **diffed**; the only difference is `controller_reach_test`.
- **It was run against broken code before it was believed** (052's lesson,
  053's practice). **Sixteen deliberate breakages, one at a time**, every
  one caught — the list and the failure counts are under "Run the tests
  first" above. The ones worth naming here: a branch ADDED to a category
  that already had rows (caught by the count, not the name), the starter
  circuit taken away, and each of the five guards wired out.
- Run with `--fixed-fps 120` and without; passes either way (TRAPS 4).

### What the tests did NOT prove

- **No model sent any of this.** Every request in the suite and in the
  measuring was typed as raw JSON through `main.gd`'s own typed door; this
  harness has no key, and nothing was reproduced from the owner's screen.
- **Nothing was rendered on a screen** and no world was looked at.
- **No world, record or saved file changes.** The prompt is byte-identical,
  `PROMPT_VERSION` did not move, and nothing on the owner's disk was
  touched. The only `scripts/` changes are comments.
- **`FAILED_AI`'s first question is not answered.** It needs a live API key
  and an API that fails, and this harness has neither. Nothing claims it is
  reachable or that it is not. Its second question IS answered:
  `ExperimentRunner` handed `MAX_RETRIES + 1` failures writes the category.
- **Two pairs of branches share a category AND a command**, and the suite
  cannot tell them apart beyond the scene state that selects them.
  `MODIFY_TRACK` and `SPAWN_OPPONENTS` each have branches chosen by
  `has_drivable()` and `has_track()`; the fixtures set that state and assert
  it beside the category, and do not read a line number. Said here rather
  than left to look like full resolution.
- **"Unreachable" is a statement about today's lists**, not a theorem — the
  whitelist, the registry, the case list and `corner_nodes`. Each is read
  off the source by the suite, so a change to any of them moves the suite,
  which is the most a suite can do.
- **The duplicate-id fault is reproduced and not fixed.** Driving the plan
  that fails when its worlds are placed produces it again: two step records
  appended `BUILT` and then the same two dictionaries appended `FAILED`
  under the same ids. It is "Human decision needed" 17(c) and it is the
  owner's. The suite reads records by POSITION in the ledger rather than by
  id for exactly that reason, and says so.

**Next action.** The class question behind "Human decision needed" 18, asked
of the whole project: **which checks in Genesis are called on input the same
function produced, and therefore cannot be proved connected?** 053 found one
(`FarmModule._check_reachable()`); 054 found that all five controller guards
have a door and none has the problem. Nobody has asked it of the rest —
tool validators, `SectionValidator`, `SeparationCheck`, `LoadCheck`,
`RefusalCheck`, the readbacks. The question is mechanical: for each check,
is there a caller that can be handed a violating input, or is its only input
built by the function that calls it? The answer for each is either a fixture
or a row in the owner's column.

## 055 — the checks that fire and the checks that are reached, which are not the same list

**Objective.** The task this file named as the next assistant task: the class
question behind "Human decision needed" 18, asked of the whole project —
*which checks in Genesis are called on input the same function produced, and
therefore cannot be proved connected?* 053 found one
(`FarmModule._check_reachable()`); 054 found that all five controller guards
have a door. Nobody had asked it of the rest.

**Starting state.** Branch `prototype-002a` at `09824fd` (054). 61 suites,
`--all`, 0 with something to look at, measured before anything was changed.

### The question turned out to be two questions, and the second is the one with answers in it

HANDOVER asked it structurally: *is there a caller that can be handed a
violating input, or is its only input built by the function that calls it?*
Asked that way the answer is dull — almost every check in Genesis has a
public door, and the farm's is the only one that does not.

The useful question is 053's operational one, and it is about the CALL rather
than about the check: **if this call stopped refusing tomorrow, would any
suite say so?** A check that fires and is not wired in refuses nothing. A
check that is wired in and that no test reaches through the game's own door
is a check the suite is not holding. From the green line at the bottom of a
run those two look identical, and so does a check that is working.

**The method is 053's, fourteen times.** Take one call site, make it stop
refusing — force its `ok`, or drop the branch that returns the refusal — in a
throwaway copy of the repository, run every suite, diff the result lines
against a baseline taken the same way, put the copy back. Nothing in this
repository was edited to measure it and no guard was removed from Genesis.

### The answer: fourteen call sites, ten held, four not — and only one of the four is the farm's problem

| | call site | wiring it out |
|---|---|---|
| W01 | `LoadCheck.compare` at `main.gd:618` | **NOT CAUGHT**, `--all` included |
| W02 | `RefusalCheck.quarrel_with` at `main.gd:298` | **NOT CAUGHT**, `--all` included |
| W03 | `FeasibilityGate.check` in racing's `pre_check` | `refusal_reach_test` |
| W04 | `SeparationCheck.check` in racing's `post_check` | `refusal_reach_test` |
| W05 | `SectionValidator.validate` in racing's `validate` | `container_door_test`, `intent_door_test`, `plan_said_test`, `prompt_bounds_test` |
| W06 | `FarmModule._check_reachable` in `solve()` | **NOT CAUGHT** — and **no door**: 053's |
| W07 | `NpcGoals.validate` at `game_controller.gd:235` | `controller_reach_test` |
| W08 | `NpcGoals.validate_door` at `game_controller.gd:476` | `controller_reach_test`, `interference_test`, `panel_refused_test` |
| W09 | `tool.validate` at `game_controller.gd:601` | `controller_reach_test` |
| W10 | `module.validate` at `game_controller.gd:1148` | `controller_reach_test`, `intent_door_test`, `procedure_test` |
| W11 | `module.pre_check` at `game_controller.gd:1153` | `controller_reach_test` |
| W12 | `module.post_check` at `game_controller.gd:1171` | `controller_reach_test` |
| W13 | `module.solve` at `game_controller.gd:1158` | `session_test` **and nothing else** — `--all` only |
| W14 | `tool.validate` at `tool_registry.gd:47` | **NOT CAUGHT**, `--all` included |

**The three that have a door nobody walked**, which is the finding:

- **`LoadCheck.compare`.** 025 built it because *"Loaded 'vault'"* was a claim
  about a file being opened dressed as a claim about a world coming back —
  *"the project's own rule, unapplied in the one place it was cheapest to
  apply"*, in its own header. Replace the verdict with a constant `RESTORED`
  and all 61 suites pass. `load_check_test` is 236 lines and calls
  `LoadCheck.compare()` fourteen times, and never once through `/load`.
- **`RefusalCheck.quarrel_with`.** 023's answer to a refusal that denies
  something Genesis does. Hand the caller an empty array and all 61 suites
  pass. `asked_test`, `limits_test` and `log_023_test` all call it directly.
- **`ToolRegistry.readback`'s validated branch.** Sharper than the other two,
  because the door WAS walked — with inputs that could not show the
  difference. `boots_test` reads back `{"weight": 130.0}`, which is identical
  whether it comes from the validator or from what was merely heard;
  `log_022_test` reads back a REFUSED look, which is the other branch. Of
  eight sampled legal specs, five differ between the two paths: *"the
  ordinary RED car"* against *"the ordinary red car"*.

**And one held so thinly it is worth its own line.** The controller's solve
step (W13) is caught by `session_test` — which sends a track that misses the
start line and counts it as a failed request — and by nothing else.
`session_test` takes minutes and runs only under `--all`, so on an ordinary
run the controller's passing-through of a module's refusal is held by
nothing. `controller_reach_test` counts those three sites as PASSTHROUGH and
leaves them to `refusal_reach_test`; `refusal_reach_test` asks the modules
directly. The passing-through itself was between the two of them.

### The first set of answers was wrong, and why is worth more than the answers

The fourteen runs were first done two and three at a time, in separate copies
of the repository, to save wall-clock. **Every copy of this project shares
one Godot `user://` directory** — `config/name` is the same in all of them —
so all of them write one `user://track_log.jsonl` and one `user://worlds`.
Every run was reading another run's ledger. `ledger_test` and
`intent_door_test` duly failed under nearly every change, and were read as
*"the guard is held"*: **`LoadCheck` and `RefusalCheck` both looked connected
and are not.** Four of the fourteen answers were wrong, all in the flattering
direction.

It was found by noticing that the two suites catching everything are not in
the slow list, so a `--all` run and a fast run should have agreed about them
and did not. Every measurement above was re-taken **one at a time, with
`user://` cleared before every run including the baseline**. TRAPS 50, and
the README now says to run the suite one at a time.

### What changed

- **`tests/check_wiring_test.gd`**, new: 179 assertions. One row per
  verdict-returning function in `scripts/` (35 of them), fail-closed in both
  directions; the structural facts behind the one NO_DOOR row; and the four
  doors nothing walked, walked. Each fixture reads the LEDGER or the
  readback, not a status line.
  - a world saved, one measurement in the save file made false on disk, and
    `/load`: the load record must say `DIFFERENT` and name the measurement.
    The honest load is asserted first, because a check that always says
    `DIFFERENT` is no better than one that always says `RESTORED`.
  - an `UNSUPPORTED` answer whose reason denies a capability, sent through
    the door an AI answer comes through: the ledger's record must carry the
    quarrel. The lie is built from `RefusalCheck.CAPABILITIES` rather than
    typed out, and the suite asserts it really is a lie first. An honest
    refusal must leave no note.
  - a circuit the solver cannot close, through `main.gd`: `FAILED_CLOSURE`
    and no valid world.
  - a tool spec the validator normalises, asked of every tool in the registry
    and built from each tool's own defaults (TRAPS 11), so a fourth tool is
    asked without the file being edited. The refused half — said back from
    what was heard, never from the defaults (TRAPS 8) — is asserted beside
    it, so the pair is held in one place.
- **`tests/refusal_reach_test.gd`**: one assertion corrected. See below.
- **`scripts/world_module.gd`**: comments only. The note at `solve()` pointed
  at an assertion that could not fail, and said nothing about the farm.
- **`README.md`**: 61 suites to 62, and run them one at a time.
- **`docs/TRAPS.md`**: traps 49, 50 and 51.

### Running the new suite against broken code found a fault in 053's work

Thirteen deliberate faults, one at a time, every one caught. The eleventh was
renaming `CarTool.validate()` — and the suite's own reflection check stayed
green.

**`Script.get_script_method_list()` includes the methods a script INHERITS.**
053 declared `WorldModule.solve()`'s `FAILED_LAYOUT` unreachable because all
three modules override `solve()`, and wrote that assertion by reflection
rather than by listing the three, explicitly so a fourth world would be asked
without the file being edited. Every module reported every `WorldModule`
method as its own. The assertion could not fail, and a fourth world that
overrode nothing would have passed it.

**The fact is unchanged** — all three modules really do define `solve()`,
re-read off their source. What was not true is that anything was holding it,
for twelve releases, and `WorldModule.solve()`'s own comment named the
assertion as the guarantee.

**And it was hiding a smaller fact worth having: `FarmModule` defines neither
`pre_check()` nor `post_check()`.** A farm runs the base's, which refuse
nothing. Nothing is wrong today — they are defaults, not stubs — but the
project believed every module had its own, because the only thing it asked
had answered yes. `check_wiring_test` now writes down which module defines
which step and fails if that changes; both suites read the module's own
source instead of asking the engine. TRAPS 51.

### Evidence — what was actually run

Godot 4.7.1 headless on Linux (`4.7.1.stable.official.a13da4feb`), in a cloud
container, every run **sequential** with `user://` cleared first.

- **Baseline at 054**: 61 suites, `--all`, 0 with something to look at.
  Re-taken clean before the measurement.
- **After**: 62 suites, `--all`, 0 with something to look at. The suite lists
  were diffed and the only difference is `check_wiring_test`.
- **`check_wiring_test` is 179 assertions** and fails against **thirteen**
  deliberate faults, one at a time: the `LoadCheck` call wired out (3
  failures), `LoadCheck` made to always say `RESTORED` (2), the
  `RefusalCheck` call wired out (1), `RefusalCheck` made to quarrel with
  everything (1), the solve refusal wired out (1), the tool readback's
  validated branch switched off (3), the tool readback made to fall back to
  the defaults (6), the farm's check made public (3), a new verdict-returning
  function added to a script with no row (1), a row naming a function that
  does not exist (1), `CarTool.validate` renamed (3), the farm given a
  `pre_check` (2), and the farm's `solve` renamed (3).
- **`refusal_reach_test`'s corrected assertion was run against the case it
  exists for**: rename `FarmModule.solve()` and it now fails. It could not
  before.
- **It passes with `--fixed-fps 120`, with `--fixed-fps 30` and without any**
  (TRAPS 4), so it is in neither runner's fixed-rate list. Its name matches
  none of `run_tests.bat`'s findstr patterns — checked by running them
  against the name, not by eye.
- **62 suites counted with `ls`**, and the README said 61.

### What the tests did NOT prove

- **No model sent any of this.** Every request was typed as raw JSON through
  `main.gd`'s own typed door; this harness has no key, and nothing was
  reproduced from the owner's screen.
- **Nothing was rendered on a screen** and no world was looked at.
- **No world, record or saved file of the owner's changes.** The prompt is
  byte-identical and `PROMPT_VERSION` did not move. The only `scripts/`
  change is comments in `world_module.gd`, verified mechanically: every `+`
  and `-` line in `scripts/` is a comment.
- **Four of the fourteen call sites are now held by a suite that did not
  exist yesterday**, which is coverage and not a fix: nothing in Genesis
  behaved wrongly at any point. The faults found are in what the suite was
  holding, not in what the code does.
- **The farm's check is not fixed.** It is still the only check in Genesis
  that cannot be proved connected, and where it should live is "Human
  decision needed" 18 and the owner's. Nothing was moved.
- **Three call sites were NOT asked**, and are declared `NOT_ASKED` rather
  than left looking covered: `GameController.finish_order` (the delivery
  verdict, called from `main.gd:692`), `main._on_revision_requested`, and
  `ExperimentRunner._on_ai_failed`, which needs a live key (054's row).
- **The enumeration's rule has a hole and the suite says so.** It collects
  functions that return `"ok"`, `"errors"`, `"category"` or `"outcome"`.
  `RefusalCheck.quarrel_with()` answers with an Array of quarrels and is
  declared by hand; a check written tomorrow in a third shape would be
  missed. The honest size of that hole is one function today.
- **"Wiring it out" is one model of a check going wrong**, not all of them. A
  check that stops refusing is caught by the fixtures above; a check that
  refuses the wrong thing is a different question, and `refusal_reach_test`
  and `controller_reach_test` are where that one lives.

**Next action.** `GameController.finish_order` is the one row in the table
that is both `NOT_ASKED` and a verdict a player acts on: it is the delivery
judgement, the thing PROTOCOL's *"never accept the carrier's claim as proof
of delivery"* is about, and the measurement above never touched its call at
`main.gd:692`. Ask it 055's question — wire out the call, run everything, and
read the diff — and then the same of `main._on_revision_requested`. Both are
one probe each in a throwaway copy, and the answer for each is either a
fixture or a row in the owner's column.

## 056 — the two rows 055 left unmeasured, and why one of them could not be reached

**Objective.** The task this file named as the next assistant task: ask 055's
question — *if this call stopped working tomorrow, would any suite say so?* —
of the two rows `check_wiring_test` left `NOT_ASKED`.
`GameController.finish_order`, the delivery verdict that PROTOCOL's *"never
accept the carrier's claim as proof of delivery"* is about, called from
`main.gd:692`; and `main._on_revision_requested`, the handler that asks the
model to correct a circuit that will not close.

**Starting state.** Branch `prototype-002a` at `b3a4606` (055). 62 suites,
`--all`, 0 with something to look at — re-measured in this container before
anything was touched, with `user://` cleared first (TRAPS 50), and it matched
what 055 recorded.

**Method, which is 055's and unchanged.** One call site at a time, wired out
in a throwaway copy of the repository, every suite run with `--all`, the
result lines **diffed** against the baseline. Every run sequential, `user://`
cleared before each. Nothing in this repository was edited to measure it and
no guard was removed from Genesis.

### THE TWO ANSWERS ARE OPPOSITE, AND THE SECOND ONE IS THE FINDING

**`finish_order` is held, and held hard.** Wire out its call at `main.gd:692`
and **seven** suites say so:

```
carry_test             failures 0 -> 1
false_delivery_test    failures 0 -> 5
interference_test      failures 0 -> 2
ledger_test            failures 0 -> 1
order_test             failures 0 -> 1
repeat_test            failures 0 -> 1
ledger_audit_test      passed   -> SCRIPT ERROR (no 'carrier' key)
```

`false_delivery_test` reaches it through `main.npc.halt()` — the NPC's own
`stopped_walking` signal, which is the door the game walks — not through the
direct calls to `finish_order` that also appear in that file. So the delivery
verdict, the one this project is most insistent about, was already being
reached through the real door by six suites and nobody had written it down.
The row was `NOT_ASKED`, which was honest: it said *not measured*, not
*unheld*. It is now `CONNECTED` and names all seven.

**`_on_revision_requested` is held by nothing.** Wire out the connect at
`main.gd:80` and **all 62 suites pass, `--all` included — the diff against the
baseline is empty.** Not one line differs.

### WHY NOTHING COULD HAVE WALKED THAT DOOR, WHICH IS THE PART TO KEEP

This is not TRAPS 49's shape — a door that existed and nothing walked. The
door is **locked from the production side.** The emit at
`game_controller.gd:1168` stands behind `_may_revise()`, and `_may_revise()`
requires `current_source["source"] == "ai"`. That string is written in **one
place in Genesis** — `AIInterpreter.describe()`, `ai_interpreter.gd:250` —
which `main.gd` reaches only after `interpreter.is_available()` passes. Raw
JSON, which is how every suite and every measurement in this repository sends
a request, is stamped `{"source": "typed"}` at `main.gd:189`.

So a harness with no key cannot produce this gate's input at any price, and
no suite written against the normal door would ever have reached the handler.

**Asked of the class, and the answer is written down rather than assumed
(TRAPS 11):** `current_source` has **two** readers in `scripts/` — grepped,
not remembered — and one of them is a record field. The closure revision is
the **only** behaviour in Genesis gated on a request's provenance. The honest
size of that class is one. TRAPS 52.

### WHAT CHANGED

One file: `tests/check_wiring_test.gd`. **No change to anything in
`scripts/`** — verified mechanically, `git diff --stat` touches `tests/` and
`docs/` only. Nothing in Genesis behaved wrongly at any point in this
session: what was found is what the suite was holding, not what the code does.

- The two `NOT_ASKED` rows become `CONNECTED` (naming the seven suites) and
  `CONNECTED_056` (the new fixture). A new verdict `CONNECTED_056` is added to
  `VERDICTS`, so a row carrying it fails if the list is not updated with it.
- A fixture, `_revision_handler()`: an unclosable circuit sent through
  `main._execute_json` with the provenance label set to what
  `AIInterpreter.describe()` would have set, then **nine** assertions — one
  the precondition that the refusal still happens, eight on the
  state the real handler leaves behind — that Genesis entered the revising
  state, that the second attempt is numbered 2, that it carries the feedback
  Godot wrote, that the next request is marked a revision, and that the two
  distances it carries are **the ones Godot measured**, read back out of the
  same record the refusal wrote rather than compared with a literal.
- It also asserts that a circuit refused while a revision is pending is still
  refused `FAILED_CLOSURE`. A revision on its way must not turn a refusal
  into a non-refusal.

**What the fixture fakes, stated rather than buried: one field.** The
provenance label. Everything downstream is the real path — the real refusal,
the real `_may_revise`, the real emit, the real handler. The suite header says
so in those words.

### EVIDENCE — WHAT WAS ACTUALLY RUN

Godot 4.7.1 headless on Linux (`4.7.1.stable.official.a13da4feb`), in a cloud
container, every run **sequential** with `user://` cleared first (TRAPS 50).

- **Baseline at 055:** 62 suites, `--all`, **0 with something to look at.**
- **After:** 62 suites, `--all`, **0 with something to look at.** The suite
  lists were **diffed**: the only difference is `check_wiring_test`'s own
  line, 179 assertions to **188**. No file was added, so neither runner
  needed an edit — and `run_tests.bat`'s `findstr` patterns were **RUN**
  against the name rather than eyeballed, as were the two probe diffs.
- **The fixture was run against broken code before it was believed** (052's
  lesson, TRAPS 51). **Ten deliberate faults, one at a time**, every one
  caught, and the FAIL lines read rather than counted: the connect wired out
  (7 failures), `_may_revise` always false (8), the handler never entering the
  revising state (1), **the closure distance read from the proposal instead of
  the closure (1)**, the second attempt numbered 1 (1), `revision_pending`
  dropped from the record (1), the feedback dropped (1),
  `describe_revision()`'s marker dropped (1), `CONNECTED_056` removed from
  `VERDICTS` (1), and racing's `correction_feedback()` returning empty (8).
- The fourth of those is the one worth naming: it proves the number assertions
  are **not vacuous**. The two distances on this circuit are 260.3 m and
  980.0 m, so a handler carrying the wrong one is caught — which an assertion
  written as a literal would not have been (TRAPS 6).
- Passes with `--fixed-fps 120`, with `--fixed-fps 30` and without any
  (TRAPS 4), so its place outside both runners' fixed-rate lists still holds.

### NOT VERIFIED

- **NO MODEL SENT ANY OF THIS.** This harness has no key. Every request was
  typed as raw JSON through `main.gd`'s own typed door, and the one gate that
  needs a model answer was set by hand, which is the whole subject of this
  commit.
- **That the AI is actually asked for a correction, and that an answer comes
  back, is still not verified and cannot be here.** The handler calls
  `interpreter.revise()` after a 4 s timer; the fixture asserts the state the
  handler sets **before** that await, so no request is ever sent. The round
  trip needs the owner's machine and a live key.
- **NOTHING WAS RENDERED ON A SCREEN** and no world was looked at.
- **NO WORLD, RECORD OR SAVED FILE OF THE OWNER'S CHANGES.** The prompt is
  byte-identical and `PROMPT_VERSION` did not move.
- **The seven suites that catch `finish_order` were not individually
  re-verified one at a time.** They came out of one `--all` sweep against one
  wire-out, diffed against the baseline. `ledger_audit_test` **throws** rather
  than failing cleanly there — it indexes `record["carrier"]` on a record that
  is not written when the call is gone. The runner reports it and counts it,
  so nothing is hidden, but it is a suite that would read better as a failure
  than as a script error. Not changed; recorded.

**Next action.** 056 measured two signal-facing call sites and the second one
turned out to be invisible for a structural reason. The class that reason
belongs to has not been swept: **`main.gd` makes sixteen `connect()` calls**
(enumerated with grep: `log_message`, `interpretation_ready`,
`interpretation_failed`, `retrying`, `track_measured`, `revision_requested`,
`equipped`, `ordered`, `door_changed`, experiment `progress` and `finished`,
`lap_completed`, race `announced`, `pressed`, `text_submitted`, and
`stopped_walking` at `main.gd:659`). Two of the sixteen are now measured —
`stopped_walking` is the one `finish_order` sits behind, and
`revision_requested` is the one nothing held. **The other fourteen have never
been asked whether wiring them out would fail anything**, and these are the
handlers that turn a controller verdict into what the player sees, which is
the layer 055 did not reach. One wire-out each, `--all`, diffed; at roughly
twenty minutes a sweep this is more than one unattended run, so it wants
doing a few at a time with the answers written into the table as they come.
Three of them (`interpretation_ready`, `interpretation_failed`, `retrying`)
may well be TRAPS 52's shape again, and the honest thing is to measure rather
than predict.

## 057 — the guard in front of the proxy, and the sweep that found it

**Objective.** The task this file named as the next assistant task: **the
class behind 056's finding, swept** — `main.gd` makes sixteen `connect()`
calls, 056 measured two of them, and the other fourteen had never been asked
whether wiring them out would fail anything. One wire-out each, every suite,
`--all`, the result lines diffed against a baseline taken the same way.

**What it turned into.** Seven of the fourteen were measured and the sweep
was stopped there (below). Asking the sweep's question of the third one —
*why is `main._on_interpretation_failed` held by nothing?* — walked back into
`ai_interpreter.gd` and found **a fault that stops the web build working at
all**. That is this commit's subject; the sweep is how it was found and its
seven answers are recorded here.

### THE FAULT: ON THE WEB, NO REQUEST WAS EVER SENT

`_send()`, `ai_interpreter.gd`, before 057:

```gdscript
	if api_key == "":
		interpretation_failed.emit("No API key found in api_key.txt.")
		return
```

**On the web `api_key` is always `""`, by design.** `_load_key()` returns
before reading anything (*"a web build has no key by design"*, its own
comment) and **nothing else in the project assigns `api_key`** — grepped
across `scripts/` and `scenes/`, not remembered. 020 put the key in the
Netlify function on purpose, because anything under `res://` is packed into
`index.pck` and can be downloaded.

So on every web request there has ever been: `is_available()` answered
**true** (it knows about the web), `main.gd` let the request through, and
then `_send()` refused it **before `_post()` could run**. The proxy 020 built
was unreachable at any price, and the player was told to check a file that a
web build must never carry.

**The guard was reachable ONLY on the web, and on the web it was always
true.** On the desktop it cannot be reached at all: `main.gd:193` and
`experiment_runner.gd:53` both stop at `is_available()` first, so a desktop
build with no key never gets as far as `_send()`. A guard that fires exactly
when it must not, and never when it should.

**FOUR PLACES ALREADY KNEW THE RULE AND THE FIFTH DID NOT.** `where_to()`
returns the proxy path; `is_available()` returns true; `_post()` attaches no
key header; `_load_key()` looks for no file. Counted by grepping `on_web()`,
which has exactly those four call sites. `_send()`'s guard is the fifth
decision about the same subject and it is the one standing in front of the
other four. **TRAPS 35's shape, and now TRAPS 53.**

**This is the owner's own "Next action".** That entry says setting
`GEMINI_API_KEY` in the Netlify site's environment is a minute's work and
then *"a stranger with the link can type a sentence and get a world, which is
the first time that has ever been true"*. **It would not have been.** The
request would have died in the browser before reaching the function, and the
error would have named `api_key.txt` — pointing at the desktop build's file
rather than at anything to do with the deployment.

### WHY NOTHING CAUGHT IT

`proxy_test` has existed since 020 and passes. It asserts where a request
**would** go, that only the desktop build attaches a key, that the function
reads the key from the environment, that it forwards three fields, that it
caps the body, that it refuses non-POST, and that the web preset carries no
key. **It never asserted that a request is made.** Destination, thoroughly;
departure, never. That is TRAPS 49's lesson one layer up, and it is why the
sweep found this and twelve releases of a green suite did not.

### THE FIX, AND WHY IT IS A FUNCTION AND NOT A SECOND `and`

Adding `and not on_web()` to the guard would have fixed the instance and left
the class: a sixth place deciding the same thing on its own (TRAPS 11). One
function answers it now and **both** readers call it:

```gdscript
static func key_missing_for(web: bool, key: String) -> bool:
	return key == "" and not web
```

`is_available()` is `not key_missing_for(on_web(), api_key)` — which is
exactly what it computed before, so **the desktop build's behaviour is
unchanged** — and `_send()`'s guard is the same call. It takes the build as
an **argument** rather than calling `on_web()` itself, because a headless
harness cannot flip `OS.has_feature("web")`: passing it in is the only reason
the web case can be measured here at all.

The same rule applied to **what the player is told**, which was the second
member of the class: `_friendly_http_error()`'s 401/403 said *"Check
api_key.txt"*, which on the web names a file that does not and must not
exist there. It is now `key_refused_message(web, code)`, and the web sentence
names `GEMINI_API_KEY` — **checked against `interpret.js`'s own source**
rather than typed out twice, so the two cannot drift apart.

**One consequence, stated rather than left to be found:** after 057 the key
guard inside `_send()` is unreachable in production, because both callers
stop at `is_available()` first. It is kept as a safety net for a direct call,
and `proxy_test` walks it that way.

### Evidence

- **62 suites, `--all`, Godot 4.7.1 headless on Linux
  (`4.7.1.stable.official.a13da4feb`) in a cloud container, every run
  sequential with `user://` cleared first (TRAPS 50): 0 with something to
  look at**, before and after. The baseline was taken the same way in the
  same container and the two lists were **diffed**: they are **identical,
  line for line**. That is not the usual result here and it is worth saying
  why rather than letting it read as a stronger claim than it is —
  `proxy_test`'s result line is `PROXY TEST failures=0` and carries **no
  assertion count**, unlike `check_wiring_test`'s, which is what made 055's
  and 056's single-line diffs visible. So the diff cannot show this commit's
  new assertions at all. They were counted by running the suite alone and
  **counting the PASS lines it printed**: 11 before, **24** after.
- `proxy_test` goes from 11 assertions to **24**, counted that way rather
  than from the source.
- **Run against broken code before it was believed (TRAPS 51): eight
  deliberate faults, made one at a time, every one caught, and the FAIL lines
  READ rather than counted.** The pre-057 logic restored in
  `key_missing_for` (1 failure — and it is the row that is the finding, *"WEB
  with no local key: SENT"*); the guard re-inlined in `_send` as
  `api_key == ""` (1, the guard assertion); `key_refused_message` losing its
  web branch (1); `KEY_ENV_NAME` drifted to a name the function does not read
  (1); the key guard removed from `_send` entirely (2, through the real
  `interpret()` door); `is_available()` inverted so it disagrees with the
  function it calls (1); the desktop sentence no longer naming `api_key.txt`
  (1); and the guard emitting its refusal and then posting anyway (1).
- The **fourth and fifth** matter most: the fourth proves the env-var
  assertion is not a literal compared with itself, and the fifth proves the
  behavioural half is not vacuous — with the guard gone, a desktop build with
  no key puts a keyless request on the wire and the suite says so.

### What this does NOT prove

- **NO BROWSER RAN AND NO WEB EXPORT WAS MADE.** What is proved is the
  **decision**, for both builds, and that the desktop guard still fires
  through the real `interpret()` door. **That a web build now reaches the
  proxy and gets an answer back is NOT verified and cannot be here.** It
  needs the owner's machine, a deployed site and `GEMINI_API_KEY` set. The
  fix is the removal of a blocker that was provably in the way, not a
  demonstration that nothing else is.
- **NO MODEL SENT ANYTHING.** This harness has no key. No request left the
  container at any point in this commit's work, deliberately: the one suite
  that drives `interpret()` does so with an empty key, which refuses before
  anything is posted, and `proxy_test` asserts `busy` is still false
  afterwards.
- **NOTHING WAS RENDERED ON A SCREEN** and no world was looked at.
- **NO WORLD, RECORD OR SAVED FILE OF THE OWNER'S CHANGES.** The prompt is
  byte-identical and `PROMPT_VERSION` did not move.
- **`is_available()`'s agreement with `key_missing_for()` is asserted for one
  row of four** — the build this run is, desktop with no key. The web rows
  are the function's alone. Written into the assertion's own text rather than
  left to look like more than it is.

### THE SWEEP: SEVEN OF SIXTEEN CONNECTS MEASURED, AND FIVE OF THE SEVEN ARE HELD BY NOTHING

Method is 056's and unchanged: one `connect()` wired out at a time in a
throwaway copy, every suite run with `--all`, the result lines **diffed**
against a baseline taken the same way, every run sequential with `user://`
cleared first (TRAPS 50). Nothing in this repository was edited to measure
it. The sixteen sites were enumerated by grepping `.connect(` in `main.gd`
rather than copied from this file.

| # | line | signal → handler | verdict |
|---|------|------------------|---------|
| 1 | 70 | `log_message` → `_on_controller_log` | **HELD, BY ONE SLOW SUITE** |
| 2 | 75 | `interpretation_ready` → `_on_interpretation_ready` | **NOT HELD — needs a key** |
| 3 | 76 | `interpretation_failed` → `_on_interpretation_failed` | **NOT HELD — and a fixture could reach it** |
| 4 | 77 | `retrying` → `_on_ai_retrying` | **NOT HELD — needs a key** |
| 5 | 79 | `track_measured` → `_on_track_measured` | **NOT HELD** |
| 6 | 80 | `revision_requested` → `_on_revision_requested` | CONNECTED_056 (056) |
| 7 | 81 | `equipped` → `_on_equipped` | **NOT HELD** |
| 8 | 82 | `ordered` → `_on_ordered` | **HELD HARD** |
| 9 | 83 | `door_changed` → `_on_door_changed` | NOT_ASKED |
| 10 | 88 | experiment `progress` | NOT_ASKED |
| 11 | 89 | experiment `finished` | NOT_ASKED |
| 12 | 93 | `lap_completed` | NOT_ASKED |
| 13 | 98 | race `announced` | NOT_ASKED |
| 14 | 100 | `pressed` → `_on_build_pressed` | NOT_ASKED |
| 15 | 101 | `text_submitted` → `_on_text_submitted` | NOT_ASKED |
| 16 | 659 | `stopped_walking` → `_on_npc_stopped` | CONNECTED (056, seven suites) |

The answers, with what each one costs the player if the wire is lost:

- **`log_message` (70) is held, but by ONE failure in ONE suite that most
  runs skip.** `drive_test` — which is in `SLOW`, so it runs only under
  `--all`. This handler writes the status line, writes every entry in the
  history panel, records whether the thing waiting for evidence was actually
  built, describes what an edit changed, re-initialises the checkpoints for a
  new circuit and stops a race on a track that has gone. Wire it out and
  **61 of 62 suites still pass**. TRAPS 49's "held only by a slow suite",
  again, on the handler that writes most of what the player reads.
- **`track_measured` (79) is held by nothing, and `main.gd:993` is the ONLY
  production caller of `WorldRegistry.panel_lines()`** — grepped. That is the
  measurements panel: the thing 046, 047, 049, 051 and 052 were all about.
  051 moved its four decisions into `panel_lines()` *"which is what this
  suite can call"*, and `panel_refused_test`, `panel_built_test` and
  `panel_geometry_test` all call it directly. **Every one of them passes with
  nothing ever drawn** — and not with the panel *blank*, which is how this
  file put it until 058 measured it: the placeholder
  `_build_metrics_panel()` seeds stays on screen instead (TRAPS 54). The
  decisions are held; the drawing is not — and since 058 the drawing is
  held too, by `tests/handler_wiring_test.gd`.
- **`equipped` (81) is held by nothing**, and it is the only place a tool
  spec reaches a body that is already standing — `car.equip()`,
  `walker.equip()`, `walker.wear()`, `npc.wear()`. `boots_test`, `tool_test`
  and `look_test` test the tool modules at their own door. Note **why**
  nothing caught it: the handler's four branches are each guarded on a node
  being non-null, and in the harness there is usually no car and no walker,
  so even a suite that reached it would do nothing observable. A fixture here
  has to stand a body up first.
- **`interpretation_ready` (75) and `retrying` (77) are held by nothing and
  are TRAPS 52's shape again** — exactly as the last session predicted and
  said should be measured rather than predicted. Both are emitted only from
  inside the HTTP response path (`ai_interpreter.gd:509` and `:409`), which
  no harness without a key can reach.
- **`interpretation_failed` (76) is held by nothing and is NOT TRAPS 52's
  shape, which is the distinction worth keeping.** `interpretation_failed` has
  an emit that needs no key — the one in `_send()` this commit is about — so
  **a fixture can reach this handler with no key and nothing faked**, unlike
  056's, which had to set a provenance field by hand. The handler sets the
  status line, writes a history entry and writes an `ai_unavailable` event to
  the ledger, so the ledger makes it observable. Not written in this commit;
  named as the next task below.
- **`ordered` (82) is held hard.** `carry_test` throws, `interference_test`
  throws, `ledger_audit_test` throws, `false_delivery_test` throws and
  `controller_reach_test` fails 1 — and several delivery suites then sit at
  `run_tests.sh`'s 600 s timeout waiting for a walk that never starts.
  **This run was STOPPED at 23 of 64 suites**, because the answer was not in
  doubt and the timeouts were costing more than the remaining rows were
  worth. Recorded as partial rather than as a complete sweep.

**Seven of the sixteen are now measured and five of the seven are held by
nothing.** The pattern across them is one layer: the handlers that turn a
controller verdict into **what the player sees** — the status line, the
history panel, the measurements panel, the kit on the body. The suite holds
the verdicts and the decisions behind those lines thoroughly, and holds
almost nothing about whether any of it is ever shown.

**Next action.** Two, in this order. **Item 2 was done in 058** and is left
struck rather than deleted, because two of its three sentences turned out to
be wrong and the corrections are the useful part.

1. ~~**The seven rows still `NOT_ASKED`**~~ **DONE IN 059: ALL SIXTEEN ROWS
   ARE NOW MEASURED.** One held (`door_changed`), two need a key, four held
   by nothing and all four reachable without one. **And this entry's own
   guesses were half right**: `pressed` and `text_submitted` are indeed held
   by nothing, and `door_changed` — called "the interesting one" — is held,
   by `interference_test`'s look for the physical door slab. Left struck
   rather than deleted because the measurement found something bigger than
   the rows: see 059 and TRAPS 56. Same method, a few at a time; budget for it
   properly, because one wire-out that breaks delivery costs 20 minutes of
   600 s timeouts rather than the 4 minutes a clean run takes.
   `door_changed` (83) and the two racing rows are the interesting ones;
   `pressed` (100) and `text_submitted` (101) are probably held by nothing,
   since every suite calls `_handle_request` directly rather than through a
   button. **And 058 is the method for whichever of them turns out to be
   unheld**: it holds three handlers through real emits on real signals in
   one fast suite, so a row found unheld now has a pattern to be held by
   rather than only a verdict.
2. ~~**A fixture for `_on_interpretation_failed`, which needs no key and
   fakes nothing.**~~ **DONE IN 058, FOR THREE HANDLERS AND NOT ONE
   (TRAPS 11), AND TWO OF THIS ENTRY'S OWN CLAIMS WERE WRONG.** The recipe
   it gave was right about `_make_main()`, about the empty key and about
   calling `interpret()` directly. It was wrong twice, and both are worth
   carrying: **"with nothing set by hand" is not reachable** —
   `_handle_request()` refuses before `interpret()` when there is no key, so
   the door is entered one level in and `pending_request` must be set as
   `_handle_request` would have set it; and **the `ai_unavailable` assertion
   it describes needs a session**, because `TrackLog.event()` returns at its
   first line outside one, so a fixture following this entry literally would
   have asserted the absence of a file write and passed. Left struck because
   the lesson is the one worth carrying: **a recipe written from reading the
   code is a proposal, and the two things it got wrong were both things the
   code does before the line the recipe was looking at.**

3. **The handler layer is now half-held, and the half that is not is named.**
   `_on_interpretation_ready` and `_on_ai_retrying` are still held by
   nothing, and **cannot be held in this harness at all** — their only emits
   are past the network. 058 asserts the connect for both and labels it
   `WIRE ONLY` in the assertion's own text. What would hold them is a fake
   HTTP response, and **that is a decision and not a task**: it means
   standing a double in front of `HTTPRequest` so the suite can feed
   `_on_request_completed` a body, which is the first test double this
   project would own. It is now **"Human decision needed" 20**.

4. **And one worth a look rather than a commit: `_metric_colour()` is
   asserted by nothing.** 058 holds which lines the panel shows and in what
   order; the colour each line is drawn in is the one thing left in
   `main.gd`'s panel code that 051 did not move into `panel_lines()`, and no
   suite reads it. It is four lines and a `match`. Whether a colour is worth
   a test is a judgement about what a panel suite is for, so it is noted
   rather than taken.

## 076 — fifty-five suites that could lose an assertion and still print failures=0

**Objective.** Read the repository first, as instructed, and take the highest
thing that is honestly useful. There is **no unaddressed owner finding** — the
last owner session is still 2026-10-16. So: the **first live entry under
"Next action"**, which 075 wrote and deliberately did not close, and which it
named as its own TRAPS 11 — *56 of the 72 suites print no assertion count on
their result line*, with `formula_test` given one in 075 because that commit
could not otherwise be verified from the result lists at all.

**Starting state.** `prototype-002a` at `a69b7f7` (075a). Baseline in this
container, `--all`, `user://` cleared first: **72 suites, 0 with something to
look at**, and the output **byte-identical to the md5 075a recorded**
(`69eb8489ca8e4586238a7a2ad7743a9e`). The record and the container agreed
before anything was touched.

### What a result line could not say, measured rather than argued

`failures=0` is the same line whether a suite made ninety assertions or none.
For the 55 suites that printed nothing else, **an assertion could be deleted
outright and the run output would not move** — the only thing that would catch
it is a diff of the full PASS list against a recorded md5, which is what 073,
074 and 075 each had to do.

**ELEVEN DELIBERATE DELETIONS, each in its own throwaway copy of the project
with its own `config/name` (TRAPS 50), the suite run after each. ALL ELEVEN
STAYED `failures=0` AND EXITED 0**, and in every one the assertion count was
the only thing that moved:

```
look_test        one _check call deleted                18 -> 17   failures=0
carry_test       one _check call deleted                21 -> 20   failures=0
judge_test       one row deleted from the case table    21 -> 20   failures=0
report_test      one _eq row deleted                    28 -> 27   failures=0
report_test      one direct if-block deleted            28 -> 27   failures=0
said_fields_test the circuit-whole row deleted         127 -> 126  failures=0
said_fields_test one unmeasured section cut from table 127 -> 126  failures=0
tool_test        the readback condition deleted          21 -> 15   failures=0
walk_test        the walls control deleted               11 -> 10   failures=0
plan_said_test   one _differs row deleted                50 -> 49   failures=0
session_test     one _check call deleted                 18 -> 17   failures=0
```

The `tool_test` row is the one to read twice: deleting **one condition** from a
six-case loop cost **six** assertions, and the suite reported `failures=0`
both times. The `session_test` row is the inherited case — it extends
`drive_test` and its count comes from the parent's helper, which is the one
shape that could have silently counted nothing.

**THREE MUST-PASS CONTROLS, checked for passing for the right reason
(TRAPS 6).** A PASS/FAIL message reworded in `look_test`, `judge_test` and
`tool_test`: all three green at the **same** count. So the count reads the
assertions and not the wording.

### The two shapes the 55 came in, enumerated rather than listed

Counted off the baseline run with `ls tests/*.gd`, not remembered: **74 files,
72 suites, 16 printed a count, 55 printed none, `sweep_test` prints a VERDICT
by design.**

- **39 suites funnel every assertion through one `func _check(ok, what)`**
  whose body is the only place a failure is recorded — verified per file by
  grepping for every `failures.append` and `bad += 1` site and confirming each
  sits inside that helper. For these the edit is mechanical: `asserted += 1`
  as the helper's first statement.
- **16 do not**, and each was read in full. `proxy_test` turned out to be the
  first shape after all (its second `failures.append` is a signal collector,
  not a failure list). `session_test` needed only its print line, because it
  extends `drive_test` and inherits the helper. The other 14 record failures
  at ad-hoc sites, and each site that decides pass or fail got its own
  increment — so the count is path-correct, and a condition removed from
  inside a loop costs one per iteration.

**The rule, stated so it can be applied to a suite written tomorrow: a result
line says how many assertions RAN, not only how many failed.**

### What changed

**55 files in `tests/`, no file added or removed, nothing in `scripts/`,
`scenes/`, `docs/` or either runner.** `run_tests.bat` was **read** rather
than assumed: it matches `failures=`/`bad=`/`VERDICT` as substrings and
computes no verdict of its own, so the new format needs no edit there, and
`run_tests.sh`'s `case` patterns match on the END of the line and still do.
The prompt is byte-identical, `PROMPT_FINGERPRINT` did not move and
`PROMPT_VERSION` stays at `050-no-command-for-a-question-1`.

**71 of the 72 suites now print a count**; `sweep_test` prints a VERDICT by
design and is the whole remainder. The class is closed.

**AND A COUNT IN THIS FILE WAS WRONG BEFORE THIS COMMIT TOUCHED IT.** The
"Run the tests first" section said *"56 of the 72 suites print no assertion
count — 15 print one"*, in the same paragraph that goes on to say
`formula_test` was given a count in 075. Both cannot be true: measured off
075's own recorded output, it was **55 and 16**. 075's "Next action" said *"the
remaining 55"* and was right; the run-record paragraph kept the pre-075 pair.
TRAPS 24's shape, one commit old, in the one paragraph of this file that
invites the reader to run the `ls` rather than trust it. Corrected.

### Evidence — what was actually run

Godot 4.7.1 on Linux (`4.7.1.stable.official.a13da4feb`), headless, in a cloud
container, every run sequential with `user://` cleared first.

- **Baseline before anything was touched:** 72 suites, `--all`, **0 with
  something to look at**, md5 `69eb8489ca8e4586238a7a2ad7743a9e` —
  **byte-identical to the md5 075a recorded on the clean pushed tree.** That
  identity is the reason the baseline is known to be uncontaminated rather
  than argued to be: the edits in this session landed while the baseline run
  was still going, and the run matching 075a's md5 exactly is what settles
  that no edited file was read by it.
- **After, twice on the final tree,** `user://` cleared before each: 72
  suites, `--all`, **0 with something to look at**, **byte-identical** (md5
  `dddf8006012399e50eb9470da9e29af6`).
- **THE VERIFICATION THE ENTRY ASKED FOR, AND IT IS THE WHOLE OF THE WORK.**
  The 55 changed suites' counts were **stripped** from the after-run output
  and the result **diffed** against the baseline: **byte-identical, md5
  `69eb8489ca8e4586238a7a2ad7743a9e` again.** No suite's verdict moved, no
  line was added or removed, and the only change to any result line is the
  inserted count.
- **A genuine failure is still flagged through the new format**, which the
  format change could have broken and nothing else would have caught: with one
  `_check` in `look_test` made to fail, the suite printed `LOOK TEST 18
  assertions, failures=1`, exited 1, and `run_tests.sh` reported **"suites
  with something to look at: 1"** and exited 1.
- **`report_test`'s early-exit line was exercised**, because this commit
  rewrote a line on a path that had never run: with the summary's
  understanding block made to go missing, it printed `REPORT TEST 1
  assertions, failures=1` and exited 1.
- Eleven deliberate deletions and three wording controls as tabled above.

### What the tests do NOT prove

- **NOTHING ASSERTS THE COUNTS.** No suite checks that a result line carries a
  count, nor that a suite's `asserted` actually tracks its assertions. The 71
  counts rest on this session's per-file reading and on the eleven deletions
  above, which covered **8 suites of 71** and all five reporting shapes. A
  suite added tomorrow with no count would be caught by nobody, which is
  exactly how this class reached 55 members. That is the first entry under
  "Next action" and it is a real gap, not a tidy-up.
- **A count is not a measure of what a suite is worth.** `capability_test`
  prints 529 and `walk_negative` prints 2; the second is not a worse suite.
  Nothing here should be read as inviting anybody to raise a number.
- Nothing was rendered, no window was opened, **no model was asked anything
  and no request left the container. There is no API key here.**
- **No secret was set and no workflow file was edited.** 064's finding stands:
  the web build has failed on every push since 14 October and the live site is
  still `71b065f`.
- **No new "Human decision needed."** New TRAPS 73.

### Next action

**THE FIRST LIVE ENTRY, AND IT IS THE GAP THIS COMMIT OPENED: nothing holds
the counts it just added.** The class-holder to write is a source scan over
`tests/`, in `source_scan_test`'s family (it already reads `tests/` through
`_code_of()` and is the tenth-member precedent): **every file in `tests/` that
is a suite must print a result line of the form `<N> assertions,
(failures|bad)=<M>`**, with `sweep_test`'s VERDICT and the two tools
(`prompt_test`, `replay`) named as the exceptions and read from the same lists
`run_tests.sh` holds rather than retyped. That catches a suite added without a
count, which is the way this class grew. It does **not** catch an `asserted`
that stops incrementing — that needs a deletion, and a deletion cannot be a
standing suite — so the entry should say so in its own header rather than
imply otherwise (TRAPS 6, TRAPS 14). It adds one line to the result list, so
the md5 above is the last comparable baseline and the next session should take
a fresh one in the same commit.

**THEN THE CLASS QUESTION 075 LEFT, UNCHANGED AND STILL THE BIGGER ONE: which
lines of the assembled prompt can be deleted with no suite failing?** 075
answered it for the racing section's 11 rule units by deleting eight of them
one at a time. The prompt has **112 non-blank lines** and **11 suites read it**
(`boots_test`, `capability_test`, `claim_field_test`, `container_door_test`,
`formula_test`, `intent_door_test`, `look_test`, `order_test`,
`procedure_test`, `prompt_bounds_test`, `prompt_numeral_test`). Doing it by
deletion is 112 runs and the rendered line does not map one-to-one onto a
source line, so **screen it cheaply first**: collect every string literal in
the eleven suites' CODE (through `_code_of()`), ask which prompt lines no
literal reaches, and only then measure the candidates by deletion. Expect
075's shape — the lines with numbers in them are held and the prose is not —
and expect the dungeon and farm sections to be where it bites, since 074
recorded that the eight PROSE numerals have nothing standing behind them.
**This commit makes that sweep cheaper to read**: a prompt line whose deletion
costs a suite an assertion without failing it now shows in the run output.

**The prompt-numeral class stays closed** and 073's warning stands: do not
re-open it by building 068's table of 41.

**And do not take the pattern-breadth axis as written.** Four entries in a row
asked for a widening and all four times the widening had no subject. The
question that has paid is the one behind it: 072's *what has the subject never
supplied?* and 075's *what has the subject supplied that nothing reads?*

## 075 — the rules the prompt stated and no suite read

**Objective.** Read the repository first, as instructed, and take the highest
thing that is honestly useful. There is **no unaddressed owner finding** — the
last owner session is 2026-10-16 and 048's *"there is no way to ASK Genesis
anything"* was written up in 050 as far as it goes without him. So: the live
axis, which 072, 073 and 074 all leave as *the remaining patterns in `tests/`
are unasked*, by the method that has paid — **not** *what can the pattern not
match?*

**Starting state.** `prototype-002a` at `6532049` (074a). Baseline in this
container, `--all`, `user://` cleared first: **72 suites, 0 with something to
look at**, and the output **byte-identical to the md5 074a recorded**
(`d13d97d014eeefea52f43e4076a4fb06`). `ls tests/*.gd` returned **74** and the
run reported **72** suites, re-counted rather than carried forward, which is
what "Run the tests first" says. The record and the container agreed before
anything was touched.

### The pattern inventory, and why it is not the number this file said

**Counted rather than trusted**, because a count in a document is TRAPS 24's
shape: `grep -c 'RegEx.new' tests/*.gd` returns **22** and
`RegEx.create_from_string` another **20** — **42 pattern sites in 14 files**,
not the *"twenty-three"* this file has carried since 072. Which commit left
that behind is not recorded and is not guessed at here. The number is not the
finding; it is the reason the entry could not be taken as written.

### The question one layer behind the axis

Asked of `formula_test`, the suite 039 built to hold *"the arithmetic the
prompt states is the arithmetic Genesis does"*. Its clause reader is a
pattern, so the axis's question applies: what can it not match?

**Measured before anything was written**, by printing every tool section and
every line of the assembled prompt carrying an arithmetic operator word: the
subject supplies **exactly one formula clause** — `push divided by (weight x
footing)` — and the pattern sees it, and only **four** prompt lines carry an
operator word at all, all four accounted for. **A widening had no subject.
That is the fourth entry on this axis in a row with nothing to widen**, and
072's warning is now a measurement rather than a caution.

**So the question was turned round: what has the subject supplied that nothing
reads?** And that one paid immediately.

### The finding

`formula_test` has two halves and **only one of them reads the prompt**.

The tool half enumerates its claim from the prompt, parses it as arithmetic,
evaluates it over a 27-spec grid against `BootsTool.top_speed()`, and asserts
`formulas == 1` — so a tool formula reworded out of the pattern's shape, or a
second one added, **fails**. That half is sound and 075 did not touch it.

**Sections 3 to 8 read the prompt at all.** Each quotes a racing rule in a
comment and measures the behaviour behind it against `TrackGeometry`,
`FeasibilityGate` or `SectionValidator`. The sentence is read from nothing. So
the rule could leave the prompt entirely and the PASS line quoting it would
keep printing — **TRAPS 24 one layer along**, with the body in `scripts/` and
the success string in `tests/`, which is why no sweep of either file alone
could see it.

**EIGHT DELIBERATE FAULTS, each deleting one rule from `racing_module.gd`'s
template in its own throwaway copy with its own `config/name` (TRAPS 50), with
`PROMPT_FINGERPRINT` moved the way a real prompt edit moves it, the full suite
run each time. SEVEN OF THE EIGHT PASSED:**

```
rule deleted from the prompt                                 before   after
"Sections join end to end ... arrive back at the start line"      0       1
"A chicane steps the track sideways by O metres ..."              0       1
"... carries the track back only by its own width, twice ..."     0       1
"Chicanes do not count."                                          0       1
"Angles are signed: positive turns right, negative turns left."   0       1
"Never give a corner, hairpin or chicane a length ..."            0       1
"The road must never cross itself, and"                           0       1
"O is more than 0 and at most 2 x R"                              1       2
```

*before* is the committed suite at 074a; *after* is this commit's. The column
is **suites with something to look at**, full suite, 70 suites each run.

**The one that was held is the one carrying typed numbers, and that is the
general shape.** The racing rules are held where they state a **NUMBER** — by
`prompt_bounds_test` and `prompt_numeral_test`, which read numbers — and held
by **nothing** where they are **PROSE**. It is 073's and 074's finding about
the prompt's own 92 numerals seen from the other side: the numbers acquired
readers, and the sentences around them never did. A rule with no number in it
had no owner at all.

### What section 9 holds

Every **rule unit** of the racing section is read off the **rendered** section:
a section-type declaration, a sentence in the `SECTION TYPES` block that is
about all of them, or a `- ` bullet under `RULES FOR A CLOSED CIRCUIT`. The
block is found by its heading and the members by the bullet mark and the JSON,
**never by any English**, so a reworded rule is still a unit and still has to
be claimed. **11 units today, counted by the suite and not declared.**

**17 rows** claim them. Each row carries the claim that identifies its rule,
rendered from the constant where it carries a number (TRAPS 28) — the full
turn from `FeasibilityGate.FULL_TURN`, the floors from `MIN_STRAIGHTS` and
`MIN_TURNS`, the adjustment from `ClosureSolver.MAX_ANGLE_ADJUSTMENT`, the
separation from `SeparationCheck.MIN_SEPARATION` — so a number typed into the
table would be the very fault the suite exists to catch. Asserted:

- **every row finds its claim in exactly one unit** — a rule deleted, or
  reworded out of the shape the row names, fails here;
- **every unit is claimed by a row** — a rule **added** to the prompt fails
  until somebody classifies it, rather than arriving unremarked (TRAPS 14);
- **the six rows that say "here" against the six measurements that actually
  registered**, in both directions and against each other, each read off its
  own array rather than against a number typed in the file (TRAPS 71).

A row naming another suite reads **that suite's code** through `_code_of()`
for the constant the rule is about. That put `formula_test` into 067's
source-scanner class, and **`source_scan_test` caught it in the same run — two
FAILs, by name**, which is the guard doing exactly its job. `formula_test` is
now its tenth member and the canonical `_code_of()` is byte-identical;
`source_scan_test` goes **24 -> 25 assertions**.

### Twelve deliberate faults, FAIL lines read

Each fails on the assertion it should and names the fault:

- the **eight deletions** above — the seven that were silent now report
  **1 suite with something to look at**, `formula_test` **failures=1**, the
  FAIL naming the rule: *"the rule \"chicane step\" is stated in exactly one
  unit of the racing section (found 0)"*.
- a **new bullet** added to the racing rules (*"Keep the track flat; no
  section may change height."*): **148 assertions, failures=1** — *"every rule
  the racing section states is claimed by a row - unit 12"*. The added-rule
  direction.
- the **"angle sign" row deleted** from the table: **145, failures=2** — *"the
  measurement \"angle sign\" that ran above has a row claiming its rule"* and
  *"5 rules are measured here and 6 measurements ran"*.
- its **registration deleted** instead: **146, failures=2** — the other
  direction, and the count again. Neither count is typed; each is read off its
  own array.
- a row's evidence needle set to a string the named suite carries **only in a
  comment** (*"TRAPS 28"* in `prompt_bounds_test`): **failures=1**, so
  `_code_of()` is doing the work and a comment cannot answer a pointer
  (TRAPS 63).

### Two must-pass controls, both checked for passing for the right reason

- a **dungeon** sentence reworded with its numbers untouched (*"Room 1 is the
  entrance, where the player comes in."*): green at the same **147**, so the
  file does not read wordings in sections it makes no claim about.
- **the control that matters** — the **unclaimed half of a claimed bullet**
  reworded, while the claimed half was left alone: *"Sections join end to end,
  in order, starting at the start line."* -> *"Sections are joined end to end,
  in the order you give them, from the start line onward."*, with the
  second sentence (the one the `closure` row claims) untouched. Green at the
  same **147**. **So the rows pin the CLAIM and not the bullet**, which is the
  difference between this and a test of the prompt's prose.

### And the same file's own count was wrong on the day it was written

039's header says *"The other five arithmetic claims are measured rather than
read"* and lists five, while **section 8 of the same commit measures a sixth**
— *"Never give a corner, hairpin or chicane a length; it is calculated"*.
TRAPS 24's shape inside the file whose own fault is a comment standing in for
a reader. Corrected, with the sixth listed. **And "measured rather than read"
turned out to be the whole fault, stated honestly for 36 commits**: the
sentence described the method and never named the consequence.

### What the tests did NOT prove

- **NOTHING IS REACHABLE FROM A MODEL HERE.** Nothing was rendered, no window
  was opened, no model was asked anything and no request left the container.
  There is no API key here.
- **The prompt is byte-identical.** `PROMPT_FINGERPRINT` did not move and
  `PROMPT_VERSION` stays at `050-no-command-for-a-question-1`. Nothing in
  `scripts/` or `scenes/` changed. No number and no sentence the model is told
  changed; what changed is that seven of them now have a reader.
- **A row naming another suite is a POINTER, not a measurement.** It asserts
  the rule is still stated and that the named suite's code names the constant
  the rule is about. **It does not watch that suite measure anything**, and
  the header says so in as many words.
- **A needle is wording.** A rule reworded while staying true fails here and
  the row has to be updated. That is the only check available for a prose
  claim, and it is the right way round — a rule changing shape should stop a
  session and make it re-read, which is what the seven faults did not do. The
  cost is a false failure on a true rewording, and `c14` above is the measure
  of how narrow that cost is: only the claimed sentence is pinned.
- **That the other suites named in the rows measure what the rows say.**
  `procedure_test` names `ClosureSolver` and `limits_test` names
  `SeparationCheck`; that those measurements are the right ones is read from
  their code naming the constant, not from watching them run.
- **That the eight PROSE numerals mean anything** — 074's gap, untouched.
- **No secret was set and no workflow file was edited.** 064's finding stands:
  the web build has failed on every push since 14 October and the live site is
  still `71b065f`.
- **No new "Human decision needed."**

### Next action

**CLOSED IN 076 — all 55 remaining suites now print a count, verified by
stripping the counts and diffing byte-for-byte against this commit's own
baseline. The original text is left below with its original number, because
the number itself was wrong: measured off 075's own output it was 55 and 16,
not 56 and 15 (see the 076 section). The reasoning for the entry stands and is
what 076 acted on.**

**THE FIRST LIVE ENTRY, AND IT IS A CLASS THIS COMMIT DELIBERATELY DID NOT
CLOSE: 56 of the 72 suites print no assertion count on their result line.**
Counted off the baseline run, not remembered: 15 print one, `sweep_test` prints
a VERDICT by design, and the rest print only `failures=0`. **This is the one
signal that would have made 072's fault visible without a diff** — that fault
was found by diffing the PASS list and seeing four lines gone, and 073 and 074
each had to diff the full output against a recorded md5 to be sure nothing had
silently stopped asserting. A count on the result line makes a vanished
assertion visible in the run output itself.
**`formula_test` was given one here, and ONLY because this commit could not
otherwise be verified from the result lists** — its line would not have moved
at all. That is **fixing one member of a list**, which is TRAPS 11, and it is
said here rather than left to look like a class fix. The remaining **55** are
mechanical and low-risk, touch only `tests/`, and would reset every result
line in one commit — so the run record below becomes the last comparable
baseline and the next session should take a fresh one in the same commit,
verifying the change by stripping the counts and diffing against it, which
must come back byte-identical. **That verification is the whole of the work;
the edit is trivial.**

**THEN THE CLASS QUESTION 075 ANSWERED FOR ONE SECTION AND NOT FOR THE PROMPT:
which lines of the assembled prompt can be deleted with no suite failing?**
075 answered it for the **racing** section's 11 rule units by deleting eight of
them one at a time. The prompt has **112 non-blank lines** and **11 suites read
it** (`boots_test`, `capability_test`, `claim_field_test`,
`container_door_test`, `formula_test`, `intent_door_test`, `look_test`,
`order_test`, `procedure_test`, `prompt_bounds_test`, `prompt_numeral_test` —
`prompt_test` and `replay` are tools). Doing it by deletion is 112 runs and the
rendered line does not map one-to-one onto a source line, so **screen it
cheaply first**: collect every string literal in the eleven suites' CODE
(through `_code_of()`), ask which prompt lines no literal reaches, and only
then measure the candidates by deletion. Expect the answer to follow 075's
shape — **the lines with numbers in them are held and the prose is not** — and
expect the dungeon and farm sections to be where it bites, since 074 already
recorded that the eight PROSE numerals have nothing standing behind them.

**The prompt-numeral class stays closed** and 073's warning stands: do not
re-open it by building 068's table of 41.

**And do not take the pattern-breadth axis as written.** Four entries in a row
have now asked for a widening and all four times the widening had no subject.
075's is the fourth and it was measured before a line was changed. The
question that has paid twice running is the one BEHIND the pattern: 072's *what
has the subject never supplied?* and 075's *what has the subject supplied that
nothing reads?* If a fifth entry on that axis is taken, measure the subject
first and expect to spend the commit somewhere else.

## 074 — the kind filed under the value, and two counts asserted against their own arrays

**Objective.** Read the repository first, as instructed, and take the highest
thing that is honestly useful. There is no unaddressed owner finding — the
last owner session is 2026-10-16 and 048's *"there is no way to ASK Genesis
anything"* was written up in 050 as far as it goes without him. So: finish
something already started rather than start something new, which meant
checking 073's own file rather than opening the regex-breadth axis its "Next
action" warns about.

**Starting state.** `prototype-002a` at `0116bab` (073). Baseline in this
container, `--all`, `user://` cleared first: **72 suites, 0 with something to
look at**, and the output **byte-identical to the md5 073 recorded**
(`0fdf976cb74056e853ae2a8f7b62fcb1`). The record and the container agreed
before anything was touched.

### The finding, and it is not the transposed number

073's table is keyed on `(file, numeral)` with the kind read off the row:

```
"npc_goals.gd": [["1", 3, "ORDINAL"], ["2", 1, "PROSE"], ["3", 4, "PROSE"]],
```

`npc_goals` types `1` three times. **Twice** it is the promise that rooms are
numbered from 1 — *"its number counting from 1"*, *"Counting from 1 is only
for a player who says 'the third room'"*. **Once** it is the `1` inside
**`room_1`**, a room name in the worked example, and that example exists
precisely to say that a name carrying a number is not a position:

> *A dungeon whose rooms are called large_hall, room_1, room_2, room_3 has a
> room called room_3, so "room 3" means room_3 — not the third room in the
> list.*

**The kind belongs to the occurrence; the key was the value.** So all three
went under `ORDINAL`, the one kind the file measures against the validators,
and the suite stayed green — because what it asserted was the count of the
numeral and never the kind of the occurrence. Section 6 measures four doors
with a door `[0, 1]`, a thing in room `0`, an order to room 1 and a
reachability walk; none of them is reachable from `room_1`, and nothing said
so.

**The file's own prose had it right.** Its header lists the prose numerals as
*"'go to room 2', 'to room 3', and the example's own room_1, room_2 and its
four room_3s"* — eight, `room_1` among them — and sums the eighteen as *"one
BOUND, two ARITHMETIC, seven ORDINAL and eight PROSE"*. The table said
**eight ORDINAL and seven PROSE**. 073's commit message counted it correctly
and said so. Nothing could catch the disagreement, because **the four
per-kind totals were a count in a comment** — TRAPS 24's shape in the file
whose header claims to have avoided it. It had avoided it per ROW, not per
KIND.

Measured before anything was written, off the templates rather than off the
sentence: **18 typed numerals, 13 bare and 5 welded into an identifier**, and
the five are exactly the worked example's `room_1`, `room_2` and three of its
`room_3`s. Seven bare `1`s, which is the *"seven"* the prose always said.

### And the same fault with no table at all (TRAPS 11)

A sweep of `tests/` for an assertion on a constant's own length found three.

| | |
|---|---|
| `controller_reach_test`: `BRANCHES.size() == 28` | **not this fault** — its message claims only *"28 declared"*, and three assertions under it check every source site against a row, every row against a site, and the per-category counts |
| `refusal_reach_test`: `LAYOUT_BRANCHES.size() == 3` | message: *"all three FAILED_LAYOUT branches were fired"* |
| `refusal_reach_test`: `SHARED_WITH_CONTROLLER.size() == 1` | message: *"and one category name has an owner outside the module pipeline"* |

Both of the latter read an array literal declared forty lines above them.
Both messages claim a fact about the run. **Measured rather than argued:**

- With **branch 3's block deleted outright**, the **pre-074 suite reported 98
  assertions, failures=0.** The branch was gone and the suite still counted a
  passing line saying all three fired.
- With `FAILED_UNWALKABLE` renamed in `game_controller.gd` so the shared name
  no longer has an owner outside the module pipeline, the **pre-074 suite
  reported 1 failure** — the enumeration's, not that line's — while the
  sentence about the owner outside the pipeline passed and was false.

That is the difference the sweep is for: a guard that says it is a guard
(TRAPS 6 allows that, and labels it) versus a guard wearing a measurement's
words.

### Implementation

Two files in `tests/`. **No file in `scripts/` or `scenes/` was wrong and
neither changed.** No file was added or removed, so neither runner needed an
edit.

`tests/prompt_numeral_test.gd`, **97 → 116 assertions**:

- A numeral may appear on **several rows with several kinds**, and the rows'
  counts must **sum** to what is typed. `npc_goals`' `1` is now two rows,
  `["1", 2, "ORDINAL"]` and `["1", 1, "PROSE"]`.
- `_typed_bare()` counts the occurrences that are **not** part of an
  identifier, off the same specifier-stripped text as `_typed()` so the two
  are comparable occurrence for occurrence. `\u0001` stands in for a
  substitution and is deliberately not a word character: a number beside a
  `%s` is a number the prompt states, not part of a name.
- **No `BOUND`, `ORDINAL` or `ARITHMETIC` occurrence may be welded into an
  identifier.** The `1` in `room_1` states nothing the code can enforce and
  cannot drift from anything, so it is prose by construction.
- An **`ORDINAL` numeral must be the `1`** that *"numbered from 1"* is about.
  A `2` filed as an ordinal fails here instead of riding section 6's
  measurement of the ones.
- `KIND_TOTALS` and `TYPED_TOTAL` are **read off the rows and asserted**, and
  the four totals must sum to the typed total.

`tests/refusal_reach_test.gd`, **99 → 105 assertions**:

- Each FAILED_LAYOUT branch appends its name to `layout_fired` **where it
  actually fires**, and the fired set is asserted against `LAYOUT_BRANCHES`
  **in both directions** plus the size.
- The shared name is read **from the source** with the reader the file already
  has: `FAILED_UNWALKABLE` must be returned by a `*_module.gd` and by
  something that is not one.

### Evidence — what was actually run

Godot 4.7.1 on Linux, `4.7.1.stable.official.a13da4feb`, headless, in a cloud
container, every run sequential with `user://` cleared first.

**SEVEN DELIBERATE FAULTS, each in its own throwaway copy with its own
`config/name` (TRAPS 50), FAIL lines READ:**

| fault | result |
|---|---|
| **073's own row restored** — all three `npc_goals` `1`s under `ORDINAL` | **3 failures**, the first naming it exactly: *"an occurrence inside an identifier is declared as a number the code enforces — it is prose"* |
| a **bare** prose numeral refiled `ORDINAL` (`ai_interpreter`'s `3`) | 3 failures |
| a **ninth prose numeral** added to the prompt **and duly declared on its row**, fingerprint moved the way a real prompt edit moves it | 2 failures, with `prompt_bounds_test` green |
| a numeral **welded into an identifier declared `ORDINAL`** (`room_5`) **with `KIND_TOTALS` and `TYPED_TOTAL` edited to agree** | 2 failures — so the bare check is not a restatement of the totals |
| branch 3's block **deleted** | 2 failures, where the **pre-074 suite was green at 98** |
| an **undeclared fourth branch** firing | 2 failures — the other direction |
| the shared name **losing its owner outside the pipeline** | 2 failures, against the pre-074 suite's 1 |

**TWO MUST-PASS CONTROLS PASS, both checked for passing for the RIGHT reason
rather than merely passing:**

- **Two prompt sentences reworded with their numbers untouched** — the
  dungeon's *"Room 1 is the entrance"* and the orders section's *"There is one
  character"*: green at the same **116**, and the eighteen still eighteen. The
  file reads where a number came from, not how the sentence reads (TRAPS 6).
- **A brand-new numeric field on a tool, stated through a substitution**
  (`wobble`, `1 to 9`, in `car_tool.gd`): green at **116** with the suite
  **byte-identical** to the committed one — `diff` RUN, not eyeballed — and
  the prompt's numeral count **92 → 95 read off the output**. The three new
  numbers really did arrive, none of them is typed, and `TYPED_TOTAL`
  correctly did not move. That is the case this file must not fire on.

**72 suites, `--all`, `user://` cleared first: 0 with something to look at.**
The baseline before anything was touched was **byte-identical to the md5 073
recorded** (`0fdf976cb74056e853ae2a8f7b62fcb1`). Against it the lists were
**diffed**: the only differences are **two assertion counts**,
`prompt_numeral_test` 97 → 116 and `refusal_reach_test` 99 → 105. No other
suite's result line moved, and no line was added or removed. **THREE full runs
on the final tree, all byte-identical**, md5
`d13d97d014eeefea52f43e4076a4fb06`, the third on the clean pushed tree — see
"Run the tests first" for why three and for the `docs/` question it settles.

### What the tests did NOT prove

- **NOTHING IS REACHABLE FROM A MODEL HERE.** Nothing was rendered, no window
  was opened, no model was asked anything and no request left the container.
  There is no API key here.
- **The prompt is byte-identical.** `PROMPT_FINGERPRINT` did not move and
  `PROMPT_VERSION` stays at `050-no-command-for-a-question-1`. No number the
  model is told changed; one row in a test table and two assertions did.
- **That the 74 substituted numerals come from the RIGHT constant.** Still
  `prompt_bounds_test`'s and `claim_field_test`'s question, and 074 does not
  re-ask it.
- **That the eight PROSE numerals mean anything.** Nothing stands behind them
  and nothing here pretends to. What holds them is now an **assertion** on
  their count rather than a sentence about it.
- **That a player can reach the farm's lane-check branch.** Measured in 074:
  `FarmModule.solve({"zones": pinched_zones})` returns **`ok=true`**, because
  `solve()` lays the zones out itself and throws the pinched positions away.
  The branch is real and its refusal is measured at `_check_reachable`, which
  is the function `solve()` returns `FAILED_LAYOUT` from; that a request can
  get to it is **not** claimed. `farm_module.gd`'s own comment says the same
  and records moving it to `post_check()` as the owner's.
- **No secret was set and no workflow file was edited.** 064's finding stands:
  the web build has failed on every push since 14 October and the live site is
  still `71b065f`.
- **No new "Human decision needed."**

### Next action

**The prompt-numeral class stays closed** and 073's warning stands: do not
re-open it by building 068's table of 41. What 074 changed is that the kind
column now means something and the totals are derived.

**The honest remainder of the tautology sweep is done.** All three assertions
on a constant's own length in `tests/` have been read; one was correctly
labelled and two were not, and both are fixed. If a fourth is written, this
is the sweep to re-run — `grep -n "_check(\s*[A-Z_][A-Z_0-9]*\.size() =="
tests/*.gd`.

**The live axis is still the one 072 and 073 named, and its method still
holds**: *what has the subject never supplied?*, not *what can the pattern not
match?* The remaining pattern-breadth entries in `tests/` are unasked, and
three entries on that axis in a row asked for a widening that was the wrong
fix. 074 is a fourth data point for the same lesson from a different
direction: the fault was not that a scan could not match something, but that
a classification was keyed one layer too coarse.

## 073 — seventy-four numbers that cannot be wrong, and eighteen that can

**Objective.** The entry 068 wrote into `prompt_bounds_test`'s header and into
this file, and that 069 through 072 each stepped around in favour of a
narrower axis: *"NOT ASSERTED: that every number in the prompt is read from
the thing that enforces it. Counted by script: the assembled prompt holds 92
numerals, 41 of them distinct."* 068's own write-up said why it was left —
*"a good part of the 41 are worked examples and ordinary prose, so the
declared half would be a table of judgements that can go stale"* — and told
the next session to read TRAPS 59 first, because a guard keyed on how a
number is written guards the writing.

**Starting state.** Branch `prototype-002a` at `74e4c86` (072). Baseline
`--all` in this container with `user://` cleared first: **71 suites, 0 with
something to look at**, md5 `f9b0d8cf50968a31a41d42023deab0ef` —
**byte-identical to the md5 072 recorded**, so the record and the container
agree before anything is touched. The count agrees too: a throwaway copy with
its own `config/name` dumped `assembled_prompt()` and it holds **92 numerals,
41 distinct**, exactly as recorded.

### The class is not 41 judgements, which is the finding

068 asked, of the numbers it could find: **is this number the constant's
number?** That question needs a reader per number and a judgement about what
each number means, which is the table nobody wanted to build. The question one
layer behind it is nearly free:

> was this number **TYPED** into the prompt, or **PRODUCED** by the code?

A number that arrives through a `%`-substitution is the same expression the
prompt is built from, so **it cannot drift from the thing that produced it**.
A number typed into the template can drift from anything — and that is the
recurring fault in this project's prompt: 035's farm bound, TRAPS 28's shape,
and 068's own live fault, the composition floors typed out beside the
constants that enforce them.

**Measured before anything was written.** The prompt templates are the
triple-quoted literals in the eight files the registries name, and with the
format specifiers removed first — so the `0` in `%.0f` is not read as a number
the prompt states — the split is:

| where | typed numerals |
|---|---|
| `ai_interpreter.gd` (`SYSTEM_PROMPT`) | `4`, `1`, `2`, `3` |
| `dungeon_module.gd` | `1` x 4 |
| `racing_module.gd` | `0`, `2` |
| `npc_goals.gd` | `1` x 3, `2`, `3` x 4 |
| `farm_module.gd`, `boots_tool.gd`, `car_tool.gd`, `look_tool.gd` | none |

**Eighteen typed, seventy-four substituted.** Seventy-four of the ninety-two
never needed a judgement at all.

### All eighteen were already true

**Nothing in `scripts/` or `scenes/` changed.** Read one at a time:

- **One states a bound**: *"Up to 4 steps"*, and `GameController.MAX_PLAN_STEPS`
  is 4. `prompt_bounds_test` already reads it, through the plan's declared
  list and its *"up to N `<members>`"* pattern — checked by grep before it was
  claimed otherwise (TRAPS 14), because the first guess was that nothing read
  it.
- **Two state arithmetic**: the chicane's *"more than 0 and at most 2 x R"*,
  which `formula_test` measures at both ends and outside.
- **Seven are ordinals** — *"1 for the first"* (the plan's step), *"room
  numbers, 1 for the first room in your list"*, *"its number counting from
  1"* in the dungeon section and again in the orders section, *"Counting from
  1 is only for a player who says 'the third room'"*, *"Room 1 is the
  entrance"* and *"reachable from room 1"*. They promise that members are
  numbered from 1, and the validators do.
- **Eight are prose**: *"go to room 2, then fetch the key"* and *"to room 3"*
  in the same sentence, and the room names in the orders section's worked
  example — `room_1`, `room_2` and `room_3` four times.

**One, two, seven and eight**, counted one at a time off the templates rather
than apportioned, and they come to eighteen.

### What changed — one new file in `tests/`

`tests/prompt_numeral_test.gd`, **97 assertions**, which asks the typed /
produced question of the class and holds the eighteen:

- **The contributors are enumerated from the registries**, never listed in the
  file, so a world or tool added later is **scanned** without it being edited
  — and **fails until a row is added for it**, which is the point rather than
  an oversight: its numbers have to be looked at by somebody. A new numeric
  **field** on an existing tool needs no edit at all, because it is stated
  through a substitution, and that is the second control below. The
  two outside the registries — the constant the prompt starts with and the
  orders section — have their paths read off `ProjectSettings.get_global_class_list()`
  rather than typed, so a renamed file fails instead of quietly reading
  nothing.
- **The enumeration is closed at both ends.** Every file in `scripts/` holding
  a template must be a contributor, and every contributor must hold exactly
  one. Without that half the scan could only ever see the files it already
  knew, which is TRAPS 69's shape and 072's finding.
- **Each template is PROVED to be its section's source.** The template is
  split on its format specifiers and every literal fragment required to appear
  in the rendered section **in order**. This is the answer to TRAPS 59: a scan
  keyed on the prompt happening to be written as a triple-quoted literal would
  be green the day somebody writes one with `+`, so the suite fails on that
  rather than skipping it.
- **Every typed numeral must be declared WITH ITS COUNT**, asserted both ways:
  an undeclared numeral fails naming the file and the line, and a declared
  numeral that has left the prompt fails saying the row is out of date and
  should be struck rather than relaxed. Keying on the count and not the
  numeral alone is deliberate — a bound typed as *"at most 3 doors"* into a
  file where `3` is already declared as prose would otherwise pass.
- **Where a typed number states a fact, the FACT is measured and not the
  number.** The typed `1`s: a door `[1, 2]` is accepted and `[0, 1]` refused,
  a thing `"in": 1` lands in the FIRST room and `"in": 0` is refused, an order
  to room 1 resolves to the first room, and the reachability walk starts at
  room 1 — four rooms joined in a triangle that leaves room 1 out are
  schema-valid and refused `FAILED_UNREACHABLE`, while the same four joined to
  room 1 are accepted, so the refusal is about room 1 and not about the door
  count.
- **And the worked example in the orders section, which nothing had ever
  read.** *"A dungeon whose rooms are called large_hall, room_1, room_2,
  room_3 has a room called room_3, so 'room 3' means room_3 — not the third
  room in the list."* Before 073, a grep of `tests/` for `large_hall` found
  **two** suites — `log_022_test` and `log_023_test` — and neither is about
  this. The names are **read out of the prompt** and
  both halves measured: the name resolves to `room_3` (room 4 of 4), the
  player's own *"room 3"* resolves there too, the **number** 3 resolves to the
  third room, and the two are **different rooms** — which is the whole point
  of the sentence. This is the one wording-keyed assertion in the file and
  says so; a pattern miss **fails** rather than skipping.

### Evidence — what was actually run

**TEN DELIBERATE FAULTS, each in its own throwaway copy with its own
`config/name` (TRAPS 50), each with `PROMPT_FINGERPRINT` recomputed and moved
the way a real prompt edit moves it, FAIL lines READ:**

| fault | result |
|---|---|
| *"A circuit may use at most 3 chicanes"* added to the racing section — **the one that justifies the file** | **1 failure**, naming the numeral and its line; **`prompt_bounds_test` and `claim_field_test` both `failures=0`** |
| the same bound typed as *"at most 2 chicanes"*, reusing a numeral already declared as arithmetic | 1 failure on the count; `prompt_bounds_test` green |
| *"Up to 4 steps"* drifted to *"Up to 6 steps"* with `MAX_PLAN_STEPS` left at 4 | 3 failures here, 1 in `prompt_bounds_test` |
| `look_tool`'s section rebuilt from `+` joins instead of a template | 1 failure; `prompt_bounds_test` green |
| a stray template added to `readback.gd` | 1 failure, by name |
| *"Room 1 is the entrance"* reworded to *"The first room in your list"*, so a declared numeral leaves | 1 failure, saying the row is out of date |
| `if a < 1` widened to `if a < 0` in `dungeon_module.gd`, so room 0 is a room | 1 failure |
| the worked example reworded so the pattern cannot find it | 2 failures — it does not skip |
| the example's `large_hall` dropped, so name and number give the same room | 1 failure, on the check that is not a restatement |
| **068's own fault**: the composition floors typed by hand as *"at least 7 straights and at least 9 corners or hairpins"* | 2 failures here, 1 in `prompt_bounds_test` |

**One fault was discarded and is recorded rather than quoted (TRAPS 55).** The
stray-template injection's first attempt put the `const` above
`readback.gd`'s `class_name`, which does not parse; the run hung until it was
killed and proved nothing. Rerun with the const appended at the end of the
file, it is the single clean failure above.

**TWO MUST-PASS CONTROLS PASS, and both were checked for passing for the RIGHT
reason rather than merely passing:**

- **Four prompt sentences reworded with their numbers untouched** — the road
  separation sentence, the car's `power` line, the dungeon's entrance line and
  the boots' `weight` line: green at the same **97**, and the prompt still
  **92** numerals. The file reads where a number came from, not how the
  sentence reads (TRAPS 6).
- **A brand-new numeric field on a tool, stated through a substitution**
  (`wobble`, `1 to 9`, in `car_tool.gd`): green at **97**, and the prompt's
  numeral count **92 → 95**, read off the suite's own output rather than
  assumed. The three new numbers really did arrive in the prompt and none of
  them is typed, which is the case the file must not fire on.

**72 suites, `--all`, `user://` cleared first: 0 with something to look at.**
**THREE full runs**, `user://` cleared before each, all **byte-identical** to
each other (md5 `0fdf976cb74056e853ae2a8f7b62fcb1`). Said as three rather than
two because the first two each had one **comment-only** edit land in `tests/`
mid-run, in a file that had already run in it; the third was taken on the
final tree with nothing changing during it, and it is identical to both — so
the edits demonstrably changed nothing, which is measured rather than argued.
Against the 071/072 baseline of 71 in this container with the same binary, the
lists were **diffed**: the only difference is **one added line**,
`prompt_numeral_test`, 97 assertions. No existing suite's result line moved —
`source_scan_test`'s included, which matters because this file is a **tenth**
member of the class that suite holds: it reads `scripts/` source, so it
defines `_code_of()` itself, byte-identical to the other nine.

**Neither runner needed an edit, and that was RUN rather than eyeballed
(TRAPS 4).** `run_tests.sh`'s `TIMED`, `SLOW` and `NOT_A_SUITE` lists match on
whole words and `run_tests.bat`'s `findstr /c:` patterns match on substrings;
both were executed against the name `prompt_numeral_test` and none matches. It
steps no physics and takes under a second.

### What the tests did NOT prove

- **NOTHING IS REACHABLE FROM A MODEL HERE.** Nothing was rendered, no window
  was opened, no model was asked anything and no request left the container.
  There is no API key here.
- **That the 74 substituted numerals come from the RIGHT constant.** A
  substitution cannot drift from its own expression, but it can be wired to a
  constant that is not the enforcer. That is `prompt_bounds_test`'s question
  for the worlds and `claim_field_test`'s for the tools, and between them they
  account for every range the prompt states. This file does not re-ask it, and
  the two questions together are what closes the class.
- **That the EIGHT PROSE numerals mean anything.** No assertion stands behind
  them. What holds them is the count: a ninth cannot appear without this file
  being edited. That half is a judgement and is marked as one in the table.
  (This clause said *"nine"* and *"a tenth"* when 073 wrote it, in the same
  commit whose message had already counted the prose at eight and corrected
  itself. Fixed in place in 074 rather than left to be read as current — and
  the count is now an assertion, so the next version of this sentence cannot
  go stale quietly. TRAPS 14, TRAPS 71.)
- **That any model is helped by it.** No model has read this prompt.
- **The prompt is byte-identical.** `PROMPT_FINGERPRINT` did not move and
  `PROMPT_VERSION` stays at `050-no-command-for-a-question-1`.
- **No secret was set and no workflow file was edited.** 064's finding stands:
  the web build has failed on every push since 14 October and the live site is
  still `71b065f`.
- **No new "Human decision needed."**

### Next action

**THE PROMPT-NUMERAL CLASS IS NOW CLOSED AT BOTH QUESTIONS**, and the sentence
in `prompt_bounds_test`'s header that said otherwise has been struck. 92
numerals: 74 produced by a substitution and held by `prompt_bounds_test` and
`claim_field_test` where they are bounds, 18 typed and held by
`prompt_numeral_test`. **Do not re-open it by building 068's table of 41.**

**The remaining twenty-three patterns in `tests/` are still unasked**
*[075: counted rather than trusted — `RegEx.new` returns 22 and
`RegEx.create_from_string` another 20, so it is 42 sites in 14 files. The
twenty-three was stale by the time this was written; see the 075 section.]*, and
072's warning stands: the method that has paid is *what has the subject never
supplied?*, not *what can the pattern not match?* Three entries on that axis
in a row asked for a widening and all three times the widening was wrong.

**And one thing this commit found and deliberately did not do.** The eight
PROSE numerals are the only part of the eighteen with nothing behind them, and
six of the eight are the room names in one worked example. A second worked
example anywhere in the prompt would arrive as prose and be declared as prose.
If that half is ever worth more, the move is **fewer worked examples in the
prompt, not more declarations** — and whether the prompt should carry worked
examples at all is a question about what the model needs, which is the owner's
screen and not an unattended session's.

## 072 — the bound nothing read, and the lookup that skipped in silence

**Objective.** The live entry under "Next action": the last of the three
regex-breadth candidates — `claim_field_test`'s `^%s: N to M`, *"said to be
unable to see a field bound written with a dash or as 'between N and M'"*.
The entry's own instruction was to read the pattern off the file, because its
text had been wrong twice running, and to **ask what the subject has never
supplied before asking what the pattern cannot match**.

**Starting state.** Branch `prototype-002a` at `8b17d70` (071). Baseline
`--all` in this container with `user://` cleared first: **71 suites, 0 with
something to look at**, md5 `f9b0d8cf50968a31a41d42023deab0ef` — **byte-identical
to the md5 071 recorded**, so the record and the container agree before
anything was touched.

### The pattern had NOT drifted, and the widening had no subject at all

Read off the file (TRAPS 66): it is
`(?m)^%s: ([0-9]+(?:\.[0-9]+)?) to ([0-9]+(?:\.[0-9]+)?)\b`, which is what
the entry said it was — the first time in three commits on this axis that the
entry's quote was right.

**And the widening it asked for has no live subject whatsoever.** Measured in
Godot across all three tool sections before anything was touched: **every one
of the nine numeric fields states its bound as `field: N to M`.** Not one
dash, not one *"between N and M"*, anywhere in the prompt. Widening the
pattern would have added breadth for a spelling Genesis does not produce —
the third commit running that this axis asked for a widening that was not the
fix (TRAPS 67, TRAPS 68).

### What the subject had never supplied, which is the finding

The hole is one layer behind the pattern, exactly where 070 and 071 found
theirs. The check was written as a **lookup per field**:

```gdscript
var bound := _stated_bound(tool_mod.prompt_section(), field)
if bound.is_empty():
	continue
```

**A lookup that misses is indistinguishable from a field that has no bound.**
So a bound reworded out of the pattern's shape does not fail and does not
warn — the assertions that would have checked it simply cease to exist, in
the suite that exists to hold bounds. TRAPS 65's shape, inside the file.

**Measured, not argued.** With `brake: %.0f to %.0f newtons` reworded to
`brake: between %.0f and %.0f newtons` and the **pre-072 suite** restored in
its own throwaway copy, the suite reported **`failures=0`** and its PASS list
lost exactly four lines, diffed rather than eyeballed:

```
- PASS  EQUIP boots: the stated bound 150.0 for 'brake' is accepted
- PASS  EQUIP boots: the stated bound 1200.0 for 'brake' is accepted
- PASS  boots 'brake' at 1200.0 validates, so the claim can be measured
- PASS  "stop on a sixpence" promises nothing else, and 'brake' at 1200.0
        changes 1 of the 2 things boots measure
```

The fourth is **the measurement of the headline claim the whole suite was
written for** — 038's *"stop on a sixpence"*. It vanished and the suite stayed
green.

### And a bound no loop over fields could ever reach

Sweeping the sections for **every** range rather than asking per field found
**ten range statements across the three tools: nine field bounds and one
that is not a field's at all.**

`BootsTool.TOP_SPEED` — *"It must come to 2 to 12 metres a second"* — is a
bound stated to the model and enforced in `validate()`, and **no loop over
`defaults().keys()` can reach it, because top speed is not a field.** A grep
of `tests/` for `TOP_SPEED` finds **one hit and it is a comment** in
`formula_test.gd`. Nothing has ever read it.

**The general rule, which is worth more than the fix:** a suite that checks
"every bound the prompt states" by looping over a code-derived list of
**fields** can only see the bounds that hang off a field. A bound stated about
a **derived quantity** is in the class and invisible to the enumeration. Ask
the subject — the text — which claims it makes, not the code which claims it
expects. TRAPS 59 and TRAPS 68, one layer further in.

### What changed — one file, in `tests/`

**Nothing in `scripts/` was wrong and no file in `scripts/` or `scenes/`
changed.** All nine field bounds are accepted at both ends, the top-speed
bound's stated numbers are its constant's, and both its ends are reachable
and accepted. The fault was not present; it was **unpreventable**. That is a
claim about the guard, not about Genesis.

`tests/claim_field_test.gd`, **79 → 121 assertions**, both counted off its own
PASS lines (the pre-072 count by running the HEAD version in its own copy):

- The per-field lookup is replaced by a sweep of every range the section
  states. Each must be **accounted for**: a numeric field's bound, or a
  **declared derived bound**. An unaccounted range **fails** — it is a number
  the model was given that nothing reads.
- **A numeric field that states no bound is now a failure, not a skip.** Which
  fields are numeric is read off `defaults()`, so a field added later is
  covered without editing the suite.
- The two readers must **agree**: the per-field lookup and the sweep must
  return the same bound, so neither can drift away from the other.
- The derived bound gets the same two checks the fields get — its numbers are
  read from the constant (TRAPS 28) — **plus one that is not a restatement:
  both ends must be REACHABLE with legal field values.** A narrowed `push` or
  `weight` range can leave an end of a derived bound unreachable while both
  constants sit exactly where they were, and the player is then told about a
  bound they cannot have. The reaching spec is **solved for** from the
  constants (`push = target x weight x footing`, tried at the corners of the
  other two ranges), never typed in.
- The claim loop's own `continue` is closed the same way: it asserted only
  that **at least one** claim was measured, so a boots claim whose bound
  stopped being readable dropped out in silence while the other kept the
  assertion green. The measurable claims are now **counted** and the count
  asserted.

### Evidence — what was actually run

**SIX DELIBERATE FAULTS, each in its own throwaway copy with its own
`config/name` (TRAPS 50), FAIL lines READ:**

| fault | result |
|---|---|
| `brake:` bound reworded to *"between N and M"* — **the original fault** | **3 failures** where the pre-072 suite was green |
| top-speed bound reworded out of the shape | 2 failures |
| top-speed numbers typed by hand so they drift from the constant | 2 failures, the unaccounted range named in the message |
| `TOP_SPEED` widened to `[2.0, 40.0]` so an end is **unreachable** with legal fields, both constants otherwise untouched | 1 failure, and it is the check that is not a restatement |
| an extra range added to the car prompt (*"Grip works best from 5 to 15"*) | 2 failures, the range quoted back |
| `steering`'s bound removed from the prompt entirely | 1 failure |

**THREE MUST-PASS CONTROLS PASS, and two of them were checked for passing for
the RIGHT reason rather than merely passing:**

- **The pre-072 comparison**, above: the original fault, same copy, old suite
  — `failures=0` and four assertions gone. That is the measurement the whole
  commit rests on.
- **Prose reworded around the bounds, numbers untouched** (three car
  descriptions rewritten): green at **121**, the same count as clean. The
  suite reads the facts and not the wording (TRAPS 6).
- **A brand-new numeric field added to a tool only** (`wobble`, `1 to 9`, in
  `car_tool.gd`): green at **128**, and the **seven new assertions name
  `wobble`** — read, not assumed — with the suite not edited.

**71 suites, `--all`, `user://` cleared first: 0 with something to look at.**
Two full runs on the final tree, byte-identical to each other, and
**byte-identical to the baseline** — expected and stated plainly rather than
dressed up: **no suite was added and no verdict changed, so the run output
cannot move.** What changed is what can now fail, and the run does not measure
that. The six faults and the pre-072 comparison are the measurement.

### What the tests did NOT prove

- **NOTHING IS REACHABLE FROM A MODEL HERE.** Nothing was rendered, no window
  was opened, no model was asked anything and no request left the container.
  There is no API key here.
- **That any model is helped by any of this.** What is measured is that the
  numbers Genesis states to the model are the numbers it enforces, and that
  they are reachable. Whether the model obeys them is the owner's screen.
- **That the three tool sections are the whole class.** This sweep runs over
  `ToolRegistry.tools()` only. The **worlds'** bounds are 035's and
  `prompt_bounds_test`'s, and the wider question — the **92 numerals in the
  assembled prompt**, 41 distinct, of which this file now accounts for ten
  more — is still open and is still the big one.
- **That the derived-bound table is safe.** It is **hand-written**, so a
  derived bound added to a tool is not in it. That is held by the
  unaccounted-range check, which fails on any range the table does not claim
  — so a new one cannot pass unexamined, it has to be added. Written into the
  suite at the table.
- **The prompt is byte-identical.** `PROMPT_FINGERPRINT` did not move and
  `PROMPT_VERSION` stays at `050-no-command-for-a-question-1`.
- **No secret was set and no workflow file was edited.** 064's finding stands:
  the web build has failed on every push since 14 October and the live site is
  still `71b065f`.
- **No new "Human decision needed."**

### Next action

**The regex-breadth axis that 068 opened is now CLOSED at all three of the
candidates 069 handed on, and all three went the same way:** the widening the
entry asked for was wrong every time, and the fault was a layer behind the
pattern every time. Do not re-open it by widening a pattern.

**The remaining twenty-three patterns in `tests/` are still unasked**
*[075: counted rather than trusted — `RegEx.new` returns 22 and
`RegEx.create_from_string` another 20, so it is 42 sites in 14 files. The
twenty-three was stale by the time this was written; see the 075 section.]*, and the
method that has now paid three times is: *what has the subject never
supplied?* — not *what can the pattern not match?*

**And one thing this commit found and deliberately did not do.** Making tools
declare their derived bounds — a `derived_bounds()` on `ToolModule` — would
remove the hand-written table in `claim_field_test.gd` and cover a derived
bound added to any future tool without the suite being edited. It is a change
to `scripts/` for one suite's benefit, and an interface addition to the tool
API is the owner's call rather than an unattended session's. **It is not
"Human decision needed" — it is a proposal, and it is small.**

## 071 — five names that were the same name five times

**Objective.** The live entry under "Smallest useful assistant task next",
the second of the three regex-breadth candidates 068 listed and 070 narrowed
to two: *"`said_article_test`'s `\b(The|A|An) ([a-z_]+) ([0-9]+)\b` cannot see
an article in front of a two-word numbered label."* The entry's own
instruction was to **open the file and read the pattern there**, because its
text for this suite had already drifted.

**Starting state.** Branch `prototype-002a` at `a331e40` (070). Baseline
`--all` in this container, `user://` cleared first: **71 suites, 0 with
something to look at**, md5 `f9b0d8cf50968a31a41d42023deab0ef` —
**byte-identical to the md5 070 recorded**, which is the strongest
confirmation available here that the tree and the binary match the record.

### The entry was wrong twice, and the second way is the finding

**The quote had drifted.** The pattern is
`\b([Tt]he|[Aa]n?) ([a-z_]+) ([0-9]+)\b` — case-folded in its first letter,
where the entry wrote `\b(The|A|An)`. Read off `tests/said_article_test.gd`
rather than taken from the entry (TRAPS 66). Second commit running that this
file's quote of a pattern has been wrong.

**The widening was wrong.** The comment sitting on that pattern had already
measured it: with two words allowed it matches *"a track needs 2 to 40
sections"*, and the `is_label()` guard behind it **cannot rule that out**,
because `is_label("track needs 2")` is `true` — confirmed in Godot, not
inferred. **A regex over free text cannot tell a name from a verb**, so no
breadth makes it the right instrument. 070 found the same shape one candidate
earlier (TRAPS 67); this is twice running.

**And the blind spot was one layer behind the pattern.**
`Readback.is_label()` says a label is a name whose **last** word is a number
and says nothing about how many words come before it — correctly, because
`great hall 2` is as much a label as `room 2`. But **every name any fixture
had ever handed it had exactly one**: `room 2`, `room_2`, `chamber 3`,
`level 2`, `key 2`. The pattern's narrowness was a *consequence* of that, not
the cause.

### What the gap was worth, measured before anything was touched

One character in `scripts/readback.gd` — `words.size() < 2` to
`words.size() != 2`:

```
the("great_hall_2")      ->  "the great hall 2"
article("great hall 2")  ->  "a great hall 2"
readback                 ->  "... entered through a 12 m great hall 2 ...
                              with a spare key 2 in the great hall 2"
```

Three articles on numbered names in one sentence a player reads, and
**all 71 suites green with the `--all` output BYTE-IDENTICAL to the
baseline**, diffed rather than eyeballed.

**It is reachable, checked rather than assumed (TRAPS 14).**
`DungeonModule.validate()` lowercases and trims whatever name the model sent
and stores it with **no shape constraint at all**: a room called
`great hall 2` — real spaces — validates `ok=true, errors=[]` and is rendered
verbatim. Both spellings are in the fixtures now because the validator
accepts both.

### Nothing in scripts/ was wrong

Every sentence family in the class was fed a multi-word numbered name before
anything was changed — `NpcGoals`' ten sentences, the no-door refusal, the
dungeon readback measured and unmeasured — and **every one was already
correct**, because every one already reads `the()` or `article()`.
**No file in `scripts/` or `scenes/` changed.** The fault was not present; it
was **unpreventable**. That is a claim about the guard, not about Genesis, and
it is the whole of what this commit is worth.

### Two suites, not one (TRAPS 11)

`tests/log_022_test.gd` holds the `is_label` fact too, with the same shape of
list, and the same one-character fault passed it as well. A grep for the
function found it; reading only the suite the entry named would have left half
the class open.

### Implementation

Two files, both in `tests/`:

- `said_article_test.gd`: the label fact asserted for multi-word names in both
  directions; `the()` and `article()` asserted over them; fixtures put a
  multi-word numbered name into every sentence family in both spellings; and
  **the sweep moved off the pattern onto `names_used`** — a registry the
  fixtures fill by calling `_use()`, so a name added to a fixture is swept
  without the sweep being edited. TRAPS 59 one layer in: guard against the
  state, not against the spelling. The old pattern is **kept beside it**,
  unchanged, as the backstop for a numbered name no fixture registered, so no
  false positive was introduced. 112 assertions to **181**, counted off its own
  PASS lines.
- `log_022_test.gd`: the same list widened, with the reason at the site.

`_occurrences()` / `_inside_longer()` handle a name standing inside a longer
one — `great hall 2` contains `hall` — **per occurrence and not per line**,
deliberately, so a sentence carrying both `the hall` and `great hall 2` still
fails on the first.

### Evidence — what was actually run

- **Baseline**, `--all`, `user://` cleared: 71 suites, 0 to look at,
  byte-identical to 070's md5.
- **After**, three full `--all` runs on the final tree, `user://` cleared each
  time: 0 to look at, all byte-identical — **and byte-identical to the
  baseline too, which is expected and is stated rather than dressed up: no
  suite was added and no verdict changed, so the run output cannot move.**
  What changed is what can now fail, and the run does not measure that. The
  faults do.
- **Ten deliberate faults, each in its own throwaway copy with its own
  `config/name` (TRAPS 50), FAIL lines read:**

  | fault | said_article | log_022 |
  |---|---|---|
  | `is_label` exactly two words (the original) | **43** | **3** |
  | `is_label` reads first word, not last | 93 | 16 |
  | `the()` stops reading `is_label` | 60 | 7 |
  | `article()` stops reading `is_label` | 26 | 2 |
  | `names_used` left empty | 3 (the pins, only) | 0 |
  | hand-written `"the "` at `dungeon_module.gd:1653` | 11 | 0 |
  | containment disabled | 1 (32 false positives) | 0 |
  | `the()` never adds an article | 21 | 2 |

- **The one that matters most** is the hand-written article, because **both
  sweeps ran on it in the same output and the old one saw half**: the pattern
  named only `room 1`; the new state-keyed sweep named `room 1` **and**
  `great hall 2`.
- **Three must-pass controls pass.** A sentence's tail reworded (*"is in"* ->
  *"sits in"*): both suites green, so the guard reads the fact and not the
  wording. A **brand-new** multi-word name added to a fixture only
  (`north_wing_4`): **named by the sweep without the sweep being edited**. The
  containment helper measured both ways: disabled, **32 false positives**
  (`hall` reported bare inside `great hall 2`), so it is load-bearing;
  enabled, **all four genuinely bare names still named**, so it masks nothing.

### And this commit's own first draft asserted a judgement, not a fact

Recorded rather than quietly fixed (TRAPS 14). It typed in that
`"room 2 of 5"` is **not** a label. It ends in a number, so `is_label()` says
it is — defensibly: *"you are in room 2 of 5"* takes no article. **The suite
failed on the fixture rather than on the code**, which is the suite working.
Replaced with `"room 2 exit"`, which tests the rule that was actually meant: a
number anywhere but the end does not make a label.

**And a second unchecked number, caught the same way.** The first draft of
this section said the suite went *"from 160 to 181 assertions"*. 160 was
remembered from a neighbouring suite's entry in this file, not counted; the
pre-071 suite prints **112** PASS lines, measured by running the `HEAD`
version in its own copy. Both are small and neither reached a commit, but
they are the two mistakes this project is about, made twice in one session by
the thing writing the warnings down: **a number in a document is a claim and
gets counted, including when it is about the document's own work.**

### What the tests did NOT prove

- **That any of this is reachable from a model.** Every name was typed by
  hand. Nothing was rendered, no window was opened, no model was asked
  anything and no request left the container. **There is no API key here.**
- **That `great hall 2` is a name a model would ever send.** What is measured
  is that `validate()` accepts and stores it, so Genesis has no defence
  against it and the readback must be right for it. Whether Gemini produces
  multi-word numbered names is the owner's screen, not this harness.
- **That the run output moving would have meant anything.** It did not move,
  and could not have: no suite was added. The ten faults are the measurement.
- **That the backstop pattern is now sound.** It is unchanged and still
  cannot see an article in front of a numbered name **no fixture
  registered** — the state-keyed sweep covers only names the suite put into
  play. A name invented inside production code and never handed to a fixture
  is covered by the old pattern only, with the old narrowness.
- **That the letter half of `article()` is right.** *"an hour"* and *"a
  unicorn"* still come out wrong; that needs pronunciation and is untouched.
- **No secret was set and no workflow file was edited.** 064's finding stands:
  the web build has failed on every push since 14 October and the live site is
  still `71b065f`.

**Next action.** ~~The last of the three regex-breadth candidates:
`claim_field_test`'s `^%s: N to M`, which is said to be unable to see a field
bound written with a dash or as *"between N and M"*.~~ **DONE IN 072**, and
the entry was right about the pattern and wrong about the fix: the prompt
states no bound with a dash or a *"between"*, and the hole was the per-field
lookup skipping in silence. Struck here rather than deleted, per TRAPS 66's
lesson that an entry is satisfied by the capability arriving. See the 072
section above, whose "Next action" is the live one. The rest of the entry
stands as written: **read the pattern off the file first**, and **ask what
the subject has never supplied before asking what the pattern cannot
match** — that is where the hole was in 070, 071 and 072 alike.

## 070 — two patterns named as one, and the verb a count never agreed with

**Objective.** The live entry under "Smallest useful assistant task next" —
the regex-breadth axis 068 opened, continued at the first of the three
candidates 069 handed on: *"`container_door_test`'s and `counted_said_test`'s
`\b1 [a-z_]+s\b` cannot see a plural that does not end in `s`"*.

**Starting state.** Branch `prototype-002a` at `c455456` (069). Baseline
`--all` in this container with `user://` cleared first: 70 suites, **0 with
something to look at**, md5 `304df3c8d47eb0085b131d5d5ad70423` — **byte-identical
to the md5 069's own message recorded**, so the record and the container agree
before anything was touched.

### The entry named one pattern and there were two

Read off the code rather than taken from the entry (TRAPS 66), then measured
in Godot before anything was changed:

| suite | pattern as written in the file | `1 dead_ends` |
|---|---|---|
| `container_door_test:320` | `\b1 [a-z]+s\b` | **BLIND** |
| `counted_said_test:346` | `\b1 [a-z_]+s\b` | CAUGHT |

The entry quoted the wider pattern for both. `1 banked_corners` and
`1 loop_segments` are blind to the first as well. **`dead_ends` is a key of
the very metrics dictionary `container_door_test`'s sweep runs over**, and a
section type reaches a panel through `RacingModule._counted()` whenever the
validator accepts one the prompt does not offer — which it can, because
`SectionValidator.SECTION_TYPES` holds ten and `OFFERED_TYPES` holds four.
`container_door_test`'s pattern is now the wider one, with the measurement
written at the site.

### The widening the entry asked for was measured, and rejected

To see `1 saved worlds` the pattern must allow a space.
`\b1 [a-z_]+(?: [a-z_]+)*s\b` does, and measured against sentences Genesis
already produces it also matches:

```
1 of them changes to the last world        <- CORRECT at a count of one
1 readback that bears on it                <- CORRECT at a count of one
```

**The agreeing word in both is a VERB.** Widening the pattern would have made
the net report two true sentences as faults, which is how an assertion gets
deleted. The multi-word hole is closed a different way instead — see below.

### And the false-positive control found a live fault

`session_report.gd:242` decided its verb by hand. **Measured by producing the
line, not by reading it:**

```
edits=0  ->  Worlds built: 1 (0 of them changes to the last world).
edits=1  ->  Worlds built: 2 (1 of them changes to the last world).
edits=2  ->  Worlds built: 3 (2 of them changes to the last world).
edits=3  ->  Worlds built: 4 (3 of them changes to the last world).
```

**Correct at one of four.** `s["changes"]` counts records whose source carries
an `edit`, so a tester who builds a world and revises it twice reads *"2 of
them changes"* — and revising is the owner's own workflow. The one count it is
correct at is the one the comment fourteen lines above it was written about:
*"042: the count and the noun after it are one fact, read from
`Readback.plural()` and never written out again"* (TRAPS 22's shape). **This
file quoted the wrong form as real output** at the 033 section, where the
transcript is now annotated rather than rewritten.

### The general rule, and the nine sites it holds at (TRAPS 11)

**A sentence that states a count and a word that agrees with it must read that
agreement from `Readback.agrees()` — whether the agreeing word is a NOUN, a
VERB or a PRONOUN, and whether the count is a variable or a constant.** 042
put the noun behind that reader and swept for nouns. A verb and a pronoun are
the same single fact, `count == 1`, decided somewhere else.

| site | what it decided by hand | was it wrong? |
|---|---|---|
| `session_report.gd:242` | the verb after the change count | **YES — at 3 of 4 counts** |
| `session_report.gd:248` | *"yes, once"* / *"yes, N times"* | no |
| `session_report.gd:290` | the bare-`"no"` count | no |
| `session_report.gd:291` | the pronoun after it | no |
| `race_director.gd:106` | `"" if count == 1 else "s"` | no |
| `ai_interpreter.gd:542` | `%d times` (`MAX_ATTEMPTS`) | no, while it is 3 |
| `ai_interpreter.gd:548` | `%d times` (`MAX_ATTEMPTS`) | no, while it is 3 |
| `dungeon_module.gd:537` | `%d rings` (`MAX_RING`) | no, while it is 4 |
| `feasibility_gate.gd:83` | the floor refusal's two plurals | no, while both are 2 |
| `racing_module.gd:76` | **the AI PROMPT's two plurals** | no, while both are 2 |

That last one is **TRAPS 11 inside 068's own fix**: 068 moved the two floors
to read from the constants that enforce them and left the plural beside them
written out by hand.

**Eight sentences are byte-identical and the ninth is the fault**, proved by
printing all eight before and after and diffing: no difference. **The
assembled prompt is byte-identical too**, so `PROMPT_FINGERPRINT` did not move
and `PROMPT_VERSION` stays at `050-no-command-for-a-question-1` —
`prompt_bounds_test` asserts it, which is the suite's assertion and not an
eyeballing.

### The suite, and why it asserts a fact and not a wording

`tests/agreement_test.gd`, **47 assertions**, counted off its own PASS lines.

- Every agreement assertion is a **round trip against `Readback.agrees()`**.
  The verb is read out of the sentence **by position** and compared **whole**,
  not with `contains()` — the first form of that assertion passed the wrong
  verb at a count of one, because *"changes"* contains *"change"*, and its own
  negative control caught it.
- **The multi-word hole is closed by deriving the nouns from the code**, not
  by widening the regex: every string literal handed to `Readback.plural()` in
  `scripts/` is collected **with its own plural** — the call's third argument
  when it has one — so `"corner or hairpin" -> "corners or hairpins"` is read
  from the call site and never assembled from a rule about adding an `s`. The
  pattern is kept beside it for the nouns no literal can be collected for:
  `RacingModule._counted()` passes `str(type)` and `FarmModule` passes
  `str(key)`.
- Two pins stop the needle half being vacuous (TRAPS 6): at least one noun is
  more than one word, and at least one plural is not the singular plus an `s`.
  Fault 13 removes every multi-word noun and both pins fail.
- The class is held mechanically in two directions: no file but `readback.gd`
  decides `is this count one` inline, and no file writes a count beside the
  plural of its noun. **The reader itself is asserted to still be there**, so
  the first scan cannot pass by `agrees()` having been deleted.

### The guard had the same shape of hole, and the faults found it

**Deliberate fault 5 — reverting `dungeon_module.gd`'s ring budget to
`%d rings` — PASSED every check in the file.** The hardcoded-plural scan
builds its needles from the nouns handed to `Readback.plural()`, and that site
was the **only call in the project passing `"ring"`**: the revert deleted the
fault and the needle that catches it in one edit. **A scan whose class is
derived from the code it is checking is blind to exactly the change that
shrinks the class.**

Held instead by `READS_THE_READER`, a per-site table naming the reader each
site routes through, **with its own weakness written into it**: those rows say
a sentence is *built* from the reader, not that its word was watched changing
with its count. That is the most this harness can say about the four sentences
it cannot stand up — `RaceDirector`'s needs a race on stepped physics,
`AIInterpreter`'s two need the node, and `DungeonModule`'s needs a placement
that actually runs out of space — and it is said plainly rather than dressed
up as a measurement. The five that **are** produced are produced.

### Evidence — what was actually run

- **Baseline, `--all`, `user://` cleared first: 70 suites, 0 with something to
  look at**, md5 `304df3c8d47eb0085b131d5d5ad70423`, byte-identical to the
  md5 069 recorded.
- **After: 71 suites, `--all`, `user://` cleared first, 0 with something to
  look at**, and the output **differs from the baseline by exactly one line —
  the new suite's**. **Three full runs on the final tree, all byte-identical**,
  md5 `f9b0d8cf50968a31a41d42023deab0ef`.
- **Fourteen deliberate faults, each in its own throwaway copy with its own
  `config/name` (TRAPS 50), FAIL lines read.** All nine reverts caught and
  named. The one that matters most is **fault 1**: it fails at counts 0, 2 and
  3 and **passes at 1**, which is the original fault's own signature.
  **Fault 5 is the one that passed first time** and produced the per-site
  table. **Two must-pass controls pass**: fault 11 rewords the sentence's tail
  and fault 14 adds a new multi-word noun in `scripts/`, covered without the
  suite being edited.
- **Fault 7 reverts the prompt and `prompt_bounds_test` stays green**, which
  is worth recording in both directions: the prompt is byte-identical either
  way, so the fingerprint confirms `PROMPT_VERSION` need not move **and**
  cannot see this fault.

### What the tests did NOT prove

- **Nothing was rendered, no window was opened, no model was asked anything
  and no request left the container. There is no API key here.** Whether a
  model's circuit ever makes any of these counts one is unmeasured; what is
  measured is what Genesis says when one does.
- **No secret was set and no workflow file was edited.** 064's finding stands:
  the web build has failed on every push since 14 October and the live site is
  still `71b065f`.
- **Four of the nine sentences were not produced**, only pinned to their
  reader. Named above, with the reason for each.
- **A hardcoded agreeing word with no conditional and no derived noun behind
  it is still invisible to both scans.** `session_report.gd:242` was exactly
  that shape and was caught only by the produced sentence. The scans catch the
  idiom and the known noun; they cannot catch a verb nobody has told them is a
  verb.
- **That any of these sentences reads well.** Eight are unchanged, so there is
  nothing new to read; the ninth now says *"2 of them change"* where it said
  *"2 of them changes"*, and that it is now correct English is not the same
  claim as that the line is worth having.

**Next action.** The regex-breadth axis has **two of 069's three candidates
left**, and they are named here so they need not be re-read — each a guess
until it is fed its member, and **each to be read off the file before it is
trusted, because 070 is the second commit running to find this file's own
enumeration short (TRAPS 66, TRAPS 67)**: `said_article_test:322`'s
`\b([Tt]he|[Aa]n?) ([a-z_]+) ([0-9]+)\b` — which the entry wrote as
`\b(The|A|An) …`, so it has **already drifted from the file**, and which
cannot see an article in front of a two-word numbered label; and
`claim_field_test:149`'s `^%s: N to M`, which cannot see a field bound written
with a dash or as *"between N and M"*. There are **27 regex sites in
`tests/`** by grep, of which 068 and 070 have asked the question of three.
New TRAPS 67. **No new "Human decision needed."**


## 069 — the list of three that was a class of five, and the member a player actually meets

**Objective.** The live entry under "Smallest useful assistant task next",
which named itself small and measured: **three player-facing sentences say
"corner" where the code means a TURN**, with line numbers —
`feasibility_gate.gd:100`, `racing_module.gd:176`, `racing_module.gd:584` —
and with the work estimated as *"three words and a full run"*.

**Starting state.** Branch `prototype-002a` at `dc4f567` (068). The baseline
`--all` run in this container, `user://` cleared first, was **byte-identical
to the md5 068's own message recorded** —
`9bb6bd51cf700054e643edd76a4d2780`, 69 suites, 0 with something to look at —
so the container reproduces 068's measurement exactly and everything below is
measured against a baseline that is known to agree with the record.

**Decision, and it is the finding.** The three line numbers were read as
where to start and not as the membership, because TRAPS 31 says a list in a
document is a reading and not the class. `grep corner scripts/*.gd` over the
string literals, then asking of each hit **which set the number beside it is
taken over**, found **five sentences in three files**. The two the entry did
not name are the two that matter most:

- **`racing_module.gd:566` — the `SOLVER CHANGE` panel row.** It reads
  `drift.max_angle_adjustment`, the solver's maximum over
  `TrackGeometry.YAW_TYPES`, which is the same number the three named
  sentences report. **All three of those are reached only by a REFUSAL. This
  one is a panel row, shown on every circuit that was BUILT** — so it is the
  member of the class a player actually meets, and it was not on the list.
- **`main.gd:845` — "tightest corner %.0f -> %.0f m radius".** It reads
  `metrics.minimum_radius`, which `TrackMetrics.measure()` takes over
  `TrackGeometry.CURVED_TYPES` — corner, hairpin, banked_corner, chicane and
  loop_segment. The same fault over a **wider set**, and **the one reading of
  three that had drifted**: `racing_module.gd:547`'s `TIGHTEST RADIUS` row and
  `experiment_runner.gd:247`'s *"tightest radius"* already named that number
  correctly. The wording is taken from those two rather than invented.

**The general rule, stated so it can be applied.** A sentence shown to a
player that names a section type is making a claim about **which sections the
number beside it was taken over**, and the claim is true only if the noun
names that whole set. The solver's angle adjustment is taken over
`YAW_TYPES`, so its noun is *turn*. The tightest radius is taken over
`CURVED_TYPES`, so its noun is *radius* and no section type at all.

**What it cost, measured rather than inferred.** `ClosureSolver.solve()`
builds an angle variable for every `YAW_TYPES` section, so a hairpin's angle
is adjusted exactly as a corner's is — measured, not supposed: on a
composition of straights and **hairpins only**, the solver reports
`max_angle_adjustment = 0.20`, the full limit, and `FeasibilityGate` reports a
reach of exactly ±20% of those hairpins' own angles. Four sentences then told
the player that number was about corners, on a circuit that had none.

**Implementation.** Five nouns, each with the set it names written at the
site: `scripts/feasibility_gate.gd` (1), `scripts/racing_module.gd` (3),
`scripts/main.gd` (1). **No logic changed.** The prompt text is untouched and
`prompt_bounds_test` still asserts `PROMPT_FINGERPRINT` unmoved, so
`PROMPT_VERSION` stays at `050-no-command-for-a-question-1` and no
interpretation measured under it is split.

**New suite: `tests/said_set_test.gd`, 31 assertions.**

### What it asserts, and why it is a fact and not a wording (TRAPS 6)

Every fixture is straights and **hairpins** with **no corner in it** —
asserted by `_no_corner_in()` on the sections actually handed to the code, not
assumed from the builder. A sentence about such a composition that uses the
word *corner* is therefore **false about the thing it describes**. The
assertions are paired: for each sentence the suite first measures **the fact
the sentence reports** (that the solver really moved a hairpin's angle, that
the gate's reach really is computed from a hairpin's angle, that
`minimum_radius` really is a hairpin's radius) and then reads the sentence,
which is also asserted to be **present and to carry its number** — a sentence
that vanished would pass a "does not say corner" check on its own.

### Evidence — what was actually run

- Godot 4.7.1 headless on Linux (`4.7.1.stable.official.a13da4feb`),
  downloaded in this container.
- **Baseline before anything was changed:** 69 suites, `--all`, `user://`
  cleared, 0 with something to look at, md5
  `9bb6bd51cf700054e643edd76a4d2780` — **the md5 068 recorded**.
- **After:** 70 suites, `--all`, `user://` cleared, 0 with something to look
  at. The output **differs from the baseline by exactly one line**, the new
  suite's. Two full runs on the final source, both byte-identical, md5
  `304df3c8d47eb0085b131d5d5ad70423`.
- **NINE DELIBERATE FAULTS, each in its own throwaway copy with its own
  `config/name` (TRAPS 50), FAIL lines read:**
  1. `gate:100` reverted to *per corner* → 1 failure, naming the sentence.
  2. `racing:176` reverted to *corners up to* → 1 failure.
  3. `racing:566` reverted to *corners* → 1 failure.
  4. `racing:584` reverted to *every corner and straight* → 1 failure.
  5. `main:845` reverted to *tightest corner* → 1 failure.
  6. **`per turn` reworded to `per section that turns` → PASSES.** This is the
     fault that matters: the suite reads the **set**, not the word, so a
     rewording that stays true of a hairpin is not broken by it (TRAPS 6).
  7. The `racing:176` sentence **deleted** → fails on the *present* assertion,
     so the "does not say corner" check is not vacuous.
  8. `hairpin` removed from `YAW_TYPES` → **6 failures**, all of them facts.
  9. `uphill` added to `OFFERED_TYPES` → fails the slope pin described below.

### A claim 069 made, measured, and corrected before publishing (TRAPS 14)

069's first fixture helper put both straights before both turns, described the
result as a paperclip, and measured a **160 m closure miss** on it — which
reads like a solver that breaks a circuit that already closes, and would have
been a serious finding. **It is not one.** A paperclip **alternates** straight
and turn, and `ClosureSolver` closes the real one **exactly**: proposal
distance `0.0000`, net turn `360.000`, `ok=true`, zero adjustment, measured
directly. **The fixture was wrong, not the code.** The corrected claim is
written into the helper's own comment in the suite rather than quietly
dropped, because the next session reading a 160 m miss in a scratch probe
should know what it was.

### What the tests did NOT prove

- **Nothing was rendered, no window was opened, no model was asked anything
  and no request left the container. There is no API key here.** Whether a
  model ever composes a hairpin is unmeasured; what is measured is what
  Genesis says when one does.
- **No secret was set and no workflow file was edited.** 064's finding stands:
  the web build has failed on every push since 14 October and the live site is
  still `71b065f`.
- **That the adjusted angle is the RIGHT angle.** That is `procedure_test`'s
  subject, which already holds `max_angle_adjustment` against `angle_limit`.
  This suite is about the noun.
- **The straight-family half of the same four sentences**, which is the next
  item.

### One half of the class is deliberately left, and it is the owner's

All four sentences that now say *"turns"* say *"straights"* beside them, and
the solver length-adjusts every section in `TrackGeometry.STRAIGHT_FAMILY` —
straight, uphill, downhill, crest, dip. **That is the identical fault one word
along, and it is TRAPS 11's exact shape.** It is latent for one reason, which
is measured and not assumed: `SectionValidator.OFFERED_TYPES` holds **two of
three** `YAW_TYPES` members and **one of five** `STRAIGHT_FAMILY` members,
because the four slope types are the subject of **"Human decision needed" 1**
(the validator accepts ten types, the prompt offers four and says *"only these
four"*, and `GENESIS_BRIEF.md` records that nothing drives the vertical axis
safely yet).

Choosing the word a player reads for a set the owner has not decided to open
is product direction, so it is written here and not changed.
`said_set_test` **pins the fact so it cannot be forgotten**: it fails if a
slope type ever becomes offered while those sentences still say *"straights"*
(fault 9 above). **If "Human decision needed" 1 is answered (a) leave it,
nothing needs doing** — the sentences are already true of every composition a
player can compose today.

**Next action.** The three regex candidates 068 read and did not take,
continuing the regex-breadth axis: `container_door_test`'s and
`counted_said_test`'s `\b1 [a-z_]+s\b`, `said_article_test`'s
`\b(The|A|An) ([a-z_]+) ([0-9]+)\b`, and `claim_field_test`'s `^%s: N to M`.
See "Smallest useful assistant task next", which now carries 069's warning as
well: **read the class off the code before trusting any enumeration of it,
that list included.** New TRAPS 66. **No new "Human decision needed"** — the
straight-family half belongs to 1, which is already open.


## 068 — the bound stated in the one direction the suite that holds bounds could not read

**Objective.** The live entry under "Smallest useful assistant task next" —
042's question, *"for every sweep in `tests/`, what is the sweep blind to?"* —
along the axis 067 explicitly left: **regex breadth**, which is 042's own
fault. 067 closed the comment axis. A comment cannot cause a pattern that
matches only one direction of its class, and `_code_of()` does nothing about
it.

**Starting state.** Branch `prototype-002a` at `5062f8b` (067). 69 suites,
`--all`, `user://` cleared first, run in this container with
Godot 4.7.1-stable before anything was touched: **0 with something to look
at**.

**Which suite, and why that one.** `grep` finds **27 patterns** in `tests/` —
eighteen `RegEx.compile()` and nine `RegEx.create_from_string()`, across
twelve files. `tests/prompt_bounds_test.gd` was taken first because its
subject is the project's earliest claim: TRAPS 28's rule is that *a bound
stated to the MODEL is a claim about Genesis*, and that suite is the only
thing holding it. Its own header says what its patterns buy — *"it does not
matter which sentence says it or how"* — which is a claim about a regular
expression, and the kind this project has learned to distrust.

### The answer, and it was two patterns blind in the same direction

`_counts_stated()` read a count statement two ways:

```
(?i)([0-9]+) to ([0-9]+) (<members>)\b
(?i)(?:at most|up to|no more than) ([0-9]+) (<members>)\b
```

Both correct. Between them they can only match a statement that names a
**maximum** — the first requires both numbers, the second only a ceiling — and
the loop that consumed them compared the maximum **unconditionally**, so a
minimum-only shape could not even be added to the reader without changing the
loop.

**What the prompt was stating in that shape, read line by line against the
code rather than searched for:** four numbers, all typed out by hand.

| stated in the prompt | the thing that enforces it | named in `tests/`? |
|---|---|---|
| `at least 2 straights` | `FeasibilityGate.MIN_STRAIGHTS` | **nowhere** |
| `at least 2 corners or hairpins` | `FeasibilityGate.MIN_TURNS` | **nowhere** |
| `exactly +360 … or -360 …` | `FeasibilityGate.FULL_TURN` | **nowhere** |
| `Angles adding up to 360` | the same `FULL_TURN` | **nowhere** |

`grep` for each of the three constants across `tests/*.gd` returns nothing at
all. A constant no test names is a constant the prompt can contradict.

### Measured, in its own throwaway copy, before anything was changed

With `racing_module.gd`'s line reading *"at least 7 straights and at least 9
corners or hairpins"* — a floor stated four times narrower than the truth,
which is TRAPS 28's own fault, the fault that suite exists for — and
`PROMPT_FINGERPRINT` moved with it the way every real prompt edit moves it:

```
suites with something to look at: 0
```

**All 69.** And the pre-068 reader handed the farm's zone floor restated as
*"Use at most 24 zones, and at least 9 zones"* against a declared minimum of
1 and a validator that accepts 1: `PROMPT BOUNDS failures=0`.

**`PROMPT_FINGERPRINT` is not a second net**, and this is worth saying because
it looks like one. It fails on *any* change to the prompt and its message says
*"move PROMPT_VERSION"*. It is a change detector, and the session that edits
the prompt moves it in the same commit. The run above is what that looks like.

### And one of them was LIVE, which the rest of 068 is not

**`FeasibilityGate`'s floor refusal told the player a narrower rule than the
gate keeps, in two sentences one line apart.** The rule read *"closing a
circuit needs at least 2 straights and 2 corners"*, and the count beside it
read `Readback.plural(turns, "corner")`. `MIN_TURNS` is compared against a count of
`TrackGeometry.YAW_TYPES`, which is `["corner", "hairpin", "banked_corner"]`,
so **a hairpin answers that door as well as a corner** — measured, not
supposed: the floor fixture `prompt_bounds_test` now builds is `MIN_STRAIGHTS`
straights and `MIN_TURNS` **hairpins and no corner at all**, and the
"clears that door" assertion is the measurement that it passes. The prompt has
always said *"corners or hairpins"*; the sentence the **player** reads said
*"corners"*. A refusal naming a narrower set than the check accepts costs the
player the design the check would have taken, which is TRAPS 15's shape at a
refusal. Both are fixed and both are held by assertions that read a real
`FAILED_DEGREES_OF_FREEDOM` verdict.

**AND THE FIRST CLAIM 068 WROTE ABOUT THIS WAS WRONG. It is left in the record
rather than quietly fixed (TRAPS 14), because the way it was caught is the
finding.** 068 wrote *"nothing in `tests/` had ever read that sentence"* on
the strength of a `grep` of `tests/` for `composition has`, which returns
nothing. **`counted_said_test` reads it.** Its needle is
`Readback.plural(1, "corner")`, built at run time, so the string a grep would
look for is not in the file — and the suite **went red on the fix**, in the
first full run after it, which is how the claim was caught rather than
published. What that assertion holds is the agreement between the count and
whatever noun follows it, with **the noun typed in**, so it could not see the
noun being the wrong one; its own file header boasts that *"the types are read
from `FarmModule.ZONE_TYPES` and `SectionValidator.SECTION_TYPES`, never typed
in here"*, and at this one site they were. Its expectation now reads `turn`
and both suites say in their comments which half they hold. **A grep for a
sentence finds the suites that QUOTE it, not the suites that CONSTRUCT it** —
and that is the same blind spot as the one 068 is about, one layer out: a
search for a wording cannot see a needle that is assembled.

**AND THE SAME WORD IS WRONG IN THREE MORE PLAYER-FACING SENTENCES, WHICH
068 MEASURED AND DELIBERATELY DID NOT CHANGE.** `ClosureSolver.solve()`
builds an adjustable variable for **every** `TrackGeometry.YAW_TYPES` section,
so it adjusts a hairpin's angle exactly as it adjusts a corner's — and three
sentences say *corner*:

- `feasibility_gate.gd:100` — *"with up to 20% adjustment per **corner**,
  this composition reaches only …"*;
- `racing_module.gd:176` — *"adjustment used: **corners** up to x%, straights
  up to y%"*;
- `racing_module.gd:584` — *"Even after the game adjusted every **corner** and
  straight by up to 20% …"*.

`grep` finds no reader for any of the three in `tests/` — **and that is the
grep 068 has just been burned by, so it is not evidence, only a starting
point**. The reason they are left is not that they are harmless but that they
are **descriptive rather than prescriptive**: none of them states a rule the
player has to satisfy, so none of them costs a design the way the floor
refusal did. Changing five player-facing sentences in one unattended commit is
more than this one should carry, and the owner is the editor of what the
player reads. **They are the first live entry under "Smallest useful assistant
task next".** The gate's own header comment, four lines above the first of
them, already says *"scale each corner or hairpin"* correctly.

**The same count was typed out in prose a second time**, in
`racing_module.gd`'s comment above `metric_lines()` — *"a closed circuit needs
at least two straights and two corners (FeasibilityGate), so the first two can
never BE one"* — where the whole point of the sentence depends on both being
above 1. It now names the constants instead of the numbers.

### Two more members, found by asking it as a class (TRAPS 11)

- **The full turn is stated a fourth time, to the PLAYER.**
  `FeasibilityGate`'s `FAILED_INFEASIBLE` reason reads *"a circuit must turn
  exactly +360 or -360 deg"* — hand-typed, in the file that declares
  `FULL_TURN`, eleven lines below it. Fixing the prompt alone would have left
  it.
- **`FeasibilityGate.MAX_ANGLE_ADJUSTMENT` is a second declaration of
  `ClosureSolver.MAX_ANGLE_ADJUSTMENT`.** The gate decides which net turns are
  reachable from **its** copy and states **its** copy to the player in the
  same refusal; the prompt states the solver's; `prompt_bounds_test` already
  asserted the solver's own pair were equal and said why, and did not know
  about the third. Both are `0.20`, so **nothing is wrong today** — what was
  missing is the tie. Moving the solver's limit alone would leave the gate
  refusing compositions the solver can close, in a sentence naming the wrong
  percentage, with every suite green.

### Implementation

- **`scripts/racing_module.gd`** — four numbers in `prompt_section()` now read
  `FeasibilityGate.FULL_TURN`, `MIN_STRAIGHTS` and `MIN_TURNS`. This is the
  rule TRAPS 28 settled and praised the two tool files for following: state
  the bound out of the constant, do not remember it.
- **`scripts/feasibility_gate.gd`** — `FAILED_INFEASIBLE`'s second reason now
  reads `FULL_TURN` as well.
- **`tests/prompt_bounds_test.gd`**, 61 assertions to 72:
  - a minimum-only reader, `(?:at least|no fewer than|a minimum of) N
    <members>`, and each half of a bound compared **only when the sentence
    states it**;
  - the two composition floors and the full turn asserted against their
    constants;
  - the floors measured at the **gate**, which is TRAPS 28's third link for a
    bound that has no `lists()` declaration to sit in the middle: the gate is
    handed a composition one straight short, one turn short, and exactly at
    the floor, and the answer is read off the **category**
    (`FAILED_DEGREES_OF_FREEDOM`) and not the sentence;
  - the refusal sentence read off a real `FAILED_INFEASIBLE` verdict, from a
    composition whose turns cancel, built from the floors so that it lands at
    the second door;
  - `FeasibilityGate.MAX_ANGLE_ADJUSTMENT` asserted equal to the solver's;
  - `TrackGeometry.YAW_TYPES` asserted to hold both a corner and a hairpin,
    because the floor fixture picks between them by the share of the full turn
    and would otherwise change which door it measures in silence;
  - and the floor refusal's own two sentences — the rule and the count beside
    it — asserted to name a turn rather than a corner, read off a real
    `FAILED_DEGREES_OF_FREEDOM` verdict.

**THE PROMPT TEXT DID NOT CHANGE.** `assembled_prompt().sha256_text()` is
`5a15cd3972ceb300e353c6204ef80ca08f991f07cf8662e30599e475bf1d9cfb`, which is
`AIInterpreter.PROMPT_FINGERPRINT` unmoved — asserted by the suite itself, not
eyeballed. `PROMPT_VERSION` stays at `050-no-command-for-a-question-1` and no
interpretation measured under it is split in two.

### Evidence — what was actually run

- **69 suites, `--all`, `user://` cleared first: 0 with something to look
  at**, against the same 69 at the 067 baseline run in this container with the
  same binary before anything was touched. No file was added, so the list
  length did not move; `prompt_bounds_test` is the only line whose assertion
  count changed, 61 to 72, counted off its own `PASS`/`FAIL` lines in a copy
  of `HEAD` rather than remembered — it prints no count in its result line, so
  the run output cannot show it. **Two full runs on the final source, and both
  are BYTE-IDENTICAL to the 067 baseline run**: md5
  `9bb6bd51cf700054e643edd76a4d2780` all three times, which is the same md5
  067's own message recorded.
- **One real regression, caught by a full run and not by reasoning**:
  `counted_said_test` went red on the refusal-noun fix (`the gate's refusal
  says "1 corner"`). Recorded above; both the code and this file's claim were
  corrected, and the suite is green.
- **Ten deliberate faults, each in its own throwaway copy with its own
  `config/name` (TRAPS 50), FAIL lines read:**
  1. the prompt's floors hand-typed back as 7 and 9 — caught, and `1b`, the
     same fault with `PROMPT_FINGERPRINT` recomputed as a real edit would
     recompute it, **fails on the new assertion alone** (`failures=1`), which
     is the whole point;
  2. the gate enforcing `MIN_STRAIGHTS + 1` while its constant says
     `MIN_STRAIGHTS` — caught, three failures, the first naming the cause;
  3. `FeasibilityGate.MAX_ANGLE_ADJUSTMENT` moved to `0.25` — caught;
  4. the prompt's full turn hand-typed as `+361/-361`, fingerprint moved —
     caught;
  5. the refusal's full turn hand-typed back and `FULL_TURN` moved to `350`,
     fingerprint moved — caught, naming `+350 or -350`;
  6. the farm's floor restated as *"at least 9 zones"*, fingerprint moved —
     caught, `the prompt's minimum of 9 is the declared 1`;
  7. **negative control**: the same wording with the **correct** floor, *"at
     least 1 zones"* — `failures=0`, so the new reader reads the number and
     not the wording (TRAPS 6);
  8. **the one that justifies the change**: fault 6's prompt against the
     **pre-068** reader — `failures=0`;
  9. the floor refusal narrowed back to *"%d corners"* — caught;
  10. the count beside it reverted to `plural(turns, "corner")` — caught.
- Fault 6's first run was discarded and is recorded rather than quoted: the
  injection removed a `%s` from the farm prompt without removing its argument,
  so eleven unrelated assertions failed from one fixture fault (TRAPS 55). Rerun
  with the argument removed, it is the single clean failure above.
- The infeasible fixture's first draft was written with two straights and
  fault 2 pushed it back to the first door; it is now built from the floors,
  and the comment above it states that at the width it is true (TRAPS 15).

### What the tests did NOT prove

- **Nothing was rendered, no window was opened, no model was asked anything
  and no request left the container.** There is no API key here. Whether
  telling the model these floors in these words changes what it sends is the
  owner's editor session.
- **One of 068's findings was live and the rest are LATENT.** The floor
  refusal's *"2 corners"* was a wrong claim in a sentence a player can read
  today, and it is fixed. The four prompt bounds were already stating the
  truth and the two adjustment constants already agree, so **nothing else
  wrong was found anywhere in the repository**: what changed for those is that
  six claims can now fail when they should.
- **The live one was not reached by a sweep.** It was found by reading
  `feasibility_gate.gd` while moving the hand-typed numbers in it, which is
  worth saying because 068's method was a question about patterns and this
  came out of reading the file the patterns pointed at.
- **The three new prompt assertions are narrower than the rest of the file and
  say so in its header.** They match the prompt's own wording around the
  numbers, because a number with no list noun beside it cannot be found any
  other way, so they will fail on a rewording that keeps the numbers true.
  That is the safe direction and it is still a cost.
- **The minimum-only reader has no live subject.** `Readback.list_rule()`
  writes *"N to M members"* or *"up to N members"* and never that shape, so
  today the pattern matches nothing. It is held by faults 6 and 7 and by
  nothing else.
- **Twenty-three of the twenty-seven patterns in `tests/` have not been
  asked.** 068 asked one suite's two. See "Smallest useful assistant task
  next" for the three candidates read and not taken.
- **The 92 numerals in the prompt are not accounted for.** 41 distinct,
  counted by script. Four are now read from their constants and the bounds
  `prompt_bounds_test` already names are read from theirs; the rest are
  unasked.
- **No secret was set and no workflow file was edited.** 064's finding stands:
  the web build has failed on every push since 14 October and the live site is
  still `71b065f`.

### Next action

**The three sentences that say "corner" where the code means a turn**, listed
above with their line numbers: `feasibility_gate.gd:100`,
`racing_module.gd:176`, `racing_module.gd:584`. Three words and a full run,
and the full run is the point — `grep` finds no reader for any of them and
`grep` is what 068 got wrong about the floor refusal.

**Then the regex-breadth axis at the remaining twenty-three patterns**, by the
same method and in the order the candidates are listed under "Smallest useful
assistant task next" — each is a guess until the pattern has been fed the
member of its class it cannot match. The wider question behind it, the
prompt's 92 numerals, is written up in the same place with what it would
cost.

## 067 — the rule written down in one commit and applied to one function

**Objective.** The live entry under "Smallest useful assistant task next",
in its own words: *"for every sweep in `tests/`, what is the sweep blind
to?"* — raised by 042, never taken. Asked here along **one** axis: can a
comment satisfy it? That axis was chosen because 066 had just been bitten by
it, fixed one function, and written the general lesson into TRAPS in the same
commit, which is TRAPS 11's exact shape.

**Starting state.** Branch `prototype-002a` at `e9f3cca` (066). 68 suites,
`--all`, `user://` cleared first: **0 with something to look at**, run in this
container before anything was touched, with
`4.7.1.stable.official.a13da4feb`.

### The class, enumerated rather than listed (TRAPS 31)

Counted by script over `tests/`, not remembered: **nine files read a `.gd`
source out of this repository** — `check_wiring_test`,
`controller_reach_test`, `handler_wiring_test`, `player_door_test`,
`proxy_test`, `record_id_test`, `refusal_reach_test`, `scene_light_test`,
`view_frame_test`. Of their scan sites, **seven already stripped comments in
some form and eleven did not**, and the split was inconsistent *inside* single
files: `check_wiring_test`'s `_verdict_functions()` strips and its `BY_HAND`
check two hundred lines later does not.

**Three of the eleven were answerable by prose in the direction that
matters** — a presence check a comment can satisfy. Each was reproduced in its
own throwaway copy of the project outside the repository with its own
`config/name` (TRAPS 50), **before** anything was changed, and each needed one
comment line:

| guard | the fault | without the comment | with it |
|---|---|---|---|
| `handler_wiring_test` — its `PLACEHOLDER` is the string `main.gd` writes | change `main.gd:978`, leave the old text in a comment beside it | **47, failures=1** | **47, failures=0** |
| `player_door_test` — no suite reaches the main scene by a path of its own | add a suite that loads the scene from a path it assembles, with a comment saying it does *not* use the setting | **67, failures=1** | **67, failures=0** |
| `check_wiring_test` — `BY_HAND`'s row still names a function that exists | rename `quarrel_with()` through `scripts/` and `tests/`, put the row back to the old name, add *"Renamed from func quarrel_with(reason)"* to `refusal_check.gd` | **188, failures=1** | **188, failures=0** |

The other eight read raw text in the **absence** direction — *"nothing in
`scripts/` sets `use_collision`"*, *"a scene resource path is written out in
one file"* — where a comment makes the suite fail **loudly** for a wording
reason rather than pass quietly. Not a false pass, and not harmless: this
file's own fixture for the `player_door_test` fault **failed on a comment in
the throwaway suite written to measure it**, which is how that half was found.

### And the rule in TRAPS 63 is the wrong rule, which is worth more than the fixes

TRAPS 63's last bullet says *"scan code, not comments."* Applied to the class
as written, **it would have narrowed two checks that are wide on purpose.**
`controller_reach_test` and `refusal_reach_test` each collect every `FAILED_`
name in `scripts/` and assert that every one has a declared row. A name that
appears **only in a comment** still has to be answered for, because somebody
reading that comment will go looking for the row.

And the same scan's other direction needs the opposite text:
*"a declared row still names a category the code returns"* is exactly the
stale row that a category deleted from the code and left in a comment would
keep alive.

**So the rule is about DIRECTION and not habit:**

> A question about what the code **does** is answered from the code, comments
> stripped. A question about what is **mentioned** anywhere reads the raw
> file. Which one a scan is asking is decided by the direction of its
> assertion.

`refusal_reach_test._categories_in_source()` now takes `code_only` and is
called **both ways**, with the reason written at the function.
**Measured when the split was made, rather than assumed: all 16 categories are
in code, 6 of them are also in comments, and none is comment-only** — so no
answer in the repository changed, and the split is what makes the staleness
half able to fail at all.

### Implementation — no file in `scripts/` or `scenes/` changed

- **One reader, `_code_of()`**, in each of the nine files plus the new suite.
  It blanks whole-line comments **in place** and cuts trailing ones, so the
  **line count is preserved** — not tidiness: `record_id_test`'s session scan
  reports `file:line` off this text, and 066's own fault 2 was a report that
  named a line which started nothing. Verified after the change: that scan
  still names `handler_wiring_test.gd:583`.
- **Eleven scan sites moved onto it**, across `check_wiring_test`,
  `controller_reach_test`, `handler_wiring_test`, `player_door_test`,
  `proxy_test`, `record_id_test`, `refusal_reach_test`, `scene_light_test` and
  `view_frame_test`. `record_id_test`'s `_asks_who_it_is()` is now two lines
  — the stripping 066 wrote by hand is the shared reader's job.
- **A negative control beside each fixed presence scan**, asserting the
  **reader** and not the wording: the needle in a whole-line comment and after
  code on the same line are both invisible, and the same needle in a line of
  code is not. That last assertion is what stops the first two passing by
  seeing nothing (TRAPS 6).
- **`tests/source_scan_test.gd`** (new, 24 assertions) enumerates every file
  in `tests/` that reads a `.gd` source, and asserts: each goes through
  `_code_of()`; each **defines** it, because `tests/` has no shared library;
  and **all ten copies are byte-identical** — ten private copies of one
  function is TRAPS 28's shape, and a drifted copy is a scan blind in a way
  nothing says. It holds itself to the same rule, and it asserts the one
  **exclusion** as a fact: `session_test.gd` names `res://tests` once and that
  line is its `extends`, so an `extends` is not a read.
- **Two things deliberately NOT changed.** The two wide `FAILED_` scans stay
  wide, with the reason written where somebody applying TRAPS 63 literally
  would read it. And `proxy_test`'s reads of `netlify/functions/interpret.js`
  and `export_presets.web.cfg` stay raw: their comments are `//` and `;`, not
  `#`, so `_code_of()` is the wrong reader and **nothing about them was
  measured here**.
- **Neither runner needed an edit.** `run_tests.sh`'s `TIMED`, `SLOW` and
  `NOT_A_SUITE` lists and `run_tests.bat`'s `findstr` patterns were **RUN**
  against the name `source_scan_test` rather than eyeballed (TRAPS 4): none
  matches, so it runs with no `--fixed-fps`. It takes under a second and
  steps no physics.

### Evidence — what was actually run

- **69 suites, `--all`, `user://` cleared first: 0 with something to look
  at**, against **68** at the 066 baseline taken in this container with the
  same binary before anything was touched. The lists were **diffed**, not
  quoted from memory: `check_wiring` 188 → 190, `handler_wiring` 47 → 49,
  `player_door` 67 → 69, `refusal_reach` 96 → 99, and one added line,
  `source_scan_test` 24. **`controller_reach` stayed at 136**, which is the
  measurement that says moving its trailing-comment skip into `_code_of()`
  cost no site: all nineteen rows held.
- **Two full runs after the last edit, BYTE-IDENTICAL** (md5
  `9bb6bd51cf700054e643edd76a4d2780`).
- **The three faults above were reproduced BEFORE the fix and re-run AFTER
  it**, and all three now fail by name: *"the placeholder this file looks for
  is the one main.gd writes, in code and not in a comment"*, *"and every suite
  that stands main.gd up reaches the scene through application/run/main_scene,
  not by a path of its own"*, *"quarrel_with is still in refusal_check.gd, in
  code and not in a comment"*.
- **066's own fault 1 still fails**, which is the regression that mattered
  most: `handler_wiring_test`'s session name reverted to the bare string is
  still caught, by name and at the right line.
- **NINE DELIBERATE FAULTS against the new suite**, each in its own throwaway
  copy with its own `config/name`, FAIL lines **read** rather than counted:

  1. A new suite in `tests/` that scans `main.gd` as raw text → named, with
     the line, **and** reported as not defining the reader. 2 failures.
  2. One copy of `_code_of()` drifted by a single character (`:=` → `=`) →
     *"all 10 copies are byte-identical"* failed naming `scene_light_test`.
  3. A member keeping the call and losing the definition → named.
  4. `_code_of()` replaced by `return source` → 6 failures: the drift row and
     every prose assertion.
  5. Comment lines **removed** instead of blanked → the line-count
     assertions failed, which is the half that protects `file:line` reports.
  6. **FAULT 6's FIRST ATTEMPT PROVED NOTHING AND IS RECORDED THAT WAY
     (TRAPS 55).** It changed one of `scene_light_test`'s two source paths and
     the suite correctly stayed green, because the file still named the other
     one — an incomplete injection, not a blind check. Re-run with **every**
     source path in that file assembled from pieces (verified by script:
     zero code lines carrying the literal), the `KNOWN` row failed by name.
  7. `session_test` given a real source read → **4** failures: it joins the
     class, is reported as raw and as defining nothing, and the exclusion
     assertion fails because its mention is no longer only its `extends`.
  8. **A negative control**: a suite whose only mention of `res://scripts`,
     `res://tests` and `FileAccess` is in a comment, reading nothing →
     correctly **not** in the class, 0 failures.
  9. **A second negative control**: a new suite that reads source **and** goes
     through an identical `_code_of()` → correctly admitted, class size 10 →
     11, 0 failures.

### What this does NOT prove

- **It does not hold the rule per needle, and `source_scan_test`'s own header
  says so.** What is asserted is that a member has the reader and uses it
  somewhere. A suite that strips comments for one scan and reads raw text for
  the next would pass. The per-needle half is held only where 067 put a
  negative control, beside each fixed presence scan. Narrowing the closure
  needs a parser, and a parser written here would be the next thing nothing
  holds to account.
- **It found no live wrong answer anywhere in the repository.** All three
  faults are **latent**: measured, every `FAILED_` category is in code, every
  needle the fixed scans look for is in code today, and not one assertion
  changed its verdict. What changed is that three guards can now fail when
  they should.
- **Nothing was rendered, no window was opened, no model was asked anything
  and no request left the container.** There is no API key here.
  `PROMPT_VERSION` did not move and the prompt is byte-identical.
- **No secret was set and no workflow file was edited.** 064's finding stands:
  the `web build` has failed on every push since 14 October and the live site
  is still `71b065f`.
- **The other axis of 042's question is still unasked.** 042's entry says to
  grep `RegEx` and `contains(` in `tests/` and ask of each *"what passes this
  that should not?"*. 067 asked exactly one thing of exactly one family of
  readers: can a comment answer it? **A regex that can only match one word
  order (042's own fault) or one direction of its class is a different blind
  spot and was not looked for here.**

### Next action

See "Next action" above. The comment axis of 042's question is answered and
struck; the regex-breadth axis is not and is now the first live entry.

## 066 — the salt that was a clock, and the entry that had been done for five commits

**Objective.** Read the repository first, as the standing instruction says,
and work the first item that is honestly available. "Next action" offered
two. **One of them had been finished five commits earlier and this file was
still calling it live** (see below). The other — *finish the id class* — is
two thirds the owner's. What was left was the third part nobody had counted:
the names the **suite** hands Genesis.

**Starting state.** Branch `prototype-002a` at `2df275f` (065). **68 suites,
`--all`, `user://` cleared first: 0 with something to look at**, run before
anything was touched.

### THE FIRST FINDING IS ABOUT THIS FILE

**"Next action" item 2 — *hold the four `connect()` rows 059 found unheld* —
was done in 060**, in `tests/player_door_test.gd`, all four through a real
emit. 065's own sentence at the top of that section called both items "the
live next task". One grep of `tests/` for `text_submitted` refutes it.

That is **TRAPS 14 in the file the project depends on for continuity**: the
next unattended session, following this file literally, would have spent its
two hours re-doing 060's work. **Why it survived is the part worth keeping:
the entry said `handler_wiring_test` was "the file to extend", and 060
satisfied it by writing a NEW FILE instead — so nobody struck it.** An entry
is satisfied when the capability arrives, not when the file named in it is
touched. The entry is now struck in place rather than deleted, with 060's
answer against it.

### THE SECOND FINDING IS A REPRODUCIBLE FAULT, AND IT IS THE HARNESS'S

059 fixed `TrackLog.next_id()` and named the class as three: the record id
(fixed), the session id and the experiment `run_id` (both left, both "Human
decision needed" 22, because the first changes reports the owner already has
and the second needs a key). **That count of three is a count of what GENESIS
mints. It is not a count of the places the rule holds.**

`main.gd:515` mints a session id as `"<name> <datetime to the second>"`, and
`TrackLog.read_session()` returns every record carrying that id out of one
`user://track_log.jsonl` that every copy of this project shares (TRAPS 50).
**Three suites start a session.** Before 066:

| suite | session name | defence |
|---|---|---|
| `handler_wiring_test` | `"handler_wiring"` | **none** |
| `session_test` | `"Sam Jones"` | **none** |
| `ledger_audit_test` | `"audit-" + Time.get_ticks_msec()` | **a clock** |

**Reproduced before anything was changed** (throwaway copy, its own
`config/name`, TRAPS 50): six paired concurrent runs of
`handler_wiring_test` against one ledger. **In FIVE of the six, one of the
pair failed** *"the ledger gained exactly one ai_unavailable event (got 3)"*
— its own two events plus the other process's one — and then returned early
at that section's `if events.size() != 1: return`, **scoring 44 assertions
where a clean run scores 47.** A varying assertion count under a treatment
that cannot reach the suite is TRAPS 56's signature exactly, and that is the
trap that cost 059 a day of sweep measurements. **After the fix: six of six,
47 assertions and 0 failures on both sides.**

**AND THE ONE SUITE THAT HAD DEFENDED ITSELF DID IT WITH THE ONE THING TRAPS
56 SAYS DOES NOT QUALIFY.** `Time.get_ticks_msec()` counts **engine uptime**,
which is mostly deterministic startup work, so it is *narrower* than
wall-clock, not wider. Measured over **20 headless runs** of this project,
the value read at the top of a suite spanned **123..199 ms**, and in 20
samples `129` came up three times and `172` twice.

### What changed, asked of the class and not the instance (TRAPS 11)

**No file in `scripts/` was touched. `PROMPT_VERSION` did not move. Nothing a
player can reach behaves differently.** Four files in `tests/`:

- `handler_wiring_test.gd` — `"handler_wiring-%d" % OS.get_process_id()`
- `session_test.gd` — `"Sam Jones %d" % OS.get_process_id()`. **The space is
  kept deliberately**: the assertion under it is about a name with a space in
  it reaching `TrackLog` intact. The report print below it built the header
  from the literal `"Session 'Sam Jones'"`; it now builds it from the same
  variable, because typed out it returned `-1` from `rfind()` and
  `substr(-1)` printed the whole history instead of the report (TRAPS 28, a
  string written twice — print-only, and fixed).
- `ledger_audit_test.gd` — the `ticks_msec` salt becomes
  `OS.get_process_id()`.
- `record_id_test.gd` — **two new sections, 11 new assertions, 22 in all.**
  TRAPS 56's "Do" ends *"then ask it of the class and write down the size of
  the answer, grepped rather than remembered"*, and this file had not. Prose
  is not a reader.
  - **Section 8 holds the rule for the harness.** It scans every `.gd` in
    `tests/`, finds every session **start** (`"/session <something not
    end>"`, outside comments and outside `_check()` messages) and asserts
    that a file which starts one also asks the OS who it is, **in code**. A
    fourth suite that starts a session unprotected fails here **by file and
    line**.
  - **Section 9 holds the owner's two as a FACT, labelled `OPEN (Human
    decision 22)`.** It finds each of the three mints in `scripts/` by the
    text that identifies it, asserts the record id's carries
    `OS.get_process_id()` and the other two still do not, and asserts the
    class is **three**. **A suite does not get to answer a question that is
    the owner's** — what it can do is say the answer has not changed, so that
    the day he moves either, the next session is told instead of grepping for
    it.
- `record_id_test`'s `quit()` is now `quit(bad)`. Stated plainly because it
  is not part of the task: the suite printed its failures and exited 0, which
  `run_tests.sh` does not read (it greps the printed line) but anyone running
  the file directly does. Every other suite of this shape already does it.

### Evidence — what was actually run

- **68 suites, `--all`, `user://` cleared first: 0 with something to look
  at**, the same 68 as the 065 baseline, because **no file was added or
  removed** — the two new sections went into a suite that already existed.
  The baseline above was run before anything was touched, in this container,
  with the same binary.
- `record_id_test` alone: **22 assertions, failures=0**, up from 12.
- **Six paired concurrent runs before the fix: 5 of 6 showed one side at 44
  assertions / 1 failure.** Six after: **6 of 6 at 47 / 0 both sides.**
- **NINE DELIBERATE FAULTS**, each in its own throwaway copy of the project
  outside the repository with its own `config/name` so it could not share
  `user://` (TRAPS 50), and the FAIL lines **read, not counted**:

  1. `handler_wiring_test`'s name back to the bare string → named the file
     and line. **This one PASSED on the first attempt and that is the most
     useful result in the commit**: section 8 searched whole files for
     `OS.get_process_id()`, and the comment the fix had just added to that
     suite says the call **in prose**. A check a comment can satisfy is TRAPS
     6 inside a test. Section 8 now scans code only, and the fault fails.
  2. `session_test`'s name back to the bare string → named it. **Its report
     listed `session_test.gd:62`, which starts nothing**: the scan was
     counting an assertion *message*, `_check(..., "/session alone reports
     the running session")`. Harmless where the file does start a session
     elsewhere; a file whose only mention was in a message would have been
     flagged for nothing. Narrowed, and re-run (fault 2b) it names line 58
     alone.
  3. `ledger_audit_test`'s salt removed → named it.
  4. **A fourth suite added to `tests/` that starts a session with a bare
     name** → named the new file and line. This is the closure working.
  5. `OS.get_process_id()` removed from `next_id()` → **4 failures**: the
     three-field assertion, the writer assertion, the `FIXED (059)` one, and
     the class count fell to 2.
  6. A process id **added** to `main.gd`'s session id — the owner answering
     HD 22 — → the `OPEN` assertion for the session id failed, which is the
     behaviour it is for.
  7. A process id added to `run_id` → the other `OPEN` assertion failed.
  8. `main.gd`'s session mint renamed → "minted in one place in `main.gd`"
     failed, and the class count fell to 2. A site that **moves** reports as
     moved rather than as fixed.
  9. **A negative control**: a suite whose only mention is `/session end`
     → correctly **not** flagged, 0 failures.

### What this does NOT prove

- **It does not make `session_test` safe to run twice at once, and 066 does
  not claim it.** That suite **deletes** `user://track_log.jsonl` at its
  first line, so a concurrent pair destroys each other's ledger for reasons
  that have nothing to do with a session name. **Measured both ways rather
  than reasoned about.** Before the fix, three paired runs scored **8 and 8,
  8 and 7, 8 and 8** failures — *both* sides, every time. After the fix, two
  paired runs scored **1 and 2, then 1 and 1**, and the surviving failure is
  the same one in every process: *"all 26 records in the session are tagged
  with the tester"*. That is `_log_lines()` walking the whole shared file and
  finding the **other** process's untagged records inside its own session
  window — the deletion, not the id. So the fix removed what it claimed to
  remove and nothing more. **Nothing was changed about the deletion**:
  whether a suite may delete a shared ledger is its own question and it is
  written up under "Human decision needed" 29.
- **Nothing was rendered, no window was opened, no model was asked anything
  and no request left the container.** No API key is present here.
- **It does not answer "Human decision needed" 22.** The product's session id
  and `run_id` are byte-identical to 065's.
- **Two real OS processes are still not proved never to collide**, for the
  reason `record_id_test`'s own header gives: that needs a second process
  spawned from a suite, and a test that races a clock passes or fails on
  where the second boundary falls. The paired runs above were driven from the
  shell, by hand, and are recorded as a count rather than asserted.
- **No secret was set and no workflow file was edited.** 064's finding
  stands: the `web build` has failed on every push since 14 October and the
  live site is still `71b065f`.

### Next action

See "Next action" above. Item 1 is now **only** the owner's two identifiers;
item 2 is struck as done in 060. The next assistant task is the first live
entry under them.

## 065 — the last of 061's six, and the eight pixels nothing was holding

**Objective.** 063's "Next action", in its own words: *"The command panel's
anchors and the three strings in the scene — the last of 061's six, and the
only part of the visual layer a headless suite has not been pointed at."* With
a warning attached: `get_rect()` on a laid-out-never-drawn `Control` under a
`CanvasLayer` *"may or may not be meaningful headless, and that should be
established by measuring it in a throwaway copy before anything is asserted
off it — an assertion resting on a rect that is always zero would be TRAPS 6
again."*

**Starting state.** `prototype-002a` at `70687e6` (064). 67 suites, `--all`,
0 with something to look at. Nothing in `scripts/` or `tests/` read a
`Control`'s rect, an anchor or any string set in `scenes/main.tscn`.

### The warning was right, and the answer is narrower than it predicted

Measured in a throwaway copy first, as instructed. **The layout is not
deferred and frames do not need stepping**: a `Control` gets its rect as it
enters the tree. There is exactly one window in which a rect reads zero —
before the viewport's first layout pass, which is to say inside
`_initialize()`, which is where a `SceneTree` script starts and therefore
exactly where a suite written the obvious way would read it.

| when the node was added | rect read immediately |
|---|---|
| inside `_initialize()`, before the first frame | `(0, 0)` |
| from a deferred call, one frame having begun | `(1152, 120)` |
| later still | `(1152, 120)` |

**So `_run.call_deferred()` is load-bearing and nothing said so.**
`scene_light_test`, `view_frame_test` and this file all open with it; for
anything reading a rect it is the difference between a measurement and
zeros compared to zeros. New TRAPS 62.

**AND THIS FILE'S OWN FIRST DRAFT GOT IT WRONG, WHICH IS HOW IT WAS FOUND.**
Section 1 was first written to assert that the rect needed frames stepped —
the probe's conclusion, carried over without re-checking the condition it
held under. It **failed on the first run**, because by the time a deferred
`_run()` adds anything, a frame has begun. The failure is the finding; the
assertion now states the rule that is true and asserts both halves of it, so
the day the engine changes its mind the next session is told which way.

### Two things 063's own paragraph undercounted, and both are TRAPS 11

1. **The strings are four, not three.** 063 named `TitleLabel`'s text,
   `InputBox`'s placeholder and `BuildButton`'s text. `scenes/main.tscn` also
   sets `StatusLabel.text = "Status: Waiting"` — and that one *is* read by
   code (`main.gd:22` holds it and overwrites it within a frame), which is
   precisely why it was easy to leave out of a list of *"strings nothing
   reads"*. The class is **a string this scene sets**, and it has four
   members. Section 0 enumerates rather than naming, so a fifth joins the
   list without the list being edited.

2. **The panels are three, not one.** *"The command panel's anchors"* names
   the one panel that is in the scene. Two more are built in code and added
   to the same `CanvasLayer` — `main.gd:916` `HistoryPanel` and `main.gd:954`
   `MetricsPanel` — and both are positioned with **absolute pixel offsets
   from the top edge**, where the command panel's are relative to the
   **bottom**. The rule a player cares about belongs to all three together:
   panels do not sit on top of one another and do not hang off the screen.

### The worst case is bounded, which is what makes it assertable

`project.godot` sets no window size, so the base viewport is Godot's default
**1152 x 648**, with stretch mode `canvas_items` and aspect `expand`.
Measured by asking the root for several sizes:

| asked | logical viewport |
|---|---|
| 1152 x 1152 | 1152 x 1152 |
| 1152 x 800 | 1152 x 799 |
| 1152 x 648 | 1152 x 648 |
| 1152 x 500 | **1492 x 648** — height floored, width grew instead |

Under `expand` the logical viewport never goes **below** the base size in
either axis. So 648 is a floor on the logical height, **the base viewport is
the tightest the vertical layout can ever be**, and a suite that checks the
panels there has checked them at every window size. The suite asserts the
floor itself rather than assuming it. `--resolution` was tried first and
**has no effect headless** — the viewport stayed 1152 x 1152 at every value —
so the root's own `size` is what moves it.

### THE FINDING: it is correct today, and eight pixels from not being

At the base viewport the three panels do not overlap — measured, not assumed.
But the margin is thin and nothing was holding it:

| panel | vertical extent | from |
|---|---|---|
| `HistoryPanel` | 10 .. 250 | absolute, from the top (`main.gd:923-926`) |
| `MetricsPanel` | 258 .. 520 | absolute, from the top (`main.gd:961`) |
| `CommandPanel` | 528 .. 648 | its **content height**, from the bottom |

**Eight pixels** between the metrics panel's bottom edge and the command
panel's top edge, and the two numbers come from different files. 520 is an
`offset_bottom` somebody typed; 528 is 648 minus the command panel's 120 px
of content height — **the sum of four children's minimum sizes, which moves
with the font**. `grow_vertical = 0` against a bottom anchor means the panel
grows **upward**, into the metrics panel.

**Demonstrated, not reasoned about.** One extra `Label` added to that
`VBoxContainer` — a legal, ordinary edit — takes the clearance to **−19 px**
and the two panels overlap. Before this commit nothing in the repository
would have said so.

**NOT A FAULT TODAY AND NOT FIXED HERE.** The layout is correct as it stands,
and moving a panel is a judgement about what the screen should look like,
which is the owner's: new "Human decision needed" 28. What the suite does is
hold the eight pixels so the day they go, it says which two edges met.

### What the suite asserts

`tests/scene_ui_test.gd` is new, **43 assertions**, and is the first file in
this project to read a `Control`'s rect, an anchor or a string set in the
scene.

- **Section 0 is a GUARD** and says so in the output, every line prefixed
  `GUARD:`. The four strings, read off a **fresh instance never added to the
  tree** — the file is the right subject for *"is a value there to be got at
  all"*, because `main.gd` overwrites `StatusLabel`'s text within a frame and
  the running game would answer this question about itself rather than about
  the scene (063's fault 8, one layer along, TRAPS 61). Nothing a player types
  writes any of these, so none can fail on a request; they fail the day
  somebody empties one in the editor.
  One of them is a different claim from the rest and is worth naming:
  **`InputBox.text` is asserted empty**, so the example sentence stays a
  placeholder and is never a value that gets submitted.
- **Section 1 is the MEASUREMENT the rest rests on** — the zero and the
  non-zero, as above. Its subject is a `CanvasLayer` and a `PanelContainer`
  built by hand and **not** a second copy of `main.tscn`: instantiating that
  scene runs `main.gd._ready`, which opens the shared ledger, and two of
  those in one process is TRAPS 56.
- **Section 2 is the measurement at the worst case.** Every **pair** of
  panels, not the pair that was interesting; containment in the viewport,
  because a panel off the bottom is invisible without overlapping anything;
  the command panel's anchoring, grow direction, and that its height is its
  content's minimum rather than a number anybody chose.
- **One assertion is labelled `JUDGEMENT` in the output**, as 063's daylight
  band is: that the clearance is **at least 8 px**. Eight is the margin
  measured at 065, not a figure anybody chose, and the label says so.
- **Section 3 closes the class off the tree.** The scene has exactly one
  `CanvasLayer`; every top-level `Control` under it is found by **walking**
  rather than by name, and the count is asserted — an enumeration that finds
  nothing passes everything inside it in silence (063's fault 2).

### Run against broken code before it was believed (TRAPS 51)

Eight deliberate faults, one at a time, each in its own throwaway copy
outside the repository with its own `config/name` so none could share
`user://` with anything. FAIL lines **read**, not counted.

| fault | result |
|---|---|
| 1. `TitleLabel`'s text emptied | **2** — the count drops to 3, and the named assertion |
| 2. `StatusLabel` deleted from the scene | **2** — the count, and *"still has a StatusLabel in it"* |
| 3. the example sentence moved from `placeholder_text` into `text` | **2** — the placeholder assertion and *"the example is a placeholder, not a value"* |
| 4. **a fifth row added to the command panel** | **4** — the string count, and the overlap, naming **−19 px** and both edges |
| 5. `MetricsPanel`'s `offset_bottom` moved 520 → 545 | **3** — the overlap, naming −17 px |
| 6. the command panel re-anchored to the top | **6** — two overlaps, the anchor pair, the grow direction, and the bottom edge |
| 7. a fourth panel built in code, off to the left | **1** — the class count alone, which is the closure doing its job: it overlaps nothing |
| 8. `HistoryPanel` pushed off the right edge | **1** — containment, printing the rect and the viewport |

### Evidence

- **Baseline at 064, before anything was added:** 67 suites, `--all`,
  **suites with something to look at: 0**.
- **After:** 68 suites, `--all`, **0 with something to look at.**
- **The lists were diffed and the only difference is ONE ADDED LINE**,
  `scene_ui_test`'s. No existing suite's result line moved. The baseline was
  re-run for the diff with the new file moved out of `tests/` rather than
  quoted from memory.
- **The full run was done twice with `user://` cleared before each** (TRAPS
  50) and **the two are byte-identical**.
- Run alone the suite gives **43 assertions, failures=0**, in about a second.

### Not verified

- **NOTHING WAS RENDERED. No pixel was drawn and no window was opened.**
  Every number here is a rect computed by the layout engine, which runs
  headless. None of it is evidence that anything is **legible**, that the
  panel style is visible, that text fits inside its own box, or that the
  colours work. A `Control` under a `CanvasLayer` is laid out and never drawn
  in this container, exactly as 062 and 063 recorded.
- **IT IS STILL NOT ASSERTED THAT THE PANELS DO NOT COVER THE WORLD**, and
  that is deliberate. 062 wrote the question down as the owner's and 063
  repeated it. It is now **partly answerable** — the panels' rects are known
  and the camera's frustum is known — and is still not answered, because
  which part of a framed world a player needs to see is a judgement about the
  game and not arithmetic. What is new is only that the inputs exist. See
  "Human decision needed" 28.
- **THE STRING VALUES ARE GUARDED, NOT JUDGED.** That `InputBox`'s
  placeholder is `"make a race track"` is asserted; **whether that is a good
  sentence to show a new player is not.** It is worth one look and it is the
  owner's: HANDOVER 032 records *"make me a race track"* with no sections
  described as hitting Prototype 001's stub, which clears the world and
  reports that it built nothing. **Whether the model answers that sentence
  with a sectionless `CREATE_TRACK` is NOT KNOWN and was not tested** — this
  harness has no key and nothing was reproduced from the owner's screen. The
  suite asserts the string, never that the string is wise.
- **NO FILE IN `scripts/` CHANGED, AND NEITHER DID `scenes/main.tscn`.** This
  commit adds one test file and documentation. `PROMPT_VERSION` did not move,
  the prompt is byte-identical and `prompt_bounds_test` passed. No model sent
  anything and no request left the container. No world, record or saved file
  of the owner's changed.
- **NO BROWSER RAN AND NO WEB EXPORT WAS MADE.** The web build gets the same
  scene and the same panels, and nothing here verifies that. 064's finding
  stands untouched: the `web build` workflow still fails on every push and
  the live site is still `71b065f`. **No secret was set and no workflow file
  was edited.**
- **NOTHING WAS MEASURED AT A WINDOW LARGER THAN THE BASE VIEWPORT'S ASPECT.**
  The floor is asserted; the ceiling is not, because panels anchored to edges
  only get further apart as the viewport grows.

### Next action

**For the assistant, and 061's six are now all read, so this is a new axis
rather than the next item on a list.** The two cheapest, in order:

1. **The id class, still two thirds undone (TRAPS 11, TRAPS 56)** — the item
   that has sat at the top of "Next action" since 059 and been passed over by
   060 through 065. The session id (`main.gd:514-515`) and the experiment
   `run_id` (`experiment_runner.gd:62`) carry the same fault 059 fixed in the
   record id. **Read the caveat before starting**: the session id's shape is
   "Human decision needed" 22 because it appears in reports the owner already
   has, so that half needs asking, and only `run_id` can be changed without
   him.
2. **The four connect rows 059 found unheld**, all four reachable with no key,
   with `handler_wiring_test` the file to extend and 058 the method. The
   cheapest is `lap_completed`; `pressed` and `text_submitted` are **the two
   doors a player actually uses** and nothing in the project emits either.
   The full ordering and the method are in the "Next action" section above.

**And one thing this commit found and left alone, which is a judgement and
not a task:** `InputBox`'s placeholder is the one example sentence Genesis
shows a new player, and the shape of request it suggests is the shape 032
recorded as hitting a stub that builds nothing. Whether the model actually
answers it that way is unverifiable here. Written up under "Human decision
needed" 28 rather than changed, because the words a player is shown first are
product and not engineering.

---

## 064 — the deploy that has failed on every push since 14 October

**Objective.** None of its own: this is a **record, not a change**. No code,
no scene and no test was touched. It exists because the question *"did the
build go through?"* was asked about 063, and answering it honestly meant
looking at the one workflow this repository has — which turned out to be
failing, and to have been failing for eight days, with nothing in these
documents saying so.

**Starting state.** Branch `prototype-002a` at `924d274` (063). 67 suites,
`--all`, **0 with something to look at**, three byte-identical runs. That part
was already true and is unchanged by this commit.

### What was measured

`.github/workflows/web.yml` is the only workflow in the repository. **It is
not a test runner** — the headless suite has never run in CI and does not run
here either. What it does is export the Godot web build on every push to
`prototype-002a` and publish it to Netlify. Read off the Actions API:

| | |
|---|---|
| last successful run | **27**, commit `71b065f` (020), 2026-10-14 06:26 |
| first failure | **28**, *"Deploy with the Netlify CLI, to one URL"*, 2026-10-14 06:30 |
| consecutive failures since | **46** — every push, 021 through 063 |

**The export is not what fails**, and that is the part worth knowing. On
063's own run, number 73, the job's steps came back:

```
3. Fetch Godot and its web export template   success   (8s)
4. Import, then export                        success   (9s)
5. Publish to Netlify                         FAILURE   (5m 27s)
```

So the web export of the current code — `scenes/main.tscn`'s fixed sun
included — **builds cleanly with the 4.7.1 web template**. The failure is in
the publish, and the log gives the cause in two lines of job environment:

```
NETLIFY_AUTH_TOKEN:
NETLIFY_SITE_ID:
Logging into your Netlify account...
Opening https://app.netlify.com/authorize?response_type=ticket&ticket=...
- Waiting for authorization...
Error: Timed out waiting for authorization.
```

Both secrets are **empty**, so the Netlify CLI falls back to an **interactive
login**, prints an authorize link into a log nobody is reading, and waits.
**Every push for eight days has spent five and a half minutes waiting for a
human to click a link in a CI log, then exited 1.**

### Why this was not found before, which is the same shape as 062 and 063

The gap is not that nobody knew the secrets were unset — HANDOVER has said
*"set `NETLIFY_AUTH_TOKEN` and `NETLIFY_SITE_ID` as GitHub secrets so a push
deploys"* since 020, under the owner's own outstanding item. **The gap is that
nothing ever read the result.** The sentence describes a future in which the
secrets are set; no document recorded that in the present they are not, and
that the consequence is 46 red runs and a public site frozen at a commit from
before 021. **A push being red is only ever true on a page nobody in this loop
opens**, which is TRAPS 60's lesson one layer out from the game: the
unattended task reads `git log`, PROTOCOL, HANDOVER and TRAPS, and the
workflow's verdict is in none of them.

### What changed

- **`docs/HANDOVER.md` only.** A new bullet under "Limitations — unverified or
  absent" with the table above; a correction to the 020 note, whose *"so a
  push deploys"* is currently **false**; and this section.
- **NOTHING ELSE.** No code, no scene, no test, no workflow file.

### Not verified, and not done

- **NO SECRET WAS SET, NO WORKFLOW FILE WAS EDITED AND NOTHING WAS
  RE-RUN.** Secrets and deployment are the owner's by standing instruction and
  this commit does not touch them. The fix is two values in **Settings →
  Secrets and variables → Actions**, and it is his.
- **IT IS NOT KNOWN WHETHER THE DEPLOY WOULD SUCCEED ONCE THEY ARE SET.** All
  that is established is which step fails and why. Whether the site then
  serves a working build is the first deploy's answer, not this one's.
- **THE SUITE STILL DOES NOT RUN IN CI**, and this commit does not propose
  that it should — adding it would be a change to what a push costs and does,
  which is the owner's call. It is written up as **"Human decision needed"
  27**.
- **NO BROWSER RAN.** The export's success is GitHub's report of its own
  step, not a page that was loaded and looked at.

### Next action

Unchanged: 063's, the command panel's anchors and the three strings in the
scene. This commit adds nothing to the assistant's queue — it moves one thing
onto the owner's, where it already half-was.

---

## 063 — the sun that pointed along the ground

**Objective.** 062's "Next action", in its own words: *"The light and the
environment, which are the next two of the six, and are probably not
measurable the way the camera was. [...] The honest smallest step is the one
section 0 already takes for the camera: assert that the scene HAS them, with
the values it has, so the day one is deleted or switched off a suite says so.
That is a guard, not a measurement, and should be labelled as one (TRAPS 6)."*

Done, and labelled. **And the estimate in that paragraph was wrong in one
place, which is what this commit is about: which way a light POINTS is
arithmetic, exactly as a camera's aim turned out to be in 062, and asking it
found a fault that has been in the scene since the project's first commit.**

**Starting state.** Branch `prototype-002a` at `9144a03` (062). 66 suites,
`--all`, `user://` absent (a fresh container): **suites with something to look
at: 0**, measured here before anything was changed.

### The layer, and what "nothing had ever read it" means exactly

062 could say that the word "camera" appeared in 17 of 65 test files and in
three assertions. This layer is thinner than that. Grepped across `scripts/`
and `tests/`, before this commit:

```
DirectionalLight     0 occurrences in scripts/, 0 in tests/
Light3D              0 occurrences in scripts/, 0 in tests/
WorldEnvironment     0 occurrences in scripts/, 0 in tests/
light_energy         0 occurrences in scripts/, 0 in tests/
ambient              0 occurrences in scripts/, 0 in tests/
```

Not an assertion, not a comment. **Nothing in this project had ever mentioned
the light or the environment at all.**

**The first version of that count said "light appears four times in
`scripts/`, every one inside an unrelated string". It was wrong and is
corrected here rather than quietly fixed (TRAPS 14): the substring appears
EIGHT times** — "slightly" twice, "lightweight", "lightened", "a light
go-kart", "light on your feet", "lighter", and one that is not an accident:

```
circuit_builder.gd:123   # Winding chosen so the road faces up, towards the light.
```

That comment **assumes a light overhead**, and is the one line in the project
that reading the scene would have falsified. It is still true after this
commit, for the first time.

### The fault

`scenes/main.tscn` has had this line since `614a1f5` — Prototype 001, the
project's first commit — and **no commit between then and this one touched
it**:

```
[node name="DirectionalLight3D" type="DirectionalLight3D" parent="."]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, -45, -30, 0)
```

That is an **identity basis** with an **origin of (-45, -30, 0)**. A
`DirectionalLight3D` emits along its own local -Z and is infinitely far away:
**the engine ignores its position entirely**, so its rotation is the whole of
what it does. Read off an instance of the scene, in the tree, before a line
was changed:

| | |
|---|---|
| `rotation_degrees` | **(0, 0, 0)** |
| direction the light travels | **(0, 0, −1)** — horizontal |
| `N·L` for a horizontal surface | **0.000000** — exactly zero |
| `N·L` for a wall facing +Z | 1.000000 |

**The sun pointed along the ground.** Every horizontal surface in Genesis —
the 200 m pad the game starts on, the pad a built world stands on, a track's
road, a farm's zone slabs, a dungeon's room and corridor floors — took **exactly
no direct light**, because a surface whose normal is perpendicular to the
direction the light travels receives none under any diffuse model. The only
surfaces the sun reached were walls facing +Z.

**And the three numbers say what was meant.** `(-45, -30, 0)` in the origin
slots of a node whose position does nothing, on a node whose rotation does
everything, is a rotation written into the wrong field. The fix moves those
same three numbers into the basis and changes nothing else.

### What it cost, stated at the width it is true (TRAPS 15)

**"The screen was black" would be false** and is asserted nowhere. The
`WorldEnvironment`'s `Environment` has `background_mode = SKY` with a
`ProceduralSkyMaterial`, ambient source `BG`, sky contribution `1.00` and
ambient energy `1.000` — so horizontal surfaces were still lit **by the sky**:
flatly, from every direction at once, with no sun term. `shadow_enabled` is
`false` on that light, so there were no shadows to lose either. What the fault
cost is the **directional half** of the lighting, which is the half that makes
a shape read as a shape, and the sun disk the procedural sky draws sat exactly
**on** the horizon rather than above it.

**How much that is worth looking at is a judgement for a pair of eyes and the
harness cannot make it.** See "Human decision needed" below: the angle itself
is the owner's to tune, and `shadow_enabled` is his call too.

### The rule, and where else it holds (TRAPS 11)

The fault is one light with no rotation. The rule it comes from is wider:
**a node whose job is decided by which way it points must have been pointed.**
Two kinds of node in `scenes/main.tscn` do their job by pointing, and the
fault was that one of the two had been given a position and no rotation while
the other had both:

| node | position | rotation |
|---|---|---|
| `Camera3D` | (0, 90, 110) | **(−40, 0, 0)** — set |
| `DirectionalLight3D` | (−45, −30, 0) — **ignored by the engine** | **none** |

So the new suite asks the question of **both classes, enumerated off the
scene**, and a third node of either kind added tomorrow is asked it too. The
other place the rule holds was read off the source rather than asserted: the
two cameras a player rides are built in code and both are pointed at
construction — `car.gd:245` calls `look_at`, `walker.gd:185` sets
`camera.rotation`. Neither was changed.

### Implementation

- **`scenes/main.tscn`** — one line. The light's three numbers moved from the
  origin into a real rotation of `(-45, -30, 0)` degrees.
  **The twelve floats were written by Godot and not by hand**, and that
  mattered: a `.tscn`'s `Transform3D` literal is the **transpose** of the
  basis `Basis.from_euler()` prints, so the hand-ordered version would have
  installed the inverse rotation — and the old line gave no warning, because
  an identity basis is its own transpose. Caught by asking the engine to
  serialize the scene and reading the line it wrote. See TRAPS 61.
- **`tests/scene_light_test.gd`** — new, **26 assertions**, the first file in
  this project to read a light or an environment. Four sections: a labelled
  **guard** that the scene has a sun and a sky and both are switched on; the
  **measurement**, whether the sun can reach a floor at all; the **class**,
  every node whose job is its direction, plus a closure read off the source
  that nothing in `scripts/` makes a light or an environment so the scene's
  are all the game has; and a second reading off the **running game** with a
  world built through the door a player types into.
- **No file in `scripts/` was changed.** Nothing about interpretation,
  validation, construction, measurement, the ledger or the prompt moved.

### Evidence — what was actually run

Godot **4.7.1.stable.official.a13da4feb**, headless, Linux, in a cloud
container with 2 cores. Every run **sequential**, with `user://` cleared
first (TRAPS 50).

- **Baseline at 062, before anything was changed:** 66 suites, `--all`,
  **suites with something to look at: 0**.
- **After:** 67 suites, `--all`, **suites with something to look at: 0**.
  **The lists were diffed and the only difference is ONE ADDED LINE**,
  `scene_light_test`'s. No existing suite's result line moved.
- **THE FULL RUN WAS DONE THREE TIMES**, `user://` moved aside before each so
  no run read another's ledger (TRAPS 50), and **all three are byte-identical
  to each other**. The third was run after the last edit to any file in the
  commit, including the comment corrections, so what is quoted here is a run
  of what is being committed and not of an earlier draft.
- **Run alone, the new suite gives 7 FAILURES BEFORE THE FIX AND 0 AFTER**,
  and takes about a second. The seven are the whole of section 1, the class
  assertion in section 2 and the guard in section 3; **every assertion in
  section 0 passed on the broken scene**, which is what makes it a guard and
  not a measurement.

### Run against broken code before it was believed (TRAPS 51)

Eight deliberate faults, one at a time, each in its own throwaway copy of the
project outside the repository with its own `config/name` so none could share
`user://` with anything. FAIL lines **read**, not counted.

| fault | result |
|---|---|
| 1. the 063 fix reverted | **7** — the whole of section 1, the class assertion, and section 3's guard |
| 2. the light deleted from the scene | **3** — and the assertion count drops 26 → 16, which is why the counts are asserted: an enumeration over no lights would otherwise pass in silence |
| 3. `light_energy` set to 0 | **2** — section 0's energy guard and section 3's |
| 4. the light switched invisible | **3** — `visible`, the ancestor-chain check, and section 3's |
| 5. the `Environment` resource cleared off the `WorldEnvironment` | **1** — and the count drops to 21, the rest of the environment block being skipped |
| 6. the sun rotated to point at the **sky** instead of the ground | **4** — and *"has a rotation at all"* correctly **passes**, which is the measured version of the comment that says the two assertions fail for different reasons |
| 7. `farm_module.gd` builds an `OmniLight3D` of its own | **1** — the closure, naming the file and line |
| 8. the **camera's** rotation deleted in the scene | **1** — the class assertion, naming `Camera3D`. **On the first draft of the suite this was 0.** |

**And fault 8 is worth more than the fix.** The suite's first draft asked
every question of the **running game**, on the reasoning that the light a
player gets is a stronger subject than the light the file describes. It is —
for a light. It is the **weaker** subject for a camera: `_frame_view()` aims
the live camera on every build, so a camera with no rotation in the scene at
all is pointed correctly within a frame of the game starting, and the draft
**reported 0 failures** on it. The fault was still caught in this repository
— `view_frame_test` section 0 holds the scene's camera to being pitched, off
its own fresh instance — but a class assertion that cannot see a missing
rotation is not holding the class. Sections 0 to 2 now read the scene as the
game launches it; section 3 reads the running game, and the two are not
allowed to stand in for each other. Caught by injecting the fault, not by
reading the code. TRAPS 61.

### What the suite asserts, and what it does not

- **Section 0 is a GUARD and says so in the output**, every line prefixed
  `GUARD:`. Those assertions passed on the broken scene and pass on the fixed
  one; none can fail on anything a player types, because nothing a player
  types touches either node. They are there for the day somebody deletes the
  light, zeroes its energy, clears the environment or switches the ambient
  source off — each one property away in the editor, and none of them visible
  to any suite before this file existed (TRAPS 6).
- **Section 1 is a measurement.** It solves the question off the ground pad's
  own up direction rather than off a literal `Vector3.UP`, so if anybody tilts
  the ground the question follows it.
- **One assertion in it is a BAND and is labelled `JUDGEMENT` in the output**:
  that the sun stands between 10° and 80° above the horizon. Those two numbers
  are an opinion about what daylight looks like, not something measured.
- **Section 3 is a guard too**, for the reason section 2's closure gives:
  nothing in `scripts/` makes or writes a light, so no request can move the
  sun. It is one build and one reading rather than a sweep over the three
  world kinds, because the answer does not depend on what was built — three
  kinds would have been three copies of one reading dressed up as three
  measurements.

### Not verified

- **NOTHING WAS RENDERED. No pixel was drawn and no window was opened.** Every
  number in this commit is a transform, a dot product or a property read off a
  resource. **A suite in this container cannot answer "is it lit" and this one
  does not pretend to.** What it answers is "can the sun reach a floor at
  all", which is arithmetic, and the answer was no.
- **WHETHER THE SCENE NOW LOOKS RIGHT IS UNMEASURED AND UNMEASURABLE HERE.**
  That the sun reaches the ground is a fact; that 45° and −30° are good angles
  is not. It is under "Human decision needed".
- **THREE OF 061'S SIX VISUAL DIFFERENCES ARE STILL READ BY NOTHING** — the
  command panel's anchors and the three strings in the scene. 062 measured the
  camera's place and angle; this commit measures the light and the
  environment's state. **Whether the panels cover the world is still not
  asserted**, and still cannot be: a `CanvasLayer`'s `Control`s are laid out
  but never drawn headless. The four `FRAME_*` constants remain asserted to be
  applied consistently, never to be the right numbers.
- **THE ENVIRONMENT IS GUARDED, NOT MEASURED.** That its ambient source is
  `BG` with full sky contribution is read and asserted; that the resulting
  ambient term is bright enough to see a dungeon floor by is not, and is a
  renderer's answer.
- **NO FILE IN `scripts/` CHANGED.** `PROMPT_VERSION` did not move, the prompt
  is byte-identical and `prompt_bounds_test` passed. No model sent anything
  and no request left the container. No world, record or saved file of the
  owner's changed. `docs/GENESIS_BRIEF.md` was not edited.
- **NO BROWSER RAN AND NO WEB EXPORT WAS MADE**, so 057's "Next action" is
  untouched and still the owner's. The web build gets the same scene and
  therefore the same fix, but nothing here verifies that.
- The two cameras a player rides were **read, not asserted**: `car.gd:245`
  points its camera with `look_at` and `walker.gd:185` sets
  `camera.rotation`, so the rule holds there, but only the scene's two
  oriented nodes are held to it by a suite.

### Next action

**The command panel's anchors and the three strings in the scene — the last
of 061's six, and the only part of the visual layer a headless suite has not
been pointed at.** The strings are the cheap half and the same trick as
section 0 here: `TitleLabel`'s text, `InputBox`'s placeholder and
`BuildButton`'s text are set in `scenes/main.tscn` and read by nothing, so a
guard can hold them to being non-empty and to being what the scene says. The
anchors are the harder half, and worth a careful look before any assertion is
written: a `Control`'s `anchors_preset` and `grow_*` flags are state a suite
can read, but `get_rect()` on a laid-out-never-drawn `Control` under a
`CanvasLayer` may or may not be meaningful headless, and **that should be
established by measuring it in a throwaway copy before anything is asserted
off it** — an assertion resting on a rect that is always zero would be TRAPS 6
again. If the rect is real, then the question 062 wrote down as the owner's
becomes partly answerable here after all: whether the panels cover the part of
the frustum a world is framed in.

---

## 062 — the layer nothing could read, and the rule kept at two of its three doors

**Objective.** 061's "Next action", in its own words: *"what in this project
is only ever true on a screen, and what would it take to measure one of them
headless? `camera.look_at_from_position` and `_restore_frame` are arithmetic
and could be asserted without a pixel."* Answer that, and in answering it find
out whether the layer nothing had ever read was in fact correct.

**Starting state.** Branch `prototype-002a` at `b84cfb2` (061). 65 suites,
`--all`, `user://` cleared first: **suites with something to look at: 0**,
measured in this container before anything was changed.

### The layer, and what "nothing could read it" means exactly

`GameController` has two functions that decide what a player sees after a
build:

- `_frame_view(bounds_min, bounds_max)` — pulls the camera back far enough to
  hold the world that was just built, aims it slightly right of and nearer
  than the centre so the panels do not cover the world, and grows the ground
  pad under it. Called at **three** places: after a plan, after a world build,
  and from `show_unrecorded`.
- `_restore_view()` — puts the camera's transform, near and far, and the pad's
  size and position, back to the ones `scenes/main.tscn` has. Called at
  **two**.

**No suite read either.** Grepped across all 65: the word "camera" appears in
**17** of the 65 files, and in exactly **three assertions** — counted, not
remembered:

```
explore_test:78     walker.camera.current             which camera is live
explore_test:117    main.controller.camera.current    which camera is live
player_door_test:374  main.controller.camera != null  that there is one
```

Every other appearance is a comment. **Not one read where a camera is, what it
is aimed at, or what it can see.** That is a whole layer of the game with no
reader — and a layer with no reader does not accumulate no faults, it
accumulates uncounted ones (TRAPS 60).

### The fault, which is the rule kept at two of its three doors (TRAPS 11)

The rule the two functions keep between them is one sentence: **when a request
leaves the world empty, the view goes back to the scene's own camera and the
scene's own 200 m pad.** The paths that empty the world without building
another were enumerated by reading **every call of `_clear_world_node()` in
`game_controller.gd`**, not from memory — six calls, three of which are
followed by a build and a framing, leaving three in the class:

| path | before 062 |
|---|---|
| `CLEAR_WORLD` — `_clear_world()` | restores |
| a sectionless `CREATE_TRACK` — `_build_prototype_ring()` | restores |
| a `PLAN` that fails in **pass 3** — `_execute_plan()` | **did not** |

**Measured in a throwaway copy outside the repository with its own
`config/name` (TRAPS 50), before a line was changed**, with the plan a player
meets first — two worlds and no `"around"`, which `_place()` centres on each
other and then refuses because neither contains the other:

| after | camera | ground pad | world children |
|---|---|---|---|
| a 500 m circuit | (455.2, 528.0, 238.4) | 1452 m at (310, −250) | 1 |
| `CLEAR_WORLD` | (0, 90, 110) — the scene's | 200 m at origin | 0 |
| a sectionless `CREATE_TRACK` | (0, 90, 110) — the scene's | 200 m at origin | 0 |
| **the failed plan** | **(455.2, 528.0, 238.4)** | **1452 m at (310, −250)** | **0** |

A camera and a 1452 m pad still framed on a circuit that is no longer there.
Both farms really do build in pass 3 — the ledger shows two `Farm built`
lines — and the plan fails after the standing world has been cleared for
building.

**040 is the commit about that exact function**, and it fixed the half of this
path that was about the world being destroyed before Genesis knew it could
replace it. It did not see this half, and the reason is not carelessness:
**nothing in the repository could express it.** A missing world is a child
count. A camera left in the wrong place is twelve floats nobody had ever asked
for.

### Implementation

- **`scripts/game_controller.gd`** — one call, `_restore_view()`, inside the
  `if cleared_for_building:` block of `_execute_plan()`. Inside the guard, because
  a plan refused in pass 1 has cleared nothing and its view must **not** be
  put back: that is 040's rule seen from the view's side, and section 3 of the
  new suite asserts both halves.
- **`tests/view_frame_test.gd`** — new, 82 assertions, six sections numbered
  0 to 5. It is the first file in this project to read a camera.

### What the suite asserts, and why each assertion is about a fact

0. **What the controller captured is the scene's own camera and pad**, compared
   against a **freshly instantiated copy of the scene** rather than against
   numbers written in the suite — so the day somebody moves the camera in the
   editor this says what moved, not that a literal is stale. It also asserts
   the live camera has **already moved** by then, which is what makes the
   capture meaningful: `main.gd` shows an unrecorded circuit at startup, and
   that frames the view. And it asserts the scene's camera is **pitched down**,
   at 40.0°, which is the one of 061's six visual differences anything can
   read: the retired stand-in's camera was level.
1. **The framing arithmetic, solved back out of what it set.** `_frame_view`
   sets five things from one centre and one span. The suite solves the span
   back out of the camera's height and the centre back out of its position,
   then asks whether the pad's centre, the pad's size, `near`, `far` and the
   camera's **aim** all agree with them. Every constant comes from
   `GameController`, never retyped (TRAPS 28). Asked of **every command
   `WorldRegistry` knows about**, with an assertion that each one has a sample
   request — so a fourth kind of world cannot be added without this suite
   asking the same question of it (TRAPS 11).
2. **The capability, not the arithmetic**: every corner of the world's real
   footprint — taken off the `VisualInstance3D` AABBs standing in the scene,
   not off any number a module reported — is **inside the camera's frustum**,
   and **on the ground pad**. `Camera3D.is_position_in_frustum()` is a matrix
   multiplication and answers headless.
3. **The class**: each of the three emptying paths, through `_handle_request`,
   each preceded by a real build, with "the view has moved off the scene's
   camera" asserted **first** so that "it went back" can never pass because it
   never left. Plus the complement: a plan refused before it clears leaves the
   world standing **and** its framing untouched.
4. **The class is closed, read off the source.** Six `_clear_world_node()`
   calls, three `_restore_view()`, three `_frame_view(`, counted in
   `game_controller.gd` — **exact counts, not floors**, because the claim is
   that the class has no fourth member and a floor would pass on a path nobody
   had classified (TRAPS 6). Plus: exactly **two** lines in `scripts/` move the
   overhead camera at all.
5. **`/view` comes back to the framed camera**, not to the scene's. A player
   who drives a circuit and stops is looking at the circuit.

### Evidence — what was actually run

Godot 4.7.1 headless on Linux (`4.7.1.stable.official.a13da4feb`), in a cloud
container with 2 cores, every run **sequential** with `user://` cleared first
(TRAPS 50).

- **Baseline at 061**: 65 suites, `--all`, **0 with something to look at**.
- **After**: 66 suites, `--all`, **0 with something to look at**.
- **The lists were diffed.** The only difference is **one added line**,
  `view_frame_test  VIEW FRAME 82 assertions, failures=0`. **No existing
  suite's result line moved.**
- `view_frame_test` was also run alone, before and after the fix: **4
  failures** before, **0** after. It takes **1.0 s** and needs no
  `--fixed-fps`.
- **The full run was done three times and only the third is quoted, which is
  worth writing down rather than tidying away.** The first came back with
  `player_door_test` at one failure — 061's guard catching this commit's
  unused `SCENE_PATH`, below. The second was clean. **The third was needed
  because the second had been spoiled from inside this session:** a single
  suite was run for a quick check while the full run was still going, and
  both share one `user://`, which is TRAPS 50 exactly, committed by the
  session that had just read it. Nothing was believed off that run; it was
  discarded and the whole thing re-run with `user://` cleared. The first and
  third agree line for line but for the added suite.

**And 061's own guard caught this commit's first draft**, which is worth more
than the fix: the new suite carried a `SCENE_PATH` constant, spelled out in
full, that it never used, and `player_door_test`'s enumeration — *"a scene
resource path is written out in this file and nowhere else"* — **failed naming
`view_frame_test.gd`**. Then it failed a **second** time, because the comment
explaining the removal quoted the literal it was about. Both were read off a
run. That is TRAPS 59's replacement doing exactly the job it was written for,
on the first new suite written after it.

### Run against broken code before it was believed (TRAPS 51)

Six deliberate faults, one at a time, each in its own throwaway copy of the
project outside the repository with its own `config/name` so none could share
`user://` with anything, FAIL lines **read** rather than counted.

| fault | result |
|---|---|
| 1. the 062 fix reverted | **4** — the camera, the near/far and the pad on the plan path, and the count of restores in section 4 |
| 2. `FRAME_HEIGHT` 0.80 → 0.08, so the camera barely leaves the ground | **1** — `CREATE_TRACK`'s near-left footprint corner falls out of the frustum. The arithmetic assertions all still pass, correctly: the suite solves the span out of the same constant, so a tuning change is not a fault and only the capability check has an opinion |
| 3. the pad centred 100 m from where the camera is aimed | **4** — all three worlds' "pad is centred where the camera is aimed", and the dungeon falls off the pad's edge |
| 4. `look_at_from_position` replaced by setting `camera.position`, so the camera is placed but never aimed | **4** — all three worlds' aim assertion, at **dot 0.977**, plus section 4's count of lines that move the camera. Worth reading: the camera keeps the scene's 40° pitch, so it is *nearly* right, every position assertion passes, and only the aim catches it |
| 5. the scene's camera levelled to the retired stand-in's `(0, 80, 120)` | **2** — the pitch assertions, and **only** those. The live camera is aimed by `look_at`, so the levelling is invisible until a world is cleared; section 0 is the only thing in this project holding the scene's camera to being pitched at all |
| 6. `_restore_view` puts the transform back but not the near and far planes | **3** — the near/far assertion on all three emptying paths |

### Not verified

- **NOTHING WAS RENDERED. No pixel was drawn and no window opened.** Every
  number here is a transform, a matrix or an AABB.
- **FIVE OF 061'S SIX VISUAL DIFFERENCES ARE STILL UNMEASURED BY ANYTHING** —
  the light, the environment, the panel's anchors and the three strings. This
  commit measures the sixth, the camera's place and angle. **A world inside the
  frustum of a scene with no light in it is a black screen and nothing here
  would notice.**
- **WHETHER THE PANELS COVER THE WORLD IS NOT ASSERTED.** `_frame_view` aims
  right of and nearer than the centre precisely because the command panel
  covers the bottom and the history and metrics panels cover the right. Where
  those panels actually end is a `Control` layout under a `CanvasLayer`, laid
  out but never drawn headless. The suite asserts the world is in the **3D
  frustum**, not that it is in the part of it a player can see. The four
  `FRAME_*` constants are therefore still **unvalidated as a choice**: they are
  asserted to be applied consistently, not to be right.
- **THE FRUSTUM ANSWER IS FOR 1152 × 648**, the size `project.godot`
  configures, set on the root window from the setting. A player who resizes the
  window, and the web build's canvas, are both other aspect ratios and neither
  was measured.
- **NO FILE IN `scripts/` CHANGED EXCEPT `game_controller.gd`**, and in it one
  call inside one existing guard. Nothing about interpretation, validation,
  construction, measurement, the ledger or the prompt moved. `PROMPT_VERSION`
  did not move and `prompt_bounds_test` passed.
- **NO MODEL SENT ANYTHING** and no request left the container. No world,
  record or saved file of the owner's changed. `docs/GENESIS_BRIEF.md` was not
  edited.
- **NO BROWSER RAN AND NO WEB EXPORT WAS MADE**, so 057's "Next action" is
  untouched and still the owner's.
- The fault fixed here is **visible only**. No measurement, record, readback or
  verdict was wrong because of it, and that was checked rather than assumed:
  the full-run lists are identical but for the new line.

### Next action

**The light and the environment, which are the next two of the six, and are
probably not measurable the way the camera was.** A `DirectionalLight3D` at a
rotation and a `WorldEnvironment` with a sky are state a suite can read off the
scene — that much is the same trick as section 0 — but *whether anything is lit*
is a renderer's answer and this container has none. The honest smallest step is
the one section 0 already takes for the camera: assert that the scene **has**
them, with the values it has, so the day one is deleted or switched off a suite
says so. That is a guard, not a measurement, and should be labelled as one
(TRAPS 6).

**And one thing for the owner rather than a task.** The four `FRAME_*`
constants decide whether a built world is hidden behind the panels, and nothing
can check them headless — the panels are laid out but never drawn. That is a
judgement a pair of eyes makes in a second and a harness cannot make at all:
build a 900 m circuit and a two-room dungeon in the editor and say whether each
sits clear of the panels. It is the cheapest piece of the visual layer the
owner can settle and the assistant cannot.

---

## 061 — the stand-in retired, and the floor it had been lending the harness

**Objective.** The task this file named as the next assistant task, in these
words: *"The sixteen `_make_main()` fixtures, asked as a class (TRAPS 11). 060
measured one difference between the hand-built tree and the scene and found it
cost nothing. The others are unmeasured... The cheapest useful end state is
that the suites which only need `main.gd` stood up LOAD THE SCENE instead of
building a stand-in."*

**Starting state.** Branch `prototype-002a` at `7e59fa3` (060). Godot 4.7.1
headless on Linux, `4.7.1.stable.official.a13da4feb`, in a cloud container
with no API key. Baseline **65 suites, `--all`, `user://` cleared first: 0
with something to look at.**

### The differences, enumerated by walking both trees rather than by reading

A throwaway script loaded `scenes/main.tscn`, built the stand-in in the same
process, walked both trees and printed every node path, class, child index and
every property `scripts/` reads off either. **Twelve differences**, and the
list is the script's output and not a reading:

| # | difference | scene | stand-in |
|---|------------|-------|----------|
| 1 | `/DirectionalLight3D` | present | **absent** |
| 2 | `/WorldEnvironment` | present | **absent** |
| 3 | `.../VBoxContainer/TitleLabel` | present | **absent** |
| 4 | `/Ground` class | `StaticBody3D` | `Node3D` |
| 5 | `Ground/CSGBox3D.position` | `(0, 0.5, 0)` — **top at y = 1.00** | `(0, −0.5, 0)` — **top at y = 0.00** |
| 6 | `Ground/CSGBox3D.use_collision` | `false` | **`true`** |
| 7 | `Ground/CSGBox3D.size` | 200 m | 400 m in twelve of the sixteen, 200 m in four |
| 8 | `Camera3D` origin | `(0, 90, 110)` | `(0, 80, 120)` |
| 9 | `Camera3D` basis | pitched 40° down | **identity — level** |
| 10 | `UI/CommandPanel` anchors | bottom-wide (T1 R1 B1) | all zero |
| 11 | `InputBox.placeholder_text`, `BuildButton.text`, `StatusLabel.text` | `"make a race track"`, `"BUILD"`, `"Status: Waiting"` | all `""` |
| 12 | child order | `Ground, Light, Env, Camera3D, UI` / `TitleLabel, InputBox, …` | `Camera3D, Ground, UI` / `InputBox, …` — six nodes at a different index |

Only **two** variants of the stand-in existed across the sixteen files,
hashed rather than compared by eye: they differ from each other in nothing
but #7.

### Decision — retire the stand-in rather than measure twelve differences

060's method was "make the fixture match and run everything", once per
difference. Twelve differences is twelve full runs and leaves the class
standing. The class fix (TRAPS 11) is to stop standing in for a thing the
repository contains: every fixture now loads the scene the game launches.

```gdscript
func _make_main() -> void:
	main = load(str(ProjectSettings.get_setting("application/run/main_scene"))).instantiate()
	get_root().add_child(main)
```

Resolved **through `ProjectSettings` and not by path**, so no suite can end
up holding a scene that is no longer the game's, and so no `.tscn` literal
lives anywhere but `player_door_test`, which is the file that compares the
two.

**And the class was SEVENTEEN suites, not sixteen.** 060's documents and
TRAPS 57 both say sixteen, counted as files with a `_make_main()`.
`session_test` has none: it `extends "res://tests/drive_test.gd"` and
inherits that file's fixture. It was a seventeenth stand-in user and is
converted with the rest, by inheritance. The correction is recorded here
rather than made silently (TRAPS 14).

### Implementation

- **Sixteen files in `tests/`**: `_make_main()`'s 27–30 hand-built lines
  replaced by the two above, with the twelve differences named in a comment
  so the next reader does not have to re-derive them. `session_test` follows
  `drive_test`. **No file in `scripts/` was changed.**
- **`tests/drive_test.gd`**: its **two** readings of a world's node name
  (the class, not one instance — TRAPS 11) now assert **identity** against
  `drivable["node"]`, which is TRAPS 58's own rule and what
  `player_door_test` section 1 already did. 060 left a comment on one of
  them; this removes the reading. The mechanism and the measured alternation
  are kept in the comment (TRAPS 14), not deleted.
  - *"farm is on screen"* read the last child's **name** and asserted it was
    not `"CircuitBuilder"` — which a dummy `@Node3D@N` satisfies as readily
    as a farm does, so it could not tell the state it was about from the
    state it was not (TRAPS 41's shape). It now holds the startup circuit's
    node **by reference** before the farm is built and asserts that node is
    gone and something else stands.
  - *"a track built after a farm replaces it"* asserted `names ==
    ["CircuitBuilder"]`, which passed on the **parity of its own build
    order**. It now asserts that one world stands and that it **is** the node
    the controller will drive.
- **`tests/player_door_test.gd`**: section 0's guard and section 6's
  enumeration both had to be turned round, and **both of 060's sentences
  under them had stopped being true**. See the next heading; that is the part
  of this commit worth reading.

### The two checks that had to be replaced, and why that is the finding

060 wrote two enumerations whose job was to stop a sentence going stale. 061
falsified both sentences, and **only one of the two checks noticed.**

**(a) The one that noticed.** Section 6 asserted *"and N other suites in
`tests/` build that slab WITH collision, which the game's scene does not"*,
with N ≥ 2. After the conversion N is **0** and the assertion **FAILED when
it was run**. That is a check behaving correctly: the fact under it moved and
it said so. It is turned round in place — it now asserts that **no** suite
gives the ground a floor the game has not got, which is the same fact from
the side that still holds and is the better guard, since it fires the day a
new fixture builds one. It is also stated explicitly that this does **not**
mean no suite has a floor: `physics_test` and `behaviour_test` build their
own 4000 m `StaticBody3D` with a real `CollisionShape3D`, deliberately, and
are asserted to still do so.

**(b) The one that did not, and this is TRAPS 59.** Section 0 asserted *"this
is the only file in `tests/` or `scripts/` that names a `.tscn`"*, written to
guard 060's claim that **nothing in this repository had ever loaded
`scenes/main.tscn`**. 061 made that claim false in seventeen files — **and
the assertion would have gone on passing**, because the converted suites
reach the scene through `ProjectSettings` and name no `.tscn` at all. A check
written against the only idiom its author could think of guards that idiom
and not the fact. What replaces it is the invariant 061 establishes:

- **no suite stands `main.gd` up by hand** — nothing in `tests/` puts
  `main.gd` on a node it made itself;
- **every suite that stands it up reaches the scene through
  `application/run/main_scene`**, not by a path of its own;
- and the count is asserted as a **floor**, because an enumeration that
  matched nothing would assert nothing and pass (TRAPS 6).

**And the first draft of those three assertions failed for the reason they
exist.** Both of them read `player_door_test`'s own source, where the strings
being searched for are written out, and reported the suite against itself;
and the `.tscn` version fired on all sixteen converted files because the
*comment* in each names `scenes/main.tscn`. A check that fires on a comment
is checking the wording. Both are fixed — the file skips itself, and the
search is for `res://scenes`, a resource path and not a filename — and the
mistake is recorded in the suite rather than quietly corrected (TRAPS 6, 14).

### What the stand-in's floor had actually been doing — measured, and it was not nothing

060 measured difference #6 one way: it patched all sixteen fixtures to
`use_collision = false` and found the full-run list identical, so **no
suite's answer rested on that floor**. That is still true after 061. But
"no answer moved" is not "nothing moved", and the number that moved is
`drive_test`'s own printed output. On the **banked square** circuit, the one
circuit in the suite where opponents leave the road at all:

| | opponent recoveries | where Green ended |
|---|---|---|
| stand-in, floor top at y = 0 | **21** | `(234, −0.1, 67)` — **resting on it** |
| the game's own scene, no floor | **25** | `(124, −50.2, −320)` — **still falling** |

**Four runs, two a side, each byte-identical to its repeat**, `user://`
cleared before each, the pre-061 side in a throwaway copy with its own
`config/name` (TRAPS 50). The other five circuits are identical line for line
across all four. So the difference is reproducible and it is the floor: **an
opponent car that came off the banked square landed on a slab the game has
not got.** Every opponent still completes its two laps and the suite's
verdict is unchanged.

**And the production code was already right about this**, asserted off the
source rather than assumed: `race_director.gd:225` computes a car's
off-road distance as `maxf(sqrt(best_d), (_points[best].y - pos.y) * 2.0)` —
the vertical drop is counted, and doubled — so a car falling straight down
reads as off the road once it is 8 m below it and is recovered like any
other. The game does not need the floor. The harness had simply been
hiding the fall.

### Evidence — what was actually run

Godot 4.7.1 headless on Linux (`4.7.1.stable.official.a13da4feb`), in a
cloud container, **every run sequential with `user://` cleared first**
(TRAPS 50). The container has 2 cores; nothing was run in parallel with a
measurement except in a copy with its own `config/name`.

- **Baseline at 060:** 65 suites, `--all`, **0 with something to look at**.
- **Each of the seventeen converted suites was run ALONE immediately after
  its own conversion**, with the runner's own `--fixed-fps 120` where the
  runner applies it. All passed.
- **After:** 65 suites, `--all`, **0 with something to look at.** The lists
  were **diffed**: the only difference is **one line**,
  `player_door_test`'s assertion count, **63 → 67**. No other suite's
  result line moved — including all sixteen whose fixture was replaced.
- **`drive_test` was run four more times** for the two measurements that
  needed it: twice on each side of the stand-in change (the banked-square
  numbers above) and twice against a renamed circuit node, once with each
  version of its own assertions (fault 7 below).
- **What the conversion buys, measured rather than argued.** The same
  deliberate fault 060 used — `BuildButton` renamed to `Build` in
  `scenes/main.tscn`, which kills the game at launch on a null at
  `main.gd:100` — run through the **whole runner** on both sides, each in a
  throwaway copy outside the repository with its own `config/name`:

  | | suites with something to look at |
  |---|---|
  | pre-061 code (`7e59fa3`) | **1 of 65** — `player_door_test` alone, the file 060 added |
  | 061 code | **18 of 65** |

  Each of the eighteen reports the same line: `SCRIPT ERROR: Invalid access
  to property or key 'pressed' on a base object of type 'null instance'`.
  The eighteen are the sixteen converted files, `session_test` by
  inheritance, and `player_door_test`. **Note what that number is and what
  it is not:** the game dying at launch is caught by 18 suites instead of 1,
  which is worth having, but 1 was already enough to catch it. The reason
  for the conversion is the other direction — those seventeen suites now
  measure what they measure **against the tree the game has** — and the
  honest summary of that is the diff above: no answer any of them gives
  changed, and now none of them rests on a stand-in.

  **Their own `failures=` count says 0 under this fault**, because the error
  is thrown in `main.gd`'s `_ready` and the suite carries on past it. What
  reports the fault is `run_tests.sh`'s own `SCRIPT ERROR` branch, which is
  checked before the result line and counted. Read as a suite count, not as
  an assertion count.

### Not verified

- **Nothing was rendered on a screen.** Headless: the scene loads and its
  nodes exist; no pixel was drawn and no window opened. Differences #1, #2,
  #8, #9, #10 and #11 — the light, the environment, the camera's place and
  angle, the panel's anchors and the three strings — are **visual, and
  nothing here measures them.** What 061 establishes about them is only that
  the suites now stand up the tree that has them.
- **No model sent anything and no request left the container.** The prompt is
  byte-identical and `PROMPT_VERSION` did not move; `prompt_bounds_test`
  holds that and passed.
- **No file in `scripts/` was changed**, so nothing a player can reach
  behaves differently. The ground slab a metre lower in the harness (#5), the
  missing `TitleLabel` (#3) and the child order (#12) are gone from the
  harness, not from the game, where they were never wrong.
- **No world, record or saved file of the owner's changed.**
- **Whether a MOUSE CLICK emits `pressed`** is still Godot's and still
  unheld, as are a player DRIVING to the checkpoints and the second emit of
  `race.announced`. 060's limitations are unchanged.
- **The `use_collision` measurement is 060's, re-stated and extended, not
  re-run.** What 061 ran is the four drive_test runs above.
- **No browser ran and no web export was made**, so 057's "Next action" is
  untouched and still the owner's.

### Run against broken code before it was believed (TRAPS 51)

Deliberate faults, one at a time, each in a throwaway copy of the project
outside the repository with its own `config/name` so it could not share
`user://` with anything, FAIL lines **read** rather than counted.

| fault | result |
|-------|--------|
| 1. `ledger_test` put back to hand-building a stand-in | **4 failures** in `player_door_test`, naming `ledger_test.gd` in three of them: the hand-built check, the setting check, the count, and section 6's collision check |
| 2. `ledger_test` loads the scene by `"res://scenes/main.tscn"` instead of the setting | **3** — the setting check, the count, and the resource-path check |
| 3. `BuildButton` renamed in the scene | **18 of 65 suites** report a SCRIPT ERROR, against **1 of 65** on the pre-061 code. Full-runner measurement, both sides |
| 4. section 0's first draft, reading its own source | **2**, naming `player_door_test.gd` itself and all sixteen converted files. This is a real mistake that was caught by running it, not by review, and it is recorded in the suite (TRAPS 6) |
| 5. section 6's 060 assertion left as it was | **1** — `with_collision.size() >= 2` against a count of 0. The check that noticed its own fact had moved |
| 6. `_clear_world_node` never frees the outgoing world | **10** in `drive_test`, the first two being the new identity assertions, naming **63 standing** and **64 standing** |
| 7. `RacingModule` names the circuit `"Circuit"` instead of `"CircuitBuilder"` | **see the table below** — this is the one that shows what the identity change buys |

Faults 4 and 5 are not injected faults: they are what the suite did when it
was first run, and they are listed here because they are the evidence that
these assertions can fail at all.

**Fault 7 is the measurement behind the `drive_test` change, and it is run
both ways.** Nothing in `scripts/` reads a world's node name — asserted off
the source by `player_door_test`, not assumed — so renaming the node breaks
nothing a player can reach. The same fault, the same copy, the only
difference being which version of `drive_test` is in it:

| `drive_test` | result |
|---|---|
| pre-061 (`7e59fa3`) | **1 failure**: `a track built after a farm replaces it (on screen: ["Circuit"])` |
| 061 | **0 failures** |

A false alarm, in other words, on a change that costs nothing — which is
what an assertion about wording does. **And note it is 1 and not 2:** the
other name-reading line, *"the last child is not called CircuitBuilder"*,
passes on `"Circuit"` as readily as on a dummy or a farm, which is the
weakness TRAPS 41 describes and the reason both lines were changed and not
just the one 060 commented on (TRAPS 11).

### Next action

**The twelve differences that are visual, and nothing in this repository can
see any of them.** 061 removed the stand-in, so the suites now stand up a
tree with a light, an environment, a 40°-pitched camera, an anchored panel
and three strings in it — and asserts nothing about any of them, because the
harness is headless. Six of the twelve differences in the table above are in
that class. The question to ask is not "does the fixture match" any more, it
is **what in this project is only ever true on a screen, and what would it
take to measure one of them headless?** `camera.look_at_from_position` and
`_restore_frame` are arithmetic and could be asserted without a pixel: the
controller captures `original_camera_transform` from the scene, and since 061
that is the game's pitched camera rather than a level stand-in, so a
`/view`-and-return assertion would now be about the real thing. That is the
smallest useful end of it.

**And one number for the owner to look at rather than a task.**
`docs/GENESIS_BRIEF.md:150`, under "Known rough edges", says banked corners
*"act as ramps and throw cars over the barrier: about 23 opponent recoveries
per race on a banked square"*. **That sentence is not falsified** — 061
measured **21** on the stand-in and **25** against the game's own scene, and
"about 23" covers both, which is said plainly because the opposite would have
been the easier thing to write. What 061 adds is where the number came from:
any such figure taken before this commit was taken in a harness whose ground
was a floor, and the scene's number on the same circuit is **25**. The brief
was **not edited** — it is a document the owner publishes, and nothing in
this commit touches what the public sees.

---

## 060 — the four doors, and the scene no test had ever loaded

**Objective.** The task this file named as the next assistant task: **hold
the four `connect()` rows of `main.gd` that 059 measured and found held by
nothing** — `lap_completed` (93), race `announced` (98), `pressed` (100) and
`text_submitted` (101). All four need no API key. The last two are the doors
a player actually uses, and 059's words for the gap were: *"nothing in the
project emits either signal, grepped, so every suite enters at
`_handle_request()` and the suite says nothing about whether typing a
sentence and pressing Build reaches the game at all."*

**Starting state.** Branch `prototype-002a` at `c4aa7fb` (059). 64 suites,
`--all`, `user://` cleared first: **0 with something to look at**.

### What was done, and it is one new file

`tests/player_door_test.gd`, **63 assertions**. **No file in `scripts/` was
changed.** The only other edit in the commit is a comment in `drive_test`
(see TRAPS 58). Nothing a player can reach behaves differently.

All four rows are held through a **real emit**. Nothing is hand-emitted into
a handler:

| line | signal → handler | how it is reached |
|------|------------------|-------------------|
| 100 | `pressed` → `_on_build_pressed` | the real `Button`'s signal, with a raw-JSON circuit in the real box; a 4×300 m circuit is built, recorded and drivable |
| 101 | `text_submitted` → `_on_text_submitted` | the real `LineEdit`'s signal; a 4×400 m circuit is built over the first |
| 93 | `lap_completed` → `_on_lap_completed` | the car's own position moved along the circuit's checkpoints, with **`main.gd:809` — the only production caller of `update_progress()`, grepped — doing the feeding from `_process`** |
| 98 | `announced` → `_on_race_announced` | a real `/race 1` and **361 physics frames of real countdown**, until `RaceDirector._physics_process` says `"GO!"` |

### THE FINDING: nothing in this repository had ever loaded `scenes/main.tscn`

Grepped across `tests/` and `scripts/`: **no file mentioned a `.tscn` at
all.** The scene is reached only by `project.godot`'s `run/main_scene`, by
uid — which is to say only by the game. Sixteen suites that need `main.gd`
build their own tree by hand in a `_make_main()` of their own, and **name
each node exactly what `main.gd`'s `@onready` lines ask for**. The fixture
supplies the names and the suite then proves they are there. That is TRAPS 14
in a fixture rather than in a document.

**The class, enumerated off the source rather than listed (TRAPS 11): six
node paths.**

| where | path | type |
|-------|------|------|
| `main.gd:20` | `$UI/CommandPanel/VBoxContainer/InputBox` | `LineEdit` |
| `main.gd:21` | `$UI/CommandPanel/VBoxContainer/BuildButton` | `Button` |
| `main.gd:22` | `$UI/CommandPanel/VBoxContainer/StatusLabel` | `Label` |
| `main.gd:23` | `$UI` | `CanvasLayer` |
| `game_controller.gd:129` | `Camera3D`, off `world_root` | `Camera3D` |
| `game_controller.gd:135` | `Ground/CSGBox3D`, off `world_root` | `CSGBox3D` |

**What that cost, measured and not argued.** In a throwaway copy,
`BuildButton` renamed to `Build` in the scene: `main.gd:100` throws *"Invalid
access to property or key 'pressed' on a base object of type 'null
instance'"* — the game dead at launch — and **before this commit every one of
the 64 suites was still green**, because every one of them built the tree it
wanted. `Ground` renamed to `Floor`: no crash at all, the controller's
`get_node_or_null` returns null and the game runs on with no camera framing
and no ground pad, silently.

`player_door_test` is **the first file in the project's history to load that
scene**. It asserts the scene is the one `ProjectSettings` launches before it
asserts anything about it; it **enumerates** the four `@onready` paths and
the two `get_node_or_null` literals out of the scripts' own source and
resolves each against the loaded scene, so a seventh path is covered the day
it is written; and it asserts that it is still the only file naming a `.tscn`,
so the sentence above cannot go stale unnoticed (TRAPS 14). See TRAPS 57.

### The fixture's floor, and what it costs: nothing, measured

Sixteen files in `tests/` set `box.use_collision = true` on the ground slab
they build. **Nothing in `scripts/` sets `use_collision` anywhere**, and the
real scene's `Ground` is a `StaticBody3D` with **no `CollisionShape3D`** and
a `CSGBox3D` with `use_collision` left at its default `false`. A 1 m
`RigidBody3D` dropped from y = 6 over cleared ground, 400 physics frames:

| | came to rest at |
|---|---|
| the real scene | **y = −42.77, and still falling** |
| the fixture | **y = 0.49, on top of the slab** |

So the harness has a floor the game does not. **What it costs today is
nothing.** All sixteen fixtures were patched to `use_collision = false` in
that throwaway copy and every suite was run again, `--all`, `user://` cleared
first: **64 suites, 0 with something to look at, and the list diffed against
the baseline is IDENTICAL, line for line.** No suite's answer rests on that
floor, and this file does not claim one does.

**An earlier draft of the suite header said something false here** and it is
recorded rather than deleted (TRAPS 14): *"every suite that has ever stood a
body on the ground has stood it on a floor the game does not have"*. The two
suites that really do stand a body on a floor — `physics_test` and
`behaviour_test` — build their own 4000 m `StaticBody3D` with a real
`CollisionShape3D` and were not touched by that patch at all.

Section 6 holds the scene's half of it as a fact, so that the day somebody
turns collision on in the scene this suite says so: sixteen fixtures are
already written as though it is on.

### Two of the suite's own assertions were false about Genesis

Both passed review by reading and both failed when run (TRAPS 6, TRAPS 14).

**(a) The name of the node a world is built into is not the world's.** The
assertion read the standing node's **name** and expected `CircuitBuilder`, as
`drive_test:174` asserts. It is `@Node3D@49`. `RacingModule.build()` sets
`circuit.name` and **then** calls `root.add_child()`; Godot replaces the name
of a node that collides with a **sibling**, and the outgoing world is still a
sibling in that frame — `queue_free()` does not remove it until the frame
ends, **the same fact 048 found underneath a count that said fourteen rooms**.
So the name **alternates**, which is more than "the first build is wrong",
the reading made before measuring:

| build | name | why |
|-------|------|-----|
| startup circuit | `CircuitBuilder` | nothing there to collide with |
| 1 | `@Node3D@49` | the startup circuit still held it |
| 2 | `CircuitBuilder` | the outgoing one was `@Node3D@49` |
| 3 | `@Node3D@124` | the outgoing one held it again |

Nothing a player can reach is wrong, **asserted rather than assumed**: no
file in `scripts/` contains `"CircuitBuilder"` except the module that assigns
it, so no production code identifies a world by name — the controller holds
`drivable["node"]` by reference, and section 1 now asserts identity rather
than name. **And the obvious fix does not fix it, measured:** moving the
assignment to after `add_child` yields `CircuitBuilder2`. Left unfixed on
purpose: "Human decision needed" 24, and TRAPS 58.

**(b) A raw-JSON request is never an edit.** The assertion expected a
`Changed: length` line in the history after a second world was built over the
first, on the reasoning that `_handle_request` sets `editing_from` and the
play loop reports the difference. It does not: **`main.gd:190` calls
`_execute_json` and RETURNS**, eight lines before `main.gd:199-201` sets
`editing_from` from the standing world. So the player who debugs with raw
JSON is never told what changed; only the AI door gets that sentence.
`drive_test` sets `main.editing_from` by hand before `_type()` for exactly
this reason, which is the repository already knowing this without anywhere
saying so. The suite now asserts the fact. "Human decision needed" 25.

### Evidence — what was actually run

Godot 4.7.1 headless on Linux (`4.7.1.stable.official.a13da4feb`), in a cloud
container, **every run sequential with `user://` cleared first** (TRAPS 50).

- **Baseline at 059:** 64 suites, `--all`, **0 with something to look at**.
- **After:** 65 suites, `--all`, **0 with something to look at**. The lists
  were **diffed** and the only difference is **one added line**,
  `player_door_test`'s. No existing suite's result line moved.
- `tests/player_door_test.gd`, **63 assertions**, about 4 s, of which 3 s is
  the RaceDirector's real countdown. Needs no `--fixed-fps`: both runners'
  lists and patterns were **RUN** against the name rather than eyeballed
  (TRAPS 4) and neither matches it, so **neither runner was edited**.
- **The fixture-floor measurement:** sixteen fixtures patched to match the
  scene, full run, list **diffed identical**.

**Run against broken code before it was believed (TRAPS 51): ELEVEN
deliberate faults, one at a time**, each in a fresh throwaway copy outside
the repository with its own `config/name`, FAIL lines **read** rather than
counted.

| fault | result |
|-------|--------|
| 1. `build_button.pressed.connect` wired out | 10 failures — the whole BUILD section, plus the three in section 7, because one fewer build shifts the name parity (see below) |
| 2. `input_box.text_submitted.connect` wired out | 6 — the RETURN section, the guard, and one in section 7 |
| 3. `lap_completed.connect` wired out | **1** — the lap sentence, and nothing else |
| 4. `race.announced.connect` wired out | 2 — the announcement never arrives; the loop runs to its 3600-frame limit |
| 5. `main.gd:809` `update_progress` removed from `_process` | 3 — no lap is counted at all; this is the production caller, not the connect |
| 6. `_on_lap_completed` reports a fixed `"1:23.45"` | **1** — the assertion is built from the tracker's own numbers through its own formatter |
| 7. `_on_text_submitted` trusts the signal argument | **1** — the guard, and only the guard |
| 8. scene: `BuildButton` renamed to `Build` | SCRIPT ERROR at `main.gd:100`; the suite reaches only **36** of its 63 assertions and fails 10 |
| 9. scene: `Ground` renamed to `Floor` | 3, including the enumerated path assertion. **This one found a fault in the suite**: its first draft read `.size` off a null `ground_box` and threw, aborting instead of reporting. Guarded now |
| 10. scene: the ground given collision, as the fixtures have it | **1** — section 6 |
| 11. `RacingModule` names the circuit AFTER `add_child` | 2, and the name it gets is `CircuitBuilder2` — which is how "the obvious fix" above was measured rather than assumed |

**Faults 1 and 2 are one fault reading as several, and the numbers are given
rather than hidden (TRAPS 55).** Section 7's three assertions read the
sequence of world-node names across the three builds, so a door wire-out
removes a build and shifts the parity. That is not three faults; it is the
section being downstream of the doors, which is also the only way the
sequence can be measured at all.

### What the suite does NOT prove

- **That a mouse click emits `pressed`, or a RETURN key `text_submitted`.**
  Those are Godot's. What is held is everything from the signal inwards, in
  the real scene.
- **That a player DRIVING reaches the checkpoints.** The car's position is
  set; nothing steers it. The driving loop is `drive_test`'s business.
- **The other emit of `race.announced`** — the result line in
  `RaceDirector._finish()`. It needs three full laps driven by somebody, and
  nobody drives in a headless run. Only the countdown's `"GO!"` is walked.
- **Anything rendered.** Headless: the scene loads, its nodes exist, no pixel
  was drawn and no window opened.
- **No model sent anything and no request left the container.** The prompt is
  byte-identical and `PROMPT_VERSION` did not move; `prompt_bounds_test`
  holds that and passed.
- **No world, record or saved file of the owner's changed.**
- **The fifteen other `_make_main()` fixtures are still not the scene**, and
  only one of their differences has been measured. That is the next task.

### Next action

**The sixteen `_make_main()` fixtures, asked as a class (TRAPS 11).** 060
measured one difference between the hand-built tree and the scene and found
it cost nothing. The others are unmeasured and they are visible by eye
already: the scene has a `TitleLabel`, a `DirectionalLight3D`, a
`WorldEnvironment` and an anchored `CommandPanel` that no fixture builds, and
its `Ground` is a `StaticBody3D` where fourteen fixtures use a bare `Node3D`.
The method is the one that worked here: diff one fixture against the scene
node by node rather than reading either, then for each difference make the
fixture match and run everything. The cheapest useful end state is that the
suites which only need `main.gd` stood up **load the scene** instead of
building a stand-in — but that is sixteen files and should be measured one at
a time, not swept.

---

## 059 — the id two writers could both mint, found while measuring something else

HANDOVER named this session's task as **the seven `connect()` rows of
`main.gd`'s sixteen still marked `NOT_ASKED`**. They were measured and the
answers are below. But the measurement produced a result that could not be
true, and chasing that is what this commit is about.

### The seven rows, measured (the assigned task)

Same method as 057 and 058: one `connect()` commented out at a time in a
throwaway copy **outside** the repository with its **own `config/name`** so
it could not share `user://` with anything (TRAPS 50), every suite run with
`--all`, the result lines **diffed** against a baseline taken the same way,
every run sequential with `user://` cleared first. The sites were enumerated
by grepping `.connect(` in `main.gd`, not copied from this file.

| # | line | signal → handler | verdict |
|---|------|------------------|---------|
| 9 | 83 | `door_changed` → `_on_door_changed` | **HELD** — `interference_test`, 3 failures |
| 10 | 88 | experiment `progress` | **NOT HELD — needs a key** (TRAPS 52) |
| 11 | 89 | experiment `finished` | **NOT HELD — needs a key** (TRAPS 52) |
| 12 | 93 | `lap_completed` → `_on_lap_completed` | **NOT HELD — and reachable with no key** |
| 13 | 98 | race `announced` → `_on_race_announced` | **NOT HELD — and reachable with no key** |
| 14 | 100 | `pressed` → `_on_build_pressed` | **NOT HELD — and reachable with no key** |
| 15 | 101 | `text_submitted` → `_on_text_submitted` | **NOT HELD — and reachable with no key** |

**All sixteen rows are now measured.** The sweep that 057 began is finished.

- **`door_changed` (83) is HELD, and held by the right assertion.** This
  file predicted it was "the interesting one" and the session writing this
  predicted from the code that nothing held it. **Both were wrong, and the
  measurement is what says so.** `interference_test` fails **3** with the
  wire out, and the assertion that catches it is
  `interference_test.gd:135` — *"and a real door stands in the corridor"*,
  which looks for the physical slab. The handler calls
  `controller.rebuild_standing_world()`, and `DungeonModule`'s own comment
  at line 1197 says why that matters: *"a shut door is a slab across the
  corridor, with collision, so it stops a body the way a wall does rather
  than by rule."* Wire it out and `route()` still refuses to path through a
  shut door, because it reads `is_shut()` straight off the layout — so the
  door is enforced **by rule and not by geometry**, which is exactly what
  018 built the slab to avoid. One suite noticed. **Note what did NOT
  notice**: `controller_reach_test.gd:699` sends a `SHUT` and asserts
  *"after a SHUT rebuilds the world, every thing still has a node"* — and
  that passes **more** easily with the wire out, because nothing is freed
  and rebuilt at all. It is TRAPS 54's shape: an assertion written to catch
  a rebuild destroying things cannot tell a rebuild that happened from one
  that never did.
- **The two experiment rows (88, 89) need a key, and that is a fact about
  one guard rather than a judgement.** `ExperimentRunner.start()` returns
  *"No API key, so the experiment cannot run."* at its third line when
  `_interpreter.is_available()` answers false, which is the real state of
  this container. Nothing downstream ever runs, so **neither handler can be
  reached by any suite here and neither was faked** (TRAPS 52). `progress`
  has an emit at the top of `_next()` that needs no key in itself, and
  `_next()` is reachable only through `start()`, so getting to it means
  setting `running` by hand — a gate set by hand, which is the thing 056 did
  and labelled.
- **The four remaining rows are held by nothing and all four are reachable
  with no key**, which is the useful half of the answer and is the next task.
  `lap_completed` is the cheapest of the four: `update_progress()` is pure
  geometry (`checkpoint_tracker.gd:40`), so walking positions past the
  twelve checkpoints in order emits the real signal with nothing faked.
  `announced` emits *"GO!"* from `_physics_process` once the countdown
  elapses. **And `pressed` and `text_submitted` are the two doors a player
  actually uses** — nothing in the project emits either signal, grepped
  across `tests/` and `scripts/`; every suite calls `_handle_request()`
  directly. So all sixteen connects could be measured and the suite still
  says nothing about whether typing a sentence and pressing Build ever
  reaches the game. Both handlers read `input_box.text` rather than the
  signal's argument, so they are one behaviour at two doors.

### The result that could not be true, which is the commit

`intent_door_test` failed **8, 8, 7 and 8** under the four wire-outs for
experiment `progress`, experiment `finished`, `lap_completed` and
`pressed` — **none of which that suite mentions**; it has no reference to an
experiment, a lap or a button — and failed **nothing** under `door_changed`,
`race_announced`, `text_submitted` or a **pristine control run of the same
copy**, which was taken and is identical to the baseline line for line.

That is TRAPS 50's signature. The varying count settles it: a wire-out does
not fail a different number of assertions each time.

**THE CAUSE.** `TrackLog.next_id()` was `"<unix seconds>-<serial>"`, and
`serial` is a static that restarts at 0 in every process. Two processes
writing to one `user://track_log.jsonl` therefore mint **the same ids**
whenever they overlap inside one wall-clock second. Measured, not inferred:
two Godot processes, three records each, one ledger, twelve paired runs —
**every id collided in eight of the twelve**. The four that did not were
pairs that straddled a second boundary.

`intent_door_test._record_for()` returns the **first** match in the file, so
when the suite that runs immediately before it had already written that id,
the lookup returned **that suite's record** and the assertions about this
suite's own request failed. One ledger with two writers is the normal state
of this repository, not an edge case: every copy shares one `user://`
(TRAPS 50) and `run_tests.sh` starts sixty-odd processes against it a
fraction of a second apart.

**WHAT IT COST BEYOND THE HARNESS**, read off the readers rather than
guessed. The id is the only thing tying a later record to an earlier one:

- `session_report._understanding()` keys evidence by id, so of two records
  sharing one, the report attributes **one's understanding verdict to the
  other** — a true-looking score about the wrong request, in the artefact
  this project exists to keep.
- `game_controller.gd:420` writes a delivery's evidence as
  `"about": <the order's id>`, so a duplicate makes the proof of a delivery
  point at two orders.
- Five suites and `session_report` scan for an id and take the first match.
  None of them says anything when there are two.

**AND IT INVALIDATES PART OF THE METHOD THIS PROJECT MEASURES WITH, which is
said here rather than left for somebody to find (TRAPS 14).** Every commit
since 055 reports *"the lists were diffed and are identical"*. Those diffs
were taken with a suite in them that can fail this way in roughly two runs
out of three. **The claims were true of the runs they describe; the
instrument had a coin flip in it.** Nothing in 055–058 is withdrawn on this
account — their wire-out answers were read off `--all` lists whose other 62
lines were stable — but the confidence attached to "identical, line for
line" was higher than the method earned.

### What changed

**One function, `scripts/track_log.gd`.** The writer's own identity is now in
the id, so no clock granularity can make two processes agree:

```gdscript
return "%d-%d-%d" % [Time.get_unix_time_from_system(), OS.get_process_id(), serial]
```

`OS.get_process_id()` rather than a random salt because it **names** the
writer: a collision is impossible and a record now also says which process
wrote it. **Nothing parses this string** — grepped across `scripts/` and
`tests/`; every consumer compares it whole, and no test asserts its shape —
so widening it breaks no reader.

**THE CLASS, NOT THE ONE THAT BROKE (TRAPS 11), AND THE LIST IS NOT
CLOSED.** The rule is: *an identifier that has to tell one writer's records
from another's must carry something only that writer has; a clock does not
qualify at any granularity.* Asked of every identifier Genesis mints from a
wall-clock time, grepped rather than remembered, the class is **three**:

| identifier | where | state |
|---|---|---|
| record id | `track_log.gd:59` | **FIXED in 059** |
| session id — tester's name + a second | `main.gd:514-515` | **SAME CLASS, NOT FIXED** |
| experiment `run_id` — a second and nothing else | `experiment_runner.gd:62` | **SAME CLASS, NOT FIXED** |

The two left are lower risk and neither is a guess: the session id also
carries the tester's **name**, so it collides only for two writers using the
same name in the same second, and `run_id` needs a key so nothing here can
reach it. **They are left deliberately and named as the next task rather
than quietly fixed**, because the session id appears in session reports the
owner already has and changing its shape is a change to an artefact of his.
**`ledger_audit_test.gd:111` already salts its session name with
`Time.get_ticks_msec()`** — somebody met this once and defended one call
site against it.

### Evidence — what was actually run

Godot 4.7.1 headless on Linux (`4.7.1.stable.official.a13da4feb`), in a
cloud container, every run **sequential** with `user://` cleared first
(TRAPS 50).

- **Baseline at 058: 63 suites, `--all`, 0 with something to look at.**
- **After: 64 suites, `--all`, 0 with something to look at.** The lists were
  **diffed** and the only difference is **one added line**, the new suite's;
  no existing suite's result line moved.
- `tests/record_id_test.gd`, **12 assertions**. It steps no physics and
  needed no entry in either runner's fixed-rate list.
- **The fix was measured against the thing it fixes, in both directions.**
  The paired-process experiment was re-run on the fixed code: **12 of 12
  pairs landed in the same wall-clock second — the exact condition in which
  the old code collided every time — and 0 collided.** Old code: 8 of 12.
  New code: 0 of 12, with the condition present in all twelve.
- **AND THE ORIGINAL FAILURE WAS REPRODUCED RATHER THAN INFERRED**, which is
  the part that turns a plausible story into a cause. The suite pair that
  produces it is `handler_wiring_test` then `intent_door_test` — the two
  that run back to back in a full run — against one `user://`, repeated ten
  times:
  - **Pre-059 code: 1 of 10 pairs failed, and it failed EIGHT**, the exact
    count seen four times during the sweep. That run had **13** ids written
    by both processes; the nine passing runs had **1**.
  - **Fixed code: 0 of 10 pairs failed**, and in every one of the ten the
    shared ledger genuinely held records from **two distinct writers**, so
    the condition was present each time.
  **1 in 10 here against 8 in 12 in the minting experiment, and the
  difference is honest rather than awkward**: the minting pair writes three
  records in a few milliseconds, so almost all of them share a second,
  while these two suites run for seconds apiece and most of their ids land
  in different seconds. The rate depends on the overlap; the mechanism does
  not.

**IT WAS RUN AGAINST BROKEN CODE BEFORE IT WAS BELIEVED (TRAPS 51):** five
deliberate faults, one at a time, in a throwaway copy with its own
`config/name`, and the **FAIL lines READ rather than counted**.

1. the pre-059 id restored, two fields — **2 failures**, and only 10 of the
   12 assertions run, because two sit behind the three-field check. Recorded
   that way rather than as "2 of 12".
2. three fields but the writer component a constant `0` — **1 failure**, and
   it is the one that matters: this is the regression that would pass a
   shape check and silently restore the collision.
3. `append()` overwriting an id the caller set — **1**.
4. `append()` never assigning an id — **2**.
5. `serial` not incrementing — **2**.

### And the first draft of the new suite asserted something false

Said here rather than quietly corrected, because it is the same shape as
058's panel assertion and it was caught the same way — by running it
(TRAPS 6, TRAPS 14).

The suite's first draft asserted **"no two records in the ledger share an
id"**. It passed alone and **failed in a full run, on 2 of 22 ids**. Reading
the records rather than the count: **a `PLAN` request writes THREE records
under ONE id** — the plan's own and one per world it builds — because they
are all the same request. It is deliberate and has been since `PLAN`
existed, and `intent_door_test._plan_record()` exists precisely because an
id alone cannot tell those three apart.

So the assertion was a claim about Genesis that is **simply untrue**, and it
would have gone red for an honest reason while saying nothing about the
fault the file is for. The invariant that was actually broken is narrower
and is what the file now asserts: **two records written by different
PROCESSES must never share an id.** Within one process, sharing one is by
design.

**The corrected form is stronger against the fault, not weaker**: wiring the
pre-059 id back now scores **2** failures rather than 1, because the ids it
writes name no writer and the suite says so.

### What the tests do NOT prove

- **That two real OS processes never collide is NOT asserted by any suite.**
  Asserting it needs a second process, which would be this project's first
  suite to spawn one, and a test that races a clock passes or fails on where
  the second boundary falls — which is the fault, not a test for it. What
  stands in its place is the 8-of-12 and 0-of-12 counts above, taken by
  hand, and one structural assertion: two processes have two process ids.
- **Nothing was rendered on a screen.** No pixel was drawn and no window
  opened.
- **No model sent anything and no request left the container.** The prompt is
  byte-identical and `PROMPT_VERSION` did not move; `prompt_bounds_test`
  holds that and passed.
- **No world, record or saved file of the owner's changes.** Records written
  from now on carry a wider id; **existing records are untouched** and every
  reader compares ids whole, so old and new sit in one ledger without
  interpreting each other.
- **The four unheld connect rows are still held by nothing.** 059 added no
  fixture for them; it added one for the ledger's ids.
- **Two of the three members of the id class are not fixed**, as above.


## 058 — the three handlers a harness can hold, and the two it cannot

HANDOVER named this as the next assistant task, in these words: *"a fixture
for `_on_interpretation_failed`, which needs no key and fakes nothing"*. It
came out of 057's sweep, which asked of each of `main.gd`'s sixteen
`connect()` calls — *if this wiring stopped working tomorrow, would any suite
say so?* — and found **five** of the seven it measured held by **nothing**.

**THE FILE DOES THE CLASS AND NOT THE ONE NAMED (TRAPS 11).** Fixing one
member of a list is not fixing the list. Asked of all five, the split is
**three and two**, and it is a fact about where the emits are rather than a
judgement:

| handler | signal | 057 | now |
|---|---|---|---|
| `_on_interpretation_failed` | `interpretation_failed` | NOT HELD | **HELD**, two reasons through two guards |
| `_on_track_measured` | `track_measured` | NOT HELD | **HELD**, a build and a refusal, line for line |
| `_on_equipped` | `equipped` | NOT HELD | **HELD**, a body already standing |
| `_on_interpretation_ready` | `interpretation_ready` | NOT HELD | **STILL NOT HELD** — needs a key |
| `_on_ai_retrying` | `retrying` | NOT HELD | **STILL NOT HELD** — needs a key |

`tests/handler_wiring_test.gd`, 47 assertions. **No file in `scripts/` was
changed.** Nothing a player can reach behaves differently after this commit
than before it.

### Why two are left unheld, and why that is a fact rather than a shrug

Mapped off `ai_interpreter.gd`'s own source rather than remembered:
`interpretation_ready` has **one** emit and it is inside
`_on_request_completed`; `retrying` has **one** and it is inside
`_try_again`, which `_on_request_completed` calls. Both need an answer from
the model, which needs a key. `interpretation_failed` has **eleven**, and
**two of them are in `_send()`**, before anything is posted. That asymmetry
is the whole reason one of the three is holdable, so the suite **asserts it
mechanically off the source**: the day someone adds a key-free emit of
either, the suite says a fixture has become possible. Run against a
deliberately added `interpretation_ready.emit()` in `_send()`, that assertion
fails and names the function.

For those two, the suite asserts the **connect** and nothing else, labelled
`WIRE ONLY` in the assertion's own text, so nobody reads it as more than it
is. TRAPS 52's shape, left as 052 and 057 left it rather than faked.

### HANDOVER's "fakes nothing" was nearly true, and the gap is the interesting part

- **`main._handle_request()` cannot reach `interpret()` with no key.** It
  refuses at `main.gd:193-195` — `is_available()` answering false — so the
  no-key door is entered **one level in**, at `interpreter.interpret()`,
  exactly as `check_wiring_test._send_as_ai()` enters at `_execute_json()`.
  `pending_request` is set first because that is the one thing
  `_handle_request` would have done on the way past (`main.gd:181`).
  Everything after is real: the real refusal, emit, signal, connect, handler.
- **THE LEDGER ASSERTION THE SKETCH DESCRIBED NEEDED A SESSION, and the
  sketch did not say so.** `TrackLog.event()` returns at its first line when
  no session is running (`track_log.gd:60`), so the `ai_unavailable` record
  the handler writes **does not exist outside a session**. A fixture that had
  asserted it without starting one would have been asserting the absence of a
  file write — and passing. The suite starts a session.
- **`attempts` is 0, not 1**, and that is right: `_send()` returns at its key
  guard before `attempt = 1`, so a request refused before anything was tried
  records no tries. Asserted as 0 with the reason in the assertion's text.

### THE FINDING: main.gd's busy guard stands in front of the interpreter's

**The suite's own first draft assumed `_send()`'s OTHER key-free refusal —
the busy one — could be reached from the top, and asserted it. It failed.**

`main.gd:177` checks `interpreter.busy` and refuses first, with **its own
sentence**: *"Still thinking about the last request..."*, which differs from
`ai_interpreter.gd:345`'s *"Still thinking about the last request."* by an
ellipsis instead of a full stop. So the typed-request door never reaches the
interpreter's guard at all, and the handler does not run: no status line from
it, no history entry, no ledger event.

**ONE CONDITION, TWO DECIDERS — 057's shape exactly**, where the key rule had
five deciders and the fifth one was wrong. **Nothing is wrong here**, and the
commit says so plainly: the player is told the right thing, by `main.gd`.
What is true is that the interpreter's busy sentence has **one production door
left** — `revise()` at `main.gd:418`, which does not check `busy`, grepped as
one of only two callers of a `_send()`-reaching public method — and that two
sentences for one condition is how the next wrong one gets written. Left as a
candidate below rather than changed, because the behaviour is correct and the
smallest complete change to correct behaviour is none.

The suite holds **both halves**: that `main.gd`'s guard fires first and the
handler does not run, and that the interpreter's guard does reach the handler
when entered where a caller that does not check `busy` enters it. Run against
`main.gd`'s busy guard deleted, the first of those fails.

### A FALSE SENTENCE IN THIS FILE, FOUND BY MEASURING IT (TRAPS 14, TRAPS 54)

Since 057 this file has said the cost of the unheld `track_measured` wire is
that *"every panel suite passes with the measurements panel permanently
**blank**"*. **Measured with the connect wired out: the panel is never
blank.** `_build_metrics_panel()` writes a line into it at `main.gd:978` —
*"Build a composed track to see its measurements."* — and with the handler
disconnected **that line is what a player sees for the whole session**, under
a heading reading TRACK MEASUREMENTS. Not blank: permanently **wrong**, which
is worse.

**And the suite's second draft walked straight into it**: it asserted the
panel was "not blank", which **passed with the connect wired out**. An
emptiness test cannot tell a measurement from the placeholder the widget was
seeded with. The corrected assertions name the two states apart — is the
placeholder **gone**, and is what replaced it the line `panel_lines()`
actually produced — and the placeholder string is checked against `main.gd`'s
own source rather than trusted in two files (TRAPS 28). **TRAPS 54.**

### What the suite asserts, and what it does not (TRAPS 6, TRAPS 14)

- **`_on_interpretation_failed`**: the status line, the history panel entry
  against the request, and the ledger's `ai_unavailable` event with its
  `request`, `reason` and `attempts` — the same refusal in all three places,
  **not a second wording** in any of them. That `revising` was cleared. That
  nothing went on the wire (`busy` false; and for the busy door, `last_body`
  still empty, which `_send()` fills only after both guards). Two different
  reasons through two different guards, which is what proves the handler is
  not hard-coded to the no-key sentence.
- **`_on_track_measured`**: that every line `panel_lines()` produced for the
  record **the signal carried** is in the panel, **in order**; one measured
  line named outright so the loop cannot go vacuous on an empty list; the
  refusal shape (RESULT FAILED and REASON); and that the panel is **cleared**
  between the two, so a refusal cannot appear under the last world's
  measurements.
- **`_on_equipped`**: a body stood up first, because the handler's branches
  are each guarded on a node being non-null and in a harness there is usually
  no walker — a suite could reach this handler and observe nothing. Then
  every field of a legal boots spec on the standing body, **and `run_push`,
  which no spec carries**: it is derived inside `Walker.equip()` from `push`
  and `BootsTool.RUN_RATIO`, so its moving is proof `equip()` itself ran
  rather than the kit merely being stored. And the `look` branch, which
  reaches the same body through `wear()`.
- **IT DOES NOT PROVE ANYTHING WAS SEEN.** Every assertion reads a
  `RichTextLabel`'s parsed text or a node's fields in a headless process. No
  pixel was drawn, no window opened, and nothing here says the panel is
  legible, the colours are right or the text fits the box. `_metric_colour()`
  is not asserted at all.
- **IT DOES NOT PROVE THE AI PATH.** No model sent anything and no request
  left the container: the no-key door refuses before `_post()`, the busy door
  refuses before `_send()` builds a body, and the suite asserts both.
- **AND IT DOES NOT HOLD THE TWO HANDLERS THAT NEED A KEY.** Those are still
  held by nothing, and the suite says so in the text of two assertions.

### Evidence — what was actually run

Godot 4.7.1 headless on Linux (`4.7.1.stable.official.a13da4feb`), in a cloud
container, every run **sequential** with `user://` cleared first (TRAPS 50).

- **Baseline at 057**: 62 suites, `--all`, **0 with something to look at**.
- **After**: 63 suites, `--all`, **0 with something to look at**.
- The two lists were **diffed**. The only difference is **one added line**,
  `handler_wiring_test    HANDLER WIRING 47 assertions, failures=0`. No
  existing suite's result line moved.
- The new suite runs in **1.2 s** and passes **without** `--fixed-fps`, so it
  needed no entry in `run_tests.sh`'s `TIMED` or `SLOW` lists and the runner
  was **not edited**. Run three times, same result each time.
- **THIRTEEN DELIBERATE FAULTS, ONE AT A TIME**, each in a throwaway copy
  outside the repository with its **own `config/name`** so it could not share
  `user://` with anything (TRAPS 50), and the FAIL lines **read** rather than
  counted:

| fault | caught by |
|---|---|
| `interpretation_failed.connect` wired out | 8 failures, all in its own two sections |
| `track_measured.connect` wired out | 5, all in the panel section |
| `equipped.connect` wired out | 8, all in the equipped section |
| `metrics_log.clear()` removed | 2 — and the draft before it caught **1** |
| `run_push` left unchanged in `Walker.equip()` | 1 — the derived field |
| the `attempts` key dropped from the event | 1 |
| the handler's `_record()` removed | 2 — the history panel |
| the handler's `revising = false` removed | 2 |
| `main.gd`'s busy guard deleted | 1 — the finding above is asserted |
| the handler's `TrackLog.event()` removed | 2 |
| `walker.wear()` branch removed from `_on_equipped` | 1 — the look branch |
| the panel drawing only its first line | 4 — the in-order assertion |
| a key-free `interpretation_ready.emit()` added to `_send()` | 1 — and it names the function |

- **TWO OF THE THIRTEEN FOUND FAULTS IN THE SUITE AND NOT IN THE CODE**, and
  they are the two worth reading: the panel's "not blank" assertion, which
  passed with the wire out (TRAPS 54), and the cascade — the first
  `interpretation_failed` wire-out scored **ten** failures across all four
  sections, of which **two** belonged to sections that hold their own wires.
  With the state a previous section leaves behind cleared between sections it
  scores **eight**, all in the two sections about that handler. A cascade
  makes a suite look like it holds more than it does, which is the flattering
  direction, the same as TRAPS 50's. **TRAPS 55.**

### Not verified

- **NO BROWSER RAN AND NO WEB EXPORT WAS MADE.** 057's "Next action" is
  untouched and still the owner's: the Netlify key. Nothing here moves it.
- **NOTHING WAS RENDERED ON A SCREEN**, and no claim above is about what a
  player's eyes would do with the panel.
- **NO MODEL SENT ANYTHING** and no request left the container.
- **NO WORLD, RECORD OR SAVED FILE OF THE OWNER'S CHANGES.** The prompt is
  byte-identical and `PROMPT_VERSION` did not move; `prompt_bounds_test`
  holds that and passed. No file in `scripts/` was touched.
- **SEVEN OF THE SIXTEEN `connect()` ROWS ARE STILL `NOT_ASKED`**, unchanged
  by this commit, and they are the first item under "Next action" below.

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

   **054 measured one more thing about them and it bears on the choice.**
   `main.gd` stands an unrecorded starter circuit in the world at launch
   (`show_unrecorded`, `main.gd:135`) so there is something to drive before
   anything has been asked for, and that sets `drivable`. So on a fresh
   session `has_drivable()` is TRUE, and **a player's first `MODIFY_TRACK` is
   refused with *"composed tracks are changed with MODIFY_SECTION, which
   comes in a later step"* — about a track he never asked for and cannot see
   the request for.** The same holds for `SPAWN_OPPONENTS`. The *other*
   refusals, the ones that name the Prototype 001 ring, are reached only
   after the world has been cleared. That makes option (a) cleaner than it
   looked (the misleading sentence goes with the commands) and it gives
   option (b) a second thing to fix. Measured, not changed: what a refusal
   should SAY is yours.

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

9. **The closure solver builds sections outside the bounds the prompt states
   and the validator enforces.** Found in 039 while measuring *"The game can
   adjust each angle and each straight length by up to 20% to close the
   loop"*, which is TRUE as stated — every straight and every corner moved
   in all four circuits measured, and nothing exceeded 20.00%. What the
   measurement also showed, and what nobody had asked:

   ```
   corner at 120 deg (the stated maximum)  ->  136.2 deg built
   corner at  10 deg (the stated minimum)  ->    8.0 deg built
   straight at 1000 m (stated maximum)     ->   up to 1200 m reachable
   ```

   `SectionValidator` would refuse every one of those if the model had sent
   it. The solver runs after validation and clamps only to +/-20%, never to
   the type's own range. Beside it, an internal disagreement in the same
   file: `ClosureSolver.length_reach()` — the analysis that answers *"could
   any straight lengths close this layout?"* — clamps to `REACH_MIN_LENGTH`
   20 and `REACH_MAX_LENGTH` 1000, the stated bounds, while `solve()` does
   not. So the feasibility answer and the solution are computed under
   different limits.

   **Nothing is broken today that has been measured.** The 20% licence is
   disclosed to the model, `/save` stores the PROPOSAL and re-solves on load
   (so a saved circuit cannot be refused on the way back in), and the drift
   is recorded — `max_angle_adjustment` and `max_length_adjustment` are in
   every circuit's record. A player who asks for a 120 degree corner may get
   136 degrees and is told a percentage, not the number.

   The options, for the record:

   - **(a) Leave it.** Costs nothing measured. The stated ranges stay a
     bound on what the model may ASK for, not on what Genesis builds.
   - **(b) Clamp each adjustment to the type's own range as well as to
     20%.** Makes the stated bound true of the built track. It narrows what
     the solver can reach, so some circuits that close today would be
     refused — which is a change to what Genesis accepts.
   - **(c) Leave the solver and make `length_reach()` agree with it**, so
     the feasibility answer and the solution use the same limits. The
     smallest change, and it fixes only the internal disagreement.

   The assistant has not chosen: (b) changes what Genesis builds and (a)
   versus (c) is a judgement about which of the two is the honest limit.
   Measured, not inferred, in 039.

10. **A plan refused for OVERLAPPING destroys the standing world, and making
    it safe changes how a plan is built.** Found in 040 while building the
    door for *"a new world replaces whatever was there before"*, which is one
    member of a rule Genesis follows everywhere else: a refusal leaves what
    was there alone. Measured headless, before and after 040's fix:

    ```
                                                   before 040   after 040
    a single world refused by its validator          survived    survived
    a plan refused for its SCHEMA                    survived    survived
    a plan with a step that cannot be worked out     DESTROYED    survived
    a plan refused for OVERLAPPING                   DESTROYED   DESTROYED
    a sectionless CREATE_TRACK (Prototype 001)       DESTROYED   DESTROYED
    ```

    040 fixed the third row by clearing when a build is certain to start
    rather than before it is known whether one can. The fourth row is not a
    move: the overlap is found in **pass 3**, by `_place()`, after the clear
    and after earlier steps have already been built, because a world's
    footprint is read off `module.build()`'s report. The fifth row is
    Prototype 001's ring and is item 2 above, deferred twice on purpose.

    **This is the more reachable half.** Two worlds with no `"around"` is the
    shape of the prompt's own PLAN skeleton — the skeleton shows two steps and
    says nothing about `around`, which is introduced in the sentence after it
    — so *"a farm and a dungeon"* is prompt-conformant model output that takes
    this path. Measured: a farm plus a 12 m hall and a 20 m vault, no
    `around`, is refused *"step 2 overlaps step 1"* and the farm that was
    standing is gone.

    The options, for the record:

    - **(a) Leave it.** Costs nothing new; the fault is as old as plans. The
      player loses a world to a refusal, and `/save` is the only way back.
    - **(b) Compute every footprint before building any of them**, so the
      overlap check moves into a pass of its own between 2 and 3 and the
      clear waits for it. `module.extent(layout)` already answers the size
      question for `_fit_plan` without building, so the pieces exist — but
      `_place()` works in built bounds and plan order, and moving it is a
      change to how a plan is assembled rather than a smaller clear.
    - **(c) Build the plan beside the standing world and swap it in only if
      every step succeeds.** Makes every plan atomic, which fixes this row and
      any future one, and needs `drivable`, `standable` and `pending_order`
      saved and restored. The largest change and the only one that does not
      have to be revisited when a fourth refusal layer appears.

    The assistant has not chosen: all three change how a plan is built, which
    is architecture, and (a) is a judgement about how much a lost world costs
    a player. Measured, not inferred, in 040.

11. **A readback rounds a measurement to whole metres, and it is prose rather
    than a defect.** Measured headless in 041 and **not changed**, because
    unlike the refusals 041 fixed it is not a misquote: the world really is
    built at the size that was asked for, so the sentence rounds a true fact.

    ```
    rooms 12.4 and 20.5 m   "entered through a 12 m hall, along with a 20 m vault"
    barn 30.4 by 20.6 m     "a farm with a 30 by 21 m barn"
    straights 200.4 m       "two 200 m straights and two 50 m corners, 90 deg right"
    ```

    The strict reading of TRAPS 34's rule — *a number said back is said as the
    player wrote it* — puts these in its class, and `Readback.number_said()`
    would render them *"a 12.4 m hall"*, *"a 30.4 by 20.6 m barn"*. Against
    that: a readback is the one sentence in Genesis whose job is to be read
    aloud, every session that has touched one has been asked whether it reads
    as help or as clutter, and three decimals across a six-section circuit is
    the worst case. **The assistant has not chosen**, because it is a
    judgement about prose and the owner is the editor.

    If the answer is "say them exactly", the change is small and the rule is
    already written: route the readbacks' measurements through
    `number_said()`. If it is "keep the rounding", that is worth a line in
    TRAPS 35 saying so, so the next audit does not re-open it. Either way the
    assertion stays out of `said_number_test` until the owner says which,
    because a suite that freezes an unmade decision is TRAPS 14.

12. **A fractional count or corner: say it back, or refuse it?** 044 made the
    readbacks faithful, which was the half that was plainly wrong — a sentence
    naming a room the request never named. It did not decide the other half,
    because that half is about what Genesis DOES.

    Three doors stand differently now and the difference is visible to a
    player:

    ```
    ORDER "room": 2.9         said back as room 2.9, and REFUSED, naming the range
    CREATE_DUNGEON "in": 2.9  said back as room 2.9, and REFUSED, naming the range
    SHUT [1, 2.9]             said back as room 2.9, and REFUSED, naming the range
    MODIFY_TRACK "corner":2.9 said back as corner 2.9, and ACTED ON as corner 2
    SPAWN_OPPONENTS 2.9       said back as 2.9 opponents, and ACTED ON as 2
    ```

    The first three go through a validator and refuse, which is what the
    prompt says Genesis does: *"it REFUSES rather than clamping"*. The last
    two have **no validator** — 036 established that four of eleven commands
    do not, and said at the time that "no validator" means something different
    for a command that builds nothing whatever it is sent. Both of them
    currently truncate in the handler and neither builds anything today
    (`TrackBuilder.corner_nodes` is never filled, so `MODIFY_TRACK` changes
    nothing and `SPAWN_OPPONENTS` places nothing).

    So the question is **whether these two commands should refuse a value the
    other three refuse, while they are still Prototype 001 stubs that do
    nothing**. Refusing costs two small checks and makes Genesis consistent
    about its own stated rule. Not refusing leaves two sentences that say a
    number back faithfully and then act on a different one — honest in the
    readback, inconsistent one layer down.

    **The assistant has not chosen**, because it is a question about what
    Genesis does on a path the owner may be about to delete (both commands are
    "Human decision needed" 2's subject), and because the same reasoning
    decides whether *"to put 2.9 opponents on the track"* should exist as a
    sentence at all. Either answer is a few lines; neither is asserted in
    `said_position_test`, which checks only that the sentence does not name a
    number the request never carried, because a suite that freezes an unmade
    decision is TRAPS 14.

13. **The farm's silence, and the two numbers 046 left on the layout.** All
    three come out of 046 and all three are about what a sentence should say
    rather than about whether what it says is true, which is why they are
    here and not in the commit.

    **(a) Should a built farm say what it built?** It says *"Farm built (full
    measurements in the panel)"* — `WorldModule.summary()`, the default —
    where a dungeon says *"CREATE_DUNGEON built 3 rooms joined by 2 doors"*
    and a circuit says *"CREATE_TRACK built a closed clockwise circuit: 8
    sections, 1114 m of road"*. A sentence that states no count cannot state
    a wrong one, so 046 left it: inventing a sentence for a world is a
    product decision, and the shape is the one 032 found at
    `SPAWN_OPPONENTS` — a silence beside two sentences that say something.
    The mechanism is already there: `FarmModule.build()` reports
    `pieces_built`, so this is a line of prose and not a change to anything
    underneath it.

    **(b) Should *"joined by 2 doors"* count doors or corridors?** The room
    count in that sentence is now read off the tree and the DOOR count is
    still read off the layout. They cannot disagree today — `_corridor()` is
    the same function the builder and the measurement both call — and they
    are not the same claim: a door is a thing in the design, a corridor is
    the thing that gets placed, and `build()` already skips a door whose legs
    come back empty (`if not legs.is_empty()`). Tying the sentence to
    corridors would make it say what a player can walk through; leaving it
    says what the dungeon was designed with. Also unanswered, and smaller:
    **a SHUT door is counted as joining two rooms**, because `walkable()`
    reports blocked doors separately and the summary does not read it.

    **(c) Should *"1114 m of road"* be measured from the road?** It is summed
    from `TrackGeometry.section_length()` per section — the design's length,
    not the centreline that was actually sampled and laid. Measured in the
    suite: with one section removed from the tree the sentence reads *"7
    sections, 1114 m of road"*, so the count follows the construction and the
    length does not. Nothing is wrong with the number today; the question is
    whether a length in a construction sentence should be measured off the
    built centreline, which `CircuitBuilder` already has in
    `centreline`.

    **The assistant has not chosen any of the three**, and no suite freezes
    any of them: `built_count_test` asserts about the piece count and says in
    its own header that it asserts nothing about doors, length or the farm's
    sentence, because a suite that freezes an unmade decision is TRAPS 14.

14. **A panel line for a doorway a body cannot use, and whether the panel
    should re-measure at all.** 047 made the dungeon's getting-about lines
    follow the doors a body can use, which is what `WALKABLE`, `route()` and
    the body had always done. Two questions came out of it and both are
    yours, because both are about what Genesis SAYS:

    - **`measure()` already counts the doorways a body cannot use —
      `walk_blocked` — and nothing in Genesis reads it.** No panel line, no
      sentence, no suite. With 047 in, shutting a door changes `DEAD ENDS`
      and `WAYS ROUND` and nothing says why. A line — *"BLOCKED 1 doorway"*,
      or whatever reads best — would say it. The number is already measured,
      so this is a sentence and not a mechanism.
    - **Nothing re-measures a standing dungeon.** `measure()` is called once,
      in `GameController._prepare()`, before the world is built. So the panel
      is a measurement of the dungeon **as created**, and a door shut
      afterwards does not reach it. 047 made the numbers correct for a
      standing dungeon without wiring anything to ask them again. Whether
      shutting a door should redraw the panel is a change to when Genesis
      speaks and to what the panel is FOR — a record of what was made, or a
      readout of what is there — and that is a product decision.

    And the smaller one beside them: **a shut door still counts in
    `door_count`**, so *"ROOMS 4 doors 4"* and *"joined by 4 doors"* are
    unchanged by shutting one. That is deliberate — a shut door still joins
    two rooms — and it is left where 046 left the same question about a
    door's construction being a corridor.

15. **What a farm's gate should LOOK like, now that it is in the right
    place.** 049 fixed the gate's position: a farm a plan has grown has a
    16 m gap in its fence posts on the south side again, where before it had
    none. What 049 did **not** touch is that the RAIL runs straight across
    that gap. `_add_fence()` places one rail per side, spanning the whole
    side, and skips only POSTS near the gate — so on every farm Genesis has
    ever built, grown or not, the gate is a gap in a row of posts with a rail
    through the middle of it. Measured, not read: the rails of a 44 × 44 m
    farm add up to **176 m**, which is exactly its perimeter — four rails,
    one per side, each as long as the side it runs, with no break anywhere.
    And the farm places no `StaticBody3D` and no `CollisionShape3D` at all,
    checked by grep across the module.

    Nothing is physically blocked either way — the fence carries no collision
    at all, so a gate is a thing a player sees and not a thing they pass
    through. So this is a question about what a farm should look like, which
    is yours:

    - **(a) Leave it.** A gap in the posts reads as a gateway well enough,
      and it is what every farm has looked like since 003.
    - **(b) Break the rail at the gate** — two rail segments per side on the
      side the gate is in. A few lines in `_add_fence()`, and it is the thing
      that would make a gate look like a gate.
    - **(c) Put a gate THERE** — two posts and a crossbar — which is new
      geometry rather than a fix.

    And one thing worth knowing whichever way it goes: **if the fence is ever
    given collision**, (a) stops being cosmetic. A rail across the only gap
    would be a farm nothing can drive into, which is the thing the farm's
    own header says it refuses — *"A farm you cannot drive a tractor around
    is refused"*. Recorded here rather than guarded, because nothing drives
    on a farm today.

16. **Whether Genesis should have a door to a QUESTION at all, and if so
    which kind.** This is your own finding — *"show me the dungeon metrics"*
    and *"where is the red key now"*, 2026-10-16 — and 050 deliberately
    added no command. What 050 did do is stop the two wrong answers it was
    producing: the prompt now states the limitation, so a question comes
    back as an honest refusal instead of an invented reason or a SHUT, and
    the checker no longer calls that honest refusal false.

    **The facts, measured headless and not read:**

    - **Both answers already exist inside Genesis.** `measure(layout)`
      returns room count, floor area, corridor length, the deepest room,
      the largest room and the extent — the whole of the first question.
      `room_of(layout, position)` turns a thing's position into a room, and
      it is how a delivery is judged, so the second question is a function
      call away.
    - **What a player can reach today, on demand, with no AI involved:**
      the game commands — `/save`, `/load`, `/worlds`, `/delete`, `/drive`,
      `/race`, `/explore`, `/view`, `/experiment`, `/stop`, `/status`,
      `/revise`, `/session`, `/log`. **Not one of them reports anything
      about the world that is standing.** `/status` is the experiment
      runner's; `/log` gives the ledger's file path; `/worlds` lists SAVED
      worlds; `/session end` summarises a tester's session. Read from
      `main.gd`'s `_run_local_command`, which is the whole list.
    - **What a player can reach today only by building or refusing:** the
      panel. `metric_lines()` is drawn from a record, and
      `GameController._prepare()` is the one place `measure()` is called,
      before anything is built. Nothing redraws it — which is "Human
      decision needed" 14 from the other side.
    - **`CommandParser.allowed_commands()` is eleven commands and every one
      builds, changes or removes something.** `asked_test` asserts that, and
      fails the day a twelfth appears, so whichever way this goes the
      limitation cannot be left in the prompt by accident.

    **The options, for the record, cheapest first:**

    - **(a) Nothing.** The refusal is honest now and says where the facts
      are. Costs nothing and the question stays unanswerable.
    - **(b) A GAME command — `/panel`, `/where`.** This is the shape every
      other on-demand door in Genesis already has: the player types it, no
      model sees it, nothing enters the whitelist, and no refusal can be
      made false by it. **The limitation in the prompt stays true**, because
      the model still cannot be asked. Two things it would run into, both
      read rather than guessed: the panel is `metric_lines(metrics, record)`
      and nothing keeps a standing world's metrics, so `/panel` would have
      to call `measure()` again — which with 047 in means it would honour a
      door shut since, and therefore answers 14's second half too, for good
      or ill. And `standable` — layout, rooms, node — is reported by the
      DUNGEON only, so a `/where` has a dungeon's layout to hand and a
      `/panel` for a farm or a circuit would need the last record instead.
    - **(c) A third GOAL on `ORDER`, not a new command.** `NpcGoals.GOALS`
      is `["go_to", "carry"]`; a goal that reports where a thing is rather
      than walking to it would reuse the validator, the readback and the
      record. Smaller than a command, and the cost is that it bends what an
      ORDER is: an order sends a character somewhere, and a question does
      not. **This one does change what the prompt says Genesis cannot do.**
    - **(d) A new whitelisted command.** The honest version of what the
      model was reaching for. It is the most expensive and it is the one
      032's three Prototype 001 stubs are the standing warning about: a
      whitelist entry that builds nothing. Two things to know before
      choosing it: **the name `LOOK` is taken** — `EQUIP look` is the tool
      that decides how the player's body looks, so a `LOOK` command and a
      `look` tool would be two different things with one name; and every
      command writes a ledger record with a construction outcome, so a
      command that constructs nothing needs an answer to what its record
      says (033 and 045 are both about that question).

    **Whichever it is, the limitation and the marks move with it**, and the
    suite is wired so they cannot be forgotten: `asked_test` fails if the
    whitelist changes, and its message names both places — the prompt's
    CANNOT list and `RefusalCheck`'s two `no_command_asks` marks.



17. **Two things 051 found that are sentences and one that is a record, all
    three measured and none of them an assistant's call.**

    051 fixed the panel's three wrong READINGS — a caveat about what was
    built driven from whether the proposal was valid, a world's name from a
    default, and a verdict printed for a record that carries none. What it
    could not fix is what the panel should SAY in the two places it now says
    almost nothing, and a fault in the ledger that is yours because the
    records are.

    - **(a) What a load check's panel should say.** `record_load_check()`
      writes the only emitted record with no `result` key, because it judges
      a world that came back off disk rather than a proposal. Before 051 the
      panel read **`RESULT  FAILED: `** in red with an empty category, for a
      check whose outcome was SAME — measured. It now prints no verdict line
      at all, which claims nothing and is the honest minimum, so a `/load`
      shows a panel of one line: *"REQUESTED not stated"*. **The record
      carries an `outcome`, a `said` and a `differences` list and not one of
      them has ever been in the panel.** What it should show — `OUTCOME
      SAME`, the differences, nothing at all — is a sentence about what
      Genesis says, so it is yours. The fields are all there; this is not a
      mechanism.
    - **(b) How a record with no world should name itself.** A record that
      is not a world now names its COMMAND: *"Valid EQUIP"*, *"Valid
      ORDER"*, *"Valid CLEAR_WORLD"*, where all three said *"Valid
      circuit"*. It is honest and it is clipped, and raw command names are
      already in player text elsewhere (`_finish_failed` writes *"EQUIP
      failed: FAILED_SCHEMA"*, and a build says *"CREATE_DUNGEON built 3
      rooms"*), which is why it was chosen over inventing a phrase. If
      *"Valid"* alone reads better, or if those commands should say
      something of their own, the change is one function —
      `WorldRegistry._panel_subject()` — and `panel_refused_test` holds the
      line either way, because it asserts that no record names a world it is
      not about and never what the sentence is.
    - **And the panel's TITLE still reads `TRACK MEASUREMENTS`** for a
      dungeon and a farm, in `main.gd._build_metrics_panel()`. It is a static
      label and not a line read from a record, so 051 left it: it is the
      same Prototype 001 word the `"circuit"` default was, one layer out.
      One word, yours to choose.

    - **(c) THE ONE THAT IS A RECORD, AND IT IS A FAULT: a plan refused in
      pass 3 writes two ledger lines with the SAME id, saying different
      things.** Found while measuring the panel, measured headless, and left
      for its own commit because what to do about it is a decision about
      YOUR evidence file. A plan that fails when its worlds are placed —
      two worlds with no `"around"`, which is the shape of the prompt's own
      PLAN skeleton — has already BUILT the earlier steps when it fails. So
      each of those step records is appended by `_build_world()` with
      `construction: BUILT`, and then the clean-up block at
      `game_controller.gd:871` sets `construction: FAILED` **on the same
      dictionary** and appends it **again**. Measured, a plan of two
      dungeons:

      ```
      [3] id=…-5  CREATE_DUNGEON  result=VALID  construction=BUILT
      [4] id=…-6  CREATE_DUNGEON  result=VALID  construction=BUILT
      [5] id=…-5  CREATE_DUNGEON  result=VALID  construction=FAILED
      [6] id=…-6  CREATE_DUNGEON  result=VALID  construction=FAILED
      [7] id=…-4  PLAN            result=FAILED construction=FAILED
      ```

      Four lines for two worlds, two ids each used twice, and the two lines
      under one id contradict each other on the construction layer.
      `TrackLog.append()` only assigns an id when one is absent, which is
      why. **This breaks the project's own stated rule** — *"the original
      interpretation is never edited: history is added to, not rewritten"* —
      and the convention that goes with it: evidence arriving later gets its
      OWN id and points back with `about`, which is exactly what
      `record_load_check()` does. **And nothing would catch it**:
      `ledger_audit_test` builds its index with `orders[str(record["id"])] =
      record`, so a duplicate id silently overwrites its twin.

      Both lines are true of a different moment, which is why this is a
      question and not just a bug:

      - **(i) Leave it.** The second line is the later truth and the file is
        in time order, so a reader taking the last line for an id gets the
        right answer. Costs: any index by id is wrong, and the rule above is
        not what the file does.
      - **(ii) Give the second append its own id and an `about`**, like a
        load check. The ledger then says what happened in the shape it
        already has for later evidence, and an audit by id keeps working.
        This ADDS records to your file.
      - **(iii) Don't re-append — emit only.** One line per world, saying
        `BUILT`, which is what happened before the plan was rolled back and
        is then wrong about the world the player is left with.

      **Not touched, and no record on your disk was changed.** The direction
      that would be safe either way is a suite that fails on a duplicate id,
      which is a guard and not a choice; say which of the three you want and
      it goes in with the guard.
18. **Where the farm's clearance check lives, which decides whether it can
    ever be proved connected.** Measured in 053 and left for you because it
    moves where a refusal comes from.

    `FarmModule._check_reachable()` is the farm's version of *"the circuit
    must close"*. It is called from inside `solve()`, on the layout `solve()`
    has just built. **Delete that call and every one of the 60 suites still
    passes** — measured with a full `--all` run, not inferred. Nothing can
    tell the connected guard from the disconnected one, because `solve()`
    cannot be made to build a layout that violates it, so there is no input
    that distinguishes the two.

    The dungeon's three guards and racing's separation check do not have this
    problem: they are reached through `post_check(layout)`, which takes the
    thing they check, so a test hands it a violation and the category comes
    back. Wiring any of those six out is caught, measured one at a time.

    052 raised the same move and declined it as *behaviour-identical, a move
    rather than a fix*, which was right on the evidence it had. The options:

    - **(a) Leave it.** Costs nothing today and the guard does work when
      called. The farm keeps the one check in this project that no suite can
      hold to account.
    - **(b) Move it into `post_check()`**, where `WorldModule`'s own comment
      says a check on a solved layout goes and where racing already puts its
      separation check. Behaviour-identical today — the branch is
      unreachable, the category stays `FAILED_LAYOUT` — and it makes the
      wiring testable, which is the whole of the argument. It is a change to
      which STEP refuses, so a record's `category` would arrive from
      `post_check` rather than `solve`; nothing in the repository reads which
      step a category came from, checked by grep, but that is the thing to
      look at twice before taking it.
    - **(c) Move all three worlds' clearance checks to one place** and make
      it the rule rather than the convention. Larger, and the class question
      rather than the instance (TRAPS 11).

    **Nothing was moved.** The guard is labelled where it stands and the
    measurement is in `tests/refusal_reach_test.gd` and in the 053 section above.

    **055 asked the same question of every other check in Genesis and this
    is still the only one.** Fourteen call sites were wired out one at a
    time: ten are held by a suite, three more have a door that nothing had
    walked and now do, and this one has no door at all. So (a) is no longer
    "the farm keeps the one check nothing can hold to account" by accident —
    it is the only one left, deliberately, and the choice is yours.
    `tests/check_wiring_test.gd` asserts the two structural facts that make
    it one (the function is private, and it is called from `farm_module.gd`
    alone), so the day it is given a door the suite says the row has moved.

19. **What a player should be told when the site has no key configured.**
    Found in 057 and deliberately NOT changed, because it is a sentence and
    a retry policy rather than a fault, and both are yours.

    The Netlify function already answers this case well. With
    `GEMINI_API_KEY` unset it returns **503** with its own message —
    *"This Genesis has no AI configured. Raw JSON commands still work."* —
    and its comment says why: *"a build without a key is a deployment
    mistake, not a player's"*. `is_available()`'s comment agrees, and says
    that such a function *"answers with Genesis's ordinary AI FAILED message
    instead, which is the honest place for that news"*.

    **Genesis never shows it.** 503 is in `WORTH_RETRYING`, so Genesis tries
    three times over several seconds, and then `_friendly_http_error(503)`
    says *"The AI service is busy. Genesis tried 3 times over a few seconds
    and it was busy every time. Worth another go in a minute."* The body is
    printed to the console and dropped. So a site with no key configured
    tells the player to wait a minute, for ever, and the one sentence that
    would have told the owner what is actually wrong is the one thrown away.

    Three things could change and they are not the same size:

    - **(a) Read the function's message when the body carries one.** The
      smallest. It changes what is shown for any error whose body has a
      `message`, which is most of Google's too, so it is a change to every
      AI error sentence and not just this one.
    - **(b) Take 503 out of `WORTH_RETRYING`.** Smallest in code and the
      worst trade: 503 from Google really is worth retrying, and that is
      what 026 put it there for. A 503 from the function and a 503 from
      Google would need telling apart, which means (a).
    - **(c) Give the function a code of its own** for "no key configured"
      — 501, say — and a sentence for it. Honest and narrow, but it is a
      change to a deployed function, which is yours and not the
      assistant's.

    **Nothing was changed.** 057 touched only what stopped the request being
    sent at all. This is the next thing a player on the live site would
    meet, and which of the three is right depends on what you want the site
    to say about itself.

20. **Whether this project should own a test double for `HTTPRequest`.**
    Found in 058, which is the second commit running to stop at the same
    wall and the first to name it as a decision rather than a limitation.

    `_on_interpretation_ready` and `_on_ai_retrying` are held by **nothing**,
    and **no fixture in this harness can hold them**. Their only emits are
    inside `_on_request_completed` and `_try_again`, past the network: 056
    hit the same wall from a different direction (TRAPS 52) and so did 057.
    Between them those two handlers are what a player sees when an answer
    arrives and when the model is busy — the status line, the history entry,
    the retry sentence 026 added so a four-second silence does not read as a
    hang. **None of it is held by anything.**

    What would hold them is a **double in front of `HTTPRequest`**, so a
    suite could hand `_on_request_completed` a response body and a code.
    That is a real change in kind and that is why it is yours:

    - **It would be the first test double this project owns.** Every suite
      today drives the real thing through a real door, which is the reason
      the suite has the standing it has. A double is a thing that can drift
      from what it stands for, and the drift is invisible: a suite that
      passes against a double that no longer matches Google's shape proves
      nothing and still says `failures=0`. TRAPS is largely a record of
      exactly that failure mode in other clothes.
    - **It would reach further than these two handlers.** Eight of
      `interpretation_failed`'s eleven emits are in
      `_on_request_completed`, and 026's whole retry policy — which codes
      are `WORTH_RETRYING`, how long it waits, what it says — is unheld for
      the same reason. So is `attempts_of_last()` returning anything but 0.
      The gain is larger than the two rows; so is the surface.
    - **The alternative is to leave them to the owner's machine**, where
      they are already exercised every time a request succeeds or the model
      is busy, and where 048's two faults were found. Unheld in the suite is
      not the same as untested in practice.

    **Nothing was built.** 058 asserts the two connects and labels them
    `WIRE ONLY` in the assertion's own text, so the gap is recorded in the
    one place that cannot go stale. If the answer is yes, the smallest honest
    first step is one response shape and one assertion, not a framework.

22. **Whether the other two time-minted identifiers should move too.**
    Found in 059, which fixed one member of a three-member class and
    deliberately left two (TRAPS 11 says to state the rule for every member,
    and this is the statement).

    The rule 059 applied: *an identifier that has to tell one writer's
    records from another's must carry something only that writer has; a
    clock does not qualify at any granularity, because the question is not
    how precise it is but whether two writers can read the same value.*

    - **The record id** (`track_log.gd:59`) was `<seconds>-<serial>` and now
      carries `OS.get_process_id()`. **Fixed**, and it had to be: it is the
      pointer every piece of later evidence uses, and it was colliding in 8
      of 12 paired runs.
    - **The session id** (`main.gd:514-515`) is the tester's **name** plus a
      wall-clock second. It collides only for two writers using the same
      name in the same second, so the risk is much smaller — and
      `read_session()` and every session report group records by it, so
      **changing its shape changes reports you already have**. That is why
      it was not touched.
    - **The experiment `run_id`** (`experiment_runner.gd:62`) is
      `"run_" + <datetime to the second>` and carries nothing else, so it is
      the weakest of the three on paper. It needs a key, so nothing in this
      harness can reach it and nothing here has measured it.

    **Nothing was moved.** The three options are: leave both (the risk is
    real but small and the cost is to your own artefacts); move `run_id`
    only (nothing reads it across processes, so it is nearly free); or move
    both and accept that session ids written from then on look different
    from the ones in your existing reports. **`ledger_audit_test.gd:111`
    already salts its session name with `Time.get_ticks_msec()`**, which is
    somebody meeting this once and defending one call site rather than the
    class.

    **066: STILL YOURS, STILL NOTHING MOVED, AND TWO THINGS ARE NOW
    DIFFERENT ABOUT THE ANSWER.**

    - **The harness no longer depends on your decision.** All three suites
      that start a session now name it with `OS.get_process_id()`. The
      `ledger_audit_test` salt above was `Time.get_ticks_msec()`, and that
      was the weakest of the three defences rather than the strongest:
      `ticks_msec` counts engine uptime, which is mostly deterministic
      startup work. Measured over 20 headless runs of this project, the
      value read at the top of a suite spanned **123..199 ms**, and in 20
      samples `129` came up three times and `172` twice. So whichever way
      you decide, the suite is not what is waiting on it.
    - **The question announces its own answer now.** `record_id_test`
      section 9 asserts, as a labelled `OPEN (Human decision 22)` fact, that
      the session id and `run_id` still carry no writer. The day you move
      either, that assertion fails and the next session is told the decision
      was made instead of having to grep for it. Proved able to fail: both
      were given a process id in a throwaway copy and both assertions went
      red (066's faults 6 and 7).

23. **What the input box should keep after a request it did not send.**
    Found in 059 while measuring the two input-door connects, and
    deliberately NOT changed, because it may well be deliberate and it is a
    judgement about what the box is for.

    `_handle_request()` has eight ways out and clears `input_box` on five of
    them: an accepted request (`main.gd:185`), a bare answer with nothing to
    confirm (`:345`) and a consumed readback judgement (`:368`). **Three
    leave the text where it is**: a `/` command, a pending revision
    (*"Waiting for the AI's correction..."*) and a busy interpreter
    (*"Still thinking about the last request..."*).

    Two of those three read as right: a sentence Genesis refused to accept
    **because it was busy** is one the player will want to send again, and
    throwing it away would be worse. The `/` command is the odd one — type
    `/drive`, and `/drive` is still sitting in the box afterwards, so
    pressing Build again re-runs it. None of the twelve local commands is
    destructive on a repeat, which is why this is a tidiness question and
    not a fault.

    **Nothing was changed.** If you want it consistent, the smallest
    complete change is to clear the box in `_run_local_command()` rather
    than at a fourth call site in `_handle_request()`, so the rule stays in
    one place per door. Whether it should be consistent at all is yours.

21. **Whether "still thinking about the last request" should be one sentence
    or two.** Found in 058 and deliberately NOT changed, because the
    behaviour is correct.

    `main.gd:177` refuses a typed request while the interpreter is busy with
    *"Still thinking about the last request..."*. `ai_interpreter.gd:345`
    refuses inside `_send()` with *"Still thinking about the last
    request."* — the same sentence with a full stop instead of an ellipsis.
    **One condition, two deciders, which is 057's shape**, where the key
    rule had five deciders and the fifth one was wrong. The difference here
    is that **neither is wrong**: the player is told the right thing, by
    `main.gd`, and the interpreter's is a real guard for the one caller that
    does not check first (`revise()`, `main.gd:418`).

    So this is not a fault and there is nothing to fix. What is true is that
    057's lesson was *put the decision in one function both readers call*,
    and this is a second place where two readers decide the same thing
    separately. Making it one function would change no behaviour at all,
    which is why the assistant did not do it — the smallest complete change
    to correct behaviour is none, and a refactor that moves nothing is how a
    repository fills with motion. Whether it is worth doing anyway, as
    insurance of the kind `key_missing_for()` turned out to be, is a
    judgement about this project's appetite for that trade and it is yours.

24. **Whether the node a world is built into should have a stable name.**
    Found in 060 by the new suite's own first draft failing, and deliberately
    NOT changed.

    `RacingModule.build()` sets `circuit.name = "CircuitBuilder"` and then
    calls `root.add_child(circuit)`. Godot replaces the name of a node that
    collides with a **sibling**, and the world being replaced is still a
    sibling in that frame. So **every other circuit a player builds gets a
    dummy `@Node3D@N` name**, decided by what the previous world was called:
    `CircuitBuilder`, `@Node3D@49`, `CircuitBuilder`, `@Node3D@124`, measured
    across four builds in one session.

    **Nothing a player can reach is wrong**, and that is asserted off the
    source rather than assumed: no file in `scripts/` contains
    `"CircuitBuilder"` except the module that assigns it, so no production
    code identifies a world by name — the controller holds `drivable["node"]`
    by reference. What reads the name is `drive_test`, twice, and the
    positive one passes on the parity of its own build order.

    **The obvious fix does not fix it, measured rather than assumed:** moving
    the assignment to after `add_child` yields `CircuitBuilder2`. What would
    fix it is freeing the outgoing world before adding the new one — which
    changes the frame in which a world disappears, and 048 is the record of
    what depended on that — or deciding that a world's node name is not
    something anything should read, and saying so where the next reader of
    `drive_test` will see it.

    The assistant did not choose, because it touches a builder every world in
    this project goes through and the fault is latent: nothing reads the name
    today. What 060 did instead is hold the behaviour so it cannot change
    silently, and put a comment on `drive_test:174` so the next session does
    not read that line as evidence the name is stable. Whether the name
    should be made stable, or the reading of it removed, is yours. See
    TRAPS 58.

    **061 TOOK THE SECOND OF THOSE TWO OPTIONS, ON THE TEST SIDE ONLY, SO
    THE PARAGRAPH ABOVE NEEDS ONE CORRECTION.** "What reads the name is
    `drive_test`, twice" **is no longer true**: both of its readings now
    assert IDENTITY against `drivable["node"]` instead, which is the rule
    TRAPS 58 states and which `player_door_test` section 1 had already been
    following. So **nothing in this repository identifies a world by name**,
    production or test, asserted off the files. **The production question is
    untouched and still yours**: `RacingModule` still assigns a name that
    `add_child` still replaces, and a world a player builds still usually
    carries a dummy one. What changed is that no check depends on it any
    more, so the latent fault can no longer be hidden by a test that passes
    on build-order parity.

25. **Whether a player who types raw JSON should be told what changed.**
    Found in 060 the same way, and not changed.

    `main.gd:190` calls `_execute_json` and **returns**, eight lines before
    `main.gd:199-201` sets `editing_from` from the standing world. So a
    raw-JSON request is never an edit, and the `Changed: length 1577 -> 1977 m`
    sentence the play loop writes for an AI request is never written for a
    typed one. Measured: two circuits built one over the other through the
    real doors, and the history contains no `Changed:` line at all.

    It may well be right. Raw JSON is the no-key door — *"useful for
    debugging without spending API calls"*, says the comment above it — and
    the controller's own build summary is printed either way, so nothing is
    hidden, only uncompared. Against that: the owner is the person who types
    raw JSON, the comparison is the one thing he cannot do by eye across two
    builds, and it is three lines to set `editing_from` before
    `_execute_json` as well.

    What makes it the owner's rather than the assistant's is that it changes
    what a request MEANS: with `editing_from` set, a typed JSON build becomes
    an edit of the standing world in the record as well as in the sentence,
    and the ledger is the artefact this project exists to keep.

26. **The sun's angle, and whether it should cast shadows.** 063 fixed a
    `DirectionalLight3D` that had no rotation at all: its three numbers were
    sitting in the origin slots, which the engine ignores for a directional
    light, so the sun pointed horizontally and every horizontal surface in
    Genesis took exactly zero direct light. That part is a defect and is
    fixed. **These two parts are not defects and were not decided:**

    - **The angle.** The fix uses the scene's own three numbers, `(-45, -30,
      0)` degrees, because reinterpreting the numbers that were already there
      is the least inventive choice available — **not** because 45° and −30°
      are the right angles. What a sun should look like over a 1500 m circuit
      is a judgement a pair of eyes makes in a second and a harness cannot
      make at all. If you want it lower, higher or round the other way, it is
      one line in `scenes/main.tscn` and `scene_light_test` will still pass:
      the band it asserts is 10° to 80° above the horizon, and that band is
      labelled `JUDGEMENT` in the suite's own output for exactly this reason.
    - **Shadows.** `shadow_enabled` is `false` on that light and always has
      been. With the sun pointing along the ground it made no difference
      whatsoever; now that it points at the ground it does. Shadows are what
      makes a track read as sitting ON the pad rather than floating over it,
      and they cost frame time — on a web build, on whatever hardware a
      visitor has. That is a visual and cost trade and it is yours. Nothing
      in this commit turned it on.

    **And the same fix changes what the web build looks like**, because the
    web build gets the same scene. Nothing here exported or rendered anything,
    so the first look at it is the owner's, in the editor or on the site.

27. **Should the headless suite run in CI?** Found while writing 064, which is
    the commit that noticed the `web build` workflow had failed 46 times
    running. The suite has **never** run in GitHub Actions: the only workflow
    exports the web build and publishes it. Every `failures=0` this project
    has ever quoted was produced on the owner's machine or in an assistant's
    container, by hand.

    The case for: a push that breaks a suite is currently invisible until
    somebody runs `run_tests.sh`, and the unattended task is the only thing
    that routinely does. The case against, and it is not small: `--all` takes
    minutes of a runner's time per push, the two slow racing suites are most
    of it, and this project's whole claim rests on the suite being run against
    **what is committed** rather than against a copy — which CI does satisfy,
    but so does the owner. It is also a change to what a push costs.

    **Nothing was built or proposed in the workflow file.** If the answer is
    yes, the smallest honest version is the fast suites only, on push, with
    `--all` left to a manual trigger.

28. **The panel layout, which is correct today and eight pixels from not
    being — and the first sentence Genesis shows a player.** Both found while
    writing 065, both left alone because both are judgements about what the
    screen should look like rather than engineering.

    **(a) The eight pixels.** At the base viewport — 1152 x 648, which is
    the tightest the vertical layout can ever be, because under stretch
    `canvas_items`/`expand` the logical height floors at the base size — the
    three panels stack like this:

    | panel | vertical extent | where the number comes from |
    |---|---|---|
    | `HistoryPanel` | 10 .. 250 | absolute offsets, `main.gd:923-926` |
    | `MetricsPanel` | 258 .. 520 | absolute offsets, `main.gd:961` |
    | `CommandPanel` | 528 .. 648 | **content height**, from the bottom edge |

    They do not overlap. But 520 is a number somebody typed into `main.gd`
    and 528 is 648 minus the command panel's 120 px of **content** height —
    the sum of four children's minimum sizes, which moves with the font. One
    extra `Label` in that `VBoxContainer` takes the clearance to **−19 px**,
    measured. The options:

    - **(i) Leave it.** Costs nothing; the suite now fails loudly the day the
      eight pixels go, naming both edges. This is what 065 did.
    - **(ii) Give the metrics panel a bottom anchor** so it ends a fixed
      distance above the command panel instead of at a fixed y. Removes the
      coupling to the font entirely and is a few lines.
    - **(iii) Lay the right-hand panels out in a container** rather than with
      absolute offsets. The most robust and the largest change.

    **Nothing was changed, and (ii) is a proposal and not a plan.** The
    assistant's view, offered as a view: the coupling is real but the failure
    mode is now visible, so this is worth doing when something else touches
    those panels and not on its own account.

    **(b) The placeholder sentence.** `InputBox`'s `placeholder_text` in
    `scenes/main.tscn` is **`"make a race track"`** — the one example Genesis
    shows a player who has never typed anything. HANDOVER 032 records
    *"make me a race track"*, with no sections described, as the request that
    hits Prototype 001's stub: it **clears the world and reports that it built
    nothing**.

    **WHAT IS NOT KNOWN, AND IT IS THE WHOLE QUESTION:** whether the model
    answers that sentence with a sectionless `CREATE_TRACK` or invents
    sections for it. **This was not tested** — the harness has no key, nothing
    was reproduced from the owner's screen, and the suite asserts only that
    the string is what the scene says, never that it is wise. So this is one
    request's worth of typing in the editor, and it answers it:

    - If it comes back as a built circuit, the placeholder is fine and this
      item closes.
    - If it comes back as *"CREATE_TRACK built nothing"*, then **the first
      thing Genesis suggests is the one thing it refuses**, and the fix is one
      string in the scene — something like *"a circuit with two long straights
      and a hairpin"*, which 031 records as working. `scene_ui_test` section 0
      asserts the current value by name, so changing it fails that assertion
      and the new string goes in the same edit.

    It is the owner's because the words a player is shown first are product.

29. **Whether a suite may delete the ledger every copy of this project
    shares.** Found in 066 while measuring the session-id collision, and
    deliberately not changed.

    `tests/session_test.gd` opens by deleting `user://track_log.jsonl`
    outright, so that its own `_log_lines()` walk sees only its own records.
    Every copy of the project shares one `user://` (TRAPS 50) and
    `run_tests.sh` starts sixty-odd processes against it, so **two
    overlapping runs of that suite destroy each other's ledger** — and, while
    it is running, any other suite's records written before the delete.

    **Measured both ways.** Before 066's fix — so for both causes together —
    three paired concurrent runs of `session_test` scored **8 and 8, 8 and 7,
    8 and 8** failures, *both* sides, every pair. After it, two paired runs
    scored **1 and 2, then 1 and 1**, and **the surviving failure is the same
    assertion in every process**: *"all 26 records in the session are tagged
    with the tester"*. `_log_lines()` walks the whole shared file, so the
    other process's untagged records land inside this one's session window.
    **That is the deletion, and a session name cannot fix it.**

    The options:

    - **Leave it.** Nothing in the harness runs two copies of one suite at
      once on purpose; the two overlapping unattended runs of 2026-10-16 are
      the case where it bites, and that is rare.
    - **Stop deleting and read only this session's records**, which is what
      every other ledger-reading suite does (`read_session()` by id). The
      suite's `_log_lines()` walk exists to assert that records *before* the
      session are untagged, which is why it wanted a clean file — so this is
      a real change to what that suite proves, not a one-liner.
    - **Give the suite its own `user://`**, which no suite does today and
      which would be this project's first per-suite project config.

    **It is the owner's because the second option narrows what a suite
    asserts**, and a suite that quietly proves less than it used to is the
    failure mode this whole document exists to prevent.

30. **Whether `tests/` should have a shared library, now that ten suites carry
    byte-identical copies of one function.** Found in 067 while applying the
    comment-stripping rule to the class, and **not** acted on, because the
    convention it would change is the owner's.

    The fact, measured rather than argued: **ten files in `tests/` now define
    `_code_of()` and all ten definitions are byte-identical**, asserted as
    such by `tests/source_scan_test.gd`. That is TRAPS 28's shape — a thing
    written out by hand in many places — and the cost of a copy drifting is a
    source scan that is blind in a way nothing says. The drift assertion is
    what stands in for the library today, and it works: faults 2 and 4 of 067
    were both caught by it.

    Why 067 did not just extract it: **every suite in `tests/` stands alone**,
    which is this project's convention and the reason `run_tests.sh` can run
    any file in that directory as a suite. A shared helper file would be the
    **first** file in `tests/` that is not a suite since `replay` and
    `prompt_test`, so it has to go into `run_tests.sh`'s `NOT_A_SUITE` list
    **and** `run_tests.bat`'s `findstr` patterns — and the `.bat` cannot be
    run here (TRAPS 4 is about exactly that file). A helper that is missed by
    one runner is a suite that prints no result line and reports as a failure
    on Windows only.

    The options:

    - **Leave it.** Ten copies and one assertion that they agree. Costs a
      copy-paste every time an eleventh suite scans source, and the assertion
      catches it the moment it drifts.
    - **A helper in `tests/`**, added to both runners' skip lists. Cheapest
      code, and the one change here that cannot be verified from this
      container.
    - **A helper in `scripts/`.** No runner change at all, because
      `run_tests.sh` only walks `tests/`. But it puts harness-only code into
      the product's own directory, where `layout_key_test` and
      `check_wiring_test` enumerate `scripts/` by reflection and would start
      answering for it.

    **It is the owner's because it is a decision about where the harness
    lives**, and because the only option that is purely mechanical is the one
    whose verification needs a Windows machine.

31. **Whether `FeasibilityGate` should declare the solver's adjustment limit
    or read it.** Found in 068 while asking which numbers in the prompt are
    read from the thing that enforces them, and **not** acted on, because it
    is a decision about which way two modules depend on each other.

    The fact, measured rather than argued: `ClosureSolver.MAX_ANGLE_ADJUSTMENT`
    and `FeasibilityGate.MAX_ANGLE_ADJUSTMENT` are **two declarations of one
    number**, `0.20`. The gate decides which net turns a composition can reach
    from **its** copy, states **its** copy to the player in
    `FAILED_INFEASIBLE`'s third reason, and the prompt states the
    **solver's**. Nothing asserted the two were the same, so moving the
    solver's limit alone would have left the gate refusing compositions the
    solver can close, in a sentence naming the wrong percentage, with every
    suite green. **Nothing is wrong today**; 068 added the assertion, which is
    the part that does not need a decision.

    The options:

    - **Leave both and keep the assertion.** The gate stays readable on its
      own — its header derives the reachable range from the limit in the two
      lines above the constant — and the suite catches a divergence.
    - **The gate reads `ClosureSolver.MAX_ANGLE_ADJUSTMENT`.** One
      declaration, and the assertion becomes unnecessary. It makes the gate,
      which runs **before** anything is solved, name the solver.
    - **Both read a third place.** No new dependency either way, and a new
      file or constant block for one number.

    **It is the owner's because it is about the shape of the pipeline**, not
    about a wrong answer: `check()` runs before any geometry is built, and
    whether the thing that decides feasibility is allowed to know about the
    thing that solves is the sort of ordering decision this project has kept
    deliberate.
