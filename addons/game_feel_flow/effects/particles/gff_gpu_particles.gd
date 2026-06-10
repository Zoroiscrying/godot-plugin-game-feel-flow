class_name GFFGPUParticles
extends GFFFeedback

## Game Feel Flow GPU Particles Effect
##
## GPU粒子效果，支持GPUParticles2D和GPUParticles3D

# ===== Properties =====
@export_group("GPU Particles Settings")
@export var particle_material: ParticleProcessMaterial
@export var amount: int = 16
@export var lifetime: float = 1.0
@export var emitting: bool = true
@export var offset: Vector3 = Vector3.ZERO

# ===== Override Methods =====

func _execute(node: Node, params: GFFParams) -> void:
	var intensity = params.get_float("intensity", 1.0)
	var final_duration = params.get_float("duration", lifetime)
	var final_amount = int(amount * intensity)

	# Create particles
	var particles: Node

	if node is Node2D:
		particles = GPUParticles2D.new()
		particles.amount = final_amount
		particles.lifetime = final_duration
		particles.emitting = emitting
		if particle_material:
			particles.process_material = particle_material
		particles.position = Vector2(offset.x, offset.y)
	elif node is Node3D:
		particles = GPUParticles3D.new()
		particles.amount = final_amount
		particles.lifetime = final_duration
		particles.emitting = emitting
		if particle_material:
			particles.process_material = particle_material
		particles.position = offset
	else:
		push_warning("GFFGPUParticles: Unsupported node type")
		return

	node.add_child(particles)

	# Wait for particles to finish
	await node.get_tree().create_timer(final_duration + 0.1).timeout
	particles.queue_free()

func _get_default_intensity() -> float:
	return 1.0

func _get_default_duration() -> float:
	return lifetime