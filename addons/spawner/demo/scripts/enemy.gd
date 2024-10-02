extends CharacterBody2D

func _physics_process(delta):
	$Path2D/PathFollow2D.progress += 0.5
