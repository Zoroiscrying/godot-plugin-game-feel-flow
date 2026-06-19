class_name GFFPunchRotation
extends GFFPunchBase

## Game Feel Flow Punch Rotation Effect
##
## 旋转冲击效果，快速旋转然后回来

# ===== 属性 =====
@export_group("Punch Settings")
@export var punch_angle: float = 15.0

# ===== 重写方法 =====

func _get_target_value(node: Node, intensity: float):
	var original = _get_original_value(node)
	return original + deg_to_rad(punch_angle * intensity)

func _get_original_value(node: Node):
	return _get_rotation(node)

func _apply_value(node: Node, value) -> void:
	_set_rotation(node, value)
