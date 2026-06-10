class_name GFFCameraFlash
extends GFFFeedback

## Game Feel Flow Camera Flash Effect
##
## 相机闪光效果，支持Camera2D和Camera3D

# ===== Properties =====
@export_group("Camera Flash Settings")
@export var flash_color: Color = Color.WHITE
@export var flash_count: int = 1

# ===== Override Methods =====

func _execute(node: Node, params: GFFParams) -> void:
	var intensity = params.get_float("intensity", 1.0)
	var final_duration = params.get_float("duration", duration)
	var color = params.get_color("color", flash_color)

	# Create flash overlay
	var flash_overlay = ColorRect.new()
	flash_overlay.color = color * intensity
	flash_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	flash_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE

	# Add to camera
	if node is Camera2D:
		var canvas_layer = CanvasLayer.new()
		canvas_layer.layer = 100
		node.add_child(canvas_layer)
		canvas_layer.add_child(flash_overlay)
		await _flash(flash_overlay, final_duration)
		canvas_layer.queue_free()
	elif node is Camera3D:
		# For 3D camera, create a SubViewport with flash
		var viewport = SubViewport.new()
		viewport.size = node.get_viewport().size
		viewport.transparent_bg = true
		viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS

		var camera = Camera3D.new()
		camera.current = false
		viewport.add_child(camera)

		var color_rect = ColorRect.new()
		color_rect.color = color * intensity
		color_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
		viewport.add_child(color_rect)

		var canvas_layer = CanvasLayer.new()
		canvas_layer.layer = 100
		node.get_viewport().add_child(canvas_layer)

		var texture_rect = TextureRect.new()
		texture_rect.texture = viewport.get_texture()
		texture_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
		canvas_layer.add_child(texture_rect)

		await _flash(color_rect, final_duration)
		canvas_layer.queue_free()
		viewport.queue_free()

func _flash(overlay: Control, duration: float) -> void:
	for i in range(flash_count):
		overlay.visible = true
		await overlay.get_tree().create_timer(duration / flash_count / 2).timeout
		overlay.visible = false
		await overlay.get_tree().create_timer(duration / flash_count / 2).timeout

func _get_default_intensity() -> float:
	return 1.0

func _get_default_duration() -> float:
	return duration