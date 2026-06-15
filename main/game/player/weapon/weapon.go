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
  type: "collectionfactory"
  data: "prototype: \"/main/game/bullets/bullets_sm.collection\"\n"
  ""
}
embedded_components {
  id: "muzzle_flash"
  type: "sprite"
  data: "default_animation: \"muzzle_flash\"\n"
  "material: \"/main/materials/map_colors/map_colors.material\"\n"
  "size {\n"
  "  x: 18.0\n"
  "  y: 18.0\n"
  "}\n"
  "textures {\n"
  "  sampler: \"texture_sampler\"\n"
  "  texture: \"/assets/sprites/bullets/bullets_sm.tilesource\"\n"
  "}\n"
  ""
  position {
    x: -1.0
    y: -9.0
  }
}
