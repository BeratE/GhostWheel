import "scripts/system/AbstractSystem"

--[[ Simple Rigid-Body 2D (top-down) physics engine working in tile coordinates.
Units: kilogram kg, meter m, milliseconds ms. (Usage of milliseconds to avoid floating-point errors)
Order of physics system:
* 1 Positional Logic
2 Collision detection
3 Collisions resolution
]]

ForceMode = {
    Force = 1,          -- Input as Force [N], change vel by force*dt/mass
    Impulse = 2,        -- Input as impulse [N/s], change vel by force/mass (default)
    Acceleration = 3,   -- Input as acceleration [m/s^2], change 
    VelocityChange = 4  -- Input as direct velocity change [m/s]
}

local PRECISION <const> = 0.0001

class("RigidBodySystem").extends(AbstractSystem)
tinyecs.processingSystem(RigidBodySystem)
RigidBodySystem.filter = tinyecs.requireAll(tinyecs.requireAll("pos"), tinyecs.rejectAny("immobile", "imagelayer", "tilelayer"))

function RigidBodySystem:onAdd(e)
    RigidBodySystem.initRigidBody(e)
end

--[[ Positional Logic ]]
function RigidBodySystem:process(e, dt)
    -- Apply linear damping force
    e:addForce(-e.lindamp * e.vel.x, -e.lindamp * e.vel.y)
    -- Set immediate acceleration 
    e.acc.x = e.force[ForceMode.Acceleration].x
    e.acc.y = e.force[ForceMode.Acceleration].y
    e.force[ForceMode.Acceleration] = vector(0, 0)
    -- Set acceleration using immediate forces
    e.acc.x += e.force[ForceMode.Force].x*dt/e.mass
    e.acc.y += e.force[ForceMode.Force].y*dt/e.mass
    e.force[ForceMode.Force] = vector(0, 0)
    -- Set acceleration using the impulse forces acting on object
    e.acc.x += e.force[ForceMode.Impulse].x/e.mass
    e.acc.y += e.force[ForceMode.Impulse].y/e.mass
    e.force[ForceMode.Impulse] = vector(0, 0)
    -- Set direct velocity change
    e.vel.x += e.force[ForceMode.VelocityChange].x
    e.vel.y += e.force[ForceMode.VelocityChange].y
    e.force[ForceMode.VelocityChange] = vector(0, 0)
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
end


--[[ Static helper functions ]]

-- Add all the required components for the rigid body system
function RigidBodySystem.initRigidBody(e, mass, lindamp, pos)
    e.pos = e.pos or pos or vector(0, 0) -- Current position of the object
    if (not isvector(e.pos)) then
        e.pos = vector (e.pos.x, e.pos.y)
    end
    --[[ Scalar components ]]
    -- Mass of object in kg (minimum of 1gram) - default 80kg
    e.mass = e.mass or mass or 80
    e.mass = math.max(e.mass, 0.001)
    -- linear damping factor [0, 1], i.e. resistance to movement
    e.lindamp = e.lindamp or lindamp or 0.1
    e.lindamp = pdlibs.math.clamp(e.lindamp, 0.0, 1.0)
    --[[ Vector components ]]
    e.force = e.force or {} -- Accumulated forces acting on the object in the next timestep
    e.force[ForceMode.Force] = e.force[ForceMode.Force] or vector(0, 0)
    e.force[ForceMode.Impulse] = e.force[ForceMode.Impulse] or vector(0, 0)
    e.force[ForceMode.Acceleration] = e.force[ForceMode.Acceleration] or vector(0, 0)
    e.force[ForceMode.VelocityChange] = e.force[ForceMode.VelocityChange] or vector(0, 0)
    e.acc = e.acc or vector(0, 0) -- Current acceleration of the object
    e.vel = e.vel or vector(0, 0) -- Current velocity of the object

    -- Add impulse force to entity
    e.addForce = e.addForce or function (self, fx, fy, mode)
        mode = mode or ForceMode.Impulse
        self.force[mode].x += fx
        self.force[mode].y += fy
    end
    -- Stop all movement
    e.stopMovement = e.stopMovement or function (self)
        self.vel:set(0, 0)
        self.acc:set(0, 0)
    end
end