components {
  id: "controller"
  component: "/main/game/enemies/enemy_01/enemy_attack/attack_dot_controller.script"
}
embedded_components {
  id: "sprite"
  type: "sprite"
  data: "default_animation: \"attack_area_dot\"\n"
  "material: \"/builtins/materials/sprite.material\"\n"
  "textures {\n"
  "  sampler: \"texture_sampler\"\n"
  "  texture: \"/assets/sprites/enemies/attacks/enemies_attacks.atlas\"\n"
  "}\n"
  ""
}
