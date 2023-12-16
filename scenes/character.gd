extends CharacterBody2D

enum HookStates {NONE, EXTEND, HOOKED, JUST_RELEASED}

@onready var hook = $Hook

var speed := 400
var gravity := 500
var jump_force = 600
# var last_looking_right = true

func _physics_process(delta):
	if hook.state == HookStates.EXTEND:
		pass
	if hook.state == HookStates.HOOKED:
		fix_hook()
	if hook.state == HookStates.NONE:
		reset_hook()
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
		print('alala')
		# hook_state = HookStates.HOOKED
		# hook_position = hook.global_position
		# hook_length = global_position.distance_to(hook_position)

func _on_hook_just_released():
	reset_hook()

func fix_hook():
	var hook_global_position = hook.global_transform.origin
	self.remove_child(hook)
	get_tree().root.add_child(hook)
	hook.global_transform.origin = hook_global_position

func reset_hook():
	get_tree().root.remove_child(hook)
	self.add_child(hook) 
	hook.global_position = global_position
