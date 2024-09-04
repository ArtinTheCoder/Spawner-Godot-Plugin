@tool
extends Marker2D

signal finished_spawning

@export_category("Enemy")

@export var enemy_scene : PackedScene

@export var enemy_amount_per_spawner = 3 

@export_category("Spawners")

@export var time_between_spawns : int = 1

@export_category("Custom Spawn Area")
@export var use_custom_areas : bool:
	set(value):
		use_custom_areas = value
		property_list_changed.emit()
		
@export_group("2D")
@export var area_2d : CollisionShape2D
@export var enemy_size : Vector2 = Vector2(0, 0)

const custom_areas : Array[StringName] = [&"area_2d", &"enemy_size"]
const custom_area_groups : Array[StringName] = [&"2D"]

var spawner_type = "single_spawner"

var amount_spawned = 0 

var custom_area_pos = Vector2(0, 0)

var warning_printed = {}

func _ready():
	var spawner_node = self
	spawner_node.child_entered_tree.connect(_on_child_entered_tree)
	
	if enemy_scene == null:
		print("NO ENEMY SCENE")
	
	get_random_pos_2d(enemy_scene)
	
func _on_child_entered_tree(node):
	get_random_pos_2d(enemy_scene)
	if use_custom_areas:
		node.global_position = custom_area_pos
		
	await get_tree().create_timer(time_between_spawns).timeout
	
	SpawnerGlobal.spawner_status[self.name] = false
	
	amount_spawned += 1
	
	if enemy_amount_per_spawner == amount_spawned:
		finished_spawning.emit()
		
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

func get_random_pos_2d(enemy: PackedScene):
	if area_2d != null:
		var shape = area_2d.get_shape()
		
		if shape is RectangleShape2D:
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
