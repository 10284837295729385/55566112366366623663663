-- ================= Roblox (executor) =================
-- Uruchom w executorze Potassium

local HttpService       = game:GetService("HttpService")
local Players           = game:GetService("Players")
local TeleportService   = game:GetService("TeleportService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui           = game:GetService("CoreGui")
local RunService        = game:GetService("RunService")

local CMD_FILE    = "MyGuiCmd.txt"
local STATUS_FILE = "MyGuiStatus.txt"
local TOGGLE_FILE = "MyGuiToggle.json"
local STATS_FILE  = "MyGuiStats.json"
local SCRIPT_URL  = "https://raw.githubusercontent.com/10284837295729385/55566112366366623663663/refs/heads/main/treadmilautospeed.lua"

-- ---------- stan ----------
local function loadToggle()
    local ok, data = pcall(readfile, TOGGLE_FILE)
    if ok and data then
        local ok2, d = pcall(function() return HttpService:JSONDecode(data) end)
        if ok2 and d then return d.on end
    end
    return false
end

local function saveToggle(state)
    pcall(writefile, TOGGLE_FILE, HttpService:JSONEncode({on = state}))
    pcall(writefile, STATUS_FILE, state and "1" or "0")
end

local on = loadToggle()
saveToggle(on)

-- ---------- dane ----------
local function getSpeed()
    local ok, v = pcall(function()
        return game:GetService("Players").LocalPlayer.leaderstats.Speed.Value
    end)
    return ok and tonumber(v) or 0
end

local function getMoney()
    local ok, v = pcall(function()
        return game:GetService("Players").LocalPlayer.PlayerGui.HUD.GameHUD.BottomLeft.Money.Value.Text
    end)
    if not ok then return 0 end
    local s = tostring(v):gsub("[^%d%.%-]", "")
    return tonumber(s) or 0
end

local startTime    = tick()
local startSpeed   = getSpeed()
local startMoney   = getMoney()
local eventCount   = 0
local lastSpeed    = startSpeed
local lastSpeedT   = tick()
local speedPerSec  = 0
local lastMoney    = startMoney
local lastMoneyT   = tick()
local moneyPerSec  = 0

-- ---------- akcje ----------
local function fireEvent()
    ReplicatedStorage.Packages.Networking["RF/Treadmill/AskWearStill"]:InvokeServer()
    eventCount = eventCount + 1
end

local function startLoop()
    task.spawn(function()
        while on do
            pcall(fireEvent)
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

-- ---------- gui ----------
local sg = Instance.new("ScreenGui")
sg.Name = "MyGui"
sg.Parent = CoreGui

local f = Instance.new("Frame")
f.Size = UDim2.new(0, 220, 0, 110)
f.Position = UDim2.new(0.5, -110, 0.5, -55)
f.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
f.Active = true
f.Draggable = true
f.Parent = sg

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 25)
title.BackgroundTransparency = 1
title.Text = "Panel (telefon -> gra)"
title.TextColor3 = Color3.new(1, 1, 1)
title.TextScaled = true
title.Parent = f

local status = Instance.new("TextLabel")
status.Size = UDim2.new(1, 0, 0, 40)
status.Position = UDim2.new(0, 0, 0, 30)
status.BackgroundTransparency = 1
status.Text = on and "ON" or "OFF"
status.TextColor3 = on and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(200, 50, 50)
status.TextScaled = true
status.Parent = f

local x = Instance.new("TextButton")
x.Size = UDim2.new(0, 25, 0, 25)
x.Position = UDim2.new(1, -25, 0, 0)
x.Text = "X"
x.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
x.TextColor3 = Color3.new(1, 1, 1)
x.Parent = f
x.MouseButton1Click:Connect(function() sg:Destroy() end)

task.spawn(function()
    while sg.Parent do
        task.wait(0.2)
        status.Text = on and "ON" or "OFF"
        status.TextColor3 = on and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(200, 50, 50)
    end
end)

-- ---------- pomiar tempa ----------
task.spawn(function()
    while true do
        task.wait(1)
        local now = tick()
        local sp  = getSpeed()
        local mn  = getMoney()

        local dtS = now - lastSpeedT
        if dtS > 0 then
            local delta = sp - lastSpeed
            if delta >= 0 then
                speedPerSec = speedPerSec*0.7 + (delta/dtS)*0.3
            end
        end
        lastSpeed = sp
        lastSpeedT = now

        local dtM = now - lastMoneyT
        if dtM > 0 then
            local delta = mn - lastMoney
            if delta >= 0 then
                moneyPerSec = moneyPerSec*0.7 + (delta/dtM)*0.3
            end
        end
        lastMoney = mn
        lastMoneyT = now
    end
end)

-- ---------- zapis statsow ----------
local function writeStats()
    local sp = getSpeed()
    local mn = getMoney()
    local data = {
        uptime      = tick() - startTime,
        speed       = sp,
        speedGain   = sp - startSpeed,
        speedPerSec = speedPerSec,
        money       = mn,
        moneyGain   = mn - startMoney,
        moneyPerSec = moneyPerSec,
        eventCount  = eventCount,
        enabled     = on,
    }
    pcall(writefile, STATS_FILE, HttpService:JSONEncode(data))
end

task.spawn(function()
    while true do
        task.wait(0.5)
        writeStats()
    end
end)

-- ---------- komendy ----------
local function writeStatus()
    pcall(writefile, STATUS_FILE, on and "1" or "0")
end

local function doToggle()
    on = not on
    saveToggle(on)
    if on then startLoop() end
end

local function doRejoin()
    saveToggle(on)
    queueScript()
    TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, Players.LocalPlayer)
end

local function doOff()
    on = false
    saveToggle(false)
end

local function doReset()
    startTime   = tick()
    startSpeed  = getSpeed()
    startMoney  = getMoney()
    eventCount  = 0
    speedPerSec = 0
    moneyPerSec = 0
end

task.spawn(function()
    while true do
        task.wait(0.3)
        local ok, data = pcall(readfile, CMD_FILE)
        if ok and data and data ~= "" then
            pcall(writefile, CMD_FILE, "")
            local cmd = tostring(data):match("^%s*(.-)%s*$"):lower()
            if cmd == "toggle" then doToggle()
            elseif cmd == "rejoin" then doRejoin()
            elseif cmd == "off" then doOff()
            elseif cmd == "reset" then doReset()
            elseif cmd == "status" then writeStatus()
            end
        end
    end
end)

print("[MyGui] Uruchomiony z panelem statystyk.")
