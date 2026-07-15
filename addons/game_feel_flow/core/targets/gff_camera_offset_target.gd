@tool
class_name GFFCameraOffsetTarget
extends GFFTarget

enum Mode { TO_TARGET, BY_AMOUNT, FROM_TARGET }

@export var target_value: Vector2 = Vector2.ZERO
@export var mode: Mode = Mode.TO_TARGET

func get_value_type() -> GFFValueType.Value:
	return GFFValueType.Value.VECTOR2

func get_initial_value(node: Node) -> Variant:
	if node is Camera2D:
		return node.offset
	if node is Camera3D:
		return node.position
	return Vector2.ZERO

func _scaled_target(intensity: float) -> Variant:
	return target_value * intensity

func _scaled_target_for_node(node: Node, intensity: float) -> Variant:
	var scaled := target_value * intensity
	if node is Camera3D:
		return Vector3(scaled.x, scaled.y, 0.0)
	return scaled

func get_start_value(node: Node, intensity: float) -> Variant:
	match mode:
		Mode.FROM_TARGET:
			return _scaled_target_for_node(node, intensity)
	return get_initial_value(node)

func get_end_value(node: Node, intensity: float) -> Variant:
	var initial = get_initial_value(node)
	var scaled = _scaled_target_for_node(node, intensity)
	match mode:
		Mode.TO_TARGET:
			return scaled
		Mode.BY_AMOUNT:
			return initial + scaled
		Mode.FROM_TARGET:
			return initial
	return initial

func apply_value(node: Node, value: Variant) -> void:
	if node is Camera2D:
		node.offset = value
	elif node is Camera3D:
		node.position = value

func get_target_name() -> String:
	return "Camera Offset"

func can_restore(node: Node) -> bool:
	# Camera2D offset needs explicit restore; Camera3D position is restored by base effect
	return node is Camera2D

func get_restorable_state(node: Node) -> Dictionary:
	if node is Camera2D:
		return {"offset": node.offset}
	return {}

func restore_state(node: Node, state: Dictionary) -> void:
	if node is Camera2D:
		node.offset = state.get("offset", Vector2.ZERO)
