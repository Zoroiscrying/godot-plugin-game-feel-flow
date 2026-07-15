@tool
class_name GFFColorTweener
extends GFFTweener

func get_tweener_name() -> String:
	return "Color"

func get_supported_value_types() -> Array[GFFValueType.Value]:
	return [GFFValueType.Value.COLOR]

func tween_node(node: Node, target: GFFTarget, from: Variant, to: Variant, duration: float, curve: Curve = null) -> void:
	var tween = _start_tween(node)
	if curve:
		tween.tween_method(_apply_curve.bind(node, target, from, to, curve), 0.0, 1.0, duration)
	else:
		tween.tween_method(_apply_linear.bind(node, target, from, to), 0.0, 1.0, duration)
	await _tween_completed

func _apply_linear(t: float, node: Node, target: GFFTarget, from: Variant, to: Variant) -> void:
	if from is Color and to is Color:
		target.apply_value(node, from.lerp(to, t))

func _apply_curve(t: float, node: Node, target: GFFTarget, from: Variant, to: Variant, curve: Curve) -> void:
	if from is Color and to is Color:
		target.apply_value(node, from.lerp(to, curve.sample(t)))
