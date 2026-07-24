extends Control

## DEPRECATED: this hub has been demoted/renamed to EffectLibrary
## (see effect_library.tscn). Kept as a thin redirect stub so old links
## and scene references don't hard-fail. For a quick first look, use
## showcase.tscn instead.

const EFFECT_LIBRARY_SCENE_PATH := "res://addons/game_feel_flow/examples/effect_library.tscn"
const SHOWCASE_SCENE_PATH := "res://addons/game_feel_flow/examples/showcase.tscn"

@onready var banner_label: Label = $Center/Panel/Margin/VBox/BannerLabel
@onready var effect_library_button: Button = $Center/Panel/Margin/VBox/HBox/EffectLibraryButton
@onready var showcase_button: Button = $Center/Panel/Margin/VBox/HBox/ShowcaseButton


func _ready() -> void:
	get_window().title = "main (deprecated)"
	banner_label.text = "Deprecated: this hub is now EffectLibrary. Open EffectLibrary or Showcase below."
	effect_library_button.pressed.connect(_on_effect_library_pressed)
	showcase_button.pressed.connect(_on_showcase_pressed)


func _on_effect_library_pressed() -> void:
	if ResourceLoader.exists(EFFECT_LIBRARY_SCENE_PATH):
		get_tree().change_scene_to_file(EFFECT_LIBRARY_SCENE_PATH)
	else:
		push_warning("main: EffectLibrary scene not available: " + EFFECT_LIBRARY_SCENE_PATH)


func _on_showcase_pressed() -> void:
	if ResourceLoader.exists(SHOWCASE_SCENE_PATH):
		get_tree().change_scene_to_file(SHOWCASE_SCENE_PATH)
	else:
		push_warning("main: Showcase scene not available: " + SHOWCASE_SCENE_PATH)
