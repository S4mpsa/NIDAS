local Decorator = require('core.lib.lua-extensions.decorator')

--- Makes the function.__tostring = description.
---
--- Use by concatenating the docstring with the
--- function to be described:
---
---     local myPrint =
---       docstring([[calls .__tostring on whatever arguments it's given]]) ..
---       function(args) print(args) end
---@type decorator
local docstring = Decorator(
    ---@param description string string to describe the function being decorated
    ---@param functionToDescribe fun()
    ---@return table describedFunction actually a table with `__call` and `__tostring` metamethods
    function(description, functionToDescribe)
        return setmetatable({}, {
            __call = function(_, ...)
                functionToDescribe(...)
            end,
            __tostring = function()
                return description
            end,
        })
    end
)

return docstring
