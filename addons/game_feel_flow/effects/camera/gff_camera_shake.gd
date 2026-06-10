class_name GFFCameraShake
extends GFFFeedback

## Game Feel Flow Camera Shake Effect
##
## 相机震动效果，支持Camera2D和Camera3D

# ===== Properties =====
@export_group("Camera Shake Settings")
@export var amplitude: float = 10.0
@export var frequency: float = 20.0
@export var axes: Vector3 = Vector3(1, 1, 0)
@export var attenuation_curve: Curve = null

# ===== Override Methods =====

func _execute(node: Node, params: GFFParams) -> void:
	var final_amplitude = amplitude * params.get_float("intensity", 1.0)
	var final_duration = params.get_float("duration", duration)
	var final_frequency = params.get_float("frequency", frequency)
	var final_axes = params.get_vector3("axes", axes)

	var original_pos = _get_position(node)
	var elapsed = 0.0
	var shake_interval = 1.0 / final_frequency

	while elapsed < final_duration:
		var t = elapsed / final_duration
		var decay = 1.0 - t

		if attenuation_curve:
			decay = attenuation_curve.sample(t)

		var offset = Vector3.ZERO
		offset.x = randf_range(-1, 1) * final_amplitude * decay * final_axes.x
		offset.y = randf_range(-1, 1) * final_amplitude * decay * final_axes.y
		offset.z = randf_range(-1, 1) * final_amplitude * decay * final_axes.z

		if node is Camera3D:
			node.position = original_pos + offset
		elif node is Camera2D:
			node.offset = Vector2(offset.x, offset.y)

		await node.get_tree().process_frame
		elapsed += node.get_process_delta_time()

	if node is Camera2D:
		node.offset = Vector2.ZERO
	else:
		_set_position(node, original_pos)

func _get_default_intensity() -> float:
	return 1.0

func _get_default_duration() -> float:
	return duration