components {
  id: "stage"
  component: "/main/game/stages/stage_01/stage_01.tilemap"
}
components {
  id: "controller"
  component: "/main/game/stages/stages_controller.script"
}
components {
  id: "obstacles"
  component: "/main/game/stages/stage_01/obstacles_01.tilemap"
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
  id: "cfactory_enemy_01"
  type: "collectionfactory"
  data: "prototype: \"/main/game/enemies/enemy_01/enemy_01.collection\"\n"
  ""
}
embedded_components {
  id: "cfactory_enemy_02"
  type: "collectionfactory"
  data: "prototype: \"/main/game/enemies/enemy_02/enemy_02.collection\"\n"
  ""
}
embedded_components {
  id: "cfactory_enemy_03"
  type: "collectionfactory"
  data: "prototype: \"/main/game/enemies/enemy_03/enemy_03.collection\"\n"
  ""
}
embedded_components {
  id: "cfactory_enemy_04"
  type: "collectionfactory"
  data: "prototype: \"/main/game/enemies/enemy_04/enemy_04.collection\"\n"
  ""
}
embedded_components {
  id: "obstacle"
  type: "collisionobject"
  data: "collision_shape: \"/main/game/stages/stage_01/obstacles_01.tilemap\"\n"
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
