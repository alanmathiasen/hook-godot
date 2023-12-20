extends CharacterBody2D

enum HookStates {NONE, EXTEND, HOOKED, JUST_RELEASED}

@onready var hook = $Hook

var speed := 400
var gravity := 400
var jump_force = 400
var facing_direction := 1
var swing_velocity := 0.0

var angle_to_hook
var distance_to_hook

var angular_velocity := 0.0
var angular_acceleration := 0.0
var linear_velocity := 0.0

var velocity_arrow = Vector2.ZERO


func _physics_process(delta):
	# print(velocity)
	handle_hook(delta)
	handle_movement(delta)
	move_and_slide()
	queue_redraw()
	

 
func handle_movement(delta):
	var direction = Input.get_axis("ui_left", "ui_right")
	if not is_on_floor():
		velocity.y += gravity * delta
	if direction != 0 and hook.state != HookStates.HOOKED:
		velocity.x = speed * direction
		facing_direction = 1 if direction > 0 else -1
	else:
		velocity.x = move_toward(velocity.x, 0, 13)
	if is_on_floor() and Input.is_action_just_pressed("ui_up"):
		velocity.y = -jump_force


func handle_hook(delta):
	if(hook.state == HookStates.HOOKED):
		#add_angular_velocity(facing_direction * 0.1)
		linear_velocity = angular_velocity * distance_to_hook
		process_velocity(delta)

func _on_hook_body_entered(_body):
	distance_to_hook = self.global_position.distance_to(hook.global_position)
	if facing_direction == 1:
		angle_to_hook = hook.get_angle_to(self.global_position)
	else:		
		angle_to_hook = self.get_angle_to(hook.global_position)
		

func process_velocity(delta:float)->void:
	angular_acceleration = 2 * delta#((-gravity*delta) / distance_to_hook) * sin(angle_to_hook)
	if facing_direction == 1:
		angular_velocity += angular_acceleration
	else:
		angular_velocity -= angular_acceleration

	angle_to_hook += angular_velocity * 0.01
	# print(rad_to_deg(angle_to_hook))
	# print('hook.global_position ', hook.global_position)
	# print('el resto ', Vector2(distance_to_hook * cos(angle_to_hook), distance_to_hook * sin(angle_to_hook)))
	self.global_position = hook.global_position - Vector2(distance_to_hook * sin(angle_to_hook), distance_to_hook * cos(angle_to_hook))
	

func add_angular_velocity(force:float)->void:
	angular_velocity += force

func _on_hook_just_released():
	var release_speed = linear_velocity
	velocity.x = -release_speed * cos(angle_to_hook) * 1
	velocity.y = 0
	velocity.y = release_speed * sin(angle_to_hook)
	# velocity.x -= linear_velocity * cos(angle_to_hook)
	# velocity.y += linear_velocity * sin(angle_to_hook)
	# Adjust the y component of the velocity
	var adjustment_factor = 1 / abs(velocity.y - 1) + 1
	velocity.y /= adjustment_factor * 2

	# print(rad_to_deg(angle_to_hook), 'sine', linear_velocity,  sin(angle_to_hook))
	angular_velocity = 0.0
	# print('velocity', velocity)

func _draw():
	draw_line(Vector2.ZERO, velocity, Color.GREEN, 2.0)
