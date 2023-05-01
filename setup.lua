-- Paste this into OpenComputer terminal to download and set up NIDAS
-- wget https://raw.githubusercontent.com/S4mpsa/NIDAS/master/setup.lua -f

local shell = require("shell")
local filesystem = require("filesystem")
local computer = require("computer")
local component = require("component")
local gpu = component.gpu
local width, height = gpu.getResolution()

local colorA = 0x00A6FF
local colorB = 0xFF00FF

gpu.fill(1, 1, width, height, " ")
gpu.setForeground(0x181818)
gpu.fill(width / 2 - 11, height / 2 - 3, 23, 6, "▄")
gpu.fill(width / 2 - 10, height / 2 - 2, 21, 4, " ")
gpu.setForeground(colorA)
gpu.set(width / 2 - 7, height / 2 - 2, "Updating NIDAS")
local tarMan = "https://raw.githubusercontent.com/mpmxyz/ocprograms/master/usr/man/tar.man"
local tarBin = "https://raw.githubusercontent.com/mpmxyz/ocprograms/master/home/bin/tar.lua"

shell.setWorkingDirectory("/usr/man")
shell.execute("wget -fq " .. tarMan)
shell.setWorkingDirectory("/bin")
shell.execute("wget -fq " .. tarBin)

local NIDAS = "https://github.com/S4mpsa/NIDAS/releases/download/auto-release-2.0/NIDAS.tar"
local infusion = "https://github.com/S4mpsa/NIDAS/releases/download/auto-release-2.0/infusion.tar"
local successful =
    pcall(
    function()
        local workDir = "/home/NIDAS/"
        local persistent = {
            "tar-exclude.txt",
            ".gitignore",
            ".github",
            "README.md",
            "settings",
            ".git",
            ".vscode"
        }
        filesystem.makeDirectory("/home/temp")
        for _, thing in ipairs(persistent) do
            if filesystem.exists(workDir .. thing) then
                shell.execute("cp -r " .. workDir .. thing .. " /home/temp/" .. thing)
            end
        end

        filesystem.remove(workDir)
        filesystem.makeDirectory(workDir)
        shell.setWorkingDirectory(workDir)
        gpu.set(width / 2 - 8, height / 2 - 1, "Downloading . . .")
        shell.execute("wget -fq " .. NIDAS)
        gpu.set(width / 2 - 8, height / 2 - 1, "                 ")
        gpu.set(width / 2 - 7, height / 2, "Extracting . . .")
        shell.execute("tar -xf NIDAS.tar")
        filesystem.remove(workDir .. "NIDAS.tar")
        filesystem.copy(workDir .. ".shrc", "/home/.shrc")
        filesystem.copy(workDir .. "setup.lua", "/home/setup.lua")
        filesystem.makeDirectory(workDir .. "settings")

        for _, thing in ipairs(persistent) do
            if filesystem.exists("/home/temp/" .. thing) then
                shell.execute("cp -r /home/temp/" .. thing .. " " .. workDir)
            end
        end
        filesystem.remove("/home/temp/")

        workDir = "/home/NIDAS/modules/"
        shell.setWorkingDirectory(workDir)
        shell.execute("wget -fq " .. infusion)
        shell.execute("tar -xf infusion.tar")
        filesystem.remove(workDir .. "infusion.tar")

        gpu.set(width / 2 - 7, height / 2, "                ")
        gpu.set(width / 2 - 7, height / 2, "Update complete.  ")
        gpu.setForeground(colorB)
        gpu.set(width / 2 - 5, height / 2 + 1, "Rebooting  ")
        os.sleep(1)
        computer.shutdown(true)
    end
)
if (not successful) then
    gpu.setForeground(0xFF0000)
    gpu.set(width / 2 - 7, height / 2, "Update failed!  ")
end
