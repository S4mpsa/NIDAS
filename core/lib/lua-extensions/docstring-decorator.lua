local Decorator = require("core.lib.lua-extensions.decorator")

--- Makes the function.__tostring = description.
---
--- Use by concatenating the docstring with the
--- function to be described:
---
---     local myPrint =
---       docstring([[calls .__tostring on whatever arguments it's given]]) ..
---       function(args) print(args) end
---@type decorator (description:string):decorator string: string to describe the function being decorated
local docstring = Decorator(function(description, functionToDescribe)
    return setmetatable({}, {
        __call = function(_, ...)
            functionToDescribe(...)
        end,
        __tostring = function()
            return description
        end,
    })
end)

return docstring
