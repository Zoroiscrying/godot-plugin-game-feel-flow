@tool
extends EditorPlugin

## Game Feel Flow Plugin

const AUTOLOAD_NAME = "GameFeelFlow"
const AUTOLOAD_PATH = "res://addons/game_feel_flow/core/game_feel_flow.gd"

var _inspector_plugin: EditorInspectorPlugin = null
var _preview_dock: Control = null
var _preview_viewport: SubViewport = null
var _preview_target: Node2D = null

func _enter_tree() -> void:
	# Add autoload singleton
	add_autoload_singleton(AUTOLOAD_NAME, AUTOLOAD_PATH)
	
	# 注册Inspector插件
	_inspector_plugin = preload("res://addons/game_feel_flow/editor/gff_player_inspector.gd").new()
	add_inspector_plugin(_inspector_plugin)
	
	# 创建预览Dock
	_preview_dock = _create_preview_dock()
	add_control_to_bottom_panel(_preview_dock, "Game Feel Flow")
	
	print("Game Feel Flow: Plugin enabled")

func _exit_tree() -> void:
	# Remove autoload singleton
	remove_autoload_singleton(AUTOLOAD_NAME)
	
	# 清理Inspector插件
	if _inspector_plugin:
		remove_inspector_plugin(_inspector_plugin)
		_inspector_plugin = null
	
	# 清理预览Dock
	if _preview_dock:
		remove_control_from_bottom_panel(_preview_dock)
		_preview_dock.queue_free()
		_preview_dock = null
	
	print("Game Feel Flow: Plugin disabled")

func _create_preview_dock() -> Control:
	## 创建预览Dock
	var main_container = HSplitContainer.new()
	main_container.custom_minimum_size = Vector2(0, 300)
	
	# 左侧：效果列表
	var left_panel = _create_effect_list_panel()
	main_container.add_child(left_panel)
	
	# 右侧：预览区域
	var right_panel = _create_preview_panel()
	main_container.add_child(right_panel)
	
	return main_container

func _create_effect_list_panel() -> Control:
	## 创建效果列表面板
	var panel = VBoxContainer.new()
	panel.custom_minimum_size = Vector2(200, 0)
	
	var label = Label.new()
	label.text = "Effects"
	label.add_theme_font_size_override("font_size", 14)
	panel.add_child(label)
	
	# 效果列表
	var list = ItemList.new()
	list.size_flags_vertical = Control.SIZE_EXPAND_FILL
	
	# 添加效果
	var effects = [
		"Shake", "Shake Position", "Shake Scale", "Shake Rotation",
		"Punch", "Punch Position", "Punch Scale", "Punch Rotation",
		"Scale", "Flash", "Color", "Alpha",
		"Hit Light", "Hit Heavy", "Death", "Pickup", "Explosion"
	]
	
	for effect in effects:
		list.add_item(effect)
	
	list.item_selected.connect(_on_effect_selected)
	panel.add_child(list)
	
	return panel

func _create_preview_panel() -> Control:
	## 创建预览面板
	var panel = VBoxContainer.new()
	
	var label = Label.new()
	label.text = "Preview"
	label.add_theme_font_size_override("font_size", 14)
	panel.add_child(label)
	
	# 预览容器
	var preview_container = SubViewportContainer.new()
	preview_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	preview_container.stretch = true
	preview_container.custom_minimum_size = Vector2(200, 200)
	
	# 创建SubViewport
	_preview_viewport = SubViewport.new()
	preview_container.add_child(_preview_viewport)
	
	# 创建预览目标
	_preview_target = ColorRect.new()
	_preview_target.size = Vector2(100, 100)
	_preview_target.color = Color.WHITE
	_preview_target.position = Vector2(50, 50)
	_preview_viewport.add_child(_preview_target)
	
	panel.add_child(preview_container)
	
	# 参数面板
	var param_panel = VBoxContainer.new()
	param_panel.name = "ParamPanel"
	panel.add_child(param_panel)
	
	# 控制按钮
	var button_bar = HBoxContainer.new()
	
	var play_button = Button.new()
	play_button.text = "Play"
	play_button.pressed.connect(_on_play_pressed)
	button_bar.add_child(play_button)
	
	var reset_button = Button.new()
	reset_button.text = "Reset"
	reset_button.pressed.connect(_on_reset_pressed)
	button_bar.add_child(reset_button)
	
	panel.add_child(button_bar)
	
	return panel

func _on_effect_selected(index: int) -> void:
	## 效果选择
	var effects = [
		"shake", "shake_position", "shake_scale", "shake_rotation",
		"punch", "punch_position", "punch_scale", "punch_rotation",
		"scale", "flash", "color", "alpha",
		"hit_light", "hit_heavy", "death", "pickup", "explosion"
	]
	
	if index >= 0 and index < effects.size():
		var effect_type = effects[index]
		_update_params(effect_type)

func _update_params(effect_type: String) -> void:
	## 更新参数面板
	var param_panel = _preview_dock.get_node("VBoxContainer/ParamPanel")
	if not param_panel:
		return
	
	# 清空参数面板
	for child in param_panel.get_children():
		child.queue_free()
	
	# 根据效果类型添加参数
	match effect_type:
		"shake", "shake_position":
			_add_float_param(param_panel, "intensity", 1.0, 0.0, 3.0, 0.1)
			_add_float_param(param_panel, "duration", 0.3, 0.01, 1.0, 0.01)
			_add_float_param(param_panel, "amplitude", 0.5, 0.1, 5.0, 0.1)
		"shake_scale":
			_add_float_param(param_panel, "intensity", 1.0, 0.0, 3.0, 0.1)
			_add_float_param(param_panel, "duration", 0.3, 0.01, 1.0, 0.01)
			_add_float_param(param_panel, "amplitude", 0.2, 0.05, 2.0, 0.05)
		"shake_rotation":
			_add_float_param(param_panel, "intensity", 1.0, 0.0, 3.0, 0.1)
			_add_float_param(param_panel, "duration", 0.3, 0.01, 1.0, 0.01)
			_add_float_param(param_panel, "amplitude", 10.0, 1.0, 45.0, 1.0)
		"punch", "punch_position", "punch_scale", "punch_rotation":
			_add_float_param(param_panel, "intensity", 1.0, 0.0, 3.0, 0.1)
			_add_float_param(param_panel, "duration", 0.3, 0.01, 1.0, 0.01)
			_add_float_param(param_panel, "elasticity", 0.5, 0.0, 1.0, 0.1)
		"scale":
			_add_float_param(param_panel, "intensity", 1.0, 0.0, 3.0, 0.1)
			_add_float_param(param_panel, "duration", 0.3, 0.01, 1.0, 0.01)
		"flash":
			_add_float_param(param_panel, "intensity", 1.0, 0.0, 3.0, 0.1)
			_add_float_param(param_panel, "duration", 0.3, 0.01, 1.0, 0.01)
			_add_float_param(param_panel, "frequency", 15.0, 5.0, 30.0, 1.0)
			_add_color_param(param_panel, "color", Color.WHITE)
		"color":
			_add_float_param(param_panel, "intensity", 1.0, 0.0, 3.0, 0.1)
			_add_float_param(param_panel, "duration", 0.3, 0.01, 0.5, 0.01)
			_add_color_param(param_panel, "color", Color.RED)
		"alpha":
			_add_float_param(param_panel, "intensity", 1.0, 0.0, 3.0, 0.1)
			_add_float_param(param_panel, "duration", 0.3, 0.01, 0.3, 0.01)
		"hit_light", "hit_heavy", "death", "pickup", "explosion":
			_add_float_param(param_panel, "intensity", 1.0, 0.0, 3.0, 0.1)

func _add_float_param(parent: Control, param_name: String, default: float, min_val: float, max_val: float, step: float = 0.01) -> void:
	var hbox = HBoxContainer.new()
	
	var label = Label.new()
	label.text = param_name
	label.custom_minimum_size.x = 100
	hbox.add_child(label)
	
	var slider = HSlider.new()
	slider.min_value = min_val
	slider.max_value = max_val
	slider.value = default
	slider.step = step
	slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	slider.name = param_name
	hbox.add_child(slider)
	
	var value_label = Label.new()
	value_label.text = "%.2f" % default
	value_label.custom_minimum_size.x = 50
	hbox.add_child(value_label)
	
	slider.value_changed.connect(func(value): value_label.text = "%.2f" % value)
	
	parent.add_child(hbox)

func _add_color_param(parent: Control, param_name: String, default: Color) -> void:
	var hbox = HBoxContainer.new()
	
	var label = Label.new()
	label.text = param_name
	label.custom_minimum_size.x = 100
	hbox.add_child(label)
	
	var color_picker = ColorPickerButton.new()
	color_picker.color = default
	color_picker.name = param_name
	hbox.add_child(color_picker)
	
	parent.add_child(hbox)

func _on_play_pressed() -> void:
	## 播放按钮点击
	if _preview_target:
		GameFeelFlow.play("shake", _preview_target)

func _on_reset_pressed() -> void:
	## 重置按钮点击
	if _preview_target:
		_preview_target.position = Vector2(50, 50)
		_preview_target.scale = Vector2.ONE
		_preview_target.rotation = 0
		_preview_target.modulate = Color.WHITE
