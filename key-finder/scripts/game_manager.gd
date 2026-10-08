extends Node

@onready var coin_count: Label = $"../CoinHUD/HUD/Panel/Row/Count"

var score := 0
var count_tween: Tween

func _ready() -> void:
	var panel: PanelContainer = coin_count.get_parent().get_parent()
	panel.offset_left = -110.0
	panel.offset_right = 110.0
	var hearts := Control.new()
	hearts.set_script(preload("res://scripts/lives_hud.gd"))
	coin_count.get_parent().add_child(hearts)
	update_count()

func add_point() -> void:
	score += 1
	update_count()
	if count_tween and count_tween.is_running():
		count_tween.kill()
	coin_count.pivot_offset = coin_count.size / 2.0
	coin_count.scale = Vector2.ONE
	count_tween = create_tween()
	count_tween.tween_property(coin_count, "scale", Vector2.ONE * 1.2, 0.1)
	count_tween.tween_property(coin_count, "scale", Vector2.ONE, 0.15)

func update_count() -> void:
	coin_count.text = str(score)
