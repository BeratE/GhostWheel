import "CoreLibs/object"
import "pdlibs/util/math"
import "libs/tinyecs"
import "scripts/system/AbstractSystem"

--[[ Application of bump collision detection.
Order of physics system:
1 Positional Logic
* 2 Collision detection
* 3 Collisions resolution
]]

class("BumpWorldSystem").extends(AbstractSystem)
tinyecs.processingSystem(BumpWorldSystem)
BumpWorldSystem.filter = tinyecs.requireAll("pos", tinyecs.requireAny("hitbox", "collision"))

function BumpWorldSystem:init(mapdata)
    BumpWorldSystem.super.init(self, mapdata)
end

function BumpWorldSystem:onAdd(e)
    if (e.collision and not e.hitbox) then
        assert(e.width and e.height, "Entity has no width/height component")
        assert(e.width > 0 and e.height > 0, "Entity requires positive width/height component")
        e.hitbox = {w = e.width, h = e.height}
    end
    
    e.onCollision = e.onCollision or function (self, col)
        log.info(("Entity %s collided with %s"):format(self.name, col.other.name))
    end

    self.bumpworld:add(e, e.pos.x, e.pos.y, e.hitbox.w, e.hitbox.h)
end

function BumpWorldSystem:onRemove(e)
    self.bumpworld:remove(e)
end

local function defaultfilter(item, other)
    -- Ignore collision bumptag j if bit j in bumpmask is set
    if item.bumpmask and other.bumptag and
      (item.bumpmask & other.bumptag ~= 0) then
        return
    end
    return other.bumptype or "touch"
end

function BumpWorldSystem:process(e, dt)
    if not e.moved or not e.collision then
        return
    end
    --[[ Position Update and Collision detection ]]
    local cols, len
    e.pos.x, e.pos.y, cols, len = self.bumpworld:move(e, e.pos.x, e.pos.y, defaultfilter)
    --[[ Collision resolution ]]
    for i = 1, len do
        local col = cols[i]
        log.info(("Collision (%s) %s - %s at %0.2f, %0.2f."):format(col.type, col.item.name, col.other.name, col.touch.x, col.touch.y))
        
        -- Response based on collision type
        if (col.type ~= 'cross') then
            e:stopMovement()
        end
        if col.type == "touch" then
        elseif col.type == "slide" then
        elseif col.type == "bounce" then
            e:addForce(col.normal.x, col.normal.y)
        elseif col.type == "cross" then
        end

        -- Check for Collision event trigger
        if (col.other.event) then
            col.other:notify("collision", {other = e})
        end

        -- Entity specific collision behavior
        e:onCollision(col)
    end
end

function BumpWorldSystem:setMapData(mapdata)
    self.bumpworld = mapdata.bumpworld
end