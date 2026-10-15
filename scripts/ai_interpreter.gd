extends Node
class_name AIInterpreter

# --- Prototype 002A - Step A7: Natural language -> composed track ---
# --- 002C: one revision turn, with Godot's closure measurements ---
# The AI is an INTERPRETER and a COMPOSER. It never touches Godot directly.
# Its only output is a string, which must still pass the command whitelist,
# the section validator, the feasibility gate, the closure solver and the
# separation check before anything is built.
#
# Instructions are NEUTRAL (experiment option A): the AI is told the pieces
# and the rules of a closed circuit, but never what any style should look
# like. Whether "technical" becomes different geometry from "high speed" is
# exactly what the experiment measures.

signal interpretation_ready(json_text: String)
signal interpretation_failed(reason: String)

const KEY_PATH := "res://api_key.txt"

# Everything that could change the results is recorded with every track.
const MODEL := "gemini-3.1-flash-lite"
const THINKING_LEVEL := "low"
# Temperature 1.0 so that repeated requests give genuinely different designs.
const TEMPERATURE := 1.0
# 002C-balance-1 adds one geometry rule: travel in opposite directions must
# balance. The 002C experiments showed designs that turned through 360 deg but
# never came back, because a hairpin reverses direction without returning.
#
# 002H-neutral-1 is the first world-neutral wording. The AI is no longer
# introduced as a racing circuit designer with other worlds as a footnote:
# every world, racing included, now describes itself through its module. The
# circuit rules are unchanged word for word, but their place in the prompt is
# not, so tracks made under 002H are not comparable with earlier ones. Old
# records keep their own version string, so the two never get mixed up.
#
# 003-readback-1 adds one thing: an UNSUPPORTED answer must say what it
# understood the player to want, not only why it cannot be built. Everything
# a world can build is unchanged, so designs are still comparable with 002H.
# 004-tools-1 adds EQUIP and the tools the registry describes. Worlds are
# unchanged, so world designs stay comparable with 003.
#
# 035-bounds-from-the-code-1 is the first version string in this list that was
# moved because a SUITE insisted on it rather than because somebody
# remembered. See PROMPT_FINGERPRINT below for why that distinction had to be
# built: this constant sat at 025 while the prompt changed underneath it
# twice, in 027 and 028, so three different prompts were recorded under one
# version and the ledger called them one population. 035 itself changes the
# farm's zone bound, the circuit's section count and seven stated limits that
# now read from their constants, so designs from here are not comparable with
# 028-034 either - and now they say so.
const PROMPT_VERSION := "035-bounds-from-the-code-1"

# --- 035: the version cannot be left behind again ---
#
# MEASURED, not inferred, and it is the reason this constant exists. The
# prompt-contributing strings were extracted at every commit from 025 to 034
# and hashed: 025 and 026 share one prompt of 14470 characters, 027 brings a
# second of 15030, and 028 a third of 15306 that stood until 035. All three
# were recorded as "025-what-genesis-does-1".
#
# PROMPT_VERSION exists so that interpretation measured under one prompt is
# not compared with interpretation measured under another - that is the whole
# reason every ledger record carries it. A version that does not move when
# the prompt moves is the same fault as a refusal that names no limit or a
# limitation nobody rechecked: a claim about Genesis that nothing was
# checking. Nothing could have caught it, because no test knew what the
# prompt was supposed to be.
#
# This is the sha256 of assembled_prompt(). tests/prompt_bounds_test.gd fails
# if they disagree, and says to move PROMPT_VERSION as well as this string.
# It is a fingerprint, not an assertion about wording: it says only that the
# prompt the model receives is the one this version names.
const PROMPT_FINGERPRINT := "8b64f8ea42b4c6f711afc8aaba9cb98d9ebb22aa0f0146d6e1d8625306ff3505"
# Which wording of the closure feedback a revised track was given.
# feedback-2 adds Godot's test of whether ANY straight lengths could close the layout.
const REVISION_VERSION := "002C-closure-feedback-2"
# 002E: the wording that shows the AI the world the player is already in.
const EDIT_VERSION := "002E-edit-1"

const ENDPOINT := "https://generativelanguage.googleapis.com/v1beta/models/" + MODEL + ":generateContent"

# --- 020: on the web, the key is not here ---
# Anything under res:// is packed into index.pck, which anyone can download
# and read, so a web build that carried api_key.txt would be publishing the
# key. The browser asks a function on the same origin instead, and that
# function - which nobody can read - adds the key and asks Google.
#
# The desktop build is untouched: it reads api_key.txt and talks to Google
# directly, as it always has.
const PROXY_PATH := "/api/interpret"


static func on_web() -> bool:
	return OS.has_feature("web")


# Where the request actually goes, and what it carries. One function, so the
# two builds cannot disagree about which is which.
static func where_to() -> String:
	return PROXY_PATH if on_web() else ENDPOINT

const SYSTEM_PROMPT := """You turn a player's request into exactly ONE command for Genesis, a game that builds worlds in Godot.

Return ONLY the JSON: no explanations, no markdown, no code fences. Never return a list of commands. If the request has several steps, return the single command for the final result; a new world replaces whatever was there before, whichever kind it was.

COMMANDS YOU MAY USE
PLAN - build several things in one request
EQUIP - give the player a tool made to their description, listed under TOOLS YOU CAN GIVE at the end. Every EQUIP must carry "tool": the name of one of those tools. A spec without it is refused, however good the spec is.
ORDER - send the dungeon's character somewhere, listed under ORDERS YOU CAN GIVE at the end
SHUT / OPEN - close or open a door of the dungeon that is standing, named by the two rooms it joins: {"command": "SHUT", "parameters": {"between": [ROOM, ROOM]}}. A player may do this at any moment, including while a character is walking through that door.
CLEAR_WORLD - remove everything, with parameters {}
UNSUPPORTED - for a request this game cannot build
One command for each kind of world, listed under WORLDS YOU CAN BUILD at the end of these instructions. Those are the only worlds that exist. Never invent a command, a type or a field that is not listed there: anything else is refused before it reaches the game.

A PLAN is for a request that needs more than one thing, such as one world placed inside another:
{"command": "PLAN", "parameters": {"steps": [{"command": COMMAND, "parameters": {...}}, {"command": COMMAND, "parameters": {...}}]}}
where each COMMAND is one of the world commands listed at the end. Up to 4 steps. A step is a normal command with its normal parameters, and a plan may not contain another plan.
To build one world around another, give the later step "around": N, where N is the number of the earlier step (1 for the first). The game works out where everything goes; never give coordinates. The surrounding world must be large enough to contain the inner one with room to spare, or the whole plan is refused.

WHAT GENESIS ALREADY DOES
These are facts about this game, not ambitions. Never say Genesis cannot do one of them.
- It MEASURES everything it builds, and the measurements go in a panel and a ledger on disk: corridor length, how many doors deep the furthest room is, lap length, closest approach of a track to itself.
- It VERIFIES a delivery from the world. When a character carries something, the answer comes from reading the thing's position afterwards, never from the character. A character has no way to report its own success, so a false delivery is not a thing Genesis can produce.
- It MOVES BODIES WITH PHYSICS. Walking is a force on a mass against drag; a car and boots each have mass, grip and braking, every one of them bounded. For BOOTS, Genesis predicts a stopping distance from those numbers and says it before anything moves. Two things it does NOT do, so never promise them: nothing in the game measures a real stop and reports it beside the prediction, and a CAR has bounded braking but no predicted stopping distance at all. A braking experiment is not a thing a player can ask for.
- It ROUTES. A character finds its way room to room through doors that are actually passable, and a door shut while it is walking is handled, not ignored.
- It PUTS ONE WORLD INSIDE ANOTHER, through a PLAN with "around". A circuit inside a farm is an ordinary request. Genesis grows the outer world until the inner one fits with room to spare, and records the growth rather than quietly shrinking what was asked for.
- It KEEPS A RECORD of every request, what it understood, whether that was permitted, whether it got built, what was attempted and what the world confirmed - and at the end it separates what succeeded, what failed, and what could not be verified either way.
- It REFUSES rather than clamping. A number outside its limits is refused with the limit named.
- It SAVES AND LOADS a world, and checks the one that comes back. The measurements taken the day it was saved are compared with the measurements taken after it is rebuilt, and a world that comes back different is reported as different.

WHAT GENESIS REALLY CANNOT DO
Say so plainly when one of these is asked for, and name which part:
- There is ONE character. Two NPCs with different jobs is not possible.
- A character takes ONE order at a time, and a new order replaces the old. What that rules out is a CHAIN OF ORDERS - "go to room 2, then fetch the key, then shut the door behind you" - and a step conditional on whether an earlier one worked. It does NOT rule out carry, which is itself a staged errand: the character walks to the thing, picks it up at the waypoint where it stands, and carries it on to the room. So "take the red key to room 3" is one ORDER and is ordinary; never refuse it as a sequence.
- No locks. A door can be shut or opened by the player; nothing is locked and no key unlocks anything. A key is an object with a name like any other.
- A saved world comes back as it was BUILT, not as it was LEFT. /save and /load do exist, and a saved world keeps its rooms, doors, zones and the objects it was built with. What is NOT saved is the state it was in: equipment goes back to the free kit, every door is open again, and a thing that had been carried somewhere is back where it started.
- One set of equipment at a time, so two cars with different specs cannot exist together and be compared.
- A farm's zones never overlap EACH OTHER: they are laid out in rows with a lane between them, so "do not let the barn sit in the pond" is already true of every farm and is not a refusal. What is not checked is a zone against anything OUTSIDE the farm - a road, or any world a PLAN puts around it - so "do not let the circuit cross the barn" is the one that cannot be promised.
- A farm's overall size cannot be given; it comes out of the zones that were asked for.

For a request this game cannot build, return:
{"command": "UNSUPPORTED", "parameters": {"understood": "what the player is asking for", "reason": "short explanation of why this game cannot build it"}}
UNDERSTOOD is what they want, as a short phrase that completes "you want ...", in your own words rather than theirs. Say it even when you cannot build it: being told the right thing is impossible is different from being told the wrong thing is.
REASON must name the part that is missing, from the list above, and must not deny anything from the list before it. A refusal is a claim about this game and is checked like any other.

Do not refuse a whole request because one clause of it is impossible. Build the part that is possible and say which part was dropped: a request for a dungeon with two objects, a delivery and a locked door is a dungeon with two objects and a delivery, with the lock named as the thing Genesis has not got.

An ORDER is not a world and not a tool: it asks a character already in the world to do something. "build a dungeon" is a world. "send him to the vault" is an order. An order can only be given about a dungeon that is already standing.

A world is a place; a tool is what the player works it with. "a farm with a big barn" is a world. "a tractor that pulls harder" is a tool. A request for both is a PLAN whose steps are the world and the EQUIP.

STYLE records how the player described what they asked for, as a short lowercase label with underscores, in the player's own terms. If they gave no description, use "unspecified". Interpret the player's description yourself when you design the world.
"""


# --- 034: the prompt the model actually receives, in one place ---
#
# SYSTEM_PROMPT is the constant; what the model is sent is that plus the
# three registries' sections. 033 measured the difference - 7573 characters
# against 15474 - by rebuilding the concatenation in a scratch script,
# because this was four lines inside ask() and nothing else could reach it.
#
# It is a function now so that a test can ask what the model is told without
# writing its own copy of the answer. tests/container_door_test.gd needs it:
# a refusal that names a legal value must not name one the prompt withholds,
# which is how 034's first attempt came to offer MODIFY_TRACK - a Prototype
# 001 stub that builds nothing and appears nowhere in this string - as the
# example of what a plan step looks like.
static func assembled_prompt() -> String:
	# Every registered world module describes its own vocabulary, so the AI
	# always knows exactly what the game can build, and nothing more.
	return SYSTEM_PROMPT \
		+ "\nWORLDS YOU CAN BUILD\n" + WorldRegistry.prompt_sections() \
		+ "\n\nTOOLS YOU CAN GIVE\n" + ToolRegistry.prompt_sections() \
		+ "\n\nORDERS YOU CAN GIVE\n" + NpcGoals.prompt_section()


var http: HTTPRequest
var api_key: String = ""
var busy: bool = false
# The AI's last answer, kept so a revision can show the AI what it said.
# The raw parts are kept as well as the text: Gemini 3 models attach a
# "thought signature" that it expects back in the next turn.
var last_model_parts: Array = []
var last_answer_text: String = ""
# The exact text of the last request sent, so a revision repeats it.
var last_prompt_text: String = ""
# 026: the last request body, so a transient failure can repeat it exactly,
# and which attempt we are on.
var last_body: Dictionary = {}
var attempt: int = 0
var retries_used: int = 0


func _ready() -> void:
	http = HTTPRequest.new()
	add_child(http)
	http.request_completed.connect(_on_request_completed)
	_load_key()


# 020: on the web the key is the server's, so the AI is available if the
# function is - which cannot be known until a request is made. Saying "no AI"
# in a browser that has one would hide the whole point of the game; a function
# that is missing or unconfigured answers with Genesis's ordinary AI FAILED
# message instead, which is the honest place for that news.
func is_available() -> bool:
	return true if on_web() else api_key != ""


# The settings behind every AI-made track, stored in the experiment record.
func describe() -> Dictionary:
	return {
		"source": "ai",
		"model": MODEL,
		"thinking_level": THINKING_LEVEL,
		"temperature": TEMPERATURE,
		"prompt_version": PROMPT_VERSION,
	}


func interpret(player_text: String, current_world: Dictionary = {}) -> void:
	var text := player_text
	if not current_world.is_empty():
		text = _with_world(player_text, current_world)
	last_prompt_text = text
	_send([{
		"role": "user",
		"parts": [{"text": text}]
	}])


# 002E: the player is already in a world, so the AI sees it and can change it
# rather than start again. This goes in the request, not the standing
# instructions, so first requests and experiments are exactly as before.
func _with_world(player_text: String, world: Dictionary) -> String:
	var command := {"command": world.get("command", ""), "parameters": world.get("parameters", {})}
	return "\n".join([
		"THE WORLD THE PLAYER IS IN NOW",
		"The player asked for: \"%s\"" % str(world.get("request", "")),
		"It was built from this command:",
		JSON.stringify(command),
		"",
		"THE PLAYER NOW SAYS",
		player_text,
		"",
		"If this changes the world above (for example \"make it longer\", \"add a hairpin\", \"tighter corners\"), return the complete command for the whole changed world, keeping everything the player did not ask to change. If it asks for something new instead, return a new command as usual.",
	])


func describe_edit() -> Dictionary:
	var d := describe()
	d["edit"] = EDIT_VERSION
	return d


# Closure feedback (002C): one more turn of the same conversation. The AI sees
# the player's request, its own previous answer, and what Godot measured, then
# proposes again. Its answer goes through every check, exactly like the first.
func revise(player_text: String, feedback: String) -> void:
	var previous: Array = last_model_parts
	if previous.is_empty():
		previous = [{"text": last_answer_text}]
	var first := last_prompt_text if last_prompt_text != "" else player_text
	_send([
		{"role": "user", "parts": [{"text": first}]},
		{"role": "model", "parts": previous},
		{"role": "user", "parts": [{"text": feedback}]},
	])


# The settings behind a revised track: the same as a first attempt, plus which
# version of the feedback the AI was given.
func describe_revision() -> Dictionary:
	var d := describe()
	d["revision"] = REVISION_VERSION
	return d


func _send(contents: Array) -> void:
	if busy:
		interpretation_failed.emit("Still thinking about the last request.")
		return

	if api_key == "":
		interpretation_failed.emit("No API key found in api_key.txt.")
		return

	var instructions := assembled_prompt()

	var body := {
		"system_instruction": {
			"parts": [{"text": instructions}]
		},
		"contents": contents,
		"generationConfig": {
			"temperature": TEMPERATURE,
			"maxOutputTokens": 8000,
			"responseMimeType": "application/json",
			"thinkingConfig": {
				"thinkingLevel": THINKING_LEVEL
			}
		}
	}

	# 026: kept so a transient failure can send the same request again without
	# rebuilding it. The retry must be the IDENTICAL request, or what comes
	# back is an answer to a different question and the ledger records a
	# comparison that was never made.
	last_body = body
	attempt = 1
	_post()


# One attempt. Separated from _send so a retry repeats the request exactly.
func _post() -> void:
	var headers := ["Content-Type: application/json"]
	if not on_web():
		headers.append("x-goog-api-key: " + api_key)

	busy = true
	var error := http.request(where_to(), headers, HTTPClient.METHOD_POST, JSON.stringify(last_body))

	if error != OK:
		busy = false
		interpretation_failed.emit("Could not send the request. (error %d)" % error)


# --- 026: a busy model is not a refusal ---
#
# 503 from Gemini means "the model is overloaded right now". Genesis used to
# fail on the first one, having made exactly one attempt, and told the player
# the AI was unavailable. That is a transient condition reported as a verdict,
# which is the same mistake as every other entry in docs/TRAPS.md - a claim
# made on evidence that does not support it.
#
# WHICH FAILURES ARE WORTH REPEATING, AND WHICH ARE NOT
# This distinction is the whole of the design. Repeating a request that will
# always fail wastes the player's time and buries the real cause under three
# attempts of the same error.
#   503 overloaded, 429 too many requests, 500/502/504 upstream - the same
#       request may well work in a second, so it is sent again.
#   400 bad request, 401/403 bad or missing key, 404 wrong model - the request
#       or the configuration is wrong, and will be wrong on the fourth attempt
#       too. Reported at once, with the reason.
# A network failure that never reached Google is retried as well: a dropped
# connection says nothing about the request.
const WORTH_RETRYING := [429, 500, 502, 503, 504]

# Three attempts, not more. The player is sitting in front of a text box
# waiting for a world; a fourth attempt is a minute of silence that a person
# reads as "broken" anyway.
const MAX_ATTEMPTS := 3

# Doubling, with a little jitter, because a model that is overloaded now is
# overloaded for everyone and a fixed delay syncs every client in the world
# onto the same second.
const FIRST_WAIT := 1.2
const JITTER := 0.4

# Told to whoever is listening, so a retry shows up in the log and in the
# record rather than looking like a long pause.
signal retrying(attempt: int, of: int, why: String, waiting: float)


# Whether this failure is being retried. Emits the signal, waits, re-sends.
func _try_again(why: String) -> bool:
	if attempt >= MAX_ATTEMPTS or last_body.is_empty():
		return false
	attempt += 1
	var waiting := FIRST_WAIT * pow(2.0, float(attempt - 2)) + randf() * JITTER
	retries_used += 1
	retrying.emit(attempt, MAX_ATTEMPTS, why, waiting)
	print("AI busy (%s). Attempt %d of %d in %.1fs." % [why, attempt, MAX_ATTEMPTS, waiting])
	# The same request, resent when a timer says so.
	#
	# A timer that CALLS BACK rather than one that is awaited: `await` here
	# would make this function a coroutine, and then every caller of it has to
	# be one too, all the way up through the signal handler. The first version
	# did that and would not compile - which is the useful kind of failure,
	# because the alternative is a handler that silently returns a half-made
	# answer to whatever called it.
	var wait := get_tree().create_timer(waiting)
	wait.timeout.connect(_post, CONNECT_ONE_SHOT)
	return true


# How many extra attempts the last answer cost. Goes into the record beside
# the answer, because an answer that took three attempts is a different
# observation from one that took one, and a rising number is the only warning
# Genesis gets that the model it depends on is struggling.
func attempts_of_last() -> int:
	return attempt


# --- internal ---

func _load_key() -> void:
	# 020: a web build has no key by design, and says so rather than warning
	# about a file that is deliberately absent.
	if on_web():
		return
	if not FileAccess.file_exists(KEY_PATH):
		push_warning("api_key.txt not found at " + KEY_PATH)
		return

	var file := FileAccess.open(KEY_PATH, FileAccess.READ)
	if file == null:
		push_warning("Could not open api_key.txt")
		return

	api_key = file.get_as_text().strip_edges()
	file.close()


func _on_request_completed(result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	busy = false

	# The request never reached Google at all.
	if result != HTTPRequest.RESULT_SUCCESS:
		if _try_again("could not reach the AI"):
			return
		interpretation_failed.emit("Could not reach the AI. Check your internet connection.")
		print("Network result code: ", result)
		return

	var raw := body.get_string_from_utf8()

	if response_code != 200:
		print("AI error body: ", raw)
		if WORTH_RETRYING.has(response_code) and _try_again("HTTP %d" % response_code):
			return
		interpretation_failed.emit(_friendly_http_error(response_code))
		return

	var json := JSON.new()
	if json.parse(raw) != OK:
		interpretation_failed.emit("The AI sent back something unreadable.")
		return

	var data = json.data

	if not data.has("candidates") or data["candidates"].is_empty():
		interpretation_failed.emit("The AI returned no answer.")
		print("AI body: ", raw)
		return

	var candidate: Dictionary = data["candidates"][0]
	if str(candidate.get("finishReason", "")) == "MAX_TOKENS":
		interpretation_failed.emit("The AI's answer was cut off before it finished.")
		return

	var parts = candidate.get("content", {}).get("parts", [])
	if parts.is_empty():
		interpretation_failed.emit("The AI returned an empty answer.")
		return

	# Thinking models can return more than one part; the answer is the text.
	var text := ""
	for part in parts:
		if typeof(part) == TYPE_DICTIONARY and part.has("text") and not bool(part.get("thought", false)):
			text += str(part["text"])
	text = text.strip_edges()

	# Models sometimes wrap JSON in markdown fences despite instructions.
	var fence := "`".repeat(3)
	text = text.replace(fence + "json", "").replace(fence, "").strip_edges()

	last_model_parts = parts
	last_answer_text = text

	print("AI raw output: ", text)
	interpretation_ready.emit(text)


func _friendly_http_error(code: int) -> String:
	match code:
		429:
			return "The AI is getting too many requests. Genesis tried %d times already; wait a minute. (HTTP 429)" % MAX_ATTEMPTS
		500, 502, 503, 504:
			# 026: by the time a player reads this, Genesis has already tried
			# MAX_ATTEMPTS times over several seconds. Saying "try again in a
			# moment" without saying that invites them to do by hand what has
			# just been done for them, three times.
			return "The AI service is busy. Genesis tried %d times over a few seconds and it was busy every time. Worth another go in a minute. (HTTP %d)" % [MAX_ATTEMPTS, code]
		400:
			return "The AI did not accept the request format. (HTTP 400)"
		401, 403:
			return "The API key was refused. Check api_key.txt. (HTTP %d)" % code
		404:
			return "The AI model name is out of date. (HTTP 404)"
	return "The AI returned an unexpected error. (HTTP %d)" % code
