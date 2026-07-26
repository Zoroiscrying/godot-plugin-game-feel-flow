@tool
extends EditorPlugin

## Game Feel Flow Plugin

const AUTOLOAD_NAME = "GameFeelFlow"
const AUTOLOAD_PATH = "res://addons/game_feel_flow/core/game_feel_flow.gd"
const PRO_PLUGIN_PATH = "res://addons/game_feel_flow_pro/plugin.cfg"

var _inspector_plugin: EditorInspectorPlugin = null
var _editor_game_feel_flow: Node = null

## Static reference to the in-editor GameFeelFlow preview instance.
## Pro extensions can use this to register their effects/presets with the editor preview.
static var editor_game_feel_flow: Node = null

## Static reference to the Inspector plugin instance so the Pro extension can connect
## to open_editor_window_requested and show the Timeline Editor dock.
static var inspector_plugin: EditorInspectorPlugin = null

func _enter_tree() -> void:
	# Project Settings → Game Feel Flow
	GFFProjectSettings.ensure_registered()

	# Add autoload singleton
	add_autoload_singleton(AUTOLOAD_NAME, AUTOLOAD_PATH)
	
	# Register Inspector plugin
	_inspector_plugin = preload("res://addons/game_feel_flow/editor/gff_player_inspector.gd").new()
	add_inspector_plugin(_inspector_plugin)
	inspector_plugin = _inspector_plugin
	
	# Create in-editor GameFeelFlow instance (for preview)
	_editor_game_feel_flow = load(AUTOLOAD_PATH).new()
	editor_game_feel_flow = _editor_game_feel_flow
	GFFEffectConfigManager.register_all()
	_editor_game_feel_flow._register_effects()
	_editor_game_feel_flow._register_combos()
	
	if is_pro_enabled():
		print("Game Feel Flow: Pro extension detected")
	
	print("Game Feel Flow: Plugin enabled")

func _exit_tree() -> void:
	# Remove autoload singleton
	remove_autoload_singleton(AUTOLOAD_NAME)
	
	# Clean up Inspector plugin
	if _inspector_plugin:
		remove_inspector_plugin(_inspector_plugin)
		_inspector_plugin = null
	inspector_plugin = null
	
	# Clean up editor GameFeelFlow instance
	if _editor_game_feel_flow:
		_editor_game_feel_flow.free()
		_editor_game_feel_flow = null
	
	print("Game Feel Flow: Plugin disabled")

const _CORE_GFF_CLASSES := ["GFFPlayer", "GFFCombo", "GFFComboEntry", "GFFEffect"]

func _get_custom_class_icon(class_name_str: String) -> Texture2D:
	if class_name_str in _CORE_GFF_CLASSES:
		return GFFIconManager.get_icon_for_class(class_name_str)
	return null

static func is_pro_enabled() -> bool:
	## Returns true if the Game Feel Flow Pro addon is present in the project.
	return FileAccess.file_exists(PRO_PLUGIN_PATH)
