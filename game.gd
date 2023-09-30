extends Node2D

@export var player: Player
@export var charge_meter: ProgressBar
@export var camera: Camera2D

func _ready() -> void:
	camera.reparent(player, false)

func _process(delta: float) -> void:
	var turn_input := Input.get_action_strength("turn_right") - Input.get_action_strength("turn_left")
	player.turning = turn_input
	
	if Input.is_action_pressed("boost"):
		player.charge_by(delta)
		
	if Input.is_action_just_released("boost"):
		player.boost()
	
	charge_meter.value = player.charge_amount

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_tree().quit()

func _on_level_1_hit_player(old_player: Player) -> void:
	var new_player := preload("res://player.tscn").instantiate()
	player = new_player
	add_child(new_player)
	
	camera.reparent(new_player)
	camera.reset_smoothing()
	
	create_tween()\
		.set_ease(Tween.EASE_OUT)\
		.tween_property(camera, "position", Vector2.ZERO, 0.3)
	
	old_player.queue_free()
