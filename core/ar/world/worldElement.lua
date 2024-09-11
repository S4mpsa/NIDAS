---Repository for graphical hudElements
local component = require("component")
local gpu = component.gpu
local filesystem = require("filesystem")

local worldElements = {}
----------------------------------------------------------------------

worldElements.cube = require("core.ar.world.elements.decorative.cube")

--The following enables automatic element requires: Code autocompletion requires static requires.
local folders = {"decorative", "functional"}

for _, folder in ipairs(folders) do
    local nextElement = filesystem.list("/home/NIDAS/core/ar/world/elements/" .. folder .. "/")
    local element = nextElement()
    while element do
        element = string.sub(element, 1, #element - 4)
        if worldElements[element] == nil then
            worldElements[element] = require("core.ar.world.elements." .. folder .. "." .. element)
        end
        element = nextElement()
    end
end
----------------------------------------------------------------------

return worldElements