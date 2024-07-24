extends CharacterBody2D

var speed = 150



func _ready():
	$Player.rotation = 0
	
func _physics_process(delta):
	get_input()
	
	move_and_slide()
	
func get_input():
	var input_direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	if Input.is_action_pressed("ui_left"):
		$Player.flip_h = true
		$AnimationPlayer.play("walk")
	
	elif Input.is_action_pressed("ui_right"):
		$Player.flip_h = false
		$AnimationPlayer.play("walk")
	
	else:
		$Player.rotation = 0
		
	velocity = input_direction * speed
