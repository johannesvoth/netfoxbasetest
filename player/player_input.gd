extends Node
class_name PlayerInput

var movement = Vector2.ZERO
var jump_intent = false

func _ready():
	NetworkTime.before_tick_loop.connect(_gather)

func _gather():
	if not is_multiplayer_authority():
		return
	
	movement = Input.get_vector("left", "right", "up", "down")
