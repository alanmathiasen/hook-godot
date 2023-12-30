class_name StateMachine extends Node
 
@export var current_state: State

var states: Dictionary = {}

func _ready():
  for child in get_children():
    if child is State:
      states[child.name] = child
      child.transitioned.connect(on_child_transitioned)
    else:
      push_warning("State machine contains child which is not 'State'")    
  
  current_state.Enter()


func _process(delta):
  current_state.Process(delta)


func _physics_process(delta):
  current_state.PhysicsProcess(delta)

func _input(event):
  current_state.ProcessInput(event)

func on_child_transitioned(new_state_name: StringName) -> void:
  # Get the next state from the `Dictionary`
  var new_state = states.get(new_state_name)
  if new_state != null:
    if new_state != current_state:
			# Exit the current state
      current_state.Exit()

			# Enter the new state
      new_state.Enter()

			# Update the current state to the new one
      current_state = new_state
  else:
    push_warning("Called transition on a state that does not exist")


func get_current_state() -> State:
    return current_state
