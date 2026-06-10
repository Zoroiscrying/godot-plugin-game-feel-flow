class_name GFFUIAlpha
extends GFFFeedback

## Game Feel Flow UI Alpha Effect
##
## UI透明度效果，专门针对Control节点优化

# ===== Properties =====
@export_group("UI Alpha Settings")
@export var target_alpha: float = 0.0
@export var alpha_mode: AlphaMode = AlphaMode.TO_ALPHA

enum AlphaMode {
	TO_ALPHA,
	ADDITIVE,
	MULTIPLICATIVE
}

# ===== Override Methods =====

func _execute(node: Node, params: GFFParams) -> void:
	var intensity = params.get_float("intensity", 1.0)
	var final_duration = params.get_float("duration", duration)
	var alpha = params.get_float("alpha", target_alpha)

	if not node is Control:
		push_warning("GFFUIAlpha: Target is not a Control")
		return

	var original_modulate = node.modulate
	var original_alpha = original_modulate.a
	var target_alpha_value: float

	match alpha_mode:
		AlphaMode.TO_ALPHA:
			target_alpha_value = alpha * intensity
		AlphaMode.ADDITIVE:
			target_alpha_value = original_alpha + alpha * intensity
		AlphaMode.MULTIPLICATIVE:
			target_alpha_value = original_alpha * alpha * intensity

	var target_color = original_modulate
	target_color.a = target_alpha_value

	if easing_curve:
		var tween = node.create_tween()
		tween.tween_method(_apply_alpha_curve.bind(node, original_modulate, target_color), 0.0, 1.0, final_duration)
		await tween.finished
	else:
		var tween = node.create_tween()
		tween.tween_property(node, "modulate", target_color, final_duration)
		await tween.finished

func _apply_alpha_curve(t: float, node: Node, from: Color, to: Color) -> void:
	var value = easing_curve.sample(t)
	node.modulate = from.lerp(to, value)

func _get_default_intensity() -> float:
	return 1.0

func _get_default_duration() -> float:
	return duration