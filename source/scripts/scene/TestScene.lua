import "scripts/scene/Scene"
import "scripts/system/IsometricTransformSystem"
import "scripts/system/CameraSystem"
import "scripts/system/RigidBodySystem"
import "scripts/entity/TiledMap"
import "scripts/entity/Player"
import "libs/pdlog"

local pd <const> = playdate
local gfx <const> = playdate.graphics

--[[ TestScene ]]
class("TestScene").extends(Scene)

function TestScene:init()
    TestScene.super.init(self)
    self.world:addSystem(IsometricTransformSystem())
    self.world:addSystem(RigidBodySystem())
    self.world:addSystem(CameraSystem())

    self.player = Player()
    self.player:add()

    self.world:add(self.player)
    self.world:refresh()
end

function TestScene:onEnter()
    TestScene.super.onEnter(self)
    log.info("Entering TestScene ..")

    -- Add Levels
    if (not self.levels) then
        self.levels = {}
        while(true) do
            local levelname = ("test-%i.json"):format(#self.levels + 1)
            local value = TiledMap(levelname)
            --[[
            local status, value = pcall(function() return TiledMap(levelname) end)
            if (not status) then
                log.warn(value)
                break
            end
            --]]
            table.insert(self.levels, value)
            break
        end
        if (#self.levels == 0) then
            error("No test levels found for TestScene", 2)
        end
        self.levelIdx = 1
        self.levels[self.levelIdx]:add()
    end
end

function TestScene:nextLevel()
    self.levels[self.levelIdx]:remove()
    self.levelIdx = (self.levelIdx % #self.levels) + 1
    self.levels[self.levelIdx]:add()
    log.info("Switching to test-scene " .. self.levelIdx)
end

local v = 1
function TestScene:onUpdate()
    TestScene.super.onUpdate(self)
    self:refreshDeltaTimeMs()
    self.world:update(self:getDeltaTimeMs())

    --print("Impulse Force " .. v)
    if (pd.buttonIsPressed(pd.kButtonA)) then
        v += 1
    end
    if (pd.buttonJustPressed(pd.kButtonUp)) then
        RigidBodySystem.addForce(self.player, 0, v)
        --self.sprite.pos.y += 1
    elseif (pd.buttonJustPressed(pd.kButtonDown)) then
        RigidBodySystem.addForce(self.player, 0, -v)
        --self.sprite.pos.y -= 1
    elseif (pd.buttonJustPressed(pd.kButtonLeft)) then
        RigidBodySystem.addForce(self.player, -v, 0)
        --self.sprite.pos.x -= 1
    elseif (pd.buttonJustPressed(pd.kButtonRight)) then
        RigidBodySystem.addForce(self.player, v, 0)
        --self.sprite.pos.x += 1
    end
    --print("Pos Sprite" .. self.sprite.x .. " " .. self.sprite.y)
    --print("Pos " .. self.sprite.pos.x .. " " .. self.sprite.pos.y)
end

function TestScene:keyPressed(key)
    --if (key == 'n') then
        self:nextLevel()
    --end
end