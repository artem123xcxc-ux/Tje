--[[
  LOST FRONT | Custom Script by Capybara
  - ESP (Box, Name, Health, Distance)
  - AIMBOT (FOV, Smooth, Head/Body)
  - INFINITE AMMO
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LP = Players.LocalPlayer
local Mouse = LP:GetMouse()

-- ============================================
-- НАСТРОЙКИ (МЕНЯЙ ЗДЕСЬ)
-- ============================================
local Settings = {
    ESP = true,                    -- Включить ESP
    AIM = true,                    -- Включить AIM
    AIM_HEAD = true,               -- Наводить в голову
    AIM_SMOOTH = 0.25,             -- Плавность наведения (0 = резко)
    FOV = 200,                     -- Радиус зоны AIM
    INF_AMMO = true,               -- Бесконечные патроны
    SHOW_NAME = true,
    SHOW_HEALTH = true,
    SHOW_DISTANCE = true,
    SHOW_LINES = true,
    TEAM_CHECK = true,             -- Фильтровать союзников
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
-- ГУИ (СВОРАЧИВАЕМОЕ)
-- ============================================
local scr = Instance.new("ScreenGui")
scr.Name = "CapybaraGUI"
scr.Parent = LP:WaitForChild("PlayerGui")
scr.ResetOnSpawn = false

local main = Instance.new("Frame")
main.Size = UDim2.new(0, 240, 0, 280)
main.Position = UDim2.new(0, 10, 0, 50)
main.BackgroundColor3 = Color3.fromRGB(10,10,15)
main.BackgroundTransparency = 0.15
main.Active = true
main.Draggable = true
main.Parent = scr
local co = Instance.new("UICorner")
co.CornerRadius = UDim.new(0, 12)
co.Parent = main

local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 30)
titleBar.BackgroundTransparency = 1
titleBar.Parent = main

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(0, 200, 0, 30)
titleLabel.Position = UDim2.new(0, 10, 0, 0)
titleLabel.Text = "🐹 CAPYBARA PRO"
titleLabel.TextColor3 = Color3.fromRGB(255,200,80)
titleLabel.BackgroundTransparency = 1
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 16
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = titleBar

local minimizeBtn = Instance.new("TextButton")
minimizeBtn.Size = UDim2.new(0, 30, 0, 30)
minimizeBtn.Position = UDim2.new(0, 210, 0, 0)
minimizeBtn.Text = "—"
minimizeBtn.TextColor3 = Color3.fromRGB(255,255,255)
minimizeBtn.BackgroundTransparency = 1
minimizeBtn.Font = Enum.Font.Gotham
minimizeBtn.TextSize = 22
minimizeBtn.Parent = titleBar

local isMinimized = false
local fullSize = main.Size
local miniSize = UDim2.new(0, 160, 0, 30)

minimizeBtn.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    main.Size = isMinimized and miniSize or fullSize
    minimizeBtn.Text = isMinimized and "+" or "—"
    for _, child in ipairs(main:GetChildren()) do
        if child ~= titleBar and child ~= co then
            child.Visible = not isMinimized
        end
    end
end)

local function toggle(text, y, cb)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0, 130, 0, 30)
    lbl.Position = UDim2.new(0, 10, 0, y)
    lbl.Text = text
    lbl.TextColor3 = Color3.fromRGB(220,220,220)
    lbl.BackgroundTransparency = 1
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 14
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = main

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 50, 0, 24)
    btn.Position = UDim2.new(0, 180, 0, y + 3)
    btn.Text = Settings[text] and "ON" or "OFF"
    btn.TextColor3 = Settings[text] and Color3.fromRGB(80,255,80) or Color3.fromRGB(255,80,80)
    btn.BackgroundColor3 = Color3.fromRGB(40,40,50)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 13
    btn.Parent = main

    btn.MouseButton1Click:Connect(function()
        Settings[text] = not Settings[text]
        btn.Text = Settings[text] and "ON" or "OFF"
        btn.TextColor3 = Settings[text] and Color3.fromRGB(80,255,80) or Color3.fromRGB(255,80,80)
        cb(Settings[text])
    end)
end

-- Создаём кнопки
local function createToggles()
    local y = 40
    local toggles = {"ESP", "AIM", "AIM_HEAD", "INF_AMMO", "TEAM_CHECK"}
    for _, t in ipairs(toggles) do
        toggle(t, y, function() end)
        y = y + 35
    end
end
createToggles()

-- FOV Slider
local fovL = Instance.new("TextLabel")
fovL.Size = UDim2.new(0, 100, 0, 30)
fovL.Position = UDim2.new(0, 10, 0, 220)
fovL.Text = "FOV: " .. Settings.FOV
fovL.TextColor3 = Color3.fromRGB(220,220,220)
fovL.BackgroundTransparency = 1
fovL.Font = Enum.Font.Gotham
fovL.TextSize = 14
fovL.Parent = main

local fovAdd = Instance.new("TextButton")
fovAdd.Size = UDim2.new(0, 40, 0, 24)
fovAdd.Position = UDim2.new(0, 190, 0, 223)
fovAdd.Text = "+"
fovAdd.TextColor3 = Color3.fromRGB(255,255,255)
fovAdd.BackgroundColor3 = Color3.fromRGB(40,40,50)
fovAdd.Font = Enum.Font.Gotham
fovAdd.TextSize = 18
fovAdd.Parent = main
fovAdd.MouseButton1Click:Connect(function()
    Settings.FOV = math.min(600, Settings.FOV + 20)
    fovL.Text = "FOV: " .. Settings.FOV
end)

local fovSub = Instance.new("TextButton")
fovSub.Size = UDim2.new(0, 40, 0, 24)
fovSub.Position = UDim2.new(0, 150, 0, 223)
fovSub.Text = "-"
fovSub.TextColor3 = Color3.fromRGB(255,255,255)
fovSub.BackgroundColor3 = Color3.fromRGB(40,40,50)
fovSub.Font = Enum.Font.Gotham
fovSub.TextSize = 18
fovSub.Parent = main
fovSub.MouseButton1Click:Connect(function()
    Settings.FOV = math.max(50, Settings.FOV - 20)
    fovL.Text = "FOV: " .. Settings.FOV
end)

-- ============================================
-- FOV (ОТОБРАЖЕНИЕ)
-- ============================================
local fovImg = Instance.new("ImageLabel")
fovImg.Size = UDim2.new(0, 0, 0, 0)
fovImg.Position = UDim2.new(0.5, 0, 0.5, 0)
fovImg.BackgroundTransparency = 1
fovImg.Image = "rbxassetid://1608528810"
fovImg.ImageColor3 = Color3.fromRGB(100, 200, 255)
fovImg.ImageTransparency = 0.7
fovImg.Parent = scr

local function updateFOV()
    local size = Settings.FOV * 2
    fovImg.Size = UDim2.new(0, size, 0, size)
    fovImg.Position = UDim2.new(0.5, -size/2, 0.5, -size/2)
    fovImg.Visible = Settings.AIM
end
RunService.RenderStepped:Connect(updateFOV)

-- ============================================
-- ESP
-- ============================================
local espPool = {}
local function getESPElement()
    for _, v in ipairs(espPool) do
        if not v.used then
            v.used = true
            v.box.Visible = true
            v.name.Visible = Settings.SHOW_NAME
            v.health.Visible = Settings.SHOW_HEALTH
            v.dist.Visible = Settings.SHOW_DISTANCE
            v.line.Visible = Settings.SHOW_LINES
            return v
        end
    end
    local box = Instance.new("Frame")
    box.Size = UDim2.new(0, 50, 0, 90)
    box.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    box.BackgroundTransparency = 0.4
    box.BorderSizePixel = 2
    box.BorderColor3 = Color3.fromRGB(255,255,255)
    box.Parent = scr

    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(0, 120, 0, 16)
    nameLabel.Position = UDim2.new(0, -35, 0, -16)
    nameLabel.Text = ""
    nameLabel.TextColor3 = Color3.fromRGB(255,255,255)
    nameLabel.TextStrokeTransparency = 0.5
    nameLabel.TextStrokeColor3 = Color3.fromRGB(0,0,0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextSize = 14
    nameLabel.Parent = scr

    local healthBar = Instance.new("Frame")
    healthBar.Size = UDim2.new(0, 50, 0, 4)
    healthBar.BackgroundColor3 = Color3.fromRGB(0,255,0)
    healthBar.BackgroundTransparency = 0.2
    healthBar.Parent = scr

    local distLabel = Instance.new("TextLabel")
    distLabel.Size = UDim2.new(0, 60, 0, 14)
    distLabel.Text = ""
    distLabel.TextColor3 = Color3.fromRGB(200,200,200)
    distLabel.TextStrokeTransparency = 0.5
    distLabel.TextStrokeColor3 = Color3.fromRGB(0,0,0)
    distLabel.BackgroundTransparency = 1
    distLabel.Font = Enum.Font.Gotham
    distLabel.TextSize = 11
    distLabel.Parent = scr

    local lineFrame = Instance.new("Frame")
    lineFrame.Size = UDim2.new(0, 2, 0, 200)
    lineFrame.BackgroundColor3 = Color3.fromRGB(255,255,255)
    lineFrame.BackgroundTransparency = 0.5
    lineFrame.Parent = scr

    local entry = {
        box = box, name = nameLabel, health = healthBar,
        dist = distLabel, line = lineFrame, used = true
    }
    table.insert(espPool, entry)
    return entry
end

RunService.RenderStepped:Connect(function()
    for _, v in ipairs(espPool) do
        v.used = false
        v.box.Visible = false
        v.name.Visible = false
        v.health.Visible = false
        v.dist.Visible = false
        v.line.Visible = false
    end
    if not Settings.ESP then return end

    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LP then
            local char = plr.Character
            if char and char:FindFirstChild("Humanoid") and char.Humanoid.Health > 0 then
                if Settings.TEAM_CHECK and getTeam(plr) == getTeam(LP) then continue end

                local root = char:FindFirstChild("HumanoidRootPart")
                if root then
                    local pos, vis = Camera:WorldToScreenPoint(root.Position)
                    if vis then
                        local dist = (root.Position - Camera.CFrame.Position).Magnitude
                        local size = math.clamp(300 / dist, 20, 80)

                        local entry = getESPElement()
                        entry.box.Size = UDim2.new(0, size, 0, size * 1.8)
                        entry.box.Position = UDim2.new(0, pos.X - size/2, 0, pos.Y - size * 1.2)
                        entry.box.Visible = true

                        if Settings.SHOW_LINES then
                            entry.line.Size = UDim2.new(0, 2, 0, math.abs(pos.Y - center.Y))
                            entry.line.Position = UDim2.new(0, pos.X - 1, 0, math.min(pos.Y, center.Y))
                            entry.line.Visible = true
                        end

                        if Settings.SHOW_NAME then
                            entry.name.Position = UDim2.new(0, pos.X - 60, 0, pos.Y - size * 1.2 - 20)
                            entry.name.Text = plr.Name
                            entry.name.Visible = true
                        end

                        if Settings.SHOW_HEALTH then
                            local health = char.Humanoid.Health / char.Humanoid.MaxHealth
                            entry.health.Size = UDim2.new(health * size, 0, 0, 4)
                            entry.health.Position = UDim2.new(0, pos.X - size/2, 0, pos.Y - size * 1.2 + size * 1.8)
                            entry.health.BackgroundColor3 = Color3.fromRGB(255 * (1 - health), 255 * health, 0)
                            entry.health.Visible = true
                        end

                        if Settings.SHOW_DISTANCE then
                            entry.dist.Position = UDim2.new(0, pos.X - 20, 0, pos.Y - size * 1.2 + size * 1.8 + 6)
                            entry.dist.Text = math.floor(dist) .. "m"
                            entry.dist.Visible = true
                        end
                    end
                end
            end
        end
    end
end)

-- ============================================
-- AIMBOT
-- ============================================
local function getClosestPlayer()
    local target = nil
    local minDist = math.huge
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LP then
            local char = plr.Character
            if char and char:FindFirstChild("Humanoid") and char.Humanoid.Health > 0 then
                if Settings.TEAM_CHECK and getTeam(plr) == getTeam(LP) then continue end

                local aimPart = nil
                if Settings.AIM_HEAD then
                    aimPart = char:FindFirstChild("Head")
                end
                if not aimPart then
                    aimPart = char:FindFirstChild("HumanoidRootPart")
                end
                if aimPart then
                    local sp, vis = Camera:WorldToScreenPoint(aimPart.Position)
                    if vis then
                        local d = (Vector2.new(sp.X, sp.Y) - center).Magnitude
                        if d < Settings.FOV and d < minDist then
                            minDist = d
                            target = aimPart
                        end
                    end
                end
            end
        end
    end
    return target
end

RunService.RenderStepped:Connect(function()
    if not Settings.AIM then return end
    local target = getClosestPlayer()
    if target then
        local pos, vis = Camera:WorldToScreenPoint(target.Position)
        if vis then
            local dx = pos.X - Mouse.X
            local dy = pos.Y - Mouse.Y
            Mouse.X = Mouse.X + dx * Settings.AIM_SMOOTH
            Mouse.Y = Mouse.Y + dy * Settings.AIM_SMOOTH
        end
    end
end)

-- ============================================
-- INFINITE AMMO (Lost Front)
-- ============================================
RunService.Heartbeat:Connect(function()
    if not Settings.INF_AMMO then return end
    local bp = LP:FindFirstChildOfClass("Backpack")
    if bp then
        for _, tool in ipairs(bp:GetChildren()) do
            if tool:IsA("Tool") and tool:FindFirstChild("Ammo") then
                tool.Ammo.Value = 999
            end
            if tool:IsA("Tool") and tool:FindFirstChild("MaxAmmo") then
                tool.MaxAmmo.Value = 999
            end
        end
    end
end)
