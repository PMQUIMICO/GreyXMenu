if getgenv().GreyX then return end
getgenv().GreyX = true

--// Serviços
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Players          = game:GetService("Players")
local Workspace        = game:GetService("Workspace")
local TweenService     = game:GetService("TweenService")
local Lighting         = game:GetService("Lighting")
local LocalPlayer      = Players.LocalPlayer
local Camera           = Workspace.CurrentCamera

--// Configurações (mantidas)
local Config = {
    Aimbot = {
        Enabled     = true,
        FOV         = 100,
        Smoothness  = 0.5,
        TargetPart  = "Head",
        VisibleCheck = true,
        TeamCheck   = true
    },
    Visuals = {
        Enabled     = true,
        Boxes       = true,
        Names       = true,
        Health      = true,
        Distance    = true,
        Tracers     = false,
        TeamCheck   = true,
        MaxDistance = 1000
    }
}

--// Load Aimbot (mantido)
local function LoadAimbot()
    local success, _ = pcall(function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/Exunys/Aimbot-V2/main/Resources/Scripts/Raw%20Main.lua"))()
    end)
    
    if success and getgenv().Aimbot then
        local AB = getgenv().Aimbot
        AB.FOVSettings.Color  = Color3.fromRGB(255, 215, 0)
        AB.FOVSettings.Visible = true
        AB.Enabled    = Config.Aimbot.Enabled
        AB.FOV        = Config.Aimbot.FOV
        AB.Smoothness = Config.Aimbot.Smoothness
        AB.TargetPart = Config.Aimbot.TargetPart
    end
end
LoadAimbot()

--// ESP (mantido igual)
local ESP = {Drawings = {}}
local DrawingLib = (drawing or Drawing)

function ESP:AddPlayer(player)
    if player == LocalPlayer then return end
    self.Drawings[player] = {
        Box      = DrawingLib.new("Square"),
        Name     = DrawingLib.new("Text"),
        Health   = DrawingLib.new("Text"),
        Distance = DrawingLib.new("Text")
    }
end

function ESP:Update()
    for player, drawings in pairs(self.Drawings) do
        if not player.Parent or not player.Character or not Config.Visuals.Enabled then
            for _, d in pairs(drawings) do d.Visible = false end
            continue
        end
        
        local char = player.Character
        local root = char:FindFirstChild("HumanoidRootPart")
        local hum  = char:FindFirstChild("Humanoid")
        
        if root and hum then
            local pos, onScreen = Camera:WorldToViewportPoint(root.Position)
            local dist = (Camera.CFrame.Position - root.Position).Magnitude
            
            if onScreen and dist <= Config.Visuals.MaxDistance then
                local isTeam = Config.Visuals.TeamCheck and player.Team == LocalPlayer.Team
                local color  = isTeam and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 215, 0)
                
                if Config.Visuals.Boxes then
                    local size = Vector2.new(2000/dist * 2, 2000/dist * 3)
                    drawings.Box.Visible  = true
                    drawings.Box.Size     = size
                    drawings.Box.Position = Vector2.new(pos.X - size.X/2, pos.Y - size.Y/2)
                    drawings.Box.Color    = color
                    drawings.Box.Thickness = 1
                else drawings.Box.Visible = false end
                
                if Config.Visuals.Names then
                    drawings.Name.Visible  = true
                    drawings.Name.Text     = player.Name
                    drawings.Name.Position = Vector2.new(pos.X, pos.Y - (2000/dist * 1.5) - 15)
                    drawings.Name.Center   = true
                    drawings.Name.Outline  = true
                    drawings.Name.Color    = Color3.new(1,1,1)
                else drawings.Name.Visible = false end
                
                if Config.Visuals.Health then
                    drawings.Health.Visible  = true
                    drawings.Health.Text     = math.floor(hum.Health) .. " HP"
                    drawings.Health.Position = Vector2.new(pos.X, pos.Y + (2000/dist * 1.5) + 5)
                    drawings.Health.Center   = true
                    drawings.Health.Outline  = true
                    drawings.Health.Color    = Color3.fromRGB(255, 255, 0)
                else drawings.Health.Visible = false end
            else
                for _, d in pairs(drawings) do d.Visible = false end
            end
        end
    end
end

RunService.RenderStepped:Connect(function() ESP:Update() end)
for _, p in ipairs(Players:GetPlayers()) do ESP:AddPlayer(p) end
Players.PlayerAdded:Connect(function(p) ESP:AddPlayer(p) end)

--// Menu UI (mantido, com Misc corrigida)
local Menu = {Tabs = {}}

function Menu:Init()
    local ScreenGui = Instance.new("ScreenGui", game:GetService("CoreGui"))
    ScreenGui.Name = "GreyXMenu"
    
    local Main = Instance.new("Frame", ScreenGui)
    Main.Size = UDim2.new(0, 500, 0, 350)
    Main.Position = UDim2.new(0.5, -250, 0.5, -175)
    Main.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
    Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 4)
    Instance.new("UIStroke", Main).Color = Color3.fromRGB(255, 215, 0)

    local Sidebar = Instance.new("Frame", Main)
    Sidebar.Size = UDim2.new(0, 130, 1, 0)
    Sidebar.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
    Instance.new("UICorner", Sidebar)

    local Title = Instance.new("TextLabel", Sidebar)
    Title.Text = "GREYX.MENU"
    Title.Size = UDim2.new(1, 0, 0, 40)
    Title.TextColor3 = Color3.fromRGB(255, 215, 0)
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 16
    Title.BackgroundTransparency = 1

    local TabContainer = Instance.new("Frame", Sidebar)
    TabContainer.Position = UDim2.new(0, 0, 0, 50)
    TabContainer.Size = UDim2.new(1, 0, 1, -50)
    TabContainer.BackgroundTransparency = 1
    Instance.new("UIListLayout", TabContainer)

    local ContentArea = Instance.new("Frame", Main)
    ContentArea.Position = UDim2.new(0, 140, 0, 10)
    ContentArea.Size = UDim2.new(1, -150, 1, -20)
    ContentArea.BackgroundTransparency = 1

    local function SyncAimbot()
        if getgenv().Aimbot then
            local AB = getgenv().Aimbot
            AB.Enabled    = Config.Aimbot.Enabled
            AB.FOV        = Config.Aimbot.FOV
            AB.Smoothness = Config.Aimbot.Smoothness
            AB.TargetPart = Config.Aimbot.TargetPart
        end
    end

    function Menu:CreateTab(name)
        local TabBtn = Instance.new("TextButton", TabContainer)
        TabBtn.Size = UDim2.new(1, 0, 0, 35)
        TabBtn.BackgroundTransparency = 1
        TabBtn.Text = name
        TabBtn.TextColor3 = Color3.fromRGB(150, 150, 150)
        TabBtn.Font = Enum.Font.GothamMedium
        TabBtn.TextSize = 13

        local Page = Instance.new("ScrollingFrame", ContentArea)
        Page.Size = UDim2.new(1, 0, 1, 0)
        Page.BackgroundTransparency = 1
        Page.Visible = false
        Page.ScrollBarThickness = 2
        Instance.new("UIListLayout", Page).Padding = UDim.new(0, 10)

        TabBtn.MouseButton1Click:Connect(function()
            for _, v in pairs(Menu.Tabs) do
                v.Page.Visible = false
                v.Btn.TextColor3 = Color3.fromRGB(150, 150, 150)
            end
            Page.Visible = true
            TabBtn.TextColor3 = Color3.fromRGB(255, 215, 0)
        end)

        Menu.Tabs[name] = {Page = Page, Btn = TabBtn}
        return Page
    end

    local function AddToggle(parent, text, default, callback)
        local Btn = Instance.new("TextButton", parent)
        Btn.Size = UDim2.new(1, -10, 0, 30)
        Btn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
        Btn.Text = text .. (default and " [ON]" or " [OFF]")
        Btn.TextColor3 = default and Color3.fromRGB(255, 215, 0) or Color3.fromRGB(200, 200, 200)
        Btn.Font = Enum.Font.Gotham
        Btn.TextSize = 12
        Instance.new("UICorner", Btn)

        Btn.MouseButton1Click:Connect(function()
            default = not default
            Btn.Text = text .. (default and " [ON]" or " [OFF]")
            Btn.TextColor3 = default and Color3.fromRGB(255, 215, 0) or Color3.fromRGB(200, 200, 200)
            callback(default)
        end)
    end

    local function AddSlider(parent, text, min, max, default, callback)
        local Container = Instance.new("Frame", parent)
        Container.Size = UDim2.new(1, -10, 0, 45)
        Container.BackgroundTransparency = 1

        local Label = Instance.new("TextLabel", Container)
        Label.Text = text .. ": " .. default
        Label.Size = UDim2.new(1, 0, 0, 20)
        Label.TextColor3 = Color3.new(1,1,1)
        Label.BackgroundTransparency = 1
        Label.TextXAlignment = Enum.TextXAlignment.Left

        local Bar = Instance.new("TextButton", Container)
        Bar.Position = UDim2.new(0, 0, 0, 25)
        Bar.Size = UDim2.new(1, 0, 0, 5)
        Bar.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        Bar.Text = ""

        local Fill = Instance.new("Frame", Bar)
        Fill.Size = UDim2.new((default-min)/(max-min), 0, 1, 0)
        Fill.BackgroundColor3 = Color3.fromRGB(255, 215, 0)

        Bar.MouseButton1Down:Connect(function()
            local conn
            conn = RunService.RenderStepped:Connect(function()
                local mp = UserInputService:GetMouseLocation().X
                local per = math.clamp((mp - Bar.AbsolutePosition.X)/Bar.AbsoluteSize.X, 0, 1)
                local val = min + (max-min)*per
                if max <= 5 then val = tonumber(string.format("%.1f", val)) else val = math.floor(val) end
                Fill.Size = UDim2.new(per, 0, 1, 0)
                Label.Text = text .. ": " .. val
                callback(val)
            end)
            local endedConn = UserInputService.InputEnded:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseButton1 then
                    conn:Disconnect()
                    endedConn:Disconnect()
                end
            end)
        end)
    end

    local function AddDropdown(parent, text, options, callback)
        local Btn = Instance.new("TextButton", parent)
        Btn.Size = UDim2.new(1, -10, 0, 30)
        Btn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
        Btn.Text = text .. ": " .. options[1]
        Btn.TextColor3 = Color3.new(1,1,1)
        Instance.new("UICorner", Btn)

        local idx = 1
        Btn.MouseButton1Click:Connect(function()
            idx = idx + 1
            if idx > #options then idx = 1 end
            Btn.Text = text .. ": " .. options[idx]
            callback(options[idx])
        end)
    end

    -- Abas LegitBot e Visuals
    local LegitPage = Menu:CreateTab("LegitBot")
    AddToggle(LegitPage, "Aimbot", Config.Aimbot.Enabled, function(v) Config.Aimbot.Enabled = v SyncAimbot() end)
    AddSlider(LegitPage, "Field of View", 10, 600, Config.Aimbot.FOV, function(v) Config.Aimbot.FOV = v SyncAimbot() end)
    AddSlider(LegitPage, "Smoothness", 0, 5, Config.Aimbot.Smoothness, function(v) Config.Aimbot.Smoothness = v SyncAimbot() end)
    AddDropdown(LegitPage, "Target Part", {"Head", "HumanoidRootPart", "Torso"}, function(v) Config.Aimbot.TargetPart = v SyncAimbot() end)
    AddToggle(LegitPage, "Team Check", Config.Aimbot.TeamCheck, function(v) Config.Aimbot.TeamCheck = v SyncAimbot() end)

    local VisualPage = Menu:CreateTab("Visuals")
    AddToggle(VisualPage, "Enable ESP", Config.Visuals.Enabled, function(v) Config.Visuals.Enabled = v end)
    AddToggle(VisualPage, "Boxes", Config.Visuals.Boxes, function(v) Config.Visuals.Boxes = v end)
    AddToggle(VisualPage, "Names", Config.Visuals.Names, function(v) Config.Visuals.Names = v end)
    AddToggle(VisualPage, "Health", Config.Visuals.Health, function(v) Config.Visuals.Health = v end)
    AddToggle(VisualPage, "Team Check", Config.Visuals.TeamCheck, function(v) Config.Visuals.TeamCheck = v end)
    AddSlider(VisualPage, "Max Distance", 100, 5000, Config.Visuals.MaxDistance, function(v) Config.Visuals.MaxDistance = v end)

    -- Aba Misc - Sky Color (só céu, minimizando impacto no lighting)
    local MiscPage = Menu:CreateTab("Misc")

    local skyColors = {
        "Default", "Blue", "Deep Blue", "Cyan", "Purple", "Pink", "Red", "Orange", 
        "Yellow", "Lime", "Green", "Emerald", "White", "Black", "Dark Gray", "Neon Violet"
    }

    local colorMap = {
        Default     = nil,
        Blue        = Color3.fromRGB(100, 180, 255),
        ["Deep Blue"] = Color3.fromRGB(20, 50, 140),
        Cyan        = Color3.fromRGB(0, 220, 240),
        Purple      = Color3.fromRGB(180, 100, 255),
        Pink        = Color3.fromRGB(255, 120, 220),
        Red         = Color3.fromRGB(240, 60, 60),
        Orange      = Color3.fromRGB(255, 160, 60),
        Yellow      = Color3.fromRGB(255, 240, 100),
        Lime        = Color3.fromRGB(180, 255, 100),
        Green       = Color3.fromRGB(80, 220, 80),
        Emerald     = Color3.fromRGB(50, 200, 120),
        White       = Color3.fromRGB(250, 250, 255),
        Black       = Color3.fromRGB(30, 30, 50),
        ["Dark Gray"] = Color3.fromRGB(70, 70, 90),
        ["Neon Violet"] = Color3.fromRGB(220, 0, 255)
    }

    -- Variáveis para restaurar
    local citizenSky = nil
    local citizenCC = nil
    local originalAtmosphereClone = nil
    local originalDiffuse = Lighting.EnvironmentDiffuseScale
    local originalSpecular = Lighting.EnvironmentSpecularScale

    AddDropdown(MiscPage, "Sky Color (Only Sky)", skyColors, function(selected)
        -- Limpa custom
        if citizenSky then citizenSky:Destroy() citizenSky = nil end
        if citizenCC then citizenCC:Destroy() citizenCC = nil end

        if selected == "Default" then
            -- Restaura
            if originalAtmosphereClone then
                originalAtmosphereClone.Parent = Lighting
                originalAtmosphereClone = nil
            end
            Lighting.EnvironmentDiffuseScale = originalDiffuse
            Lighting.EnvironmentSpecularScale = originalSpecular
            return
        end

        local targetColor = colorMap[selected]

        -- Remove Atmosphere temporariamente
        local atm = Lighting:FindFirstChildOfClass("Atmosphere")
        if atm and not originalAtmosphereClone then
            originalAtmosphereClone = atm:Clone()
            atm.Parent = nil
        end

        -- Cria Sky vazio (sem texturas, sem corpos celestes)
        citizenSky = Instance.new("Sky")
        citizenSky.Name = "GreyX_OnlySky"
        citizenSky.Parent = Lighting

        citizenSky.SkyboxBk = ""
        citizenSky.SkyboxDn = ""
        citizenSky.SkyboxFt = ""
        citizenSky.SkyboxLf = ""
        citizenSky.SkyboxRt = ""
        citizenSky.SkyboxUp = ""

        citizenSky.CelestialBodiesShown = false
        citizenSky.StarCount = 0
        citizenSky.SunAngularSize = 0
        citizenSky.MoonAngularSize = 0

        -- ColorCorrection focada no céu (tint + flat look)
        citizenCC = Instance.new("ColorCorrectionEffect")
        citizenCC.Name = "GreyX_SkyTint"
        citizenCC.Parent = Lighting
        citizenCC.Enabled = true
        citizenCC.TintColor = targetColor
        citizenCC.Brightness = -0.08  -- Leve escurecimento pro flat
        citizenCC.Contrast = 0.05
        citizenCC.Saturation = -0.4   -- Reduz saturação pra menos "vivo" no mapa

        -- Zera reflexão do céu no mapa (crucial!)
        Lighting.EnvironmentDiffuseScale = 0
        Lighting.EnvironmentSpecularScale = 0
    end)

    -- Abre LegitBot por padrão
    Menu.Tabs["LegitBot"].Btn.TextColor3 = Color3.fromRGB(255, 215, 0)
    Menu.Tabs["LegitBot"].Page.Visible = true

    -- Draggable
    local dragging, dragStart, startPos
    Main.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = Main.Position
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    -- Toggle F5
    UserInputService.InputBegan:Connect(function(input)
        if input.KeyCode == Enum.KeyCode.F5 then
            ScreenGui.Enabled = not ScreenGui.Enabled
        end
    end)
end

Menu:Init()
