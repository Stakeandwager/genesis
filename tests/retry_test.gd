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
