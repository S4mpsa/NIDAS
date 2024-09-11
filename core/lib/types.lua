---@meta

---@class Coordinate2D
---@field x number
---@field y number


---@class Coordinate3D
---@field x number
---@field y number
---@field z number

---@class Window
---@field name string
---@field size Coordinate2D
---@field position Coordinate2D
---@field depth number
---@field buffer number
---@field elements table

---@class Element
---@field size Coordinate2D
---@field position Coordinate2D
---@field onClick function