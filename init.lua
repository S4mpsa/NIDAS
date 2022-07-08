-- Adds NIDAS library folders to default package path
package.path = package.path .. ";/home/NIDAS/?.lua;/home/NIDAS/lib/?.lua"

local tileEntity = require("core.tile-entity")
while true do
    for entity in tileEntity.list() do
        entity.update()
    end
end
