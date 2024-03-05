---@diagnostic disable: undefined-field
import "CoreLibs/object"
import "pdlibs/util/math"
import "libs/ecs/tiny"

--[[ Simple Rigid-Body 2D (top-down) physics engine.
Units: kilogram kg, meter m, milliseconds ms.
(Usage of milliseconds to avoid floating-point errors)
Order of operations:
1 Positional Logic
2 Collision detection
3 Collisions resolution
]]

local point <const> = playdate.geometry.point

--[[ Basic implementation of 2D rigid body dynamics. ]]
class("RigidBodySystem").extends()
tinyecs.processingSystem(RigidBodySystem)
RigidBodySystem.filter = tinyecs.requireAll("pos")

function RigidBodySystem:init()
    RigidBodySystem.super.init(self)
end

function RigidBodySystem:onAdd(e)
    self.addRigidBody(e)
end

function RigidBodySystem:process(e, dt)
    --[[ Positional Logic ]]
    -- Apply linear damping force
    self.addForce(e, - e.lindamp * e.vel.x, - e.lindamp * e.vel.y)
    -- Set acceleration using the impulse forces acting on object
    e.acc.x = e.force.x/e.mass
    e.acc.y = e.force.y/e.mass
    e.force = point.new(0, 0)
    -- Velocity verlet integration    
    e.pos:offset(e.vel.x*dt + e.acc.x/2*dt*dt, e.vel.y*dt + e.acc.y/2*dt*dt)
    e.vel:offset(e.acc.x*dt, e.acc.y*dt)
    -- Clamp velocity
    if (math.abs(e.acc.x) < 0.01) then e.acc.x = 0 end
    if (math.abs(e.acc.y) < 0.01) then e.acc.y = 0 end
    if (math.abs(e.vel.x) < 0.01) then e.vel.x = 0 end
    if (math.abs(e.vel.y) < 0.01) then e.vel.y = 0 end
    
    --print("Entity Acc: " .. e.acc.x .. ", " .. e.acc.y)
    --print("Entity Vel: " .. e.vel.x .. ", " .. e.vel.y)
end


--[[ Static helper functions ]]

-- Add all the required components for the rigid body system
function RigidBodySystem.addRigidBody(e, mass, lindamp)
    --[[ Scalar ]]
    -- Mass of object in kg (minimum of 1gram)
    e.mass = e.mass or mass or 1
    e.mass = math.max(e.mass, 0.001)
    -- linear daming factor [0, 1], i.e. resistance to movement
    e.lindamp = e.lindamp or lindamp or 0.1
    e.lindamp = pdlibs.math.clamp(e.lindamp, 0.0, 1.0)
    --[[ Vector ]]
    e.force = e.force or point.new(0, 0) -- Forces currently acting on the object
    e.vel = e.vel or point.new(0, 0) -- Current velocity of the object
    e.acc = e.acc or point.new(0, 0) -- Current acceleration of the object
    e.pos = e.pos or point.new(0, 0) -- Current position of the object
end

function RigidBodySystem.addForce(e, fx, fy)
    e.force:offset(fx, fy)
    return e.force
end