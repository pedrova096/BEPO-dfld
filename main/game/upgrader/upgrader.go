components {
  id: "controller"
  component: "/main/game/upgrader/upgrader_controller.script"
}
embedded_components {
  id: "sprite"
  type: "sprite"
  data: "default_animation: \"toolbox\"\n"
  "material: \"/builtins/materials/sprite.material\"\n"
  "textures {\n"
  "  sampler: \"texture_sampler\"\n"
  "  texture: \"/assets/sprites/cog/upgrader.atlas\"\n"
  "}\n"
  ""
  position {
    y: 11.0
    z: 2.0
  }
}
embedded_components {
  id: "sprite_shadow"
  type: "sprite"
  data: "default_animation: \"default\"\n"
  "material: \"/builtins/materials/sprite.material\"\n"
  "slice9 {\n"
  "  x: 8.0\n"
  "  y: 8.0\n"
  "  z: 8.0\n"
  "  w: 8.0\n"
  "}\n"
  "size {\n"
  "  x: 36.0\n"
  "  y: 14.0\n"
  "}\n"
  "size_mode: SIZE_MODE_MANUAL\n"
  "textures {\n"
  "  sampler: \"texture_sampler\"\n"
  "  texture: \"/assets/sprites/global/shadow.tilesource\"\n"
  "}\n"
  ""
  position {
    y: 1.0
  }
}
embedded_components {
  id: "body"
  type: "collisionobject"
  data: "type: COLLISION_OBJECT_TYPE_TRIGGER\n"
  "mass: 0.0\n"
  "friction: 0.1\n"
  "restitution: 0.5\n"
  "group: \"upgrader_trigger\"\n"
  "mask: \"player\"\n"
  "embedded_collision_shape {\n"
  "  shapes {\n"
  "    shape_type: TYPE_BOX\n"
  "    position {\n"
  "      y: 8.0\n"
  "    }\n"
  "    rotation {\n"
  "    }\n"
  "    index: 0\n"
  "    count: 3\n"
  "  }\n"
  "  data: 9.0\n"
  "  data: 7.0\n"
  "  data: 10.0\n"
  "}\n"
  ""
}
embedded_components {
  id: "star_flare_sprite"
  type: "sprite"
  data: "default_animation: \"star_flare\"\n"
  "material: \"/main/materials/star_flare/star_flare.material\"\n"
  "size {\n"
  "  x: 64.0\n"
  "  y: 64.0\n"
  "}\n"
  "textures {\n"
  "  sampler: \"texture_sampler\"\n"
  "  texture: \"/assets/sprites/global/global.atlas\"\n"
  "}\n"
  ""
  position {
    y: 9.0
    z: 1.0
  }
}
