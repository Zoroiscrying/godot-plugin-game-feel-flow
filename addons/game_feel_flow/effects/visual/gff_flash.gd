class_name GFFFlash
extends GFFFeedback

## Game Feel Flow Flash Effect
##
## 闪光效果，改变颜色，支持Node2D、Node3D和Control

# ===== Properties =====
@export_group("Flash Settings")
@export var flash_color: Color = Color.WHITE
@export var flash_count: int = 1

# ===== Override Methods =====

func _execute(node: Node, params: GFFParams) -> void:
	var intensity = params.get_float("intensity", 1.0)
	var final_duration = params.get_float("duration", duration)
	var color = params.get_color("color", flash_color)

	# 检查节点类型，选择合适的方式改变颜色
	if node is Node3D:
		# 3D节点使用材质颜色
		_execute_3d(node, color, intensity, final_duration)
	elif node is Node2D or node is Control:
		# 2D节点和UI使用modulate
		_execute_2d(node, color, intensity, final_duration)

func _execute_3d(node: Node3D, color: Color, intensity: float, final_duration: float) -> void:
	## 3D节点的闪光效果
	var mesh_instance = node as MeshInstance3D
	if not mesh_instance:
		# 如果不是MeshInstance3D，尝试查找子节点
		for child in node.get_children():
			if child is MeshInstance3D:
				mesh_instance = child
				break
	
	if not mesh_instance:
		push_warning("GFFFlash: No MeshInstance3D found for 3D flash effect")
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
		var flash_color_intensity = color * intensity
		
		for i in range(flash_count):
			# 闪到目标颜色
			material.albedo_color = flash_color_intensity
			await node.get_tree().create_timer(final_duration / flash_count / 2).timeout
			# 恢复原色
			material.albedo_color = original_color
			await node.get_tree().create_timer(final_duration / flash_count / 2).timeout

func _execute_2d(node: Node, color: Color, intensity: float, final_duration: float) -> void:
	## 2D节点和UI的闪光效果
	var original_modulate = _get_modulate(node)

	for i in range(flash_count):
		_set_modulate(node, color * intensity)
		await node.get_tree().create_timer(final_duration / flash_count / 2).timeout
		_set_modulate(node, original_modulate)
		await node.get_tree().create_timer(final_duration / flash_count / 2).timeout

func _get_default_intensity() -> float:
	return 1.0

func _get_default_duration() -> float:
	return duration
