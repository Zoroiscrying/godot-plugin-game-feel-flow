extends GdUnitTestSuite

## GFFCombo 单元测试

# 测试用的反馈实现
class MockFeedback:
	extends GFFFeedback

	var execute_count: int = 0
	var execution_order: Array = []

	func _execute(target: Node, params: GFFParams) -> void:
		execute_count += 1
		execution_order.append(label)

# 测试夹具
var combo: GFFCombo

func before_test() -> void:
	# 每个测试前执行
	combo = GFFCombo.new()

func after_test() -> void:
	# 每个测试后执行
	combo.free()

# ===== 基础属性测试 =====

func test_empty_effects() -> void:
	# 测试空效果列表
	assert_array(combo.effects).is_empty()

func test_default_params() -> void:
	# 测试默认参数
	assert_object(combo.params).is_null()

# ===== 状态测试 =====

func test_initial_state() -> void:
	# 测试初始状态
	assert_bool(combo.is_playing()).is_false()

# ===== 播放测试 =====

func test_play_empty_combo() -> void:
	# 测试播放空组合
	await combo.play()
	assert_bool(combo.is_playing()).is_false()

func test_play_calls_effects() -> void:
	# 测试播放调用效果
	var feedback1 = MockFeedback.new()
	feedback1.label = "feedback1"
	var feedback2 = MockFeedback.new()
	feedback2.label = "feedback2"
	combo.effects = [feedback1, feedback2]

	await combo.play()

	assert_int(feedback1.execute_count).is_equal(1)
	assert_int(feedback2.execute_count).is_equal(1)
	feedback1.free()
	feedback2.free()

func test_play_skips_disabled() -> void:
	# 测试播放跳过禁用的效果
	var feedback1 = MockFeedback.new()
	feedback1.enabled = true
	var feedback2 = MockFeedback.new()
	feedback2.enabled = false
	combo.effects = [feedback1, feedback2]

	await combo.play()

	assert_int(feedback1.execute_count).is_equal(1)
	assert_int(feedback2.execute_count).is_equal(0)
	feedback1.free()
	feedback2.free()

func test_play_emits_signals() -> void:
	# 测试播放发送信号
	var started_received = false
	var finished_received = false
	combo.started.connect(func(): started_received = true)
	combo.finished.connect(func(): finished_received = true)

	var feedback = MockFeedback.new()
	combo.effects = [feedback]

	await combo.play()

	assert_bool(started_received).is_true()
	assert_bool(finished_received).is_true()
	feedback.free()

# ===== 参数合并测试 =====

func test_play_with_null_params() -> void:
	# 测试 null 参数
	var feedback = MockFeedback.new()
	combo.effects = [feedback]

	await combo.play(null)

	assert_int(feedback.execute_count).is_equal(1)
	feedback.free()

func test_play_with_gff_params() -> void:
	# 测试 GFFParams 参数
	var feedback = MockFeedback.new()
	combo.effects = [feedback]

	var params = GFFParams.create(2.0, 0.5)
	await combo.play(null, params)

	assert_int(feedback.execute_count).is_equal(1)
	feedback.free()

func test_play_with_dict_params() -> void:
	# 测试字典参数
	var feedback = MockFeedback.new()
	combo.effects = [feedback]

	await combo.play(null, {"intensity": 2.0, "duration": 0.5})

	assert_int(feedback.execute_count).is_equal(1)
	feedback.free()

func test_play_with_float_params() -> void:
	# 测试浮点数参数
	var feedback = MockFeedback.new()
	combo.effects = [feedback]

	await combo.play(null, 2.0)

	assert_int(feedback.execute_count).is_equal(1)
	feedback.free()

func test_merge_params_intensity() -> void:
	# 测试参数合并 - 强度
	combo.params = GFFParams.create(1.0)
	var feedback = MockFeedback.new()
	combo.effects = [feedback]

	await combo.play(null, GFFParams.create(2.0))

	assert_int(feedback.execute_count).is_equal(1)
	feedback.free()

# ===== 停止测试 =====

func test_stop() -> void:
	# 测试停止
	combo.stop()
	assert_bool(combo.is_playing()).is_false()

func test_stop_with_effects() -> void:
	# 测试停止效果
	var feedback = MockFeedback.new()
	combo.effects = [feedback]
	combo.stop()
	feedback.free()

# ===== 静态方法测试 =====

func test_death_combo() -> void:
	# 测试死亡组合
	var death_combo = GFFCombo.death()
	assert_object(death_combo).is_not_null()
	# 注意：death() 目前返回空组合，因为效果类还未完全实现

func test_hit_combo() -> void:
	# 测试受伤组合
	var hit_combo = GFFCombo.hit()
	assert_object(hit_combo).is_not_null()

func test_pickup_combo() -> void:
	# 测试拾取组合
	var pickup_combo = GFFCombo.pickup()
	assert_object(pickup_combo).is_not_null()
