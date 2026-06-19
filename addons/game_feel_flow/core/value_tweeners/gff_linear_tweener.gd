class_name GFFLinearTweener
extends GFFValueTweener

## Game Feel Flow Linear Tweener
##
## 线性变化

func tween_value(node: Node, target_function: GFFTargetFunction, from: Variant, to: Variant, duration: float, curve: Curve = null) -> void:
	var tween = node.create_tween()
	if curve:
		tween.tween_method(_apply_curve.bind(node, target_function, from, to, curve), 0.0, 1.0, duration)
	else:
		tween.tween_method(_apply_linear.bind(node, target_function, from, to), 0.0, 1.0, duration)
	await tween.finished

func _apply_linear(t: float, node: Node, target_function: GFFTargetFunction, from: Variant, to: Variant) -> void:
	var value = _interpolate(from, to, t)
	target_function.set_value(node, value)

func _apply_curve(t: float, node: Node, target_function: GFFTargetFunction, from: Variant, to: Variant, curve: Curve) -> void:
	var curve_value = curve.sample(t)
	var value = _interpolate(from, to, curve_value)
	target_function.set_value(node, value)

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

func get_value_at_time(t: float, from: Variant, to: Variant, curve: Curve = null) -> Variant:
	var curve_value = t
	if curve:
		curve_value = curve.sample(t)
	return _interpolate(from, to, curve_value)
