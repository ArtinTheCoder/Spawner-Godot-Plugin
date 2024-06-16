@tool
extends EditorPlugin

func _enter_tree():
	add_custom_type("Spawner Container", "Node", preload("res://addons/spawner/spawner_container.gd"), preload("res://icon.svg"))
	add_custom_type("Spawner", "Marker2D", preload("res://addons/spawner/spawner.gd"), preload("res://icon.svg"))
func _exit_tree():
	remove_custom_type("SpawnerContainer")
	remove_custom_type("Spawner")
