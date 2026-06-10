# Implement 23 Effects Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Implement 23 remaining effects for the Game Feel Flow plugin, all extending GFFFeedback.

**Architecture:** Each effect extends GFFFeedback base class, following the same pattern as GFFShake and GFFScale. Effects are organized into subdirectories by category (camera, visual, audio, time, particles, physics, animation, ui, transform).

**Tech Stack:** GDScript, Godot 4.x

---

## File Structure

```
addons/game_feel_flow/effects/
├── camera/
│   ├── gff_camera_shake.gd
│   ├── gff_camera_zoom.gd
│   └── gff_camera_flash.gd
├── visual/
│   ├── gff_flash.gd
│   ├── gff_color.gd
│   ├── gff_alpha.gd
│   └── gff_flicker.gd
├── audio/
│   ├── gff_sound.gd
│   └── gff_audio_volume.gd
├── time/
│   ├── gff_freeze_frame.gd
│   └── gff_time_scale.gd
├── particles/
│   ├── gff_particles.gd
│   └── gff_gpu_particles.gd
├── physics/
│   ├── gff_impulse.gd
│   └── gff_velocity.gd
├── animation/
│   ├── gff_tween.gd
│   └── gff_animator.gd
├── ui/
│   ├── gff_ui_shake.gd
│   ├── gff_ui_color.gd
│   ├── gff_ui_scale.gd
│   └── gff_ui_alpha.gd
└── transform/
    ├── gff_position.gd
    └── gff_rotation.gd
```

---

## Implementation Tasks

### Task 1: Camera Effects

**Files:**
- Create: `addons/game_feel_flow/effects/camera/gff_camera_shake.gd`
- Create: `addons/game_feel_flow/effects/camera/gff_camera_zoom.gd`
- Create: `addons/game_feel_flow/effects/camera/gff_camera_flash.gd`

- [ ] **Step 1: Create gff_camera_shake.gd**

```gdscript
class_name GFFCameraShake
extends GFFFeedback

## Game Feel Flow Camera Shake Effect
##
## 相机震动效果，支持Camera2D和Camera3D

# ===== Properties =====
@export_group("Camera Shake Settings")
@export var amplitude: float = 10.0
@export var frequency: float = 20.0
@export var axes: Vector3 = Vector3(1, 1, 0)
@export var attenuation_curve: Curve = null

# ===== Override Methods =====

func _execute(node: Node, params: GFFParams) -> void:
	var final_amplitude = amplitude * params.get_float("intensity", 1.0)
	var final_duration = params.get_float("duration", duration)
	var final_frequency = params.get_float("frequency", frequency)
	var final_axes = params.get_vector3("axes", axes)

	var original_pos = _get_position(node)
	var elapsed = 0.0
	var shake_interval = 1.0 / final_frequency

	while elapsed < final_duration:
		var t = elapsed / final_duration
		var decay = 1.0 - t

		if attenuation_curve:
			decay = attenuation_curve.sample(t)

		var offset = Vector3.ZERO
		offset.x = randf_range(-1, 1) * final_amplitude * decay * final_axes.x
		offset.y = randf_range(-1, 1) * final_amplitude * decay * final_axes.y
		offset.z = randf_range(-1, 1) * final_amplitude * decay * final_axes.z

		if node is Camera3D:
			node.position = original_pos + offset
		elif node is Camera2D:
			node.offset = Vector2(offset.x, offset.y)

		await node.get_tree().process_frame
		elapsed += node.get_process_delta_time()

	if node is Camera2D:
		node.offset = Vector2.ZERO
	else:
		_set_position(node, original_pos)

func _get_default_intensity() -> float:
	return 1.0

func _get_default_duration() -> float:
	return duration
```

- [ ] **Step 2: Create gff_camera_zoom.gd**

```gdscript
class_name GFFCameraZoom
extends GFFFeedback

## Game Feel Flow Camera Zoom Effect
##
## 相机缩放效果，支持Camera2D和Camera3D

# ===== Properties =====
@export_group("Camera Zoom Settings")
@export var target_zoom: Vector2 = Vector2(1.5, 1.5)
@export var zoom_mode: ZoomMode = ZoomMode.TO_ZOOM

enum ZoomMode {
	TO_ZOOM,
	ADDITIVE,
	MULTIPLICATIVE
}

# ===== Override Methods =====

func _execute(node: Node, params: GFFParams) -> void:
	var intensity = params.get_float("intensity", 1.0)
	var final_duration = params.get_float("duration", duration)

	if node is Camera2D:
		var original_zoom = node.zoom
		var target: Vector2

		match zoom_mode:
			ZoomMode.TO_ZOOM:
				target = target_zoom * intensity
			ZoomMode.ADDITIVE:
				target = original_zoom + target_zoom * intensity
			ZoomMode.MULTIPLICATIVE:
				target = original_zoom * target_zoom * intensity

		if easing_curve:
			var tween = node.create_tween()
			tween.tween_method(_apply_zoom_curve.bind(node, original_zoom, target), 0.0, 1.0, final_duration)
			await tween.finished
		else:
			var tween = node.create_tween()
			tween.tween_property(node, "zoom", target, final_duration)
			await tween.finished
	elif node is Camera3D:
		var original_fov = node.fov
		var target_fov = original_fov * (1.0 / intensity)

		if easing_curve:
			var tween = node.create_tween()
			tween.tween_method(_apply_fov_curve.bind(node, original_fov, target_fov), 0.0, 1.0, final_duration)
			await tween.finished
		else:
			var tween = node.create_tween()
			tween.tween_property(node, "fov", target_fov, final_duration)
			await tween.finished

func _apply_zoom_curve(t: float, node: Node, from: Vector2, to: Vector2) -> void:
	var value = easing_curve.sample(t)
	node.zoom = from.lerp(to, value)

func _apply_fov_curve(t: float, node: Node, from: float, to: float) -> void:
	var value = easing_curve.sample(t)
	node.fov = lerp(from, to, value)

func _get_default_intensity() -> float:
	return 1.0

func _get_default_duration() -> float:
	return duration
```

- [ ] **Step 3: Create gff_camera_flash.gd**

```gdscript
class_name GFFCameraFlash
extends GFFFeedback

## Game Feel Flow Camera Flash Effect
##
## 相机闪光效果，支持Camera2D和Camera3D

# ===== Properties =====
@export_group("Camera Flash Settings")
@export var flash_color: Color = Color.WHITE
@export var flash_count: int = 1

# ===== Override Methods =====

func _execute(node: Node, params: GFFParams) -> void:
	var intensity = params.get_float("intensity", 1.0)
	var final_duration = params.get_float("duration", duration)
	var color = params.get_color("color", flash_color)

	# Create flash overlay
	var flash_overlay = ColorRect.new()
	flash_overlay.color = color * intensity
	flash_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	flash_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE

	# Add to camera
	if node is Camera2D:
		var canvas_layer = CanvasLayer.new()
		canvas_layer.layer = 100
		node.add_child(canvas_layer)
		canvas_layer.add_child(flash_overlay)
		await _flash(flash_overlay, final_duration)
		canvas_layer.queue_free()
	elif node is Camera3D:
		# For 3D camera, create a SubViewport with flash
		var viewport = SubViewport.new()
		viewport.size = node.get_viewport().size
		viewport.transparent_bg = true
		viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS

		var camera = Camera3D.new()
		camera.current = false
		viewport.add_child(camera)

		var color_rect = ColorRect.new()
		color_rect.color = color * intensity
		color_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
		viewport.add_child(color_rect)

		var canvas_layer = CanvasLayer.new()
		canvas_layer.layer = 100
		node.get_viewport().add_child(canvas_layer)

		var texture_rect = TextureRect.new()
		texture_rect.texture = viewport.get_texture()
		texture_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
		canvas_layer.add_child(texture_rect)

		await _flash(color_rect, final_duration)
		canvas_layer.queue_free()
		viewport.queue_free()

func _flash(overlay: Control, duration: float) -> void:
	for i in range(flash_count):
		overlay.visible = true
		await overlay.get_tree().create_timer(duration / flash_count / 2).timeout
		overlay.visible = false
		await overlay.get_tree().create_timer(duration / flash_count / 2).timeout

func _get_default_intensity() -> float:
	return 1.0

func _get_default_duration() -> float:
	return duration
```

- [ ] **Step 4: Create camera directory and commit**

Run: `mkdir -p addons/game_feel_flow/effects/camera`

---

### Task 2: Visual Effects

**Files:**
- Create: `addons/game_feel_flow/effects/visual/gff_flash.gd`
- Create: `addons/game_feel_flow/effects/visual/gff_color.gd`
- Create: `addons/game_feel_flow/effects/visual/gff_alpha.gd`
- Create: `addons/game_feel_flow/effects/visual/gff_flicker.gd`

- [ ] **Step 1: Create gff_flash.gd**

```gdscript
class_name GFFFlash
extends GFFFeedback

## Game Feel Flow Flash Effect
##
## 闪光效果，改变modulate颜色，支持Node2D和Control

# ===== Properties =====
@export_group("Flash Settings")
@export var flash_color: Color = Color.WHITE
@export var flash_count: int = 1

# ===== Override Methods =====

func _execute(node: Node, params: GFFParams) -> void:
	var intensity = params.get_float("intensity", 1.0)
	var final_duration = params.get_float("duration", duration)
	var color = params.get_color("color", flash_color)

	var original_modulate = _get_modulate(node)

	for i in range(flash_count):
		_set_modulate(node, color * intensity)
		await node.get_tree().create_timer(final_duration / flash_count / 2).timeout
		_set_modulate(node, original_modulate)
		await node.get_tree().create_timer(final_duration / flash_count / 2).timeout

func _get_default_intensity() -> float:
	return 1.0

func _get_default_duration() -> float:
	return duration
```

- [ ] **Step 2: Create gff_color.gd**

```gdscript
class_name GFFColor
extends GFFFeedback

## Game Feel Flow Color Effect
##
## 颜色效果，改变modulate颜色，支持Node2D和Control

# ===== Properties =====
@export_group("Color Settings")
@export var target_color: Color = Color.WHITE
@export var color_mode: ColorMode = ColorMode.TO_COLOR

enum ColorMode {
	TO_COLOR,
	MULTIPLY,
	ADD
}

# ===== Override Methods =====

func _execute(node: Node, params: GFFParams) -> void:
	var intensity = params.get_float("intensity", 1.0)
	var final_duration = params.get_float("duration", duration)
	var color = params.get_color("color", target_color)

	var original_modulate = _get_modulate(node)
	var target: Color

	match color_mode:
		ColorMode.TO_COLOR:
			target = color * intensity
		ColorMode.MULTIPLY:
			target = original_modulate * color * intensity
		ColorMode.ADD:
			target = original_modulate + color * intensity

	if easing_curve:
		var tween = node.create_tween()
		tween.tween_method(_apply_color_curve.bind(node, original_modulate, target), 0.0, 1.0, final_duration)
		await tween.finished
	else:
		var tween = node.create_tween()
		tween.tween_property(node, "modulate", target, final_duration)
		await tween.finished

func _apply_color_curve(t: float, node: Node, from: Color, to: Color) -> void:
	var value = easing_curve.sample(t)
	_set_modulate(node, from.lerp(to, value))

func _get_default_intensity() -> float:
	return 1.0

func _get_default_duration() -> float:
	return duration
```

- [ ] **Step 3: Create gff_alpha.gd**

```gdscript
class_name GFFAlpha
extends GFFFeedback

## Game Feel Flow Alpha Effect
##
## 透明度效果，改变alpha值，支持Node2D和Control

# ===== Properties =====
@export_group("Alpha Settings")
@export var target_alpha: float = 0.0
@export var alpha_mode: AlphaMode = AlphaMode.TO_ALPHA

enum AlphaMode {
	TO_ALPHA,
	ADDITIVE,
	MULTIPLICATIVE
}

# ===== Override Methods =====

func _execute(node: Node, params: GFFParams) -> void:
	var intensity = params.get_float("intensity", 1.0)
	var final_duration = params.get_float("duration", duration)
	var alpha = params.get_float("alpha", target_alpha)

	var original_modulate = _get_modulate(node)
	var original_alpha = original_modulate.a
	var target_alpha_value: float

	match alpha_mode:
		AlphaMode.TO_ALPHA:
			target_alpha_value = alpha * intensity
		AlphaMode.ADDITIVE:
			target_alpha_value = original_alpha + alpha * intensity
		AlphaMode.MULTIPLICATIVE:
			target_alpha_value = original_alpha * alpha * intensity

	var target_color = original_modulate
	target_color.a = target_alpha_value

	if easing_curve:
		var tween = node.create_tween()
		tween.tween_method(_apply_alpha_curve.bind(node, original_modulate, target_color), 0.0, 1.0, final_duration)
		await tween.finished
	else:
		var tween = node.create_tween()
		tween.tween_property(node, "modulate", target_color, final_duration)
		await tween.finished

func _apply_alpha_curve(t: float, node: Node, from: Color, to: Color) -> void:
	var value = easing_curve.sample(t)
	_set_modulate(node, from.lerp(to, value))

func _get_default_intensity() -> float:
	return 1.0

func _get_default_duration() -> float:
	return duration
```

- [ ] **Step 4: Create gff_flicker.gd**

```gdscript
class_name GFFFlicker
extends GFFFeedback

## Game Feel Flow Flicker Effect
##
## 闪烁效果，快速改变颜色，支持Node2D和Control

# ===== Properties =====
@export_group("Flicker Settings")
@export var flicker_color: Color = Color.WHITE
@export var flicker_count: int = 5
@export var flicker_interval: float = 0.05

# ===== Override Methods =====

func _execute(node: Node, params: GFFParams) -> void:
	var intensity = params.get_float("intensity", 1.0)
	var final_duration = params.get_float("duration", duration)
	var color = params.get_color("color", flicker_color)
	var count = params.get_int("flicker_count", flicker_count)
	var interval = final_duration / count

	var original_modulate = _get_modulate(node)

	for i in range(count):
		_set_modulate(node, color * intensity)
		await node.get_tree().create_timer(interval / 2).timeout
		_set_modulate(node, original_modulate)
		await node.get_tree().create_timer(interval / 2).timeout

func _get_default_intensity() -> float:
	return 1.0

func _get_default_duration() -> float:
	return duration
```

- [ ] **Step 5: Create visual directory and commit**

Run: `mkdir -p addons/game_feel_flow/effects/visual`

---

### Task 3: Audio Effects

**Files:**
- Create: `addons/game_feel_flow/effects/audio/gff_sound.gd`
- Create: `addons/game_feel_flow/effects/audio/gff_audio_volume.gd`

- [ ] **Step 1: Create gff_sound.gd**

```gdscript
class_name GFFSound
extends GFFFeedback

## Game Feel Flow Sound Effect
##
## 音效播放效果

# ===== Properties =====
@export_group("Sound Settings")
@export var audio_stream: AudioStream
@export var volume_db: float = 0.0
@export var pitch_scale: float = 1.0
@export var pitch_random_range: float = 0.0

# ===== Override Methods =====

func _execute(node: Node, params: GFFParams) -> void:
	var intensity = params.get_float("intensity", 1.0)
	var final_duration = params.get_float("duration", duration)

	if not audio_stream:
		push_warning("GFFSound: No audio stream assigned")
		return

	# Create audio player
	var audio_player = AudioStreamPlayer.new()
	audio_player.stream = audio_stream
	audio_player.volume_db = volume_db + linear_to_db(intensity)
	audio_player.pitch_scale = pitch_scale + randf_range(-pitch_random_range, pitch_random_range)

	node.add_child(audio_player)
	audio_player.play()

	# Wait for audio to finish or duration
	var wait_time = max(audio_stream.get_length(), final_duration)
	await node.get_tree().create_timer(wait_time).timeout

	audio_player.queue_free()

func _get_default_intensity() -> float:
	return 1.0

func _get_default_duration() -> float:
	return duration
```

- [ ] **Step 2: Create gff_audio_volume.gd**

```gdscript
class_name GFFAudioVolume
extends GFFFeedback

## Game Feel Flow Audio Volume Effect
##
## 音量变化效果，支持AudioStreamPlayer

# ===== Properties =====
@export_group("Audio Volume Settings")
@export var target_volume_db: float = -6.0
@export var volume_mode: VolumeMode = VolumeMode.TO_VOLUME

enum VolumeMode {
	TO_VOLUME,
	ADDITIVE,
	MULTIPLICATIVE
}

# ===== Override Methods =====

func _execute(node: Node, params: GFFParams) -> void:
	var intensity = params.get_float("intensity", 1.0)
	var final_duration = params.get_float("duration", duration)
	var volume = params.get_float("volume", target_volume_db)

	if not node is AudioStreamPlayer and not node is AudioStreamPlayer2D and not node is AudioStreamPlayer3D:
		push_warning("GFFAudioVolume: Target is not an AudioStreamPlayer")
		return

	var original_volume = node.volume_db
	var target_volume: float

	match volume_mode:
		VolumeMode.TO_VOLUME:
			target_volume = volume * intensity
		VolumeMode.ADDITIVE:
			target_volume = original_volume + volume * intensity
		VolumeMode.MULTIPLICATIVE:
			target_volume = original_volume * volume * intensity

	if easing_curve:
		var tween = node.create_tween()
		tween.tween_method(_apply_volume_curve.bind(node, original_volume, target_volume), 0.0, 1.0, final_duration)
		await tween.finished
	else:
		var tween = node.create_tween()
		tween.tween_property(node, "volume_db", target_volume, final_duration)
		await tween.finished

func _apply_volume_curve(t: float, node: Node, from: float, to: float) -> void:
	var value = easing_curve.sample(t)
	node.volume_db = lerp(from, to, value)

func _get_default_intensity() -> float:
	return 1.0

func _get_default_duration() -> float:
	return duration
```

- [ ] **Step 3: Create audio directory and commit**

Run: `mkdir -p addons/game_feel_flow/effects/audio`

---

### Task 4: Time Effects

**Files:**
- Create: `addons/game_feel_flow/effects/time/gff_freeze_frame.gd`
- Create: `addons/game_feel_flow/effects/time/gff_time_scale.gd`

- [ ] **Step 1: Create gff_freeze_frame.gd**

```gdscript
class_name GFFFreezeFrame
extends GFFFeedback

## Game Feel Flow Freeze Frame Effect
##
## 冻结帧效果，暂停场景树

# ===== Properties =====
@export_group("Freeze Frame Settings")
@export var freeze_duration: float = 0.1

# ===== Override Methods =====

func _execute(node: Node, params: GFFParams) -> void:
	var final_duration = params.get_float("duration", freeze_duration)

	# Store original time scale
	var original_time_scale = Engine.time_scale

	# Freeze
	Engine.time_scale = 0.0
	await node.get_tree().create_timer(final_duration, true, false, true).timeout

	# Restore
	Engine.time_scale = original_time_scale

func _get_default_intensity() -> float:
	return 1.0

func _get_default_duration() -> float:
	return freeze_duration
```

- [ ] **Step 2: Create gff_time_scale.gd**

```gdscript
class_name GFFTimeScale
extends GFFFeedback

## Game Feel Flow Time Scale Effect
##
## 时间缩放效果，改变Engine.time_scale

# ===== Properties =====
@export_group("Time Scale Settings")
@export var target_time_scale: float = 0.5
@export var time_scale_mode: TimeScaleMode = TimeScaleMode.TO_SCALE

enum TimeScaleMode {
	TO_SCALE,
	ADDITIVE,
	MULTIPLICATIVE
}

# ===== Override Methods =====

func _execute(node: Node, params: GFFParams) -> void:
	var intensity = params.get_float("intensity", 1.0)
	var final_duration = params.get_float("duration", duration)
	var time_scale = params.get_float("time_scale", target_time_scale)

	var original_time_scale = Engine.time_scale
	var target: float

	match time_scale_mode:
		TimeScaleMode.TO_SCALE:
			target = time_scale * intensity
		TimeScaleMode.ADDITIVE:
			target = original_time_scale + time_scale * intensity
		TimeScaleMode.MULTIPLICATIVE:
			target = original_time_scale * time_scale * intensity

	if easing_curve:
		var tween = node.create_tween()
		tween.tween_method(_apply_time_scale_curve.bind(original_time_scale, target), 0.0, 1.0, final_duration)
		await tween.finished
	else:
		var tween = node.create_tween()
		tween.tween_method(_apply_time_scale.bind(target), 0.0, 1.0, final_duration)
		await tween.finished

	Engine.time_scale = original_time_scale

func _apply_time_scale_curve(t: float, from: float, to: float) -> void:
	var value = easing_curve.sample(t)
	Engine.time_scale = lerp(from, to, value)

func _apply_time_scale(t: float, target: float) -> void:
	Engine.time_scale = target

func _get_default_intensity() -> float:
	return 1.0

func _get_default_duration() -> float:
	return duration
```

- [ ] **Step 3: Create time directory and commit**

Run: `mkdir -p addons/game_feel_flow/effects/time`

---

### Task 5: Particles Effects

**Files:**
- Create: `addons/game_feel_flow/effects/particles/gff_particles.gd`
- Create: `addons/game_feel_flow/effects/particles/gff_gpu_particles.gd`

- [ ] **Step 1: Create gff_particles.gd**

```gdscript
class_name GFFParticles
extends GFFFeedback

## Game Feel Flow Particles Effect
##
## 粒子效果，支持GPUParticles2D和GPUParticles3D

# ===== Properties =====
@export_group("Particles Settings")
@export var particle_scene: PackedScene
@export var emit_count: int = 10
@export var offset: Vector3 = Vector3.ZERO

# ===== Override Methods =====

func _execute(node: Node, params: GFFParams) -> void:
	var intensity = params.get_float("intensity", 1.0)
	var final_duration = params.get_float("duration", duration)
	var count = int(emit_count * intensity)

	if not particle_scene:
		push_warning("GFFParticles: No particle scene assigned")
		return

	# Instance particles
	var particles = particle_scene.instantiate()
	node.add_child(particles)

	# Set position offset
	if particles is Node3D:
		particles.position = offset
	elif particles is Node2D:
		particles.position = Vector2(offset.x, offset.y)

	# Emit
	if particles is GPUParticles2D:
		particles.amount = count
		particles.emitting = true
	elif particles is GPUParticles3D:
		particles.amount = count
		particles.emitting = true
	elif particles is CPUParticles2D:
		particles.amount = count
		particles.emitting = true
	elif particles is CPUParticles3D:
		particles.amount = count
		particles.emitting = true

	# Wait and cleanup
	await node.get_tree().create_timer(final_duration).timeout
	particles.queue_free()

func _get_default_intensity() -> float:
	return 1.0

func _get_default_duration() -> float:
	return duration
```

- [ ] **Step 2: Create gff_gpu_particles.gd**

```gdscript
class_name GFFGPUParticles
extends GFFFeedback

## Game Feel Flow GPU Particles Effect
##
## GPU粒子效果，支持GPUParticles2D和GPUParticles3D

# ===== Properties =====
@export_group("GPU Particles Settings")
@export var particle_material: ParticleProcessMaterial
@export var amount: int = 16
@export var lifetime: float = 1.0
@export var emitting: bool = true
@export var offset: Vector3 = Vector3.ZERO

# ===== Override Methods =====

func _execute(node: Node, params: GFFParams) -> void:
	var intensity = params.get_float("intensity", 1.0)
	var final_duration = params.get_float("duration", lifetime)
	var final_amount = int(amount * intensity)

	# Create particles
	var particles: Node

	if node is Node2D:
		particles = GPUParticles2D.new()
		particles.amount = final_amount
		particles.lifetime = final_duration
		particles.emitting = emitting
		if particle_material:
			particles.process_material = particle_material
		particles.position = Vector2(offset.x, offset.y)
	elif node is Node3D:
		particles = GPUParticles3D.new()
		particles.amount = final_amount
		particles.lifetime = final_duration
		particles.emitting = emitting
		if particle_material:
			particles.process_material = particle_material
		particles.position = offset
	else:
		push_warning("GFFGPUParticles: Unsupported node type")
		return

	node.add_child(particles)

	# Wait for particles to finish
	await node.get_tree().create_timer(final_duration + 0.1).timeout
	particles.queue_free()

func _get_default_intensity() -> float:
	return 1.0

func _get_default_duration() -> float:
	return lifetime
```

- [ ] **Step 3: Create particles directory and commit**

Run: `mkdir -p addons/game_feel_flow/effects/particles`

---

### Task 6: Physics Effects

**Files:**
- Create: `addons/game_feel_flow/effects/physics/gff_impulse.gd`
- Create: `addons/game_feel_flow/effects/physics/gff_velocity.gd`

- [ ] **Step 1: Create gff_impulse.gd**

```gdscript
class_name GFFImpulse
extends GFFFeedback

## Game Feel Flow Impulse Effect
##
## 冲量效果，支持RigidBody2D和RigidBody3D

# ===== Properties =====
@export_group("Impulse Settings")
@export var impulse_force: Vector3 = Vector3(0, -10, 0)
@export var impulse_point: Vector3 = Vector3.ZERO

# ===== Override Methods =====

func _execute(node: Node, params: GFFParams) -> void:
	var intensity = params.get_float("intensity", 1.0)
	var final_duration = params.get_float("duration", duration)
	var force = params.get_vector3("force", impulse_force) * intensity

	if node is RigidBody3D:
		node.apply_impulse(force, impulse_point)
	elif node is RigidBody2D:
		node.apply_impulse(Vector2(force.x, force.y), Vector2(impulse_point.x, impulse_point.y))
	else:
		push_warning("GFFImpulse: Target is not a RigidBody")

func _get_default_intensity() -> float:
	return 1.0

func _get_default_duration() -> float:
	return duration
```

- [ ] **Step 2: Create gff_velocity.gd**

```gdscript
class_name GFFVelocity
extends GFFFeedback

## Game Feel Flow Velocity Effect
##
## 速度效果，支持RigidBody2D和RigidBody3D

# ===== Properties =====
@export_group("Velocity Settings")
@export var target_velocity: Vector3 = Vector3(0, -10, 0)
@export var velocity_mode: VelocityMode = VelocityMode.TO_VELOCITY

enum VelocityMode {
	TO_VELOCITY,
	ADDITIVE,
	MULTIPLICATIVE
}

# ===== Override Methods =====

func _execute(node: Node, params: GFFParams) -> void:
	var intensity = params.get_float("intensity", 1.0)
	var final_duration = params.get_float("duration", duration)
	var velocity = params.get_vector3("velocity", target_velocity) * intensity

	if node is RigidBody3D:
		var original_velocity = node.linear_velocity
		var target: Vector3

		match velocity_mode:
			VelocityMode.TO_VELOCITY:
				target = velocity
			VelocityMode.ADDITIVE:
				target = original_velocity + velocity
			VelocityMode.MULTIPLICATIVE:
				target = original_velocity * velocity

		if easing_curve:
			var tween = node.create_tween()
			tween.tween_method(_apply_velocity_curve.bind(node, original_velocity, target), 0.0, 1.0, final_duration)
			await tween.finished
		else:
			var tween = node.create_tween()
			tween.tween_property(node, "linear_velocity", target, final_duration)
			await tween.finished
	elif node is RigidBody2D:
		var original_velocity = node.linear_velocity
		var velocity_2d = Vector2(velocity.x, velocity.y)
		var target: Vector2

		match velocity_mode:
			VelocityMode.TO_VELOCITY:
				target = velocity_2d
			VelocityMode.ADDITIVE:
				target = original_velocity + velocity_2d
			VelocityMode.MULTIPLICATIVE:
				target = original_velocity * velocity_2d

		if easing_curve:
			var tween = node.create_tween()
			tween.tween_method(_apply_velocity_2d_curve.bind(node, original_velocity, target), 0.0, 1.0, final_duration)
			await tween.finished
		else:
			var tween = node.create_tween()
			tween.tween_property(node, "linear_velocity", target, final_duration)
			await tween.finished
	else:
		push_warning("GFFVelocity: Target is not a RigidBody")

func _apply_velocity_curve(t: float, node: Node, from: Vector3, to: Vector3) -> void:
	var value = easing_curve.sample(t)
	node.linear_velocity = from.lerp(to, value)

func _apply_velocity_2d_curve(t: float, node: Node, from: Vector2, to: Vector2) -> void:
	var value = easing_curve.sample(t)
	node.linear_velocity = from.lerp(to, value)

func _get_default_intensity() -> float:
	return 1.0

func _get_default_duration() -> float:
	return duration
```

- [ ] **Step 3: Create physics directory and commit**

Run: `mkdir -p addons/game_feel_flow/effects/physics`

---

### Task 7: Animation Effects

**Files:**
- Create: `addons/game_feel_flow/effects/animation/gff_tween.gd`
- Create: `addons/game_feel_flow/effects/animation/gff_animator.gd`

- [ ] **Step 1: Create gff_tween.gd**

```gdscript
class_name GFFTween
extends GFFFeedback

## Game Feel Flow Tween Effect
##
## 缓动效果，支持自定义属性动画

# ===== Properties =====
@export_group("Tween Settings")
@export var property: String = "position"
@export var target_value: Variant
@export var tween_type: TweenType = TweenType.TO_VALUE

enum TweenType {
	TO_VALUE,
	FROM_VALUE,
	OSCILLATE
}

# ===== Override Methods =====

func _execute(node: Node, params: GFFParams) -> void:
	var intensity = params.get_float("intensity", 1.0)
	var final_duration = params.get_float("duration", duration)
	var value = params.get_variant("value", target_value)

	if property.is_empty():
		push_warning("GFFTween: No property specified")
		return

	var original_value = node.get(property)

	match tween_type:
		TweenType.TO_VALUE:
			if easing_curve:
				var tween = node.create_tween()
				tween.tween_method(_apply_curve.bind(node, original_value, value), 0.0, 1.0, final_duration)
				await tween.finished
			else:
				var tween = node.create_tween()
				tween.tween_property(node, property, value, final_duration)
				await tween.finished
		TweenType.FROM_VALUE:
			node.set(property, value)
			if easing_curve:
				var tween = node.create_tween()
				tween.tween_method(_apply_curve.bind(node, value, original_value), 0.0, 1.0, final_duration)
				await tween.finished
			else:
				var tween = node.create_tween()
				tween.tween_property(node, property, original_value, final_duration)
				await tween.finished
		TweenType.OSCILLATE:
			if easing_curve:
				var tween = node.create_tween()
				tween.tween_method(_apply_curve.bind(node, original_value, value), 0.0, 1.0, final_duration / 2)
				tween.tween_method(_apply_curve.bind(node, value, original_value), 0.0, 1.0, final_duration / 2)
				await tween.finished
			else:
				var tween = node.create_tween()
				tween.tween_property(node, property, value, final_duration / 2)
				tween.tween_property(node, property, original_value, final_duration / 2)
				await tween.finished

func _apply_curve(t: float, node: Node, from, to) -> void:
	var value = easing_curve.sample(t)
	if from is float and to is float:
		node.set(property, lerp(from, to, value))
	elif from is Vector2 and to is Vector2:
		node.set(property, from.lerp(to, value))
	elif from is Vector3 and to is Vector3:
		node.set(property, from.lerp(to, value))
	elif from is Color and to is Color:
		node.set(property, from.lerp(to, value))

func _get_default_intensity() -> float:
	return 1.0

func _get_default_duration() -> float:
	return duration
```

- [ ] **Step 2: Create gff_animator.gd**

```gdscript
class_name GFFAnimator
extends GFFFeedback

## Game Feel Flow Animator Effect
##
## 动画播放效果，支持AnimationPlayer

# ===== Properties =====
@export_group("Animator Settings")
@export var animation_name: String = ""
@export var playback_speed: float = 1.0
@export var from_end: bool = false

# ===== Override Methods =====

func _execute(node: Node, params: GFFParams) -> void:
	var intensity = params.get_float("intensity", 1.0)
	var final_duration = params.get_float("duration", duration)
	var anim_name = params.get_string("animation", animation_name)

	# Find AnimationPlayer
	var anim_player: AnimationPlayer = null
	if node is AnimationPlayer:
		anim_player = node
	else:
		anim_player = node.get_node_or_null("AnimationPlayer")
		if not anim_player:
			for child in node.get_children():
				if child is AnimationPlayer:
					anim_player = child
					break

	if not anim_player:
		push_warning("GFFAnimator: No AnimationPlayer found")
		return

	if anim_name.is_empty():
		push_warning("GFFAnimator: No animation name specified")
		return

	if not anim_player.has_animation(anim_name):
		push_warning("GFFAnimator: Animation '", anim_name, "' not found")
		return

	# Play animation
	anim_player.play(anim_name, -1, playback_speed * intensity, from_end)

	# Wait for animation
	var animation = anim_player.get_animation(anim_name)
	if animation:
		var wait_time = animation.length / (playback_speed * intensity)
		await node.get_tree().create_timer(wait_time).timeout

func _get_default_intensity() -> float:
	return 1.0

func _get_default_duration() -> float:
	return duration
```

- [ ] **Step 3: Create animation directory and commit**

Run: `mkdir -p addons/game_feel_flow/effects/animation`

---

### Task 8: UI Effects

**Files:**
- Create: `addons/game_feel_flow/effects/ui/gff_ui_shake.gd`
- Create: `addons/game_feel_flow/effects/ui/gff_ui_color.gd`
- Create: `addons/game_feel_flow/effects/ui/gff_ui_scale.gd`
- Create: `addons/game_feel_flow/effects/ui/gff_ui_alpha.gd`

- [ ] **Step 1: Create gff_ui_shake.gd**

```gdscript
class_name GFFUIShake
extends GFFFeedback

## Game Feel Flow UI Shake Effect
##
## UI震动效果，专门针对Control节点优化

# ===== Properties =====
@export_group("UI Shake Settings")
@export var amplitude: float = 5.0
@export var frequency: float = 20.0
@export var axes: Vector2 = Vector2(1, 1)
@export var attenuation_curve: Curve = null

# ===== Override Methods =====

func _execute(node: Node, params: GFFParams) -> void:
	var final_amplitude = amplitude * params.get_float("intensity", 1.0)
	var final_duration = params.get_float("duration", duration)
	var final_frequency = params.get_float("frequency", frequency)
	var final_axes = params.get_vector2("axes", axes)

	if not node is Control:
		push_warning("GFFUIShake: Target is not a Control")
		return

	var original_pos = node.position
	var elapsed = 0.0
	var shake_interval = 1.0 / final_frequency

	while elapsed < final_duration:
		var t = elapsed / final_duration
		var decay = 1.0 - t

		if attenuation_curve:
			decay = attenuation_curve.sample(t)

		var offset = Vector2.ZERO
		offset.x = randf_range(-1, 1) * final_amplitude * decay * final_axes.x
		offset.y = randf_range(-1, 1) * final_amplitude * decay * final_axes.y

		node.position = original_pos + offset

		await node.get_tree().process_frame
		elapsed += node.get_process_delta_time()

	node.position = original_pos

func _get_default_intensity() -> float:
	return 1.0

func _get_default_duration() -> float:
	return duration
```

- [ ] **Step 2: Create gff_ui_color.gd**

```gdscript
class_name GFFUIColor
extends GFFFeedback

## Game Feel Flow UI Color Effect
##
## UI颜色效果，专门针对Control节点优化

# ===== Properties =====
@export_group("UI Color Settings")
@export var target_color: Color = Color.WHITE
@export var color_mode: ColorMode = ColorMode.TO_COLOR

enum ColorMode {
	TO_COLOR,
	MULTIPLY,
	ADD
}

# ===== Override Methods =====

func _execute(node: Node, params: GFFParams) -> void:
	var intensity = params.get_float("intensity", 1.0)
	var final_duration = params.get_float("duration", duration)
	var color = params.get_color("color", target_color)

	if not node is Control:
		push_warning("GFFUIColor: Target is not a Control")
		return

	var original_modulate = node.modulate
	var target: Color

	match color_mode:
		ColorMode.TO_COLOR:
			target = color * intensity
		ColorMode.MULTIPLY:
			target = original_modulate * color * intensity
		ColorMode.ADD:
			target = original_modulate + color * intensity

	if easing_curve:
		var tween = node.create_tween()
		tween.tween_method(_apply_color_curve.bind(node, original_modulate, target), 0.0, 1.0, final_duration)
		await tween.finished
	else:
		var tween = node.create_tween()
		tween.tween_property(node, "modulate", target, final_duration)
		await tween.finished

func _apply_color_curve(t: float, node: Node, from: Color, to: Color) -> void:
	var value = easing_curve.sample(t)
	node.modulate = from.lerp(to, value)

func _get_default_intensity() -> float:
	return 1.0

func _get_default_duration() -> float:
	return duration
```

- [ ] **Step 3: Create gff_ui_scale.gd**

```gdscript
class_name GFFUIScale
extends GFFFeedback

## Game Feel Flow UI Scale Effect
##
## UI缩放效果，专门针对Control节点优化

# ===== Properties =====
@export_group("UI Scale Settings")
@export var target_scale: Vector2 = Vector2(1.2, 1.2)
@export var scale_mode: ScaleMode = ScaleMode.TO_SCALE
@export var pivot_offset: Vector2 = Vector2.ZERO

enum ScaleMode {
	TO_SCALE,
	ADDITIVE,
	MULTIPLICATIVE
}

# ===== Override Methods =====

func _execute(node: Node, params: GFFParams) -> void:
	var intensity = params.get_float("intensity", 1.0)
	var final_duration = params.get_float("duration", duration)
	var scale = params.get_vector2("scale", target_scale)

	if not node is Control:
		push_warning("GFFUIScale: Target is not a Control")
		return

	var original_scale = node.scale
	var target: Vector2

	match scale_mode:
		ScaleMode.TO_SCALE:
			target = scale * intensity
		ScaleMode.ADDITIVE:
			target = original_scale + scale * intensity
		ScaleMode.MULTIPLICATIVE:
			target = original_scale * scale * intensity

	# Set pivot if specified
	if pivot_offset != Vector2.ZERO:
		node.pivot_offset = pivot_offset

	if easing_curve:
		var tween = node.create_tween()
		tween.tween_method(_apply_scale_curve.bind(node, original_scale, target), 0.0, 1.0, final_duration)
		await tween.finished
	else:
		var tween = node.create_tween()
		tween.tween_property(node, "scale", target, final_duration)
		await tween.finished

func _apply_scale_curve(t: float, node: Node, from: Vector2, to: Vector2) -> void:
	var value = easing_curve.sample(t)
	node.scale = from.lerp(to, value)

func _get_default_intensity() -> float:
	return 1.0

func _get_default_duration() -> float:
	return duration
```

- [ ] **Step 4: Create gff_ui_alpha.gd**

```gdscript
class_name GFFUIAlpha
extends GFFFeedback

## Game Feel Flow UI Alpha Effect
##
## UI透明度效果，专门针对Control节点优化

# ===== Properties =====
@export_group("UI Alpha Settings")
@export var target_alpha: float = 0.0
@export var alpha_mode: AlphaMode = AlphaMode.TO_ALPHA

enum AlphaMode {
	TO_ALPHA,
	ADDITIVE,
	MULTIPLICATIVE
}

# ===== Override Methods =====

func _execute(node: Node, params: GFFParams) -> void:
	var intensity = params.get_float("intensity", 1.0)
	var final_duration = params.get_float("duration", duration)
	var alpha = params.get_float("alpha", target_alpha)

	if not node is Control:
		push_warning("GFFUIAlpha: Target is not a Control")
		return

	var original_modulate = node.modulate
	var original_alpha = original_modulate.a
	var target_alpha_value: float

	match alpha_mode:
		AlphaMode.TO_ALPHA:
			target_alpha_value = alpha * intensity
		AlphaMode.ADDITIVE:
			target_alpha_value = original_alpha + alpha * intensity
		AlphaMode.MULTIPLICATIVE:
			target_alpha_value = original_alpha * alpha * intensity

	var target_color = original_modulate
	target_color.a = target_alpha_value

	if easing_curve:
		var tween = node.create_tween()
		tween.tween_method(_apply_alpha_curve.bind(node, original_modulate, target_color), 0.0, 1.0, final_duration)
		await tween.finished
	else:
		var tween = node.create_tween()
		tween.tween_property(node, "modulate", target_color, final_duration)
		await tween.finished

func _apply_alpha_curve(t: float, node: Node, from: Color, to: Color) -> void:
	var value = easing_curve.sample(t)
	node.modulate = from.lerp(to, value)

func _get_default_intensity() -> float:
	return 1.0

func _get_default_duration() -> float:
	return duration
```

- [ ] **Step 5: Create ui directory and commit**

Run: `mkdir -p addons/game_feel_flow/effects/ui`

---

### Task 9: Transform Effects

**Files:**
- Create: `addons/game_feel_flow/effects/transform/gff_position.gd`
- Create: `addons/game_feel_flow/effects/transform/gff_rotation.gd`

- [ ] **Step 1: Create gff_position.gd**

```gdscript
class_name GFFPosition
extends GFFFeedback

## Game Feel Flow Position Effect
##
## 位置效果，支持Node2D、Node3D和Control

# ===== Properties =====
@export_group("Position Settings")
@export var target_position: Vector3 = Vector3.ZERO
@export var position_mode: PositionMode = PositionMode.TO_POSITION
@export var relative_to_current: bool = true

enum PositionMode {
	TO_POSITION,
	ADDITIVE,
	MULTIPLICATIVE
}

# ===== Override Methods =====

func _execute(node: Node, params: GFFParams) -> void:
	var intensity = params.get_float("intensity", 1.0)
	var final_duration = params.get_float("duration", duration)
	var position = params.get_vector3("position", target_position)

	var original_position = _get_position(node)
	var target

	match position_mode:
		PositionMode.TO_POSITION:
			if relative_to_current:
				target = original_position + position * intensity
			else:
				target = position * intensity
		PositionMode.ADDITIVE:
			target = original_position + position * intensity
		PositionMode.MULTIPLICATIVE:
			if node is Node3D:
				target = Vector3(
					original_position.x * position.x * intensity,
					original_position.y * position.y * intensity,
					original_position.z * position.z * intensity
				)
			else:
				target = Vector2(
					original_position.x * position.x * intensity,
					original_position.y * position.y * intensity
				)

	if easing_curve:
		var tween = node.create_tween()
		tween.tween_method(_apply_position_curve.bind(node, original_position, target), 0.0, 1.0, final_duration)
		await tween.finished
	else:
		var tween = node.create_tween()
		tween.tween_property(node, "position", target, final_duration)
		await tween.finished

func _apply_position_curve(t: float, node: Node, from, to) -> void:
	var value = easing_curve.sample(t)
	if node is Node3D:
		_set_position(node, from.lerp(to, value))
	else:
		_set_position(node, Vector2(from.x, from.y).lerp(Vector2(to.x, to.y), value))

func _get_default_intensity() -> float:
	return 1.0

func _get_default_duration() -> float:
	return duration
```

- [ ] **Step 2: Create gff_rotation.gd**

```gdscript
class_name GFFRotation
extends GFFFeedback

## Game Feel Flow Rotation Effect
##
## 旋转效果，支持Node2D、Node3D和Control

# ===== Properties =====
@export_group("Rotation Settings")
@export var target_rotation: float = 0.0
@export var rotation_mode: RotationMode = RotationMode.TO_ROTATION
@export var rotate_3d: Vector3 = Vector3.ZERO

enum RotationMode {
	TO_ROTATION,
	ADDITIVE,
	MULTIPLICATIVE
}

# ===== Override Methods =====

func _execute(node: Node, params: GFFParams) -> void:
	var intensity = params.get_float("intensity", 1.0)
	var final_duration = params.get_float("duration", duration)
	var rotation = params.get_float("rotation", target_rotation)

	var original_rotation = _get_rotation(node)
	var target: float

	match rotation_mode:
		RotationMode.TO_ROTATION:
			target = rotation * intensity
		RotationMode.ADDITIVE:
			target = original_rotation + rotation * intensity
		RotationMode.MULTIPLICATIVE:
			target = original_rotation * rotation * intensity

	if node is Node3D:
		var original_rotation_3d = node.rotation
		var target_rotation_3d = original_rotation_3d + rotate_3d * intensity

		if easing_curve:
			var tween = node.create_tween()
			tween.tween_method(_apply_rotation_3d_curve.bind(node, original_rotation_3d, target_rotation_3d), 0.0, 1.0, final_duration)
			await tween.finished
		else:
			var tween = node.create_tween()
			tween.tween_property(node, "rotation", target_rotation_3d, final_duration)
			await tween.finished
	else:
		if easing_curve:
			var tween = node.create_tween()
			tween.tween_method(_apply_rotation_curve.bind(node, original_rotation, target), 0.0, 1.0, final_duration)
			await tween.finished
		else:
			var tween = node.create_tween()
			tween.tween_property(node, "rotation", target, final_duration)
			await tween.finished

func _apply_rotation_curve(t: float, node: Node, from: float, to: float) -> void:
	var value = easing_curve.sample(t)
	_set_rotation(node, lerp(from, to, value))

func _apply_rotation_3d_curve(t: float, node: Node, from: Vector3, to: Vector3) -> void:
	var value = easing_curve.sample(t)
	node.rotation = from.lerp(to, value)

func _get_default_intensity() -> float:
	return 1.0

func _get_default_duration() -> float:
	return duration
```

- [ ] **Step 3: Commit transform effects**

---

## Verification

After implementing all effects:

1. Run: `rtk tsc` to check for type errors
2. Verify all files are in correct directories
3. Check that all effects extend GFFFeedback
4. Verify class_name conventions match file names

---

## Summary

**Files created:** 23 new effect files
**Directories created:** 8 new subdirectories under `addons/game_feel_flow/effects/`

All effects follow the GFFFeedback pattern with:
- `_execute()` method implementation
- `_get_default_intensity()` and `_get_default_duration()` overrides
- Proper parameter handling via GFFParams
- Support for easing curves
- Type-specific node handling (Node2D, Node3D, Control, etc.)
