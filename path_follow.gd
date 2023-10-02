@tool
extends PathFollow2D

@export_range(0, 10000, 1, "or_greater") var follow_speed_pixels := 100.0
@export_range(0, 10000, 1, "or_greater") var offset_pixels := 0.0
@export var preview := true:
	set(value):
		preview = value
		progress = 0
		
var lifetime := 0.0

func _process(delta: float) -> void:
	if Engine.is_editor_hint() and not preview: return
	lifetime += delta

func _physics_process(_delta: float) -> void:
	if Engine.is_editor_hint() and not preview: return
	progress = offset_pixels + lifetime * follow_speed_pixels
