extends Node2D

@onready var single_enemy_spawner = $SingleEnemySpawner

var single_enemy_spawner_node

func _ready():
	single_enemy_spawner_node = single_enemy_spawner.get_node("SpawnerContainer/Spawner")
	single_enemy_spawner_node.amount_enemy_spawned.connect(single_amount_of_enemy_spawned)

func single_amount_of_enemy_spawned(amount):
	print(amount)
