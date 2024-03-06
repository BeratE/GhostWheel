---@diagnostic disable: undefined-field, inject-field, need-check-nil
import "CoreLibs/object"
import "libs/tinyecs"
import "pdlibs/util/debug"

local gfx <const> = playdate.graphics
local disp <const> = playdate.display
local geom <const> = playdate.geometry

-- [[ Derives screen coordinates by applying linear transform to position coordinates ]]
class("AffineTransformSystem").extends()
tinyecs.processingSystem(AffineTransformSystem)
AffineTransformSystem.filter = tinyecs.requireAll("pos")


function AffineTransformSystem:init()
    AffineTransformSystem.super.init(self)
    local a = math.pi/4 -- 45 degrees 
    local c1 = math.cos(-a)
    local s1 = math.sin(-a)
    -- Top-Down to Screen Coordinate projection
    self.isometric    = geom.affineTransform.new(c1/PPM, s1/PPM, s1/(2*PPM), -c1/(2*PPM))
    self.isometricInv = self.isometric:copy()
    self.isometricInv:invert()
end

function AffineTransformSystem:preProcess(dt)
    local d = disp.getRect()
    local ox, oy = gfx.getDrawOffset()
    self.topDownViewPort = {
        self.isometricInv:transformedPoint(geom.point.new(d.x     - ox, d.y      - oy)),
        self.isometricInv:transformedPoint(geom.point.new(d.x     - ox, d.height - oy)),
        self.isometricInv:transformedPoint(geom.point.new(d.width - ox, d.height - oy)),
        self.isometricInv:transformedPoint(geom.point.new(d.width - ox, d.y      - oy))
    }
    --print("Top-Down Viewport: " .. pdlibs.dump(self.topDownViewPort))
end

function AffineTransformSystem:process(e, dt)
    local x, y = self.isometric:transformXY(e.pos.x, e.pos.y)
    
    e:moveTo(x, y)
    --print("Entity Sprite Pos: " .. e.pos.x .. " " .. e.pos.y .. ", " .. x .. " " .. y)
end

