import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"

local pd <const> = playdate
local dsp <const> = playdate.display
local gfx <const> = playdate.graphics

-- Initialization
FPS = 30
math.randomseed(pd.getSecondsSinceEpoch())
dsp.setRefreshRate(FPS)
gfx.setDrawOffset(0, 0)

function pd.update()
    pd.timer.updateTimers() -- Update all timers
    gfx.sprite.update()     -- Update all sprites
    pd.drawFPS(0, 0)
end

-- Save Gamestate on termination
function pd.gameWillTerminate()
end

-- Save Gamestate on sleep
function pd.deviceWillSleep()
end