extends RewindableState
@export var character: CharacterBody2D
@export var input: PlayerInput

func display_enter(_previous, _t):
	character.modulate = Color.WHITE

func tick(delta, tick, is_fresh):
	
	if input.jump:
		state_machine.transition(&"Jump")
	elif input.movement != Vector2.ZERO:
		state_machine.transition(&"Move")
