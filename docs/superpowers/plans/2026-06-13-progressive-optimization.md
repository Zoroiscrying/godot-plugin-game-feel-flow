# Game Feel Flow 渐进式优化实施计划

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal：** 按照Unity Feel的设计理念，优化Game Feel Flow插件的效果质量、API设计、文档示例和编辑器工具

**Architecture：** 渐进式优化，在现有架构基础上逐步改进，保持向后兼容

**Tech Stack：** GDScript 4.2+, Godot Engine 4.2+, GdUnit4 (测试)

---

## 文件结构

```
addons/game_feel_flow/
├── core/
│   ├── game_feel_flow.gd          # 全局单例（保留）
│   ├── gff_player.gd              # 播放器节点（保留）
│   ├── gff_feedback.gd            # 效果基类（优化）
│   ├── gff_params.gd              # 参数类（保留）
│   ├── gff_combo.gd               # 组合效果（优化）
│   └── gf_util.gd                 # 快捷工具（保留）
├── effects/                       # 25个效果（优化默认参数）
├── presets/
│   ├── curves/                    # 曲线预设（新增）
│   │   ├── ease_in.tres
│   │   ├── ease_out.tres
│   │   ├── ease_in_out.tres
│   │   ├── bounce.tres
│   │   ├── elastic.tres
│   │   └── linear.tres
│   └── combos/                    # 组合效果预设（新增）
├── editor/
│   └── gff_debug_panel.gd         # 调试面板（保留）
└── examples/                      # 示例场景（优化）
```

---

## Phase 1: 效果质量优化（1周）

### Task 1.1: 调整默认参数

**Files:**
- Modify: `addons/game_feel_flow/core/gff_feedback.gd`
- Modify: `addons/game_feel_flow/effects/transform/gff_shake.gd`
- Modify: `addons/game_feel_flow/effects/transform/gff_scale.gd`
- Modify: `addons/game_feel_flow/core/gff_combo.gd`

- [ ] **Step 1: 调整GFFFeedback默认参数**

```gdscript
# gff_feedback.gd
@export var duration: float = 0.1  # 从0.2改为0.1
@export var delay: float = 0.0
@export var cooldown: float = 0.0

@export_group("Randomness")
@export var random_duration_min: float = 0.8
@export var random_duration_max: float = 1.2
@export var random_intensity_min: float = 0.9
@export var random_intensity_max: float = 1.1
```

- [ ] **Step 2: 调整GFFShake默认参数**

```gdscript
# gff_shake.gd
@export_group("Shake Settings")
@export var amplitude: float = 0.1  # 从10.0改为0.1
@export var frequency: float = 15.0
@export var axes: Vector3 = Vector3(1, 1, 0)
```

- [ ] **Step 3: 调整GFFScale默认参数**

```gdscript
# gff_scale.gd
@export_group("Scale Settings")
@export var target_scale: Vector2 = Vector2(1.1, 1.1)  # 从1.5改为1.1
@export var target_scale_3d: Vector3 = Vector3(1.1, 1.1, 1.1)
```

- [ ] **Step 4: 调整组合效果默认参数**

```gdscript
# gff_combo.gd
static func hit_light() -> GFFCombo:
    var combo = GFFCombo.new()
    combo.label = "hit_light"
    var arr: Array[GFFFeedback] = []
    arr.append(_create_shake(0.3, 0.08))  # 从0.5改为0.3
    arr.append(_create_flash(Color.WHITE, 0.04))
    arr.append(_create_scale(Vector2(1.05, 1.05), 0.08))  # 从1.1改为1.05
    combo.effects = arr
    return combo

static func hit_heavy() -> GFFCombo:
    var combo = GFFCombo.new()
    combo.label = "hit_heavy"
    var arr: Array[GFFFeedback] = []
    arr.append(_create_shake(0.6, 0.12))  # 从1.0改为0.6
    arr.append(_create_flash(Color.WHITE, 0.06))
    arr.append(_create_freeze(0.02))
    arr.append(_create_scale(Vector2(1.15, 1.15), 0.12))  # 从1.3改为1.15
    combo.effects = arr
    return combo

static func death() -> GFFCombo:
    var combo = GFFCombo.new()
    combo.label = "death"
    var arr: Array[GFFFeedback] = []
    arr.append(_create_shake(0.8, 0.2))  # 从1.5改为0.8
    arr.append(_create_flash(Color.RED, 0.08))
    arr.append(_create_freeze(0.04))
    arr.append(_create_scale(Vector2(0.9, 0.9), 0.15))
    arr.append(_create_alpha(0.0, 0.2))
    combo.effects = arr
    return combo

static func pickup() -> GFFCombo:
    var combo = GFFCombo.new()
    combo.label = "pickup"
    var arr: Array[GFFFeedback] = []
    arr.append(_create_scale(Vector2(1.1, 1.1), 0.08))  # 从1.3改为1.1
    arr.append(_create_flash(Color.YELLOW, 0.04))
    combo.effects = arr
    return combo

static func explosion() -> GFFCombo:
    var combo = GFFCombo.new()
    combo.label = "explosion"
    var arr: Array[GFFFeedback] = []
    arr.append(_create_shake(1.0, 0.2))  # 从2.0改为1.0
    arr.append(_create_flash(Color.ORANGE, 0.08))
    arr.append(_create_freeze(0.04))
    arr.append(_create_scale(Vector2(1.2, 1.2), 0.15))  # 从1.5改为1.2
    combo.effects = arr
    return combo
```

- [ ] **Step 5: 更新测试文件中的默认值**

```gdscript
# test_gff_feedback.gd
func test_default_duration() -> void:
    assert_float(feedback.duration).is_equal(0.1)

# test_gff_shake.gd
func test_default_amplitude() -> void:
    assert_float(shake.amplitude).is_equal(0.1)
```

- [ ] **Step 6: 运行测试验证**

```bash
& "F:\Engines\Godot\Godot4-6-2-Csharp\Godot_v4.6.2-stable_mono_win64_console.exe" --path "F:\Coding-Projects\Godot\godot-plugin-game-feel-flow" -s -d --remote-debug tcp://127.0.0.1:65535 res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a "res://tests_optional/" --ignoreHeadlessMode
```

- [ ] **Step 7: 提交**

```bash
git add -A
git commit -m "fix: adjust default effect parameters to be more subtle"
```

---

### Task 1.2: 创建本地曲线资源文件

**Files:**
- Create: `addons/game_feel_flow/presets/curves/ease_in.tres`
- Create: `addons/game_feel_flow/presets/curves/ease_out.tres`
- Create: `addons/game_feel_flow/presets/curves/ease_in_out.tres`
- Create: `addons/game_feel_flow/presets/curves/bounce.tres`
- Create: `addons/game_feel_flow/presets/curves/elastic.tres`
- Create: `addons/game_feel_flow/presets/curves/linear.tres`

- [ ] **Step 1: 创建曲线预设目录**

```bash
mkdir -p addons/game_feel_flow/presets/curves
```

- [ ] **Step 2: 在Godot编辑器中创建曲线资源**

1. 打开Godot编辑器
2. 右键 → 新建资源 → Curve
3. 设置曲线点：
   - ease_in: (0,0), (1,1) - 缓入
   - ease_out: (0,0), (1,1) - 缓出
   - ease_in_out: (0,0), (0.5,0.5), (1,1) - 缓入缓出
   - bounce: (0,0), (0.3,1.2), (0.5,0.8), (0.7,1.05), (1,1) - 弹跳
   - elastic: (0,0), (0.2,1.3), (0.4,0.7), (0.6,1.1), (0.8,0.95), (1,1) - 弹性
   - linear: (0,0), (1,1) - 线性
4. 保存为.tres文件

- [ ] **Step 3: 提交**

```bash
git add addons/game_feel_flow/presets/curves/
git commit -m "feat: add curve preset resource files"
```

---

### Task 1.3: 优化恢复机制

**Files:**
- Modify: `addons/game_feel_flow/core/gff_feedback.gd`

- [ ] **Step 1: 添加RestoreMode枚举**

```gdscript
# gff_feedback.gd
@export_group("Restore")
@export var restore_after_play: bool = false  # 默认不恢复
@export var restore_mode: RestoreMode = RestoreMode.IMMEDIATE

enum RestoreMode {
    IMMEDIATE,  # 立即恢复
    GRADUAL,    # 渐进恢复
    CUSTOM      # 自定义恢复
}
```

- [ ] **Step 2: 更新恢复逻辑**

```gdscript
# gff_feedback.gd
func apply(target: Node, params: GFFParams = null) -> void:
    # ... 执行效果 ...
    
    # 恢复初始状态
    if restore_after_play:
        match restore_mode:
            RestoreMode.IMMEDIATE:
                _restore_initial_state(node)
            RestoreMode.GRADUAL:
                await _restore_gradual(node)
            RestoreMode.CUSTOM:
                _restore_custom(node)
```

- [ ] **Step 3: 运行测试验证**

```bash
& "F:\Engines\Godot\Godot4-6-2-Csharp\Godot_v4.6.2-stable_mono_win64_console.exe" --path "F:\Coding-Projects\Godot\godot-plugin-game-feel-flow" -s -d --remote-debug tcp://127.0.0.1:65535 res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a "res://tests_optional/" --ignoreHeadlessMode
```

- [ ] **Step 4: 提交**

```bash
git add -A
git commit -m "feat: add RestoreMode enum for flexible restore behavior"
```

---

## Phase 2: API设计优化（1周）

### Task 2.1: 优化GFFPlayer播放器

**Files:**
- Modify: `addons/game_feel_flow/core/gff_player.gd`

- [ ] **Step 1: 优化play()方法**

```gdscript
# gff_player.gd
func play(effect, params = null) -> void:
    ## 播放效果
    ## effect: String | GFFFeedback | GFFCombo
    if effect is String:
        var feedback = _get_effect(effect)
        if feedback:
            await _play_feedback(feedback, params)
        else:
            push_warning("GFFPlayer: Effect not found: ", effect)
    elif effect is GFFFeedback:
        await _play_feedback(effect, params)
    elif effect is GFFCombo:
        await _play_combo(effect, params)
```

- [ ] **Step 2: 优化play_combo()方法**

```gdscript
# gff_player.gd
func play_combo(combo, params = null) -> void:
    ## 播放组合效果
    ## combo: String | GFFCombo
    if combo is String:
        var combo_resource = _get_combo(combo)
        if combo_resource:
            await _play_combo(combo_resource, params)
        else:
            push_warning("GFFPlayer: Combo not found: ", combo)
    elif combo is GFFCombo:
        await _play_combo(combo, params)
```

- [ ] **Step 3: 运行测试验证**

```bash
& "F:\Engines\Godot\Godot4-6-2-Csharp\Godot_v4.6.2-stable_mono_win64_console.exe" --path "F:\Coding-Projects\Godot\godot-plugin-game-feel-flow" -s -d --remote-debug tcp://127.0.0.1:65535 res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a "res://tests_optional/" --ignoreHeadlessMode
```

- [ ] **Step 4: 提交**

```bash
git add -A
git commit -m "feat: optimize GFFPlayer to support String/Feedback/Combo"
```

---

### Task 2.2: 优化示例场景使用GFUtil

**Files:**
- Modify: `addons/game_feel_flow/examples/main_3d.gd`
- Modify: `addons/game_feel_flow/examples/main_2d.gd`
- Modify: `addons/game_feel_flow/examples/main_ui.gd`
- Modify: `addons/game_feel_flow/examples/demo_effects.gd`

- [ ] **Step 1: 更新main_3d.gd使用GFUtil**

```gdscript
# main_3d.gd
func _play_effect(effect_type: String) -> void:
    if not _selected_target:
        print("Please select a target first")
        return

    var params = _get_params()
    var visual_target = _get_visual_target(_selected_target)

    match effect_type:
        "shake":
            GFUtil.shake(visual_target, params.get_float("intensity", 1.0))
        "scale":
            GFUtil.scale(visual_target, params.get_float("intensity", 1.0))
        "flash":
            GFUtil.flash(visual_target, params.get_color("color", Color.WHITE))
        "color":
            GFUtil.color(visual_target, params.get_color("color", Color.RED))
        "hit_light":
            GFUtil.hit(visual_target, params.get_float("intensity", 1.0))
        "hit_heavy":
            GFUtil.hit_heavy(visual_target, params.get_float("intensity", 1.0))
        "explosion":
            GFUtil.explosion(visual_target, params.get_float("intensity", 1.0))
        "death":
            GFUtil.death(visual_target, params.get_float("intensity", 1.0))
```

- [ ] **Step 2: 更新其他示例场景**

类似地更新main_2d.gd、main_ui.gd和demo_effects.gd

- [ ] **Step 3: 运行测试验证**

```bash
& "F:\Engines\Godot\Godot4-6-2-Csharp\Godot_v4.6.2-stable_mono_win64_console.exe" --path "F:\Coding-Projects\Godot\godot-plugin-game-feel-flow" -s -d --remote-debug tcp://127.0.0.1:65535 res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a "res://tests_optional/" --ignoreHeadlessMode
```

- [ ] **Step 4: 提交**

```bash
git add -A
git commit -m "refactor: update example scenes to use GFUtil shortcuts"
```

---

## Phase 3: 文档和示例（1周）

### Task 3.1: 编写快速入门指南

**Files:**
- Create: `docs/QUICKSTART.md`

- [ ] **Step 1: 创建快速入门指南**

```markdown
# Game Feel Flow 快速入门

## 安装

1. 下载插件
2. 复制 `addons/game_feel_flow` 到你的项目
3. 在Godot编辑器中启用插件

## 第一个效果

```gdscript
# 使用GFUtil快捷方式
GFUtil.hit(target_node, 1.0)
GFUtil.shake(target_node, 1.0)
GFUtil.flash(target_node, Color.WHITE)
```

## 自定义参数

```gdscript
# 使用GFFParams
var params = GFFParams.create(2.0, 0.5)
    .with_color("color", Color.RED)
    .with_float("amplitude", 0.2)

GameFeelFlow.play("shake", target_node, params)
```

## 组合效果

```gdscript
# 使用预定义组合
GFUtil.hit(target_node, 1.0)
GFUtil.death(target_node, 1.0)
GFUtil.pickup(target_node, 1.0)
```
```

- [ ] **Step 2: 提交**

```bash
git add docs/QUICKSTART.md
git commit -m "docs: add quickstart guide"
```

---

### Task 3.2: 编写API文档

**Files:**
- Create: `docs/API.md`

- [ ] **Step 1: 创建API文档**

```markdown
# Game Feel Flow API 文档

## GameFeelFlow 全局单例

### play(effect, target, params)
播放效果

**参数：**
- effect: String | GFFFeedback | GFFCombo - 效果名称或对象
- target: Node - 目标节点
- params: GFFParams | Dictionary | float - 参数

### play_combo(combo, target, params)
播放组合效果

**参数：**
- combo: String | GFFCombo - 组合效果名称或对象
- target: Node - 目标节点
- params: GFFParams | Dictionary | float - 参数

## GFFPlayer 播放器

### play(effect, params)
播放效果

### play_combo(combo, params)
播放组合效果

### stop()
停止所有效果

## GFUtil 快捷工具

### hit(target, intensity)
播放轻击效果

### hit_heavy(target, intensity)
播放重击效果

### death(target, intensity)
播放死亡效果

### pickup(target, intensity)
播放拾取效果

### explosion(target, intensity)
播放爆炸效果

### shake(target, intensity)
播放震动效果

### scale(target, intensity)
播放缩放效果

### flash(target, color)
播放闪白效果

### color(target, color)
播放颜色效果

### freeze(duration)
播放冻结帧效果

### slow_motion(duration, scale)
播放慢动作效果
```

- [ ] **Step 2: 提交**

```bash
git add docs/API.md
git commit -m "docs: add API documentation"
```

---

## Phase 4: 编辑器工具（1周）

### Task 4.1: 实现可视化配置

**Files:**
- Modify: `addons/game_feel_flow/editor/gff_param_panel.gd`

- [ ] **Step 1: 优化参数面板**

```gdscript
# gff_param_panel.gd
func setup_for_effect(effect_name: String) -> void:
    clear_controls()
    
    match effect_name:
        "shake":
            add_float_param("intensity", 1.0, 0.0, 3.0, 0.1)
            add_float_param("duration", 0.1, 0.01, 0.5, 0.01)
            add_float_param("amplitude", 0.1, 0.01, 1.0, 0.01)
            add_float_param("frequency", 15.0, 5.0, 50.0, 1.0)
        "scale":
            add_float_param("intensity", 1.0, 0.0, 3.0, 0.1)
            add_float_param("duration", 0.1, 0.01, 0.5, 0.01)
        # ... 其他效果
```

- [ ] **Step 2: 提交**

```bash
git add -A
git commit -m "feat: optimize parameter panel for better UX"
```

---

### Task 4.2: 实现调试面板

**Files:**
- Modify: `addons/game_feel_flow/editor/gff_debug_panel.gd`

- [ ] **Step 1: 优化调试面板**

```gdscript
# gff_debug_panel.gd
func _update_display() -> void:
    # 显示活跃效果
    var active_count = GameFeelFlow._active_effects.size()
    effects_label.text = "Active Effects: %d" % active_count
    
    # 显示FPS
    fps_label.text = "FPS: %d" % Engine.get_frames_per_second()
    
    # 显示内存使用
    var memory = OS.get_memory_info()
    memory_label.text = "Memory: %d MB" % (memory["physical"] / 1024 / 1024)
```

- [ ] **Step 2: 提交**

```bash
git add -A
git commit -m "feat: enhance debug panel with more metrics"
```

---

## 完成

**总计：4个Phase，10个Task**

**执行方式：**
1. 使用 `superpowers:subagent-driven-development` 或 `superpowers:executing-plans` 执行计划
2. 按顺序完成每个任务
3. 运行测试验证
4. 提交代码

**预计时间：4周**
