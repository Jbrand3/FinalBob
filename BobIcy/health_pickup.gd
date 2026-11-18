extends Area2D

@export var heal_amount: int = 1

func _ready() -> void:
	collision_layer = 0
	collision_mask = 1 | 16
	monitoring = true
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") or "Bob" in body.name:
		_heal_player(body)

func _on_area_entered(area: Area2D) -> void:
	var owner_node = area.get_parent()
	if owner_node and (owner_node.is_in_group("player") or "Bob" in owner_node.name):
		_heal_player(owner_node)

func _heal_player(player: Node2D) -> void:
	var hc = player.get_node_or_null("HealthComponent")
	if hc and "current" in hc and "max_health" in hc:
		if hc.current < hc.max_health:
			hc.current = clampi(hc.current + heal_amount, 0, hc.max_health)
			if hc.has_signal("changed"):
				hc.changed.emit(hc.current)
			queue_free()
