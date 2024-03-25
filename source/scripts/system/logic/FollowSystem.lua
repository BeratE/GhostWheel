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
    e.follow.tolerance = e.follow.tolerance or 8
    e.follow.speed = e.follow.speed or 0.1
    
    e.setFollowTarget = e.setFollowTarget or function (self, target)
        if not target then return end
        local t = target
        if (target.objrefid) then
            t = self.objref[target.objrefid]
        end
        self.follow.target = t
    end

    e.isInFollowDistance = e.isInFollowDistance or function (self, d)
        if (not self.follow.target) then return true end
        local cx = self.pos.x - (self.follow.target.x or self.follow.target.pos.x)
        local cy = self.pos.y - (self.follow.target.y or self.follow.target.pos.y)
        return ((cx*cx)+(cy*cy) <= d*d)
    end

    e.hasFollowReached = e.hasFollowReached or function (self)
        return self:isInFollowDistance(e.follow.mindist + e.follow.tolerance)
    end

    e:setFollowTarget(e.follow.target)
end

function FollowSystem:process(e, dt)
    if (e.follow.pause or e:hasFollowReached()) then
        return
    end
    local s = e.follow.speed
    local dx = (e.follow.target.x or e.follow.target.pos.x) - e.pos.x
    local dy = (e.follow.target.y or e.follow.target.pos.y) - e.pos.y
    if (math.abs(dx) > e.follow.tolerance) then e:addForce(dx/math.abs(dx)*s, 0, ForceMode.VelocityChange) end
    if (math.abs(dy) > e.follow.tolerance) then e:addForce(0, dy/math.abs(dy)*s, ForceMode.VelocityChange) end
end