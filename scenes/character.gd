extends CharacterBody2D

enum HookStates {NONE, EXTEND, HOOKED, JUST_RELEASED}

const SPEED := 600
const GRAVITY := 800
const JUMP_FORCE = -600
const BREAK_SPEED = 500
const SWING_SPEED = 10
var facing_direction := 1
var swing_velocity := 0.0

var angle_to_hook
var distance_to_hook

var angular_velocity := 0.0
var angular_acceleration := 0.0
var linear_velocity := 0.0

var velocity_arrow = Vector2.ZERO

@onready var hook = $Hook

func _physics_process(delta):

	# print('hook to character: ', rad_to_deg(hook.get_angle_to(self.global_position)))
	# print('character to hook: ', rad_to_deg(self.get_angle_to(hook.global_position)))
	handle_movement(delta)
	handle_hook(delta)

	move_and_slide()
	queue_redraw()
	

 
func handle_movement(delta):
	var direction = Input.get_axis("ui_left", "ui_right")

	if direction != 0 and hook.state != HookStates.HOOKED:
		var target_velocity = SPEED * direction
		var interpolation_speed = 0.025  # Adjust this value to change the rate of interpolation
		velocity.x = lerp(velocity.x, target_velocity, interpolation_speed)
		facing_direction = 1 if direction > 0 else -1
	elif is_on_floor():
		velocity.x = move_toward(velocity.x, 0, delta * BREAK_SPEED)

	if not is_on_floor():
		velocity.y += GRAVITY * delta
	elif Input.is_action_just_pressed("ui_up"):
			velocity.y += JUMP_FORCE
		

func handle_hook(delta):
	if(hook.state == HookStates.HOOKED):
		#add_angular_velocity(facing_direction * 0.1)
		linear_velocity = angular_velocity * distance_to_hook
		process_velocity(delta)
		

func process_velocity(delta:float)->void:
	# print('angle to hook ', rad_to_deg(angle_to_hook))
	# print('sin ',sin(angle_to_hook))
	angular_acceleration = ((-GRAVITY*delta) / distance_to_hook) * sin(angle_to_hook)
	# print(angular_acceleration)

	if facing_direction == 1:
		angular_velocity += angular_acceleration
	else:
		angular_velocity -= angular_acceleration

	angle_to_hook += deg_to_rad(angular_velocity)
	# print(rad_to_deg(angle_to_hook))
	# print(rad_to_deg(angle_to_hook))
	# print('hook.global_position ', hook.global_position)
	# print('el resto ', Vector2(distance_to_hook * cos(angle_to_hook), distance_to_hook * sin(angle_to_hook)))
	self.global_position = hook.global_position - Vector2(distance_to_hook * sin(angle_to_hook), distance_to_hook * cos(angle_to_hook))
	

func add_angular_velocity(force:float)->void:
	angular_velocity += force



func _on_hook_body_entered(_body):
	distance_to_hook = self.global_position.distance_to(hook.global_position)
	if facing_direction == 1:
		angle_to_hook = hook.get_angle_to(self.global_position)
		print('135-->', rad_to_deg(angle_to_hook))
	else:		
		angle_to_hook = self.get_angle_to(hook.global_position)
		print('45-->', rad_to_deg(angle_to_hook))

	angular_velocity = vel_to_ang(self.velocity, distance_to_hook)


func _on_hook_just_released():
	var release_speed = linear_velocity
	velocity.x = -release_speed * cos(angle_to_hook) * 1.2
	velocity.y = release_speed * sin(angle_to_hook)
	# velocity.x -= linear_velocity * cos(angle_to_hook)
	# velocity.y += linear_velocity * sin(angle_to_hook)
	# Adjust the y component of the velocity
	var adjustment_factor = (1 / abs(velocity.y - 1) + 1) * 2
	velocity.y /= adjustment_factor 
	# print('angular velocity', angular_velocity)
	angular_velocity = 0.0
	# print('velocity', velocity)

func _draw():
	# draw_line(Vector2.ZERO, linear_velocity, Color.RED, 2.0)
	draw_line(Vector2.ZERO, velocity, Color.GREEN, 2.0)
	
	var xPos = cos(self.get_angle_to(hook.global_position))
	var yPos = sin(self.get_angle_to(hook.global_position))
	draw_circle(Vector2(xPos, yPos) * distance_to_hook, 10, Color.RED)

func vel_to_ang(vel: Vector2, radius: float) -> float:
		if radius == 0:
				print("Error: Radius cannot be zero.")
				return 0

		# Calculate the speed from the velocity vector
		var angular_speed = vel.length()
		# Calculate the angular velocity


		return (angular_speed / radius) * facing_direction
