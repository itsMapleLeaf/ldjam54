@tool
extends CollisionPolygon2D

@export_range(1, 100, 1, "or_greater") var sides := 6:
	set(value):
		sides = value
		_generate_polygon()

@export_range(0, 1000, 1, "or_greater", "or_less", "hide_slider") var radius := 100.0:
	set(value):
		radius = value
		_generate_polygon()

func _ready() -> void:
	_generate_polygon()

func _generate_polygon() -> void:
	var points := PackedVector2Array()
	for i in sides:
		points.append(Vector2.UP.rotated(i / float(sides) * PI * 2.0) * radius)
	polygon = points
