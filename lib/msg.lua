local Player = {
  MOVE_PRESSED = hash("move_pressed"),
  MOVE_RELEASED = hash("move_released"),
  TARGET_ENEMIES = hash("target_enemies"),
  SET_SUPER_ACTION = hash("set_super_action"),
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
  SPAWN_VENDING = hash("spawn_vending"),
}

local Game = {
  AUTO_COLLECT_POINT = hash("auto_collect_point"),
  DISABLE_SPAWNER = hash("disable_spawner"),
  OPEN_VENDING = hash("open_vending"),
  PERROCOIN_EXPIRED = hash("perrocoin_expired"),
  PERROCOIN_PICKED = hash("perrocoin_picked"),
  PLAYER_COLLECT_POINT = hash("player_collect_point"),
  PLAYER_LIFE_CHANGED = hash("player_life_changed"),
  PLAYER_SET_LIFE_COUNT = hash("player_set_life_count"),
  POINT_EXPIRED = hash("point_expired"),
  UPGRADE_CHOSEN = hash("upgrade_chosen"),
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

local Sound = {
  PLAY_SFX_SOUND = hash("play_sfx_sound"),
  STOP_SFX_SOUND = hash("stop_sfx_sound"),
  STOP_ALL_SFX = hash("stop_all_sfx"),
  MUTE = hash("sound_mute"),
  UNMUTE = hash("sound_unmute"),
}

local UI = {
  ENABLE_MOVE = hash("enable_move"),
  DISABLE_MOVE = hash("disable_move"),
  ENABLE_BUTTON_ACTION = hash("enable_button"),
  DISABLE_BUTTON_ACTION = hash("disable_button"),
  SHOW_WIPE = hash("show_wipe"),
  SET_LIFE_NODES = hash("set_life_nodes"),
  LIFE_CHANGED = hash("life_changed"), -- Split into added or removed
  SHOW_SHOP_MODAL = hash("show_shop_modal"),
  UPGRADE_CHOSEN = hash("upgrade_chosen"),
}

local Vending = {
  DISAPPEAR = hash("disappear_vending"),
}

return {
  Attacker = Attacker,
  Bullet = Bullet,
  Camera = Camera,
  Vending = Vending,
  Enemy = Enemy,
  Game = Game,
  Main = Main,
  Player = Player,
  Sound = Sound,
  Stager = Stager,
  UI = UI,
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
