<p align="center">
  <img src="icon.png" alt="Game Feel Flow" width="160">
</p>

# Game Feel Flow

<p align="center">馃幃 One-stop game feel (juice) system for Godot 鈥?shake, flash, freeze frames, camera work and more, as composable data-driven effects.</p>

[![Godot Engine](https://img.shields.io/badge/Godot%20Engine-4.6+-478cbf?logo=godotengine&logoColor=white)](https://godotengine.org/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Docs](https://img.shields.io/badge/Docs-Online-blue)](https://indieshade.github.io/godot-plugin-game-feel-flow/)
[![Pro](https://img.shields.io/badge/Pro%20Extension-Available-orange)](#-pro-version)

---

## 鉁?Why Game Feel Flow?

- 馃幆 **One-line effects** 鈥?`GFUtil.hit(self, 2.0)` and you're done
- 馃З **29 built-in effects + 15 ready-made combos** 鈥?transform, camera, audio, time, particles, physics, events
- 馃帥锔?**Edit in the Inspector** 鈥?the `GFFPlayer` node exposes combos and effects directly in the Godot Inspector, no code required
- 馃攣 **Loop modes** 鈥?Repeat / Ping-Pong / Mirror, finite or infinite, for breathing, heartbeat and warning-idle effects
- 馃搱 **Custom easing curves** 鈥?override any tweener with a visual `Curve`
- 鈿?**Overlap strategies** 鈥?Ignore / Cancel / Replace / Queue / Add when effects collide
- 鈫╋笍 **Editor Undo/Redo** 鈥?all Inspector edits integrate with `EditorUndoRedoManager`

![GFFPlayer Inspector](https://indieshade.github.io/godot-plugin-game-feel-flow/images/gffplayer-inspector.png)

---

## 馃殌 Installation

### From the Godot Asset Library (recommended)

1. Open the **AssetLib** tab in the Godot editor
2. Search for **"Game Feel Flow"** and install
3. Enable the plugin in **Project 鈫?Project Settings 鈫?Plugins**

### From GitHub

1. Download the [latest repository archive](https://github.com/IndieShade/godot-plugin-game-feel-flow)
2. Copy `addons/game_feel_flow` into your project's `addons/` folder
3. Enable the plugin in **Project 鈫?Project Settings 鈫?Plugins**

---

## 馃幃 Quick Start

```gdscript
# Method 1: GFUtil shortcuts (fastest)
GFUtil.hit(self, 2.0)
GFUtil.death(self)
GFUtil.pickup(self)

# Method 2: GameFeelFlow singleton
GameFeelFlow.play("hit", self, {"intensity": 2.0})

# Method 3: GFFPlayer node (no code 鈥?configure combos in the Inspector)
$GFFPlayer.play("hit", {"intensity": 2.0})
```

Chained parameters:

```gdscript
GameFeelFlow.play("shake", self, GFFParams.create(2.0, 0.5)
    .with_float("amplitude", 15.0)
    .with_color("color", Color.RED)
    .with_curve("curve", my_curve))
```

馃摉 Full guide: [Quick Start](https://indieshade.github.io/godot-plugin-game-feel-flow/getting-started/quick-start/)

---

## 馃幀 Open this first

Try the example scenes in this order:

1. **`addons/game_feel_flow/examples/showcase.tscn`** 鈥?Free reel for recording and first impressions (**16:9**). Shots **loop in place**; use **Prev / Next** to change shots and **H** to hide the chrome bar.
2. **`addons/game_feel_flow/examples/onboarding.tscn`** 鈥?Short walkthrough of `GFFPlayer` and combos.
3. **`addons/game_feel_flow/examples/effect_library.tscn`** 鈥?Full effect catalog / lab.
4. **`addons/game_feel_flow_pro/examples/showcase.tscn`** *(Pro)* 鈥?Pro-only reel (screen, blur, UI, material, audio, timeline, xform, climax) with the same transport controls.

馃摉 [Examples documentation](https://indieshade.github.io/godot-plugin-game-feel-flow/examples/)

---

## 馃幆 Built-in Effects (Free 鈥?29)

| Category | Effects |
|----------|---------|
| **Transform** | `shake_position` `shake_scale` `shake_rotation` `punch_position` `punch_scale` `punch_rotation` `curved_position` `curved_scale` `curved_rotation` (aliases: `shake`, `punch`) |
| **Visual** | `flash` `color` `alpha` |
| **Camera** | `camera_shake` `camera_zoom` `camera_fov` `camera_flash` |
| **Audio** | `sound` `audio_volume` |
| **Time** | `freeze_frame` `time_scale` |
| **Particles** | `particles` `gpu_particles` |
| **Physics** | `impulse` `velocity` |
| **Animation** | `tween` `animator` |
| **Events** | `event` `signal` `method` |

Plus **15 built-in combos**: `hit_light/medium/heavy/critical`, `death`, `death_explosion`, `pickup`, `pickup_coin/health/power`, `explosion`, `explosion_small/large`, `ui_button_press`, `ui_notification`.

![Combo editing in the Inspector](https://indieshade.github.io/godot-plugin-game-feel-flow/images/combo-list.png)

---

## 馃攣 Loop Effects

Any effect can loop 鈥?`loop_count = -1` loops forever, `0` plays once:

- **Repeat** 鈥?restarts from the beginning each cycle
- **Ping-Pong** 鈥?alternates direction without drift
- **Mirror** 鈥?inverts target parameters on odd iterations, tween direction unchanged

Perfect for breathing, heartbeats, warning pulses and idle animations.

![Loop demo](https://indieshade.github.io/godot-plugin-game-feel-flow/images/repeat-loop-heartbeat.png)

馃摉 [Looping documentation](https://indieshade.github.io/godot-plugin-game-feel-flow/effects/looping/)

---

## 馃拵 Pro Version

**Game Feel Flow Pro** is a paid extension that drops into `addons/` alongside the free version:

- 馃枼锔?**Timeline Editor** 鈥?arrange effect blocks on tracks: multi-select, copy/paste, snap-to-grid, event blocks, mouse-wheel zoom
- 馃帹 **23 additional effects** 鈥?UI (9), screen shaders (6), advanced audio (3), material (2), squash & stretch / spring / wiggle (3)
- 馃О **10 extra targets + 2 tweeners + 15 editor presets**

馃憠 [Get Game Feel Flow Pro on itch.io](https://indieshade.itch.io/game-feel-flow-pro)

![Timeline Editor (Pro)](https://indieshade.github.io/godot-plugin-game-feel-flow/images/timeline-editor.png)

馃摉 [Pro documentation](https://indieshade.github.io/godot-plugin-game-feel-flow/pro/)

---

## 馃摉 Documentation

- **Online docs**: https://indieshade.github.io/godot-plugin-game-feel-flow/
- [Installation](https://indieshade.github.io/godot-plugin-game-feel-flow/getting-started/installation/)
- [API Reference](https://indieshade.github.io/godot-plugin-game-feel-flow/api/)
- [Effect List](https://indieshade.github.io/godot-plugin-game-feel-flow/effects/)

---

## 馃З Custom Effects

Extend `GFFEffect` to create your own:

```gdscript
class_name MyEffect
extends GFFEffect

func _execute(node: Node, params: GFFParams) -> void:
    var intensity = _get_intensity(params)
    var duration = _get_duration_param(params)
    # Your effect logic here...
```

---

## 馃 Contributing

Issues and Pull Requests are welcome on the [public repository](https://github.com/IndieShade/godot-plugin-game-feel-flow)!

---

## 馃搫 License

MIT License 鈥?see [LICENSE](LICENSE).

## 馃檹 Credits

- [Unity Feel by More Mountains](https://assetstore.unity.com/packages/tools/utilities/feel-176399) 鈥?Inspiration
- [Godot Engine](https://godotengine.org/) 鈥?Game engine

---

<p align="center">
  Made with 鉂わ笍 for the Godot community
</p>
