---@diagnostic disable: undefined-field, need-check-nil
import "CoreLibs/object"
import "CoreLibs/graphics"

local gfx <const> = playdate.graphics
local geom <const> = playdate.geometry

class("Player").extends(gfx.sprite)

function Player:init()
    Player.super.init(self)
    local img = gfx.image.new(48, 64)
    gfx.pushContext(img)
        gfx.fillEllipseInRect(0, 0, img:getSize())
    gfx.popContext()
    self:setImage(img)
    self:setCenter(0.5, 0.5)
    self:setZIndex(0)

    self.player = true
    self.mass = 80
    self.pos = geom.point.new(0, 0)
end