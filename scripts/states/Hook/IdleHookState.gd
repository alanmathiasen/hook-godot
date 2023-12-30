class_name IdleHookState extends State

@export var hook: Area2D
@export var line: Line2D
@export var character: CharacterBody2D

func Enter():
	hook.set_collision_layer_value(2, false)  # Disable the collision layer
	hook.set_collision_mask_value(2, false)
	hook.hide()
	line.hide()
	hook.global_position = character.global_position

func ProcessInput(event):
	var is_hook_pressed = event.is_action_pressed('hook')
	if is_hook_pressed:
		transitioned.emit('ExtendingHookState')

func Exit():
	hook.set_collision_layer_value(2, true)  # Enable the collision layer
	hook.set_collision_mask_value(2, true)
	

