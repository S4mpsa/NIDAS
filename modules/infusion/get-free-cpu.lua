-- Import section

local getInterface = require("server.usecases.get-machine")

--

local function exec(address)
    local meInterface = getInterface(address)
    if not meInterface.address then
        return
    end

    local cpus = meInterface.getCpus()
    for _, cpu in ipairs(cpus) do
        if not cpu.busy then
            return cpu
        end
    end
end

return exec
