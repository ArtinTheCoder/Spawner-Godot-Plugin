@tool
extends EditorPlugin

func _enter_tree():
	add_custom_type("SpawnerContainer", "Node2D", preload("res://addons/spawner/spawner_container.gd"), preload("res://icon.svg"))
	add_custom_type("Spawner", "Marker2D", preload("res://addons/spawner/spawner.gd"), preload("res://addons/spawner/Spawner.png"))
	add_custom_type("MultipleSpawner", "Marker2D", preload("res://addons/spawner/multiple_spawner.gd"), preload("res://addons/spawner/MultipleSpawner.png"))

func _exit_tree():
	remove_custom_type("SpawnerContainer")
	remove_custom_type("Spawner")
	remove_custom_type("MultipleSpawner")
