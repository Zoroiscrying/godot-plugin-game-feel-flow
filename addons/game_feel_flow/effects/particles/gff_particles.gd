class_name GFFParticles
extends GFFFeedback

## Game Feel Flow Particles Effect
##
## 粒子效果，支持GPUParticles2D和GPUParticles3D

# ===== Properties =====
@export_group("Particles Settings")
@export var particle_scene: PackedScene
@export var emit_count: int = 10
@export var offset: Vector3 = Vector3.ZERO

# ===== Override Methods =====

func _execute(node: Node, params: GFFParams) -> void:
	var intensity = params.get_float("intensity", 1.0)
	var final_duration = params.get_float("duration", duration)
	var count = int(emit_count * intensity)

	if not particle_scene:
		push_warning("GFFParticles: No particle scene assigned")
		return

	# Instance particles
	var particles = particle_scene.instantiate()
	node.add_child(particles)

	# Set position offset
	if particles is Node3D:
		particles.position = offset
	elif particles is Node2D:
		particles.position = Vector2(offset.x, offset.y)

	# Emit
	if particles is GPUParticles2D:
		particles.amount = count
		particles.emitting = true
	elif particles is GPUParticles3D:
		particles.amount = count
		particles.emitting = true
	elif particles is CPUParticles2D:
		particles.amount = count
		particles.emitting = true
	elif particles is CPUParticles3D:
		particles.amount = count
		particles.emitting = true

	# Wait and cleanup
	await node.get_tree().create_timer(final_duration).timeout
	particles.queue_free()

func _get_default_intensity() -> float:
	return 1.0

func _get_default_duration() -> float:
	return duration