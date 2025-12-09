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

local Enemy = {
  SPAWNED = hash("enemy_spawned"),
  KILLED = hash("enemy_killed"),
}

local Stager = {
  STAGE_ENDED = hash("stage_ended"),
  WAVE_STARTED = hash("wave_started"),
  WAVE_ENDED = hash("wave_ended"),
  ENEMY_KILLED = hash("enemy_killed"),
}

local Game = {
  OPEN_DOOR = hash("open_door"),
  DISABLE_SPAWNER = hash("disable_spawner"),
}

return {
  Camera = Camera,
  Enemy = Enemy,
  Game = Game,
  Player = Player,
  Stager = Stager,
  -- Globals
  APPLY_DAMAGE = hash("apply_damage"),
  STATE_TRANSITION = hash("state_transition"),
}
