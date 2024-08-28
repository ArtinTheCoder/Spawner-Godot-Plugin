class_name EnemyResource 
extends Resource

@export_group("Spawning Requirements")
@export var scene: PackedScene ## Your enemy scene
@export_range(0, 100) var chance: int ## The chance for it to spawn
@export var max_amount : int ## How much it should spawn

@export_group("Enemy Info") ## FOR CUSTOM AREA SPAWNING
@export var enemy_size : Vector2 ## FOR CUSTOM AREA SPAWNING
@export var enemy_pivot_point_in_center : bool = true ## FOR CUSTOM AREA SPAWNING
