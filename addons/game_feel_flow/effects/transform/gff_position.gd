class_name GFFPosition
extends GFFFeedback

## Game Feel Flow Position Effect
##
## 位置效果，支持Node2D、Node3D和Control

# ===== Properties =====
@export_group("Position Settings")
@export var target_position: Vector3 = Vector3.ZERO
@export var position_mode: PositionMode = PositionMode.TO_POSITION
@export var relative_to_current: bool = true

enum PositionMode {
	TO_POSITION,
	ADDITIVE,
	MULTIPLICATIVE
}

# ===== Override Methods =====

func _execute(node: Node, params: GFFParams) -> void:
	var intensity = params.get_float("intensity", 1.0)
	var final_duration = params.get_float("duration", duration)
	var position = params.get_vector3("position", target_position)

	var original_position = _get_position(node)
	var target

	match position_mode:
		PositionMode.TO_POSITION:
			if relative_to_current:
				target = original_position + position * intensity
			else:
				target = position * intensity
		PositionMode.ADDITIVE:
			target = original_position + position * intensity
		PositionMode.MULTIPLICATIVE:
			if node is Node3D:
				target = Vector3(
					original_position.x * position.x * intensity,
					original_position.y * position.y * intensity,
					original_position.z * position.z * intensity
				)
			else:
				target = Vector2(
					original_position.x * position.x * intensity,
					original_position.y * position.y * intensity
				)

	if easing_curve:
		var tween = node.create_tween()
		tween.tween_method(_apply_position_curve.bind(node, original_position, target), 0.0, 1.0, final_duration)
		await tween.finished
	else:
		var tween = node.create_tween()
		tween.tween_property(node, "position", target, final_duration)
		await tween.finished

func _apply_position_curve(t: float, node: Node, from, to) -> void:
	var value = easing_curve.sample(t)
	if node is Node3D:
		_set_position(node, from.lerp(to, value))
	else:
		_set_position(node, Vector2(from.x, from.y).lerp(Vector2(to.x, to.y), value))

func _get_default_intensity() -> float:
	return 1.0

func _get_default_duration() -> float:
	return duration