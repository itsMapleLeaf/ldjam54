extends Area2D

signal exited_level

func _on_area_exited(_area: Area2D) -> void:
	await get_tree().physics_frame # wait for physics to resolve
	
	var is_in_level := get_overlapping_areas().any(
		func (area: Area2D): return area.is_in_group("LevelArea"))
		
	if not is_in_level:
		exited_level.emit()
