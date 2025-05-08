extends RewindableState

@export var character: CharacterBody2D
@export var input: PlayerInput

var jump_cooldown_ticks = 180  # Equivalent to 1 second at 60 FPS
var jump_ticks_remaining = 0

func display_enter(_previous, _t):
	character.modulate = Color.BLUE

func enter(state, ticks):
	jump_ticks_remaining = jump_cooldown_ticks # reset the ticks


func tick(delta, tick, is_fresh):
	if jump_ticks_remaining > 0:
		jump_ticks_remaining -= 1
	else:
		print("exiting jump state")
		state_machine.transition(&"Idle")
