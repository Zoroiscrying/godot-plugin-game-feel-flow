extends Control

## 参数调节子场景
## 实时调节效果参数并预览

# ===== 节点引用 =====
@onready var effect_option: OptionButton = $VBoxContainer/HBoxContainer/EffectOption
@onready var preview_container: SubViewportContainer = $VBoxContainer/HSplitContainer/PreviewContainer
@onready var preview_viewport: SubViewport = $VBoxContainer/HSplitContainer/PreviewContainer/SubViewport
@onready var param_panel: VBoxContainer = $VBoxContainer/HSplitContainer/ParamPanel
@onready var code_button: Button = $VBoxContainer/HBoxContainer/CodeButton
@onready var reset_button: Button = $VBoxContainer/HBoxContainer/ResetButton

# ===== 属性 =====
var current_effect: String = ""
var preview_target: Node2D = null

# ===== 生命周期 =====

func _ready() -> void:
	_setup_effect_options()
	_connect_signals()
	_create_preview_target()

# ===== 初始化 =====

func _setup_effect_options() -> void:
	var effects = ["shake", "scale", "flash", "color", "alpha", "freeze_frame", "time_scale"]
	for effect in effects:
		effect_option.add_item(effect.capitalize())

func _connect_signals() -> void:
	effect_option.item_selected.connect(_on_effect_selected)
	code_button.pressed.connect(_on_code_pressed)
	reset_button.pressed.connect(_on_reset_pressed)
	param_panel.params_changed.connect(_on_params_changed)

func _create_preview_target() -> void:
	preview_target = Node2D.new()
	var sprite = ColorRect.new()
	sprite.size = Vector2(100, 100)
	sprite.color = Color.WHITE
	sprite.position = Vector2(-50, -50)
	preview_target.add_child(sprite)
	preview_viewport.add_child(preview_target)

# ===== 效果切换 =====

func _select_effect(effect_name: String) -> void:
	current_effect = effect_name
	param_panel.setup_for_effect(effect_name)

# ===== 回调方法 =====

func _on_effect_selected(index: int) -> void:
	var effects = ["shake", "scale", "flash", "color", "alpha", "freeze_frame", "time_scale"]
	if index >= 0 and index < effects.size():
		_select_effect(effects[index])

func _on_params_changed(params: GFFParams) -> void:
	if current_effect and preview_target:
		GameFeelFlow.play(current_effect, preview_target, params)

func _on_code_pressed() -> void:
	var code_preview = preload("res://addons/game_feel_flow/examples/components/code_preview.tscn").instantiate()
	add_child(code_preview)
	var params_code = "GFFParams.create(1.0, 0.3)"
	code_preview.show_code('GameFeelFlow.play("%s", target, %s)' % [current_effect, params_code])

func _on_reset_pressed() -> void:
	param_panel.reset_params()
