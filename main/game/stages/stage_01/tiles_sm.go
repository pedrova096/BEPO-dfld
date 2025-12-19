components {
  id: "tileset"
  component: "/main/game/stages/stage_01/tiles_sm.tilemap"
}
embedded_components {
  id: "static"
  type: "collisionobject"
  data: "collision_shape: \"/main/game/stages/stage_01/tiles_sm.tilemap\"\n"
  "type: COLLISION_OBJECT_TYPE_STATIC\n"
  "mass: 0.0\n"
  "friction: 0.1\n"
  "restitution: 0.5\n"
  "group: \"obstacle\"\n"
  "mask: \"player\"\n"
  "mask: \"bullet\"\n"
  "mask: \"enemy\"\n"
  ""
}
