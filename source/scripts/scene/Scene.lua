import "CoreLibs/object"
import "libs/ecs/tiny"
import "pdlibs/state/State"

class("Scene").extends(pdlibs.state.StateMachine)

function Scene:init()
    self.world = tiny.world()
end

function Scene:onEnter()
    
end

function Scene:onExit()
    
end

function Scene:onUpdate()
    self.world:update(getDeltaTimeMs())
end