@tool
class_name GFFGPUParticles
extends GFFEffect

## Game Feel Flow GPU Particles Effect
##
## GPU particle effect supporting GPUParticles2D and GPUParticles3D

# ===== Properties =====
@export_group("GPU Particles Settings")
@export var particle_material: ParticleProcessMaterial
@export var amount: int = 16
@export var lifetime: float = 1.0
@export var emitting: bool = true
@export var offset: Vector3 = Vector3.ZERO

# ===== State =====
var _spawned_particles: Node = null

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

	_spawned_particles = particles
	node.add_child(particles)

	# Wait for particles to finish
	var tree := node.get_tree() if node and is_instance_valid(node) else Engine.get_main_loop()
	var timer: SceneTreeTimer
	if tree is SceneTree:
		timer = tree.create_timer(final_duration + 0.1, true, false, true)
	else:
		timer = tree.create_timer(final_duration + 0.1)
	while _is_playing and timer.time_left > 0:
		await tree.process_frame

	if _is_playing and is_instance_valid(_spawned_particles):
		_spawned_particles.queue_free()
		_spawned_particles = null

func _stop() -> void:
	if is_instance_valid(_spawned_particles):
		_spawned_particles.queue_free()
		_spawned_particles = null

func _get_default_intensity() -> float:
	return 1.0

func _get_default_duration() -> float:
	return lifetime