extends Node
class_name SpawnerContainer

signal start_wave(should_start)

signal wave_finished

signal specific_enemy_wave_spawned_multi_spawner(enemy)

var spawners = []

var total_enemies = 0

var current_enemies = 0

var start_spawning : bool

@export var start_waves_onready : bool = true

func _ready():
	get_spawners()
	start_wave.connect(_on_start_wave)

func _on_start_wave(should_start):
	start_spawning = should_start
	print(start_spawning)
	
func get_spawners():
	for spawner in get_children(true):
		spawners.append(spawner)
		if spawner.spawner_type == "multiple_spawner":
			total_enemies += spawner.culminating_spawner_amount
		else:
			total_enemies += spawner.enemy_amount_per_spawner
	
func _physics_process(delta):
	if start_waves_onready == true or start_spawning:
		for i in range(spawners.size()):
			var spawner_name = spawners[i].name

			if not SpawnerGlobal.spawner_status.has(spawner_name):
				SpawnerGlobal.spawner_status[spawner_name] = false
				SpawnerGlobal.spawner_count[spawner_name] = 0
					
				# \ allows it to go to the next line on the if statement
				# Check if the spawner can spawn more enemies based on max_amount	
			if spawners[i].spawner_type != "multiple_spawner":
				if not SpawnerGlobal.spawner_status[spawner_name] \
				and SpawnerGlobal.spawner_count[spawner_name] < spawners[i].enemy_amount_per_spawner:
					#print(spawner_name, " ", SpawnerGlobal.spawner_count[spawner_name])
					spawn_enemy(spawners[i], spawners[i].custom_area_pos.x, spawners[i].custom_area_pos.y)
					SpawnerGlobal.spawner_status[spawner_name] = true

			else:
				if not SpawnerGlobal.spawner_status[spawner_name]:
					if spawners[i].use_custom_areas:
						SpawnerGlobal.spawner_status[spawner_name] = true
						spawn_enemy(spawners[i], spawners[i].custom_area_pos.x, spawners[i].custom_area_pos.y)

					else:
						SpawnerGlobal.spawner_status[spawner_name] = true
						spawn_enemy(spawners[i], spawners[i].global_position.x, spawners[i].global_position.y)
						
func spawn_enemy(spawner, x_pos, y_pos):
	if spawner.spawner_type == "multiple_spawner":
		var enemy_data = spawner.choose_enemy()
	
		if enemy_data and SpawnerGlobal.spawner_count[spawner.name] < spawner.culminating_spawner_amount:
			var enemy_instantiate = enemy_data.scene.instantiate()
	
			spawner.add_child(enemy_instantiate)
			SpawnerGlobal.spawner_count[spawner.name] += 1
			
			if SpawnerGlobal.spawner_count[spawner.name] == enemy_data.max_amount:
				specific_enemy_wave_spawned_multi_spawner.emit(enemy_data)
				
		else:
			wave_finished.emit()
	
	elif spawner.spawner_type == "single_spawner":
		var enemy_instantiate = spawner.enemy_scene.instantiate()
		spawner.add_child(enemy_instantiate)
		SpawnerGlobal.spawner_count[spawner.name] += 1
	
	current_enemies += 1
