import "CoreLibs/object"
import "libs/tinyecs"
import "pdlibs/util/debug"

local geom <const> = playdate.geometry

-- [[ Derives screen coordinates by applying linear transform to position coordinates ]]
class("TransformSystem").extends()
tinyecs.processingSystem(TransformSystem)
TransformSystem.filter = tinyecs.requireAll("pos", "sprite")

function TransformSystem:init(tilewidth, tileheight)
    TransformSystem.super.init(self)
    self:setTileSize(tilewidth, tileheight)
end

function TransformSystem:onAdd(e)
    e.sprite:moveTo(self.toScreen:transformXY(e.pos.x, e.pos.y))
end

function TransformSystem:preProcess(dt)
end

function TransformSystem:process(e, dt)
    if not e.moved then
        return
    end
    e.sprite:moveTo(self.toScreen:transformXY(e.pos.x, e.pos.y))
end

function TransformSystem:setTileSize(tilewidth, tileheight)
    local ppm = tileheight
    -- Top-Down to Screen Coordinate projection
    self.toScreen = geom.affineTransform.new(
        (tilewidth/2)/ppm, -(tilewidth/2)/ppm,
        (tileheight/2)/ppm, (tileheight/2)/ppm)
    self.toTile = self.toScreen:copy()
    self.toTile:invert()
end