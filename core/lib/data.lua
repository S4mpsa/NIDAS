local serialization = require("serialization")

local data = {}


---Saves a table to file
---@param name string
---@param dataToWrite table
function data.save(name, dataToWrite)
    local file = io.open(settings.dataFolder .. name, "w")
    if file then
        file:write(serialization.serialize(dataToWrite))
        file:close()
    else
        error("Opening " .. settings.dataFolder .. name .. " failed.")
    end
end

---Loads a saved table from file
---@param name string
function data.load(name)
    local file = io.open(settings.dataFolder .. name, "r")
    if file then
        local dataRead = serialization.unserialize(file:read("*a"))
        file:close()
        return dataRead
    else
        return nil
    end
end

return data