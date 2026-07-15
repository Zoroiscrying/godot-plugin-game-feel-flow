@tool
class_name GFFParams
extends Resource

## Game Feel Flow Parameters
##
## Parameter class supporting chained calls and multiple data types

# ===== Base Parameters =====
@export var intensity: float = 1.0
@export var duration: float = -1.0

# ===== Extended Parameters =====
@export var _data: Dictionary = {}

# ===== Chain Methods =====

func with_float(key: String, value: float) -> GFFParams:
	_data[key] = value
	return self

func with_int(key: String, value: int) -> GFFParams:
	_data[key] = value
	return self

func with_bool(key: String, value: bool) -> GFFParams:
	_data[key] = value
	return self

func with_vector2(key: String, value: Vector2) -> GFFParams:
	_data[key] = value
	return self

func with_vector3(key: String, value: Vector3) -> GFFParams:
	_data[key] = value
	return self

func with_color(key: String, value: Color) -> GFFParams:
	_data[key] = value
	return self

func with_string(key: String, value: String) -> GFFParams:
	_data[key] = value
	return self

func with_curve(key: String, value: Curve) -> GFFParams:
	_data[key] = value
	return self

func with_node(key: String, value: Node) -> GFFParams:
	_data[key] = value
	return self

func with_resource(key: String, value: Resource) -> GFFParams:
	_data[key] = value
	return self

func with_variant(key: String, value: Variant) -> GFFParams:
	_data[key] = value
	return self

# ===== Getters =====

func get_float(key: String, default: float = 0.0) -> float:
	if key == "intensity":
		return intensity
	elif key == "duration":
		return duration if duration >= 0 else default
	return _data.get(key, default)

func get_int(key: String, default: int = 0) -> int:
	if key == "intensity":
		return int(intensity)
	elif key == "duration":
		return int(duration) if duration >= 0 else default
	return _data.get(key, default)

func get_bool(key: String, default: bool = false) -> bool:
	return _data.get(key, default)

func get_vector2(key: String, default: Vector2 = Vector2.ZERO) -> Vector2:
	var value = _data.get(key, default)
	if value is Vector3:
		return Vector2(value.x, value.y)
	return value

func get_vector3(key: String, default: Vector3 = Vector3.ZERO) -> Vector3:
	var value = _data.get(key, default)
	if value is Vector2:
		return Vector3(value.x, value.y, 0)
	return value

func get_color(key: String, default: Color = Color.WHITE) -> Color:
	return _data.get(key, default)

func get_string(key: String, default: String = "") -> String:
	return _data.get(key, default)

func get_curve(key: String, default: Curve = null) -> Curve:
	return _data.get(key, default)

func get_node(key: String, default: Node = null) -> Node:
	return _data.get(key, default)

func get_resource(key: String, default: Resource = null) -> Resource:
	return _data.get(key, default)

func get_variant(key: String, default: Variant = null) -> Variant:
	return _data.get(key, default)

# ===== Factory Methods =====

static func create(p_intensity: float = 1.0, p_duration: float = -1.0) -> GFFParams:
	var params = GFFParams.new()
	params.intensity = p_intensity
	params.duration = p_duration
	return params

static func from_dict(dict: Dictionary) -> GFFParams:
	var params = GFFParams.new()
	for key in dict:
		if key == "intensity":
			params.intensity = dict[key]
		elif key == "duration":
			params.duration = dict[key]
		else:
			params._data[key] = dict[key]
	return params
