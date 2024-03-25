import "CoreLibs/animator"
import "scripts/system/AbstractSystem"

local gfx <const> = playdate.graphics

--[[ Entity moves along a given patrol path (reference to another polygon entity)]]
class("PatrolSystem").extends(AbstractSystem)
tinyecs.processingSystem(PatrolSystem)
PatrolSystem.filter = tinyecs.requireAll("patrol", "pos")

function PatrolSystem:onAdd(e)
    e.patrol.polygon = e.patrol.polygon or e.objref[e.patrol.objrefid].polygon
    e.patrol.duration = e.patrol.polygon:length()/e.patrol.speed
    e.patrol.repeatcount = e.patrol.repeatcount or -1
    e.patrol.reverses = e.patrol.reverses or false
    e.patrol.speed = e.patrol.speed or 0.1
    e.patrol.pause = e.patrol.pause or false
    e.patrol.polygonidx = 1
    e.follow = {}

    e.patrolRestart = e.patrolRestart or function ()
        e.patrol.animator = gfx.animator.new(e.patrol.duration, e.patrol.polygon)
        e.patrol.animator.reverses = e.patrol.reverses
        e.patrol.animator.repeatCount = e.patrol.repeatcount
        e.patrol.pause = false
    end
end

function PatrolSystem:process(e, dt)
    if (not e.patrol.animator) then
        if (not e.patrol.pause) then
            e:patrolRestart()
        end
    else
        if e.patrol.animator:ended() then
            if (e.patrol.repeatcount < 0) then
                e.patrol.animator:reset()
            end
        else
            -- Needs fix to work with physics systems
            local p = e.patrol.animator:currentValue()
            e.pos:set(p.x, p.y)
        end
    end
end