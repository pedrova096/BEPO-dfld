components {
  id: "stage_01"
  component: "/main/game/stages/stage_01/stage_01.tilemap"
}
components {
  id: "obstacles_02"
  component: "/main/game/stages/stage_02/obstacles_02.tilemap"
  position {
    z: 5.0
  }
}
embedded_components {
  id: "wall"
  type: "collisionobject"
  data: "collision_shape: \"/main/game/stages/stage_01/stage_01.tilemap\"\n"
  "type: COLLISION_OBJECT_TYPE_STATIC\n"
  "mass: 0.0\n"
  "friction: 0.1\n"
  "restitution: 0.5\n"
  "group: \"wall\"\n"
  "mask: \"player\"\n"
  "mask: \"bullet\"\n"
  "mask: \"enemy\"\n"
  ""
}
embedded_components {
  id: "obstacles"
  type: "collisionobject"
  data: "collision_shape: \"/main/game/stages/stage_02/obstacles_02.tilemap\"\n"
  "type: COLLISION_OBJECT_TYPE_STATIC\n"
  "mass: 0.0\n"
  "friction: 0.1\n"
  "restitution: 0.5\n"
  "group: \"wall\"\n"
  "mask: \"player\"\n"
  "mask: \"bullet\"\n"
  "mask: \"enemy\"\n"
  ""
}
