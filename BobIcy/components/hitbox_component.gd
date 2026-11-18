class_name HitboxComponent
extends Area2D

signal landed

@export var damage: int = 1
var is_enemy_attack: bool = false

func _ready() -> void:
	area_entered.connect(_on_area_entered)

func _on_area_entered(area: Area2D) -> void:
	if not area.has_method("take_hit"):
		return
		
	var target = area.get_parent()
	
	# Enemy attacks ONLY hurt Bob
	if is_enemy_attack:
		if not (target.is_in_group("player") or "Bob" in target.name):
			return
	# Player attacks NEVER hurt Bob
	else:
		if target.is_in_group("player") or "Bob" in target.name:
			return
		
	area.take_hit(damage)
	landed.emit()
