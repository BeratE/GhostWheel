import "CoreLibs/object"
import "pdlibs/util/math"
import "libs/tinyecs"

--[[ Application of bump collision detection.
Order of physics system:
1 Positional Logic
* 2 Collision detection
3 Collisions resolution
]]

local function defaultfilter(item, other)
    return "touch"
end

class("BumpWorldSystem").extends()
tinyecs.processingSystem(BumpWorldSystem)
BumpWorldSystem.filter = tinyecs.requireAll("pos", "hitbox")

function BumpWorldSystem:init(bumpworld)
    BumpWorldSystem.super.init(self)
    self:setBumpWorld(bumpworld)
end

function BumpWorldSystem:onAdd(e)
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
    local x, y, cols, len = self.bumpworld:move(e, e.pos.x, e.pos.y, collisionfilter)
    e.pos:set(x, y)
    for i = 1, len do
        local col = cols[i]
        local collided = true
        log.info(("Collision with %s at %0.2f, %0.2f."):format(col.other.name, col.touch.x, col.touch.y))
        if col.type == "touch" then
            e.vel:set(0, 0)
            e.acc:set(0, 0)
        elseif col.type == "slide" then
            
        elseif col.type == "bounce" then
            
        end

        if e.onCollision and collided then
            e:onCollision(col)
        end
    end
end

function BumpWorldSystem:setBumpWorld(bumpworld)
    self.bumpworld = bumpworld
end