extends CanvasLayer

@export var main_menu_path: String = "res://main_menu.tscn"

func _ready() -> void:
	# Allow buttons to work even if the scene tree is paused
	process_mode = Node.PROCESS_MODE_ALWAYS
	$Control/VBoxContainer/RetryButton.pressed.connect(_on_retry_pressed)
	$Control/VBoxContainer/MainMenuButton.pressed.connect(_on_main_menu_pressed)
	
func _on_retry_pressed() -> void:
	print('y')
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_main_menu_pressed() -> void:
	print('y')
	get_tree().paused = false
	get_tree().change_scene_to_file(main_menu_path)
