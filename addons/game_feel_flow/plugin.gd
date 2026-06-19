@tool
extends EditorPlugin

## Game Feel Flow Plugin

const AUTOLOAD_NAME = "GameFeelFlow"
const AUTOLOAD_PATH = "res://addons/game_feel_flow/core/game_feel_flow.gd"

var _inspector_plugin: EditorInspectorPlugin = null
var _preview_dock: Control = null
var _preview_viewport: SubViewport = null
var _preview_target: Node = null
var _preview_camera: Camera3D = null
var _param_panel: VBoxContainer = null
var _current_effect: String = ""
var _current_target_type: String = "2d"  # 2d, 3d, ui

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
	
	# 左侧：效果列表和目标选择
	var left_panel = _create_left_panel()
	main_container.add_child(left_panel)
	
	# 右侧：预览区域和参数
	var right_panel = _create_right_panel()
	main_container.add_child(right_panel)
	
	return main_container

func _create_left_panel() -> Control:
	## 创建左侧面板
	var panel = VBoxContainer.new()
	panel.custom_minimum_size = Vector2(200, 0)
	
	# 目标选择
	var target_label = Label.new()
	target_label.text = "Target Type"
	target_label.add_theme_font_size_override("font_size", 14)
	panel.add_child(target_label)
	
	var target_option = OptionButton.new()
	target_option.add_item("2D Sprite", 0)
	target_option.add_item("3D Box", 1)
	target_option.add_item("UI Button", 2)
	target_option.item_selected.connect(_on_target_type_changed)
	panel.add_child(target_option)
	
	# 效果列表
	var effect_label = Label.new()
	effect_label.text = "Effects"
	effect_label.add_theme_font_size_override("font_size", 14)
	panel.add_child(effect_label)
	
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

func _create_right_panel() -> Control:
	## 创建右侧面板
	var panel = VBoxContainer.new()
	
	# 预览容器
	var preview_container = SubViewportContainer.new()
	preview_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	preview_container.stretch = true
	preview_container.custom_minimum_size = Vector2(200, 200)
	
	# 创建SubViewport
	_preview_viewport = SubViewport.new()
	_preview_viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	preview_container.add_child(_preview_viewport)
	
	# 创建默认目标
	_create_target("2d")
	
	panel.add_child(preview_container)
	
	# 参数面板
	_param_panel = VBoxContainer.new()
	_param_panel.name = "ParamPanel"
	panel.add_child(_param_panel)
	
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

func _create_target(target_type: String) -> void:
	## 创建预览目标
	# 清除旧目标
	if _preview_target:
		_preview_target.queue_free()
		_preview_target = null
	
	# 清除旧相机
	if _preview_camera:
		_preview_camera.queue_free()
		_preview_camera = null
	
	_current_target_type = target_type
	
	match target_type:
		"2d":
			_create_2d_target()
		"3d":
			_create_3d_target()
		"ui":
			_create_ui_target()

func _create_2d_target() -> void:
	## 创建2D目标
	var target = ColorRect.new()
	target.size = Vector2(100, 100)
	target.color = Color.WHITE
	target.position = Vector2(150, 150)
	_preview_viewport.add_child(target)
	_preview_target = target

func _create_3d_target() -> void:
	## 创建3D目标
	# 创建相机
	_preview_camera = Camera3D.new()
	_preview_camera.position = Vector3(0, 2, 5)
	_preview_camera.look_at(Vector3.ZERO)
	_preview_viewport.add_child(_preview_camera)
	
	# 创建目标
	var target = MeshInstance3D.new()
	target.mesh = BoxMesh.new()
	_preview_viewport.add_child(target)
	_preview_target = target
	
	# 添加光源
	var light = DirectionalLight3D.new()
	light.position = Vector3(2, 3, 2)
	light.look_at(Vector3.ZERO)
	_preview_viewport.add_child(light)

func _create_ui_target() -> void:
	## 创建UI目标
	var target = Button.new()
	target.text = "Click Me"
	target.position = Vector2(150, 150)
	target.size = Vector2(100, 50)
	_preview_viewport.add_child(target)
	_preview_target = target

func _on_target_type_changed(index: int) -> void:
	## 目标类型改变
	match index:
		0:
			_create_target("2d")
		1:
			_create_target("3d")
		2:
			_create_target("ui")

func _on_effect_selected(index: int) -> void:
	## 效果选择
	var effects = [
		"shake", "shake_position", "shake_scale", "shake_rotation",
		"punch", "punch_position", "punch_scale", "punch_rotation",
		"scale", "flash", "color", "alpha",
		"hit_light", "hit_heavy", "death", "pickup", "explosion"
	]
	
	if index >= 0 and index < effects.size():
		_current_effect = effects[index]
		_update_params(_current_effect)

func _update_params(effect_type: String) -> void:
	## 更新参数面板
	if not _param_panel:
		return
	
	# 清空参数面板
	for child in _param_panel.get_children():
		child.queue_free()
	
	# 根据效果类型添加参数
	match effect_type:
		"shake", "shake_position":
			_add_float_param("intensity", 1.0, 0.0, 3.0, 0.1)
			_add_float_param("duration", 0.3, 0.01, 1.0, 0.01)
			_add_float_param("amplitude", 0.5, 0.1, 5.0, 0.1)
		"shake_scale":
			_add_float_param("intensity", 1.0, 0.0, 3.0, 0.1)
			_add_float_param("duration", 0.3, 0.01, 1.0, 0.01)
			_add_float_param("amplitude", 0.2, 0.05, 2.0, 0.05)
		"shake_rotation":
			_add_float_param("intensity", 1.0, 0.0, 3.0, 0.1)
			_add_float_param("duration", 0.3, 0.01, 1.0, 0.01)
			_add_float_param("amplitude", 10.0, 1.0, 45.0, 1.0)
		"punch", "punch_position", "punch_scale", "punch_rotation":
			_add_float_param("intensity", 1.0, 0.0, 3.0, 0.1)
			_add_float_param("duration", 0.3, 0.01, 1.0, 0.01)
			_add_float_param("elasticity", 0.5, 0.0, 1.0, 0.1)
		"scale":
			_add_float_param("intensity", 1.0, 0.0, 3.0, 0.1)
			_add_float_param("duration", 0.3, 0.01, 1.0, 0.01)
		"flash":
			_add_float_param("intensity", 1.0, 0.0, 3.0, 0.1)
			_add_float_param("duration", 0.3, 0.01, 1.0, 0.01)
			_add_float_param("frequency", 15.0, 5.0, 30.0, 1.0)
			_add_color_param("color", Color.WHITE)
		"color":
			_add_float_param("intensity", 1.0, 0.0, 3.0, 0.1)
			_add_float_param("duration", 0.3, 0.01, 0.5, 0.01)
			_add_color_param("color", Color.RED)
		"alpha":
			_add_float_param("intensity", 1.0, 0.0, 3.0, 0.1)
			_add_float_param("duration", 0.3, 0.01, 0.3, 0.01)
		"hit_light", "hit_heavy", "death", "pickup", "explosion":
			_add_float_param("intensity", 1.0, 0.0, 3.0, 0.1)

func _add_float_param(param_name: String, default: float, min_val: float, max_val: float, step: float = 0.01) -> void:
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
	
	_param_panel.add_child(hbox)

func _add_color_param(param_name: String, default: Color) -> void:
	var hbox = HBoxContainer.new()
	
	var label = Label.new()
	label.text = param_name
	label.custom_minimum_size.x = 100
	hbox.add_child(label)
	
	var color_picker = ColorPickerButton.new()
	color_picker.color = default
	color_picker.name = param_name
	hbox.add_child(color_picker)
	
	_param_panel.add_child(hbox)

func _on_play_pressed() -> void:
	## 播放按钮点击
	if _preview_target and not _current_effect.is_empty():
		var params = _get_params()
		GameFeelFlow.play(_current_effect, _preview_target, params)

func _on_reset_pressed() -> void:
	## 重置按钮点击
	_create_target(_current_target_type)

func _get_params() -> GFFParams:
	## 获取参数
	var params = GFFParams.new()
	
	for child in _param_panel.get_children():
		if child is HBoxContainer:
			for subchild in child.get_children():
				if subchild is HSlider:
					if subchild.name == "intensity":
						params.intensity = subchild.value
					elif subchild.name == "duration":
						params.duration = subchild.value
					else:
						params.with_float(subchild.name, subchild.value)
				elif subchild is ColorPickerButton:
					params.with_color(subchild.name, subchild.color)
	
	return params
