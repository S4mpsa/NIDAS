local graphics = require("lib.graphics.graphics")
local colors    = require("lib.graphics.colors")
local event = require("event")
local uc = require("unicode")
local renderer = require("lib.graphics.renderer")
local parser = require("lib.utils.parser")
local gui = {}

local borderColor = colors.gray
local primaryColor = colors.electricBlue
local accentColor = colors.magenta

function gui.setColors(primary, accent, border)
    primaryColor = primary or colors.electricBlue
    accentColor = accent or colors.magenta
    borderColor = border or colors.gray
end

function gui.borderColor() return borderColor end
function gui.primaryColor() return primaryColor end
function gui.accentColor() return accentColor end

--Creates a bounded 3-tall button.
--  text = Text to display on button
--  onClick = Function to call when button is pressed
--  args = Arguments to pass to the button
--  [width] = Optional width to force the button to be a certain width. Defaults to the length of the text + 2
function gui.bigButton(x, y, text, onClick, args, width, suppressFlash)
    width = width or #text+2
    local gpu = graphics.context().gpu
    local page = renderer.createObject(x, y, width, 3, true)
    gpu.setActiveBuffer(page)
    local top = "╭"
    local middle = "│"
    local bottom = "╰"
    for i = 1, width-2 do
        top = top .. "─"
        middle = middle .. " "
        bottom = bottom .. "─"
    end
    top = top .. "╮"
    middle = middle .. "│"
    bottom = bottom .. "╯"
    graphics.outline(1, 1, {top, middle, bottom}, primaryColor)
    graphics.text(width/2 - #text/2 + 1, 3, text, accentColor)
    local function flash()
        graphics.outline(x, y*2-1, {top, middle, bottom}, accentColor)
        graphics.text(x+width/2 - #text/2, y*2+1, text, accentColor)
        local function done()
            gpu.bitblt(0, x, y, width, 3, page, 1, 1)
        end
        if not suppressFlash then event.timer(0.3, done, 1) end
    end
    renderer.setClickable(page, {flash, onClick}, args, {x, y}, {x+width, y+3})
    gpu.setActiveBuffer(0)
    return page
end

--Creates a small, 1-tall button.
--  text = Text to display on button
--  onClick = Function to call when button is pressed
--  args = Arguments to pass to the button
--  [width] = Optional width to force the button to be a certain width. Defaults to the length of the text + 2
function gui.smallButton(x, y, text, onClick, args, width, color, leftAlign)
    color = color or primaryColor
    text = tostring(text)
    width = width or #text+2
    leftAlign = leftAlign or false
    local gpu = graphics.context().gpu
    local page = renderer.createObject(x, y, width, 1, true)
    gpu.setActiveBuffer(page)
    if leftAlign then
        graphics.text(2, 1, text, color)
    else
        graphics.text(math.ceil(width/2 - #text/2 + 1), 1, text, color)
    end
    renderer.setClickable(page, onClick, args, {x, y}, {x+width, y+1})
    gpu.setActiveBuffer(0)
    return page
end

--Creates a rectangular frame, starting from x, y and going to x+width, y+height
function gui.listFrame(x, y, width, height, title)
    local gpu = graphics.context().gpu
    local page = renderer.createObject(x, y, width, height)
    local top = "╭"
    local middle = "│"
    local bottom = "╰"
    for i = 1, width-2 do
        top = top .. "─"
        middle = middle .. " "
        bottom = bottom .. "─"
    end
    top = top .. "╮"
    middle = middle .. "│"
    bottom = bottom .. "╯"
    local borders = {top, bottom}
    for i = 1, height-2 do table.insert(borders, 2, middle) end
    gpu.setActiveBuffer(page)
    graphics.outline(1, 1, borders, borderColor)
    if title ~= nil then
        graphics.text(math.ceil(1+width/2-#title/2), 3, title, borderColor)
    end
    gpu.setActiveBuffer(0)
    return page
end

--Creates a list of multiple small buttons at x, y, with borders.
--Buttons are passed as a table of tables:
--Each button is of the form {name = "Name", func = functionToCall, args = argsToPass}
function gui.multiButtonList(x, y, buttons, width, height, title, color, leftAlign)
    leftAlign = leftAlign or false
    color = color or primaryColor
    local pages = {}
    table.insert(pages, gui.listFrame(x, y, width, height, title))
    local titleOffset = 0
    if title ~= nil then titleOffset = 1 end
    for i = 0, #buttons-1 do
        if leftAlign then
            table.insert(pages, gui.smallButton(x+1, y+i+1+titleOffset, buttons[i+1].name, buttons[i+1].func, buttons[i+1].args, width-2, color, true))
        else
            table.insert(pages, gui.smallButton(x+1, y+i+1+titleOffset, buttons[i+1].name, buttons[i+1].func, buttons[i+1].args, width-2, color))
        end
    end
    return pages
end

--Creates an undecorated text input box at x, y, with optional max width.
--The start value of the text box is passed in startValue.
--Returns the value inserted when pressing ENTER, or nil if focus is lost (touch signal not in box).
function gui.textInput(x, y, maxWidth, startValue)
    x = x or 1
    y = y or 1
    maxWidth = maxWidth or 15
    startValue = startValue or ""
    local returnString = startValue
    graphics.rectangle(x, -1+2*y, maxWidth, 2, colors.black)
    graphics.text(x, -1+2*y, returnString.."_", accentColor)
    local value = 0
    local function checkExit(_, _, X, Y)
        if X < x or X > x+maxWidth or Y ~= y then
            value = -1
        end
    end
    local focusListener = event.listen("touch", checkExit)
    while value ~= 13 and value ~= -1 and value ~= 9 do
        local _, _, key, _, _ = event.pull(0.05, "key_down")
        if key ~= nil then
            value = key
            if #returnString < maxWidth then
                if key >= 32 and key <= 126 then
                    returnString = returnString..uc.char(key)
                end
            end
            if key == 8 then
                returnString = returnString:sub(1, -2)
            end
            local padded = returnString
            if #returnString ~= maxWidth then
                padded = returnString.."_"
                for i = 2, maxWidth-#returnString+1 do padded = padded.." " end
            end
            graphics.text(x, -1+2*y, padded, accentColor)
        end
        renderer.multicast()
    end
    event.cancel(focusListener)
    if value == 9 then
        event.push("touch", _, x, y+1)
    end
    local padded = returnString
    for i = 1, maxWidth-#padded+1 do padded = padded.." " end
    graphics.text(x, -1+2*y, padded, primaryColor)
    renderer.multicast()
    return returnString
end

local function split(string, sep)
    if sep == nil then sep = "%s" end
    local words = {}
    for str in string.gmatch(string, "([^"..sep.."]+)") do
        table.insert(words, str)
    end
    return words
end

--Creates a bounded text box that wraps the text.
function gui.wrappedTextBox(x, y, width, height, text, title)
    local page = gui.listFrame(x, y, width, height, title)
    local gpu = graphics.context().gpu
    local words = split(text, " ")
    local lines = {}
    local line = ""
    for i = 1, #words do
        if #line+#words[i] < width-3 then
            line = line .. " " .. words[i]
        else
            table.insert(lines, line)
            line = " "..words[i]
        end
    end
    if #line > 0 then
        table.insert(lines, line)
    end
    gpu.setActiveBuffer(page)
    for i = 1, #lines do
        graphics.text(2, 5+i*2, lines[i])
    end
    gpu.setActiveBuffer(0)
    return page
end

function gui.configMenu(x, y, width, height, title, data)
    local page = gui.listFrame(x, y, width, height, title)
    return page
end

--Creates an undecorated number input box at x, y, with optional max width.
--The start value of the number box is passed in startValue. Defaults to 0.
--The number can either expand right or left, depending on startLeft. True = Number grows to the right, False = Number grows to the left. Defaults to false.
--Returns the value inserted when pressing ENTER, or nil if focus is lost (touch signal not in box).
function gui.numberInput(x, y, maxWidth, startValue, startLeft, delim, minValue, maxValue)
    x = x or 1
    y = y or 1
    maxWidth = maxWidth or 15
    startValue = startValue or 0
    startLeft = startLeft or false
    delim = delim or " "
    local number = startValue
    local padded = parser.splitNumber(tonumber(number), delim)
    if startLeft then
        padded = padded.."_"
        for i = 1, maxWidth-#padded do padded = padded.." " end
    else
        for i = 1, maxWidth-#padded do padded = " "..padded end
        padded = padded.."_"
    end
    graphics.text(x, -1+2*y, padded, accentColor)
    renderer.multicast()
    local value = 0
    local function checkExit(_, _, X, Y)
        if X < x or X > x+maxWidth or Y ~= y then
            value = -1
        end
    end
    local focusListener = event.listen("touch", checkExit)
    while value ~= 13 and value ~= -1 and value ~= 9 do
        local _, _, key, _, _ = event.pull(0.05, "key_down")
        if key ~= nil then
            value = key
            if #parser.splitNumber(tonumber(number), delim) < maxWidth then
                if (key >= 48 and key <= 57) or key == 45 then
                    if key == 45 then
                        number = -number
                    else
                        number = tonumber(tostring(number)..uc.char(key))
                    end
                end
            end
            if key == 8 then
                if number > 9 or number < -9 then
                    number = tonumber(tostring(number):sub(1, -2))
                else
                    number = 0
                end
            end
            padded = parser.splitNumber(tonumber(number), delim)
            if #padded ~= maxWidth then
                if startLeft then
                    padded = padded.."_"
                    for i = 1, maxWidth-#padded do padded = padded.." " end
                else
                    for i = 1, maxWidth-#padded do padded = " "..padded end
                    padded = padded.."_"
                end
            end
            graphics.text(x, -1+2*y, padded, accentColor)
        end
        renderer.multicast()
    end
    event.cancel(focusListener)
    if value == 13 or value == 9 then
        padded = parser.splitNumber(tonumber(number), delim)
        if not startLeft then
            for i = 1, maxWidth-#padded do padded = " "..padded end
        end
        graphics.text(x, -1+2*y, padded.." ", primaryColor)
        renderer.multicast()
        if value == 9 then
            event.push("touch", _, x, y+1)
        end
        if minValue and number < minValue then return minValue end
        if maxValue and number > maxValue then return maxValue end
        return number
    else
        padded = parser.splitNumber(tonumber(startValue),delim)
        if not startLeft then
            for i = 1, maxWidth-#padded do padded = " "..padded end
        end
        graphics.text(x, -1+2*y, padded.." ", primaryColor)
        renderer.multicast()
        return nil
    end
end

local function compareColors(a,b)
    return a[2] < b[2]
  end
--Color selection return the color value that was selected, or nil if click was not in the box.
function gui.colorSelection(x, y, colorList)
    local context = graphics.context()
    local maxX = context.width
    local maxY = context.height
    local gpu = context.gpu
    local colorTable = {}
    local longestName = 0
    if x < 0 then
        x = renderer.getX()
    end
    if y < 0 then
        y = renderer.getY()
    end
    for name, value in pairs(colorList) do
        if type(name) == "string" then
            if #name > longestName then longestName = #name end
            table.insert(colorTable, {name, value})
        end
    end
    table.sort(colorTable, compareColors)
    local height = #colorTable + 4
    if maxX <= (x+longestName+5) then x = maxX-(longestName+4) end
    if maxY <= (y+height) then y = maxY-(height-1) end
    local page = gpu.allocateBuffer(longestName+5, height)
    gpu.setActiveBuffer(page)
    graphics.rectangle(1, 1, 5+longestName, 6+2*#colorTable, borderColor)
    graphics.rectangle(5, 3, longestName, 2+2*#colorTable, colors.black)
    graphics.text(5, 3, "Custom")
    for i = 1, #colorTable do
        graphics.text(5, 3+2*i, colorTable[i][1], colorTable[i][2])
        graphics.rectangle(2, 3+2*i, 2, 2, colorTable[i][2])
    end
    gpu.setActiveBuffer(0)
    local background = gpu.allocateBuffer(longestName+5, height)
    gpu.bitblt(background, 1, 1, maxY, maxX, 0, y, x)
    gpu.bitblt(_, x, y, maxX, maxY, page)
    renderer.setFocus()
    renderer.multicast()
    local _, _, touchX, touchY, button, _ = event.pull(_, "touch")
    local customColor = nil
    if touchY == y + 1 then
        customColor = gui.textInput(x+4, y+1, 8, "0x")
    end
    renderer.leaveFocus()
    gpu.bitblt(0, x, y, maxX, maxY, background)
    renderer.multicast()
    gpu.freeBuffer(page)
    gpu.freeBuffer(background)
    if touchX > x and touchX < x+longestName+4 and touchY > y and touchY < y+height then
        if touchY == y + 1 then
            if customColor ~= nil then
                return tonumber(customColor), "Custom", longestName
            else
                return nil
            end
        end
        return colorTable[touchY-y-1][2], colorTable[touchY-y-1][1], longestName
    else
        return nil
    end
end

--There are two drop-down menus: Color selection and arbitrary list
--These have prioritized click capture and are rendered without the need to call renderer.update(), and are removed as soon as the screen is clicked.

--Arbitrary list returns the value of the object that was clicked, or calls the function assigned with predeteremined arguments.
--
--To use the arbitrary list, you need to provide it with objects in the following format:
--dropDownChoices = {
--        {
--            displayName = "Name on the dropdown menu"),
--            value = theFunctionToCall or "Value to return"
--            args = {arg1, arg2, arg3, ...} or nil
--        },
--        {
--            displayName = "Name on the dropdown menu"),
--            value = theFunctionToCall or "Value to return"
--            args = {arg1, arg2, arg3, ...} or nil
--        }
--    }
--The drop-down menu is then created as follows:
--gui.selectionMenu(x, y, dropDownChoices)
function gui.selectionBox(x, y, choices)
    local context = graphics.context()
    local maxX = context.width
    local maxY = context.height
    local gpu = context.gpu
    local longestName = 0
    if type(x) == "function" then
        x = x()
    end
    if type(y) == "function" then
        y = y()
    end

    for i = 1, #choices do
        if #choices[i].displayName > longestName then longestName = #choices[i].displayName end
    end
    longestName = longestName + 2
    local height = #choices + 2
    if maxX <= (x+longestName+5) then x = maxX-(longestName+4) end
    if maxY <= (y+height) then y = maxY-(height-1) end
    local page = gpu.allocateBuffer(longestName+2, height)
    gpu.setActiveBuffer(page)
    graphics.rectangle(1, 1, 2+longestName, 1, borderColor)
    graphics.rectangle(1, 4+2*#choices, 2+longestName, 1, borderColor)
    graphics.rectangle(1, 1, 1, 4+2*#choices, borderColor)
    graphics.rectangle(2+longestName, 1, 1, 4+2*#choices, borderColor)
    graphics.rectangle(2, 3, longestName, 2*#choices, colors.black)
    for i = 1, #choices do
        graphics.text(3, 1+2*i, choices[i].displayName, accentColor)
    end
    gpu.setActiveBuffer(0)
    local background = gpu.allocateBuffer(longestName+2, height)
    gpu.bitblt(background, 1, 1, maxY, maxX, 0, y, x)
    gpu.bitblt(_, x, y, maxX, maxY, page)
    renderer.multicast()
    renderer.setFocus()
    local _, _, touchX, touchY, button, _ = event.pull(_, "touch")
    renderer.leaveFocus()
    gpu.bitblt(0, x, y, maxX, maxY, background)
    gpu.freeBuffer(page)
    gpu.freeBuffer(background)
    renderer.multicast()
    if touchX > x and touchX < x+longestName and touchY > y and touchY < y+height-1 then
        if type(choices[touchY-y].value) == "function" then
            choices[touchY-y].value(table.unpack(choices[touchY-y].args))
        else
            return choices[touchY-y].value
        end
    else
        return nil
    end
end

local function setTextAttribute(x, y, tableToModify, tableValue, attribute, maxLength)
    maxLength = maxLength or 50
    local startValue = ""
    test = tableToModify
    if tableValue ~= nil then
        startValue = tableToModify[tableValue][attribute] or "None"
    else
        startValue = tableToModify[attribute] or "None"
    end
    local value = gui.textInput(x, y, maxLength, startValue)
    if value ~= nil then
        if tableValue ~= nil then
            tableToModify[tableValue][attribute] = value
        else
            tableToModify[attribute] = value
            debugtable = tableToModify
        end
    end
end
local function setNumberAttribute(x, y, tableToModify, tableValue, attribute, minValue, maxValue, maxLength)
    maxLength = maxLength or 50
    local startValue = 0
    if tableValue ~= nil then
        startValue = tableToModify[tableValue][attribute] or 0
    else
        startValue = tableToModify[attribute] or 0
    end
    local value = gui.numberInput(x, y, maxLength, startValue, true, "", minValue, maxValue)
    if value ~= nil then
        if tableValue ~= nil then
            tableToModify[tableValue][attribute] = value
        else
            tableToModify[attribute] = value
        end
    end
end

local function setColorAttribute(x, y, tableToModify, tableValue, attribute)
    local value, name, longest = gui.colorSelection(x, y, colors)
    if value ~= nil then
        if tableValue ~= nil then
            tableToModify[tableValue][attribute] = value
            for i = 1, longest-#name do name = name .. " " end
        else
            tableToModify[attribute] = value
            for i = 1, longest-#name do name = name .. " " end
        end
        graphics.text(x, 2*y-1, name, value)
    end
end

local function setBooleanAttribute(x, y, tableToModify, tableValue, attribute)
    local startValue = false
    if tableValue ~= nil then
        startValue = tableToModify[tableValue][attribute] or false
    else
        startValue = tableToModify[attribute] or false
    end
    local value = not startValue
    local color = borderColor
    local displayName = ""
    if value then displayName = "Enabled"; color = primaryColor else displayName = "Disabled" end
    graphics.text(x, y*2-1, displayName.." ", color)
    renderer.multicast()
    if value ~= nil then
        if tableValue ~= nil then
            tableToModify[tableValue][attribute] = value
        else
            tableToModify[attribute] = value
        end
    end
end

local function setComponentAttribute(x, y, tableToModify, tableValue, attribute, componentType, nameTable)
    local startValue = ""
    if type(componentType) == "string" then componentType = {componentType} end
    if tableValue ~= nil then
        startValue = tableToModify[tableValue][attribute] or "None"
    else
        startValue = tableToModify[attribute] or "None"
    end
    local function contains(type)
        for i = 1, #componentType do
            if componentType[i] == type then return true end
        end
        return false
    end
    local components = {}
    for address, component in require("component").list() do
        if contains(component) then
            local displayName = address
            if nameTable ~= nil then
                if nameTable[address] ~= nil then
                    displayName = nameTable[address].name or displayName
                end
            end
            table.insert(components,
            {displayName = displayName,
            value = address,
            args = nil})
        end
    end
    table.insert(components,
    {displayName = "None",
    value = "None",
    args = nil})
    local value = gui.selectionBox(x+2, y, components)
    if value ~= nil then
        if tableValue ~= nil then
            if value == "None" then tableToModify[tableValue][attribute] = nil end
            tableToModify[tableValue][attribute] = value
            graphics.text(x, y*2-1, value, primaryColor)
        else
            if value == "None" then tableToModify[attribute] = nil end
            tableToModify[attribute] = value
            graphics.text(x, y*2-1, value, primaryColor)
        end
    end
end

--Creates a named list of attributes to change, given in attributeData in the format {name="Name", attribute="attr", type="string|number"}
--The attributes to modify should be on the third level of a list: dataTable.dataValue.attribute
--If dataValue is nil, then the main dataTable.attribute is modified instead.
function gui.multiAttributeList(x, y, page, pageTable, attributeData, dataTable, dataValue, maxLength)
    maxLength = maxLength or 20
    dataValue = dataValue or nil
    local longestAttribute = 0
    for i = 1, #attributeData do
        if #attributeData[i].name > longestAttribute then longestAttribute = #attributeData[i].name end
    end
    for i = 1, #attributeData do
        local attribute = attributeData[i].attribute
        local name = attributeData[i].name
        local type = attributeData[i].type
        local displayName = ""
        if dataValue ~= nil then displayName = dataTable[dataValue][attribute] else displayName = dataTable[attribute] end
        graphics.context().gpu.setActiveBuffer(page)
        graphics.text(3, 2*y+2*i-1, name)
        if type == "string" then
            table.insert(pageTable, gui.smallButton(x+longestAttribute, y+i, displayName or attributeData[i].defaultValue or "None", setTextAttribute, {x+longestAttribute+1, y+i, dataTable, dataValue, attribute, maxLength}, maxLength, nil, true))
        elseif type == "number" then
            table.insert(pageTable, gui.smallButton(x+longestAttribute, y+i, displayName or attributeData[i].defaultValue or "None", setNumberAttribute, {x+longestAttribute+1, y+i, dataTable, dataValue, attribute, attributeData[i].minValue, attributeData[i].maxValue, maxLength}))
        elseif type == "color" then
            table.insert(pageTable, gui.smallButton(x+longestAttribute, y+i, colors[displayName] or "Custom", setColorAttribute,
            {x+longestAttribute+1, y+i, dataTable, dataValue, attribute}, _, displayName or attributeData[i].defaultValue))
        elseif type == "boolean" then
            local color = borderColor
            if displayName then displayName = "Enabled"; color = primaryColor else displayName = "Disabled" end
            table.insert(pageTable, gui.smallButton(x+longestAttribute, y+i, displayName, setBooleanAttribute, {x+longestAttribute+1, y+i, dataTable, dataValue, attribute, attributeData[i].defaultValue}, _, color))
        elseif type == "header" then --Do nothing
        elseif type == "component" then
            table.insert(pageTable, gui.smallButton(x+longestAttribute, y+i, displayName or attributeData[i].defaultValue or "None", setComponentAttribute, {x+longestAttribute+1, y+i, dataTable, dataValue, attribute, attributeData[i].componentType, attributeData[i].nameTable}))
        end
    end
    return pageTable
end

function gui.logo(x, y, version, border, primary, accent)
    local bColor = border or borderColor
    local pColor = primary or primaryColor
    local aColor = accent or accentColor
    local logo1 = {
        "█◣  █  ◢  ███◣   ◢█◣  ◢███◣",
        "█◥◣ █  █  █  ◥◣ ◢◤ ◥◣ █   ",
        "█ ◥◣█  █  █   █ █   █ █    ",
        "█  ◥█  █  █   █ █▃▃▃█ ◥███◣",
        "█   █  █  █   █ █   █     █",
        "█   █  █  █  ◢◤ █   █     █",
        "█   █  ◤  ███◤  █   █ ◢███◤"
    }
    local logo2 ={
        " ◢█◣ ",
        "◢◤ ◥◣",
        "█   █",
        "█▃▃▃█",
        "█   █",
        "█   █",
        "█   █"
    }
    --local page = renderer.createObject(x, y, 29, 8)
    --local gpu = graphics.context().gpu
    --gpu.setActiveBuffer(page)
    graphics.text(x+1, y+3, "◢", bColor)
    graphics.text(x+1, y+14, "◥", bColor)
    graphics.rectangle(x+1, y+5, 1, 12, bColor)
    graphics.rectangle(x+2, y+14, 27, 1, bColor)
    graphics.outline(x+3, y+1, logo1, pColor)
    graphics.outline(x+19, y+1, logo2, aColor)
    graphics.text(x+27, y+3, "Ver", aColor)
    graphics.text(x+27, y+5, version, aColor)
    --gpu.setActiveBuffer(0)
end

function gui.smallLogo(x, y, version)
    local logo1 = {
        "▙ ▌▐ ▛▚▗▀▖▞▀",
        "▌▚▌▐ ▌▐▐▄▌▘▗",
        "▌ ▌▐ ▙▞▐ ▌▄▞"
    }
    local logo2 ={
        "▗▀▖",
        "▐▄▌",
        "▐ ▌",
    }
    local page = renderer.createObject(x, y, 20, 4)
    local gpu = graphics.context().gpu
    gpu.setActiveBuffer(page)
    graphics.text(1, 3, "◢", borderColor)
    graphics.rectangle(1, 5, 1, 4, borderColor)
    graphics.rectangle(2, 8, 18, 1, borderColor)
    graphics.outline(3, 1, logo1, primaryColor)
    graphics.outline(10, 1, logo2, accentColor)
    graphics.text(16, 5, version, accentColor)
    graphics.text(20, 5, "◢", borderColor)
    graphics.text(20, 7, "◤", borderColor)
    gpu.setActiveBuffer(0)
end

--Unwrapped text box allowing for multiple instances of graphics.text() to be drawn at once
--Supports drawing blank lines by omitting input.name
--The input argument is a table with the following format:
--input = {
--    {
--        text = "[string to display]",
--        color = [color used, optional]
--    },{
--        text = "[string to display]",
--        color = [color used, optional]
--    }
--}
function gui.multiLineText(x, y, input, defaultColor)
    local defaultColor = defaultColor or gui.primaryColor()
    for i = 1, #input do
        if input[i].text then
            graphics.text(x, y + i, input[i].text, input[i].color or defaultColor, true)
        end
    end
end

return gui