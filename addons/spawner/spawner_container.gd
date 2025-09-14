extends Node
signal start_wave(should_start)
signal wave_finished
# TODO
#signal specific_enemy_wave_spawned_multi_spawner(enemy)
var spawners = []
var total_enemies = 0
var current_enemies = 0
@export var start_waves_onready : bool = true
@export var max_active_enemies : int = 10  # Maximum number of active enemies before pausing
@onready var SpawnerGlobal = get_node_or_null("/root/SpawnerGlobal")
var start_spawning : bool
var all_active_enemies = []  # Array to track all active enemies for pausing
var current_spawner_index = 0  # Round-robin spawner selection
var spawners_per_frame = 1  # How many spawners can spawn per frame

func _ready():
	if SpawnerGlobal == null:
		print("SpawnerGlobal is NULL")
	start_spawning = start_waves_onready
	get_spawners()
	start_wave.connect(_on_start_wave)

func _on_start_wave(should_start):
	start_spawning = should_start

func get_spawners():
	for spawner in get_children(true):
		spawners.append(spawner)
		if spawner.spawner_type == "multiple_spawner":
			total_enemies += spawner.culminating_spawner_amount
		elif spawner.spawner_type == "single_spawner":
			total_enemies += spawner.enemy_amount_per_spawner

func _physics_process(delta):
	if not start_spawning:
		return

	if all_active_enemies.size() >= max_active_enemies:
		return

	var spawners_processed = 0
	var starting_index = current_spawner_index
	
	while spawners_processed < spawners.size() and spawners_processed < spawners_per_frame:
		var spawner = spawners[current_spawner_index]

		process_spawner(spawner)
		
		current_spawner_index = (current_spawner_index + 1) % spawners.size()
		spawners_processed += 1
		
		# Stop ifgone full circle back to starting point
		if current_spawner_index == starting_index and spawners_processed > 0:
			break
		
		# Stop if hit the max active enemies limit
		if all_active_enemies.size() >= max_active_enemies:
			break

func process_spawner(spawner):
	var name = spawner.name
	if SpawnerGlobal:
		if not SpawnerGlobal.spawner_status.has(name):
			SpawnerGlobal.spawner_status[name] = false
			SpawnerGlobal.spawner_count[name] = 0
		else:
			if spawner.spawner_type != "multiple_spawner":
				# single spawner
				if not SpawnerGlobal.spawner_status[name] \
				and SpawnerGlobal.spawner_count[name] < spawner.enemy_amount_per_spawner:
					spawn_enemy(spawner, spawner.custom_area_pos.x, spawner.custom_area_pos.y)
					SpawnerGlobal.spawner_status[name] = true
			else:
				# multiple spawner
				if not SpawnerGlobal.spawner_status[name]:
					SpawnerGlobal.spawner_status[name] = true
					var pos = spawner.custom_area_pos if spawner.use_custom_areas else spawner.global_position
					spawn_enemy(spawner, pos.x, pos.y)

func spawn_enemy(spawner, x_pos, y_pos):
	# pauses spawning once it reached the limit
	if all_active_enemies.size() >= max_active_enemies:
		return
	else:
		if spawner.spawner_type == "multiple_spawner":
			var enemy_data = spawner.choose_enemy()
			if enemy_data and SpawnerGlobal.spawner_count[spawner.name] < spawner.culminating_spawner_amount:
				var inst = enemy_data.scene.instantiate()
				spawner.add_child(inst)
				all_active_enemies.append(inst)
				# enemy's "death signal"
				if inst.has_signal("tree_exiting"):
					inst.tree_exiting.connect(_on_enemy_died.bind(inst))
				SpawnerGlobal.spawner_count[spawner.name] += 1
				
#			TODO
				#if SpawnerGlobal.spawner_count[spawner.name] == enemy_data.max_amount:
					#specific_enemy_wave_spawned_multi_spawner.emit(enemy_data)
				current_enemies += 1
				
			else:
				wave_finished.emit()
				
		elif spawner.spawner_type == "single_spawner":
			var inst = spawner.enemy_scene.instantiate()
			spawner.add_child(inst)
			all_active_enemies.append(inst)
			if inst.has_signal("tree_exiting"):
				inst.tree_exiting.connect(_on_enemy_died.bind(inst))
			SpawnerGlobal.spawner_count[spawner.name] += 1
			current_enemies += 1

func _on_enemy_died(enemy):
	if enemy in all_active_enemies:
		all_active_enemies.erase(enemy)
	current_enemies = max(current_enemies - 1, 0)
