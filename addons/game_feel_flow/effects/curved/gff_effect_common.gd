@tool
class_name GFFEffectCommon
extends GFFEffect

## Game Feel Flow Common Effect
##
## Generic property animation effect: combine a Target and a Tweener to produce any property change.

@export_group("Common Effect")
@export var target: GFFTarget = null
@export var tweener: GFFTweener = null

# Captured start/end values for loop modes that must not drift with the node's current state.
# Used by PING_PONG (alternates direction) and MIRROR (reverses target offset).
var _loop_base_from: Variant = null
var _loop_base_to: Variant = null

func _execute(node: Node, params: GFFParams) -> void:
	if target == null:
		push_warning("GFFEffectCommon: No target configured")
		return
	if tweener == null:
		push_warning("GFFEffectCommon: No tweener configured")
		return
	if not tweener.can_handle(target):
		push_warning("GFFEffectCommon: Tweener %s cannot handle target %s" % [tweener.get_tweener_name(), target.get_target_name()])
		return

	var intensity := params.get_float("intensity", _get_default_intensity())
	var final_duration := params.get_float("duration", duration)

	var from := target.get_start_value(node, intensity)
	var to := target.get_end_value(node, intensity)

	# Capture the original start/end values on the first iteration so PING_PONG
	# can alternate between fixed values instead of drifting with the node state.
	if _loop_iteration_index == 0:
		_loop_base_from = from
		_loop_base_to = to

	match loop_mode:
		LoopMode.REPEAT:
			# Use the values computed from the node's current state.
			pass
		LoopMode.PING_PONG:
			# Keep target parameters, reverse tween direction on odd iterations.
			from = _loop_base_from
			to = _loop_base_to
			if _loop_iteration_index % 2 == 1:
				var tmp = from
				from = to
				to = tmp
		LoopMode.MIRROR:
			# Keep tween direction, reverse target parameters on odd iterations.
			if _loop_iteration_index % 2 == 1:
				to = target.get_end_value(node, -intensity)

	tweener.apply_params(params)
	await tweener.tween_node(node, target, from, to, final_duration, easing_curve)

func _stop() -> void:
	if tweener and tweener.has_method("stop"):
		tweener.stop()

func _save_initial_state(node: Node) -> void:
	if target and target.can_restore(node):
		_initial_state = target.get_restorable_state(node)
	else:
		super._save_initial_state(node)

func _restore_initial_state(node: Node) -> void:
	if target and target.can_restore(node):
		target.restore_state(node, _initial_state)
	else:
		super._restore_initial_state(node)
