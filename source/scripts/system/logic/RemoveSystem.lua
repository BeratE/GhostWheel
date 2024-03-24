import "scripts/system/AbstractSystem"

--[[ Remove entities from the world ]]

class("RemoveSystem").extends(AbstractSystem)
tinyecs.system(RemoveSystem)
RemoveSystem.filter = tinyecs.requireAll("remove")

function RemoveSystem:onAdd(e)
    if (e.remove) then
        e.remove = false
        _G["world"]:removeEntity(e)
    end
end