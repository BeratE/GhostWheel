import "CoreLibs/animator"
import "scripts/system/AbstractSystem"

local pd <const> = playdate
local gfx <const> = playdate.graphics

--[[ Follows a given target, target needs to be a table with a pos attribute. ]]
class("FollowSystem").extends(AbstractSystem)
tinyecs.processingSystem(FollowSystem)
FollowSystem.filter = tinyecs.requireAll("pos", "follow")

function FollowSystem:onAdd(e)
    e.follow.pause = e.follow.pause or false
    e.follow.mindist = e.follow.mindist or 0
    e.follow.tolerance = e.follow.tolerance or 0.5
    e.follow.speed = e.follow.speed or 0.1
    
    e.setFollowTarget = e.setFollowTarget or function (self, target)
        if not target then return end
        local t = target
        if (target.objrefid) then
            t = self.objref[target.objrefid]
        end
        self.follow.target = t
    end

    -- Check if entity is in distance to target 
    e.isInFollowDistance = e.isInFollowDistance or function (self, d)
        if (not self.follow.target) then return true end
        if (not self.follow.target.pos) then return true end
        local p1 = self.pos
        local p2 = self.follow.target.pos
        return (vector.dist(p1, p2) <= d)
    end

    e.hasFollowReached = e.hasFollowReached or function (self)
        return self:isInFollowDistance( e.follow.mindist + e.follow.tolerance)
    end

    e:setFollowTarget(e.target.follow)
end

function FollowSystem:process(e, dt)
    if (e.follow.pause or e:hasFollowReached()) then
        return
    end
    local s = e.follow.speed
    local dx = e.follow.target.pos.x - e.pos.x
    local dy = e.follow.target.pos.y - e.pos.y
    e:addForce(dx/abs(dx)*s, dy/abs(dy)*s, ForceMode.VelocityChange)
end