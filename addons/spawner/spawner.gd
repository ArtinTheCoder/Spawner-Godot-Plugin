extends Marker2D

@export_category("Enemy")

@export var enemy_scene : PackedScene

@export var enemy_amount_per_spawner = 3 

@export_category("Spawners")

@export var time_between_spawns : int

func _on_child_entered_tree(node):
	await get_tree().create_timer(time_between_spawns).timeout
	
	SpawnerGlobal.spawner_status[self.name] = false
