---@meta

---@class Component
---@field id string
---@field absolutePosition Coordinate2D
---@field absoluteSize Coordinate2D
---@field pos Coordinate2D
---@field size Coordinate2D
---@field callBack fun(...)
---@field onClick fun(pos: Coordinate2D, size: Coordinate2D, ...)
---@field onDrag fun(pos: Coordinate2D, size: Coordinate2D, ...)
---@field onRender fun(pos: Coordinate2D, size: Coordinate2D, ...)
---@field onScroll fun(pos: Coordinate2D, size: Coordinate2D, ...)
---@field visible boolean
---@field children Component[]
---@field parent Component

---@class Coordinate2D
---@field x number
---@field y number
