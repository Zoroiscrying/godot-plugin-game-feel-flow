extends Control

## Effect demo sub-scene
## Card grid showing all available effects

const EffectCard = preload("res://addons/game_feel_flow/examples/components/effect_card.gd")

# ===== Node References =====
@onready var filter_bar: HBoxContainer = $VBoxContainer/FilterBar
@onready var search_line: LineEdit = $VBoxContainer/FilterBar/SearchLine
@onready var grid_container: GridContainer = $VBoxContainer/ScrollContainer/GridContainer
@onready var detail_window: Window = $DetailWindow
@onready var param_panel: VBoxContainer = $DetailWindow/VBoxContainer/ParamPanel
@onready var preview_container: SubViewportContainer = $DetailWindow/VBoxContainer/PreviewContainer
@onready var code_button: Button = $DetailWindow/VBoxContainer/HBoxContainer/CodeButton
@onready var reset_button: Button = $DetailWindow/VBoxContainer/HBoxContainer/ResetButton
@onready var close_button: Button = $DetailWindow/VBoxContainer/HBoxContainer/CloseButton

# ===== Properties =====
var current_filter: String = "all"
var current_effect: String = ""
var effect_cards: Array[PanelContainer] = []
var visible_cards: Array[PanelContainer] = []
var _cards_created: bool = false

# ===== Effect List =====
var effects: Array[Dictionary] = [
	{"name": "Shake Position", "type": "shake_position", "complexity": "simple"},
	{"name": "Shake Scale", "type": "shake_scale", "complexity": "simple"},
	{"name": "Shake Rotation", "type": "shake_rotation", "complexity": "simple"},
	{"name": "Punch Position", "type": "punch_position", "complexity": "simple"},
	{"name": "Punch Scale", "type": "punch_scale", "complexity": "simple"},
	{"name": "Punch Rotation", "type": "punch_rotation", "complexity": "simple"},
	{"name": "Curved Position", "type": "curved_position", "complexity": "simple"},
	{"name": "Curved Scale", "type": "curved_scale", "complexity": "simple"},
	{"name": "Curved Rotation", "type": "curved_rotation", "complexity": "simple"},
	{"name": "Color", "type": "color", "complexity": "simple"},
	{"name": "Alpha", "type": "alpha", "complexity": "simple"},
	{"name": "Flash", "type": "flash", "complexity": "simple"},
	{"name": "Freeze Frame", "type": "freeze_frame", "complexity": "simple"},
	{"name": "Time Scale", "type": "time_scale", "complexity": "medium"},
	{"name": "Sound", "type": "sound", "complexity": "medium"},
	{"name": "Audio Volume", "type": "audio_volume", "complexity": "medium"},
	{"name": "Camera Shake", "type": "camera_shake", "complexity": "medium"},
	{"name": "Camera Zoom", "type": "camera_zoom", "complexity": "medium"},
	{"name": "Camera FOV", "type": "camera_fov", "complexity": "medium"},
	{"name": "Camera Flash", "type": "camera_flash", "complexity": "medium"},
	{"name": "Particles", "type": "particles", "complexity": "complex"},
	{"name": "GPU Particles", "type": "gpu_particles", "complexity": "complex"},
	{"name": "Impulse", "type": "impulse", "complexity": "medium"},
	{"name": "Velocity", "type": "velocity", "complexity": "medium"},
	{"name": "Tween", "type": "tween", "complexity": "complex"},
	{"name": "Animator", "type": "animator", "complexity": "complex"},
]

# ===== Lifecycle =====

func _ready() -> void:
	_setup_filter_buttons()
	_connect_signals()
	_create_effect_cards()

# ===== Initialization =====

func _setup_filter_buttons() -> void:
	var filters = ["All", "Simple", "Medium", "Complex"]
	for filter_name in filters:
		var button = Button.new()
		button.text = filter_name
		button.toggle_mode = true
		button.button_pressed = filter_name == "All"
		button.pressed.connect(_on_filter_pressed.bind(filter_name.to_lower()))
		filter_bar.add_child(button)

func _connect_signals() -> void:
	search_line.text_changed.connect(_on_search_changed)
	code_button.pressed.connect(_on_code_pressed)
	reset_button.pressed.connect(_on_reset_pressed)
	close_button.pressed.connect(_on_close_pressed)

func _create_effect_cards() -> void:
	# Create all cards initially but use object pool
	for effect in effects:
		var card = _create_card_lazy(effect)
		grid_container.add_child(card)
		effect_cards.append(card)
	_cards_created = true

func _create_card(effect: Dictionary) -> PanelContainer:
	var card = EffectCard.create_from_pool()
	card.set_effect(effect["name"], effect["type"], effect["complexity"])
	card.clicked.connect(_on_card_clicked)
	return card

func _create_card_lazy(effect: Dictionary) -> PanelContainer:
	var card = EffectCard.create_from_pool()
	card.set_effect(effect["name"], effect["type"], effect["complexity"])
	if not card.clicked.is_connected(_on_card_clicked):
		card.clicked.connect(_on_card_clicked)
	return card

# ===== Filter & Search =====

func _filter_effects(filter: String) -> void:
	current_filter = filter
	_update_card_visibility()

func _search_effects(query: String) -> void:
	visible_cards.clear()
	for card in effect_cards:
		var visible = query.is_empty() or card.effect_name.to_lower().contains(query.to_lower())
		card.visible = visible
		if visible:
			visible_cards.append(card)

func _update_card_visibility() -> void:
	visible_cards.clear()
	for card in effect_cards:
		var visible = current_filter == "all" or card.complexity == current_filter
		if visible and not search_line.text.is_empty():
			visible = card.effect_name.to_lower().contains(search_line.text.to_lower())
		card.visible = visible
		if visible:
			visible_cards.append(card)

# ===== Detail Preview =====

func _show_detail(effect_name: String) -> void:
	current_effect = effect_name
	detail_window.popup_centered(Vector2i(800, 600))
	param_panel.setup_for_effect(effect_name)

# ===== Callbacks =====

func _on_filter_pressed(filter: String) -> void:
	_filter_effects(filter)

func _on_search_changed(text: String) -> void:
	_search_effects(text)

func _on_card_clicked(effect_name: String) -> void:
	_show_detail(effect_name)

func _on_code_pressed() -> void:
	var code_preview = preload("res://addons/game_feel_flow/examples/components/code_preview.tscn").instantiate()
	add_child(code_preview)
	code_preview.show_code('GameFeelFlow.play("%s", target_node)' % current_effect)

func _on_reset_pressed() -> void:
	param_panel.reset_params()

func _on_close_pressed() -> void:
	detail_window.hide()
