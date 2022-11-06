-- Paste this into an Opencomputers terminal to download NIDAS's package manager
-- wget -f https://raw.githubusercontent.com/S4mpsa/NIDAS/master/setup.lua

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

print('Downloading some stuff first...')

local tempDir = '/home/temp/'
local NIDASDir = '/home/NIDAS/'

local event = require('event')
event.onError = print

local filesystem = require('filesystem')
local shell = require('shell')
local computer = require('computer')

local gui = require('hand.hand-gui')
local renderEngine = require('core.lib.graphics.core.engine')

-------------------------------- Utilities -------------------------------------

---@param url string
local function download(url)
    shell.execute('wget -fq ' .. url)
end

---@param filePath string
local function untar(filePath)
    shell.execute('tar -xf ' .. filePath)
end

---@param package Package
local function install(package)
    filesystem.makeDirectory(NIDASDir)
    if package.name ~= 'NIDAS' then
        filesystem.makeDirectory(NIDASDir .. 'modules')
        shell.setWorkingDirectory(NIDASDir .. 'modules')
    end
    untar(tempDir .. package.name .. '.tar')
end

------------------------------- Dependencies -----------------------------------

local tarMan = 'https://raw.githubusercontent.com/' ..
    'mpmxyz/ocprograms/master/usr/man/tar.man'
local tarBin = 'https://raw.githubusercontent.com/' ..
    'mpmxyz/ocprograms/master/home/bin/tar.lua'
local jsonBin = 'https://raw.githubusercontent.com/' ..
    'rxi/json.lua/master/json.lua'

shell.setWorkingDirectory('/usr/man')
download(tarMan)

shell.setWorkingDirectory('/bin')
download(tarBin)
download(jsonBin)

local json = require('json')

--------------------------------- Packages -------------------------------------

---@return Package[]
local function getPackages(releases)
    local packages = {}
    for _, release in ipairs(releases) do
        for _, asset in ipairs(release.assets) do
            local author = asset.uploader.login
            if author == 'gordominossi' or author == 'S4mpsa' then
                author = 'gordominossi and S4mpsa'
            end

            local description = (asset.label and asset.label ~= '')
                and asset.label
                or 'No description'

            ---@type Package
            local package = {
                author = author,
                description = description,
                downloadCount = asset.download_count,
                name = string.gsub(asset.name, '.tar', ''),
                size = asset.size,
                url = asset.browser_download_url,
                tag = string.gsub(release.tag_name, '(auto%-release%-)', ''),
                version = release.tag_name,
                updatedAt = asset.updated_at,
            }
            if not release.prerelease or true then
                table.insert(packages, package)
            end
        end
    end

    return packages
end

----------------------------------- Main ---------------------------------------

local function main()
    filesystem.remove(tempDir)
    filesystem.makeDirectory(tempDir)
    shell.setWorkingDirectory(tempDir)

    download('https://api.github.com/repos/S4mpsa/NIDAS/releases')
    local file = io.open('releases', 'r')
    local releases = json.decode(file:read('a'))
    file:close()

    local packages = getPackages(releases)

    local root = gui.rootComponent(packages, download, install)
    renderEngine.registerEvents(root)
    renderEngine.render(root)
end

event.listen('interrupted', function()
    computer.shutdown(true)
end)

main()

while true do
    ---@diagnostic disable-next-line: undefined-field
    os.sleep(1000)
end
