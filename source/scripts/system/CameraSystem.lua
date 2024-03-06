---@diagnostic disable: undefined-field, inject-field, need-check-nil
import "CoreLibs/object"
import "libs/tinyecs"
import "pdlibs/util/debug"

local gfx <const> = playdate.graphics
local disp <const> = playdate.display
local geom <const> = playdate.geometry

-- [[ Lazily follows the player character around by setting the drawing offset ]]
class("CameraSystem").extends()
tinyecs.processingSystem(CameraSystem)
CameraSystem.filter = tinyecs.requireAll("player")


function CameraSystem:init()
    CameraSystem.super.init(self)
    
end

function CameraSystem:preProcess(dt)
    
end

function CameraSystem:process(e, dt)
    gfx.setDrawOffset(DRAW_OFFSET_X -e.x, DRAW_OFFSET_Y -e.y)
end

function CameraSystem:postProcess(dt)
    
end
