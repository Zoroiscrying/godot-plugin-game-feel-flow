class_name GFFFreezeFrame
extends GFFFeedback

## Game Feel Flow Freeze Frame Effect
##
## 冻结帧效果，暂停场景树

# ===== Properties =====
@export_group("Freeze Frame Settings")
@export var freeze_duration: float = 0.1

# ===== Override Methods =====

func _execute(node: Node, params: GFFParams) -> void:
	var final_duration = params.get_float("duration", freeze_duration)

	# Store original time scale
	var original_time_scale = Engine.time_scale

	# Freeze
	Engine.time_scale = 0.0
	await node.get_tree().create_timer(final_duration, true, false, true).timeout

	# Restore
	Engine.time_scale = original_time_scale

func _get_default_intensity() -> float:
	return 1.0

func _get_default_duration() -> float:
	return freeze_duration