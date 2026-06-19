class_name GFFAlpha
extends GFFFeedback

## Game Feel Flow Alpha Effect
##
## 透明度效果，改变alpha值，支持Node2D、Node3D和Control

# ===== Properties =====
@export_group("Alpha Settings")
@export var target_alpha: float = 0.0
@export var alpha_mode: AlphaMode = AlphaMode.TO_ALPHA

enum AlphaMode {
	TO_ALPHA,
	ADDITIVE,
	MULTIPLICATIVE
}

# ===== Override Methods =====

func _execute(node: Node, params: GFFParams) -> void:
	var intensity = params.get_float("intensity", 1.0)
	var final_duration = params.get_float("duration", duration)
	var alpha = params.get_float("alpha", target_alpha)

	# 检查节点类型，选择合适的方式改变透明度
	if node is Node3D:
		# 3D节点使用材质透明度
		_execute_3d(node, alpha, intensity, final_duration)
	elif node is Node2D or node is Control:
		# 2D节点和UI使用modulate
		_execute_2d(node, alpha, intensity, final_duration)

func _execute_3d(node: Node3D, alpha: float, intensity: float, final_duration: float) -> void:
	## 3D节点的透明度效果
	var mesh_instance = node as MeshInstance3D
	if not mesh_instance:
		# 如果不是MeshInstance3D，尝试查找子节点
		for child in node.get_children():
			if child is MeshInstance3D:
				mesh_instance = child
				break
	
	if not mesh_instance:
		push_warning("GFFAlpha: No MeshInstance3D found for 3D alpha effect")
		return
	
	# 获取或创建材质
	var material = mesh_instance.get_surface_override_material(0)
	if not material:
		material = mesh_instance.get_active_material(0)
	if not material:
		material = StandardMaterial3D.new()
		mesh_instance.set_surface_override_material(0, material)
	
	if material is StandardMaterial3D:
		var original_color = material.albedo_color
		var target_alpha_value = alpha * intensity
		
		# 创建目标颜色（保持RGB，改变Alpha）
		var target_color = original_color
		target_color.a = target_alpha_value
		
		if easing_curve:
			var tween = node.create_tween()
			tween.tween_method(_apply_material_curve.bind(material, original_color, target_color), 0.0, 1.0, final_duration)
			await tween.finished
		else:
			var tween = node.create_tween()
			tween.tween_property(material, "albedo_color", target_color, final_duration)
			await tween.finished

func _execute_2d(node: Node, alpha: float, intensity: float, final_duration: float) -> void:
	## 2D节点和UI的透明度效果
	var original_modulate = _get_modulate(node)
	var original_alpha = original_modulate.a
	var target_alpha_value: float

	match alpha_mode:
		AlphaMode.TO_ALPHA:
			target_alpha_value = alpha * intensity
		AlphaMode.ADDITIVE:
			target_alpha_value = original_alpha + alpha * intensity
		AlphaMode.MULTIPLICATIVE:
			target_alpha_value = original_alpha * alpha * intensity

	var target_color = original_modulate
	target_color.a = target_alpha_value

	if easing_curve:
		var tween = node.create_tween()
		tween.tween_method(_apply_alpha_curve.bind(node, original_modulate, target_color), 0.0, 1.0, final_duration)
		await tween.finished
	else:
		var tween = node.create_tween()
		tween.tween_property(node, "modulate", target_color, final_duration)
		await tween.finished

func _apply_alpha_curve(t: float, node: Node, from: Color, to: Color) -> void:
	var value = easing_curve.sample(t)
	_set_modulate(node, from.lerp(to, value))

func _apply_material_curve(t: float, material: StandardMaterial3D, from: Color, to: Color) -> void:
	var value = easing_curve.sample(t)
	material.albedo_color = from.lerp(to, value)

func _get_default_intensity() -> float:
	return 1.0

func _get_default_duration() -> float:
	return duration
