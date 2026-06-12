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

func play(effect, target: Node, params = null) -> void:
	## 播放效果
	## effect: String | GFFFeedback | GFFCombo
	if debug_enabled:
		print("GameFeelFlow: Playing effect on ", target.name)

	# 查找GFFPlayer
	var player = _find_player(target)

	if player:
		# 使用GFFPlayer播放
		await player.play(effect, params)
	else:
		# 直接播放
		if effect is String:
			var feedback = get_effect(effect)
			if feedback:
				effect_started.emit(effect)
				await feedback.apply(target, _ensure_params(params))
				effect_finished.emit(effect)
			else:
				push_warning("GameFeelFlow: Effect not found: ", effect)
		elif effect is GFFFeedback:
			effect_started.emit(effect.label if effect.label else "unknown")
			await effect.apply(target, _ensure_params(params))
			effect_finished.emit(effect.label if effect.label else "unknown")
		elif effect is GFFCombo:
			effect_started.emit(effect.label if effect.label else "unknown")
			await effect.execute(target, _ensure_params(params))
			effect_finished.emit(effect.label if effect.label else "unknown")

func play_combo(combo, target: Node, params = null) -> void:
	## 播放组合效果
	## combo: String | GFFCombo
	if debug_enabled:
		print("GameFeelFlow: Playing combo on ", target.name)

	# 查找GFFPlayer
	var player = _find_player(target)

	if player:
		# 使用GFFPlayer播放
		await player.play_combo(combo, params)
	else:
		# 直接播放
		if combo is String:
			var combo_resource = get_combo(combo)
			if combo_resource:
				effect_started.emit(combo)
				await combo_resource.execute(target, _ensure_params(params))
				effect_finished.emit(combo)
			else:
				push_warning("GameFeelFlow: Combo not found: ", combo)
		elif combo is GFFCombo:
			effect_started.emit(combo.label if combo.label else "unknown")
			await combo.execute(target, _ensure_params(params))
			effect_finished.emit(combo.label if combo.label else "unknown")

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
		"shake": "res://addons/game_feel_flow/effects/transform/gff_shake.gd",
		"scale": "res://addons/game_feel_flow/effects/transform/gff_scale.gd",
		"position": "res://addons/game_feel_flow/effects/transform/gff_position.gd",
		"rotation": "res://addons/game_feel_flow/effects/transform/gff_rotation.gd",
		"camera_shake": "res://addons/game_feel_flow/effects/camera/gff_camera_shake.gd",
		"camera_zoom": "res://addons/game_feel_flow/effects/camera/gff_camera_zoom.gd",
		"camera_flash": "res://addons/game_feel_flow/effects/camera/gff_camera_flash.gd",
		"flash": "res://addons/game_feel_flow/effects/visual/gff_flash.gd",
		"color": "res://addons/game_feel_flow/effects/visual/gff_color.gd",
		"alpha": "res://addons/game_feel_flow/effects/visual/gff_alpha.gd",
		"flicker": "res://addons/game_feel_flow/effects/visual/gff_flicker.gd",
		"sound": "res://addons/game_feel_flow/effects/audio/gff_sound.gd",
		"audio_volume": "res://addons/game_feel_flow/effects/audio/gff_audio_volume.gd",
		"freeze_frame": "res://addons/game_feel_flow/effects/time/gff_freeze_frame.gd",
		"time_scale": "res://addons/game_feel_flow/effects/time/gff_time_scale.gd",
		"particles": "res://addons/game_feel_flow/effects/particles/gff_particles.gd",
		"gpu_particles": "res://addons/game_feel_flow/effects/particles/gff_gpu_particles.gd",
		"impulse": "res://addons/game_feel_flow/effects/physics/gff_impulse.gd",
		"velocity": "res://addons/game_feel_flow/effects/physics/gff_velocity.gd",
		"tween": "res://addons/game_feel_flow/effects/animation/gff_tween.gd",
		"animator": "res://addons/game_feel_flow/effects/animation/gff_animator.gd",
		"ui_shake": "res://addons/game_feel_flow/effects/ui/gff_ui_shake.gd",
		"ui_color": "res://addons/game_feel_flow/effects/ui/gff_ui_color.gd",
		"ui_scale": "res://addons/game_feel_flow/effects/ui/gff_ui_scale.gd",
		"ui_alpha": "res://addons/game_feel_flow/effects/ui/gff_ui_alpha.gd",
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
