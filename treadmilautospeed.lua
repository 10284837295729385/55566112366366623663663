-- ================= Roblox (executor) =================
-- Uruchom w executorze Potassium

local HttpService       = game:GetService("HttpService")
local Players           = game:GetService("Players")
local TeleportService   = game:GetService("TeleportService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui           = game:GetService("CoreGui")

local CMD_FILE    = "MyGuiCmd.txt"
local STATUS_FILE = "MyGuiStatus.txt"
local STATS_FILE  = "MyGuiStats.json"
local STATE_FILE  = "MyGuiState.json"
local SCRIPT_URL  = "https://raw.githubusercontent.com/10284837295729385/55566112366366623663663/refs/heads/main/treadmilautospeed.lua"

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

-- ---------- stan ----------
local state = readJson(STATE_FILE, {
    startSpeed = nil,
    startMoney = nil,
    moneyBase  = nil,
    eventCount = 0,
})

local on = readJson("MyGuiToggle.json", {on = false}).on
pcall(writefile, STATUS_FILE, on and "1" or "0")

-- ---------- dane z gry ----------
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

-- inicjalizacja bazy
if state.startSpeed == nil then state.startSpeed = getSpeed() end
if state.moneyBase == nil then state.moneyBase = getMoneyNum() end

-- ---------- czas pracy: liczymy w oparciu o tick() z pauza ----------
local sessionStart = tick()

local function getUptime()
    return tick() - sessionStart
end

-- ---------- event ----------
local function fireEvent()
    pcall(function()
        ReplicatedStorage.Packages.Networking["RF/Treadmill/AskWearStill"]:InvokeServer()
    end)
    state.eventCount = (state.eventCount or 0) + 1
end

local function startLoop()
    task.spawn(function()
        while on do
            fireEvent()
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

-- ---------- GUI ----------
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

-- ---------- zapis statsow ----------
local function writeStats()
    local sp  = getSpeed()
    local mn  = getMoneyNum()
    local txt = getMoneyRaw()

    writeJson(STATS_FILE, {
        uptime     = getUptime(),
        speed      = sp,
        speedGain  = sp - (state.startSpeed or sp),
        money      = mn,
        moneyText  = txt,
        moneyGain  = mn - (state.moneyBase or mn),
        eventCount = state.eventCount or 0,
        enabled    = on,
    })
end

task.spawn(function()
    while true do
        task.wait(0.25)
        writeStats()
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
    if on then startLoop() end
end

local function doRejoin()
    writeJson(STATE_FILE, state)
    writeToggle()
    queueScript()
    TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, Players.LocalPlayer)
end

local function doOff()
    on = false
    writeToggle()
end

local function doReset()
    state.startSpeed = getSpeed()
    state.moneyBase  = getMoneyNum()
    state.eventCount = 0
    sessionStart = tick()
    writeJson(STATE_FILE, state)
end

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

print("[MyGui] Uruchomiony.")
