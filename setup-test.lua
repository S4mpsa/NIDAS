-- Paste this into OpenComputer terminal to download and set up NIDAS
-- wget https://raw.githubusercontent.com/S4mpsa/NIDAS/develop/setup-test.lua -f

local shell = require("shell")

local tarMan = "https://raw.githubusercontent.com/mpmxyz/ocprograms/master/usr/man/tar.man"
local tarBin = "https://raw.githubusercontent.com/mpmxyz/ocprograms/master/home/bin/tar.lua"

shell.setWorkingDirectory("/usr/man")
shell.execute("wget -fq " .. tarMan)
shell.setWorkingDirectory("/bin")
shell.execute("wget -fq " .. tarBin)

NIDAS = "https://github.com/S4mpsa/NIDAS/releases/download/v-1/NIDAS.tar"

local successfull =
    pcall(
    function()
        shell.execute("rm -rf /home/NIDAS")
        shell.execute("mkdir /home/NIDAS")

        shell.setWorkingDirectory("/home/NIDAS")
        print("Downloading NIDAS")
        shell.execute("wget -fq " .. NIDAS .. " -f")
        print("Extracting")
        shell.execute("tar -xf NIDAS.tar")
        shell.execute("rm -f NIDAS.tar")
        shell.execute("rm -rf /home/lib")
        shell.execute("cp -r lib /home/lib")
        shell.execute("cp -f .shrc /home/.shrc")
        shell.execute("cp -f setup-test.lua /home/setup-test.lua")

        print("Success!\n")
    end
)
if (not successfull) then
    print("Update failed")
end
