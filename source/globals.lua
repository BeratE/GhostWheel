--[[ Global constants ]]
DEBUG = true
DEBUG_DRAW = true
FPS = 30 -- Frames per second

--[[ CONFIGURATIONS ]]

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