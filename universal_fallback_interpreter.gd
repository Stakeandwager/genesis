extends Node
class_name UniversalFallbackInterpreter

signal layout_ready(json_text: String)
signal interpretation_failed(reason: String)

func interpret(raw_text: String) -> void:
	var text := raw_text.strip_edges().to_lower()
	var numbers := _extract_numbers(text)
	
	# Domain routing based on keywords
	if text.contains("track") or text.contains("circuit") or text.contains("corner") or text.contains("straight"):
		_generate_track_fallback(text, numbers)
	elif text.contains("farm") or text.contains("crop") or text.contains("barn") or text.contains("field"):
		_generate_farm_fallback(text, numbers)
	elif text.contains("arena") or text.contains("box") or text.contains("grid"):
		_generate_arena_fallback(text, numbers)
	else:
		interpretation_failed.emit("Universal Fallback: No matching layout template found for: '%s'" % raw_text)


func _extract_numbers(text: String) -> Array[float]:
	var regex := RegEx.new()
	regex.compile("\\d+(\\.\\d+)?")
	var results := regex.search_all(text)
	var numbers: Array[float] = []
	for res in results:
		numbers.append(res.get_string().to_float())
	return numbers


func _generate_track_fallback(text: String, numbers: Array[float]) -> void:
	var corners := int(numbers[0]) if numbers.size() > 0 and text.contains("corner") else 4
	var length := numbers[1] if numbers.size() > 1 else 300.0
	
	var sections := []
	for i in range(corners):
		sections.append({"type": "straight", "length": length})
		sections.append({"type": "corner", "radius": 50.0, "angle": 360.0 / float(corners)})
		
	var payload := {
		"command": "CREATE_TRACK",
		"parameters": {
			"mode": "circuit",
			"intent": {"style": "%d_corner_fallback" % corners},
			"sections": sections
		}
	}
	layout_ready.emit(JSON.stringify(payload))


func _generate_farm_fallback(text: String, numbers: Array[float]) -> void:
	var size := numbers[0] if numbers.size() > 0 else 100.0
	var payload := {
		"command": "CREATE_FARM",
		"parameters": {
			"mode": "grid",
			"intent": {"style": "dynamic_fallback_farm"},
			"zones": [
				{"type": "perimeter_fence", "width": size, "length": size},
				{"type": "central_barn", "position": [0.0, 0.0, 0.0], "size": [15.0, 10.0]},
				{"type": "crop_plot", "quadrant": "quadrant_grid", "size": [size * 0.4, size * 0.4]}
			]
		}
	}
	layout_ready.emit(JSON.stringify(payload))


func _generate_arena_fallback(_text: String, numbers: Array[float]) -> void:
	var radius := numbers[0] if numbers.size() > 0 else 50.0
	var payload := {
		"command": "CREATE_ARENA",
		"parameters": {
			"mode": "radial",
			"intent": {"style": "dynamic_fallback_arena"},
			"radius": radius
		}
	}
	layout_ready.emit(JSON.stringify(payload))
