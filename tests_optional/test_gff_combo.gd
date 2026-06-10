extends GdUnitTestSuite

## GFFCombo 单元测试

# 测试夹具
var combo: GFFCombo

func before_test() -> void:
	combo = GFFCombo.new()

func after_test() -> void:
	pass

# ===== 基础属性测试 =====

func test_label_default() -> void:
	assert_str(combo.label).is_empty()

func test_empty_effects() -> void:
	assert_array(combo.effects).is_empty()

func test_default_params_null() -> void:
	assert_object(combo.default_params).is_null()

# ===== 静态工厂方法测试 =====

func test_hit_light_combo() -> void:
	var hit_combo = GFFCombo.hit_light()
	assert_object(hit_combo).is_not_null()
	assert_str(hit_combo.label).is_equal("hit_light")
	assert_int(hit_combo.effects.size()).is_equal(3)

func test_hit_heavy_combo() -> void:
	var hit_combo = GFFCombo.hit_heavy()
	assert_object(hit_combo).is_not_null()
	assert_str(hit_combo.label).is_equal("hit_heavy")
	assert_int(hit_combo.effects.size()).is_equal(4)

func test_death_combo() -> void:
	var death_combo = GFFCombo.death()
	assert_object(death_combo).is_not_null()
	assert_str(death_combo.label).is_equal("death")
	assert_int(death_combo.effects.size()).is_equal(5)

func test_pickup_combo() -> void:
	var pickup_combo = GFFCombo.pickup()
	assert_object(pickup_combo).is_not_null()
	assert_str(pickup_combo.label).is_equal("pickup")
	assert_int(pickup_combo.effects.size()).is_equal(2)

func test_explosion_combo() -> void:
	var explosion_combo = GFFCombo.explosion()
	assert_object(explosion_combo).is_not_null()
	assert_str(explosion_combo.label).is_equal("explosion")
	assert_int(explosion_combo.effects.size()).is_equal(4)

func test_hit_light_effects_not_null() -> void:
	var hit_combo = GFFCombo.hit_light()
	for effect in hit_combo.effects:
		assert_object(effect).is_not_null()

func test_death_effects_not_null() -> void:
	var death_combo = GFFCombo.death()
	for effect in death_combo.effects:
		assert_object(effect).is_not_null()

func test_all_combos_unique_labels() -> void:
	var labels = []
	labels.append(GFFCombo.hit_light().label)
	labels.append(GFFCombo.hit_heavy().label)
	labels.append(GFFCombo.death().label)
	labels.append(GFFCombo.pickup().label)
	labels.append(GFFCombo.explosion().label)
	assert_int(labels.size()).is_equal(5)
	# All labels should be unique
	for i in range(labels.size()):
		for j in range(i + 1, labels.size()):
			assert_str(labels[i]).is_not_equal(labels[j])

func test_combo_default_params_null() -> void:
	var hit_combo = GFFCombo.hit_light()
	assert_object(hit_combo.default_params).is_null()
