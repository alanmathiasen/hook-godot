class_name State extends Node
 
signal transitioned(new_state_name: StringName)
 
func Enter() -> void:
  pass
	
func Exit() -> void:
  pass
	
func Process(delta: float) -> void:
  pass
 
func PhysicsProcess(delta: float) -> void:
  pass

func ProcessInput(event: InputEvent) -> void:
  pass