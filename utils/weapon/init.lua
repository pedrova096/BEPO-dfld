local Weapon = require("utils.weapon.weapon")
local ShotgunWeapon = require("utils.weapon.shotgun_weapon")
local Configs = require("utils.weapon.configs")
local BulletPool = require("utils.weapon.bullet_pool")

return {
  Weapon = Weapon,
  ShotgunWeapon = ShotgunWeapon,
  WeaponConfigs = Configs.WeaponConfigs,
  BulletConfigs = Configs.BulletConfigs,
  BulletPool = BulletPool,
}
