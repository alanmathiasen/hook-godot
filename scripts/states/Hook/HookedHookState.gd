class_name HookedHookState extends HookState

var has_entered = false

func Enter():
	if not has_entered:
		var hook_global_position = hook.global_position
		line.points[0] = Vector2.ZERO
		character.remove_child(hook)
		character.get_tree().root.add_child(hook)
		hook.global_position = hook_global_position
		has_entered = true
	
func Exit():
	character.get_tree().root.remove_child(hook)
	character.add_child(hook) 
	has_entered = false


func ProcessInput(event):
	var is_hook_released = event.is_action_released('hook')
	if is_hook_released:
		transitioned.emit('IdleHookState')

func PhysicsProcess(_delta):
	line.points[1] = hook.to_local(character.global_position)
