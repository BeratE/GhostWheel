import "CoreLibs/animator"
import "scripts/system/AbstractSystem"

local pd <const> = playdate
local gfx <const> = playdate.graphics

--[[ Entity moves along a given patrol path (reference to another polygon entity)]]
class("PatrolSystem").extends(AbstractSystem)
tinyecs.processingSystem(PatrolSystem)
PatrolSystem.filter = tinyecs.requireAll("patrol", "pos")

function PatrolSystem:init()
    PatrolSystem.super.init(self)
end

function PatrolSystem:onAdd(e)
    -- Check if patrol reference is a polygon entity
    local polygon = e.objref[e.patrol.oid].polygon
    assert(polygon, "Patrol reference must be a polygon object!")
    e.patrol.reverses = e.patrol.reverses or false
    e.patrol.speed = e.patrol.speed or 0.1
    e.patrol.duration = polygon:length()/e.patrol.speed
    e.patrol.animator = gfx.animator.new(e.patrol.duration, polygon)
    e.patrol.animator.reverses = e.patrol.reverses
end

function PatrolSystem:process(e, dt)
    if e.patrol.animator:ended() then
        e.patrol.animator:reset()
    end
    local p = e.patrol.animator:currentValue()
    e.pos:set(p.x, p.y)
end