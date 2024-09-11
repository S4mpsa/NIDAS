local component = require("component") local gpu = component.gpu

local horizontalSteps = 4
local verticalSteps = 9

function hudConfigurator()
    local Module
    local gridEnabled = true
    local xThresholds = {}
    local yThresholds = {}
    local function init()
        --Sets up the module, called on boot.
        local res = glassManager.getResolution("Sampsa_")
        glassManager.setActivePlayer("Sampsa_")

        local gridLines = {}
        local grid = glassManager.create("Sampsa_", "HUD Grid", {x=res.x, y=res.y}, {x=0, y=0})
        grid.options.closeOnFocusLoss = false
        --Hotbar edges
        local div1 = res.x/2-91
        local div2 = res.x/2+91
        --Vertical lines
        local step = div1 / horizontalSteps
        for i=1, horizontalSteps, 1 do
            local line = hudElements.rectangle({x=step*i, y=0}, {x=1, y=res.y}, 0x222222, 0.4)
            table.insert(gridLines, line)
            table.insert(xThresholds, step*i)
        end
        for i=0, horizontalSteps, 1 do
            local line = hudElements.rectangle({x=div2 + step*i, y=0}, {x=1, y=res.y}, 0x222222, 0.4)
            table.insert(gridLines, line)
            table.insert(xThresholds, div2 + step*i)
        end
        --Horizontal lines
        step = res.y / verticalSteps
        for i=1, verticalSteps, 1 do
            local line = hudElements.rectangle({x=0, y=step * i}, {x=res.x, y=1}, 0x222222, 0.4)
            table.insert(gridLines, line)
            table.insert(yThresholds, step*i)
        end

        grid.addElements(gridLines)

        local surface = hudElements.rectangle({x=0, y=0}, {x=res.x, y=res.y}, 0xffffff, 0.0)

        surface.onClick = function (window, element, eventName, address, x, y, button, name)
            if eventName == "hud_click" then
                if Module.data.selectionWindow then
                    Module.data.selectionWindow.remove()
                    Module.data.selectionWindow = nil
                    Module.data.selection = nil
                end
                Module.data.selectionStart = {x=x, y=y}
            end
            return true
        end

        local function toggleGrid()
            if gridEnabled then
                grid.remove()
            else
                element.init()
            end
        end

        surface.onClickRight = function (window, element, eventName, address, x, y, button, name)
            local contextWindow = glassManager.create("Sampsa_", "Context Surface 2", {x=res.x, y=res.y}, {x=0, y=0})
            contextWindow.options.closeOnFocusLoss = false
            local menu = hudElements.contextMenu({
                ["Toggle grid"] = toggleGrid,
            }, {x=x, y=y})
            contextWindow.addElement(menu)
            glassManager.render(contextWindow)
            return true
        end

        surface.onDrag = function (window, element, eventName, address, x, y, button, name)
            if eventName == "hud_drag"then
                if Module.data.selection == nil then
                    Module.data.selection = {x=x, y=y, w=1, h=1}
                end

                Module.data.selection = {
                    x=math.min(x, Module.data.selectionStart.x),
                    y=math.min(y, Module.data.selectionStart.y),
                    w=math.abs(x - Module.data.selectionStart.x),
                    h=math.abs(y - Module.data.selectionStart.y)}

                if Module.data.selectionWindow then
                    Module.data.selectionWindow.remove()
                    Module.data.selectionWindow = nil
                end

                local selection = glassManager.create("Sampsa_", "Selection",
                    {x=Module.data.selection.w, y=Module.data.selection.h},
                    {x=Module.data.selection.x, y=Module.data.selection.y})
                selection.options.closeOnFocusLoss = false
                local selectionRect = hudElements.rectangle({x=0, y=0}, {x=Module.data.selection.w, y=Module.data.selection.h}, 0x777777, 0.5)
                selection.addElement(selectionRect)
                Module.data.selectionWindow = selection
                selectionRect.onClick = function() return false end
                selectionRect.onDrag = function() return false end

                local gridSelectionLeft = 0
                local gridSelectionRight = nil
                local gridSelectionTop = 0
                local gridSelectionBottom = nil
                for _, value in ipairs(xThresholds) do
                    if value < Module.data.selection.x then gridSelectionLeft = value end
                    if gridSelectionRight == nil then
                        if value > Module.data.selection.x + Module.data.selection.w then gridSelectionRight = value end
                    end
                end
                for _, value in ipairs(yThresholds) do
                    if value < Module.data.selection.y then gridSelectionTop = value end
                    if gridSelectionBottom == nil then
                        if value > Module.data.selection.y + Module.data.selection.h then gridSelectionBottom = value end
                    end
                end

                if Module.data.gridSelection ~= nil then
                    Module.data.gridSelection.remove()
                    Module.data.gridSelection = nil
                end
                local gridSelectionWindow = glassManager.create("Sampsa_", "Grid Selection",
                    {x=gridSelectionRight - gridSelectionLeft, y=gridSelectionBottom - gridSelectionTop}, {x=gridSelectionLeft, y=gridSelectionTop})
                gridSelectionWindow.options.closeOnFocusLoss = false

                local selectionWidth = gridSelectionRight - gridSelectionLeft
                local selectionHeight = gridSelectionBottom - gridSelectionTop
                local gridSelectionRect = hudElements.rectangle({x=1, y=1},{x=selectionWidth - 1, y=selectionHeight - 1}, theme.primaryColour, 0.2)
                Module.data.gridSelection = gridSelectionWindow
                gridSelectionRect.onClick = function() return false end
                gridSelectionRect.onDrag = function() return false end

                local function removeGridSelection()
                    if Module.data.gridSelection ~= nil then
                        Module.data.gridSelection.remove()
                        Module.data.gridSelection = nil
                    end
                end
                
                --Test module
                local function addModule()
                    local moduleWindow = glassManager.create("Sampsa_", "Module"..tostring(Module.data.moduleCount),
                        {x=selectionWidth, y=selectionHeight},
                        {x=gridSelectionLeft, y=gridSelectionTop})
                        moduleWindow.options.closeOnFocusLoss = false
                    local dummyModule = hudElements.rectangle({x=0, y=0}, {x=selectionWidth, y=selectionHeight}, theme.accentColour, 1.0)
                    moduleWindow.addElement(dummyModule)
                    Module.data.moduleCount = Module.data.moduleCount + 1
                    glassManager.render(moduleWindow)
                end

                gridSelectionRect.onClickRight = function (window2, element2, eventName2, address2, x2, y2, button2, name2)
                    local contextWindow = glassManager.create("Sampsa_", "Context Surface", {x=res.x, y=res.y}, {x=0, y=0})
                    contextWindow.options.closeOnFocusLoss = false
                    local menu = hudElements.contextMenu({
                        ["Remove selection"] = removeGridSelection,
                        ["Add module"] = addModule
                    }, {x=x2, y=y2})
                    contextWindow.addElement(menu)
                    glassManager.render(contextWindow)
                    return true
                end

                gridSelectionWindow.addElement(gridSelectionRect)
                glassManager.render(gridSelectionWindow)
                return true
            end
        end

        grid.addElement(surface)
        glassManager.render()
    end
    local function update()
        --Processes the Module logic, called by the main thread once per tick.
    end
    local function save()
        --Save the Module.data to a file.
    end
    local function load()
        --Load the saved data.
    end


    Module = {
        name = "HudConfigurator",
        init = init,
        update = update,
        save = save,
        load = load,
        data = {
            moduleCount = 0,
            selection = nil,
            selectionWindow = nil,
            selectionStart = nil,
            contextMenu = nil,
            gridSelection = nil}
    }

    return Module
end

return hudConfigurator