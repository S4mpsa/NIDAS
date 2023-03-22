local component = require("component") local gpu = component.gpu

function title(name, colour)
    
    local function draw(window, element)
        gpu.setForeground(element.data.colour)
        local title = element.data.name or window.name
        if window.size.x - 2 >= #title then
            gpu.set(2, 1, title)
        elseif window.size.x >= 6 then
            gpu.set(2, 1,  (string.sub(title, 1, window.size.x - 6) .. "..."))
        end
    end

    local element = {
        size = {x=0, y=0},
        position = {x=0, y=0},
        onClick = false,
        draw = draw,
        data = {colour = colour or theme.primaryColour,
                name = name or nil},
    }
    return element
end

return title