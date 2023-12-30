extends CharacterBody2D

enum HookStates {NONE, EXTEND, HOOKED, JUST_RELEASED}

const SPEED := 600
const GRAVITY := 500
const JUMP_FORCE = -600
const BREAK_SPEED = 500
const SWING_SPEED = 1.2

var facing_direction := 1
var angular_acceleration := 0.0
var angular_velocity = Vector2.ZERO
var initial_speed := 0.0
var angle_to_hook
var distance_to_hook

var velocity_arrow = Vector2.ZERO

@onready var hook = $Hook
@onready var animation = $AnimatedSprite2D
@onready var fsm = $Hook/HookStateMachine

func _physics_process(delta):
	handle_movement(delta)
	handle_hook(delta)

	move_and_slide()
	queue_redraw()
	

 
func handle_movement(delta):
	var direction = Input.get_axis("ui_left", "ui_right")

	if direction != 0:
		if is_on_floor():
			animation.play('walk')
		velocity.x = calculate_velocity(direction)
		facing_direction = 1 if direction > 0 else -1
	elif is_on_floor():
		velocity.x = move_toward(velocity.x, 0, delta * 10)
		animation.stop()

	if not is_on_floor():
		velocity.y += GRAVITY * delta
	elif Input.is_action_just_pressed("ui_up"):
			velocity.y += JUMP_FORCE
		

func handle_hook(delta):
	var hook_state = fsm.get_current_state().name

	if hook_state == 'HookedHookState':
		process_velocity(delta)
	for index in get_slide_collision_count():
		var collision := get_slide_collision(index)
		var body := collision.get_collider()
		

func process_velocity(delta:float)->void:
	angular_acceleration = ((GRAVITY * delta) / distance_to_hook) * -facing_direction 
	angle_to_hook -= (angular_acceleration * delta + initial_speed) * delta * SWING_SPEED
	var new_pos = hook.global_position + Vector2(distance_to_hook * cos(angle_to_hook), distance_to_hook * sin(angle_to_hook))
	var old_pos = self.global_position
	self.global_position = new_pos
	angular_velocity = (self.global_position - old_pos) / delta


func _on_hook_body_entered(_body):
	distance_to_hook = self.global_position.distance_to(hook.global_position)
	if facing_direction == 1:
		angle_to_hook = hook.get_angle_to(self.global_position)
	else:		
		angle_to_hook = hook.get_angle_to(self.global_position)
	initial_speed = vel_to_ang(velocity, distance_to_hook)


func _on_hook_just_released():
	print(angular_velocity)
	velocity += angular_velocity
	angular_velocity = Vector2.ZERO 
	var adjustment_factor = (1 / abs(velocity.y - 1) + 1) 
	velocity.y /= adjustment_factor 
	

func _draw():
	# draw_line(Vector2.ZERO, linear_velocity, Color.RED, 2.0)
	draw_line(Vector2.ZERO, velocity, Color.GREEN, 2.0)
	draw_line(Vector2.ZERO, angular_velocity, Color.BLUE, 2.0)
	# draw_circle(hook.global_position, 10, Color.RED)
	# var xPos = cos(self.get_angle_to(hook.global_position))
	# var yPos = sin(self.get_angle_to(hook.global_position))
	# draw_circle(Vector2(xPos, yPos) * distance_to_hook, 10, Color.RED)

func vel_to_ang(vel: Vector2, radius: float) -> float:
		if radius == 0:
				print("Error: Radius cannot be zero.")
				return 0

		# Calculate the speed from the velocity vector
		var angular_speed = vel.length()
		# Calculate the angular velocity


		return (angular_speed / radius) * facing_direction


func calculate_velocity(direction):
	var target_velocity = SPEED * direction
	var interpolation_speed = 0.025  # Adjust this value to change the rate of interpolation
	return lerp(velocity.x, target_velocity, interpolation_speed)
