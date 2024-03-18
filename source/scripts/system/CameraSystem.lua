---@diagnostic disable: undefined-field, inject-field, need-check-nil
import "CoreLibs/object"
import "libs/tinyecs"
import "libs/vector"
import "pdlibs/util/debug"

local gfx <const> = playdate.graphics
local disp <const> = playdate.display

local function round(x)
    return math.floor(x * 32 + 16) / 32
end

-- [[ Lazily follows the player character around by setting the drawing offset ]]
class("CameraSystem").extends()
tinyecs.processingSystem(CameraSystem)
CameraSystem.filter = tinyecs.requireAll("cameraTrack", "sprite")


function CameraSystem:init()
    CameraSystem.super.init(self)
end

function CameraSystem:onAdd(e)
    local xo, yo = e.cameraTrack.xoffset, e.cameraTrack.yoffset
    local x, y = e.sprite.x + xo, e.sprite.y + yo
    self.camera = vector(x, y)
end

function CameraSystem:preProcess(dt)
end

function CameraSystem:process(e, dt)
    local xo, yo = e.cameraTrack.xoffset, e.cameraTrack.yoffset
    local x, y = e.sprite.x + xo, e.sprite.y + yo
    local xp, yp = self.camera:unpack()
    local lerp = 0.1
    self.camera:set(-round(xp + (x - xp) * lerp), -round(yp + (y - yp) * lerp))

    --gfx.setDrawOffset(self.camera.x, self.camera.y)
    gfx.setDrawOffset(disp.getWidth()/2 -e.sprite.x, disp.getHeight()/2 -e.sprite.y)
end

function CameraSystem:postProcess(dt)
end

function CameraSystem.getViewPort()
    local drawOffset = gfx.getDrawOffset()
    return {
        x = drawOffset.x, y = drawOffset.y,
        w = disp.getWidth(), h = disp.getHeight()
    }
end
