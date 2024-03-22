import "CoreLibs/object"
import "pdlibs/util/math"
import "libs/tinyecs"
import "scripts/system/AbstractSystem"

--[[ Process entity specific dynamic behavior stored in the event component. 
Events execute a specified behavior depending on the recieved messages. ]]

class("EventSystem").extends(AbstractSystem)
tinyecs.processingSystem(EventSystem)
EventSystem.filter = tinyecs.requireAll("event")

function EventSystem:init()
    EventSystem.super.init(self)
end

function EventSystem:onAdd(e)
    e.event.messages = e.event.messages or {}
    e.event.consumed = e.event.consumed or false

    e.eventCheckTrigger = e.eventCheckTrigger or function (self, ...)
        if (not self.event.trigger) then return true end
        for _, type in ipairs({...}) do
            if (self.event.trigger == type) then return true end
        end
        return false
    end
    -- Notify only this entity
    e.eventNotify = e.eventNotify or function (self, header, body)
        if (self:eventCheckTrigger(header)) then
            table.insert(self.event.messages, {header = header, body = body})
        end
    end
end

function EventSystem:process(e, dt)
    if (e.event.consumed or #e.event.messages == 0) then
        return
    end
    -- Consume events
    for _, msg in ipairs(e.event.messages) do
        log.info(("Event %s: %s "):format(msg.header, msg.body))
        if msg.header == "collision" then
            
        end
    end
    e.event.messages = {}
    if (not e.event.repeats) then
        e.event.consumed = true
    end
end

-- Notify all entities in the system
function EventSystem:broadcast(header, body)
    for _, e in ipairs(self.entities) do
        e:eventNotify(header, body)
    end
end