local component = require("component")
local event = require("event")

--Window manager is global

local elements = require("core.graphics.elements.element")
local worldElements = require("core.ar.world.worldElement")
local stringUtils = require("core.lib.stringUtils")

local machineProxy = require("core.network.data.multiblocks.getMachineProxy")

local machineDisplay = {}

local windowsOpened = 0

function machineDisplay.init()
    for address, values in pairs(componentManager.list()) do
        for glassAddress, _ in pairs(component.list("glasses")) do
            local glasses = component.proxy(glassAddress)
            local player = glasses.getBindPlayers()

            local machineObject = glassManager.createObject(player, "MachineDisplay", componentManager.list()[address].location)
            local cube = worldElements.cube({x=0, y=0, z=0}, theme.primaryColour, {alpha = 0.2, lookingAt = true, scale=1.05})
            machineObject.addElement(cube)

            local function showInformationBox(object, name, side)
                local machine = machineProxy(address, values.source)
                
                local function createDisplay()
                    local data = machine.getInfo()
                    local longestString = stringUtils.getLongestString(data)
                    local res = glassManager.getResolution("Sampsa_")
                    local hudWindow = glassManager.create("Sampsa_", "Machine Display (" .. tostring(windowsOpened) .. ")",
                                                        {x = 8 + longestString * 6, y=5 + #data * 11}, {x=res.x / 2 + 3, y=res.y / 2 + 3})
                    hudWindow.options.closeOnFocusLoss = true
                    windowsOpened = windowsOpened + 1
                    hudWindow.addElements({
                        hudElements.diagonalBorder(),
                        hudElements.periodic(machine.update, 4)
                    })
    
                    for i, _ in ipairs(data) do
                        local function getString()
                            return machine.getInfo()[i] or ""
                        end
                        hudWindow.addElement(hudElements.variableText({x = 6, y = -4 + i * 10}, getString, 0.8, 0xFFFFFF, 1.0, 10))
                    end
                    moduleManager.attach(hudWindow)
                    glassManager.render(hudWindow)
                end

                if machine and not machine.proxy then --Remote machine, wait until data arrives
                    local received = false
                    local function receiveData(_, remoteAddress)
                        if not received and remoteAddress == address then
                            received = true
                            createDisplay()
                            event.ignore("update_receiveD", receiveData)
                        end
                    end
                    event.listen("update_received", receiveData)
                else
                    createDisplay()
                end

            end

            machineObject.interact = showInformationBox
        end
    end
end

return machineDisplay