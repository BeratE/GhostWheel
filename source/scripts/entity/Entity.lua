import "CoreLibs/object"
import "CoreLibs/graphics"
import "libs/vector"

local gfx <const> = playdate.graphics

--[[ Abstract Entity class, holds unique id.
All entities in the world should inherit or be in instance of this. ]]
class("Entity").extends()

-- Predefined IDs
Entity.ID = {
    Player = 1
}
local next_id = (#Entity.ID+1)

function Entity:init()
    self.entityid = next_id
    next_id += 1
end


function Entity:setDebugSprite()
    self.debugsprite = true
    self.width, self.height = 32, 32
    local img = gfx.image.new(self.width, self.height)
    gfx.pushContext(img)
    gfx.setColor(gfx.kColorBlack)
    gfx.fillEllipseInRect(0, 0, self.width, self.height)
    gfx.setColor(gfx.kColorWhite)
    gfx.fillEllipseInRect(2, 2, self.width-4, self.height-4)
    gfx.popContext()
    self.sprite = gfx.sprite.new(img)
    self.sprite:setCenter(0.5, 0.0)
    self.sprite:setZIndex(0)
end