extends Area2D
class_name Player

const TURN_SPEED := 3.0
const MIN_BOOST_STRENGTH := 100.0
const MAX_BOOST_STRENGTH := 600.0
const DRAG := 30.0
const CHARGE_TIME := 0.5
const STRAFE_SPEED := 200.0
const STRAFE_ROTATION := 0.4
const STRAFE_ROTATION_SPEED := 10.0

var speed := 0.0
var movement_angle := 0.0
var facing_angle := 0.0
var turning := 0.0
var strafing := 0.0
var charge_amount := 0.0
var smoke_wait_time := 0.0

@export var sprite: Node2D
@export var camera: Camera2D
@export var boost_animation_player: AnimationPlayer
@export var charge_meter: ProgressBar
@export var smoke_spawn_marker: Node2D

func _ready() -> void:
	boost_animation_player.play("idle")
	boost_animation_player.animation_set_next("boost", "idle")

func charge_by(delta: float) -> void:
	charge_amount = minf(charge_amount + delta / CHARGE_TIME, 1)

func boost() -> void:
	speed = lerpf(MIN_BOOST_STRENGTH, MAX_BOOST_STRENGTH, charge_amount)
	charge_amount = 0
	movement_angle = facing_angle
	boost_animation_player.stop()
	boost_animation_player.play("boost")

func _process(delta: float) -> void:
	# collect input
	turning = Input.get_action_strength("turn_right") - Input.get_action_strength("turn_left")
	strafing = Input.get_action_strength("strafe_right") - Input.get_action_strength("strafe_left")
	if Input.is_action_pressed("boost"): charge_by(delta)
	if Input.is_action_just_released("boost"): boost()
	
	# apply movement from speed and drag
	speed = move_toward(speed, 0, delta * DRAG / 2)
	global_position += Vector2.UP.rotated(movement_angle) * speed * delta
	speed = move_toward(speed, 0, delta * DRAG / 2)
	
	# apply movement from strafing
	global_position += Vector2.RIGHT.rotated(facing_angle) * strafing * STRAFE_SPEED * delta
	
	# apply facing angle
	rotation = facing_angle
	
	# apply turning
	facing_angle += turning * TURN_SPEED * delta
	
	# update charge meter UI
	charge_meter.value = charge_amount
	
	# tilt the sprite based on our strafing input
	sprite.rotation = lerp_angle(sprite.rotation, strafing * STRAFE_ROTATION, delta * STRAFE_ROTATION_SPEED)
	
	# spawn smoke particles
	smoke_wait_time -= max(speed / 20 * delta, delta * 10)
	if smoke_wait_time <= 0:
		smoke_wait_time += 1
		
		var smoke := preload("res://smoke.tscn").instantiate() as Node2D
		smoke.global_position = smoke_spawn_marker.global_position
		get_parent().get_child(get_index() - 1).add_child(smoke)

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("PlayerKiller"):
		var explosion := preload("res://explosion.tscn").instantiate() as Node2D
		explosion.global_position = global_position
		get_parent().add_child(explosion)
		
		set_process.call_deferred(false)
		visible = false
		
		await get_tree().create_timer(1).timeout
		
		set_process(true)
		visible = true
		
		camera.position = global_position
		camera.rotation = global_rotation
		
		global_position = Vector2.ZERO
		rotation = 0
		speed = 0
		movement_angle = 0
		facing_angle = 0
		turning = 0
		charge_amount = 0

		var tween := create_tween().set_ease(Tween.EASE_OUT).set_parallel()
		tween.tween_property(camera, "position", Vector2.ZERO, 0.3)
		tween.tween_property(camera, "rotation", 0, 0.3)

	if area.is_in_group("LevelComplete"):
		var warp_effect := preload("res://warp_effect.tscn").instantiate() as Node2D
		set_process.call_deferred(false)
		add_child(warp_effect)
		sprite.visible = false
