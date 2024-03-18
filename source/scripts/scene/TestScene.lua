import "scripts/scene/Scene"
import "scripts/system/TransformSystem"
import "scripts/system/CameraSystem"
import "scripts/system/RigidBodySystem"
import "scripts/system/BumpWorldSystem"
import "scripts/system/SpriteSystem"
import "scripts/entity/Level"
import "scripts/entity/Player"
import "libs/pdlog"

local pd <const> = playdate
local gfx <const> = playdate.graphics

--[[ TestScene ]]
class("TestScene").extends(Scene)

function TestScene:init()
    TestScene.super.init(self)
    -- Initialize Entities
    self.levels = {}
    while(true) do
        local levelname = ("test-%i.json"):format(#self.levels + 1)
        --local value = Level(levelname)
        --
        local status, value = pcall(function() return Level(levelname) end)
        if (not status) then
            log.warn(value)
            break
        end
        --
        table.insert(self.levels, value)
        break
    end
    if (#self.levels == 0) then
        error("No test levels found for TestScene", 2)
    end
    self.levelIdx = 1
    local bumpworld = self.levels[self.levelIdx].bumpworld
    self.player = Player(self.levels[self.levelIdx].spawns.player)
    -- Initialize Systems
    self.systems = {
        rigidbody = RigidBodySystem(),
        bumpworld = BumpWorldSystem(bumpworld),
        transform = TransformSystem(),
        sprite = SpriteSystem(),
        camera = CameraSystem()
    }
    -- Add Systems
    for _, sys in pairs(self.systems) do
        self.world:addSystem(sys)
    end
end

function TestScene:onEnter()
    TestScene.super.onEnter(self)
    log.info("Entering TestScene ..")
    -- Add Entities
    self.world:addEntity(self.player)
    self.levels[self.levelIdx]:add(self.world)
end

function TestScene:onExit()
    log.info("Exiting TestScene ..")
    -- Remove Entities
    self.world:addEntity(self.player)
    self.levels[self.levelIdx]:remove(self.world)
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
        self.player:addForce(0, -v)
    elseif (pd.buttonJustPressed(pd.kButtonDown)) then
        self.player:addForce(0, v)
    elseif (pd.buttonJustPressed(pd.kButtonLeft)) then
        self.player:addForce(-v, 0)
    elseif (pd.buttonJustPressed(pd.kButtonRight)) then
        self.player:addForce(v, 0)
    end
    --print("Pos Sprite" .. self.sprite.x .. " " .. self.sprite.y)
    
end

function TestScene:switchNextLevel()
    local prevIdx = self.levelIdx
    self.levelIdx = (self.levelIdx % #self.levels) + 1
    log.info("Switching to test-scene " .. self.levelIdx)
    if (self.levels[prevIdx]) then
        self.levels[prevIdx]:remove(self.world)
    end
    self.levels[self.levelIdx]:add(self.world)
    self.systems.bumpworld.bumpworld = self.levels[self.levelIdx].bumpworld
    self.world:refresh()
end

function TestScene:keyPressed(key)
    if (key == 'n') then
        self:switchNextLevel()
    end
end