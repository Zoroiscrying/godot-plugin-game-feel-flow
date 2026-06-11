extends PanelContainer

## 效果卡片组件
## 用于展示单个效果的预览和信息

# ===== 信号 =====
signal clicked(effect_name: String)

# ===== 属性 =====
var effect_name: String = ""
var effect_type: String = ""
var complexity: String = "simple"  # simple, medium, complex
var preview_target: Node = null

# ===== 节点引用 =====
@onready var name_label: Label = $VBoxContainer/NameLabel
@onready var preview_container: SubViewportContainer = $VBoxContainer/PreviewContainer
@onready var preview_viewport: SubViewport = $VBoxContainer/PreviewContainer/SubViewport
@onready var complexity_label: Label = $VBoxContainer/ComplexityLabel
@onready var type_label: Label = $VBoxContainer/TypeLabel

# ===== 初始化 =====

func _ready() -> void:
	gui_input.connect(_on_gui_input)

# ===== 公共方法 =====

func set_effect(p_name: String, p_type: String, p_complexity: String) -> void:
	effect_name = p_name
	effect_type = p_type
	complexity = p_complexity
	
	if name_label:
		name_label.text = p_name
	if complexity_label:
		complexity_label.text = p_complexity.capitalize()
	if type_label:
		type_label.text = p_type

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

# ===== 回调方法 =====

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		clicked.emit(effect_name)
