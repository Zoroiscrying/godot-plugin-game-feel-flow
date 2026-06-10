class_name GFFFlash
extends GFFFeedback

## Game Feel Flow Flash Effect
##
## 闪光效果，改变modulate颜色，支持Node2D和Control

# ===== Properties =====
@export_group("Flash Settings")
@export var flash_color: Color = Color.WHITE
@export var flash_count: int = 1

# ===== Override Methods =====

func _execute(node: Node, params: GFFParams) -> void:
	var intensity = params.get_float("intensity", 1.0)
	var final_duration = params.get_float("duration", duration)
	var color = params.get_color("color", flash_color)

	var original_modulate = _get_modulate(node)

	for i in range(flash_count):
		_set_modulate(node, color * intensity)
		await node.get_tree().create_timer(final_duration / flash_count / 2).timeout
		_set_modulate(node, original_modulate)
		await node.get_tree().create_timer(final_duration / flash_count / 2).timeout

func _get_default_intensity() -> float:
	return 1.0

func _get_default_duration() -> float:
	return duration