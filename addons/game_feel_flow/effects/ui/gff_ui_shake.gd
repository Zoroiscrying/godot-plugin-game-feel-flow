class_name GFFUIShake
extends GFFFeedback

## Game Feel Flow UI Shake Effect
##
## UI震动效果，专门针对Control节点优化

# ===== Properties =====
@export_group("UI Shake Settings")
@export var amplitude: float = 5.0
@export var frequency: float = 20.0
@export var axes: Vector2 = Vector2(1, 1)
@export var attenuation_curve: Curve = null

# ===== Override Methods =====

func _execute(node: Node, params: GFFParams) -> void:
	var final_amplitude = amplitude * params.get_float("intensity", 1.0)
	var final_duration = params.get_float("duration", duration)
	var final_frequency = params.get_float("frequency", frequency)
	var final_axes = params.get_vector2("axes", axes)

	if not node is Control:
		push_warning("GFFUIShake: Target is not a Control")
		return

	var original_pos = node.position
	var elapsed = 0.0
	var shake_interval = 1.0 / final_frequency

	while elapsed < final_duration:
		var t = elapsed / final_duration
		var decay = 1.0 - t

		if attenuation_curve:
			decay = attenuation_curve.sample(t)

		var offset = Vector2.ZERO
		offset.x = randf_range(-1, 1) * final_amplitude * decay * final_axes.x
		offset.y = randf_range(-1, 1) * final_amplitude * decay * final_axes.y

		node.position = original_pos + offset

		await node.get_tree().process_frame
		elapsed += node.get_process_delta_time()

	node.position = original_pos

func _get_default_intensity() -> float:
	return 1.0

func _get_default_duration() -> float:
	return duration