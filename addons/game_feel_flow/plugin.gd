@tool
extends EditorPlugin

## Game Feel Flow Plugin

const AUTOLOAD_NAME = "GameFeelFlow"
const AUTOLOAD_PATH = "res://addons/game_feel_flow/core/game_feel_flow.gd"

var _inspector_plugin: EditorInspectorPlugin = null
var _preview_window: Window = null

func _enter_tree() -> void:
	# Add autoload singleton
	add_autoload_singleton(AUTOLOAD_NAME, AUTOLOAD_PATH)
	
	# 注册Inspector插件
	_inspector_plugin = preload("res://addons/game_feel_flow/editor/gff_player_inspector.gd").new()
	add_inspector_plugin(_inspector_plugin)
	
	# 添加工具菜单
	add_tool_menu_item("Game Feel Flow Preview", _show_preview_window)
	
	print("Game Feel Flow: Plugin enabled")

func _exit_tree() -> void:
	# Remove autoload singleton
	remove_autoload_singleton(AUTOLOAD_NAME)
	
	# 清理Inspector插件
	if _inspector_plugin:
		remove_inspector_plugin(_inspector_plugin)
		_inspector_plugin = null
	
	# 清理预览窗口
	if _preview_window:
		_preview_window.queue_free()
		_preview_window = null
	
	remove_tool_menu_item("Game Feel Flow Preview")
	
	print("Game Feel Flow: Plugin disabled")

func _show_preview_window() -> void:
	## 显示预览窗口
	if _preview_window:
		_preview_window.show()
		_preview_window.grab_focus()
		return
	
	# 创建预览窗口
	_preview_window = Window.new()
	_preview_window.title = "Game Feel Flow Preview"
	_preview_window.size = Vector2i(800, 600)
	_preview_window.popup_centered()
	
	# 创建预览控制
	var preview_control = _create_preview_control()
	_preview_window.add_child(preview_control)
	
	EditorInterface.get_base_control().add_child(_preview_window)

func _create_preview_control() -> Control:
	## 创建预览控制界面
	var main_container = VBoxContainer.new()
	main_container.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	
	# 工具栏
	var toolbar = _create_toolbar()
	main_container.add_child(toolbar)
	
	# 内容区域
	var content = HSplitContainer.new()
	content.size_flags_vertical = Control.SIZE_EXPAND_FILL
	
	# 左侧：效果列表
	var left_panel = _create_effect_list_panel()
	content.add_child(left_panel)
	
	# 右侧：预览区域
	var right_panel = _create_preview_panel()
	content.add_child(right_panel)
	
	main_container.add_child(content)
	
	# 状态栏
	var status_bar = _create_status_bar()
	main_container.add_child(status_bar)
	
	return main_container

func _create_toolbar() -> Control:
	## 创建工具栏
	var toolbar = HBoxContainer.new()
	
	# 播放按钮
	var play_button = Button.new()
	play_button.text = "Play"
	play_button.pressed.connect(_on_play_pressed)
	toolbar.add_child(play_button)
	
	# 停止按钮
	var stop_button = Button.new()
	stop_button.text = "Stop"
	stop_button.pressed.connect(_on_stop_pressed)
	toolbar.add_child(stop_button)
	
	# 重置按钮
	var reset_button = Button.new()
	reset_button.text = "Reset"
	reset_button.pressed.connect(_on_reset_pressed)
	toolbar.add_child(reset_button)
	
	return toolbar

func _create_effect_list_panel() -> Control:
	## 创建效果列表面板
	var panel = VBoxContainer.new()
	
	var label = Label.new()
	label.text = "Effects"
	label.add_theme_font_size_override("font_size", 16)
	panel.add_child(label)
	
	# 效果列表
	var list = ItemList.new()
	list.custom_minimum_size = Vector2(200, 0)
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
	
	panel.add_child(list)
	
	return panel

func _create_preview_panel() -> Control:
	## 创建预览面板
	var panel = VBoxContainer.new()
	
	var label = Label.new()
	label.text = "Preview"
	label.add_theme_font_size_override("font_size", 16)
	panel.add_child(label)
	
	# 预览容器
	var preview_container = SubViewportContainer.new()
	preview_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	preview_container.stretch = true
	
	var viewport = SubViewport.new()
	preview_container.add_child(viewport)
	
	# 预览目标
	var target = ColorRect.new()
	target.size = Vector2(100, 100)
	target.color = Color.WHITE
	target.position = Vector2(150, 150)
	viewport.add_child(target)
	
	panel.add_child(preview_container)
	
	# 参数面板
	var param_panel = VBoxContainer.new()
	param_panel.name = "ParamPanel"
	panel.add_child(param_panel)
	
	return panel

func _create_status_bar() -> Control:
	## 创建状态栏
	var status_bar = HBoxContainer.new()
	
	var status_label = Label.new()
	status_label.text = "Ready"
	status_bar.add_child(status_label)
	
	var fps_label = Label.new()
	fps_label.text = "FPS: 60"
	fps_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	fps_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	status_bar.add_child(fps_label)
	
	return status_bar

func _on_play_pressed() -> void:
	## 播放按钮点击
	print("GFF Editor: Play pressed")

func _on_stop_pressed() -> void:
	## 停止按钮点击
	print("GFF Editor: Stop pressed")

func _on_reset_pressed() -> void:
	## 重置按钮点击
	print("GFF Editor: Reset pressed")
