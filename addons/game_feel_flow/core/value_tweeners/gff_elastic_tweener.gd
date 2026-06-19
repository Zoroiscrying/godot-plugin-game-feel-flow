class_name GFFElasticTweener
extends GFFValueTweener

## Game Feel Flow Elastic Tweener
##
## 弹性变化

# ===== 属性 =====
var elasticity: float = 0.5
var punch_mode: int = 0  # 0=TO_TARGET, 1=TO_ORIGIN

func setup_from_params(params: GFFParams) -> void:
	## 从GFFParams中读取参数
	elasticity = params.get_float("elasticity", elasticity)
	punch_mode = params.get_int("punch_mode", punch_mode)

func tween_value(node: Node, target_function: GFFTargetFunction, from: Variant, to: Variant, duration: float, curve: Curve = null) -> void:
	var tween = node.create_tween()
	
	match punch_mode:
		0:  # TO_TARGET - 到达目标点
			if curve:
				tween.tween_method(_apply_curve.bind(node, target_function, from, to, curve), 0.0, 1.0, duration)
			else:
				tween.tween_method(_apply_elastic.bind(node, target_function, from, to), 0.0, 1.0, duration)
		1:  # TO_ORIGIN - 回到初始点
			# 先超出目标点，然后回到初始点
			var overshoot = _calculate_overshoot(from, to)
			if curve:
				tween.tween_method(_apply_curve.bind(node, target_function, from, overshoot, curve), 0.0, 0.5, duration / 2)
				tween.tween_method(_apply_curve.bind(node, target_function, overshoot, from, curve), 0.0, 0.5, duration / 2)
			else:
				tween.tween_method(_apply_elastic.bind(node, target_function, from, overshoot), 0.0, 0.5, duration / 2)
				tween.tween_method(_apply_elastic.bind(node, target_function, overshoot, from), 0.0, 0.5, duration / 2)
	
	await tween.finished

func _calculate_overshoot(from: Variant, to: Variant) -> Variant:
	## 计算超出目标点的位置
	if from is float and to is float:
		return from + (to - from) * 1.5
	elif from is Vector2 and to is Vector2:
		return from + (to - from) * 1.5
	elif from is Vector3 and to is Vector3:
		return from + (to - from) * 1.5
	return to

func _apply_elastic(t: float, node: Node, target_function: GFFTargetFunction, from: Variant, to: Variant) -> void:
	var elastic_t = _elastic_ease(t)
	var value = _interpolate(from, to, elastic_t)
	target_function.set_value(node, value)

func _apply_curve(t: float, node: Node, target_function: GFFTargetFunction, from: Variant, to: Variant, curve: Curve) -> void:
	var curve_value = curve.sample(t)
	var value = _interpolate(from, to, curve_value)
	target_function.set_value(node, value)

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

func get_value_at_time(t: float, from: Variant, to: Variant, curve: Curve = null) -> Variant:
	var curve_value = t
	if curve:
		curve_value = curve.sample(t)
	else:
		curve_value = _elastic_ease(t)
	return _interpolate(from, to, curve_value)
