class_name GFFEffectConfigManager

## Game Feel Flow Effect Config Manager

# ===== Scripts =====
const GFFEffectConfigScript = preload("res://addons/game_feel_flow/core/gff_effect_config.gd")

# ===== Singleton =====
static var _instance = null
static var _configs: Dictionary = {}

# ===== Static Methods =====

static func get_instance():
	if _instance == null:
		_instance = new()
	return _instance

static func register_config(effect_name: String, configs: Array) -> void:
	_configs[effect_name] = configs

static func get_config(effect_name: String) -> Array:
	return _configs.get(effect_name, [])

static func _float_param(name: String, display: String, default: float, min_val: float, max_val: float, step: float):
	return GFFEffectConfigScript.float_param(name, display, default, min_val, max_val, step)

static func _int_param(name: String, display: String, default: int, min_val: int, max_val: int):
	return GFFEffectConfigScript.int_param(name, display, default, min_val, max_val)

static func _color_param(name: String, display: String, default: Color):
	return GFFEffectConfigScript.color_param(name, display, default)

# ===== Register All Configs =====

static func register_all() -> void:
	# Shake
	register_config("shake", [
		_float_param("amplitude", "Amplitude", 10.0, 0.0, 100.0, 0.1),
		_float_param("duration", "Duration", 0.2, 0.01, 2.0, 0.01),
	])

	# Scale
	register_config("scale", [
		_float_param("duration", "Duration", 0.2, 0.01, 2.0, 0.01),
	])

	# Color
	register_config("color", [
		_color_param("color", "Color", Color.WHITE),
		_float_param("duration", "Duration", 0.2, 0.01, 2.0, 0.01),
	])

	# Alpha
	register_config("alpha", [
		_float_param("alpha", "Alpha", 0.0, 0.0, 1.0, 0.01),
		_float_param("duration", "Duration", 0.2, 0.01, 2.0, 0.01),
	])

	# Flash
	register_config("flash", [
		_color_param("color", "Color", Color.WHITE),
		_float_param("duration", "Duration", 0.1, 0.01, 1.0, 0.01),
	])

	# Freeze Frame
	register_config("freeze_frame", [
		_float_param("duration", "Duration", 0.05, 0.01, 0.5, 0.01),
	])

	# Time Scale
	register_config("time_scale", [
		_float_param("scale", "Scale", 0.3, 0.0, 2.0, 0.01),
		_float_param("duration", "Duration", 1.0, 0.01, 5.0, 0.01),
	])

	# Hit Effect
	register_config("hit", [
		_float_param("intensity", "Intensity", 1.0, 0.1, 5.0, 0.1),
		_float_param("duration", "Duration", 0.3, 0.01, 1.0, 0.01),
		_float_param("freeze_duration", "Freeze Duration", 0.05, 0.01, 0.3, 0.01),
		_float_param("shake_amplitude", "Shake Amplitude", 5.0, 0.0, 20.0, 0.1),
		_float_param("knockback_distance", "Knockback Distance", 20.0, 0.0, 100.0, 1.0),
		_float_param("rotation_angle", "Rotation Angle", 15.0, 0.0, 90.0, 1.0),
		_color_param("flash_color", "Flash Color", Color.WHITE),
	])

	# Hit presets (same parameters as hit effect)
	for preset in ["hit_light", "hit_medium", "hit_heavy", "hit_critical", "explosion", "death"]:
		register_config(preset, [
			_float_param("intensity", "Intensity", 1.0, 0.1, 5.0, 0.1),
			_float_param("duration", "Duration", 0.3, 0.01, 1.0, 0.01),
			_float_param("freeze_duration", "Freeze Duration", 0.05, 0.01, 0.3, 0.01),
			_float_param("shake_amplitude", "Shake Amplitude", 5.0, 0.0, 20.0, 0.1),
			_float_param("knockback_distance", "Knockback Distance", 20.0, 0.0, 100.0, 1.0),
			_float_param("rotation_angle", "Rotation Angle", 15.0, 0.0, 90.0, 1.0),
			_color_param("flash_color", "Flash Color", Color.WHITE),
		])

	print("GFFEffectConfigManager: Registered configs")

