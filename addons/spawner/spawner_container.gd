extends Node

@export var spawn_enemies_at_the_same_spawners : bool

@export var enemy_amount_per_spawner = 1

@export var wait_time_till_next_spawn : int

var amount_spawned = 0

var spawn_status = {}

var spawners = []

func _ready():
	get_spawners()
	print(spawners)

func amount_of_spawners():
	var amount = 0
	
	for spawner in get_child_count(true):
		amount += 1
		
	return amount
	
func get_spawners():
	for spawner in get_children(true):
		print("Spawner X = " + str(spawner.global_position.x), " Spawner Y = " + str(spawner.global_position.y))
		spawners.append(spawner)

		
func _physics_process(delta):
	if amount_spawned != (enemy_amount_per_spawner * amount_of_spawners()):
		for i in spawners.size():
			spawn_enemy(spawners[i], spawners[i].global_position.x, spawners[i].global_position.y)
	
func spawn_enemy(spawner, x_pos, y_pos):
	if amount_spawned != (enemy_amount_per_spawner * amount_of_spawners()):

		if spawn_enemies_at_the_same_spawners:
			var spawn_status = true

			var enemy_instantiate = spawner.enemy_scene.instantiate()
			spawner.add_child(enemy_instantiate)
			spawn_status = false
				#wait_till_next_spawn(marker_node, null)
			amount_spawned += 1
			print(amount_spawned)
		
		else:
			for i in spawners.size():
				print(i)
				var spawner_test = spawners[i]
				var enemy_instantiate = spawner.enemy_scene.instantiate()
				spawner_test.add_child(enemy_instantiate)
				amount_spawned += 1
				print("Spawned enemy #", amount_spawned, " at spawner #", i + 1)
				if amount_spawned >= enemy_amount_per_spawner:
					break
				await get_tree().create_timer(3.0).timeout

