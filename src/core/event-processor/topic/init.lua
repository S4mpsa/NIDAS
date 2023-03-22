local wrap = require('lib.lua-extensions.wrap')

---@type Topic
local Topic = {}

---@param name string
---@return Topic
function Topic.new(name)
    local eventsCounter = 0
    local listenersCounter = 0

    ---@type Event[]
    local events = {}
    ---@type function[]
    local listeners = {}

    ---@class Topic
    local self = {
        name = name,
    }

    ---@param listenerFunction function
    ---@return string listenerId
    function self.addListener(listenerFunction)
        local listenerId = self.name .. '/' .. listenersCounter
        listeners[listenerId] = wrap(listenerFunction, self.name, true)
        listenersCounter = listenersCounter + 1

        return listenerId
    end

    ---@param listenerId string
    function self.ignoreListener(listenerId)
        if listeners[listenerId] then
            listeners[listenerId] = nil
            listenersCounter = listenersCounter - 1
        end
    end

    ---@param event Event
    function self.insert(event)
        local eventId = self.name .. '/' .. eventsCounter
        events[eventId] = event
        eventsCounter = eventsCounter + 1

        return eventId
    end

    ---@return Event?
    function self.remove()
        if eventsCounter == 0 then
            return
        end

        local id
        for eventId, _ in pairs(events) do
            id = eventId
        end

        local event = events[id]
        if id then
            events[id] = nil
            eventsCounter = eventsCounter - 1
        end

        return event
    end

    ---@param event Event?
    function self.execute(event)
        if event then
            for _, listener in pairs(listeners) do
                listener(event.payload)
            end
        end
    end

    return self
end

return Topic
