---@diagnostic disable: undefined-field
import "CoreLibs/object"
import "CoreLibs/graphics"
import "libs/vector"
import "scripts/entity/Entity"

local gfx <const> = playdate.graphics

--[[ Generic Map Entity Tile or Object ]]
class("MapEntity").extends(Entity)

function MapEntity:init(layer, z, x, y)
    MapEntity.super.init(self)
    self.name = ("%s_%i_%i"):format(layer.name, x, y)
    self.idx = layer.data[((y-1)*layer.width) + x]
    self.pos = vector((x-1)*PPM, (y-1)*PPM)
    self.layeridx = z
    self[layer.type] = true
    if (layer.property) then
        for _, property in ipairs(layer.property) do
            self[property.name] = property.value
        end
    end
end

function MapEntity:setSprite(img)
    self.sprite = gfx.sprite.new(img)
    self.sprite:setZIndex(SPRITE_Z_MIN + self.layeridx)
    self.sprite:setCenter(0.5, 0.0)
    self.sprite:moveTo(TransformSystem.TileToScreen():transformXY(self.pos.x, self.pos.y))
end