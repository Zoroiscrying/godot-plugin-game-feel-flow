@tool
extends EditorInspectorPlugin

## GFFPlayer Inspector Plugin
##
## 为GFFPlayer提供自定义Inspector界面

var _player: GFFPlayer = null

func _can_begin(object: Object) -> bool:
	return object is GFFPlayer

func _parse_begin(object: Object) -> void:
	_player = object as GFFPlayer

func _parse_category(object: Object, category: String) -> void:
	if category != "GFFPlayer":
		return
	
	# 添加预设管理界面
	var preset_control = _create_preset_control()
	add_custom_control(preset_control)
	
	# 添加组合效果列表
	var combo_list_control = _create_combo_list_control()
	add_custom_control(combo_list_control)

func _create_preset_control() -> Control:
	## 创建预设管理控件
	var vbox = VBoxContainer.new()
	
	var label = Label.new()
	label.text = "Combo Presets"
	label.add_theme_font_size_override("font_size", 16)
	vbox.add_child(label)
	
	# 加载预设按钮
	var load_button = Button.new()
	load_button.text = "Load Presets from Directory"
	load_button.pressed.connect(_on_load_presets_pressed)
	vbox.add_child(load_button)
	
	# 保存当前配置为预设
	var save_button = Button.new()
	save_button.text = "Save Current as Preset"
	save_button.pressed.connect(_on_save_preset_pressed)
	vbox.add_child(save_button)
	
	return vbox

func _create_combo_list_control() -> Control:
	## 创建组合效果列表控件
	var vbox = VBoxContainer.new()
	
	var label = Label.new()
	label.text = "Available Combos"
	label.add_theme_font_size_override("font_size", 16)
	vbox.add_child(label)
	
	# 组合效果列表
	var list = ItemList.new()
	list.custom_minimum_size = Vector2(0, 200)
	
	if _player:
		var combo_names = _player.get_combo_names()
		for combo_name in combo_names:
			list.add_item(combo_name)
	
	vbox.add_child(list)
	
	# 播放按钮
	var play_button = Button.new()
	play_button.text = "Play Selected"
	play_button.pressed.connect(_on_play_selected_pressed.bind(list))
	vbox.add_child(play_button)
	
	return vbox

func _on_load_presets_pressed() -> void:
	## 加载预设
	if _player:
		_player._load_presets()
		_player._build_combo_dictionary()
		print("GFFPlayer: Presets loaded")

func _on_save_preset_pressed() -> void:
	## 保存当前配置为预设
	if _player:
		var dialog = EditorFileDialog.new()
		dialog.file_mode = EditorFileDialog.FILE_MODE_SAVE_FILE
		dialog.add_filter("*.tres", "Resource files")
		dialog.access = EditorFileDialog.ACCESS_RESOURCES
		dialog.title = "Save Combo Preset"
		dialog.file_selected.connect(_on_preset_file_selected)
		EditorInterface.get_base_control().add_child(dialog)
		dialog.popup_centered(Vector2i(600, 400))

func _on_preset_file_selected(path: String) -> void:
	## 预设文件选择完成
	if _player:
		var combo = GFFCombo.new()
		combo.label = "custom_combo"
		_player.save_combo_as_preset(combo, path)

func _on_play_selected_pressed(list: ItemList) -> void:
	## 播放选中的组合效果
	if _player and list.get_selected_items().size() > 0:
		var index = list.get_selected_items()[0]
		var combo_name = list.get_item_text(index)
		_player.play(combo_name)
