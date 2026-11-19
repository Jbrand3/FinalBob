extends CharacterBody2D

@export_group("Movement Dials")
@export var speed: float = 300.0
@export var jump_velocity: float = -1900.0

@export_group("Combat & Stats Dials")
@export var coins: int = 0
@export var speed_multiplier: float = 1.0
@export var jump_multiplier: float = 1.0
@export var damage_multiplier: float = 1.0
@export_range(0.1, 2.0, 0.05) var throw_cooldown: float = 0.35

const KNIFE_SCENE = preload("res://components/knife.tscn")
const KNIFE_SPAWN_OFFSET: float = 65.0

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

var can_throw: bool = true


func _ready() -> void:
	var hurtbox := get_node_or_null("HurtboxComponent")
	if hurtbox:
		var health := get_node_or_null("HealthComponent")
		if health:
			hurtbox.health = health
			
	if has_node("HealthComponent"):
		var hc = $HealthComponent
		if has_node("HurtboxComponent"):
			$HurtboxComponent.health = hc
		if hc.has_signal("died"):
			hc.died.connect(die)

func die() -> void:
	get_tree().reload_current_scene()

func _physics_process(delta: float) -> void:
	_apply_gravity(delta)
	_handle_movement()
	_handle_combat()
	_update_animations()
	move_and_slide()


func _apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta


func _handle_movement() -> void:
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity * jump_multiplier

	var direction := Input.get_axis("move_left", "move_right")
	var current_speed := speed * speed_multiplier
	
	if direction != 0.0:
		velocity.x = direction * current_speed
		sprite.flip_h = direction < 0.0
	else:
		velocity.x = move_toward(velocity.x, 0.0, current_speed)


func _handle_combat() -> void:
	if can_throw and is_on_floor() and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		throw_knife()


func _update_animations() -> void:
	if not is_on_floor():
		_play_first_available(["jump", "Jump"])
	else:
		_play_first_available(["idle", "Idle", "default"])


func _play_first_available(anim_names: Array[String]) -> void:
	if not sprite or not sprite.sprite_frames:
		return
		
	for anim in anim_names:
		if sprite.sprite_frames.has_animation(anim):
			sprite.play(anim)
			return


func throw_knife() -> void:
	can_throw = false
	
	var aim_dir := global_position.direction_to(get_global_mouse_position())
	var knife := KNIFE_SCENE.instantiate()
	knife.global_position = global_position + (aim_dir * KNIFE_SPAWN_OFFSET)
	
	if "shooter" in knife:
		knife.shooter = self
	if "direction" in knife:
		knife.direction = aim_dir
		
	get_parent().add_child(knife)
	
	await get_tree().create_timer(throw_cooldown).timeout
	can_throw = true
