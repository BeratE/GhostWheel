---@diagnostic disable: undefined-field
import "CoreLibs/object"
import "CoreLibs/graphics"
import "libs/vector"

local gfx <const> = playdate.graphics

class("Tile").extends()

function Tile:init(layer, z, x, y)
    -- Tile specific components
    self.tile = true
    self.name = ("%s_%i_%i"):format(layer.name, x, y)
    self.idx = layer.data[((y-1)*layer.width) + x]
    self.pos = vector((x-1)*PPM, (y-1)*PPM)
    self.layeridx = z

    self[layer.type] = true
    -- Set custom properties
    if (layer.property) then
        for _, property in ipairs(layer.property) do
            self[property.name] = property.value
        end
    end
end

function Tile:setImage(img)
    self.sprite = gfx.sprite.new(img)
    self.sprite:setZIndex(SPRITE_Z_MIN + self.layeridx)
    self.sprite:setCenter(0.5, 0.0)
    self.sprite:moveTo(TransformSystem.TileToScreen():transformXY(self.pos.x, self.pos.y))
end