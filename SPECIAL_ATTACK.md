# Special Attack — Configurable System (v1)

## Goal

Design a configuration-driven special attack system that allows defining attacks through composable categories instead of hard-coded logic. Each special attack is built from reusable behavior modules.

## Core Special Attack Schema

```yaml
special_attack:
  id: string
  cost:
    kill_cost: number # replaces cooldown
    charges: number # max stored uses

  stats:
    base_damage: number
    stat_scaling: number # factor applied to actor stats

  timing:
    windup: seconds
    active: seconds? # optional phase duration
```

### Notes

- kill_cost = resource model based on kills instead of time cooldown
- charges = stackable uses
- active phase optional → supports instant or channeled attacks

## Behavior Categories

Each special attack includes one or more behavior modules.

### 1️⃣ Targeting

Defines how the attack selects its target or direction.

```yaml
targeting:
  mode: "point" | "auto"
```

#### Modes

- point → player chooses position/direction
- auto → system selects best target automatically

### 2️⃣ AoE Zone Module

Creates an area that evaluates entities over time.

```yaml
aoe_zone:
  shape: circle | box | cone
  radius: number

  events:
    on_enter: effect_id
    on_tick: effect_id
    on_exit: effect_id
```

#### Behavior

- Event-driven
- Can support DoT, slow, stun, etc.
- Tick interval can be engine default in v1

### 3️⃣ Summon Module

Spawns temporary entities.

```yaml
summon:
  entity_id: string
  count: number

  duration_mode: "lifetime" | "hit_count"
  duration_value: number

  control: "controlled" | "uncontrolled"
```

#### Behavior

- lifetime → seconds alive
- hit_count → expires after N hits/actions
- controlled → player-directed
- uncontrolled → AI behavior

### 4️⃣ Modifier Module

Applies temporary state changes to the caster.

```yaml
modifier:
  invulnerable: boolean
  stat_multiplier:
    damage: number
    speed: number
    defense: number
    duration: seconds
```

#### Examples

- Dash invulnerability window
- Rage damage buff
- Speed boost escape skill

## Attack Intent Tags

Used for balancing + AI + UI grouping.

intent:

- burst_damage
- crowd_control
- mobility

**Purpose**

- Balance tuning
- Enemy AI response
- UI filtering
- Analytics

## System Rules

- A special attack can combine multiple modules
- Modules must be independent and composable
- Timing applies globally unless overridden by module
- Effects execution = v2 (separate effect registry)
