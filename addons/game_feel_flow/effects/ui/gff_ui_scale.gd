class_name GFFUIScale
extends GFFFeedback

## Game Feel Flow UI Scale Effect
##
## UI缩放效果，专门针对Control节点优化

# ===== Properties =====
@export_group("UI Scale Settings")
@export var target_scale: Vector2 = Vector2(1.2, 1.2)
@export var scale_mode: ScaleMode = ScaleMode.TO_SCALE
@export var pivot_offset: Vector2 = Vector2.ZERO

enum ScaleMode {
	TO_SCALE,
	ADDITIVE,
	MULTIPLICATIVE
}

# ===== Override Methods =====

func _execute(node: Node, params: GFFParams) -> void:
	var intensity = params.get_float("intensity", 1.0)
	var final_duration = params.get_float("duration", duration)
	var scale = params.get_vector2("scale", target_scale)

	if not node is Control:
		push_warning("GFFUIScale: Target is not a Control")
		return

	var original_scale = node.scale
	var target: Vector2

	match scale_mode:
		ScaleMode.TO_SCALE:
			target = scale * intensity
		ScaleMode.ADDITIVE:
			target = original_scale + scale * intensity
		ScaleMode.MULTIPLICATIVE:
			target = original_scale * scale * intensity

	# Set pivot if specified
	if pivot_offset != Vector2.ZERO:
		node.pivot_offset = pivot_offset

	if easing_curve:
		var tween = node.create_tween()
		tween.tween_method(_apply_scale_curve.bind(node, original_scale, target), 0.0, 1.0, final_duration)
		await tween.finished
	else:
		var tween = node.create_tween()
		tween.tween_property(node, "scale", target, final_duration)
		await tween.finished

func _apply_scale_curve(t: float, node: Node, from: Vector2, to: Vector2) -> void:
	var value = easing_curve.sample(t)
	node.scale = from.lerp(to, value)

func _get_default_intensity() -> float:
	return 1.0

func _get_default_duration() -> float:
	return duration