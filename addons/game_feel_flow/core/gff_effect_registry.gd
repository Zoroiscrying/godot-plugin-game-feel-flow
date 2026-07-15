@tool
class_name GFFEffectRegistry
extends RefCounted

const GFFEffectCommonScript := preload("res://addons/game_feel_flow/effects/curved/gff_effect_common.gd")

static var TargetScripts := {
	"position": preload("res://addons/game_feel_flow/core/targets/gff_position_target.gd"),
	"scale": preload("res://addons/game_feel_flow/core/targets/gff_scale_target.gd"),
	"rotation": preload("res://addons/game_feel_flow/core/targets/gff_rotation_target.gd"),
	"color": preload("res://addons/game_feel_flow/core/targets/gff_color_target.gd"),
	"alpha": preload("res://addons/game_feel_flow/core/targets/gff_alpha_target.gd"),
	"camera_offset": preload("res://addons/game_feel_flow/core/targets/gff_camera_offset_target.gd"),
	"camera_zoom": preload("res://addons/game_feel_flow/core/targets/gff_camera_zoom_target.gd"),
	"camera_fov": preload("res://addons/game_feel_flow/core/targets/gff_camera_fov_target.gd"),
}

static var TweenerScripts := {
	"linear": preload("res://addons/game_feel_flow/core/tweeners/gff_linear_tweener.gd"),
	"elastic": preload("res://addons/game_feel_flow/core/tweeners/gff_elastic_tweener.gd"),
	"shake": preload("res://addons/game_feel_flow/core/tweeners/gff_shake_tweener.gd"),
	"flash": preload("res://addons/game_feel_flow/core/tweeners/gff_flash_tweener.gd"),
	"color": preload("res://addons/game_feel_flow/core/tweeners/gff_color_tweener.gd"),
}

static var _presets: Array[Dictionary] = []

static func _ensure_presets() -> void:
	if not _presets.is_empty():
		return
	_presets = [
		{"name": "Position", "target": "position", "tweener": "linear"},
		{"name": "Scale", "target": "scale", "tweener": "linear"},
		{"name": "Rotation", "target": "rotation", "tweener": "linear"},
		{"name": "Color", "target": "color", "tweener": "color"},
		{"name": "Alpha", "target": "alpha", "tweener": "linear"},
		{"name": "Shake Position", "target": "position", "tweener": "shake"},
		{"name": "Shake Scale", "target": "scale", "tweener": "shake"},
		{"name": "Shake Rotation", "target": "rotation", "tweener": "shake"},
		{"name": "Flash", "target": "color", "tweener": "flash"},
		{"name": "Punch Scale", "target": "scale", "tweener": "elastic"},
		{"name": "Camera Shake", "target": "camera_offset", "tweener": "shake"},
		{"name": "Camera Zoom", "target": "camera_zoom", "tweener": "linear"},
		{"name": "Camera FOV", "target": "camera_fov", "tweener": "linear"},
	]

static func get_preset_names() -> PackedStringArray:
	_ensure_presets()
	var names: PackedStringArray = []
	for preset in _presets:
		names.append(preset.name)
	return names

static func create_preset(name: String) -> GFFEffect:
	_ensure_presets()
	for preset in _presets:
		if preset.name == name:
			return create_effect(preset.target, preset.tweener)
	return null

static func create_effect(target_key: String, tweener_key: String) -> GFFEffect:
	var effect: GFFEffect = GFFEffectCommonScript.new()
	if TargetScripts.has(target_key):
		effect.target = TargetScripts[target_key].new()
	if TweenerScripts.has(tweener_key):
		effect.tweener = TweenerScripts[tweener_key].new()
	return effect

static func get_target_script(key: String) -> Script:
	return TargetScripts.get(key)

static func get_tweener_script(key: String) -> Script:
	return TweenerScripts.get(key)

static func get_target_keys() -> Array:
	return TargetScripts.keys()

static func get_tweener_keys() -> Array:
	return TweenerScripts.keys()

static func register_target(key: String, script: Script) -> void:
	## Register a custom target script. The script must extend GFFTarget.
	if script == null:
		push_warning("GFFEffectRegistry: Cannot register null target script for key: ", key)
		return
	var tmp = script.new()
	if not tmp is GFFTarget:
		push_warning("GFFEffectRegistry: Target script does not extend GFFTarget: ", key)
		if tmp is RefCounted:
			tmp.free()
		return
	TargetScripts[key] = script

static func register_tweener(key: String, script: Script) -> void:
	## Register a custom tweener script. The script must extend GFFTweener.
	if script == null:
		push_warning("GFFEffectRegistry: Cannot register null tweener script for key: ", key)
		return
	var tmp = script.new()
	if not tmp is GFFTweener:
		push_warning("GFFEffectRegistry: Tweener script does not extend GFFTweener: ", key)
		if tmp is RefCounted:
			tmp.free()
		return
	TweenerScripts[key] = script

static func register_preset(name: String, target_key: String, tweener_key: String) -> void:
	## Register a custom effect preset.
	_presets.append({"name": name, "target": target_key, "tweener": tweener_key})

static func get_tweener_keys_for_value_type(value_type: int = -1) -> Array:
	if value_type < 0:
		return TweenerScripts.keys()
	var result: Array = []
	for key in TweenerScripts.keys():
		var script: Script = TweenerScripts[key]
		if script == null:
			continue
		var instance = script.new() as GFFTweener
		if instance and instance.get_supported_value_types().has(value_type):
			result.append(key)
	return result

static func get_value_type_for_target_key(target_key: String) -> int:
	var script: Script = TargetScripts.get(target_key)
	if script == null:
		return -1
	var instance = script.new() as GFFTarget
	if instance:
		return instance.get_value_type()
	return -1
