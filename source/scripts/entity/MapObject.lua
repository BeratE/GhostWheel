import "CoreLibs/object"
import "scripts/entity/MapEntity"

local geom <const> = playdate.geometry

--[[ Map Object Entity ]]
class("MapObject").extends(MapEntity)

function MapObject:init(layer, lidx, object)
    MapTile.super.init(self, layer, lidx)
    self:setProperties(object.properties)
    if (object.name == "") then object.name = layer.name end
    self.name = ("[%i]%s"):format(object.id, object.name)
    self.oid = object.id
    self.width = object.width
    self.height = object.height
    self.pos.x += object.x
    self.pos.y += object.y
    self.rotation = object.rotation
    self.type = object.type
    self.text = object.text
    -- Set geometrical properties
    if object.point then
        self.point = geom.point.new(self.pos.x, self.pos.y)
    elseif object.polygon or object.polyline then
        local poly = (object.polygon or object.polyline)
        local size = #poly
        if (object.polygon) then size += 1 end
        self.polygon = geom.polygon.new(size)
        for n, p in ipairs(poly) do
            self.polygon:setPointAt(n, self.pos.x + p.x, self.pos.y+p.y)
        end
        if (object.polygon) then -- Close polygon
            self.polygon:setPointAt(size, self.pos.x +  poly[1].x, self.pos.y+ poly[1].y)
        end
    else
        if (object.ellipse) then
            self.ellipse = true
        end
        self.rectangle = geom.rect.new(self.pos.x, self.pos.y, self.width, self.height)
    end
end