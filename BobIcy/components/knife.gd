class_name Knife
extends Area2D

@export var speed: float = 520.0
var direction: Vector2 = Vector2.RIGHT
var lifetime: float = 2.0

@onready var hitbox: HitboxComponent = $HitboxComponent

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	hitbox.landed.connect(queue_free)
	rotation = direction.angle() + (PI / 4.0)

func _physics_process(delta: float) -> void:
	position += direction * speed * delta
	lifetime -= delta
	if lifetime <= 0.0:
		queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Bob":
		return
	queue_free()
