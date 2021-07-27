local function findIn(table, value)
    local key = nil

    for k, v in pairs(table) do
        if v == value then
            key = k
            break
        end
    end

    return key
end

return findIn
