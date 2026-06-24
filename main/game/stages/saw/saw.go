components {
  id: "controller"
  component: "/main/game/stages/saw/saw_controller.script"
}
embedded_components {
  id: "sprite"
  type: "sprite"
  data: "default_animation: \"default\"\n"
  "material: \"/builtins/materials/sprite.material\"\n"
  "textures {\n"
  "  sampler: \"texture_sampler\"\n"
  "  texture: \"/assets/sprites/tiles/saw.tilesource\"\n"
  "}\n"
  ""
  position {
    x: -1.5
  }
}
