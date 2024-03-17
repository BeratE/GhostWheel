--[[ Global constants ]]
DEBUG = false
FPS = 30 -- Frames per second

TILE_WIDTH  = 128           -- Global Tile-width for isometric coordinate conversion
TILE_HEIGHT = 64            -- Global Tile-height or isometric coordinate conversion
PPM = TILE_HEIGHT           -- Pixel-Per-Meter. Stretching factor for Tile coordinate system.

BUMP_CELL_MULTIPLIER = 2    -- BumpWorld cell size multiplier

DIR = {
    NE = 1, -- North-East
    E  = 2, -- West
    SE = 3, -- Sout-East
    S  = 4, -- South
    SW = 5, -- South-West
    W  = 6, -- West
    NW = 7, -- North West
    N  = 8,  -- North
}

--[[ Drawing ]]
SPRITE_Z_MIN = -32768
SPRITE_Z_MAX = 32767


--[[ Definitions for Tiled ]]
Tiled = {
    Map = {
        Compression = {
            Default = -1
        },
        Orientation = {
            Orthogonal = "orthogonal",
            Isometric  = "isometric",
            Staggered  = "staggered",
            Hexagonal  = "hexagonal"
        },
        RenderOrder = {
            RightDown = "right-down", -- Default
            RightUp   = "right-up",
            LeftDown  = "left-down",
            LeftUp    = "left-up" -- Only supported for orthogonal maps
        },
    },
    Layer = {
        Type = {
            Tile   = "tilelayer",
            Object = "objectgroup",
            Image  = "imagelayer",
            Group  = "group",
        }
    }
}