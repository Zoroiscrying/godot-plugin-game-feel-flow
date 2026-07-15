@tool
class_name GFFEvent
extends GFFEffect

## Game Feel Flow Event Effect
##
## Send a string event through the GameFeelFlow global event system.

# ===== Properties =====
@export_group("Event Settings")
@export var event_name: String = ""
@export var event_data: Dictionary = {}

func _init() -> void:
	requires_target = false
	restore_after_play = false

# ===== Override Methods =====

func _execute(node: Node, params: GFFParams) -> void:
	var name = params.get_string("event_name", event_name)
	if name.is_empty():
		push_warning("GFFEvent: event_name is empty")
		return

	var data = event_data.duplicate()
	# Allows overriding/appending event data through params
	var override_data = params.get_variant("event_data", {})
	if override_data is Dictionary:
		for key in override_data:
			data[key] = override_data[key]

	if node:
		data["target"] = node

	GameFeelFlow.emit(name, data)

func _get_default_intensity() -> float:
	return 1.0

func _get_default_duration() -> float:
	return 0.0
