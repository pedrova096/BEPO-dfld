local Default = {
  Move = require("lib.stater.states.default.move"),
  Hurt = require("lib.stater.states.default.hurt"),
  Idle = require("lib.stater.states.default.idle"),
}

return {
  Default = Default,
}