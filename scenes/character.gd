extends CharacterBody2D

enum HookStates {NONE, EXTEND, HOOKED, JUST_RELEASED}

var speed := 400
var gravity := 500
var jump_force = 600
# var last_looking_right = true
var local_hook_state = HookStates.NONE

func _physics_process(delta):
	if $Hook.state == HookStates.EXTEND:
		print('hola')
	handle_movement(delta)
	move_and_slide()

func handle_movement(delta):
	var direction = Input.get_axis("ui_left", "ui_right")
	if not is_on_floor():
		velocity.y += gravity * delta
	if direction != 0:
		velocity.x = speed * direction
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
	if is_on_floor() and Input.is_action_just_pressed("ui_up"):
		velocity.y = -jump_force

func _on_hook_body_entered(body):
	if body.get_collision_layer() == 2:
		print('gancho')
		# hook_state = HookStates.HOOKED
		# hook_position = hook.global_position
		# hook_length = global_position.distance_to(hook_position)



func _on_hook_hook_state_changed(hook_state:Variant):
	local_hook_state = hook_state
	print(hook_state)
	pass # Replace with function body.
	

