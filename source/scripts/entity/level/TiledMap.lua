---@diagnostic disable: undefined-field, need-check-nil
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

--[[ Load, manage and render TILED Level Editor maps.
Implemented as a sprite that manages a group of tile sprites. ]]
class("TiledMap").extends(gfx.sprite)

function TiledMap:init(map)
    TiledMap.super.moveTo(self, 200, 120)
    TiledMap.super.setCenter(self, 0.5, 0.5)
    TiledMap.super.setZIndex(self, SPRITE_Z_MIN)
    self:readMapJson(map)
    TiledMap.super.init(self)
end

function TiledMap:readMapJson(filename)
    local tiled = json.decodeFile("assets/map/"..filename)
    -- Sanity check
    assert(tiled, "Invalid TILED map file passed to level")
    assert(tiled.width == tiled.height, "TiledMap only supports maps of equal width and height")
    assert(tiled.orientation == Orientation.Isometric, "TiledMap can only load isometric tiled data")
    assert(tiled.renderorder == RenderOrder.RightDown, "TiledMap can only use right-down render order")
    -- Read tile data
    self.width = tiled.width
    self.height = tiled.height
    self.tilewidth  = tiled.tilewidth
    self.tileheight = tiled.tileheight
    self.tiledepth  = self.tileheight/2
    --TiledMap.super.setSize(self, self.width*self.tilewidth, self.height*self.tiledepth)
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
    -- Construct sprites
    self.sprites = {}
    for z, layer in ipairs(self.layers) do
        if (layer.visible) then
            for y = 1, layer.height do
                for x = 1, layer.width  do
                    if (layer.type == "tilelayer") then
                        local tileidx = layer.data[((y-1)*layer.width) + x]
                        local tilesprite = gfx.sprite.new(self.tiles[tileidx])
                        if (tilesprite) then
                            local px, py = self:getScreenCoordinatesAt(x, y, 0)
                            tilesprite:setZIndex(SPRITE_Z_MIN + z)
                            tilesprite:setCenter(0.5, 0.5)
                            tilesprite:moveTo(px + layer.x, py + layer.y)
                            --print(tilesprite.x, tilesprite.y)
                            table.insert(self.sprites, tilesprite)
                        end
                    end
                end
            end
        end
    end
    assert(#self.sprites > 0, "TiledMap was unable to retrieve any map data")
end

function TiledMap:getScreenCoordinatesAt(x, y, z)
    local px = self.x + ((x-y) * (self.tilewidth / 2))  - self.tilewidth/2
    local py = self.y + ((y+x) * (self.tileheight / 2)) - (self.tileheight * (self.height / 2)) - self.tileheight - (z * self.tiledepth)
    print(px, py)
    return px, py
end

--[[ Sprite Management ]]

function TiledMap:moveTo(x, y)
    local dx, dy = x - self.x, y - self.y
    TiledMap.super.moveTo(self, x, y)
    for _, sprite in ipairs(self.sprites) do
        sprite:moveBy(dx, dy)
    end
end

function TiledMap:setZIndex(z)
    local pz = TiledMap:getZIndex()
    TiledMap.super.setZIndex(self, z)
    for _, sprite in ipairs(self.sprites) do
        sprite:setZIndex(z + sprite:getZIndex() - pz)
    end
end

function TiledMap:setSize(width, height)
    TiledMap.super.setSize(self, width, height)
    for _, sprite in ipairs(self.sprites) do
        sprite:setSize(width, height)
    end
end

TiledMap.__index = function(tiledmap, key)
    -- Check if requested function is part of TiledMap
    local proxy_value = rawget(TiledMap, key)
	if proxy_value then
        --print(("TiledMap __index: rawget(TiledMap, %s)"):format(key))
		return proxy_value
	end
    -- Check if requested function is part of gfx.sprite
	proxy_value = rawget(gfx.sprite, key)
    if type(proxy_value) == "function" then
        --print(("TiledMap __index: rawget(gfx.sprite, %s)"):format(key))
        -- Set to function on the TiledMap
		rawset(tiledmap, key, function(tm, ...)
            local retVal = TiledMap.super[key](tm, ...)
            if (not retVal) then
                for _, sprite in ipairs(tm.sprites) do
                    sprite[key](sprite, ...)
                end
            end
			return retVal
		end)
		return tiledmap[key]
	end
	return proxy_value -- Otherwise return usual
end