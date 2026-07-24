@tool
class_name GFFComboEffect
extends GFFEffect

## Game Feel Flow Combo Effect
## Wraps a GFFCombo so it can be used as a nested effect inside another combo.

@export var combo: GFFCombo = null

func _get_default_duration() -> float:
	if combo:
		return combo.get_total_duration()
	return duration

func _execute(node: Node, params: GFFParams) -> void:
	if combo == null:
		push_warning("GFFComboEffect: No combo assigned")
		return
	await combo.execute(node, params)

func _get_default_intensity() -> float:
	return 1.0
