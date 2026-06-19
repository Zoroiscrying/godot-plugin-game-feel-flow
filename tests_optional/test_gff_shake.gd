extends GdUnitTestSuite

## GFFShake 单元测试

# 测试夹具
var shake: GFFShake
var target: Node2D
var camera: Camera2D

func before_test() -> void:
	# 每个测试前执行
	shake = GFFShake.new()
	target = Node2D.new()
	camera = Camera2D.new()
	target.add_child(camera)
	# 添加到场景树中，否则 get_tree() 会返回 null
	add_child(target)

func after_test() -> void:
	# 每个测试后执行
	target.free()

# ===== 基础属性测试 =====

func test_default_amplitude() -> void:
	# 测试默认振幅
	assert_float(shake.amplitude).is_equal(0.5)

func test_default_frequency() -> void:
	# 测试默认频率
	assert_float(shake.frequency).is_equal(15.0)

func test_default_axes() -> void:
	# 测试默认轴向
	assert_that(shake.axes).is_equal(Vector3(1, 1, 0))

func test_default_attenuation_curve() -> void:
	# 测试默认衰减曲线
	assert_object(shake.attenuation_curve).is_null()

# ===== 执行测试 =====

func test_execute_with_camera() -> void:
	# 测试带相机执行
	var original_position = camera.position
	var params = GFFParams.create(1.0, 0.1)

	# 执行震动
	await shake.apply(target, params)

	# 震动后应该恢复原始位置
	assert_that(camera.position).is_equal(original_position)

func test_execute_with_node2d() -> void:
	# 测试带 Node2D 执行
	var original_position = target.position
	var params = GFFParams.create(1.0, 0.1)

	# 执行震动
	await shake.apply(target, params)

	# 震动后应该恢复原始位置
	assert_that(target.position).is_equal(original_position)

func test_execute_with_custom_params() -> void:
	# 测试自定义参数
	var params = GFFParams.create(2.0, 0.1) \
		.with_float("amplitude", 20.0) \
		.with_float("frequency", 30.0) \
		.with_vector3("axes", Vector3(1, 0, 0))

	await shake.apply(target, params)

	# 应该正常执行
	assert_bool(shake.is_playing()).is_false()

func test_execute_with_curve() -> void:
	# 测试带曲线执行
	var curve = Curve.new()
	curve.add_point(Vector2(0, 1))
	curve.add_point(Vector2(1, 0))
	shake.attenuation_curve = curve

	var params = GFFParams.create(1.0, 0.1)

	await shake.apply(target, params)

	assert_bool(shake.is_playing()).is_false()

# ===== 参数获取测试 =====

func test_get_amplitude_with_params() -> void:
	# 测试从参数获取振幅
	var params = GFFParams.create().with_float("amplitude", 20.0)
	var amp = params.get_float("amplitude", shake.amplitude)
	assert_float(amp).is_equal(20.0)

func test_get_amplitude_without_params() -> void:
	# 测试无参数时获取默认振幅
	var amp = shake.amplitude
	assert_float(amp).is_equal(0.5)

func test_get_frequency_with_params() -> void:
	# 测试从参数获取频率
	var params = GFFParams.create().with_float("frequency", 30.0)
	var freq = params.get_float("frequency", shake.frequency)
	assert_float(freq).is_equal(30.0)

func test_get_axes_with_params() -> void:
	# 测试从参数获取轴向
	var params = GFFParams.create().with_vector3("axes", Vector3(1, 0, 0))
	var ax = params.get_vector3("axes", shake.axes)
	assert_that(ax).is_equal(Vector3(1, 0, 0))
