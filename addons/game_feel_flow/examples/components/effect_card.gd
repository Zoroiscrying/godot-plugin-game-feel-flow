extends PanelContainer

## Effect card component
## Used to show preview and info for a single effect

const EFFECT_CARD_SCENE := preload("res://addons/game_feel_flow/examples/components/effect_card.tscn")

# ===== Object Pool =====
static var pool: Array[PanelContainer] = []

static func create_from_pool() -> PanelContainer:
	if pool.size() > 0:
		var card = pool.pop_front()
		card.visible = true
		return card
	# Must instantiate the scene — script.new() has no child nodes.
	return EFFECT_CARD_SCENE.instantiate() as PanelContainer

static func return_to_pool(card: PanelContainer) -> void:
	card.visible = false
	pool.append(card)

# ===== Signals =====
signal clicked(effect_name: String)

# ===== Properties =====
var effect_name: String = ""
var effect_type: String = ""
var complexity: String = "simple"  # simple, medium, complex
var preview_target: Node = null
var _pending_name: String = ""
var _pending_type: String = ""
var _pending_complexity: String = ""

# ===== Node References =====
@onready var name_label: Label = $VBoxContainer/NameLabel
@onready var preview_container: SubViewportContainer = $VBoxContainer/PreviewContainer
@onready var preview_viewport: SubViewport = $VBoxContainer/PreviewContainer/SubViewport
@onready var complexity_label: Label = $VBoxContainer/ComplexityLabel
@onready var type_label: Label = $VBoxContainer/TypeLabel

# ===== Initialization =====

func _ready() -> void:
	gui_input.connect(_on_gui_input)
	if not _pending_name.is_empty():
		name_label.text = _pending_name
		complexity_label.text = _pending_complexity.capitalize()
		type_label.text = _pending_type
		_pending_name = ""
		_pending_type = ""
		_pending_complexity = ""

func _exit_tree() -> void:
	stop_preview()

# ===== Public Methods =====

func set_effect(p_name: String, p_type: String, p_complexity: String) -> void:
	effect_name = p_name
	effect_type = p_type
	complexity = p_complexity
	
	if name_label:
		name_label.text = p_name
		complexity_label.text = p_complexity.capitalize()
		type_label.text = p_type
	else:
		_pending_name = p_name
		_pending_type = p_type
		_pending_complexity = p_complexity

func start_preview() -> void:
	if preview_target and preview_viewport:
		preview_viewport.add_child(preview_target)

func stop_preview() -> void:
	if preview_target and preview_target.get_parent() == preview_viewport:
		preview_viewport.remove_child(preview_target)

func get_code_example() -> String:
	var code = ""
	match effect_type:
		"shake":
			code = 'GameFeelFlow.play("shake", target_node)'
		"scale":
			code = 'GameFeelFlow.play("scale", target_node)'
		"flash":
			code = 'GameFeelFlow.play("flash", target_node)'
		"color":
			code = 'GameFeelFlow.play("color", target_node)'
		_:
			code = 'GameFeelFlow.play("%s", target_node)' % effect_type
	return code

# ===== Callbacks =====

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		clicked.emit(effect_name)
