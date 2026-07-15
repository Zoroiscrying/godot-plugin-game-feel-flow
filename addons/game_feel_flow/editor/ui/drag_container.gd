@tool
extends Container

## Drag-reorder container inspired by ProtonScatter's DragContainer.
## Children are laid out vertically like a VBoxContainer and can be reordered
## by dragging them from their drag handle. The dragged child itself must
## implement _get_drag_data(at_position) and return itself when the mouse is
## over the handle area.

signal child_moved(last_index: int, new_index: int)

var _separation: int = 0
var _drag_offset: Vector2 = Vector2.ZERO
var _dragged_child: Control = null
var _old_index: int = 0
var _new_index: int = 0
var _map: Array[float] = []


func _ready() -> void:
	_separation = get_theme_constant("separation", "VBoxContainer") + 2


func _notification(what: int) -> void:
	if what == NOTIFICATION_SORT_CHILDREN or what == NOTIFICATION_RESIZED:
		_update_layout()


func _can_drop_data(at_position: Vector2, data: Variant) -> bool:
	if data is not Control or data.get_parent() != self:
		return false

	# Drag just started
	if not _dragged_child:
		_dragged_child = data
		_drag_offset = at_position - data.position
		_old_index = data.get_index()
		_new_index = _old_index

	# Dragged control follows the mouse along the Y axis only
	data.position.y = at_position.y - _drag_offset.y

	# Check if the children order should be changed
	var computed_index := 0
	for pos_y in _map:
		if pos_y > data.position.y - 16.0:
			break
		computed_index += 1

	computed_index = clampi(computed_index, 0, get_child_count() - 1)

	if computed_index != data.get_index():
		move_child(data, computed_index)
		_new_index = computed_index

	return true


func _drop_data(at_position: Vector2, data: Variant) -> void:
	_drag_offset = Vector2.ZERO
	_dragged_child = null
	_update_layout()

	if _old_index != _new_index:
		child_moved.emit(_old_index, _new_index)


# Detects if the user drops the child outside the container and treats it as
# if the drop happened at the current position.
func _unhandled_input(event: InputEvent) -> void:
	if not _dragged_child:
		return

	if event is InputEventMouseButton and not event.pressed:
		_drop_data(_dragged_child.position, _dragged_child)


func _update_layout() -> void:
	_map.clear()
	var offset := Vector2.ZERO

	for c in get_children():
		if c is Control:
			_map.push_back(offset.y)
			var child_min_size: Vector2 = c.get_combined_minimum_size()
			var possible_space: Rect2 = Rect2(offset, Vector2(size.x, child_min_size.y))

			if c != _dragged_child:
				fit_child_in_rect(c, possible_space)

			offset.y += c.size.y + _separation

	custom_minimum_size.y = maxf(0.0, offset.y - _separation)
