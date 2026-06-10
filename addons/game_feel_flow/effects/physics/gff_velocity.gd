class_name GFFVelocity
extends GFFFeedback

## Game Feel Flow Velocity Effect
##
## 速度效果，支持RigidBody2D和RigidBody3D

# ===== Properties =====
@export_group("Velocity Settings")
@export var target_velocity: Vector3 = Vector3(0, -10, 0)
@export var velocity_mode: VelocityMode = VelocityMode.TO_VELOCITY

enum VelocityMode {
	TO_VELOCITY,
	ADDITIVE,
	MULTIPLICATIVE
}

# ===== Override Methods =====

func _execute(node: Node, params: GFFParams) -> void:
	var intensity = params.get_float("intensity", 1.0)
	var final_duration = params.get_float("duration", duration)
	var velocity = params.get_vector3("velocity", target_velocity) * intensity

	if node is RigidBody3D:
		var original_velocity = node.linear_velocity
		var target: Vector3

		match velocity_mode:
			VelocityMode.TO_VELOCITY:
				target = velocity
			VelocityMode.ADDITIVE:
				target = original_velocity + velocity
			VelocityMode.MULTIPLICATIVE:
				target = original_velocity * velocity

		if easing_curve:
			var tween = node.create_tween()
			tween.tween_method(_apply_velocity_curve.bind(node, original_velocity, target), 0.0, 1.0, final_duration)
			await tween.finished
		else:
			var tween = node.create_tween()
			tween.tween_property(node, "linear_velocity", target, final_duration)
			await tween.finished
	elif node is RigidBody2D:
		var original_velocity = node.linear_velocity
		var velocity_2d = Vector2(velocity.x, velocity.y)
		var target: Vector2

		match velocity_mode:
			VelocityMode.TO_VELOCITY:
				target = velocity_2d
			VelocityMode.ADDITIVE:
				target = original_velocity + velocity_2d
			VelocityMode.MULTIPLICATIVE:
				target = original_velocity * velocity_2d

		if easing_curve:
			var tween = node.create_tween()
			tween.tween_method(_apply_velocity_2d_curve.bind(node, original_velocity, target), 0.0, 1.0, final_duration)
			await tween.finished
		else:
			var tween = node.create_tween()
			tween.tween_property(node, "linear_velocity", target, final_duration)
			await tween.finished
	else:
		push_warning("GFFVelocity: Target is not a RigidBody")

func _apply_velocity_curve(t: float, node: Node, from: Vector3, to: Vector3) -> void:
	var value = easing_curve.sample(t)
	node.linear_velocity = from.lerp(to, value)

func _apply_velocity_2d_curve(t: float, node: Node, from: Vector2, to: Vector2) -> void:
	var value = easing_curve.sample(t)
	node.linear_velocity = from.lerp(to, value)

func _get_default_intensity() -> float:
	return 1.0

func _get_default_duration() -> float:
	return duration