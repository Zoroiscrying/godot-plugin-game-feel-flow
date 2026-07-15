@tool
extends RefCounted
class_name GFFIconManager

const ICON_DIR := "res://addons/game_feel_flow/icons/"
const FALLBACK := "res://addons/game_feel_flow/icons/icon_gff_feedback.svg"

static func get_icon(name: String) -> Texture2D:
	var path := ICON_DIR + name + ".svg"
	var tex: Texture2D = null
	if FileAccess.file_exists(path):
		tex = load(path) as Texture2D
	if tex == null:
		tex = load(FALLBACK) as Texture2D
	return tex


static func get_icon_for_effect(effect: GFFEffect) -> Texture2D:
	if effect == null:
		return get_icon("icon_gff_feedback")
	if effect is GFFEffectCommon:
		var common := effect as GFFEffectCommon
		if common.target:
			return get_icon_for_target(common.target)
	var script := effect.get_script()
	if script == null:
		return get_icon("icon_gff_feedback")
	return get_icon_for_script_path(script.get_path())


static func get_icon_for_target(target: GFFTarget) -> Texture2D:
	if target == null:
		return get_icon("icon_gff_feedback")
	var cls := target.get_class()
	match cls:
		"GFFUIPositionTarget", "GFFUIScaleTarget", "GFFUIRotationTarget", "GFFUIColorTarget", "GFFUIAlphaTarget":
			return get_icon("icon_ui_target")
		"GFFMaterialColorTarget", "GFFMaterialAlphaTarget":
			return get_icon("icon_material_target")
		"GFFCameraOffsetTarget", "GFFCameraZoomTarget", "GFFCameraFovTarget":
			return get_icon("icon_camera_target")
	var script := target.get_script()
	if script == null:
		return get_icon("icon_gff_feedback")
	return get_icon_for_script_path(script.get_path())


static func get_icon_for_script_path(script_path: String) -> Texture2D:
	var base := script_path.get_file().get_basename()  # e.g. "gff_position_target"
	if base.ends_with("_target"):
		var target_name := base.replace("gff_", "").replace("_target", "")
		if target_name.begins_with("ui_"):
			return get_icon("icon_ui_target")
		elif target_name.begins_with("material_"):
			return get_icon("icon_material_target")
		elif target_name.begins_with("camera_"):
			return get_icon("icon_camera_target")
		return get_icon("icon_" + target_name)
	var icon_name := base.replace("gff_", "icon_")
	return get_icon(icon_name)


static func get_icon_for_class(class_name_str: String) -> Texture2D:
	match class_name_str:
		"GFFPlayer":
			return get_icon("icon_gff_player")
		"GFFCombo":
			return get_icon("icon_gff_combo")
		"GFFComboEntry":
			return get_icon("icon_gff_combo_entry")
		_:
			return get_icon("icon_gff_feedback")
