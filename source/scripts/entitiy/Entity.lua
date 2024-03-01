import "CoreLibs/object"
import "CoreLibs/sprite"
import "pdlibs/state/StateMachine"

local pd <const> = playdate
local gfx <const> = playdate.graphics

class("Entity").extends()

function Entity:init()
    Entity.super.init(self)
    self:resetKinematics()
    self:initCollision()
end

function Entity:update()
    Entity.super.update(self)

    self:updateKinematics()
end

function Entity:updateState()
end

--[[ Apply kinematic movement using velocity and acceration.
 Apprixmated velocity verlet (assuming constant acceleration). ]]
function Entity:updateKinematics()
    local x = self.x + self.vel.x*dt + self.acc.x/2*dt*dt
    local y = self.y + self.vel.y*dt + self.acc.y/2*dt*dt
    self.vel.x += self.acc.x*dt
    self.vel.y += self.acc.y*dt
    self:moveWithCollisions(x, y)
end

function Entity:resetKinematics()
    self.kinematics = {
        acc = {0, 0},
        vel = {0, 0}
    }
end

function Entity:initCollision()
    self:setCollideRect(0, 0, 8, 8)
    self.collisionResponse = function (self, other)
        return gfx.sprite.kCollisionTypeOverlap
    end
end

function Entity:initState()
    self.state = pdlibs.state.StateMachine()
end