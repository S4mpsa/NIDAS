local Topic = require('core.event-processor.topic')

local EventProcessor = {}
function EventProcessor.new()
    ---@type Topic[]
    local topics = {}

    ---@class EventProcessor
    local this = {}

    ---@param topicName? string
    ---@param listenerFunction function
    ---@return string? listenerId
    function this.listen(topicName, listenerFunction)
        if topicName then
            topics[topicName] = topics[topicName] or Topic.new(topicName)
            return topics[topicName].addListener(listenerFunction)
        end
    end

    ---@param topicName? string
    ---@param listenerId string
    function this.ignore(topicName, listenerId)
        if type(listenerId) ~= 'string' then
            return
        end
        if topicName and topics[topicName] then
            topics[topicName].ignoreListener(listenerId)
        end
    end

    ---@param topicName any
    ---@param event Event
    ---@return string eventId
    function this.push(topicName, event)
        topics[topicName] = topics[topicName] or Topic.new(topicName)
        return topics[topicName].insert(event)
    end

    function this.consumeQueue()
        local hasMore = true
        while hasMore do
            hasMore = false
            for _, topic in pairs(topics) do
                local event = topic.remove()
                if event ~= nil then
                    topic.execute(event)
                    hasMore = true
                end
            end
        end
    end

    return this
end

return EventProcessor
