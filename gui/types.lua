---@meta

---@class Component
---@field id string
---@field absolutePosition Coordinate2D
---@field absoluteSize Coordinate2D
---@field pos Coordinate2D
---@field size Coordinate2D
---@field callBack fun(...)
---@field onClick fun(pos: Coordinate2D?, size: Coordinate2D?, button?, callBack?: function, ...)
---@field onDrag fun(pos: Coordinate2D?, size: Coordinate2D?, button?, callBack?: function, ...)
---@field onRender fun(pos: Coordinate2D?, size: Coordinate2D?, button?, callBack?: function, ...)
---@field onScroll fun(pos: Coordinate2D?, size: Coordinate2D?, direction?, callBack?: function, ...)
---@field visible boolean
---@field children Component[]
---@field parent Component

---@class Coordinate2D
---@field x number
---@field y number
