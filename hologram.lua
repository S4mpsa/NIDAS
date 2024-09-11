-- Generates a random heightmap and displays scrolling text above it.

local component = require("component")
local noise = require("noise")
local keyboard = require("keyboard")
local shell = require("shell")
local hologram = component.hologram

hologram.clear()
hologram.setScale(0.33)

local seed = math.random(0xFFFFFFFF)
for x = 1, 16 * 3 do
  for z = 1, 16 * 3 do
    hologram.fill(x, z, 15 + noise.fbm(x/(16*3) + seed, 1, z/(16*3) + seed) * 28,3)
  end
end

local glyphs = {
["a"]=[[
XXXXX
X   X
XXXXX
X   X
X   X
]],
["b"]=[[
XXXX 
X   X
XXXX 
X   X
XXXX 
]],
["c"]=[[
XXXXX
X    
X    
X    
XXXXX
]],
["d"]=[[
XXXX 
X   X
X   X
X   X
XXXX 
]],
["e"]=[[
XXXXX
X    
XXXX 
X    
XXXXX
]],
["f"]=[[
XXXXX
X    
XXXX 
X    
X    
]],
["g"]=[[
XXXXX
X    
X XXX
X   X
XXXXX
]],
["h"]=[[
X   X
X   X
XXXXX
X   X
X   X
]],
["i"]=[[
 XXX 
  X  
  X  
  X  
 XXX 
]],
["j"]=[[
    X
    X
    X
X   X
XXXXX
]],
["k"]=[[
X   X
X  X 
XXX  
X  X 
X   X
]],
["l"]=[[
X    
X    
X    
X    
XXXXX
]],
["m"]=[[
X   X
XX XX
X X X
X   X
X   X
]],
["n"]=[[
X   X
XX  X
X X X
X  XX
X   X
]],
["o"]=[[
XXXXX
X   X
X   X
X   X
XXXXX
]],
["p"]=[[
XXXXX
X   X
XXXXX
X    
X    
]],
["q"]=[[
XXXXX
X   X
X   X
X  X 
XXX X
]],
["r"]=[[
XXXXX
X   X
XXXX 
X   X
X   X
]],
["s"]=[[
XXXXX
X    
XXXXX
    X
XXXXX
]],
["t"]=[[
XXXXX
  X  
  X  
  X  
  X  
]],
["u"]=[[
X   X
X   X
X   X
X   X
XXXXX
]],
["v"]=[[
X   X
X   X
X   X
 X X 
  X  
]],
["w"]=[[
X   X
X   X
X X X
X X X
 X X 
]],
["x"]=[[
X   X
 X X 
  X  
 X X 
X   X
]],
["y"]=[[
X   X
X   X
 XXX 
  X  
  X  
]],
["z"]=[[
XXXXX
    X
 XXX 
X    
XXXXX
]],
["0"]=[[
 XXX 
X   X
X X X
X   X
 XXX 
]],
["1"]=[[
  XX 
 X X 
   X 
   X 
   X 
]],
["2"]=[[
XXXX 
    X
  X  
X    
XXXXX
]],
["3"]=[[
XXXX 
    X
 XXX 
    X
XXXX 
]],
["4"]=[[
X   X
X   X
XXXXX
    X
    X
]],
["5"]=[[
XXXXX
X    
XXXX 
    X
XXXX 
]],
["6"]=[[
 XXX 
X    
XXXX 
X   X
 XXX 
]],
["7"]=[[
XXXXX
   X 
 XXX 
  X  
 X   
]],
["8"]=[[
 XXX 
X   X
 XXX 
X   X
 XXX 
]],
["9"]=[[
 XXX 
X   X
 XXXX
    X
 XXX 
]],
[" "]=[[
     
     
     
     
     
]],
["."]=[[
   
   
   
   
 X 
]],
[","]=[[
    
    
    
  X 
 X  
]],
[";"]=[[
    
  X 
    
  X 
 X  
]],
["-"]=[[
     
     
 XXX 
     
     
]],
["+"]=[[
     
  X  
 XXX 
  X  
     
]],
["*"]=[[
     
 X X 
  X  
 X X 
     
]],
["/"]=[[
    X
   X 
  X  
 X   
X    
]],
["\\"]=[[
X    
 X   
  X  
   X 
    X
]],
["_"]=[[
     
     
     
     
XXXXX
]],
["!"]=[[
 X 
 X 
 X 
   
 X 
]],
["?"]=[[
 XXX 
    X
  XX 
     
  X  
]],
["("]=[[
  X 
 X  
 X  
 X  
  X 
]],
[")"]=[[
 X  
  X 
  X 
  X 
 X  
]],
}

local args = shell.parse(...)
local text = "Open Computers"
if args[1] then
  text = tostring(args[1])
else
  print("No text specified, using default value 'Open Computers'.")
end
local text = text .. " "

-- Generate one big string that represents the concatenated glyphs for the provided text.
local value = ""
for row = 1, 5 do
  for col = 1, #text do
    local char = string.sub(text:lower(), col, col)
    local glyph = glyphs[char]
    if glyph then
      local s = 0
      for _ = 2, row do
        s = string.find(glyph, "\n", s + 1, true)
        if not s then
          break
        end
      end
      if s then
        local line = string.sub(glyph, s + 1, (string.find(glyph, "\n", s + 1, true) or 0) - 1)
        value = value .. line .. " "
      end
    end
  end
  value = value .. "\n"
end

local bm = {}
for token in value:gmatch("([^\r\n]*)") do
  if token ~= "" then
    table.insert(bm, token)
  end
end
local h,w = #bm,#bm[1]
local sx, sy = math.max(0,(16*3-w)/2), 2*16-h-1
local z = 16*3/2

print("Press Ctrl+W to stop.")
for i = 1, math.huge do
  os.sleep(0.1)
  local function col(n)
    return (n - 1 + i) % w + 1
  end
  for i=1, math.min(16*3,w) do
    local x = sx + i
    local i = col(i)
    for j=1, h do
      local y = sy + j-1
      if bm[1+h-j]:sub(i, i) ~= " " then
        hologram.set(x, y, z, 1)
      else
        hologram.set(x, y, z, 0)
      end
      if keyboard.isKeyDown(keyboard.keys.w) and keyboard.isControlDown() then
        hologram.clear()
        os.exit()
      end
    end
  end
end