@tool
extends EditorPlugin

## Game Feel Flow Plugin

const AUTOLOAD_NAME = "GameFeelFlow"
const AUTOLOAD_PATH = "res://addons/game_feel_flow/core/game_feel_flow.gd"

var _inspector_plugin: EditorInspectorPlugin = null
var _editor_dock: Control = null
var _current_effect: GFFCurvedBase = null
var _status_label: Label = null

func _enter_tree() -> void:
	# Add autoload singleton
	add_autoload_singleton(AUTOLOAD_NAME, AUTOLOAD_PATH)
	
	# 注册Inspector插件
	_inspector_plugin = preload("res://addons/game_feel_flow/editor/gff_player_inspector.gd").new()
	add_inspector_plugin(_inspector_plugin)
	
	# 创建编辑器Dock
	_editor_dock = _create_editor_dock()
	add_control_to_bottom_panel(_editor_dock, "Game Feel Flow")
	
	print("Game Feel Flow: Plugin enabled")

func _exit_tree() -> void:
	# Remove autoload singleton
	remove_autoload_singleton(AUTOLOAD_NAME)
	
	# 清理Inspector插件
	if _inspector_plugin:
		remove_inspector_plugin(_inspector_plugin)
		_inspector_plugin = null
	
	# 清理编辑器Dock
	if _editor_dock:
		remove_control_from_bottom_panel(_editor_dock)
		_editor_dock.queue_free()
		_editor_dock = null
	
	print("Game Feel Flow: Plugin disabled")

func _create_editor_dock() -> Control:
	## 创建编辑器Dock
	var main_container = VBoxContainer.new()
	main_container.custom_minimum_size = Vector2(0, 200)
	
	# 工具栏
	var toolbar = _create_toolbar()
	main_container.add_child(toolbar)
	
	# 效果配置
	var config_panel = _create_effect_config()
	main_container.add_child(config_panel)
	
	# 状态栏
	var status_bar = _create_status_bar()
	main_container.add_child(status_bar)
	
	return main_container

func _create_toolbar() -> Control:
	## 创建工具栏
	var toolbar = HBoxContainer.new()
	
	# 新建按钮
	var new_button = Button.new()
	new_button.text = "New"
	new_button.pressed.connect(_on_new_pressed)
	toolbar.add_child(new_button)
	
	# 加载按钮
	var load_button = Button.new()
	load_button.text = "Load"
	load_button.pressed.connect(_on_load_pressed)
	toolbar.add_child(load_button)
	
	# 保存按钮
	var save_button = Button.new()
	save_button.text = "Save"
	save_button.pressed.connect(_on_save_pressed)
	toolbar.add_child(save_button)
	
	var separator = VSeparator.new()
	toolbar.add_child(separator)
	
	# 测试按钮
	var test_button = Button.new()
	test_button.text = "Test in Scene"
	test_button.pressed.connect(_on_test_pressed)
	toolbar.add_child(test_button)
	
	return toolbar

func _create_effect_config() -> Control:
	## 创建效果配置
	var config = VBoxContainer.new()
	config.name = "EffectConfig"
	
	# 效果名称
	var name_hbox = HBoxContainer.new()
	var name_label = Label.new()
	name_label.text = "Name:"
	name_label.custom_minimum_size.x = 80
	name_hbox.add_child(name_label)
	
	var name_edit = LineEdit.new()
	name_edit.name = "EffectName"
	name_edit.text = "new_effect"
	name_hbox.add_child(name_edit)
	config.add_child(name_hbox)
	
	# Target Type
	var target_hbox = HBoxContainer.new()
	var target_label = Label.new()
	target_label.text = "Target:"
	target_label.custom_minimum_size.x = 80
	target_hbox.add_child(target_label)
	
	var target_option = OptionButton.new()
	target_option.name = "TargetType"
	target_option.add_item("Position", 0)
	target_option.add_item("Scale", 1)
	target_option.add_item("Rotation", 2)
	target_option.add_item("Modulate", 3)
	target_hbox.add_child(target_option)
	config.add_child(target_hbox)
	
	# Tweener Type
	var tweener_hbox = HBoxContainer.new()
	var tweener_label = Label.new()
	tweener_label.text = "Tweener:"
	tweener_label.custom_minimum_size.x = 80
	tweener_hbox.add_child(tweener_label)
	
	var tweener_option = OptionButton.new()
	tweener_option.name = "TweenerType"
	tweener_option.add_item("Linear", 0)
	tweener_option.add_item("Elastic", 1)
	tweener_option.add_item("Shake", 2)
	tweener_option.add_item("Flash", 3)
	tweener_option.add_item("Color", 4)
	tweener_hbox.add_child(tweener_option)
	config.add_child(tweener_hbox)
	
	# Duration
	var duration_hbox = HBoxContainer.new()
	var duration_label = Label.new()
	duration_label.text = "Duration:"
	duration_label.custom_minimum_size.x = 80
	duration_hbox.add_child(duration_label)
	
	var duration_slider = HSlider.new()
	duration_slider.name = "Duration"
	duration_slider.min_value = 0.01
	duration_slider.max_value = 2.0
	duration_slider.value = 0.3
	duration_slider.step = 0.01
	duration_slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	duration_hbox.add_child(duration_slider)
	
	var duration_value = Label.new()
	duration_value.text = "0.30"
	duration_value.custom_minimum_size.x = 40
	duration_hbox.add_child(duration_value)
	
	duration_slider.value_changed.connect(func(value): duration_value.text = "%.2f" % value)
	config.add_child(duration_hbox)
	
	# Intensity
	var intensity_hbox = HBoxContainer.new()
	var intensity_label = Label.new()
	intensity_label.text = "Intensity:"
	intensity_label.custom_minimum_size.x = 80
	intensity_hbox.add_child(intensity_label)
	
	var intensity_slider = HSlider.new()
	intensity_slider.name = "Intensity"
	intensity_slider.min_value = 0.0
	intensity_slider.max_value = 3.0
	intensity_slider.value = 1.0
	intensity_slider.step = 0.1
	intensity_slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	intensity_hbox.add_child(intensity_slider)
	
	var intensity_value = Label.new()
	intensity_value.text = "1.00"
	intensity_value.custom_minimum_size.x = 40
	intensity_hbox.add_child(intensity_value)
	
	intensity_slider.value_changed.connect(func(value): intensity_value.text = "%.2f" % value)
	config.add_child(intensity_hbox)
	
	return config

func _create_status_bar() -> Control:
	## 创建状态栏
	var status_bar = HBoxContainer.new()
	
	_status_label = Label.new()
	_status_label.text = "Ready"
	status_bar.add_child(_status_label)
	
	return status_bar

# ===== 回调方法 =====

func _on_new_pressed() -> void:
	## 新建效果
	_current_effect = GFFCurvedBase.new()
	_update_status("New effect created")

func _on_load_pressed() -> void:
	## 加载效果
	var dialog = EditorFileDialog.new()
	dialog.file_mode = EditorFileDialog.FILE_MODE_OPEN_FILE
	dialog.add_filter("*.tres", "Resource files")
	dialog.access = EditorFileDialog.ACCESS_RESOURCES
	dialog.title = "Load Effect"
	dialog.file_selected.connect(_on_effect_file_selected)
	EditorInterface.get_base_control().add_child(dialog)
	dialog.popup_centered(Vector2i(600, 400))

func _on_effect_file_selected(path: String) -> void:
	## 效果文件选择完成
	var effect = load(path)
	if effect is GFFCurvedBase:
		_current_effect = effect
		_update_status("Loaded: " + path)
	else:
		_update_status("Error: Not a valid effect file")

func _on_save_pressed() -> void:
	## 保存效果
	if not _current_effect:
		_update_status("Error: No effect to save")
		return
	
	# 从UI读取配置
	_update_effect_from_ui()
	
	var dialog = EditorFileDialog.new()
	dialog.file_mode = EditorFileDialog.FILE_MODE_SAVE_FILE
	dialog.add_filter("*.tres", "Resource files")
	dialog.access = EditorFileDialog.ACCESS_RESOURCES
	dialog.title = "Save Effect"
	dialog.file_selected.connect(_on_save_file_selected)
	EditorInterface.get_base_control().add_child(dialog)
	dialog.popup_centered(Vector2i(600, 400))

func _on_save_file_selected(path: String) -> void:
	## 保存文件选择完成
	if _current_effect:
		var error = ResourceSaver.save(_current_effect, path)
		if error == OK:
			_update_status("Saved: " + path)
		else:
			_update_status("Error: failed to save")

func _on_test_pressed() -> void:
	## 测试效果 - 打开测试场景
	var scene_path = "res://addons/game_feel_flow/editor/test_scene_2d.tscn"
	EditorInterface.open_scene_from_path(scene_path)
	_update_status("Opened test scene")

# ===== 辅助方法 =====

func _update_status(message: String) -> void:
	## 更新状态栏
	if _status_label:
		_status_label.text = message

func _update_effect_from_ui() -> void:
	## 从UI更新效果配置
	if not _current_effect:
		_current_effect = GFFCurvedBase.new()
	
	var config = _editor_dock.get_node("EffectConfig")
	if not config:
		return
	
	for child in config.get_children():
		if child is HBoxContainer:
			for subchild in child.get_children():
				if subchild is LineEdit and subchild.name == "EffectName":
					_current_effect.resource_name = subchild.text
				elif subchild is OptionButton:
					if subchild.name == "TargetType":
						_current_effect.target_type = subchild.selected as GFFCurvedBase.TargetType
					elif subchild.name == "TweenerType":
						_current_effect.tweener_type = subchild.selected as GFFCurvedBase.TweenerType
