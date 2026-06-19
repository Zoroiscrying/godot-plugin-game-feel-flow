class_name GFFPunch
extends GFFFeedback

## Game Feel Flow Punch Effect
##
## 冲击效果，快速放大然后缩小，支持Node2D、Node3D和Control

# ===== 属性 =====
@export_group("Punch Settings")
@export var punch_scale: Vector2 = Vector2(1.3, 1.3)
@export var punch_scale_3d: Vector3 = Vector3(1.3, 1.3, 1.3)
@export var elasticity: float = 0.5
@export var punch_curve: Curve = null

# ===== 重写方法 =====

func _execute(node: Node, params: GFFParams) -> void:
	var intensity = params.get_float("intensity", 1.0)
	var final_duration = params.get_float("duration", duration)
	var final_elasticity = params.get_float("elasticity", elasticity)
	
	var original_scale = _get_scale(node)
	var target_scale: Vector3
	
	if node is Node3D:
		target_scale = punch_scale_3d * intensity
	else:
		target_scale = Vector3(punch_scale.x * intensity, punch_scale.y * intensity, 1.0)
	
	# 创建弹性曲线
	var curve = punch_curve
	if not curve:
		curve = _create_elastic_curve(final_elasticity)
	
	# 执行动画
	var tween = node.create_tween()
	tween.tween_method(_apply_punch_curve.bind(node, original_scale, target_scale, curve), 0.0, 1.0, final_duration)
	await tween.finished

func _apply_punch_curve(t: float, node: Node, from: Variant, to: Variant, curve: Curve) -> void:
	var value = curve.sample(t)
	if node is Node3D:
		_set_scale(node, from.lerp(to, value))
	else:
		_set_scale(node, Vector2(from.x + (to.x - from.x) * value, from.y + (to.y - from.y) * value))

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
