extends Area2D
class_name Player

const TURN_SPEED := 3.0
const MIN_BOOST_STRENGTH := 100.0
const MAX_BOOST_STRENGTH := 300.0
const DRAG := 30.0
const CHARGE_TIME := 0.5

var speed := 0.0
var movement_direction := 0.0
var facing := 0.0
var turning := 0.0
var charge_amount := 0.0

@export var sprite: Node2D
@export var camera: Camera2D
@export var boost_animation_player: AnimationPlayer
@export var charge_meter: ProgressBar

func charge_by(delta: float) -> void:
	charge_amount += minf(delta / CHARGE_TIME, 1)

func boost() -> void:
	speed = lerpf(MIN_BOOST_STRENGTH, MAX_BOOST_STRENGTH, charge_amount)
	charge_amount = 0
	movement_direction = facing
	boost_animation_player.stop()
	boost_animation_player.play("boost")

func _ready() -> void:
	boost_animation_player.play("idle")
	boost_animation_player.animation_set_next("boost", "idle")

func _process(delta: float) -> void:
	var turn_input := Input.get_action_strength("turn_right") - Input.get_action_strength("turn_left")
	turning = turn_input
	
	if Input.is_action_pressed("boost"):
		charge_by(delta)
		
	if Input.is_action_just_released("boost"):
		boost()
	
	charge_meter.value = charge_amount
	
	speed = move_toward(speed, 0, delta * DRAG / 2)
	position += Vector2.UP.rotated(movement_direction) * speed * delta
	speed = move_toward(speed, 0, delta * DRAG / 2)
	
	rotation = facing
	
	facing += turning * TURN_SPEED * delta

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("PlayerKiller"):
		var explosion := preload("res://explosion.tscn").instantiate()
		explosion.global_position = global_position
		get_parent().add_child(explosion)
		
		process_mode = Node.PROCESS_MODE_DISABLED
		visible = false
		
		await get_tree().create_timer(1).timeout
		
		process_mode = Node.PROCESS_MODE_INHERIT
		visible = true
		
		camera.position = global_position
		camera.rotation = global_rotation
		
		global_position = Vector2.ZERO
		rotation = 0
		speed = 0
		movement_direction = 0
		facing = 0
		turning = 0
		charge_amount = 0

		var tween := create_tween().set_ease(Tween.EASE_OUT).set_parallel()
		tween.tween_property(camera, "position", Vector2.ZERO, 0.3)
		tween.tween_property(camera, "rotation", 0, 0.3)
