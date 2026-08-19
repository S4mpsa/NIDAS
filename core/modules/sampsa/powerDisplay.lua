local component = require("component") local gpu = component.gpu
local data      = require("core.lib.data")
local numUtils  = require("core.lib.numUtils")

local stringUtils = require("core.lib.stringUtils")

function powerDisplayModule(moduleWindow, player)

    player = player or "Sampsa_"
    
    if moduleWindow == nil then
        nidasError("Must provide module window!")
    end


    local Module

    --Private methods
    local function addStatic(element)
        table.insert(Module.data.elements.static, element)
        Module.data.window.addElement(element)
        return element
    end
    local function addElement(name, element)
        Module.data.elements.dynamic[name] = element
        Module.data.window.addElement(element)
        return element
    end

    local function selectSource(x, y)
        local res = glassManager.getResolution(Module.config.player)
        local choices = {}
        for address, _ in pairs(componentManager.list()) do
            local function setAddress()
                Module.config.source = address
                Module.save()
            end
            choices[string.sub(address, 1, 8)] = setAddress
        end

        local selectionWindow = glassManager.create(Module.config.player, "Selection Surface", {x=res.x, y=res.y}, {x=0, y=0})
        selectionWindow.options.closeOnFocusLoss = false
        local menu = hudElements.contextMenu(choices, {x=x, y=y})
        selectionWindow.addElement(menu)
        glassManager.render(selectionWindow)
    end

    --Common methods
    local function init()
        --Sets up the module, called on boot.
        local window = Module.data.window
        local size = {x=window.size.x, y=window.size.y}
        local res = glassManager.getResolution(Module.config.player)
       
        local taper = 0
        local barSize = size.y - 30
        --Static elements
        addStatic(hudElements.diagonal({x=0, y=0}, {x=size.x - taper*(barSize - 10), y=2}, theme.background, 0.1, {0, taper}))
        addStatic(hudElements.diagonal({x=0, y=2}, {x=size.x - taper*(barSize - 8), y=2}, theme.background, 0.2, {0, taper}))
        addStatic(hudElements.diagonal({x=0, y=4}, {x=size.x - taper*(barSize - 6), y=2}, theme.background, 0.3, {0, taper}))
        addStatic(hudElements.diagonal({x=0, y=6}, {x=size.x - taper*(barSize - 4), y=2}, theme.background, 0.4, {0, taper}))
        addStatic(hudElements.diagonal({x=0, y=8}, {x=size.x - taper*(barSize - 2), y=2}, theme.background, 0.5, {0, taper}))
        -- Progress bar top/middle/bottom
        addStatic(hudElements.diagonal({x=0, y=10}, {x=size.x - (taper*barSize), y=3}, theme.borderColour, 1.0, {0, taper}))
        addStatic(hudElements.diagonal({x=0, y=13}, {x=size.x, y=barSize}, theme.background, 0.7, {0, 1}))
        addStatic(hudElements.diagonal({x=0, y=13 + barSize}, {x=size.x, y=3}, theme.borderColour, 1.0, {0, 0}))
        --Progress bar left/Right
        addStatic(hudElements.diagonal({x=0, y=13}, {x=barSize+2, y=barSize}, theme.borderColour, 1.0, {0, 1}))
        addStatic(hudElements.diagonal({x=size.x - (barSize + 6), y=13}, {x=barSize+6, y=barSize}, theme.borderColour, 1.0, {-1, taper}))

        -- Bottom section top/middle/bottom
        addStatic(hudElements.diagonal({x=0, y=16 + barSize}, {x=size.x, y=size.y - barSize - 16}, theme.background, 0.4, {0, 0}))
        addStatic(hudElements.diagonal({x=0, y=size.y - 3}, {x=size.x, y=3}, theme.borderColour, 1.0, {0, 0}))
        --Bottom section left/Right
        addStatic(hudElements.diagonal({x=0, y=16 + barSize}, {x=20, y=size.y - barSize - 18}, theme.borderColour, 1.0, {0, -1}))
        addStatic(hudElements.diagonal({x=size.x - 50, y=16 + barSize}, {x=50, y=size.y - barSize - 18}, theme.borderColour, 1.0, {1, 0}))

        local function getCurrentEU()
            local lsc = componentManager.data(Module.config.source)
            if lsc ~= nil then
                if lsc.currentCapacity ~= nil then
                    if Module.data.window.size.x < 250 then
                        return stringUtils.metricNumber(lsc.currentCapacity) .. " EU"
                    else
                        return stringUtils.splitNumber(lsc.currentCapacity) .. " EU"
                    end
                end
                return "ERROR: Invalid type"
            else
                return "Source not found"
            end
        end

        local function getMaxEU()
            local lsc = componentManager.data(Module.config.source)
            if lsc ~= nil then
                if lsc.currentCapacity ~= nil then
                    if Module.data.window.size.x < 250 then
                        return stringUtils.metricNumber(lsc.maxCapacity) .. " EU"
                    else 
                        return stringUtils.splitNumber(lsc.maxCapacity) .. " EU"
                    end
                end
            end
            return ""
        end

        local function getPercentEU()
            local lsc = componentManager.data(Module.config.source)
            if lsc ~= nil then
                if lsc.currentCapacity ~= nil then
                    return stringUtils.percentage(math.min(1.0, lsc.currentCapacity / lsc.maxCapacity)) .. " EU"
                end
            end
            return ""
        end

        local function getPercentage()
            local lsc = componentManager.data(Module.config.source)
            if lsc ~= nil then
                if lsc.maxCapacity ~= nil then
                    return math.min(1.0, lsc.currentCapacity / lsc.maxCapacity)
                end
            end
            return 0.0
        end

        local function getTimeToFull()
            local lsc = componentManager.data(Module.config.source)
            if lsc ~= nil then
                if lsc.timeToCap ~= nil then
                    return string.sub(lsc.timeToCap, 9)
                end
            end
            return ""
        end

        local function getInputOutput()
            local lsc = componentManager.data(Module.config.source)
            local textElement = Module.data.elements.dynamic["InputOutput"]
            if lsc ~= nil then
                if lsc.averageInShort ~= nil then
                    local delta = math.floor(lsc.averageInShort - lsc.averageOutShort - lsc.passiveLoss)
                    if delta >= 0 then
                        if textElement ~= nil then
                            textElement.data.widgets["text"].setColor(numUtils.toRGB(colours.lime))
                        end
                        return "+" .. stringUtils.splitNumber(delta) .. " EU/t"
                    else
                        if textElement ~= nil then
                            textElement.data.widgets["text"].setColor(numUtils.toRGB(colours.red))
                        end
                        return stringUtils.splitNumber(delta) .. " EU/t"
                    end
                end
            end
            return ""
        end

        local function getAverageInput()
            local lsc = componentManager.data(Module.config.source)
            if lsc ~= nil then
                if lsc.averageInLong ~= nil then
                    return "+" .. stringUtils.metricNumber(lsc.averageInLong) .. " EU/t"
                end
            end
            return ""
        end

        local function getAverageOutput()
            local lsc = componentManager.data(Module.config.source)
            if lsc ~= nil then
                if lsc.averageOutLong ~= nil then
                    local delta = lsc.averageOutLong + lsc.passiveLoss
                    return "-" .. stringUtils.metricNumber(delta) .. " EU/t"
                end
            end
            return ""
        end

        -- Approximation of text length
        --setPosition(x+w-30-(4.5*#parser.splitNumber(maxEU)), y-9) 

        --Text elements
        addElement("CurrentEU", hudElements.variableText({x=1, y=1}, getCurrentEU, 1.0, theme.primaryColour, 1.0, 4))
        addElement("MaxEU", hudElements.variableText({x=size.x - 1, y=1}, getMaxEU, 1.0, theme.accentColour, 1.0, 4, 1))
        addElement("PercentEU", hudElements.variableText({x=size.x * 0.5, y=1}, getPercentEU, 1.0, theme.accentColour, 1.0, 4, 0))
        addElement("ProgressBar", hudElements.progressBar({x=2, y=13}, {x=size.x-(2), y=barSize}, theme.primaryColour, 1.0, {-1, 1}, getPercentage))
        if size.x < 250 then
            addElement("TimeToFull", hudElements.variableText({x=size.x * 0.5, y=9 + barSize * 0.5}, getTimeToFull, 0.7, theme.accentColour, 0.7, 4, 0))
        else
            addElement("TimeToFull", hudElements.variableText({x=21, y=18 + barSize}, getTimeToFull, 0.7, theme.accentColour, 0.7, 4))
        end
        addElement("InputOutput", hudElements.variableText({x=size.x * 0.5 - 1, y=17 + barSize}, getInputOutput, 1.0, colours.green, 1.0, 4, 0))
        addElement("AverageInput", hudElements.variableText({x=size.x - 50 + 12, y=17 + barSize}, getAverageInput, 0.5, theme.primaryColour, 1.0, 4, -1))
        addElement("AverageOutput", hudElements.variableText({x=size.x - 50 + 7, y=22 + barSize}, getAverageOutput, 0.5, theme.accentColour, 1.0, 4, -1))

        local foreGround = addStatic(hudElements.rectangle({x=0, y=0}, {x=size.x, y=size.y}, theme.background, 0.0))

        foreGround.onClickRight = function (window2, element2, eventName2, address2, x2, y2, button2, name2)
            local contextWindow = glassManager.create("Sampsa_", "Context Surface", {x=res.x, y=res.y}, {x=0, y=0})
            contextWindow.options.closeOnFocusLoss = false
            local menu = hudElements.contextMenu({
                ["Remove module"] = Module.remove,
                ["Select source"] = selectSource
            }, {x=x2, y=y2})
            contextWindow.addElement(menu)
            glassManager.render(contextWindow)
            return true
        end

        glassManager.render(window)
    end

    local function remove()
        -- Removes the module. Should clean up all elements it was using, including the window.

        moduleManager.detach(Module)
        Module.data.window.remove()
    end

    local function update(tick)
        --Processes the module logic, called by the main thread once per tick.
        for _, element in pairs(Module.data.elements.dynamic) do
            element.update(tick)
        end
    end
    local function save()
        --Save the module configuration to a file.
        data.save("PowerDisplay_" .. Module.config.player, Module.config)
    end
    local function load()
        --Load the saved lsc.
        Module.config = data.load("PowerDisplay_" .. Module.config.player)
    end

    Module = {
        init = init,
        remove = remove,
        update = update,
        save = save,
        load = load,
        config = {
            player = player,
            source = nil
        },
        data = {
            window = moduleWindow,
            elements = {
                static = {},
                dynamic = {}
            }
        }
    }

    return Module
end

return powerDisplayModule