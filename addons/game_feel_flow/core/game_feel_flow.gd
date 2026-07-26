extends Node

## Game Feel Flow
##
## Global singleton providing shortcut APIs and effect management

const GFFEventScript = preload("res://addons/game_feel_flow/effects/events/gff_event.gd")
const GFFSignalScript = preload("res://addons/game_feel_flow/effects/events/gff_signal.gd")
const GFFMethodScript = preload("res://addons/game_feel_flow/effects/events/gff_method.gd")

# ===== Signals =====
signal effect_started(effect_name: String)
signal effect_finished(effect_name: String)

# ===== Properties =====
var debug_enabled: bool = false
var _effect_registry: Dictionary = {}
var _combo_registry: Dictionary = {}
var _overlap_manager: Node = null
var _effect_stack: GFFEffectStack = null

# ===== Lifecycle =====

func _ready() -> void:
	print("Game Feel Flow: Initializing...")
	GFFProjectSettings.ensure_registered()
	GFFEffectConfigManager.register_all()
	_register_effects()
	_register_combos()
	_register_project_combos()
	_effect_stack = GFFEffectStack.new()
	_effect_stack.effect_started.connect(_on_stack_effect_started)
	_effect_stack.effect_finished.connect(_on_stack_effect_finished)
	print("Game Feel Flow: Ready (", _effect_registry.size(), " effects, ", _combo_registry.size(), " combos)")

# ===== Core API =====

func _resolve_target_for_effect(effect: GFFEffect, target: Node) -> Node:
	## If the effect is a camera effect but the target is not a camera, auto-find the current viewport's active camera
	if effect is GFFEffectCommon:
		var common := effect as GFFEffectCommon
		if common.target and (
			common.target is GFFCameraOffsetTarget
			or common.target is GFFCameraZoomTarget
			or common.target is GFFCameraFovTarget
		):
			if not (target is Camera2D or target is Camera3D):
				var viewport := target.get_viewport()
				if viewport:
					var cam2d := viewport.get_camera_2d()
					if cam2d:
						return cam2d
					var cam3d := viewport.get_camera_3d()
					if cam3d:
						return cam3d
				push_warning("GameFeelFlow: Camera effect requires a Camera2D/Camera3D target, none found for ", target.name)
	return target


func play(effect, target: Node, params = null) -> void:
	## Play effect
	## effect: String | GFFEffect | GFFCombo
	if debug_enabled:
		print("GameFeelFlow: Playing effect on ", target.name)

	# Find GFFPlayer
	var player = _find_player(target)

	if player:
		# Play via GFFPlayer
		await player.play(effect, params)
	else:
		# Play directly through the global effect stack
		if effect is String:
			var feedback = get_effect(effect)
			if feedback:
				feedback = feedback.duplicate(true)
				target = _resolve_target_for_effect(feedback, target)
				var started := _effect_stack.play(feedback, target, _ensure_params(params))
				if started:
					effect_started.emit(effect)
					await feedback.finished
					effect_finished.emit(effect)
			else:
				push_warning("GameFeelFlow: Effect not found: ", effect)
		elif effect is GFFEffect:
			target = _resolve_target_for_effect(effect, target)
			var started := _effect_stack.play(effect, target, _ensure_params(params))
			if started:
				var effect_name: String = effect.label if effect.label else "unknown"
				effect_started.emit(effect_name)
				await effect.finished
				effect_finished.emit(effect_name)
		elif effect is GFFCombo:
			var combo: GFFCombo = effect.duplicate(true)
			effect_started.emit(combo.label if combo.label else "unknown")
			await combo.execute(target, _ensure_params(params))
			effect_finished.emit(combo.label if combo.label else "unknown")

func play_combo(combo, target: Node, params = null) -> void:
	## Play combo effect
	## combo: String | GFFCombo
	if debug_enabled:
		print("GameFeelFlow: Playing combo on ", target.name)

	# Find GFFPlayer
	var player = _find_player(target)

	if player:
		# Play via GFFPlayer (player falls back to global/project combos for string keys)
		await player.play_combo(combo, params)
	else:
		# Play directly
		if combo is String:
			var combo_resource = resolve_combo(combo)
			if combo_resource:
				combo_resource = combo_resource.duplicate(true)
				effect_started.emit(combo)
				await combo_resource.execute(target, _ensure_params(params))
				effect_finished.emit(combo)
			else:
				push_warning("GameFeelFlow: Combo not found: ", combo)
		elif combo is GFFCombo:
			effect_started.emit(combo.label if combo.label else "unknown")
			await combo.execute(target, _ensure_params(params))
			effect_finished.emit(combo.label if combo.label else "unknown")

func play_global(effect, params = null) -> void:
	## Play global effect (no target node needed, e.g. freeze frame, time scale)
	## effect: String | GFFEffect
	var tree = Engine.get_main_loop()
	if not tree is SceneTree:
		push_warning("GameFeelFlow: SceneTree not available for global effect")
		return
	await play(effect, tree.root, params)

func stop(target: Node) -> void:
	## Stop all effects on target (GFFPlayer-owned and global stack).
	stop_all(target)

func stop_all(node: Node = null) -> void:
	## Stop all effects. If a node is provided, only stop effects on that node
	## and its descendants (including GFFPlayer-owned effects and global-stack effects).
	if node:
		for player in _find_players(node):
			player.stop()
		if _effect_stack:
			_effect_stack.stop_by_target(node)
	else:
		if _effect_stack:
			_effect_stack.clear()

# ===== Registration =====

func register_effect(name: String, effect: GFFEffect) -> void:
	## Register effect
	_effect_registry[name] = effect

func register_combo(name: String, combo: GFFCombo) -> void:
	## Register combo
	_combo_registry[name] = combo

func register_target(key: String, script: Script) -> void:
	## Register a custom target type for Pro or user extensions
	GFFEffectRegistry.register_target(key, script)

func register_tweener(key: String, script: Script) -> void:
	## Register a custom tweener type for Pro or user extensions
	GFFEffectRegistry.register_tweener(key, script)

func register_preset(name: String, target_key: String, tweener_key: String) -> void:
	## Register a custom effect preset for Pro or user extensions
	GFFEffectRegistry.register_preset(name, target_key, tweener_key)

func get_effect(name: String) -> GFFEffect:
	## Get effect
	return _effect_registry.get(name)

func get_combo(name: String) -> GFFCombo:
	## Get combo
	return _combo_registry.get(name)

func resolve_combo(name: String) -> GFFCombo:
	## Resolve a combo by name: global registry, then project `.tres` (Pro dirs).
	var combo: GFFCombo = get_combo(name)
	if combo:
		return combo
	combo = _try_load_project_combo(name)
	if combo:
		register_combo(name, combo)
	return combo

func get_effect_names() -> Array:
	## Get all effect names
	return _effect_registry.keys()

func get_combo_names() -> Array:
	## Get all combo names
	return _combo_registry.keys()

func get_all_effects() -> Dictionary:
	## Get all effects (read-only)
	return _effect_registry.duplicate()

func get_all_combos() -> Dictionary:
	## Get all combos (read-only)
	return _combo_registry.duplicate()

# ===== Signal System =====

func emit(event: String, data: Dictionary = {}) -> void:
	## Emit event
	if event in _signal_listeners:
		for callback in _signal_listeners[event]:
			callback.call(data)

func listen(event: String, callback: Callable) -> void:
	## Listen to event
	if event not in _signal_listeners:
		_signal_listeners[event] = []
	_signal_listeners[event].append(callback)

func unlisten(event: String, callback: Callable) -> void:
	## Stop listening
	if event in _signal_listeners:
		_signal_listeners[event].erase(callback)

# ===== Debug Methods =====

func set_debug(enabled: bool) -> void:
	## Set debug mode
	debug_enabled = enabled

# ===== Internal Methods =====

var _signal_listeners: Dictionary = {}

func _register_effects() -> void:
	## Register built-in effects
	# Shake series
	_effect_registry["shake_position"] = GFFEffectRegistry.create_effect("position", "shake")
	_effect_registry["shake_scale"] = GFFEffectRegistry.create_effect("scale", "shake")
	_effect_registry["shake_rotation"] = GFFEffectRegistry.create_effect("rotation", "shake")

	# Punch series — relative BY_AMOUNT + elastic return to origin
	_effect_registry["punch_position"] = GFFEffectRegistry.create_effect("position", "elastic")
	var punch_scale := GFFEffectRegistry.create_effect("scale", "elastic") as GFFEffectCommon
	var punch_scale_target := punch_scale.target as GFFScaleTarget
	punch_scale_target.mode = GFFScaleTarget.Mode.BY_AMOUNT
	punch_scale_target.target_value = Vector3(0.25, 0.25, 0.0)
	(punch_scale.tweener as GFFElasticTweener).punch_mode = GFFElasticTweener.PunchMode.TO_ORIGIN
	_effect_registry["punch_scale"] = punch_scale
	_effect_registry["punch_rotation"] = GFFEffectRegistry.create_effect("rotation", "elastic")

	# Curved series
	_effect_registry["curved_position"] = GFFEffectRegistry.create_effect("position", "linear")
	_effect_registry["curved_scale"] = GFFEffectRegistry.create_effect("scale", "linear")
	_effect_registry["curved_rotation"] = GFFEffectRegistry.create_effect("rotation", "linear")

	# Special effects
	_effect_registry["flash"] = GFFEffectRegistry.create_effect("color", "flash")
	_effect_registry["color"] = GFFEffectRegistry.create_effect("color", "color")
	var alpha_effect := GFFEffectRegistry.create_effect("alpha", "linear") as GFFEffectCommon
	(alpha_effect.target as GFFAlphaTarget).target_alpha = 0.0
	alpha_effect.restore_after_play = true
	alpha_effect.restore_mode = GFFEffect.RestoreMode.GRADUAL
	alpha_effect.restore_duration = 0.25
	_effect_registry["alpha"] = alpha_effect

	# Camera effects
	_effect_registry["camera_shake"] = GFFEffectRegistry.create_effect("camera_offset", "shake")
	_effect_registry["camera_zoom"] = GFFEffectRegistry.create_effect("camera_zoom", "linear")
	_effect_registry["camera_fov"] = GFFEffectRegistry.create_effect("camera_fov", "linear")

	# Keep old screen flash effect
	_effect_registry["camera_flash"] = GFFCameraFlash.new()

	# Audio effects
	_effect_registry["sound"] = GFFSound.new()
	_effect_registry["audio_volume"] = GFFAudioVolume.new()

	# Time effects
	_effect_registry["freeze_frame"] = GFFFreezeFrame.new()
	_effect_registry["time_scale"] = GFFTimeScale.new()

	# Particle effects
	_effect_registry["particles"] = GFFParticles.new()
	_effect_registry["gpu_particles"] = GFFGPUParticles.new()

	# Physics effects
	_effect_registry["impulse"] = GFFImpulse.new()
	_effect_registry["velocity"] = GFFVelocity.new()

	# Animation effects
	_effect_registry["tween"] = GFFTween.new()
	_effect_registry["animator"] = GFFAnimator.new()

	# Event effects
	_effect_registry["event"] = GFFEventScript.new()
	_effect_registry["signal"] = GFFSignalScript.new()
	_effect_registry["method"] = GFFMethodScript.new()

	# Keep old names as aliases
	_effect_registry["shake"] = _effect_registry["shake_position"]
	_effect_registry["punch"] = _effect_registry["punch_position"]

	print("Game Feel Flow: Registered ", _effect_registry.size(), " effects")

func _register_combos() -> void:
	## Register built-in combos
	_combo_registry["hit_light"] = GFFCombo.hit_light()
	_combo_registry["hit_medium"] = GFFCombo.hit_medium()
	_combo_registry["hit_heavy"] = GFFCombo.hit_heavy()
	_combo_registry["hit_critical"] = GFFCombo.hit_critical()
	_combo_registry["death"] = GFFCombo.death()
	_combo_registry["death_explosion"] = GFFCombo.death_explosion()
	_combo_registry["pickup"] = GFFCombo.pickup()
	_combo_registry["pickup_coin"] = GFFCombo.pickup_coin()
	_combo_registry["pickup_health"] = GFFCombo.pickup_health()
	_combo_registry["pickup_power"] = GFFCombo.pickup_power()
	_combo_registry["explosion"] = GFFCombo.explosion()
	_combo_registry["explosion_small"] = GFFCombo.explosion_small()
	_combo_registry["explosion_large"] = GFFCombo.explosion_large()
	_combo_registry["ui_button_press"] = GFFCombo.ui_button_press()
	_combo_registry["ui_notification"] = GFFCombo.ui_notification()

func _register_project_combos() -> void:
	## Pro: load Save-as-Project-Combo `.tres` into the global table (no-op without Pro).
	const PRO_PROJECT_COMBOS := "res://addons/game_feel_flow_pro/core/gff_project_combos.gd"
	if not FileAccess.file_exists(PRO_PROJECT_COMBOS):
		return
	var script = load(PRO_PROJECT_COMBOS)
	if script and script.has_method("register_into"):
		var count: int = script.register_into(self)
		if count > 0 and debug_enabled:
			print("GameFeelFlow: Registered ", count, " project combo(s)")

func _try_load_project_combo(combo_name: String) -> GFFCombo:
	## Lazy fallback if a project combo was saved after startup / not yet scanned.
	const PRO_PROJECT_COMBOS := "res://addons/game_feel_flow_pro/core/gff_project_combos.gd"
	if not FileAccess.file_exists(PRO_PROJECT_COMBOS):
		return null
	var script = load(PRO_PROJECT_COMBOS)
	if script and script.has_method("try_load"):
		return script.try_load(combo_name)
	return null

func _find_player(target: Node) -> GFFPlayer:
	## Recursively find GFFPlayer node
	if target is GFFPlayer:
		return target
	for child in target.get_children():
		if child is GFFPlayer:
			return child
		var found = _find_player(child)
		if found:
			return found
	return null

func _find_players(node: Node) -> Array[GFFPlayer]:
	## Recursively find all GFFPlayer nodes under the given node
	var players: Array[GFFPlayer] = []
	if node is GFFPlayer:
		players.append(node)
	for child in node.get_children():
		if child is GFFPlayer:
			players.append(child)
		else:
			players.append_array(_find_players(child))
	return players

func _on_stack_effect_started(effect_id: String) -> void:
	if debug_enabled:
		print("GameFeelFlow: Stack started ", effect_id)

func _on_stack_effect_finished(effect_id: String) -> void:
	if debug_enabled:
		print("GameFeelFlow: Stack finished ", effect_id)

func _ensure_params(params) -> GFFParams:
	## Ensure params is a GFFParams type
	if params == null:
		return GFFParams.create()
	elif params is float or params is int:
		return GFFParams.create(params)
	elif params is Dictionary:
		return GFFParams.from_dict(params)
	elif params is GFFParams:
		return params
	else:
		return GFFParams.create()
