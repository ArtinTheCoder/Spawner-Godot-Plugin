extends Node2D

@onready var single_enemy_spawner = $SingleEnemySpawner
@onready var multi_enemy_spawner: StaticBody2D = $MultiEnemySpawner
@onready var single_start_onready: Label = $SingleSpawnerInfo/StartOnready
@onready var multi_start_onready: Label = $MultiSpawnerInfo/StartOnready

@onready var next_cam: Button = $CanvasLayer/NextCam

var single_enemy_spawner_node
var single_enemy_spawner_container_node 

var multi_enemy_spawner_node
var multi_enemy_spawner_container_node 

# This for the switching camera button not related to plugin
var cameras = []
var current_camera = 0

func _ready():
	single_enemy_spawner_node = single_enemy_spawner.get_node("SpawnerContainer/Spawner")
	single_enemy_spawner_node.amount_enemy_spawned.connect(single_spawner_amount_of_enemy_spawned)
	single_enemy_spawner_node.finished_spawning.connect(single_spawner_finished_spawning)
	
	multi_enemy_spawner_node = multi_enemy_spawner.get_node("SpawnerContainer/MultipleSpawner")
	multi_enemy_spawner_node.amount_enemy_spawned.connect(multiple_spawner_amount_enemy_spawned)
	multi_enemy_spawner_node.finished_spawning.connect(multiple_spawner_finished_spawning)
	
	single_enemy_spawner_container_node = single_enemy_spawner.get_node("SpawnerContainer")
	
	multi_enemy_spawner_container_node = multi_enemy_spawner.get_node("SpawnerContainer")

	single_start_onready.text = "Single Spawner spawns on ready is " + str(single_enemy_spawner_container_node.start_waves_onready)
	multi_start_onready.text = "Mult Spawner spawns on ready is " + str(multi_enemy_spawner_container_node.start_waves_onready)
	
	cameras = [$SingleEnemySpawnerCamera, $SingleEnemySpawnerCamera2]
	
func single_spawner_amount_of_enemy_spawned(amount):
	#print("Enemy spawned: " + str(amount))
	pass

func single_spawner_finished_spawning():
	print("Single enemy spawner finished spawning.")
	
func multiple_spawner_amount_enemy_spawned(amount_of_enemies_spawned):
	print("Multiple enemies spawned: " + str(amount_of_enemies_spawned))

func multiple_spawner_finished_spawning():
	print("Multiple enemy spawner finished spawning.")
	
func _on_start_single_pressed():
	single_enemy_spawner_container_node.start_wave.emit(true)

func _on_stop_single_pressed():
	single_enemy_spawner_container_node.start_wave.emit(false)

func _on_start_multi_enemy_pressed() -> void:
	multi_enemy_spawner_container_node.start_wave.emit(true)
	
func _on_stop_multi_enemy_pressed() -> void:
	multi_enemy_spawner_container_node.start_wave.emit(false)
	
func _on_next_cam_pressed() -> void:
	current_camera = (current_camera + 1) % cameras.size()
	for i in cameras.size():
		cameras[i].enabled = (i == current_camera)
