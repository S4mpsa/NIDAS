local component = require("component") local gpu = component.gpu
local stringUtils = require("core.lib.stringUtils")

---@param position Coordinate2D
---@param size Coordinate2D
---@param str string
---@param colour? number
function multiLineText(position, size, str, colour)
    
    local function draw(window, element)
        local words = stringUtils.split(str, " ")
        local lines = {}
        local line = ""
        for i = 1, #words do
            if #line+#words[i] < element.size.x-3 then
                line = line .. " " .. words[i]
            else
                table.insert(lines, line)
                line = " "..words[i]
            end
        end
        if #line > 0 then
            table.insert(lines, line)
        end
        for i = 1, #lines do
            if i < element.size.y then
                gpu.set(1, i, lines[i])
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

return multiLineText