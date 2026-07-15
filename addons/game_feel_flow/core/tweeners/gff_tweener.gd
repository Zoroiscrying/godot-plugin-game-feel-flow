@tool
class_name GFFTweener
extends Resource

signal _tween_completed

var _active_tween: Tween = null
var _is_stopped: bool = false

func get_tweener_name() -> String:
	return "Tweener"

func get_supported_value_types() -> Array[GFFValueType.Value]:
	return []

func can_handle(target: GFFTarget) -> bool:
	return get_supported_value_types().has(target.get_value_type())

func tween_node(node: Node, target: GFFTarget, from: Variant, to: Variant, duration: float, curve: Curve = null) -> void:
	push_error("tween_node() not implemented")

func apply_params(params: GFFParams) -> void:
	## Let Tweener read parameters from GFFParams (including intensity and custom params; optional subclass implementation)
	pass

func _start_tween(node: Node) -> Tween:
	_is_stopped = false
	_active_tween = node.create_tween()
	_active_tween.finished.connect(_complete_tween)
	return _active_tween

func _complete_tween() -> void:
	_active_tween = null
	_tween_completed.emit()

func stop() -> void:
	_is_stopped = true
	if _active_tween and is_instance_valid(_active_tween):
		_active_tween.kill()
		_active_tween = null
		_tween_completed.emit()
