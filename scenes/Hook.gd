extends Area2D


enum HookStates {NONE, EXTEND, HOOKED, JUST_RELEASED}


signal hook_just_released


const HOOK_SPEED = 1000.0
const HOOK_DIRECTION_RIGHT = Vector2(1, -1)
const HOOK_DIRECTION_LEFT = Vector2(-1, -1)
const HOOK_COLLISION_LAYER = 2

@onready var line := $Line2D
@onready var character := get_parent()

var state := HookStates.NONE
var previous_state := HookStates.NONE
var release_direction := Vector2.ZERO

var is_hooked := false
var hook_position := Vector2.ZERO
var hook_length := 0.0

#var last_swing_velocity := Vector2.ZERO


func _ready():
	line.points[0] = Vector2.ZERO
	self.hide()
	

func _input(event):
  # si se apreto el boton de hook
	if event.is_action_pressed('hook'):
		# si no se esta extendiendo ni esta enganchado
		if state == HookStates.NONE:
			# hacer la direccion del hook igual a la del personaje
			release_direction = HOOK_DIRECTION_RIGHT if character.facing_direction == 1 else HOOK_DIRECTION_LEFT
			# hacer el estado de hook extendiendo
			change_state(HookStates.EXTEND)
		elif state == HookStates.HOOKED:
			# si no llamar la funcion que resetea el hook
			is_hooked = false
			reset_hook()
		else: 
			reset_hook()


func _physics_process(delta):
	line.points[1] = to_local(character.global_position)
	match state:
		HookStates.EXTEND:
			extend_hook(delta)
		HookStates.HOOKED:
			if previous_state != HookStates.HOOKED:
				print('fix hook')
				fix_hook()
		HookStates.NONE:
			if previous_state != HookStates.NONE and previous_state != HookStates.HOOKED:
				print('reset hook')
				reset_hook()


func extend_hook(delta):
	self.show()
	line.show()
	# move hook
	global_position += release_direction * HOOK_SPEED * delta
  

func _on_hook_body_entered(body:Node2D):
	if body.get_collision_layer() == HOOK_COLLISION_LAYER and not state == HookStates.HOOKED:
		change_state(HookStates.HOOKED)
		# var direction_to_hook = (global_position - character.global_position).normalized()
		# print(direction_to_hook)
		# character.swing_velocity = character.velocity.dot(direction_to_hook) * direction_to_hook
		
func fix_hook():    
	var hook_global_position = global_transform.origin
	character.remove_child(self)
	character.get_tree().root.add_child(self)
	self.global_position = hook_global_position
	change_state(HookStates.HOOKED)
	

func reset_hook():
	character.get_tree().root.remove_child(self)
	character.add_child(self) 
	global_position = character.global_position
	change_state(HookStates.NONE)
	self.hide()
	line.hide()
	global_transform.origin = character.global_position
	print('hook reset', state)
	if state == HookStates.HOOKED:
		hook_just_released.emit()


func draw_line_to_character():
	line.points[1] = to_local(character.global_position)

func change_state(new_state):
	previous_state = state
	state = new_state
