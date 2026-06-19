class_name GFFShakeRotation
extends GFFFeedback

## Game Feel Flow Shake Rotation Effect
##
## 旋转震动效果，支持Node2D、Node3D和Control

# ===== 属性 =====
@export_group("Shake Settings")
@export var amplitude: float = 10.0
@export var frequency: float = 15.0
@export var attenuation_curve: Curve = null

# ===== 重写方法 =====

func _execute(node: Node, params: GFFParams) -> void:
	var intensity = params.get_float("intensity", 1.0)
	var final_duration = params.get_float("duration", duration)
	var final_amplitude = params.get_float("amplitude", amplitude) * intensity
	var final_frequency = params.get_float("frequency", frequency)
	
	var original_rotation = _get_rotation(node)
	var elapsed = 0.0
	var shake_interval = 1.0 / final_frequency
	
	while elapsed < final_duration:
		var t = elapsed / final_duration
		var decay = 1.0 - t
		
		# 应用衰减曲线
		if attenuation_curve:
			decay = attenuation_curve.sample(t)
		
		# 计算偏移（角度转弧度）
		var offset_rad = deg_to_rad(randf_range(-1, 1) * final_amplitude * decay)
		
		# 应用旋转
		_set_rotation(node, original_rotation + offset_rad)
		
		# 等待下一帧
		await node.get_tree().process_frame
		elapsed += node.get_process_delta_time()
	
	# 恢复旋转
	_set_rotation(node, original_rotation)

func _get_default_intensity() -> float:
	return 1.0

func _get_default_duration() -> float:
	return duration
