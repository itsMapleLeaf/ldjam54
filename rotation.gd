@tool
extends Node2D

@export var speed := 1.0

func _ready() -> void:
	rotation = 0

func _process(delta: float) -> void:
	rotate(delta * speed)
