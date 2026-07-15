@tool
class_name GFFTween
extends GFFEffect

## Game Feel Flow Tween Effect
##
## Tween effect supporting custom property animation

# ===== Properties =====
@export_group("Tween Settings")
@export var property: String = "position"
@export var target_value: Variant
@export var tween_type: TweenType = TweenType.TO_VALUE

enum TweenType {
	TO_VALUE,
	FROM_VALUE,
	OSCILLATE
}

# ===== Override Methods =====

func _execute(node: Node, params: GFFParams) -> void:
	var intensity = params.get_float("intensity", 1.0)
	var final_duration = params.get_float("duration", duration)
	var value = params.get_variant("value", target_value)

	if property.is_empty():
		push_warning("GFFTween: No property specified")
		return

	var original_value = node.get(property)

	match tween_type:
		TweenType.TO_VALUE:
			var tween = node.create_tween()
			_register_active_tween(tween)
			if easing_curve:
				tween.tween_method(_apply_tween_curve.bind(node, original_value, value), 0.0, 1.0, final_duration)
			else:
				tween.tween_property(node, property, value, final_duration)
			await _await_tween(tween)
		TweenType.FROM_VALUE:
			node.set(property, value)
			var tween = node.create_tween()
			_register_active_tween(tween)
			if easing_curve:
				tween.tween_method(_apply_tween_curve.bind(node, value, original_value), 0.0, 1.0, final_duration)
			else:
				tween.tween_property(node, property, original_value, final_duration)
			await _await_tween(tween)
		TweenType.OSCILLATE:
			var tween = node.create_tween()
			_register_active_tween(tween)
			if easing_curve:
				tween.tween_method(_apply_tween_curve.bind(node, original_value, value), 0.0, 1.0, final_duration / 2)
				tween.tween_method(_apply_tween_curve.bind(node, value, original_value), 0.0, 1.0, final_duration / 2)
			else:
				tween.tween_property(node, property, value, final_duration / 2)
				tween.tween_property(node, property, original_value, final_duration / 2)
			await _await_tween(tween)

func _apply_tween_curve(t: float, node: Node, from, to) -> void:
	var value = easing_curve.sample(t)
	if from is float and to is float:
		node.set(property, lerp(from, to, value))
	elif from is Vector2 and to is Vector2:
		node.set(property, from.lerp(to, value))
	elif from is Vector3 and to is Vector3:
		node.set(property, from.lerp(to, value))
	elif from is Color and to is Color:
		node.set(property, from.lerp(to, value))

func _get_default_intensity() -> float:
	return 1.0

func _get_default_duration() -> float:
	return duration