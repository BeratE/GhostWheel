import "CoreLibs/animator"
import "scripts/system/AbstractSystem"

local gfx <const> = playdate.graphics

--[[ Entity moves along a given patrol path (reference to another polygon entity).
Employs the FollowSystem by setting target points along a polygon. ]]
class("PatrolSystem").extends(AbstractSystem)
tinyecs.processingSystem(PatrolSystem)
PatrolSystem.filter = tinyecs.requireAll("patrol", "pos")

function PatrolSystem:onAdd(e)
    e.patrol.polygon = e.patrol.polygon or e.objref[e.patrol.objrefid].polygon
    e.patrol.repeatcount = e.patrol.repeatcount or -1
    e.patrol.reverses = e.patrol.reverses or false
    e.patrol.speed = e.patrol.speed or 0.1
    e.patrol.pause = e.patrol.pause or false
    e.patrol.polygonidx = 1
    e.patrol.currentdir = 1
    e.patrol.iteration = 1
    e.follow = {
        target = e.patrol.polygon:getPointAt(1),
        pause = e.patrol.pause,
        speed = e.patrol.speed
    }
    _G["world"]:addEntity(e)
end

function PatrolSystem:process(e, dt)
    if (e.patrol.pause or
        not e.hasFollowReached or
        ((e.patrol.repeatcount > -1) and
         (e.patrol.iteration > e.patrol.repeatcount+1))) then
        return
    end
    e.follow.pause = e.patrol.pause
    e.follow.speed = e.patrol.speed
    if (e:hasFollowReached()) then
        e.patrol.polygonidx += e.patrol.currentdir
        if (e.patrol.polygonidx == 0 or e.patrol.polygonidx == e.patrol.polygon:length()+1) then
            e.patrol.iteration += 1
            if (e.patrol.reverses) then
                e.patrol.currentdir = -e.patrol.currentdir
                e.patrol.polygonidx += 2*e.patrol.currentdir
            end
        end
        e.follow.target = e.patrol.polygon:getPointAt(e.patrol.polygonidx)
    end
end