# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

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
