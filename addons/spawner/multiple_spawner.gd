extends Marker2D

@export_category("Enemy")

@export var enemy_scene_array : Array[Enemy]

@export_category("Spawners")

@export var time_between_spawns : int

var rng = RandomNumberGenerator.new()

var enemy_scene

var enemy_amount_per_spawner

func _ready():
	choose_enemy()

func choose_enemy():
	var total_chance = 0
	
	for data in enemy_scene_array:
		total_chance += data.chance
		
	var rand_rng_enemy = rng.randi() % enemy_scene_array.size()
	
	var rand_value = rng.randi() % total_chance
	var cumulative_chance = 0
 
	for data in enemy_scene_array:
		cumulative_chance += data.chance
		if rand_value < cumulative_chance:
			enemy_scene = data.scene
			enemy_amount_per_spawner = data.amount
			print("Selected enemy with chance: ", data.chance)
			break

	rng.randomize()
	
func _on_child_entered_tree(node):
	
	await get_tree().create_timer(time_between_spawns).timeout
	
	SpawnerGlobal.spawner_status[self.name] = false
	
	choose_enemy()
