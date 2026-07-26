extends Control

## EffectLibrary: full effect catalog hub (demoted/renamed from legacy `main`).
## Catalog sub-scenes live in the content pane; 2D/3D playgrounds embed
## `main_2d` / `main_3d` via SubViewport (they are Node2D / Node3D roots).

const SHOWCASE_SCENE_PATH := "res://addons/game_feel_flow/examples/showcase.tscn"
const ONBOARDING_SCENE_PATH := "res://addons/game_feel_flow/examples/onboarding.tscn"
const MAIN_2D_PATH := "res://addons/game_feel_flow/examples/main_2d.tscn"
const MAIN_3D_PATH := "res://addons/game_feel_flow/examples/main_3d.tscn"

const SCENE_ENTRIES: Array[Dictionary] = [
	{"id": "effects_demo", "label": "Effects Catalog", "path": "res://addons/game_feel_flow/examples/scenes/effects_demo.tscn", "embed": false},
	{"id": "game_scenes", "label": "Game Scenes", "path": "res://addons/game_feel_flow/examples/scenes/game_scenes.tscn", "embed": false},
	{"id": "param_adjuster", "label": "Param Adjuster", "path": "res://addons/game_feel_flow/examples/scenes/param_adjuster.tscn", "embed": false},
	{"id": "combo_effects", "label": "Combo Effects", "path": "res://addons/game_feel_flow/examples/scenes/combo_effects.tscn", "embed": false},
	{"id": "perf_monitor", "label": "Perf Monitor", "path": "res://addons/game_feel_flow/examples/scenes/perf_monitor.tscn", "embed": false},
	{"id": "loop_demo", "label": "Loop Demo", "path": "res://addons/game_feel_flow/examples/scenes/loops/loop_demo.tscn", "embed": false},
	{"id": "combo_click", "label": "Combo Click Demo", "path": "res://addons/game_feel_flow/examples/demo_combo_workflow.tscn", "embed": true},
	{"id": "main_2d", "label": "2D Playground", "path": MAIN_2D_PATH, "embed": true},
	{"id": "main_3d", "label": "3D Playground", "path": MAIN_3D_PATH, "embed": true},
]

@onready var title_label: Label = $ToolBar/HBoxContainer/TitleLabel
@onready var nav_list: ItemList = $HSplitContainer/NavPanel/NavList
@onready var content_container: Control = $HSplitContainer/ContentContainer
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

var current_scene: Node = null
var current_scene_id: String = ""
var current_index: int = 0
var is_3d_mode: bool = false
var is_auto_play: bool = false
var _auto_timer: Timer = null
var _viewport_host: SubViewportContainer = null
var _viewport: SubViewport = null
var _help_dialog: AcceptDialog = null
var _packed_scenes: Dictionary = {}


func _ready() -> void:
	get_window().title = "EffectLibrary"
	title_label.text = "EffectLibrary"
	_preload_scenes()
	_setup_nav()
	_connect_signals()
	_setup_auto_timer()
	_load_scene_at(0)


func _process(_delta: float) -> void:
	_update_fps()
	_update_effects_count()


func _preload_scenes() -> void:
	_packed_scenes.clear()
	for entry in SCENE_ENTRIES:
		var path: String = entry["path"]
		if ResourceLoader.exists(path):
			_packed_scenes[entry["id"]] = load(path)
		else:
			push_warning("EffectLibrary: missing scene %s" % path)


func _setup_nav() -> void:
	nav_list.clear()
	for entry in SCENE_ENTRIES:
		nav_list.add_item(entry["label"])
	if nav_list.item_count > 0:
		nav_list.select(0)


func _connect_signals() -> void:
	nav_list.item_selected.connect(_on_nav_selected)
	mode_button.pressed.connect(_on_mode_pressed)
	help_button.pressed.connect(_on_help_pressed)
	auto_play_button.pressed.connect(_on_auto_play_pressed)
	prev_button.pressed.connect(_on_prev_pressed)
	next_button.pressed.connect(_on_next_pressed)
	showcase_button.pressed.connect(_on_showcase_pressed)
	onboarding_button.pressed.connect(_on_onboarding_pressed)


func _setup_auto_timer() -> void:
	_auto_timer = Timer.new()
	_auto_timer.wait_time = 3.0
	_auto_timer.one_shot = false
	_auto_timer.timeout.connect(_on_auto_tick)
	add_child(_auto_timer)


func _load_scene_at(index: int) -> void:
	if SCENE_ENTRIES.is_empty():
		return
	current_index = clampi(index, 0, SCENE_ENTRIES.size() - 1)
	var entry: Dictionary = SCENE_ENTRIES[current_index]
	_load_scene_entry(entry)
	if nav_list.item_count > current_index:
		nav_list.select(current_index)
	mode_button.text = "2D" if entry["id"] == "main_3d" else "3D"
	is_3d_mode = entry["id"] == "main_3d"


func _load_scene_entry(entry: Dictionary) -> void:
	_clear_content()

	var scene_id: String = entry["id"]
	if not _packed_scenes.has(scene_id):
		scene_label.text = "Scene: missing (%s)" % scene_id
		current_scene_id = ""
		current_scene = null
		return

	var packed: PackedScene = _packed_scenes[scene_id]
	var instance: Node = packed.instantiate()
	current_scene_id = scene_id
	current_scene = instance
	scene_label.text = "Scene: " + str(entry["label"])

	if entry.get("embed", false) or not (instance is Control):
		_mount_in_viewport(instance)
	else:
		var control := instance as Control
		control.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		control.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		control.size_flags_vertical = Control.SIZE_EXPAND_FILL
		content_container.add_child(control)


func _mount_in_viewport(instance: Node) -> void:
	_ensure_viewport()
	_viewport.add_child(instance)
	_viewport_host.visible = true


func _ensure_viewport() -> void:
	if _viewport_host != null:
		return
	_viewport_host = SubViewportContainer.new()
	_viewport_host.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_viewport_host.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_viewport_host.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_viewport_host.stretch = true
	_viewport = SubViewport.new()
	_viewport.handle_input_locally = true
	_viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	_viewport_host.add_child(_viewport)
	content_container.add_child(_viewport_host)


func _clear_content() -> void:
	if current_scene != null and is_instance_valid(current_scene):
		current_scene.queue_free()
	current_scene = null

	# Drop leftover Control children except the viewport host.
	for child in content_container.get_children():
		if child == _viewport_host:
			continue
		child.queue_free()

	if _viewport != null:
		for child in _viewport.get_children():
			child.queue_free()
	if _viewport_host != null:
		_viewport_host.visible = false


func _update_fps() -> void:
	if fps_label:
		fps_label.text = "FPS: %d" % Engine.get_frames_per_second()


func _update_effects_count() -> void:
	if effects_label == null:
		return
	var count := 0
	if current_scene != null and is_instance_valid(current_scene):
		if "effect_cards" in current_scene:
			count = current_scene.effect_cards.size()
		elif "effects" in current_scene:
			count = current_scene.effects.size()
		elif GameFeelFlow != null:
			count = GameFeelFlow.get_effect_names().size()
	elif GameFeelFlow != null:
		count = GameFeelFlow.get_effect_names().size()
	effects_label.text = "Effects: %d" % count


func _on_nav_selected(index: int) -> void:
	_load_scene_at(index)


func _on_mode_pressed() -> void:
	# Jump to the opposite playground.
	var target_id := "main_2d" if is_3d_mode else "main_3d"
	for i in SCENE_ENTRIES.size():
		if SCENE_ENTRIES[i]["id"] == target_id:
			_load_scene_at(i)
			return


func _on_help_pressed() -> void:
	if _help_dialog == null:
		_help_dialog = AcceptDialog.new()
		_help_dialog.title = "EffectLibrary Help"
		_help_dialog.dialog_text = (
			"Browse catalog scenes on the left.\n"
			+ "Combo Click Demo: click / Space combos (teaching flow is Onboarding).\n"
			+ "Use 3D / 2D to open the playground demos (main_2d / main_3d).\n"
			+ "Prev / Next cycle scenes. Auto advances every 3 seconds.\n"
			+ "Showcase and Onboarding jump to the guided flows."
		)
		add_child(_help_dialog)
	_help_dialog.popup_centered()


func _on_auto_play_pressed() -> void:
	is_auto_play = not is_auto_play
	auto_play_button.text = "Stop" if is_auto_play else "Auto"
	if is_auto_play:
		_auto_timer.start()
	else:
		_auto_timer.stop()


func _on_auto_tick() -> void:
	_on_next_pressed()


func _on_prev_pressed() -> void:
	if SCENE_ENTRIES.is_empty():
		return
	var next_i := (current_index - 1 + SCENE_ENTRIES.size()) % SCENE_ENTRIES.size()
	_load_scene_at(next_i)


func _on_next_pressed() -> void:
	if SCENE_ENTRIES.is_empty():
		return
	var next_i := (current_index + 1) % SCENE_ENTRIES.size()
	_load_scene_at(next_i)


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
