package.path = package.path.."/NIDAS/server/?.lua;/home/NIDAS/?.lua;/home/NIDAS/?/init.lua"

local gui = require("lib.graphics.gui")
local graphics = require("lib.graphics.graphics")
local component = require("component")
local colors = require("lib.graphics.colors")
local renderer = require("lib.graphics.renderer")
local serialization = require("serialization")
local shell = require("shell")
local testObject = {
    gpu = component.gpu,
    page = 0,
    width = 160,
    heigth = 50,
}
graphics.setContext(testObject)

local configurationData = {
    enabledModules = {}
}

local modules = {
    {name = "HUD", module = "hud", desc = "Test 1"},
    {name = "Primary Server", module = "server", desc = "Test 2"},
    {name = "Power Control", module = "modules.tools.powerControl", desc = "Test 3"}
}
local processes = {}
local function save()
    shell.setWorkingDirectory("/home/NIDAS/configuration")
    local file = io.open("enabledModules", "w")
    file:write(serialization.serialize(configurationData))
    file:close()
end

local function load()
    local file = io.open("enabledModules", "r")
    if file ~= nil then
        configurationData = serialization.unserialize(file:read("*a"))
        file:close()
    end
end

local moduleSelectorVar = nil
local moduleDeSelectorVar = nil

local function activate(module, displayName)
    displayName = displayName or module
    if module == "server" or module == "local" then --Server or primary process is always #1
        table.insert(processes, 1, {func = require(module), returnValue = nil, name = displayName, module = module})
    else
        table.insert(processes, {func = require(module), returnValue = nil, name = displayName, module = module})
    end
    local found = 0
    for i = 1, #modules do
        if modules[i].module == module then
            found= i
        end
    end
    if found ~= 0 then table.remove(modules, found) end
    moduleSelectorVar(25, 5, 25, 30)
    moduleDeSelectorVar(55, 5, 25, 30)
    renderer.update()
end

local function deactivate(module)
    local found = 0
    for i = 1, #processes do
        if processes[i].module == module then
            table.insert(modules, {name = processes[i].name, module = processes[i].module})
            found = i
        end
    end
    if found ~= 0 then
        table.remove(processes, found)
    end
    moduleSelectorVar(25, 5, 25, 30)
    moduleDeSelectorVar(55, 5, 25, 30)
    renderer.update()
end

local selector = nil
local function moduleSelector(x, y, width, heigth)
    if selector ~= nil then renderer.removeObject(selector) end
    local buttons = {}
    for i = 1, #modules do
        local onActivation =
        {
            {displayName = "Activate",
            value = activate,
            args = {modules[i].module, modules[i].name}},
            {displayName = "Info",
            value = activate,
            args = {modules[i].module, modules[i].name}}
        }
        table.insert(buttons, {name = modules[i].name, desc = modules[i].desc, func = gui.selectionBox, args = {x+width/2, y+i, onActivation}})
    end
    selector = gui.multiButtonList(x, y, buttons, width, heigth)
end
moduleSelectorVar = moduleSelector

local deSelector = nil
local function moduleDeSelector(x, y, width, heigth)
    if deSelector ~= nil then renderer.removeObject(deSelector) end
    local buttons = {}
    for i = 1, #processes do
        local onActivation =
        {
            {displayName = "Deactivate",
            value = deactivate,
            args = {processes[i].module, processes[i].name}},
            {displayName = "Info",
            value = deactivate,
            args = {processes[i].module, processes[i].name}}
        }
        table.insert(buttons, {name = processes[i].name, func = gui.selectionBox, args = {x+width/2, y+i, onActivation}})
    end
    deSelector = gui.multiButtonList(x, y, buttons, width, heigth)
end
moduleDeSelectorVar = moduleDeSelector

local serverData = nil
local function main()
    if #processes > 0 then
        serverData = processes[1].func()
        for i = 2, #processes do
            local p = processes[i]
            if p.args == nil then
                processes[i].returnValue = p.func(serverData)
            else
                processes[i].returnValue = p.func(serverData, table.unpack(p.args))
            end
        end
    end
    os.sleep()
end

local function generateMenu()
    load()
    moduleSelector(25, 5, 25, 30)
    moduleDeSelector(55, 5, 25, 30)
    --activate("hud")
    main()
    renderer.update()
end

return generateMenu