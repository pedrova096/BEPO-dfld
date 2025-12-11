-- Baseline, tune values during gameplay balancing.

local BulletConfigs = {
  Pistol = { speed = 210, force = 1 },
  Shotgun = { speed = 210, force = 0.6 },
  Sniper = { speed = 450, force = 2, penetrate = 2 },
  MachineGun = { speed = 250, force = 0.9 },
  Rocket = { speed = 175, force = 3, explode = 1, explode_radius = 42 },
  Laser = { speed = 0, force = 0.2, beam = 1, beam_length = 200 },
  Plasma = { speed = 260, force = 1.1, energy = 1, energy_consumption = 0.1 },
}

---@type ShotgunWeaponConfig
local ShotgunWeaponConfig = {
  fire_interval = 0.83, -- ~1.2 shots/sec
  ammo_capacity = 6,
  reload_time = 1.6,
  range = 220,
  accuracy = 0.65,
  pellets = 6,
  spread = 18,
  bullet_config = BulletConfigs.Shotgun,
}

local WeaponConfigs = {
  Pistol = {
    fire_interval = 0.4, -- 2.5 shots/sec
    ammo_capacity = 12,
    reload_time = 1.2,
    range = 300,
    accuracy = 0.9,
    bullet_config = BulletConfigs.Pistol,
  },
  Shotgun = ShotgunWeaponConfig,
  Sniper = {
    fire_interval = 1.25, -- 0.8 shots/sec
    ammo_capacity = 4,
    reload_time = 2.2,
    range = 900,
    accuracy = 0.98,
    bullet_config = BulletConfigs.Sniper,
  },
  MachineGun = {
    fire_interval = 0.11, -- ~9 shots/sec
    ammo_capacity = 40,
    reload_time = 2.4,
    range = 360,
    accuracy = 0.72,
    bullet_config = BulletConfigs.MachineGun,
  },
  RocketLauncher = {
    fire_interval = 1.11, -- ~0.9 shots/sec
    ammo_capacity = 3,
    reload_time = 2.8,
    range = 420,
    accuracy = 0.85,
    bullet_config = BulletConfigs.Rocket,
  },
  LaserRifle = {
    fire_interval = 0.17, -- ~6 shots/sec
    ammo_capacity = 16,
    reload_time = 1.9,
    range = 480,
    accuracy = 0.94,
    bullet_config = BulletConfigs.Laser,
  },
  PlasmaRifle = {
    fire_interval = 0.22, -- ~4.5 shots/sec
    ammo_capacity = 24,
    reload_time = 2.1,
    range = 420,
    accuracy = 0.9,
    bullet_config = BulletConfigs.Plasma,
  },
}

return {
  WeaponConfigs = WeaponConfigs,
  BulletConfigs = BulletConfigs,
  ShotgunWeaponConfig = ShotgunWeaponConfig,
}
