extends Node2D
class_name Player

@export var sprite: Node2D
@export var camera: Camera2D
@export var boost_animation_player: AnimationPlayer
@export var charge_meter: ProgressBar
@export var smoke_spawn_marker: Node2D
@export var hitbox: Area2D

const TURN_SPEED := 3.0
const MIN_BOOST_STRENGTH := 100.0
const MAX_BOOST_STRENGTH := 600.0
const DRAG := 0.0
const CHARGE_TIME := 0.5
const STRAFE_SPEED := 200.0
const STRAFE_ROTATION := 0.4
const STRAFE_ROTATION_SPEED := 10.0
const GRAVITY_PIT_STRENGTH := 200.0

var speed := 0.0
var movement_angle := 0.0
var facing_angle := 0.0
var turning := 0.0
var strafing := 0.0
var charge_amount := 0.0
var smoke_wait_time := 0.0

# this really shouldn't be here, but game jam code LOL
var levels := [
	"res://levels/straight.tscn",
	"res://levels/turns.tscn",
	"res://levels/snake.tscn",
	"res://levels/split_paths.tscn",
	"res://levels/big_curve.tscn",
	"res://levels/obstacles.tscn",
	"res://levels/hard_turns.tscn",
	"res://levels/gravity_pits.tscn",
	"res://levels/hell.tscn",
	"res://levels/end.tscn",
]

func reset() -> void:
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
	
	set_process(true)
	visible = true

func _ready() -> void:
	boost_animation_player.play("idle")
	boost_animation_player.animation_set_next("boost", "idle")
	
	charge_meter.get_parent().modulate.a = 0

func charge_by(delta: float) -> void:
	charge_amount = minf(charge_amount + delta / CHARGE_TIME, 1)

func boost() -> void:
	speed = lerpf(MIN_BOOST_STRENGTH, MAX_BOOST_STRENGTH, charge_amount)
	movement_angle = facing_angle
	charge_amount = 0
	boost_animation_player.stop()
	boost_animation_player.play("boost")

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("reset"):
		reset()
		return
		
	if event.is_action_pressed("ui_cancel"):
		get_tree().quit()

func _process(delta: float) -> void:
	# collect input
	turning = Input.get_action_strength("turn_right") - Input.get_action_strength("turn_left")
	strafing = Input.get_action_strength("strafe_right") - Input.get_action_strength("strafe_left")
	
	var charging := false
	if Input.is_action_pressed("boost"):
		charging = true
		charge_by(delta)
		
	if Input.is_action_just_released("boost"): boost()
	
	# apply movement from speed and drag
	speed = move_toward(speed, 0, delta * DRAG / 2)
	global_position += Vector2.UP.rotated(movement_angle) * speed * delta
	speed = move_toward(speed, 0, delta * DRAG / 2)
	
	# apply movement from strafing
	global_position += Vector2.RIGHT.rotated(facing_angle) * strafing * STRAFE_SPEED * delta
	
	# apply gravity pit attraction
	var gravity_pit = hitbox.get_overlapping_areas().filter(
		func (area: Area2D): return area.is_in_group("GravityPit")
	).reduce(func (closest: Area2D, next: Area2D):
		var next_distance := next.global_position.distance_to(global_position)
		var closest_distance = closest.global_position.distance_to(global_position)
		if next_distance < closest_distance:
			return next
		else:
			return closest
	)
	
	if gravity_pit is Area2D:
		global_position = global_position.move_toward(
			gravity_pit.global_position, delta * GRAVITY_PIT_STRENGTH
		)
	
	# apply facing angle
	rotation = facing_angle
	
	# apply turning
	facing_angle += turning * TURN_SPEED * delta
	
	# update charge meter UI
	if charging:
		charge_meter.get_parent().modulate.a = 1
		charge_meter.value = charge_amount
	else:
		charge_meter.get_parent().modulate.a -= delta / 0.3
	
	# tilt the sprite based on our strafing input
	sprite.rotation = lerp_angle(sprite.rotation, strafing * STRAFE_ROTATION, delta * STRAFE_ROTATION_SPEED)
	
	# spawn smoke particles
	smoke_wait_time -= max(speed / 20 * delta, delta * 10)
	if smoke_wait_time <= 0:
		smoke_wait_time += 1
		
		var smoke := preload("res://smoke.tscn").instantiate() as Node2D
		smoke.global_position = smoke_spawn_marker.global_position
		get_parent().get_child(get_index() - 1).add_sibling(smoke)

func _on_hitbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("LevelComplete"):
		var warp_effect := preload("res://warp_effect.tscn").instantiate() as Node2D
		warp_effect.global_position = global_position
		warp_effect.rotation = rotation
		add_sibling(warp_effect)
		
		set_process.call_deferred(false)
		visible = false
		
		var current_level := get_tree().current_scene.scene_file_path
		var current_level_index := levels.find(current_level)
		if current_level_index < levels.size() - 1:
			await get_tree().create_timer(1).timeout
			get_tree().change_scene_to_file(levels[current_level_index + 1])
		else:
			$EndScreen.show()
	
	if area.is_in_group("LevelObstacle"):
		_kill()

func _on_level_area_detector_exited_level() -> void:
	_kill()
	
func _kill():
	var explosion := preload("res://explosion.tscn").instantiate() as Node2D
	explosion.global_position = global_position
	add_sibling(explosion)
	
	set_process.call_deferred(false)
	visible = false
	
	await get_tree().create_timer(0.5).timeout
	
	reset()
