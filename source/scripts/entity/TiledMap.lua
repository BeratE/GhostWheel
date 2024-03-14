---@diagnostic disable: undefined-field, need-check-nil
import "CoreLibs/object"
import "CoreLibs/graphics"
import "pdlibs/util/string"
import "libs/pdlog"

--[[ Supports JSON loading of TILED Tiled.Maps v1.8]]

local gfx <const> = playdate.graphics

--[[ Load, manage and render TILED Level Editor maps.
Implemented as a sprite that manages a group of tile sprites. ]]
class("TiledMap").extends(gfx.sprite)

function TiledMap:init(map)
    self:readMapJson(map)
    TiledMap.super.init(self)
end

function TiledMap:readMapJson(tiled_filename)
    -- Reset sprite properties
    TiledMap.super.moveTo(self, 200, 120)
    TiledMap.super.setCenter(self, 0.5, 0.5)
    TiledMap.super.setZIndex(self, SPRITE_Z_MIN)
    -- Read json map
    tiled_filename = "assets/map/"..tiled_filename
    log.info("Loading Tiled file " .. tiled_filename)
    local tiled = json.decodeFile(tiled_filename)
    -- Sanity check
    assert(tiled, "Unable to decode Tiled map file " .. tiled_filename)
    assert(tiled.compressionlevel == Tiled.Map.Compression.Default, "TiledMap only supports default compression")
    assert(tiled.infinite == false, "TileTiled.Map does not support infinite maps")
    assert(tiled.width == tiled.height, "TiledMap only supports maps of equal width and height")
    assert(tiled.orientation == Tiled.Map.Orientation.Isometric, "TiledMap can only load isometric tiled data")
    assert(tiled.renderorder == Tiled.Map.RenderOrder.RightDown, "TiledMap can only use right-down render order")
    -- Read tile data
    self.nTilesX = tiled.width
    self.nTilesY = tiled.height
    self.tileWidth  = tiled.tilewidth
    self.tileHeight = tiled.tileheight
    self.tileDepth  = self.tileHeight/2
    TiledMap.super.setSize(self, self.nTilesX*self.tileWidth, self.nTilesY*self.tileHeight)
    self.corners = {
        top    = {x = self.width/2, y = 0},
        bottom = {x = self.width/2, y = self.height},
        left   = {x = 0,            y = self.height/2},
        right  = {x = self.width,   y = self.height/2},
    }
    -- Collect tilesets into one big image table
    self.tiles = {}
    for _,t in ipairs(tiled.tilesets) do
        local source_filename =  t.image or t.source or t.name
        -- Cut until filename if a path is given
        source_filename = pdlibs.string.cutPathToFilename(source_filename)
        -- Find image name without suffix
        local tableIdx = string.find(source_filename, "-table-", 1, true)
        if (tableIdx and tableIdx > 2) then
            source_filename = string.sub(source_filename, 1, tableIdx-1)
        else
            error("Invalid image name used in tilesets (" .. source_filename .. ")", 2)
        end
        local imgtable = assets.getImageTable(source_filename)
        assert(imgtable, "Unable to retrieve tileset image (" .. source_filename .. ")" )
        for i = 1, #imgtable do
            table.insert(self.tiles, imgtable:getImage(i))
        end
    end
    -- Retrieve layer information
    self.sprites = {}
    local addLayerSprite = function (img, layer, z, px, py)
        local sprite = gfx.sprite.new(img)
        sprite:setZIndex(SPRITE_Z_MIN + z)
        sprite:setCenter(0.5, 0.5)
        local offsetX = (layer.x or 0)*self.tileWidth + (layer.offsetx or 0)
        local offsetY = (layer.y or 0)*self.tileWidth + (layer.offsety or 0)
        sprite:moveTo((px or 0) + offsetX, (py or 0) + offsetY)
        if (layer.property) then
            for _, property in ipairs(layer.property) do
                sprite[property.name] = property.value
            end
        end
        sprite[layer.type] = true
        table.insert(self.sprites, sprite)
    end
    for z, layer in ipairs(tiled.layers) do
        if (layer.type == Tiled.Layer.Type.Tile) then
            for y = 1, layer.height do
                for x = 1, layer.width  do
                    local tileidx = layer.data[((y-1)*layer.width) + x]
                    local tileimg = self.tiles[tileidx]
                    if (tileimg) then
                        local px = self.x + ((x-y) * (self.tileWidth / 2))  - self.tileWidth/2
                        local py = self.y + ((y+x) * (self.tileHeight / 2)) - (self.tileHeight * (self.nTilesY / 2)) - self.tileHeight
                        addLayerSprite(tileimg, layer, z, px, py)
                    elseif (tileidx > 0) then
                        local msg = ("Tile index %i not found in tilelayer %i at (%i, %i)"):format(tileidx, z, x, y)
                        log.warn(msg)
                    end
                end
            end
        elseif(layer.type == Tiled.Layer.Type.Object) then
            --
        elseif(layer.type == Tiled.Layer.Type.Image) then
            print("hello")
            local img_name = pdlibs.string.cutPathToFilename(layer.image)
            local img = gfx.sprite.new(assets.getImage(img_name))
            if (img) then
                local px, py = self.x - self.width/2, self.y + self.height/2
                addLayerSprite(img, layer, z, px, py)
            else
                local msg = ("Image %s not found in tilelayer %i"):format(img_name, z)
                log.warn(msg)
            end
        else
            log.warn("Unrecognized layer type ".. layer.type)
        end
    end
    assert(#self.sprites > 0, "TiledMap was unable to retrieve any map data")
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

-- All other sprite functions are modified to iterate over sprite table
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
            -- Skip if function is a getter
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