class_name GFFUIColor
extends GFFFeedback

## Game Feel Flow UI Color Effect
##
## UI颜色效果，专门针对Control节点优化

# ===== Properties =====
@export_group("UI Color Settings")
@export var target_color: Color = Color.WHITE
@export var color_mode: ColorMode = ColorMode.TO_COLOR

enum ColorMode {
	TO_COLOR,
	MULTIPLY,
	ADD
}

# ===== Override Methods =====

func _execute(node: Node, params: GFFParams) -> void:
	var intensity = params.get_float("intensity", 1.0)
	var final_duration = params.get_float("duration", duration)
	var color = params.get_color("color", target_color)

	if not node is Control:
		push_warning("GFFUIColor: Target is not a Control")
		return

	var original_modulate = node.modulate
	var target: Color

	match color_mode:
		ColorMode.TO_COLOR:
			target = color * intensity
		ColorMode.MULTIPLY:
			target = original_modulate * color * intensity
		ColorMode.ADD:
			target = original_modulate + color * intensity

	if easing_curve:
		var tween = node.create_tween()
		tween.tween_method(_apply_color_curve.bind(node, original_modulate, target), 0.0, 1.0, final_duration)
		await tween.finished
	else:
		var tween = node.create_tween()
		tween.tween_property(node, "modulate", target, final_duration)
		await tween.finished

func _apply_color_curve(t: float, node: Node, from: Color, to: Color) -> void:
	var value = easing_curve.sample(t)
	node.modulate = from.lerp(to, value)

func _get_default_intensity() -> float:
	return 1.0

func _get_default_duration() -> float:
	return duration