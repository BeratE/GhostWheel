import "scripts/scene/Scene"
import "scripts/system/TransformSystem"
import "scripts/system/CameraSystem"
import "scripts/system/RigidBodySystem"
import "scripts/system/BumpWorldSystem"
import "scripts/entity/Level"
import "scripts/entity/Player"
import "libs/pdlog"

local pd <const> = playdate
local gfx <const> = playdate.graphics
local geom <const> = playdate.geometry

--[[ TestScene ]]
class("TestScene").extends(Scene)

function TestScene:init()
    TestScene.super.init(self)
    -- Load levels
    self.levels = {}
    while(true) do
        local levelname = ("test-%i.json"):format(#self.levels + 1)
        local value = Level(levelname)
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
    -- Initialize Systems
    self.systems = {
        rigidbody = RigidBodySystem(),
        bumpworld = BumpWorldSystem(self.levels[self.levelIdx].bumpworld),
        transform = TransformSystem(),
        camera = CameraSystem()
    }
    -- Add Systems
    for _, sys in pairs(self.systems) do
        self.world:addSystem(sys)
    end
    -- Add entities
    self.player = Player()
    self.world:addEntity(self.player)
    self.world:addEntity(self.levels[self.levelIdx])
end

function TestScene:onEnter()
    TestScene.super.onEnter(self)
    log.info("Entering TestScene ..")
    -- Add Sprites
    self.player:add()
    self.levels[self.levelIdx]:add()
end

function TestScene:onExit()
    -- Remove Sprites
    self.player:remove()
    self.levels[self.levelIdx]:remove()
end

local v = 0.1
function TestScene:onUpdate()
    TestScene.super.onUpdate(self)
    self:refreshDeltaTimeMs()
    self.world:update(self:getDeltaTimeMs())

    --print("Impulse Force " .. v)
    if (pd.buttonIsPressed(pd.kButtonA)) then
        v += 0.1
    end
    if (pd.buttonJustPressed(pd.kButtonUp)) then
        RigidBodySystem.addForce(self.player, 0, -v)
        --self.sprite.pos.y += 1
    elseif (pd.buttonJustPressed(pd.kButtonDown)) then
        RigidBodySystem.addForce(self.player, 0, v)
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

function TestScene:switchNextLevel()
    if (self.levels[self.levelIdx]) then
        self.levels[self.levelIdx]:remove()
        self.world:removeEntity(self.levels[self.levelIdx])
    end
    self.levelIdx = (self.levelIdx % #self.levels) + 1
    self.levels[self.levelIdx]:add()
    self.world:addEntity(self.levels[self.levelIdx])
    self.systems.bumpworld.bumpworld = self.levels[self.levelIdx].bumpworld
    log.info("Switching to test-scene " .. self.levelIdx)
end

function TestScene:keyPressed(key)
    if (key == 'n') then
        self:switchNextLevel()
    end
end