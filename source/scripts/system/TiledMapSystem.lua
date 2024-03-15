---@diagnostic disable: undefined-field, inject-field, need-check-nil
import "CoreLibs/object"
import "libs/tinyecs"
import "pdlibs/util/debug"
import "scripts/system/TransformSystem"

local gfx <const> = playdate.graphics
local disp <const> = playdate.display
local geom <const> = playdate.geometry

-- [[ Process properties and events stored in the given tiled map ]]
class("TiledMapSystem").extends()
tinyecs.processingSystem(TiledMapSystem)
TiledMapSystem.filter = tinyecs.requireAll("tiledmap")

function TiledMapSystem:init()
    TiledMapSystem.super.init(self)
end

function TiledMapSystem:preProcess(dt)
    --gfx.clear()
end

function TiledMapSystem:process(e, dt)
    -- Transform for each sprite in the tiled map
    for _, sprite in ipairs(e.sprites) do
        --local x, y = TransformSystem.ScreenToTile():transformXY(sprite.pos.x, sprite.pos.y)
        --if (sprite[Tiled.Layer.Type.Tile]) then
            --gfx.fillCircleAtPoint(x, y, 5)
            --gfx.drawPolygon(sprite.tilePolyTD)
        --else
        --    gfx.fillCircleAtPoint(x, y, 5)
        --end
        
    end
    
end