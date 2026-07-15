@tool
class_name GFFLinearTweener
extends GFFTweener

func get_tweener_name() -> String:
	return "Linear"

func get_supported_value_types() -> Array[GFFValueType.Value]:
	return [
		GFFValueType.Value.FLOAT,
		GFFValueType.Value.VECTOR2,
		GFFValueType.Value.VECTOR3,
		GFFValueType.Value.COLOR,
	]

func tween_node(node: Node, target: GFFTarget, from: Variant, to: Variant, duration: float, curve: Curve = null) -> void:
	var tween = _start_tween(node)
	if curve:
		tween.tween_method(_apply_curve.bind(node, target, from, to, curve), 0.0, 1.0, duration)
	else:
		tween.tween_method(_apply_linear.bind(node, target, from, to), 0.0, 1.0, duration)
	await _tween_completed

func _apply_linear(t: float, node: Node, target: GFFTarget, from: Variant, to: Variant) -> void:
	target.apply_value(node, _interpolate(from, to, t))

func _apply_curve(t: float, node: Node, target: GFFTarget, from: Variant, to: Variant, curve: Curve) -> void:
	target.apply_value(node, _interpolate(from, to, curve.sample(t)))

func _interpolate(from: Variant, to: Variant, t: float) -> Variant:
	if from is float and to is float:
		return from + (to - from) * t
	elif from is Vector2 and to is Vector2:
		return from.lerp(to, t)
	elif from is Vector3 and to is Vector3:
		return from.lerp(to, t)
	elif from is Color and to is Color:
		return from.lerp(to, t)
	return from
