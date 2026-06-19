class_name GFFCombo
extends Resource

## Game Feel Flow Combo
##
## 组合效果，支持顺序、并行和时间线控制

# ===== 属性 =====
@export var label: String = ""
@export var entries: Array[GFFComboEntry] = []
@export var default_params: GFFParams = null

# ===== 内部类 =====

class GFFComboEntry:
	extends Resource
	
	@export var effect: GFFFeedback = null
	@export var start_time: float = 0.0  # 相对于组合开始的时间
	@export var wait_for_previous: bool = false  # 是否等待前一个效果完成
	@export var enabled: bool = true

# ===== 预定义组合 =====

static func hit_light() -> GFFCombo:
	## 轻击效果
	var combo = GFFCombo.new()
	combo.label = "hit_light"
	combo.entries = [
		_create_entry(_create_shake(0.3, 0.08), 0.0, false),
		_create_entry(_create_flash(Color.WHITE, 0.04), 0.0, false),
		_create_entry(_create_punch_scale(Vector2(0.1, 0.1), 0.15), 0.0, false),
	]
	return combo

static func hit_heavy() -> GFFCombo:
	## 重击效果
	var combo = GFFCombo.new()
	combo.label = "hit_heavy"
	combo.entries = [
		_create_entry(_create_shake(0.6, 0.12), 0.0, false),
		_create_entry(_create_flash(Color.WHITE, 0.06), 0.0, false),
		_create_entry(_create_freeze(0.02), 0.06, true),  # 等待flash完成
		_create_entry(_create_punch_scale(Vector2(0.2, 0.2), 0.2), 0.08, false),
	]
	return combo

static func death() -> GFFCombo:
	## 死亡效果
	var combo = GFFCombo.new()
	combo.label = "death"
	combo.entries = [
		_create_entry(_create_shake(0.8, 0.2), 0.0, false),
		_create_entry(_create_flash(Color.RED, 0.08), 0.0, false),
		_create_entry(_create_freeze(0.04), 0.08, true),
		_create_entry(_create_punch_scale(Vector2(-0.2, -0.2), 0.3), 0.12, false),
		_create_entry(_create_alpha(0.0, 0.2), 0.3, false),
	]
	return combo

static func pickup() -> GFFCombo:
	## 拾取效果
	var combo = GFFCombo.new()
	combo.label = "pickup"
	combo.entries = [
		_create_entry(_create_punch_scale(Vector2(0.15, 0.15), 0.12), 0.0, false),
		_create_entry(_create_flash(Color.YELLOW, 0.04), 0.0, false),
	]
	return combo

static func explosion() -> GFFCombo:
	## 爆炸效果
	var combo = GFFCombo.new()
	combo.label = "explosion"
	combo.entries = [
		_create_entry(_create_shake(1.0, 0.2), 0.0, false),
		_create_entry(_create_flash(Color.ORANGE, 0.08), 0.0, false),
		_create_entry(_create_freeze(0.04), 0.08, true),
		_create_entry(_create_punch_scale(Vector2(0.25, 0.25), 0.25), 0.12, false),
	]
	return combo

# ===== 执行方法 =====

func execute(target: Node, params: GFFParams = null) -> void:
	## 执行组合效果
	var start_time = Time.get_ticks_msec() / 1000.0
	
	for entry in entries:
		if not entry.enabled:
			continue
		
		# 等待到开始时间
		var current_time = Time.get_ticks_msec() / 1000.0
		var elapsed = current_time - start_time
		var wait_time = entry.start_time - elapsed
		
		if wait_time > 0:
			await target.get_tree().create_timer(wait_time).timeout
		
		# 如果需要等待前一个效果完成
		if entry.wait_for_previous:
			await entry.effect.apply(target, params)
		else:
			# 并行执行
			entry.effect.apply(target, params)

# ===== 辅助方法 =====

static func _create_entry(effect: GFFFeedback, start_time: float, wait_for_previous: bool) -> GFFComboEntry:
	## 创建组合条目
	var entry = GFFComboEntry.new()
	entry.effect = effect
	entry.start_time = start_time
	entry.wait_for_previous = wait_for_previous
	return entry

static func _create_shake(p_amplitude: float, p_duration: float):
	## 创建震动效果
	var effect = GFFCurvedBase.new()
	effect.target_type = GFFCurvedBase.TargetType.POSITION
	effect.tweener_type = GFFCurvedBase.TweenerType.SHAKE
	effect.duration = p_duration
	effect._default_amplitude = p_amplitude
	return effect

static func _create_flash(color: Color, p_duration: float):
	## 创建闪白效果
	var effect = GFFCurvedBase.new()
	effect.target_type = GFFCurvedBase.TargetType.MODULATE
	effect.tweener_type = GFFCurvedBase.TweenerType.FLASH
	effect.duration = p_duration
	effect._default_flash_color = color
	return effect

static func _create_freeze(p_duration: float):
	## 创建冻结帧效果
	var effect = load("res://addons/game_feel_flow/effects/time/gff_freeze_frame.gd").new()
	effect.duration = p_duration
	return effect

static func _create_scale(target_scale: Vector2, p_duration: float):
	## 创建缩放效果
	var effect = GFFCurvedBase.new()
	effect.target_type = GFFCurvedBase.TargetType.SCALE
	effect.tweener_type = GFFCurvedBase.TweenerType.LINEAR
	effect.duration = p_duration
	effect._default_target_x = target_scale.x
	effect._default_target_y = target_scale.y
	return effect

static func _create_punch_scale(target_scale: Vector2, p_duration: float):
	## 创建冲击缩放效果
	var effect = GFFCurvedBase.new()
	effect.target_type = GFFCurvedBase.TargetType.SCALE
	effect.tweener_type = GFFCurvedBase.TweenerType.ELASTIC
	effect.punch_mode = GFFCurvedBase.PunchMode.TO_ORIGIN
	effect.duration = p_duration
	effect._default_target_x = target_scale.x
	effect._default_target_y = target_scale.y
	return effect

static func _create_alpha(target_alpha: float, p_duration: float):
	## 创建透明度效果
	var effect = GFFCurvedBase.new()
	effect.target_type = GFFCurvedBase.TargetType.MODULATE
	effect.tweener_type = GFFCurvedBase.TweenerType.COLOR
	effect.duration = p_duration
	effect._default_target_x = target_alpha
	return effect
