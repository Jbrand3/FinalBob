extends Node2D

@export var coin_value: int = 1
@export var pickup_radius: float = 80.0
@export var fall_gravity: float = 600.0
@export var pop_spread_x: float = 60.0
@export var pop_min_y: float = -200.0
@export var pop_max_y: float = -130.0

var velocity: Vector2 = Vector2.ZERO
var start_y: float = 0.0
var landed: bool = false

func _ready() -> void:
	print("COIN SPAWNED AT: ", global_position)
	start_y = global_position.y
	velocity = Vector2(randf_range(-pop_spread_x, pop_spread_x), randf_range(pop_min_y, pop_max_y))

func _physics_process(delta: float) -> void:
	if not landed:
		velocity.y += fall_gravity * delta
		position += velocity * delta
		if global_position.y >= start_y and velocity.y > 0:
			global_position.y = start_y
			landed = true

	var bob = find_bob()
	if bob and global_position.distance_to(bob.global_position) <= pickup_radius:
		if "coins" in bob:
			bob.coins += coin_value
		print("COIN COLLECTED! Total: ", bob.get("coins"))
		queue_free()

func find_bob() -> Node2D:
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		return players[0]
	for child in get_tree().current_scene.get_children():
		if child is CharacterBody2D and "coins" in child:
			return child
	return null
