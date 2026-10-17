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

- Last commit at the time of writing: **058**, the task this file named as
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

64 files in `tests/`, of which `replay` and `prompt_test` are tools rather
than suites, leaving **62 suites**, counted with `ls tests/*.gd` rather than
remembered, and since 024 every one of them runs — nothing is skipped as
broken. `--all` adds the two slow racing suites.

**RUN THEM ONE AT A TIME.** Every copy of this project has the same
`config/name` in `project.godot`, and Godot derives `user://` from it — so
every copy shares one `user://track_log.jsonl` and one `user://worlds`. Two
runs at once, on one machine, read and write each other's ledger and saved
worlds, and suites fail for reasons that have nothing to do with the code.
055 took four answers off such a run before noticing. If a run is being used
as a measurement, clear `user://` before it, baseline included (TRAPS 50).

Last full run (057, Godot 4.7.1 on Linux —
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

**Still the owner's, and still a minute's work — but it would NOT have
worked before 057, and that is new information.** The proxy is built (020):
set `GEMINI_API_KEY` in the Netlify site's environment variables, and set
`NETLIFY_AUTH_TOKEN` and `NETLIFY_SITE_ID` as GitHub secrets so a push
deploys. After that, a stranger with the link can type a sentence and get a
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

1. **The seven rows still `NOT_ASKED`** — unchanged by 058, which added no
   `connect()` and removed none. Same method, a few at a time; budget for it
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
