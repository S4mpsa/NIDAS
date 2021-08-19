-- This file *would* be stored in /lib/core/boot.lua
-- How you get it there is up to you
-- NOTE: If using this, you must remove the relevant lines that display the logo in /home/configuration/menu.lua
-- called from /init.lua
local raw_loadfile = ...

_G._OSVERSION = "OpenOS 1.7.5"

-- luacheck: globals component computer unicode _OSVERSION
local component = component
local computer = computer
local unicode = unicode

-- Runlevel information.
_G.runlevel = "S"
local shutdown = computer.shutdown
computer.runlevel = function()
  return _G.runlevel
end
computer.shutdown = function(reboot)
  _G.runlevel = reboot and 6 or 0
  if os.sleep then
    computer.pushSignal("shutdown")
    os.sleep(0.1) -- Allow shutdown processing.
  end
  shutdown(reboot)
end

local w, h
local screen = component.list("screen", true)()
local gpu = screen and component.list("gpu", true)()
if gpu then
  gpu = component.proxy(gpu)
  if not gpu.getScreen() then
    gpu.bind(screen)
  end
  _G.boot_screen = gpu.getScreen()
  w, h = gpu.maxResolution()
  gpu.setResolution(w, h)
  gpu.setBackground(0x000000)
  gpu.setForeground(0xFFFFFF)
  gpu.fill(1, 1, w, h, " ")
end

-- Report boot progress if possible.
local uptime = computer.uptime
-- we actually want to ref the original pullSignal here because /lib/event intercepts it later
-- because of that, we must re-pushSignal when we use this, else things break badly
local pull = computer.pullSignal
local last_sleep = uptime()
local function status(msg)
  -- boot can be slow in some environments, protect from timeouts
  if uptime() - last_sleep > 1 then
    local signal = table.pack(pull(0))
    -- there might not be any signal
    if signal.n > 0 then
      -- push the signal back in queue for the system to use it
      computer.pushSignal(table.unpack(signal, 1, signal.n))
    end
    last_sleep = uptime()
  end
end

status("Booting " .. _OSVERSION .. "...")

-- Custom low-level dofile implementation reading from our ROM.
local function dofile(file)
  status("> " .. file)
  local program, reason = raw_loadfile(file)
  if program then
    local result = table.pack(pcall(program))
    if result[1] then
      return table.unpack(result, 2, result.n)
    else
      error(result[2])
    end
  else
    error(reason)
  end
end

status("Initializing package management...")

-- Load file system related libraries we need to load other stuff moree
-- comfortably. This is basically wrapper stuff for the file streams
-- provided by the filesystem components.
local package = dofile("/lib/package.lua")

do
  -- Unclutter global namespace now that we have the package module and a filesystem
  _G.component = nil
  _G.computer = nil
  _G.process = nil
  _G.unicode = nil
  -- Inject the package modules into the global namespace, as in Lua.
  _G.package = package

  -- Initialize the package module with some of our own APIs.
  package.loaded.component = component
  package.loaded.computer = computer
  package.loaded.unicode = unicode
  package.loaded.buffer = dofile("/lib/buffer.lua")
  package.loaded.filesystem = dofile("/lib/filesystem.lua")

  -- Inject the io modules
  _G.io = dofile("/lib/io.lua")
end

status("Initializing file system...")

-- Mount the ROM and temporary file systems to allow working on the file
-- system module from this point on.
require("filesystem").mount(computer.getBootAddress(), "/")

status("Running boot scripts...")

-- Run library startup scripts. These mostly initialize event handlers.
local function rom_invoke(method, ...)
  return component.invoke(computer.getBootAddress(), method, ...)
end

local scripts = {}
for _, file in ipairs(rom_invoke("list", "boot")) do
  local path = "boot/" .. file
  if not rom_invoke("isDirectory", path) then
    table.insert(scripts, path)
  end
end

local function screen_divideHex(hex, divisor)
  local r = ((hex >> 16) & 0xFF)
  local g = ((hex >> 8) & 0xFF)
  local b = ((hex) & 0xFF)
  return ((math.ceil(divisor * r)) << 16) + ((math.ceil(divisor * g)) << 8) + (divisor * b)
end

local function graphics_text(x, y, text, color)
  color = color or 0xFFFFFF
  if y % 2 == 0 then
    error("Y must be odd.")
  else
    local screenY = math.ceil(y / 2)
    gpu.setForeground(color)
    gpu.set(x, screenY, text)
  end
end

local function pixel(x, y, color)
  local screenY = math.ceil(y / 2)
  gpu.setForeground(color)
  if y % 2 == 1 then --Upper half of pixel
    gpu.set(x, screenY, "▀")
  else --Lower half of pixel
    gpu.set(x, screenY, "▄")
  end
end

local function graphics_rectangle(x, y, width, height, color)
  local hLeft = height
  if x > 0 and y > 0 then
    if y % 2 == 0 then
      for i = x, x + width - 1 do
        pixel(i, y, color)
      end
      hLeft = hLeft - 1
    end
    gpu.setForeground(color)
    if hLeft % 2 == 1 then
      gpu.fill(x, math.ceil(y / 2) + (height - hLeft), width, (hLeft - 1) / 2, "█")
      for j = x, x + width - 1 do
        pixel(j, y + height - 1, color)
      end
    else
      gpu.fill(x, math.ceil(y / 2) + (height - hLeft), width, hLeft / 2, "█")
    end
  end
end
local function graphics_outline(x, y, lines, color)
  color = color or 0xFFFFFF
  for i = 0, #lines - 1 do
    graphics_text(x, y + i * 2, lines[i + 1], color)
  end
end
local function gui_logo(x, y, version, border, primary, accent)
  local bColor = border
  local pColor = primary
  local aColor = accent
  local logo1 = {
    "█◣  █  ◢  ███◣   ◢█◣  ◢███◣",
    "█◥◣ █  █  █  ◥◣ ◢◤ ◥◣ █   ",
    "█ ◥◣█  █  █   █ █   █ █    ",
    "█  ◥█  █  █   █ █▃▃▃█ ◥███◣",
    "█   █  █  █   █ █   █     █",
    "█   █  █  █  ◢◤ █   █     █",
    "█   █  ◤  ███◤  █   █ ◢███◤"
  }
  local logo2 = {
    " ◢█◣ ",
    "◢◤ ◥◣",
    "█   █",
    "█▃▃▃█",
    "█   █",
    "█   █",
    "█   █"
  }

  graphics_text(x + 1, y + 3, "◢", bColor)
  graphics_text(x + 1, y + 14, "◥", bColor)
  graphics_rectangle(x + 1, y + 5, 1, 12, bColor)
  graphics_rectangle(x + 2, y + 14, 27, 1, bColor)
  graphics_outline(x + 3, y + 1, logo1, pColor)
  graphics_outline(x + 19, y + 1, logo2, aColor)
  graphics_text(x + 27, y + 3, "Ver", aColor)
  graphics_text(x + 27, y + 5, version, aColor)
end

gpu.setResolution(80, 20)
local x, y = gpu.getResolution()
if y % 2 == 0 then
  y = y - 1
end

local steps = (#scripts + 1)
table.sort(scripts)
for i = 2, (#scripts + 1) do
  gui_logo(
    x / 2 - 15,
    y / 2 + 1,
    dofile("/home/NIDAS/nidas_version.lua"),
    screen_divideHex(0x181828, (i / (steps)) ^ 2),
    screen_divideHex(0x00A6FF, (i / (steps + 0)) ^ 2),
    screen_divideHex(0xFF00FF, (i / (steps + 0)) ^ 2)
  )
  gpu.setForeground(0xFFFFFF)
  dofile(scripts[i - 1])
end

status("Initializing components...")

for c, t in component.list() do
  computer.pushSignal("component_added", c, t)
end

status("Initializing system...")

computer.pushSignal("init") -- so libs know components are initialized.
require("event").pull(1, "init") -- Allow init processing.
_G.runlevel = 1
