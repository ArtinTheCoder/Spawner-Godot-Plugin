@tool
class_name SingleSpawner
extends Marker2D

signal finished_spawning
signal amount_enemy_spawned(amount_of_enemies_spawned : int)
signal enemy_spawned(enemy)

@export_category("Spawner Info")

@export var enemy_scene : CustomizablePackedScene

@export var enemy_amount_per_spawner = 3 

@export_category("Timer")

@export var time_between_spawns : int = 1
@export var use_random_time : bool:  
	set(value):
		use_random_time = value 
		property_list_changed.emit()

@export var min_time : int = 1
@export var max_time : int = 5

var actual_enemy_scene : PackedScene

var time_between_spawn_rng = RandomNumberGenerator.new() 

const RANDOM_TIME : Array[StringName] = [&"min_time", &"max_time"]

@export_category("Custom Spawn Area")
@export var use_custom_areas : bool:
	set(value):
		use_custom_areas = value
		property_list_changed.emit()

@export_group("2D")
@export var area_2d : CollisionShape2D
@export var enemy_size : Vector2 = Vector2(0, 0)

const CUSTOM_AREAS : Array[StringName] = [&"area_2d", &"enemy_size"]
const CUSTOM_AREAS_GROUP : Array[StringName] = [&"2D"]

var spawner_type = "single_spawner"

var amount_spawned = 0 

var custom_area_pos = Vector2(0, 0)

var warning_printed = {}

func _ready():
	if enemy_scene == null:
		print("NO ENEMY SCENE ATTACHED TO THE SPAWNER")
	else:
		actual_enemy_scene = enemy_scene.scene
		
	var spawner_node = self
	spawner_node.child_entered_tree.connect(_on_child_entered_tree)
	
	get_random_pos_2d(actual_enemy_scene)

func _on_child_entered_tree(node):
	get_random_pos_2d(actual_enemy_scene)
	if use_custom_areas:
		node.global_position = custom_area_pos
	
	amount_spawned += 1
	
	enemy_spawned.emit(node)
	amount_enemy_spawned.emit(amount_spawned)
	
	if use_random_time == false:
		await get_tree().create_timer(time_between_spawns).timeout
	else:
		var time = time_between_spawn_rng.randi_range(min_time, max_time)
		time_between_spawn_rng.randomize()
		
		await get_tree().create_timer(time).timeout

	get_parent().spawner_data.spawner_status[self.name] = false
	
	if enemy_amount_per_spawner == amount_spawned:
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
		
func get_random_pos_2d(enemy: PackedScene):
	if area_2d != null:
		var shape = area_2d.get_shape()
		
		if shape is RectangleShape2D:
			if area_2d.disabled != true:
				print("TURN ON DISABLED MODE ON YOUR COLLSION SHAPE SO IT DOESN'T INTERFERE WITH YOUR GAME")

			var top_left_corner = area_2d.global_position - (area_2d.shape.size / 2)
			
			if shape.size < enemy_size and !warning_printed.has("ShapeSizeSmallerThanEnemySize"):
				print("PLEASE MAKE SURE TO INCREASE THE AREA SPAWN BECAUSE IT'S SMALLER THAN THE ENEMY")
				warning_printed["ShapeSizeSmallerThanEnemySize"] = 1
		
			custom_area_pos.x = randi_range(top_left_corner.x + (enemy_size.x / 2), top_left_corner.x + area_2d.shape.size.x - (enemy_size.x / 2)) 
				
			custom_area_pos.y = randi_range(top_left_corner.y + (enemy_size.y / 2), top_left_corner.y + area_2d.shape.size.y - (enemy_size.y / 2)) 
			
		elif not shape is RectangleShape2D and !warning_printed.has("MustRectangleCollision"):
			print("IT MUST BE A RECTANGLE COLLISION SHAPE 2D")
			warning_printed["MustRectangleCollision"] = 1
			
	elif area_2d == null and !warning_printed.has("NoCollisionShapeAttached") and use_custom_areas == true:
		print("THERE IS NO COLLISION SHAPE ATTACHED TO THIS SCRIPT")
		warning_printed["NoCollisionShapeAttached"] = 1
