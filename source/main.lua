import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"
import "globals"

local pd <const> = playdate
local dsp <const> = playdate.display
local gfx <const> = playdate.graphics
local currTimeMs = pd.getCurrentTimeMilliseconds()
local deltaTimeMs = 0

-- Initialization
math.randomseed(pd.getSecondsSinceEpoch())
dsp.setRefreshRate(FPS)
gfx.setDrawOffset(0, 0)

--[[ Update Routines ]]

local function updateDeltaTime()
    local nowTimeMs = pd.getCurrentTimeMilliseconds()
    deltaTimeMs = nowTimeMs - currTimeMs
    currTimeMs = nowTimeMs
end

function pd.update()
    updateDeltaTime()
    pd.timer.updateTimers() -- Update all timers
    gfx.sprite.update()     -- Update all sprites
    pd.drawFPS(0, 0)
end

function getDeltaTimeMs()
    return deltaTimeMs
end

-- [[ Game lifecycle ]]

-- Save Gamestate on termination
function pd.gameWillTerminate()
end

-- Save Gamestate on sleep
function pd.deviceWillSleep()
end