
local event = require('event')
event.onError = print

local gpu = require('component').gpu

local clamp = require('core.lib.numUtils').clamp

local windowBorder = require('core.lib.graphics.atoms.window-border')
local textBox = require('core.lib.graphics.atoms.text-box')
local separator = require('core.lib.graphics.atoms.separator')

local gui = {}

--------------------------------- Components -----------------------------------

local wheelPos = { y = 0 }
---@type Coordinates
local resolution = {}
resolution.x, resolution.y = gpu.getResolution()

local function getMaxYPos(numberOfPackages)
    return math.min(7 * (numberOfPackages + 1), (resolution.y + 7) / 2 ) + 7
end

---@param packages Package[]
---@return Component
local function scrollBarComponent(packages, callBack)
    local maxYPos = getMaxYPos(#packages)
    local previousClickPosition = { y = wheelPos.y }
    local function onClick(clickPosition,  _, _, _)
        previousClickPosition = clickPosition
    end
    local function onDrag(dragPosition, _, reRender, onDragCallBack)
        onDragCallBack(
            (previousClickPosition.y - dragPosition.y) / getMaxYPos(#packages),
            reRender
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
    return  scrollBar
end

---@param packages Package[]
---@return Component
local function modulesComponent(packages, callBack)
    local previousClickPosition = { y = wheelPos.y }
    local function onClick(clickPosition, _, _, _)
        previousClickPosition = clickPosition
    end
    local function onDrag(dragPosition, _, reRender, onDragCallBack)
        onDragCallBack(
            (dragPosition.y - previousClickPosition.y) / getMaxYPos(#packages),
            reRender
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
                and childPos.y < resolution.y - childSize.y - 2,
            size = { y = childSize.y },
            children = {
                {
                    id = 'border',
                    onRender = function (pos, size)
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
                    onRender = function (pos, size)
                        textBox(pos, size, 'By ' .. package.author)
                    end,
                },
                {
                    id = 'file-size',
                    pos = { x = -#sizeInKB - 3, y = 2 },
                    onRender = function (pos, size)
                        textBox(pos, size, sizeInKB)
                    end,
                    children = {
                        {
                            id = 'select-icon',
                            pos = { x = -2 },
                            onRender = function (pos)
                                local selectIcon = package.selected
                                    and '➖'
                                    or '➕'
                                gpu.set(pos.x, pos.y, selectIcon)
                            end,
                            onClick = function (_, _, _, _)
                                package.selected = not package.selected
                            end
                        }
                    }
                },
                {
                    id = 'publication-date',
                    pos = { x = -#publishDate - 1, y = 4 },
                    onRender = function (pos, size)
                        textBox(pos, size, publishDate)
                    end,
                },
                {
                    id = 'description',
                    pos = { x = 5, y = 4 },
                    size = { x = -#publishDate - 5 },
                    onRender = function (pos, size)
                        textBox(pos, size, package.description)
                    end,
                },
            }
        }
        table.insert(component.children, child)
    end
    return component
end

local function welcomeBoxComponent(packages, download, install)
    local downloadIcon = '⬇'
    local installIcon = '➡'
    local downloadText = 'Download selected packages'
    local installText = 'Install downloaded packages'

    return {
        id = 'welcome',
        pos = { x = 5, y = 3 },
        size = { x = -4 },
        onRender = function (pos, size)
            textBox(
                pos,
                size,
                'Welcome to NIDAS\'s package manager, The Hand!'
            )
            textBox(
                { x = pos.x, y = pos.y + 2},
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
                pos = { x = -#downloadText - 8 },
                size = {x = #downloadText + 2,  y = 1 },
                onRender = function (pos, size)
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
                        onRender = function (pos)
                            gpu.set(pos.x, pos.y, downloadIcon)
                        end,
                        onClick = function (_, _, reRender, _)
                            if downloadIcon ~= '⋯' then
                                downloadIcon = '⋯'
                                reRender()
                                for _, package in ipairs(packages) do
                                    if package.selected then
                                        download(package.url)
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
                pos = { x = -#installText - 8,  y = 2 },
                size = {x = #installText + 2,  y = 1 },
                onRender = function (pos, size)
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
                        onRender = function (pos)
                            gpu.set(pos.x, pos.y, installIcon)
                        end,
                        onClick = function (_, _, reRender, _)
                            if installIcon ~= '⋯' then
                                installIcon = '⋯'
                                reRender()
                                for _, package in ipairs(packages) do
                                    if package.selected then
                                        install(package)
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
end

---@return Component
function gui.rootComponent(packages, download, install)

    local modules = {}
    local maxYPos = getMaxYPos(#packages)
    local function onScroll(_, direction, reRender)
        event.push('refresh', 'root')
        local nextWheelPosY = clamp(wheelPos.y - direction, 0, maxYPos)
        for i, child in ipairs(modules.children) do
            child.pos.y = (child.size.y + 1) * (i - 1) - wheelPos.y
            child.visible = 0 <= child.pos.y
                and child.pos.y < resolution.y - child.size.y - 8
        end
        wheelPos.y = nextWheelPosY
        reRender()
    end

    local function dragCallBack(_, _, direction, reRender)
        onScroll(nil, direction, reRender)
    end

    modules = modulesComponent(packages, dragCallBack)
    local scrollBar = scrollBarComponent(packages, dragCallBack)
    local welcomeBox = welcomeBoxComponent(packages, download, install)
    return {
        id = 'root',
        pos = { x = 0, y = 1 },
        size = resolution,
        onRender = function (pos, size)
            windowBorder(pos, size, 'Package list')
        end,
        onScroll = onScroll,
        children = {
            modules,
            scrollBar,
            welcomeBox,
        }
    }
end

return gui
