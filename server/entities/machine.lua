-- Import section

local status = require("status")

--

local machine = {
    name = "",
    workAllowed = false,
    storedEU = 0,
    active = false,
    inputAverage = 0,
    outputAverage = 0,
    outputVoltage = 0,
    outputAmperage = 0,
    EUCapacity = 0,
    workProgress = 0,
    workMaxProgress = 0,
    isBroken = false,
    address = "",
    status = status
}

function machine.setWorkAllowed(allow, machine)
end

function machine:isWorkAllowed()
end

function machine:getAverageElectricInput()
end

function machine.getOwnerName()
end

function machine:getEUStored()
end

function machine.getWorkMaxProgress()
end

function machine:getSensorInformation()
end

function machine:getEUOutputAverage()
end

function machine:getEUInputAverage()
end

function machine:getStoredEU()
end

function machine.isMachineActive()
end

function machine.getOutputVoltage()
end

function machine.getAverageElectricOutput()
end

function machine:hasWork()
end

function machine.getOutputAmperage()
end

function machine:getEUCapacity()
end

function machine.getWorkProgress()
end

function machine:getEUMaxStored()
end

function machine:getEfficiencyPercentage()
end

function machine.getBatteryCharge(slot)
end

function machine.getMaxBatteryCharge(slot)
end

return machine
