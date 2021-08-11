-- Paste this into OpenComputer terminal to download and set up NIDAS
-- wget https://raw.githubusercontent.com/S4mpsa/NIDAS/develop/setup.lua -f

local shell = require("shell")
local filesystem = require("filesystem")
local computer = require("computer")

local tarMan =
    "https://raw.githubusercontent.com/mpmxyz/ocprograms/master/usr/man/tar.man"
local tarBin =
    "https://raw.githubusercontent.com/mpmxyz/ocprograms/master/home/bin/tar.lua"

shell.setWorkingDirectory("/usr/man")
shell.execute("wget -fq " .. tarMan)
shell.setWorkingDirectory("/bin")
shell.execute("wget -fq " .. tarBin)

local NIDAS
local release
local arg = {...}
if arg[1] == "test" or arg[1] == "latest" then
    NIDAS = "https://github.com/S4mpsa/NIDAS/releases/download/v-1/NIDAS.tar"
    release = "latest"
elseif arg[1] == "dev" or arg[1] == "staging" then
    NIDAS = "https://github.com/S4mpsa/NIDAS/releases/download/v0/NIDAS.tar"
    release = "staging"
else
    NIDAS = "https://github.com/S4mpsa/NIDAS/releases/latest/download/NIDAS.tar"
    release = "\"stable\""
end

local successful = pcall(function()
    if filesystem.exists("/home/NIDAS/settings") then
        shell.execute("cp -r /home/NIDAS/settings /home/temp/settings")
    end
    local workDir = "/home/NIDAS/"
    filesystem.remove(workDir)
    filesystem.makeDirectory(workDir)

    shell.setWorkingDirectory(workDir)
    print("Downloading NIDAS-" .. release)
    shell.execute("wget -fq " .. NIDAS)
    print("Extracting")
    shell.execute("tar -xf NIDAS.tar")
    filesystem.remove(workDir .. "NIDAS.tar")
    --filesystem.remove("/home/lib")
    --shell.execute("cp -r lib /home/lib")
    filesystem.copy(workDir .. ".shrc", "/home/.shrc")
    filesystem.copy(workDir .. "setup.lua", "/home/setup.lua")

    if filesystem.exists("/home/temp/settings") then
        shell.execute("cp -r /home/temp/settings " .. workDir ..
                          "settings")
        filesystem.remove("/home/temp/settings")
    end

    local rebootTime = 3
    print("Success!")
    print("Rebooting in 3s\n")
    for i = 1, rebootTime do
        io.write(".")
        os.sleep(1)
    end
    computer.shutdown(true)
end)
if (not successful) then print("Update failed") end
