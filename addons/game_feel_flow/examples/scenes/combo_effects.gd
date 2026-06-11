extends Control

## 组合效果子场景
## 展示和编辑组合效果

# ===== 节点引用 =====
@onready var combo_list: ItemList = $VBoxContainer/HSplitContainer/ComboList
@onready var preview_container: SubViewportContainer = $VBoxContainer/HSplitContainer/VBoxContainer/PreviewContainer
@onready var preview_viewport: SubViewport = $VBoxContainer/HSplitContainer/VBoxContainer/PreviewContainer/SubViewport
@onready var effects_list: ItemList = $VBoxContainer/HSplitContainer/VBoxContainer/EffectsList
@onready var code_edit: CodeEdit = $VBoxContainer/HSplitContainer/VBoxContainer/CodeEdit
@onready var play_button: Button = $VBoxContainer/HBoxContainer/PlayButton
@onready var copy_button: Button = $VBoxContainer/HBoxContainer/CopyButton

# ===== 属性 =====
var current_combo: String = ""
var preview_target: Node2D = null

# ===== 组合效果列表 =====
var combos: Dictionary = {
	"hit_light": {"name": "Hit Light", "effects": ["shake", "flash", "scale"]},
	"hit_heavy": {"name": "Hit Heavy", "effects": ["shake", "flash", "freeze_frame", "scale"]},
	"death": {"name": "Death", "effects": ["shake", "flash", "freeze_frame", "scale", "alpha"]},
	"pickup": {"name": "Pickup", "effects": ["scale", "flash"]},
	"explosion": {"name": "Explosion", "effects": ["shake", "flash", "freeze_frame", "scale"]},
}

# ===== 生命周期 =====

func _ready() -> void:
	_setup_combo_list()
	_connect_signals()
	_create_preview_target()

# ===== 初始化 =====

func _setup_combo_list() -> void:
	for combo_name in combos:
		var combo = combos[combo_name]
		combo_list.add_item(combo["name"])

func _connect_signals() -> void:
	combo_list.item_selected.connect(_on_combo_selected)
	play_button.pressed.connect(_on_play_pressed)
	copy_button.pressed.connect(_on_copy_pressed)

func _create_preview_target() -> void:
	preview_target = Node2D.new()
	var sprite = ColorRect.new()
	sprite.size = Vector2(100, 100)
	sprite.color = Color.WHITE
	sprite.position = Vector2(-50, -50)
	preview_target.add_child(sprite)
	preview_viewport.add_child(preview_target)

# ===== 组合效果选择 =====

func _select_combo(combo_name: String) -> void:
	current_combo = combo_name
	_update_effects_list()
	_update_code_preview()

func _update_effects_list() -> void:
	effects_list.clear()
	if current_combo in combos:
		var combo = combos[current_combo]
		for effect in combo["effects"]:
			effects_list.add_item(effect)

func _update_code_preview() -> void:
	if current_combo:
		code_edit.text = 'GameFeelFlow.play_combo("%s", target_node)' % current_combo

# ===== 回调方法 =====

func _on_combo_selected(index: int) -> void:
	var combo_names = combos.keys()
	if index >= 0 and index < combo_names.size():
		_select_combo(combo_names[index])

func _on_play_pressed() -> void:
	if current_combo and preview_target:
		GameFeelFlow.play_combo(current_combo, preview_target)

func _on_copy_pressed() -> void:
	if current_combo:
		DisplayServer.clipboard_set(code_edit.text)
