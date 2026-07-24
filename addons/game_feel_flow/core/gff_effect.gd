@tool
class_name GFFEffect
extends Resource

## Game Feel Flow Feedback Base
##
## Base class for all effects. Inherits Resource to support Inspector config and .tres files

# ===== Overlap Strategy =====
enum OverlapStrategy {
	ADD,      # Stack - multiple effects active simultaneously
	REPLACE,  # Replace - new effect replaces old
	QUEUE,    # Queue - wait for previous to finish
	IGNORE,   # Ignore - skip if already playing
	CANCEL    # Cancel - stop current, play new
}

# ===== Base Properties =====
@export var enabled: bool = true
@export var label: String = ""
@export var priority: int = 0
@export var overlap_strategy: OverlapStrategy = OverlapStrategy.REPLACE
@export var max_concurrent: int = 0

# ===== Time Control =====
@export_group("Timing")
@export var duration: float = 0.3
@export var delay: float = 0.0
@export var cooldown: float = 0.0

# ===== Recovery Control =====
@export_group("Restore")
@export var restore_after_play: bool = true
## How to return to the pre-play state after the effect finishes.
## - Immediate: snap back now
## - Gradual: tween back over [member restore_duration]
## - Custom: override [method _restore_custom] in a script (see help when Custom is selected)
@export var restore_mode: RestoreMode = RestoreMode.IMMEDIATE:
	set(value):
		restore_mode = value
		notify_property_list_changed()
## Tween / timing length for Gradual; Custom overrides can read this same field.
@export var restore_duration: float = 0.3
## How to implement Custom restore (read-only). Only visible when mode is Custom.
@export_multiline var custom_restore_help: String = CUSTOM_RESTORE_HELP

const CUSTOM_RESTORE_HELP := """Custom restore is code, not Inspector settings.

1. Attach a script that extends this effect (Script → Extend / New Script on the resource).
2. Override:

func _restore_custom(node: Node) -> void:
	# restore_duration is available on self
	await get_tree().create_timer(restore_duration).timeout
	_restore_initial_state(node)

3. Use restore_duration for your own timing.
4. Call _restore_initial_state(node) for the default snap, or restore manually.

A dedicated Restoration resource may replace this hook later."""

enum RestoreMode {
	IMMEDIATE,  ## Snap properties back instantly
	GRADUAL,    ## Tween back over restore_duration
	CUSTOM,     ## Override _restore_custom() in a script; see custom_restore_help
}

# ===== Looping =====
@export_group("Looping")
## Number of extra loops. 0 means play once, -1 means infinite loop until stop() is called.
@export var loop_count: int = 0
## How the effect behaves across loop iterations.
@export var loop_mode: LoopMode = LoopMode.REPEAT
## Delay between loop iterations (seconds).
@export var loop_delay: float = 0.0
## If true, restore the initial state between iterations. Usually left false for continuous loops.
@export var restore_between_loops: bool = false

enum LoopMode {
	REPEAT,   # Each iteration plays from start to end.
	PING_PONG,# Alternates direction each iteration (start->end, end->start, ...).
	MIRROR,   # Curve-time mirror; currently behaves like PingPong.
}

# ===== Randomness =====
@export_group("Randomness")
@export var random_duration_min: float = 1.0
@export var random_duration_max: float = 1.0
@export var random_intensity_min: float = 1.0
@export var random_intensity_max: float = 1.0

# ===== Curve =====
@export_group("Curve")
@export var easing_curve: Curve = null

# ===== Target Requirements =====
## Whether an operable node target is required. Global effects (e.g. freeze frame, time scale) can set this false,
## so execution continues even if target is null.
@export var requires_target: bool = true

# ===== Signals =====
signal started
signal finished

# ===== State =====
var _is_playing: bool = false
var _initial_state: Dictionary = {}
var _last_play_time: float = 0.0
var _active_tweens: Array[Tween] = []
var _loop_iteration_index: int = 0

# ===== Public Methods =====

func apply(target: Node, params: GFFParams = null) -> void:
	## Execute effect
	if not enabled:
		return

	# Reentrancy guard: the same instance cannot execute concurrently, otherwise _is_playing state becomes inconsistent.
	# CANCEL / REPLACE stops the current effect and re-executes; other strategies simply ignore.
	if _is_playing:
		match overlap_strategy:
			OverlapStrategy.CANCEL, OverlapStrategy.REPLACE:
				stop()
			_:
				return

	# Check cooldown
	if cooldown > 0.0 and Time.get_ticks_msec() / 1000.0 - _last_play_time < cooldown:
		return

	# Check target node validity
	if requires_target and (not target or not is_instance_valid(target)):
		push_warning("GFFEffect: Target node required but not valid for effect: ", label)
		return

	# Delay execution
	if delay > 0.0:
		var tree = target.get_tree() if target and is_instance_valid(target) else Engine.get_main_loop()
		if tree is SceneTree:
			await tree.create_timer(delay, true, false, true).timeout
		else:
			await tree.create_timer(delay).timeout
		if requires_target and (not target or not is_instance_valid(target)):
			return

		if not _is_playing:
			return

	# Resolve target node
	var node = _resolve_target(target)
	if requires_target and not node:
		push_warning("GFFEffect: No valid target node found for effect: ", label)
		return

	# Save initial state
	if restore_after_play and is_instance_valid(node):
		_save_initial_state(node)

	# Execute effect (with optional looping)
	_is_playing = true
	started.emit()

	var iteration := 0
	var remaining_loops := loop_count
	# remaining_loops < 0 means infinite; 0 means play once; >0 means that many extra loops.

	while true:
		if not _is_playing:
			break
		if requires_target and not is_instance_valid(node):
			break

		_loop_iteration_index = iteration

		# Calculate random parameters per iteration
		var final_duration = _get_duration_param(params) * randf_range(random_duration_min, random_duration_max)
		var final_intensity = _get_intensity(params) * randf_range(random_intensity_min, random_intensity_max)
		var final_params = _create_final_params(params, final_intensity, final_duration)

		_last_play_time = Time.get_ticks_msec() / 1000.0

		await _execute(node, final_params)

		if not _is_playing:
			break

		if restore_between_loops and restore_after_play and is_instance_valid(node):
			_restore_initial_state(node)

		if remaining_loops == 0:
			break
		if remaining_loops > 0:
			remaining_loops -= 1

		iteration += 1

		if loop_delay > 0.0:
			var tree = node.get_tree() if is_instance_valid(node) else Engine.get_main_loop()
			if tree is SceneTree:
				await tree.create_timer(loop_delay, true, false, true).timeout
			else:
				await tree.create_timer(loop_delay).timeout
			if not _is_playing or (requires_target and not is_instance_valid(node)):
				break

	# Final restore
	if restore_after_play and is_instance_valid(node):
		match restore_mode:
			RestoreMode.IMMEDIATE:
				_restore_initial_state(node)
			RestoreMode.GRADUAL:
				await _restore_gradual(node)
			RestoreMode.CUSTOM:
				await _restore_custom(node)

	_is_playing = false
	finished.emit.call_deferred()

func stop() -> void:
	## Stop effect
	if not _is_playing:
		return
	_is_playing = false
	_kill_active_tweens()
	_stop()

func _register_active_tween(tween: Tween) -> void:
	if tween:
		_active_tweens.append(tween)
		tween.finished.connect(_unregister_active_tween.bind(tween))

func _unregister_active_tween(tween: Tween) -> void:
	_active_tweens.erase(tween)

func _kill_active_tweens() -> void:
	for tween in _active_tweens:
		if is_instance_valid(tween):
			tween.kill()
	_active_tweens.clear()

func _await_tween(tween: Tween) -> void:
	## Wait for tween to finish, but return immediately if the effect is stop()ped
	if tween == null:
		return
	# The flag must live in a Dictionary: GDScript lambdas capture value types
	# (bool, int, float) by value, so a plain bool would never update here.
	var state := {"completed": false}
	var on_finished := func(): state.completed = true
	tween.finished.connect(on_finished)
	while not state.completed and _is_playing and tween.is_valid():
		await Engine.get_main_loop().process_frame
	tween.finished.disconnect(on_finished)

func _stop() -> void:
	## Subclasses may override: cleanup logic when stopped
	pass

func is_playing() -> bool:
	## Is playing
	return _is_playing

# ===== Virtual Methods (Subclass Must Implement) =====

func _execute(node: Node, params: GFFParams) -> void:
	## Execute effect logic (subclass implementation)
	push_error("_execute() not implemented in ", get_class())

func _get_default_intensity() -> float:
	## Get default intensity (subclass may override)
	return 1.0

func _get_default_duration() -> float:
	## Get default duration (subclass may override)
	return duration

# ===== Helpers =====

func _resolve_target(target: Node) -> Node:
	## Resolve target node
	if not target or not is_instance_valid(target):
		return null

	# Global effects do not resolve, passing the target through directly (may be Viewport or null)
	if not requires_target:
		return target

	if target is Node2D or target is Node3D or target is Control:
		return target

	# Recursively find operable node in children
	return _find_operable_child(target)

func _find_operable_child(node: Node) -> Node:
	for child in node.get_children():
		if child is Node2D or child is Node3D or child is Control:
			return child
		var found = _find_operable_child(child)
		if found:
			return found
	return null

func _save_initial_state(node: Node) -> void:
	## Save initial state
	_initial_state = {
		"position": _get_position(node),
		"rotation": _get_rotation(node),
		"scale": _get_scale(node),
		"modulate": _get_modulate(node),
	}

func _restore_initial_state(node: Node) -> void:
	## Restore initial state
	if _initial_state.is_empty() or not is_instance_valid(node):
		return

	_set_position(node, _initial_state["position"])
	_set_rotation(node, _initial_state["rotation"])
	_set_scale(node, _initial_state["scale"])
	_set_modulate(node, _initial_state["modulate"])

func _restore_gradual(node: Node) -> void:
	## Gradually restore initial transform/modulate state over restore_duration.
	if _initial_state.is_empty() or not is_instance_valid(node):
		return

	var duration := maxf(0.0, restore_duration)
	if duration <= 0.0:
		_restore_initial_state(node)
		return

	var tween = node.create_tween()
	_register_active_tween(tween)
	tween.set_parallel(true)
	if _initial_state.has("position"):
		tween.tween_method(_set_position.bind(node), _get_position(node), _initial_state["position"], duration)
	if _initial_state.has("rotation"):
		tween.tween_method(_set_rotation.bind(node), _get_rotation(node), _initial_state["rotation"], duration)
	if _initial_state.has("scale"):
		tween.tween_method(_set_scale.bind(node), _get_scale(node), _initial_state["scale"], duration)
	if _initial_state.has("modulate"):
		tween.tween_method(_set_modulate.bind(node), _get_modulate(node), _initial_state["modulate"], duration)
	await _await_tween(tween)

func _restore_custom(node: Node) -> void:
	## Custom recovery hook. Override in a script subclass for full control.
	## Default: wait [member restore_duration], then snap like Immediate.
	## See [member custom_restore_help] in the Inspector when mode is Custom.
	if not is_instance_valid(node):
		return
	var duration := maxf(0.0, restore_duration)
	if duration > 0.0 and node.is_inside_tree():
		var tree := node.get_tree()
		if tree:
			await tree.create_timer(duration, true, false, true).timeout
	if is_instance_valid(node):
		_restore_initial_state(node)

func _validate_property(property: Dictionary) -> void:
	match property.name:
		"restore_duration":
			if restore_mode != RestoreMode.GRADUAL and restore_mode != RestoreMode.CUSTOM:
				property.usage = PROPERTY_USAGE_NO_EDITOR
		"custom_restore_help":
			if restore_mode != RestoreMode.CUSTOM:
				property.usage = PROPERTY_USAGE_NO_EDITOR
			else:
				# Visible docs only — not serialized into .tres files.
				property.usage = PROPERTY_USAGE_EDITOR | PROPERTY_USAGE_READ_ONLY
func _get_intensity(params: GFFParams) -> float:
	## Get intensity parameter
	if params:
		return params.get_float("intensity", _get_default_intensity())
	return _get_default_intensity()

func _get_duration_param(params: GFFParams) -> float:
	## Get duration parameter
	if params:
		return params.get_float("duration", _get_default_duration())
	return _get_default_duration()

func _create_final_params(params: GFFParams, intensity: float, duration: float) -> GFFParams:
	## Build final parameters
	var final_params = GFFParams.new()
	final_params.intensity = intensity
	final_params.duration = duration

	if params:
		# Copy extra parameters (skip already-computed intensity and duration)
		for key in params._data:
			if key != "intensity" and key != "duration":
				final_params._data[key] = params._data[key]

	return final_params

func _apply_curve(value: float, curve: Curve) -> float:
	## Apply curve
	if curve:
		return curve.sample(value)
	return value

# ===== Node Operations =====

func _get_position(node: Node):
	if node is Node3D:
		return node.position
	elif node is Node2D:
		return node.position
	elif node is Control:
		return node.position
	return Vector2.ZERO

func _set_position(node: Node, pos) -> void:
	if node is Node3D:
		if pos is Vector3:
			node.position = pos
		elif pos is Vector2:
			node.position = Vector3(pos.x, pos.y, 0)
	elif node is Node2D:
		if pos is Vector2:
			node.position = pos
		elif pos is Vector3:
			node.position = Vector2(pos.x, pos.y)
	elif node is Control:
		if pos is Vector2:
			node.position = pos

func _get_rotation(node: Node) -> float:
	if node is Node3D:
		return node.rotation.y
	elif node is Node2D:
		return node.rotation
	elif node is Control:
		return node.rotation
	return 0.0

func _set_rotation(node: Node, r: float) -> void:
	if node is Node3D:
		node.rotation.y = r
	elif node is Node2D:
		node.rotation = r
	elif node is Control:
		node.rotation = r

func _get_scale(node: Node):
	if node is Node3D:
		return node.scale
	elif node is Node2D:
		return node.scale
	elif node is Control:
		return node.scale
	return Vector2.ONE

func _set_scale(node: Node, s) -> void:
	if node is Node3D:
		if s is Vector3:
			node.scale = s
		elif s is Vector2:
			node.scale = Vector3(s.x, s.y, 1)
	elif node is Node2D:
		if s is Vector2:
			node.scale = s
		elif s is Vector3:
			node.scale = Vector2(s.x, s.y)
	elif node is Control:
		if s is Vector2:
			node.scale = s

func _get_modulate(node: Node) -> Color:
	if node is Node2D:
		return node.modulate
	elif node is Control:
		return node.modulate
	return Color.WHITE

func _set_modulate(node: Node, c: Color) -> void:
	if node is Node2D:
		node.modulate = c
	elif node is Control:
		node.modulate = c
