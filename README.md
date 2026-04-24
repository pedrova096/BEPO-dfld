# BEPO

This project it's a simple top-down shooter with typical roguelite systems. The player it's a small robot that auto-shoots the enemies. The enemies chase the player and attack him by shooting or a melee-attack. The game will be played stage-by-stage and it will present different challenges (to define). When the stage its clean, we will reward the player with a random upgrade.

## Upgrades

Similar to Ember Knight or Hades, we will have a clean stage -> reward system. The player could receive one of this types of rewards:

- **Boost**: Typical roguelite stats boost
  - Health
  - Speed
  - Ammo
  - Critical Chance
  - Bullet Damage
  - Bullet Rate
  - Bullet Spread
  - Bullet Knockback
- **Bullet Effect**: When hit the enemy will have a chance of:
  - **Infect**: DoT
  - **Burn**: It will explode after received
  - **Freeze**: It will slow or freeze the enemy
  - **Life Steal**: ??
- **Super powers**: This are activation powers
  - **Repel Zone**: It will push back and hurt enemies in a zone
  - **Vortex Zone**: It will attract the enemy into a zone for an small explosion
- **Classic upgrades**
  - **Pierce**: Bullet pass through enemies
  - **Ricochet**: Bullet bounce n times of enemies
  - **Shield**: Armor layer before health
