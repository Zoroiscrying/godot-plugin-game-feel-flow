extends Node

## Game Feel Flow
##
## 全局单例，提供快捷API和效果管理

# ===== 信号 =====
signal effect_started(effect_name: String)
signal effect_finished(effect_name: String)

# ===== 属性 =====
var debug_enabled: bool = false
var _effect_registry: Dictionary = {}
var _combo_registry: Dictionary = {}
var _overlap_manager: Node = null

# ===== 生命周期 =====

func _ready() -> void:
	print("Game Feel Flow: Initializing...")
	_register_effects()
	_register_combos()
	print("Game Feel Flow: Ready (", _effect_registry.size(), " effects, ", _combo_registry.size(), " combos)")

# ===== 核心API =====

func play(effect_name: String, target: Node, params = null) -> void:
	## 播放效果
	if debug_enabled:
		print("GameFeelFlow: Playing '", effect_name, "' on ", target.name)

	var effect = get_effect(effect_name)
	if not effect:
		push_warning("GameFeelFlow: Effect not found: ", effect_name)
		return

	# 检查目标节点
	var player = _find_player(target)
	if player:
		await player.play(effect_name, params)
	else:
		await effect.apply(target, _ensure_params(params))

	effect_started.emit(effect_name)

func play_combo(combo_name: String, target: Node, params = null) -> void:
	## 播放组合效果
	if debug_enabled:
		print("GameFeelFlow: Playing combo '", combo_name, "' on ", target.name)

	var combo = get_combo(combo_name)
	if not combo:
		push_warning("GameFeelFlow: Combo not found: ", combo_name)
		return

	var player = _find_player(target)
	if player:
		await player.play_combo(combo, _ensure_params(params))
	else:
		await combo.execute(null, _ensure_params(params))

func stop(target: Node) -> void:
	## 停止目标的所有效果
	var player = _find_player(target)
	if player:
		player.stop()

# ===== 注册方法 =====

func register_effect(name: String, effect: GFFFeedback) -> void:
	## 注册效果
	_effect_registry[name] = effect

func register_combo(name: String, combo: GFFCombo) -> void:
	## 注册组合效果
	_combo_registry[name] = combo

func get_effect(name: String) -> GFFFeedback:
	## 获取效果
	return _effect_registry.get(name)

func get_combo(name: String) -> GFFCombo:
	## 获取组合效果
	return _combo_registry.get(name)

# ===== 信号系统 =====

func emit(event: String, data: Dictionary = {}) -> void:
	## 发送事件
	if event in _signal_listeners:
		for callback in _signal_listeners[event]:
			callback.call(data)

func listen(event: String, callback: Callable) -> void:
	## 监听事件
	if event not in _signal_listeners:
		_signal_listeners[event] = []
	_signal_listeners[event].append(callback)

func unlisten(event: String, callback: Callable) -> void:
	## 取消监听
	if event in _signal_listeners:
		_signal_listeners[event].erase(callback)

# ===== 调试方法 =====

func set_debug(enabled: bool) -> void:
	## 设置调试模式
	debug_enabled = enabled

# ===== 内部方法 =====

var _signal_listeners: Dictionary = {}

func _register_effects() -> void:
	## 注册内置效果
	var effects = {
		"shake": "res://addons/game_feel_flow/effects/gff_shake.gd",
		"flash": "res://addons/game_feel_flow/effects/gff_flash.gd",
		"scale": "res://addons/game_feel_flow/effects/gff_scale.gd",
		"color": "res://addons/game_feel_flow/effects/gff_color.gd",
		"alpha": "res://addons/game_feel_flow/effects/gff_alpha.gd",
		"freeze_frame": "res://addons/game_feel_flow/effects/gff_freeze_frame.gd",
		"time_scale": "res://addons/game_feel_flow/effects/gff_time_scale.gd",
		"hit": "res://addons/game_feel_flow/effects/gff_hit.gd",
	}

	for name in effects:
		var path = effects[name]
		if ResourceLoader.exists(path):
			var script = load(path)
			if script:
				var effect = script.new()
				if effect is GFFFeedback:
					_effect_registry[name] = effect

func _register_combos() -> void:
	## 注册内置组合效果
	_combo_registry["hit_light"] = GFFCombo.hit_light()
	_combo_registry["hit_heavy"] = GFFCombo.hit_heavy()
	_combo_registry["death"] = GFFCombo.death()
	_combo_registry["pickup"] = GFFCombo.pickup()
	_combo_registry["explosion"] = GFFCombo.explosion()

func _find_player(target: Node) -> GFFPlayer:
	## 查找GFFPlayer节点
	if target is GFFPlayer:
		return target
	for child in target.get_children():
		if child is GFFPlayer:
			return child
	return null

func _ensure_params(params) -> GFFParams:
	## 确保参数是GFFParams类型
	if params == null:
		return GFFParams.create()
	elif params is float or params is int:
		return GFFParams.create(params)
	elif params is Dictionary:
		return GFFParams.from_dict(params)
	elif params is GFFParams:
		return params
	else:
		return GFFParams.create()
