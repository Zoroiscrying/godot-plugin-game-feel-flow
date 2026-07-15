class_name GFUtil

## Game Feel Flow Utility
##
## Shortcut utility class providing shortcuts for common effects

# ===== Combo Shortcuts =====

static func hit(target: Node, intensity: float = 1.0) -> void:
	## Play light hit effect
	GameFeelFlow.play_combo("hit_light", target, GFFParams.create(intensity))

static func hit_heavy(target: Node, intensity: float = 1.0) -> void:
	## Play heavy hit effect
	GameFeelFlow.play_combo("hit_heavy", target, GFFParams.create(intensity))

static func death(target: Node, intensity: float = 1.0) -> void:
	## Play death effect
	GameFeelFlow.play_combo("death", target, GFFParams.create(intensity))

static func pickup(target: Node, intensity: float = 1.0) -> void:
	## Play pickup effect
	GameFeelFlow.play_combo("pickup", target, GFFParams.create(intensity))

static func explosion(target: Node, intensity: float = 1.0) -> void:
	## Play explosion effect
	GameFeelFlow.play_combo("explosion", target, GFFParams.create(intensity))

# ===== Single Effect Shortcuts =====

static func shake(target: Node, intensity: float = 1.0) -> void:
	## Play shake effect
	GameFeelFlow.play("shake", target, GFFParams.create(intensity))

static func scale(target: Node, intensity: float = 1.0) -> void:
	## Play scale effect
	GameFeelFlow.play("scale", target, GFFParams.create(intensity))

static func flash(target: Node, color: Color = Color.WHITE) -> void:
	## Play flash effect
	GameFeelFlow.play("flash", target, GFFParams.create().with_color("color", color))

static func color(target: Node, color: Color = Color.RED) -> void:
	## Play color effect
	GameFeelFlow.play("color", target, GFFParams.create().with_color("color", color))

static func alpha(target: Node, target_alpha: float = 0.0) -> void:
	## Play alpha effect
	GameFeelFlow.play("alpha", target, GFFParams.create().with_float("target_alpha", target_alpha))

static func freeze(duration: float = 0.05) -> void:
	## Play freeze frame effect
	GameFeelFlow.play_global("freeze_frame", GFFParams.create().with_float("duration", duration))

static func slow_motion(duration: float = 1.0, time_scale: float = 0.3) -> void:
	## Play slow motion effect
	GameFeelFlow.play_global("time_scale", GFFParams.create().with_float("duration", duration).with_float("scale", time_scale))
