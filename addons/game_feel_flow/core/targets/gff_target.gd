@tool
class_name GFFTarget
extends Resource

func get_value_type() -> GFFValueType.Value:
	return GFFValueType.Value.FLOAT

func get_initial_value(node: Node) -> Variant:
	return 0.0

func get_start_value(node: Node, intensity: float) -> Variant:
	return get_initial_value(node)

func get_end_value(node: Node, intensity: float) -> Variant:
	return get_initial_value(node)

func apply_value(node: Node, value: Variant) -> void:
	pass

func get_target_name() -> String:
	return "Target"

func can_restore(node: Node) -> bool:
	return false

func get_restorable_state(node: Node) -> Dictionary:
	return {}

func restore_state(node: Node, state: Dictionary) -> void:
	pass
