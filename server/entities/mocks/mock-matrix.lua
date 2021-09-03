-- Import section

local machine = require("server.entities.machine")
local inherits = require("lib.utils.inherits")
local new = require("lib.utils.new")

--

local mockMatrix =
    inherits(
    machine,
    {
        mocks = {}
    }
)

function mockMatrix:getMock(address, name)
    if not address then
        return nil
    end
    if not self.mocks[address] then
        self.mocks[address] = {
            name = name or "fake matrix",
            address = address,
            aspects = {
                {amount = 32.0, name = "Sensus"},
                {amount = 16.0, name = "Auram"},
                {amount = 16.0, name = "Tutamen"}
            },
            type = "blockstonedevice_2"
        }
    end
    return self.mocks[address]
end

function mockMatrix:getAspects()
    return {aspects = self.aspects}
end

function mockMatrix.getAspectCount(aspectName, self)
    if not type(aspectName) == string then
        error("string expected, got " .. type(aspectName))
    end

    local amount = 0.0
    for aspect in ipairs(self.aspects) do
        if aspect.name == aspectName then
            amount = aspect.amount
            break
        end
    end

    return amount
end

return mockMatrix
