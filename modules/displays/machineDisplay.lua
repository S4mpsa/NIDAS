local component = require("component")
local serialization = require("serialization")
local states         = require("server.entities.states")
local machineDisplay = {}
local event = require("event")

local gui = require("lib.graphics.gui")
local graphics = require("lib.graphics.graphics")
local renderer = require("lib.graphics.renderer")
local colors = require("lib.graphics.colors")

local machineDisplayData = {}
local bufferPages = {}

local function save(data)
    local file = io.open("/home/NIDAS/settings/machineDisplayData", "w")
    file:write(serialization.serialize(machineDisplayData))
    file:close()
end

local function load()
    local file = io.open("/home/NIDAS/settings/machineDisplayData", "r")
    if file then
        machineDisplayData = serialization.unserialize(file:read("*a")) or {}
        file:close()
    end
end

local inView = false

local function gridAlignedX()
    return 2 + 21 * math.floor((renderer.getX() - 2) / 21)
end

local function gridAlignedY()
    return 2 + 3 * math.floor((renderer.getY() - 2) / 3)
end

local machineList = {}
local function genericMachine()
    local context = graphics.context()
    local border = gui.borderColor()
    local emptyBar = 0x111111
    local accent = gui.accentColor()
    local progress = gui.primaryColor()
    local gpu = context.gpu
    local page = renderer.createObject(gridAlignedX(), gridAlignedY(), 21, 3, true)
    gpu.setActiveBuffer(page)
    --Initialization
    local function reset()
        gpu.setActiveBuffer(page)
        graphics.text(1, 3, "│          ╭───", emptyBar)
        graphics.text(1, 5, "╰──────────╯", emptyBar)
        graphics.text(13, 5, "---", progress)
        graphics.text(17, 5, "---s", progress)
        gpu.setActiveBuffer(0)
    end

    --Borders
    graphics.text(1, 1, "┎╴╶────────────────╮", border)
    graphics.text(14, 1, "╶", border)
    graphics.text(16, 3, "┭───╯", border)
    graphics.text(16, 5, "┊", border)
    graphics.text(3, 1, "Set Address", accent)

    reset()
    local function fillBar(percentage)
        local function between(p, min, max) return (p > min and p < max) end
        local function fill(row, chars) graphics.text(1, 1+(2*row), chars, progress) end
        gpu.setActiveBuffer(page)
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
        local currentString = ""..current
        while #currentString ~= 3 do currentString = " "..currentString end
        text(x+12, y+4, currentString, progress)
        local maxString = max.."s"
        while #maxString ~= 4 do maxString = maxString.." " end
        text(x+16, y+4, maxString, progress)
        gpu.setActiveBuffer(0)
    end
    --Update loop
    local data = nil
    local function update()
        --percentage = current / max
        --fillBar(percentage)
        --if max - current <= 1 then reset() end
    end


    local function delete()
        renderer.removeObject(page)
        graphics.clear()
        renderer.update()
    end
    local function setMachine()
        local components = {}
        data = gui.com
    end
    local onActivation = {
        {displayName = "Set Address",
        value = setMachine,
        args = {1}},
        {displayName = "Remove",
        value = delete,
        args = {1}}
    }
    renderer.setClickable(page, gui.selectionBox, {gridAlignedX(), gridAlignedY(), onActivation}, {gridAlignedX(), gridAlignedY()}, {gridAlignedX()+20, gridAlignedY()+3})
    gpu.setActiveBuffer(0)
    renderer.update()
end

local function returnToMenu()
    inView = false
    renderer.switchWindow("main")
    renderer.clearWindow("machineDisplay")
    renderer.update()
end

local function displayView()
    inView = true
    local context = graphics.context()
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
        args = {renderer.getX, renderer.getY}}
    }
    renderer.setClickable(divider, gui.selectionBox, {gridAlignedX, gridAlignedY, onActivation}, {1, 1}, {context.width, context.height-2}, true)
    renderer.update()
end

gui.bigButton(40, graphics.context().height-4, "Machines", displayView, _, _, true)

local refresh = nil
local currentConfigWindow = {}
function machineDisplay.configure(x, y, _, _, _, page)
    local renderingData = {x, y, gui, graphics, renderer, page}
    graphics.context().gpu.setActiveBuffer(page)
    renderer.update()
    return currentConfigWindow
end
refresh = machineDisplay.configure

load()

function machineDisplay.update(data)
    if inView then
        
    end
end

return machineDisplay