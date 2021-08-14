local function findIn(list, value)
    local key = nil
    local iterator

    if type(list) == "function" then
        iterator = list
    else
        iterator = pairs(list)
    end

    for k, v in iterator do
        if v == value then
            key = k
            break
        end
    end

    return key
end

return findIn
