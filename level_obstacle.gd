extends Area2D

func _ready() -> void:
	for child in get_children():
		if child is CollisionPolygon2D:
			var polygon := $PolygonTemplate.duplicate()
			polygon.polygon = child.polygon
			polygon.visible = true
			child.add_child(polygon)
			
		if child is CollisionShape2D: if child.shape is RectangleShape2D:
			var rect := child.shape.get_rect() as Rect2
			
			var points := PackedVector2Array([
				rect.position,
				rect.position + Vector2(rect.size.x, 0),
				rect.position + rect.size,
				rect.position + Vector2(0, rect.size.y)
			])
			
			var polygon := $PolygonTemplate.duplicate()
			polygon.polygon = points
			polygon.visible = true
			child.add_child(polygon)
