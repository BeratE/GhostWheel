import "CoreLibs/object"
import "CoreLibs/graphics"
import "libs/vector"
import "scripts/entity/Entity"

local gfx <const> = playdate.graphics

--[[ Generic Map Entity Tile or Object ]]
class("MapEntity").extends(Entity)

function MapEntity:init(layer, lidx)
    MapEntity.super.init(self)
    self.mapentity = true            -- Generic Map Entity
    self[layer.type] = true          -- Object/Tile Entity
    self.lidx = lidx or layer.id     -- Layer index
    self.pos = vector((layer.offsetx or 0), (layer.offsety or 0))
    self.name = layer.name
    self:setProperties(layer.properties)
end

function MapEntity:setSprite(img)
    if (img) then
        self.sprite = gfx.sprite.new(img)
        self.sprite:setZIndex(SPRITE_Z_MIN + self.lidx)
        self.sprite:setCenter(0.5, 0.0)
    end
end

function MapEntity:setProperties(properties)
    if (properties) then
        for _, property in ipairs(properties) do
            local value = property.value
            -- Translate string dot notation
            local p, names = self, {}
            for n in string.gmatch(property.name, '([^.]*)') do
                table.insert(names, n)
            end
            for i = 1, #names-1 do
                p[names[i]] = p[names[i]] or {}
                p = p[names[i]]
            end
            p[names[#names]] = value
        end
    end
end