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
class("Level").extends()

function Level:init(filepathname)
    self:readTiledJson(filepathname)
end

function Level:readTiledJson(filepathname)
    self.leveldata = true
    -- Reset sprite properties
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
    self.width = self.nTilesX*self.tileWidth
    self.height = self.nTilesY*self.tileHeight
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
    -- Initialize tilemap bumpword
    self.bumpworld = bump.newWorld()
    -- Iterate layers
    for z, layer in ipairs(tiled.layers) do
        if (layer.type == Tiled.Layer.Type.Tile) then
            for y = 1, layer.height do
                for x = 1, layer.width  do
                    -- Create Tile Entity
                    local tile = {
                        tile = true,
                        tilelayer = z,
                        tilename = ("%s_%i_%i"):format(layer.name, x, y),
                        tileidx = layer.data[((y-1)*layer.width) + x],
                        pos = vector((x-1)*PPM, (y-1)*PPM),
                    }
                    tile[layer.type] = true
                    -- Set custom properties
                    if (layer.property) then
                        for _, property in ipairs(layer.property) do
                            tile[property.name] = property.value
                        end
                    end
                    -- Tile with sprite
                    local tileimg = self.images[tile.tileidx]
                    if (tileimg) then
                        tile.sprite = gfx.sprite.new(tileimg)
                        tile.sprite:setZIndex(SPRITE_Z_MIN + z)
                        tile.sprite:setCenter(0.5, 0.0)
                        tile.sprite:moveTo(TransformSystem.TileToScreen():transformXY(tile.pos.x, tile.pos.y))
                    -- Empty collision tile
                    elseif(tile.tileidx == 0) then
                        if (layer.name == LayerName.Floor) then
                            self.bumpworld:add(tile, tile.pos.x, tile.pos.y, PPM, PPM)
                        end
                    else
                        local msg = ("Tile index %i not found in tilelayer %i at (%i, %i)"):format(tile.tileidx, z, x, y)
                        log.warn(msg)
                    end
                    table.insert(self.tiles, tile)
                end
            end
        elseif(layer.type == Tiled.Layer.Type.Object) then
            for i, obj in ipairs(layer.objects) do
                if obj.name == "spawn_player" then
                    self.spawn_player = {x = obj.x, y = obj.y}
                end
            end
        --[[
        elseif(layer.type == Tiled.Layer.Type.Image) then
            local img_name = pdlibs.string.cutPathToFilename(layer.image)
            local img = gfx.sprite.new(assets.getImage(img_name))
            if (img) then
                local px, py = self.x - self.width/2, self.y + self.height/2
                addTileSprite(img, layer, z, px, py)
            else
                local msg = ("Image %s not found in tilelayer %i"):format(img_name, z)
                log.warn(msg)
            end
            --]]
        else
            log.warn("Unrecognized layer type ".. layer.type)
        end
    end
    assert(#self.tiles > 0, "TiledMap was unable to retrieve any map data")
end