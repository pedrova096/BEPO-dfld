local Player = {
  -- events
  MOVE_PRESSED = hash("move_pressed"),
  MOVE_RELEASED = hash("move_released"),
  -- commands
  SET_TARGET_ENEMIES = hash("set_target_enemies"),
  APPLY_UPGRADE = hash("apply_upgrade"),
}

local Weapon = {
  -- events
  FIRED = hash("weapon_fired"),
  RELOAD_COMPLETED = hash("weapon_reload_completed"),
  RELOAD_STARTED = hash("weapon_reload_started"),
  CONFIG_RECEIVED = hash("weapon_config_received"),
  -- commands
  FORCE_RELOAD = hash("force_reload"),
  SET_DIRECTION = hash("set_direction"),
  STOP_FIRING = hash("stop_firing"),
  SET_PROPERTIES = hash("set_properties"),
  FIRE = hash("fire"),
  REQUEST_CONFIG = hash("request_weapon_config"),
}

local Camera = {
  -- commands
  SHAKE = hash("camera_shake"),
  STOP_SHAKE = hash("stop_camera_shake"),
  FOLLOW = hash("follow_camera_target"),
  UNFOLLOW = hash("unfollow_camera_target"),
}

local Enemy = {
  -- commands
  ACTIVATE_ENEMY = hash("activate_enemy"),
  -- events
  ENEMY_KILLED = hash("enemy_killed"),
  CONFIRM_ENEMY_DESPAWN = hash("confirm_enemy_despawn"),
}

local Bullet = {
  -- events
  FIRED = hash("bullet_fired"),
  HIT = hash("bullet_hit"),
  FINISHED = hash("bullet_finished"),
}

local Stager = {
  -- events
  -- STAGE_ENDED = hash("stage_ended"),
  -- WAVE_STARTED = hash("wave_started"),
  -- WAVE_ENDED = hash("wave_ended"),
  DOOR_ENTERED = hash("door_entered"),
  -- commands
  LOAD_STAGE = hash("load_stage"),
  OPEN_DOORS = hash("open_doors"),
}

local Game = {
  -- events
  PLAYER_LIFE_CHANGED = hash("player_life_changed"),
  PERROCOIN_PICKED = hash("perrocoin_picked"),
  PERROCOIN_EXPIRED = hash("perrocoin_expired"),
  -- commands
  DISABLE_SPAWNER = hash("disable_spawner"),
  PLAYER_SET_LIFE_COUNT = hash("player_set_life_count"),
  START_RUN = hash("start_run"),
  AUTO_COLLECT_POINT = hash("auto_collect_point"),
  OPEN_UPGRADER = hash("open_upgrader"),
  PROCESS_PLAYER_UPGRADE = hash("process_player_upgrade")
}

local Attacker = {
  -- commands
  START_WINDUP = hash("start_attack_windup"),
  START_ATTACK = hash("start_attack"),
  START_RECOVERY = hash("start_attack_recovery"),
  START_COOLDOWN = hash("start_attack_cooldown"),
  SET_DIRECTION = hash("attacker_set_direction"),
  RESET = hash("attacker_reset")
}

local Main = {
  -- events
  GAME_OVER = hash("game_over"),
  RUN_ENDED = hash("run_ended"),
  -- commands
  START_NEW_GAME = hash("start_new_game")
}

local Sound = {
  -- commands
  PLAY_SFX_SOUND = hash("play_sfx_sound"),
  STOP_SFX_SOUND = hash("stop_sfx_sound"),
  STOP_ALL_SFX = hash("stop_all_sfx"),
  MUTE = hash("sound_mute"),
  UNMUTE = hash("sound_unmute"),
}

local Wave = {
  -- events
  WAVE_STARTED = hash("wave_started"),
  STAGE_COMPLETED = hash("stage_completed"),
}

local UI = {
  -- events
  LIFE_CHANGED = hash("life_changed"), -- Split into added or removed
  -- commands
  ENABLE_MOVE = hash("enable_move"),
  DISABLE_MOVE = hash("disable_move"),
  ENABLE_BUTTON_ACTION = hash("enable_button"),
  DISABLE_BUTTON_ACTION = hash("disable_button"),
  SHOW_WIPE = hash("show_wipe"),
  SET_LIFE_NODES = hash("set_life_nodes"),
  SHOW_SHOP_MODAL = hash("show_shop_modal"),
}

return {
  Attacker = Attacker,
  Bullet = Bullet,
  Camera = Camera,
  Enemy = Enemy,
  Game = Game,
  Main = Main,
  Player = Player,
  Sound = Sound,
  Stager = Stager,
  UI = UI,
  Wave = Wave,
  Weapon = Weapon,
  -- global events
  COLLISION_OCCURRED = hash("collision_response"),
  PROXY_LOADED = hash("proxy_loaded"),
  PROXY_UNLOADED = hash("proxy_unloaded"),
  STATE_CHANGED = hash("state_changed"),
  TRIGGER_OCCURRED = hash("trigger_response"),
  -- global commands
  APPLY_DAMAGE = hash("apply_damage"),
  HIDE_ELEMENT = hash("hide_element"),
  SHOW_ELEMENT = hash("show_element"),
}
