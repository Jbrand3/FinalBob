extends CharacterBody2D

enum State { PATROL, ATTACK }
var current_state: State = State.PATROL

@export_group("Movement & Combat")
@export var speed: float = 45.0
@export var shoot_interval: float = 1.5
@export var turn_delay: float = 0.3
@export var knife_spawn_offset: float = 75.0
@export var knife_fallback_speed: float = 400.0

@export_group("Drops")
@export var min_coins: int = 1
@export var max_coins: int = 3
@export_range(0.0, 1.0, 0.05) var health_drop_chance: float = 0.35
@export var drop_spread_x: float = 15.0
@export var drop_offset_y: float = 10.0

var direction = 1
var turn_cooldown = 0.0
var shoot_cooldown = 0.0
var is_throwing = false
var target_player: Node2D = null

var knife_scene = preload("res://components/knife.tscn")
var coin_scene = preload("res://coin.tscn")
var health_pickup_scene = preload("res://health_pickup.tscn")

@onready var floor_check: RayCast2D = $FloorCheck
@onready var knife_spawn: Marker2D = $KnifeSpawn
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	sprite.animation_finished.connect(_on_animation_finished)
	sprite.play("Enemy_walk")
	if has_node("HealthComponent"):
		var hc = $HealthComponent
		if has_node("HurtboxComponent"):
			$HurtboxComponent.health = hc
		if hc.has_signal("died"):
			hc.died.connect(die)

func check_health() -> void:
	if not has_node("HealthComponent"):
		return
	var hc = $HealthComponent
	if "current" in hc and hc.current <= 0:
		die()


func _physics_process(delta: float) -> void:
	check_health()

	if turn_cooldown > 0:
		turn_cooldown -= delta
	if shoot_cooldown > 0:
		shoot_cooldown -= delta

	if not is_on_floor():
		velocity += get_gravity() * delta

	match current_state:
		State.PATROL:
			patrol_state()
		State.ATTACK:
			attack_state()

	move_and_slide()


func die() -> void:
	if randf() < health_drop_chance:
		var heart = health_pickup_scene.instantiate()
		heart.global_position = global_position + Vector2(0, drop_offset_y)
		get_tree().current_scene.call_deferred("add_child", heart)
	else:
		var drop_count = randi_range(min_coins, max_coins)
		for i in range(drop_count):
			var coin = coin_scene.instantiate()
			coin.global_position = global_position + Vector2(randf_range(-drop_spread_x, drop_spread_x), drop_offset_y)
			get_tree().current_scene.call_deferred("add_child", coin)
	queue_free()

func patrol_state() -> void:
	is_throwing = false
	if turn_cooldown <= 0 and (is_on_wall() or (is_on_floor() and not floor_check.is_colliding())):
		turn_around()
	velocity.x = direction * speed
	if sprite.animation != "Enemy_walk":
		sprite.play("Enemy_walk")

func attack_state() -> void:
	velocity.x = 0
	if not is_instance_valid(target_player):
		target_player = null
		current_state = State.PATROL
		return

	var look_dir = sign(target_player.global_position.x - global_position.x)
	if look_dir != 0 and look_dir != direction:
		set_facing(look_dir)

	if shoot_cooldown <= 0:
		throw_knife()
		shoot_cooldown = shoot_interval
		is_throwing = false
	elif not is_throwing and sprite.animation != "Enemy_walk":
		sprite.play("Enemy_walk")

func turn_around() -> void:
	set_facing(direction * -1)
	turn_cooldown = turn_delay

func set_facing(new_dir: int) -> void:
	direction = new_dir
	sprite.flip_h = (direction < 0)
	floor_check.position.x = abs(floor_check.position.x) * direction
	knife_spawn.position.x = abs(knife_spawn.position.x) * direction

func throw_knife() -> void:
	sprite.play("Enemy_throw")
	var knife = knife_scene.instantiate()
	if "shooter" in knife:
		knife.shooter = self
	if "direction" in knife:
		knife.direction = Vector2(direction, 0)
	get_parent().add_child(knife)
	knife.global_position = global_position + Vector2(direction * knife_spawn_offset, 0)

func _on_animation_finished() -> void:
	if sprite.animation == "Enemy_throw":
		is_throwing = false
		sprite.play("Enemy_walk")

func _on_detection_zone_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		target_player = body
		current_state = State.ATTACK

func _on_detection_zone_body_exited(body: Node2D) -> void:
	if body.is_in_group("player") or body == target_player:
		target_player = null
		is_throwing = false
		current_state = State.PATROL
		sprite.play("Enemy_walk")
