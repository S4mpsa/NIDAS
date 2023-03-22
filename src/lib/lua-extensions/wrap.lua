---@param f function
---@param functionName? string
---@param respawn? boolean
---@return fun(...): table
local function wrap(f, functionName, respawn)
    local coro = coroutine.create(f)
    local function wrapped(...)
        if coroutine.status(coro) == 'dead' and respawn then
            coro = coroutine.create(f)
        end
        local result = { coroutine.resume(coro, ...) }

        local success = table.remove(result, 1)
        if not success then
            error((functionName or '') .. ': ' .. result[1])
        end

        ---@diagnostic disable-next-line: undefined-field
        os.sleep(0)

        return result
    end

    return wrapped
end

return wrap
