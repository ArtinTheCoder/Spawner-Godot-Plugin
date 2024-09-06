extends Node2D

@onready var spawner_container = $SpawnerContainer

func _on_start_pressed():
	spawner_container.start_wave.emit(true)

func _on_stop_pressed():
	spawner_container.start_wave.emit(false)

func _on_spawner_container_wave_finished():
	print("SPAWNER CONTAINER FINISHED")

func _on_spawner_container_specific_enemy_wave_spawned_multi_spawner(enemy):
	print("SPECIFIC ENEMY FINISH: ", enemy)
