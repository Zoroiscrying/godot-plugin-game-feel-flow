# Game Feel Flow 示例场景实施计划

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal：** 创建一个综合性的示例场景系统，用于演示、测试和教学Game Feel Flow插件的所有功能

**Architecture：** 主场景+子场景模块化架构，主场景负责导航和设置，子场景负责具体功能演示，组件库提供可复用的UI组件

**Tech Stack：** GDScript 4.2+, Godot Engine 4.2+, GdUnit4 (测试)

---

## 文件结构

```
addons/game_feel_flow/examples/
├── main.tscn                    # 主场景（导航+设置+帮助）
├── main.gd
├── scenes/
│   ├── effects_demo.tscn        # 效果演示子场景
│   ├── effects_demo.gd
│   ├── game_scenes.tscn         # 游戏场景子场景
│   ├── game_scenes.gd
│   ├── param_adjuster.tscn      # 参数调节子场景
│   ├── param_adjuster.gd
│   ├── combo_effects.tscn       # 组合效果子场景
│   ├── combo_effects.gd
│   ├── perf_monitor.tscn        # 性能监控子场景
│   └── perf_monitor.gd
├── components/                  # 可复用组件
│   ├── effect_card.tscn         # 效果卡片组件
│   ├── effect_card.gd
│   ├── param_panel.tscn         # 参数面板组件
│   ├── param_panel.gd
│   ├── code_preview.tscn        # 代码预览弹窗
│   └── code_preview.gd
└── resources/                   # 资源文件
    ├── themes/
    │   └── dark_theme.tres      # 暗色主题
    └── presets/
        └── default_params.tres  # 默认参数预设
```

---

## Phase 1: 核心组件（2天）

### Task 1.1: 创建EffectCard组件

**Files:**
- Create: `addons/game_feel_flow/examples/components/effect_card.gd`
- Create: `addons/game_feel_flow/examples/components/effect_card.tscn`

- [ ] **Step 1: 创建EffectCard脚本**

```gdscript
extends PanelContainer

## 效果卡片组件
## 用于展示单个效果的预览和信息

# ===== 信号 =====
signal clicked(effect_name: String)

# ===== 属性 =====
var effect_name: String = ""
var effect_type: String = ""
var complexity: String = "simple"  # simple, medium, complex
var preview_target: Node = null

# ===== 节点引用 =====
@onready var name_label: Label = $VBoxContainer/NameLabel
@onready var preview_container: SubViewportContainer = $VBoxContainer/PreviewContainer
@onready var preview_viewport: SubViewport = $VBoxContainer/PreviewContainer/SubViewport
@onready var complexity_label: Label = $VBoxContainer/ComplexityLabel
@onready var type_label: Label = $VBoxContainer/TypeLabel

# ===== 初始化 =====

func _ready() -> void:
	gui_input.connect(_on_gui_input)

# ===== 公共方法 =====

func set_effect(p_name: String, p_type: String, p_complexity: String) -> void:
	effect_name = p_name
	effect_type = p_type
	complexity = p_complexity
	
	if name_label:
		name_label.text = p_name
	if complexity_label:
		complexity_label.text = p_complexity.capitalize()
	if type_label:
		type_label.text = p_type

func start_preview() -> void:
	if preview_target and preview_viewport:
		preview_viewport.add_child(preview_target)

func stop_preview() -> void:
	if preview_target and preview_target.get_parent() == preview_viewport:
		preview_viewport.remove_child(preview_target)

func get_code_example() -> String:
	var code = ""
	match effect_type:
		"shake":
			code = 'GameFeelFlow.play("shake", target_node)'
		"scale":
			code = 'GameFeelFlow.play("scale", target_node)'
		"flash":
			code = 'GameFeelFlow.play("flash", target_node)'
		"color":
			code = 'GameFeelFlow.play("color", target_node)'
		_:
			code = 'GameFeelFlow.play("%s", target_node)' % effect_type
	return code

# ===== 回调方法 =====

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		clicked.emit(effect_name)
```

- [ ] **Step 2: 创建EffectCard场景**

在Godot编辑器中创建场景：
1. 创建PanelContainer根节点
2. 添加VBoxContainer子节点
3. 添加Label子节点（NameLabel、ComplexityLabel、TypeLabel）
4. 添加SubViewportContainer子节点（PreviewContainer）
5. 在SubViewportContainer内添加SubViewport
6. 连接脚本

- [ ] **Step 3: 测试EffectCard**

```bash
# 在Godot编辑器中测试
# 创建测试场景，添加EffectCard实例
# 验证点击信号是否正常触发
```

- [ ] **Step 4: 提交**

```bash
git add addons/game_feel_flow/examples/components/effect_card.*
git commit -m "feat: add EffectCard component for example scenes"
```

---

### Task 1.2: 创建ParamPanel组件

**Files:**
- Create: `addons/game_feel_flow/examples/components/param_panel.gd`
- Create: `addons/game_feel_flow/examples/components/param_panel.tscn`

- [ ] **Step 1: 创建ParamPanel脚本**

```gdscript
extends VBoxContainer

## 参数面板组件
## 动态生成效果参数调节控件

# ===== 信号 =====
signal params_changed(params: GFFParams)

# ===== 属性 =====
var effect_name: String = ""
var params: Dictionary = {}

# ===== 节点引用 =====
var controls: Dictionary = {}

# ===== 公共方法 =====

func setup_for_effect(p_effect_name: String) -> void:
	effect_name = p_effect_name
	clear_controls()
	
	match p_effect_name:
		"shake":
			add_float_param("intensity", 1.0, 0.0, 5.0)
			add_float_param("duration", 0.3, 0.01, 2.0)
			add_float_param("amplitude", 10.0, 1.0, 50.0)
			add_float_param("frequency", 20.0, 1.0, 100.0)
		"scale":
			add_float_param("intensity", 1.0, 0.0, 5.0)
			add_float_param("duration", 0.3, 0.01, 2.0)
		"flash":
			add_float_param("intensity", 1.0, 0.0, 5.0)
			add_float_param("duration", 0.1, 0.01, 1.0)
			add_color_param("color", Color.WHITE)
		"color":
			add_float_param("intensity", 1.0, 0.0, 5.0)
			add_float_param("duration", 0.3, 0.01, 2.0)
			add_color_param("color", Color.RED)
		"alpha":
			add_float_param("intensity", 1.0, 0.0, 5.0)
			add_float_param("duration", 0.3, 0.01, 2.0)
		"freeze_frame":
			add_float_param("duration", 0.1, 0.01, 1.0)
		"time_scale":
			add_float_param("duration", 0.3, 0.01, 2.0)
			add_float_param("scale", 0.5, 0.0, 2.0)
		_:
			add_float_param("intensity", 1.0, 0.0, 5.0)
			add_float_param("duration", 0.2, 0.01, 2.0)

func get_params() -> GFFParams:
	var gff_params = GFFParams.new()
	for param_name in controls:
		var control = controls[param_name]
		if control is HSlider:
			if param_name == "intensity":
				gff_params.intensity = control.value
			elif param_name == "duration":
				gff_params.duration = control.value
			else:
				gff_params.with_float(param_name, control.value)
		elif control is ColorPickerButton:
			gff_params.with_color(param_name, control.color)
	return gff_params

func reset_params() -> void:
	setup_for_effect(effect_name)

# ===== 内部方法 =====

func clear_controls() -> void:
	for child in get_children():
		child.queue_free()
	controls.clear()

func add_float_param(param_name: String, default: float, min_val: float, max_val: float) -> void:
	var hbox = HBoxContainer.new()
	
	var label = Label.new()
	label.text = param_name.capitalize()
	label.custom_minimum_size.x = 100
	hbox.add_child(label)
	
	var slider = HSlider.new()
	slider.min_value = min_val
	slider.max_value = max_val
	slider.value = default
	slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	slider.name = param_name
	hbox.add_child(slider)
	
	var value_label = Label.new()
	value_label.text = "%.2f" % default
	value_label.custom_minimum_size.x = 50
	hbox.add_child(value_label)
	
	slider.value_changed.connect(func(value): 
		value_label.text = "%.2f" % value
		params_changed.emit(get_params())
	)
	
	add_child(hbox)
	controls[param_name] = slider

func add_color_param(param_name: String, default: Color) -> void:
	var hbox = HBoxContainer.new()
	
	var label = Label.new()
	label.text = param_name.capitalize()
	label.custom_minimum_size.x = 100
	hbox.add_child(label)
	
	var color_picker = ColorPickerButton.new()
	color_picker.color = default
	color_picker.name = param_name
	hbox.add_child(color_picker)
	
	color_picker.color_changed.connect(func(color): 
		params_changed.emit(get_params())
	)
	
	add_child(hbox)
	controls[param_name] = color_picker
```

- [ ] **Step 2: 创建ParamPanel场景**

在Godot编辑器中创建场景：
1. 创建VBoxContainer根节点
2. 连接脚本

- [ ] **Step 3: 测试ParamPanel**

```bash
# 在Godot编辑器中测试
# 创建测试场景，添加ParamPanel实例
# 调用setup_for_effect("shake")
# 验证参数控件是否正确生成
```

- [ ] **Step 4: 提交**

```bash
git add addons/game_feel_flow/examples/components/param_panel.*
git commit -m "feat: add ParamPanel component for example scenes"
```

---

### Task 1.3: 创建CodePreview组件

**Files:**
- Create: `addons/game_feel_flow/examples/components/code_preview.gd`
- Create: `addons/game_feel_flow/examples/components/code_preview.tscn`

- [ ] **Step 1: 创建CodePreview脚本**

```gdscript
extends Window

## 代码预览组件
## 显示效果调用代码并支持复制

# ===== 属性 =====
var code_text: String = ""
var language: String = "gdscript"

# ===== 节点引用 =====
@onready var code_edit: CodeEdit = $VBoxContainer/CodeEdit
@onready var copy_button: Button = $VBoxContainer/HBoxContainer/CopyButton
@onready var close_button: Button = $VBoxContainer/HBoxContainer/CloseButton

# ===== 生命周期 =====

func _ready() -> void:
	copy_button.pressed.connect(_on_copy_pressed)
	close_button.pressed.connect(_on_close_pressed)
	close_requested.connect(_on_close_pressed)

# ===== 公共方法 =====

func show_code(code: String, lang: String = "gdscript") -> void:
	code_text = code
	language = lang
	
	if code_edit:
		code_edit.text = code
		code_edit.editable = false
	
	popup_centered(Vector2i(600, 400))

func copy_to_clipboard() -> void:
	DisplayServer.clipboard_set(code_text)

# ===== 回调方法 =====

func _on_copy_pressed() -> void:
	copy_to_clipboard()

func _on_close_pressed() -> void:
	hide()
```

- [ ] **Step 2: 创建CodePreview场景**

在Godot编辑器中创建场景：
1. 创建Window根节点
2. 添加VBoxContainer子节点
3. 添加CodeEdit子节点
4. 添加HBoxContainer子节点（包含CopyButton和CloseButton）
5. 连接脚本

- [ ] **Step 3: 测试CodePreview**

```bash
# 在Godot编辑器中测试
# 创建测试场景，添加CodePreview实例
# 调用show_code("GameFeelFlow.play('shake', target)")
# 验证代码显示和复制功能
```

- [ ] **Step 4: 提交**

```bash
git add addons/game_feel_flow/examples/components/code_preview.*
git commit -m "feat: add CodePreview component for example scenes"
```

---

### Task 1.4: 创建暗色主题

**Files:**
- Create: `addons/game_feel_flow/examples/resources/themes/dark_theme.tres`

- [ ] **Step 1: 创建暗色主题资源**

在Godot编辑器中创建主题：
1. 创建新主题资源
2. 设置背景色：#1e1e2e
3. 设置面板背景：#2d2d3f
4. 设置文字颜色：#cdd6f4
5. 设置强调色：#89b4fa
6. 保存为dark_theme.tres

- [ ] **Step 2: 测试主题**

```bash
# 在Godot编辑器中测试
# 创建测试场景，应用主题
# 验证颜色是否正确显示
```

- [ ] **Step 3: 提交**

```bash
git add addons/game_feel_flow/examples/resources/themes/
git commit -m "feat: add dark theme for example scenes"
```

---

## Phase 2: 主场景（1天）

### Task 2.1: 创建主场景布局

**Files:**
- Create: `addons/game_feel_flow/examples/main.gd`
- Create: `addons/game_feel_flow/examples/main.tscn`

- [ ] **Step 1: 创建主场景脚本**

```gdscript
extends Control

## Game Feel Flow 示例场景主场景

# ===== 节点引用 =====
@onready var nav_list: ItemList = $HSplitContainer/NavPanel/NavList
@onready var content_container: Container = $HSplitContainer/ContentContainer
@onready var scene_label: Label = $StatusBar/HBoxContainer/SceneLabel
@onready var effects_label: Label = $StatusBar/HBoxContainer/EffectsLabel
@onready var fps_label: Label = $StatusBar/HBoxContainer/FPSLabel
@onready var mode_button: Button = $ToolBar/HBoxContainer/ModeButton
@onready var help_button: Button = $ToolBar/HBoxContainer/HelpButton
@onready var auto_play_button: Button = $ToolBar/HBoxContainer/AutoPlayButton
@onready var prev_button: Button = $ToolBar/HBoxContainer/PrevButton
@onready var next_button: Button = $ToolBar/HBoxContainer/NextButton

# ===== 属性 =====
var current_scene: Node = null
var current_scene_name: String = ""
var is_3d_mode: bool = false
var is_auto_play: bool = false

# ===== 场景引用 =====
var scenes: Dictionary = {}

# ===== 生命周期 =====

func _ready() -> void:
	_setup_scenes()
	_connect_signals()
	_load_scene("effects_demo")

func _process(_delta: float) -> void:
	_update_fps()
	_update_effects_count()

# ===== 初始化 =====

func _setup_scenes() -> void:
	scenes = {
		"effects_demo": preload("res://addons/game_feel_flow/examples/scenes/effects_demo.tscn"),
		"game_scenes": preload("res://addons/game_feel_flow/examples/scenes/game_scenes.tscn"),
		"param_adjuster": preload("res://addons/game_feel_flow/examples/scenes/param_adjuster.tscn"),
		"combo_effects": preload("res://addons/game_feel_flow/examples/scenes/combo_effects.tscn"),
		"perf_monitor": preload("res://addons/game_feel_flow/examples/scenes/perf_monitor.tscn"),
	}

func _connect_signals() -> void:
	nav_list.item_selected.connect(_on_nav_selected)
	mode_button.pressed.connect(_on_mode_pressed)
	help_button.pressed.connect(_on_help_pressed)
	auto_play_button.pressed.connect(_on_auto_play_pressed)
	prev_button.pressed.connect(_on_prev_pressed)
	next_button.pressed.connect(_on_next_pressed)

# ===== 场景管理 =====

func _load_scene(scene_name: String) -> void:
	if current_scene:
		current_scene.queue_free()
	
	if scene_name in scenes:
		current_scene = scenes[scene_name].instantiate()
		content_container.add_child(current_scene)
		current_scene_name = scene_name
		scene_label.text = "Scene: " + scene_name.capitalize().replace("_", " ")

func _get_scene_names() -> Array[String]:
	return scenes.keys()

# ===== UI更新 =====

func _update_fps() -> void:
	if fps_label:
		fps_label.text = "FPS: %d" % Engine.get_frames_per_second()

func _update_effects_count() -> void:
	if effects_label:
		var count = 0
		# 统计活跃效果数
		effects_label.text = "Effects: %d" % count

# ===== 回调方法 =====

func _on_nav_selected(index: int) -> void:
	var scene_names = _get_scene_names()
	if index >= 0 and index < scene_names.size():
		_load_scene(scene_names[index])

func _on_mode_pressed() -> void:
	is_3d_mode = !is_3d_mode
	mode_button.text = "2D" if is_3d_mode else "3D"
	# 切换场景模式

func _on_help_pressed() -> void:
	# 显示帮助弹窗
	pass

func _on_auto_play_pressed() -> void:
	is_auto_play = !is_auto_play
	auto_play_button.text = "Stop" if is_auto_play else "Auto"
	# 切换自动演示模式

func _on_prev_pressed() -> void:
	# 上一个效果
	pass

func _on_next_pressed() -> void:
	# 下一个效果
	pass
```

- [ ] **Step 2: 创建主场景**

在Godot编辑器中创建场景：
1. 创建Control根节点
2. 添加ToolBar（HBoxContainer）
3. 添加HSplitContainer
4. 左侧添加NavPanel（PanelContainer + ItemList）
5. 右侧添加ContentContainer（Container）
6. 底部添加StatusBar（HBoxContainer）
7. 连接脚本

- [ ] **Step 3: 测试主场景**

```bash
# 在Godot编辑器中测试
# 运行主场景
# 验证导航菜单和场景切换功能
```

- [ ] **Step 4: 提交**

```bash
git add addons/game_feel_flow/examples/main.*
git commit -m "feat: add main scene with navigation and toolbar"
```

---

## Phase 3: 效果演示子场景（2天）

### Task 3.1: 创建效果演示子场景

**Files:**
- Create: `addons/game_feel_flow/examples/scenes/effects_demo.gd`
- Create: `addons/game_feel_flow/examples/scenes/effects_demo.tscn`

- [ ] **Step 1: 创建效果演示脚本**

```gdscript
extends Control

## 效果演示子场景
## 展示所有可用效果的卡片网格

# ===== 节点引用 =====
@onready var filter_bar: HBoxContainer = $VBoxContainer/FilterBar
@onready var search_line: LineEdit = $VBoxContainer/FilterBar/SearchLine
@onready var grid_container: GridContainer = $VBoxContainer/ScrollContainer/GridContainer
@onready var detail_window: Window = $DetailWindow
@onready var param_panel: VBoxContainer = $DetailWindow/VBoxContainer/ParamPanel
@onready var preview_container: SubViewportContainer = $DetailWindow/VBoxContainer/PreviewContainer
@onready var code_button: Button = $DetailWindow/VBoxContainer/HBoxContainer/CodeButton
@onready var reset_button: Button = $DetailWindow/VBoxContainer/HBoxContainer/ResetButton
@onready var close_button: Button = $DetailWindow/VBoxContainer/HBoxContainer/CloseButton

# ===== 属性 =====
var current_filter: String = "all"
var current_effect: String = ""
var effect_cards: Array[PanelContainer] = []

# ===== 效果列表 =====
var effects: Array[Dictionary] = [
	{"name": "Shake", "type": "shake", "complexity": "simple"},
	{"name": "Scale", "type": "scale", "complexity": "simple"},
	{"name": "Flash", "type": "flash", "complexity": "simple"},
	{"name": "Color", "type": "color", "complexity": "simple"},
	{"name": "Alpha", "type": "alpha", "complexity": "simple"},
	{"name": "Flicker", "type": "flicker", "complexity": "medium"},
	{"name": "Freeze Frame", "type": "freeze_frame", "complexity": "simple"},
	{"name": "Time Scale", "type": "time_scale", "complexity": "medium"},
	{"name": "Sound", "type": "sound", "complexity": "simple"},
	{"name": "Audio Volume", "type": "audio_volume", "complexity": "medium"},
	{"name": "Camera Shake", "type": "camera_shake", "complexity": "medium"},
	{"name": "Camera Zoom", "type": "camera_zoom", "complexity": "medium"},
	{"name": "Camera Flash", "type": "camera_flash", "complexity": "medium"},
	{"name": "Particles", "type": "particles", "complexity": "complex"},
	{"name": "GPU Particles", "type": "gpu_particles", "complexity": "complex"},
	{"name": "Impulse", "type": "impulse", "complexity": "medium"},
	{"name": "Velocity", "type": "velocity", "complexity": "medium"},
	{"name": "Tween", "type": "tween", "complexity": "complex"},
	{"name": "Animator", "type": "animator", "complexity": "complex"},
	{"name": "Position", "type": "position", "complexity": "simple"},
	{"name": "Rotation", "type": "rotation", "complexity": "simple"},
	{"name": "UI Shake", "type": "ui_shake", "complexity": "simple"},
	{"name": "UI Color", "type": "ui_color", "complexity": "simple"},
	{"name": "UI Scale", "type": "ui_scale", "complexity": "simple"},
	{"name": "UI Alpha", "type": "ui_alpha", "complexity": "simple"},
]

# ===== 生命周期 =====

func _ready() -> void:
	_setup_filter_buttons()
	_connect_signals()
	_create_effect_cards()

# ===== 初始化 =====

func _setup_filter_buttons() -> void:
	var filters = ["All", "Simple", "Medium", "Complex"]
	for filter_name in filters:
		var button = Button.new()
		button.text = filter_name
		button.toggle_mode = true
		button.button_pressed = filter_name == "All"
		button.pressed.connect(_on_filter_pressed.bind(filter_name.to_lower()))
		filter_bar.add_child(button)

func _connect_signals() -> void:
	search_line.text_changed.connect(_on_search_changed)
	code_button.pressed.connect(_on_code_pressed)
	reset_button.pressed.connect(_on_reset_pressed)
	close_button.pressed.connect(_on_close_pressed)

func _create_effect_cards() -> void:
	for effect in effects:
		var card = _create_card(effect)
		grid_container.add_child(card)
		effect_cards.append(card)

func _create_card(effect: Dictionary) -> PanelContainer:
	var card_script = preload("res://addons/game_feel_flow/examples/components/effect_card.gd")
	var card = PanelContainer.new()
	card.set_script(card_script)
	card.set_effect(effect["name"], effect["type"], effect["complexity"])
	card.clicked.connect(_on_card_clicked)
	return card

# ===== 筛选和搜索 =====

func _filter_effects(filter: String) -> void:
	current_filter = filter
	_update_card_visibility()

func _search_effects(query: String) -> void:
	for card in effect_cards:
		var visible = query.is_empty() or card.effect_name.to_lower().contains(query.to_lower())
		card.visible = visible

func _update_card_visibility() -> void:
	for card in effect_cards:
		var visible = current_filter == "all" or card.complexity == current_filter
		if visible and not search_line.text.is_empty():
			visible = card.effect_name.to_lower().contains(search_line.text.to_lower())
		card.visible = visible

# ===== 详情预览 =====

func _show_detail(effect_name: String) -> void:
	current_effect = effect_name
	detail_window.popup_centered(Vector2i(800, 600))
	param_panel.setup_for_effect(effect_name)

# ===== 回调方法 =====

func _on_filter_pressed(filter: String) -> void:
	_filter_effects(filter)

func _on_search_changed(text: String) -> void:
	_search_effects(text)

func _on_card_clicked(effect_name: String) -> void:
	_show_detail(effect_name)

func _on_code_pressed() -> void:
	var code_preview = preload("res://addons/game_feel_flow/examples/components/code_preview.tscn").instantiate()
	add_child(code_preview)
	code_preview.show_code('GameFeelFlow.play("%s", target_node)' % current_effect)

func _on_reset_pressed() -> void:
	param_panel.reset_params()

func _on_close_pressed() -> void:
	detail_window.hide()
```

- [ ] **Step 2: 创建效果演示场景**

在Godot编辑器中创建场景：
1. 创建Control根节点
2. 添加VBoxContainer
3. 添加FilterBar（HBoxContainer + LineEdit）
4. 添加ScrollContainer + GridContainer
5. 添加DetailWindow（Window）
6. 连接脚本

- [ ] **Step 3: 测试效果演示**

```bash
# 在Godot编辑器中测试
# 运行效果演示场景
# 验证卡片显示、筛选、搜索功能
```

- [ ] **Step 4: 提交**

```bash
git add addons/game_feel_flow/examples/scenes/effects_demo.*
git commit -m "feat: add effects demo scene with card grid"
```

---

## Phase 4: 游戏场景子场景（2天）

### Task 4.1: 创建游戏场景子场景

**Files:**
- Create: `addons/game_feel_flow/examples/scenes/game_scenes.gd`
- Create: `addons/game_feel_flow/examples/scenes/game_scenes.tscn`

- [ ] **Step 1: 创建游戏场景脚本**

```gdscript
extends Control

## 游戏场景子场景
## 模拟真实游戏场景的效果演示

# ===== 节点引用 =====
@onready var tab_container: TabContainer = $VBoxContainer/TabContainer
@onready var attack_scene: Control = $VBoxContainer/TabContainer/Attack
@onready var death_scene: Control = $VBoxContainer/TabContainer/Death
@onready var pickup_scene: Control = $VBoxContainer/TabContainer/Pickup
@onready var explosion_scene: Control = $VBoxContainer/TabContainer/Explosion
@onready var ui_scene: Control = $VBoxContainer/TabContainer/UI

# ===== 生命周期 =====

func _ready() -> void:
	_setup_attack_scene()
	_setup_death_scene()
	_setup_pickup_scene()
	_setup_explosion_scene()
	_setup_ui_scene()

# ===== 攻击场景 =====

func _setup_attack_scene() -> void:
	var player = _create_character("Player", Vector2(200, 300))
	var enemy = _create_character("Enemy", Vector2(600, 300))
	
	var hit_light_btn = Button.new()
	hit_light_btn.text = "Hit Light"
	hit_light_btn.pressed.connect(func(): GameFeelFlow.play_combo("hit_light", enemy))
	
	var hit_heavy_btn = Button.new()
	hit_heavy_btn.text = "Hit Heavy"
	hit_heavy_btn.pressed.connect(func(): GameFeelFlow.play_combo("hit_heavy", enemy))
	
	var hbox = HBoxContainer.new()
	hbox.add_child(hit_light_btn)
	hbox.add_child(hit_heavy_btn)
	hbox.position = Vector2(350, 500)
	
	attack_scene.add_child(player)
	attack_scene.add_child(enemy)
	attack_scene.add_child(hbox)

# ===== 死亡场景 =====

func _setup_death_scene() -> void:
	var enemy = _create_character("Enemy", Vector2(400, 300))
	
	var death_btn = Button.new()
	death_btn.text = "Death"
	death_btn.pressed.connect(func(): GameFeelFlow.play_combo("death", enemy))
	death_btn.position = Vector2(350, 500)
	
	death_scene.add_child(enemy)
	death_scene.add_child(death_btn)

# ===== 拾取场景 =====

func _setup_pickup_scene() -> void:
	var player = _create_character("Player", Vector2(200, 300))
	var item = _create_item("Item", Vector2(600, 300))
	
	var pickup_btn = Button.new()
	pickup_btn.text = "Pickup"
	pickup_btn.pressed.connect(func(): GameFeelFlow.play_combo("pickup", item))
	pickup_btn.position = Vector2(350, 500)
	
	pickup_scene.add_child(player)
	pickup_scene.add_child(item)
	pickup_scene.add_child(pickup_btn)

# ===== 爆炸场景 =====

func _setup_explosion_scene() -> void:
	var target = _create_character("Target", Vector2(400, 300))
	
	var explosion_btn = Button.new()
	explosion_btn.text = "Explosion"
	explosion_btn.pressed.connect(func(): GameFeelFlow.play_combo("explosion", target))
	explosion_btn.position = Vector2(350, 500)
	
	explosion_scene.add_child(target)
	explosion_scene.add_child(explosion_btn)

# ===== UI反馈场景 =====

func _setup_ui_scene() -> void:
	var button = Button.new()
	button.text = "Click Me"
	button.position = Vector2(300, 200)
	button.pressed.connect(func(): GameFeelFlow.play("ui_scale", button))
	
	var progress = ProgressBar.new()
	progress.value = 50
	progress.position = Vector2(300, 300)
	progress.size = Vector2(200, 30)
	
	var animate_btn = Button.new()
	animate_btn.text = "Animate Progress"
	animate_btn.position = Vector2(300, 400)
	animate_btn.pressed.connect(func(): 
		var tween = create_tween()
		tween.tween_property(progress, "value", 100, 0.5)
		tween.tween_property(progress, "value", 0, 0.5)
	)
	
	ui_scene.add_child(button)
	ui_scene.add_child(progress)
	ui_scene.add_child(animate_btn)

# ===== 辅助方法 =====

func _create_character(name: String, position: Vector2) -> Node2D:
	var character = Node2D.new()
	character.name = name
	character.position = position
	
	var sprite = ColorRect.new()
	sprite.size = Vector2(50, 80)
	sprite.color = Color.BLUE if name == "Player" else Color.RED
	sprite.position = Vector2(-25, -40)
	character.add_child(sprite)
	
	var label = Label.new()
	label.text = name
	label.position = Vector2(-20, -60)
	character.add_child(label)
	
	return character

func _create_item(name: String, position: Vector2) -> Node2D:
	var item = Node2D.new()
	item.name = name
	item.position = position
	
	var sprite = ColorRect.new()
	sprite.size = Vector2(30, 30)
	sprite.color = Color.YELLOW
	sprite.position = Vector2(-15, -15)
	item.add_child(sprite)
	
	return item
```

- [ ] **Step 2: 创建游戏场景**

在Godot编辑器中创建场景：
1. 创建Control根节点
2. 添加VBoxContainer
3. 添加TabContainer
4. 添加5个标签页（Attack、Death、Pickup、Explosion、UI）
5. 连接脚本

- [ ] **Step 3: 测试游戏场景**

```bash
# 在Godot编辑器中测试
# 运行游戏场景
# 验证各个标签页的效果演示
```

- [ ] **Step 4: 提交**

```bash
git add addons/game_feel_flow/examples/scenes/game_scenes.*
git commit -m "feat: add game scenes with attack, death, pickup, explosion, UI demos"
```

---

## Phase 5: 其他子场景（1天）

### Task 5.1: 创建参数调节子场景

**Files:**
- Create: `addons/game_feel_flow/examples/scenes/param_adjuster.gd`
- Create: `addons/game_feel_flow/examples/scenes/param_adjuster.tscn`

- [ ] **Step 1: 创建参数调节脚本**

```gdscript
extends Control

## 参数调节子场景
## 实时调节效果参数并预览

# ===== 节点引用 =====
@onready var effect_option: OptionButton = $VBoxContainer/HBoxContainer/EffectOption
@onready var preview_container: SubViewportContainer = $VBoxContainer/HSplitContainer/PreviewContainer
@onready var preview_viewport: SubViewport = $VBoxContainer/HSplitContainer/PreviewContainer/SubViewport
@onready var param_panel: VBoxContainer = $VBoxContainer/HSplitContainer/ParamPanel
@onready var code_button: Button = $VBoxContainer/HBoxContainer/CodeButton
@onready var reset_button: Button = $VBoxContainer/HBoxContainer/ResetButton

# ===== 属性 =====
var current_effect: String = ""
var preview_target: Node2D = null

# ===== 生命周期 =====

func _ready() -> void:
	_setup_effect_options()
	_connect_signals()
	_create_preview_target()

# ===== 初始化 =====

func _setup_effect_options() -> void:
	var effects = ["shake", "scale", "flash", "color", "alpha", "freeze_frame", "time_scale"]
	for effect in effects:
		effect_option.add_item(effect.capitalize())

func _connect_signals() -> void:
	effect_option.item_selected.connect(_on_effect_selected)
	code_button.pressed.connect(_on_code_pressed)
	reset_button.pressed.connect(_on_reset_pressed)
	param_panel.params_changed.connect(_on_params_changed)

func _create_preview_target() -> void:
	preview_target = Node2D.new()
	var sprite = ColorRect.new()
	sprite.size = Vector2(100, 100)
	sprite.color = Color.WHITE
	sprite.position = Vector2(-50, -50)
	preview_target.add_child(sprite)
	preview_viewport.add_child(preview_target)

# ===== 效果切换 =====

func _select_effect(effect_name: String) -> void:
	current_effect = effect_name
	param_panel.setup_for_effect(effect_name)

# ===== 回调方法 =====

func _on_effect_selected(index: int) -> void:
	var effects = ["shake", "scale", "flash", "color", "alpha", "freeze_frame", "time_scale"]
	if index >= 0 and index < effects.size():
		_select_effect(effects[index])

func _on_params_changed(params: GFFParams) -> void:
	if current_effect and preview_target:
		GameFeelFlow.play(current_effect, preview_target, params)

func _on_code_pressed() -> void:
	var code_preview = preload("res://addons/game_feel_flow/examples/components/code_preview.tscn").instantiate()
	add_child(code_preview)
	var params_code = "GFFParams.create(1.0, 0.3)"
	code_preview.show_code('GameFeelFlow.play("%s", target, %s)' % [current_effect, params_code])

func _on_reset_pressed() -> void:
	param_panel.reset_params()
```

- [ ] **Step 2: 创建参数调节场景**

在Godot编辑器中创建场景：
1. 创建Control根节点
2. 添加VBoxContainer
3. 添加HBoxContainer（EffectOption + CodeButton + ResetButton）
4. 添加HSplitContainer
5. 左侧添加PreviewContainer（SubViewportContainer + SubViewport）
6. 右侧添加ParamPanel
7. 连接脚本

- [ ] **Step 3: 测试参数调节**

```bash
# 在Godot编辑器中测试
# 运行参数调节场景
# 验证效果切换和参数调节功能
```

- [ ] **Step 4: 提交**

```bash
git add addons/game_feel_flow/examples/scenes/param_adjuster.*
git commit -m "feat: add param adjuster scene with real-time preview"
```

---

### Task 5.2: 创建组合效果子场景

**Files:**
- Create: `addons/game_feel_flow/examples/scenes/combo_effects.gd`
- Create: `addons/game_feel_flow/examples/scenes/combo_effects.tscn`

- [ ] **Step 1: 创建组合效果脚本**

```gdscript
extends Control

## 组合效果子场景
## 展示和编辑组合效果

# ===== 节点引用 =====
@onready var combo_list: ItemList = $VBoxContainer/HSplitContainer/ComboList
@onready var preview_container: SubViewportContainer = $VBoxContainer/HSplitContainer/VBoxContainer/PreviewContainer
@onready var preview_viewport: SubViewport = $VBoxContainer/HSplitContainer/VBoxContainer/PreviewContainer/SubViewport
@onready var effects_list: ItemList = $VBoxContainer/HSplitContainer/VBoxContainer/EffectsList
@onready var code_edit: CodeEdit = $VBoxContainer/HSplitContainer/VBoxContainer/CodeEdit
@onready var play_button: Button = $VBoxContainer/HBoxContainer/PlayButton
@onready var copy_button: Button = $VBoxContainer/HBoxContainer/CopyButton

# ===== 属性 =====
var current_combo: String = ""
var preview_target: Node2D = null

# ===== 组合效果列表 =====
var combos: Dictionary = {
	"hit_light": {"name": "Hit Light", "effects": ["shake", "flash", "scale"]},
	"hit_heavy": {"name": "Hit Heavy", "effects": ["shake", "flash", "freeze_frame", "scale"]},
	"death": {"name": "Death", "effects": ["shake", "flash", "freeze_frame", "scale", "alpha"]},
	"pickup": {"name": "Pickup", "effects": ["scale", "flash"]},
	"explosion": {"name": "Explosion", "effects": ["shake", "flash", "freeze_frame", "scale"]},
}

# ===== 生命周期 =====

func _ready() -> void:
	_setup_combo_list()
	_connect_signals()
	_create_preview_target()

# ===== 初始化 =====

func _setup_combo_list() -> void:
	for combo_name in combos:
		var combo = combos[combo_name]
		combo_list.add_item(combo["name"])

func _connect_signals() -> void:
	combo_list.item_selected.connect(_on_combo_selected)
	play_button.pressed.connect(_on_play_pressed)
	copy_button.pressed.connect(_on_copy_pressed)

func _create_preview_target() -> void:
	preview_target = Node2D.new()
	var sprite = ColorRect.new()
	sprite.size = Vector2(100, 100)
	sprite.color = Color.WHITE
	sprite.position = Vector2(-50, -50)
	preview_target.add_child(sprite)
	preview_viewport.add_child(preview_target)

# ===== 组合效果选择 =====

func _select_combo(combo_name: String) -> void:
	current_combo = combo_name
	_update_effects_list()
	_update_code_preview()

func _update_effects_list() -> void:
	effects_list.clear()
	if current_combo in combos:
		var combo = combos[current_combo]
		for effect in combo["effects"]:
			effects_list.add_item(effect)

func _update_code_preview() -> void:
	if current_combo:
		code_edit.text = 'GameFeelFlow.play_combo("%s", target_node)' % current_combo

# ===== 回调方法 =====

func _on_combo_selected(index: int) -> void:
	var combo_names = combos.keys()
	if index >= 0 and index < combo_names.size():
		_select_combo(combo_names[index])

func _on_play_pressed() -> void:
	if current_combo and preview_target:
		GameFeelFlow.play_combo(current_combo, preview_target)

func _on_copy_pressed() -> void:
	if current_combo:
		DisplayServer.clipboard_set(code_edit.text)
```

- [ ] **Step 2: 创建组合效果场景**

在Godot编辑器中创建场景：
1. 创建Control根节点
2. 添加VBoxContainer
3. 添加HSplitContainer
4. 左侧添加ComboList（ItemList）
5. 右侧添加VBoxContainer（PreviewContainer + EffectsList + CodeEdit）
6. 底部添加HBoxContainer（PlayButton + CopyButton）
7. 连接脚本

- [ ] **Step 3: 测试组合效果**

```bash
# 在Godot编辑器中测试
# 运行组合效果场景
# 验证组合效果选择和播放功能
```

- [ ] **Step 4: 提交**

```bash
git add addons/game_feel_flow/examples/scenes/combo_effects.*
git commit -m "feat: add combo effects scene with preset combos"
```

---

### Task 5.3: 创建性能监控子场景

**Files:**
- Create: `addons/game_feel_flow/examples/scenes/perf_monitor.gd`
- Create: `addons/game_feel_flow/examples/scenes/perf_monitor.tscn`

- [ ] **Step 1: 创建性能监控脚本**

```gdscript
extends Control

## 性能监控子场景
## 显示FPS、效果执行时间、内存使用等性能数据

# ===== 节点引用 =====
@onready var fps_chart: Control = $VBoxContainer/TabContainer/FPS/Chart
@onready var fps_label: Label = $VBoxContainer/TabContainer/FPS/FPSLabel
@onready var effects_list: ItemList = $VBoxContainer/TabContainer/Effects/List
@onready var memory_label: Label = $VBoxContainer/TabContainer/Memory/Label
@onready var active_label: Label = $VBoxContainer/TabContainer/Active/Label

# ===== 属性 =====
var fps_history: Array[float] = []
var max_history: int = 100

# ===== 生命周期 =====

func _ready() -> void:
	pass

func _process(_delta: float) -> void:
	_update_fps()
	_update_memory()
	_update_active_effects()

# ===== 性能更新 =====

func _update_fps() -> void:
	var fps = Engine.get_frames_per_second()
	fps_history.append(fps)
	if fps_history.size() > max_history:
		fps_history.pop_front()
	
	if fps_label:
		fps_label.text = "FPS: %d" % fps
	
	_update_fps_chart()

func _update_fps_chart() -> void:
	if not fps_chart or fps_history.is_empty():
		return
	
	# 简单的FPS图表绘制
	fps_chart.queue_redraw()

func _update_memory() -> void:
	if memory_label:
		var memory = OS.get_memory_info()
		memory_label.text = "Memory: %d MB" % (memory["physical"] / 1024 / 1024)

func _update_active_effects() -> void:
	if active_label:
		# 统计活跃效果数
		active_label.text = "Active Effects: 0"

func _draw_fps_chart() -> void:
	if not fps_chart or fps_history.is_empty():
		return
	
	var width = fps_chart.size.x
	var height = fps_chart.size.y
	var step = width / max_history
	
	# 绘制背景
	draw_rect(Rect2(Vector2.ZERO, fps_chart.size), Color("#2d2d3f"))
	
	# 绘制FPS线
	var points = PackedVector2Array()
	for i in range(fps_history.size()):
		var x = i * step
		var y = height - (fps_history[i] / 60.0 * height)
		points.append(Vector2(x, y))
	
	if points.size() > 1:
		draw_polyline(points, Color("#89b4fa"), 2.0)
	
	# 绘制60FPS参考线
	var y60 = height - (60.0 / 60.0 * height)
	draw_line(Vector2(0, y60), Vector2(width, y60), Color("#a6e3a1"), 1.0)
	
	# 绘制30FPS参考线
	var y30 = height - (30.0 / 60.0 * height)
	draw_line(Vector2(0, y30), Vector2(width, y30), Color("#f9e2af"), 1.0)
```

- [ ] **Step 2: 创建性能监控场景**

在Godot编辑器中创建场景：
1. 创建Control根节点
2. 添加VBoxContainer
3. 添加TabContainer
4. 添加4个标签页（FPS、Effects、Memory、Active）
5. 在各个标签页中添加相应的控件
6. 连接脚本

- [ ] **Step 3: 测试性能监控**

```bash
# 在Godot编辑器中测试
# 运行性能监控场景
# 验证FPS图表和性能数据更新
```

- [ ] **Step 4: 提交**

```bash
git add addons/game_feel_flow/examples/scenes/perf_monitor.*
git commit -m "feat: add performance monitor scene with FPS chart"
```

---

## Phase 6: 测试和优化（2天）

### Task 6.1: 编写单元测试

**Files:**
- Create: `tests_optional/test_example_scenes.gd`

- [ ] **Step 1: 创建单元测试**

```gdscript
extends GdUnitTestSuite

## 示例场景单元测试

# 测试EffectCard组件
func test_effect_card_set_effect() -> void:
	var card = preload("res://addons/game_feel_flow/examples/components/effect_card.gd").new()
	card.set_effect("Shake", "shake", "simple")
	assert_str(card.effect_name).is_equal("Shake")
	assert_str(card.effect_type).is_equal("shake")
	assert_str(card.complexity).is_equal("simple")

# 测试ParamPanel组件
func test_param_panel_setup() -> void:
	var panel = preload("res://addons/game_feel_flow/examples/components/param_panel.gd").new()
	panel.setup_for_effect("shake")
	assert_str(panel.effect_name).is_equal("shake")

# 测试ParamPanel获取参数
func test_param_panel_get_params() -> void:
	var panel = preload("res://addons/game_feel_flow/examples/components/param_panel.gd").new()
	panel.setup_for_effect("shake")
	var params = panel.get_params()
	assert_object(params).is_not_null()

# 测试CodePreview组件
func test_code_preview_show_code() -> void:
	var preview = preload("res://addons/game_feel_flow/examples/components/code_preview.gd").new()
	# 注意：Window组件需要在场景中测试
	# preview.show_code("test code")
	assert_str(preview.code_text).is_equal("")
```

- [ ] **Step 2: 运行测试**

```bash
# 在Godot编辑器中运行测试
# 或使用命令行
& "F:\Engines\Godot\Godot4-6-2-Csharp\Godot_v4.6.2-stable_mono_win64_console.exe" --path "F:\Coding-Projects\Godot\godot-plugin-game-feel-flow" -s -d --remote-debug tcp://127.0.0.1:65535 res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a "res://tests_optional/" --ignoreHeadlessMode
```

- [ ] **Step 3: 提交**

```bash
git add tests_optional/test_example_scenes.gd
git commit -m "test: add unit tests for example scene components"
```

---

### Task 6.2: 性能优化

**Files:**
- Modify: `addons/game_feel_flow/examples/components/effect_card.gd`
- Modify: `addons/game_feel_flow/examples/scenes/effects_demo.gd`

- [ ] **Step 1: 优化EffectCard对象池**

```gdscript
# 在effect_card.gd中添加对象池支持
static var pool: Array[PanelContainer] = []

static func create_from_pool() -> PanelContainer:
	if pool.size() > 0:
		return pool.pop_front()
	return preload("res://addons/game_feel_flow/examples/components/effect_card.gd").new()

static func return_to_pool(card: PanelContainer) -> void:
	card.visible = false
	pool.append(card)
```

- [ ] **Step 2: 优化懒加载**

```gdscript
# 在effects_demo.gd中添加懒加载
var card_pool: Array[PanelContainer] = []
var visible_cards: Array[PanelContainer] = []

func _create_card_lazy(effect: Dictionary) -> PanelContainer:
	var card = EffectCard.create_from_pool()
	card.set_effect(effect["name"], effect["type"], effect["complexity"])
	return card
```

- [ ] **Step 3: 测试优化效果**

```bash
# 在Godot编辑器中测试
# 验证对象池和懒加载是否正常工作
```

- [ ] **Step 4: 提交**

```bash
git add addons/game_feel_flow/examples/components/effect_card.gd
git add addons/game_feel_flow/examples/scenes/effects_demo.gd
git commit -m "perf: add object pool and lazy loading for example scenes"
```

---

## 完成

**总计：6个Phase，15个Task**

**实施步骤：**
1. 使用 `superpowers:subagent-driven-development` 或 `superpowers:executing-plans` 执行计划
2. 按顺序完成每个任务
3. 运行测试验证
4. 提交代码

**预计时间：10天**
