class_name GFFScale
extends GFFFeedback

## Game Feel Flow Scale Effect
##
## 缩放效果，支持Node2D、Node3D和Control

# ===== 枚举 =====
enum ScaleMode {
	TO_SCALE,      # 缩放到目标值
	ADDITIVE,      # 叠加缩放
	MULTIPLICATIVE # 乘法缩放
}

# ===== 属性 =====
@export_group("Scale Settings")
@export var target_scale: Vector2 = Vector2(1.2, 1.2)
@export var target_scale_3d: Vector3 = Vector3(1.2, 1.2, 1.2)
@export var scale_mode: ScaleMode = ScaleMode.TO_SCALE

# ===== 重写方法 =====

func _execute(node: Node, params: GFFParams) -> void:
	## 执行缩放效果
	var intensity = params.get_float("intensity", 1.0)
	var final_duration = params.get_float("duration", duration)
	var original_scale = _get_scale(node)

	var target

	match scale_mode:
		ScaleMode.TO_SCALE:
			if node is Node3D:
				target = target_scale_3d * intensity
			else:
				target = target_scale * intensity
		ScaleMode.ADDITIVE:
			if node is Node3D:
				target = original_scale + target_scale_3d * intensity
			else:
				target = original_scale + target_scale * intensity
		ScaleMode.MULTIPLICATIVE:
			if node is Node3D:
				target = original_scale * target_scale_3d * intensity
			else:
				target = original_scale * target_scale * intensity

	# 应用缓动曲线
	if easing_curve:
		var tween = node.create_tween()
		tween.tween_method(_apply_scale_curve.bind(node, original_scale, target), 0.0, 1.0, final_duration)
		await tween.finished
	else:
		var tween = node.create_tween()
		tween.tween_property(node, "scale", target, final_duration)
		await tween.finished

func _apply_scale_curve(t: float, node: Node, from, to) -> void:
	## 应用缩放曲线
	var value = easing_curve.sample(t)
	if node is Node3D:
		_set_scale(node, from.lerp(to, value))
	else:
		_set_scale(node, from.lerp(to, value))

func _get_default_intensity() -> float:
	return 1.0

func _get_default_duration() -> float:
	return duration
