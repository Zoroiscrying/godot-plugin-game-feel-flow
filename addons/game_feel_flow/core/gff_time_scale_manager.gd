class_name GFFTimeScaleManager
extends RefCounted

## Manages a stack of time-scale requests so multiple time/freeze effects can nest safely.

static var _stack: Array[Dictionary] = []

static func push(time_scale: float, source: Object) -> void:
	_stack.append({"time_scale": time_scale, "source": source})
	_apply()

static func pop(source: Object) -> void:
	for i in range(_stack.size() - 1, -1, -1):
		if _stack[i]["source"] == source:
			_stack.remove_at(i)
			break
	_apply()

static func update(source: Object, time_scale: float) -> void:
	for req in _stack:
		if req["source"] == source:
			req["time_scale"] = time_scale
			break
	_apply()

static func get_current_time_scale() -> float:
	if _stack.is_empty():
		return 1.0
	return _stack[-1]["time_scale"]

static func clear() -> void:
	_stack.clear()
	_apply()

static func _apply() -> void:
	while not _stack.is_empty():
		var source = _stack[-1]["source"]
		if is_instance_valid(source):
			break
		_stack.pop_back()

	if _stack.is_empty():
		Engine.time_scale = 1.0
	else:
		Engine.time_scale = _stack[-1]["time_scale"]
