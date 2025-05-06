extends CharacterBody2D

@export var speed = 400
@export var input: PlayerInput

func _rollback_tick(delta, tick, is_fresh):
	velocity = input.movement * speed
	velocity *= NetworkTime.physics_factor

	move_and_slide()
	velocity /= NetworkTime.physics_factor
