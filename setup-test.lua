-- Paste this into OpenComputer terminal to download and set up NIDAS
-- wget https://raw.githubusercontent.com/S4mpsa/NIDAS/develop/setup-test.lua -f
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

NIDAS = "https://github.com/S4mpsa/NIDAS/releases/download/v-1/NIDAS.tar"

local successfull = pcall(function()
    if filesystem.exists("/home/NIDAS") then
        shell.execute(
            "cp -r /home/NIDAS/configuration, /home/temp/configuration")
    end
    filesystem.remove("/home/NIDAS")
    filesystem.makeDirectory("/home/NIDAS")

    shell.setWorkingDirectory("/home/NIDAS")
    print("Downloading NIDAS")
    shell.execute("wget -fq " .. NIDAS .. " -f")
    print("Extracting")
    shell.execute("tar -xf NIDAS.tar")
    filesystem.remove("NIDAS.tar")
    filesystem.remove("/home/lib")
    shell.execute("cp -r lib /home/lib")
    filesystem.copy(".shrc", "/home/.shrc")
    filesystem.copy("setup-test.lua", "/home/setup-test.lua")

    if filesystem.exists("/home/temp/configuration") then
        shell.execute(
            "cp -r /home/temp/configuration, /home/NIDAS/configuration")
        filesystem.remove("/home/temp/configuration")
    end

    print("Success!\n")
end)
if (not successfull) then print("Update failed") end
