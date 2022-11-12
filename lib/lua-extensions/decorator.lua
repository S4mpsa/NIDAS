---@alias decorator {__metatable:{__concat:fun()}}
local Decorator = {}

---@type fun(decoratorFunction:fun(decoratorArguments:any, functionToDecorate:fun())):decorator
setmetatable(Decorator, {
    --- Prepares the decoratorFunction to receive the arguments it needs
    --- so it can then be applied to the functionToDecorate
    ---@param decoratorFunction function
    ---@return fun(decoratorArguments:any):decorator
    __call = function(_, decoratorFunction)
        --- The decorator builder
        ---@param decoratorArguments any
        ---@return decorator
        return function(decoratorArguments)
            return setmetatable({}, {
                __concat = function(_, functionToDecorate)
                    return decoratorFunction(decoratorArguments, functionToDecorate)
                end,
            })
        end
    end,
})

return Decorator
