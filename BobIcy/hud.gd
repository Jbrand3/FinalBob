extends CanvasLayer

func _process(_delta: float) -> void:
	var bob = get_tree().get_first_node_in_group("player")
	if not bob:
		bob = get_tree().root.find_child("Bob", true, false)
	if not bob:
		return

	var hp_comp = bob.get_node_or_null("HealthComponent")
	var health_label = find_child("HealthLabel", true, false)
	if hp_comp and health_label and "current" in hp_comp:
		health_label.text = "Health: " + str(hp_comp.current)

	var coins_label = find_child("CoinsLabel", true, false)
	if coins_label and "coins" in bob:
		coins_label.text = "Coins: " + str(bob.coins)
