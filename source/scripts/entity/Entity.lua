import "CoreLibs/object"
import "CoreLibs/graphics"
import "libs/vector"

local nextId = 1

--[[ Abstract Entity class, holds unique id.
All entities in the world should inherit or be in instance of this. ]]
class("Entity").extends()

function Entity:init()
    self.entityid = nextId
    nextId += 1
end