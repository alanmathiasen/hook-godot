extends CharacterBody2D

enum HookStates {NONE, EXTEND, HOOKED}

const SPEED = 300.0
const JUMP_VELOCITY = -800.0
const SWING_SPEED : float = 0.001 # Adjust the swing speed as needed

const HOOK_SPEED = 1000.0
const HOOK_SWING_RADIUS : float = 1.0  # Adjust the swing radius as needed
var swing_angle : float = 1
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var hook_state: HookStates = HookStates.NONE
var prev_position
var hook_position : Vector2 = Vector2.ZERO
var hook_length = 0.0
var hook_right_direction = Vector2(cos(deg_to_rad(315)), sin(deg_to_rad(315)))
var hook_left_direction = Vector2(cos(deg_to_rad(225)), sin(deg_to_rad(225)))

var is_first := true
var last_looking_right = true

@onready var hook := $"../Hook"
@onready var line := $Line2D

func _ready():
	prev_position = global_position


func _physics_process(delta):
	prev_position = global_position
	line.points[0] = Vector2.ZERO
	handle_character_movement(delta)
	handle_hook(delta)
	move_and_slide()

func handle_character_movement(delta):
	# Add the gravity.
	if not is_on_floor() and hook_state != HookStates.HOOKED:
		velocity.y += gravity * delta
	# Handle movement inputs.
	# if hook_state == HookStates.HOOKED:
	# 	velocity.y += 200
	# 	hook.global_position = hook_position
	var direction = Input.get_axis("ui_left", "ui_right")
	if direction != 0:
		velocity.x = direction * SPEED
		if direction > 0:
			last_looking_right = true
		elif direction < 0:
			last_looking_right = false
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	# Handle Jump.
	if Input.is_action_just_pressed("ui_up") and is_on_floor():
		velocity.y = JUMP_VELOCITY


func handle_hook(delta):
	if Input.is_action_just_released("hook"):
		hide_hook()
	elif Input.is_action_just_pressed("hook") and hook_state == HookStates.NONE:
		extend_hook()
	if(hook_state == HookStates.EXTEND or hook_state == HookStates.HOOKED):
		move_hook(delta)
	if Input.is_action_pressed("hook") and hook_state == HookStates.HOOKED:
		pass
	if hook.visible:
		line.points[1] = to_local(hook.global_position)

func extend_hook():
	hook.global_position = global_position
	hook_state = HookStates.EXTEND
	hook.show()
	line.show()

func hide_hook():
	hook_state = HookStates.NONE
	hook.hide()
	line.hide()

func move_hook(delta):
	var distance_travelled = global_position.distance_to(prev_position)
	print(distance_travelled)
	if hook_state == HookStates.EXTEND:
		if last_looking_right:
			hook.global_position += hook_right_direction * HOOK_SPEED * delta
		else: 
			hook.global_position += hook_left_direction * HOOK_SPEED * delta
		# hook.global_position += last_looking_right ? hook_right_direction * HOOK_SPEED * delta : hook_left_direction * HOOK_SPEED * delta 
	elif hook_state == HookStates.HOOKED:
		swing(delta)
	# 	print('hola')
	# 	# Calculate the direction from the player to the hooked position
	# 	var direction_to_hook = (hook_position - global_position).normalized()
	# 	# Rotate the direction to create a swinging effect
	# 	var rotated_direction = direction_to_hook.rotated(swing_angle)
	# 	# Update the player's position based on the hooked position and swinging
	# 	global_position += rotated_direction * SWING_SPEED * delta
	# 	# Increment the swing angle for the next frame
	# 	#swing_angle += SWING_SPEED * delta

func _on_hook_body_entered(body):
	if(body.get_collision_layer() == 2 and hook_state == HookStates.EXTEND and is_first):
		print(is_first)
		is_first = false
		hook_state = HookStates.HOOKED
		hook_position = hook.global_position
		hook_length = global_position.distance_to(hook_position)

func _on_hook_body_exited(_body:Node2D):
	print('g')
	is_first = true

func swing(delta):
	var direction_to_hook = (hook_position - global_position).normalized()
	var rotated_direction
	var acceleration = hook_length * delta * 100
	if last_looking_right:
		rotated_direction = direction_to_hook.rotated(deg_to_rad(-HOOK_SWING_RADIUS))
	else:
		rotated_direction = direction_to_hook.rotated(deg_to_rad(HOOK_SWING_RADIUS))
	global_position = hook_position - rotated_direction * hook_length
	# swing_angle += SWING_SPEED * delta  # Increment the swing angle
