extends Polygon2D

func _ready() -> void:
	var area := Area2D.new()
	area.monitoring = false
	area.add_to_group("PlayerKiller")
	add_child(area)
	
	var collision_polygon := CollisionPolygon2D.new()
	collision_polygon.polygon = polygon
	collision_polygon.build_mode = CollisionPolygon2D.BUILD_SEGMENTS
	area.add_child(collision_polygon)
