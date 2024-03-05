---@diagnostic disable: undefined-field, inject-field, need-check-nil
import "CoreLibs/object"
import "libs/ecs/tiny"
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
    
end

function CameraSystem:postProcess(dt)
    
end
