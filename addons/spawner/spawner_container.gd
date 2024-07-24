extends Node

var spawners = []

func _ready():
	get_spawners()
	
func get_spawners():
	for spawner in get_children(true):
		#print("Spawner X = " + str(spawner.global_position.x), " Spawner Y = " + str(spawner.global_position.y))
		spawners.append(spawner)
		
func _physics_process(delta):
	for i in range(spawners.size()):
		var spawner_name = spawners[i].name

		if not SpawnerGlobal.spawner_status.has(spawner_name):
			SpawnerGlobal.spawner_status[spawner_name] = false
			SpawnerGlobal.spawner_count[spawner_name] = 0
		# \ allows it to go to the next line on the if statement
		# Check if the spawner can spawn more enemies based on max_amount
		if not SpawnerGlobal.spawner_status[spawner_name] \
		and SpawnerGlobal.spawner_count[spawner_name] < spawners[i].enemy_amount_per_spawner:
			print(spawner_name, " ", SpawnerGlobal.spawner_count[spawner_name])
			spawn_enemy(spawners[i], spawners[i].global_position.x, spawners[i].global_position.y)
			SpawnerGlobal.spawner_status[spawner_name] = true
	
		
func spawn_enemy(spawner, x_pos, y_pos):
	print("SPAWNING ", spawner.name)
	if spawner.spawner_type == "multiple_spawner":
		var enemy_data = spawner.choose_enemy()
		if enemy_data and SpawnerGlobal.spawner_count[spawner.name] < enemy_data.max_amount:
			var enemy_instantiate = enemy_data.scene.instantiate()
			spawner.add_child(enemy_instantiate)
			SpawnerGlobal.spawner_count[spawner.name] += 1
		else:
			print("No enemy spawned: Max amount reached or no enemy selected")
	else:
		print("SPAWNED")
		var enemy_instantiate = spawner.enemy_scene.instantiate()
		spawner.add_child(enemy_instantiate)
		SpawnerGlobal.spawner_count[spawner.name] += 1
		
