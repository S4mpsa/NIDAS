local event = require('event')
event.onError = print

local gpu = require('component').gpu

local clamp = require('lib.numUtils').clamp

local windowBorder = require('gui.components.atoms.window-border')
local textBox = require('gui.components.atoms.text-box')
local separator = require('gui.components.atoms.horizontal-separator')

--[[☰]]
--------------------------------- Components -----------------------------------

---@type Coordinate2D
local wheelPos = { y = 0 }

local function getMaxYPos(numberOfPackages)
    return math.min(7 * (numberOfPackages + 1), (20 + 7) / 2) + 7
end

---@param packages Package[]
---@return Component
local function scrollBarComponent(packages, callBack)
    local maxYPos = getMaxYPos(#packages)
    local previousClickPosition = { y = wheelPos.y }
    local function onClick(clickPosition, _, _, _)
        previousClickPosition = clickPosition
    end

    local function onDrag(dragPosition, _, _, onDragCallBack)
        onDragCallBack(
            (previousClickPosition.y - dragPosition.y) / getMaxYPos(#packages)
        )
    end

    local size = { x = 2, y = -9 }
    ---@type Component
    local scrollBar = {
        id = 'scrollBar',
        pos = { x = -4, y = 8 },
        size = size,
        callBack = callBack,
        onClick = onClick,
        onDrag = onDrag,
        children = {
            {
                id = 'bar',
                onRender = windowBorder
            },
            {
                id = 'wheel',
                pos = wheelPos,
                size = { y = maxYPos + size.y - 21 },
                onRender = windowBorder,
            }
        }
    }
    return scrollBar
end

---@param packages Package[]
---@return Component
local function modulesComponent(packages, callBack)
    local previousClickPosition = { y = wheelPos.y }
    local function onClick(clickPosition, _, _, _)
        previousClickPosition = clickPosition
    end

    local function onDrag(dragPosition, _, _, onDragCallBack)
        onDragCallBack(
            (dragPosition.y - previousClickPosition.y) / getMaxYPos(#packages)
        )
    end

    ---@type Component
    local component = {
        id = 'modules',
        pos = { x = 2, y = 8 },
        size = { x = -8 },
        callBack = callBack,
        onClick = onClick,
        onDrag = onDrag,
        children = {}
    }
    for i, package in ipairs(packages) do
        local sizeInKB = tostring(math.ceil(package.size / 1024)) .. 'kB'
        local publishDate = string.sub(package.updatedAt, 1, 10)
        local childSize = { y = 6 }
        local childPos = { y = (childSize.y + 1) * (i - 1) - wheelPos.y }

        ---@type Component
        local child = {
            id = package.name .. '-' .. i,
            pos = childPos,
            visible = 0 <= childPos.y
                and childPos.y < 50 - childSize.y - 2,
            size = { y = childSize.y },
            children = {
                {
                    id = 'border',
                    onRender = function(pos, size)
                        windowBorder(
                            pos,
                            size,
                            package.name .. ' - ' .. package.tag
                        )
                    end,
                },
                {
                    id = 'author',
                    pos = { x = 5, y = 2 },
                    onRender = function(pos, size)
                        textBox(pos, size, 'By ' .. package.author)
                    end,
                },
                {
                    id = 'file-size',
                    pos = { x = - #sizeInKB - 3, y = 2 },
                    onRender = function(pos, size)
                        textBox(pos, size, sizeInKB)
                    end,
                    children = {
                        {
                            id = 'select-icon',
                            pos = { x = -2 },
                            onRender = function(pos)
                                local selectIcon = package.selected
                                    and '➖'
                                    or '➕'
                                gpu.set(pos.x, pos.y, selectIcon)
                            end,
                            onClick = function(_, _, _, _)
                                package.selected = not package.selected
                            end
                        }
                    }
                },
                {
                    id = 'publication-date',
                    pos = { x = - #publishDate - 1, y = 4 },
                    onRender = function(pos, size)
                        textBox(pos, size, publishDate)
                    end,
                },
                {
                    id = 'description',
                    pos = { x = 5, y = 4 },
                    size = { x = - #publishDate - 5 },
                    onRender = function(pos, size)
                        textBox(pos, size, package.description)
                    end,
                },
            }
        }
        table.insert(component.children, child)
    end
    return component
end

local function welcomeBox(packages, download, install)
    local downloadIcon = '⬇'
    local installIcon = '➡'
    local downloadText = 'Download selected packages'
    local installText = 'Install downloaded packages'

    ---@type Component
    local wecolmeBoxComponent = {
        id = 'welcome',
        pos = { x = 5, y = 3 },
        size = { x = -4 },
        onRender = function(pos, size)
            textBox(
                pos,
                size,
                'Welcome to NIDAS\'s package manager, The Hand!'
            )
            textBox(
                { x = pos.x, y = pos.y + 2 },
                size,
                'Here\'s a list of curated packages. Enjoy :)'
            )
        end,
        children = {
            {
                id = 'separator',
                pos = { y = 3 },
                size = { x = -8, y = 1 },
                onRender = separator
            },
            {
                id = 'download',
                pos = { x = - #downloadText - 8 },
                size = { x = #downloadText + 2, y = 1 },
                onRender = function(pos, size)
                    textBox(
                        pos,
                        size,
                        downloadText
                    )
                end,

                children = {
                    {
                        id = 'download-icon',
                        pos = { x = -1 },
                        onRender = function(pos)
                            gpu.set(pos.x, pos.y, downloadIcon)
                        end,
                        onClick = function()
                            if downloadIcon ~= '⋯' then
                                downloadIcon = '⋯'
                                for _, package in ipairs(packages) do
                                    if package.selected then
                                        download(package.url)
                                        coroutine.yield()
                                    end
                                end
                                downloadIcon = '✔'
                            end
                        end,
                    }
                }
            },
            {
                id = 'install',
                pos = { x = - #installText - 8, y = 2 },
                size = { x = #installText + 2, y = 1 },
                onRender = function(pos, size)
                    textBox(
                        pos,
                        size,
                        installText
                    )
                end,

                children = {
                    {
                        id = 'install-icon',
                        pos = { x = -1 },
                        onRender = function(pos)
                            gpu.set(pos.x, pos.y, installIcon)
                        end,
                        onClick = function()
                            if installIcon ~= '⋯' then
                                installIcon = '⋯'
                                for _, package in ipairs(packages) do
                                    if package.selected then
                                        install(package)
                                        coroutine.yield()
                                    end
                                end
                                installIcon = '✔'
                            end
                        end,
                    }
                }
            }
        }
    }

    return wecolmeBoxComponent
end

---@param packages Package[]
---@param download function
---@param install function
---@return Component
local function handGui(packages, download, install)
    local modules = {}
    local maxYPos = getMaxYPos(#packages)
    local function onScroll(pos, size, direction)
        local nextWheelPosY = clamp(wheelPos.y - direction, 0, maxYPos)
        for i, child in ipairs(modules.children) do
            child.pos.y = (child.size.y + 1) * (i - 1) - wheelPos.y
            child.visible = pos.y <= child.pos.y
                and child.pos.y < pos.y + size.y - child.size.y - 8
        end
        wheelPos.y = nextWheelPosY
    end

    modules = modulesComponent(packages, onScroll)
    local scrollBar = scrollBarComponent(packages, onScroll)
    local welcomeBoxComponent = welcomeBox(packages, download, install)
    ---@type Component
    local component = {
        id = 'root',
        onRender = function(pos, size)
            windowBorder(pos, size, 'Package list')
        end,
        onScroll = onScroll,
        children = {
            modules,
            scrollBar,
            welcomeBoxComponent,
        }
    }
    return component
end

return handGui
