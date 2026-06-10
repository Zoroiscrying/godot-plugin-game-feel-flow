extends GdUnitTestSuite

## GFFParams 单元测试

# 测试夹具
var params: GFFParams

func before_test() -> void:
	# 每个测试前执行
	params = GFFParams.create()

func after_test() -> void:
	# 每个测试后执行
	params = null

# ===== 创建测试 =====

func test_create_default() -> void:
	# 测试默认创建
	var p = GFFParams.create()
	assert_float(p.intensity).is_equal(1.0)
	assert_float(p.duration).is_equal(-1.0)

func test_create_with_params() -> void:
	# 测试带参数创建
	var p = GFFParams.create(2.0, 0.5)
	assert_float(p.intensity).is_equal(2.0)
	assert_float(p.duration).is_equal(0.5)

# ===== 链式方法测试 =====

func test_with_float() -> void:
	# 测试 with_float
	params.with_float("amplitude", 10.0)
	assert_float(params.get_float("amplitude")).is_equal(10.0)

func test_with_int() -> void:
	# 测试 with_int
	params.with_int("count", 5)
	assert_int(params.get_int("count")).is_equal(5)

func test_with_bool() -> void:
	# 测试 with_bool
	params.with_bool("enabled", true)
	assert_bool(params.get_bool("enabled")).is_true()

func test_with_vector2() -> void:
	# 测试 with_vector2
	var vec = Vector2(10, 20)
	params.with_vector2("position", vec)
	assert_vector2(params.get_vector2("position")).is_equal(vec)

func test_with_vector3() -> void:
	# 测试 with_vector3
	var vec = Vector3(10, 20, 30)
	params.with_vector3("axes", vec)
	assert_vector3(params.get_vector3("axes")).is_equal(vec)

func test_with_color() -> void:
	# 测试 with_color
	var color = Color.RED
	params.with_color("color", color)
	assert_color(params.get_color("color")).is_equal(color)

func test_with_string() -> void:
	# 测试 with_string
	params.with_string("name", "test")
	assert_str(params.get_string("name")).is_equal("test")

func test_with_curve() -> void:
	# 测试 with_curve
	var curve = Curve.new()
	curve.add_point(Vector2(0, 0))
	curve.add_point(Vector2(1, 1))
	params.with_curve("easing", curve)
	assert_object(params.get_curve("easing")).is_same(curve)

func test_with_node() -> void:
	# 测试 with_node
	var node = Node.new()
	params.with_node("target", node)
	assert_object(params.get_node("target")).is_same(node)
	node.free()

func test_with_resource() -> void:
	# 测试 with_resource
	var resource = Resource.new()
	params.with_resource("data", resource)
	assert_object(params.get_resource("data")).is_same(resource)

func test_with_variant() -> void:
	# 测试 with_variant
	params.with_variant("custom", "value")
	assert_that(params.get_variant("custom")).is_equal("value")

# ===== 获取方法测试 =====

func test_get_float_default() -> void:
	# 测试 get_float 默认值
	assert_float(params.get_float("nonexistent", 5.0)).is_equal(5.0)

func test_get_int_default() -> void:
	# 测试 get_int 默认值
	assert_int(params.get_int("nonexistent", 10)).is_equal(10)

func test_get_bool_default() -> void:
	# 测试 get_bool 默认值
	assert_bool(params.get_bool("nonexistent", true)).is_true()

func test_get_vector2_default() -> void:
	# 测试 get_vector2 默认值
	var default = Vector2(1, 2)
	assert_vector2(params.get_vector2("nonexistent", default)).is_equal(default)

func test_get_vector3_default() -> void:
	# 测试 get_vector3 默认值
	var default = Vector3(1, 2, 3)
	assert_vector3(params.get_vector3("nonexistent", default)).is_equal(default)

func test_get_color_default() -> void:
	# 测试 get_color 默认值
	var default = Color.BLUE
	assert_color(params.get_color("nonexistent", default)).is_equal(default)

func test_get_string_default() -> void:
	# 测试 get_string 默认值
	assert_str(params.get_string("nonexistent", "default")).is_equal("default")

func test_get_curve_default() -> void:
	# 测试 get_curve 默认值
	assert_object(params.get_curve("nonexistent", null)).is_null()

func test_get_node_default() -> void:
	# 测试 get_node 默认值
	assert_object(params.get_node("nonexistent", null)).is_null()

func test_get_resource_default() -> void:
	# 测试 get_resource 默认值
	assert_object(params.get_resource("nonexistent", null)).is_null()

func test_get_variant_default() -> void:
	# 测试 get_variant 默认值
	assert_that(params.get_variant("nonexistent", "default")).is_equal("default")

# ===== 链式调用测试 =====

func test_chain_calls() -> void:
	# 测试链式调用
	var result = params \
		.with_float("amplitude", 10.0) \
		.with_color("color", Color.RED) \
		.with_int("count", 5)

	assert_float(result.get_float("amplitude")).is_equal(10.0)
	assert_color(result.get_color("color")).is_equal(Color.RED)
	assert_int(result.get_int("count")).is_equal(5)
	# 链式调用应该返回同一个对象
	assert_object(result).is_same(params)

# ===== 覆盖测试 =====

func test_override_value() -> void:
	# 测试覆盖值
	params.with_float("value", 1.0)
	params.with_float("value", 2.0)
	assert_float(params.get_float("value")).is_equal(2.0)
