---@diagnostic disable: undefined-field, inject-field, need-check-nil
import "CoreLibs/object"
import "libs/tinyecs"
import "pdlibs/util/debug"

local gfx <const> = playdate.graphics
local disp <const> = playdate.display

-- [[ Manage sprite component of entities ]]
class("SpriteSystem").extends()
tinyecs.system(SpriteSystem)
SpriteSystem.filter = tinyecs.requireAll("sprite")


function SpriteSystem:init()
    SpriteSystem.super.init(self)
end

function SpriteSystem:onAdd(e)
    e.sprite:add()
end

function SpriteSystem:onRemove(e)
    e.sprite:remove()
end

function SpriteSystem:update(dt)
    gfx.sprite.update() -- Update all sprites
end