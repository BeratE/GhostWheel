import "CoreLibs/object"
import "libs/ecs/tiny"

class("EntityStateSystem").extends()
tinyecs.processingSystem(EntityStateSystem)
EntityStateSystem.filter = tinyecs.requireAll("state")

function EntityStateSystem:init()
    EntityStateSystem.super.init(self)
end

function EntityStateSystem:process(e, dt)
    e.state:update()
end