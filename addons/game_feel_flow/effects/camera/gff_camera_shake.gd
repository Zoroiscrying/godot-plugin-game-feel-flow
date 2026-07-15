@tool
class_name GFFCameraShake
extends GFFEffect

## Game Feel Flow Camera Shake Effect
##
## Camera shake effect supporting Camera2D and Camera3D

# ===== Properties =====
@export_group("Camera Shake Settings")
@export var amplitude: float = 10.0
@export var frequency: float = 20.0
@export var axes: Vector3 = Vector3(1, 1, 0)
@export var attenuation_curve: Curve = null

# ===== State =====
var _shake_node: Node = null
var _original_camera_pos = null
var _original_camera_offset: Vector2 = Vector2.ZERO

# ===== Override Methods =====

func _execute(node: Node, params: GFFParams) -> void:
	_shake_node = node
	var final_amplitude = amplitude * params.get_float("intensity", 1.0)
	var final_duration = params.get_float("duration", duration)
	var final_frequency = params.get_float("frequency", frequency)
	var final_axes = params.get_vector3("axes", axes)

	_original_camera_pos = _get_position(node)
	if node is Camera2D:
		_original_camera_offset = node.offset

	var elapsed = 0.0
	var shake_interval = 1.0 / final_frequency

	while elapsed < final_duration and _is_playing:
		var t = elapsed / final_duration
		var decay = 1.0 - t

		if attenuation_curve:
			decay = attenuation_curve.sample(t)

		var offset = Vector3.ZERO
		offset.x = randf_range(-1, 1) * final_amplitude * decay * final_axes.x
		offset.y = randf_range(-1, 1) * final_amplitude * decay * final_axes.y
		offset.z = randf_range(-1, 1) * final_amplitude * decay * final_axes.z

		if node is Camera3D:
			node.position = _original_camera_pos + offset
		elif node is Camera2D:
			node.offset = Vector2(offset.x, offset.y)

		await node.get_tree().process_frame
		if not _is_playing:
			break
		elapsed += node.get_process_delta_time()

	if _is_playing:
		_restore_camera()

func _stop() -> void:
	if is_instance_valid(_shake_node):
		_restore_camera()
	_shake_node = null

func _restore_camera() -> void:
	if _shake_node is Camera2D:
		_shake_node.offset = _original_camera_offset
	else:
		_set_position(_shake_node, _original_camera_pos)

func _get_default_intensity() -> float:
	return 1.0

func _get_default_duration() -> float:
	return duration