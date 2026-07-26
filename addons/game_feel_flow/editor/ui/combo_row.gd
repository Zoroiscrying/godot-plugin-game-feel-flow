@tool
extends PanelContainer

## Single Combo row (Unity Feel style)

signal selected
signal key_renamed(old_key: String, new_key: String)
signal deleted
signal duplicated
signal save_as_project_requested
signal set_default_requested

@export var combo: GFFCombo = null:
	set(v):
		combo = v
		_refresh()

@export var combo_key: String = "":
	set(v):
		combo_key = v
		_refresh()

@export var is_selected: bool = false:
	set(v):
		is_selected = v
		_update_style()

@export var is_default: bool = false:
	set(v):
		is_default = v
		_update_style()
		_refresh()

var _key_label: Label
var _rename_edit: LineEdit
var _select_btn: Button
var _drag_handle: TextureRect = null
var _default_btn: Button = null
var _is_editing: bool = false

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_PASS
	_refresh()

const ROW_HEIGHT := 32

func _get_drag_data(at_position: Vector2) -> Variant:
	if _drag_handle == null:
		return null
	var handle_rect := Rect2(_drag_handle.global_position - global_position, _drag_handle.size)
	if not handle_rect.has_point(at_position):
		return null
	var preview := Label.new()
	preview.text = combo_key
	set_drag_preview(preview)
	return self

func _refresh() -> void:
	for child in get_children():
		child.queue_free()

	custom_minimum_size = Vector2(0, ROW_HEIGHT)

	var row = HBoxContainer.new()
	row.add_theme_constant_override("separation", 6)
	row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.size_flags_vertical = Control.SIZE_EXPAND_FILL
	add_child(row)

	# Drag handle
	var drag = TextureRect.new()
	drag.texture = _get_icon("TripleBar")
	drag.stretch_mode = TextureRect.STRETCH_KEEP_CENTERED
	drag.custom_minimum_size = Vector2(22, ROW_HEIGHT)
	drag.tooltip_text = "Drag to reorder"
	drag.mouse_default_cursor_shape = Control.CURSOR_DRAG
	drag.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	row.add_child(drag)
	_drag_handle = drag

	# Default indicator / toggle button
	_default_btn = Button.new()
	_default_btn.text = "★" if is_default else "☆"
	_default_btn.flat = true
	_default_btn.custom_minimum_size = Vector2(ROW_HEIGHT, ROW_HEIGHT)
	_default_btn.tooltip_text = "Set as default combo" if not is_default else "This is the default combo"
	_default_btn.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	_default_btn.add_theme_font_size_override("font_size", 18)
	if is_default:
		_default_btn.add_theme_color_override("font_color", Color(1.0, 0.85, 0.2))
	_default_btn.pressed.connect(func(): set_default_requested.emit())
	row.add_child(_default_btn)

	# Select button
	_select_btn = Button.new()
	_select_btn.text = _get_display_text()
	_select_btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
	_select_btn.flat = true
	_select_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_select_btn.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	_select_btn.pressed.connect(func(): selected.emit())
	row.add_child(_select_btn)

	# Rename inline (hidden by default)
	_rename_edit = LineEdit.new()
	_rename_edit.text = combo_key
	_rename_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_rename_edit.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	_rename_edit.visible = false
	_rename_edit.focus_exited.connect(_on_rename_finished)
	_rename_edit.gui_input.connect(_on_rename_input)
	row.add_child(_rename_edit)

	# Duplicate button
	var dup_btn = Button.new()
	dup_btn.icon = _get_icon("Duplicate")
	dup_btn.flat = true
	dup_btn.custom_minimum_size = Vector2(ROW_HEIGHT, ROW_HEIGHT)
	dup_btn.tooltip_text = "Duplicate combo"
	dup_btn.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	dup_btn.pressed.connect(func(): duplicated.emit())
	row.add_child(dup_btn)

	# Save as project combo
	var save_btn = Button.new()
	save_btn.icon = _get_icon("Save")
	save_btn.flat = true
	save_btn.custom_minimum_size = Vector2(ROW_HEIGHT, ROW_HEIGHT)
	save_btn.tooltip_text = "Save as Project Combo (Project Settings → Game Feel Flow → save_path)"
	save_btn.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	save_btn.pressed.connect(func(): save_as_project_requested.emit())
	row.add_child(save_btn)

	# Rename button
	var rename_btn = Button.new()
	rename_btn.icon = _get_icon("Edit")
	rename_btn.flat = true
	rename_btn.custom_minimum_size = Vector2(ROW_HEIGHT, ROW_HEIGHT)
	rename_btn.tooltip_text = "Rename"
	rename_btn.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	rename_btn.pressed.connect(_start_rename)
	row.add_child(rename_btn)

	# Delete button
	var del_btn = Button.new()
	del_btn.icon = _get_icon("Remove")
	del_btn.flat = true
	del_btn.custom_minimum_size = Vector2(ROW_HEIGHT, ROW_HEIGHT)
	del_btn.tooltip_text = "Delete"
	del_btn.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	del_btn.add_theme_color_override("icon_normal_color", Color(0.9, 0.3, 0.3))
	del_btn.pressed.connect(func(): deleted.emit())
	row.add_child(del_btn)

func _get_display_text() -> String:
	var text := combo_key
	if combo:
		var count := combo.entries.size()
		var duration := _get_total_duration()
		text = "%s  (%d effect%s, %.2fs)" % [combo_key, count, "s" if count != 1 else "", duration]
	return text

func _get_total_duration() -> float:
	if combo == null:
		return 0.0
	var max_end := 0.0
	for entry in combo.entries:
		if entry:
			max_end = maxf(max_end, entry.start_time + entry.duration)
	return max_end

func _update_style() -> void:
	var style = StyleBoxFlat.new()
	if is_default:
		style.bg_color = Color(0.30, 0.26, 0.14)
		style.border_width_left = 3
		style.border_color = Color(1.0, 0.85, 0.2)
	elif is_selected:
		style.bg_color = Color(0.24, 0.28, 0.36)
	else:
		style.bg_color = Color(0.17, 0.18, 0.20)
	style.border_width_bottom = 1
	style.border_color = Color(0.10, 0.10, 0.12)
	style.content_margin_left = 6
	style.content_margin_right = 6
	style.content_margin_top = 2
	style.content_margin_bottom = 2
	add_theme_stylebox_override("panel", style)

	if _default_btn:
		_default_btn.text = "★" if is_default else "☆"
		_default_btn.tooltip_text = "This is the default combo" if is_default else "Set as default combo"
		if is_default:
			_default_btn.add_theme_color_override("font_color", Color(1.0, 0.85, 0.2))
		else:
			_default_btn.remove_theme_color_override("font_color")

func _start_rename() -> void:
	_is_editing = true
	_select_btn.visible = false
	_rename_edit.visible = true
	_rename_edit.text = combo_key
	_rename_edit.grab_focus()
	_rename_edit.select_all()

func _on_rename_finished() -> void:
	if not _is_editing:
		return
	_is_editing = false
	var new_key = _rename_edit.text.strip_edges()
	_select_btn.visible = true
	_rename_edit.visible = false
	if new_key != combo_key and not new_key.is_empty():
		key_renamed.emit(combo_key, new_key)

func _on_rename_input(event: InputEvent) -> void:
	if event is InputEventKey and event.keycode == KEY_ESCAPE and event.pressed:
		_is_editing = false
		_select_btn.visible = true
		_rename_edit.visible = false

func _get_icon(name: String) -> Texture2D:
	if Engine.is_editor_hint():
		return EditorInterface.get_editor_theme().get_icon(name, "EditorIcons")
	return null
