local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")

local SCRIPT_URL = "TWOJ_URL_DO_SCRIPTU"

local FILE = "MyGuiToggle.json"

local function loadToggle()
    local ok, data = pcall(function()
        return readfile(FILE)
    end)
    if ok and data then
        local ok2, decoded = pcall(function()
            return HttpService:JSONDecode(data)
        end)
        if ok2 and decoded then
            return decoded.on
        end
    end
    return false
end

local function saveToggle(state)
    pcall(function()
        writefile(FILE, HttpService:JSONEncode({on = state}))
    end)
end

local sg = Instance.new("ScreenGui")
sg.Name = "MyGui"
sg.Parent = CoreGui

local f = Instance.new("Frame")
f.Size = UDim2.new(0, 200, 0, 160)
f.Position = UDim2.new(0.5, -100, 0.5, -80)
f.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
f.Active = true
f.Draggable = true
f.Parent = sg

local x = Instance.new("TextButton")
x.Size = UDim2.new(0, 25, 0, 25)
x.Position = UDim2.new(1, -25, 0, 0)
x.Text = "X"
x.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
x.TextColor3 = Color3.new(1, 1, 1)
x.Parent = f
x.MouseButton1Click:Connect(function()
    sg:Destroy()
end)

local toggle = Instance.new("TextButton")
toggle.Size = UDim2.new(0, 80, 0, 30)
toggle.Position = UDim2.new(0.5, -40, 0.5, -40)
toggle.Text = "OFF"
toggle.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
toggle.TextColor3 = Color3.new(1, 1, 1)
toggle.Parent = f

local rejoinBtn = Instance.new("TextButton")
rejoinBtn.Size = UDim2.new(0, 80, 0, 30)
rejoinBtn.Position = UDim2.new(0.5, -40, 0.5, 10)
rejoinBtn.Text = "REJOIN"
rejoinBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 160)
rejoinBtn.TextColor3 = Color3.new(1, 1, 1)
rejoinBtn.Parent = f

local on = loadToggle()
toggle.Text = on and "ON" or "OFF"
toggle.BackgroundColor3 = on and Color3.fromRGB(50, 180, 50) or Color3.fromRGB(60, 60, 60)

local function startLoop()
    task.spawn(function()
        while on do
            pcall(function()
                local Event = game:GetService("ReplicatedStorage").Packages.Networking["RF/Treadmill/AskWearStill"]
                Event:InvokeServer()
            end)
            task.wait(5)
        end
    end)
end

if on then
    startLoop()
end

toggle.MouseButton1Click:Connect(function()
    on = not on
    toggle.Text = on and "ON" or "OFF"
    toggle.BackgroundColor3 = on and Color3.fromRGB(50, 180, 50) or Color3.fromRGB(60, 60, 60)
    saveToggle(on)
    if on then
        startLoop()
    end
end)

rejoinBtn.MouseButton1Click:Connect(function()
    saveToggle(on)
    local code = "loadstring(game:HttpGet('" .. SCRIPT_URL .. "'))()"
    if syn and syn.queue_on_teleport then
        syn.queue_on_teleport(code)
    elseif queue_on_teleport then
        queue_on_teleport(code)
    elseif fluxus and fluxus.queue_on_teleport then
        fluxus.queue_on_teleport(code)
    elseif krnl and krnl.queue_on_teleport then
        krnl.queue_on_teleport(code)
    end
    TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, Players.LocalPlayer)
end)