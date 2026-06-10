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
	game_feel_flow = load("res://addons/game_feel_flow/core/game_feel_flow.gd").new()
	target = Node.new()

func after_test() -> void:
	target.free()
	game_feel_flow.free()


# ===== 注册系统测试 =====

func test_register_effect() -> void:
	var feedback = MockFeedback.new()
	game_feel_flow.register_effect("test", feedback)
	assert_object(game_feel_flow.get_effect("test")).is_same(feedback)


func test_get_nonexistent_effect() -> void:
	assert_object(game_feel_flow.get_effect("nonexistent")).is_null()

func test_register_combo() -> void:
	var combo = GFFCombo.new()
	combo.label = "test_combo"
	game_feel_flow.register_combo("test_combo", combo)
	assert_object(game_feel_flow.get_combo("test_combo")).is_same(combo)

func test_get_nonexistent_combo() -> void:
	assert_object(game_feel_flow.get_combo("nonexistent")).is_null()

# ===== 调试测试 =====

func test_set_debug() -> void:
	game_feel_flow.set_debug(true)
	assert_bool(game_feel_flow.debug_enabled).is_true()
	game_feel_flow.set_debug(false)
	assert_bool(game_feel_flow.debug_enabled).is_false()

# ===== 查找播放器测试 =====

func test_find_player_direct() -> void:
	var player = GFFPlayer.new()
	target.add_child(player)
	var found = game_feel_flow._find_player(target)
	assert_object(found).is_same(player)
	player.free()

func test_find_player_returns_null() -> void:
	var found = game_feel_flow._find_player(target)
	assert_object(found).is_null()

func test_find_player_is_target() -> void:
	var player = GFFPlayer.new()
	var found = game_feel_flow._find_player(player)
	assert_object(found).is_same(player)
	player.free()

# ===== 参数处理测试 =====

func test_ensure_params_null() -> void:
	var params = game_feel_flow._ensure_params(null)
	assert_object(params).is_not_null()
	assert_float(params.intensity).is_equal(1.0)

func test_ensure_params_gff_params() -> void:
	var original = GFFParams.create(2.0, 0.5)
	var params = game_feel_flow._ensure_params(original)
	assert_object(params).is_same(original)

func test_ensure_params_float() -> void:
	var params = game_feel_flow._ensure_params(2.0)
	assert_object(params).is_not_null()
	assert_float(params.intensity).is_equal(2.0)

func test_ensure_params_int() -> void:
	var params = game_feel_flow._ensure_params(2)
	assert_object(params).is_not_null()
	assert_float(params.intensity).is_equal(2.0)

func test_ensure_params_dict() -> void:
	var params = game_feel_flow._ensure_params({"intensity": 2.0, "duration": 0.5})
	assert_object(params).is_not_null()
	assert_float(params.intensity).is_equal(2.0)
	assert_float(params.duration).is_equal(0.5)

# ===== 信号系统测试 =====

func test_emit_event() -> void:
	var received_data = null
	game_feel_flow.listen("test_event", func(data): received_data = data)
	game_feel_flow.emit("test_event", {"key": "value"})
	assert_that(received_data).is_equal({"key": "value"})

func test_listen_event() -> void:
	var call_count = 0
	var callback = func(data): call_count += 1
	game_feel_flow.listen("test_event", callback)
	game_feel_flow.emit("test_event")
	assert_int(call_count).is_equal(1)
	game_feel_flow.unlisten("test_event", callback)

func test_unlisten_event() -> void:
	var call_count = 0
	var callback = func(data): call_count += 1
	game_feel_flow.listen("test_event", callback)
	game_feel_flow.unlisten("test_event", callback)
	game_feel_flow.emit("test_event")
	assert_int(call_count).is_equal(0)

func test_multiple_listeners() -> void:
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
	game_feel_flow.emit("nonexistent_event")

# ===== 信号发射测试 =====

func test_play_emits_effect_started() -> void:
	var received_name = ""
	game_feel_flow.effect_started.connect(func(name): received_name = name)
	var feedback = MockFeedback.new()
	game_feel_flow.register_effect("test_effect", feedback)
	game_feel_flow.play("test_effect", target)
	assert_that(received_name).is_equal("test_effect")

