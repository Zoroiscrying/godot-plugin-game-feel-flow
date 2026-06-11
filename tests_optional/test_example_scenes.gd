extends GdUnitTestSuite

## 示例场景单元测试

# 测试EffectCard组件
func test_effect_card_set_effect() -> void:
	var card = preload("res://addons/game_feel_flow/examples/components/effect_card.gd").new()
	card.set_effect("Shake", "shake", "simple")
	assert_str(card.effect_name).is_equal("Shake")
	assert_str(card.effect_type).is_equal("shake")
	assert_str(card.complexity).is_equal("simple")

# 测试ParamPanel组件
func test_param_panel_setup() -> void:
	var panel = preload("res://addons/game_feel_flow/examples/components/param_panel.gd").new()
	panel.setup_for_effect("shake")
	assert_str(panel.effect_name).is_equal("shake")

# 测试ParamPanel获取参数
func test_param_panel_get_params() -> void:
	var panel = preload("res://addons/game_feel_flow/examples/components/param_panel.gd").new()
	panel.setup_for_effect("shake")
	var params = panel.get_params()
	assert_object(params).is_not_null()

# 测试CodePreview组件
func test_code_preview_show_code() -> void:
	var preview = preload("res://addons/game_feel_flow/examples/components/code_preview.gd").new()
	assert_str(preview.code_text).is_equal("")
