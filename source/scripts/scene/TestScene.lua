import "scripts/scene/Scene"
import "scripts/system/render/DebugSpriteSystem"
import "scripts/system/render/SpriteSystem"
import "scripts/system/render/TransformSystem"
import "scripts/system/render/CameraSystem"
import "scripts/system/physics/RigidBodySystem"
import "scripts/system/physics/BumpWorldSystem"
import "scripts/system/logic/EventSystem"
import "scripts/system/logic/FollowSystem"
import "scripts/system/logic/PatrolSystem"
import "scripts/entity/MapData"
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
    local level = self.levels[self.levelIdx]
    self.player = level.player
    -- Initialize Systems
    self.systems = {
        bumpworld = BumpWorldSystem(level),
        transform = TransformSystem(level),
        rigidbody = RigidBodySystem(),
        --debugsprite = DebugSpriteSystem(),
        sprite = SpriteSystem(),
        camera = CameraSystem(),
        event = EventSystem(),
        follow = FollowSystem(),
        patrol = PatrolSystem()
    }
    self:addSystems(self.systems)
end

function TestScene:onEnter()
    TestScene.super.onEnter(self)
    log.info("Entering TestScene ..")
    self.levels[self.levelIdx]:add(self.world)
    self.world:refresh()
    gfx.setFont(assets.getFont("ruby_12"))
end

function TestScene:onExit()
    TestScene.super.onExit(self)
    log.info("Exiting TestScene ..")
    self.levels[self.levelIdx]:remove(self.world)
    self.world:refresh()
end

function TestScene:onUpdate()
    TestScene.super.onUpdate(self)
    self:debugDraw()
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
    for _, sys in pairs(self.systems) do
        sys:setMapData(self.levels[self.levelIdx])
    end
    self.world:refresh()
end

local v = 0.1
local capture = {
    code = {},
    mode = false,
}
function capturecode(code)
    local number = 0
    for i = #code, 1, -1 do
        local c = code[i]
        local e = 10^(#code - i)
        number += c*e
    end
    return number
end

function TestScene:keyPressed(key)
    -- Print help
    if (key == "h") then
        log.info("TestScene Simulator Keyboard help: ")
        log.info("i - Move player up")
        log.info("k - Move player down")
        log.info("j - Move player left")
        log.info("l - Move player right")
        log.info("u - Increase player velocity")
        log.info("c - toggle collision")
        log.info("n - switch to next level")
        log.info("+ - open capture code (cc) mode")
        log.info("+(%d+)o - cc print object with given oid")
    end
    -- Code Capture (CC) Mode
    if (key == '+') then
        capture.mode = true
        capture.code = {}
        log.info("Opening code capture mode.")
    end
    if (capture.mode) then
        if (key:match("%d")) then
            table.insert(capture.code, tonumber(key))
            log.info(("Captured code %i"):format(capturecode(capture.code)))
        end
        if (key == "o") then
            local code = capturecode(capture.code)
            log.info(("Closing code capture mode, code %i."):format(code))
            capture.code = {}
            local entity = self.levels[self.levelIdx].objects[code]
            log.info(("Table for objectid %i"):format(code))
            printTable(entity)
        end
    end
    -- Level Management
    if (key == 'n') then
        self:switchNextLevel()
    end
    if (key == "c") then
        if (self.systems.bumpworld.world == nil) then
            log.info("DEBUG: Activate Collision")
            self.world:addSystem(self.systems.bumpworld)
        else
            log.info("DEBUG: Deactivate Collision")
            self.world:removeSystem(self.systems.bumpworld)
        end
    end
    -- Player Movement
    if (key == "i") then
        self.player:addForce(0, -v)
    elseif (key == "k") then
        self.player:addForce(0, v)
    elseif (key == "j") then
        self.player:addForce(-v, 0)
    elseif (key == "l") then
        self.player:addForce(v, 0)
    elseif (key == "u") then
        v += 0.1
    end
end

function TestScene:debugDraw()
    if (not DEBUG_DRAW) then
        return
    end
    for _, e in ipairs(self.systems.bumpworld.entities) do
        -- Draw Hitbox
        local x, y, w, h = e.pos.x, e.pos.y, e.hitbox.w, e.hitbox.h
        local rect = pd.geometry.rect.new(x, y, w, h):toPolygon()
        self.systems.transform.toScreen:transformPolygon(rect)
        local p = rect:getPointAt(1)

        gfx.pushContext()
            if (e.immobile) then gfx.setColor(gfx.kColorWhite)
            else gfx.setColor(gfx.kColorBlack) end
            gfx.setDitherPattern(0.5, gfx.image.kDitherTypeBayer2x2)
            gfx.fillPolygon(rect)
        gfx.popContext()

        -- Draw Name
        local name = e.name
        local tw, th = gfx.getTextSize(name)
        gfx.pushContext()
            gfx.setColor(gfx.kColorWhite)
            gfx.setDitherPattern(0.2, gfx.image.kDitherTypeBayer8x8)
            gfx.setLineWidth(2)
            gfx.fillRect(p.x-tw/2, p.y-th, tw, th)
        gfx.popContext()
        gfx.pushContext()
            gfx.setColor(gfx.kColorBlack)
            gfx.drawText(name, p.x-tw/2, p.y-th)
        gfx.popContext()
    end
end