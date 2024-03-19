---@diagnostic disable: undefined-field
import "CoreLibs/object"
import "scripts/entity/MapEntity"

--[[ Map Tile Entity ]]
class("MapTile").extends(MapEntity)

function MapTile:init(layer, lidx, tx, ty)
    MapTile.super.init(self, layer, lidx)
    self.name = ("%s_%i_%i"):format(self.name, tx or 0, ty or 0)
    self.pos.x += ((tx or 1)-1)*PPM
    self.pos.y += ((ty or 1)-1)*PPM
    self.tileidx = layer.data[((ty-1)*layer.width) + tx]
end