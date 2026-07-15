@tool
class_name GFFSignal
extends GFFEffect

## Game Feel Flow Signal Effect
##
## Dynamically trigger a native Signal on the target node.

# ===== Properties =====
@export_group("Signal Settings")
@export var signal_name: String = ""
@export var signal_args: Array = []

func _init() -> void:
	restore_after_play = false

# ===== Override Methods =====

func _execute(node: Node, params: GFFParams) -> void:
	var name = params.get_string("signal_name", signal_name)
	if name.is_empty():
		push_warning("GFFSignal: signal_name is empty")
		return

	if not node or not is_instance_valid(node):
		push_warning("GFFSignal: No valid target node")
		return

	if not node.has_signal(name):
		push_warning("GFFSignal: Signal '", name, "' not found on target")
		return

	var args = params.get_variant("signal_args", signal_args)
	if not args is Array:
		args = signal_args

	match args.size():
		0: node.emit_signal(name)
		1: node.emit_signal(name, args[0])
		2: node.emit_signal(name, args[0], args[1])
		3: node.emit_signal(name, args[0], args[1], args[2])
		4: node.emit_signal(name, args[0], args[1], args[2], args[3])
		5: node.emit_signal(name, args[0], args[1], args[2], args[3], args[4])
		_:
			push_warning("GFFSignal: Too many signal arguments (max 5 supported)")

func _get_default_intensity() -> float:
	return 1.0

func _get_default_duration() -> float:
	return 0.0
