---@diagnostic disable: undefined-field, need-check-nil, inject-field
import "CoreLibs/object"
import "CoreLibs/graphics"
import "pdlibs/util/string"
import "libs/bump"
import "libs/pdlog"

--[[ Supports JSON loading of TILED Tiled.Maps v1.8]]

local gfx <const> = playdate.graphics

--[[ Load, manage and render TILED Level Editor maps.
Implemented as a sprite that manages a group of tile sprites. ]]
class("Level").extends(gfx.sprite)

function Level:init(filepathname)
    self:readTiledJson(filepathname)
    Level.super.init(self)
end

function Level:readTiledJson(filepathname)
    -- Reset sprite properties
    Level.super.setCenter(self, 0.5, 0.5)
    Level.super.setZIndex(self, SPRITE_Z_MIN)
    -- Read json map
    filepathname = "assets/map/"..filepathname
    log.info("Loading Tiled file " .. filepathname)
    local tiled = json.decodeFile(filepathname)
    -- Sanity check
    assert(tiled, "Unable to decode Tiled map file " .. filepathname)
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
    Level.super.setSize(self, self.nTilesX*self.tileWidth, self.nTilesY*self.tileHeight)
    -- Collect tilesets into one big image table
    self.images = {}
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
            table.insert(self.images, imgtable:getImage(i))
        end
    end
    -- Retrieve layer information
    self.tiles = {}
    self.objects = {}
    local addLayerSprite = function (img, layer, z, sx, sy)
        local sprite = gfx.sprite.new(img)
        sprite:setZIndex(SPRITE_Z_MIN + z)
        sprite:setCenter(0.5, 0.0)
        sprite:moveTo(sx, sy)
        if (layer.property) then
            for _, property in ipairs(layer.property) do
                sprite[property.name] = property.value
            end
        end
        sprite[layer.type] = true
        table.insert(self.tiles, sprite)
    end
    -- Initialize tilemap bumpword
    self.bumpworld = bump.newWorld(self.tileHeight*BUMP_CELL_MULTIPLIER)
    -- Iterate layers
    for z, layer in ipairs(tiled.layers) do
        if (layer.type == Tiled.Layer.Type.Tile) then
            for y = 1, layer.height do
                for x = 1, layer.width  do
                    local tileidx = layer.data[((y-1)*layer.width) + x]
                    local tileimg = self.images[tileidx]
                    local tx, ty = (x-1)*PPM, (y-1)*PPM
                    if (tileimg) then
                        local sx, sy = TransformSystem.TileToScreen():transformXY(tx, ty)
                        addLayerSprite(tileimg, layer, z, sx, sy)
                    elseif (tileidx == 0) then -- Empty tile registered as collision
                        local tile = {name = ("Tile_%i_%i"):format(x, y)}
                        --self.bumpworld:add(tile, tx, ty, PPM, PPM)
                    else
                        local msg = ("Tile index %i not found in tilelayer %i at (%i, %i)"):format(tileidx, z, x, y)
                        log.warn(msg)
                    end
                end
            end
        elseif(layer.type == Tiled.Layer.Type.Object) then
            for i, obj in ipairs(layer.objects) do
                if obj.name == "spawn_player" then
                    self.spawn_player = {x = obj.x, y = obj.y}
                end
            end
        elseif(layer.type == Tiled.Layer.Type.Image) then
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
    assert(#self.tiles > 0, "TiledMap was unable to retrieve any map data")
end



--[[ Sprite Management ]]

function Level:moveTo(x, y)
    local dx, dy = x - self.x, y - self.y
    Level.super.moveTo(self, x, y)
    for _, sprite in ipairs(self.tiles) do
        sprite:moveBy(dx, dy)
    end
end

function Level:setZIndex(z)
    local pz = Level:getZIndex()
    Level.super.setZIndex(self, z)
    for _, sprite in ipairs(self.tiles) do
        sprite:setZIndex(z + sprite:getZIndex() - pz)
    end
end

function Level:setSize(width, height)
    Level.super.setSize(self, width, height)
end

-- All other sprite functions are modified to iterate over sprite table
Level.__index = function(tiledmap, key)
    -- Check if requested function is part of TiledMap
    local proxy_value = rawget(Level, key)
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
            local retVal = Level.super[key](tm, ...)
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