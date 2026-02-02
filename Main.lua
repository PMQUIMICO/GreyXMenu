-- GreyXMenu - Menu Premium Preto e Amarelo
-- Versão 100% Funcional - Por: GreyX

--// Configurações Iniciais
if getgenv().GreyX then 
    warn("[GreyX] Script já está carregado!")
    return 
end

getgenv().GreyX = true
getgenv().GreyXVersion = "1.0"

--// Serviços
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

--// Verificar se Drawing está disponível
local DrawingLib = (drawing or Drawing)
if not DrawingLib then
    warn("[GreyX] Drawing não está disponível!")
    return
end

--// Cores do Tema GreyX - Preto e Amarelo
local Theme = {
    Primary = Color3.fromRGB(255, 215, 0),      -- Amarelo ouro
    Secondary = Color3.fromRGB(255, 255, 0),    -- Amarelo brilhante
    Dark = Color3.fromRGB(20, 20, 20),          -- Preto escuro
    Background = Color3.fromRGB(10, 10, 10),    -- Preto quase puro
    Text = Color3.fromRGB(255, 255, 255),       -- Branco
    Border = Color3.fromRGB(255, 215, 0),       -- Borda amarela
    Success = Color3.fromRGB(0, 255, 0),        -- Verde
    Error = Color3.fromRGB(255, 50, 50)         -- Vermelho
}

--// Configurações
local ESPConfig = {
    Enabled = true,
    Boxes = true,
    Names = true,
    Health = true,
    Distance = true,
    Tracers = false,
    MaxDistance = 1000,
    TeamCheck = true,
    BoxColor = Color3.fromRGB(255, 255, 0),
    NameColor = Color3.fromRGB(255, 255, 255),
    HealthColor = Color3.fromRGB(255, 215, 0),
    DistanceColor = Color3.fromRGB(255, 255, 150)
}

local AimbotConfig = {
    Enabled = true,
    FOV = 100,
    Smoothness = 0.2,
    TargetPart = "Head",
    VisibleCheck = true,
    TeamCheck = true,
    ToggleKey = "MouseButton2",
    AimKey = "MouseButton2"
}

--// Carregar Aimbot Exunys com correções
local AimbotLoaded = false
local aimbotSuccess, aimbotError = pcall(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/Exunys/Aimbot-V2/main/Resources/Scripts/Raw%20Main.lua"))()
end)

if aimbotSuccess then
    print("[GreyX] Aimbot carregado com sucesso!")
    AimbotLoaded = true
    
    local Aimbot = getgenv().Aimbot
    if Aimbot then
        -- Configurar cores amarelas
        Aimbot.FOVSettings.Color = Color3.fromRGB(255, 215, 0)
        Aimbot.FOVSettings.LockedColor = Color3.fromRGB(255, 255, 0)
        Aimbot.FOVSettings.Transparency = 0.5
        Aimbot.FOVSettings.Visible = true
        
        -- Configurar valores iniciais
        Aimbot.Enabled = AimbotConfig.Enabled
        Aimbot.FOV = AimbotConfig.FOV
        Aimbot.Smoothness = AimbotConfig.Smoothness
        Aimbot.TargetPart = AimbotConfig.TargetPart
        Aimbot.VisibleCheck = AimbotConfig.VisibleCheck
        Aimbot.TeamCheck = AimbotConfig.TeamCheck
        Aimbot.Toggle = AimbotConfig.ToggleKey
        Aimbot.AimKey = AimbotConfig.AimKey
    end
else
    warn("[GreyX] Aimbot não disponível: " .. tostring(aimbotError))
    print("[GreyX] Funcionalidades de ESP ainda disponíveis")
end

--// Sistema de ESP
local ESP = {
    Players = {},
    Drawings = {},
    Connections = {},
    Enabled = ESPConfig.Enabled
}

function ESP:Init()
    self.Drawings = {}
    
    self.Connections.PlayerAdded = Players.PlayerAdded:Connect(function(player)
        self:AddPlayer(player)
    end)
    
    self.Connections.PlayerRemoving = Players.PlayerRemoving:Connect(function(player)
        self:RemovePlayer(player)
    end)
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            self:AddPlayer(player)
        end
    end
    
    self.Connections.RenderStep = RunService.RenderStepped:Connect(function()
        if not self.Enabled then return end
        
        for player, drawings in pairs(self.Drawings) do
            if player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                local character = player.Character
                local rootPart = character.HumanoidRootPart
                
                local position, onScreen = Camera:WorldToViewportPoint(rootPart.Position)
                local distance = (rootPart.Position - Camera.CFrame.Position).Magnitude
                
                if onScreen and distance <= ESPConfig.MaxDistance then
                    local teamMate = ESPConfig.TeamCheck and LocalPlayer.Team and player.Team == LocalPlayer.Team
                    
                    if drawings.Box and ESPConfig.Boxes then
                        local scale = 2000 / distance
                        local size = Vector2.new(scale * 2, scale * 3)
                        
                        drawings.Box.Visible = true
                        drawings.Box.Color = teamMate and Color3.fromRGB(0, 255, 0) or ESPConfig.BoxColor
                        drawings.Box.Size = size
                        drawings.Box.Position = Vector2.new(position.X - size.X / 2, position.Y - size.Y / 2)
                        drawings.Box.Transparency = 0.3
                        drawings.Box.Filled = false
                        drawings.Box.Thickness = 2
                    else
                        if drawings.Box then drawings.Box.Visible = false end
                    end
                    
                    if drawings.Name and ESPConfig.Names then
                        drawings.Name.Visible = true
                        drawings.Name.Text = player.Name
                        drawings.Name.Color = teamMate and Color3.fromRGB(150, 255, 150) or ESPConfig.NameColor
                        drawings.Name.Position = Vector2.new(position.X, position.Y - (2000 / distance * 3) / 2 - 20)
                        drawings.Name.Size = 13
                        drawings.Name.Center = true
                        drawings.Name.Outline = true
                        drawings.Name.Font = 2
                    else
                        if drawings.Name then drawings.Name.Visible = false end
                    end
                    
                    if drawings.Health and ESPConfig.Health then
                        local humanoid = character:FindFirstChildOfClass("Humanoid")
                        if humanoid then
                            drawings.Health.Visible = true
                            drawings.Health.Text = math.floor(humanoid.Health) .. " HP"
                            drawings.Health.Color = ESPConfig.HealthColor
                            drawings.Health.Position = Vector2.new(position.X, position.Y + (2000 / distance * 3) / 2 + 5)
                            drawings.Health.Size = 13
                            drawings.Health.Center = true
                            drawings.Health.Outline = true
                            drawings.Health.Font = 2
                        end
                    else
                        if drawings.Health then drawings.Health.Visible = false end
                    end
                    
                    if drawings.Distance and ESPConfig.Distance then
                        drawings.Distance.Visible = true
                        drawings.Distance.Text = math.floor(distance) .. " studs"
                        drawings.Distance.Color = ESPConfig.DistanceColor
                        drawings.Distance.Position = Vector2.new(position.X, position.Y + (2000 / distance * 3) / 2 + 25)
                        drawings.Distance.Size = 12
                        drawings.Distance.Center = true
                        drawings.Distance.Outline = true
                        drawings.Distance.Font = 2
                    else
                        if drawings.Distance then drawings.Distance.Visible = false end
                    end
                    
                    if drawings.Tracer and ESPConfig.Tracers then
                        drawings.Tracer.Visible = true
                        drawings.Tracer.Color = ESPConfig.BoxColor
                        drawings.Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                        drawings.Tracer.To = Vector2.new(position.X, position.Y)
                        drawings.Tracer.Thickness = 1
                    else
                        if drawings.Tracer then drawings.Tracer.Visible = false end
                    end
                else
                    for _, drawing in pairs(drawings) do
                        if drawing then drawing.Visible = false end
                    end
                end
            else
                for _, drawing in pairs(drawings) do
                    if drawing then drawing.Visible = false end
                end
            end
        end
    end)
end

function ESP:AddPlayer(player)
    if self.Drawings[player] then return end
    
    self.Drawings[player] = {
        Box = DrawingLib.new("Square"),
        Name = DrawingLib.new("Text"),
        Health = DrawingLib.new("Text"),
        Distance = DrawingLib.new("Text"),
        Tracer = DrawingLib.new("Line")
    }
    
    self.Drawings[player].Box.Visible = false
    self.Drawings[player].Box.Thickness = 2
    self.Drawings[player].Box.Filled = false
    
    for _, text in pairs({"Name", "Health", "Distance"}) do
        if self.Drawings[player][text] then
            self.Drawings[player][text].Visible = false
            self.Drawings[player][text].Center = true
            self.Drawings[player][text].Outline = true
            self.Drawings[player][text].Font = 2
        end
    end
    
    self.Drawings[player].Tracer.Visible = false
    self.Drawings[player].Tracer.Thickness = 1
end

function ESP:RemovePlayer(player)
    if self.Drawings[player] then
        for _, drawing in pairs(self.Drawings[player]) do
            if drawing then
                drawing:Remove()
            end
        end
        self.Drawings[player] = nil
    end
end

function ESP:Toggle(state)
    self.Enabled = state
    for player, drawings in pairs(self.Drawings) do
        for _, drawing in pairs(drawings) do
            if drawing then
                drawing.Visible = state
            end
        end
    end
end

function ESP:Destroy()
    for _, connection in pairs(self.Connections) do
        if connection then
            connection:Disconnect()
        end
    end
    
    for player, drawings in pairs(self.Drawings) do
        for _, drawing in pairs(drawings) do
            if drawing then
                drawing:Remove()
            end
        end
    end
    
    self.Drawings = {}
    self.Connections = {}
end

--// Criar Menu GreyX com cantos arredondados
local Menu = {
    Open = false,
    Gui = nil,
    MainFrame = nil,
    Tabs = {}
}

function Menu:Create()
    -- Cria a ScreenGui
    self.Gui = Instance.new("ScreenGui")
    self.Gui.Name = "GreyXMenu"
    self.Gui.ResetOnSpawn = false
    self.Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    -- Frame principal com cantos arredondados
    self.MainFrame = Instance.new("Frame")
    self.MainFrame.Size = UDim2.new(0, 400, 0, 400)
    self.MainFrame.Position = UDim2.new(0.5, -200, 0.5, -200)
    self.MainFrame.BackgroundColor3 = Theme.Background
    self.MainFrame.BorderSizePixel = 0
    self.MainFrame.Active = true
    self.MainFrame.Draggable = true
    self.MainFrame.Visible = self.Open
    self.MainFrame.Parent = self.Gui
    
    -- Arredondar cantos do frame principal
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = self.MainFrame
    
    -- Barra de título
    local titleBar = Instance.new("Frame")
    titleBar.Size = UDim2.new(1, 0, 0, 40)
    titleBar.Position = UDim2.new(0, 0, 0, 0)
    titleBar.BackgroundColor3 = Theme.Dark
    titleBar.BorderSizePixel = 0
    titleBar.Parent = self.MainFrame
    
    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 12, 0, 0)
    titleCorner.Parent = titleBar
    
    -- Título
    local title = Instance.new("TextLabel")
    title.Text = "GREYX MENU"
    title.Size = UDim2.new(1, 0, 1, 0)
    title.Position = UDim2.new(0, 0, 0, 0)
    title.BackgroundTransparency = 1
    title.TextColor3 = Theme.Primary
    title.Font = Enum.Font.GothamBold
    title.TextSize = 20
    title.TextStrokeTransparency = 0.5
    title.TextStrokeColor3 = Color3.new(0, 0, 0)
    title.Parent = titleBar
    
    local subtitle = Instance.new("TextLabel")
    subtitle.Text = "v" .. getgenv().GreyXVersion
    subtitle.Size = UDim2.new(0, 50, 0, 20)
    subtitle.Position = UDim2.new(1, -60, 0, 10)
    subtitle.BackgroundTransparency = 1
    subtitle.TextColor3 = Theme.Secondary
    subtitle.Font = Enum.Font.Gotham
    subtitle.TextSize = 14
    subtitle.TextXAlignment = Enum.TextXAlignment.Right
    subtitle.Parent = titleBar
    
    -- Área de abas
    local tabsContainer = Instance.new("Frame")
    tabsContainer.Size = UDim2.new(1, 0, 0, 50)
    tabsContainer.Position = UDim2.new(0, 0, 0, 40)
    tabsContainer.BackgroundColor3 = Theme.Dark
    tabsContainer.BorderSizePixel = 0
    tabsContainer.Parent = self.MainFrame
    
    -- Conteúdo das abas
    local contentFrame = Instance.new("Frame")
    contentFrame.Size = UDim2.new(1, -20, 1, -110)
    contentFrame.Position = UDim2.new(0, 10, 0, 100)
    contentFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    contentFrame.BorderSizePixel = 0
    contentFrame.Parent = self.MainFrame
    
    local contentCorner = Instance.new("UICorner")
    contentCorner.CornerRadius = UDim.new(0, 8)
    contentCorner.Parent = contentFrame
    
    -- Abas
    local tabs = {"LegitBot", "Visuals"}
    self.Tabs = {}
    
    for i, tabName in ipairs(tabs) do
        -- Botão da aba
        local tabButton = Instance.new("TextButton")
        tabButton.Name = tabName
        tabButton.Text = tabName
        tabButton.Size = UDim2.new(0.5, 0, 1, 0)
        tabButton.Position = UDim2.new((i-1) * 0.5, 0, 0, 0)
        tabButton.BackgroundColor3 = Theme.Dark
        tabButton.TextColor3 = Theme.Text
        tabButton.Font = Enum.Font.GothamBold
        tabButton.TextSize = 16
        tabButton.BorderSizePixel = 0
        tabButton.AutoButtonColor = false
        tabButton.Parent = tabsContainer
        
        -- Arredondar cantos do botão
        local buttonCorner = Instance.new("UICorner")
        buttonCorner.CornerRadius = UDim.new(0, 8)
        buttonCorner.Parent = tabButton
        
        -- Conteúdo da aba
        local tabContent = Instance.new("ScrollingFrame")
        tabContent.Name = tabName .. "Content"
        tabContent.Size = UDim2.new(1, 0, 1, 0)
        tabContent.Position = UDim2.new(0, 0, 0, 0)
        tabContent.BackgroundTransparency = 1
        tabContent.BorderSizePixel = 0
        tabContent.ScrollBarThickness = 4
        tabContent.ScrollBarImageColor3 = Theme.Primary
        tabContent.Visible = false
        tabContent.Parent = contentFrame
        
        self.Tabs[tabName] = {
            Button = tabButton,
            Content = tabContent,
            Active = false
        }
        
        -- Evento de clique na aba
        tabButton.MouseButton1Click:Connect(function()
            self:SwitchTab(tabName)
        end)
    end
    
    -- Criar conteúdo das abas
    self:CreateLegitBotTab()
    self:CreateVisualsTab()
    
    -- Botão de fechar
    local closeButton = Instance.new("TextButton")
    closeButton.Text = "×"
    closeButton.Size = UDim2.new(0, 30, 0, 30)
    closeButton.Position = UDim2.new(1, -40, 0, 5)
    closeButton.BackgroundColor3 = Theme.Error
    closeButton.TextColor3 = Color3.new(1, 1, 1)
    closeButton.Font = Enum.Font.GothamBold
    closeButton.TextSize = 24
    closeButton.BorderSizePixel = 0
    closeButton.Parent = titleBar
    
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(1, 0)
    closeCorner.Parent = closeButton
    
    closeButton.MouseButton1Click:Connect(function()
        self:Toggle(false)
    end)
    
    -- Adicionar efeito de hover nos botões
    for _, tab in pairs(self.Tabs) do
        tab.Button.MouseEnter:Connect(function()
            if not tab.Active then
                game:GetService("TweenService"):Create(tab.Button, TweenInfo.new(0.2), {
                    BackgroundColor3 = Color3.fromRGB(40, 40, 40)
                }):Play()
            end
        end)
        
        tab.Button.MouseLeave:Connect(function()
            if not tab.Active then
                game:GetService("TweenService"):Create(tab.Button, TweenInfo.new(0.2), {
                    BackgroundColor3 = Theme.Dark
                }):Play()
            end
        end)
    end
    
    -- Mostrar primeira aba
    self:SwitchTab("LegitBot")
    
    -- Parent do GUI
    self.Gui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
end

function Menu:SwitchTab(tabName)
    for name, tab in pairs(self.Tabs) do
        tab.Active = (name == tabName)
        tab.Content.Visible = (name == tabName)
        
        if tab.Active then
            tab.Button.BackgroundColor3 = Theme.Primary
            tab.Button.TextColor3 = Color3.new(0, 0, 0)
            
            -- Garantir que o conteúdo seja rolável
            tab.Content.CanvasSize = UDim2.new(0, 0, 0, tab.Content.UIListLayout.AbsoluteContentSize.Y + 20)
        else
            tab.Button.BackgroundColor3 = Theme.Dark
            tab.Button.TextColor3 = Theme.Text
        end
    end
end

function Menu:CreateLegitBotTab()
    local tab = self.Tabs["LegitBot"]
    local content = tab.Content
    
    -- Lista para organizar elementos
    local listLayout = Instance.new("UIListLayout")
    listLayout.Padding = UDim.new(0, 10)
    listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Parent = content
    
    -- Aimbot Toggle
    local aimbotContainer = self:CreateToggleContainer("AIMBOT", AimbotConfig.Enabled, function(value)
        AimbotConfig.Enabled = value
        if AimbotLoaded and getgenv().Aimbot then
            getgenv().Aimbot.Enabled = value
        end
    end)
    aimbotContainer.LayoutOrder = 1
    aimbotContainer.Parent = content
    
    -- FOV Slider
    local fovContainer = self:CreateSliderContainer("FOV", AimbotConfig.FOV, 50, 200, function(value)
        AimbotConfig.FOV = value
        if AimbotLoaded and getgenv().Aimbot then
            getgenv().Aimbot.FOV = value
        end
    end)
    fovContainer.LayoutOrder = 2
    fovContainer.Parent = content
    
    -- Smoothness Slider (FUNCIONANDO)
    local smoothContainer = self:CreateSliderContainer("SMOOTHNESS", AimbotConfig.Smoothness, 0.1, 1, function(value)
        AimbotConfig.Smoothness = value
        if AimbotLoaded and getgenv().Aimbot then
            getgenv().Aimbot.Smoothness = value
        end
    end, 0.1)
    smoothContainer.LayoutOrder = 3
    smoothContainer.Parent = content
    
    -- Target Part Dropdown
    local targetContainer = self:CreateDropdownContainer("TARGET PART", {"Head", "HumanoidRootPart", "Torso"}, 
        AimbotConfig.TargetPart, function(value)
            AimbotConfig.TargetPart = value
            if AimbotLoaded and getgenv().Aimbot then
                getgenv().Aimbot.TargetPart = value
            end
        end)
    targetContainer.LayoutOrder = 4
    targetContainer.Parent = content
    
    -- Team Check Toggle
    local teamContainer = self:CreateToggleContainer("TEAM CHECK", AimbotConfig.TeamCheck, function(value)
        AimbotConfig.TeamCheck = value
        if AimbotLoaded and getgenv().Aimbot then
            getgenv().Aimbot.TeamCheck = value
        end
    end)
    teamContainer.LayoutOrder = 5
    teamContainer.Parent = content
    
    -- Visible Check Toggle
    local visibleContainer = self:CreateToggleContainer("VISIBLE CHECK", AimbotConfig.VisibleCheck, function(value)
        AimbotConfig.VisibleCheck = value
        if AimbotLoaded and getgenv().Aimbot then
            getgenv().Aimbot.VisibleCheck = value
        end
    end)
    visibleContainer.LayoutOrder = 6
    visibleContainer.Parent = content
end

function Menu:CreateVisualsTab()
    local tab = self.Tabs["Visuals"]
    local content = tab.Content
    
    -- Lista para organizar elementos
    local listLayout = Instance.new("UIListLayout")
    listLayout.Padding = UDim.new(0, 10)
    listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Parent = content
    
    -- ESP Toggle
    local espContainer = self:CreateToggleContainer("ESP", ESPConfig.Enabled, function(value)
        ESPConfig.Enabled = value
        ESP:Toggle(value)
    end)
    espContainer.LayoutOrder = 1
    espContainer.Parent = content
    
    -- Boxes Toggle
    local boxesContainer = self:CreateToggleContainer("BOXES", ESPConfig.Boxes, function(value)
        ESPConfig.Boxes = value
    end)
    boxesContainer.LayoutOrder = 2
    boxesContainer.Parent = content
    
    -- Names Toggle
    local namesContainer = self:CreateToggleContainer("NAMES", ESPConfig.Names, function(value)
        ESPConfig.Names = value
    end)
    namesContainer.LayoutOrder = 3
    namesContainer.Parent = content
    
    -- Health Toggle
    local healthContainer = self:CreateToggleContainer("HEALTH", ESPConfig.Health, function(value)
        ESPConfig.Health = value
    end)
    healthContainer.LayoutOrder = 4
    healthContainer.Parent = content
    
    -- Distance Toggle
    local distanceContainer = self:CreateToggleContainer("DISTANCE", ESPConfig.Distance, function(value)
        ESPConfig.Distance = value
    end)
    distanceContainer.LayoutOrder = 5
    distanceContainer.Parent = content
    
    -- Tracers Toggle
    local tracersContainer = self:CreateToggleContainer("TRACERS", ESPConfig.Tracers, function(value)
        ESPConfig.Tracers = value
    end)
    tracersContainer.LayoutOrder = 6
    tracersContainer.Parent = content
    
    -- Team Check Toggle
    local teamContainer = self:CreateToggleContainer("TEAM CHECK", ESPConfig.TeamCheck, function(value)
        ESPConfig.TeamCheck = value
    end)
    teamContainer.LayoutOrder = 7
    teamContainer.Parent = content
    
    -- Max Distance Slider
    local maxDistanceContainer = self:CreateSliderContainer("MAX DISTANCE", ESPConfig.MaxDistance, 100, 5000, function(value)
        ESPConfig.MaxDistance = value
    end, 100)
    maxDistanceContainer.LayoutOrder = 8
    maxDistanceContainer.Parent = content
end

function Menu:CreateToggleContainer(name, defaultValue, callback)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(0.9, 0, 0, 50)
    container.BackgroundTransparency = 1
    container.LayoutOrder = 1
    
    local label = Instance.new("TextLabel")
    label.Text = name
    label.Size = UDim2.new(0.6, 0, 1, 0)
    label.Position = UDim2.new(0, 0, 0, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = Theme.Text
    label.Font = Enum.Font.Gotham
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = container
    
    local toggleButton = Instance.new("TextButton")
    toggleButton.Size = UDim2.new(0, 60, 0, 30)
    toggleButton.Position = UDim2.new(1, -60, 0.5, -15)
    toggleButton.BackgroundColor3 = defaultValue and Theme.Primary or Color3.fromRGB(60, 60, 60)
    toggleButton.Text = defaultValue and "ON" or "OFF"
    toggleButton.TextColor3 = defaultValue and Color3.new(0, 0, 0) or Theme.Text
    toggleButton.Font = Enum.Font.GothamBold
    toggleButton.TextSize = 12
    toggleButton.BorderSizePixel = 0
    toggleButton.AutoButtonColor = false
    toggleButton.Parent = container
    
    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(1, 0)
    toggleCorner.Parent = toggleButton
    
    toggleButton.MouseButton1Click:Connect(function()
        local newValue = not defaultValue
        defaultValue = newValue
        
        toggleButton.BackgroundColor3 = newValue and Theme.Primary or Color3.fromRGB(60, 60, 60)
        toggleButton.Text = newValue and "ON" or "OFF"
        toggleButton.TextColor3 = newValue and Color3.new(0, 0, 0) or Theme.Text
        
        if callback then
            callback(newValue)
        end
    end)
    
    -- Efeito de hover
    toggleButton.MouseEnter:Connect(function()
        game:GetService("TweenService"):Create(toggleButton, TweenInfo.new(0.2), {
            BackgroundColor3 = defaultValue and Theme.Secondary or Color3.fromRGB(80, 80, 80)
        }):Play()
    end)
    
    toggleButton.MouseLeave:Connect(function()
        game:GetService("TweenService"):Create(toggleButton, TweenInfo.new(0.2), {
            BackgroundColor3 = defaultValue and Theme.Primary or Color3.fromRGB(60, 60, 60)
        }):Play()
    end)
    
    return container
end

function Menu:CreateSliderContainer(name, defaultValue, min, max, callback, step)
    step = step or 1
    
    local container = Instance.new("Frame")
    container.Size = UDim2.new(0.9, 0, 0, 70)
    container.BackgroundTransparency = 1
    container.LayoutOrder = 2
    
    local label = Instance.new("TextLabel")
    label.Text = name .. ": " .. defaultValue
    label.Size = UDim2.new(1, 0, 0, 20)
    label.Position = UDim2.new(0, 0, 0, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = Theme.Text
    label.Font = Enum.Font.Gotham
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Name = "Label"
    label.Parent = container
    
    -- Slider background
    local sliderBg = Instance.new("Frame")
    sliderBg.Size = UDim2.new(1, 0, 0, 20)
    sliderBg.Position = UDim2.new(0, 0, 0, 30)
    sliderBg.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    sliderBg.BorderSizePixel = 0
    sliderBg.Parent = container
    
    local bgCorner = Instance.new("UICorner")
    bgCorner.CornerRadius = UDim.new(1, 0)
    bgCorner.Parent = sliderBg
    
    -- Slider fill
    local fillPercent = (defaultValue - min) / (max - min)
    local sliderFill = Instance.new("Frame")
    sliderFill.Size = UDim2.new(fillPercent, 0, 1, 0)
    sliderFill.Position = UDim2.new(0, 0, 0, 0)
    sliderFill.BackgroundColor3 = Theme.Primary
    sliderFill.BorderSizePixel = 0
    sliderFill.Parent = sliderBg
    
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(1, 0)
    fillCorner.Parent = sliderFill
    
    -- Slider handle
    local sliderHandle = Instance.new("TextButton")
    sliderHandle.Size = UDim2.new(0, 24, 0, 24)
    sliderHandle.Position = UDim2.new(fillPercent, -12, 0.5, -12)
    sliderHandle.BackgroundColor3 = Theme.Secondary
    sliderHandle.Text = ""
    sliderHandle.BorderSizePixel = 0
    sliderHandle.AutoButtonColor = false
    sliderHandle.Parent = sliderBg
    
    local handleCorner = Instance.new("UICorner")
    handleCorner.CornerRadius = UDim.new(1, 0)
    handleCorner.Parent = sliderHandle
    
    -- Controles
    local minusButton = Instance.new("TextButton")
    minusButton.Text = "-"
    minusButton.Size = UDim2.new(0, 30, 0, 30)
    minusButton.Position = UDim2.new(0, 0, 0, 55)
    minusButton.BackgroundColor3 = Theme.Dark
    minusButton.TextColor3 = Theme.Text
    minusButton.Font = Enum.Font.GothamBold
    minusButton.TextSize = 18
    minusButton.BorderSizePixel = 0
    minusButton.Parent = container
    
    local minusCorner = Instance.new("UICorner")
    minusCorner.CornerRadius = UDim.new(0, 8)
    minusCorner.Parent = minusButton
    
    local plusButton = Instance.new("TextButton")
    plusButton.Text = "+"
    plusButton.Size = UDim2.new(0, 30, 0, 30)
    plusButton.Position = UDim2.new(1, -30, 0, 55)
    plusButton.BackgroundColor3 = Theme.Dark
    plusButton.TextColor3 = Theme.Text
    plusButton.Font = Enum.Font.GothamBold
    plusButton.TextSize = 18
    plusButton.BorderSizePixel = 0
    plusButton.Parent = container
    
    local plusCorner = Instance.new("UICorner")
    plusCorner.CornerRadius = UDim.new(0, 8)
    plusCorner.Parent = plusButton
    
    local function updateSlider(value)
        value = math.clamp(value, min, max)
        value = math.floor(value / step) * step -- Arredonda para o step mais próximo
        
        local percent = (value - min) / (max - min)
        
        sliderFill.Size = UDim2.new(percent, 0, 1, 0)
        sliderHandle.Position = UDim2.new(percent, -12, 0.5, -12)
        label.Text = name .. ": " .. value
        
        if callback then
            callback(value)
        end
        
        return value
    end
    
    minusButton.MouseButton1Click:Connect(function()
        defaultValue = updateSlider(defaultValue - step)
    end)
    
    plusButton.MouseButton1Click:Connect(function()
        defaultValue = updateSlider(defaultValue + step)
    end)
    
    -- Efeitos de hover
    minusButton.MouseEnter:Connect(function()
        game:GetService("TweenService"):Create(minusButton, TweenInfo.new(0.2), {
            BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        }):Play()
    end)
    
    minusButton.MouseLeave:Connect(function()
        game:GetService("TweenService"):Create(minusButton, TweenInfo.new(0.2), {
            BackgroundColor3 = Theme.Dark
        }):Play()
    end)
    
    plusButton.MouseEnter:Connect(function()
        game:GetService("TweenService"):Create(plusButton, TweenInfo.new(0.2), {
            BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        }):Play()
    end)
    
    plusButton.MouseLeave:Connect(function()
        game:GetService("TweenService"):Create(plusButton, TweenInfo.new(0.2), {
            BackgroundColor3 = Theme.Dark
        }):Play()
    end)
    
    return container
end

function Menu:CreateDropdownContainer(name, options, defaultValue, callback)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(0.9, 0, 0, 50)
    container.BackgroundTransparency = 1
    container.LayoutOrder = 4
    
    local label = Instance.new("TextLabel")
    label.Text = name
    label.Size = UDim2.new(0.6, 0, 1, 0)
    label.Position = UDim2.new(0, 0, 0, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = Theme.Text
    label.Font = Enum.Font.Gotham
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = container
    
    local dropdownButton = Instance.new("TextButton")
    dropdownButton.Size = UDim2.new(0, 100, 0, 30)
    dropdownButton.Position = UDim2.new(1, -100, 0.5, -15)
    dropdownButton.BackgroundColor3 = Theme.Dark
    dropdownButton.Text = defaultValue
    dropdownButton.TextColor3 = Theme.Text
    dropdownButton.Font = Enum.Font.Gotham
    dropdownButton.TextSize = 12
    dropdownButton.BorderSizePixel = 0
    dropdownButton.AutoButtonColor = false
    dropdownButton.Parent = container
    
    local dropdownCorner = Instance.new("UICorner")
    dropdownCorner.CornerRadius = UDim.new(0, 8)
    dropdownCorner.Parent = dropdownButton
    
    local currentIndex = 1
    for i, option in ipairs(options) do
        if option == defaultValue then
            currentIndex = i
            break
        end
    end
    
    dropdownButton.MouseButton1Click:Connect(function()
        currentIndex = currentIndex + 1
        if currentIndex > #options then
            currentIndex = 1
        end
        
        local newValue = options[currentIndex]
        dropdownButton.Text = newValue
        
        if callback then
            callback(newValue)
        end
    end)
    
    -- Efeito de hover
    dropdownButton.MouseEnter:Connect(function()
        game:GetService("TweenService"):Create(dropdownButton, TweenInfo.new(0.2), {
            BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        }):Play()
    end)
    
    dropdownButton.MouseLeave:Connect(function()
        game:GetService("TweenService"):Create(dropdownButton, TweenInfo.new(0.2), {
            BackgroundColor3 = Theme.Dark
        }):Play()
    end)
    
    return container
end

function Menu:Toggle(visible)
    if not self.MainFrame then
        self:Create()
    end
    
    self.Open = visible
    self.MainFrame.Visible = visible
    
    -- Atualizar o tamanho do canvas das abas quando abrir
    if visible then
        for _, tab in pairs(self.Tabs) do
            wait(0.1) -- Pequeno delay para garantir que os elementos sejam renderizados
            if tab.Content.UIListLayout then
                tab.Content.CanvasSize = UDim2.new(0, 0, 0, tab.Content.UIListLayout.AbsoluteContentSize.Y + 20)
            end
        end
    end
end

--// Sistema de Input
local function SetupInputs()
    -- F5 para abrir/fechar menu
    UserInputService.InputBegan:Connect(function(input, processed)
        if processed then return end
        
        if input.KeyCode == Enum.KeyCode.F5 then
            Menu:Toggle(not Menu.Open)
        end
    end)
end

--// Inicialização
print("\n" .. string.rep("=", 50))
print("GREYX MENU - Preto & Amarelo")
print("Versão: " .. getgenv().GreyXVersion)
print("Menu: ScreenGui com cantos arredondados")
print(string.rep("=", 50))
print("Controles:")
print("F5: Abrir/Fechar Menu")
print(string.rep("=", 50) .. "\n")

-- Inicializar sistemas
ESP:Init()
SetupInputs()

-- Ativar ESP
ESP:Toggle(ESPConfig.Enabled)

print("[GreyX] Script inicializado com sucesso!")
print("[GreyX] Menu GreyX pronto (F5 para abrir)")
print("[GreyX] Smoothness e FOV FUNCIONANDO 100%")

-- Sistema de limpeza
local function Cleanup()
    ESP:Destroy()
    
    if Menu.Gui then
        Menu.Gui:Destroy()
    end
    
    getgenv().GreyX = false
    print("[GreyX] Script desativado!")
end

game:BindToClose(Cleanup)

getgenv().DisableGreyX = Cleanup

getgenv().ReloadGreyX = function()
    Cleanup()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/seu-usuario/GreyX/main/main.lua"))()
end

-- Adicionar atalhos rápidos para ESP
UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    
    if input.KeyCode == Enum.KeyCode.F1 then
        ESPConfig.Enabled = not ESPConfig.Enabled
        ESP:Toggle(ESPConfig.Enabled)
        print("[ESP] " .. (ESPConfig.Enabled and "ON" or "OFF"))
    
    elseif input.KeyCode == Enum.KeyCode.F2 then
        ESPConfig.Boxes = not ESPConfig.Boxes
        print("[Boxes] " .. (ESPConfig.Boxes and "ON" or "OFF"))
    
    elseif input.KeyCode == Enum.KeyCode.F3 then
        ESPConfig.Names = not ESPConfig.Names
        print("[Names] " .. (ESPConfig.Names and "ON" or "OFF"))
    
    elseif input.KeyCode == Enum.KeyCode.F4 then
        ESPConfig.Health = not ESPConfig.Health
        print("[Health] " .. (ESPConfig.Health and "ON" or "OFF"))
    end
end)
