@tool
class_name GFFElasticTweener
extends GFFTweener

enum PunchMode { TO_TARGET, TO_ORIGIN }

@export var punch_mode: PunchMode = PunchMode.TO_TARGET
@export var elasticity: float = 0.5

func get_tweener_name() -> String:
	return "Elastic"

func get_supported_value_types() -> Array[GFFValueType.Value]:
	return [
		GFFValueType.Value.FLOAT,
		GFFValueType.Value.VECTOR2,
		GFFValueType.Value.VECTOR3,
	]

func tween_node(node: Node, target: GFFTarget, from: Variant, to: Variant, duration: float, curve: Curve = null) -> void:
	var tween = _start_tween(node)
	match punch_mode:
		PunchMode.TO_TARGET:
			if curve:
				tween.tween_method(_apply_curve.bind(node, target, from, to, curve), 0.0, 1.0, duration)
			else:
				tween.tween_method(_apply_elastic.bind(node, target, from, to), 0.0, 1.0, duration)
		PunchMode.TO_ORIGIN:
			var overshoot = _calculate_overshoot(from, to)
			if curve:
				tween.tween_method(_apply_curve.bind(node, target, from, overshoot, curve), 0.0, 1.0, duration / 2.0)
				tween.tween_method(_apply_curve.bind(node, target, overshoot, from, curve), 0.0, 1.0, duration / 2.0)
			else:
				tween.tween_method(_apply_elastic.bind(node, target, from, overshoot), 0.0, 1.0, duration / 2.0)
				tween.tween_method(_apply_elastic.bind(node, target, overshoot, from), 0.0, 1.0, duration / 2.0)
	await _tween_completed

func _calculate_overshoot(from: Variant, to: Variant) -> Variant:
	if from is float and to is float:
		return from + (to - from) * 1.5
	elif from is Vector2 and to is Vector2:
		return from + (to - from) * 1.5
	elif from is Vector3 and to is Vector3:
		return from + (to - from) * 1.5
	return to

func _apply_elastic(t: float, node: Node, target: GFFTarget, from: Variant, to: Variant) -> void:
	target.apply_value(node, _interpolate(from, to, _elastic_ease(t)))

func _apply_curve(t: float, node: Node, target: GFFTarget, from: Variant, to: Variant, curve: Curve) -> void:
	target.apply_value(node, _interpolate(from, to, curve.sample(t)))

func _elastic_ease(t: float) -> float:
	if t == 0.0 or t == 1.0:
		return t
	var p = 0.3
	var s = p / 4.0
	return pow(2, -10 * t) * sin((t - s) * (2 * PI) / p) + 1

func _interpolate(from: Variant, to: Variant, t: float) -> Variant:
	if from is float and to is float:
		return from + (to - from) * t
	elif from is Vector2 and to is Vector2:
		return from.lerp(to, t)
	elif from is Vector3 and to is Vector3:
		return from.lerp(to, t)
	return from
