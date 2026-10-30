extends SceneTree

# 026 - a busy model is not a refusal.
#
# The owner, after a session of them: "the 503 request is terrible". Gemini's
# 503 means "this model is overloaded right now". Genesis made exactly ONE
# attempt, and on the first 503 told the player the AI service was busy and
# to try again - which is a transient condition reported as a verdict, and
# therefore the same mistake as every other entry in docs/TRAPS.md: a claim
# made on evidence that does not support it. One sample is not a measurement.
#
# WHAT THIS SUITE IS AND IS NOT
# It asserts the DECISION - which failures are worth repeating, how long the
# waits are, that the repeated request is identical - because that is the part
# with a right answer. It cannot assert that a retry fixes a real 503: that
# needs Google, a key and an overloaded model, none of which a headless
# harness has. So the network half is explicitly NOT verified, and the commit
# message says so.
#
# The distinction below is the whole design. Repeating a request that will
# always fail wastes the player's time and buries the real cause under three
# identical errors.

var bad := 0
var asserted := 0


func _check(ok: bool, what: String) -> void:
	asserted += 1
	print(("PASS  " if ok else "FAIL  ") + what)
	if not ok:
		bad += 1


func _initialize() -> void:
	_what_is_worth_repeating()
	_what_is_not()
	_the_waits()
	_the_message_a_player_ends_up_with()
	_every_branch_of_the_http_message()
	_the_record()

	print("RETRY TEST %d assertions, failures=%d" % [asserted, bad])
	quit(1 if bad > 0 else 0)


# --- transient: the same request may well work in a second ---
func _what_is_worth_repeating() -> void:
	for code in [429, 500, 502, 503, 504]:
		_check(AIInterpreter.WORTH_RETRYING.has(code),
			"HTTP %d is retried: the model being busy says nothing about the request" % code)
	_check(AIInterpreter.WORTH_RETRYING.has(503),
		"503 above all, which is the one the owner was looking at")


# --- permanent: wrong on the fourth attempt too ---
#
# This half is the one that keeps the feature honest. A retry on a bad key
# turns one clear "the API key was refused" into three of them spread over
# four seconds, which is strictly worse than failing at once.
func _what_is_not() -> void:
	var permanent := {
		400: "the request format is wrong",
		401: "the key is missing",
		403: "the key was refused",
		404: "the model name is out of date",
	}
	for code in permanent:
		_check(not AIInterpreter.WORTH_RETRYING.has(code),
			"HTTP %d is NOT retried: %s" % [code, str(permanent[code])])

	# A 200 is not a failure at all, so it is not in the list either.
	_check(not AIInterpreter.WORTH_RETRYING.has(200), "200 is not in the retry list")


# --- how long a player waits ---
#
# Three attempts and no more. Somebody is sitting in front of a text box
# waiting for a world; a fourth attempt is another few seconds of silence that
# a person reads as "broken" anyway.
func _the_waits() -> void:
	_check(AIInterpreter.MAX_ATTEMPTS == 3,
		"three attempts, not more: %d" % AIInterpreter.MAX_ATTEMPTS)

	# The doubling, computed the same way _try_again computes it, so the
	# arithmetic is asserted rather than described in a comment.
	var total := 0.0
	var waits := PackedStringArray()
	for a in range(2, AIInterpreter.MAX_ATTEMPTS + 1):
		var wait: float = AIInterpreter.FIRST_WAIT * pow(2.0, float(a - 2))
		waits.append("%.1fs" % wait)
		total += wait + AIInterpreter.JITTER
	print("      waits before attempts 2..%d: %s" % [AIInterpreter.MAX_ATTEMPTS, ", ".join(waits)])
	_check(total < 6.0, "the whole thing is over inside 6 seconds, worst case %.1fs" % total)
	_check(total > 1.0, "but it does actually wait: %.1fs" % total)
	_check(AIInterpreter.JITTER > 0.0,
		"with jitter, because a model that is overloaded is overloaded for everybody and a fixed delay syncs every client onto the same second")


# --- what the player is told when it really is down ---
func _the_message_a_player_ends_up_with() -> void:
	var interpreter := AIInterpreter.new()

	var busy := interpreter._friendly_http_error(503)
	print("      %s" % busy)
	# It must not invite the player to do by hand what has just been done for
	# them three times.
	_check(busy.contains("tried %d times" % AIInterpreter.MAX_ATTEMPTS),
		"the 503 message says Genesis already tried, and how often")
	_check(busy.contains("503"), "and keeps the code, for anybody reading the log")

	var refused := interpreter._friendly_http_error(403)
	_check(not refused.contains("tried"),
		"but a refused key does not claim retries that never happened: '%s'" % refused)
	_check(refused.contains("api_key.txt"), "it names the file to look at instead")

	var unknown := interpreter._friendly_http_error(418)
	_check(unknown.contains("418"), "an unexpected code is reported with its number")
	interpreter.free()


# --- a retry is an observation, and gets recorded ---
#
# Not for tidiness: a rising attempt count is the only warning Genesis gets
# that the model underneath it is degrading, and the whole project is built on
# recording what actually happened rather than what was hoped.
func _the_record() -> void:
	var interpreter := AIInterpreter.new()
	_check(interpreter.attempts_of_last() == 0, "no request yet, so no attempts")

	var described := interpreter.describe()
	_check(described.has("model"), "the record already says which model answered")
	_check(str(described["model"]) != "", "by name: %s" % str(described["model"]))
	_check(described.has("prompt_version"),
		"and which prompt, so a model change cannot be mistaken for a prompt change")

	# The signal the UI listens to, so a retry is visible rather than a pause.
	_check(interpreter.has_signal("retrying"), "a retry is announced, not silent")
	interpreter.free()


# --- 092: every branch of the HTTP message, driven off the function's own arms ---
#
# WHY THIS IS HERE. 091a named `experiment_runner.gd:140` as the one refusal
# producer outside both reach tables - it writes `"reasons": [reason]`, where
# `reason` is whatever a failed interpret call said - and left a READING as the
# first step, not a check (TRAPS 6). The reading is done and the answer is
# that `reason` CANNOT arrive empty: `ai_interpreter.gd` emits
# `interpretation_failed` at ten places, nine of them non-empty literals, and
# the tenth is `_friendly_http_error(code)`, whose every branch returns one too.
# All fourteen codes driven came back non-empty. So no assertion was added
# about an empty `reason`; there is no fault there to hold.
#
# WHAT THE READING FOUND ON THE WAY IS WHY THIS FUNCTION EXISTS, and it was
# measured one fault at a time, each alone in its own copy with its own
# `config/name` (TRAPS 50, TRAPS 80), against the 091a tree, every other suite
# run after each:
#
#   400 branch made to say nothing         nothing noticed      SILENT
#   404 branch made to say nothing         nothing noticed      SILENT
#   400 branch made to say "(HTTP 500)"    nothing noticed      SILENT
#   429 branch made to say nothing         agreement_test       caught
#   default branch made to say nothing     retry_test, via 418  caught
#
# And the 429 catch is not this property being held. `agreement_test` COUNTS
# the occurrences of `Readback.plural(MAX_ATTEMPTS, "time")` in the source and
# found one where it wanted two: the plural idiom being counted, not the
# sentence being read. That is the same accidental catch 091 found sitting
# behind `FAILED_PLACEMENT`.
#
# SO THE CHECK IS ON THE CLASS AND NOT ON THE TWO SILENT MEMBERS (TRAPS 11),
# and the codes are read OFF the `match` arms rather than listed here
# (TRAPS 82): an arm added to the function is driven by this suite from the
# moment it is added, and fails it until it says something.
#
# THE SECOND HALF - "and it names the code that arrived" - IS NOT TIDINESS.
# Three of the six arms write their code as a LITERAL (`(HTTP 400)`,
# `(HTTP 404)`, `(HTTP 429)`) instead of through `% code`, and the
# `500, 502, 503, 504` arm is the standing proof that an arm can gain a second
# code. The day one of those three does, its sentence starts naming a code
# that did not happen - which is the injection above that nothing noticed.
func _every_branch_of_the_http_message() -> void:
	var f := FileAccess.open("res://scripts/ai_interpreter.gd", FileAccess.READ)
	_check(f != null, "the interpreter's source opened, so the arms below were read and not typed out here")
	if f == null:
		return
	# Through _code_of(), which is this project's convention for every suite
	# that reads source: a scan a comment can satisfy is not a check, and
	# source_scan_test holds that every scanner in tests/ defines its own
	# byte-identical copy because tests/ has no shared library. This suite
	# joined that class with 092 and is named in its KNOWN list.
	var body := _function_body(_code_of(f.get_as_text()), "func _friendly_http_error(code: int) -> String:")
	f.close()
	_check(body != "", "and _friendly_http_error is still in it, under that name")

	var codes := _arm_codes(body)

	# A reader that found nothing would pass every loop below by never running
	# it (TRAPS 75), so it is tied to something the code already states rather
	# than to a number written beside it. Every retried code must have its own
	# arm: that is 026's whole point - a player told the service is busy has to
	# be told Genesis already tried, and the generic default does not say it.
	_check(AIInterpreter.WORTH_RETRYING.size() > 0, "there is a retry list to tie the reader to")
	for code in AIInterpreter.WORTH_RETRYING:
		_check(codes.has(int(code)),
			"HTTP %d is retried, so it has its own arm rather than falling to the generic message" % code)
	print("      _friendly_http_error names %d codes across its arms: %s" % [codes.size(), str(codes)])

	# The reader held by its own probes, positive and negative, the way
	# proxy_test holds its comment stripper.
	# 067's pair, beside the scan: prose in, nothing out; code in, the needle
	# out. Held twice over, because an arm can be hidden by a comment in two
	# ways and _code_of() and the pattern each catch one.
	_check(not _code_of("\t\t# 418:\n").contains("418"),
		"a commented-out arm is blanked before the pattern ever sees it")
	_check(_code_of("\t\t418:\n").contains("418"),
		"while a real one survives _code_of(), so the reader is not passing by seeing nothing")
	_check(not _arm_codes("\t\t# 418:\n\t\tvar x := 1\n").has(418),
		"and the pattern rejects it too, if it ever arrives unstripped")
	_check(_arm_codes("\t\t418, 419:\n") == [418, 419],
		"while a real two-code arm gives both, in order")
	_check(_arm_codes("\t\tvar d := {}\n\t\tif x:\n").is_empty(),
		"and a line that ends in a colon without being an arm gives nothing")

	var interpreter := AIInterpreter.new()
	# 599 matches no arm, so the default is driven too. It is the one branch
	# with no arm to be read off, which is why it is named here.
	var driven := codes.duplicate()
	driven.append(599)
	for code in driven:
		var said: String = interpreter._friendly_http_error(int(code))
		_check(said.strip_edges() != "", "HTTP %d gets a sentence that says something" % code)
		_check(said.contains(str(code)),
			"and it names the code that arrived rather than one beside it: '%s'" % said)
	interpreter.free()


# The arms of a `match` on an integer, as a flat list of codes in source order.
# Only a line whose whole head is digits and commas counts, so a comment, a
# dictionary entry and an `if` cannot be mistaken for one - asserted above
# rather than assumed. That is the SECOND guard and not the first: the body
# handed in here has already been through _code_of(), which is this project's
# convention and is held by source_scan_test. An earlier draft of this
# function had the pattern INSTEAD of _code_of() and said so in a comment
# citing TRAPS 86 - that comment was wrong, source_scan_test went red by name
# on the first full run, and the episode is TRAPS 89.
static func _arm_codes(body: String) -> Array:
	var out: Array = []
	for raw in body.split("\n"):
		var line := str(raw).strip_edges()
		if not line.ends_with(":"):
			continue
		var head := line.substr(0, line.length() - 1).strip_edges()
		if head == "":
			continue
		var pieces := head.split(",")
		var all_numbers := true
		for piece in pieces:
			if not str(piece).strip_edges().is_valid_int():
				all_numbers = false
				break
		if not all_numbers:
			continue
		for piece in pieces:
			out.append(int(str(piece).strip_edges()))
	return out


# A function's body: everything after its header up to the next top-level
# `func`, which is where its last branch ends.
static func _function_body(source: String, header: String) -> String:
	var start := source.find(header)
	if start < 0:
		return ""
	var out := ""
	for raw in source.substr(start + header.length()).split("\n"):
		var line := str(raw)
		if line.begins_with("func ") or line.begins_with("static func "):
			break
		out += line + "\n"
	return out


static func _code_of(source: String) -> String:
	var out := ""
	for raw in source.split("\n"):
		var line := str(raw)
		if line.strip_edges().begins_with("#"):
			out += "\n"
			continue
		var hash_at := line.find("#")
		out += (line if hash_at < 0 else line.substr(0, hash_at)) + "\n"
	return out
