@tool
class_name GFFEffectStack
extends Resource

## Game Feel Flow Feedback Stack
##
## Manages a group of running GFFEffect instances, handling overlap strategy, queuing, and stopping.
## Each GFFPlayer holds one stack internally.

# ===== Signals =====
signal effect_started(effect_id: String)
signal effect_finished(effect_id: String)
signal all_finished

# ===== State =====
var _active_effects: Dictionary = {}  # effect_id -> GFFEffect
var _active_targets: Dictionary = {}  # effect_id -> Node
var _effect_queues: Dictionary = {}   # effect_id -> Array[Dictionary]
var _playing_count: int = 0

# ===== Public Methods =====

func play(feedback: GFFEffect, target: Node, params: GFFParams = null) -> bool:
	## Try to push a feedback onto the stack and play it.
	## Decides whether to ignore, cancel, replace, or queue based on feedback.overlap_strategy.
	## Returns whether playback started successfully.
	if not feedback or not feedback.enabled:
		return false

	var effect_id = _get_effect_id(feedback)
	# ADD strategy allows multiple instances with the same label to run concurrently, so use a unique id to avoid dictionary collisions
	if feedback.overlap_strategy == GFFEffect.OverlapStrategy.ADD:
		effect_id = effect_id + "_" + str(feedback.get_instance_id())

	match feedback.overlap_strategy:
		GFFEffect.OverlapStrategy.IGNORE:
			if effect_id in _active_effects:
				return false
		GFFEffect.OverlapStrategy.CANCEL:
			if effect_id in _active_effects:
				stop_effect(effect_id)
		GFFEffect.OverlapStrategy.REPLACE:
			if effect_id in _active_effects:
				stop_effect(effect_id)
		GFFEffect.OverlapStrategy.QUEUE:
			if effect_id in _active_effects:
				if effect_id not in _effect_queues:
					_effect_queues[effect_id] = []
				_effect_queues[effect_id].append({"feedback": feedback, "target": target, "params": params})
				return false
		GFFEffect.OverlapStrategy.ADD:
			pass

	# Enforce max concurrent instances for ADD strategy.
	if feedback.max_concurrent > 0 and feedback.overlap_strategy == GFFEffect.OverlapStrategy.ADD:
		var base_id := _get_effect_id(feedback)
		var active_ids: Array[String] = []
		for id in _active_effects.keys():
			if id.begins_with(base_id + "_"):
				active_ids.append(id)
		while active_ids.size() >= feedback.max_concurrent:
			stop_effect(active_ids.pop_front())

	_feedback_apply(feedback, target, params, effect_id)
	return true

func stop(effect_id: String = "") -> void:
	## Stop effects. Stops all when no argument is passed.
	if effect_id.is_empty():
		for id in _active_effects.keys():
			var effect = _active_effects[id]
			if effect and effect.has_method("stop"):
				effect.stop()
		_active_effects.clear()
		_active_targets.clear()
		_effect_queues.clear()
		_playing_count = 0
		all_finished.emit()
	else:
		stop_effect(effect_id)

func stop_effect(effect_id: String) -> void:
	## Stop specified effect and clear its queue
	if effect_id in _active_effects:
		var effect = _active_effects[effect_id]
		if effect and effect.has_method("stop"):
			effect.stop()
		_active_effects.erase(effect_id)
		_active_targets.erase(effect_id)
	_effect_queues.erase(effect_id)

func stop_by_target(node: Node) -> void:
	## Stop all active effects and queued effects whose target is the given node or one of its descendants.
	if not node:
		return

	# Remove queued entries that target this subtree before stopping active effects,
	# so finishing an active effect does not immediately restart one of the removed entries.
	for effect_id in _effect_queues.keys():
		var queue: Array = _effect_queues[effect_id]
		var i := queue.size() - 1
		while i >= 0:
			var entry = queue[i]
			var entry_target: Node = entry.get("target")
			if is_instance_valid(entry_target) and _is_target_under_node(entry_target, node):
				queue.remove_at(i)
			i -= 1
		if queue.is_empty():
			_effect_queues.erase(effect_id)

	var ids_to_stop: Array[String] = []
	for effect_id in _active_effects.keys():
		var effect_target: Node = _active_targets.get(effect_id)
		if is_instance_valid(effect_target) and _is_target_under_node(effect_target, node):
			ids_to_stop.append(effect_id)

	for effect_id in ids_to_stop:
		var effect = _active_effects[effect_id]
		if effect and effect.has_method("stop"):
			effect.stop()
		_active_effects.erase(effect_id)
		_active_targets.erase(effect_id)
		_playing_count = max(_playing_count - 1, 0)
		effect_finished.emit(effect_id)

	if _playing_count == 0:
		all_finished.emit()

func is_playing() -> bool:
	return _playing_count > 0

func is_effect_playing(effect_id: String) -> bool:
	return effect_id in _active_effects

func get_active_effects() -> Dictionary:
	## Return a copy of the active effect dictionary
	return _active_effects.duplicate()

func clear() -> void:
	stop()

# ===== Internal Methods =====

func _feedback_apply(feedback: GFFEffect, target: Node, params: GFFParams, effect_id: String) -> void:
	_active_effects[effect_id] = feedback
	_active_targets[effect_id] = target
	_playing_count += 1
	effect_started.emit(effect_id)

	var finished_callable := _on_feedback_finished.bind(effect_id)
	if feedback.finished.is_connected(finished_callable):
		feedback.finished.disconnect(finished_callable)
	feedback.finished.connect(finished_callable, CONNECT_ONE_SHOT)
	feedback.apply(target, params)

func _on_feedback_finished(effect_id: String) -> void:
	_active_effects.erase(effect_id)
	_active_targets.erase(effect_id)
	_playing_count = max(_playing_count - 1, 0)
	effect_finished.emit(effect_id)

	# Process queue
	if effect_id in _effect_queues and not _effect_queues[effect_id].is_empty():
		var next = _effect_queues[effect_id].pop_front()
		_feedback_apply(next["feedback"], next["target"], next["params"], effect_id)
		return

	if _playing_count == 0:
		all_finished.emit()

func _get_effect_id(feedback: GFFEffect) -> String:
	if feedback.label.is_empty():
		return str(feedback.get_instance_id())
	return feedback.label

func _is_target_under_node(target: Node, node: Node) -> bool:
	return target == node or node.is_ancestor_of(target)
