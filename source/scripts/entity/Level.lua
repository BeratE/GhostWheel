---@diagnostic disable: undefined-field, need-check-nil, inject-field
import "CoreLibs/object"
import "CoreLibs/graphics"
import "scripts/entity/Tile"
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
    self.tileimages = {}
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
            table.insert(self.tileimages, imgtable:getImage(i))
        end
    end
    -- Initialize tilemap bumpword and add map borders
    self.bumpworld = bump.newWorld()
    self.bumpworld:add({name = "_borderTop"},   0, -16, self.nTilesX*PPM, 16)
    self.bumpworld:add({name = "_borderBot"},   0, self.nTilesY*PPM, self.nTilesX*PPM, 16)
    self.bumpworld:add({name = "_borderLeft"},  -16, 0, 16, self.nTilesY*PPM)
    self.bumpworld:add({name = "_borderRight"}, self.nTilesX*PPM, 0, 16, self.nTilesY*PPM)
    -- Retrieve layer information
    self.tiles = {}
    self.images = {}
    self.objects = {}
    self.spawns = {}
    -- Iterate layers
    for z, layer in ipairs(tiled.layers) do
        if (layer.type == Tiled.Layer.Type.Tile) then
            for y = 1, layer.height do
                for x = 1, layer.width  do
                    local tile = Tile(layer, z, x, y)
                    local tileimg = self.tileimages[tile.idx]
                    if (tileimg) then
                        tile:setImage(tileimg)
                    elseif(tile.idx == 0) then
                        if (layer.name == LayerName.Floor) then
                            self.bumpworld:add(tile, tile.pos.x, tile.pos.y, PPM, PPM)
                        end
                    else
                        local msg = ("Tile index %i not found in tilelayer %i at (%i, %i)"):format(tile.idx, z, x, y)
                        log.warn(msg)
                    end
                    table.insert(self.tiles, tile)
                end
            end
        elseif(layer.type == Tiled.Layer.Type.Object) then
            if (layer.name == LayerName.Spawn) then
                
                for i, obj in ipairs(layer.objects) do
                    if obj.name == "player" then
                        self.spawns.player = vector(obj.x, obj.y)
                    end
                end
            end
            
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
        else
            log.warn("Unrecognized layer type ".. layer.type)
        end
    end
    assert(#self.tiles > 0, "TiledMap was unable to retrieve any map data")
end

function Level:add(world)
    world:add(table.unpack(self.tiles))
end

function Level:remove(world)
    world:remove(table.unpack(self.tiles))
end