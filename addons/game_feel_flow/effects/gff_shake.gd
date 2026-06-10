extends RefCounted

## Shake effect (supports Node2D, Node3D, Control)

const GFFNodeHelperScript = preload("res://addons/game_feel_flow/core/gff_node_helper.gd")

var default_amplitude: float = 10.0
var default_duration: float = 0.2
var default_intensity: float = 1.0
var falloff_curve: Curve = null

func apply(target: Node, params = null) -> void:
	var intensity = default_intensity
	var duration = default_duration
	var amplitude = default_amplitude * intensity * 0.1

	if params:
		if params is RefCounted or params is Resource:
			if params.has_method("get_float"):
				intensity = params.get_float("intensity", default_intensity)
				duration = params.get_float("duration", default_duration)
				amplitude = params.get_float("amplitude", default_amplitude) * intensity * 0.1
		elif params is float:
			intensity = params

	var node = GFFNodeHelperScript.get_target_node(target)
	if not node:
		return

	var original = GFFNodeHelperScript.get_position(node)
	var elapsed = 0.0

	while elapsed < duration:
		var t = elapsed / duration
		var decay = 1.0 - t
		if falloff_curve:
			decay = falloff_curve.sample(t)

		var offset = Vector3.ZERO
		offset.x = randf_range(-1, 1) * amplitude * decay
		offset.y = randf_range(-1, 1) * amplitude * decay
		offset.z = randf_range(-1, 1) * amplitude * decay

		if node is Node3D:
			GFFNodeHelperScript.set_position(node, original + offset)
		else:
			GFFNodeHelperScript.set_position(node, original + Vector2(offset.x, offset.y))

		await node.get_tree().process_frame
		elapsed += node.get_process_delta_time()

	GFFNodeHelperScript.set_position(node, original)
