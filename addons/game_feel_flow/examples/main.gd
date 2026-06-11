extends Control

## Game Feel Flow 示例场景主场景

# ===== 节点引用 =====
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

# ===== 属性 =====
var current_scene: Node = null
var current_scene_name: String = ""
var is_3d_mode: bool = false
var is_auto_play: bool = false

# ===== 场景引用 =====
var scenes: Dictionary = {}

# ===== 生命周期 =====

func _ready() -> void:
	_setup_scenes()
	_connect_signals()
	_load_scene("effects_demo")

func _process(_delta: float) -> void:
	_update_fps()
	_update_effects_count()

# ===== 初始化 =====

func _setup_scenes() -> void:
	scenes = {
		"effects_demo": preload("res://addons/game_feel_flow/examples/scenes/effects_demo.tscn"),
		"game_scenes": preload("res://addons/game_feel_flow/examples/scenes/game_scenes.tscn"),
		"param_adjuster": preload("res://addons/game_feel_flow/examples/scenes/param_adjuster.tscn"),
		"combo_effects": preload("res://addons/game_feel_flow/examples/scenes/combo_effects.tscn"),
		"perf_monitor": preload("res://addons/game_feel_flow/examples/scenes/perf_monitor.tscn"),
	}

func _connect_signals() -> void:
	nav_list.item_selected.connect(_on_nav_selected)
	mode_button.pressed.connect(_on_mode_pressed)
	help_button.pressed.connect(_on_help_pressed)
	auto_play_button.pressed.connect(_on_auto_play_pressed)
	prev_button.pressed.connect(_on_prev_pressed)
	next_button.pressed.connect(_on_next_pressed)

# ===== 场景管理 =====

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

# ===== UI更新 =====

func _update_fps() -> void:
	if fps_label:
		fps_label.text = "FPS: %d" % Engine.get_frames_per_second()

func _update_effects_count() -> void:
	if effects_label:
		var count = 0
		# 统计活跃效果数
		effects_label.text = "Effects: %d" % count

# ===== 回调方法 =====

func _on_nav_selected(index: int) -> void:
	var scene_names = _get_scene_names()
	if index >= 0 and index < scene_names.size():
		_load_scene(scene_names[index])

func _on_mode_pressed() -> void:
	is_3d_mode = !is_3d_mode
	mode_button.text = "2D" if is_3d_mode else "3D"
	# 切换场景模式

func _on_help_pressed() -> void:
	# 显示帮助弹窗
	pass

func _on_auto_play_pressed() -> void:
	is_auto_play = !is_auto_play
	auto_play_button.text = "Stop" if is_auto_play else "Auto"
	# 切换自动演示模式

func _on_prev_pressed() -> void:
	# 上一个效果
	pass

func _on_next_pressed() -> void:
	# 下一个效果
	pass