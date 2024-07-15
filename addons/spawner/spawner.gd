extends Marker2D

@export_category("Enemy")

@export var enemy_scene : PackedScene

@export var enemy_amount_per_spawner = 1 # Enemy Amount To Spawn Per Spawner

@export_category("Spawners")

@export var time_between_spawns : int

var spawn = true

var change_marker_pos = false

var spawners_node = []

var spawn_status = {}

var amount_of_spawned = 0

func wait_till_next_spawn(timer_node):
	var timer = Timer.new()
	add_child(timer)
	timer_node = timer
	timer.wait_time = time_between_spawns
	timer.one_shot = true
	timer_node = timer
	timer.timeout.connect(spawn_time_timeout.bind(timer_node))
	timer.start()

func spawn_time_timeout(timer_node):
	timer_node.queue_free()
	
