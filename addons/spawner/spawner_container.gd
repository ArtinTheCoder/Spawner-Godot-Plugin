extends Node

var total_amount_spawned = 0

var spawners = []

func _ready():
	get_spawners()
	
func amount_of_spawners():
	var amount = 0
	
	for spawner in get_child_count(true):
		amount += 1
	
	return amount
	
func get_spawners():
	for spawner in get_children(true):
		print("Spawner X = " + str(spawner.global_position.x), " Spawner Y = " + str(spawner.global_position.y))
		spawners.append(spawner)

func amount_spawned_limit():
	for spawner in range(spawners.size()):
		var limit = spawners[spawner].enemy_amount_per_spawner * amount_of_spawners()
		
		return limit
		
func _physics_process(delta):
	for i in range(spawners.size()):
		var spawner_name = spawners[i].name
			
		if not SpawnerGlobal.spawner_status.has(spawner_name):
			SpawnerGlobal.spawner_status[spawner_name] = false
			SpawnerGlobal.spawner_count[spawner_name] = 0
		
		
		# \ allows it to go to the next line on the if statement
		if spawner_name == spawners[i].name \
			and not SpawnerGlobal.spawner_status[spawner_name] \
			and SpawnerGlobal.spawner_count[spawner_name] < spawners[i].enemy_amount_per_spawner:
			
				spawn_enemy(spawners[i], spawners[i].global_position.x, spawners[i].global_position.y)
				SpawnerGlobal.spawner_status[spawner_name] = true
				SpawnerGlobal.spawner_count[spawner_name] += 1
				
func spawn_enemy(spawner, x_pos, y_pos):
	var enemy_instantiate = spawner.enemy_scene.instantiate()
	
	spawner.add_child(enemy_instantiate)
	
	total_amount_spawned += 1
	
