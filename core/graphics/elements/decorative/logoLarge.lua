local component = require("component") local gpu = component.gpu

---@param position Coordinate2D
function singleLineText(position)
    
    local logo1 = {
        "█◣  █  ◢  ███◣   ◢█◣  ◢███◣",
        "█◥◣ █  █  █  ◥◣ ◢◤ ◥◣ █   ",
        "█ ◥◣█  █  █   █ █   █ █    ",
        "█  ◥█  █  █   █ █▃▃▃█ ◥███◣",
        "█   █  █  █   █ █   █     █",
        "█   █  █  █  ◢◤ █   █     █",
        "█   █  ◤  ███◤  █   █ ◢███◤"
    }
    local logo2 ={
        " ◢█◣ ",
        "◢◤ ◥◣",
        "█   █",
        "█▃▃▃█",
        "█   █",
        "█   █",
        "█   █"
    }

    local function draw(window, element)
        gpu.setForeground(theme.primaryColour)
        for i, line in ipairs(logo1) do
            gpu.set(1, i, line)
        end
        gpu.setForeground(theme.accentColour)
        for i, line in ipairs(logo2) do
            gpu.set(17, i, line)
        end
    end

    local element = {
        size = {x=27, y=7},
        position = position,
        onClick = false,
        draw = draw,
        data = {},
    }
    return element
end

return singleLineText