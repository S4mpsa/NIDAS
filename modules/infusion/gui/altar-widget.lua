local gpu = require('component').gpu

local coreStatuses = require('modules.infusion.constants').coreStatuses

local windowBorder = require('core.lib.graphics.atoms.window-border')

---@param label string
---@return Component
local function altarLabel(label)
    ---@type Component
    local component = {
        id = 'altar-label',
        onRender = function (pos, size)
            windowBorder(pos, size, label)
        end
    }

    return component
end

---@return Component
local function largeMatrixIcon()
    ---@type Component
    local component = {
        id = 'matrix-icon',
        pos = { x = -22, y = 1 },
        size = { x = 20, y = 10 },
        onRender = function (pos)
            gpu.setForeground(0xDD00DD)
            local largeIconLines = {
                '        ⋰  ⋱        ',
                '      ⋰      ⋱      ',
                '      ⋱      ⋰      ',
                '  ⋰  ⋱  ⋱  ⋰  ⋰  ⋱  ',
                '⋰      ⋱    ⋰      ⋱',
                '⋱      ⋰    ⋱      ⋰',
                '  ⋱  ⋰  ⋰  ⋱  ⋱  ⋰  ',
                '      ⋰      ⋱      ',
                '      ⋱      ⋰      ',
                '        ⋱  ⋰        '
            }
            for lineIndex, iconLine in ipairs(largeIconLines) do
                gpu.set(pos.x, pos.y + lineIndex, iconLine)
            end
        end
    }
    return component
end

---@return Component
local function smallMatrixIcon()
    ---@type Component
    local component = {
        id = 'matrix-icon',
        pos = { x = 7, y = 4 },
        size = { x = 7, y = 4 },
        onRender = function (pos)
            gpu.setForeground(0xDD00DD)
            local smallIconLines = {
                '  ⋰ ⋱ ',
                '⋰ ⋱ ⋰ ⋱',
                '⋱ ⋰ ⋱ ⋰',
                '  ⋱ ⋰ ',
            }
            for lineIndex, iconLine in ipairs(smallIconLines) do
                gpu.set(pos.x, pos.y + lineIndex, iconLine)
            end
        end
    }
    return component
end

---@param essentiaName string
---@param essentiaProgress Progress
---@return Component
local function essentiaBar(essentiaName, essentiaProgress)
    local currentProgress = essentiaProgress.current
    local maxProgress = essentiaProgress.max

    ---@type Component
    local component = {
        id = 'essentia-bar',
        pos = { y = 14 },
        size = { x = 16, y = 2 },
        children = {
            {
                id = 'label',
                onRender = function(pos)
                    gpu.set(pos.x, pos.y, essentiaName)
                end
            },
            {
                id = 'amount',
                pos = { x = -#(currentProgress .. ' / ' .. maxProgress) },
                onRender = function(pos)
                    gpu.set(
                        pos.x,
                        pos.y,
                        currentProgress .. ' / ' .. maxProgress
                    )
                end
            },
            {
                id = 'progress',
                pos = { y = 1 },
                onRender = function (pos, size)
                    gpu.setForeground(0x666666)
                    -- gpu.set(pos.x, pos.y, '◖')
                    gpu.set(
                        pos.x,
                        pos.y,
                        string.rep('=', size.x)
                    )
                    -- gpu.set(pos.x + size.x - 1, pos.y, '◗')

                    local progressSize = math.ceil(
                        size.x * currentProgress / maxProgress
                    )
                    gpu.setForeground(0xDD00DD)
                    if (progressSize > 0) then
                        -- gpu.set(pos.x, pos.y, '◖')
                        gpu.set(
                            pos.x,
                            pos.y,
                            string.rep('🬋', progressSize)
                        )
                    end
                    -- if (progressSize == size.x) then
                    --     gpu.set(pos.x + size.x - 1, pos.y, '◗')
                    -- end
                end
            }
        }
    }

    return component
end

local smallIcon = smallMatrixIcon()

local resolution = {}
resolution.x, resolution.y = gpu.getResolution()

---@param status AltarStatus
---@param requiredEssentiaList Essentia[]
---@param essentiaList Essentia[]
---@return Component
local function altarWidget(status, item, requiredEssentiaList, essentiaList)
    local icon = smallIcon --largeMatrixIcon()
    local message = ''
    if status == coreStatuses.no_infusions then
        message = 'Altar is idle'
        icon = largeMatrixIcon()
    elseif status == coreStatuses.infusion_start then
        message = 'Placing items for "' .. item .. '" on the pedestals'
    elseif status == coreStatuses.waiting_on_matrix then
        message = 'Waiting for matrix activation'
    elseif status == coreStatuses.missing_essentia then
        message = 'Missing essentia to infuse "' .. item .. '"'
    elseif status == coreStatuses.waiting_on_essentia then
        message = 'Infusing "' .. item .. '"'
    end

    local label = altarLabel(message)

    local essentiaComponents = {}
    for i, requiredEssentia in ipairs(requiredEssentiaList or {}) do
        local currentEssentia = {}
        for _, essentia in ipairs(essentiaList) do
            if essentia.label == requiredEssentia.label then
                currentEssentia = essentia
                break
            end
        end
        essentiaComponents[i] = essentiaBar(
            string.gsub(requiredEssentia.label, ' Gas', ''),
            {
                current = currentEssentia.amount or 0,
                max = requiredEssentia.amount
            }
        )
        essentiaComponents[i].pos = {
            x = 20 + ((i - 1) % 2) * 19,
            y = 2 * math.ceil(i / 2) + 1
        }
    end

    ---@type Component
    local component = {
        id = 'root',
        pos = { x = 0, y = 0 },
        size = resolution,
        children = {
            {
                id = 'altar-widget',
                pos = { x = 2, y = 2 },
                size = { x = 58, y = 14 },
                children = {
                    label,
                    icon,
                    table.unpack(essentiaComponents)
                }
            },
            -- {
            --     id = 'altar-widget2',
            --     pos = { x = 60, y = 2 },
            --     size = { x = 58, y = 14 },
            --     children = {
            --         label,
            --         icon,
            --         table.unpack(essentiaComponents)
            --     }
            -- }
        }
    }

    return component
end

return altarWidget
