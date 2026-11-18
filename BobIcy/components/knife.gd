extends Area2D

@export var speed: float = 520.0
var direction: Vector2 = Vector2.RIGHT
var lifetime: float = 2.0
var shooter: Node2D = null

@onready var hitbox: Area2D = $HitboxComponent

func _ready() -> void:
	hitbox.collision_layer = 8
	hitbox.collision_mask = 16
	hitbox.monitoring = true
	hitbox.monitorable = true

	if shooter != null and (shooter.is_in_group("player") or "Bob" in shooter.name):
		hitbox.is_enemy_attack = false
	else:
		hitbox.is_enemy_attack = true
		
	hitbox.landed.connect(queue_free)
	rotation = direction.angle() + (PI / 4.0)

func _physics_process(delta: float) -> void:
	position += direction * speed * delta
	lifetime -= delta
	if lifetime <= 0.0:
		queue_free()
