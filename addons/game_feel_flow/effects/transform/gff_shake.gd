class_name GFFShake
extends GFFFeedback

## Game Feel Flow Shake Effect
##
## 震动效果，支持Node2D、Node3D和Control

# ===== 属性 =====
@export_group("Shake Settings")
@export var amplitude: float = 5.0
@export var frequency: float = 15.0
@export var axes: Vector3 = Vector3(1, 1, 0)
@export var attenuation_curve: Curve = null

# ===== 重写方法 =====

func _execute(node: Node, params: GFFParams) -> void:
	## 执行震动效果
	var intensity = params.get_float("intensity", 1.0)
	var final_amplitude = params.get_float("amplitude", amplitude * intensity)
	var final_duration = params.get_float("duration", duration)
	var final_frequency = params.get_float("frequency", frequency)
	var final_axes = params.get_vector3("axes", axes)

	var original_pos = _get_position(node)
	var elapsed = 0.0
	var shake_interval = 1.0 / final_frequency

	while elapsed < final_duration:
		var t = elapsed / final_duration
		var decay = 1.0 - t

		# 应用衰减曲线
		if attenuation_curve:
			decay = attenuation_curve.sample(t)

		# 计算偏移
		var offset = Vector3.ZERO
		offset.x = randf_range(-1, 1) * final_amplitude * decay * final_axes.x
		offset.y = randf_range(-1, 1) * final_amplitude * decay * final_axes.y
		offset.z = randf_range(-1, 1) * final_amplitude * decay * final_axes.z

		# 应用位置
		if node is Node3D:
			_set_position(node, original_pos + offset)
		else:
			_set_position(node, original_pos + Vector2(offset.x, offset.y))

		# 等待下一帧
		await node.get_tree().process_frame
		elapsed += node.get_process_delta_time()

	# 恢复位置
	_set_position(node, original_pos)

func _get_default_intensity() -> float:
	return 1.0

func _get_default_duration() -> float:
	return duration
