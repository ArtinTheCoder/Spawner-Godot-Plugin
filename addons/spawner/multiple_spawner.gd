extends Marker2D

@export_category("Enemy")

@export var enemy_scene_array : Array[Enemy]

@export_category("Spawners")

@export var time_between_spawns : int

var rng = RandomNumberGenerator.new()

var spawner_type = "multiple_spawner"

var culminating_spawner_amount = 0

var enemy_counts = {}

func _ready():
	for data in enemy_scene_array:
		culminating_spawner_amount += data.max_amount
		enemy_counts[data.scene.resource_path] = 0
		
	var spawner_node = self
	spawner_node.child_entered_tree.connect(_on_child_entered_tree)
	
func choose_enemy():
	var available_enemies = enemy_scene_array.filter(func(data): return enemy_counts[data.scene.resource_path] < data.max_amount)
	
	if available_enemies.is_empty():
		return null
 	
	var total_chance = 0
	for data in available_enemies:
		total_chance += data.chance
		
	var rand_rng_enemy = rng.randi() % available_enemies.size()
	var rand_value = rng.randi() % total_chance
	var cumulative_chance = 0
	
	for data in available_enemies:
		
		cumulative_chance += data.chance
		if rand_value < cumulative_chance:
			enemy_counts[data.scene.resource_path] += 1
			print(data.scene.resource_path)
			return data
			
	rng.randomize()
	
	return null
	
func _on_child_entered_tree(node):

	await get_tree().create_timer(time_between_spawns).timeout
	
	SpawnerGlobal.spawner_status[self.name] = false
