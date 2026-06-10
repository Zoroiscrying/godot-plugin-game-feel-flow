class_name GFFImpulse
extends GFFFeedback

## Game Feel Flow Impulse Effect
##
## 冲量效果，支持RigidBody2D和RigidBody3D

# ===== Properties =====
@export_group("Impulse Settings")
@export var impulse_force: Vector3 = Vector3(0, -10, 0)
@export var impulse_point: Vector3 = Vector3.ZERO

# ===== Override Methods =====

func _execute(node: Node, params: GFFParams) -> void:
	var intensity = params.get_float("intensity", 1.0)
	var final_duration = params.get_float("duration", duration)
	var force = params.get_vector3("force", impulse_force) * intensity

	if node is RigidBody3D:
		node.apply_impulse(force, impulse_point)
	elif node is RigidBody2D:
		node.apply_impulse(Vector2(force.x, force.y), Vector2(impulse_point.x, impulse_point.y))
	else:
		push_warning("GFFImpulse: Target is not a RigidBody")

func _get_default_intensity() -> float:
	return 1.0

func _get_default_duration() -> float:
	return duration