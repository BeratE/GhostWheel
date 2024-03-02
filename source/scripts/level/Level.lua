import "CoreLibs/object"
import "CoreLibs/graphics"

local gfx <const> = playdate.graphics

class("Level").extends(gfx.sprite)

function Level:init(gridSize, tileWidth, tileHeight)
    Level.super.init(self)
    -- Grid meta
    self.gridSize = gridSize
    self.blockWidth  = tileWidth
    self.blockHeight = tileHeight
    self.blockDepth  = tileHeight / 2
    self:resetGrid()
end

function Level:resetGrid()
    self.grid = {}
    for x = 1, self.gridSize do
        self.grid[x] = {}
        for y = 1, self.gridSize do
           self.grid[x][y] = TILE.UNDEFINED
        end
    end
end

--[[ Order from top to right to bottom left ]]
function Level:update()
    Level.super.update(self)
    --[[
    for x = 1, self.gridSize do
        for y = 1, self.gridSize do
            self:drawTileAt(tile, x, y)
        end
    end
    ]]
end

function Level:drawTileAt(tile, x, y, z)
    
end

function Level:getTileCoordsAt(x, y, z)
    z = z or 0
    local px = self.x + ((y-x) * (self.blockWidth / 2))
    local py = self.y + ((x+y) * (self.blockDepth / 2)) - (self.blockDepth * (self.gridSize / 2)) - (z * self.blockDepth)
    return px, py
end