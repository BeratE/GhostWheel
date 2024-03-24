import "CoreLibs/object"
import "libs/tinyecs"
import "libs/vector"
import "pdlibs/util/math"
import "pdlibs/util/debug"

class("AbstractSystem").extends()

function AbstractSystem:init(mapdata)
    self:setMapData(mapdata)
end

function AbstractSystem:setMapData(mapdata)
end