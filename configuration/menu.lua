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
    {"HUD", "hud"},
    {"Primary Server", "server"},
    {"Power Control", "modules.tools.powerControl"}
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

local function activate(module, args)
    if module == "server" or module == "local" then --Server or primary process is always #1
        table.insert(processes, 1, {func = require(module), args = args, returnValue = nil})
    else
        table.insert(processes, {func = require(module), args = args, returnValue = nil})
    end
end


local serverData = nil
local function main()
    serverData = processes[1].func()
    for i = 2, #processes do
        local p = processes[i]
        if p.args == nil then
            processes[i].returnValue = p.func(serverData)
        else
            processes[i].returnValue = p.func(serverData, p.args[1], p.args[2], p.args[3], p.args[4], p.args[5])
        end
    end
    os.sleep()
end

local function generateMenu()
    load()
    activate("server")
    activate("hud")
    activate("modules.tools.powerControl", {component.redstone.address})
    while true do
        main()
    end
end

return generateMenu