class_name GFFColor
extends GFFFeedback

## Game Feel Flow Color Effect
##
## 颜色效果，改变modulate颜色，支持Node2D和Control

# ===== Properties =====
@export_group("Color Settings")
@export var target_color: Color = Color.WHITE
@export var color_mode: ColorMode = ColorMode.TO_COLOR

enum ColorMode {
	TO_COLOR,
	MULTIPLY,
	ADD
}

# ===== Override Methods =====

func _execute(node: Node, params: GFFParams) -> void:
	var intensity = params.get_float("intensity", 1.0)
	var final_duration = params.get_float("duration", duration)
	var color = params.get_color("color", target_color)

	# 检查节点类型，选择合适的方式改变颜色
	if node is Node3D:
		# 3D节点使用材质颜色
		_execute_3d(node, color, intensity, final_duration)
	elif node is Node2D or node is Control:
		# 2D节点和UI使用modulate
		_execute_2d(node, color, intensity, final_duration)

func _execute_3d(node: Node3D, color: Color, intensity: float, final_duration: float) -> void:
	## 3D节点的颜色效果
	var mesh_instance = node as MeshInstance3D
	if not mesh_instance:
		# 如果不是MeshInstance3D，尝试查找子节点
		for child in node.get_children():
			if child is MeshInstance3D:
				mesh_instance = child
				break
	
	if not mesh_instance:
		push_warning("GFFColor: No MeshInstance3D found for 3D color effect")
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
		var target_color = color * intensity
		
		if easing_curve:
			var tween = node.create_tween()
			tween.tween_method(_apply_material_curve.bind(material, original_color, target_color), 0.0, 1.0, final_duration)
			await tween.finished
		else:
			var tween = node.create_tween()
			tween.tween_property(material, "albedo_color", target_color, final_duration)
			await tween.finished

func _execute_2d(node: Node, color: Color, intensity: float, final_duration: float) -> void:
	## 2D节点和UI的颜色效果
	var original_modulate = _get_modulate(node)
	var target: Color

	match color_mode:
		ColorMode.TO_COLOR:
			target = color * intensity
		ColorMode.MULTIPLY:
			target = original_modulate * color * intensity
		ColorMode.ADD:
			target = original_modulate + color * intensity

	if easing_curve:
		var tween = node.create_tween()
		tween.tween_method(_apply_color_curve.bind(node, original_modulate, target), 0.0, 1.0, final_duration)
		await tween.finished
	else:
		var tween = node.create_tween()
		tween.tween_property(node, "modulate", target, final_duration)
		await tween.finished

func _apply_color_curve(t: float, node: Node, from: Color, to: Color) -> void:
	var value = easing_curve.sample(t)
	_set_modulate(node, from.lerp(to, value))

func _apply_material_curve(t: float, material: StandardMaterial3D, from: Color, to: Color) -> void:
	var value = easing_curve.sample(t)
	material.albedo_color = from.lerp(to, value)

func _get_default_intensity() -> float:
	return 1.0

func _get_default_duration() -> float:
	return duration