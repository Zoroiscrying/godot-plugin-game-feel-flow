class_name GFFColorTweener
extends GFFValueTweener

## Game Feel Flow Color Tweener
##
## 颜色变化

func tween_value(node: Node, target_function: GFFTargetFunction, from: Variant, to: Variant, duration: float, curve: Curve = null) -> void:
	var tween = node.create_tween()
	if curve:
		tween.tween_method(_apply_curve.bind(node, target_function, from, to, curve), 0.0, 1.0, duration)
	else:
		tween.tween_method(_apply_linear.bind(node, target_function, from, to), 0.0, 1.0, duration)
	await tween.finished

func _apply_linear(t: float, node: Node, target_function: GFFTargetFunction, from: Variant, to: Variant) -> void:
	if from is Color and to is Color:
		target_function.set_value(node, from.lerp(to, t))

func _apply_curve(t: float, node: Node, target_function: GFFTargetFunction, from: Variant, to: Variant, curve: Curve) -> void:
	var curve_value = curve.sample(t)
	if from is Color and to is Color:
		target_function.set_value(node, from.lerp(to, curve_value))

func get_value_at_time(t: float, from: Variant, to: Variant, curve: Curve = null) -> Variant:
	var curve_value = t
	if curve:
		curve_value = curve.sample(t)
	if from is Color and to is Color:
		return from.lerp(to, curve_value)
	return from
