import "scripts/system/AbstractSystem"

--[[ In Construction ]]

-- List of predefined event subjects
Event = {
    Collision = "collision" -- Occurs when other collides with entity
}

class("EventSystem").extends(AbstractSystem)
tinyecs.processingSystem(EventSystem)
EventSystem.filter = tinyecs.requireAll("event")

function EventSystem:init()
    EventSystem.super.init(self)
end

function EventSystem:onAdd(e)
    e.messages = e.messages or {}     -- Event message queue

    for _, s in pairs(e.event) do
        if (type(s) == "table") then
            s.consumed = s.consumed or false
            s.repeats = s.repeats or false
        end
    end

    -- Notify only this entity
    e.notify = e.notify or function (self, subject, body)
        if (self.event[subject] and
            not self.event[subject].consumed) then
            table.insert(self.messages, {
                subject = subject,
                body = body
            })
        end
    end
end

-- Recursively sets/overwrites properties 
local function setProperty(e, name, value)
    if (type(value) == "table" and e[name] and type(e[name] == "table")) then
        for n, v in pairs(value) do
            setProperty(e[name], n, v)
        end
    else
        e[name] = value
    end
end

function EventSystem:process(e, dt)
    if (#e.messages == 0) then
        return
    end
    -- Consume messages
    for _, msg in ipairs(e.messages) do
        log.info(("Event %s: %s "):format(msg.subject, msg.body))
        local subject = e.event[msg.subject]
        local consumed = not subject.repeats
        -- Set Entity Attributes
        for action, body in pairs(subject) do
            -- Set Values
            if (action:match("set%d*")) then
                local target = msg.body -- Default target
                -- Check if special target is selected
                if (body.oid and body.oid > 0) then
                    target = e.objref[body.oid]
                end
                for name, value in pairs(body) do
                    if (name ~= "oid") then
                        setProperty(target, name, value)
                    end
                end
                -- Refresh Entity since components have possibly changed
                _G["world"]:addEntity(target)
            end
        end
        subject.consumed = consumed
    end
    e.messages = {}
end

function EventSystem:postProcess(dt)
    
end

-- Notify all entities in the system
function EventSystem:broadcast(subject, body)
    for _, e in ipairs(self.entities) do
        e:notify(subject, body)
    end
end