class_name GFFTimeScale
extends GFFFeedback

## Game Feel Flow Time Scale Effect
##
## 时间缩放效果，改变Engine.time_scale

# ===== Properties =====
@export_group("Time Scale Settings")
@export var target_time_scale: float = 0.5
@export var time_scale_mode: TimeScaleMode = TimeScaleMode.TO_SCALE

enum TimeScaleMode {
	TO_SCALE,
	ADDITIVE,
	MULTIPLICATIVE
}

# ===== Override Methods =====

func _execute(node: Node, params: GFFParams) -> void:
	var intensity = params.get_float("intensity", 1.0)
	var final_duration = params.get_float("duration", duration)
	var time_scale = params.get_float("time_scale", target_time_scale)

	var original_time_scale = Engine.time_scale
	var target: float

	match time_scale_mode:
		TimeScaleMode.TO_SCALE:
			target = time_scale * intensity
		TimeScaleMode.ADDITIVE:
			target = original_time_scale + time_scale * intensity
		TimeScaleMode.MULTIPLICATIVE:
			target = original_time_scale * time_scale * intensity

	if easing_curve:
		var tween = node.create_tween()
		tween.tween_method(_apply_time_scale_curve.bind(original_time_scale, target), 0.0, 1.0, final_duration)
		await tween.finished
	else:
		var tween = node.create_tween()
		tween.tween_method(_apply_time_scale.bind(target), 0.0, 1.0, final_duration)
		await tween.finished

	Engine.time_scale = original_time_scale

func _apply_time_scale_curve(t: float, from: float, to: float) -> void:
	var value = easing_curve.sample(t)
	Engine.time_scale = lerp(from, to, value)

func _apply_time_scale(t: float, target: float) -> void:
	Engine.time_scale = target

func _get_default_intensity() -> float:
	return 1.0

func _get_default_duration() -> float:
	return duration