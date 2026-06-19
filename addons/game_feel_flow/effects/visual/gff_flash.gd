class_name GFFFlash
extends GFFFeedback

## Game Feel Flow Flash Effect
##
## 闪光效果，改变颜色，支持Node2D、Node3D和Control

# ===== Properties =====
@export_group("Flash Settings")
@export var flash_color: Color = Color.WHITE
@export var flash_frequency: float = 15.0
@export var lerp_mode: LerpMode = LerpMode.INSTANT

enum LerpMode {
	INSTANT,  # 瞬间切换
	LINEAR,   # 线性过渡
	SMOOTH    # 平滑过渡
}

# ===== Override Methods =====

func _execute(node: Node, params: GFFParams) -> void:
	var intensity = params.get_float("intensity", 1.0)
	var final_duration = params.get_float("duration", duration)
	var color = params.get_color("color", flash_color)
	var frequency = params.get_float("frequency", flash_frequency)
	
	# 计算闪烁次数
	var count = int(final_duration * frequency)
	if count < 1:
		count = 1

	# 检查节点类型，选择合适的方式改变颜色
	if node is Node3D:
		_execute_3d(node, color, intensity, final_duration, frequency, count)
	elif node is Node2D or node is Control:
		_execute_2d(node, color, intensity, final_duration, frequency, count)

func _execute_3d(node: Node3D, color: Color, intensity: float, final_duration: float, frequency: float, count: int) -> void:
	## 3D节点的闪光效果
	var mesh_instance = node as MeshInstance3D
	if not mesh_instance:
		for child in node.get_children():
			if child is MeshInstance3D:
				mesh_instance = child
				break
	
	if not mesh_instance:
		push_warning("GFFFlash: No MeshInstance3D found for 3D flash effect")
		return
	
	var material = mesh_instance.get_surface_override_material(0)
	if not material:
		material = mesh_instance.get_active_material(0)
	if not material:
		material = StandardMaterial3D.new()
		mesh_instance.set_surface_override_material(0, material)
	
	if material is StandardMaterial3D:
		var original_color = material.albedo_color
		var flash_color_intensity = color * intensity
		var interval = 1.0 / frequency
		
		match lerp_mode:
			LerpMode.INSTANT:
				for i in range(count):
					material.albedo_color = flash_color_intensity
					await node.get_tree().create_timer(interval / 2).timeout
					material.albedo_color = original_color
					await node.get_tree().create_timer(interval / 2).timeout
			LerpMode.LINEAR:
				for i in range(count):
					var tween = node.create_tween()
					tween.tween_property(material, "albedo_color", flash_color_intensity, interval / 2)
					await tween.finished
					var tween2 = node.create_tween()
					tween2.tween_property(material, "albedo_color", original_color, interval / 2)
					await tween2.finished
			LerpMode.SMOOTH:
				for i in range(count):
					var tween = node.create_tween()
					tween.tween_property(material, "albedo_color", flash_color_intensity, interval / 2).set_ease(Tween.EASE_IN_OUT)
					await tween.finished
					var tween2 = node.create_tween()
					tween2.tween_property(material, "albedo_color", original_color, interval / 2).set_ease(Tween.EASE_IN_OUT)
					await tween2.finished

func _execute_2d(node: Node, color: Color, intensity: float, final_duration: float, frequency: float, count: int) -> void:
	## 2D节点和UI的闪光效果
	var original_modulate = _get_modulate(node)
	var flash_color_intensity = color * intensity
	var interval = 1.0 / frequency

	match lerp_mode:
		LerpMode.INSTANT:
			for i in range(count):
				_set_modulate(node, flash_color_intensity)
				await node.get_tree().create_timer(interval / 2).timeout
				_set_modulate(node, original_modulate)
				await node.get_tree().create_timer(interval / 2).timeout
		LerpMode.LINEAR:
			for i in range(count):
				var tween = node.create_tween()
				tween.tween_method(_set_modulate.bind(node), original_modulate, flash_color_intensity, interval / 2)
				await tween.finished
				var tween2 = node.create_tween()
				tween2.tween_method(_set_modulate.bind(node), flash_color_intensity, original_modulate, interval / 2)
				await tween2.finished
		LerpMode.SMOOTH:
			for i in range(count):
				var tween = node.create_tween()
				tween.tween_method(_set_modulate.bind(node), original_modulate, flash_color_intensity, interval / 2).set_ease(Tween.EASE_IN_OUT)
				await tween.finished
				var tween2 = node.create_tween()
				tween2.tween_method(_set_modulate.bind(node), flash_color_intensity, original_modulate, interval / 2).set_ease(Tween.EASE_IN_OUT)
				await tween2.finished

func _get_default_intensity() -> float:
	return 1.0

func _get_default_duration() -> float:
	return duration
