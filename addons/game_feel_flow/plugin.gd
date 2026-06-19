@tool
extends EditorPlugin

## Game Feel Flow Plugin

const AUTOLOAD_NAME = "GameFeelFlow"
const AUTOLOAD_PATH = "res://addons/game_feel_flow/core/game_feel_flow.gd"

var _editor_plugin: EditorPlugin = null

func _enter_tree() -> void:
	# Add autoload singleton
	add_autoload_singleton(AUTOLOAD_NAME, AUTOLOAD_PATH)
	
	# 注册编辑器插件
	_editor_plugin = preload("res://addons/game_feel_flow/editor/gff_editor_plugin.gd").new()
	add_child(_editor_plugin)
	
	print("Game Feel Flow: Plugin enabled")

func _exit_tree() -> void:
	# Remove autoload singleton
	remove_autoload_singleton(AUTOLOAD_NAME)
	
	# 清理编辑器插件
	if _editor_plugin:
		_editor_plugin.queue_free()
		_editor_plugin = null
	
	print("Game Feel Flow: Plugin disabled")
