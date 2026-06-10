extends GdUnitTestSuite

## GFFPlayer 单元测试

# 测试用的反馈实现
class MockFeedback:
	extends GFFFeedback

	var execute_count: int = 0
	var last_target: Node = null
	var last_params: GFFParams = null

	func _execute(target: Node, params: GFFParams) -> void:
		execute_count += 1
		last_target = target
		last_params = params

# 测试夹具
var player: GFFPlayer
var target: Node
var parent: Node

func before_test() -> void:
	# 每个测试前执行
	parent = Node.new()
	target = Node.new()
	parent.add_child(target)
	player = GFFPlayer.new()
	target.add_child(player)

func after_test() -> void:
	# 每个测试后执行
	player.free()
	target.free()
	parent.free()

# ===== 基础属性测试 =====

func test_default_play_on_ready() -> void:
	# 测试默认 play_on_ready
	assert_bool(player.play_on_ready).is_false()

func test_default_target() -> void:
	# 测试默认目标（应该是父节点）
	assert_object(player.target).is_same(target)

func test_default_stack() -> void:
	# 测试默认堆栈
	assert_object(player.stack).is_null()

# ===== 播放测试 =====

func test_play_with_feedback() -> void:
	# 测试播放单个反馈
	var feedback = MockFeedback.new()
	await player.play(feedback)
	assert_int(feedback.execute_count).is_equal(1)
	assert_object(feedback.last_target).is_same(target)
	feedback.free()

func test_play_with_feedback_and_params() -> void:
	# 测试带参数播放
	var feedback = MockFeedback.new()
	var params = GFFParams.create(2.0, 0.5)
	await player.play(feedback, params)
	assert_int(feedback.execute_count).is_equal(1)
	assert_object(feedback.last_params).is_same(params)
	feedback.free()

func test_play_with_dict_params() -> void:
	# 测试字典参数
	var feedback = MockFeedback.new()
	await player.play(feedback, {"intensity": 2.0, "duration": 0.5})
	assert_int(feedback.execute_count).is_equal(1)
	feedback.free()

func test_play_with_float_params() -> void:
	# 测试浮点数参数
	var feedback = MockFeedback.new()
	await player.play(feedback, 2.0)
	assert_int(feedback.execute_count).is_equal(1)
	feedback.free()

func test_play_null_feedback() -> void:
	# 测试 null 反馈（应该播放堆栈）
	player.stack = GFFFeedbackStack.new()
	await player.play()
	# 不应该崩溃
	player.stack.free()

func test_play_string_feedback() -> void:
	# 测试字符串反馈（未注册）
	await player.play("nonexistent")
	# 不应该崩溃，但会有警告

# ===== 堆栈播放测试 =====

func test_play_stack() -> void:
	# 测试播放堆栈
	var feedback = MockFeedback.new()
	player.stack = GFFFeedbackStack.new()
	player.stack.add_feedback(feedback)

	await player.play()

	assert_int(feedback.execute_count).is_equal(1)
	feedback.free()
	player.stack.free()

# ===== 停止测试 =====

func test_stop() -> void:
	# 测试停止
	player.stop()
	# 不应该崩溃

func test_stop_with_stack() -> void:
	# 测试停止堆栈
	player.stack = GFFFeedbackStack.new()
	player.stop()
	player.stack.free()

func test_stop_all() -> void:
	# 测试停止所有（包括子节点）
	var child_player = GFFPlayer.new()
	player.add_child(child_player)
	player.stop_all()
	child_player.free()

# ===== 信号测试 =====

func test_started_signal() -> void:
	# 测试 started 信号
	var signal_received = false
	player.started.connect(func(): signal_received = true)

	player.stack = GFFFeedbackStack.new()
	var feedback = MockFeedback.new()
	player.stack.add_feedback(feedback)

	await player.play()

	assert_bool(signal_received).is_true()
	feedback.free()
	player.stack.free()

func test_finished_signal() -> void:
	# 测试 finished 信号
	var signal_received = false
	player.finished.connect(func(): signal_received = true)

	player.stack = GFFFeedbackStack.new()
	var feedback = MockFeedback.new()
	player.stack.add_feedback(feedback)

	await player.play()

	assert_bool(signal_received).is_true()
	feedback.free()
	player.stack.free()

# ===== 资源管理测试 =====

func test_export_stack() -> void:
	# 测试导出堆栈
	player.stack = GFFFeedbackStack.new()
	var exported = player.export_stack()
	assert_object(exported).is_same(player.stack)
	player.stack.free()

func test_import_stack() -> void:
	# 测试导入堆栈
	var new_stack = GFFFeedbackStack.new()
	player.import_stack(new_stack)
	assert_object(player.stack).is_same(new_stack)
	player.stack.free()
