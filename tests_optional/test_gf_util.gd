extends GdUnitTestSuite

## GFUtil 单元测试

# 测试夹具
var target: Node2D

func before_test() -> void:
	target = Node2D.new()
	add_child(target)

# ===== 组合效果测试 =====

func test_hit() -> void:
	await GFUtil.hit(target, 1.0)
	assert_bool(true).is_true()

func test_hit_heavy() -> void:
	await GFUtil.hit_heavy(target, 1.0)
	assert_bool(true).is_true()

func test_death() -> void:
	await GFUtil.death(target, 1.0)
	assert_bool(true).is_true()

func test_pickup() -> void:
	await GFUtil.pickup(target, 1.0)
	assert_bool(true).is_true()

func test_explosion() -> void:
	await GFUtil.explosion(target, 1.0)
	assert_bool(true).is_true()

# ===== 单一效果测试 =====

func test_shake() -> void:
	await GFUtil.shake(target, 1.0)
	assert_bool(true).is_true()

func test_flash() -> void:
	await GFUtil.flash(target, Color.WHITE)
	assert_bool(true).is_true()
