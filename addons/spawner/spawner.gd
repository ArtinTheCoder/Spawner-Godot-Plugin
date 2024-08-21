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

var custom_area_x_pos = 0
var custom_area_y_pos = 0

func _ready():
	var spawner_node = self
	spawner_node.child_entered_tree.connect(_on_child_entered_tree)
	
	if enemy_scene == null:
		print("NO ENEMY SCENE")

func _on_child_entered_tree(node):
	if use_custom_areas:
		node.global_position.x = custom_area_x_pos
		node.global_position.y = custom_area_y_pos 
		
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

func get_random_pos_2d(enemy: EnemyResource):
	var shape = area_2d.get_shape()
	if area_2d != null:
		if shape is RectangleShape2D:
			custom_area_x_pos = randi_range(area_2d.shape.get_rect().size.x + (enemy.enemy_size.x / 2), area_2d.shape.get_rect().size.x * 2) 
			custom_area_x_pos -= enemy.enemy_size.x
			print("AREA X: ", custom_area_x_pos )
			prints(area_2d.shape.get_rect().size.x + (enemy.enemy_size.x / 2), area_2d.shape.get_rect().size.x * 2)
			
			if custom_area_x_pos < area_2d.shape.get_rect().size.x + (enemy.enemy_size.x / 2):
				custom_area_x_pos = area_2d.shape.get_rect().size.x + (enemy.enemy_size.x / 2)
			
			custom_area_y_pos = randi_range(area_2d.global_position.y, area_2d.global_position.y - area_2d.shape.get_rect().size.y / 2) 
			custom_area_y_pos -= enemy.enemy_size.y
		else:
			print("IT MUST BE A RECTANGLE COLLISION SHAPE 2D")
	else:
		print("THERE IS NO COLLISION SHAPE ATTACHED TO THIS SCRIPT")
