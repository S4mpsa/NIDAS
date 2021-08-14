local function findInIterator(iterator, value)
    local key = nil

    for k, v in iterator do
        if v == value then
            key = k
            break
        end
    end

    return key
end

return findInIterator
