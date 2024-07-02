extends Marker2D

@export_category("Enemy")

@export var enemy_scene : PackedScene

@export_category("Spawners")


var spawn = true

var change_marker_pos = false

var spawners_node = []

var spawn_status = {}

var amount_of_spawned = 0

func wait_till_next_spawn(marker_node, timer_node):
	var timer = Timer.new()
	add_child(timer)
	timer_node = timer
	#timer.wait_time = wait_time_till_next_spawn
	timer.one_shot = true
	timer_node = timer
	timer.timeout.connect(spawn_time_timeout.bind(marker_node, timer_node))
	timer.start()

func spawn_time_timeout(marker_node, timer_node):
	spawn_status[marker_node] = true
	timer_node.queue_free()
	
