@tool
class_name GFFDragHandle
extends Control

## Inspector drag sort handle
## Use _gui_input to capture mouse events

signal drag_started
signal drag_position_changed(global_pos: Vector2)
signal drag_finished(cancelled: bool)

var _dragging := false

func _ready() -> void:
	custom_minimum_size = Vector2(24, 28)
	mouse_default_cursor_shape = Control.CURSOR_MOVE
	mouse_filter = Control.MOUSE_FILTER_STOP
	focus_mode = Control.FOCUS_ALL

func _draw() -> void:
	var color = Color(0.5, 0.5, 0.5, 0.7) if not _dragging else Color(0.9, 0.7, 0.3, 1.0)
	var center = size * 0.5
	for y_offset in [-4.0, 0.0, 4.0]:
		draw_line(
			Vector2(center.x - 6, center.y + y_offset),
			Vector2(center.x + 6, center.y + y_offset),
			color,
			1.5,
			true
		)

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mb = event as InputEventMouseButton
		if mb.button_index == MOUSE_BUTTON_LEFT:
			if mb.pressed and not _dragging:
				print("GFFDragHandle: drag started")
				_dragging = true
				grab_focus()
				drag_started.emit()
				accept_event()
			elif not mb.pressed and _dragging:
				print("GFFDragHandle: drag finished")
				_dragging = false
				drag_finished.emit(false)
				accept_event()
			
	elif event is InputEventMouseMotion and _dragging:
		var global_pos = get_global_mouse_position()
		print("GFFDragHandle: position changed, global_pos=", global_pos)
		drag_position_changed.emit(global_pos)
		accept_event()
		
	elif event is InputEventKey and _dragging:
		var key = event as InputEventKey
		if key.pressed and key.keycode == KEY_ESCAPE:
			print("GFFDragHandle: cancelled by escape")
			_dragging = false
			drag_finished.emit(true)
			accept_event()
