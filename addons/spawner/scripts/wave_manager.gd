extends Node

signal wave_started(index: int)
signal wave_completed(index: int)
signal all_waves_completed()

@export var waves: Array[WaveResource]
@export var auto_start: bool = false
@export var time_between_waves: float = 3.0

var current_wave_index = 0
var containers_finished = 0
var spawner_containers = []

func _ready():
	if auto_start:
		await get_tree().process_frame
		start_wave(0)
		
func start_wave(index: int):
	spawner_containers = get_tree().get_nodes_in_group("spawner_containers")
	containers_finished = 0
	var wave = waves[index]
	
	print(wave.wave_name)
	print(wave.time_between_waves)
	print(wave.max_active_enemies_override)
	
	for container in spawner_containers:
		if wave.max_active_enemies_override != -1:
			container.max_active_enemies = wave.max_active_enemies_override
			
		container.reset_spawners()
		container.wave_finished.connect(_on_container_finished, CONNECT_ONE_SHOT)
		container.start_wave.emit(true)
	
	wave_started.emit(index)

func _on_container_finished():
	containers_finished += 1
	if containers_finished >= spawner_containers.size():
		wave_completed.emit(current_wave_index)
		_advance_wave()

func _advance_wave():
	current_wave_index += 1
	
	if current_wave_index >= waves.size():
		all_waves_completed.emit()
		return
		
	var next_wave = waves[current_wave_index]
	var wait_time = next_wave.time_between_waves if next_wave.time_between_waves > 0 else time_between_waves
	
	await get_tree().create_timer(wait_time).timeout
	start_wave(current_wave_index)
	
