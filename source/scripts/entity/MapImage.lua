---@diagnostic disable: undefined-field
import "CoreLibs/object"
import "scripts/entity/MapEntity"

--[[ Map Image Entity ]]
class("MapImage").extends(Entity)

function MapImage:init(layer, lidx, img)
    MapImage.super.init(self, layer, lidx)
    self:setSprite(img)
end