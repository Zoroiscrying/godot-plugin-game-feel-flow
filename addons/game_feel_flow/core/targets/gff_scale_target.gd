@tool
class_name GFFScaleTarget
extends GFFTarget

enum Mode { TO_TARGET, BY_AMOUNT, FROM_TARGET }

@export var target_value: Vector3 = Vector3.ONE
@export var mode: Mode = Mode.TO_TARGET

func get_value_type() -> GFFValueType.Value:
	return GFFValueType.Value.VECTOR3

func get_initial_value(node: Node) -> Variant:
	if node is Node3D:
		return node.scale
	if node is Node2D:
		return Vector3(node.scale.x, node.scale.y, 1.0)
	return Vector3.ONE

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
		node.scale = value
	elif node is Node2D:
		node.scale = Vector2(value.x, value.y)

func apply_params(params: GFFParams) -> void:
	if params == null:
		return
	var mode_v: Variant = params.get_variant("mode", null)
	if mode_v != null:
		mode = int(mode_v) as Mode
	var tv: Variant = params.get_variant("target_value", null)
	if tv is Vector3:
		target_value = tv
	elif tv is Vector2:
		target_value = Vector3(tv.x, tv.y, 0.0)

func get_target_name() -> String:
	return "Scale"
