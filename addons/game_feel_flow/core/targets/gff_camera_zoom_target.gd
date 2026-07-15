@tool
class_name GFFCameraZoomTarget
extends GFFTarget

enum Mode { TO_TARGET, BY_AMOUNT, FROM_TARGET }

@export var target_value: Vector2 = Vector2.ONE
@export var mode: Mode = Mode.TO_TARGET

func get_value_type() -> GFFValueType.Value:
	return GFFValueType.Value.VECTOR2

func get_initial_value(node: Node) -> Variant:
	if node is Camera2D:
		return node.zoom
	return Vector2.ONE

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
	if node is Camera2D:
		node.zoom = value

func get_target_name() -> String:
	return "Camera Zoom"

func can_restore(node: Node) -> bool:
	return node is Camera2D

func get_restorable_state(node: Node) -> Dictionary:
	if node is Camera2D:
		return {"zoom": node.zoom}
	return {}

func restore_state(node: Node, state: Dictionary) -> void:
	if node is Camera2D:
		node.zoom = state.get("zoom", Vector2.ONE)
