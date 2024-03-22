import "CoreLibs/object"
import "pdlibs/util/math"
import "libs/tinyecs"

--[[ Process entity specific dynamic behavior stored in the event component. ]]

class("EventSystem").extends()
tinyecs.processingSystem(EventSystem)
EventSystem.filter = tinyecs.requireAll("event")

function EventSystem:init()
    EventSystem.super.init(self)
end

local function checkTrigger(e, ...)
    if (not e.event.trigger) then
        return true
    end
    for _, type in ipairs({...}) do
        if (e.event.trigger == type) then return true end
    end
    return false
end

function EventSystem:onAdd(e)
    e.event.messages = e.event.messages or {}
    e.event.consumed = e.event.consumed or false

    e.event.checkTrigger = e.event.checkTrigger or function (self, ...)
        if (not self.trigger) then
            return true
        end
        for _, type in ipairs({...}) do
            if (self.trigger == type) then return true end
        end
        return false
    end

    e.event.notify = e.event.notify or function (self, type, body)
        if (self:checkTrigger(type)) then
            table.insert(self.messages, {header = type, body = body})
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