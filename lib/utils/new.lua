local function new(class, props, ...)
  local newObject = {}

  for key, value in pairs(class) do
    newObject[key] = value
  end

  for key, value in pairs(props) do
    newObject[key] = value
  end

  local parents = {...}
  for i = 1, #parents do
    for key, value in pairs(parents[i]) do
      newObject[key] = value
    end
  end

  setmetatable(newObject, {__index = class})

  return newObject
end

return new
