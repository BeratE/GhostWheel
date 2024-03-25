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
        if (not self.follow.target) then
            return true
        end
    end

    e:setFollowTarget(e.target.follow)
end

function FollowSystem:process(e, dt)
    if (not e.follow.target or e.follow.reached) then
        return
    end
    -- Check if target is reached

end