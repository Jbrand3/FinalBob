extends Node2D

var start_map = preload("res://map_1.tscn")
var upper_maps = [
	preload("res://map_2.tscn"),
	preload("res://map_3.tscn"),
	preload("res://map_4.tscn")
]

var next_spawn_y: float = 0.0
var map_height: float = 648.0

func _ready() -> void:
	randomize()
	var first_map = start_map.instantiate()
	first_map.position.y = 0.0
	add_child(first_map)
	
	map_height = get_map_height(first_map)
	next_spawn_y = -map_height
	spawn_next_map()

func _process(_delta: float) -> void:
	var player = get_tree().get_first_node_in_group("player")
	if not player:
		player = find_child("Bob", true, false)
	if player and player.global_position.y < next_spawn_y + (map_height * 2.0):
		spawn_next_map()

func spawn_next_map() -> void:
	var chosen_scene = upper_maps.pick_random()
	var new_map = chosen_scene.instantiate()
	new_map.position.y = next_spawn_y
	add_child(new_map)
	
	var h = get_map_height(new_map)
	next_spawn_y -= h

func get_map_height(map_node: Node2D) -> float:
	if map_node.has_node("Top"):
		return abs(map_node.get_node("Top").position.y)
	if map_node.has_node("Marker2D"):
		return abs(map_node.get_node("Marker2D").position.y)
	return get_viewport_rect().size.y
