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
const PROMPT_VERSION := "004-tools-1"
# Which wording of the closure feedback a revised track was given.
# feedback-2 adds Godot's test of whether ANY straight lengths could close the layout.
const REVISION_VERSION := "002C-closure-feedback-2"
# 002E: the wording that shows the AI the world the player is already in.
const EDIT_VERSION := "002E-edit-1"

const ENDPOINT := "https://generativelanguage.googleapis.com/v1beta/models/" + MODEL + ":generateContent"

const SYSTEM_PROMPT := """You turn a player's request into exactly ONE command for Genesis, a game that builds worlds in Godot.

Return ONLY the JSON: no explanations, no markdown, no code fences. Never return a list of commands. If the request has several steps, return the single command for the final result; a new world replaces whatever was there before, whichever kind it was.

COMMANDS YOU MAY USE
PLAN - build several things in one request
EQUIP - give the player a tool made to their description, listed under TOOLS YOU CAN GIVE at the end
CLEAR_WORLD - remove everything, with parameters {}
UNSUPPORTED - for a request this game cannot build
One command for each kind of world, listed under WORLDS YOU CAN BUILD at the end of these instructions. Those are the only worlds that exist. Never invent a command, a type or a field that is not listed there: anything else is refused before it reaches the game.

A PLAN is for a request that needs more than one thing, such as one world placed inside another:
{"command": "PLAN", "parameters": {"steps": [{"command": COMMAND, "parameters": {...}}, {"command": COMMAND, "parameters": {...}}]}}
where each COMMAND is one of the world commands listed at the end. Up to 4 steps. A step is a normal command with its normal parameters, and a plan may not contain another plan.
To build one world around another, give the later step "around": N, where N is the number of the earlier step (1 for the first). The game works out where everything goes; never give coordinates. The surrounding world must be large enough to contain the inner one with room to spare, or the whole plan is refused.

For a request this game cannot build, return:
{"command": "UNSUPPORTED", "parameters": {"understood": "what the player is asking for", "reason": "short explanation of why this game cannot build it"}}
UNDERSTOOD is what they want, as a short phrase that completes "you want ...", in your own words rather than theirs. Say it even when you cannot build it: being told the right thing is impossible is different from being told the wrong thing is.

A world is a place; a tool is what the player works it with. "a farm with a big barn" is a world. "a tractor that pulls harder" is a tool. A request for both is a PLAN whose steps are the world and the EQUIP.

STYLE records how the player described what they asked for, as a short lowercase label with underscores, in the player's own terms. If they gave no description, use "unspecified". Interpret the player's description yourself when you design the world.
"""

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


func _ready() -> void:
	http = HTTPRequest.new()
	add_child(http)
	http.request_completed.connect(_on_request_completed)
	_load_key()


func is_available() -> bool:
	return api_key != ""


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

	# Every registered world module describes its own vocabulary, so the AI
	# always knows exactly what the game can build, and nothing more.
	var instructions := SYSTEM_PROMPT \
		+ "\nWORLDS YOU CAN BUILD\n" + WorldRegistry.prompt_sections() \
		+ "\n\nTOOLS YOU CAN GIVE\n" + ToolRegistry.prompt_sections()

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

	var headers := [
		"Content-Type: application/json",
		"x-goog-api-key: " + api_key,
	]

	busy = true
	var error := http.request(ENDPOINT, headers, HTTPClient.METHOD_POST, JSON.stringify(body))

	if error != OK:
		busy = false
		interpretation_failed.emit("Could not send the request. (error %d)" % error)


# --- internal ---

func _load_key() -> void:
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
		interpretation_failed.emit("Could not reach the AI. Check your internet connection.")
		print("Network result code: ", result)
		return

	var raw := body.get_string_from_utf8()

	if response_code != 200:
		print("AI error body: ", raw)
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
			return "The AI is getting too many requests. Wait a minute and try again. (HTTP 429)"
		500, 502, 503, 504:
			return "The AI service is busy right now. Try again in a moment. (HTTP %d)" % code
		400:
			return "The AI did not accept the request format. (HTTP 400)"
		401, 403:
			return "The API key was refused. Check api_key.txt. (HTTP %d)" % code
		404:
			return "The AI model name is out of date. (HTTP 404)"
	return "The AI returned an unexpected error. (HTTP %d)" % code
