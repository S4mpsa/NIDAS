local horizontalSeparator = require('core.lib.graphics.atoms.horizontal-separator')
local verticalSeparator = require('core.lib.graphics.atoms.vertical-separator')
local textBox = require('core.lib.graphics.atoms.text-box')
local altarWidget = require('modules.infusion.gui.altar-widget')
local coreStatuses = require('modules.infusion.constants').coreStatuses

local altarIndexes = {}
local nKnownAltars = 0
local altarWidgets = {}

local label = {
    id = 'dashboard-border',
    pos = { x = 1 },
    size = { x = -2 },
    onRender = function(pos, size)
        horizontalSeparator(pos, size, 'Infusion automation')
    end
}

local separator = {
    id = 'separator',
    pos = { y = 1 },
    size = { y = -2 },
    onRender = verticalSeparator,
}

local footer = {
    id = 'footer',
    pos = { y = -2 },
    onRender = horizontalSeparator,
}

local function newPosition(widget, index)
    return {
        x = widget.size.x * ((index - 1) % 2) + 2,
        y = widget.size.y * (math.ceil(index / 2) - 1)
    }
end

for i = 1, 6 do
    altarWidgets[i] = altarWidget('No altar')
    altarWidgets[i].pos = newPosition(altarWidgets[i], i)
end

---@param altarId string
---@param status AltarStatus
---@param itemName? string
---@param requiredEssentiaList? Essentia[]
---@param essentiaList? Essentia[]
---@return Component
local function altarDashboard(
    altarId,
    status,
    itemName,
    requiredEssentiaList,
    essentiaList
)
    local inactive = false
    local message = ''
    if status == coreStatuses.no_infusions or status == 'dead' then
        message = 'Altar ' .. string.sub(altarId, 1, 4) .. ' is idle'
        inactive = true
    elseif status == coreStatuses.infusion_start then
        message = (itemName and itemName ~= '')
            and 'Placing items for "' .. itemName .. '" on the pedestals'
            or 'Placing items on the pedestals'
    elseif status == coreStatuses.waiting_on_matrix then
        message = 'Waiting for matrix activation'
    elseif status == coreStatuses.missing_essentia then
        message = 'Missing essentia to infuse "' .. itemName .. '"'
    elseif status == coreStatuses.waiting_on_infusion then
        message = (itemName and itemName ~= '')
            and 'Infusing "' .. itemName .. '"'
            or 'Infusing'
    end

    local altarIndex = altarIndexes[altarId]
    if altarId and not altarIndex then
        if nKnownAltars == 6 then
            error('too many altars')
        end
        nKnownAltars = nKnownAltars + 1
        altarIndex = nKnownAltars
        altarIndexes[altarId] = altarIndex
    end

    if altarIndex then
        altarWidgets[altarIndex] = altarWidget(
            message,
            requiredEssentiaList,
            essentiaList,
            inactive
        )
        altarWidgets[altarIndex].pos = newPosition(
            altarWidgets[altarIndex],
            altarIndex
        )
    end

    ---@type Component
    local component = {
        id = 'altar-dashboard',
        pos = { x = 0, y = 2 },
        size = { x = 160, y = 49 },
        children = {
            label,
            {
                id = 'widgets',
                pos = { x = 41, y = 2 },
                size = { y = -4 },
                children = {
                    separator,
                    table.unpack(altarWidgets),
                },
            },
            footer
        }
    }

    return component
end

return altarDashboard
