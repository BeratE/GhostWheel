import "CoreLibs/object"
import "libs/ecs/tiny"
import "pdlibs/state/State"
import "scripts/system/render/AffineTransformSystem"
import "scripts/system/render/DrawBackgroundSystem"
import "scripts/system/physics/RigidBodySystem"
import "scripts/entity/level/TiledMap"
import "assets"

local pd <const> = playdate
local gfx <const> = playdate.graphics

--[[ Each Game Scene contains an ECS World 
 and is responsible for managing entities and systems. ]]
class("Scene").extends(pdlibs.state.State)

function Scene:init()
    self.world = tinyecs.world() -- Each scene holds its own ecs-world
    --self.world:addSystem(DrawBackgroundSystem())
    self.world:addSystem(AffineTransformSystem())
    self.world:addSystem(RigidBodySystem())

    local img = assets.getImageTable("people-dead")
    self.sprite = gfx.sprite.new(img:getImage(1))
    self.sprite:add()
    self.sprite:setCenter(0.5, 0.5)
    self.sprite.pos = playdate.geometry.point.new(0, 0)
    self.sprite.mass = 80
    self.sprite:setZIndex(10)

    self.world:add(self.sprite)
    self.world:refresh()

    self.level = TiledMap("test.json")
    self.level:add()
    


    self.currTimeMs = pd.getCurrentTimeMilliseconds()
    self.deltaTimeMs = 0
end

function Scene:onEnter()
    _G["world"] = self.world
end

function Scene:onExit()
end

local v = 1
function Scene:onUpdate()
    self:refreshDeltaTimeMs()
    self.world:update(self:getDeltaTimeMs())

    --print("Impulse Force " .. v)
    if (pd.buttonIsPressed(pd.kButtonA)) then
        v += 1
    end
    if (pd.buttonJustPressed(pd.kButtonUp)) then
        RigidBodySystem.addForce(self.sprite, v, v)
        --self.sprite.pos.y += 1
    elseif (pd.buttonJustPressed(pd.kButtonDown)) then
        RigidBodySystem.addForce(self.sprite, -v, -v)
        --self.sprite.pos.y -= 1
    elseif (pd.buttonJustPressed(pd.kButtonLeft)) then
        RigidBodySystem.addForce(self.sprite, -v, v)
        --self.sprite.pos.x -= 1
    elseif (pd.buttonJustPressed(pd.kButtonRight)) then
        RigidBodySystem.addForce(self.sprite, v, -v)
        --self.sprite.pos.x += 1
    end
    --print("Pos Sprite" .. self.sprite.x .. " " .. self.sprite.y)
    --print("Pos " .. self.sprite.pos.x .. " " .. self.sprite.pos.y)
end

function Scene:refreshDeltaTimeMs()
    -- update delta time
    local nowTimeMs = pd.getCurrentTimeMilliseconds()
    self.deltaTimeMs = nowTimeMs - self.currTimeMs
    self.currTimeMs = nowTimeMs
end

function Scene:getDeltaTimeMs()
    return self.deltaTimeMs
end