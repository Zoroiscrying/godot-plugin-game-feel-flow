extends GdUnitTestSuite

## GameFeelFlow 单元测试

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
var game_feel_flow: Node
var target: Node

func before_test() -> void:
	# 每个测试前执行
	# 注意：GameFeelFlow 是全局单例，我们需要获取它
	game_feel_flow = Engine.get_singleton("GameFeelFlow")
	if not game_feel_flow:
		# 如果没有注册，创建一个临时的
		game_feel_flow = load("res://addons/game_feel_flow/core/game_feel_flow.gd").new()
	target = Node.new()

func after_test() -> void:
	# 每个测试后执行
	target.free()
	# 不要 free game_feel_flow，因为它是全局单例

# ===== 注册系统测试 =====

func test_register_feedback() -> void:
	# 测试注册反馈
	var feedback = MockFeedback.new()
	game_feel_flow.register_feedback("test", feedback)
	assert_object(game_feel_flow.get_feedback("test")).is_same(feedback)
	game_feel_flow.unregister_feedback("test")
	feedback.free()

func test_unregister_feedback() -> void:
	# 测试注销反馈
	var feedback = MockFeedback.new()
	game_feel_flow.register_feedback("test", feedback)
	game_feel_flow.unregister_feedback("test")
	assert_object(game_feel_flow.get_feedback("test")).is_null()
	feedback.free()

func test_get_nonexistent_feedback() -> void:
	# 测试获取不存在的反馈
	assert_object(game_feel_flow.get_feedback("nonexistent")).is_null()

func test_register_preset() -> void:
	# 测试注册预设
	var feedback = MockFeedback.new()
	game_feel_flow.register_preset("test_preset", feedback)
	assert_object(game_feel_flow.get_preset("test_preset")).is_same(feedback)
	game_feel_flow.unregister_preset("test_preset")
	feedback.free()

func test_unregister_preset() -> void:
	# 测试注销预设
	var feedback = MockFeedback.new()
	game_feel_flow.register_preset("test_preset", feedback)
	game_feel_flow.unregister_preset("test_preset")
	assert_object(game_feel_flow.get_preset("test_preset")).is_null()
	feedback.free()

func test_get_nonexistent_preset() -> void:
	# 测试获取不存在的预设
	assert_object(game_feel_flow.get_preset("nonexistent")).is_null()

# ===== 调试测试 =====

func test_set_debug() -> void:
	# 测试设置调试模式
	game_feel_flow.set_debug(true)
	assert_bool(game_feel_flow.debug_enabled).is_true()
	game_feel_flow.set_debug(false)
	assert_bool(game_feel_flow.debug_enabled).is_false()

func test_get_active_effects() -> void:
	# 测试获取活跃效果
	var effects = game_feel_flow.get_active_effects()
	assert_array(effects).is_empty()

# ===== 查找策略测试 =====

func test_default_find_strategy() -> void:
	# 测试默认查找策略
	assert_int(game_feel_flow.default_find_strategy).is_equal(game_feel_flow.FindStrategy.AUTO)

func test_find_player_direct() -> void:
	# 测试直接子节点查找
	var player = GFFPlayer.new()
	target.add_child(player)
	var found = game_feel_flow._find_player(target)
	assert_object(found).is_same(player)
	player.free()

func test_find_player_recursive() -> void:
	# 测试递归查找
	var child = Node.new()
	target.add_child(child)
	var player = GFFPlayer.new()
	child.add_child(player)
	var found = game_feel_flow._find_player(target)
	assert_object(found).is_same(player)
	child.free()
	player.free()

func test_find_player_returns_null() -> void:
	# 测试找不到播放器
	var found = game_feel_flow._find_player(target)
	assert_object(found).is_null()

func test_find_player_cached() -> void:
	# 测试缓存
	var player = GFFPlayer.new()
	target.add_child(player)
	var found1 = game_feel_flow._find_player(target)
	var found2 = game_feel_flow._find_player(target)
	assert_object(found1).is_same(found2)
	player.free()

# ===== 参数处理测试 =====

func test_ensure_params_null() -> void:
	# 测试 null 参数
	var params = game_feel_flow._ensure_params(null)
	assert_object(params).is_not_null()
	assert_float(params.intensity).is_equal(1.0)

func test_ensure_params_gff_params() -> void:
	# 测试 GFFParams 参数
	var original = GFFParams.create(2.0, 0.5)
	var params = game_feel_flow._ensure_params(original)
	assert_object(params).is_same(original)

func test_ensure_params_float() -> void:
	# 测试浮点数参数
	var params = game_feel_flow._ensure_params(2.0)
	assert_object(params).is_not_null()
	assert_float(params.intensity).is_equal(2.0)

func test_ensure_params_int() -> void:
	# 测试整数参数
	var params = game_feel_flow._ensure_params(2)
	assert_object(params).is_not_null()
	assert_float(params.intensity).is_equal(2.0)

func test_ensure_params_dict() -> void:
	# 测试字典参数
	var params = game_feel_flow._ensure_params({"intensity": 2.0, "duration": 0.5})
	assert_object(params).is_not_null()
	assert_float(params.intensity).is_equal(2.0)
	assert_float(params.duration).is_equal(0.5)

# ===== 信号系统测试 =====

func test_emit_event() -> void:
	# 测试发送事件
	var received_data = null
	game_feel_flow.listen("test_event", func(data): received_data = data)
	game_feel_flow.emit("test_event", {"key": "value"})
	assert_that(received_data).is_equal({"key": "value"})
	game_feel_flow.unlisten("test_event", func(data): pass)

func test_listen_event() -> void:
	# 测试监听事件
	var call_count = 0
	var callback = func(data): call_count += 1
	game_feel_flow.listen("test_event", callback)
	game_feel_flow.emit("test_event")
	assert_int(call_count).is_equal(1)
	game_feel_flow.unlisten("test_event", callback)

func test_unlisten_event() -> void:
	# 测试取消监听
	var call_count = 0
	var callback = func(data): call_count += 1
	game_feel_flow.listen("test_event", callback)
	game_feel_flow.unlisten("test_event", callback)
	game_feel_flow.emit("test_event")
	assert_int(call_count).is_equal(0)

func test_multiple_listeners() -> void:
	# 测试多个监听器
	var call_count1 = 0
	var call_count2 = 0
	var callback1 = func(data): call_count1 += 1
	var callback2 = func(data): call_count2 += 1
	game_feel_flow.listen("test_event", callback1)
	game_feel_flow.listen("test_event", callback2)
	game_feel_flow.emit("test_event")
	assert_int(call_count1).is_equal(1)
	assert_int(call_count2).is_equal(1)
	game_feel_flow.unlisten("test_event", callback1)
	game_feel_flow.unlisten("test_event", callback2)

func test_emit_nonexistent_event() -> void:
	# 测试发送不存在的事件
	game_feel_flow.emit("nonexistent_event")
	# 不应该崩溃
