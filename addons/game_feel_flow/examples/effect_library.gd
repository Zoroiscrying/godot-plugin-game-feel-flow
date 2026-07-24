extends Control

## EffectLibrary: the full effect catalog hub (demoted/renamed from legacy `main`).
## For a quick first look, use showcase.tscn; for a short Player/Combo teaching
## flow, use onboarding.tscn. This hub exposes every demo scene for deep-dives.

const SHOWCASE_SCENE_PATH := "res://addons/game_feel_flow/examples/showcase.tscn"
const ONBOARDING_SCENE_PATH := "res://addons/game_feel_flow/examples/onboarding.tscn"

# ===== Node References =====
@onready var title_label: Label = $ToolBar/HBoxContainer/TitleLabel
@onready var nav_list: ItemList = $HSplitContainer/NavPanel/NavList
@onready var content_container: Container = $HSplitContainer/ContentContainer
@onready var scene_label: Label = $StatusBar/HBoxContainer/SceneLabel
@onready var effects_label: Label = $StatusBar/HBoxContainer/EffectsLabel
@onready var fps_label: Label = $StatusBar/HBoxContainer/FPSLabel
@onready var mode_button: Button = $ToolBar/HBoxContainer/ModeButton
@onready var help_button: Button = $ToolBar/HBoxContainer/HelpButton
@onready var auto_play_button: Button = $ToolBar/HBoxContainer/AutoPlayButton
@onready var prev_button: Button = $ToolBar/HBoxContainer/PrevButton
@onready var next_button: Button = $ToolBar/HBoxContainer/NextButton
@onready var showcase_button: Button = $ToolBar/HBoxContainer/ShowcaseButton
@onready var onboarding_button: Button = $ToolBar/HBoxContainer/OnboardingButton

# ===== Properties =====
var current_scene: Node = null
var current_scene_name: String = ""
var is_3d_mode: bool = false
var is_auto_play: bool = false

# ===== Scene References =====
var scenes: Dictionary = {}

# ===== Lifecycle =====

func _ready() -> void:
	get_window().title = "EffectLibrary"
	title_label.text = "EffectLibrary"
	_setup_scenes()
	_connect_signals()
	_load_scene("effects_demo")

func _process(_delta: float) -> void:
	_update_fps()
	_update_effects_count()

# ===== Initialization =====

func _setup_scenes() -> void:
	scenes = {
		"effects_demo": preload("res://addons/game_feel_flow/examples/scenes/effects_demo.tscn"),
		"game_scenes": preload("res://addons/game_feel_flow/examples/scenes/game_scenes.tscn"),
		"param_adjuster": preload("res://addons/game_feel_flow/examples/scenes/param_adjuster.tscn"),
		"combo_effects": preload("res://addons/game_feel_flow/examples/scenes/combo_effects.tscn"),
		"perf_monitor": preload("res://addons/game_feel_flow/examples/scenes/perf_monitor.tscn"),
		"loop_demo": preload("res://addons/game_feel_flow/examples/scenes/loops/loop_demo.tscn"),
	}

func _connect_signals() -> void:
	nav_list.item_selected.connect(_on_nav_selected)
	mode_button.pressed.connect(_on_mode_pressed)
	help_button.pressed.connect(_on_help_pressed)
	auto_play_button.pressed.connect(_on_auto_play_pressed)
	prev_button.pressed.connect(_on_prev_pressed)
	next_button.pressed.connect(_on_next_pressed)
	showcase_button.pressed.connect(_on_showcase_pressed)
	onboarding_button.pressed.connect(_on_onboarding_pressed)

# ===== Scene Management =====

func _load_scene(scene_name: String) -> void:
	if current_scene:
		current_scene.queue_free()
	
	if scene_name in scenes:
		current_scene = scenes[scene_name].instantiate()
		content_container.add_child(current_scene)
		current_scene_name = scene_name
		scene_label.text = "Scene: " + scene_name.capitalize().replace("_", " ")

func _get_scene_names() -> Array[String]:
	return scenes.keys()

# ===== UI Update =====

func _update_fps() -> void:
	if fps_label:
		fps_label.text = "FPS: %d" % Engine.get_frames_per_second()

func _update_effects_count() -> void:
	if effects_label:
		var count = 0
		# Count active effects
		effects_label.text = "Effects: %d" % count

# ===== Callbacks =====

func _on_nav_selected(index: int) -> void:
	var scene_names = _get_scene_names()
	if index >= 0 and index < scene_names.size():
		_load_scene(scene_names[index])

func _on_mode_pressed() -> void:
	is_3d_mode = !is_3d_mode
	mode_button.text = "2D" if is_3d_mode else "3D"
	# Switch scene mode

func _on_help_pressed() -> void:
	# Show help popup
	pass

func _on_auto_play_pressed() -> void:
	is_auto_play = !is_auto_play
	auto_play_button.text = "Stop" if is_auto_play else "Auto"
	# Toggle auto demo mode

func _on_prev_pressed() -> void:
	# Previous effect
	pass

func _on_next_pressed() -> void:
	# Next effect
	pass

func _on_showcase_pressed() -> void:
	if ResourceLoader.exists(SHOWCASE_SCENE_PATH):
		get_tree().change_scene_to_file(SHOWCASE_SCENE_PATH)
	else:
		push_warning("EffectLibrary: Showcase scene not available: " + SHOWCASE_SCENE_PATH)

func _on_onboarding_pressed() -> void:
	if ResourceLoader.exists(ONBOARDING_SCENE_PATH):
		get_tree().change_scene_to_file(ONBOARDING_SCENE_PATH)
	else:
		push_warning("EffectLibrary: Onboarding scene not available: " + ONBOARDING_SCENE_PATH)
