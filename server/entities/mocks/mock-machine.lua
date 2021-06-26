-- Import section

Machine = require("server.entities.machine")
Inherits = require("utils.inherits")
New = require("utils.new")

--

local mockMachine =
    Inherits(
    Machine,
    {
        mocks = {}
    }
)

function mockMachine:getMock(address, name)
    if not address then
        return nil
    end
    if not self.mocks[address] then
        self.mocks[address] = {
            name = name or "fake machine",
            workAllowed = true,
            storedEU = math.random(1608388608),
            active = true,
            inputAverage = math.random(16000),
            outputAverage = math.random(16000),
            outputVoltage = 0,
            outputAmperage = 1,
            EUCapacity = 1608388608,
            workProgress = 0,
            workMaxProgress = 0,
            isBroken = false,
            address = address
        }
    end
    return self.mocks[address]
end

function mockMachine:setWorkAllowed(allow)
    local mock = self:getMock(self.address, self.name)
    if mock.isBroken then
        mock.isBroken = false
    end
    mock.workAllowed = allow
end

function mockMachine:isWorkAllowed()
    local mock = self:getMock(self.address)
    return mock.workAllowed
end

function mockMachine:getAverageElectricInput()
    return self:getEUInputAverage()
end

function mockMachine.getOwnerName()
    return "gordominossi"
end

function mockMachine:getEUStored()
    return self:getStoredEU()
end

function mockMachine.getWorkMaxProgress()
    return mockMachine.workMaxProgress
end

function mockMachine:getSensorInformation()
    local mock = self:getMock(self.address, self.name)
    mock.workProgress = mock.workProgress + 1
    if mock.workProgress > mock.workMaxProgress then
        mock.workProgress = 0
        mock.workMaxProgress = 0
    end
    if mock.workAllowed and not mock.isBroken and math.random(1000) > 999 and mock.workProgress == 0 then
        mock.workMaxProgress = math.random(500)
    end
    mock.isBroken = mock.isBroken or math.random(100000) > 99999
    return {
        "Progress: §a" .. mock.workProgress .. "§r s / §e" .. mock.workMaxProgress .. "§r s",
        "Stored Energy: §a1000§r EU / §e1000§r EU",
        "Probably uses: §c4§r EU/t",
        "Max Energy Income: §e128§r EU/t(x2A) Tier: §eMV§r",
        "Problems: §c" .. (mock.isBroken and 1 or 0) .. "§r Efficiency: §e" .. (mock.isBroken and 0 or 100) .. ".0§r %",
        "Pollution reduced to: §a0§r %",
        n = 6
    }
end

function mockMachine:getEUOutputAverage()
    local mock = self:getMock(self.address)
    mock.EUOutputAverage = mock.EUOutputAverage + math.random(-100, 100)
    return mock.EUOutputAverage
end

function mockMachine:getEUInputAverage()
    local mock = self:getMock(self.address)
    mock.inputAverage = mock.inputAverage + math.random(-100, 100)
    return mock.inputAverage
end

function mockMachine:getStoredEU()
    local mock = self:getMock(self.address)
    mock.workProgress = mock.storedEU + mock.inputAverage - mock.outputAverage
    return mock.workProgress
end

function mockMachine.isMachineActive()
    return mockMachine.active
end

function mockMachine.getOutputVoltage()
    return mockMachine.outputVoltage
end

function mockMachine.getAverageElectricOutput()
    return 0.0
end

function mockMachine:hasWork()
    local mock = self:getMock(self.address)
    return mock.workProgress < mock.workMaxProgress
end

function mockMachine.getOutputAmperage()
    return mockMachine.outputAmperage
end

function mockMachine:getEUCapacity()
    local mock = self:getMock(self.address)
    return mock.EUCapacity
end

function mockMachine.getWorkProgress()
    return mockMachine.workProgress
end

function mockMachine:getEUMaxStored()
    return self:getEUCapacity()
end

function mockMachine:new(address, name)
    return New(self, {address = address, name = name})
end

function mockMachine:getEfficiencyPercentage()
    return 100
end

function mockMachine.getBatteryCharge(slot, self)
    local mock = self:getMock(self.address)
    if slot > 16 then
        return nil
    else
        return 1000000 / mock.workProgress
    end
end

function mockMachine.getMaxBatteryCharge(slot)
    if slot > 16 then
        return nil
    else
        return 1000000
    end
end

return mockMachine
