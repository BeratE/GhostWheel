import "CoreLibs/object"
import "libs/tinyecs"
import "pdlibs/util/debug"
import "scripts/system/AbstractSystem"

local geom <const> = playdate.geometry

-- [[ Derives screen coordinates by applying linear transform to position coordinates ]]
class("TransformSystem").extends(AbstractSystem)
tinyecs.processingSystem(TransformSystem)
TransformSystem.filter = tinyecs.requireAll("pos", "sprite")

function TransformSystem:init(mapdata)
    TransformSystem.super.init(self, mapdata)
end

function TransformSystem:onAdd(e)
    e.sprite:moveTo(self.toScreen:transformXY(e.pos.x, e.pos.y))
end

function TransformSystem:process(e, dt)
    local x, y = e.pos.x, e.pos.y
    e.sprite:moveTo(self.toScreen:transformXY(x, y))
end

function TransformSystem:setMapData(mapdata)
    self.tilewidth = mapdata.tileWidth
    self.tileheight = mapdata.tileHeight
    self.ppm = mapdata.tileHeight
    if (mapdata.orientation == "isometric") then
        self.toScreen = geom.affineTransform.new(
            (self.tilewidth/2)/self.ppm, -(self.tilewidth/2)/self.ppm,
            (self.tileheight/2)/self.ppm, (self.tileheight/2)/self.ppm)
    else
        self.toScreen = geom.affineTransform.new(
            1/self.ppm, 1/self.ppm,
            1/self.ppm, 1/self.ppm)
    end
    self.toTile = self.toScreen:copy()
    self.toTile:invert()
end