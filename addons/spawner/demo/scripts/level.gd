extends Node2D

func _on_button_pressed():
	$SpawnerContainer.start_wave.emit(true)

func _on_stop_pressed():
	$SpawnerContainer.start_wave.emit(false)

func _on_spawner_container_wave_finished():
	print("DONE")
