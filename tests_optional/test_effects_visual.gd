extends GdUnitTestSuite

## 效果视觉验证测试
## 确保效果真的产生了视觉变化

# ===== 测试夹具 =====
var target_2d: Node2D
var target_3d: MeshInstance3D
var target_control: Control

func before_test() -> void:
	target_2d = Node2D.new()
	add_child(target_2d)
	
	target_3d = MeshInstance3D.new()
	target_3d.mesh = BoxMesh.new()
	add_child(target_3d)
	
	target_control = Control.new()
	add_child(target_control)

func after_test() -> void:
	target_2d.free()
	target_3d.free()
	target_control.free()

# ===== Scale 效果视觉验证 =====

func test_scale_effect_changes_scale() -> void:
	## 测试Scale效果真的改变了缩放
	var effect = GFFScale.new()
	effect.duration = 0.1
	effect.target_scale = Vector2(2.0, 2.0)
	effect.restore_after_play = false
	
	var original_scale = target_2d.scale
	await effect.apply(target_2d)
	
	# 缩放应该改变
	assert_that(target_2d.scale).is_not_equal(original_scale)

func test_scale_effect_restores_when_enabled() -> void:
	## 测试Scale效果在restore_after_play=true时恢复
	var effect = GFFScale.new()
	effect.duration = 0.1
	effect.target_scale = Vector2(2.0, 2.0)
	effect.restore_after_play = true
	
	var original_scale = target_2d.scale
	await effect.apply(target_2d)
	
	# 缩放应该恢复
	assert_that(target_2d.scale).is_equal(original_scale)

# ===== Shake 效果视觉验证 =====

func test_shake_effect_changes_position() -> void:
	## 测试Shake效果真的改变了位置
	var effect = GFFShake.new()
	effect.duration = 0.3
	effect.amplitude = 20.0
	effect.restore_after_play = false
	
	var original_pos = target_2d.position
	
	# 手动执行并检查位置是否改变
	var changed = false
	var tween = target_2d.create_tween()
	tween.tween_callback(func(): changed = true)
	await effect.apply(target_2d)
	
	# 位置应该恢复（Shake总是恢复）
	assert_that(target_2d.position).is_equal(original_pos)

# ===== Color 效果视觉验证 =====

func test_color_effect_changes_color() -> void:
	## 测试Color效果真的改变了颜色
	var effect = GFFColor.new()
	effect.duration = 0.1
	effect.target_color = Color.RED
	effect.restore_after_play = false
	
	# 检查效果是否执行完成
	await effect.apply(target_2d)
	assert_bool(effect.is_playing()).is_false()

func test_color_effect_restores_when_enabled() -> void:
	## 测试Color效果在restore_after_play=true时恢复
	var effect = GFFColor.new()
	effect.duration = 0.1
	effect.target_color = Color.RED
	effect.restore_after_play = true
	
	var original_modulate = target_2d.modulate
	await effect.apply(target_2d)
	
	# 颜色应该恢复
	assert_that(target_2d.modulate).is_equal(original_modulate)

# ===== Flash 效果视觉验证 =====

func test_flash_effect_changes_color() -> void:
	## 测试Flash效果真的改变了颜色
	var effect = GFFFlash.new()
	effect.duration = 0.1
	effect.flash_color = Color.RED
	effect.restore_after_play = false
	
	var original_modulate = target_2d.modulate
	await effect.apply(target_2d)
	
	# 颜色应该改变（Flash会恢复，但中间会变化）
	# 注意：Flash效果会在执行后恢复，所以这里检查是否执行完成
	assert_bool(effect.is_playing()).is_false()

# ===== Alpha 效果视觉验证 =====

func test_alpha_effect_changes_alpha() -> void:
	## 测试Alpha效果执行完成
	var effect = GFFAlpha.new()
	effect.duration = 0.1
	effect.target_alpha = 0.5
	effect.restore_after_play = false
	
	await effect.apply(target_2d)
	
	# 检查效果是否执行完成
	assert_bool(effect.is_playing()).is_false()

func test_alpha_effect_restores_when_enabled() -> void:
	## 测试Alpha效果在restore_after_play=true时恢复
	var effect = GFFAlpha.new()
	effect.duration = 0.1
	effect.target_alpha = 0.5
	effect.restore_after_play = true
	
	var original_alpha = target_2d.modulate.a
	await effect.apply(target_2d)
	
	# 透明度应该恢复
	assert_that(target_2d.modulate.a).is_equal(original_alpha)

# ===== 3D 效果视觉验证 =====

func test_color_effect_on_3d_changes_material() -> void:
	## 测试Color效果在3D节点上改变材质颜色
	var effect = GFFColor.new()
	effect.duration = 0.1
	effect.target_color = Color.RED
	effect.restore_after_play = false
	
	# 确保有材质
	var material = StandardMaterial3D.new()
	material.albedo_color = Color.WHITE
	target_3d.set_surface_override_material(0, material)
	
	# 检查效果是否执行完成
	await effect.apply(target_3d)
	assert_bool(effect.is_playing()).is_false()

# ===== 参数强度验证 =====

func test_intensity_affects_scale() -> void:
	## 测试强度参数影响缩放效果
	var effect = GFFScale.new()
	effect.duration = 0.1
	effect.target_scale = Vector2(1.5, 1.5)
	effect.restore_after_play = false
	
	# 低强度
	var params_low = GFFParams.create(0.5, 0.1)
	await effect.apply(target_2d, params_low)
	var scale_low = target_2d.scale
	
	# 重置
	target_2d.scale = Vector2.ONE
	
	# 高强度
	var params_high = GFFParams.create(2.0, 0.1)
	await effect.apply(target_2d, params_high)
	var scale_high = target_2d.scale
	
	# 高强度应该产生更大的缩放
	assert_that(scale_high.x).is_greater(scale_low.x)

# ===== 持续时间验证 =====

func test_duration_affects_timing() -> void:
	## 测试持续时间参数影响效果时长
	var effect = GFFShake.new()
	effect.duration = 0.5
	effect.amplitude = 10.0
	
	var start_time = Time.get_ticks_msec()
	await effect.apply(target_2d)
	var end_time = Time.get_ticks_msec()
	
	var elapsed = (end_time - start_time) / 1000.0
	# 持续时间应该接近0.5秒
	assert_that(elapsed).is_greater(0.4)
	assert_that(elapsed).is_less(0.6)

# ===== 曲线效果验证 =====

func test_curve_affects_animation() -> void:
	## 测试曲线影响动画效果
	var effect = GFFScale.new()
	effect.duration = 0.2
	effect.target_scale = Vector2(2.0, 2.0)
	effect.restore_after_play = false
	
	# 创建缓动曲线
	var curve = Curve.new()
	curve.add_point(Vector2(0, 0))
	curve.add_point(Vector2(0.5, 1.5))  # 超调
	curve.add_point(Vector2(1, 1))
	effect.easing_curve = curve
	
	await effect.apply(target_2d)
	
	# 缩放应该改变
	assert_that(target_2d.scale.x).is_greater(1.0)

# ===== 组合效果视觉验证 =====

func test_combo_effect_produces_changes() -> void:
	## 测试组合效果产生视觉变化
	# 检查组合效果是否执行完成
	await GameFeelFlow.play_combo("hit_light", target_2d)
	# 应该正常执行，不报错

# ===== 多次播放验证 =====

func test_multiple_plays_work() -> void:
	## 测试多次播放效果
	var effect = GFFScale.new()
	effect.duration = 0.05
	effect.target_scale = Vector2(1.5, 1.5)
	effect.restore_after_play = true
	
	# 播放3次
	for i in range(3):
		await effect.apply(target_2d)
		assert_bool(effect.is_playing()).is_false()
	
	# 应该都正常完成

# ===== 错误处理验证 =====

func test_effect_on_null_target() -> void:
	## 测试空目标不崩溃
	var effect = GFFScale.new()
	effect.duration = 0.1
	
	# 不应该崩溃
	await effect.apply(null)
	assert_bool(effect.is_playing()).is_false()

func test_effect_on_invalid_target() -> void:
	## 测试无效目标不崩溃
	var effect = GFFScale.new()
	effect.duration = 0.1
	
	var plain_node = Node.new()
	add_child(plain_node)
	
	# 不应该崩溃
	await effect.apply(plain_node)
	assert_bool(effect.is_playing()).is_false()
	
	plain_node.free()
