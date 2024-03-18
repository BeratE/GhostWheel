---@diagnostic disable: undefined-field, need-check-nil
import "CoreLibs/object"
import "CoreLibs/graphics"
import "scripts/entity/Entity"
import "libs/vector"

local gfx <const> = playdate.graphics

class("Player").extends(Entity)

function Player:init(pos)
    Player.super.init(self)
    self.player = true
    self.cameraTrack = {offsetx = 0, offsety = 0}
    self:setSprite()
    self.mass = 80
    self.pos = pos or vector(PPM/2, PPM/2)
    self.hitbox = {w = self.sprite.width, h = self.sprite.height}
end

function Player:setSprite()
    local img = gfx.image.new(16, 16)
    gfx.pushContext(img)
    gfx.setColor(gfx.kColorBlack)
    gfx.fillEllipseInRect(0, 0, img:getSize())
    gfx.setColor(gfx.kColorWhite)
    gfx.fillEllipseInRect(2, 2, img.width-4, img.height-4)
    gfx.popContext()
    self.sprite = gfx.sprite.new(img)
    self.sprite:setCenter(0.5, 0.5)
    self.sprite:setZIndex(0)
end