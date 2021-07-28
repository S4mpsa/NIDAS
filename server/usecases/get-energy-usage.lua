local function exec(probablyUsesString)
    local noCommaString = string.gsub(probablyUsesString, ",", "")
    local estimate = "0"
    pcall(function()
        estimate =
            string.sub(noCommaString, string.find(noCommaString, "%bc§"))
    end)
    return tonumber((string.gsub(string.gsub(estimate, "c", ""), "§", "")))

end

return exec
