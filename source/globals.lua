--[[ Global constants ]]
DEBUG = true
FPS = 30 -- Frames per second

--[[ CONFIGURATIONS ]]

-- Make this dependant on Level data?
TILE_WIDTH  = 128           -- Global Tile-width for isometric coordinate conversion
TILE_HEIGHT = 64            -- Global Tile-height or isometric coordinate conversion
PPM = TILE_HEIGHT           -- Pixel-Per-Meter. Stretching factor for Tile coordinate system.

CAMERA_LERP_FACTOR = 0.1    -- Smoothing factor for camera lerping
BUMP_CELL_MULTIPLIER = 2    -- BumpWorld cell size multiplier


--[[ DEFINITIONS ]]

--[[ Drawing ]]
SPRITE_Z_MIN = -32768
SPRITE_Z_MAX = 32767

--[[ Direction ]]
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

--[[ Special Tiled layers]]
LayerName = {
    Floor = "floor", -- Empty tiles on floor layer are treated as walls
    Spawns = "spawn",
    Events = "events"
}

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