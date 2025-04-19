# GhostWheel
Experimental Isomentric 2.D Game Engine written in Lua for the [Playdate](https://play.date/) SDK, able to load level data created in the [Tiled Map Editor](https://www.mapeditor.org/).

A playable prototype engine for creating isometric, physics-enabled 2.5D levels, using JSON data exported from the [Tiled Map Editor](https://www.mapeditor.org/).
Designed with an Entity-Component-System (ECS) architecture, this engine empowers non-technical level designers to quickly prototype and test game levels using only Tiled.

The ultimate goal is to allow designers to:
* Rapidly prototype isometric levels
* Define rich game logic with no code
* Use pre-rendered visuals for final levels after testing
* Focus on gameplay, not engine internals

> 🚧 **_ Note:_** : This engine is experimental and under active development. Expect bugs and incomplete features.


## 🗺 Level Editing in Tiled
Levels are created entirely in the [Tiled Map Editor](https://www.mapeditor.org/), using JSON export format. 
All core level data—collision, visuals, player start, monsters, event zones, etc. are defined using custom properties on tiles, objects, and layers.

![GhostWheel_Tiled](https://github.com/user-attachments/assets/2cbdcae3-a0c1-41be-979f-9a923da2c2b7)

What You Can Define in Tiled:
| Feature	          | Defined Via                                                     |
| ------------------| --------------------------------------------------------------- |
| Layout & terrain  |	Tile layers                                                     |
| Player/Monsters	  | Object layers with custom properties (e.g. "player", "monster") |
| Collision	        | Object layers with "collision" component                        |
| Patrol paths      |	Object groups with waypoints                                    |
| Triggers & events	| Areas with "event" components                                   |
| Camera tracking	  | "cameratrack" property                                          |

### 📁 Example Workflow
* Open Tiled
* Design your level using tile and object layers
* Add properties like "player", "event", "collision", "dialog", etc.
* Export the map as .json
* Load it into the game engine and test on Playdate or desktop

## 🛠 Entity-Component-System Design
All entities (player, NPCs, items, triggers) are defined by their components, which are simple flags or attributes set in Tiled.
For example, a snippet of exported level data containing a "PlayerStart" object may look like this:
```json
{
  "type": "object",
  "name": "PlayerStart",
  "properties": {
    "player": true,
    "cameratrack": true,
    "collision": true
  }
}
```
The engine automatically builds this into a controllable player entity with camera tracking and collision detection.

![GhostWheel_Collision](https://github.com/user-attachments/assets/f44e15cd-36a6-4a78-b8ce-12e3e72b9f17)

## 🎮 Some Supported Featues
#### Map/Level Loading
* Load JSON files exported from Tiled Map Editor
*  Support Isometric grid data,
* (x, y) shift of map (for camera)
* Support multiple layers
* Support multiple tilesets
* Support multiple levels (height differences)
* Support different map width/height
* Support layer properties
* Support image layers
### Rendering & Physics
* Render Tiled Map Data
* Translate 2D Position coordinates to 2.5d isometric coordinates
* Translation from top-down (physics) to isometric (render) (see Isometric)
* Axis-Aligned collision detection in 2d position space
* Rigid-Body physics collision response
* Velocity Verlet Integration with velocity and acceleration
* Impulses using forces
* Resistance to movement (linear damping)
* Finetunable feel (force, damping, mass)

## 🧪 Current Limitations / Unsupported Features
* ❌ No animation system yet
* ❌ No event trigger logic (in progress)
* ❌ No UI/Dialog/Inventory/Item systems (planned)
* ❌ No visual scripting for triggers
* ❌ No support for hexagonal maps or staggered projections

## 🛠 Immediate To-Do
* Basic animation support
* Trigger system for events
* Items and inventory system
* Doors to other rooms/levels
* Dialog system

## 💬 Contributing
This project is experimental and feedback is welcome! If you're a designer or developer and want to try it out, open an issue or contribute directly.

## Libraries
* [tiny-ecs](https://github.com/bakpakin/tiny-ecs/tree/demo-commandokibbles) - Entity Component System for Lua
* [bump](https://github.com/kikito/bump.lua) - Collision Detection library for Lua
* [vector](https://github.com/automattf/vector.lua) - Vector library for Lua
* [pdlog](https://github.com/edzillion/pd-log.lua) - Logging module for Playdate
