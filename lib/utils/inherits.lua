local function inherits(...)
  local newClass = {}

  function newClass:new(object)
    object = object or {}
    setmetatable(object, newClass)
    return object
  end

  local function search(key, parentList)
    for i = 1, #parentList do
      local value = parentList[i][key]
      if value then
        return value
      end
    end
  end

  local parents = {...}
  for i = 1, #parents do
    for key, value in pairs(parents[i]) do
      newClass[key] = value
    end
  end

  setmetatable(
    newClass,
    {
      __index = function(table, key)
        return search(key, parents)
      end
    }
  )

  newClass.__index = newClass
  return newClass
end

return inherits
