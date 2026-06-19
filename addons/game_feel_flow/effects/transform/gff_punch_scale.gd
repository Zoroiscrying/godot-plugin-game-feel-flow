class_name GFFPunchScale
extends GFFPunchBase

## Game Feel Flow Punch Scale Effect
##
## 缩放冲击效果，快速放大然后缩小

# ===== 属性 =====
@export_group("Punch Settings")
@export var punch_scale: Vector2 = Vector2(1.3, 1.3)
@export var punch_scale_3d: Vector3 = Vector3(1.3, 1.3, 1.3)

# ===== 重写方法 =====

func _get_target_value(node: Node, intensity: float):
	if node is Node3D:
		return punch_scale_3d * intensity
	else:
		return Vector2(punch_scale.x * intensity, punch_scale.y * intensity)

func _get_original_value(node: Node):
	return _get_scale(node)

func _apply_value(node: Node, value) -> void:
	_set_scale(node, value)
