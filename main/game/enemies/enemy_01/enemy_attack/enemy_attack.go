components {
  id: "controller"
  component: "/main/game/attacks/basic_attack_controller.script"
}
embedded_components {
  id: "area_sprite"
  type: "sprite"
  data: "default_animation: \"attack_area_01\"\n"
  "material: \"/builtins/materials/sprite.material\"\n"
  "size {\n"
  "  x: 24.0\n"
  "  y: 24.0\n"
  "}\n"
  "textures {\n"
  "  sampler: \"texture_sampler\"\n"
  "  texture: \"/assets/sprites/enemies/attacks/enemies_attacks.atlas\"\n"
  "}\n"
  ""
}
embedded_components {
  id: "body"
  type: "collisionobject"
  data: "type: COLLISION_OBJECT_TYPE_TRIGGER\n"
  "mass: 0.0\n"
  "friction: 0.1\n"
  "restitution: 0.5\n"
  "group: \"enemy_trigger\"\n"
  "mask: \"player\"\n"
  "embedded_collision_shape {\n"
  "  shapes {\n"
  "    shape_type: TYPE_BOX\n"
  "    position {\n"
  "    }\n"
  "    rotation {\n"
  "    }\n"
  "    index: 0\n"
  "    count: 3\n"
  "    id: \"body\"\n"
  "  }\n"
  "  data: 10.0\n"
  "  data: 10.0\n"
  "  data: 10.0\n"
  "}\n"
  ""
}
embedded_components {
  id: "sprite"
  type: "sprite"
  data: "default_animation: \"enemy_attack\"\n"
  "material: \"/builtins/materials/sprite.material\"\n"
  "size {\n"
  "  x: 28.0\n"
  "  y: 28.0\n"
  "}\n"
  "textures {\n"
  "  sampler: \"texture_sampler\"\n"
  "  texture: \"/assets/sprites/enemies/attacks/enemies_attacks.atlas\"\n"
  "}\n"
  ""
  position {
    y: 1.0
  }
  rotation {
    z: 0.38268343
    w: 0.9238795
  }
}
embedded_components {
  id: "dot_factory"
  type: "factory"
  data: "prototype: \"/main/game/enemies/enemy_01/enemy_attack/attack_dot.go\"\n"
  ""
}
