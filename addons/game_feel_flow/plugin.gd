@tool
extends EditorPlugin

## Game Feel Flow Plugin

const AUTOLOAD_NAME = "GameFeelFlow"
const AUTOLOAD_PATH = "res://addons/game_feel_flow/core/game_feel_flow.gd"

func _enter_tree() -> void:
    # Add autoload singleton
    add_autoload_singleton(AUTOLOAD_NAME, AUTOLOAD_PATH)
    print("Game Feel Flow: Plugin enabled")

func _exit_tree() -> void:
    # Remove autoload singleton
    remove_autoload_singleton(AUTOLOAD_NAME)
    print("Game Feel Flow: Plugin disabled")
