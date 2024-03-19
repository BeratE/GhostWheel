import "CoreLibs/object"
import "CoreLibs/graphics"
import "libs/vector"

local nextId = 1

--[[ Abstract Entity class, holds unique id ]]
class("Entity").extends()

function Entity:init()
    self.entityid = nextId
    nextId += 1
end