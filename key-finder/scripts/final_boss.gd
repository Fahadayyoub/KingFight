extends Node2D

const MAX_HEALTH := 8
const PROJECTILE := preload("res://scripts/boss_projectile.gd")
const HUD := preload("res://scripts/boss_hud.gd")
@export var activation_x := 5320.0
@export var arena_left := 5280.0
@export var arena_right := 5840.0
@export_node_path("Node2D") var gate_path: NodePath

var health := MAX_HEALTH
var active := false
var defeated := false
var player: CharacterBody2D
var cooldown := 1.2
var winding_up := false
var locked_aim := Vector2.ZERO
var primary: Node2D
var projectiles: Array[Node2D] = []
var throws := 0
var flash := 0.0
var hud: Control
var arena_walls: Array[StaticBody2D] = []

func _ready() -> void:
	player = get_parent().get_node("Player")
	var layer := CanvasLayer.new()
	layer.layer = 12
	add_child(layer)
	hud = Control.new()
	hud.set_script(HUD)
	hud.boss = self
	hud.anchor_left = 0.5
	hud.anchor_right = 0.5
	hud.offset_left = -230
	hud.offset_right = 230
	hud.offset_top = 62
	hud.offset_bottom = 126
	hud.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hud.visible = false
	layer.add_child(hud)
	$AnimatedSprite2D.play(&"default")

func _physics_process(delta: float) -> void:
	if defeated or Progress.dying or not is_instance_valid(player):
		return
	if not active:
		if player.global_position.x >= activation_x:
			activate()
		return
	flash = maxf(0, flash - delta)
	$AnimatedSprite2D.modulate = Color("fff0bb") if flash > 0 else (Color("f4a18d") if health <= MAX_HEALTH / 2 else Color.WHITE)
	if is_instance_valid(primary):
		return
	cooldown -= delta
	if cooldown <= 0:
		if not winding_up:
			winding_up = true
			locked_aim = player.global_position + Vector2(0, -6)
			cooldown = 0.65 if health <= MAX_HEALTH / 2 else 0.95
		else:
			throw_comet()
			winding_up = false
			cooldown = 0.65 if health <= MAX_HEALTH / 2 else 1.1
	queue_redraw()

func activate() -> void:
	active = true
	for edge in [arena_left, arena_right]:
		var wall := StaticBody2D.new()
		var collider := CollisionShape2D.new()
		var shape := RectangleShape2D.new()
		shape.size = Vector2(12, 200)
		collider.shape = shape
		wall.add_child(collider)
		add_child(wall)
		wall.global_position = Vector2(edge, -96)
		arena_walls.append(wall)
	queue_redraw()
	hud.visible = true
	get_tree().current_scene.get_node("CoinHUD/HUD/ProgressHUD").hide()
	var camera: Camera2D = player.get_node("Camera2D")
	camera.zoom = Vector2(2, 2)
	camera.position = Vector2(60, -60)
	camera.limit_left = int(arena_left)
	camera.limit_right = 5920

func throw_comet() -> void:
	var comet := Node2D.new()
	comet.set_script(PROJECTILE)
	comet.boss = self
	var origin := global_position + Vector2(-18, -24)
	var aim := locked_aim - origin
	comet.direction = aim.normalized() if aim.length() > 1 else Vector2.LEFT
	comet.outbound_distance = clampf(aim.length() + 32, 110, 460)
	comet.speed = 240.0 if health <= MAX_HEALTH / 2 else 190.0
	get_tree().current_scene.add_child(comet)
	comet.global_position = origin
	primary = comet
	projectiles.append(comet)
	throws += 1
	$ThrowSound.play()
	if health <= MAX_HEALTH / 2 and throws % 2 == 0:
		var wave := Node2D.new()
		wave.set_script(PROJECTILE)
		wave.boss = self
		wave.ground_wave = true
		wave.speed = 165.0
		get_tree().current_scene.add_child(wave)
		wave.global_position = global_position + Vector2(-28, 0)
		projectiles.append(wave)

func take_return_hit(projectile: Node2D) -> void:
	if defeated or not active or projectile.boss != self or not projectile.returning or projectile.ground_wave:
		return
	if not projectiles.has(projectile):
		return
	projectiles.erase(projectile)
	health = maxi(0, health - 1)
	flash = 0.25
	$HurtSound.play()
	if health == 0:
		defeat()

func defeat() -> void:
	defeated = true
	winding_up = false
	$Contact/CollisionShape2D.set_deferred("disabled", true)
	$AnimatedSprite2D.modulate = Color("675872")
	$VictorySound.play()
	for projectile in projectiles:
		if is_instance_valid(projectile):
			projectile.queue_free()
	projectiles.clear()
	for wall in arena_walls:
		wall.queue_free()
	arena_walls.clear()
	get_node(gate_path).unlock()
	queue_redraw()

func _draw() -> void:
	# Crown and orb shield turn the existing purple slime into the final boss.
	if active and not defeated:
		for edge in [arena_left, arena_right]:
			draw_line(to_local(Vector2(edge, -192)), to_local(Vector2(edge, 0)), Color(0.95, 0.66, 0.42, 0.6), 2)
	if not defeated:
		draw_arc(Vector2(0, -28), 34, PI * 0.6, PI * 1.4, 20, Color("ba9bd5"), 2)
		draw_colored_polygon(PackedVector2Array([Vector2(-17,-54),Vector2(-18,-70),Vector2(-8,-62),Vector2(0,-76),Vector2(8,-62),Vector2(18,-70),Vector2(17,-54)]), Color("f4c876"))
		if winding_up:
			var aim := to_local(locked_aim)
			draw_line(Vector2(-18, -24), aim, Color(1, 0.58, 0.35, 0.55), 1)
			draw_circle(aim, 8, Color(1, 0.58, 0.35, 0.25))
