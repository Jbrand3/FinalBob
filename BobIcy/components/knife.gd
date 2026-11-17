class_name Knife
extends Area2D
## A thrown knife. It flies straight until it leaves the screen or hits a wall.

@export var speed: float = 520.0

var direction: Vector2 = Vector2.RIGHT

@onready var hitbox: HitboxComponent = $HitboxComponent

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	hitbox.landed.connect(queue_free)

func _physics_process(delta: float) -> void:
	position += direction * speed * delta
	if not get_viewport_rect().grow(40.0).has_point(global_position):
		queue_free()

func _on_body_entered(_body: Node2D) -> void:
	queue_free()
