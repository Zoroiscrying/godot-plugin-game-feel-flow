@tool
class_name GFFCameraFovTarget
extends GFFTarget

enum Mode { TO_TARGET, BY_AMOUNT, FROM_TARGET }

@export var target_value: float = 75.0
@export var mode: Mode = Mode.TO_TARGET

func get_value_type() -> GFFValueType.Value:
	return GFFValueType.Value.FLOAT

func get_initial_value(node: Node) -> Variant:
	if node is Camera3D:
		return node.fov
	return 75.0

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
	if node is Camera3D:
		node.fov = clampf(value, 1.0, 179.0)

func get_target_name() -> String:
	return "Camera FOV"

func can_restore(node: Node) -> bool:
	return node is Camera3D

func get_restorable_state(node: Node) -> Dictionary:
	if node is Camera3D:
		return {"fov": node.fov}
	return {}

func restore_state(node: Node, state: Dictionary) -> void:
	if node is Camera3D:
		node.fov = state.get("fov", 75.0)
