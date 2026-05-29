local Player = {
  -- commands
  MOVE = hash("player_move"),
  STOP_MOVE = hash("stop_move"),
  SET_SPECIAL_ACTION = hash("set_special_action"),
  SET_TARGET_ENEMIES = hash("set_target_enemies"),
  SET_POSITION = hash("set_position"),
  APPLY_UPGRADE = hash("apply_upgrade"),
  START_SPECIAL_ACTION = hash("start_special_action"),
  RUN_SPECIAL_ACTION = hash("run_special_action"),
  RELEASE_SPECIAL_ACTION = hash("release_special_action"),
  CANCEL_SPECIAL_ACTION = hash("cancel_special_action"),
  MOVE_SPECIAL_ACTION = hash("move_special_action"),
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
  SET_BOUNDS = hash("set_camera_bounds"),
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
  STAGE_LOADED = hash("stage_loaded"),
  STAGE_COMPLETED = hash("stage_completed"),
  -- WAVE_STARTED = hash("wave_started"),
  -- WAVE_ENDED = hash("wave_ended"),
  CONNECTION_ENTERED = hash("connection_entered"),
  -- commands
  LOAD_STAGE = hash("load_stage"),
  ENABLE_CONNECTIONS = hash("enable_connections"),
  START_STAGE = hash("start_stage"),
}

local Game = {
  -- events
  PLAYER_LIFE_CHANGED = hash("player_life_changed"),
  PERROCOIN_PICKED = hash("perrocoin_picked"),
  COG_PICKED = hash("COG_PICKED"),
  PERROCOIN_EXPIRED = hash("perrocoin_expired"),

  -- commands
  DISABLE_SPAWNER = hash("disable_spawner"),
  PLAYER_SET_LIFE_COUNT = hash("player_set_life_count"),
  START_RUN = hash("start_run"),
  LOAD_LEVEL_STAGE = hash("load_level_stage"),
  OPEN_UPGRADER = hash("open_upgrader"),
  PROCESS_PLAYER_UPGRADE = hash("process_player_upgrade"),
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

local UI = {
  -- events
  LIFE_CHANGED = hash("life_changed"), -- Split into added or removed
  WIPE_SHOWN = hash("wipe_shown"),
  WIPE_HIDDEN = hash("wipe_hidden"),
  -- commands
  ENABLE_MOVE = hash("enable_move"),
  DISABLE_MOVE = hash("disable_move"),
  ENABLE_BUTTON_ACTION = hash("enable_button"),
  DISABLE_BUTTON_ACTION = hash("disable_button"),
  SHOW_WIPE = hash("show_wipe"),
  HIDE_WIPE = hash("hide_wipe"),
  SET_LIFE_NODES = hash("set_life_nodes"),
  SHOW_SHOP_MODAL = hash("show_shop_modal"),
  SHOW_TOAST = hash("show_toast"),
  HIDE_TOAST = hash("hide_toast"),
}

local SpecialAction = {
  -- commands
  PREPARE = hash("special_action_prepare"),
  AIM = hash("special_action_aim"),
  LAUNCHED = hash("special_action_launched"),
  CANCELED = hash("special_action_canceled"),
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
  SpecialAction = SpecialAction,
  Stager = Stager,
  UI = UI,
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
  REMOVE_ELEMENT = hash("remove_element"),
  SHOW_ELEMENT = hash("show_element"),
}
