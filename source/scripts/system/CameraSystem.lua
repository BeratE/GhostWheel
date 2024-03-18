---@diagnostic disable: undefined-field, inject-field, need-check-nil
import "CoreLibs/object"
import "libs/tinyecs"
import "libs/vector"
import "pdlibs/util/debug"

local gfx <const> = playdate.graphics
local disp <const> = playdate.display

-- [[ Lazily follows the player character around by setting the drawing offset ]]
class("CameraSystem").extends()
tinyecs.processingSystem(CameraSystem)
CameraSystem.filter = tinyecs.requireAll("cameraTrack", "sprite")


function CameraSystem:init()
    CameraSystem.super.init(self)
end

function CameraSystem:onAdd(e)
    self.center = vector(disp.getWidth()/2, disp.getHeight()/2)
    self.camera = vector(self.center.x - e.sprite.x + e.cameraTrack.offsetx, self.center.y - e.sprite.y + e.cameraTrack.offsety)
end

function CameraSystem:preProcess(dt)
    self.center = vector(disp.getWidth()/2, disp.getHeight()/2)
end

function CameraSystem:process(e, dt)
    local lerp = CAMERA_LERP_FACTOR
    local tx, ty = self.center.x - e.sprite.x + e.cameraTrack.offsetx, self.center.y - e.sprite.y + e.cameraTrack.offsety
    local cx, cy = self.camera:unpack()
    local sx, sy = cx + lerp*(tx - cx), cy + lerp*(ty - cy)
    self.camera:set(sx, sy)
    gfx.setDrawOffset(self.camera.x, self.camera.y)
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
