import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"
import "pdlibs/state/StateMachine"
import "globals"
import "assets"

import "scripts/scene/TestScene"

--[[ Global variables ]]
SCENE_MANAGER = pdlibs.state.StateMachine()
SCENE_MANAGER:switch(TestScene())

--[[ Local variables ]]
local pd <const> = playdate
local dsp <const> = playdate.display
local gfx <const> = playdate.graphics


-- Initialization
math.randomseed(pd.getSecondsSinceEpoch())
dsp.setRefreshRate(FPS)
gfx.setDrawOffset(DRAW_OFFSET_X, DRAW_OFFSET_Y)

--[[ Update Routines ]]

function pd.update()
    pd.timer.updateTimers()   -- Update all timers
    SCENE_MANAGER:update()    -- Update current scene
    gfx.sprite.update()       -- Update all sprites
    pd.drawFPS(0, 0)
end


-- [[ Game lifecycle ]]

-- Save Gamestate on termination
function pd.gameWillTerminate()
end

-- Save Gamestate on sleep
function pd.deviceWillSleep()
end