@tool
class_name GFFCameraZoom
extends GFFEffect

## Game Feel Flow Camera Zoom Effect
##
## Camera zoom effect supporting Camera2D and Camera3D

# ===== Properties =====
@export_group("Camera Zoom Settings")
@export var target_zoom: Vector2 = Vector2(1.5, 1.5)
@export var zoom_mode: ZoomMode = ZoomMode.TO_ZOOM

enum ZoomMode {
	TO_ZOOM,
	ADDITIVE,
	MULTIPLICATIVE
}

# ===== State =====
var _zoom_node: Node = null
var _original_zoom: Vector2 = Vector2.ONE
var _original_fov: float = 75.0

# ===== Override Methods =====

func _execute(node: Node, params: GFFParams) -> void:
	_zoom_node = node
	var intensity = params.get_float("intensity", 1.0)
	var final_duration = params.get_float("duration", duration)

	if node is Camera2D:
		_original_zoom = node.zoom
		var target: Vector2

		match zoom_mode:
			ZoomMode.TO_ZOOM:
				target = target_zoom * intensity
			ZoomMode.ADDITIVE:
				target = _original_zoom + target_zoom * intensity
			ZoomMode.MULTIPLICATIVE:
				target = _original_zoom * target_zoom * intensity

		var tween = node.create_tween()
		_register_active_tween(tween)
		if easing_curve:
			tween.tween_method(_apply_zoom_curve.bind(node, _original_zoom, target), 0.0, 1.0, final_duration)
		else:
			tween.tween_property(node, "zoom", target, final_duration)
		await _await_tween(tween)
	elif node is Camera3D:
		_original_fov = node.fov
		var target_fov = _original_fov * (1.0 / intensity)

		var tween = node.create_tween()
		_register_active_tween(tween)
		if easing_curve:
			tween.tween_method(_apply_fov_curve.bind(node, _original_fov, target_fov), 0.0, 1.0, final_duration)
		else:
			tween.tween_property(node, "fov", target_fov, final_duration)
		await _await_tween(tween)

func _stop() -> void:
	if is_instance_valid(_zoom_node):
		if _zoom_node is Camera2D:
			_zoom_node.zoom = _original_zoom
		elif _zoom_node is Camera3D:
			_zoom_node.fov = _original_fov
	_zoom_node = null

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