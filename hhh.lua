--[[
  LOST FRONT | Рабочий ESP
  Чистый, быстрый, красивый
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LP = Players.LocalPlayer
local Mouse = LP:GetMouse()

-- ============================================
-- НАСТРОЙКИ (МЕНЯЙ ЗДЕСЬ)
-- ============================================
local Settings = {
    ESP = true,
    ShowBox = true,
    ShowName = true,
    ShowHealth = true,
    ShowDistance = true,
    ShowTracer = true,
}

-- ============================================
-- ОПРЕДЕЛЕНИЕ КОМАНДЫ
-- ============================================
local function getTeam(player)
    local char = player.Character
    if char then
        for _, child in ipairs(char:GetChildren()) do
            if child:IsA("BasePart") and child:FindFirstChild("TeamColor") then
                return child.TeamColor.Name
            end
        end
        local torso = char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")
        if torso then
            return torso.BrickColor.Name
        end
    end
    return "White"
end

-- ============================================
-- ГУИ (МИНИМАЛИСТИЧНОЕ)
-- ============================================
local scr = Instance.new("ScreenGui")
scr.Name = "CapybaraESP"
scr.Parent = LP:WaitForChild("PlayerGui")
scr.ResetOnSpawn = false

local main = Instance.new("Frame")
main.Size = UDim2.new(0, 180, 0, 180)
main.Position = UDim2.new(0, 10, 0, 50)
main.BackgroundColor3 = Color3.fromRGB(15,15,20)
main.BackgroundTransparency = 0.15
main.Active = true
main.Draggable = true
main.Parent = scr
local co = Instance.new("UICorner")
co.CornerRadius = UDim.new(0, 10)
co.Parent = main

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.Position = UDim2.new(0, 0, 0, 5)
title.Text = "🐹 CAPYBARA"
title.TextColor3 = Color3.fromRGB(255,200,80)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.Parent = main

local function toggle(text, y, cb)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 160, 0, 24)
    btn.Position = UDim2.new(0, 10, 0, y)
    btn.Text = text .. ": ON"
    btn.TextColor3 = Color3.fromRGB(80,255,80)
    btn.BackgroundColor3 = Color3.fromRGB(40,40,50)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 13
    btn.Parent = main

    local state = true
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.Text = text .. ": " .. (state and "ON" or "OFF")
        btn.TextColor3 = state and Color3.fromRGB(80,255,80) or Color3.fromRGB(255,80,80)
        cb(state)
    end)
end

toggle("ESP", 35, function(v) Settings.ESP = v end)
toggle("Box", 65, function(v) Settings.ShowBox = v end)
toggle("Name", 95, function(v) Settings.ShowName = v end)
toggle("Health", 125, function(v) Settings.ShowHealth = v end)

-- ============================================
-- ESP (ПРОСТОЙ И РАБОЧИЙ)
-- ============================================
local espObjects = {}

local function createESP()
    local box = Instance.new("Frame")
    box.Size = UDim2.new(0, 50, 0, 80)
    box.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    box.BackgroundTransparency = 0.5
    box.BorderSizePixel = 2
    box.BorderColor3 = Color3.fromRGB(255,255,255)
    box.Parent = scr

    local name = Instance.new("TextLabel")
    name.Size = UDim2.new(0, 120, 0, 16)
    name.Position = UDim2.new(0, -35, 0, -18)
    name.Text = ""
    name.TextColor3 = Color3.fromRGB(255,255,255)
    name.TextStrokeTransparency = 0.5
    name.TextStrokeColor3 = Color3.fromRGB(0,0,0)
    name.BackgroundTransparency = 1
    name.Font = Enum.Font.GothamBold
    name.TextSize = 14
    name.Parent = scr

    local health = Instance.new("Frame")
    health.Size = UDim2.new(0, 50, 0, 4)
    health.Position = UDim2.new(0, 0, 0, 0)
    health.BackgroundColor3 = Color3.fromRGB(0,255,0)
    health.BackgroundTransparency = 0.2
    health.Parent = scr

    local tracer = Instance.new("Frame")
    tracer.Size = UDim2.new(0, 2, 0, 200)
    tracer.BackgroundColor3 = Color3.fromRGB(255,255,255)
    tracer.BackgroundTransparency = 0.4
    tracer.Parent = scr

    return {
        box = box,
        name = name,
        health = health,
        tracer = tracer,
        used = false
    }
end

for i = 1, 20 do
    local obj = createESP()
    obj.box.Visible = false
    obj.name.Visible = false
    obj.health.Visible = false
    obj.tracer.Visible = false
    table.insert(espObjects, obj)
end

local function getESPObject()
    for _, obj in ipairs(espObjects) do
        if not obj.used then
            obj.used = true
            obj.box.Visible = false
            obj.name.Visible = false
            obj.health.Visible = false
            obj.tracer.Visible = false
            return obj
        end
    end
    return nil
end

-- ============================================
-- ОСНОВНОЙ ЦИКЛ
-- ============================================
RunService.RenderStepped:Connect(function()
    -- Сброс всех объектов
    for _, obj in ipairs(espObjects) do
        obj.used = false
        obj.box.Visible = false
        obj.name.Visible = false
        obj.health.Visible = false
        obj.tracer.Visible = false
    end

    if not Settings.ESP then return end

    local centerX = Camera.ViewportSize.X / 2
    local centerY = Camera.ViewportSize.Y / 2
    local myTeam = getTeam(LP)

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr == LP then continue end

        local char = plr.Character
        if not char then continue end
        local humanoid = char:FindFirstChild("Humanoid")
        if not humanoid or humanoid.Health <= 0 then continue end

        -- Показываем только врагов
        if getTeam(plr) == myTeam then continue end

        local root = char:FindFirstChild("HumanoidRootPart")
        if not root then continue end

        local pos, onScreen = Camera:WorldToScreenPoint(root.Position)
        if not onScreen then continue end

        local dist = (root.Position - Camera.CFrame.Position).Magnitude
        local size = math.clamp(300 / dist, 25, 90)

        local esp = getESPObject()
        if not esp then continue end

        -- Бокс
        if Settings.ShowBox then
            esp.box.Size = UDim2.new(0, size, 0, size * 1.8)
            esp.box.Position = UDim2.new(0, pos.X - size/2, 0, pos.Y - size * 1.1)
            esp.box.Visible = true
        end

        -- Имя
        if Settings.ShowName then
            esp.name.Position = UDim2.new(0, pos.X - 60, 0, pos.Y - size * 1.1 - 18)
            esp.name.Text = plr.Name
            esp.name.Visible = true
        end

        -- Здоровье
        if Settings.ShowHealth then
            local hp = humanoid.Health / humanoid.MaxHealth
            esp.health.Size = UDim2.new(hp * size, 0, 0, 4)
            esp.health.Position = UDim2.new(0, pos.X - size/2, 0, pos.Y - size * 1.1 + size * 1.8 + 2)
            esp.health.BackgroundColor3 = Color3.fromRGB(255 * (1 - hp), 255 * hp, 0)
            esp.health.Visible = true
        end

        -- Трассер
        if Settings.ShowTracer then
            esp.tracer.Size = UDim2.new(0, 2, 0, math.abs(pos.Y - centerY))
            esp.tracer.Position = UDim2.new(0, pos.X - 1, 0, math.min(pos.Y, centerY))
            esp.tracer.Visible = true
        end
    end
end)
