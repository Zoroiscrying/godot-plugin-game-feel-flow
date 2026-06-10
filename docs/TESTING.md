# Game Feel Flow Testing Guide

This document describes how to write and run unit tests for the Game Feel Flow plugin.

---

## Testing Framework

Game Feel Flow uses [GdUnit4](https://github.com/MikeSchulze/gdUnit4) as the unit testing framework.

### Installing GdUnit4

#### Method 1: Git Clone

```bash
cd addons
git clone https://github.com/MikeSchulze/gdUnit4.git
cd gdUnit4
git checkout v4.2.0
```

#### Method 2: Godot Asset Library

In Godot editor:
1. Open AssetLib tab
2. Search for "GdUnit4"
3. Download and install

---

## Test Directory Structure

```
tests_optional/
├── test_gff_params.gd           # GFFParams tests
├── test_gff_feedback.gd         # GFFFeedback tests
├── test_gff_feedback_stack.gd   # GFFFeedbackStack tests
├── test_gff_player.gd           # GFFPlayer tests
├── test_gff_combo.gd            # GFFCombo tests
├── test_game_feel_flow.gd       # GameFeelFlow tests
└── test_gff_shake.gd            # GFFShake tests
```

---

## Writing Tests

### Test Class Structure

```gdscript
extends GdUnitTestSuite

# Test fixture
var my_object: MyClass

func before_test() -> void:
    # Execute before each test
    my_object = MyClass.new()

func after_test() -> void:
    # Execute after each test
    my_object.free()

# Test method
func test_my_method() -> void:
    # Test logic
    var result = my_object.my_method()
    assert_that(result).is_equal(expected_value)
```

### Test Naming Conventions

- Test methods start with `test_`
- Use descriptive names: `test_create_with_params`, `test_play_calls_effects`
- Use underscores to separate words

### Common Assertions

```gdscript
# Equality assertions
assert_that(value).is_equal(expected)
assert_int(value).is_equal(expected)
assert_float(value).is_equal(expected)
assert_str(value).is_equal(expected)
assert_bool(value).is_true()
assert_bool(value).is_false()

# Collection assertions
assert_array(array).is_empty()
assert_array(array).has_size(expected)
assert_array(array).contains(element)
assert_array(array).is_equal(expected)

# Object assertions
assert_object(object).is_null()
assert_object(object).is_not_null()
assert_object(object).is_same(expected)
assert_object(object).is_not_same(expected)

# Signal assertions
assert_signal(object).is_emitted("signal_name")
assert_signal(object).is_not_emitted("signal_name")

# Type assertions
assert_vector2(vec).is_equal(expected)
assert_vector3(vec).is_equal(expected)
assert_color(color).is_equal(expected)
```

---

## Test Examples

### Testing GFFParams

```gdscript
extends GdUnitTestSuite

var params: GFFParams

func before_test() -> void:
    params = GFFParams.create()

func after_test() -> void:
    params = null

func test_create_default() -> void:
    var p = GFFParams.create()
    assert_float(p.intensity).is_equal(1.0)
    assert_float(p.duration).is_equal(-1.0)

func test_with_float() -> void:
    params.with_float("amplitude", 10.0)
    assert_float(params.get_float("amplitude")).is_equal(10.0)

func test_chain_calls() -> void:
    var result = params \
        .with_float("amplitude", 10.0) \
        .with_color("color", Color.RED)
    
    assert_float(result.get_float("amplitude")).is_equal(10.0)
    assert_color(result.get_color("color")).is_equal(Color.RED)
    assert_object(result).is_same(params)
```

### Testing GFFFeedback

```gdscript
extends GdUnitTestSuite

class TestFeedback:
    extends GFFFeedback
    
    var execute_count: int = 0
    
    func _execute(target: Node, params: GFFParams) -> void:
        execute_count += 1

var feedback: TestFeedback
var target: Node

func before_test() -> void:
    feedback = TestFeedback.new()
    target = Node.new()

func after_test() -> void:
    feedback.free()
    target.free()

func test_apply_calls_execute() -> void:
    await feedback.apply(target)
    assert_int(feedback.execute_count).is_equal(1)

func test_apply_not_execute_when_disabled() -> void:
    feedback.enabled = false
    await feedback.apply(target)
    assert_int(feedback.execute_count).is_equal(0)
```

### Testing GFFPlayer

```gdscript
extends GdUnitTestSuite

class MockFeedback:
    extends GFFFeedback
    
    var execute_count: int = 0
    
    func _execute(target: Node, params: GFFParams) -> void:
        execute_count += 1

var player: GFFPlayer
var target: Node

func before_test() -> void:
    target = Node.new()
    player = GFFPlayer.new()
    target.add_child(player)

func after_test() -> void:
    player.free()
    target.free()

func test_play_with_feedback() -> void:
    var feedback = MockFeedback.new()
    await player.play(feedback)
    assert_int(feedback.execute_count).is_equal(1)
    feedback.free()

func test_play_with_dict_params() -> void:
    var feedback = MockFeedback.new()
    await player.play(feedback, {"intensity": 2.0})
    assert_int(feedback.execute_count).is_equal(1)
    feedback.free()
```

---

## Running Tests

### Method 1: GdUnit4 Editor Plugin

1. Open the project in Godot editor
2. Open GdUnit4 panel (usually at the bottom)
3. Click "Run All" to run all tests
4. Or right-click on a single test file to run it

### Method 2: Command Line

```bash
# Run all tests
godot --headless --script res://addons/gdUnit4/bin/GdUnitCmdTool.gd -- --add "res://tests_optional/"

# Run a single test file
godot --headless --script res://addons/gdUnit4/bin/GdUnitCmdTool.gd -- --add "res://tests_optional/test_gff_params.gd"

# Generate XML report
godot --headless --script res://addons/gdUnit4/bin/GdUnitCmdTool.gd -- --add "res://tests_optional/" --report-xml
```

### Method 3: Script

```bash
# Linux/macOS
./run_tests.sh

# Windows
run_tests.bat
```

---

## Test Coverage

Current test coverage for core components:

| Component | Test File | Status |
|-----------|-----------|--------|
| GFFParams | test_gff_params.gd | ✅ Complete |
| GFFFeedback | test_gff_feedback.gd | ✅ Complete |
| GFFFeedbackStack | test_gff_feedback_stack.gd | ✅ Complete |
| GFFPlayer | test_gff_player.gd | ✅ Complete |
| GFFCombo | test_gff_combo.gd | ✅ Complete |
| GameFeelFlow | test_game_feel_flow.gd | ✅ Complete |
| GFFShake | test_gff_shake.gd | ✅ Complete |

---

## Best Practices

### 1. Test Isolation

Each test should be independent and not rely on other test states:

```gdscript
func before_test() -> void:
    # Initialize test objects
    my_object = MyClass.new()

func after_test() -> void:
    # Clean up resources
    my_object.free()
```

### 2. Test Naming

Use descriptive test names:

```gdscript
# ❌ Bad
func test_1() -> void:

# ✅ Good
func test_create_with_params() -> void:
func test_play_calls_effects() -> void:
func test_stop_when_playing() -> void:
```

### 3. Test Boundary Conditions

```gdscript
func test_empty_array() -> void:
    assert_array([]).is_empty()

func test_null_value() -> void:
    assert_object(null).is_null()

func test_negative_value() -> void:
    var result = my_function(-1)
    assert_that(result).is_equal(expected)
```

### 4. Test Asynchronous Operations

```gdscript
func test_async_operation() -> void:
    await my_async_function()
    assert_that(result).is_equal(expected)
```

### 5. Use Mock Objects

```gdscript
class MockService:
    extends MyService
    
    var call_count: int = 0
    var last_args: Array = []
    
    func my_method(args) -> void:
        call_count += 1
        last_args.append(args)

func test_with_mock() -> void:
    var mock = MockService.new()
    var system = MySystem.new(mock)
    
    system.do_something()
    
    assert_int(mock.call_count).is_equal(1)
    mock.free()
```

---

## Troubleshooting

### Test Failures

1. **Check initialization**: Ensure `before_test()` correctly initializes
2. **Check cleanup**: Ensure `after_test()` correctly releases resources
3. **Check async**: Ensure `await` is used for async operations

### Slow Tests

1. **Reduce wait times**: Use shorter test durations
2. **Simplify test data**: Use simpler test objects
3. **Avoid repetition**: Use parameterized tests

### Memory Leaks

1. **Release resources**: Release all created objects in `after_test()`
2. **Check child nodes**: Ensure child nodes are also released
3. **Use weak references**: For temporary references

---

## CI/CD Integration

### GitHub Actions

```yaml
name: Run Tests

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Godot
        uses: chickensoft-games/setup-godot@v1
        with:
          version: 4.2.0
          
      - name: Run Tests
        run: |
          godot --headless --script res://addons/gdUnit4/bin/GdUnitCmdTool.gd -- --add "res://tests_optional/" --report-xml
          
      - name: Upload Test Results
        uses: actions/upload-artifact@v3
        if: always()
        with:
          name: test-results
          path: reports/
```

---

## References

- [GdUnit4 Official Documentation](https://mikeschulze.github.io/gdUnit4/)
- [GdUnit4 GitHub](https://github.com/MikeSchulze/gdUnit4)
- [Godot Testing Best Practices](https://docs.godotengine.org/en/stable/tutorials/best_practices/)
