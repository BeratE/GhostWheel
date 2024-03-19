import "scripts/scene/Scene"
import "scripts/system/TransformSystem"
import "scripts/system/CameraSystem"
import "scripts/system/RigidBodySystem"
import "scripts/system/BumpWorldSystem"
import "scripts/system/SpriteSystem"
import "scripts/entity/MapData"
import "scripts/entity/Player"
import "libs/pdlog"

--[[ TestScene ]]
class("TestScene").extends(Scene)

function TestScene:init()
    TestScene.super.init(self)
    -- Initialize Entities
    self.levels = {}
    while(true) do
        local levelname = ("test-%i.json"):format(#self.levels + 1)
        local value = MapData(levelname)
        --[[
        local status, value = pcall(function() return MapData(levelname) end)
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
    --self.player = Player(self.levels[self.levelIdx].spawns.player)
    self.player = Player()
    local bumpworld = self.levels[self.levelIdx].bumpworld
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
    self.world:refresh()
end

function TestScene:onExit()
    log.info("Exiting TestScene ..")
    -- Remove Entities
    self.world:addEntity(self.player)
    self.levels[self.levelIdx]:remove(self.world)
    self.world:refresh()
end

function TestScene:onUpdate()
    TestScene.super.onUpdate(self)
    self:refreshDeltaTimeMs()
    self.world:update(self:getDeltaTimeMs())
end

function TestScene:switchNextLevel()
    local prevIdx = self.levelIdx
    self.levelIdx = (self.levelIdx % #self.levels) + 1
    log.info("Switching to test-scene " .. self.levelIdx)
    if (self.levels[prevIdx]) then
        self.levels[prevIdx]:remove(self.world)
    end
    self.world:refresh()
    self.levels[self.levelIdx]:add(self.world)
    self.systems.bumpworld:setBumpWorld(self.levels[self.levelIdx].bumpworld)
    self.world:refresh()
end

local v = 0.1
function TestScene:keyPressed(key)
    -- Print help
    if (key == "h") then
        log.info("TestScene Simulator Keyboard help: ")
        log.info("i - Move player up")
        log.info("k - Move player down")
        log.info("j - Move player left")
        log.info("l - Move player right")
        log.info("+ - Increase player velocity")
        log.info("c - toggle collision")
        log.info("n - switch to next level")
    end

    if (key == 'n') then
        self:switchNextLevel()
    elseif (key == "i") then
        self.player:addForce(0, -v)
    elseif (key == "k") then
        self.player:addForce(0, v)
    elseif (key == "j") then
        self.player:addForce(-v, 0)
    elseif (key == "l") then
        self.player:addForce(v, 0)
    elseif (key == "+") then
        v += 0.1
    elseif (key == "c") then
        if (self.systems.bumpworld.world == nil) then
            log.info("DEBUG: Activate Collision")
            self.world:addSystem(self.systems.bumpworld)
        else
            log.info("DEBUG: Deactivate Collision")
            self.world:removeSystem(self.systems.bumpworld)
        end
    end
end