class_name GFFCurvePresets

## Game Feel Flow Curve Presets
##
## Curve preset library, provides common easing curves

# ===== Linear =====

static func linear() -> Curve:
	## Linear curve
	var curve = Curve.new()
	curve.add_point(Vector2(0, 0))
	curve.add_point(Vector2(1, 1))
	return curve

# ===== Ease In =====

static func ease_in() -> Curve:
	## Ease In curve (slow start)
	var curve = Curve.new()
	curve.add_point(Vector2(0, 0), 0, 0.5)
	curve.add_point(Vector2(1, 1), 0.5, 0)
	return curve

static func ease_in_quad() -> Curve:
	## Ease In Quad curve
	var curve = Curve.new()
	curve.add_point(Vector2(0, 0), 0, 0.3)
	curve.add_point(Vector2(1, 1), 0.7, 0)
	return curve

static func ease_in_cubic() -> Curve:
	## Ease In Cubic curve
	var curve = Curve.new()
	curve.add_point(Vector2(0, 0), 0, 0.2)
	curve.add_point(Vector2(1, 1), 0.8, 0)
	return curve

# ===== Ease Out =====

static func ease_out() -> Curve:
	## Ease Out curve (fast end)
	var curve = Curve.new()
	curve.add_point(Vector2(0, 0), 0, 0.5)
	curve.add_point(Vector2(1, 1), 0.5, 0)
	return curve

static func ease_out_quad() -> Curve:
	## Ease Out Quad curve
	var curve = Curve.new()
	curve.add_point(Vector2(0, 0), 0, 0.3)
	curve.add_point(Vector2(1, 1), 0.7, 0)
	return curve

static func ease_out_cubic() -> Curve:
	## Ease Out Cubic curve
	var curve = Curve.new()
	curve.add_point(Vector2(0, 0), 0, 0.2)
	curve.add_point(Vector2(1, 1), 0.8, 0)
	return curve

# ===== Ease In Out =====

static func ease_in_out() -> Curve:
	## Ease In Out curve
	var curve = Curve.new()
	curve.add_point(Vector2(0, 0), 0, 0.4)
	curve.add_point(Vector2(0.5, 0.5), 0.3, 0.3)
	curve.add_point(Vector2(1, 1), 0.6, 0)
	return curve

static func ease_in_out_quad() -> Curve:
	## Ease In Out Quad curve
	var curve = Curve.new()
	curve.add_point(Vector2(0, 0), 0, 0.3)
	curve.add_point(Vector2(0.5, 0.5), 0.2, 0.2)
	curve.add_point(Vector2(1, 1), 0.7, 0)
	return curve

# ===== Special Effects =====

static func bounce() -> Curve:
	## Bounce curve
	var curve = Curve.new()
	curve.add_point(Vector2(0, 0))
	curve.add_point(Vector2(0.1, 0.8))
	curve.add_point(Vector2(0.2, 0.2))
	curve.add_point(Vector2(0.3, 0.6))
	curve.add_point(Vector2(0.4, 0.4))
	curve.add_point(Vector2(0.5, 0.5))
	curve.add_point(Vector2(0.6, 0.48))
	curve.add_point(Vector2(0.7, 0.5))
	curve.add_point(Vector2(0.8, 0.49))
	curve.add_point(Vector2(0.9, 0.5))
	curve.add_point(Vector2(1, 0.5))
	return curve

static func elastic() -> Curve:
	## Elastic curve
	var curve = Curve.new()
	curve.add_point(Vector2(0, 0))
	curve.add_point(Vector2(0.1, 1.2))
	curve.add_point(Vector2(0.2, 0.8))
	curve.add_point(Vector2(0.3, 1.1))
	curve.add_point(Vector2(0.4, 0.9))
	curve.add_point(Vector2(0.5, 1.05))
	curve.add_point(Vector2(0.6, 0.95))
	curve.add_point(Vector2(0.7, 1.02))
	curve.add_point(Vector2(0.8, 0.98))
	curve.add_point(Vector2(0.9, 1.01))
	curve.add_point(Vector2(1, 1))
	return curve

static func back() -> Curve:
	## Back curve
	var curve = Curve.new()
	curve.add_point(Vector2(0, 0))
	curve.add_point(Vector2(0.2, -0.2))
	curve.add_point(Vector2(0.4, 0.1))
	curve.add_point(Vector2(0.6, 0.8))
	curve.add_point(Vector2(0.8, 1.1))
	curve.add_point(Vector2(1, 1))
	return curve

static func snap() -> Curve:
	## Snap curve (quick reach target)
	var curve = Curve.new()
	curve.add_point(Vector2(0, 0))
	curve.add_point(Vector2(0.1, 0.9))
	curve.add_point(Vector2(0.2, 0.95))
	curve.add_point(Vector2(0.3, 0.98))
	curve.add_point(Vector2(0.4, 0.99))
	curve.add_point(Vector2(0.5, 1.0))
	curve.add_point(Vector2(1, 1))
	return curve

static func smooth_step() -> Curve:
	## Smooth step curve
	var curve = Curve.new()
	curve.add_point(Vector2(0, 0))
	curve.add_point(Vector2(0.1, 0.01))
	curve.add_point(Vector2(0.2, 0.05))
	curve.add_point(Vector2(0.3, 0.15))
	curve.add_point(Vector2(0.4, 0.3))
	curve.add_point(Vector2(0.5, 0.5))
	curve.add_point(Vector2(0.6, 0.7))
	curve.add_point(Vector2(0.7, 0.85))
	curve.add_point(Vector2(0.8, 0.95))
	curve.add_point(Vector2(0.9, 0.99))
	curve.add_point(Vector2(1, 1))
	return curve

# ===== Decay Curves =====

static func decay_linear() -> Curve:
	## Linear decay curve (from 1 to 0)
	var curve = Curve.new()
	curve.add_point(Vector2(0, 1))
	curve.add_point(Vector2(1, 0))
	return curve

static func decay_ease_out() -> Curve:
	## Ease Out decay curve
	var curve = Curve.new()
	curve.add_point(Vector2(0, 1), 0, 0.5)
	curve.add_point(Vector2(1, 0), -0.5, 0)
	return curve

# ===== Shake Curves =====

static func shake_sine() -> Curve:
	## Sine shake curve
	var curve = Curve.new()
	curve.add_point(Vector2(0, 1))
	curve.add_point(Vector2(0.1, -0.8))
	curve.add_point(Vector2(0.2, 0.6))
	curve.add_point(Vector2(0.3, -0.4))
	curve.add_point(Vector2(0.4, 0.3))
	curve.add_point(Vector2(0.5, -0.2))
	curve.add_point(Vector2(0.6, 0.15))
	curve.add_point(Vector2(0.7, -0.1))
	curve.add_point(Vector2(0.8, 0.05))
	curve.add_point(Vector2(0.9, -0.02))
	curve.add_point(Vector2(1, 0))
	return curve

# ===== Register All Presets =====

func register_all() -> void:
	## Register all curve presets to GameFeelFlow
	print("GFFCurvePresets: Registered curve presets")

# ===== Get Preset =====

static func get_preset(name: String) -> Curve:
	## Get curve preset
	match name:
		"linear":
			return linear()
		"ease_in":
			return ease_in()
		"ease_in_quad":
			return ease_in_quad()
		"ease_in_cubic":
			return ease_in_cubic()
		"ease_out":
			return ease_out()
		"ease_out_quad":
			return ease_out_quad()
		"ease_out_cubic":
			return ease_out_cubic()
		"ease_in_out":
			return ease_in_out()
		"ease_in_out_quad":
			return ease_in_out_quad()
		"bounce":
			return bounce()
		"elastic":
			return elastic()
		"back":
			return back()
		"snap":
			return snap()
		"smooth_step":
			return smooth_step()
		"decay_linear":
			return decay_linear()
		"decay_ease_out":
			return decay_ease_out()
		"shake_sine":
			return shake_sine()
		_:
			push_warning("GFFCurvePresets: Unknown preset: " + name)
			return linear()
