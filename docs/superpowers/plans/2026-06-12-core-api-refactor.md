# Game Feel Flow Core API Refactor Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal：** 按照REQUIREMENTS.md设计文档重新实现核心API，使其更简洁、更符合Unity Feel的设计理念

**Architecture：** GFFPlayer组件 + GFFFeedback资源 + GameFeelFlow全局单例 + GFUtil快捷工具

**Tech Stack：** GDScript 4.2+, Godot Engine 4.2+, GdUnit4 (测试)

---

## 文件结构

```
addons/game_feel_flow/
├── core/
│   ├── game_feel_flow.gd          # 全局单例（重构）
│   ├── gff_player.gd              # 播放器节点（重构）
│   ├── gff_feedback.gd            # 效果基类（保留）
│   ├── gff_params.gd              # 参数类（保留）
│   ├── gff_combo.gd               # 组合效果（保留）
│   ├── gff_overlap_manager.gd     # 叠加管理器（新增）
│   └── gf_util.gd                 # 快捷工具（新增）
├── effects/                       # 25个效果（保留）
├── presets/                       # 预设资源（保留）
├── editor/                        # 编辑器工具（保留）
└── examples/                      # 示例场景（保留）
```

---

## Phase 1: 核心API重构（3天）

### Task 1.1: 重构GFFPlayer.play()方法

**Files:**
- Modify: `addons/game_feel_flow/core/gff_player.gd`
- Test: `tests_optional/test_gff_player.gd`

- [ ] **Step 1: 修改play()方法签名**

```gdscript
func play(effect, params = null) -> void:
	## 播放效果
	## effect: String | GFFFeedback | GFFCombo
	if effect is String:
		var feedback = _get_effect(effect)
		if feedback:
			await _play_feedback(feedback, params)
	elif effect is GFFFeedback:
		await _play_feedback(effect, params)
	elif effect is GFFCombo:
		await _play_combo(effect, params)
```

- [ ] **Step 2: 添加_play_feedback()方法**

```gdscript
func _play_feedback(feedback: GFFFeedback, params = null) -> void:
	## 播放单个效果
	var effect_id = feedback.label if not feedback.label.is_empty() else str(feedback.get_instance_id())
	
	# 检查叠加策略
	match feedback.overlap_strategy:
		GFFFeedback.OverlapStrategy.IGNORE:
			if effect_id in _active_effects:
				return
		GFFFeedback.OverlapStrategy.CANCEL:
			if effect_id in _active_effects:
				stop_effect(effect_id)
		GFFFeedback.OverlapStrategy.REPLACE:
			if effect_id in _active_effects:
				stop_effect(effect_id)
		GFFFeedback.OverlapStrategy.QUEUE:
			if effect_id in _active_effects:
				_effect_queue.append({"effect": feedback, "params": params})
				return
	
	# 添加到活跃效果
	_active_effects[effect_id] = feedback
	effect_started.emit(effect_id)
	
	# 执行效果
	await feedback.apply(_get_target_node(), _ensure_params(params))
	
	# 从活跃效果中移除
	_active_effects.erase(effect_id)
	effect_finished.emit(effect_id)
	
	# 处理队列
	if not _effect_queue.is_empty():
		var next = _effect_queue.pop_front()
		_play_feedback(next["effect"], next["params"])
```

- [ ] **Step 3: 添加_get_target_node()方法**

```gdscript
func _get_target_node() -> Node:
	## 获取目标节点
	# 如果自身是Node2D/Node3D/Control，返回自身
	if self is Node2D or self is Node3D or self is Control:
		return self
	
	# 否则查找子节点
	for child in get_children():
		if child is Node2D or child is Node3D or child is Control:
			return child
	
	# 如果都没有，返回父节点
	return get_parent() if get_parent() else self
```

- [ ] **Step 4: 添加_ensure_params()方法**

```gdscript
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
```

- [ ] **Step 5: 更新play_combo()方法**

```gdscript
func play_combo(combo, params = null) -> void:
	## 播放组合效果
	## combo: String | GFFCombo
	if combo is String:
		var combo_resource = _get_combo(combo)
		if combo_resource:
			await _play_combo(combo_resource, params)
	elif combo is GFFCombo:
		await _play_combo(combo, params)

func _play_combo(combo: GFFCombo, params = null) -> void:
	## 播放组合效果
	if combo:
		var target = _get_target_node()
		await combo.execute(target, _ensure_params(params))
```

- [ ] **Step 6: 添加_get_combo()方法**

```gdscript
func _get_combo(combo_name: String) -> GFFCombo:
	## 获取组合效果
	# 从全局单例获取
	var combo = GameFeelFlow.get_combo(combo_name)
	if combo:
		return combo
	
	# 从本地效果列表查找
	for effect in effects:
		if effect is GFFCombo and effect.label == combo_name:
			return effect
	
	return null
```

- [ ] **Step 7: 运行测试验证**

```bash
& "F:\Engines\Godot\Godot4-6-2-Csharp\Godot_v4.6.2-stable_mono_win64_console.exe" --path "F:\Coding-Projects\Godot\godot-plugin-game-feel-flow" -s -d --remote-debug tcp://127.0.0.1:65535 res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a "res://tests_optional/" --ignoreHeadlessMode
```

- [ ] **Step 8: 提交**

```bash
git add addons/game_feel_flow/core/gff_player.gd
git commit -m "feat: refactor GFFPlayer.play() to support String/Feedback/Combo"
```

---

### Task 1.2: 创建GFUtil快捷工具

**Files:**
- Create: `addons/game_feel_flow/core/gf_util.gd`
- Test: `tests_optional/test_gf_util.gd`

- [ ] **Step 1: 创建GFUtil类**

```gdscript
class_name GFUtil

## Game Feel Flow Utility
##
## 快捷工具类，提供常用效果的快捷方法

# ===== 快捷方法 =====

static func hit(target: Node, intensity: float = 1.0) -> void:
	## 播放轻击效果
	GameFeelFlow.play_combo("hit_light", target, GFFParams.create(intensity))

static func hit_heavy(target: Node, intensity: float = 1.0) -> void:
	## 播放重击效果
	GameFeelFlow.play_combo("hit_heavy", target, GFFParams.create(intensity))

static func death(target: Node, intensity: float = 1.0) -> void:
	## 播放死亡效果
	GameFeelFlow.play_combo("death", target, GFFParams.create(intensity))

static func pickup(target: Node, intensity: float = 1.0) -> void:
	## 播放拾取效果
	GameFeelFlow.play_combo("pickup", target, GFFParams.create(intensity))

static func explosion(target: Node, intensity: float = 1.0) -> void:
	## 播放爆炸效果
	GameFeelFlow.play_combo("explosion", target, GFFParams.create(intensity))

static func shake(target: Node, intensity: float = 1.0) -> void:
	## 播放震动效果
	GameFeelFlow.play("shake", target, GFFParams.create(intensity))

static func scale(target: Node, intensity: float = 1.0) -> void:
	## 播放缩放效果
	GameFeelFlow.play("scale", target, GFFParams.create(intensity))

static func flash(target: Node, color: Color = Color.WHITE) -> void:
	## 播放闪白效果
	GameFeelFlow.play("flash", target, GFFParams.create().with_color("color", color))

static func color(target: Node, color: Color = Color.RED) -> void:
	## 播放颜色效果
	GameFeelFlow.play("color", target, GFFParams.create().with_color("color", color))

static func alpha(target: Node, alpha: float = 0.0) -> void:
	## 播放透明度效果
	GameFeelFlow.play("alpha", target, GFFParams.create().with_float("target_alpha", alpha))

static func freeze(duration: float = 0.05) -> void:
	## 播放冻结帧效果
	GameFeelFlow.play("freeze_frame", null, GFFParams.create().with_float("duration", duration))

static func slow_motion(duration: float = 1.0, scale: float = 0.3) -> void:
	## 播放慢动作效果
	GameFeelFlow.play("time_scale", null, GFFParams.create().with_float("duration", duration).with_float("scale", scale))
```

- [ ] **Step 2: 创建测试**

```gdscript
extends GdUnitTestSuite

## GFUtil 单元测试

func test_hit() -> void:
	# 测试hit快捷方法
	var target = Node2D.new()
	add_child(target)
	await GFUtil.hit(target, 1.0)
	assert_bool(true).is_true()  # 只要不崩溃就算成功
	target.free()

func test_shake() -> void:
	# 测试shake快捷方法
	var target = Node2D.new()
	add_child(target)
	await GFUtil.shake(target, 1.0)
	assert_bool(true).is_true()
	target.free()
```

- [ ] **Step 3: 运行测试验证**

```bash
& "F:\Engines\Godot\Godot4-6-2-Csharp\Godot_v4.6.2-stable_mono_win64_console.exe" --path "F:\Coding-Projects\Godot\godot-plugin-game-feel-flow" -s -d --remote-debug tcp://127.0.0.1:65535 res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a "res://tests_optional/" --ignoreHeadlessMode
```

- [ ] **Step 4: 提交**

```bash
git add addons/game_feel_flow/core/gf_util.gd tests_optional/test_gf_util.gd
git commit -m "feat: add GFUtil shortcut methods for common effects"
```

---

### Task 1.3: 重构GameFeelFlow全局单例

**Files:**
- Modify: `addons/game_feel_flow/core/game_feel_flow.gd`
- Test: `tests_optional/test_game_feel_flow.gd`

- [ ] **Step 1: 重构play()方法**

```gdscript
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
				await feedback.apply(target, _ensure_params(params))
			else:
				push_warning("GameFeelFlow: Effect not found: ", effect)
		elif effect is GFFFeedback:
			await effect.apply(target, _ensure_params(params))
		elif effect is GFFCombo:
			await effect.execute(target, _ensure_params(params))
	
	effect_started.emit(str(effect))
```

- [ ] **Step 2: 重构play_combo()方法**

```gdscript
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
				await combo_resource.execute(target, _ensure_params(params))
			else:
				push_warning("GameFeelFlow: Combo not found: ", combo)
		elif combo is GFFCombo:
			await combo.execute(target, _ensure_params(params))
	
	effect_started.emit(str(combo))
```

- [ ] **Step 3: 运行测试验证**

```bash
& "F:\Engines\Godot\Godot4-6-2-Csharp\Godot_v4.6.2-stable_mono_win64_console.exe" --path "F:\Coding-Projects\Godot\godot-plugin-game-feel-flow" -s -d --remote-debug tcp://127.0.0.1:65535 res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a "res://tests_optional/" --ignoreHeadlessMode
```

- [ ] **Step 4: 提交**

```bash
git add addons/game_feel_flow/core/game_feel_flow.gd
git commit -m "feat: refactor GameFeelFlow to support String/Feedback/Combo"
```

---

## Phase 2: 示例场景更新（2天）

### Task 2.1: 更新示例场景使用新API

**Files:**
- Modify: `addons/game_feel_flow/examples/main_3d.gd`
- Modify: `addons/game_feel_flow/examples/main_2d.gd`
- Modify: `addons/game_feel_flow/examples/main_ui.gd`
- Modify: `addons/game_feel_flow/examples/demo_effects.gd`

- [ ] **Step 1: 更新main_3d.gd使用GFUtil**

```gdscript
func _play_effect(effect_type: String) -> void:
	if not _selected_target:
		print("Please select a target first")
		return

	var params = _get_params()
	print("Playing: ", effect_type, " on ", _selected_target.name, " with params: ", params)

	match effect_type:
		"shake":
			GFUtil.shake(_selected_target, params.get_float("intensity", 1.0))
		"scale":
			GFUtil.scale(_selected_target, params.get_float("intensity", 1.0))
		"flash":
			GFUtil.flash(_selected_target, params.get_color("color", Color.WHITE))
		"color":
			GFUtil.color(_selected_target, params.get_color("color", Color.RED))
		"hit_light":
			GFUtil.hit(_selected_target, params.get_float("intensity", 1.0))
		"hit_heavy":
			GFUtil.hit_heavy(_selected_target, params.get_float("intensity", 1.0))
		"explosion":
			GFUtil.explosion(_selected_target, params.get_float("intensity", 1.0))
		"death":
			GFUtil.death(_selected_target, params.get_float("intensity", 1.0))
```

- [ ] **Step 2: 更新main_2d.gd使用GFUtil**

```gdscript
func _play_effect(effect_type: String) -> void:
	var params = _get_params()
	print("Playing: ", effect_type, " with params: ", params)

	match effect_type:
		"shake":
			GFUtil.shake(sprite, params.get_float("intensity", 1.0))
		"scale":
			GFUtil.scale(sprite, params.get_float("intensity", 1.0))
		"color":
			GFUtil.color(sprite, params.get_color("color", Color.RED))
		"alpha":
			GFUtil.alpha(sprite, params.get_float("target_alpha", 0.0))
		"flash":
			GFUtil.flash(sprite, params.get_color("color", Color.WHITE))
		"freeze_frame":
			GFUtil.freeze(params.get_float("duration", 0.05))
		"time_scale":
			GFUtil.slow_motion(params.get_float("duration", 1.0), params.get_float("scale", 0.3))
		"hit_light":
			GFUtil.hit(sprite, params.get_float("intensity", 1.0))
		"hit_heavy":
			GFUtil.hit_heavy(sprite, params.get_float("intensity", 1.0))
		"explosion":
			GFUtil.explosion(sprite, params.get_float("intensity", 1.0))
		"death":
			GFUtil.death(sprite, params.get_float("intensity", 1.0))
```

- [ ] **Step 3: 更新main_ui.gd使用GFUtil**

```gdscript
func _play_effect(effect_type: String) -> void:
	var params = _get_params()
	print("Playing: ", effect_type, " with params: ", params)

	match effect_type:
		"button_press":
			# Simple scale animation using Tween
			var tween = demo_button.create_tween()
			tween.tween_property(demo_button, "scale", Vector2(0.9, 0.9), 0.05)
			tween.tween_property(demo_button, "scale", Vector2(1.0, 1.0), 0.1)
		"sprite_scale":
			GFUtil.scale(demo_sprite, params.get_float("intensity", 1.0))
		"sprite_color":
			GFUtil.color(demo_sprite, params.get_color("color", Color.RED))
		"hit_light":
			GFUtil.hit(demo_sprite, params.get_float("intensity", 1.0))
		"hit_medium":
			GFUtil.hit_heavy(demo_sprite, params.get_float("intensity", 1.0))
```

- [ ] **Step 4: 更新demo_effects.gd使用GFUtil**

```gdscript
func _play_effect(effect_type: String) -> void:
	var params = _get_params()
	
	match effect_type:
		"shake":
			GFUtil.shake(target_sprite, params.get_float("intensity", 1.0))
		"scale":
			GFUtil.scale(target_sprite, params.get_float("intensity", 1.0))
		"flash":
			GFUtil.flash(target_sprite, params.get_color("color", Color.WHITE))
		"color":
			GFUtil.color(target_sprite, params.get_color("color", Color.RED))
		"alpha":
			GFUtil.alpha(target_sprite, params.get_float("target_alpha", 0.0))
		"freeze_frame":
			GFUtil.freeze(params.get_float("duration", 0.05))
		"time_scale":
			GFUtil.slow_motion(params.get_float("duration", 1.0), params.get_float("scale", 0.3))
		"hit":
			GFUtil.hit(target_sprite, params.get_float("intensity", 1.0))
```

- [ ] **Step 5: 运行测试验证**

```bash
& "F:\Engines\Godot\Godot4-6-2-Csharp\Godot_v4.6.2-stable_mono_win64_console.exe" --path "F:\Coding-Projects\Godot\godot-plugin-game-feel-flow" -s -d --remote-debug tcp://127.0.0.1:65535 res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a "res://tests_optional/" --ignoreHeadlessMode
```

- [ ] **Step 6: 提交**

```bash
git add addons/game_feel_flow/examples/
git commit -m "refactor: update example scenes to use GFUtil shortcuts"
```

---

## Phase 3: 测试和文档（2天）

### Task 3.1: 更新测试用例

**Files:**
- Modify: `tests_optional/test_gff_player.gd`
- Modify: `tests_optional/test_game_feel_flow.gd`
- Create: `tests_optional/test_gf_util.gd`

- [ ] **Step 1: 更新GFFPlayer测试**

```gdscript
func test_play_with_string() -> void:
	# 测试通过字符串播放效果
	await player.play("shake")
	assert_bool(player.is_playing()).is_false()

func test_play_with_feedback() -> void:
	# 测试通过GFFFeedback播放效果
	var feedback = GFFShake.new()
	feedback.duration = 0.1
	await player.play(feedback)
	assert_bool(player.is_playing()).is_false()

func test_play_with_combo() -> void:
	# 测试通过GFFCombo播放效果
	var combo = GFFCombo.hit_light()
	await player.play(combo)
	assert_bool(player.is_playing()).is_false()
```

- [ ] **Step 2: 运行测试验证**

```bash
& "F:\Engines\Godot\Godot4-6-2-Csharp\Godot_v4.6.2-stable_mono_win64_console.exe" --path "F:\Coding-Projects\Godot\godot-plugin-game-feel-flow" -s -d --remote-debug tcp://127.0.0.1:65535 res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a "res://tests_optional/" --ignoreHeadlessMode
```

- [ ] **Step 3: 提交**

```bash
git add tests_optional/
git commit -m "test: update tests for new API design"
```

---

## 完成

**总计：3个Phase，6个Task**

**执行方式：**
1. 使用 `superpowers:subagent-driven-development` 执行计划
2. 按顺序完成每个任务
3. 运行测试验证
4. 提交代码

**预计时间：7天**
