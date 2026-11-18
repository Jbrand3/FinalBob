extends Area2D

var velocity: Vector2 = Vector2.ZERO
var fall_gravity: float = 600.0
var start_y: float = 0.0
var landed: bool = false

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	start_y = global_position.y
	velocity = Vector2(randf_range(-90.0, 90.0), randf_range(-220.0, -140.0))

func _physics_process(delta: float) -> void:
	if not landed:
		velocity.y += fall_gravity * delta
		position += velocity * delta
		if global_position.y >= start_y and velocity.y > 0:
			global_position.y = start_y
			landed = true

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") or body.name == "Bob":
		if "coins" in body:
			body.coins += 1
		print("Coin collected!")
		queue_free()
