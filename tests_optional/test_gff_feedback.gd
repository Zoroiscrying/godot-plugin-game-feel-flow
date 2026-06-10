extends GdUnitTestSuite

## GFFFeedback 单元测试

# 测试用的反馈实现
class TestFeedback:
	extends GFFFeedback

	var execute_count: int = 0
	var last_target: Node = null
	var last_params: GFFParams = null

	func _execute(target: Node, params: GFFParams) -> void:
		execute_count += 1
		last_target = target
		last_params = params

# 测试夹具
var feedback: TestFeedback
var target: Node

func before_test() -> void:
	# 每个测试前执行
	feedback = TestFeedback.new()
	target = Node.new()

func after_test() -> void:
	# 每个测试后执行
	feedback.free()
	target.free()

# ===== 基础属性测试 =====

func test_default_enabled() -> void:
	# 测试默认启用
	assert_bool(feedback.enabled).is_true()

func test_default_label() -> void:
	# 测试默认标签
	assert_str(feedback.label).is_empty()

func test_default_priority() -> void:
	# 测试默认优先级
	assert_int(feedback.priority).is_equal(0)

func test_default_overlap_strategy() -> void:
	# 测试默认叠加策略
	assert_int(feedback.overlap_strategy).is_equal(GFFFeedback.OverlapStrategy.ADD)

func test_default_intensity() -> void:
	# 测试默认强度
	assert_float(feedback.default_intensity).is_equal(1.0)

func test_default_duration() -> void:
	# 测试默认持续时间
	assert_float(feedback.default_duration).is_equal(0.2)

# ===== 状态测试 =====

func test_initial_state() -> void:
	# 测试初始状态
	assert_bool(feedback.is_playing()).is_false()

# ===== 应用测试 =====

func test_apply_calls_execute() -> void:
	# 测试 apply 调用 _execute
	await feedback.apply(target)
	assert_int(feedback.execute_count).is_equal(1)

func test_apply_with_params() -> void:
	# 测试带参数的 apply
	var params = GFFParams.create(2.0, 0.5)
	await feedback.apply(target, params)
	assert_int(feedback.execute_count).is_equal(1)
	assert_object(feedback.last_params).is_same(params)

func test_apply_sets_target() -> void:
	# 测试 apply 设置目标
	await feedback.apply(target)
	assert_object(feedback.last_target).is_same(target)

func test_apply_with_null_target() -> void:
	# 测试 null 目标
	await feedback.apply(null)
	assert_int(feedback.execute_count).is_equal(1)
	assert_object(feedback.last_target).is_null()

func test_apply_emits_started_signal() -> void:
	# 测试 started 信号
	var signal_received = false
	feedback.started.connect(func(): signal_received = true)
	await feedback.apply(target)
	assert_bool(signal_received).is_true()

func test_apply_emits_finished_signal() -> void:
	# 测试 finished 信号
	var signal_received = false
	feedback.finished.connect(func(): signal_received = true)
	await feedback.apply(target)
	assert_bool(signal_received).is_true()

func test_apply_not_execute_when_disabled() -> void:
	# 测试禁用时不执行
	feedback.enabled = false
	await feedback.apply(target)
	assert_int(feedback.execute_count).is_equal(0)

# ===== 停止测试 =====

func test_stop() -> void:
	# 测试停止
	feedback.stop()
	assert_bool(feedback.is_playing()).is_false()

# ===== 参数获取测试 =====

func test_get_intensity_with_params() -> void:
	# 测试从参数获取强度
	var params = GFFParams.create(2.0)
	assert_float(feedback._get_intensity(params)).is_equal(2.0)

func test_get_intensity_without_params() -> void:
	# 测试无参数时获取默认强度
	assert_float(feedback._get_intensity(null)).is_equal(1.0)

func test_get_duration_with_params() -> void:
	# 测试从参数获取持续时间
	var params = GFFParams.create(1.0, 0.5)
	assert_float(feedback._get_duration(params)).is_equal(0.5)

func test_get_duration_without_params() -> void:
	# 测试无参数时获取默认持续时间
	assert_float(feedback._get_duration(null)).is_equal(0.2)

func test_get_duration_with_negative() -> void:
	# 测试负数持续时间使用默认值
	var params = GFFParams.create(1.0, -1.0)
	assert_float(feedback._get_duration(params)).is_equal(0.2)
