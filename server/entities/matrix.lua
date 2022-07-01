-- Import section

local status = require("server.entities.status")

--

local matrix = {
    name = "",
    address = "",
    aspects = {},
    type = "blockstonedevice_2"
}

function matrix:getAspects()
end

function matrix.getAspectCount(aspectName, self)
end

return matrix
