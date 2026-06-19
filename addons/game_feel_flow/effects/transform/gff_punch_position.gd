class_name GFFPunchPosition
extends GFFPunchBase

## Game Feel Flow Punch Position Effect
##
## 位置冲击效果，快速移动然后回来

# ===== 属性 =====
@export_group("Punch Settings")
@export var punch_offset: Vector2 = Vector2(10.0, 0.0)
@export var punch_offset_3d: Vector3 = Vector3(10.0, 0.0, 0.0)

# ===== 重写方法 =====

func _get_target_value(node: Node, intensity: float):
	var original = _get_original_value(node)
	if node is Node3D:
		return original + punch_offset_3d * intensity
	else:
		return original + Vector2(punch_offset.x * intensity, punch_offset.y * intensity)

func _get_original_value(node: Node):
	return _get_position(node)

func _apply_value(node: Node, value) -> void:
	_set_position(node, value)
