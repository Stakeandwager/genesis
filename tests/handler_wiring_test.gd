extends SceneTree

# --- 058: the handlers the sweep found held by nothing ---
#
# THE TASK, AND WHERE IT CAME FROM
#
# HANDOVER named this as the next assistant task, in these words: "a fixture
# for _on_interpretation_failed, which needs no key and fakes nothing". That
# came out of 057's sweep of main.gd's sixteen connect() calls, which asked
# of each one - if this wiring stopped working tomorrow, would any suite say
# so? - and found FIVE of the seven it measured held by NOTHING:
#
#   75  interpretation_ready  -> _on_interpretation_ready   NOT HELD
#   76  interpretation_failed -> _on_interpretation_failed   NOT HELD
#   77  retrying              -> _on_ai_retrying             NOT HELD
#   79  track_measured        -> _on_track_measured          NOT HELD
#   81  equipped              -> _on_equipped                NOT HELD
#
# All five are one layer: the handlers that turn a verdict into WHAT THE
# PLAYER SEES. The suite held the verdicts thoroughly and held nothing about
# whether any of it is ever shown. main.gd:993 is the ONLY production caller
# of WorldRegistry.panel_lines() - grepped across scripts/, and still true.
#
# AND HANDOVER'S WORDING FOR WHAT THAT COST IS WRONG, which this file says
# rather than repeating (TRAPS 14). It reads "every panel suite passes with
# the measurements panel permanently BLANK". Measured here with the connect
# wired out: the panel is never blank. _build_metrics_panel() writes a
# placeholder line into it at main.gd:978 - "Build a composed track to see
# its measurements." - and with the handler disconnected that line is what
# stays there for the whole session, under a heading that says TRACK
# MEASUREMENTS. Not blank: permanently wrong, which is worse, and which an
# assertion that the panel is "not blank" cannot tell from a measurement.
# This file made that mistake in its second draft; see the panel section.
#
# THIS FILE DOES THE CLASS AND NOT THE ONE HANDOVER NAMED (TRAPS 11). Fixing
# one member of a list is not fixing the list. Asked of all five, the honest
# split is THREE AND TWO, and it is a fact about the emits rather than a
# judgement:
#
#   REACHABLE HERE, AND HELD BY THIS FILE:
#     _on_interpretation_failed - _send() refuses before any network, twice
#     _on_track_measured        - emitted from ten places in the
#                                 controller, grepped, two of which this
#                                 file walks: an accepted build and a
#                                 refusal. NOT "every world command": that
#                                 was not measured and is not claimed.
#     _on_equipped              - emitted at game_controller.gd:622, the
#                                 line after an accepted tool spec is
#                                 stored in `kit`
#
#   NOT REACHABLE HERE, AND NOT FAKED (TRAPS 52):
#     _on_interpretation_ready - its ONLY emit is inside _on_request_completed
#     _on_ai_retrying          - its ONLY emit is inside _try_again, which
#                                _on_request_completed calls
#   Both need an answer from the model, which needs a key this harness does
#   not have. They are left unheld, and the asymmetry that makes the third
#   one holdable is ASSERTED MECHANICALLY off the interpreter's own source
#   at the bottom of this file, so that the day someone adds a key-free emit
#   of either, this file says a fixture has become possible.
#
# WHAT IS SET BY HAND, SAID PLAINLY, BECAUSE HANDOVER PREDICTED "NOTHING"
#
# HANDOVER's sketch said the fixture would fake nothing. It is nearly true
# and not quite, and the reason is worth more than the claim:
#
#   main._handle_request() REFUSES before it can reach interpret() when
#   there is no key - "No API key - type raw JSON instead." at main.gd:192,
#   which is is_available() answering false at main.gd:193-195. So the
#   no-key door cannot be entered from the top. This fixture enters one level in, at
#   interpreter.interpret(), exactly as check_wiring_test._send_as_ai()
#   enters at _execute_json() and for the same reason, and sets
#   pending_request first because that is the one thing _handle_request
#   would have done on the way past (main.gd:181).
#
#   Everything after that is real: the real refusal, the real emit, the real
#   signal, the real connect, the real handler.
#
#   The SECOND door - _send()'s OTHER key-free refusal, the busy one - was
#   expected to be walkable from the top, and is not. main.gd:177 checks
#   interpreter.busy and refuses first, with its own sentence. So that door
#   is entered the same way, one level in, with busy = true set by hand; the
#   suite asserts BOTH halves, main.gd's guard firing first and the
#   interpreter's guard reaching the handler when it is entered where a
#   caller that does not check busy enters it. Nothing is posted and the
#   suite asserts that from last_body, which _send() fills only after both
#   guards. See section 2.
#
# AND THE LEDGER ASSERTION HANDOVER SKETCHED NEEDED A SESSION, which that
# sketch did not mention. TrackLog.event() returns at its first line when no
# session is running (track_log.gd:59), so the ai_unavailable record the
# handler writes does not exist outside a session. A fixture that asserted
# it without starting one would have been asserting the absence of a file
# write and passing. This file starts a session with /session and clears
# TrackLog.session at the end rather than running /session end, which would
# print a report this file has nothing to say about.
#
# RUN AGAINST BROKEN CODE BEFORE IT WAS BELIEVED (TRAPS 51), and what that
# means here exactly, because "every assertion was proved able to fail"
# would be a bigger claim than was earned: THIRTEEN deliberate faults, one
# at a time, each in a throwaway copy outside the repository with its own
# config/name so it could not share user:// with anything (TRAPS 50), and
# the FAIL lines READ rather than counted. They are listed in HANDOVER's 058
# section with what each one caught. The three connects were wired out one
# at a time and each failed only its own section; two of the thirteen found
# faults in THIS FILE rather than in the code, which is why the panel
# section reads the way it does.

var main: Node3D
var asserted := 0
var bad := 0
var notes: Array = []

# 066: the session name carries THIS PROCESS, and that is not decoration.
#
# It was the bare string "handler_wiring" until 066, and a bare string is a
# name a second writer can also have. The session id main.gd mints is
# "<name> <datetime to the second>" (main.gd:515), so two processes running
# this suite inside one wall-clock second mint the SAME session id - and
# _session_records() reads records back by that id, out of a user:// every
# copy of this project shares (TRAPS 50). Measured, not reasoned about: six
# paired concurrent runs against one ledger, and in FIVE of the six one of
# the pair failed "the ledger gained exactly one ai_unavailable event (got
# 3)" and then returned early, scoring 44 assertions where a clean run
# scores 47. A varying assertion count under a treatment that cannot reach
# the suite is TRAPS 56's signature exactly, and that is the trap that cost
# 059 a day of sweep measurements.
#
# OS.get_process_id() is the fix TRAPS 56 names: a clock is not an identity
# at any granularity, because the question is not how precise it is but
# whether two writers can read the same value. See record_id_test section 4,
# which holds this rule for every suite in tests/ rather than for this one.
var session_name := "handler_wiring-%d" % OS.get_process_id()
# What _build_metrics_panel() writes into the panel at main.gd:978, before
# anything is measured. Kept here because an assertion that the panel is
# merely "not blank" cannot tell this apart from a real measurement, and the
# first draft of this file made exactly that mistake.
const PLACEHOLDER := "Build a composed track to see its measurements."
# A boots spec every field of which is inside BootsTool's bounds and none of
# which is a default, so that a body still wearing the defaults cannot pass
# for a body that was re-equipped.
const BOOTS := {
	"push": 400.0,
	"weight": 70.0,
	"footing": 0.9,
	"turning": 30.0,
	"brake": 600.0,
	"colour": "red",
}


func _check(ok: bool, what: String) -> void:
	asserted += 1
	if ok:
		print("PASS  ", what)
	else:
		bad += 1
		print("  FAIL  ", what)


func _initialize() -> void:
	_run.call_deferred()


# --- the harness: the real main.gd, as check_wiring_test stands it up ---

# 061: the scene the game launches, loaded rather than hand-built.
#
# This function used to build a stand-in tree by hand and name each node what
# main.gd's @onready lines ask for, so the fixture SUPPLIED the names the
# suite then proved were there (TRAPS 57). 061 walked both trees and
# enumerated twelve differences between that stand-in and scenes/main.tscn -
# a missing light, environment and TitleLabel, a Ground that was a Node3D
# where the scene has a StaticBody3D, a ground slab a metre lower with
# collision the scene has not got, a camera at a different place and angle,
# an unanchored panel, three unset strings and the child order of six nodes.
# What this suite measures is now measured against the tree the game has.
#
# The scene is resolved through ProjectSettings rather than by path, so no
# suite can end up holding a scene that is no longer the game's; the setting
# itself is asserted in player_door_test.
func _make_main() -> void:
	main = load(str(ProjectSettings.get_setting("application/run/main_scene"))).instantiate()
	get_root().add_child(main)


# Every record this session's ledger holds, oldest first.
func _session_records() -> Array:
	return TrackLog.read_session(str(TrackLog.session.get("id", "")))


func _events_named(name: String) -> Array:
	var out: Array = []
	for record in _session_records():
		var r: Dictionary = record
		if str(r.get("event", "")) == name:
			out.append(r)
	return out


func _history() -> String:
	return main.history_log.get_parsed_text()


func _panel() -> String:
	return main.metrics_log.get_parsed_text()


# Between sections, so that ONE fault cannot look like three.
#
# _on_interpretation_failed is the handler that clears `revising`, and
# main.gd refuses every typed request while `revising` is true (main.gd:166).
# So wiring THAT connect out leaves this file unable to send anything at
# all, and the track_measured and equipped sections fail for a reason that
# has nothing to do with their own wiring.
#
# MEASURED, NOT ASSUMED, AND THE NUMBERS ARE SMALL ON PURPOSE: the first
# run of the interpretation_failed wire-out scored TEN failures spread
# across all four sections. With this reset in place the same wire-out
# scores EIGHT, all of them in the two sections about that handler. The two
# it removed were the track_measured and equipped sections reporting a
# fault that was not theirs - one fault reading as three.
#
# It is harness state and not a verdict. Section 1 asserts `revising` was
# cleared and that `busy` is false, and both of those run before this is
# ever called; section 2 sets `busy` itself, deliberately, after it.
func _reset_between() -> void:
	main.revising = false
	main.interpreter.busy = false
	main.interpreter.api_key = ""


# --- 1. _on_interpretation_failed, through the key guard ---
#
# The door a desktop build with no key walks. Nothing is faked: api_key is
# "" because there is no api_key.txt, which is the real state of this
# container, and _send() refuses for exactly that reason.
func _failed_handler_no_key() -> void:
	var before: int = _history().length()
	var request := "a dungeon with a hall and a vault"

	# The handler clears this. Set it so the assertion that it was cleared
	# can fail; left true, main refuses every later request in this file.
	main.revising = true
	main.interpreter.api_key = ""
	main.pending_request = request
	main.interpreter.interpret(request)
	await process_frame

	var reason := "No API key found in api_key.txt."
	_check(main.status_label.text == reason,
		"the status line carries the refusal the interpreter emitted: " + main.status_label.text)
	_check(not main.revising,
		"and the handler cleared `revising`, so the next request is not refused as a pending revision")
	_check(not main.interpreter.busy,
		"and no request was put on the wire")

	var gained := _history().substr(before)
	_check(gained.contains(request),
		"the history panel gained the request the player typed")
	_check(gained.contains(reason),
		"and the reason, against it")

	var events := _events_named("ai_unavailable")
	_check(events.size() == 1,
		"the ledger gained exactly one ai_unavailable event (got %d)" % events.size())
	if events.size() != 1:
		return
	var event: Dictionary = events[0]
	_check(str(event.get("request", "")) == request,
		"and it records WHICH request was lost: " + str(event.get("request", "")))
	_check(str(event.get("reason", "")) == reason,
		"and the same reason the player was shown, not a second wording")
	# attempts_of_last() returns `attempt`, and _send() returns at its key
	# guard BEFORE `attempt = 1`. So a request refused before anything was
	# tried records 0 tries, which is the honest number and not an off-by-one.
	_check(int(event.get("attempts", -1)) == 0,
		"and 0 attempts, because the request was refused before one was made")
	notes.append("interpretation_failed, no-key door: status, history and ledger all carry the same refusal")


# --- 2. the busy guard: the same handler, and a finding this suite's own
#        first draft walked into ---
#
# THE FIRST DRAFT OF THIS FUNCTION ASSUMED _handle_request COULD REACH
# _send()'s OTHER key-free emit, the busy one, and asserted it. It failed,
# and the reason is the finding:
#
#   main.gd:177 CHECKS interpreter.busy AND REFUSES FIRST, with its own
#   sentence - "Still thinking about the last request..." - which differs
#   from the interpreter's by an ellipsis instead of a full stop. So the
#   typed-request door never reaches ai_interpreter.gd:345 at all, and the
#   handler does not run: no status line from it, no history entry, no
#   ledger event.
#
# ONE CONDITION, TWO DECIDERS, which is 057's shape exactly - there the key
# rule had five deciders and the fifth one was wrong. Nothing is wrong here:
# the player is told the right thing, by main.gd. What is true is that the
# interpreter's busy sentence has one production door left (revise(), at
# main.gd:418, which does not check busy), and that two sentences for one
# condition is how the next wrong one gets written. Recorded in HANDOVER as
# a candidate rather than changed here, because the behaviour is correct and
# the smallest complete change to it is none.
#
# So this holds BOTH halves as facts: main.gd's guard fires first and the
# handler does not run; and, entered where it can be entered, the
# interpreter's own guard does reach the handler with a second reason, which
# is what proves the handler is not hard-coded to the no-key sentence.
func _failed_handler_busy() -> void:
	var request := "a farm with a barn"
	main.interpreter.last_body = {}
	main.interpreter.busy = true
	var before: int = _events_named("ai_unavailable").size()

	# (a) the typed-request door, which main.gd refuses first.
	main._handle_request(request)
	await process_frame
	_check(main.status_label.text == "Still thinking about the last request...",
		"while the AI is busy, main.gd refuses a typed request with ITS sentence: " + main.status_label.text)
	_check(_events_named("ai_unavailable").size() == before,
		"and the handler did not run, so ai_interpreter.gd:345 is not reachable from the typed door")
	_check(main.interpreter.last_body.is_empty(),
		"and _send() was never entered")

	# (b) entered where a caller that does not check busy enters it, which is
	# what revise() does. One field is set by hand - busy - and the refusal,
	# the emit, the signal, the connect and the handler are all real.
	main.pending_request = request
	main.interpreter.interpret(request)
	await process_frame

	var reason := "Still thinking about the last request."
	_check(main.status_label.text == reason,
		"the interpreter's own busy guard reaches the same handler with a DIFFERENT reason: " + main.status_label.text)
	# _send() fills last_body only after BOTH guards, and _post() is the line
	# after. An empty body is proof the function returned before either.
	_check(main.interpreter.last_body.is_empty(),
		"and _send() returned before it built a request, so nothing could be posted")

	var events := _events_named("ai_unavailable")
	_check(events.size() == before + 1,
		"the ledger gained one more ai_unavailable event (got %d)" % (events.size() - before))
	if events.size() == before + 1:
		var event: Dictionary = events[events.size() - 1]
		_check(str(event.get("reason", "")) == reason,
			"and it carries the busy reason, not the no-key one - so the handler says back what it was given")
		_check(str(event.get("request", "")) == request,
			"and the request it was lost on")

	main.interpreter.busy = false
	notes.append("interpretation_failed: two reasons through two guards, and main.gd's own guard stands in front of one of them")


# --- 3. _on_track_measured, which draws the measurements panel ---
#
# 057: main.gd:993 is the ONLY production caller of
# WorldRegistry.panel_lines(). panel_refused_test, panel_built_test and
# panel_geometry_test all call it directly, and every one of them passes
# with the panel permanently blank. This asserts the panel against the
# record the SIGNAL carried, so the decisions and the drawing are held
# together.
func _measurements_panel() -> void:
	# NOT "the panel is blank at launch", and NOT "the panel is not blank"
	# either - both were written here and both were wrong.
	#
	# main.gd stands a starter circuit up in _ready() and that build emits
	# track_measured, so the handler has already run once before this suite
	# sends anything. The first draft asserted the panel was BLANK and
	# failed. The second asserted it was NOT blank and PASSED WITH THE
	# CONNECT WIRED OUT - because _build_metrics_panel() writes a placeholder
	# line into it at main.gd:978, so the panel is never blank at all. The
	# assertion was vacuous and the sentence beside it was a false claim
	# about what it proved (TRAPS 14).
	#
	# What tells the two states apart is WHICH line is there: the
	# placeholder, or panel_lines()' own first line for the starter circuit.
	# And the placeholder above is a string typed out in two files, which is
	# TRAPS 28's shape. Checked against main.gd's own source rather than
	# trusted, so it cannot drift into a constant that matches nothing and
	# makes the assertion below pass for free.
	var main_src := FileAccess.open("res://scripts/main.gd", FileAccess.READ)
	_check(main_src != null, "main.gd's source can be read")
	if main_src != null:
		var text := main_src.get_as_text()
		main_src.close()
		_check(text.contains(PLACEHOLDER),
			"the placeholder this file looks for is the one main.gd writes")

	var at_launch := _panel()
	_check(not at_launch.contains(PLACEHOLDER),
		"the placeholder _build_metrics_panel() wrote is gone, so something replaced it")
	_check(at_launch.contains("REQUESTED"),
		"and what replaced it is panel_lines()' first line - the handler ran at launch, for the starter circuit")

	var seen: Array = []
	var listener := func(record: Dictionary) -> void: seen.append(record)
	main.controller.track_measured.connect(listener)

	main._handle_request('{"command": "CREATE_DUNGEON", "parameters": {"rooms": [{"name": "hall", "width": 12, "depth": 12}, {"name": "vault", "width": 10, "depth": 10}], "doors": [[1, 2]]}}')
	await process_frame
	await process_frame

	_check(seen.size() >= 1,
		"a world command emits track_measured (got %d)" % seen.size())
	if seen.is_empty():
		main.controller.track_measured.disconnect(listener)
		return

	var built := _panel()
	_check(built != at_launch,
		"and the panel changed, so what is on it is this build and not the last one")
	# The strong form: every line panel_lines() produced for the record the
	# signal carried is IN the panel, in order. Wire the connect out and
	# panel_lines() still answers; the panel is empty and this fails.
	var record: Dictionary = seen[seen.size() - 1]
	var lines: Array = WorldRegistry.panel_lines(record)
	_check(lines.size() > 0,
		"panel_lines() has something to say about that record (%d lines)" % lines.size())
	var at := 0
	var in_order := true
	var missing := ""
	for line in lines:
		var entry: Dictionary = line
		var label := str(entry["label"])
		var value := str(entry["value"])
		var want := (label + "   " + value) if label != "" else value
		var found := built.find(want, at)
		if found < 0:
			in_order = false
			if missing == "":
				missing = want
			break
		at = found + want.length()
	_check(in_order,
		"and the panel shows every one of them, in order" if in_order else "the panel is missing panel_lines()' line: " + missing)
	# One measured line named outright, so that the assertion above cannot go
	# quietly vacuous if panel_lines() ever returns an empty list.
	_check(built.contains("ROOMS") and built.contains("doors 1"),
		"including the measured line a player reads: the room and door count")

	# The refusal shape, and that the panel is CLEARED between the two. The
	# handler's first line is metrics_log.clear(); without it the dungeon's
	# measurements would still be on screen beside a refusal of something
	# else.
	seen.clear()
	main._handle_request('{"command": "EQUIP", "parameters": {"tool": "look", "spec": {"skin": "chartreuse"}}}')
	await process_frame
	await process_frame
	var refused := _panel()
	_check(seen.size() >= 1,
		"a refused command emits track_measured too (got %d)" % seen.size())
	_check(refused.contains("FAILED") and refused.contains("REASON"),
		"and the panel states the refusal and its reason")
	_check(not refused.contains("ROOMS"),
		"and the dungeon's measurements are GONE, because the handler clears the panel first")
	main.controller.track_measured.disconnect(listener)
	notes.append("track_measured: the panel matches panel_lines() line for line, for a built world and a refusal")


# --- 4. _on_equipped, which is the only way kit reaches a body already up ---
#
# 057: this is the only place a tool spec reaches a body that is already
# standing. boots_test, tool_test and look_test test the tool modules at
# their own door. The handler's branches are each guarded on a node being
# non-null and in the harness there is usually no walker, so a suite could
# reach this handler and observe nothing. A body has to be stood up first.
func _equipped_handler() -> void:
	main._run_local_command("/explore")
	await process_frame
	_check(main.walker != null and main.exploring,
		"a body is standing in the dungeon, so the handler's walker branch is not a no-op")
	if main.walker == null:
		return

	var walker: Walker = main.walker
	_check(is_equal_approx(walker.push, BootsTool.DEFAULT_PUSH) and is_equal_approx(walker.mass, BootsTool.DEFAULT_WEIGHT),
		"and it is wearing the default boots, so a change is a change")

	main._handle_request('{"command": "EQUIP", "parameters": {"tool": "boots", "spec": %s}}' % JSON.stringify(BOOTS))
	await process_frame
	await process_frame

	_check(is_equal_approx(walker.push, float(BOOTS["push"])),
		"the EQUIP reached the standing body: push is now %.0f" % walker.push)
	_check(is_equal_approx(walker.mass, float(BOOTS["weight"])),
		"and its weight")
	_check(is_equal_approx(walker.drag, float(BOOTS["footing"])),
		"and its footing")
	_check(is_equal_approx(walker.turn_push, float(BOOTS["turning"])),
		"and its turning")
	_check(is_equal_approx(walker.brake, float(BOOTS["brake"])),
		"and its brake")
	# The one field no spec mentions. run_push is derived inside
	# Walker.equip() from push and BootsTool.RUN_RATIO, so it cannot have
	# arrived by the kit being stored somewhere: equip() ran.
	_check(is_equal_approx(walker.run_push, float(BOOTS["push"]) * BootsTool.RUN_RATIO),
		"and run_push, which no spec carries, is push x RUN_RATIO - so Walker.equip() itself ran")
	_check(walker.colour.is_equal_approx(BootsTool.COLOURS[str(BOOTS["colour"])]),
		"and the body is the colour that was asked for")

	# The look branch, which reaches the same body through wear() rather than
	# equip(). A second member of the handler's list, not a second assertion
	# about the first.
	var before_skin: Color = walker.skin
	main._handle_request('{"command": "EQUIP", "parameters": {"tool": "look", "spec": {"skin": "grey"}}}')
	await process_frame
	await process_frame
	_check(not walker.skin.is_equal_approx(before_skin) and walker.skin.is_equal_approx(LookTool.SKINS["grey"]),
		"and a look spec reaches the same standing body through wear()")
	notes.append("equipped: both branches that can reach a standing body were reached, and the derived field moved")


# --- 5. the two that need a key, and the fact that makes them different ---
#
# Not a fixture and not a fake. This reads the interpreter's own source and
# asserts the asymmetry 057 found, so that the day it stops being true this
# file says so. _send() is the only emitting function a request with no key
# can reach; what it emits decides which of these three handlers a harness
# can hold at all.
func _why_two_are_unreachable() -> void:
	var file := FileAccess.open("res://scripts/ai_interpreter.gd", FileAccess.READ)
	_check(file != null, "the interpreter's source can be read")
	if file == null:
		return
	var source := file.get_as_text()
	file.close()

	# Which function is each emit of each signal in?
	var holders := {"interpretation_ready": [], "interpretation_failed": [], "retrying": []}
	var fn := ""
	for raw in source.split("\n"):
		var line := str(raw)
		if line.begins_with("func "):
			fn = line.substr(5, line.find("(") - 5)
		for name in holders:
			if line.contains(str(name) + ".emit(") and not line.strip_edges().begins_with("#"):
				(holders[name] as Array).append(fn)

	var ready: Array = holders["interpretation_ready"]
	var retry: Array = holders["retrying"]
	var failed: Array = holders["interpretation_failed"]

	_check(ready.size() > 0 and not ready.has("_send") and not ready.has("_post"),
		"every emit of interpretation_ready is past the network: %s" % str(ready))
	_check(retry.size() > 0 and not retry.has("_send") and not retry.has("_post"),
		"every emit of retrying is past the network: %s" % str(retry))
	_check(failed.has("_send"),
		"interpretation_failed is the only one of the three _send() emits, which is why it alone is held above")
	_check(ready.size() + retry.size() > 0,
		"neither signal has been deleted, so the two rows left unheld still exist")

	# The wire, not the behaviour, and labelled so nobody reads it as more.
	# These two handlers cannot be held by this harness at all; asserting the
	# connect is the only thing left, and it proves only that the connect is
	# there.
	_check(main.interpreter.interpretation_ready.is_connected(Callable(main, "_on_interpretation_ready")),
		"WIRE ONLY: interpretation_ready is connected (its behaviour is NOT held by anything)")
	_check(main.interpreter.retrying.is_connected(Callable(main, "_on_ai_retrying")),
		"WIRE ONLY: retrying is connected (its behaviour is NOT held by anything)")
	notes.append("interpretation_ready and retrying remain unheld, and the source says why rather than this file claiming it")


func _run() -> void:
	_make_main()
	await process_frame
	await process_frame

	main._run_local_command("/session " + session_name)
	await process_frame
	_check(not TrackLog.session.is_empty(),
		"a session is running, without which TrackLog.event() writes nothing at all")

	print("--- interpretation_failed, through the key guard ---")
	await _failed_handler_no_key()
	print("--- the busy guard, and main.gd's own guard in front of it ---")
	await _failed_handler_busy()
	_reset_between()
	print("--- track_measured, the measurements panel ---")
	await _measurements_panel()
	_reset_between()
	print("--- equipped, a body already standing ---")
	await _equipped_handler()
	print("--- the two that need a key ---")
	_why_two_are_unreachable()

	TrackLog.session = {}
	for note in notes:
		print("  ", note)
	print("HANDLER WIRING %d assertions, failures=%d" % [asserted, bad])
	quit(bad)
