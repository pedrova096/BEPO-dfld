components {
  id: "controller"
  component: "/main/game/enemies/enemy_02/weapon/weapon_controller.script"
}
embedded_components {
  id: "bullet_sm_factory"
  type: "factory"
  data: "prototype: \"/main/game/bullets/bullets_sm.go\"\n"
  ""
}
embedded_components {
  id: "sprite"
  type: "sprite"
  data: "default_animation: \"weapon_01\"\n"
  "material: \"/main/materials/map_colors/map_colors.material\"\n"
  "size {\n"
  "  x: 18.0\n"
  "  y: 18.0\n"
  "}\n"
  "textures {\n"
  "  sampler: \"texture_sampler\"\n"
  "  texture: \"/assets/sprites/enemies/weapons/enemy_weapons.atlas\"\n"
  "}\n"
  ""
}
embedded_components {
  id: "area_factory"
  type: "factory"
  data: "prototype: \"/main/game/enemies/enemy_02/weapon/arrow_area/arrow_area.go\"\n"
  ""
}
