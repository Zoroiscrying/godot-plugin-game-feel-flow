extends GdUnitTestSuite

## GFFFeedback 单元测试

# 测试用的反馈实现
class TestFeedback:
	extends GFFFeedback

	var execute_count: int = 0
	var last_node: Node = null
	var last_params: GFFParams = null
	var was_playing_on_execute: bool = false

	func _execute(node: Node, params: GFFParams) -> void:
		was_playing_on_execute = _is_playing
		execute_count += 1
		last_node = node
		last_params = params

	func _get_default_intensity() -> float:
		return 1.0

# 测试夹具
var feedback: TestFeedback
var target: Node2D

func before_test() -> void:
	feedback = TestFeedback.new()
	target = Node2D.new()

func after_test() -> void:
	feedback.free()
	target.free()

# ===== 基础属性测试 =====

func test_default_enabled() -> void:
	assert_bool(feedback.enabled).is_true()

func test_default_label() -> void:
	assert_str(feedback.label).is_empty()

func test_default_priority() -> void:
	assert_int(feedback.priority).is_equal(0)

func test_default_overlap_strategy() -> void:
	assert_int(feedback.overlap_strategy).is_equal(GFFFeedback.OverlapStrategy.REPLACE)

# ===== 时间控制测试 =====

func test_default_duration() -> void:
	assert_float(feedback.duration).is_equal(0.2)

func test_default_delay() -> void:
	assert_float(feedback.delay).is_equal(0.0)

func test_default_cooldown() -> void:
	assert_float(feedback.cooldown).is_equal(0.0)

# ===== 恢复控制测试 =====

func test_default_restore_after_play() -> void:
	assert_bool(feedback.restore_after_play).is_true()

# ===== 随机性测试 =====

func test_default_random_duration() -> void:
	assert_float(feedback.random_duration_min).is_equal(1.0)
	assert_float(feedback.random_duration_max).is_equal(1.0)

func test_default_random_intensity() -> void:
	assert_float(feedback.random_intensity_min).is_equal(1.0)
	assert_float(feedback.random_intensity_max).is_equal(1.0)

# ===== 曲线测试 =====

func test_default_easing_curve() -> void:
	assert_object(feedback.easing_curve).is_null()

# ===== 状态测试 =====

func test_initial_state() -> void:
	assert_bool(feedback.is_playing()).is_false()

func test_initial_state_dict_empty() -> void:
	assert_that(feedback._initial_state.size()).is_equal(0)

func test_last_play_time_zero() -> void:
	assert_float(feedback._last_play_time).is_equal(0.0)

# ===== 应用测试 =====

func test_apply_calls_execute() -> void:
	await feedback.apply(target)
	assert_int(feedback.execute_count).is_equal(1)

func test_apply_with_params() -> void:
	var params = GFFParams.create(2.0, 0.5)
	await feedback.apply(target, params)
	assert_int(feedback.execute_count).is_equal(1)
	assert_float(feedback.last_params.intensity).is_equal(2.0)

func test_apply_sets_resolved_node() -> void:
	await feedback.apply(target)
	assert_object(feedback.last_node).is_same(target)

func test_apply_emits_started_signal() -> void:
	var signal_received = false
	feedback.started.connect(func(): signal_received = true)
	await feedback.apply(target)
	assert_bool(signal_received).is_true()

func test_apply_emits_finished_signal() -> void:
	var signal_received = false
	feedback.finished.connect(func(): signal_received = true)
	await feedback.apply(target)
	assert_bool(signal_received).is_true()

func test_apply_sets_playing_state() -> void:
	await feedback.apply(target)
	assert_bool(feedback.was_playing_on_execute).is_true()
	assert_bool(feedback.is_playing()).is_false()

func test_apply_not_execute_when_disabled() -> void:
	feedback.enabled = false
	await feedback.apply(target)
	assert_int(feedback.execute_count).is_equal(0)

func test_apply_updates_last_play_time() -> void:
	await feedback.apply(target)
	assert_float(feedback._last_play_time).is_greater(0.0)

# ===== 停止测试 =====

func test_stop() -> void:
	feedback._is_playing = true
	feedback.stop()
	assert_bool(feedback.is_playing()).is_false()

# ===== 解析目标测试 =====

func test_resolve_target_node2d() -> void:
	var resolved = feedback._resolve_target(target)
	assert_object(resolved).is_same(target)

func test_resolve_target_control() -> void:
	var control = Control.new()
	var resolved = feedback._resolve_target(target)
	add_child(control)
	assert_object(feedback._resolve_target(control)).is_same(control)
	control.free()

func test_resolve_target_parent_finds_child() -> void:
	var parent = Node.new()
	var child = Node2D.new()
	parent.add_child(child)
	add_child(parent)
	var resolved = feedback._resolve_target(parent)
	assert_object(resolved).is_same(child)
	parent.free()

func test_resolve_target_returns_null_for_plain_node() -> void:
	var plain = Node.new()
	add_child(plain)
	var resolved = feedback._resolve_target(plain)
	assert_object(resolved).is_null()
	plain.free()

# ===== 参数获取测试 =====

func test_get_intensity_with_params() -> void:
	var params = GFFParams.create(2.0)
	assert_float(feedback._get_intensity(params)).is_equal(2.0)

func test_get_intensity_without_params() -> void:
	assert_float(feedback._get_intensity(null)).is_equal(1.0)

func test_get_duration_param_with_params() -> void:
	var params = GFFParams.create(1.0, 0.5)
	assert_float(feedback._get_duration_param(params)).is_equal(0.5)

func test_get_duration_param_without_params() -> void:
	assert_float(feedback._get_duration_param(null)).is_equal(0.2)

# ===== 最终参数创建测试 =====

func test_create_final_params() -> void:
	var params = GFFParams.create(1.0, 0.5)
	params.with_float("amplitude", 10.0)
	var final = feedback._create_final_params(params, 2.0, 0.3)
	assert_float(final.intensity).is_equal(2.0)
	assert_float(final.duration).is_equal(0.3)
	assert_float(final.get_float("amplitude")).is_equal(10.0)

func test_create_final_params_without_input() -> void:
	var final = feedback._create_final_params(null, 1.5, 0.4)
	assert_float(final.intensity).is_equal(1.5)
	assert_float(final.duration).is_equal(0.4)

# ===== 曲线应用测试 =====

func test_apply_curve_with_null() -> void:
	assert_float(feedback._apply_curve(0.5, null)).is_equal(0.5)

func test_apply_curve_with_curve() -> void:
	var curve = Curve.new()
	curve.add_point(Vector2(0, 0))
	curve.add_point(Vector2(1, 1))
	var result = feedback._apply_curve(0.5, curve)
	assert_float(result).is_equal(0.5)

# ===== 初始状态保存恢复测试 =====

func test_save_initial_state() -> void:
	target.position = Vector2(10, 20)
	target.rotation = 0.5
	target.scale = Vector2(2, 2)
	target.modulate = Color.RED
	feedback._save_initial_state(target)
	assert_that(feedback._initial_state.size()).is_greater(0)
	assert_vector2(feedback._initial_state["position"]).is_equal(Vector2(10, 20))
	assert_float(feedback._initial_state["rotation"]).is_equal(0.5)
	assert_vector2(feedback._initial_state["scale"]).is_equal(Vector2(2, 2))
	assert_color(feedback._initial_state["modulate"]).is_equal(Color.RED)

func test_restore_initial_state() -> void:
	target.position = Vector2(10, 20)
	target.rotation = 0.5
	target.scale = Vector2(2, 2)
	target.modulate = Color.RED
	feedback._save_initial_state(target)
	target.position = Vector2(99, 99)
	target.rotation = 1.0
	target.scale = Vector2(5, 5)
	target.modulate = Color.BLUE
	feedback._restore_initial_state(target)
	assert_vector2(target.position).is_equal(Vector2(10, 20))
	assert_float(target.rotation).is_equal(0.5)
	assert_vector2(target.scale).is_equal(Vector2(2, 2))
	assert_color(target.modulate).is_equal(Color.RED)

func test_restore_empty_state_does_nothing() -> void:
	var orig_pos = target.position
	feedback._restore_initial_state(target)
	assert_vector2(target.position).is_equal(orig_pos)

# ===== 节点操作测试 =====

func test_get_set_position_node2d() -> void:
	var pos = Vector2(10, 20)
	feedback._set_position(target, pos)
	assert_vector2(feedback._get_position(target)).is_equal(pos)

func test_get_set_rotation_node2d() -> void:
	feedback._set_rotation(target, 0.5)
	assert_float(feedback._get_rotation(target)).is_equal(0.5)

func test_get_set_scale_node2d() -> void:
	var s = Vector2(2, 3)
	feedback._set_scale(target, s)
	assert_vector2(feedback._get_scale(target)).is_equal(s)

func test_get_set_modulate_node2d() -> void:
	var c = Color.RED
	feedback._set_modulate(target, c)
	assert_color(feedback._get_modulate(target)).is_equal(c)

func test_get_position_plain_node_returns_zero() -> void:
	var plain = Node.new()
	assert_vector2(feedback._get_position(plain)).is_equal(Vector2.ZERO)
	plain.free()

func test_get_rotation_plain_node_returns_zero() -> void:
	var plain = Node.new()
	assert_float(feedback._get_rotation(plain)).is_equal(0.0)
	plain.free()

func test_get_scale_plain_node_returns_one() -> void:
	var plain = Node.new()
	assert_vector2(feedback._get_scale(plain)).is_equal(Vector2.ONE)
	plain.free()

func test_get_modulate_plain_node_returns_white() -> void:
	var plain = Node.new()
	assert_color(feedback._get_modulate(plain)).is_equal(Color.WHITE)
	plain.free()

# ===== 冷却时间测试 =====

func test_cooldown_blocks_rapid_apply() -> void:
	feedback.cooldown = 10.0
	await feedback.apply(target)
	assert_int(feedback.execute_count).is_equal(1)
	await feedback.apply(target)
	assert_int(feedback.execute_count).is_equal(1)
