extends RefCounted

## Freeze frame effect

var default_duration: float = 0.05

func apply(target: Node, params = null) -> void:
	var duration = default_duration

	if params:
		if params is RefCounted or params is Resource:
			if params.has_method("get_float"):
				duration = params.get_float("duration", default_duration)
		elif params is float:
			duration = params

	var original = Engine.time_scale
	Engine.time_scale = 0.0
	await Engine.get_main_loop().create_timer(duration, true, false, true).timeout
	Engine.time_scale = original
