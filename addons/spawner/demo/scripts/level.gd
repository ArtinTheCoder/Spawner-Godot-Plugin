extends Node2D

func _on_button_pressed():
	$SpawnerContainer.start_wave.emit(true)

func _on_stop_pressed():
	$SpawnerContainer.start_wave.emit(false)

func _on_spawner_container_wave_finished():
	print("SPAWNER CONTAINER FINISHED")

func _on_multiple_spawner_2_finished_spawning():
	print("MULTIPLE SPAWNER FINISHED")

func _on_spawner_container_specific_enemy_wave_spawned_multi_spawner(enemy):
	print("WORKING")
