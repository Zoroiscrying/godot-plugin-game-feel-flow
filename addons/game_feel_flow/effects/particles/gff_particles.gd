@tool
class_name GFFParticles
extends GFFEffect

## Game Feel Flow Particles Effect
##
## Particle effect supporting GPUParticles2D and GPUParticles3D

# ===== Properties =====
@export_group("Particles Settings")
@export var particle_scene: PackedScene
@export var emit_count: int = 10
@export var offset: Vector3 = Vector3.ZERO

# ===== State =====
var _spawned_particles: Node = null

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
	_spawned_particles = particles
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
	var tree := node.get_tree() if node and is_instance_valid(node) else Engine.get_main_loop()
	var timer: SceneTreeTimer
	if tree is SceneTree:
		timer = tree.create_timer(final_duration, true, false, true)
	else:
		timer = tree.create_timer(final_duration)
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
	return duration