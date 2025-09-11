extends CharacterBody2D

@export var speed: float = 50
@export var change_dir_time: float = 1.5 

var move_dir: Vector2 = Vector2.ZERO
var time_left: float = 0.0

func _ready():
	randomize()
	_pick_new_direction()

func _physics_process(delta):
	time_left -= delta
	if time_left <= 0:
		_pick_new_direction()
		
	# Move and slide handles wall collisions automatically
	velocity = move_dir * speed
	move_and_slide()

func _pick_new_direction():
	# Random normalized vector
	move_dir = Vector2(randf() * 2 - 1, randf() * 2 - 1).normalized()
	time_left = change_dir_time + randf() * 0.5 # add some randomness

func _on_mouse_entered() -> void:
	queue_free()
