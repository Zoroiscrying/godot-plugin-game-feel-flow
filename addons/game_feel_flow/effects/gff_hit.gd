extends RefCounted

## Hit Effect - Optimized
##
## Complete hit effect with visual feedback, timing, and intensity scaling

const GFFNodeHelperScript = preload("res://addons/game_feel_flow/core/gff_node_helper.gd")

# ===== Default Parameters =====
var default_intensity: float = 1.0
var default_duration: float = 0.3
var default_freeze_duration: float = 0.05
var default_shake_amplitude: float = 5.0
var default_knockback_distance: float = 20.0
var default_rotation_angle: float = 15.0
var default_flash_color: Color = Color.WHITE

func apply(target: Node, params = null) -> void:
	# Read parameters
	var intensity = default_intensity
	var duration = default_duration
	var freeze_duration = default_freeze_duration
	var shake_amplitude = default_shake_amplitude
	var knockback_distance = default_knockback_distance
	var rotation_angle = default_rotation_angle
	var flash_color = default_flash_color

	if params:
		if params is RefCounted or params is Resource:
			if params.has_method("get_float"):
				intensity = params.get_float("intensity", default_intensity)
				duration = params.get_float("duration", default_duration)
				freeze_duration = params.get_float("freeze_duration", default_freeze_duration)
				shake_amplitude = params.get_float("shake_amplitude", default_shake_amplitude)
				knockback_distance = params.get_float("knockback_distance", default_knockback_distance)
				rotation_angle = params.get_float("rotation_angle", default_rotation_angle)
			if params.has_method("get_color"):
				flash_color = params.get_color("flash_color", default_flash_color)
		elif params is float:
			intensity = params

	var node = GFFNodeHelperScript.get_target_node(target)
	if not node:
		return

	# Store original state
	var original_pos = GFFNodeHelperScript.get_position(node)
	var original_rot = GFFNodeHelperScript.get_rotation(node)
	var original_color = GFFNodeHelperScript.get_modulate(node)

	# Phase 1: Instant rotation + Flash
	var hit_rotation = deg_to_rad(rotation_angle * intensity)
	GFFNodeHelperScript.set_rotation(node, original_rot + hit_rotation)
	GFFNodeHelperScript.set_modulate(node, flash_color * intensity)

	# Phase 2: Freeze frame
	Engine.time_scale = 0.0
	await node.get_tree().create_timer(freeze_duration, true, false, true).timeout
	Engine.time_scale = 1.0

	# Phase 3: Shake + Color recovery
	var shake_duration = 0.15 * duration
	var elapsed = 0.0

	while elapsed < shake_duration:
		var t = elapsed / shake_duration
		var decay = 1.0 - t

		var offset = Vector3.ZERO
		offset.x = randf_range(-1, 1) * shake_amplitude * decay * 0.1
		offset.y = randf_range(-1, 1) * shake_amplitude * decay * 0.1

		if node is Node3D:
			GFFNodeHelperScript.set_position(node, original_pos + offset)
		else:
			GFFNodeHelperScript.set_position(node, original_pos + Vector2(offset.x, offset.y))

		var color_t = elapsed / shake_duration
		GFFNodeHelperScript.set_modulate(node, flash_color.lerp(original_color, color_t))

		await node.get_tree().process_frame
		elapsed += node.get_process_delta_time()

	GFFNodeHelperScript.set_modulate(node, original_color)

	# Phase 4: Knockback
	var knockback_dir = Vector2.RIGHT.rotated(randf() * TAU)
	var knockback_pos = original_pos + Vector3(knockback_dir.x, knockback_dir.y, 0) * knockback_distance * 0.1

	var tween = node.create_tween()
	if node is Node3D:
		tween.tween_property(node, "position", knockback_pos, duration * 0.3)
	else:
		tween.tween_property(node, "position", Vector2(knockback_pos.x, knockback_pos.y), duration * 0.3)
	await tween.finished

	# Phase 5: Rotation recovery
	var tween2 = node.create_tween()
	if node is Node3D:
		tween2.tween_property(node, "rotation:y", original_rot, duration * 0.4)
	else:
		tween2.tween_property(node, "rotation", original_rot, duration * 0.4)
	await tween2.finished
