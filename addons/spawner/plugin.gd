@tool
extends EditorPlugin

func _enter_tree():
	add_custom_type("SpawnerContainer", "Node2D", preload("res://addons/spawner/scripts/spawner_container.gd"), preload("res://addons/spawner/icons/SpawnerContainerIcon.svg"))
	add_custom_type("Spawner", "Marker2D", preload("res://addons/spawner/scripts/single_spawner.gd"), preload("res://addons/spawner/icons/SpawnerNodeLogo.png"))
	add_custom_type("MultipleSpawner", "Marker2D", preload("res://addons/spawner/scripts/multiple_spawner.gd"), preload("res://addons/spawner/icons/MultipleSpawnerNodeLogo.png"))

func _exit_tree():
	remove_custom_type("SpawnerContainer")
	remove_custom_type("Spawner")
	remove_custom_type("MultipleSpawner")
