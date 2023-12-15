extends Area2D

enum HookStates {NONE, EXTEND, HOOKED, JUST_RELEASED}

signal hook_state_changed(hook_state)

const HOOK_SPEED = 100.0
const HOOK_DIRECTION_RIGHT = Vector2(1, -1)
const HOOK_DIRECTION_LEFT = Vector2(-1, -1)

@onready var line := $Line2D
@onready var character := get_parent()

var state := HookStates.NONE
var hook_position := Vector2.ZERO
var hook_length := 0.0
var last_swing_velocity := Vector2.ZERO

func _ready():
    line.points[0] = Vector2.ZERO
    self.hide()

func _input(event):
  if event.is_action_pressed('hook'):
    hook_state_changed.emit(HookStates.EXTEND)
    pass
    if state == HookStates.EXTEND:
        reset_hook()
    else:
        state = HookStates.EXTEND

func _physics_process(delta):
  match state:
    HookStates.EXTEND:
      extend_hook(delta)

func extend_hook(delta):
  # show hook
  self.show()
  line.show()

  # move hook
  global_position += HOOK_DIRECTION_RIGHT * HOOK_SPEED * delta

  # draw line
  line.points[1] = to_local(character.global_position)
  
func reset_hook():
  self.hide()
  line.hide()
  state = HookStates.NONE
  global_position = character.global_position

