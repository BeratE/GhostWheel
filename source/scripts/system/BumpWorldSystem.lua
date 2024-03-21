import "CoreLibs/object"
import "pdlibs/util/math"
import "libs/tinyecs"

--[[ Application of bump collision detection.
Order of physics system:
1 Positional Logic
* 2 Collision detection
3 Collisions resolution
]]

class("BumpWorldSystem").extends()
tinyecs.processingSystem(BumpWorldSystem)
BumpWorldSystem.filter = tinyecs.requireAll("pos",
    tinyecs.requireAny("hitbox", "collision"))

function BumpWorldSystem:init(bumpworld)
    BumpWorldSystem.super.init(self)
    self:setBumpWorld(bumpworld)
end

function BumpWorldSystem:onAdd(e)
    if (e.collision and not e.hitbox) then
        assert(e.width and e.height, "Entity has no width/height component")
        assert(e.width > 0 and e.height > 0, "Entity requires positive width/height component")
        e.hitbox = {w = e.width, h = e.height}
    end
    if (not e.onCollision) then
        -- Just add a debug statement
        e.onCollision = function (self, col)
            log.info(("Entity %s collided with %s"):format(self.name, col.other.name))
        end
    end
    self.bumpworld:add(e, e.pos.x, e.pos.y, e.hitbox.w, e.hitbox.h)
end

function BumpWorldSystem:onRemove(e)
    self.bumpworld:remove(e)
end

local function defaultfilter(item, other)
    -- Ignore collision bumptag j if bit j in bumpmask is set
    if (item.bumpmask and other.bumptag) then
        if (item.bumpmask & other.bumptag ~= 0) then
            return
        end
    end
    return other.bumptype or "touch"
end

function BumpWorldSystem:process(e, dt)
    if not e.moved then
        e.bumpcols = nil
        return
    end
    --[[ Position Update and Collision detection ]]
    local cols, len
    e.pos.x, e.pos.y, cols, len = self.bumpworld:move(e, e.pos.x, e.pos.y, defaultfilter)
    e.bumpcols = cols
    for i = 1, len do
        local col = cols[i]
        log.info(("Collision (%s) %s at %0.2f, %0.2f."):format(col.type, col.other.name, col.touch.x, col.touch.y))
        -- Behavior depending on collision type
        if (col.type ~= "cross") then
            e:stopMovement()
        end
        if col.type == "touch" then

        elseif col.type == "slide" then

        elseif col.type == "bounce" then
            e:addForce(col.normal.x, col.normal.y)
        elseif col.type == "cross" then
            
        end

        e:onCollision(col)
    end
end

function BumpWorldSystem:setBumpWorld(bumpworld)
    self.bumpworld = bumpworld
end