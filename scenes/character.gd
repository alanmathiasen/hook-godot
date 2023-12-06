extends CharacterBody2D

enum HookStates {NONE, EXTEND, HOOKED, JUST_RELEASED}

const SPEED = 300.0
const JUMP_VELOCITY = -500.0
const SWING_SPEED : float = 0.01 # Adjust the swing speed as needed
const HOOK_SPEED = 1000.0

var swing_angle := 1.0
@export var gravity := 2000
var hook_state := HookStates.NONE
var prev_position
var hook_position := Vector2.ZERO
var hook_length = 0.0
var hook_right_direction = Vector2(1, -1)
var hook_left_direction = Vector2(-1, -1)
var last_swing_velocity := Vector2.ZERO
var angular_acceleration = 0.0
var angular_velocity = 0.0

# TODO this is just testing, delete
var angle = 0

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
	if(is_on_floor()):
		if direction != 0:
			velocity.x = direction * SPEED
			if direction > 0:
				last_looking_right = true
			elif direction < 0:
				last_looking_right = false
		else:
				velocity.x = move_toward(velocity.x, 0, SPEED)
	else:
			if direction != 0:
				velocity.x = direction * SPEED / 2
				if direction > 0:
					last_looking_right = true
				elif direction < 0:
					last_looking_right = false 

		
	# Handle Jump.
	if Input.is_action_just_pressed("ui_up") and is_on_floor():
		velocity.y = JUMP_VELOCITY

func handle_hook(delta):
	if Input.is_action_just_released("hook"):
		velocity = Vector2(last_swing_velocity.x, -last_swing_velocity.y)
		hook_state = HookStates.NONE
		hide_hook()

	elif Input.is_action_just_pressed("hook") and hook_state == HookStates.NONE:
		extend_hook()
		velocity.y = 0

	if hook_state == HookStates.NONE:
		hide_hook()
		
	if(hook_state == HookStates.EXTEND or hook_state == HookStates.HOOKED):
		move_hook(delta)

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
	if hook_state == HookStates.EXTEND:
		if last_looking_right:
			hook.position += hook_right_direction * HOOK_SPEED * delta 
		else: 
			hook.position += hook_left_direction * HOOK_SPEED * delta
	elif hook_state == HookStates.HOOKED:
		swing(delta)

func _on_hook_body_entered(body):
	if(body.get_collision_layer() == 2 and hook_state == HookStates.EXTEND):
		hook_state = HookStates.HOOKED
		hook_position = hook.global_position
		hook_length = global_position.distance_to(hook_position)
		angular_velocity += velocity.length() * 0.001

func _on_hook_body_exited(_body:Node2D):
	angle = 0
	pass

func swing(delta):
	
	# last_swing_velocity = Vector2(0, 0)
	if (angle == 0):
		if last_looking_right:
			angle	= deg_to_rad(315) 
			angular_velocity += 1
			
		else: 
			angle	= deg_to_rad(45)
			angular_velocity += -1
			

	angle += angular_velocity * delta
	global_position = hook.global_position + Vector2(hook_length*sin(angle), hook_length*cos(angle))
	last_swing_velocity = Vector2(hook_length * angular_velocity * cos(angle), hook_length * angular_velocity * sin(angle))
	if last_looking_right:
		if(angle > deg_to_rad(450)):
			hook_state = HookStates.NONE 
			velocity = last_swing_velocity
			

	else:
		if(angle < deg_to_rad(-180)):
			hook_state = HookStates.NONE
			# velocity = last_swing_velocity
			velocity = last_swing_velocity
			

