import "scripts/system/AbstractSystem"

--[[ In Construction ]]

-- List of predefined event subjects
Event = {
    Collision = "collision", -- When other collides with entity
    Property = "property"    -- When entity property/component is changed
}

class("EventSystem").extends(AbstractSystem)
tinyecs.processingSystem(EventSystem)
EventSystem.filter = tinyecs.requireAll("event")

function EventSystem:onAdd(e)
    e.messages = e.messages or {}     -- Event message queue

    for _, s in pairs(e.event) do
        if (type(s) == "table") then
            s.ignore = s.ignore or false
            s.repeats = s.repeats or false
        end
    end

    -- Notify only this entity
    e.notify = e.notify or function (self, subject, body)
        if (self.event[subject] and not self.event[subject].ignore) then
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

-- Retrieve property from entity with dot notation
local function getProperty(e, name)
     -- Translate string dot notation
    local p = e
    for n in string.gmatch(name, '([^.]*)') do
        p = p[n]
    end
    return p
end

function EventSystem:process(e, dt)
    if (#e.messages == 0) then
        return
    end
    -- Consume messages
    for i, msg in ipairs(e.messages) do
        log.info(("Event %s: %s "):format(msg.subject, msg.body))
        local subject = e.event[msg.subject]
        local ignore = not subject.repeats
        -- Set Entity Attributes
        for action, body in pairs(subject) do
            if (action:match("set%d*")) then -- Set Values
                local target = msg.body -- Default target
                -- Check if special target is selected
                if (body.oid and body.oid > 0) then
                    target = e.objref[body.oid]
                end
                for name, value in pairs(body) do
                    if (name == "oid") then
                        goto continue
                    end
                    if (type(value) == "string") then
                        -- Translate to literal nil
                        if (value == "nil") then
                            value = nil
                        -- Look for reference values
                        else
                            local ref, propname = value:match(("^(%a+):([%w.]+)"))
                            if (ref == "self") then
                                value = getProperty(e, propname)
                            elseif (ref == "body") then
                                value = getProperty(msg.body, propname)
                            end
                        end
                    end
                    setProperty(target, name, value)
                    --[[
                    if (target.event) then
                        target:notify(Event.Property, {name = name, value = value})
                    end
                    --]]
                    ::continue::
                end
                -- Refresh Entity since components have possibly changed
                _G["world"]:addEntity(target)
            end
        end
        subject.ignore = ignore
    end
    e.messages = {}
end

-- Notify all entities in the system
function EventSystem:broadcast(subject, body)
    for _, e in ipairs(self.entities) do
        e:notify(subject, body)
    end
end