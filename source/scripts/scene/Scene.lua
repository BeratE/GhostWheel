import "CoreLibs/object"
import "libs/tinyecs"
import "pdlibs/state/State"


local getCurrTimeMs <const> = playdate.getCurrentTimeMilliseconds

--[[ Each Game Scene contains an ECS World 
 and is responsible for managing entities and systems. ]]
class("Scene").extends(pdlibs.state.State)

function Scene:init()
    self.world = tinyecs.world() -- Each scene holds its own ecs-world
    self.currTimeMs = getCurrTimeMs()
    self.deltaTimeMs = 0
end

function Scene:onEnter()
    _G["world"] = self.world
end

function Scene:onExit()
end

function Scene:onUpdate()
    self:refreshDeltaTimeMs()
    self.world:update(self:getDeltaTimeMs())
    self.world:refresh()
end

function Scene:refreshDeltaTimeMs()
    -- update delta time
    local nowTimeMs = getCurrTimeMs()
    self.deltaTimeMs = nowTimeMs - self.currTimeMs
    self.currTimeMs = nowTimeMs
end

function Scene:getDeltaTimeMs()
    return self.deltaTimeMs
end

function Scene:addSystems(systems)
    for _, sys in pairs(systems) do
        self.world:addSystem(sys)
    end
end

-- [[ Simulator and Debug ]]

function Scene:debugDraw()
end

function Scene:debugMenu()
end

function Scene:keyPressed(key)
end