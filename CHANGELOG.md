# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- **Pro project combos → global play**: Save as Project Combo now registers into `GameFeelFlow`, so `GameFeelFlow.play_combo("MyCombo", node)` works. Startup scans configured combo folders; string play also lazy-loads from those folders.
- **Project Settings → Game Feel Flow → Combos**: configurable multi-path `search_paths` for loading project combos, plus `save_path` for Save as Project Combo (defaults: `res://presets/combos/`, `res://effects/combos/`).

### Fixed
- Playgrounds and EffectLibrary demos now `stop_all` and restore transforms before replaying, so rapid Play no longer leaves subjects drifted off-center.
- `GameFeelFlow.stop(target)` now delegates to `stop_all(target)` (GFFPlayer **and** global effect stack), matching the documented intent.

### Removed
- Legacy orphan demos: `demo_resource_effects`, `demo_effects`, `demo_game`, `demo_inspector` (superseded by EffectLibrary / showcase / playgrounds).

### Changed
- Example docs (`examples.md`, QUICKSTART, PROJECT_SUMMARY) now list current entry points only.
- Example subjects refreshed with Kenney CC0 character / coin assets (2D + 3D + Pro UI).
- **Free + Pro showcases** now drive shots via `GFFPlayer.combo_dictionary` resources (`examples/resources/showcase_combos/`) and `play_combo(key)` — no runtime `GFFEffect.new()` assembly in the reel scripts.

### Documentation
- Showcase / Pro reel shot lists, flash bleach, freeze (`Engine.time_scale`), punch `BY_AMOUNT`, and Effect Stack naming (`GFFEffect` / `GFFEffectStack`).
- Added `docs/SCREENSHOTS.md` capture checklist for docs + store assets.

## [1.0.0] - 2026-07-15

First public release: free version submitted to the Godot Asset Library,
Pro extension distributed via itch.io.

### Changed
- **Free / Pro 拆分**：UI 与 Material target 迁移到 `addons/game_feel_flow_pro`，Free 核心不再包含这些 effect。
- **循环模式语义整理**：
  - `REPEAT` 按当前状态重新计算目标值；
  - `PING_PONG` 捕获基准值并交替方向，避免漂移；
  - `MIRROR` 保持 Tween 方向，奇数迭代反转 target 参数。
- `GFFPlayer` Inspector 默认显示 `auto_play` 与 `default_combo_index`。
- **GFFPlayer Combo 存储模型重构**：Combo 现在默认存储在 `combo_dictionary: Dictionary[String, GFFCombo]` 中，Timeline Editor 直接编辑该字典；旧的 `active_combo` / `timeline_data` 自动迁移。
- Inspector Combos 区域改为自定义列表：支持添加、右侧图标重命名/删除、点击切换编辑的 Combo。
- Effects 编辑现在依附于选中的 Combo，不再作为独立的 Quick Effects 存在。
- `GFFFeedback.stop()` 新增 `_stop()` 虚方法，子类可自定义停止清理逻辑。

### Added
- **Timeline Editor 编辑增强（Direction B）**：
  - 多选：Ctrl+Click 切换选中、空白处拖拽框选（Ctrl/Shift 并集），选中高亮；Delete 删除所有选中块；拖动任一选中块可整组移动。
  - 复制/粘贴：Ctrl+C / Ctrl+V，粘贴到播放头位置（无播放头时保持原 start_time），粘贴时深复制 effect 实例，支持跨 Combo / Player 粘贴（`GFFBlockClipboard`）。
  - 吸附到网格：工具栏 🧲 Snap 开关（激活时高亮）+ 步长下拉（0.01/0.05/0.1/0.25/0.5s）。
  - Event 块：`GFFEventEffect`（event_type=method/signal，method_name、signal_name、args），金色菱形标记、零时长、不参与重叠检测，播放头到达 start_time 时在预览/运行时触发。
  - 时间轴缩放：鼠标滚轮以光标为中心缩放，工具栏 Reset Zoom 按钮。
- `tests_optional` 之外新增 `addons/game_feel_flow_pro/tests/test_timeline_editor.gd`：多选、复制/粘贴、吸附计算、Event 触发共 18 个用例。
- `tests_optional/test_effect_loop.gd`：覆盖 REPEAT / PING_PONG / MIRROR 与无限循环停止。
- `docsite/docs/effects/looping.md`：循环效果文档与截图占位。
- Pro plugin 向编辑器 preview 实例注册 effect，支持 Timeline / Inspector 预览 Pro target。
- `GFFFeedbackStack`：管理 Feedback 的叠加策略（IGNORE / CANCEL / REPLACE / QUEUE / ADD）、排队和停止。
- Events 效果：`GFFEvent`（全局事件）、`GFFSignal`（节点信号）、`GFFMethod`（节点方法调用）。
- 内置 Curve Presets 资源文件与生成脚本。
- 内置 Combo 静态工厂扩展（`hit_medium`、`hit_critical`、`death_explosion`、`pickup_*`、`ui_*`、`explosion_*` 等）。
- `GFFPlayer` 新增 Editor 辅助方法：`editor_add_combo`、`editor_rename_combo`、`editor_delete_combo`、`editor_add_effect_to_combo`、`editor_remove_effect_from_combo`、`editor_set_entry_enabled`。
- 测试覆盖：`test_gff_feedback_stack.gd`、`test_events.gd`，测试总数提升至 213。

### Fixed
- 修复循环示例场景切换时未停止 GFFPlayer 导致的残留 shake / `data.tree is null` 报错。
- 修复 headless 测试中的 CanvasItem / RID 资源泄漏（`test_example_scenes.gd` 未释放示例组件节点）。
- 修复 `GFFFeedbackStack.ADD` 策略下同 label 实例互相覆盖的问题。
- 修复示例场景 `main_3d.tscn` 对已删除 `presets/combos/*.tres` 的依赖。

### Added
- Initial version release
- Core framework
  - GameFeelFlow global singleton
  - GFFPlayer node component
  - GFFFeedback base class
  - GFFParams parameter class (supports chaining)
  - GFFCombo combo effect
  - GFUtil utility class
- Resource-based effect system (NEW)
  - GFFEffect resource class (data-driven effects)
  - GFFEffectExecutor node (effect execution)
  - GFFEffectCombo resource (combo effects)
  - 14+ effect types
  - Factory methods for easy creation
  - Can be saved as .tres files
- Basic feedback effects (22 effects)
  - GFFShake shake effect
  - GFFFlash flash effect
  - GFFFreezeFrame freeze frame
  - GFFScale scale effect
  - GFFSound sound effect
  - GFFPosition position effect
  - GFFRotation rotation effect
  - GFFCameraShake camera shake
  - GFFCameraZoom camera zoom
  - GFFCameraFlash camera flash
  - GFFAudioVolume audio volume
  - GFFColor color effect
  - GFFAlpha alpha effect
  - GFFTimeScale time scale
  - GFFParticles particles effect
  - GFFImpulse impulse effect
  - GFFVelocity velocity effect
  - GFFTween tween animation
  - GFFAnimator animator control
  - GFFEvent event trigger
  - GFFSignal signal trigger
  - GFFMethod method call
- Signal system
  - Native signal support
  - String routing support
  - Auto-bind functionality
- Find strategies
  - Direct child lookup
  - Recursive lookup
  - Group lookup
  - Auto selection
- Curve presets
  - GFFCurvePresets class (25+ presets)
  - Linear, Ease In, Ease Out, Ease In Out
  - Bounce, Elastic, Back special effects
  - Decay curves, Shake curves
- Debug tools
  - GFFDebugPanel debug panel
  - GFFDebugOverlay visual overlay
  - GFFDebugLogger logging system
  - GFFDebugManager debug manager
- Presets
  - GFFPresets preset class (13 presets)
  - Hit effects, Death effects, Pickup effects, UI effects, Environment effects
- Main scenes
  - main_2d 2D main scene (collection display)
  - main_3d 3D main scene (collection display)
  - main_ui UI main scene (collection display)
- Example scenes
  - demo_basic basic demo
  - demo_effects effects demo
  - demo_curves curve presets demo
  - demo_debug debug tools demo
  - demo_action action game demo
  - demo_ui UI demo
  - demo_complete complete demo
- Unit tests (GdUnit4)
  - test_gff_params parameter class tests
  - test_gff_feedback feedback base tests
  - test_gff_feedback_stack feedback stack tests
  - test_gff_player player node tests
  - test_gff_combo combo effect tests
  - test_game_feel_flow global singleton tests
  - test_gff_shake shake effect tests
- CI/CD
  - GitHub Actions automated testing

### Changed
- None

### Deprecated
- None

### Removed
- None

### Fixed
- None

### Security
- None

---

## [0.1.0] - 2024-XX-XX

### Added
- Project initialization
- Documentation
  - REQUIREMENTS.md requirements document
  - README.md project description
  - CHANGELOG.md changelog

---

## Version Notes

- **Major**: Incompatible API changes
- **Minor**: Backwards-compatible functionality additions
- **Patch**: Backwards-compatible bug fixes

---

## Todo

### Phase 1: Core Framework ✅
- [x] Plugin base structure
- [x] GameFeelFlow singleton
- [x] GFFFeedback base class
- [x] GFFPlayer node
- [x] GFFParams parameter class
- [x] GFFFeedbackStack stack
- [x] Signal system
- [x] Unit tests (GdUnit4)
- [x] CI/CD configuration

### Phase 2: Basic Feedback ✅
- [x] Transform feedback (4 effects)
  - GFFShake shake
  - GFFScale scale
  - GFFPosition position
  - GFFRotation rotation
- [x] Camera feedback (3 effects)
  - GFFCameraShake camera shake
  - GFFCameraZoom camera zoom
  - GFFCameraFlash camera flash
- [x] Audio feedback (2 effects)
  - GFFSound sound
  - GFFAudioVolume audio volume
- [x] Visual feedback (3 effects)
  - GFFFlash flash
  - GFFColor color
  - GFFAlpha alpha
- [x] Time feedback (2 effects)
  - GFFFreezeFrame freeze frame
  - GFFTimeScale time scale
- [x] Particles feedback (2 effects)
  - GFFParticles particles
- [x] Physics feedback (2 effects)
  - GFFImpulse impulse
  - GFFVelocity velocity
- [x] Animation feedback (2 effects)
  - GFFTween tween animation
  - GFFAnimator animator control
- [x] Events feedback (3 effects)
  - GFFEvent event trigger
  - GFFSignal signal trigger
  - GFFMethod method call

### Phase 3: Parameter Curves ✅
- [x] Curve resource integration (using Godot built-in)
- [x] Curve presets library (25+ presets)
- [x] Runtime hot update (Godot built-in support)

### Phase 4: Debug Tools ✅
- [x] Debug panel (GFFDebugPanel)
- [x] Visual overlay (GFFDebugOverlay)
- [x] Log output (GFFDebugLogger)
- [x] Debug switch (GFFDebugManager)

### Phase 5: Presets and Examples ✅
- [x] Preset library (13 presets)
  - Hit effects (4)
  - Death effects (2)
  - Pickup effects (3)
  - UI effects (2)
  - Environment effects (2)
- [x] Demo scenes (10)
  - main_2d 2D main scene
  - main_3d 3D main scene
  - main_ui UI main scene
  - demo_basic basic demo
  - demo_effects effects demo
  - demo_curves curve presets demo
  - demo_debug debug tools demo
  - demo_action action game demo
  - demo_ui UI demo
  - demo_complete complete demo
- [x] Complete documentation

### Phase 6: Asset Library Submission 📅
- [ ] Prepare icons and screenshots
- [ ] Write Asset Library description
- [ ] Submit for review
- [ ] Community promotion

### Phase 7: Pro Version Development 📅
- [ ] UI feedback (8 effects)
- [ ] Screen effects (6 effects)
- [ ] Advanced Transform (4 effects)
- [ ] Advanced Camera (5 effects)
- [ ] Advanced Audio (5 effects)
- [ ] Advanced Visual (6 effects)
- [ ] Haptics (3 effects)
- [ ] Preset library (50 presets)
- [ ] Editor tools (7 tools)
