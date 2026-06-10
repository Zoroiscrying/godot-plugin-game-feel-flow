extends RefCounted

## Alpha effect (supports Node2D, Control)

const GFFNodeHelperScript = preload("res://addons/game_feel_flow/core/gff_node_helper.gd")

var default_alpha: float = 0.0
var default_duration: float = 0.2
var default_intensity: float = 1.0

func apply(target: Node, params = null) -> void:
	var intensity = default_intensity
	var duration = default_duration
	var alpha = default_alpha

	if params:
		if params is RefCounted or params is Resource:
			if params.has_method("get_float"):
				intensity = params.get_float("intensity", default_intensity)
				duration = params.get_float("duration", default_duration)
				alpha = params.get_float("alpha", default_alpha)
		elif params is float:
			intensity = params

	var node = GFFNodeHelperScript.get_target_node(target)
	if not node:
		return

	var tween = node.create_tween()
	tween.tween_property(node, "modulate:a", alpha * intensity, duration)
	await tween.finished
