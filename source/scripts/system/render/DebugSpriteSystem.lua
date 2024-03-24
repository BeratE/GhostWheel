import "scripts/system/AbstractSystem"

local gfx <const> = playdate.graphics

-- [[ Manage sprite component of entities ]]
class("DebugSpriteSystem").extends(AbstractSystem)
tinyecs.processingSystem(DebugSpriteSystem)
DebugSpriteSystem.filter = tinyecs.requireAll("debugsprite", "sprite", "name")


function DebugSpriteSystem:init()
    DebugSpriteSystem.super.init(self)
end

function DebugSpriteSystem:process(e, dt)
    local x, y = e.sprite.x, e.sprite.y
    local name = e.name
    gfx.drawText(name, x, y)
end