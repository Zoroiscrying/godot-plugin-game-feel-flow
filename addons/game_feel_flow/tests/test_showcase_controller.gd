# addons/game_feel_flow/tests/test_showcase_controller.gd
class_name TestShowcaseController
extends GdUnitTestSuite

const __source = "res://addons/game_feel_flow/examples/components/gff_showcase_controller.gd"

var _starts: Array[String] = []
var _stops: Array[String] = []

func _make_shot(id: String, title: String) -> Dictionary:
	return {
		"id": id,
		"title": title,
		"start": func() -> void: _starts.append(id),
		"stop": func() -> void: _stops.append(id),
	}

func before_test() -> void:
	_starts.clear()
	_stops.clear()

func test_next_stops_previous_and_starts_next() -> void:
	var c: GFFShowcaseController = auto_free(GFFShowcaseController.new())
	c.set_shots([_make_shot("a", "A"), _make_shot("b", "B")])
	c.play_current()
	assert_array(_starts).contains_exactly(["a"])
	c.next_shot()
	assert_array(_stops).contains_exactly(["a"])
	assert_array(_starts).contains_exactly(["a", "b"])

func test_replay_restarts_same_shot() -> void:
	var c: GFFShowcaseController = auto_free(GFFShowcaseController.new())
	c.set_shots([_make_shot("a", "A")])
	c.play_current()
	c.replay()
	assert_array(_stops).contains_exactly(["a"])
	assert_array(_starts).contains_exactly(["a", "a"])

func test_loop_flag_defaults_true() -> void:
	var c: GFFShowcaseController = auto_free(GFFShowcaseController.new())
	assert_bool(c.loop_enabled).is_true()

func test_does_not_auto_advance_on_play() -> void:
	## play_current must not call next_shot / must stay on index 0
	var c: GFFShowcaseController = auto_free(GFFShowcaseController.new())
	c.set_shots([_make_shot("a", "A"), _make_shot("b", "B")])
	c.play_current()
	assert_int(c.current_index).is_equal(0)
