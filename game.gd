extends Node2D

@export var levels: Node

@onready var player := preload("res://player.tscn").instantiate() as Player
@onready var current_level := levels.get_child(current_level_index).duplicate() as Node2D

var current_level_index := 0

func _ready() -> void:
	player.level_completed.connect(_on_player_level_completed)
	
	add_child(current_level)
	add_child(player)
	
func _on_player_level_completed() -> void:
	await get_tree().create_timer(2).timeout
	
	current_level_index = mini(current_level_index + 1, levels.get_child_count() - 1)
	
	current_level.queue_free()
	current_level = levels.get_child(current_level_index).duplicate()
	add_child(current_level)
	
	player.queue_free()
	player = preload("res://player.tscn").instantiate() as Player
	player.level_completed.connect(_on_player_level_completed)
	add_child(player)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_tree().quit()
