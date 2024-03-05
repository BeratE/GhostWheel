import "CoreLibs/object"
import "CoreLibs/graphics"
import "assets"

--[[ Supports JSON loading of TILED Maps v1.8]]

local gfx <const> = playdate.graphics
local Orientation <const> = {
    Orthogonal = "orthogonal",
    Isometric  = "isometric",
    Staggered  = "isometric",
    Hexagonal  = "isometric"
}
local RenderOrder <const> = {
    RightDown = "right-down"
}

--[[ Read and display TILED Level Editor maps ]]
class("TiledMap").extends()

function TiledMap:init(map)
    self:readMapJson(map)
    self.pos = {x = 200, y = 120}
end

function TiledMap:readMapJson(filename)
    local tiled = json.decodeFile("assets/map/"..filename)
    -- Sanity check
    assert(tiled, "Invalid tiled map file passed to level")
    assert(tiled.width == tiled.height, "Level only supports maps of equal width and height")
    assert(tiled.orientation == Orientation.Isometric, "Level can only load isometric tiled data")
    assert(tiled.renderorder == RenderOrder.RightDown, "Level can only use right-down render order")
    -- Read tile data
    self.width = tiled.width
    self.height = tiled.height
    self.tilewidth  = tiled.tilewidth
    self.tileheight = tiled.tileheight
    self.tiledepth  = self.tileheight/2
    -- Retrieve tileset info
    self.tiles = {}
    for _,t in ipairs(tiled.tilesets) do
        local filename =  t.image or t.source or t.name
        filename = filename:sub(string.find(filename, "/[^/]*$"), filename:find("-table-", 1, true) - 1)
        local imgtable = assets.getImageTable(filename)
        assert(imgtable, "Invalid image used in tilesets (" .. filename .. ")" )
        for i = 1, #imgtable do
            table.insert(self.tiles, imgtable:getImage(i))
        end
    end
    -- Retrieve layer information
    self.layers = tiled.layers
end


--[[ Order from top to right to bottom left ]]
function TiledMap:draw()
    local z = 0
    for _, layer in ipairs(self.layers) do
        if (layer.visible) then
            for y = 1, layer.height do
                for x = 1, layer.width  do
                    if (layer.type == "tilelayer") then
                        local tileidx = layer.data[((y-1)*layer.width) + x]
                        if (tileidx > 0 and tileidx <= #self.tiles) then
                            local px, py = self:getTilePositionAt(x, y, 0)
                            self.tiles[tileidx]:draw(px + layer.x, py + layer.y)
                        end
                    end
                end
            end
        end
    end
end


function TiledMap:getTilePositionAt(x, y, z)
    local px = self.pos.x + ((x-y) * (self.tilewidth / 2))  - self.tilewidth/2
    local py = self.pos.y + ((y+x) * (self.tileheight / 2)) - (self.tileheight * (self.height / 2)) - self.tileheight - (z * self.tiledepth)
    return px, py
end