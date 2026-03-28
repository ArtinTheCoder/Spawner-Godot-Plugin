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
	print("Start wave called")
	spawner_containers = get_tree().get_nodes_in_group("spawner_containers")
	containers_finished = 0
	
	for container in spawner_containers:
		container.wave_finished.connect(_on_container_finished, CONNECT_ONE_SHOT)
		container.start_wave.emit(true)
	
	wave_started.emit(index)

func _on_container_finished():
	print("contaienr finished called")
	containers_finished += 1
	if containers_finished >= spawner_containers.size():
		wave_completed.emit(current_wave_index)
		_advance_wave()

func _advance_wave():
	prints("advacne wave called")
	current_wave_index += 1
	if current_wave_index >= waves.size():
		all_waves_completed.emit()
		return
	await get_tree().create_timer(time_between_waves).timeout
	start_wave(current_wave_index)
	
