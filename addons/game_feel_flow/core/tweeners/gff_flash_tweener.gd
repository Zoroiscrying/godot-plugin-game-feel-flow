@tool
class_name GFFFlashTweener
extends GFFTweener

enum LerpMode { INSTANT, LINEAR, SMOOTH }

@export var flash_color: Color = Color.WHITE
@export var frequency: float = 15.0
@export var lerp_mode: LerpMode = LerpMode.INSTANT

func get_tweener_name() -> String:
	return "Flash"

func get_supported_value_types() -> Array[GFFValueType.Value]:
	return [GFFValueType.Value.COLOR]

func tween_node(node: Node, target: GFFTarget, from: Variant, to: Variant, duration: float, curve: Curve = null) -> void:
	_is_stopped = false
	var count = maxi(1, int(duration * frequency))
	var interval = duration / count
	for i in range(count):
		if _is_stopped or not is_instance_valid(node):
			return
		match lerp_mode:
			LerpMode.INSTANT:
				target.apply_value(node, flash_color)
				await node.get_tree().create_timer(interval / 2.0).timeout
				if _is_stopped or not is_instance_valid(node):
					return
				target.apply_value(node, from)
				await node.get_tree().create_timer(interval / 2.0).timeout
			LerpMode.LINEAR:
				await _flash_tween(node, target, from, flash_color, interval / 2.0, Tween.EASE_IN_OUT)
				if _is_stopped or not is_instance_valid(node):
					return
				await _flash_tween(node, target, flash_color, from, interval / 2.0, Tween.EASE_IN_OUT)
			LerpMode.SMOOTH:
				await _flash_tween(node, target, from, flash_color, interval / 2.0, Tween.EASE_IN_OUT)
				if _is_stopped or not is_instance_valid(node):
					return
				await _flash_tween(node, target, flash_color, from, interval / 2.0, Tween.EASE_IN_OUT)

func _flash_tween(node: Node, target: GFFTarget, from: Color, to: Color, duration: float, ease_type: int) -> void:
	var tween = _start_tween(node)
	tween.tween_method(_apply_lerp.bind(node, target, from, to), 0.0, 1.0, duration).set_ease(ease_type)
	await _tween_completed

func _apply_lerp(t: float, node: Node, target: GFFTarget, from: Color, to: Color) -> void:
	target.apply_value(node, from.lerp(to, t))
