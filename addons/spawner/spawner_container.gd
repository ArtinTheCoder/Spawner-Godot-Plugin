extends Node

signal start_wave(should_start)
signal wave_finished
signal specific_enemy_wave_spawned_multi_spawner(enemy)

var spawners = []
var total_enemies = 0
var current_enemies = 0

@export var start_waves_onready : bool = true
@export var max_active_enemies : int = 35  # Maximum number of active enemies before culling
@onready var SpawnerGlobal = get_node_or_null("/root/SpawnerGlobal")

var start_spawning : bool
var all_active_enemies = []  # Array to track all active enemies for culling

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
		else:
			total_enemies += spawner.enemy_amount_per_spawner
			
func _physics_process(delta):
	if start_spawning:
		for spawner in spawners:
			var name = spawner.name
			if SpawnerGlobal:
				if not SpawnerGlobal.spawner_status.has(name):
					SpawnerGlobal.spawner_status[name] = false
					SpawnerGlobal.spawner_count[name]  = 0
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
	if all_active_enemies.size() >= max_active_enemies:
		cull_oldest_enemy()
		
	if spawner.spawner_type == "multiple_spawner":
		var enemy_data = spawner.choose_enemy()
		if enemy_data and SpawnerGlobal.spawner_count[spawner.name] < spawner.culminating_spawner_amount:
			var inst = enemy_data.scene.instantiate()
			spawner.add_child(inst)
			# Track the new enemy
			all_active_enemies.append(inst)
			# Connect to the enemy's death signal to update our tracking
			if inst.has_signal("tree_exiting"):
				inst.tree_exiting.connect(_on_enemy_died.bind(inst))
				
			SpawnerGlobal.spawner_count[spawner.name] += 1
			if SpawnerGlobal.spawner_count[spawner.name] == enemy_data.max_amount:
				specific_enemy_wave_spawned_multi_spawner.emit(enemy_data)
		else:
			wave_finished.emit()
			
	elif spawner.spawner_type == "single_spawner":
		var inst = spawner.enemy_scene.instantiate()
		spawner.add_child(inst)
		# Track the new enemy
		all_active_enemies.append(inst)
		# Connect to the enemy's death signal to update our tracking
		if inst.has_signal("tree_exiting"):
			inst.tree_exiting.connect(_on_enemy_died.bind(inst))
			
		SpawnerGlobal.spawner_count[spawner.name] += 1
	current_enemies += 1
	
func _on_enemy_died(enemy):
	if enemy in all_active_enemies:
		all_active_enemies.erase(enemy)
	current_enemies -= 1
	

func cull_oldest_enemy(): 
	# If we have enemies to cull, remove the oldest one (first in the array) 
	if all_active_enemies.size() > 0:
		var oldest_enemy = all_active_enemies[0] 
		
		if is_instance_valid(oldest_enemy) and oldest_enemy.is_inside_tree():
			# Disconnect the signal first to avoid _on_enemy_died being called 
			if oldest_enemy.is_connected("tree_exiting", _on_enemy_died): 
				oldest_enemy.disconnect("tree_exiting", _on_enemy_died)
			
			# Remove from tracking array 
			all_active_enemies.erase(oldest_enemy) 
			# Free the enemy 
			oldest_enemy.queue_free() 
			current_enemies -= 1 
			
		else: 
			# If the enemy is not valid, just remove it from the array 
			all_active_enemies.remove_at(0)
