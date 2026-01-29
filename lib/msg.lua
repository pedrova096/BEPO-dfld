local Player = {
  MOVE_PRESSED = hash("move_pressed"),
  MOVE_RELEASED = hash("move_released"),
  TARGET_ENEMIES = hash("target_enemies"),
}

local Weapon = {
  FORCE_RELOAD = hash("force_reload"),
  SET_DIRECTION = hash("set_direction"),
  LIB_FIRE_WEAPON = hash("lib_fire_weapon"),
  LIB_RELOAD_COMPLETED = hash("lib_reload_completed"),
  LIB_RELOAD_STARTED = hash("lib_reload_started"),
  RELEASE_WEAPON = hash("release_weapon"),
  SET_PROPERTIES = hash("set_properties"),
  TRIGGER_WEAPON = hash("trigger_weapon"),
  WEAPON_CONFIG_QUERY = hash("weapon_config_query"),
  WEAPON_CONFIG_RESPONSE = hash("weapon_config_response"),
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
  OPEN_DOOR = hash("open_door"),
  ENTER_DOOR = hash("enter_door"),
}

local Game = {
  DISABLE_SPAWNER = hash("disable_spawner"),
  PLAYER_SET_LIFE_COUNT = hash("player_set_life_count"),
  PLAYER_LIFE_CHANGED = hash("player_life_changed"),
  SHOW_WIPE = hash("show_wipe"),
}

local Attacker = {
  PREPARE = hash("attacker_prepare"),
  ATTACK = hash("attacker_attack"),
  RECOVER = hash("attacker_recover"),
  COOLDOWN = hash("attacker_cooldown"),
  SET_DIRECTION = hash("attacker_set_direction"),
  RESET = hash("attacker_reset")
}

local Main = {
  GAME_OVER = hash("game_over"),
  NEW_GAME = hash("new_game")
}

return {
  Attacker = Attacker,
  Bullet = Bullet,
  Camera = Camera,
  Enemy = Enemy,
  Game = Game,
  Main = Main,
  Player = Player,
  Stager = Stager,
  Weapon = Weapon,
  -- Globals
  APPLY_DAMAGE = hash("apply_damage"),
  COLLISION_RESPONSE = hash("collision_response"),
  HIDE_ELEMENT = hash("hide_element"),
  PROXY_LOADED = hash("proxy_loaded"),
  PROXY_UNLOADED = hash("proxy_unloaded"),
  SHOW_ELEMENT = hash("show_element"),
  STATE_TRANSITION = hash("state_transition"),
  TRIGGER_RESPONSE = hash("trigger_response"),
}
