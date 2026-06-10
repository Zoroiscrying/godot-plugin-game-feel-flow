extends RefCounted

## Time scale effect

var default_scale: float = 0.3
var default_duration: float = 1.0
var restore_original: bool = true

func apply(target: Node, params = null) -> void:
	var duration = default_duration
	var scale = default_scale

	if params:
		if params is RefCounted or params is Resource:
			if params.has_method("get_float"):
				duration = params.get_float("duration", default_duration)
				scale = params.get_float("scale", default_scale)
		elif params is float:
			scale = params

	var original = Engine.time_scale
	var tween = target.create_tween()
	tween.tween_method(_set_time_scale.bind(original), original, scale, duration)
	await tween.finished

	if restore_original:
		Engine.time_scale = original

func _set_time_scale(value: float, _original: float) -> void:
	Engine.time_scale = value
