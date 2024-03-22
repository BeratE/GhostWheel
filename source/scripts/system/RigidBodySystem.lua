import "CoreLibs/object"
import "pdlibs/util/math"
import "libs/tinyecs"
import "libs/vector"
import "scripts/system/AbstractSystem"

--[[ Simple Rigid-Body 2D (top-down) physics engine working in tile coordinates.
Units: kilogram kg, meter m, milliseconds ms. (Usage of milliseconds to avoid floating-point errors)
Order of physics system:
* 1 Positional Logic
2 Collision detection
3 Collisions resolution
]]

local PRECISION <const> = 0.0001

class("RigidBodySystem").extends(AbstractSystem)
tinyecs.processingSystem(RigidBodySystem)
RigidBodySystem.filter = tinyecs.requireAll(tinyecs.requireAll("pos"), tinyecs.rejectAny("immobile", "imagelayer", "tilelayer"))

function RigidBodySystem:init()
    RigidBodySystem.super.init(self)
end

function RigidBodySystem:onAdd(e)
    RigidBodySystem.initRigidBody(e)
end

--[[ Positional Logic ]]
function RigidBodySystem:process(e, dt)
    -- Apply linear damping force
    e:addForce(-e.lindamp * e.vel.x, -e.lindamp * e.vel.y)
    -- Set acceleration using the impulse forces acting on object
    e.acc.x = e.force.x/e.mass
    e.acc.y = e.force.y/e.mass
    e.force = vector(0, 0)
    -- Velocity verlet integration
    e.moved = false
    local x = e.pos.x + e.vel.x*dt + e.acc.x/2*dt*dt
    local y = e.pos.y + e.vel.y*dt + e.acc.y/2*dt*dt
    if (e.pos.x ~= x or e.pos.y ~= y) then
        e.pos.x, e.pos.y = x, y
        e.moved = true
    end
    e.vel.x += e.acc.x*dt
    e.vel.y += e.acc.y*dt
    -- Clamp velocity
    if (math.abs(e.acc.x) < PRECISION) then e.acc.x = 0 end
    if (math.abs(e.acc.y) < PRECISION) then e.acc.y = 0 end
    if (math.abs(e.vel.x) < PRECISION) then e.vel.x = 0 end
    if (math.abs(e.vel.y) < PRECISION) then e.vel.y = 0 end
    --print("Entity Acc: " .. e.acc.x .. ", " .. e.acc.y)
    --print("Entity Vel: " .. e.vel.x .. ", " .. e.vel.y)
    --print("Entity Pos " .. e.pos.x .. " " .. e.pos.y)
end


--[[ Static helper functions ]]

-- Add all the required components for the rigid body system
function RigidBodySystem.initRigidBody(e, mass, lindamp, pos)
    e.pos = e.pos or pos or vector(0, 0) -- Current position of the object
    --[[ Scalar components ]]
    -- Mass of object in kg (minimum of 1gram) - default 80kg
    e.mass = e.mass or mass or 80
    e.mass = math.max(e.mass, 0.001)
    -- linear damping factor [0, 1], i.e. resistance to movement
    e.lindamp = e.lindamp or lindamp or 0.1
    e.lindamp = pdlibs.math.clamp(e.lindamp, 0.0, 1.0)
    --[[ Vector components ]]
    e.force = e.force or vector(0, 0) -- Accumulated forces acting on the object in the next timestep 
    e.acc = e.acc or vector(0, 0) -- Current acceleration of the object
    e.vel = e.vel or vector(0, 0) -- Current velocity of the object

    -- Add impulse force to entity
    e.addForce = e.addForce or function (self, fx, fy)
        self.force.x += fx
        self.force.y += fy
    end
    -- Stop all movement
    e.stopMovement = e.stopMovement or function (self)
        self.vel:set(0, 0)
        self.acc:set(0, 0)
    end
end