extends RefCounted

## Flash effect (supports Node2D, Control)

const GFFNodeHelperScript = preload("res://addons/game_feel_flow/core/gff_node_helper.gd")

var default_color: Color = Color.WHITE
var default_duration: float = 0.1
var default_intensity: float = 1.0
var flash_count: int = 1

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

	var original = GFFNodeHelperScript.get_modulate(node)

	for i in range(flash_count):
		GFFNodeHelperScript.set_modulate(node, color * intensity)
		await node.get_tree().create_timer(duration / flash_count / 2).timeout
		GFFNodeHelperScript.set_modulate(node, original)
		await node.get_tree().create_timer(duration / flash_count / 2).timeout
