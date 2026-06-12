class_name GFUtil

## Game Feel Flow Utility
##
## 快捷工具类，提供常用效果的快捷方法

# ===== 组合效果快捷方法 =====

static func hit(target: Node, intensity: float = 1.0) -> void:
	## 播放轻击效果
	GameFeelFlow.play_combo("hit_light", target, GFFParams.create(intensity))

static func hit_heavy(target: Node, intensity: float = 1.0) -> void:
	## 播放重击效果
	GameFeelFlow.play_combo("hit_heavy", target, GFFParams.create(intensity))

static func death(target: Node, intensity: float = 1.0) -> void:
	## 播放死亡效果
	GameFeelFlow.play_combo("death", target, GFFParams.create(intensity))

static func pickup(target: Node, intensity: float = 1.0) -> void:
	## 播放拾取效果
	GameFeelFlow.play_combo("pickup", target, GFFParams.create(intensity))

static func explosion(target: Node, intensity: float = 1.0) -> void:
	## 播放爆炸效果
	GameFeelFlow.play_combo("explosion", target, GFFParams.create(intensity))

# ===== 单一效果快捷方法 =====

static func shake(target: Node, intensity: float = 1.0) -> void:
	## 播放震动效果
	GameFeelFlow.play("shake", target, GFFParams.create(intensity))

static func scale(target: Node, intensity: float = 1.0) -> void:
	## 播放缩放效果
	GameFeelFlow.play("scale", target, GFFParams.create(intensity))

static func flash(target: Node, color: Color = Color.WHITE) -> void:
	## 播放闪白效果
	GameFeelFlow.play("flash", target, GFFParams.create().with_color("color", color))

static func color(target: Node, color: Color = Color.RED) -> void:
	## 播放颜色效果
	GameFeelFlow.play("color", target, GFFParams.create().with_color("color", color))

static func alpha(target: Node, target_alpha: float = 0.0) -> void:
	## 播放透明度效果
	GameFeelFlow.play("alpha", target, GFFParams.create().with_float("target_alpha", target_alpha))

static func freeze(duration: float = 0.05) -> void:
	## 播放冻结帧效果
	GameFeelFlow.play("freeze_frame", null, GFFParams.create().with_float("duration", duration))

static func slow_motion(duration: float = 1.0, time_scale: float = 0.3) -> void:
	## 播放慢动作效果
	GameFeelFlow.play("time_scale", null, GFFParams.create().with_float("duration", duration).with_float("scale", time_scale))
