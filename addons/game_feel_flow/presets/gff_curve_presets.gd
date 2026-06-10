class_name GFFCurvePresets

## Game Feel Flow Curve Presets
##
## 提供常用曲线预设

static func ease_in() -> Curve:
	var curve = Curve.new()
	curve.add_point(Vector2(0, 0))
	curve.add_point(Vector2(1, 1), Vector2(0.5, 0), Vector2(0.5, 1))
	return curve

static func ease_out() -> Curve:
	var curve = Curve.new()
	curve.add_point(Vector2(0, 0), Vector2(0.5, 0), Vector2(0.5, 1))
	curve.add_point(Vector2(1, 1))
	return curve

static func ease_in_out() -> Curve:
	var curve = Curve.new()
	curve.add_point(Vector2(0, 0))
	curve.add_point(Vector2(0.5, 0.5))
	curve.add_point(Vector2(1, 1))
	return curve

static func bounce() -> Curve:
	var curve = Curve.new()
	curve.add_point(Vector2(0, 0))
	curve.add_point(Vector2(0.3, 1.2))
	curve.add_point(Vector2(0.5, 0.8))
	curve.add_point(Vector2(0.7, 1.05))
	curve.add_point(Vector2(1, 1))
	return curve

static func elastic() -> Curve:
	var curve = Curve.new()
	curve.add_point(Vector2(0, 0))
	curve.add_point(Vector2(0.2, 1.3))
	curve.add_point(Vector2(0.4, 0.7))
	curve.add_point(Vector2(0.6, 1.1))
	curve.add_point(Vector2(0.8, 0.95))
	curve.add_point(Vector2(1, 1))
	return curve
