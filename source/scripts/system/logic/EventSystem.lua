import "scripts/system/AbstractSystem"

--[[ An Event component listens to messages 
with a predefined subject(headers) from other system,
and react with their according actions. ]]

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
    local propertyChanged = (e[name] ~= value)
    if (type(value) == "table" and type(e[name] == "table")) then
        if (value ~= e[name]) then
            for n, v in pairs(value) do
                setProperty(e[name], n, v)
            end
        end
    else
        e[name] = value
    end
    return propertyChanged
end

-- Retrieve property from entity with dot notation
local function getProperty(e, name)
    local pointer = e
    for n in string.gmatch(name, '([^.]*)') do
        pointer = pointer[n] -- Translate string dot notation
    end
    return pointer
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
        for aname, abody in pairs(subject) do
            -- Action "Set" Name-Value Pairs
            if (aname:match("set%d*")) then
                local target = msg.body -- Default target
                if (abody.objrefid and abody.objrefid > 0) then -- Check if special target is selected
                    target = e.objref[abody.objrefid]
                end
                for pname, pvalue in pairs(abody) do
                    if (pname ~= "oid") then
                        if (type(pvalue) == "string") then
                            if (pvalue == "nil") then -- Translate to literal nil
                                pvalue = nil
                            else                     -- Look for reference values
                                local ref, rest = pvalue:match(("^(%a+):([%w.]+)"))
                                if     (ref == "self") then pvalue = getProperty(e, rest)
                                elseif (ref == "body") then pvalue = getProperty(msg.body, rest) end
                            end
                        end
                        local propertyChanged = setProperty(target, pname, pvalue)
                        if (propertyChanged and target.event) then
                            target:notify(Event.Property, {name = pname, value = pvalue})
                        end
                    end
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