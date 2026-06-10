class_name GFFEffectConfig
extends Resource

## Game Feel Flow Effect Configuration
##
## Defines parameters for an effect

# ===== Parameter Type =====
enum ParamType {
	FLOAT,
	INT,
	BOOL,
	VECTOR2,
	COLOR,
}

# ===== Properties =====
@export var name: String = ""
@export var display_name: String = ""
@export var param_type: ParamType = ParamType.FLOAT
@export var default_value: Variant = null
@export var min_value: float = 0.0
@export var max_value: float = 100.0
@export var step: float = 0.1
@export var description: String = ""

# ===== Static Factory Methods =====

static func float_param(p_name: String, p_display: String, p_default: float, p_min: float = 0.0, p_max: float = 100.0, p_step: float = 0.1) -> GFFEffectConfig:
	var config = GFFEffectConfig.new()
	config.name = p_name
	config.display_name = p_display
	config.param_type = ParamType.FLOAT
	config.default_value = p_default
	config.min_value = p_min
	config.max_value = p_max
	config.step = p_step
	return config

static func int_param(p_name: String, p_display: String, p_default: int, p_min: int = 0, p_max: int = 100) -> GFFEffectConfig:
	var config = GFFEffectConfig.new()
	config.name = p_name
	config.display_name = p_display
	config.param_type = ParamType.INT
	config.default_value = p_default
	config.min_value = p_min
	config.max_value = p_max
	config.step = 1
	return config

static func bool_param(p_name: String, p_display: String, p_default: bool) -> GFFEffectConfig:
	var config = GFFEffectConfig.new()
	config.name = p_name
	config.display_name = p_display
	config.param_type = ParamType.BOOL
	config.default_value = p_default
	return config

static func vector2_param(p_name: String, p_display: String, p_default: Vector2) -> GFFEffectConfig:
	var config = GFFEffectConfig.new()
	config.name = p_name
	config.display_name = p_display
	config.param_type = ParamType.VECTOR2
	config.default_value = p_default
	return config

static func color_param(p_name: String, p_display: String, p_default: Color) -> GFFEffectConfig:
	var config = GFFEffectConfig.new()
	config.name = p_name
	config.display_name = p_display
	config.param_type = ParamType.COLOR
	config.default_value = p_default
	return config
