local Default = {
  Empty = require("lib.stater.states.default.empty"),
  Move = require("lib.stater.states.default.move"),
  Hurt = require("lib.stater.states.default.hurt"),
  Idle = require("lib.stater.states.default.idle"),
}

local Enemy = {
  Spawn = require("lib.stater.states.enemy.spawn"),
  Move = require("lib.stater.states.enemy.move"),
  Hurt = require("lib.stater.states.enemy.hurt"),
  Attack = require("lib.stater.states.enemy.attack"),
  Idle = require("lib.stater.states.enemy.idle"),
  Dead = require("lib.stater.states.enemy.dead"),
  Despawn = require("lib.stater.states.enemy.despawn"),
}

local Player = {
  Move = require("lib.stater.states.player.move"),
}

return {
  Default = Default,
  Enemy = Enemy,
  Player = Player,
}
