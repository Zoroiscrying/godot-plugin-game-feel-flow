# Game Feel Flow

> 🎮 Professional game feel enhancement system for Godot

[![Godot Engine](https://img.shields.io/badge/Godot%20Engine-4.2+-478cbf?logo=godotengine&logoColor=white)](https://godotengine.org/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Pro](https://img.shields.io/badge/Pro%20Extension-Available-orange)](#-pro-version)

---

## ✨ Features

- 🎯 **One-line effects** — Simple and easy-to-use API
- 🎨 **Rich feedback types** — Shake, flash, scale, sound, and more
- 📦 **Resource-based reuse** — Effects can be saved as .tres files
- 🔧 **Parameter curves** — Visual easing curve editing
- 🐛 **Debug tools** — Runtime effect execution monitoring
- ⚡ **Overlap strategies** — Smart handling of simultaneous effects
- ↩️ **Editor Undo/Redo** — Timeline and Inspector edits are undoable via `EditorUndoRedoManager`

---

## 🚀 Quick Start

### Installation

1. Download the plugin
2. Copy `addons/game_feel_flow` folder to your project
3. Enable the plugin in Godot editor

### Basic Usage

```gdscript
# Method 1: Use GFUtil (fastest)
GFUtil.hit(self, 2.0)
GFUtil.death(self)
GFUtil.pickup(self)

# Method 2: Use GameFeelFlow
GameFeelFlow.play("hit", self, {"intensity": 2.0})

# Method 3: Use GFFPlayer
$GFFPlayer.play("hit", {"intensity": 2.0})
```

### Chained Parameters

```gdscript
GameFeelFlow.play("shake", self, GFFParams.create(2.0, 0.5)
    .with_float("amplitude", 15.0)
    .with_color("color", Color.RED)
    .with_curve("curve", my_curve))
```

---

## 🎬 Demo

Open `addons/game_feel_flow/examples/demo_combo_workflow.tscn` and run it:

- **Left Click** — play the `hit` combo
- **Space** — play the `explosion` combo

![Inspector Screenshot](docs/images/inspector_screenshot.png)

---

## 📖 Documentation

- **Online Docs**: https://zoroiscrying.github.io/godot-plugin-game-feel-flow/
- [Requirements Document](docs/REQUIREMENTS.md)
- [Testing Guide](docs/TESTING.md)
- [API Documentation](docs/API.md)
- [Quick Start](docs/QUICKSTART.md)

---

## 🎯 Feedback Types

### Free Version (23 effects)

| Category | Effect | Class |
|----------|--------|-------|
| **Transform** | Shake | `GFFEffectCommon` + `GFFPositionTarget` + `GFFShakeTweener` |
| | Scale | `GFFEffectCommon` + `GFFScaleTarget` + `GFFLinearTweener` |
| | Position | `GFFEffectCommon` + `GFFPositionTarget` + `GFFLinearTweener` |
| | Rotation | `GFFEffectCommon` + `GFFRotationTarget` + `GFFLinearTweener` |
| **Camera** | Camera Shake | `GFFEffectCommon` + `GFFCameraOffsetTarget` + `GFFShakeTweener` |
| | Camera Zoom | `GFFEffectCommon` + `GFFCameraZoomTarget` + `GFFLinearTweener` |
| | Camera FOV | `GFFEffectCommon` + `GFFCameraFovTarget` + `GFFLinearTweener` |
| | Camera Flash | `GFFCameraFlash` |
| **Audio** | Sound | `GFFSound` |
| | Audio Volume | `GFFAudioVolume` |
| **Visual** | Flash | `GFFEffectCommon` + `GFFColorTarget` + `GFFFlashTweener` |
| | Color | `GFFEffectCommon` + `GFFColorTarget` + `GFFColorTweener` |
| | Alpha | `GFFEffectCommon` + `GFFAlphaTarget` + `GFFLinearTweener` |
| **Time** | Freeze Frame | `GFFFreezeFrame` |
| | Time Scale | `GFFTimeScale` |
| **Particles** | Particles | `GFFParticles` |
| **Physics** | Impulse | `GFFImpulse` |
| | Velocity | `GFFVelocity` |
| **Animation** | Tween | `GFFTween` |
| | Animator | `GFFAnimator` |
| **Events** | Event | `GFFEvent` |
| | Signal | `GFFSignal` |
| | Method | `GFFMethod` |

### Pro Version (49 additional effects)

Upgrade to **Game Feel Flow Pro** for specialized feedback categories:

- UI Feedback (8 effects)
- Screen Effects (6 effects)
- Advanced Transform (4 effects)
- Advanced Camera (5 effects)
- Advanced Audio (5 effects)
- Advanced Visual (6 effects)
- Haptics (3 effects)
- And more...

See [`addons/game_feel_flow_pro/README.md`](addons/game_feel_flow_pro/README.md) for installation and details.

### Version Comparison

| | Free | Pro - Personal | Pro - Studio |
|---|:---:|:---:|:---:|
| **Price** | $0 | $29 | $79 |
| **Effects** | 23 | 72 | 72 |
| **Presets** | 10+ | 60 | 60 |
| **Editor Tools** | Basic | Advanced | Advanced |
| **Updates** | - | 1 year | Permanent |
| **Commercial License** | MIT | Personal | Studio |

### Usage Examples

```gdscript
# Using effect name
GameFeelFlow.play("shake", self, {"intensity": 2.0})
GameFeelFlow.play("scale", self, GFFParams.create(1.5, 0.3))
GameFeelFlow.play("color", self, GFFParams.create().with_color("color", Color.RED))

# Using GFUtil shortcuts
GFUtil.shake(self, 2.0)
GFUtil.flash(self, Color.RED)
GFUtil.freeze(0.1)
```

---

## 🛠️ Development

### Project Structure

```
addons/game_feel_flow/
├── plugin.cfg              # Plugin configuration
├── plugin.gd               # Plugin entry point
├── core/                   # Core system
│   ├── game_feel_flow.gd   # Global singleton
│   ├── gff_player.gd       # Player node
│   ├── gff_effect.gd       # Effect base class
│   ├── gff_effect_stack.gd # Running effect stack / overlap manager
│   ├── gff_effect_registry.gd # Effect factory and preset registry
│   ├── gff_params.gd       # Parameter class
│   ├── gff_combo.gd        # Combo effect
│   ├── gff_time_scale_manager.gd # Stack-based time-scale manager
│   ├── gf_util.gd          # Utility class
│   ├── targets/            # Target property adapters
│   │   ├── gff_target.gd
│   │   ├── gff_position_target.gd
│   │   ├── gff_scale_target.gd
│   │   ├── gff_rotation_target.gd
│   │   ├── gff_color_target.gd
│   │   ├── gff_alpha_target.gd
│   │   ├── gff_ui_position_target.gd
│   │   ├── gff_ui_scale_target.gd
│   │   ├── gff_ui_rotation_target.gd
│   │   ├── gff_ui_color_target.gd
│   │   ├── gff_ui_alpha_target.gd
│   │   ├── gff_material_color_target.gd
│   │   ├── gff_material_alpha_target.gd
│   │   ├── gff_camera_offset_target.gd
│   │   ├── gff_camera_zoom_target.gd
│   │   └── gff_camera_fov_target.gd
│   └── tweeners/           # Tweener interpolation drivers
│       ├── gff_tweener.gd
│       ├── gff_linear_tweener.gd
│       ├── gff_elastic_tweener.gd
│       ├── gff_shake_tweener.gd
│       ├── gff_flash_tweener.gd
│       └── gff_color_tweener.gd
├── effects/                # Feedback effects
│   └── curved/
│       └── gff_effect_common.gd  # Generic Target + Tweener effect
├── presets/                # Preset resources
├── editor/                 # Editor tools
└── examples/               # Example scenes

tests_optional/             # Unit tests (requires GdUnit4)
├── test_gff_params.gd
├── test_gff_effect.gd
├── test_gff_effect_stack.gd
├── test_gff_player.gd
├── test_gff_combo.gd
├── test_game_feel_flow.gd
└── test_gff_shake.gd
```

### Running Tests

Tests require [GdUnit4](https://github.com/MikeSchulze/gdUnit4) framework.

```bash
# Linux/macOS
./run_tests.sh

# Windows
run_tests.bat
```

Or run manually:

```bash
# Download GdUnit4
git clone https://github.com/MikeSchulze/gdUnit4.git addons/gdUnit4

# Run tests
godot --headless --script res://addons/gdUnit4/bin/GdUnitCmdTool.gd -- --add "res://tests_optional/"
```

**Note:** Test scripts are located in `tests_optional/` folder. This folder is ignored by Godot (.gdignore) to prevent loading errors when GdUnit4 is not installed.

### Custom Effect

```gdscript
class_name MyEffect
extends GFFEffect

func _execute(node: Node, params: GFFParams) -> void:
    var intensity = _get_intensity(params)
    var duration = _get_duration_param(params)

    # Your effect logic here...
```

---

## 📋 Roadmap

- [x] Core framework
- [x] Unit tests (GdUnit4)
- [x] Basic feedback effects (23 effects)
- [x] Parameter curve presets
- [x] Debug tools
- [x] Preset library (13 presets)
- [ ] Asset Library submission
- [ ] Pro version development

---

## 🤝 Contributing

Issues and Pull Requests are welcome!

---

## 📄 License

MIT License

---

## 🙏 Credits

- [Unity Feel by More Mountains](https://assetstore.unity.com/packages/tools/utilities/feel-176399) — Inspiration
- [Godot Engine](https://godotengine.org/) — Game engine

---

<p align="center">
  Made with ❤️ for the Godot community
</p>
