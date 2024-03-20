import "CoreLibs/object"
import "pdlibs/util/math"
import "libs/tinyecs"

--[[ Application of bump collision detection.
Order of physics system:
1 Positional Logic
* 2 Collision detection
3 Collisions resolution
]]

local function defaultfilter(entity, other)
    return other.bumptype or "touch"
end

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
        assert(e.width and e.height, "Entity with collision component requires width/height")
        e.hitbox = {w = e.width, h = e.height}
    end
    if (not e.onCollision) then
        e.onCollision = function (self, col)
            log.info(("Entity %s collided with %s"):format(self.name, col.other.name))
        end
    end
    self.bumpworld:add(e, e.pos.x, e.pos.y, e.hitbox.w, e.hitbox.h)
end

function BumpWorldSystem:onRemove(e)
    self.bumpworld:remove(e)
end

function BumpWorldSystem:preProcess(dt)
end

function BumpWorldSystem:process(e, dt)
    if not e.moved then
        return
    end
    --[[ Position Update and Collision detection ]]
    local collisionfilter = e.bumpfilter or defaultfilter
    local cols, len
    e.pos.x, e.pos.y, cols, len = self.bumpworld:move(e, e.pos.x, e.pos.y, collisionfilter)
    for i = 1, len do
        local col = cols[i]
        log.info(("Collision (%s) %s at %0.2f, %0.2f."):format(col.type, col.other.name, col.touch.x, col.touch.y))
        if col.type == "touch" then
            e.vel:set(0, 0)
            e.acc:set(0, 0)
        elseif col.type == "slide" then
        elseif col.type == "bounce" then
            e.vel:set(0, 0)
            e.acc:set(0, 0)
            e:addForce(col.normal.x, col.normal.y)
        elseif col.type == "cross" then
            
        end

        e:onCollision(col)
    end
end

function BumpWorldSystem:setBumpWorld(bumpworld)
    self.bumpworld = bumpworld
end