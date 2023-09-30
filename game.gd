extends Node2D

@export var player: Player
@export var charge_meter: ProgressBar

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
