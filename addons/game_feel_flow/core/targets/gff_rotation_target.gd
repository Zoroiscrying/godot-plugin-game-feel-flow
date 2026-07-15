@tool
class_name GFFRotationTarget
extends GFFTarget

enum Mode { TO_TARGET, BY_AMOUNT, FROM_TARGET }

@export var target_value: float = 0.0
@export var mode: Mode = Mode.TO_TARGET
@export var use_degrees: bool = true

func get_value_type() -> GFFValueType.Value:
	return GFFValueType.Value.FLOAT

func get_initial_value(node: Node) -> Variant:
	if node is Node3D:
		return rad_to_deg(node.rotation.y) if use_degrees else node.rotation.y
	if node is Node2D:
		return rad_to_deg(node.rotation) if use_degrees else node.rotation
	return 0.0

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
	var final_value: float = value
	if use_degrees:
		final_value = deg_to_rad(value)
	if node is Node3D:
		node.rotation.y = final_value
	elif node is Node2D:
		node.rotation = final_value

func get_target_name() -> String:
	return "Rotation"
