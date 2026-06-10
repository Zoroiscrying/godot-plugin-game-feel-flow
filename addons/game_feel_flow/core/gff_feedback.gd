class_name GFFFeedback
extends Resource

## Game Feel Flow Feedback Base

# ===== Overlap Strategy =====
enum OverlapStrategy {
    ADD,
    REPLACE,
    QUEUE,
    IGNORE,
    CANCEL
}

# ===== Properties =====
@export var enabled: bool = true
@export var label: String = ""
@export var priority: int = 0
@export var overlap_strategy: OverlapStrategy = OverlapStrategy.ADD

# ===== Default Parameters =====
@export_group("Default Parameters")
@export var default_intensity: float = 1.0
@export var default_duration: float = 0.2
@export var default_delay: float = 0.0

# ===== Signals =====
signal started
signal finished

# ===== State =====
var _is_playing: bool = false

# ===== Public Methods =====

func apply(target: Node, params = null) -> void:
    if not enabled:
        return
    _is_playing = true
    started.emit()
    await _execute(target, params)
    _is_playing = false
    finished.emit()

func stop() -> void:
    _is_playing = false

func is_playing() -> bool:
    return _is_playing

# ===== Virtual Methods =====

func _execute(target: Node, params) -> void:
    push_error("_execute() not implemented")

# ===== Helper Methods =====

func _get_intensity(params) -> float:
    if params is float or params is int:
        return params
    elif params is RefCounted or params is Resource:
        if params.has_method("get_float"):
            return params.get_float("intensity", default_intensity)
    return default_intensity

func _get_duration(params) -> float:
    if params is float or params is int:
        return params
    elif params is RefCounted or params is Resource:
        if params.has_method("get_float"):
            return params.get_float("duration", default_duration)
    return default_duration

func _get_delay(params) -> float:
    if params is RefCounted or params is Resource:
        if params.has_method("get_float"):
            return params.get_float("delay", default_delay)
    return default_delay
