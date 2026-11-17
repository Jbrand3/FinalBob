extends CharacterBody2D

const SPEED = 400.0
const JUMP_VELOCITY = -1800.0
const KNIFE_SCENE = preload("res://components/knife.tscn")

var throw_cooldown: float = 1.0
var cooldown_timer: float = 0.0

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	var direction := Input.get_axis("move_left", "move_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	if direction < 0:
		$AnimatedSprite2D.flip_h = true
	elif direction > 0:
		$AnimatedSprite2D.flip_h = false
	if not is_on_floor():
		$AnimatedSprite2D.play("Jump")
	else:
		$AnimatedSprite2D.play("Idle")
	if cooldown_timer > 0.0:
		cooldown_timer -= delta

	move_and_slide()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("throw_knife") and cooldown_timer <= 0.0 and is_on_floor():
		throw_knife()
		cooldown_timer = throw_cooldown
func throw_knife() -> void:
	var knife = KNIFE_SCENE.instantiate()
	var aim_dir = global_position.direction_to(get_global_mouse_position())
	knife.direction = aim_dir
	knife.global_position = global_position + (aim_dir * 60.0)
	get_parent().add_child(knife)
