local component = require("component") local gpu = component.gpu

function exampleModule(position, str)

    local function init()
        --Sets up the module, called on boot.
    end
    local function update()
        --Processes the module logic, called by the main thread once per tick.
    end
    local function save()
        --Save the module.data to a file.
    end
    local function load()
        --Load the saved data.
    end


    local module = {
        init = init,
        update = update,
        save = save,
        load = load,
        data = {} --Data should have all the variables that are used by the module. It can be accessed from elsewhere by the return value.
    }

    return module
end

return exampleModule