extends GdUnitTestSuite

## GFFFeedbackStack 单元测试

# 测试用的反馈实现
class MockFeedback:
	extends GFFFeedback

	var execute_count: int = 0
	var execution_order: Array = []

	func _execute(target: Node, params: GFFParams) -> void:
		execute_count += 1
		execution_order.append(label)

# 测试夹具
var stack: GFFFeedbackStack

func before_test() -> void:
	# 每个测试前执行
	stack = GFFFeedbackStack.new()

func after_test() -> void:
	# 每个测试后执行
	stack.free()

# ===== 基础属性测试 =====

func test_default_play_on_start() -> void:
	# 测试默认 play_on_start
	assert_bool(stack.play_on_start).is_false()

func test_default_cooldown() -> void:
	# 测试默认冷却时间
	assert_float(stack.cooldown).is_equal(0.0)

func test_default_intensity_multiplier() -> void:
	# 测试默认强度乘数
	assert_float(stack.intensity_multiplier).is_equal(1.0)

func test_empty_feedbacks() -> void:
	# 测试空反馈列表
	assert_array(stack.feedbacks).is_empty()

# ===== 状态测试 =====

func test_initial_state() -> void:
	# 测试初始状态
	assert_bool(stack.is_playing()).is_false()

# ===== 添加/移除测试 =====

func test_add_feedback() -> void:
	# 测试添加反馈
	var feedback = MockFeedback.new()
	stack.add_feedback(feedback)
	assert_array(stack.feedbacks).has_size(1)
	assert_object(stack.feedbacks[0]).is_same(feedback)
	feedback.free()

func test_remove_feedback() -> void:
	# 测试移除反馈
	var feedback1 = MockFeedback.new()
	var feedback2 = MockFeedback.new()
	stack.add_feedback(feedback1)
	stack.add_feedback(feedback2)
	stack.remove_feedback(0)
	assert_array(stack.feedbacks).has_size(1)
	assert_object(stack.feedbacks[0]).is_same(feedback2)
	feedback1.free()
	feedback2.free()

func test_remove_invalid_index() -> void:
	# 测试移除无效索引
	var feedback = MockFeedback.new()
	stack.add_feedback(feedback)
	stack.remove_feedback(-1)  # 无效索引
	stack.remove_feedback(1)   # 无效索引
	assert_array(stack.feedbacks).has_size(1)
	feedback.free()

func test_clear() -> void:
	# 测试清空
	var feedback1 = MockFeedback.new()
	var feedback2 = MockFeedback.new()
	stack.add_feedback(feedback1)
	stack.add_feedback(feedback2)
	stack.clear()
	assert_array(stack.feedbacks).is_empty()
	feedback1.free()
	feedback2.free()

func test_get_feedbacks() -> void:
	# 测试获取反馈列表
	var feedback1 = MockFeedback.new()
	var feedback2 = MockFeedback.new()
	stack.add_feedback(feedback1)
	stack.add_feedback(feedback2)
	var feedbacks = stack.get_feedbacks()
	assert_array(feedbacks).has_size(2)
	feedback1.free()
	feedback2.free()

# ===== 播放测试 =====

func test_play_empty_stack() -> void:
	# 测试播放空堆栈
	await stack.play()
	assert_bool(stack.is_playing()).is_false()

func test_play_calls_feedbacks() -> void:
	# 测试播放调用反馈
	var feedback1 = MockFeedback.new()
	feedback1.label = "feedback1"
	var feedback2 = MockFeedback.new()
	feedback2.label = "feedback2"
	stack.add_feedback(feedback1)
	stack.add_feedback(feedback2)

	await stack.play()

	assert_int(feedback1.execute_count).is_equal(1)
	assert_int(feedback2.execute_count).is_equal(1)
	feedback1.free()
	feedback2.free()

func test_play_respects_priority() -> void:
	# 测试播放尊重优先级
	var feedback1 = MockFeedback.new()
	feedback1.label = "low"
	feedback1.priority = 1
	var feedback2 = MockFeedback.new()
	feedback2.label = "high"
	feedback2.priority = 10
	stack.add_feedback(feedback1)
	stack.add_feedback(feedback2)

	await stack.play()

	# 高优先级应该先执行
	assert_str(feedback1.execution_order[0]).is_equal("high")
	assert_str(feedback1.execution_order[1]).is_equal("low")
	feedback1.free()
	feedback2.free()

func test_play_skips_disabled() -> void:
	# 测试播放跳过禁用的反馈
	var feedback1 = MockFeedback.new()
	feedback1.enabled = true
	var feedback2 = MockFeedback.new()
	feedback2.enabled = false
	stack.add_feedback(feedback1)
	stack.add_feedback(feedback2)

	await stack.play()

	assert_int(feedback1.execute_count).is_equal(1)
	assert_int(feedback2.execute_count).is_equal(0)
	feedback1.free()
	feedback2.free()

func test_play_emits_signals() -> void:
	# 测试播放发送信号
	var started_received = false
	var finished_received = false
	stack.started.connect(func(): started_received = true)
	stack.finished.connect(func(): finished_received = true)

	var feedback = MockFeedback.new()
	stack.add_feedback(feedback)

	await stack.play()

	assert_bool(started_received).is_true()
	assert_bool(finished_received).is_true()
	feedback.free()

func test_play_with_intensity_multiplier() -> void:
	# 测试强度乘数
	var feedback = MockFeedback.new()
	stack.add_feedback(feedback)
	stack.intensity_multiplier = 2.0

	await stack.play()

	assert_int(feedback.execute_count).is_equal(1)
	feedback.free()

# ===== 停止测试 =====

func test_stop() -> void:
	# 测试停止
	var feedback = MockFeedback.new()
	stack.add_feedback(feedback)
	stack.stop()
	assert_bool(stack.is_playing()).is_false()
	feedback.free()

# ===== 冷却时间测试 =====

func test_cooldown() -> void:
	# 测试冷却时间
	stack.cooldown = 1.0
	var feedback = MockFeedback.new()
	stack.add_feedback(feedback)

	# 第一次播放
	await stack.play()
	assert_int(feedback.execute_count).is_equal(1)

	# 立即再次播放（应该被冷却阻止）
	await stack.play()
	assert_int(feedback.execute_count).is_equal(1)

	feedback.free()
