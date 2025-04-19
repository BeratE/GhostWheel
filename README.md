# GhostWheel
Experimental Isomentric 2.D Game Engine, able to load level data created in .

A playable prototype engine for creating isometric, physics-enabled 2.5D levels, using JSON data exported from the [Tiled Map Editor](https://www.mapeditor.org/).
Designed with an Entity-Component-System (ECS) architecture, this engine empowers non-technical level designers to quickly prototype and test game levels using only Tiled.

> 🚧 **_ Note:_** : This engine is experimental and under active development. Expect bugs and incomplete features.

## 🧪 Goals
The ultimate goal is to allow designers to:
* Rapidly prototype isometric levels
* Define rich game logic with no code
* Use pre-rendered visuals for final levels after testing
* Focus on gameplay, not engine internals

## 🗺 Level Editing in Tiled
Levels are created entirely in [Tiled Map Editor](https://www.mapeditor.org/), using JSON export format. 
All core level data—collision, visuals, player start, monsters, event zones, etc.—are defined using custom properties on tiles, objects, and layers.

![GhostWheel_Tiled](https://github.com/user-attachments/assets/2cbdcae3-a0c1-41be-979f-9a923da2c2b7)

What You Can Define in Tiled
| Feature	 | Defined Via |
| -------- | ------- |
| Layout & terrain |	Tile layers |
| Player/Monsters	| Object layers with custom properties (e.g. "player", "monster") |
| Collision	| Object layers with "collision" component |
| Patrol paths |	Object groups with waypoints |
| Triggers & events	| Areas with "event" components |
| Camera tracking	| "cameratrack" property |
| Dialogs |	Placeholder support via trigger components |

## 📁 Example Workflow
* Open Tiled
* Design your level using tile and object layers
* Add properties like "player", "event", "collision", "dialog", etc.
* Export the map as .json
* Load it into the game engine and test on Playdate or desktop

## 🎮 Playable Prototype

![GhostWheel_Collision](https://github.com/user-attachments/assets/f44e15cd-36a6-4a78-b8ce-12e3e72b9f17)

### Isometric Engine
#### Map/Level Loading
* Load JSON files exported from Tiled Map Editor
* Render Isometric grid data
* Support x,y shift of map (for camera)
* Support multiple layers
* Support multiple tilesets
* Support multiple levels (height differences)
* Support different map width/height
* Support layer properties
* Support image layers
### Rendering
* Render Tiled Map Data
* Translate Position to Isometric Coordinates
### Collision Detection
Axis-Aligned Collision detection
Physics based collision response

### Physics Engine
* Velocity Verlet Integration with velocity and acceleration
* Impulses using forces
* Resistance to movement (linear damping)
* Finetunable feel (force, damping, mass)
* Translation from top-down (physics) to isometric (render) (see Isometric)



## 💬 Contributing
This project is experimental and feedback is welcome! If you're a designer or developer and want to try it out, open an issue or contribute directly.

## Libraries
* [tiny-ecs](https://github.com/bakpakin/tiny-ecs/tree/demo-commandokibbles) - Entity Component System for Lua
* [bump](https://github.com/kikito/bump.lua) - Collision Detection library for Lua
* [vector](https://github.com/automattf/vector.lua) - Vector library for Lua
* [pdlog](https://github.com/edzillion/pd-log.lua) - Logging module for Playdate
