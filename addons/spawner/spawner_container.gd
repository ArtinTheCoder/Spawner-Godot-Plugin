extends Node

@export var spawn_enemies_at_the_same_spawners : bool


@export var spawner_cooldown : int

var amount_spawned = 0

var spawn_status = {}

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
	if amount_spawned < amount_spawned_limit():
		for i in range(spawners.size()):
			spawn_enemy(spawners[i], spawners[i].global_position.x, spawners[i].global_position.y)
			
#func spawn_enemy(spawner, x_pos, y_pos):
	#if amount_spawned >= (enemy_amount_per_spawner * amount_of_spawners()):
#
		#if spawn_enemies_at_the_same_spawners:
			#var spawn_status = true
#
			#var enemy_instantiate = spawner.enemy_scene.instantiate()
			#spawner.add_child(enemy_instantiate)
			#spawn_status = false
			#amount_spawned += 1
			#print(amount_spawned)
		#
		#else:
			#for i in spawners.size():
				#print(i)
				#var spawner_test = spawners[i]
				#var enemy_instantiate = spawner.enemy_scene.instantiate()
				#spawner_test.add_child(enemy_instantiate)
				#amount_spawned += 1
				#print("Spawned enemy #", amount_spawned, " at spawner #", i + 1)
				#if amount_spawned >= enemy_amount_per_spawner:
					#break
				#await get_tree().create_timer(3.0).timeout

func spawn_enemy(spawner, x_pos, y_pos):
	var enemy_instantiate = spawner.enemy_scene.instantiate()
	
	spawner.add_child(enemy_instantiate)
	amount_spawned += 1
	
	#print("Spawned enemy #", amount_spawned, " at spawner #", spawners.find(spawner) + 1)
	
	# The - -1 for some reason fixs a bug that when you run it. 
	# It will still spawn an extra one at the end
		
	if amount_spawned >= (spawner.enemy_amount_per_spawner * amount_of_spawners() - -1):
		amount_spawned = 0
		
	else:
		print(spawner.time_between_spawns)
		
