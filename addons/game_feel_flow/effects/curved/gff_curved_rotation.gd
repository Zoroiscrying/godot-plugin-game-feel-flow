class_name GFFCurvedRotation
extends GFFCurvedBase

## Game Feel Flow Curved Rotation Effect
##
## 曲线驱动的旋转变化

# ===== 属性 =====
@export_group("Rotation Settings")
@export var target_angle: float = 15.0

# ===== 重写方法 =====

func _create_target_function() -> GFFTargetFunction:
	return GFFRotationTarget.new()

func _calculate_target_value(original_value: Variant, intensity: float) -> Variant:
	if original_value is float:
		return original_value + deg_to_rad(target_angle * intensity)
	return original_value
