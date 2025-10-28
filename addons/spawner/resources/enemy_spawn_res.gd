class_name EnemyResource 
extends Resource

@export_group("Spawning Requirements")
@export var enemy_scene : CustomizablePackedScene ## Your enemy scene
@export_range(0, 100) var chance: int ## The chance for it to spawn
@export var max_amount : int ## How much it should spawn

@export_group("Enemy Info") ## FOR CUSTOM AREA SPAWNING
@export var enemy_size : Vector2 ## Your Enemy Size X and Y

var scene:
	get:
		if enemy_scene != null:
			return enemy_scene.scene
		return null
