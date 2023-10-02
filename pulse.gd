@tool
extends Node2D

@export_range(-20, 20, 0.1, "or_greater", "or_less") var speed := 1.0
@export_range(0, 1, 0.001, "or_greater", "or_less") var intensity := 0.1

var time := 0.0

func _process(delta: float) -> void:
	time += delta
	scale = Vector2.ONE + Vector2.ONE * sin(time * speed) * intensity
