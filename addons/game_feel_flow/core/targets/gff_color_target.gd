@tool
class_name GFFColorTarget
extends GFFTarget

@export var target_color: Color = Color.WHITE

func get_value_type() -> GFFValueType.Value:
	return GFFValueType.Value.COLOR

func get_initial_value(node: Node) -> Variant:
	if node is CanvasItem:
		return node.modulate
	return Color.WHITE

func get_end_value(node: Node, intensity: float) -> Variant:
	return target_color * intensity

func apply_value(node: Node, value: Variant) -> void:
	if node is CanvasItem:
		node.modulate = value

func get_target_name() -> String:
	return "Color"
