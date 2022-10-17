local gpu = require('component').gpu
local event = require('event')

local renderEngine = {}

---@param rootComponent Component
---@return Component[]
local function assembleElementQueue(rootComponent)
    rootComponent.pos = rootComponent.pos or {}
    rootComponent.pos.x = rootComponent.pos.x or 0
    rootComponent.pos.y = rootComponent.pos.y or 0
    rootComponent.absolutePosition = rootComponent.absolutePosition
        or rootComponent.pos

    rootComponent.size = rootComponent.size or {}
    rootComponent.size.x = rootComponent.size.x or 0
    rootComponent.size.y = rootComponent.size.y or 0
    rootComponent.absoluteSize = rootComponent.absoluteSize
        or rootComponent.size

    local queue = { rootComponent }
    local i = 1
    ---@type Component
    local parent = queue[i]
    while parent do
        local children = parent.children
        ---@type Component
        for _, child in ipairs(children or {}) do
            local relativePosition = {}
            if not child.pos or not child.pos.x then
                relativePosition.x = 0
            elseif child.pos.x < 0 then
                relativePosition.x = parent.absoluteSize.x + child.pos.x
            else
                relativePosition.x = child.pos.x
            end
            if not child.pos or not child.pos.y then
                relativePosition.y = 0
            elseif child.pos.y < 0 then
                relativePosition.y = parent.absoluteSize.y + child.pos.y
            else
                relativePosition.y = child.pos.y
            end
            child.absolutePosition = {
                x = relativePosition.x + parent.absolutePosition.x,
                y = relativePosition.y + parent.absolutePosition.y,
            }

            local absoluteSize = {}
            if not child.size or not child.size.x then
                absoluteSize.x = parent.absoluteSize.x
                    - relativePosition.x
            elseif child.size.x < 0 then
                absoluteSize.x = parent.absoluteSize.x + child.size.x
            else
                absoluteSize.x = child.size.x
            end
            if not child.size or not child.size.y then
                absoluteSize.y = parent.absoluteSize.y
                    - relativePosition.y
            elseif child.size.y < 0 then
                absoluteSize.y = parent.absoluteSize.y + child.size.y
            else
                absoluteSize.y = child.size.y
            end
            child.absoluteSize = {
                x = math.min(
                    absoluteSize.x,
                    parent.absoluteSize.x - relativePosition.x
                ),
                y = math.min(
                    absoluteSize.y,
                    parent.absoluteSize.y - relativePosition.y
                )
            }


            child.parent = parent

            table.insert(queue, child)
        end
        i = i + 1
        parent = queue[i]
    end
    return queue
end

---@param rootComponent Component
function renderEngine.render(rootComponent)
    local renderQueue = assembleElementQueue(rootComponent)

    gpu.fill(
        rootComponent.absolutePosition.x + 1,
        rootComponent.absolutePosition.y + 1,
        rootComponent.absoluteSize.x - 1,
        rootComponent.absoluteSize.y - 1,
        ' '
    )

    for _, element in ipairs(renderQueue) do
        local shouldRender = element.visible ~= false
        local parent = element.parent
        while shouldRender and parent do
            shouldRender = shouldRender and parent.visible ~= false
            parent = parent.parent
        end

        if shouldRender and element.onRender then
            element.onRender(element.absolutePosition, element.absoluteSize)
        end
    end
end

local function isInside(component, pos)
    return pos.x >= component.absolutePosition.x
        and pos.x <= component.absolutePosition.x + component.absoluteSize.x
        and pos.y >= component.absolutePosition.y
        and pos.y <= component.absolutePosition.y + component.absoluteSize.y
end

---@param rootComponent Component
function renderEngine.registerEvents(rootComponent)
    local registerQueue = assembleElementQueue(rootComponent)

    for _, element in ipairs(registerQueue) do
        local function renderElement()
            renderEngine.render(element)
        end

        if element.onClick then
            local onClick = function(_, _, x, y, button)
                local clickPosition = { x = x, y = y }
                if not isInside(element, clickPosition) then
                    element.clicked = false
                else
                    local tree = { element }
                    local i = 1
                    local parent = tree[i]
                    while parent do
                        local children = parent.children
                        for _, child in ipairs(children or {}) do
                            if child.onClick
                                and isInside(child, clickPosition) then
                                    element.clicked = false
                                    return
                            end
                            table.insert(tree, child)
                        end
                        i = i + 1
                        parent = tree[i]
                    end

                    element.onClick(
                        clickPosition,
                        button,
                        renderElement,
                        function (...)
                            (element.callBack or function() end)(
                                element.absolutePosition,
                                element.absoluteSize,
                                ...
                            )
                        end
                    )
                    element.clicked = true
                    renderElement()
                end
            end

            event.listen('touch', onClick)
        end

        if element.onDrag then
            event.listen('drag', function(_, _, x, y, button)
                if not element.onClick or element.clicked then
                    element.onDrag(
                        { x = x, y = y },
                        button,
                        renderElement,
                        function (...)
                            (element.callBack or function() end)(
                                element.absolutePosition,
                                element.absoluteSize,
                                ...
                            )
                        end
                    )
                    renderEngine.render(element)
                end
            end)
        end

        if element.onScroll then
            local onScroll = function(_, _, x, y, direction)
                local scrollPosition = { x = x, y = y }
                if not isInside(element, scrollPosition) then
                    element.clicked = false
                else
                    local tree = { element }
                    local i = 1
                    local parent = tree[i]
                    while parent do
                        local children = parent.children
                        for _, child in ipairs(children or {}) do
                            if child.onScroll
                                and isInside(child, scrollPosition) then
                                    return
                            end
                            table.insert(tree, child)
                        end
                        i = i + 1
                        parent = tree[i]
                    end

                    element.onScroll(scrollPosition, direction, renderElement)
                    renderElement()
                end
            end

            event.listen('scroll', onScroll)
        end

        event.listen('refresh', function(_, id)
            if id == element.id then
                renderElement()
            end
        end)

    end
end

return renderEngine
