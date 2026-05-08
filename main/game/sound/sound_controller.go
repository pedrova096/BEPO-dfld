components {
  id: "controller"
  component: "/main/game/sound/sound_controller.script"
}
embedded_components {
  id: "snd_steps"
  type: "sound"
  data: "sound: \"/assets/sounds/bepo_steps.ogg\"\n"
  "group: \"sfx\"\n"
  "gain: 0.1\n"
  ""
}
embedded_components {
  id: "snd_shot"
  type: "sound"
  data: "sound: \"/assets/sounds/shot.ogg\"\n"
  "group: \"sfx\"\n"
  ""
}
