local gpu = require('component').gpu

local split = require('core.lib.stringUtils').split

---@param pos Coordinates
---@param size Coordinates
---@param text string
local function textBox(pos, size, text)
    local words = split(text)
    local lineWidth = 0
    local line = 0
    for _, word in ipairs(words) do
        if line > size.y then
            return
        elseif lineWidth + #word <= size.x then
            gpu.set(pos.x + lineWidth, pos.y + line, word)
            lineWidth = lineWidth + #word + 1
        else
            lineWidth = 0
            line = line + 1
            if lineWidth + #word <= size.x then
                gpu.set(pos.x + lineWidth, pos.y + line, word)
                lineWidth = lineWidth + #word + 1
            end
        end
    end
end

return textBox
