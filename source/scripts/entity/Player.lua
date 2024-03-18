---@diagnostic disable: undefined-field, need-check-nil
import "CoreLibs/object"
import "CoreLibs/graphics"
import "libs/vector"

local gfx <const> = playdate.graphics

class("Player").extends()

function Player:init()
    -- Player specific components
    self.player = true
    -- Sprite component
    self.sprite = gfx.sprite.new(Player.getDummyImage())
    self.sprite:setCenter(0.5, 0.5)
    self.sprite:setZIndex(0)
    -- Physics and collision components
    self.mass = 80
    self.pos = vector(PPM/2, PPM/2)
    self.hitbox = {w = self.sprite.width, h = self.sprite.height}
end

function Player.getDummyImage()
    local img = gfx.image.new(16, 16)
    gfx.pushContext(img)
    gfx.setColor(gfx.kColorBlack)
    gfx.fillEllipseInRect(0, 0, img:getSize())
    gfx.setColor(gfx.kColorWhite)
    gfx.fillEllipseInRect(2, 2, img.width-4, img.height-4)
    gfx.popContext()
    return img
end