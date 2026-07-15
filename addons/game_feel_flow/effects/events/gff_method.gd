@tool
class_name GFFMethod
extends GFFEffect

## Game Feel Flow Method Effect
##
## Call a method on the target node.

# ===== Properties =====
@export_group("Method Settings")
@export var method_name: String = ""
@export var method_args: Array = []

func _init() -> void:
	restore_after_play = false

# ===== Override Methods =====

func _execute(node: Node, params: GFFParams) -> void:
	var name = params.get_string("method_name", method_name)
	if name.is_empty():
		push_warning("GFFMethod: method_name is empty")
		return

	if not node or not is_instance_valid(node):
		push_warning("GFFMethod: No valid target node")
		return

	if not node.has_method(name):
		push_warning("GFFMethod: Method '", name, "' not found on target")
		return

	var args = params.get_variant("method_args", method_args)
	if not args is Array:
		args = method_args

	match args.size():
		0: node.call(name)
		1: node.call(name, args[0])
		2: node.call(name, args[0], args[1])
		3: node.call(name, args[0], args[1], args[2])
		4: node.call(name, args[0], args[1], args[2], args[3])
		5: node.call(name, args[0], args[1], args[2], args[3], args[4])
		_:
			push_warning("GFFMethod: Too many method arguments (max 5 supported)")

func _get_default_intensity() -> float:
	return 1.0

func _get_default_duration() -> float:
	return 0.0
