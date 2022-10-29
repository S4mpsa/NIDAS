---@meta

---@class Coordinates
---@field x number
---@field y number

---@class Component
---@field id string
---@field absolutePosition Coordinates
---@field absoluteSize Coordinates
---@field pos Coordinates
---@field size Coordinates
---@field callBack fun(...)
---@field onClick fun(pos: Coordinates, size: Coordinates, ...)
---@field onDrag fun(pos: Coordinates, size: Coordinates, ...)
---@field onRender fun(pos: Coordinates, size: Coordinates, ...)
---@field onScroll fun(pos: Coordinates, size: Coordinates, ...)
---@field visible boolean
---@field children Component[]
---@field parent Component

---@class Progress
---@field current number
---@field max number
