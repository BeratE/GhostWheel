---@diagnostic disable: undefined-field
import "CoreLibs/object"
import "pdlibs/util/math"
import "libs/tinyecs"

--[[ Application of bump collision detection.
Order of physics system:
1 Positional Logic
* 2 Collision detection
3 Collisions resolution
]]

local point <const> = playdate.geometry.point

local function collisionFilter(item, other)
    return "touch"
end

class("BumpWorldSystem").extends()
tinyecs.processingSystem(BumpWorldSystem)
BumpWorldSystem.filter = tinyecs.requireAll("pos", "hitbox")

function BumpWorldSystem:init(bumpworld)
    BumpWorldSystem.super.init(self)
    self.bumpworld = bumpworld
end

function BumpWorldSystem:onAdd(e)
    self.bumpworld:add(e, e.pos.x, e.pos.y, e.hitbox.w, e.hitbox.h)
end

function BumpWorldSystem:onRemove(e)
    self.bumpworld:remove(e)
end

function BumpWorldSystem:preProcess(dt)
    -- Check if a bumpworld is given
    self.process = self.proxyProcess
    if (not self.bumpworld) then
        self.process = self.emptyProcess
    end
end


function BumpWorldSystem:proxyProcess(e, dt)
    --[[ Position Update and Collision detection ]]
    local px, py, cols, len = self.bumpworld:move(e, e.pos.x, e.pos.y, e.onCollision or collisionFilter)
    for i = 1, len do
        local col = cols[i]
        local collided = true

        log.info(("Collision with %s at %0.2f, %0.2f."):format(col.other.name, col.touch.x, col.touch.y))
        
        if col.type == "touch" then
            --e.vel.x, e.vel.y = 0, 0
        elseif col.type == "slide" then
            
        elseif col.type == "bounce" then
            
        end


        if e.onCollision and collided then
            e:onCollision(col)
        end
    end
    e.pos.x, e.pos.y = px, py
end

function BumpWorldSystem:emptyProcess(e, dt)
    -- Do Nothing
end