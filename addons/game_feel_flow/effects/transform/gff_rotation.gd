class_name GFFRotation
extends GFFFeedback

## Game Feel Flow Rotation Effect
##
## 旋转效果，支持Node2D、Node3D和Control

# ===== Properties =====
@export_group("Rotation Settings")
@export var target_rotation: float = 0.0
@export var rotation_mode: RotationMode = RotationMode.TO_ROTATION
@export var rotate_3d: Vector3 = Vector3.ZERO

enum RotationMode {
	TO_ROTATION,
	ADDITIVE,
	MULTIPLICATIVE
}

# ===== Override Methods =====

func _execute(node: Node, params: GFFParams) -> void:
	var intensity = params.get_float("intensity", 1.0)
	var final_duration = params.get_float("duration", duration)
	var rotation = params.get_float("rotation", target_rotation)

	var original_rotation = _get_rotation(node)
	var target: float

	match rotation_mode:
		RotationMode.TO_ROTATION:
			target = rotation * intensity
		RotationMode.ADDITIVE:
			target = original_rotation + rotation * intensity
		RotationMode.MULTIPLICATIVE:
			target = original_rotation * rotation * intensity

	if node is Node3D:
		var original_rotation_3d = node.rotation
		var target_rotation_3d = original_rotation_3d + rotate_3d * intensity

		if easing_curve:
			var tween = node.create_tween()
			tween.tween_method(_apply_rotation_3d_curve.bind(node, original_rotation_3d, target_rotation_3d), 0.0, 1.0, final_duration)
			await tween.finished
		else:
			var tween = node.create_tween()
			tween.tween_property(node, "rotation", target_rotation_3d, final_duration)
			await tween.finished
	else:
		if easing_curve:
			var tween = node.create_tween()
			tween.tween_method(_apply_rotation_curve.bind(node, original_rotation, target), 0.0, 1.0, final_duration)
			await tween.finished
		else:
			var tween = node.create_tween()
			tween.tween_property(node, "rotation", target, final_duration)
			await tween.finished

func _apply_rotation_curve(t: float, node: Node, from: float, to: float) -> void:
	var value = easing_curve.sample(t)
	_set_rotation(node, lerp(from, to, value))

func _apply_rotation_3d_curve(t: float, node: Node, from: Vector3, to: Vector3) -> void:
	var value = easing_curve.sample(t)
	node.rotation = from.lerp(to, value)

func _get_default_intensity() -> float:
	return 1.0

func _get_default_duration() -> float:
	return duration