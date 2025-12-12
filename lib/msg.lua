local Player = {
  MOVE_PRESSED = hash("move_pressed"),
  MOVE_RELEASED = hash("move_released"),
  TARGET_ENEMIES = hash("target_enemies"),
}

local Weapon = {
  TRIGGER_WEAPON = hash("trigger_weapon"),
  FIRE_WEAPON = hash("fire_weapon"),
  RELEASE_WEAPON = hash("release_weapon"),
  SET_PROPERTIES = hash("set_properties"),
  RELOAD_STARTED = hash("reload_started"),
  RELOAD_COMPLETED = hash("reload_completed"),
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

local Bullet = {
  BULLET_FIRED = hash("bullet_fired"),
  BULLET_HIT = hash("bullet_hit"),
  BULLET_FINISHED = hash("bullet_finished"),
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
  Weapon = Weapon,
  Stager = Stager,
  Bullet = Bullet,
  -- Globals
  APPLY_DAMAGE = hash("apply_damage"),
  STATE_TRANSITION = hash("state_transition"),
  TRIGGER_RESPONSE = hash("trigger_response")
}
