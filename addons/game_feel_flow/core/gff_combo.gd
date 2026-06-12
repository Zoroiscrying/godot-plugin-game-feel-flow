class_name GFFCombo
extends Resource

## Game Feel Flow Combo
##
## 组合效果，预定义常用效果组合

# ===== 属性 =====
@export var label: String = ""
@export var effects: Array[GFFFeedback] = []
@export var default_params: GFFParams = null

# ===== 预定义组合 =====

static func hit_light() -> GFFCombo:
	## 轻击效果
	var combo = GFFCombo.new()
	combo.label = "hit_light"
	var arr: Array[GFFFeedback] = []
	arr.append(_create_shake(0.3, 0.08))
	arr.append(_create_flash(Color.WHITE, 0.04))
	arr.append(_create_scale(Vector2(1.05, 1.05), 0.08))
	combo.effects = arr
	return combo

static func hit_heavy() -> GFFCombo:
	## 重击效果
	var combo = GFFCombo.new()
	combo.label = "hit_heavy"
	var arr: Array[GFFFeedback] = []
	arr.append(_create_shake(0.6, 0.12))
	arr.append(_create_flash(Color.WHITE, 0.06))
	arr.append(_create_freeze(0.02))
	arr.append(_create_scale(Vector2(1.15, 1.15), 0.12))
	combo.effects = arr
	return combo

static func death() -> GFFCombo:
	## 死亡效果
	var combo = GFFCombo.new()
	combo.label = "death"
	var arr: Array[GFFFeedback] = []
	arr.append(_create_shake(0.8, 0.2))
	arr.append(_create_flash(Color.RED, 0.08))
	arr.append(_create_freeze(0.04))
	arr.append(_create_scale(Vector2(0.9, 0.9), 0.15))
	arr.append(_create_alpha(0.0, 0.2))
	combo.effects = arr
	return combo

static func pickup() -> GFFCombo:
	## 拾取效果
	var combo = GFFCombo.new()
	combo.label = "pickup"
	var arr: Array[GFFFeedback] = []
	arr.append(_create_scale(Vector2(1.1, 1.1), 0.08))
	arr.append(_create_flash(Color.YELLOW, 0.04))
	combo.effects = arr
	return combo

static func explosion() -> GFFCombo:
	## 爆炸效果
	var combo = GFFCombo.new()
	combo.label = "explosion"
	var arr: Array[GFFFeedback] = []
	arr.append(_create_shake(1.0, 0.2))
	arr.append(_create_flash(Color.ORANGE, 0.08))
	arr.append(_create_freeze(0.04))
	arr.append(_create_scale(Vector2(1.2, 1.2), 0.15))
	combo.effects = arr
	return combo

# ===== 执行方法 =====

func execute(target: Node, params: GFFParams = null) -> void:
	## 执行组合效果
	for effect in effects:
		if effect.get("enabled") == null or effect.enabled:
			await effect.apply(target, params)

# ===== 辅助方法 =====

static func _create_shake(p_amplitude: float, p_duration: float):
	## 创建震动效果
	var effect = load("res://addons/game_feel_flow/effects/transform/gff_shake.gd").new()
	effect.amplitude = p_amplitude
	effect.duration = p_duration
	return effect

static func _create_flash(color: Color, p_duration: float):
	## 创建闪白效果
	var effect = load("res://addons/game_feel_flow/effects/visual/gff_flash.gd").new()
	effect.flash_color = color
	effect.duration = p_duration
	return effect

static func _create_freeze(p_duration: float):
	## 创建冻结帧效果
	var effect = load("res://addons/game_feel_flow/effects/time/gff_freeze_frame.gd").new()
	effect.duration = p_duration
	return effect

static func _create_scale(target_scale: Vector2, p_duration: float):
	## 创建缩放效果
	var effect = load("res://addons/game_feel_flow/effects/transform/gff_scale.gd").new()
	effect.target_scale = target_scale
	effect.duration = p_duration
	return effect

static func _create_alpha(target_alpha: float, p_duration: float):
	## 创建透明度效果
	var effect = load("res://addons/game_feel_flow/effects/visual/gff_alpha.gd").new()
	effect.target_alpha = target_alpha
	effect.duration = p_duration
	return effect
