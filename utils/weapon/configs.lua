local WeaponIds = {
  Pistol = hash("Pistol"),
  Rifle = hash("Rifle"),
  Shotgun = hash("Shotgun"),
}

local BulletConfigs = {
  [WeaponIds.Pistol] = { speed = 100, force = 8 },
  [WeaponIds.Rifle] = { speed = 140, force = 10 },
  [WeaponIds.Shotgun] = { speed = 120, force = 8 },
}

---@type ShotgunWeaponConfig
local ShotgunWeaponConfig = {
  fire_interval = 0.83, -- ~1.2 shots/sec
  ammo_capacity = 8,
  reload_time = 1.5,
  range = 220,
  accuracy = 0.7,
  bullet_damage = 1,
  pellets = 4,
  spread = 40,
  pellet_spawn_width = 10,
  bullet_config = BulletConfigs[WeaponIds.Shotgun],
}

local Configs = {
  [WeaponIds.Pistol] = {
    fire_interval = 0.4, -- 2.5 shots/sec
    ammo_capacity = 1,
    reload_time = 1.2,
    range = 300,
    accuracy = 0.9,
    bullet_damage = 1,
    bullet_config = BulletConfigs[WeaponIds.Pistol],
  },
  [WeaponIds.Rifle] = {
    fire_interval = 0.25, -- 4 shots/sec
    ammo_capacity = 4,
    reload_time = 1.5,
    range = 420,
    accuracy = 0.78,
    bullet_damage = 1,
    bullet_config = BulletConfigs[WeaponIds.Rifle],
  },
  [WeaponIds.Shotgun] = ShotgunWeaponConfig,
}

return {
  WeaponIds = WeaponIds,
  Configs = Configs,
  BulletConfigs = BulletConfigs,
}
