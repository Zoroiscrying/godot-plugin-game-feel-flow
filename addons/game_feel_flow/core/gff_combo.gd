@tool
class_name GFFCombo
extends Resource

## Game Feel Flow Combo
##
## Combo effect supporting sequential, parallel, and timeline control.
## Timeline Editor directly edits Combo entries (with start_time / duration / track_idx),
## GFFPlayer holds and plays it.

# ===== Properties =====
@export var label: String = ""
@export var entries: Array[GFFComboEntry] = []
@export var default_params: GFFParams = null

# ===== Signals =====
signal started
signal finished

# ===== State =====
var _is_executing: bool = false
var _stop_requested: bool = false

# ===== Predefined Combos =====

static func hit_light() -> GFFCombo:
	## Light hit: small pixel shake + white bleach flash + subtle relative punch.
	## Shake amplitude is in local position units (pixels for Node2D).
	var combo = GFFCombo.new()
	combo.label = "hit_light"
	combo.add_entry(_create_shake(3.0, 0.08), 0.0, 0.08, 0)
	combo.add_entry(_create_flash(Color.WHITE, 0.06), 0.0, 0.06, 1)
	combo.add_entry(_create_punch_scale(Vector2(0.04, 0.04), 0.14), 0.0, 0.14, 2)
	return combo

static func hit_heavy() -> GFFCombo:
	## Heavy hit: stronger shake + bleach flash + brief freeze + punch.
	var combo = GFFCombo.new()
	combo.label = "hit_heavy"
	combo.add_entry(_create_shake(10.0, 0.14), 0.0, 0.14, 0)
	combo.add_entry(_create_flash(Color.WHITE, 0.08), 0.0, 0.08, 1)
	combo.add_entry(_create_freeze(0.06), 0.04, 0.06, 2)
	combo.add_entry(_create_punch_scale(Vector2(0.18, 0.18), 0.22), 0.06, 0.22, 2)
	return combo

static func death() -> GFFCombo:
	## Death effect
	var combo = GFFCombo.new()
	combo.label = "death"
	combo.add_entry(_create_shake(0.8, 0.2), 0.0, 0.2, 0)
	combo.add_entry(_create_flash(Color.RED, 0.08), 0.0, 0.08, 1)
	combo.add_entry(_create_freeze(0.04), 0.08, 0.04, 2)
	combo.add_entry(_create_punch_scale(Vector2(-0.2, -0.2), 0.3), 0.12, 0.3, 2)
	var alpha_effect = _create_alpha(0.0, 0.2)
	alpha_effect.restore_after_play = false
	combo.add_entry(alpha_effect, 0.3, 0.2, 1)
	return combo

static func pickup() -> GFFCombo:
	## Pickup effect
	var combo = GFFCombo.new()
	combo.label = "pickup"
	combo.add_entry(_create_punch_scale(Vector2(0.15, 0.15), 0.12), 0.0, 0.12, 0)
	combo.add_entry(_create_flash(Color.YELLOW, 0.04), 0.0, 0.04, 1)
	return combo

static func explosion() -> GFFCombo:
	## Explosion effect
	var combo = GFFCombo.new()
	combo.label = "explosion"
	combo.add_entry(_create_shake(1.0, 0.2), 0.0, 0.2, 0)
	combo.add_entry(_create_flash(Color.ORANGE, 0.08), 0.0, 0.08, 1)
	combo.add_entry(_create_freeze(0.04), 0.08, 0.04, 2)
	combo.add_entry(_create_punch_scale(Vector2(0.25, 0.25), 0.25), 0.12, 0.25, 2)
	return combo

static func hit_medium() -> GFFCombo:
	## Medium hit effect
	var combo = GFFCombo.new()
	combo.label = "hit_medium"
	combo.add_entry(_create_shake(0.45, 0.1), 0.0, 0.1, 0)
	combo.add_entry(_create_flash(Color.WHITE, 0.05), 0.0, 0.05, 1)
	combo.add_entry(_create_punch_scale(Vector2(0.15, 0.15), 0.18), 0.0, 0.18, 2)
	return combo

static func hit_critical() -> GFFCombo:
	## Critical hit effect
	var combo = GFFCombo.new()
	combo.label = "hit_critical"
	combo.add_entry(_create_shake(0.9, 0.18), 0.0, 0.18, 0)
	combo.add_entry(_create_flash(Color.YELLOW, 0.1), 0.0, 0.1, 1)
	combo.add_entry(_create_freeze(0.03), 0.05, 0.03, 2)
	combo.add_entry(_create_punch_scale(Vector2(0.3, 0.3), 0.25), 0.08, 0.25, 2)
	return combo

static func death_explosion() -> GFFCombo:
	## Explosion death effect
	var combo = GFFCombo.new()
	combo.label = "death_explosion"
	combo.add_entry(_create_shake(1.2, 0.35), 0.0, 0.35, 0)
	combo.add_entry(_create_flash(Color.ORANGE, 0.15), 0.0, 0.15, 1)
	combo.add_entry(_create_freeze(0.06), 0.1, 0.06, 2)
	combo.add_entry(_create_punch_scale(Vector2(-0.3, -0.3), 0.35), 0.15, 0.35, 2)
	var alpha_effect = _create_alpha(0.0, 0.25)
	alpha_effect.restore_after_play = false
	combo.add_entry(alpha_effect, 0.35, 0.25, 1)
	return combo

static func pickup_coin() -> GFFCombo:
	## Coin pickup: hop up + big pop scale + gold bleach flash (distinct from hit_light).
	var combo = GFFCombo.new()
	combo.label = "pickup_coin"
	combo.add_entry(_create_punch_position(Vector2(0.0, -36.0), 0.28), 0.0, 0.28, 0)
	combo.add_entry(_create_punch_scale(Vector2(0.35, 0.35), 0.22), 0.0, 0.22, 1)
	combo.add_entry(_create_flash(Color.GOLD, 0.12), 0.0, 0.12, 2)
	return combo

static func pickup_health() -> GFFCombo:
	## Heal effect
	var combo = GFFCombo.new()
	combo.label = "pickup_health"
	combo.add_entry(_create_punch_scale(Vector2(0.18, 0.18), 0.12), 0.0, 0.12, 0)
	combo.add_entry(_create_flash(Color.GREEN, 0.06), 0.0, 0.06, 1)
	return combo

static func pickup_power() -> GFFCombo:
	## Power-up effect
	var combo = GFFCombo.new()
	combo.label = "pickup_power"
	combo.add_entry(_create_shake(0.3, 0.1), 0.0, 0.1, 0)
	combo.add_entry(_create_punch_scale(Vector2(0.25, 0.25), 0.15), 0.0, 0.15, 1)
	combo.add_entry(_create_flash(Color.CYAN, 0.08), 0.0, 0.08, 2)
	return combo

static func ui_button_press() -> GFFCombo:
	## UI button press effect
	var combo = GFFCombo.new()
	combo.label = "ui_button_press"
	combo.add_entry(_create_punch_scale(Vector2(-0.12, -0.12), 0.08), 0.0, 0.08, 0)
	combo.add_entry(_create_flash(Color.WHITE, 0.03), 0.0, 0.03, 1)
	return combo

static func ui_notification() -> GFFCombo:
	## UI notification popup effect
	var combo = GFFCombo.new()
	combo.label = "ui_notification"
	combo.add_entry(_create_punch_scale(Vector2(0.1, 0.1), 0.2), 0.0, 0.2, 0)
	combo.add_entry(_create_flash(Color.YELLOW, 0.05), 0.0, 0.05, 1)
	return combo

static func explosion_small() -> GFFCombo:
	## Small explosion effect
	var combo = GFFCombo.new()
	combo.label = "explosion_small"
	combo.add_entry(_create_shake(0.5, 0.12), 0.0, 0.12, 0)
	combo.add_entry(_create_flash(Color.ORANGE, 0.05), 0.0, 0.05, 1)
	combo.add_entry(_create_punch_scale(Vector2(0.15, 0.15), 0.15), 0.0, 0.15, 2)
	return combo

static func explosion_large() -> GFFCombo:
	## Large explosion effect
	var combo = GFFCombo.new()
	combo.label = "explosion_large"
	combo.add_entry(_create_shake(1.5, 0.35), 0.0, 0.35, 0)
	combo.add_entry(_create_flash(Color.RED, 0.15), 0.0, 0.15, 1)
	combo.add_entry(_create_freeze(0.06), 0.12, 0.06, 2)
	combo.add_entry(_create_punch_scale(Vector2(0.4, 0.4), 0.35), 0.15, 0.35, 2)
	return combo

# ===== Execution =====

func execute(target: Node, params: GFFParams = null) -> void:
	## Execute combo
	## Group by track_idx; same track executes sequentially, different tracks run in parallel.
	if _is_executing:
		push_warning("GFFCombo: Already executing, ignoring duplicate execute()")
		return
	
	_is_executing = true
	_stop_requested = false
	started.emit()
	
	if not target or not is_instance_valid(target):
		_is_executing = false
		finished.emit()
		return
	
	# Merge parameters
	var final_params = params
	if final_params == null and default_params != null:
		final_params = default_params
	
	# Group and sort by track
	var tracks: Dictionary = {}
	for entry in entries:
		if not entry or not entry.enabled or not entry.effect:
			continue
		if not tracks.has(entry.track_idx):
			tracks[entry.track_idx] = []
		tracks[entry.track_idx].append(entry)
	
	for track in tracks.values():
		track.sort_custom(func(a, b): return a.start_time < b.start_time)
	
	# Start each track (in parallel)
	var tracks_to_run: int = tracks.size()
	if tracks_to_run == 0:
		_is_executing = false
		finished.emit()
		return
	
	# In GDScript, calling a function containing await without await returns a GDScriptFunctionState;
	# but the compiler forbids calling async functions without await. To avoid coroutine collection causing hangs in headless mode,
	# use call_deferred to start lambda coroutines, scheduled by the engine and updating completion flag when done.
	var done_flags: Array[bool] = []
	done_flags.resize(tracks_to_run)
	done_flags.fill(false)
	
	var track_index := 0
	for track_idx in tracks.keys():
		var idx: int = track_index
		var track_entries: Array = tracks[track_idx]
		var task := func() -> void:
			await _execute_track(target, track_entries, final_params)
			done_flags[idx] = true
		task.call_deferred()
		track_index += 1
	
	# Wait for all tracks to finish
	var all_done := false
	while not all_done:
		if _stop_requested:
			break
		all_done = true
		for flag in done_flags:
			if not flag:
				all_done = false
				break
		if not all_done:
			if not is_instance_valid(target) or target.get_tree() == null:
				break
			await target.get_tree().process_frame
	
	_is_executing = false
	finished.emit()

func _execute_track(target: Node, track_entries: Array, params: GFFParams) -> void:
	var combo_start = Time.get_ticks_msec() / 1000.0
	var last_end_time: float = 0.0
	
	for entry in track_entries:
		if _stop_requested:
			return
		if not entry or not entry.effect:
			continue
		
		var desired_start = entry.start_time
		if entry.wait_for_previous:
			desired_start = last_end_time
		
		var current_time = Time.get_ticks_msec() / 1000.0
		var elapsed = current_time - combo_start
		var wait_time = desired_start - elapsed
		
		if wait_time > 0:
			await target.get_tree().create_timer(wait_time).timeout
			if not is_instance_valid(target):
				return
		
		if _stop_requested:
			return
		
		var effect_instance: GFFEffect = entry.effect.duplicate(true)
		# Timeline entry duration should override the effect's own duration.
		if entry.duration > 0.0:
			effect_instance.duration = entry.duration
			var entry_params: GFFParams = params
			if entry_params == null:
				entry_params = GFFParams.create()
			else:
				entry_params = entry_params.duplicate()
			entry_params.duration = entry.duration
			
			# Apply intensity curve as a multiplier (sampled at midpoint for now).
			if entry.intensity_curve:
				entry_params.intensity *= entry.intensity_curve.sample(0.5)
			
			await effect_instance.apply(target, entry_params)
		else:
			await effect_instance.apply(target, params)
		if not is_instance_valid(target):
			return
		
		var entry_end = desired_start + entry.duration
		if entry_end > last_end_time:
			last_end_time = entry_end

# ===== Public Management =====

func add_entry(effect: GFFEffect, start_time: float, duration: float, track_idx: int) -> GFFComboEntry:
	## Add a timeline entry
	var entry = GFFComboEntry.new()
	entry.effect = effect
	entry.start_time = start_time
	entry.duration = duration
	entry.track_idx = track_idx
	entry.enabled = true
	entries.append(entry)
	return entry

func clear_entries() -> void:
	## Clear all entries
	entries.clear()

func remove_entry_by_effect(effect: GFFEffect) -> void:
	## Remove entry by effect reference (remove first match)
	for i in range(entries.size()):
		if entries[i].effect == effect:
			entries.remove_at(i)
			return

func is_executing() -> bool:
	return _is_executing

func stop() -> void:
	## Request stop execution
	_stop_requested = true
	for entry in entries:
		if entry.effect and entry.effect.has_method("stop"):
			entry.effect.stop()

static func _create_shake(p_amplitude: float, p_duration: float) -> GFFEffect:
	var effect := GFFEffectCommon.new()
	var t := GFFPositionTarget.new()
	var tw := GFFShakeTweener.new()
	tw.amplitude = p_amplitude
	effect.target = t
	effect.tweener = tw
	effect.duration = p_duration
	return effect

static func _create_punch_position(amount: Vector2, p_duration: float) -> GFFEffect:
	var effect := GFFEffectCommon.new()
	var t := GFFPositionTarget.new()
	t.mode = GFFPositionTarget.Mode.BY_AMOUNT
	t.target_value = Vector3(amount.x, amount.y, 0.0)
	var tw := GFFElasticTweener.new()
	tw.punch_mode = GFFElasticTweener.PunchMode.TO_ORIGIN
	effect.target = t
	effect.tweener = tw
	effect.duration = p_duration
	return effect

static func _create_flash(color: Color, p_duration: float) -> GFFEffect:
	var effect := GFFEffectCommon.new()
	var t := GFFColorTarget.new()
	var tw := GFFFlashTweener.new()
	tw.flash_color = color
	effect.target = t
	effect.tweener = tw
	effect.duration = p_duration
	return effect

static func _create_freeze(p_duration: float) -> GFFEffect:
	var effect := GFFFreezeFrame.new()
	effect.duration = p_duration
	return effect

static func _create_scale(target_scale: Vector2, p_duration: float) -> GFFEffect:
	var effect := GFFEffectCommon.new()
	var t := GFFScaleTarget.new()
	t.target_value = Vector3(target_scale.x, target_scale.y, 1.0)
	var tw := GFFLinearTweener.new()
	effect.target = t
	effect.tweener = tw
	effect.duration = p_duration
	return effect

static func _create_punch_scale(target_scale: Vector2, p_duration: float) -> GFFEffect:
	## target_scale is a relative delta (BY_AMOUNT), e.g. (0.2, 0.2) = +20% then elastic return.
	var effect := GFFEffectCommon.new()
	var t := GFFScaleTarget.new()
	t.mode = GFFScaleTarget.Mode.BY_AMOUNT
	t.target_value = Vector3(target_scale.x, target_scale.y, 0.0)
	var tw := GFFElasticTweener.new()
	tw.punch_mode = GFFElasticTweener.PunchMode.TO_ORIGIN
	effect.target = t
	effect.tweener = tw
	effect.duration = p_duration
	return effect

static func _create_alpha(target_alpha: float, p_duration: float) -> GFFEffect:
	var effect := GFFEffectCommon.new()
	var t := GFFAlphaTarget.new()
	t.target_alpha = target_alpha
	var tw := GFFLinearTweener.new()
	effect.target = t
	effect.tweener = tw
	effect.duration = p_duration
	return effect
