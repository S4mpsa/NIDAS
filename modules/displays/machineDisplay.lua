local component = require("component")
local serialization = require("serialization")
local states         = require("server.entities.states")
local machineDisplay = {}

local gui = require("lib.graphics.gui")
local graphics = require("lib.graphics.graphics")
local renderer = require("lib.graphics.renderer")

local machineList = {}

local function save()
    local file = io.open("/home/NIDAS/settings/machineDisplayData", "w")
    local temp = {}
    for i = 1, #machineList do
        temp[i] = machineList[i].update
        machineList[i].update = nil
    end
    file:write(serialization.serialize(machineList))
    file:close()
    for i = 1, #machineList do
        machineList[i].update = temp[i]
    end
end
local machineConstructor = nil
local function load()
    local file = io.open("/home/NIDAS/settings/machineDisplayData", "r")
    if file then
        local machinesToAdd = serialization.unserialize(file:read("*a")) or {}
        for i = 1, #machinesToAdd do
            local data = machinesToAdd[i]
            local setAddress = machineConstructor(data.x, data.y, true)
            setAddress(data.address, true)
        end
        file:close()
        renderer.update()
    end
end

local inView = false

local function gridAlignedX()
    return 1 + 21 * math.floor((renderer.getX() - 1) / 21)
end

local function gridAlignedY()
    return 1 + 3 * math.floor((renderer.getY() - 1) / 3)
end

local function genericMachine(savedX, savedY, skipRendering)
    local context = graphics.context()
    local border = gui.borderColor()
    local emptyBar = 0x111111
    local accent = gui.accentColor()
    local progress = gui.primaryColor()
    local gpu = context.gpu
    local xLoc = savedX or gridAlignedX()
    local yLoc = savedY or gridAlignedY()
    local page = renderer.createObject(xLoc, yLoc, 21, 3, true)
    gpu.setActiveBuffer(page)
    --Initialization
    local function reset(x, y, skipProgress)
        graphics.text(x, y*2+1, "│          ╭───", emptyBar)
        graphics.text(x, y*2+3, "╰──────────╯", emptyBar)
        if not skipProgress then
            graphics.text(x+12, y*2+3, "---", progress)
            graphics.text(x+16, y*2+3, "---s", progress)
        end
    end

    --Borders
    graphics.text(1, 1, "┎╴╶────────────────╮", border)
    graphics.text(14, 1, "╶", border)
    graphics.text(16, 3, "┭───╯", border)
    graphics.text(16, 5, "┊", border)
    graphics.text(3, 1, "Set Address", accent)
    reset(1, 1)

    local function fillBar(x, y, percentage)
        local function between(p, min, max) return (p > min and p < max) end
        local function fill(row, chars) graphics.text(x, (y*2)+(2*row)-1, chars, progress) end
        if between(percentage, 0, 13/17) then fill(1, "│") end
        if between(percentage, 1/17, 2/17) then fill(2, "╰") end
        if between(percentage, 2/17, 3/17) then fill(2, "╰─") end
        if between(percentage, 3/17, 4/17) then fill(2, "╰──") end
        if between(percentage, 4/17, 5/17) then fill(2, "╰───") end
        if between(percentage, 5/17, 6/17) then fill(2, "╰────") end
        if between(percentage, 6/17, 7/17) then fill(2, "╰─────") end
        if between(percentage, 7/17, 8/17) then fill(2, "╰──────") end
        if between(percentage, 8/17, 9/17) then fill(2, "╰───────") end
        if between(percentage, 9/17, 10/17) then fill(2, "╰────────") end
        if between(percentage, 10/17, 11/17) then fill(2, "╰─────────") end
        if between(percentage, 11/17, 12/17) then fill(2, "╰──────────") end
        if between(percentage, 12/17, 13/17) then fill(2, "╰──────────╯") end
        if between(percentage, 13/17, 14/17) then fill(1, "│          ╭") end
        if between(percentage, 14/17, 15/17) then fill(1, "│          ╭─") end
        if between(percentage, 15/17, 16/17) then fill(1, "│          ╭──") end
        if between(percentage, 16/17, 17/17) then fill(1, "│          ╭───") end
    end
    local function update(x, y, data)
        if data.state.name == states.ON.name or data.state.name == states.BROKEN.name then
            local currentProgress = data.progress
            local maxProgress = data.maxProgress
            local percentage = currentProgress / maxProgress
            fillBar(x, y, percentage)

            local currentString = ""..tostring(math.floor(currentProgress/20))
            while #currentString < 3 do currentString = " "..currentString end
            graphics.text(x+12, y*2+3, currentString, progress)
            local maxString = tostring(math.ceil(maxProgress/20)).."s"
            while #maxString < 4 do maxString = maxString.." " end
            graphics.text(x+16, y*2+3, maxString, progress)
            if maxProgress - currentProgress <= 5 then reset(x, y, true) end
            if data.state.name == states.BROKEN.name then
                graphics.text(x+1, y*2+1, "Broken", accent)
            end
        elseif data.state.name == states.IDLE.name then
            reset(x, y)
        elseif data.state.name == states.OFF.name then
            reset(x, y)
            graphics.text(x+1, y*2+1, "Disabled", 0xFF0000)
        elseif data.state.name == states.MISSING.name then
            reset(x, y)
            graphics.text(x+1, y*2+1, "Not Found", 0xFF0000)
        end
    end
    local function delete()
        renderer.removeObject(page)
        graphics.clear()
        renderer.update()
        for i = 1, #machineList do
            local machine = machineList[i]
            if machine.x == xLoc and machine.y == yLoc then
                table.remove(machineList, i)
                save()
            end
        end
    end
    local function setMachine(savedAddress, skipSaving)
        local file = io.open("/home/NIDAS/settings/known-machines", "r")
        local knownMachines = {}
        if file then
            knownMachines = serialization.unserialize(file:read("*a")) or {}
            file:close()
        end
        local values = {}
        local duplicate
        for address, machine in pairs(knownMachines) do
            duplicate = false
            for _, v in pairs(machineList) do
                if address == v.address then
                    duplicate = true
                    break
                end
            end
            if not duplicate then
                table.insert(values,
                {displayName = machine.name,
                value = address,
                args = nil})
            end
        end
        local value = savedAddress or gui.selectionBox(xLoc, yLoc, values)
        if value then
            gpu.setActiveBuffer(page)
            local name = knownMachines[value].name
            graphics.text(1, 1, "┎╴╶────────────────╮", border)
            graphics.text(3, 1, name, accent)
            graphics.text(3+#name, 1, "╶", border)
            gpu.setActiveBuffer(0)
            renderer.update()
            table.insert(machineList, {address = value, x = xLoc, y = yLoc, update = update})
            if not skipSaving then save() end
        end
    end
    local onActivation = {
        {displayName = "Set Address",
        value = setMachine,
        args = {}},
        {displayName = "Remove",
        value = delete,
        args = {}}
    }
    renderer.setClickable(page, gui.selectionBox, {xLoc, yLoc, onActivation}, {xLoc, yLoc}, {xLoc+20, yLoc+3})
    gpu.setActiveBuffer(0)
    if not skipRendering then renderer.update() end
    return setMachine
end
machineConstructor = genericMachine

local function returnToMenu()
    inView = false
    renderer.switchWindow("main")
    renderer.clearWindow("machineDisplay")
    renderer.update()
end

local function displayView()
    inView = true
    local context = graphics.context()
    machineList = {}
    renderer.switchWindow("machineDisplay")
    gui.smallButton(1, (context.height), "< < < Return", returnToMenu, {}, nil, gui.primaryColor())
    local divider = renderer.createObject(1, context.height - 1, context.width, 1)
    context.gpu.setActiveBuffer(divider)
    local bar = ""
    for i = 1, context.width do bar = bar .. "▂" end
    graphics.text(1, 1, bar, gui.borderColor())
    context.gpu.setActiveBuffer(0)
    local onActivation = {
        {displayName = "Add Display",
        value = genericMachine,
        args = {}}
    }
    load()
    renderer.setClickable(divider, gui.selectionBox, {gridAlignedX, gridAlignedY, onActivation}, {1, 1}, {context.width, context.height-2}, true)
end

function machineDisplay.windowButton()
    return {name = "Machines", func = displayView}
end
--gui.bigButton(40, graphics.context().height-4, "Machines", displayView, _, _, true)

local currentConfigWindow = {}
function machineDisplay.configure(x, y, _, _, _, page)
    local renderingData = {x, y, gui, graphics, renderer, page}
    graphics.context().gpu.setActiveBuffer(page)
    renderer.update()
    return currentConfigWindow
end

function machineDisplay.update(data)
    if inView and data ~= nil then
        graphics.context().gpu.setActiveBuffer(0)
        for i = 1, #machineList do
            local machine = machineList[i]
            machine.update(machine.x, machine.y, data.multiblocks[machine.address])
        end
    end
end

return machineDisplay
