extends RewindableState
@export var character: CharacterBody2D
@export var input: PlayerInput
@export var speed = 300.0

@export var animation_name: String

func display_enter(_previous, _t):
	character.modulate = Color.RED

func tick(delta, tick, is_fresh):
	character.velocity = input.movement * speed
	character.velocity *= NetworkTime.physics_factor

	character.move_and_slide()
	character.velocity /= NetworkTime.physics_factor
	
	if input.jump:
		state_machine.transition(&"Jump")
	elif input.movement == Vector2.ZERO:
		state_machine.transition(&"Idle")
