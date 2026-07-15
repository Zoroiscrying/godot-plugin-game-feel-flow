@tool
class_name GFFShakeTweener
extends GFFTweener

@export var amplitude: float = 0.5
@export var frequency: float = 15.0

var _base_amplitude: float = -1.0

func get_tweener_name() -> String:
	return "Shake"

func apply_params(params: GFFParams) -> void:
	if _base_amplitude < 0.0:
		_base_amplitude = amplitude
	var intensity := params.get_float("intensity", 1.0)
	amplitude = params.get_float("amplitude", _base_amplitude) * intensity
	frequency = params.get_float("frequency", frequency)

func get_supported_value_types() -> Array[GFFValueType.Value]:
	return [
		GFFValueType.Value.FLOAT,
		GFFValueType.Value.VECTOR2,
		GFFValueType.Value.VECTOR3,
	]

func tween_node(node: Node, target: GFFTarget, from: Variant, to: Variant, duration: float, curve: Curve = null) -> void:
	_is_stopped = false
	var elapsed = 0.0
	while elapsed < duration and not _is_stopped:
		if not is_instance_valid(node):
			return
		var t = elapsed / duration
		var decay = curve.sample(t) if curve else (1.0 - t)
		var offset = _calculate_offset(decay)
		target.apply_value(node, _add_offset(from, offset))
		await node.get_tree().process_frame
		if _is_stopped or not is_instance_valid(node):
			return
		elapsed += node.get_process_delta_time()
	if is_instance_valid(node) and not _is_stopped:
		target.apply_value(node, from)

func _calculate_offset(decay: float) -> Variant:
	var offset = Vector3.ZERO
	offset.x = randf_range(-1, 1) * amplitude * decay
	offset.y = randf_range(-1, 1) * amplitude * decay
	offset.z = randf_range(-1, 1) * amplitude * decay
	return offset

func _add_offset(from: Variant, offset: Variant) -> Variant:
	if from is float:
		return from + offset.x
	elif from is Vector2:
		return from + Vector2(offset.x, offset.y)
	elif from is Vector3:
		return from + offset
	return from
