local function exec(multiblock)
    local maxProgress = multiblock:getWorkMaxProgress() or 0

    if maxProgress > 0 then
        local probablyUsesString = multiblock:getSensorInformation()[3]
        local noCommaString = string.gsub(probablyUsesString, ",", "")
        local estimate = "0"
        pcall(
            function()
                estimate = string.sub(noCommaString, string.find(noCommaString, "%bc§"))
            end
        )
        return tonumber((string.gsub(string.gsub(estimate, "c", ""), "§", "")))
    else
        return 0
    end
end

return exec
