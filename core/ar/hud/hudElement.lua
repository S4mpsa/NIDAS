---Repository for graphical hudElements
local component = require("component")
local gpu = component.gpu
local filesystem = require("filesystem")

local hudElements = {}
----------------------------------------------------------------------

hudElements.rectangle = require("core.ar.hud.elements.decorative.rectangle")
hudElements.windowBorder = require("core.ar.hud.elements.decorative.windowBorder")
hudElements.text = require("core.ar.hud.elements.decorative.text")

hudElements.simpleButton = require("core.ar.hud.elements.functional.simpleButton")
hudElements.variableText = require("core.ar.hud.elements.functional.variableText")
hudElements.periodic = require("core.ar.hud.elements.functional.periodic")
hudElements.contextMenu = require("core.ar.hud.elements.functional.contextMenu")

--The following enables automatic element requires: Code autocompletion requires static requires.
local folders = {"decorative", "functional"}

for _, folder in ipairs(folders) do
    local nextElement = filesystem.list("/home/NIDAS/core/ar/hud/elements/" .. folder .. "/")
    local element = nextElement()
    while element do
        element = string.sub(element, 1, #element - 4)
        if hudElements[element] == nil then
            hudElements[element] = require("core.ar.hud.elements." .. folder .. "." .. element)
        end
        element = nextElement()
    end
end
----------------------------------------------------------------------

---Glass methods
--addCube3D()
--addFloatingText()
--address()
--addTriangle3D()
--addQuad()
--addTextLabel()
--slot()
--addQuad3D()
--getObjectCount()
--addRect()
--addItem()
--getBindPlayers()
--type()
--newUniqueKey()
--removeObject()
--addDot()
--addDot3D()
--addTriangle()
--removeAll()
--addLine3D()


return hudElements