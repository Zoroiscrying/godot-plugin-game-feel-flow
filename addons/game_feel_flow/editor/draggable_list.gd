@tool
class_name GFFDraggableList
extends VBoxContainer

## Draggable effect list container
## Supports can_drop_data / drop_data for receiving drag data

func can_drop_data(position: Vector2, data: Variant) -> bool:
	return data is Dictionary and data.has("from_index")

func drop_data(position: Vector2, data: Variant) -> void:
	if not (data is Dictionary and data.has("from_index")):
		return
	
	var from_idx = data["from_index"] as int
	var to_idx = get_drop_index(position)
	
	var plugin = get_meta("inspector_plugin")
	if plugin and plugin.has_method("_handle_drop"):
		plugin.call("_handle_drop", from_idx, to_idx)

func get_drop_index(position: Vector2) -> int:
	var children = get_children()
	for i in range(children.size()):
		var child = children[i]
		if position.y < child.position.y + child.size.y / 2.0:
			return i
	return children.size()
