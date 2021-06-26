local function new(class, props)
  local newObject = props or {}

  for key, value in pairs(class) do
    newObject[key] = value
  end

  setmetatable(newObject, {__index = class})

  return newObject
end

return new
