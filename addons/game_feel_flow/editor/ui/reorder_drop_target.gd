@tool
extends VBoxContainer

## Container receiving drag-and-drop reorder placement signals

signal item_dropped(data: Dictionary, drop_index: int)

func _can_drop_data(at_position: Vector2, data: Variant) -> bool:
	return data is Dictionary and data.has("type")

func _drop_data(at_position: Vector2, data: Variant) -> void:
	if not data is Dictionary:
		return
	var drop_index := 0
	for i in range(get_child_count()):
		var child = get_child(i)
		if child.get_global_rect().position.y + child.size.y * 0.5 > at_position.y:
			break
		drop_index = i + 1
	item_dropped.emit(data, drop_index)
