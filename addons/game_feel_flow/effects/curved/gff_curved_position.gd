class_name GFFCurvedPosition
extends GFFCurvedBase

## Game Feel Flow Curved Position Effect
##
## 曲线驱动的位置变化

# ===== 属性 =====
@export_group("Position Settings")
@export var target_offset: Vector2 = Vector2(10.0, 0.0)
@export var target_offset_3d: Vector3 = Vector3(10.0, 0.0, 0.0)

# ===== 重写方法 =====

func _create_target_function() -> GFFTargetFunction:
	return GFFPositionTarget.new()

func _calculate_target_value(original_value: Variant, intensity: float) -> Variant:
	if original_value is Vector3:
		return original_value + target_offset_3d * intensity
	elif original_value is Vector2:
		return original_value + Vector2(target_offset.x * intensity, target_offset.y * intensity)
	return original_value
