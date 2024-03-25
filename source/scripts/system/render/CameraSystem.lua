import "scripts/system/AbstractSystem"


local gfx <const> = playdate.graphics
local disp <const> = playdate.display

-- [[ Lazily follows the player character around by setting the drawing offset ]]
class("CameraSystem").extends(AbstractSystem)
tinyecs.processingSystem(CameraSystem)
CameraSystem.filter = tinyecs.requireAll("cameratrack", "sprite")

function CameraSystem:onAdd(e)
    if not e.cameratrack then
        return
    end
    self.center = vector(disp.getWidth()/2, disp.getHeight()/2)
    self.camera = vector(self.center.x - e.sprite.x, self.center.y - e.sprite.y)
end

function CameraSystem:preProcess(dt)
    self.center = vector(disp.getWidth()/2, disp.getHeight()/2)
end

function CameraSystem:process(e, dt)
    if not e.cameratrack then
        return
    end
    local lerp = CAMERA_LERP_FACTOR
    local tx, ty = self.center.x - e.sprite.x, self.center.y - e.sprite.y
    local cx, cy = self.camera:unpack()
    local sx, sy = cx + lerp*(tx - cx), cy + lerp*(ty - cy)
    self.camera:set(sx, sy)
    gfx.setDrawOffset(self.camera.x, self.camera.y)
end
