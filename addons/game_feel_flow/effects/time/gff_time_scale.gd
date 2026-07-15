@tool
class_name GFFTimeScale
extends GFFEffect

## Game Feel Flow Time Scale Effect
##
## Time scale effect, changes Engine.time_scale through the time-scale stack.

# ===== Properties =====
@export_group("Time Scale Settings")
@export var target_time_scale: float = 0.5
@export var time_scale_mode: TimeScaleMode = TimeScaleMode.TO_SCALE

enum TimeScaleMode {
	TO_SCALE,
	ADDITIVE,
	MULTIPLICATIVE
}

func _init() -> void:
	requires_target = false

func _execute(node: Node, params: GFFParams) -> void:
	var intensity = params.get_float("intensity", 1.0)
	var final_duration = params.get_float("duration", duration)
	var time_scale = params.get_float("time_scale", target_time_scale)

	var current_scale := GFFTimeScaleManager.get_current_time_scale()
	var target: float

	match time_scale_mode:
		TimeScaleMode.TO_SCALE:
			target = time_scale * intensity
		TimeScaleMode.ADDITIVE:
			target = current_scale + time_scale * intensity
		TimeScaleMode.MULTIPLICATIVE:
			target = current_scale * time_scale * intensity

	GFFTimeScaleManager.push(current_scale, self)

	var tween_target: Node = node if node and is_instance_valid(node) else Engine.get_main_loop().root
	if not tween_target:
		push_warning("GFFTimeScale: No valid node to host tween")
		GFFTimeScaleManager.pop(self)
		return

	var tween = tween_target.create_tween()
	tween.set_ignore_time_scale(true)
	_register_active_tween(tween)
	if easing_curve:
		tween.tween_method(_update_time_scale_curve.bind(current_scale, target), 0.0, 1.0, final_duration)
	else:
		tween.tween_method(_update_time_scale.bind(current_scale, target), 0.0, 1.0, final_duration)
	await _await_tween(tween)

	if _is_playing:
		GFFTimeScaleManager.pop(self)

func _stop() -> void:
	GFFTimeScaleManager.pop(self)

func _update_time_scale_curve(t: float, from: float, to: float) -> void:
	var value = easing_curve.sample(t)
	GFFTimeScaleManager.update(self, lerp(from, to, value))

func _update_time_scale(t: float, from: float, to: float) -> void:
	GFFTimeScaleManager.update(self, lerp(from, to, t))

func _get_default_intensity() -> float:
	return 1.0

func _get_default_duration() -> float:
	return duration
