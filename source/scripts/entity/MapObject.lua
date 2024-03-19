---@diagnostic disable: undefined-field
import "CoreLibs/object"
import "scripts/entity/MapEntity"

local geom <const> = playdate.geometry

--[[ Map Object Entity ]]
class("MapObject").extends(MapEntity)

function MapObject:init(layer, lidx, object, oidx)
    MapTile.super.init(self, layer, lidx)
    self:setProperties(object.properties)
    self.name = ("%s_%s_%i"):format(self.name, object.name, oidx)
    self.width = object.width
    self.height = object.height
    self.pos.x += object.x
    self.pos.y += object.y
    self.rotation = object.rotation
    self.type = object.type
    self.text = object.text
    if object.point then
        self.point = geom.point.new(self.pos.x, self.pos.y)
    elseif object.polygon or object.polyline then
        local polygon = object.polygon or object.polyline
        self.polygon = geom.polygon.new(#polygon)
        for n, p in ipairs(polygon) do
            self.polygon:setPointAt(n, p.x, p.y)
        end
    else
        if (object.ellipse) then
            self.ellipse = true
        end
        self.rectangle = geom.rect.new(self.pos.x, self.pos.y, self.width, self.height)
    end
end