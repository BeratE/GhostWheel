import "scripts/system/AbstractSystem"

local gfx <const> = playdate.graphics

-- [[ Manage sprite component of entities ]]
class("DebugSpriteSystem").extends(AbstractSystem)
tinyecs.processingSystem(DebugSpriteSystem)
DebugSpriteSystem.filter = tinyecs.requireAll("debugsprite", "sprite", "name")

function DebugSpriteSystem:onAdd(e)
    e.debugsprite = gfx.sprite.spriteWithText(e.name, 400, 200, gfx.kColorWhite)
    e.debugsprite:add()
end

function DebugSpriteSystem:onRemove(e)
    e.debugsprite:remove()
end

function DebugSpriteSystem:process(e, dt)
    e.debugsprite:moveTo(e.sprite.x, e.sprite.y-10)
end