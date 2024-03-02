import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"
import "pdlibs/state/StateMachine"
import "globals"


--[[ Global variables ]]
SCENE_MANAGER = pdlibs.state.StateMachine()

--[[ Local variables ]]
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

function pd.update()
    -- update delta time
    local nowTimeMs = pd.getCurrentTimeMilliseconds()
    deltaTimeMs = nowTimeMs - currTimeMs
    currTimeMs = nowTimeMs
    SCENE_MANAGER:update()    -- Update current scene
    pd.timer.updateTimers()   -- Update all timers
    gfx.sprite.update()       -- Update all sprites
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