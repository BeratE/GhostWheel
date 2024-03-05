import "CoreLibs/object"
import "libs/ecs/tiny"

local gfx <const> = playdate.graphics
local disp <const> = playdate.display

class("DrawBackgroundSystem").extends()
tinyecs.system(DrawBackgroundSystem)

function DrawBackgroundSystem:init()
    DrawBackgroundSystem.super.init(self)
end

function DrawBackgroundSystem:update(dt)
	gfx.fillRect(0, 0, disp:getWidth(), disp:getHeight())
end