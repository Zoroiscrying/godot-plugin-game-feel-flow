extends GdUnitTestSuite

## Punch scale combos must use BY_AMOUNT (relative), not absolute TO_TARGET.

const __source := "res://addons/game_feel_flow/core/gff_combo.gd"


#region punch_scale_mode
func test_create_punch_scale_uses_by_amount() -> void:
	var combo := GFFCombo.hit_light()
	var punch_entry: GFFComboEntry = combo.entries[2]
	var effect := punch_entry.effect as GFFEffectCommon
	assert_object(effect).is_not_null()
	var scale_target := effect.target as GFFScaleTarget
	assert_object(scale_target).is_not_null()
	assert_int(scale_target.mode).is_equal(GFFScaleTarget.Mode.BY_AMOUNT)
	assert_that(scale_target.target_value.z).is_equal(0.0)


func test_hit_light_shake_is_pixel_scale() -> void:
	var combo := GFFCombo.hit_light()
	var shake_effect := combo.entries[0].effect as GFFEffectCommon
	var tw := shake_effect.tweener as GFFShakeTweener
	assert_float(tw.amplitude).is_greater(1.0)


func test_pickup_coin_has_hop() -> void:
	var combo := GFFCombo.pickup_coin()
	assert_int(combo.entries.size()).is_equal(3)
#endregion
