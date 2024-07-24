extends Area2D

var used = false

func _on_body_entered(body):

	if body.name == "Player" and used == false:
		used = true
		$StaticBody2D/AnimatedSprite2D.play("Opening")
		

func _on_animated_sprite_2d_animation_finished():
	#$StaticBody2D/AnimatedSprite2D.play("Opened")
	$StaticBody2D/CollisionShape2D.disabled = true

