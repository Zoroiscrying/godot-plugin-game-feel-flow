class_name GFFShakeTweener
extends GFFValueTweener

## Game Feel Flow Shake Tweener
##
## 震动变化

# ===== 属性 =====
var amplitude: float = 0.5
var frequency: float = 15.0

func setup_from_params(params: GFFParams) -> void:
	## 从GFFParams中读取参数
	amplitude = params.get_float("amplitude", amplitude)
	frequency = params.get_float("frequency", frequency)

func tween_value(node: Node, target_function: GFFTargetFunction, from: Variant, to: Variant, duration: float, curve: Curve = null) -> void:
	var elapsed = 0.0
	
	while elapsed < duration:
		var t = elapsed / duration
		var decay = 1.0 - t
		
		# 应用衰减曲线
		if curve:
			decay = curve.sample(t)
		
		# 计算随机偏移（使用amplitude作为强度）
		var offset = _calculate_offset(amplitude, decay)
		var value = _add_offset(from, offset)
		
		target_function.set_value(node, value)
		
		await node.get_tree().process_frame
		elapsed += node.get_process_delta_time()
	
	# 恢复原值
	target_function.set_value(node, from)

func _calculate_offset(amplitude: float, decay: float) -> Variant:
	var offset = Vector3.ZERO
	offset.x = randf_range(-1, 1) * amplitude * decay
	offset.y = randf_range(-1, 1) * amplitude * decay
	offset.z = randf_range(-1, 1) * amplitude * decay
	return offset

func _add_offset(from: Variant, offset: Variant) -> Variant:
	if from is float:
		return from + offset.x
	elif from is Vector2:
		return from + Vector2(offset.x, offset.y)
	elif from is Vector3:
		return from + offset
	return from

func get_value_at_time(t: float, from: Variant, to: Variant, curve: Curve = null) -> Variant:
	# Shake不能静态计算值
	return from
