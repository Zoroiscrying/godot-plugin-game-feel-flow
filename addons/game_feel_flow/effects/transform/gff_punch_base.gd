class_name GFFPunchBase
extends GFFFeedback

## Game Feel Flow Punch Base Effect
##
## 冲击效果基类，快速放大然后缩小

# ===== 属性 =====
@export_group("Punch Settings")
@export var elasticity: float = 0.5
@export var punch_curve: Curve = null

# ===== 虚方法 =====

func _get_target_value(node: Node, intensity: float):
	## 获取目标值（子类重写）
	push_error("_get_target_value() not implemented")

func _get_original_value(node: Node):
	## 获取原始值（子类重写）
	push_error("_get_original_value() not implemented")

func _apply_value(node: Node, value) -> void:
	## 应用值（子类重写）
	push_error("_apply_value() not implemented")

# ===== 重写方法 =====

func _execute(node: Node, params: GFFParams) -> void:
	var intensity = params.get_float("intensity", 1.0)
	var final_duration = params.get_float("duration", duration)
	var final_elasticity = params.get_float("elasticity", elasticity)
	
	var original_value = _get_original_value(node)
	var target_value = _get_target_value(node, intensity)
	
	# 创建弹性曲线
	var curve = punch_curve
	if not curve:
		curve = _create_elastic_curve(final_elasticity)
	
	# 执行动画
	var tween = node.create_tween()
	tween.tween_method(_apply_punch_curve.bind(node, original_value, target_value, curve), 0.0, 1.0, final_duration)
	await tween.finished

func _apply_punch_curve(t: float, node: Node, from, to, curve: Curve) -> void:
	var value = curve.sample(t)
	if from is float and to is float:
		_apply_value(node, from + (to - from) * value)
	elif from is Vector2 and to is Vector2:
		_apply_value(node, from.lerp(to, value))
	elif from is Vector3 and to is Vector3:
		_apply_value(node, from.lerp(to, value))

func _create_elastic_curve(elasticity: float) -> Curve:
	var curve = Curve.new()
	curve.add_point(Vector2(0, 0))
	curve.add_point(Vector2(0.3, 1.2 * elasticity))
	curve.add_point(Vector2(0.5, 0.8))
	curve.add_point(Vector2(0.7, 1.05 * elasticity))
	curve.add_point(Vector2(0.9, 0.95))
	curve.add_point(Vector2(1, 1))
	return curve

func _get_default_intensity() -> float:
	return 1.0

func _get_default_duration() -> float:
	return duration
