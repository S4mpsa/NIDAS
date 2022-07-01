---@alias decorator {__metatable:{__concat:fun()}}
---@type fun(decoratorFunction:fun(decoratorArguments:any, functionToDecorate:fun())):decorator
local Decorator = {}

setmetatable(Decorator, {
    --- Prepares the decoratorFunction to receive the arguments it needs
    --- so it can then be applied to the functionToDecorate
    ---@param decoratorFunction function
    ---@return fun(decoratorArguments:any):decorator
    __call = function(decoratorFunction)
        --- The decorator builder
        ---@param decoratorArguments any
        ---@return decorator
        return function(decoratorArguments)
            return setmetatable({}, {
                __concat = function(_, functionToDecorate)
                    return decoratorFunction(decoratorArguments,
                                             functionToDecorate)
                end
            })
        end
    end
})

return Decorator
