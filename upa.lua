local comp = require("component")
local gpu = comp.gpu



local ENABLED = 1
local READY = 2
local OFF = 3
local NO_SIGNAL = 4

local ENABLED_COLOUR = 0x00ff00
local READY_COLOUR = 0x00A6FF
local OFF_COLOUR = 0xff0000
local NO_SIGNAL_COLOUR = 0x222222

local towerCount = 3
local columnCount = 6
local floorCount = 16

local columns = {
    "NONE",
    "NONE",
    "NONE",
    "NONE",
    "NONE",
    "NONE",
    "NONE",
    "8de216b8-c831-481e-b576-afb28aa29eb9",
    "09792043-9ed2-4435-a4fc-e97ce13f8835",
    "NONE",
    "NONE",
    "NONE",
    "NONE",
    "NONE",
    "NONE",
    "NONE",
    "NONE",
    "NONE"
}

local states = {}

for x = 1, 18 do
    states[x] = {}
    for y = 1, 16 do
        states[x][y] = 0
    end
end

local receivers = {}
for i = 1, 18 do
    receivers[i] = comp.proxy(columns[i])
end

local enabledMachines = 0
local readyMachines = 0
local totalMachines = 0
local notFound = 0

function updateRedstone()

    enabledMachines = 0
    readyMachines = 0
    totalMachines = 0
    notFound = 0

    for x = 1, 18 do
        receiver = receivers[x]
        if receiver ~= nil then
            local columnStates = receiver.getBundledInput(1)
            for y = 1, 16 do
               
                if columnStates[y-1] > 0 then --If machine is enabled
                    states[x][y] = 30
                elseif states[x][y] ~= 0 then -- Decaying state for machines
                    states[x][y] = math.max(states[x][y] - 1, 1)
                end

                if states[x][y] > 20 then
                    enabledMachines = enabledMachines + 1
                    totalMachines = totalMachines + 1
                elseif states[x][y] > 0 then
                    readyMachines = readyMachines + 1
                    totalMachines = totalMachines + 1
                end

            end
        end
    end
end

gpu.setResolution(89, 35)
gpu.fill(1, 1, 91, 34, " ")

function machine(tower, column, floor)
    local state = states[tower * 6 + column][floor]
    if state == ENABLED then
        gpu.setForeground(ENABLED_COLOUR)
    elseif state == READY then
        gpu.setForeground(READY_COLOUR)
    elseif state == OFF then
        gpu.setForeground(OFF_COLOUR)
    else
        gpu.setForeground(NO_SIGNAL_COLOUR)
    end

    local utilization = enabledMachines / totalMachines

    --State heuristics
    -- If the machine is actively running -> ENABLED
    -- If the machine was running in the last 10 seconds -> ENABLED
    if state > 27 then
        gpu.setForeground(ENABLED_COLOUR)

    -- If the machine was running in the last 30 seconds and more than 50% of the machines
    -- are running -> READY
    elseif utilization > 0.5 and state > 1 then
        gpu.setForeground(READY_COLOUR)

    -- If the machine hasn't been running in the last 30 seconds and more than 75% of the
    -- machines are running -> OFF (Broken state)
    elseif utilization > 0.75 and state == 1 then

        gpu.setForeground(OFF_COLOUR)

    -- If the machine hasn't received any signal ever -> NO_SIGNAL
    else
        if state == 0 then
            gpu.setForeground(NO_SIGNAL_COLOUR)
        else
            gpu.setForeground(READY_COLOUR)
        end
    end
    gpu.fill(1 + tower*30 + column * 4, 1 + floor * 2, 2, 1, "█")
end

function updateMachines()
    updateRedstone()
    for t = 0, towerCount-1 do
        for c = 1, columnCount do
            for f = 1, floorCount do
                machine(t, c, f)
            end
        end
    end
end

while true do
    updateMachines()
    os.sleep(1)
end