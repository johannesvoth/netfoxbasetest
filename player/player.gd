extends CharacterBody2D

@export var speed = 400
@export var input: PlayerInput

@export var state_machine: RewindableStateMachine
@onready var current_state_label: Label = $CurrentStateLabel
@onready var sprite_2d: Sprite2D = $Sprite2D


func _ready() -> void:
	state_machine.state = &"Idle"
	state_machine.on_display_state_changed.connect(func(_old_state, new_state):
		current_state_label.text = state_machine.state
		# in here, any UI stuff it seems.
	)
