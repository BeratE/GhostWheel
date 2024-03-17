---@diagnostic disable: undefined-field, inject-field, need-check-nil
import "CoreLibs/object"
import "libs/tinyecs"
import "pdlibs/util/debug"

local gfx <const> = playdate.graphics
local disp <const> = playdate.display
local geom <const> = playdate.geometry
-- Top-Down to Screen Coordinate projection
local trIsometric = geom.affineTransform.new((TILE_WIDTH/2)/PPM, -(TILE_WIDTH/2)/PPM, (TILE_HEIGHT/2)/PPM, (TILE_HEIGHT/2)/PPM)
local trIsometricInv = trIsometric:copy()
trIsometricInv:invert()

-- [[ Derives screen coordinates by applying linear transform to position coordinates ]]
class("TransformSystem").extends()
tinyecs.processingSystem(TransformSystem)
TransformSystem.filter = tinyecs.requireAll("pos")

function TransformSystem:init()
    TransformSystem.super.init(self)
end

function TransformSystem:preProcess(dt)
    local d = disp.getRect()
    local ox, oy = gfx.getDrawOffset()
    self.topDownViewPort = {
        trIsometricInv:transformedPoint(geom.point.new(d.x     - ox, d.y      - oy)),
        trIsometricInv:transformedPoint(geom.point.new(d.x     - ox, d.height - oy)),
        trIsometricInv:transformedPoint(geom.point.new(d.width - ox, d.height - oy)),
        trIsometricInv:transformedPoint(geom.point.new(d.width - ox, d.y      - oy))
    }
    --print("Top-Down Viewport: " .. pdlibs.dump(self.topDownViewPort))
end

function TransformSystem:process(e, dt)
    local x, y = TransformSystem.TileToScreen():transformXY(e.pos.x, e.pos.y)
    e:moveTo(x, y)
    --print("Entity Pos: " .. e.pos.x .. " " .. e.pos.y .. ", Sprite: " .. x .. " " .. y)
end

function TransformSystem.TileToScreen()
    return trIsometric
end

function TransformSystem.ScreenToTile()
    return trIsometricInv
end