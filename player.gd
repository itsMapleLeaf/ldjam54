extends Area2D
class_name Player

const TURN_SPEED := 7.0
const MIN_BOOST_STRENGTH := 100.0
const MAX_BOOST_STRENGTH := 300.0
const DRAG := 100.0
const CHARGE_TIME := 0.5

var speed := 0.0
var movement_direction := 0.0
var facing := 0.0
var turning := 0.0
var charge_amount := 0.0

@export var sprite: Node2D
@export var boost_animation_player: AnimationPlayer

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
	speed = move_toward(speed, 0, delta * DRAG / 2)
	position += Vector2.UP.rotated(movement_direction) * speed * delta
	speed = move_toward(speed, 0, delta * DRAG / 2)
	
	sprite.rotation = facing
	
	facing += turning * TURN_SPEED * delta
	
