extends Node2D

@export var player: Player
@export var level_container: Node2D

func _ready() -> void:
	var level := preload("res://levels/level1.tscn").instantiate()
	level_container.add_child(level)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_tree().quit()
