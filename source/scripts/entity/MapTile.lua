import "CoreLibs/object"
import "scripts/entity/MapEntity"

--[[ Map Tile Entity ]]
class("MapTile").extends(MapEntity)

function MapTile:init(layer, lidx, tx, ty, ppm, img)
    MapTile.super.init(self, layer, lidx)
    self.name = ("%s[%i-%i]"):format(self.layername, tx or 0, ty or 0)
    self.pos.x += ((tx or 1)-1) * (ppm or 1)
    self.pos.y += ((ty or 1)-1) * (ppm or 1)
    self.width, self.height = ppm, ppm
    self:setSprite(img)
end