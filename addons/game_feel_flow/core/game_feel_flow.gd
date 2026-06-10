extends Node

## Game Feel Flow
##
## Global singleton for game feel effects

# ===== Configuration =====
var debug_enabled: bool = false

# ===== Internal Storage =====
var _feedback_registry: Dictionary = {}
var _signal_listeners: Dictionary = {}
var _executor = null

# ===== Combo System =====
var _combo_count: int = 0
var _combo_timer: float = 0.0
var _combo_timeout: float = 2.0

# ===== Lifecycle =====

func _ready() -> void:
	print("Game Feel Flow: Global singleton ready")
	_init_executor()
	_register_effects()
	_register_configs()

func _process(delta: float) -> void:
	if _combo_count > 0:
		_combo_timer -= delta
		if _combo_timer <= 0:
			_combo_count = 0

# ===== Initialization =====

func _init_executor() -> void:
	var script = load("res://addons/game_feel_flow/core/gff_effect_executor.gd")
	if script:
		_executor = script.new()
		add_child(_executor)

func _register_effects() -> void:
	var effects = {
		"shake": "res://addons/game_feel_flow/effects/gff_shake.gd",
		"flash": "res://addons/game_feel_flow/effects/gff_flash.gd",
		"scale": "res://addons/game_feel_flow/effects/gff_scale.gd",
		"color": "res://addons/game_feel_flow/effects/gff_color.gd",
		"alpha": "res://addons/game_feel_flow/effects/gff_alpha.gd",
		"freeze_frame": "res://addons/game_feel_flow/effects/gff_freeze_frame.gd",
		"time_scale": "res://addons/game_feel_flow/effects/gff_time_scale.gd",
		"hit": "res://addons/game_feel_flow/effects/gff_hit.gd",
	}

	for name in effects:
		var path = effects[name]
		if ResourceLoader.exists(path):
			var script = load(path)
			if script:
				var effect = script.new()
				if effect.has_method("apply"):
					_feedback_registry[name] = effect

	print("Game Feel Flow: Registered ", _feedback_registry.size(), " effects")

func _register_configs() -> void:
	## Register effect configurations
	var script = load("res://addons/game_feel_flow/core/gff_effect_config_manager.gd")
	if script:
		script.register_all()
		print("Game Feel Flow: Registered configs")

# ===== Core API =====

func execute(effect, target: Node, params = null) -> void:
	## Execute any effect (single or combo)
	if debug_enabled:
		print("GameFeelFlow: executing effect on ", target.name)

	if effect is String:
		var feedback = get_feedback(effect)
		if feedback:
			var gff_params = _ensure_params(params)
			await feedback.apply(target, gff_params)
		else:
			push_warning("GameFeelFlow: Effect not found: " + effect)
	elif effect is RefCounted or effect is Resource:
		if effect.has_method("execute"):
			if _executor:
				await effect.execute(target, _executor)
			else:
				push_warning("GameFeelFlow: Executor not initialized")
		elif effect.has_method("apply"):
			var gff_params = _ensure_params(params)
			await effect.apply(target, gff_params)

# ===== Registration =====

func register_feedback(name: String, feedback) -> void:
	_feedback_registry[name] = feedback

func get_feedback(name: String):
	return _feedback_registry.get(name)

# ===== Signal System =====

func emit(event: String, data: Dictionary = {}) -> void:
	if event in _signal_listeners:
		for callback in _signal_listeners[event]:
			callback.call(data)

func listen(event: String, callback: Callable) -> void:
	if event not in _signal_listeners:
		_signal_listeners[event] = []
	_signal_listeners[event].append(callback)

func unlisten(event: String, callback: Callable) -> void:
	if event in _signal_listeners:
		_signal_listeners[event].erase(callback)

# ===== Combo System =====

func hit(target: Node, intensity: float = 1.0, duration: float = 0.3) -> void:
	## Play hit effect with combo tracking
	_combo_count += 1
	_combo_timer = _combo_timeout

	var combo_intensity = intensity + (_combo_count * 0.1)
	var combo_duration = duration + (_combo_count * 0.02)

	execute("hit", target, {
		"intensity": combo_intensity,
		"duration": combo_duration,
		"freeze_duration": 0.05 + (_combo_count * 0.01),
		"shake_amplitude": 5.0 + (_combo_count * 1.0),
		"knockback_distance": 20.0 + (_combo_count * 5.0),
		"rotation_angle": 15.0 + (_combo_count * 2.0),
	})

	if _combo_count > 1:
		print("Combo: ", _combo_count, "x")

# ===== Debug =====

func set_debug(enabled: bool) -> void:
	debug_enabled = enabled

# ===== Internal =====

func _ensure_params(params):
	if params == null:
		return _create_params(1.0, -1.0)
	elif params is float or params is int:
		return _create_params(params, -1.0)
	elif params is Dictionary:
		var p = _create_params(1.0, -1.0)
		for key in params:
			if key == "intensity":
				p.intensity = params[key]
			elif key == "duration":
				p.duration = params[key]
			else:
				p._data[key] = params[key]
		return p
	elif params is RefCounted or params is Resource:
		return params
	else:
		return _create_params(1.0, -1.0)

func _create_params(p_intensity: float, p_duration: float):
	var script = load("res://addons/game_feel_flow/core/gff_params.gd")
	if script:
		var params = script.new()
		params.intensity = p_intensity
		params.duration = p_duration
		return params
	return null
