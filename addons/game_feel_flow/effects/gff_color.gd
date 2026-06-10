extends RefCounted

## Color effect (supports Node2D, Control)

const GFFNodeHelperScript = preload("res://addons/game_feel_flow/core/gff_node_helper.gd")

var default_color: Color = Color.WHITE
var default_duration: float = 0.2
var default_intensity: float = 1.0

func apply(target: Node, params = null) -> void:
	var intensity = default_intensity
	var duration = default_duration
	var color = default_color

	if params:
		if params is RefCounted or params is Resource:
			if params.has_method("get_float"):
				intensity = params.get_float("intensity", default_intensity)
				duration = params.get_float("duration", default_duration)
			if params.has_method("get_color"):
				color = params.get_color("color", default_color)
		elif params is float:
			intensity = params

	var node = GFFNodeHelperScript.get_target_node(target)
	if not node:
		return

	var tween = node.create_tween()
	tween.tween_property(node, "modulate", color * intensity, duration)
	await tween.finished
