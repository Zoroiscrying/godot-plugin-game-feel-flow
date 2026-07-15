@tool
extends EditorInspectorPlugin

## GFFPlayer Inspector plugin
## Adds the CombosPanel as a custom inspector section for GFFPlayer,
## and hides the raw combo_dictionary property so users never see it.

signal open_editor_window_requested(player: GFFPlayer)

const EditorPropertyClass := preload("res://addons/game_feel_flow/editor/gff_player_editor_property.gd")

func _can_handle(object: Object) -> bool:
	return object is GFFPlayer

func _parse_begin(object: Object) -> void:
	if object is GFFPlayer:
		var editor = EditorPropertyClass.new()
		editor.set_player(object as GFFPlayer)
		editor.open_timeline_requested.connect(_on_open_timeline)
		add_custom_control(editor)

func _parse_property(object, type, name, hint_type, hint_string, usage_flags, wide):
	# Hide the raw combo_dictionary property; the custom section above handles it.
	if name == "combo_dictionary":
		return true

	# Hide other properties managed by custom UI.
	# auto_play and default_combo_index are kept visible so users can configure
	# which combo plays automatically and whether it auto-plays at all.
	if name in ["effects", "default_params", "combo_presets", "active_combo_key",
				"timeline_data", "active_combo", "preset_directory"]:
		return true
	return false

func _on_open_timeline(player: GFFPlayer) -> void:
	open_editor_window_requested.emit(player)
