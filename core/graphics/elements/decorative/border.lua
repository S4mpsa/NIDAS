local component = require("component") local gpu = component.gpu

function border(colour)
    
    local function draw(window, element)
        gpu.setForeground(element.data.colour)
        local top = "┍"
        local edges = "│"
        local bottom = "╰"
        for i = 1, window.size.x - 2 do
            top = top.."━"
            bottom = bottom.."─"
        end
        for i = 1, window.size.y - 3 do
            edges = edges.."│"
        end
        top = top.."┑"
        bottom = bottom.."╯"
        gpu.set(1, 1, top)
        gpu.set(1, 2, edges, true)
        gpu.set(window.size.x, 2, edges, true)
        gpu.set(1, window.size.y, bottom)
    end

    local element = {
        size = {x=0, y=0},
        position = {x=0, y=0},
        onClick = false,
        draw = draw,
        data = {colour = colour or theme.borderColour}
    }
    return element
end

return border