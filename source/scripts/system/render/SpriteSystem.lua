import "scripts/system/AbstractSystem"

local gfx <const> = playdate.graphics

-- [[ Manage sprite component of entities ]]
class("SpriteSystem").extends(AbstractSystem)
tinyecs.system(SpriteSystem)
SpriteSystem.filter = tinyecs.requireAll("sprite")

function SpriteSystem:onAdd(e)
    e.sprite:add()
end

function SpriteSystem:onRemove(e)
    e.sprite:remove()
end

function SpriteSystem:preWrap()
    --gfx.clear()
end

function SpriteSystem:update(dt)
    gfx.sprite.update() -- Update all sprites
end