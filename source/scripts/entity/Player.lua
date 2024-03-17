---@diagnostic disable: undefined-field, need-check-nil
import "CoreLibs/object"
import "CoreLibs/graphics"

local gfx <const> = playdate.graphics
local geom <const> = playdate.geometry

class("Player").extends(gfx.sprite)

function Player:init()
    Player.super.init(self)
    local img = gfx.image.new(16, 16)
    gfx.pushContext(img)
    gfx.setColor(gfx.kColorBlack)
    gfx.fillEllipseInRect(0, 0, img:getSize())
    gfx.setColor(gfx.kColorWhite)
    gfx.fillEllipseInRect(2, 2, img.width-4, img.height-4)
    gfx.popContext()
    self:setImage(img)
    self:setCenter(0.5, 0.5)
    self:setZIndex(0)
    self.hitbox = {w = img.width, h = img.height}
    self.player = true
    self.mass = 80
    self.pos = geom.point.new(PPM/2, PPM/2)
end