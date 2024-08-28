@tool
extends Marker2D

signal finished_spawning

@export_category("Enemy")

@export var enemy_scene_array : Array[EnemyResource]

@export_category("Spawners")

@export var time_between_spawns : int = 1

@export_category("Spawn Area")

@export var use_custom_areas : bool:
	set(value):
		use_custom_areas = value
		property_list_changed.emit()
		
@export_group("2D")
@export var area_2d : CollisionShape2D

const custom_areas : Array[StringName] = [&"area_2d"]
const custom_area_groups : Array[StringName] = [&"2D"]

var rng = RandomNumberGenerator.new()

var spawner_type = "multiple_spawner"

var culminating_spawner_amount = 0

var enemy_counts = {}

var amount_spawned = 0

var custom_area_pos = Vector2(0, 0)

func _ready():
	for data in enemy_scene_array:
		culminating_spawner_amount += data.max_amount
		enemy_counts[data.scene.resource_path] = 0
		if data.chance > 100:
			print("THE TOTAL AMOUNT OF CHANCE IS OVER 100!", "SPAWNER NAME:", self.name)
	
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
			
			if use_custom_areas == true and area_2d != null:
				get_random_pos_2d(data)

			return data
	
	rng.randomize()
	
	return null
	
func _on_child_entered_tree(node):

	if use_custom_areas:
		node.global_position = custom_area_pos
	
	await get_tree().create_timer(time_between_spawns).timeout
	
	SpawnerGlobal.spawner_status[self.name] = false
	amount_spawned += 1
	
	if total_amount_to_spawn() == amount_spawned:
		finished_spawning.emit()
	
func total_amount_to_spawn():
	var total_enemies_spawned = 0
	
	for enemy in enemy_scene_array.size():
		total_enemies_spawned += enemy_scene_array[enemy].max_amount

	return total_enemies_spawned

func _validate_property(property : Dictionary) -> void:
	if property.name in custom_areas:
		if use_custom_areas:
			property.usage |= PROPERTY_USAGE_EDITOR
		else:
			property.usage &= ~PROPERTY_USAGE_EDITOR
	
	if property.name in custom_area_groups:
		if use_custom_areas:
			property.usage |= PROPERTY_USAGE_GROUP
		else:
			property.usage &= ~PROPERTY_USAGE_GROUP

func get_random_pos_2d(enemy: EnemyResource):
	
	if area_2d != null:
		var shape = area_2d.get_shape()
		var top_left_corner = area_2d.global_position - (area_2d.shape.size / 2)
	
		if shape is RectangleShape2D:
			print(custom_area_pos)
			custom_area_pos.x = randi_range(top_left_corner.x + (enemy.enemy_size.x / 2), top_left_corner.x + area_2d.shape.size.x - (enemy.enemy_size.x / 2)) 
			
			custom_area_pos.y = randi_range(top_left_corner.y + (enemy.enemy_size.y / 2), top_left_corner.y + area_2d.shape.size.y - (enemy.enemy_size.y / 2)) 
		
			
		else:
			print("IT MUST BE A RECTANGLE COLLISION SHAPE 2D")
	else:
		print("THERE IS NO COLLISION SHAPE ATTACHED TO THIS SCRIPT")
