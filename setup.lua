-- Paste this into OpenComputer terminal to download and set up NIDAS
-- wget https://raw.githubusercontent.com/S4mpsa/NIDAS/master/setup.lua -f
local shell = require("shell")
local filesystem = require("filesystem")

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
    if filesystem.exists("/home/NIDAS/configuration") then
        shell.execute("cp -r /home/NIDAS/configuration /home/temp/configuration")
    end
    filesystem.remove("/home/NIDAS")
    filesystem.makeDirectory("/home/NIDAS")

    shell.setWorkingDirectory("/home/NIDAS")
    print("Downloading NIDAS-" .. release)
    shell.execute("wget -fq " .. NIDAS)
    print("Extracting")
    shell.execute("tar -xf NIDAS.tar")
    filesystem.remove("NIDAS.tar")
    filesystem.remove("/home/lib")
    shell.execute("cp -r lib /home/lib")
    filesystem.copy(".shrc", "/home/.shrc")
    filesystem.copy("setup.lua", "/home/setup.lua")

    if filesystem.exists("/home/temp/configuration") then
        shell.execute("cp -r /home/temp/configuration /home/NIDAS/configuration")
        filesystem.remove("/home/temp/configuration")
    end

    print("Success!\n")
end)
if (not successful) then print("Update failed") end
