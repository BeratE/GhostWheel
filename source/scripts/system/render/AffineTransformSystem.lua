---@diagnostic disable: undefined-field
import "CoreLibs/object"
import "libs/ecs/tiny"

local geometry <const> = playdate.geometry

-- [[ Derives screen coordinates by applying linear transform to position coordinates ]]
class("AffineTransformSystem").extends()
tinyecs.processingSystem(AffineTransformSystem)
AffineTransformSystem.filter = tinyecs.requireAll("pos")


function AffineTransformSystem:init()
    AffineTransformSystem.super.init(self)
    local rangle = -math.pi/4 -- 45 degrees 
    local c4 = math.cos(rangle)/PPM
    local s4 = math.sin(rangle)/PPM
    --self.isometric = geometry.affineTransform.new()
    --self.isometric = self.isometric:scaledBy(1/PPM, 1/PPM)
    --self.isometric = self.isometric:rotatedBy(-45)
    --self.isometric = self.isometric:scaledBy(0, 1/2)
    self.isometric = geometry.affineTransform.new(c4, s4, s4/2, -c4/2)
end

function AffineTransformSystem:process(e, dt)
    local x, y = self.isometric:transformXY(e.pos.x, e.pos.y)
    
    e:moveTo(x, y)
    --print("1 Sprite Pos " .. e.pos.x .. " " .. e.pos.y .. " -- " .. x .. " " .. y)
end

