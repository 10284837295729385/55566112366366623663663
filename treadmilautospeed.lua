-- ================= Roblox (executor) =================
-- Uruchom w executorze Potassium

local HttpService       = game:GetService("HttpService")
local Players           = game:GetService("Players")
local TeleportService   = game:GetService("TeleportService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui           = game:GetService("CoreGui")
local TweenService      = game:GetService("TweenService")
local RunService        = game:GetService("RunService")

local CMD_FILE    = "MyGuiCmd.txt"
local STATUS_FILE = "MyGuiStatus.txt"
local STATS_FILE  = "MyGuiStats.json"
local STATE_FILE  = "MyGuiState.json"
local SCRIPT_URL  = "https://raw.githubusercontent.com/10284837295729385/55566112366366623663663/refs/heads/main/treadmilautospeed.lua"

local LP = Players.LocalPlayer

-- ---------- pomocnicze ----------
local function readJson(file, default)
    local ok, data = pcall(readfile, file)
    if ok and data and data ~= "" then
        local ok2, d = pcall(function() return HttpService:JSONDecode(data) end)
        if ok2 and d then return d end
    end
    return default
end

local function writeJson(file, tbl)
    pcall(writefile, file, HttpService:JSONEncode(tbl))
end

-- ============================================================
-- BYPASSY
-- ============================================================
pcall(function()
    local getgc        = getgc or (debug and debug.getgc)
    local getconstants = getconstants or (debug and debug.getconstants)
    local setconstant  = setconstant or (debug and debug.setconstant)
    local islclosure   = islclosure or function(F) return not pcall(setfenv, getfenv(F)) end
    if getgc and getconstants and setconstant then
        for _, Function in ipairs(getgc(true)) do
            if typeof(Function) == "function" and islclosure(Function) then
                local ok, src = pcall(debug.info, Function, "s")
                if ok and type(src) == "string"
                   and src:find("ReplicatedFirst", 1, true)
                   and src:find("UGI", 1, true) then
                    local okC, consts = pcall(getconstants, Function)
                    if okC and type(consts) == "table" then
                        for i, c in next, consts do
                            if type(c) == "string" and c == "Humanoid" then
                                pcall(setconstant, Function, i, "")
                            end
                        end
                    end
                end
            end
        end
    end
end)

pcall(function()
    local getgc        = getgc or (debug and debug.getgc)
    local getconstants = getconstants or (debug and debug.getconstants)
    local islclosure   = islclosure or function(fn) return not pcall(setfenv, getfenv(fn)) end
    local HookFn       = hookfunction or replaceclosure or hookfunc
    if getgc and getconstants and HookFn and debug and debug.getstack and debug.setstack then
        for _, fn in ipairs(getgc(true)) do
            if typeof(fn) == "function" and islclosure(fn) then
                local ok, consts = pcall(getconstants, fn)
                if ok and type(consts) == "table" and table.find(consts, "X-14") then
                    local cb
                    cb = HookFn(fn, function(...)
                        local stack = debug.getstack(1)
                        if type(stack) == "table" then
                            for idx, val in pairs(stack) do
                                if val == "X-14" then
                                    pcall(debug.setstack, 1, idx, nil)
                                end
                            end
                        end
                        if cb then return cb(...) end
                    end)
                end
            end
        end
    end
end)

pcall(function()
    if typeof(filtergc) ~= "function" or typeof(debug.getupvalues) ~= "function" then return end
    local ok, fn = pcall(function()
        return filtergc("function", { Constants = { "gmatch", "GetFullName" } }, true)
    end)
    if not ok or type(fn) ~= "function" then return end
    local setMeta = (typeof(setrawmetatable) == "function" and setrawmetatable)
                 or (typeof(setmetatable) == "function" and setmetatable)
    if not setMeta then return end
    local okUv, ups = pcall(debug.getupvalues, fn)
    if not okUv or type(ups) ~= "table" then return end
    for _, tbl in pairs(ups) do
        if typeof(tbl) == "table" then
            pcall(setMeta, tbl, { __newindex = function() end })
        end
    end
end)

pcall(function()
    local getgc   = getgc or (debug and debug.getgc)
    local setmeta = setrawmetatable or setmetatable
    local getmeta = getrawmetatable or getmetatable
    if getgc and setmeta then
        for _, obj in ipairs(getgc(true)) do
            if typeof(obj) == "table" and not (getmeta and getmeta(obj)) then
                local mainrun = false
                for _, v in pairs(obj) do
                    if v == obj then mainrun = true; break end
                end
                if mainrun then
                    for _, v in pairs(obj) do
                        if typeof(v) == "number" and v >= 1 and v <= 3 and obj[v] == nil then
                            pcall(setmeta, obj, { __newindex = function() end })
                            break
                        end
                    end
                end
            end
        end
    end
end)

pcall(function()
    local pps = game:GetService("ProximityPromptService")
    pps.PromptButtonHoldBegan:Connect(function(prompt, player)
        if player == LP and tostring(prompt) == "CarryAreaEgg" then
            prompt.HoldDuration = 0
        end
    end)
end)

-- ============================================================
-- BYPASS ANTY-COFANIE
-- ============================================================
local BYPASS_LEG_OFFSET = Vector3.new(0, -6.7, 0)
local BYPASS_TP_OFFSET  = Vector3.new(0, 6.7, 0)

local function getHRP()
    local ch = LP.Character
    return ch and ch:FindFirstChild("HumanoidRootPart")
end

local function heartbeatTP(cframeTarget, holdTime)
    local hrp = getHRP()
    if not hrp then return end
    local ch = LP.Character
    if ch then
        for _, part in ipairs(ch:GetDescendants()) do
            if part:IsA("BasePart") then
                pcall(function() part.CanCollide = false end)
            end
        end
    end
    local conn
    conn = RunService.Heartbeat:Connect(function()
        local r = getHRP()
        if r and r.Parent then
            r.CFrame = cframeTarget
            r.AssemblyLinearVelocity = Vector3.zero
            r.AssemblyAngularVelocity = Vector3.zero
        end
    end)
    task.wait(holdTime or 0.25)
    if conn then conn:Disconnect() end
    local r2 = getHRP()
    if r2 then
        r2.CFrame = cframeTarget
        r2.AssemblyLinearVelocity = Vector3.zero
        r2.AssemblyAngularVelocity = Vector3.zero
    end
end

local function bypassReturnTP(safeCFrame, holdTime)
    local hrp = getHRP()
    if not hrp then return false end
    local targetPart = workspace:FindFirstChild("SpawnLocation", true)
    if not targetPart or not targetPart:IsA("BasePart") then
        heartbeatTP(safeCFrame, holdTime or 0.3)
        return true
    end
    pcall(function() targetPart.CanCollide = false end)
    local ch = LP.Character
    if ch then
        for _, part in ipairs(ch:GetDescendants()) do
            if part:IsA("BasePart") then
                pcall(function() part.CanCollide = false end)
            end
        end
    end
    local conn
    conn = RunService.Heartbeat:Connect(function()
        local r = getHRP()
        if not r or not r.Parent then return end
        pcall(function() targetPart.CFrame = r.CFrame * CFrame.new(BYPASS_LEG_OFFSET) end)
        r.CFrame = safeCFrame + BYPASS_TP_OFFSET
        r.AssemblyLinearVelocity = Vector3.zero
        r.AssemblyAngularVelocity = Vector3.zero
        pcall(function() targetPart.CFrame = safeCFrame end)
    end)
    task.wait(holdTime or 0.35)
    if conn then conn:Disconnect() end
    local r2 = getHRP()
    if r2 then
        r2.CFrame = safeCFrame
        r2.AssemblyLinearVelocity = Vector3.zero
        r2.AssemblyAngularVelocity = Vector3.zero
    end
    return true
end

-- ---------- plot ----------
local function getMyPlot()
    local plots = workspace:FindFirstChild("Plots")
    if not plots then return nil end
    for _, plot in ipairs(plots:GetChildren()) do
        local nameLabel = plot:FindFirstChild("PlayerName", true)
        if nameLabel and nameLabel:IsA("TextLabel") then
            if nameLabel.Text == LP.Name or nameLabel.Text == LP.DisplayName then
                return plot
            end
        end
    end
    return nil
end

local function getPlotCenter()
    local plot = getMyPlot()
    if plot then
        local center = plot.PrimaryPart or plot:FindFirstChild("CenterPoint", true)
        if center and center:IsA("BasePart") then
            return Vector3.new(center.Position.X, math.max(center.Position.Y, 70.4), center.Position.Z)
        end
    end
    return Vector3.new(522.8, 70.4, -245.1)
end

local function getTreadmillSign()
    local plot = getMyPlot()
    if not plot then return nil end
    local treadmill = plot:FindFirstChild("TreadmillUpgrade", true)
    if not treadmill then return nil end
    local sign = treadmill:FindFirstChild("Sign", true)
    if not sign then
        for _, d in ipairs(treadmill:GetDescendants()) do
            if d.Name:lower():find("sign") then sign = d; break end
        end
    end
    if not sign then return nil end
    if sign:IsA("BasePart") then return sign end
    return sign:FindFirstChildWhichIsA("BasePart", true)
end

local function teleportToSign()
    local sign = getTreadmillSign()
    if not sign then return false end
    if not getHRP() then return false end
    local targetCFrame = CFrame.new(sign.Position + Vector3.new(0, 3, 0))
    local ok = pcall(bypassReturnTP, targetCFrame, 0.35)
    if not ok then heartbeatTP(targetCFrame, 0.35) end
    return true
end

-- ---------- stan ----------
local state = readJson(STATE_FILE, {
    startSpeed = nil,
    moneyBase  = nil,
    eventCount = 0,
})

local on = readJson("MyGuiToggle.json", {on = false}).on
pcall(writefile, STATUS_FILE, on and "1" or "0")

-- ---------- dane ----------
local function getSpeed()
    local ok, v = pcall(function()
        return tonumber(Players.LocalPlayer.leaderstats.Speed.Value)
    end)
    return ok and v or 0
end

local function getMoneyRaw()
    local ok, v = pcall(function()
        return Players.LocalPlayer.PlayerGui.HUD.GameHUD.BottomLeft.Money.Value.Text
    end)
    if ok and v ~= nil then return tostring(v) end
    return "0"
end

local function getMoneyNum()
    local s = getMoneyRaw()
    local mult = 1
    local num = s
    local suffix = s:match("([KkMmBbTt])%s*$")
    if suffix then
        suffix = suffix:upper()
        if suffix == "K" then mult = 1e3
        elseif suffix == "M" then mult = 1e6
        elseif suffix == "B" then mult = 1e9
        elseif suffix == "T" then mult = 1e12 end
        num = s:gsub("[KkMmBbTt%s%$%,]", "")
    else
        num = s:gsub("[%s%$%,]", "")
    end
    local parsed = tonumber(num)
    if not parsed then return 0 end
    return parsed * mult
end

if state.startSpeed == nil then state.startSpeed = getSpeed() end
if state.moneyBase  == nil then state.moneyBase  = getMoneyNum() end

local sessionStart = tick()
local function getUptime() return tick() - sessionStart end

local lastSpeed = getSpeed()
local lastSpeedT = tick()
local speedPerSec = 0

task.spawn(function()
    while true do
        task.wait(1)
        local now = tick()
        local sp = getSpeed()
        local dt = now - lastSpeedT
        if dt > 0 then
            local delta = sp - lastSpeed
            if delta >= 0 then
                speedPerSec = speedPerSec * 0.7 + (delta / dt) * 0.3
            end
        end
        lastSpeed = sp
        lastSpeedT = now
    end
end)

-- ---------- eventy ----------
local function fireEventOn()
    pcall(function()
        ReplicatedStorage.Packages.Networking["RF/Treadmill/AskWearStill"]:InvokeServer()
    end)
    state.eventCount = (state.eventCount or 0) + 1
end

local function fireEventOff()
    pcall(function()
        ReplicatedStorage.Packages.Networking["RF/Treadmill/AskDoff"]:InvokeServer()
    end)
end

local function startLoop()
    task.spawn(function()
        local ok = teleportToSign()
        if not ok then
            task.wait(0.5)
            teleportToSign()
        end
        task.wait(0.5)

        while on do
            local sign = getTreadmillSign()
            local hrp = getHRP()
            if sign and hrp then
                local dist = (hrp.Position - sign.Position).Magnitude
                if dist > 15 then
                    teleportToSign()
                    task.wait(0.4)
                end
            end
            fireEventOn()
            task.wait(5)
        end
    end)
end

if on then startLoop() end

local function queueScript()
    local code = "loadstring(game:HttpGet('" .. SCRIPT_URL .. "'))()"
    if syn and syn.queue_on_teleport then syn.queue_on_teleport(code)
    elseif queue_on_teleport then queue_on_teleport(code)
    elseif fluxus and fluxus.queue_on_teleport then fluxus.queue_on_teleport(code)
    elseif krnl and krnl.queue_on_teleport then krnl.queue_on_teleport(code) end
end

queueScript()

-- ================== GUI ==================
local COLORS = {
    bg1       = Color3.fromRGB(18, 18, 24),
    bg2       = Color3.fromRGB(28, 28, 38),
    accentOn  = Color3.fromRGB(46, 204, 113),
    accentOff = Color3.fromRGB(231, 76, 60),
    accentBlu = Color3.fromRGB(52, 152, 219),
    accentPur = Color3.fromRGB(155, 89, 182),
    text      = Color3.fromRGB(240, 240, 245),
    textDim   = Color3.fromRGB(160, 160, 175),
    stroke    = Color3.fromRGB(255, 255, 255, 0.08),
}

local sg = Instance.new("ScreenGui")
sg.Name = "MyGui"
sg.Parent = CoreGui
sg.IgnoreGuiInset = true
sg.ResetOnSpawn = false

local main = Instance.new("Frame")
main.Size = UDim2.new(0, 240, 0, 300)
main.Position = UDim2.new(0.5, -120, 0.5, -150)
main.BackgroundColor3 = COLORS.bg1
main.BorderSizePixel = 0
main.Active = true
main.Draggable = true
main.Parent = sg

local mainCorner = Instance.new("UICorner", main)
mainCorner.CornerRadius = UDim.new(0, 14)

local mainStroke = Instance.new("UIStroke", main)
mainStroke.Color = COLORS.stroke
mainStroke.Thickness = 1

local mainGradient = Instance.new("UIGradient", main)
mainGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, COLORS.bg2),
    ColorSequenceKeypoint.new(1, COLORS.bg1),
})
mainGradient.Rotation = 135

local topbar = Instance.new("Frame")
topbar.Size = UDim2.new(1, 0, 0, 34)
topbar.BackgroundTransparency = 1
topbar.Parent = main

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -60, 1, 0)
title.Position = UDim2.new(0, 14, 0, 0)
title.BackgroundTransparency = 1
title.Text = "✦  PANEL"
title.TextColor3 = COLORS.text
title.Font = Enum.Font.GothamBold
title.TextSize = 14
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = topbar

local dot = Instance.new("Frame")
dot.Size = UDim2.new(0, 8, 0, 8)
dot.Position = UDim2.new(1, -68, 0.5, -4)
dot.BackgroundColor3 = COLORS.accentOff
dot.BorderSizePixel = 0
dot.Parent = topbar
local dotCorner = Instance.new("UICorner", dot)
dotCorner.CornerRadius = UDim.new(1, 0)

local statusPulse = Instance.new("UIStroke", dot)
statusPulse.Color = COLORS.accentOff
statusPulse.Thickness = 2
statusPulse.Transparency = 0.5

local statusText = Instance.new("TextLabel")
statusText.Size = UDim2.new(0, 40, 1, 0)
statusText.Position = UDim2.new(1, -58, 0, 0)
statusText.BackgroundTransparency = 1
statusText.Text = "OFF"
statusText.TextColor3 = COLORS.accentOff
statusText.Font = Enum.Font.GothamBold
statusText.TextSize = 11
statusText.TextXAlignment = Enum.TextXAlignment.Left
statusText.Parent = topbar

local close = Instance.new("TextButton")
close.Size = UDim2.new(0, 26, 0, 26)
close.Position = UDim2.new(1, -32, 0, 4)
close.BackgroundColor3 = Color3.fromRGB(60, 30, 35)
close.Text = "×"
close.TextColor3 = Color3.fromRGB(255, 120, 120)
close.Font = Enum.Font.GothamBold
close.TextSize = 18
close.AutoButtonColor = false
close.Parent = topbar
local closeCorner = Instance.new("UICorner", close)
closeCorner.CornerRadius = UDim.new(0, 8)

close.MouseEnter:Connect(function()
    TweenService:Create(close, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(200, 50, 60)}):Play()
end)
close.MouseLeave:Connect(function()
    TweenService:Create(close, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(60, 30, 35)}):Play()
end)
close.MouseButton1Click:Connect(function()
    local out = TweenService:Create(main, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
        Size = UDim2.new(0, 0, 0, 0),
        Position = UDim2.new(0.5, 0, 0.5, 0),
    })
    out:Play()
    out.Completed:Connect(function() sg:Destroy() end)
end)

local sep = Instance.new("Frame")
sep.Size = UDim2.new(1, -20, 0, 1)
sep.Position = UDim2.new(0, 10, 0, 36)
sep.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
sep.BackgroundTransparency = 0.9
sep.BorderSizePixel = 0
sep.Parent = main

local function makeInfoBox(y, label, accent)
    local box = Instance.new("Frame")
    box.Size = UDim2.new(1, -20, 0, 38)
    box.Position = UDim2.new(0, 10, 0, y)
    box.BackgroundColor3 = Color3.fromRGB(35, 35, 48)
    box.BorderSizePixel = 0
    box.Parent = main

    local c = Instance.new("UICorner", box)
    c.CornerRadius = UDim.new(0, 10)

    local s = Instance.new("UIStroke", box)
    s.Color = accent
    s.Thickness = 1
    s.Transparency = 0.7

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -14, 0, 14)
    lbl.Position = UDim2.new(0, 10, 0, 4)
    lbl.BackgroundTransparency = 1
    lbl.Text = label
    lbl.TextColor3 = COLORS.textDim
    lbl.Font = Enum.Font.GothamMedium
    lbl.TextSize = 9
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = box

    local val = Instance.new("TextLabel")
    val.Size = UDim2.new(1, -14, 0, 18)
    val.Position = UDim2.new(0, 10, 0, 16)
    val.BackgroundTransparency = 1
    val.Text = "-"
    val.TextColor3 = COLORS.text
    val.Font = Enum.Font.GothamBold
    val.TextSize = 14
    val.TextXAlignment = Enum.TextXAlignment.Left
    val.Parent = box

    return val
end

local uptimeVal    = makeInfoBox(46, "CZAS PRACY", COLORS.accentPur)
local speedVal     = makeInfoBox(88, "SPEED  •  ZYSK", COLORS.accentOn)
local speedRateVal = makeInfoBox(130, "SPEED / GODZINA", COLORS.accentBlu)
local moneyVal     = makeInfoBox(172, "MONEY  •  ZYSK", Color3.fromRGB(241, 196, 15))

local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(1, -20, 0, 40)
toggleBtn.Position = UDim2.new(0, 10, 0, 220)
toggleBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 75)
toggleBtn.Text = "OFF"
toggleBtn.TextColor3 = COLORS.text
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.TextSize = 15
toggleBtn.AutoButtonColor = false
toggleBtn.Parent = main
local tbCorner = Instance.new("UICorner", toggleBtn)
tbCorner.CornerRadius = UDim.new(0, 12)

local rejoinBtn = Instance.new("TextButton")
rejoinBtn.Size = UDim2.new(1, -20, 0, 24)
rejoinBtn.Position = UDim2.new(0, 10, 0, 264)
rejoinBtn.BackgroundColor3 = Color3.fromRGB(40, 70, 110)
rejoinBtn.Text = "REJOIN"
rejoinBtn.TextColor3 = COLORS.text
rejoinBtn.Font = Enum.Font.GothamBold
rejoinBtn.TextSize = 11
rejoinBtn.AutoButtonColor = false
rejoinBtn.Parent = main
local rbCorner = Instance.new("UICorner", rejoinBtn)
rbCorner.CornerRadius = UDim.new(0, 8)

local function updateToggleUI()
    local targetBg = on and COLORS.accentOn or Color3.fromRGB(60, 60, 75)
    local targetText = on and "ON" or "OFF"
    local targetDot = on and COLORS.accentOn or COLORS.accentOff
    TweenService:Create(toggleBtn, TweenInfo.new(0.2), {BackgroundColor3 = targetBg}):Play()
    TweenService:Create(dot, TweenInfo.new(0.2), {BackgroundColor3 = targetDot}):Play()
    TweenService:Create(statusPulse, TweenInfo.new(0.2), {Color = targetDot}):Play()
    toggleBtn.Text = targetText
    statusText.Text = targetText
    statusText.TextColor3 = targetDot
end
updateToggleUI()

toggleBtn.MouseEnter:Connect(function()
    if not on then
        TweenService:Create(toggleBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(80, 80, 95)}):Play()
    end
end)
toggleBtn.MouseLeave:Connect(function()
    if not on then
        TweenService:Create(toggleBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(60, 60, 75)}):Play()
    end
end)
rejoinBtn.MouseEnter:Connect(function()
    TweenService:Create(rejoinBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(52, 100, 160)}):Play()
end)
rejoinBtn.MouseLeave:Connect(function()
    TweenService:Create(rejoinBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(40, 70, 110)}):Play()
end)

task.spawn(function()
    while sg.Parent do
        task.wait(0.5)
        local t = Instance.new("Tween")
        t.Instance = statusPulse
        t.Time = 0.5
        t.Property = "Transparency"
        t.Style = Enum.EasingStyle.Sine
        t.Direction = Enum.EasingDirection.InOut
        t.Goal = {Transparency = statusPulse.Transparency == 0.5 and 0.9 or 0.5}
        t:Play()
    end
end)

-- ---------- komendy ----------
local function writeToggle()
    writeJson("MyGuiToggle.json", {on = on})
    pcall(writefile, STATUS_FILE, on and "1" or "0")
end

local function doToggle()
    on = not on
    writeToggle()
    updateToggleUI()
    if on then
        startLoop()
    else
        fireEventOff()
    end
end

local function doRejoin()
    writeJson(STATE_FILE, state)
    writeToggle()
    queueScript()
    TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, Players.LocalPlayer)
end

local function doOff()
    if on then fireEventOff() end
    on = false
    writeToggle()
    updateToggleUI()
end

local function doReset()
    state.startSpeed = getSpeed()
    state.moneyBase  = getMoneyNum()
    state.eventCount = 0
    sessionStart = tick()
    writeJson(STATE_FILE, state)
end

toggleBtn.MouseButton1Click:Connect(doToggle)
rejoinBtn.MouseButton1Click:Connect(doRejoin)

-- ---------- live update UI ----------
local function fmtNum(n)
    n = tostring(math.floor(n or 0))
    local k
    while true do
        n, k = n:gsub("^(-?%d+)(%d%d%d)", "%1 %2")
        if k == 0 then break end
    end
    return n
end

local function fmtTime(sec)
    sec = math.floor(sec)
    local h = math.floor(sec/3600)
    local m = math.floor((sec%3600)/60)
    local s = sec%60
    if h > 0 then return h.."h "..m.."m "..s.."s" end
    if m > 0 then return m.."m "..s.."s" end
    return s.."s"
end

task.spawn(function()
    while sg.Parent do
        task.wait(0.25)
        local sp = getSpeed()
        local mn = getMoneyRaw()
        local perHour = speedPerSec * 3600

        uptimeVal.Text = fmtTime(getUptime())
        speedVal.Text = fmtNum(sp) .. "  (+" .. fmtNum(sp - (state.startSpeed or sp)) .. ")"
        speedRateVal.Text = "+" .. fmtNum(perHour) .. " /h"
        moneyVal.Text = tostring(mn) .. "  (+" .. fmtNum(getMoneyNum() - (state.moneyBase or getMoneyNum())) .. ")"
    end
end)

-- ---------- stats file ----------
local function writeStats()
    local sp  = getSpeed()
    local mn  = getMoneyNum()
    local txt = getMoneyRaw()

    writeJson(STATS_FILE, {
        uptime       = getUptime(),
        speed        = sp,
        speedGain    = sp - (state.startSpeed or sp),
        speedPerSec  = speedPerSec,
        speedPerHour = speedPerSec * 3600,
        money        = mn,
        moneyText    = txt,
        moneyGain    = mn - (state.moneyBase or mn),
        eventCount   = state.eventCount or 0,
        enabled      = on,
    })
end

task.spawn(function()
    while true do
        task.wait(0.25)
        writeStats()
    end
end)

-- ---------- komendy z pliku ----------
task.spawn(function()
    while true do
        task.wait(0.25)
        local ok, data = pcall(readfile, CMD_FILE)
        if ok and data and data ~= "" then
            pcall(writefile, CMD_FILE, "")
            local cmd = tostring(data):match("^%s*(.-)%s*$"):lower()
            if cmd == "toggle" then doToggle()
            elseif cmd == "rejoin" then doRejoin()
            elseif cmd == "off" then doOff()
            elseif cmd == "reset" then doReset()
            end
        end
    end
end)

task.spawn(function()
    while sg.Parent do
        task.wait(1)
        local f = readJson("MyGuiToggle.json", {on = on})
        if f.on ~= nil and f.on ~= on then
            local wasOn = on
            on = f.on
            updateToggleUI()
            if on then
                startLoop()
            elseif wasOn then
                fireEventOff()
            end
        end
    end
end)

print("[MyGui] Uruchomiony. OFF wysyla AskDoff.")
