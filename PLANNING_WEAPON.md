# Weapon Module

## Requirements

This module is responsible for any (player or enemy) weapon. Here's a list of considerations:
- **Bullets**: Bullets are independent, so that any weapon configuration can fire any type of bullet. Inside of the weapon, we will have a bullet pool to reuse bullets when they are finished.
- **Variations**: We will configure different type of weapons that can be used by the player or enemy. Starting, we will have the most common weapons:
  - **Pistol**: A single shot weapon.
  - **Shotgun**: A spread fire weapon.
  - **Sniper Rifle**: A long range weapon.
  - **Machine Gun**: A rapid fire weapon.
  - **Rocket Launcher**: A explosive weapon.
  - **Laser Rifle**: A beam weapon.
  - **Plasma Rifle**: A energy weapon.
  For the structure we will have a base weapon component that will be used by all the weapons
- **Weapon Properties**: We will have a set of properties that will be used to configure the weapon:
  - **Weapon Base**:
    - **Fire Rate**: The fire rate of the weapon.
    - **Ammo Capacity**: The ammo capacity of the weapon.
    - **Reload Time**: The reload time of the weapon.
    - **Range**: The range of the weapon.
    - **Accuracy**: The accuracy of the weapon.
  - **Shotgun**:
    - **Pellets**: The number of pellets to fire.
    - **Spread**: The spread of the weapon.
- **Bullet Properties**: We will have a set of properties that will be used to configure the bullet:
  - **Bullet Base**:
    - **Speed**: The speed of the bullet.
    - **Direction**: The direction of the bullet.
    - **Force**: The force of the bullet.
    - **Sniper Bullet**
      - **Penetrate**: The number of times the bullet can penetrate an enemy.
    - **Rocket Launcher Bullet**
      - **Explode**: The explode of the bullet.
      - **Explode Radius**: The explode radius of the bullet.
    - **Laser Rifle Bullet**
      - **Beam**: The beam of the bullet.
      - **Beam Length**: The beam length of the bullet.
    - **Plasma Rifle Bullet**
      - **Energy**: The energy of the bullet.
      - **Energy Consumption**: The energy consumption of the bullet.

## Implementation
```lua
  function init(self)
    self.weapon = Weapon:new({
      id = 'pistol',
      config = WeaponConfigs.Pistol,
      target = 'enemy' | 'player',
    })
  end
```

### Update
```lua
  function update(self, dt)
    self.weapon:update(dt)
  end
```

### Messages
```lua
local function on_bullet_hit(self, bullet)
  self.weapon:on_bullet_hit(bullet)
end

function on_message(self, message_id, message, sender)
  if message_id == Msg.Bullet.BULLET_FINISHED then
    on_bullet_finished(self, message.bullet)
  end
end
```

### Weapon Config
```lua
---@class WeaponConfig
---@field fire_interval number
---@field ammo_capacity number
---@field reload_time number
---@field range number
---@field accuracy number

---@class ShotgunWeaponConfig : WeaponConfig
---@field pellets number
---@field spread number
```

### Bullet Config
```lua
---@class BulletConfig
---@field speed number
---@field direction number
---@field force number

---@class SniperBulletConfig : BulletConfig
---@field penetrate number

---@class RocketLauncherBulletConfig : BulletConfig
---@field explode number
---@field explode_radius number

---@class LaserRifleBulletConfig : BulletConfig
---@field beam number
---@field beam_length number

---@class PlasmaRifleBulletConfig : BulletConfig
---@field energy number
---@field energy_consumption number
```