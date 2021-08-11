package.path = package.path.."/NIDAS/server/?.lua;/home/NIDAS/?.lua;/home/NIDAS/?/init.lua"

local gui = require("lib.graphics.gui")
local graphics = require("lib.graphics.graphics")
local renderer = require("lib.graphics.renderer")
local serialization = require("serialization")

require("component").gpu.setResolution(125, 35)
graphics.setContext()

local maxWidth = graphics.context().width
local maxheight = graphics.context().height
local selectionBoxWidth = 20
local location = {x = 2, y = 1}
local configurationData = {}

local modules = {
    {name = "HUD",              module = "hud", desc = "Overlays a HUD on your screen."},
    {name = "Primary Server",   module = "server", desc = "Updates all data and handles communication between other servers."},
    {name = "Power Control",    module = "modules.tools.powerControl", desc = "Emits redstone when power levels are below a certain amount."}
}
local processes = {}

local moduleSelectorVar = nil
local moduleDeSelectorVar = nil

local function save()
    configurationData.modules = {}
    configurationData.processes = {}
    for i = 1, #modules do
        table.insert(configurationData.modules, {name = modules[i].name, module = modules[i].module, desc = modules[i].desc})
    end
    for i = 1, #processes do
        table.insert(configurationData.processes, {name = processes[i].name, module = processes[i].module, desc = processes[i].desc})
    end
    local file = io.open("/home/NIDAS/settings/enabledModules", "w")
    file:write(serialization.serialize(configurationData))
    file:close()
end

local function activate(module, displayName, desc)
    displayName = displayName or module
    if module == "server" or module == "local" then --Server or primary process is always #1
        table.insert(processes, 1, {func = require(module), returnValue = nil, name = displayName, module = module, desc = desc})
    else
        table.insert(processes, {func = require(module), returnValue = nil, name = displayName, module = module, desc = desc})
    end
    local found = 0
    for i = 1, #modules do
        if modules[i].module == module then
            found= i
        end
    end
    if found ~= 0 then table.remove(modules, found) end
    moduleSelectorVar(location.x, location.y, selectionBoxWidth, maxheight-5)
    moduleDeSelectorVar(location.x+selectionBoxWidth+1, location.y, selectionBoxWidth, maxheight-5)
    renderer.update()
end

local function deactivate(module)
    local found = 0
    for i = 1, #processes do
        if processes[i].module == module then
            table.insert(modules, {name = processes[i].name, module = processes[i].module, desc = processes[i].desc})
            found = i
        end
    end
    if found ~= 0 then
        table.remove(processes, found)
    end
    moduleSelectorVar(location.x, location.y, selectionBoxWidth, maxheight-5)
    moduleDeSelectorVar(location.x+selectionBoxWidth+1, location.y, selectionBoxWidth, maxheight-5)
    renderer.update()
end

local function load()
    local file = io.open("/home/NIDAS/settings/enabledModules", "r")
    if file ~= nil then
        configurationData = serialization.unserialize(file:read("*a"))
        if configurationData ~= nil then
            for i = 1, #configurationData.processes do
                activate(configurationData.processes[i].module, configurationData.processes[i].name, configurationData.processes[i].desc)
            end
        else
            configurationData = {}
        end
        file:close()
    end
end

local currentTab = nil
local function flush()
    if currentTab ~= nil then
        renderer.removeObject(currentTab)
    end
    currentTab = nil
end

--Modules for configuring start here
local function infoScreen(x, y, width, height, text, title)
    flush()
    currentTab = gui.wrappedTextBox(x, y, width, height, text, title)
    renderer.update()
end

local function configScreen(x, y, width, height, title, data)
    flush()
    currentTab = gui.configMenu(x, y, width, height, title, data)
    graphics.context().gpu.setActiveBuffer(currentTab)
    local configurationTab = data.configure(x, y, gui, graphics, renderer, currentTab)
    currentTab = {currentTab}
    if configurationTab ~= nil then for i = 1, #configurationTab do table.insert(currentTab, configurationTab[i]) end end
end

local selector = nil
local function moduleSelector(x, y, width, height)
    if selector ~= nil then
        renderer.removeObject(selector)
    end
    local buttons = {}
    for i = 1, #modules do
        local onActivation =
        {
            {displayName = "Activate",
            value = activate,
            args = {modules[i].module, modules[i].name, modules[i].desc}},
            {displayName = "Info",
            value = infoScreen,
            args = {location.x+2*selectionBoxWidth+2, location.y, maxWidth-(location.x+2*selectionBoxWidth+2), maxheight-5, modules[i].desc, modules[i].name}},
            {displayName = "Configure",
            value = configScreen,
            args = {location.x+2*selectionBoxWidth+2, location.y, maxWidth-(location.x+2*selectionBoxWidth+2), maxheight-5, modules[i].name, require(modules[i].module)}}
        }
        table.insert(buttons, {name = modules[i].name, desc = modules[i].desc, func = gui.selectionBox, args = {x+width/2, y+i, onActivation}})
    end
    selector = gui.multiButtonList(x, y, buttons, width, height, "Available ".."("..math.floor(#buttons)..")")
end
moduleSelectorVar = moduleSelector

local deSelector = nil
local function moduleDeSelector(x, y, width, height)
    if deSelector ~= nil then renderer.removeObject(deSelector) end
    local buttons = {}
    for i = 1, #processes do
        local onActivation =
        {
            {displayName = "Deactivate",
            value = deactivate,
            args = {processes[i].module, processes[i].name, processes[i].desc}},
            {displayName = "Info",
            value = infoScreen,
            args = {location.x+2*selectionBoxWidth+2, location.y, maxWidth-(location.x+2*selectionBoxWidth+2), maxheight-5, processes[i].desc, processes[i].name}},
            {displayName = "Configure",
            value = configScreen,
            args = {location.x+2*selectionBoxWidth+2, location.y, maxWidth-(location.x+2*selectionBoxWidth+2), maxheight-5, processes[i].name, require(processes[i].module)}}
        }
        table.insert(buttons, {name = processes[i].name, func = gui.selectionBox, args = {x+width/2, y+i, onActivation}})
    end
    deSelector = gui.multiButtonList(x, y, buttons, width, height, "Active ".."("..math.floor(#buttons)..")")
end
moduleDeSelectorVar = moduleDeSelector

local running = false
local serverData = nil

local function switch()
    running = not running
end

local function reboot()
    require("computer").shutdown(true)
end

local function generateMenu()
    moduleSelector(location.x, location.y, selectionBoxWidth, maxheight-5)
    moduleDeSelector(location.x+selectionBoxWidth+1, location.y, selectionBoxWidth, maxheight-5)
    gui.bigButton(location.x, location.y+maxheight-5, "Run", switch)
    gui.bigButton(location.x+5, location.y+maxheight-5, "Save", save)
    gui.bigButton(location.x+11, location.y+maxheight-5, "Reboot", reboot)
    gui.smallLogo(maxWidth-20, maxheight-4)
    renderer.update()
end

local function main()
    if #processes > 0 and running then
        serverData = processes[1].func.update()
        for i = 2, #processes do
            local p = processes[i]
            if p.args == nil then
                processes[i].returnValue = p.func.update(serverData)
            else
                processes[i].returnValue = p.func.update(serverData, table.unpack(p.args))
            end
        end
    end
    os.sleep()
end

local function update()
    load()
    generateMenu()
    while true do
        main()
    end
end

return update