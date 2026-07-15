@tool
extends Control

## Inline Curve editor (referencing ProtonScatter's CurvePanel)

signal curve_changed

@export var grid_color := Color(1, 1, 1, 0.2)
@export var grid_color_sub := Color(1, 1, 1, 0.1)
@export var curve_color := Color(1, 1, 1, 0.9)
@export var point_color := Color.WHITE
@export var selected_point_color := Color.ORANGE
@export var point_radius := 4.0
@export var text_color := Color(0.9, 0.9, 0.9)
@export var columns := 4
@export var rows := 2

var curve: Curve:
	set(v):
		curve = v
		queue_redraw()

var _hover_point := -1:
	set(v):
		if v != _hover_point:
			_hover_point = v
			queue_redraw()

var _selected_point := -1:
	set(v):
		if v != _selected_point:
			_selected_point = v
			queue_redraw()

var _selected_tangent := -1:
	set(v):
		if v != _selected_tangent:
			_selected_tangent = v
			queue_redraw()

var _dragging := false
var _hover_radius_sq := 250.0
var _tangents_length := 30.0
var _font: Font

func _ready() -> void:
	custom_minimum_size = Vector2(0, 120)
	if Engine.is_editor_hint():
		_font = EditorInterface.get_editor_theme().get_font("main", "EditorFonts")
	else:
		_font = ThemeDB.fallback_font
	queue_redraw()
	resized.connect(queue_redraw)

func _gui_input(event: InputEvent) -> void:
	if curve == null:
		return

	if event is InputEventKey and event.pressed and event.keycode == KEY_DELETE:
		if _selected_point != -1:
			remove_point(_selected_point)

	elif event is InputEventMouseButton:
		if event.double_click and event.button_index == MOUSE_BUTTON_LEFT:
			add_point(_to_curve_space(event.position))

		elif event.pressed and event.button_index == MOUSE_BUTTON_MIDDLE:
			var i := get_point_at(event.position)
			if i != -1:
				remove_point(i)

		elif event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			_selected_tangent = get_tangent_at(event.position)
			if _selected_tangent == -1:
				_selected_point = get_point_at(event.position)
			_dragging = _selected_point != -1
			queue_redraw()

		elif _dragging and not event.pressed:
			_dragging = false
			curve_changed.emit()

	elif event is InputEventMouseMotion:
		if _dragging:
			_drag(event)
		else:
			_hover_point = get_point_at(event.position)

func add_point(pos: Vector2) -> void:
	if curve == null:
		return
	pos.y = clampf(pos.y, 0.0, 1.0)
	curve.add_point(pos)
	queue_redraw()
	curve_changed.emit()

func remove_point(idx: int) -> void:
	if curve == null:
		return
	if _selected_point == idx:
		_selected_point = -1
	if _hover_point == idx:
		_hover_point = -1
	curve.remove_point(idx)
	queue_redraw()
	curve_changed.emit()

func get_point_at(pos: Vector2) -> int:
	if curve == null:
		return -1
	for i in range(curve.get_point_count()):
		var p := _to_view_space(curve.get_point_position(i))
		if p.distance_squared_to(pos) <= _hover_radius_sq:
			return i
	return -1

func get_tangent_at(pos: Vector2) -> int:
	if curve == null or _selected_point < 0:
		return -1
	if _selected_point != 0:
		var cp := _get_tangent_view_pos(_selected_point, 0)
		if cp.distance_squared_to(pos) <= _hover_radius_sq:
			return 0
	if _selected_point != curve.get_point_count() - 1:
		var cp := _get_tangent_view_pos(_selected_point, 1)
		if cp.distance_squared_to(pos) <= _hover_radius_sq:
			return 1
	return -1

func _drag(event: InputEventMouseMotion) -> void:
	if curve == null or _selected_point < 0:
		return
	var snap_threshold := 0.0
	if event.ctrl_pressed:
		snap_threshold = 0.025 if event.shift_pressed else 0.1

	if _selected_tangent == -1:
		var point_pos := _to_curve_space(event.position).snapped(Vector2(snap_threshold, snap_threshold))
		var i := curve.set_point_offset(_selected_point, point_pos.x)
		_selected_point = i
		_hover_point = i
		point_pos.y = clampf(point_pos.y, 0.0, 1.0)
		curve.set_point_value(_selected_point, point_pos.y)
	else:
		var point_pos := curve.get_point_position(_selected_point)
		var control_pos := _to_curve_space(event.position).snapped(Vector2(snap_threshold, snap_threshold))
		var dir := (control_pos - point_pos).normalized()
		var tangent := 1.0 if is_zero_approx(dir.x) else dir.y / dir.x
		var link := not event.shift_pressed
		if _selected_tangent == 0:
			curve.set_point_left_tangent(_selected_point, tangent)
			if link and _selected_point != curve.get_point_count() - 1 and curve.get_point_right_mode(_selected_point) != Curve.TANGENT_LINEAR:
				curve.set_point_right_tangent(_selected_point, tangent)
		else:
			curve.set_point_right_tangent(_selected_point, tangent)
			if link and _selected_point != 0 and curve.get_point_left_mode(_selected_point) != Curve.TANGENT_LINEAR:
				curve.set_point_left_tangent(_selected_point, tangent)
	queue_redraw()

func _draw() -> void:
	if curve == null:
		return
	var h := _font.get_height() if _font else 16
	var min_inner := Vector2(h, size.y - h)
	var max_inner := Vector2(size.x - h, h)
	var width := max_inner.x - min_inner.x
	var height := max_inner.y - min_inner.y

	_draw_grid(min_inner, max_inner, width, height, h)
	_draw_curve(min_inner, max_inner, width, height)
	_draw_points()
	_draw_tangents()

func _draw_grid(min_inner: Vector2, max_inner: Vector2, width: float, height: float, h: float) -> void:
	draw_line(Vector2(0, max_inner.y), Vector2(size.x, max_inner.y), grid_color)
	draw_line(Vector2(0, min_inner.y), Vector2(size.x, min_inner.y), grid_color)
	draw_line(Vector2(min_inner.x, 0), Vector2(min_inner.x, size.y), grid_color)
	draw_line(Vector2(max_inner.x, 0), Vector2(max_inner.x, size.y), grid_color)

	var x_offset := 1.0 / columns
	for i in range(columns + 1):
		var x := width * (i * x_offset) + min_inner.x
		draw_line(Vector2(x, 0), Vector2(x, size.y), grid_color_sub)
		draw_string(_font, Vector2(x + 4, h - 4), str(snappedf(i * x_offset, 0.01)), HORIZONTAL_ALIGNMENT_LEFT, -1, 12, text_color)

	var y_offset := 1.0 / rows
	for i in range(rows + 1):
		var y := height * (i * y_offset) + min_inner.y
		draw_line(Vector2(0, y), Vector2(size.x, y), grid_color_sub)
		draw_string(_font, Vector2(min_inner.x + 4, y - 4), str(snappedf(i * (1.0 / rows), 0.01)), HORIZONTAL_ALIGNMENT_LEFT, -1, 12, text_color)

func _draw_curve(min_inner: Vector2, max_inner: Vector2, width: float, height: float) -> void:
	var steps := 100
	var x_step := width / steps
	var a := curve.sample(0.0)
	var a_y := remap(a, 0.0, 1.0, min_inner.y, max_inner.y)
	for i in range(steps - 1):
		var x := (i + 1) / float(steps)
		var b := curve.sample(x)
		var b_x := min_inner.x + x_step * (i + 1)
		var b_y := remap(b, 0.0, 1.0, min_inner.y, max_inner.y)
		draw_line(Vector2(min_inner.x + x_step * i, a_y), Vector2(b_x, b_y), curve_color, 2.0)
		a_y = b_y

func _draw_points() -> void:
	if curve == null:
		return
	for i in range(curve.get_point_count()):
		var pos := _to_view_space(curve.get_point_position(i))
		var color := selected_point_color if i == _selected_point else point_color
		draw_circle(pos, point_radius, color)
		if _hover_point == i:
			draw_arc(pos, point_radius + 4.0, 0.0, TAU, 12, point_color, 1.0, true)

func _draw_tangents() -> void:
	if curve == null or _selected_point < 0:
		return
	var i := _selected_point
	var pos := _to_view_space(curve.get_point_position(i))
	if i != 0:
		var cp := _get_tangent_view_pos(i, 0)
		draw_line(pos, cp, selected_point_color)
		draw_rect(Rect2(cp, Vector2.ONE).grow(2), selected_point_color)
	if i != curve.get_point_count() - 1:
		var cp := _get_tangent_view_pos(i, 1)
		draw_line(pos, cp, selected_point_color)
		draw_rect(Rect2(cp, Vector2.ONE).grow(2), selected_point_color)

func _to_view_space(pos: Vector2) -> Vector2:
	var h := _font.get_height() if _font else 16
	return Vector2(
		remap(pos.x, 0.0, 1.0, h, size.x - h),
		remap(pos.y, 0.0, 1.0, size.y - h, h)
	)

func _to_curve_space(pos: Vector2) -> Vector2:
	var h := _font.get_height() if _font else 16
	return Vector2(
		remap(pos.x, h, size.x - h, 0.0, 1.0),
		remap(pos.y, size.y - h, h, 0.0, 1.0)
	)

func _get_tangent_view_pos(i: int, tangent: int) -> Vector2:
	var dir := Vector2(-1.0, -curve.get_point_left_tangent(i)) if tangent == 0 else Vector2(1.0, curve.get_point_right_tangent(i))
	var point_pos := _to_view_space(curve.get_point_position(i))
	var control_pos := _to_view_space(curve.get_point_position(i) + dir)
	return point_pos + _tangents_length * (control_pos - point_pos).normalized()
