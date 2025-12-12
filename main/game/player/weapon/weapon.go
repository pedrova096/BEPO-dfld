components {
  id: "controller"
  component: "/main/game/player/weapon/weapon_controller.script"
}
embedded_components {
  id: "sprite"
  type: "sprite"
  data: "default_animation: \"idle\"\n"
  "material: \"/main/materials/map_colors/map_colors.material\"\n"
  "textures {\n"
  "  sampler: \"texture_sampler\"\n"
  "  texture: \"/assets/sprites/player/weapon/player_weapon.tilesource\"\n"
  "}\n"
  ""
}
embedded_components {
  id: "bullet_sm_factory"
  type: "factory"
  data: "prototype: \"/main/game/bullets/bullets_sm.go\"\n"
  ""
}
