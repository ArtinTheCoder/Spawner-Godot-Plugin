extends CharacterBody2D

var speed = 150

func _ready():
	$Player.rotation = 0
	
func _physics_process(delta):
	get_input()
	
	move_and_slide()
	
func get_input():
	var input_direction = Input.get_vector("Left", "Right", "Forward", "Backward")
	
	if Input.is_action_pressed("Left"):
		$Player.flip_h = true
		$AnimationPlayer.play("walk")
	
	elif Input.is_action_pressed("Right"):
		$Player.flip_h = false
		$AnimationPlayer.play("walk")
	
	else:
		$Player.rotation = 0
		
	velocity = input_direction * speed
