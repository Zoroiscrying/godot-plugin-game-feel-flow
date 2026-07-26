@tool
class_name GFFAlphaTarget
extends GFFTarget

@export var target_alpha: float = 1.0

func get_value_type() -> GFFValueType.Value:
	return GFFValueType.Value.FLOAT

func get_initial_value(node: Node) -> Variant:
	if node is CanvasItem:
		return node.modulate.a
	return 1.0

func get_end_value(node: Node, intensity: float) -> Variant:
	return clampf(target_alpha * intensity, 0.0, 1.0)

func apply_value(node: Node, value: Variant) -> void:
	if node is CanvasItem:
		var c: Color = node.modulate
		c.a = clampf(value, 0.0, 1.0)
		node.modulate = c

func apply_params(params: GFFParams) -> void:
	if params == null:
		return
	var v: Variant = params.get_variant("target_alpha", null)
	if v != null:
		target_alpha = float(v)

func get_target_name() -> String:
	return "Alpha"
