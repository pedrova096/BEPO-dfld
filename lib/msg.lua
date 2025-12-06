local Player = {
  MOVE_PRESSED = hash("move_pressed"),
  MOVE_RELEASED = hash("move_released"),
}

local Camera = {
  SHAKE = hash("camera_shake"),
  SHAKE_INTERRUPT = hash("camera_shake_interrupt"),
  CAMERA_FOLLOW = hash("camera_follow"),
  CAMERA_UNFOLLOW = hash("camera_unfollow"),
}

return {
  Player = Player,
  Camera = Camera,
  -- Globals
  APPLY_DAMAGE = hash("apply_damage"),
  STATE_TRANSITION = hash("state_transition"),
}