extends Node

var checkpoint_position := Vector2.ZERO
var has_checkpoint := false
var furthest_x := 0.0

func set_checkpoint(at: Vector2) -> void:
	checkpoint_position = at
	has_checkpoint = true

func reset() -> void:
	checkpoint_position = Vector2.ZERO
	has_checkpoint = false
	furthest_x = 0.0
