import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"
import "pdlibs/state/StateMachine"
import "libs/pdlog"
import "globals"
import "assets"

import "scripts/scene/TestScene"

--[[ Global variables ]]
SCENE_MANAGER = pdlibs.state.StateMachine()
SCENE_MANAGER:switch(TestScene())

--[[ Local variables ]]
local pd <const> = playdate
local gfx <const> = playdate.graphics
local disp <const> = playdate.display


--[[ Initialization ]]
math.randomseed(pd.getSecondsSinceEpoch())
disp.setRefreshRate(FPS)
gfx.setDrawOffset(disp.getWidth()/2, disp.getHeight()/2)
--gfx.setBackgroundColor(gfx.kColorBlack)

--[[ Update Routines ]]

function pd.update()
    pd.timer.updateTimers()   -- Update all timers
    gfx.sprite.update()       -- Update all sprites
    SCENE_MANAGER:update()    -- Update current scene
    pd.drawFPS(0, 0)
end


--[[ Game lifecycle ]]

-- Save Gamestate on termination
function pd.gameWillTerminate()
end

-- Save Gamestate on sleep
function pd.deviceWillSleep()
end


--[[ Simulator and Debug ]]

function playdate.keyPressed(key)
    if (#key > 1) then
        log.warn("Key pressed (null-terminated) " .. key)
        key = key[1]
    else
        log.info("Key pressed " .. key)
    end
    SCENE_MANAGER.current:keyPressed(key)
end

local menu = playdate.getSystemMenu()
local debugItem, error = menu:addCheckmarkMenuItem("debug", DEBUG, function(value)
    DEBUG = value
    log.info("Debug mode set to " .. string.upper(tostring(value)))
end)
if (not debugItem) then
    log.error(error)
end