@tool
class_name GFFFreezeFrame
extends GFFEffect

## Game Feel Flow Freeze Frame Effect
##
## Freeze frame effect, pauses the scene tree using a time-scale stack.

func _init() -> void:
	requires_target = false
	restore_after_play = false

func _execute(node: Node, params: GFFParams) -> void:
	var final_duration = params.get_float("duration", duration)

	GFFTimeScaleManager.push(0.0, self)

	var tween_host: Node = node
	if not is_instance_valid(tween_host):
		var tree := Engine.get_main_loop() as SceneTree
		tween_host = tree.root if tree else null
	if tween_host == null:
		GFFTimeScaleManager.pop(self)
		return

	var tween = tween_host.create_tween()
	tween.set_ignore_time_scale(true)
	_register_active_tween(tween)
	tween.tween_interval(final_duration)
	await _await_tween(tween)

	if _is_playing:
		GFFTimeScaleManager.pop(self)

func _stop() -> void:
	GFFTimeScaleManager.pop(self)

func _get_default_intensity() -> float:
	return 1.0

func _get_default_duration() -> float:
	return duration
