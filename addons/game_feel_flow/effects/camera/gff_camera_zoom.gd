class_name GFFCameraZoom
extends GFFFeedback

## Game Feel Flow Camera Zoom Effect
##
## 相机缩放效果，支持Camera2D和Camera3D

# ===== Properties =====
@export_group("Camera Zoom Settings")
@export var target_zoom: Vector2 = Vector2(1.5, 1.5)
@export var zoom_mode: ZoomMode = ZoomMode.TO_ZOOM

enum ZoomMode {
	TO_ZOOM,
	ADDITIVE,
	MULTIPLICATIVE
}

# ===== Override Methods =====

func _execute(node: Node, params: GFFParams) -> void:
	var intensity = params.get_float("intensity", 1.0)
	var final_duration = params.get_float("duration", duration)

	if node is Camera2D:
		var original_zoom = node.zoom
		var target: Vector2

		match zoom_mode:
			ZoomMode.TO_ZOOM:
				target = target_zoom * intensity
			ZoomMode.ADDITIVE:
				target = original_zoom + target_zoom * intensity
			ZoomMode.MULTIPLICATIVE:
				target = original_zoom * target_zoom * intensity

		if easing_curve:
			var tween = node.create_tween()
			tween.tween_method(_apply_zoom_curve.bind(node, original_zoom, target), 0.0, 1.0, final_duration)
			await tween.finished
		else:
			var tween = node.create_tween()
			tween.tween_property(node, "zoom", target, final_duration)
			await tween.finished
	elif node is Camera3D:
		var original_fov = node.fov
		var target_fov = original_fov * (1.0 / intensity)

		if easing_curve:
			var tween = node.create_tween()
			tween.tween_method(_apply_fov_curve.bind(node, original_fov, target_fov), 0.0, 1.0, final_duration)
			await tween.finished
		else:
			var tween = node.create_tween()
			tween.tween_property(node, "fov", target_fov, final_duration)
			await tween.finished

func _apply_zoom_curve(t: float, node: Node, from: Vector2, to: Vector2) -> void:
	var value = easing_curve.sample(t)
	node.zoom = from.lerp(to, value)

func _apply_fov_curve(t: float, node: Node, from: float, to: float) -> void:
	var value = easing_curve.sample(t)
	node.fov = lerp(from, to, value)

func _get_default_intensity() -> float:
	return 1.0

func _get_default_duration() -> float:
	return duration