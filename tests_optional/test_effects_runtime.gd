extends GdUnitTestSuite

## 效果运行时测试
## 测试效果在不同节点类型上的行为

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

# ===== Color 效果测试 =====

func test_color_effect_on_2d() -> void:
	## 测试Color效果在2D节点上使用modulate
	var effect = GFFColor.new()
	effect.duration = 0.1
	
	var original_modulate = target_2d.modulate
	await effect.apply(target_2d)
	# 效果应该正常执行，不报错
	assert_bool(effect.is_playing()).is_false()

func test_color_effect_on_3d() -> void:
	## 测试Color效果在3D节点上使用材质颜色
	var effect = GFFColor.new()
	effect.duration = 0.1
	
	# 3D节点需要有MeshInstance3D子节点或本身是MeshInstance3D
	await effect.apply(target_3d)
	# 效果应该正常执行，不报错
	assert_bool(effect.is_playing()).is_false()

func test_color_effect_on_control() -> void:
	## 测试Color效果在Control节点上使用modulate
	var effect = GFFColor.new()
	effect.duration = 0.1
	
	var original_modulate = target_control.modulate
	await effect.apply(target_control)
	# 效果应该正常执行，不报错
	assert_bool(effect.is_playing()).is_false()

# ===== Flash 效果测试 =====

func test_flash_effect_on_2d() -> void:
	## 测试Flash效果在2D节点上
	var effect = GFFFlash.new()
	effect.duration = 0.1
	
	await effect.apply(target_2d)
	assert_bool(effect.is_playing()).is_false()

func test_flash_effect_on_3d() -> void:
	## 测试Flash效果在3D节点上
	var effect = GFFFlash.new()
	effect.duration = 0.1
	
	await effect.apply(target_3d)
	assert_bool(effect.is_playing()).is_false()

func test_flash_effect_on_control() -> void:
	## 测试Flash效果在Control节点上
	var effect = GFFFlash.new()
	effect.duration = 0.1
	
	await effect.apply(target_control)
	assert_bool(effect.is_playing()).is_false()

# ===== Scale 效果测试 =====

func test_scale_effect_on_2d() -> void:
	## 测试Scale效果在2D节点上
	var effect = GFFScale.new()
	effect.duration = 0.1
	
	var original_scale = target_2d.scale
	await effect.apply(target_2d)
	assert_bool(effect.is_playing()).is_false()

func test_scale_effect_on_3d() -> void:
	## 测试Scale效果在3D节点上
	var effect = GFFScale.new()
	effect.duration = 0.1
	
	var original_scale = target_3d.scale
	await effect.apply(target_3d)
	assert_bool(effect.is_playing()).is_false()

func test_scale_effect_on_control() -> void:
	## 测试Scale效果在Control节点上
	var effect = GFFScale.new()
	effect.duration = 0.1
	
	var original_scale = target_control.scale
	await effect.apply(target_control)
	assert_bool(effect.is_playing()).is_false()

# ===== Shake 效果测试 =====

func test_shake_effect_on_2d() -> void:
	## 测试Shake效果在2D节点上
	var effect = GFFShake.new()
	effect.duration = 0.1
	
	var original_pos = target_2d.position
	await effect.apply(target_2d)
	assert_bool(effect.is_playing()).is_false()
	# 位置应该恢复
	assert_that(target_2d.position).is_equal(original_pos)

func test_shake_effect_on_3d() -> void:
	## 测试Shake效果在3D节点上
	var effect = GFFShake.new()
	effect.duration = 0.1
	
	var original_pos = target_3d.position
	await effect.apply(target_3d)
	assert_bool(effect.is_playing()).is_false()
	# 位置应该恢复
	assert_that(target_3d.position).is_equal(original_pos)

func test_shake_effect_on_control() -> void:
	## 测试Shake效果在Control节点上
	var effect = GFFShake.new()
	effect.duration = 0.1
	
	var original_pos = target_control.position
	await effect.apply(target_control)
	assert_bool(effect.is_playing()).is_false()
	# 位置应该恢复
	assert_that(target_control.position).is_equal(original_pos)

# ===== Alpha 效果测试 =====

func test_alpha_effect_on_2d() -> void:
	## 测试Alpha效果在2D节点上
	var effect = GFFAlpha.new()
	effect.duration = 0.1
	
	await effect.apply(target_2d)
	assert_bool(effect.is_playing()).is_false()

func test_alpha_effect_on_control() -> void:
	## 测试Alpha效果在Control节点上
	var effect = GFFAlpha.new()
	effect.duration = 0.1
	
	await effect.apply(target_control)
	assert_bool(effect.is_playing()).is_false()

# ===== FreezeFrame 效果测试 =====

func test_freeze_frame_effect() -> void:
	## 测试FreezeFrame效果
	var effect = GFFFreezeFrame.new()
	effect.duration = 0.05
	
	var original_time_scale = Engine.time_scale
	await effect.apply(target_2d)
	assert_bool(effect.is_playing()).is_false()
	# 时间缩放应该恢复
	assert_that(Engine.time_scale).is_equal(original_time_scale)

# ===== GameFeelFlow 集成测试 =====

func test_game_feel_flow_play_on_2d() -> void:
	## 测试通过GameFeelFlow播放效果到2D节点
	await GameFeelFlow.play("shake", target_2d, GFFParams.create(1.0, 0.1))
	# 应该正常执行，不报错

func test_game_feel_flow_play_on_3d() -> void:
	## 测试通过GameFeelFlow播放效果到3D节点
	await GameFeelFlow.play("shake", target_3d, GFFParams.create(1.0, 0.1))
	# 应该正常执行，不报错

func test_game_feel_flow_play_combo_on_2d() -> void:
	## 测试通过GameFeelFlow播放组合效果到2D节点
	await GameFeelFlow.play_combo("hit_light", target_2d)
	# 应该正常执行，不报错

func test_game_feel_flow_play_combo_on_3d() -> void:
	## 测试通过GameFeelFlow播放组合效果到3D节点
	await GameFeelFlow.play_combo("hit_light", target_3d)
	# 应该正常执行，不报错

# ===== 参数传递测试 =====

func test_effect_with_custom_params() -> void:
	## 测试自定义参数
	var effect = GFFShake.new()
	effect.duration = 0.1
	
	var params = GFFParams.create(2.0, 0.2)
	params.with_float("amplitude", 20.0)
	
	await effect.apply(target_2d, params)
	assert_bool(effect.is_playing()).is_false()

func test_effect_with_curve() -> void:
	## 测试带曲线的效果
	var effect = GFFShake.new()
	effect.duration = 0.1
	effect.attenuation_curve = Curve.new()
	effect.attenuation_curve.add_point(Vector2(0, 1))
	effect.attenuation_curve.add_point(Vector2(1, 0))
	
	await effect.apply(target_2d)
	assert_bool(effect.is_playing()).is_false()

# ===== 恢复机制测试 =====

func test_effect_restore_after_play() -> void:
	## 测试效果播放后恢复
	var effect = GFFShake.new()
	effect.duration = 0.1
	effect.restore_after_play = true
	
	var original_pos = target_2d.position
	await effect.apply(target_2d)
	assert_that(target_2d.position).is_equal(original_pos)

func test_effect_no_restore() -> void:
	## 测试效果不恢复
	var effect = GFFScale.new()
	effect.duration = 0.1
	effect.restore_after_play = false
	
	await effect.apply(target_2d)
	# 位置可能改变，但不应该报错

# ===== 叠加策略测试 =====

func test_overlap_replace() -> void:
	## 测试替换策略
	var effect = GFFShake.new()
	effect.duration = 0.1
	effect.overlap_strategy = GFFFeedback.OverlapStrategy.REPLACE
	
	# 同时播放两次
	effect.apply(target_2d)
	await effect.apply(target_2d)
	assert_bool(effect.is_playing()).is_false()
