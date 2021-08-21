-- Iport section

local graphics = require("lib.graphics.graphics")
local renderer = require("lib.graphics.renderer")
local gui = require("lib.graphics.gui")

--

local function setConfigure(server)
    local selectedMachineAddress = "None"
    local currentConfigWindow = {}
    local function configure(x, y, page)
        graphics.context().gpu.setActiveBuffer(page)

        graphics.text(3, 11, "Machine:")
        local function changeMachine(machineAddress)
            selectedMachineAddress = machineAddress
            renderer.removeObject(currentConfigWindow)
            configure(x, y, page)
        end
        local function refreshAndOpenSelectionBox()
            local onActivation = {}
            for address, machine in pairs(server.knownMachines or {}) do
                table.insert(
                    onActivation,
                    {displayName = machine.name or address, value = changeMachine, args = {address}}
                )
            end
            gui.selectionBox(x + 15, y + 5, onActivation)
        end
        table.insert(
            currentConfigWindow,
            gui.smallButton(x + 10, y + 5, selectedMachineAddress, refreshAndOpenSelectionBox)
        )

        local _, ySize = graphics.context().gpu.getBufferSize(page)
        table.insert(currentConfigWindow, gui.bigButton(x + 2, y + tonumber(ySize) - 4, "Save Configuration", server.save))
        local attributeChangeList = {
            {name = "Main Server", attribute = "isMain", type = "boolean", defaultValue = false},
            {
                name = "Power Capacitor",
                attribute = "powerAddress",
                type = "component",
                defaultValue = "None",
                componentType = "gt_machine",
                nameTable = server.statuses.multiblocks
            }
        }
        gui.multiAttributeList(x + 3, y + 1, page, currentConfigWindow, attributeChangeList, server.serverData)

        if selectedMachineAddress ~= "None" then
            attributeChangeList = {
                {name = "Machine Name", attribute = "name", type = "string", defaultValue = nil}
            }
            gui.multiAttributeList(
                x + 3,
                y + 7,
                page,
                currentConfigWindow,
                attributeChangeList,
                server.knownMachines,
                selectedMachineAddress
            )
        end

        renderer.update()
        return currentConfigWindow
    end
    return configure
end

return setConfigure
