extends Node

signal lives_changed

const MAX_LIVES := 3
var lives := MAX_LIVES
var dying := false

var checkpoint_position := Vector2.ZERO
var has_checkpoint := false
var furthest_x := 0.0

func set_checkpoint(at: Vector2) -> void:
	checkpoint_position = at
	has_checkpoint = true

func lose_life() -> bool:
	if dying or lives <= 0:
		return false
	dying = true
	lives -= 1
	lives_changed.emit()
	return true

func reset() -> void:
	lives = MAX_LIVES
	dying = false
	lives_changed.emit()
	reset_level()

func reset_level() -> void:
	checkpoint_position = Vector2.ZERO
	has_checkpoint = false
	furthest_x = 0.0
