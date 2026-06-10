# Game Feel Flow — Requirements Document

> Professional game feel enhancement system for Godot

---

## 1. Product Positioning

### 1.1 Core Value

**Game Feel Flow** is a one-stop game feel enhancement system that enables developers to quickly implement professional hit feedback, visual effects, and impact sensations.

### 1.2 Target Users

| User Type | Need | Solution |
|-----------|------|----------|
| **Beginner Developers** | Quick start | Preset library + examples |
| **Independent Developers** | Efficient iteration | Parameter curves + runtime hot update |
| **Small Teams** | Team collaboration | Resource-based + debug tools |
| **Professional Users** | Advanced features | Pro version editor tools |

### 1.3 Competitive Analysis

**Unity Feel by More Mountains** — The most popular Game Feel plugin in Unity ecosystem

| Feature | Unity Feel | Game Feel Flow |
|---------|-----------|----------------|
| **Feedback Count** | 300+ | Free 50+, Pro 150+ |
| **Core Architecture** | MMFeedbacks + MMFeedback | GFFFeedbackStack + GFFFeedback |
| **Configuration** | Inspector visualization | Inspector + resources + code |
| **Extensibility** | C# inheritance | GDScript inheritance + resource system |
| **Price** | $60 | Free $0 / Pro $29 |

---

## 2. Core Pain Points Analysis

### 2.1 Pain Point Priority

#### P0 — Must Solve (Core Value)

| Priority | Pain Point | Solution |
|----------|------------|----------|
| **1** | **Code Invasion** | Hybrid mode (node + resource + signal) |
| **2** | **Difficult to Reuse** | .tres file export |
| **3** | **Parameter Tuning Hell** | Parameter curves + runtime hot update |

#### P1 — Should Solve (Experience Enhancement)

| Priority | Pain Point | Solution |
|----------|------------|----------|
| **4** | **Debug Pain** | Debug panel + visual markers + logging |
| **5** | **Effect Overlap** | Hybrid strategies + priority |

#### P2 — Future Iteration (Nice to Have)

| Priority | Pain Point | Solution |
|----------|------------|----------|
| **6** | **Performance Black Box** | Performance analyzer (Pro) |
| **7** | **Team Collaboration** | Editor tools (Pro) |

---

## 3. Architecture Design

### 3.1 Core Components

| Component | Type | Description |
|-----------|------|-------------|
| **GameFeelFlow** | Global Singleton | Quick access to effects, signal system, preset management |
| **GFFPlayer** | Node Component | Attached to game objects, contains feedback stack |
| **GFFFeedback** | Resource Base | Base class for all feedback effects |
| **GFFParams** | Resource Class | Parameter passing, supports chaining |
| **GFFFeedbackStack** | Resource Class | Feedback stack, manages multiple effects |
| **GFFCombo** | Resource Class | Combo effects, predefined effect combinations |
| **GFUtil** | Static Utility | Shortcut methods for quick demo development |

### 3.2 Architecture Pattern

**Hybrid Mode (Node + Resource + Signal)**

| Mode | Use Case | Example |
|------|----------|---------|
| **Node Mounting** | Effects bound to specific objects | Character hit flash, camera shake |
| **Resource Reference** | Reusable generic effects | Hit sound, pickup particles |
| **Signal Driven** | Global/UI/cross-object effects | Global slow motion, UI popup animation |

### 3.3 Design Principles

1. **User Choice** — Teach through templates and demos
2. **Three modes interoperable** — Node, resource, signal
3. **Same effect repeated trigger no conflict** — Handle through overlap strategies

---

## 4. API Design

### 4.1 GameFeelFlow (Global Singleton)

```gdscript
# ===== Core Play Methods =====
GameFeelFlow.play(effect, target: Node, params = null) -> void
# effect: GFFEffect | GFFFeedback | String
# target: Node | GFFPlayer (auto-find child nodes)
# params: GFFParams | Dict | float | null

GameFeelFlow.play_global(effect, params = null) -> void

# ===== Signal System =====
GameFeelFlow.emit(event: String, data: Dictionary = {}) -> void
GameFeelFlow.listen(event: String, callback: Callable) -> void
GameFeelFlow.connect_signal(sig: Signal, callback: Callable) -> void
GameFeelFlow.auto_bind(sig: Signal, player: GFFPlayer, effect) -> void

# ===== Preset Management =====
GameFeelFlow.get_preset(name: String) -> GFFFeedback
GameFeelFlow.register_preset(name: String, feedback: GFFFeedback) -> void
```

### 4.2 GFFPlayer (Node Component)

```gdscript
# ===== Core Play Methods =====
func play(effect, params = null) -> void
# effect: GFFEffect | GFFFeedback | String

func play_combo(combo: GFFCombo, params = null) -> void

# ===== Control Methods =====
func stop() -> void
func stop_all() -> void

# ===== Resource Management =====
func export_stack() -> Resource
func import_stack(resource: Resource) -> void
```

### 4.3 GFUtil (Utility)

```gdscript
# ===== Shortcut Methods (for quick demo development) =====
GFUtil.hit(target: Node, intensity: float = 1.0) -> void
GFUtil.death(target: Node) -> void
GFUtil.pickup(target: Node) -> void
GFUtil.shake(target: Node, intensity: float = 1.0) -> void
GFUtil.flash(target: Node, color: Color = Color.WHITE) -> void
GFUtil.freeze(duration: float = 0.1) -> void
GFUtil.slow_motion(duration: float = 1.0, scale: float = 0.3) -> void
```

### 4.4 GFFParams (Parameter Class)

```gdscript
class_name GFFParams
extends Resource

# Common parameters
@export var intensity: float = 1.0
@export var duration: float = -1.0

# Extension parameters
@export var _data: Dictionary = {}

# ===== Chaining Methods =====
func with_float(key: String, value: float) -> GFFParams
func with_int(key: String, value: int) -> GFFParams
func with_bool(key: String, value: bool) -> GFFParams
func with_vector2(key: String, value: Vector2) -> GFFParams
func with_vector3(key: String, value: Vector3) -> GFFParams
func with_color(key: String, value: Color) -> GFFParams
func with_string(key: String, value: String) -> GFFParams
func with_curve(key: String, value: Curve) -> GFFParams
func with_node(key: String, value: Node) -> GFFParams
func with_resource(key: String, value: Resource) -> GFFParams
func with_variant(key: String, value: Variant) -> GFFParams

# ===== Get Methods =====
func get_float(key: String, default: float = 0.0) -> float
func get_int(key: String, default: int = 0) -> int
func get_bool(key: String, default: bool = false) -> bool
func get_vector2(key: String, default: Vector2 = Vector2.ZERO) -> Vector2
func get_vector3(key: String, default: Vector3 = Vector3.ZERO) -> Vector3
func get_color(key: String, default: Color = Color.WHITE) -> Color
func get_string(key: String, default: String = "") -> String
func get_curve(key: String, default: Curve = null) -> Curve
func get_node(key: String, default: Node = null) -> Node
func get_resource(key: String, default: Resource = null) -> Resource
func get_variant(key: String, default: Variant = null) -> Variant

# ===== Static Factory Methods =====
static func create(intensity: float = 1.0, duration: float = -1.0) -> GFFParams
```

### 4.5 GFFCombo (Combo Effect)

```gdscript
class_name GFFCombo
extends Resource

@export var effects: Array[GFFFeedback] = []
@export var params: GFFParams = null

# Predefined combos
const DEATH = "death"
const HIT = "hit"
const PICKUP = "pickup"

# Static methods
static func death() -> GFFCombo
static func hit() -> GFFCombo
static func pickup() -> GFFCombo
```

### 4.6 Usage Examples

#### Quick Demo Development

```gdscript
# Using GFUtil (fastest)
GFUtil.hit(self, 2.0)
GFUtil.death(self)
GFUtil.pickup(self)
GFUtil.shake(self)
GFUtil.freeze(0.2)
```

#### Formal Development

```gdscript
# Method 1: Simplest
GameFeelFlow.play(GFFEffect.HIT, self, 2.0)

# Method 2: Dictionary
GameFeelFlow.play(GFFEffect.HIT, self, {
    "intensity": 2.0,
    "duration": 0.5,
    "amplitude": 15.0
})

# Method 3: Chaining (recommended)
GameFeelFlow.play(GFFEffect.HIT, self, GFFParams.create(2.0, 0.5)
    .with_float("amplitude", 15.0)
    .with_color("color", Color.RED)
    .with_curve("curve", my_curve))

# Method 4: Node
$GFFPlayer.play(GFFEffect.HIT, {"intensity": 2.0})
```

#### Signal Driven

```gdscript
# Native signal
signal player_hit(intensity: float)

# Auto bind
GameFeelFlow.auto_bind(player_hit, $GFFPlayer, GFFEffect.HIT)

# String routing
GameFeelFlow.emit("player_hit", {"intensity": 2.0})
GameFeelFlow.listen("player_hit", _on_player_hit)
```

---

## 5. Feedback Type Distribution

### 5.1 Free Version (50+ effects)

| Category | Count | Contents |
|----------|-------|----------|
| **Transform** | 4 | Shake, Scale, Position, Rotation |
| **Camera** | 3 | Shake, Flash, Zoom |
| **Audio** | 2 | Sound, Volume Control |
| **Visual** | 3 | Flash, Color, Alpha |
| **Time** | 2 | Freeze Frame, Time Scale |
| **Particles** | 2 | Particles, GPU Particles |
| **Physics** | 2 | Impulse, Velocity |
| **Animation** | 2 | Tween, Animator |
| **Events** | 3 | Event, Signal, Method |

**Total: 23 core effects**

### 5.2 Pro Version (100+ effects)

**Includes all free content, plus:**

| Category | Extra Effects | Contents |
|----------|---------------|----------|
| **UI** | 8 | Shake, Color, Scale, Alpha, RectTransform, Text, Progress Bar, Scroll |
| **Screen Effects** | 6 | Chromatic Aberration, Vignette, Blur, Distortion, Pixelation, Scanlines |
| **Advanced Transform** | 4 | Squash & Stretch, Wiggle, Spring, Path Motion |
| **Advanced Camera** | 5 | Fade, Offset, Lens Distortion, Depth of Field, Multi-camera |
| **Advanced Audio** | 5 | Pitch, Filter, 3D Sound, Playlist, Mixer |
| **Advanced Visual** | 6 | Material, Shader, Sprite, Trail, Glow, Blur |
| **Haptics** | 3 | Haptic Feedback, Vibration Pattern, Device Control |
| **Other** | 12 | Advanced animation, physics, events, etc. |

**Total: 49 additional effects**

### 5.3 Business Strategy

**Core Strategy: Free version makes games "playable", Pro version makes games "fun"**

- ✅ Free version is good enough — 23 effects can create decent hit feedback
- ✅ But has obvious gaps — Missing UI feedback, screen effects, advanced animation
- ✅ Pro version has strong value — 49 additional effects, average less than $0.6 each

---

## 6. Technical Details

### 6.1 Curve Resources

**Use Godot built-in Curve resources, don't reinvent the wheel**

```gdscript
# Godot built-in Curve resource
var curve: Curve = Curve.new()
curve.add_point(Vector2(0, 0))
curve.add_point(Vector2(1, 1))
var value = curve.sample(0.5)

# Use in GFFParams
GFFParams.create().with_curve("easing", my_curve)

# Use in feedback effects
var curve = params.get_curve("easing", null)
if curve:
    value = curve.sample(t)
```

### 6.2 Overlap Strategies

**5 strategies for handling simultaneous effects**

```gdscript
enum OverlapStrategy {
    ADD,      # Additive - effects accumulate (shake, particles, sound)
    REPLACE,  # Replace - new effect replaces old (color, alpha)
    QUEUE,    # Queue - wait for previous to finish (screen effects)
    IGNORE,   # Ignore - skip if already playing
    CANCEL    # Cancel - stop current, play new
}
```

**Priority System**

```gdscript
@export var priority: int = 0  # Higher value = higher priority
@export var max_concurrent: int = -1  # Max simultaneous plays
```

**Default Strategy Recommendations**

| Effect Type | Recommended Strategy | Reason |
|-------------|---------------------|--------|
| Shake | ADD | Multiple shakes should accumulate |
| Color | REPLACE | Color can only show one |
| Particles | ADD | Multiple particles can show simultaneously |
| Sound | ADD | Multiple sounds can play simultaneously |
| Screen Effects | QUEUE | Screen effects need to queue |
| Camera Effects | CANCEL | Camera effects should interrupt |

### 6.3 Target Node Lookup

**Support auto-find GFFPlayer in child nodes**

```gdscript
# Pass parent node, auto-find GFFPlayer
GameFeelFlow.play(GFFEffect.HIT, player_node)

# Find strategy enum
enum FindStrategy {
    DIRECT_CHILD,  # Only direct children
    RECURSIVE,     # Recursive search
    GROUP,         # Use Group search
    AUTO           # Auto select (recommended)
}
```

### 6.4 Parameter Usage

**Get parameters in feedback effects**

```gdscript
func _execute(target: Node, params: GFFParams) -> void:
    # Get parameters directly from params
    var intensity = params.intensity if params else default_intensity
    var duration = params.duration if params else default_duration
    var amplitude = params.get_float("amplitude", default_amplitude)
    var frequency = params.get_float("frequency", default_frequency)
    var axes = params.get_vector3("axes", default_axes)
    
    # Execute effect logic...
```

---

## 7. File Structure

### 7.1 Split Repository Design

#### Repository 1: game-feel-flow (Free Version)

```
game-feel-flow/
├── addons/
│   └── game_feel_flow/
│       ├── plugin.cfg
│       ├── plugin.gd
│       ├── core/
│       ├── effects/
│       ├── presets/
│       ├── editor/
│       └── examples/
├── README.md
└── CHANGELOG.md
```

#### Repository 2: game-feel-flow-pro (Pro Version)

```
game-feel-flow-pro/
├── addons/
│   └── game_feel_flow_pro/
│       ├── plugin.cfg
│       ├── plugin.gd
│       ├── effects/
│       ├── presets/
│       └── editor/
├── README.md
└── CHANGELOG.md
```

### 7.2 User Usage

#### Free Version Only

```
my_game/
├── addons/
│   └── game_feel_flow/  # Download from free version repo
└── project.godot
```

#### With Pro Version

```
my_game/
├── addons/
│   ├── game_feel_flow/      # Download from free version repo
│   └── game_feel_flow_pro/  # Download from pro version repo
└── project.godot
```

---

## 8. Development Roadmap

### 8.1 Timeline

```
Week 1-2: Core framework
Week 3-5: Basic feedback (23 effects)
Week 6:   Parameter curves
Week 7:   Debug tools
Week 8:   Presets and examples
Week 9:   Asset Library submission
         ↓
      Free version released, gather user feedback
         ↓
Week 10-17: Pro version development (6-8 weeks)
Week 18-19: Commercialization
         ↓
      Pro version released, start earning
```

**Total time: ~4-5 months**

### 8.2 Detailed Plan

#### Phase 1: Core Framework (2 weeks)

| Task | Priority | Time |
|------|----------|------|
| Plugin base structure | P0 | 2 days |
| GameFeelFlow singleton | P0 | 1 day |
| GFFFeedback base class | P0 | 2 days |
| GFFPlayer node | P0 | 2 days |
| GFFParams parameter class | P0 | 1 day |
| GFFFeedbackStack stack | P0 | 2 days |
| Signal system (native + string) | P0 | 2 days |

#### Phase 2: Basic Feedback (3 weeks)

| Category | Effects | Time |
|----------|---------|------|
| Transform | 4 effects | 4 days |
| Camera | 3 effects | 3 days |
| Audio | 2 effects | 2 days |
| Visual | 3 effects | 3 days |
| Time | 2 effects | 2 days |
| Particles | 2 effects | 2 days |
| Physics | 2 effects | 2 days |
| Animation | 2 effects | 2 days |
| Events | 3 effects | 2 days |

#### Phase 3: Parameter Curves (1 week)

| Task | Priority | Time |
|------|----------|------|
| Curve resource integration | P0 | 2 days |
| Inspector curve editor | P0 | 3 days |
| Runtime hot update | P1 | 2 days |

#### Phase 4: Debug Tools (1 week)

| Task | Priority | Time |
|------|----------|------|
| Debug panel | P1 | 2 days |
| Visual markers | P1 | 2 days |
| Log output | P1 | 1 day |
| Debug switch | P1 | 1 day |

#### Phase 5: Presets and Examples (1 week)

| Task | Priority | Time |
|------|----------|------|
| 10 preset effects | P1 | 3 days |
| 3 demo scenes | P1 | 3 days |
| Basic documentation | P1 | 2 days |

#### Phase 6: Asset Library Submission (1 week)

| Task | Priority | Time |
|------|----------|------|
| Prepare icons and screenshots | P1 | 1 day |
| Write Asset Library description | P1 | 1 day |
| Submit for review | P1 | 1 day |
| Community promotion | P1 | 2 days |

#### Phase 7: Pro Version Development (6-8 weeks)

| Category | Effects | Time |
|----------|---------|------|
| UI feedback | 8 effects | 1 week |
| Screen effects | 6 effects | 1 week |
| Advanced Transform | 4 effects | 3 days |
| Advanced Camera | 5 effects | 3 days |
| Advanced Audio | 5 effects | 3 days |
| Advanced Visual | 6 effects | 3 days |
| Haptics | 3 effects | 2 days |
| Preset library | 50 presets | 1 week |
| Editor tools | 7 tools | 1 week |
| Documentation and examples | - | 1 week |

#### Phase 8: Commercialization (2 weeks)

| Task | Priority | Time |
|------|----------|------|
| Setup sales page (itch.io/Gumroad) | P1 | 2 days |
| Prepare Pro documentation | P1 | 2 days |
| Build Discord community | P1 | 2 days |
| Record demo videos | P1 | 2 days |
| Release Pro version | P1 | 2 days |

---

## 9. Business Model

### 9.1 Pricing Strategy

| Version | Price | Content |
|---------|-------|---------|
| **Free** | $0 | 23 effects + 10 presets + basic documentation |
| **Pro - Personal** | $29 | 72 effects + 60 presets + editor tools + 1 year updates |
| **Pro - Studio** | $79 | Pro personal + commercial license + permanent updates |

### 9.2 Sales Channels

| Channel | Purpose | Commission |
|---------|---------|------------|
| **Asset Library** | Free version | - |
| **itch.io** | Pro version sales | 10% |
| **Gumroad** | Pro version sales | 10% |
| **GitHub Sponsors** | Subscription model | - |
| **Official Website** | Self-built store (long term) | - |

### 9.3 Promotion Strategy

1. **Godot Official Forum** — Release free version, share tutorials
2. **Reddit** — r/godot community promotion
3. **YouTube** — Create tutorial videos
4. **Twitter/X** — Share GIF demos
5. **Discord** — Build community, provide support
6. **Game Jam** — Sponsor or participate

---

## 10. Competitive Analysis

### 10.1 Godot Ecosystem Competitors

| Competitor | Type | Features | Pros/Cons |
|------------|------|----------|-----------|
| **GameFeel & Juice** | Asset Library plugin | Screen shake, tween, flash, squash & stretch, freeze frame, particles | ✅ Feature-rich ❌ May not be updated |
| **Screen Shake (Arnklit)** | Asset Library plugin | Dedicated screen shake | ✅ Focused ❌ Limited features |
| **Polish & Juice** | GitHub library | GDScript function set | ✅ Lightweight ❌ Not a complete plugin |
| **Godot Built-in Tween** | Engine built-in | Tween animation system | ✅ Official support ❌ Limited features |

### 10.2 Differentiation Advantages

| Aspect | Existing Competitors | Game Feel Flow |
|--------|---------------------|----------------|
| **Architecture** | Script functions/simple plugins | Complete feedback stack system |
| **Configuration** | Code-based | Inspector + resources + code |
| **Reusability** | Poor, code copying | .tres resources, reusable |
| **Parameter Tuning** | Modify code and run | Parameter curves + runtime hot update |
| **Debugging** | None | Debug panel + visual markers + logging |
| **Overlap Strategies** | None | 5 strategies + priority |
| **Preset Library** | Few or none | Free 10, Pro 60 presets |
| **Editor Tools** | None or simple | Pro 7 advanced tools |

### 10.3 Market Opportunity

1. **Market Gap** — Godot lacks a professional solution like Unity Feel
2. **User Demand** — Game feel is a core game development need
3. **Clear Differentiation** — Our architecture and tools clearly outperform existing competitors
4. **Viable Business Model** — Free version gains users, Pro version generates revenue
5. **Godot Growth** — Godot user base is rapidly growing, market demand is high

---

## 11. Key Success Factors

### 11.1 Product Level

1. **API Usability** — One-line code to trigger effects
2. **Inspector Visualization** — No-code configuration
3. **Preset Quality** — Ready-to-use effects
4. **Documentation Quality** — Clear API docs + tutorials

### 11.2 Business Level

1. **Visual Demos** — Attractive GIF/videos
2. **Community Interaction** — Responsive to feedback
3. **Continuous Updates** — Regular feature additions
4. **Version Synchronization** — Free and Pro versions stay in sync

---

## 12. Risk Assessment

| Risk | Probability | Impact | Mitigation |
|------|-------------|--------|------------|
| **Existing competitors update** | Medium | Medium | Continuous iteration, maintain advantage |
| **Godot official releases similar feature** | Low | High | Do better, provide additional value |
| **New competitors appear** | Medium | Medium | First-mover advantage, build brand |
| **Users don't pay** | Medium | High | Free version good enough, Pro version strong value |

---

## 13. Summary

**Game Feel Flow** is a professional game feel enhancement system that provides:

- ✅ **Hybrid Architecture** — Node + resource + signal, flexible decoupling
- ✅ **Rich Feedback Types** — Free 23 effects, Pro 49 additional
- ✅ **Easy-to-use API** — Chaining, shortcuts, multiple parameter passing
- ✅ **Professional Tools** — Parameter curves, debug tools, overlap strategies
- ✅ **Complete Ecosystem** — Presets, examples, documentation, community

**Goal:** Become the most popular Game Feel plugin in Godot ecosystem, comparable to Unity's Feel by More Mountains.

---

*Document Version: v1.0*  
*Last Updated: 2024*  
*Maintainer: [Your Name]*
