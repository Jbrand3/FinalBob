class_name HurtboxComponent
extends Area2D

@export var health: HealthComponent

func take_hit(amount: int) -> void:
	if health != null:
		health.take_hit(amount)
