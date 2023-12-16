extends Area2D

enum HookStates {NONE, EXTEND, HOOKED, JUST_RELEASED}

const HOOK_SPEED = 300.0
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
    if state != HookStates.EXTEND:
        state = HookStates.EXTEND
    else:
        reset_hook()

func _physics_process(delta):
  match state:
    HookStates.EXTEND:
      extend_hook(delta)

func extend_hook(delta):
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



func _on_hook_body_entered(body:Node2D):
  if body.get_collision_layer() == 1:
    print('hook_length')
