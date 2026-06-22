# Underworld — Godot 4 prototype

Open this directory in Godot 4.3+ and run the project (F6/F5). `scenes/Intro.tscn` is the entry scene and transitions to `scenes/Main.tscn` after any key press.

Controls: WASD — walk, mouse — look, Escape — quit. There is deliberately no HUD, inventory, objectives, combat, or collectibles.

The procedural world contains six distinct biomes: Yellow Offices, Drowned Halls, Silent Apartments, Underpass Tunnels, Dead Mall, and Endless Stairwell. Each generated maze contains 42 connected rooms and exactly one distant transition door. The fear director selects from 14 non-repeating architecture, light, fog, entity, and procedural-audio events at long random intervals.

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
│   ├── PhantomDoor.gd
│   ├── CorridorModule.gd
│   ├── FlickeringLight.gd
│   └── EntityShadow.gd
├── shaders/{vhs,intro_monochrome,infinite_clouds}.gdshader
├── materials/{wall,floor,ceiling,shadow}.tres
├── resources/
└── audio/
└── tests/{LevelSmokeTest,FearEventsSmokeTest}.gd
```

Audio is procedural and generated at runtime; `audio/` is reserved for later authored ambience.
