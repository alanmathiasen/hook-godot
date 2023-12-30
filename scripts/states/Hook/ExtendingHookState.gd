class_name ExtendingHookState extends State

const HOOK_DIRECTION_RIGHT = Vector2(cos(deg_to_rad(-45)), sin(deg_to_rad(-45)))
const HOOK_DIRECTION_LEFT = Vector2(cos(deg_to_rad(-135)), sin(deg_to_rad(-135)))
const HOOK_SPEED = 2000.0
const HOOK_COLLISION_LAYER = 2

@export var hook: Area2D
@export var line: Line2D
@export var character: CharacterBody2D

var release_direction


func Enter():
	hook.connect("body_entered", _on_hook_body_entered)

	hook.show()
	line.show()
	release_direction = HOOK_DIRECTION_RIGHT if character.facing_direction == 1 else HOOK_DIRECTION_LEFT
	line.points[0] = Vector2.ZERO

func ProcessInput(event):
	var is_hook_released = event.is_action_released('hook')
	if is_hook_released:
		transitioned.emit('IdleHookState')

func PhysicsProcess(delta):
	hook.global_position += release_direction * HOOK_SPEED * delta
	line.points[1] = hook.to_local(character.global_position)

func Exit():
	hook.disconnect("body_entered", _on_hook_body_entered)


func _on_hook_body_entered(body):
	if body.get_collision_layer() == HOOK_COLLISION_LAYER:
		# transitioned.call_deferred('emit', 'HookedHookState')
		transitioned.emit('HookedHookState')
