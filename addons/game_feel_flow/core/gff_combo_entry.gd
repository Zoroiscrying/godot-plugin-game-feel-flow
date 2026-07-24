class_name GFFComboEntry
extends Resource

## Game Feel Flow Combo Entry
##
## A single entry on the combo timeline storing effect, time, track, etc.

@export var effect: GFFEffect = null
@export var start_time: float = 0.0   # Time relative to combo start
@export var duration: float = 0.3     # Duration on timeline
@export var track_idx: int = 0        # Track index (0-based)
@export var wait_for_previous: bool = false  # Whether to wait for previous effect to finish
@export var enabled: bool = true
@export var intensity_curve: Curve = null   # Intensity multiplier over normalized block time (0-1)
