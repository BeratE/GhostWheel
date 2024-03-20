---@diagnostic disable: undefined-field, need-check-nil, inject-field
import "CoreLibs/object"
import "CoreLibs/graphics"
import "scripts/entity/MapTile"
import "scripts/entity/MapObject"
import "pdlibs/util/string"
import "libs/bump"
import "libs/pdlog"

local gfx <const> = playdate.graphics

--[[ Container for map info, bumpworld and 
collection of tile, object and image entities. 
Loads TILED map data from JSON files]]
class("MapData").extends()

function MapData:init(filepathname)
    self:_readTiledJson(filepathname)
end

function MapData:add(world)
    world:add(table.unpack(self.entitis))
end

function MapData:remove(world)
    world:remove(table.unpack(self.entitis))
end

function MapData:_readTiledJson(filepathname)
    self.mapdata = true

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
    local ppm = self.tileHeight
    -- Set map properties
    if (tiled.properties) then
        for _, property in ipairs(tiled.properties) do
            self[property.name] = property.value
        end
    end
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
    self.bumpworld:add({name = "_borderTop"},   0, -ppm, self.nTilesX*ppm, ppm)
    self.bumpworld:add({name = "_borderBot"},   0, self.nTilesY*ppm, self.nTilesX*ppm, 16)
    self.bumpworld:add({name = "_borderLeft"},  -ppm, 0, ppm, self.nTilesY*ppm)
    self.bumpworld:add({name = "_borderRight"}, self.nTilesX*ppm, 0, ppm, self.nTilesY*ppm)
    -- Retrieve entities from layers
    self.entitis = {}
    for lidx, layer in ipairs(tiled.layers) do
        if (layer.type == Tiled.Layer.Type.Tile) then
            for y = 1, layer.height do
                for x = 1, layer.width  do
                    local tileidx = layer.data[((y-1)*layer.width) + x]
                    local tileimg = self.tileimages[tileidx]
                    if (tileimg) then
                        table.insert(self.entitis, MapTile(layer, lidx, x, y, ppm, tileimg))
                    elseif(tileidx ~= 0) then
                        local msg = ("Tile index %i not found in tilelayer %i at (%i, %i)"):format(tileidx, lidx, x, y)
                        log.warn(msg)
                    end
                end
            end
        elseif(layer.type == Tiled.Layer.Type.Object) then
            for oidx, object in ipairs(layer.objects) do
                table.insert(self.entitis, MapObject(layer, lidx, object))
            end
        elseif(layer.type == Tiled.Layer.Type.Image) then
            local img_name = pdlibs.string.cutPathToFilename(layer.image)
            local img = gfx.sprite.new(assets.getImage(img_name))
            if (img) then
                table.insert(self.entitis, MapImage(layer, lidx, img))
            else
                local msg = ("Image %s not found in tilelayer %i"):format(img_name, lidx)
                log.warn(msg)
            end
        else
            log.warn("Unrecognized layer type ".. layer.type)
        end
    end
    -- Post-Process entities
    for _, e in ipairs(self.entitis) do
        if (e.collision and not e.hitbox) then
            e.hitbox = {
                w = math.max(e.width or 1, 1),
                h = math.max(e.height or 1, 1)
            }
        end
        if (e.bumptype and not e.bumpfilter) then
            e.bumpfilter = function (self, other)
                return e.bumptype
            end
        end
    end
end

function MapData:getBumpWorld()
    return self.bumpworld
end

function MapData:getTileSize()
    return self.tileWidth, self.tileHeight
end