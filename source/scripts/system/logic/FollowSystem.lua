import "CoreLibs/animator"
import "scripts/system/AbstractSystem"

local pd <const> = playdate
local gfx <const> = playdate.graphics

--[[ Follows a given target. 
Target either needs a pos component or x and y attributes. ]]
class("FollowSystem").extends(AbstractSystem)
tinyecs.processingSystem(FollowSystem)
FollowSystem.filter = tinyecs.requireAll("pos", "follow")

function FollowSystem:onAdd(e)
    e.follow.pause = e.follow.pause or false
    e.follow.mindist = e.follow.mindist or 0
    if (not e.follow.tolerance) then
        
        if (e.width or e.height) then
            e.follow.tolerance = math.max(e.width or e.height, e.height or e.width)/2
        end
    end
    e.follow.tolerance = e.follow.tolerance or 10
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
    local dx = (e.follow.target.x or e.follow.target.pos.x) - e.pos.x
    local dy = (e.follow.target.y or e.follow.target.pos.y) - e.pos.y
    local s = e.follow.speed
    local sx, sy = 0, 0
    if (math.abs(dx) > e.follow.tolerance) then sx = dx/math.abs(dx) end
    if (math.abs(dy) > e.follow.tolerance) then sy = dy/math.abs(dy) end
    local n = math.sqrt(sx*sx+sy*sy)
    if (n > 0) then e:addForce(s*sx/n, s*sy/n, ForceMode.VelocityChange) end
end