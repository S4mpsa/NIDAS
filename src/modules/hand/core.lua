-- Paste this into an Opencomputers terminal to download NIDAS's package manager
-- wget -f https://raw.githubusercontent.com/S4mpsa/NIDAS/master/setup.lua

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

local tempDir = '/home/temp/'
local NIDASDir = '/home/NIDAS/'

-- local event = require('event')
-- local computer = require('computer')
-- event.listen('interrupted', function()
--     computer.shutdown(true)
-- end)
-- event.onError = print

local filesystem = require('filesystem')
local shell = require('shell')

local serialization = require('serialization')

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
    shell.setWorkingDirectory(package.name)
    local file = io.open('package.lua', 'w')
    file:write(serialization.serialize(package))

    shell.setWorkingDirectory(NIDASDir)
end

------------------------------- Dependencies -----------------------------------

local function downloadDependencies()
    print('Downloading a few utilities first...')
    shell.setWorkingDirectory('/usr/man')
    if not filesystem.exists('/usr/man/tar.man') then
        local tarMan = 'https://raw.githubusercontent.com/' ..
            'mpmxyz/ocprograms/master/usr/man/tar.man'
        download(tarMan)
    end

    shell.setWorkingDirectory('/bin')
    if not filesystem.exists('/bin/tar.bin') then
        local tarBin = 'https://raw.githubusercontent.com/' ..
            'mpmxyz/ocprograms/master/home/bin/tar.lua'
        download(tarBin)
    end
    if not filesystem.exists('/bin/json.lua') then
        local jsonBin = 'https://raw.githubusercontent.com/' ..
            'rxi/json.lua/master/json.lua'
        download(jsonBin)
    end
end

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
    downloadDependencies()
    local json = require('json')

    filesystem.remove(tempDir)
    filesystem.makeDirectory(tempDir)
    shell.setWorkingDirectory(tempDir)

    print('Making sure your system is up to date...')
    download('https://api.github.com/repos/S4mpsa/NIDAS/releases')
    local file = io.open('releases', 'r')
    local releases = json.decode(file:read('a'))
    file:close()

    shell.setWorkingDirectory(NIDASDir)
    shell.execute('clear')

    local packages = getPackages(releases)
    while true do
        coroutine.yield(packages, download, install)
    end
end

return main
