extends GdUnitTestSuite

## GFFParams 单元测试

# 测试夹具
var params: GFFParams

func before_test() -> void:
	params = GFFParams.create()

func after_test() -> void:
	params = null

# ===== 创建测试 =====

func test_create_default() -> void:
	var p = GFFParams.create()
	assert_float(p.intensity).is_equal(1.0)
	assert_float(p.duration).is_equal(-1.0)

func test_create_with_params() -> void:
	var p = GFFParams.create(2.0, 0.5)
	assert_float(p.intensity).is_equal(2.0)
	assert_float(p.duration).is_equal(0.5)

func test_from_dict() -> void:
	var dict = {
		"intensity": 3.0,
		"duration": 0.8,
		"amplitude": 10.0,
		"count": 5
	}
	var p = GFFParams.from_dict(dict)
	assert_float(p.intensity).is_equal(3.0)
	assert_float(p.duration).is_equal(0.8)
	assert_float(p.get_float("amplitude")).is_equal(10.0)
	assert_int(p.get_int("count")).is_equal(5)

# ===== 链式方法测试 =====

func test_with_float() -> void:
	params.with_float("amplitude", 10.0)
	assert_float(params.get_float("amplitude")).is_equal(10.0)

func test_with_int() -> void:
	params.with_int("count", 5)
	assert_int(params.get_int("count")).is_equal(5)

func test_with_bool() -> void:
	params.with_bool("enabled", true)
	assert_bool(params.get_bool("enabled")).is_true()

func test_with_vector2() -> void:
	var vec = Vector2(10, 20)
	params.with_vector2("position", vec)
	assert_vector2(params.get_vector2("position")).is_equal(vec)

func test_with_vector3() -> void:
	var vec = Vector3(10, 20, 30)
	params.with_vector3("axes", vec)
	assert_vector3(params.get_vector3("axes")).is_equal(vec)

func test_with_color() -> void:
	var color = Color.RED
	params.with_color("color", color)
	assert_color(params.get_color("color")).is_equal(color)

func test_with_string() -> void:
	params.with_string("name", "test")
	assert_str(params.get_string("name")).is_equal("test")

func test_with_curve() -> void:
	var curve = Curve.new()
	curve.add_point(Vector2(0, 0))
	curve.add_point(Vector2(1, 1))
	params.with_curve("easing", curve)
	assert_object(params.get_curve("easing")).is_same(curve)

func test_with_node() -> void:
	var node = Node.new()
	params.with_node("target", node)
	assert_object(params.get_node("target")).is_same(node)
	node.free()

func test_with_resource() -> void:
	var resource = Resource.new()
	params.with_resource("data", resource)
	assert_object(params.get_resource("data")).is_same(resource)

func test_with_variant() -> void:
	params.with_variant("custom", "value")
	assert_that(params.get_variant("custom")).is_equal("value")

# ===== 获取方法测试 =====

func test_get_float_default() -> void:
	assert_float(params.get_float("nonexistent", 5.0)).is_equal(5.0)

func test_get_int_default() -> void:
	assert_int(params.get_int("nonexistent", 10)).is_equal(10)

func test_get_bool_default() -> void:
	assert_bool(params.get_bool("nonexistent", true)).is_true()

func test_get_vector2_default() -> void:
	var default = Vector2(1, 2)
	assert_vector2(params.get_vector2("nonexistent", default)).is_equal(default)

func test_get_vector3_default() -> void:
	var default = Vector3(1, 2, 3)
	assert_vector3(params.get_vector3("nonexistent", default)).is_equal(default)

func test_get_color_default() -> void:
	var default = Color.BLUE
	assert_color(params.get_color("nonexistent", default)).is_equal(default)

func test_get_string_default() -> void:
	assert_str(params.get_string("nonexistent", "default")).is_equal("default")

func test_get_curve_default() -> void:
	assert_object(params.get_curve("nonexistent", null)).is_null()

func test_get_node_default() -> void:
	assert_object(params.get_node("nonexistent", null)).is_null()

func test_get_resource_default() -> void:
	assert_object(params.get_resource("nonexistent", null)).is_null()

func test_get_variant_default() -> void:
	assert_that(params.get_variant("nonexistent", "default")).is_equal("default")

# ===== 向量转换测试 =====

func test_get_vector2_from_vector3() -> void:
	params.with_vector3("pos", Vector3(10, 20, 30))
	assert_vector2(params.get_vector2("pos")).is_equal(Vector2(10, 20))

func test_get_vector3_from_vector2() -> void:
	params.with_vector2("pos", Vector2(10, 20))
	assert_vector3(params.get_vector3("pos")).is_equal(Vector3(10, 20, 0))

# ===== 链式调用测试 =====

func test_chain_calls() -> void:
	var result = params \
		.with_float("amplitude", 10.0) \
		.with_color("color", Color.RED) \
		.with_int("count", 5)

	assert_float(result.get_float("amplitude")).is_equal(10.0)
	assert_color(result.get_color("color")).is_equal(Color.RED)
	assert_int(result.get_int("count")).is_equal(5)
	assert_object(result).is_same(params)

# ===== 覆盖测试 =====

func test_override_value() -> void:
	params.with_float("value", 1.0)
	params.with_float("value", 2.0)
	assert_float(params.get_float("value")).is_equal(2.0)
