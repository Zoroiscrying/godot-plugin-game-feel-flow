# Game Feel Flow

One-stop game feel (juice) system for Godot — shake, flash, freeze frames, camera work and more, as composable data-driven effects.

[![Godot Engine](https://img.shields.io/badge/Godot%20Engine-4.6+-478cbf?logo=godotengine&logoColor=white)](https://godotengine.org/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Docs](https://img.shields.io/badge/Docs-Online-blue)](https://indieshade.github.io/godot-plugin-game-feel-flow/)

> This file ships inside `addons/game_feel_flow/` so Asset Library installs always keep the license and docs entry points with the plugin.

## Enable

1. Open **Project → Project Settings → Plugins**
2. Enable **Game Feel Flow**

## Quick start

```gdscript
# Method 1: GFUtil shortcuts (fastest)
GFUtil.hit(self, 2.0)
GFUtil.death(self)
GFUtil.pickup(self)

# Method 2: GameFeelFlow singleton
GameFeelFlow.play("hit", self, {"intensity": 2.0})

# Method 3: GFFPlayer node (configure combos in the Inspector)
$GFFPlayer.play("hit", {"intensity": 2.0})
```

## Try these scenes first

1. `examples/showcase.tscn` — Free reel (**16:9**)
2. `examples/onboarding.tscn` — GFFPlayer + combos walkthrough
3. `examples/effect_library.tscn` — Full effect catalog / lab

## Features

- 29 built-in effects + 15 ready-made combos
- Edit combos on `GFFPlayer` in the Inspector
- Loop modes: Repeat / Ping-Pong / Mirror
- Custom easing curves and overlap strategies
- Editor Undo/Redo integration

## Documentation

- Online docs: https://indieshade.github.io/godot-plugin-game-feel-flow/
- Public repository: https://github.com/IndieShade/godot-plugin-game-feel-flow
- Pro extension: https://indieshade.itch.io/game-feel-flow-pro

## License

MIT License — see [LICENSE](LICENSE).
