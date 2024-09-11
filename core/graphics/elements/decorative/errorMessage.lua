local component = require("component") local gpu = component.gpu
local stringUtils = require("core.lib.stringUtils")

---@param position Coordinate2D
---@param size Coordinate2D
---@param str string
---@param colour? number
local function errorMessage(position, size, str, colour)

    local function draw(window, element)
        str = str:gsub("\t", "  ")
        local lines = stringUtils.split(str, "\n")
        for i = 1, #lines do
            if i < element.size.y then
                gpu.set(1, 1, "NIDAS has encountered an error! Include the following stack trace when asking for help.")
                local old = gpu.getForeground()
                gpu.setForeground(0xff0000)
                gpu.set(1, i + 2, lines[i])
                gpu.setForeground(old)
            end
        end
    end

    local element = {
        size = size,
        position = position,
        onClick = false,
        draw = draw,
        data = {colour = colour or theme.textColour, str = str},
    }
    return element
end

return errorMessage