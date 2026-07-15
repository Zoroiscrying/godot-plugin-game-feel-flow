@tool
class_name GFFPositionTarget
extends GFFTarget

enum Mode { TO_TARGET, BY_AMOUNT, FROM_TARGET }

@export var target_value: Vector3 = Vector3.ZERO
@export var mode: Mode = Mode.TO_TARGET

func get_value_type() -> GFFValueType.Value:
	return GFFValueType.Value.VECTOR3

func get_initial_value(node: Node) -> Variant:
	if node is Node3D:
		return node.position
	if node is Node2D:
		return Vector3(node.position.x, node.position.y, 0.0)
	return Vector3.ZERO

func _scaled_target(intensity: float) -> Variant:
	return target_value * intensity

func get_start_value(node: Node, intensity: float) -> Variant:
	match mode:
		Mode.FROM_TARGET:
			return _scaled_target(intensity)
	return get_initial_value(node)

func get_end_value(node: Node, intensity: float) -> Variant:
	var initial = get_initial_value(node)
	match mode:
		Mode.TO_TARGET:
			return _scaled_target(intensity)
		Mode.BY_AMOUNT:
			return initial + _scaled_target(intensity)
		Mode.FROM_TARGET:
			return initial
	return initial

func apply_value(node: Node, value: Variant) -> void:
	if node is Node3D:
		node.position = value
	elif node is Node2D:
		node.position = Vector2(value.x, value.y)

func get_target_name() -> String:
	return "Position"
