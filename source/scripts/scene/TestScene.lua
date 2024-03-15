import "scripts/scene/Scene"
import "scripts/system/TransformSystem"
import "scripts/system/CameraSystem"
import "scripts/system/RigidBodySystem"
import "scripts/system/TiledMapSystem"
import "scripts/entity/TiledMap"
import "scripts/entity/Player"
import "libs/pdlog"

local pd <const> = playdate
local gfx <const> = playdate.graphics
local geom <const> = playdate.geometry

--[[ TestScene ]]
class("TestScene").extends(Scene)

function TestScene:init()
    TestScene.super.init(self)
    self.world:addSystem(TransformSystem())
    self.world:addSystem(RigidBodySystem())
    self.world:addSystem(TiledMapSystem())
    self.world:addSystem(CameraSystem())
    self.player = Player()
end

function TestScene:onEnter()
    TestScene.super.onEnter(self)
    log.info("Entering TestScene ..")
    --[[ All entities to world ]]

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
        self.world:addEntity(self.levels[self.levelIdx])
    end
    
    -- Add player
    self.player:add()
    self.world:addEntity(self.player)

    self.world:refresh()

    --local x, y = TransformSystem.TD2ISO():transformXY(self.levels[self.levelIdx].spawn_player.x, self.levels[self.levelIdx].spawn_player.y)
    --self.player.pos = geom.point.new(self.levels[self.levelIdx].spawn_player.x, self.levels[self.levelIdx].spawn_player.y)
end

function TestScene:nextLevel()
    self.levels[self.levelIdx]:remove()
    self.world.removeEntity(self.levels[self.levelIdx])
    self.levelIdx = (self.levelIdx % #self.levels) + 1
    self.levels[self.levelIdx]:add()
    self.world.addEntity(self.levels[self.levelIdx])
    log.info("Switching to test-scene " .. self.levelIdx)
end

local v = 0.01
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
    
end

function TestScene:keyPressed(key)
    --if (key == 'n') then
        self:nextLevel()
    --end
end