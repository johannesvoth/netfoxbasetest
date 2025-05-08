extends CharacterBody2D

@export var speed = 400
@export var input: PlayerInput

@export var state_machine: RewindableStateMachine
@onready var current_state_label: Label = $CurrentStateLabel
@onready var sprite_2d: Sprite2D = $Sprite2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	state_machine.state = &"Idle"
	state_machine.on_display_state_changed.connect(func(_old_state, new_state):
		current_state_label.text = state_machine.state
		var animation_name = new_state.animation_name
		print("display state change")
		if animation_player && animation_name != "":
			print("playing animation" + animation_name)
			animation_player.play(animation_name)
	)
