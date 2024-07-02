@tool
extends EditorPlugin

func _enter_tree():
	add_custom_type("Spawner_Container", "Node", preload("res://addons/spawner/spawner_container.gd"), preload("res://icon.svg"))
	add_custom_type("Spawner", "Marker2D", preload("res://addons/spawner/spawner.gd"), preload("res://addons/spawner/Spawner.png"))
func _exit_tree():
	remove_custom_type("Spawner_Container")
	remove_custom_type("Spawner")
