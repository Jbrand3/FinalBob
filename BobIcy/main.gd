extends Node2D

var map1_scene = preload("res://map_1.tscn")
var map2_scene = preload("res://map_2.tscn")
var bob_scene = preload("res://bob.tscn")

var bob: CharacterBody2D
var next_spawn_y: float = 0.0
const MAP_HEIGHT: float = 648.0

func _ready() -> void:
	var m1 = map1_scene.instantiate()
	add_child(m1)
	
	if m1.has_node("Bob"):
		m1.get_node("Bob").queue_free()
	
	bob = bob_scene.instantiate()
	bob.position = Vector2(576, 500)
	add_child(bob)
	
	spawn_map2()

func _process(_delta: float) -> void:
	if bob.position.y < next_spawn_y + MAP_HEIGHT:
		spawn_map2()

func spawn_map2() -> void:
	next_spawn_y -= MAP_HEIGHT
	var m2 = map2_scene.instantiate()
	m2.position = Vector2(0, next_spawn_y)
	add_child(m2)
