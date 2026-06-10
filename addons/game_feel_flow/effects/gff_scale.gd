extends RefCounted

## Scale effect (supports Node2D, Node3D, Control)

const GFFNodeHelperScript = preload("res://addons/game_feel_flow/core/gff_node_helper.gd")

var default_target_scale: Vector2 = Vector2(1.5, 1.5)
var default_target_scale_3d: Vector3 = Vector3(1.5, 1.5, 1.5)
var default_duration: float = 0.2
var default_intensity: float = 1.0
var curve: Curve = null

func apply(target: Node, params = null) -> void:
	var intensity = default_intensity
	var duration = default_duration

	if params:
		if params is RefCounted or params is Resource:
			if params.has_method("get_float"):
				intensity = params.get_float("intensity", default_intensity)
				duration = params.get_float("duration", default_duration)
		elif params is float:
			intensity = params

	var node = GFFNodeHelperScript.get_target_node(target)
	if not node:
		return

	var target_scale
	if node is Node3D:
		target_scale = default_target_scale_3d * intensity
	else:
		target_scale = default_target_scale * intensity

	var tween = node.create_tween()
	tween.tween_property(node, "scale", target_scale, duration)
	await tween.finished
