---@diagnostic disable: undefined-field
import "CoreLibs/object"
import "CoreLibs/graphics"
import "libs/vector"
import "scripts/entity/Entity"

local gfx <const> = playdate.graphics

--[[ Generic Map Entity Tile or Object ]]
class("MapEntity").extends(Entity)

function MapEntity:init(layer, lidx)
    MapEntity.super.init(self)
    self.lidx = lidx or layer.id     -- Layer index
    self[layer.type] = true          -- Object/Tile
    self:setProperties(layer.properties)
    self.pos = vector((layer.offsetx or 0), (layer.offsety or 0))
    self.name = ("%s_%i"):format(layer.name, self.lidx)
end

function MapEntity:setSprite(img)
    self.sprite = gfx.sprite.new(img)
    self.sprite:setZIndex(SPRITE_Z_MIN + self.lidx)
    self.sprite:setCenter(0.5, 0.0)
    self.sprite:moveTo(TransformSystem.TileToScreen():transformXY(self.pos.x, self.pos.y))
end

function MapEntity:setProperties(properties)
    if (properties) then
        for _, property in ipairs(properties) do
            -- Translate string dot notation
            local pointer, prev, lname = self, self, property.name
            for name in string.gmatch(property.name, '([^.]*)') do
                prev = pointer
                pointer[name] = {}
                pointer = pointer[name]
            end
            prev[lname] = property.value
        end
    end
end