class_name GFFFlicker
extends GFFFeedback

## Game Feel Flow Flicker Effect
##
## 闪烁效果，快速改变颜色，支持Node2D和Control

# ===== Properties =====
@export_group("Flicker Settings")
@export var flicker_color: Color = Color.WHITE
@export var flicker_count: int = 5
@export var flicker_interval: float = 0.05

# ===== Override Methods =====

func _execute(node: Node, params: GFFParams) -> void:
	var intensity = params.get_float("intensity", 1.0)
	var final_duration = params.get_float("duration", duration)
	var color = params.get_color("color", flicker_color)
	var count = params.get_int("flicker_count", flicker_count)
	var interval = final_duration / count

	var original_modulate = _get_modulate(node)

	for i in range(count):
		_set_modulate(node, color * intensity)
		await node.get_tree().create_timer(interval / 2).timeout
		_set_modulate(node, original_modulate)
		await node.get_tree().create_timer(interval / 2).timeout

func _get_default_intensity() -> float:
	return 1.0

func _get_default_duration() -> float:
	return duration