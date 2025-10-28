@tool
extends Marker2D

signal finished_spawning
signal amount_enemy_spawned(amount_of_enemies_spawned)

@export_category("Spawner Infio")

@export var enemy_scene_array : Array[EnemyResource]

@export_category("Timer")

@export var time_between_spawns : int = 1
@export var use_random_time : bool:  
	set(value):
		use_random_time = value 
		property_list_changed.emit()

@export var min_time : int = 1
@export var max_time : int = 5

var time_between_spawn_rng = RandomNumberGenerator.new()

const RANDOM_TIME : Array[StringName] = [&"min_time", &"max_time"]

@export_category("Spawn Area")

@export var use_custom_areas : bool:
	set(value):
		use_custom_areas = value
		property_list_changed.emit()
		
@export_group("2D")
@export var area_2d : CollisionShape2D

const CUSTOM_AREAS : Array[StringName] = [&"area_2d"]
const CUSTOM_AREAS_GROUP : Array[StringName] = [&"2D"]

var rng = RandomNumberGenerator.new()

var spawner_type = "multiple_spawner"

var culminating_spawner_amount = 0
var enemy_counts = {}
var amount_spawned = 0
var custom_area_pos = Vector2(0, 0)

var warning_printed = {}

func _ready():
	rng.randomize()
	
	for data in enemy_scene_array:
		culminating_spawner_amount += data.max_amount
		enemy_counts[data.scene.resource_path] = 0
		if data.chance > 100:
			print("THE TOTAL AMOUNT OF CHANCE IS OVER 100!", "SPAWNER NAME:", self.name)
	
	self.child_entered_tree.connect(_on_child_entered_tree)
	
func choose_enemy():
	var available_enemies = enemy_scene_array.filter(func(data): return enemy_counts[data.scene.resource_path] < data.max_amount)
	
	if available_enemies.is_empty():
		return null
 	
	var total_chance = 0
	for data in available_enemies:
		total_chance += data.chance
	
	# -1 is there otherwise it would gave a value from 0 to 100 so
	# there is 101 possible values
	var rand_value = rng.randi_range(0, total_chance - 1)
	var cumulative_chance = 0
	
	for data in available_enemies:
		cumulative_chance += data.chance
		if rand_value <= cumulative_chance:
			enemy_counts[data.scene.resource_path] += 1
			
			if use_custom_areas == true and area_2d != null:
				get_random_pos_2d(data)

			return data
	
	return null

func _on_child_entered_tree(node): 
	if use_custom_areas: 
		node.global_position = custom_area_pos 
		
	amount_spawned += 1 
		
	amount_enemy_spawned.emit(amount_spawned) 
		
	if use_random_time == false:
		await get_tree().create_timer(time_between_spawns).timeout
	else:
		var time = time_between_spawn_rng.randi_range(min_time, max_time)
		time_between_spawn_rng.randomize()
	
		await get_tree().create_timer(time).timeout
	
	get_parent().spawner_data.spawner_status[self.name] = false
	
	if culminating_spawner_amount == amount_spawned: 
		finished_spawning.emit()

func _validate_property(property : Dictionary) -> void:
	if property.name in CUSTOM_AREAS:
		if use_custom_areas:
			property.usage |= PROPERTY_USAGE_EDITOR
		else:
			property.usage &= ~PROPERTY_USAGE_EDITOR
	
	if property.name in CUSTOM_AREAS_GROUP:
		if use_custom_areas:
			property.usage |= PROPERTY_USAGE_GROUP
		else:
			property.usage &= ~PROPERTY_USAGE_GROUP
	
	if property.name in RANDOM_TIME:
		if use_random_time:
			property.usage |= PROPERTY_USAGE_EDITOR
		else:
			property.usage &= ~PROPERTY_USAGE_EDITOR
	
	if property.name == "time_between_spawns" and use_random_time:
		property.usage = PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_READ_ONLY

func get_random_pos_2d(enemy: EnemyResource):
	if area_2d != null:
		var shape = area_2d.get_shape()
		
		if shape is RectangleShape2D:
			var top_left_corner = area_2d.global_position - (area_2d.shape.size / 2)
		
			if shape.size < enemy.enemy_size and !warning_printed.has("ShapeSizeSmallerThanEnemySize"):
				print("PLEASE MAKE SURE TO INCREASE THE AREA SPAWN BECAUSE IT'S SMALLER THAN THE ENEMY")
				warning_printed["ShapeSizeSmallerThanEnemySize"] = 1
			
			custom_area_pos.x = randi_range(top_left_corner.x + (enemy.enemy_size.x / 2), top_left_corner.x + area_2d.shape.size.x - (enemy.enemy_size.x / 2)) 
			
			custom_area_pos.y = randi_range(top_left_corner.y + (enemy.enemy_size.y / 2), top_left_corner.y + area_2d.shape.size.y - (enemy.enemy_size.y / 2)) 
			
		elif not shape is RectangleShape2D and !warning_printed.has("MustRectangleCollision"):
			print("IT MUST BE A RECTANGLE COLLISION SHAPE 2D")
			warning_printed["MustRectangleCollision"] = 1
			
	elif area_2d == null and !warning_printed.has("NoCollisionShapeAttached"):
		print("THERE IS NO COLLISION SHAPE ATTACHED TO THIS SCRIPT")
		warning_printed["NoCollisionShapeAttached"] = 1
