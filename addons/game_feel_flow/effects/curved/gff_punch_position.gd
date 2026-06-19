class_name GFFPunchPosition
extends GFFCurvedBase

## Game Feel Flow Punch Position Effect
##
## 位置冲击效果

# ===== 属性 =====
@export_group("Punch Settings")
@export var punch_offset: Vector2 = Vector2(10.0, 0.0)
@export var punch_offset_3d: Vector3 = Vector3(10.0, 0.0, 0.0)
@export var elasticity: float = 0.5

# ===== 重写方法 =====

func _init() -> void:
	tweener_type = TweenerType.ELASTIC
	super._init()

func _create_target_function() -> GFFTargetFunction:
	return GFFPositionTarget.new()

func _calculate_target_value(original_value: Variant, intensity: float) -> Variant:
	if original_value is Vector3:
		return original_value + punch_offset_3d * intensity
	elif original_value is Vector2:
		return original_value + Vector2(punch_offset.x * intensity, punch_offset.y * intensity)
	return original_value
