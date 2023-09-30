extends Polygon2D

signal hit_player(player: Player)

func _ready() -> void:
	var area := Area2D.new()
	area.area_entered.connect(_on_area_entered)
	add_child(area)
	
	var collision_polygon := CollisionPolygon2D.new()
	collision_polygon.polygon = polygon
	collision_polygon.build_mode = CollisionPolygon2D.BUILD_SEGMENTS
	area.add_child(collision_polygon)
	
func _on_area_entered(area: Area2D) -> void:
	if area is Player: hit_player.emit(area) 
