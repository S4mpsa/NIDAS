-- Adds NIDAS library folders to default package path
package.path = package.path .. ";/home/NIDAS/?.lua;/home/NIDAS/lib/?.lua"
--Require global libraries
windowManager = require("core.graphics.renderer.windowManager")
contextMenu = require("core.graphics.ui.contextMenu")
renderer = require("core.graphics.renderer.renderer")
theme = require("settings.theme")
