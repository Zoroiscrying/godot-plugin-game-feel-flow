class_name GFFPunchRotation
extends GFFCurvedBase

## Game Feel Flow Punch Rotation Effect
##
## 旋转冲击效果

# ===== 属性 =====
@export_group("Punch Settings")
@export var punch_angle: float = 15.0
@export var elasticity: float = 0.5

# ===== 重写方法 =====

func _init() -> void:
	tweener_type = TweenerType.ELASTIC
	super._init()

func _create_target_function() -> GFFTargetFunction:
	return GFFRotationTarget.new()

func _calculate_target_value(original_value: Variant, intensity: float) -> Variant:
	if original_value is float:
		return original_value + deg_to_rad(punch_angle * intensity)
	return original_value
