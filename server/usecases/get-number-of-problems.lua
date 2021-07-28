local function exec(problemsString)
    local problems = "0"
    pcall(
        function()
            problems = string.sub(problemsString, string.find(problemsString, "c%d"))
        end
    )
    return tonumber((string.gsub(problems, "c", "")))
end

return exec
