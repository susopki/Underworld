# Underworld — Godot 4 prototype

Open this directory in Godot 4.3+ and run the project (F6/F5). `scenes/Intro.tscn` is the entry scene and transitions to `scenes/Main.tscn` after any key press.

Controls: WASD — walk, mouse — look, Escape — quit. There is deliberately no HUD, inventory, objectives, combat, or collectibles.

## Project structure

```
Underworld/
├── project.godot
├── scenes/
│   ├── Main.tscn
│   ├── Intro.tscn
│   ├── Player.tscn
│   ├── CorridorModule.tscn
│   ├── RoomModule.tscn
│   └── EntityShadow.tscn
├── scripts/
│   ├── Main.gd
│   ├── IntroController.gd
│   ├── PlayerController.gd
│   ├── CameraBob.gd
│   ├── AtmosphereManager.gd
│   ├── RandomSoundManager.gd
│   ├── ScareEventManager.gd
│   ├── LevelGenerator.gd
│   ├── LevelPortal.gd
│   ├── RoomModule.gd
│   ├── CeilingRift.gd
│   ├── BiomeEntity.gd
│   ├── CorridorModule.gd
│   ├── FlickeringLight.gd
│   └── EntityShadow.gd
├── shaders/{vhs,intro_monochrome,infinite_clouds}.gdshader
├── materials/{wall,floor,ceiling,shadow}.tres
├── resources/
└── audio/
```

Audio is procedural and generated at runtime; `audio/` is reserved for later authored ambience.
