class_name GFFCombo
extends Resource

## Game Feel Flow Combo
##
## 组合效果，预定义常用效果组合

# ===== 属性 =====
@export var label: String = ""
@export var effects: Array = []
@export var default_params: GFFParams = null

# ===== 预定义组合 =====

static func hit_light() -> GFFCombo:
	## 轻击效果
	var combo = GFFCombo.new()
	combo.label = "hit_light"
	combo.effects = [
		_create_shake(0.5, 0.15),
		_create_flash(Color.WHITE, 0.1),
		_create_scale(Vector2(1.1, 1.1), 0.15),
	]
	return combo

static func hit_heavy() -> GFFCombo:
	## 重击效果
	var combo = GFFCombo.new()
	combo.label = "hit_heavy"
	combo.effects = [
		_create_shake(1.0, 0.3),
		_create_flash(Color.WHITE, 0.15),
		_create_freeze(0.05),
		_create_scale(Vector2(1.3, 1.3), 0.2),
	]
	return combo

static func death() -> GFFCombo:
	## 死亡效果
	var combo = GFFCombo.new()
	combo.label = "death"
	combo.effects = [
		_create_shake(1.5, 0.5),
		_create_flash(Color.RED, 0.2),
		_create_freeze(0.1),
		_create_scale(Vector2(0.0, 0.0), 0.5),
		_create_alpha(0.0, 0.5),
	]
	return combo

static func pickup() -> GFFCombo:
	## 拾取效果
	var combo = GFFCombo.new()
	combo.label = "pickup"
	combo.effects = [
		_create_scale(Vector2(1.3, 1.3), 0.15),
		_create_flash(Color.YELLOW, 0.1),
	]
	return combo

static func explosion() -> GFFCombo:
	## 爆炸效果
	var combo = GFFCombo.new()
	combo.label = "explosion"
	combo.effects = [
		_create_shake(2.0, 0.5),
		_create_flash(Color.ORANGE, 0.2),
		_create_freeze(0.1),
		_create_scale(Vector2(1.5, 1.5), 0.3),
	]
	return combo

# ===== 执行方法 =====

func execute(player: GFFPlayer, params: GFFParams = null) -> void:
	## 执行组合效果
	for effect in effects:
		if effect.get("enabled") == null or effect.enabled:
			await effect.apply(player, params)

# ===== 辅助方法 =====

static func _create_shake(intensity: float, duration: float):
	## 创建震动效果
	var effect = load("res://addons/game_feel_flow/effects/gff_shake.gd").new()
	effect.default_intensity = intensity
	effect.default_duration = duration
	return effect

static func _create_flash(color: Color, duration: float):
	## 创建闪白效果
	var effect = load("res://addons/game_feel_flow/effects/gff_flash.gd").new()
	effect.default_color = color
	effect.default_duration = duration
	return effect

static func _create_freeze(duration: float):
	## 创建冻结帧效果
	var effect = load("res://addons/game_feel_flow/effects/gff_freeze_frame.gd").new()
	effect.default_duration = duration
	return effect

static func _create_scale(target_scale: Vector2, duration: float):
	## 创建缩放效果
	var effect = load("res://addons/game_feel_flow/effects/gff_scale.gd").new()
	effect.default_target_scale = target_scale
	effect.default_duration = duration
	return effect

static func _create_alpha(target_alpha: float, duration: float):
	## 创建透明度效果
	var effect = load("res://addons/game_feel_flow/effects/gff_alpha.gd").new()
	effect.default_alpha = target_alpha
	effect.default_duration = duration
	return effect
