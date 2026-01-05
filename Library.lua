-- ╔══════════════════════════════════════════════════════════════╗
-- ║       RAVYNETH UI V13 - FINAL PERFECT (100% FIXED)          ║
-- ╚══════════════════════════════════════════════════════════════╝

local RavynethUI = {}
RavynethUI.__index = RavynethUI

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")

local Player = Players.LocalPlayer

-- CONFIG SYSTEM
local ConfigFolder = "RavynethHub"
local ConfigFile = "Config.json"
local SavedConfig = {}

local function SaveConfig()
    pcall(function()
        if not isfolder(ConfigFolder) then makefolder(ConfigFolder) end
        writefile(ConfigFolder .. "/" .. ConfigFile, HttpService:JSONEncode(SavedConfig))
    end)
end

local function LoadConfig()
    if not isfolder(ConfigFolder) then makefolder(ConfigFolder) end
    if isfile(ConfigFolder .. "/" .. ConfigFile) then
        pcall(function()
            SavedConfig = HttpService:JSONDecode(readfile(ConfigFolder .. "/" .. ConfigFile))
        end)
    end
end

-- THEME (СТРОГИЙ ЧЕРНО-ФИОЛЕТОВЫЙ)
local Theme = {
    Background = Color3.fromRGB(12, 10, 18),
    BackgroundEnd = Color3.fromRGB(22, 15, 32),
    Sidebar = Color3.fromRGB(18, 14, 24),
    Content = Color3.fromRGB(15, 12, 20),
    Element = Color3.fromRGB(25, 20, 32),
    
    Accent = Color3.fromRGB(138, 43, 226),
    AccentDark = Color3.fromRGB(108, 33, 196),
    AccentLight = Color3.fromRGB(168, 73, 255),
    
    Text = Color3.fromRGB(255, 255, 255),
    TextDim = Color3.fromRGB(170, 170, 190),
    
    Success = Color3.fromRGB(100, 200, 100),
    Warning = Color3.fromRGB(255, 180, 50),
    Error = Color3.fromRGB(255, 80, 80),
    Info = Color3.fromRGB(138, 43, 226)
}

local function Tween(object, properties, duration)
    if not object or not object.Parent then return end
    local tween = TweenService:Create(
        object,
        TweenInfo.new(duration or 0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
        properties
    )
    tween:Play()
    return tween
end

local function Create(class, properties)
    local instance = Instance.new(class)
    for property, value in pairs(properties) do
        if property ~= "Parent" then
            pcall(function() instance[property] = value end)
        end
    end
    if properties.Parent then instance.Parent = properties.Parent end
    return instance
end

-- SHADOW EFFECT
local function AddShadow(parent, intensity)
    intensity = intensity or 0.7
    
    local Shadow = Create("ImageLabel", {
        Name = "Shadow",
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = UDim2.new(1, 30, 1, 30),
        BackgroundTransparency = 1,
        Image = "rbxassetid://5554236805",
        ImageColor3 = Color3.new(0, 0, 0),
        ImageTransparency = intensity,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(23, 23, 277, 277),
        ZIndex = parent.ZIndex - 1,
        Parent = parent
    })
    
    return Shadow
end

function RavynethUI:CreateWindow(config)
    config = config or {}
    local WindowName = config.Name or "Ravyneth Hub"
    local DefaultKey = config.ToggleKey or Enum.KeyCode.RightShift
    local LogoUrl = config.LogoUrl or "https://github.com/axxore/RavynethUI/blob/main/logo.png?raw=true"
    
    LoadConfig()
    
    local Window = {
        Tabs = {},
        CurrentTab = nil,
        Visible = true,
        Minimized = false,
        ToggleKey = SavedConfig.UIToggleKey and Enum.KeyCode[SavedConfig.UIToggleKey] or DefaultKey,
        ShowNotifications = true
    }
    
    function Window:SaveConfig(flag, value)
        SavedConfig[flag] = value
        SaveConfig()
    end
    
    function Window:GetConfig(flag)
        return SavedConfig[flag]
    end
    
    local ScreenGui = Create("ScreenGui", {
        Name = "RavynethUI_" .. HttpService:GenerateGUID(false),
        Parent = CoreGui,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        ResetOnSpawn = false
    })
    
    -- Main Frame
    local MainFrame = Create("Frame", {
        Name = "MainFrame",
        Size = UDim2.new(0, 680, 0, 480),
        Position = UDim2.new(0.5, -340, 0.5, -240),
        BackgroundColor3 = Theme.Background,
        BackgroundTransparency = 0.08,
        BorderSizePixel = 0,
        Active = true,
        ClipsDescendants = false,
        ZIndex = 1,
        Parent = ScreenGui
    })
    
    Create("UICorner", {CornerRadius = UDim.new(0, 14), Parent = MainFrame})
    
    -- GRADIENT
    Create("UIGradient", {
        Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Theme.Background),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(15, 12, 22)),
            ColorSequenceKeypoint.new(1, Theme.BackgroundEnd)
        },
        Rotation = 145,
        Parent = MainFrame
    })
    
    -- MAIN SHADOW
    local MainShadow = Create("ImageLabel", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = UDim2.new(1, 50, 1, 50),
        BackgroundTransparency = 1,
        Image = "rbxassetid://5554236805",
        ImageColor3 = Color3.new(0, 0, 0),
        ImageTransparency = 0.4,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(23, 23, 277, 277),
        ZIndex = 0,
        Parent = MainFrame
    })
    
    -- DRAG SYSTEM
    local dragging = false
    local dragStart = nil
    local startPos = nil
    
    local function StartDrag(input)
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
    end
    
    local function UpdateDrag(input)
        if not dragging then return end
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
    
    UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            UpdateDrag(input)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    -- Header
    local Header = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 50),
        BackgroundColor3 = Theme.Sidebar,
        BackgroundTransparency = 0.5,
        BorderSizePixel = 0,
        ZIndex = 2,
        Parent = MainFrame
    })
    
    Create("UICorner", {CornerRadius = UDim.new(0, 14), Parent = Header})
    
    Create("Frame", {
        Size = UDim2.new(1, 0, 0, 14),
        Position = UDim2.new(0, 0, 1, -14),
        BackgroundColor3 = Theme.Sidebar,
        BackgroundTransparency = 0.5,
        BorderSizePixel = 0,
        ZIndex = 2,
        Parent = Header
    })
    
    -- HEADER DRAG
    local HeaderDragArea = Create("Frame", {
        Name = "DragArea",
        Size = UDim2.new(1, -90, 1, 0),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundTransparency = 1,
        ZIndex = 3,
        Parent = Header
    })
    
    HeaderDragArea.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            StartDrag(input)
        end
    end)
    
    -- LOGO CONTAINER (БЕЗ CLICK AREA!)
    local LogoContainer = Create("Frame", {
        Name = "LogoContainer",
        Size = UDim2.new(0, 220, 1, 0),
        Position = UDim2.new(0, 15, 0, 0),
        BackgroundTransparency = 1,
        ZIndex = 3,
        Parent = Header
    })
    
    local LogoImage = Create("ImageLabel", {
        Name = "RavynethLogo",
        Size = UDim2.new(0, 36, 0, 36),
        Position = UDim2.new(0, 0, 0.5, -18),
        BackgroundTransparency = 1,
        Image = LogoUrl,
        ScaleType = Enum.ScaleType.Fit,
        ImageTransparency = 0,
        ZIndex = 4,
        Parent = LogoContainer
    })
    
    local LogoText = Create("TextLabel", {
        Size = UDim2.new(1, -45, 0, 24),
        Position = UDim2.new(0, 45, 0, 6),
        BackgroundTransparency = 1,
        Text = "RAVYNETH",
        TextColor3 = Theme.Text,
        TextSize = 18,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 4,
        Parent = LogoContainer
    })
    
    local LogoSubtext = Create("TextLabel", {
        Size = UDim2.new(1, -45, 0, 12),
        Position = UDim2.new(0, 45, 0, 28),
        BackgroundTransparency = 1,
        Text = "ADVANCED SCRIPT HUB",
        TextColor3 = Theme.TextDim,
        TextSize = 8,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 4,
        Parent = LogoContainer
    })
    
    -- Buttons Container (FIXED: БЕЗ НАЛОЖЕНИЯ)
    local ButtonContainer = Create("Frame", {
        Size = UDim2.new(0, 74, 0, 32),
        Position = UDim2.new(1, -84, 0, 9),
        BackgroundTransparency = 1,
        ZIndex = 3,
        Parent = Header
    })
    
    Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        HorizontalAlignment = Enum.HorizontalAlignment.Right,
        Padding = UDim.new(0, 8),
        Parent = ButtonContainer
    })
    
    local MinimizeBtn = Create("TextButton", {
        Size = UDim2.new(0, 33, 0, 32),
        BackgroundColor3 = Theme.Element,
        BackgroundTransparency = 0.4,
        Text = "━",
        TextColor3 = Theme.Text,
        TextSize = 14,
        Font = Enum.Font.GothamBold,
        AutoButtonColor = false,
        ZIndex = 4,
        Parent = ButtonContainer
    })
    
    Create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = MinimizeBtn})
    AddShadow(MinimizeBtn, 0.8)
    
    MinimizeBtn.MouseEnter:Connect(function()
        Tween(MinimizeBtn, {BackgroundColor3 = Theme.Accent, BackgroundTransparency = 0.2}, 0.15)
    end)
    
    MinimizeBtn.MouseLeave:Connect(function()
        Tween(MinimizeBtn, {BackgroundColor3 = Theme.Element, BackgroundTransparency = 0.4}, 0.15)
    end)
    
    local CloseBtn = Create("TextButton", {
        Size = UDim2.new(0, 33, 0, 32),
        BackgroundColor3 = Theme.Element,
        BackgroundTransparency = 0.4,
        Text = "×",
        TextColor3 = Theme.Text,
        TextSize = 22,
        Font = Enum.Font.GothamBold,
        AutoButtonColor = false,
        ZIndex = 4,
        Parent = ButtonContainer
    })
    
    Create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = CloseBtn})
    AddShadow(CloseBtn, 0.8)
    
    CloseBtn.MouseEnter:Connect(function()
        Tween(CloseBtn, {BackgroundColor3 = Color3.fromRGB(220, 60, 60), BackgroundTransparency = 0.2}, 0.15)
    end)
    
    CloseBtn.MouseLeave:Connect(function()
        Tween(CloseBtn, {BackgroundColor3 = Theme.Element, BackgroundTransparency = 0.4}, 0.15)
    end)
    
    CloseBtn.MouseButton1Click:Connect(function()
        Window:Destroy()
    end)
    
    -- Sidebar
    local Sidebar = Create("Frame", {
        Name = "Sidebar",
        Size = UDim2.new(0, 130, 1, -60),
        Position = UDim2.new(0, 10, 0, 55),
        BackgroundColor3 = Theme.Sidebar,
        BackgroundTransparency = 0.4,
        BorderSizePixel = 0,
        ZIndex = 2,
        Parent = MainFrame
    })
    
    Create("UICorner", {CornerRadius = UDim.new(0, 10), Parent = Sidebar})
    AddShadow(Sidebar, 0.85)
    
    local SidebarList = Create("ScrollingFrame", {
        Size = UDim2.new(1, -10, 1, -10),
        Position = UDim2.new(0, 5, 0, 5),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = Theme.Accent,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ZIndex = 3,
        Parent = Sidebar
    })
    
    Create("UIListLayout", {
        Padding = UDim.new(0, 6),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = SidebarList
    })
    
    Create("UIPadding", {
        PaddingTop = UDim.new(0, 5),
        PaddingLeft = UDim.new(0, 5),
        PaddingRight = UDim.new(0, 5),
        Parent = SidebarList
    })
    
    -- Content
    local ContentContainer = Create("Frame", {
        Name = "ContentContainer",
        Size = UDim2.new(1, -155, 1, -60),
        Position = UDim2.new(0, 145, 0, 55),
        BackgroundColor3 = Theme.Content,
        BackgroundTransparency = 0.4,
        BorderSizePixel = 0,
        ZIndex = 2,
        Parent = MainFrame
    })
    
    Create("UICorner", {CornerRadius = UDim.new(0, 10), Parent = ContentContainer})
    AddShadow(ContentContainer, 0.85)
    
    -- MINIMIZE/EXPAND (FIXED: ТОЛЬКО КНОПКА!)
    MinimizeBtn.MouseButton1Click:Connect(function()
        Window.Minimized = not Window.Minimized
        
        if Window.Minimized then
            -- MINIMIZE
            Tween(MainFrame, {Size = UDim2.new(0, 230, 0, 50)}, 0.25)
            
            task.wait(0.1)
            
            Sidebar.Visible = false
            ContentContainer.Visible = false
            ButtonContainer.Visible = false
            HeaderDragArea.Visible = false
            
            MinimizeBtn.Text = "+"
            MinimizeBtn.Size = UDim2.new(0, 33, 0, 32)
            MinimizeBtn.Position = UDim2.new(1, -43, 0, 9)
            MinimizeBtn.Parent = Header
            
            -- LOGO HOVER EFFECT
            LogoText.MouseEnter:Connect(function()
                Tween(LogoText, {TextSize = 20}, 0.15)
            end)
            
            LogoText.MouseLeave:Connect(function()
                Tween(LogoText, {TextSize = 18}, 0.15)
            end)
            
        else
            -- EXPAND
            Sidebar.Visible = true
            ContentContainer.Visible = true
            ButtonContainer.Visible = true
            HeaderDragArea.Visible = true
            
            MinimizeBtn.Text = "━"
            MinimizeBtn.Parent = ButtonContainer
            
            Tween(MainFrame, {Size = UDim2.new(0, 680, 0, 480)}, 0.25)
        end
    end)
    
    -- Window Functions
    function Window:Toggle()
        Window.Visible = not Window.Visible
        MainFrame.Visible = Window.Visible
    end
    
    function Window:Destroy()
        Tween(MainFrame, {BackgroundTransparency = 1}, 0.3)
        Tween(MainShadow, {ImageTransparency = 1}, 0.3)
        task.wait(0.3)
        ScreenGui:Destroy()
    end
    
    function Window:SetToggleKey(newKey)
        Window.ToggleKey = newKey
        SavedConfig.UIToggleKey = tostring(newKey)
        SaveConfig()
    end
    
    -- FIXED: HOTKEY РАБОТАЕТ
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if not gameProcessed and input.KeyCode == Window.ToggleKey then
            Window:Toggle()
        end
    end)
    
    -- Create Tab
    function Window:CreateTab(tabName)
        local Tab = {
            Name = tabName,
            Container = nil
        }
        
        local TabButton = Create("TextButton", {
            Size = UDim2.new(1, 0, 0, 38),
            BackgroundColor3 = Theme.Element,
            BackgroundTransparency = 0.4,
            Text = "",
            AutoButtonColor = false,
            ZIndex = 4,
            Parent = SidebarList
        })
        
        Create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = TabButton})
        
        local TabLabel = Create("TextLabel", {
            Size = UDim2.new(1, -16, 1, 0),
            Position = UDim2.new(0, 10, 0, 0),
            BackgroundTransparency = 1,
            Text = tabName,
            TextColor3 = Theme.TextDim,
            TextSize = 13,
            Font = Enum.Font.GothamBold,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 5,
            Parent = TabButton
        })
        
        local TabContent = Create("ScrollingFrame", {
            Name = tabName .. "Content",
            Size = UDim2.new(1, -20, 1, -20),
            Position = UDim2.new(0, 10, 0, 10),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ScrollBarThickness = 4,
            ScrollBarImageColor3 = Theme.Accent,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            Visible = false,
            ZIndex = 3,
            Parent = ContentContainer
        })
        
        Create("UIListLayout", {
            Padding = UDim.new(0, 8),
            SortOrder = Enum.SortOrder.LayoutOrder,
            Parent = TabContent
        })
        
        Tab.Container = TabContent
        
        TabButton.MouseEnter:Connect(function()
            if Window.CurrentTab ~= Tab then
                Tween(TabButton, {BackgroundTransparency = 0.2}, 0.15)
            end
        end)
        
        TabButton.MouseLeave:Connect(function()
            if Window.CurrentTab ~= Tab then
                Tween(TabButton, {BackgroundTransparency = 0.4}, 0.15)
            end
        end)
        
        TabButton.MouseButton1Click:Connect(function()
            for _, tab in pairs(Window.Tabs) do
                tab.Container.Visible = false
                Tween(tab.Button, {BackgroundColor3 = Theme.Element, BackgroundTransparency = 0.4}, 0.15)
                Tween(tab.Label, {TextColor3 = Theme.TextDim}, 0.15)
            end
            
            TabContent.Visible = true
            Tween(TabButton, {BackgroundColor3 = Theme.Accent, BackgroundTransparency = 0.2}, 0.15)
            Tween(TabLabel, {TextColor3 = Theme.Text}, 0.15)
            Window.CurrentTab = Tab
        end)
        
        Tab.Button = TabButton
        Tab.Label = TabLabel
        
        table.insert(Window.Tabs, Tab)
        
        if #Window.Tabs == 1 then
            TabButton.BackgroundColor3 = Theme.Accent
            TabButton.BackgroundTransparency = 0.2
            TabLabel.TextColor3 = Theme.Text
            TabContent.Visible = true
            Window.CurrentTab = Tab
        end
        
        -- SECTION
        function Tab:CreateSection(sectionName)
            local SectionFrame = Create("Frame", {
                Size = UDim2.new(1, 0, 0, 32),
                BackgroundTransparency = 1,
                ZIndex = 4,
                Parent = TabContent
            })
            
            local SectionLabel = Create("TextLabel", {
                Size = UDim2.new(1, -16, 1, -6),
                Position = UDim2.new(0, 8, 0, 0),
                BackgroundTransparency = 1,
                Text = sectionName,
                TextColor3 = Theme.Accent,
                TextSize = 15,
                Font = Enum.Font.GothamBold,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = 5,
                Parent = SectionFrame
            })
            
            local Divider = Create("Frame", {
                Size = UDim2.new(1, -16, 0, 2),
                Position = UDim2.new(0, 8, 1, -4),
                BackgroundColor3 = Theme.Accent,
                BackgroundTransparency = 0.5,
                BorderSizePixel = 0,
                ZIndex = 5,
                Parent = SectionFrame
            })
            
            Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = Divider})
        end
        
        -- LABEL
        function Tab:CreateLabel(text)
            local LabelFrame = Create("Frame", {
                Size = UDim2.new(1, 0, 0, 26),
                BackgroundTransparency = 1,
                ZIndex = 4,
                Parent = TabContent
            })
            
            local Label = Create("TextLabel", {
                Size = UDim2.new(1, -16, 1, 0),
                Position = UDim2.new(0, 8, 0, 0),
                BackgroundTransparency = 1,
                Text = text,
                TextColor3 = Theme.TextDim,
                TextSize = 12,
                Font = Enum.Font.Gotham,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextWrapped = true,
                ZIndex = 5,
                Parent = LabelFrame
            })
            
            local LabelObject = {}
            function LabelObject:Set(newText)
                if Label and Label.Parent then Label.Text = newText end
            end
            return LabelObject
        end
        
        -- TOGGLE
        function Tab:CreateToggle(config)
            config = config or {}
            local Name = config.Name or "Toggle"
            local Flag = config.Flag or Name
            local CurrentValue = SavedConfig[Flag]
            if CurrentValue == nil then CurrentValue = config.CurrentValue or false end
            local Callback = config.Callback or function() end
            
            local ToggleFrame = Create("Frame", {
                Size = UDim2.new(1, 0, 0, 38),
                BackgroundColor3 = Theme.Element,
                BackgroundTransparency = 0.4,
                BorderSizePixel = 0,
                ZIndex = 4,
                Parent = TabContent
            })
            
            Create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = ToggleFrame})
            AddShadow(ToggleFrame, 0.9)
            
            local ToggleLabel = Create("TextLabel", {
                Size = UDim2.new(1, -50, 1, 0),
                Position = UDim2.new(0, 12, 0, 0),
                BackgroundTransparency = 1,
                Text = Name,
                TextColor3 = Theme.Text,
                TextSize = 12,
                Font = Enum.Font.GothamSemibold,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = 5,
                Parent = ToggleFrame
            })
            
            local ToggleButton = Create("TextButton", {
                Size = UDim2.new(0, 40, 0, 22),
                Position = UDim2.new(1, -46, 0.5, -11),
                BackgroundColor3 = CurrentValue and Theme.Accent or Theme.Content,
                BackgroundTransparency = 0.2,
                Text = "",
                AutoButtonColor = false,
                ZIndex = 5,
                Parent = ToggleFrame
            })
            
            Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = ToggleButton})
            
            local ToggleCircle = Create("Frame", {
                Size = UDim2.new(0, 18, 0, 18),
                Position = CurrentValue and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9),
                BackgroundColor3 = Theme.Text,
                BorderSizePixel = 0,
                ZIndex = 6,
                Parent = ToggleButton
            })
            
            Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = ToggleCircle})
            
            local ToggleObject = {Value = CurrentValue}
            
            local function Update()
                if not ToggleButton or not ToggleButton.Parent then return end
                Tween(ToggleButton, {BackgroundColor3 = CurrentValue and Theme.Accent or Theme.Content}, 0.2)
                Tween(ToggleCircle, {Position = CurrentValue and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)}, 0.2)
                SavedConfig[Flag] = CurrentValue
                SaveConfig()
                Callback(CurrentValue)
            end
            
            ToggleButton.MouseButton1Click:Connect(function()
                CurrentValue = not CurrentValue
                ToggleObject.Value = CurrentValue
                Update()
            end)
            
            function ToggleObject:Set(value)
                CurrentValue = value
                ToggleObject.Value = value
                Update()
            end
            
            pcall(Callback, CurrentValue)
            return ToggleObject
        end
        
        -- SLIDER
        function Tab:CreateSlider(config)
            config = config or {}
            local Name = config.Name or "Slider"
            local Flag = config.Flag or Name
            local Range = config.Range or {0, 100}
            local Increment = config.Increment or 1
            local CurrentValue = SavedConfig[Flag] or config.CurrentValue or Range[1]
            local Callback = config.Callback or function() end
            local Suffix = config.Suffix or ""
            
            local SliderFrame = Create("Frame", {
                Size = UDim2.new(1, 0, 0, 52),
                BackgroundColor3 = Theme.Element,
                BackgroundTransparency = 0.4,
                BorderSizePixel = 0,
                ZIndex = 4,
                Parent = TabContent
            })
            
            Create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = SliderFrame})
            AddShadow(SliderFrame, 0.9)
            
            local SliderLabel = Create("TextLabel", {
                Size = UDim2.new(1, -16, 0, 20),
                Position = UDim2.new(0, 12, 0, 8),
                BackgroundTransparency = 1,
                Text = Name,
                TextColor3 = Theme.Text,
                TextSize = 12,
                Font = Enum.Font.GothamSemibold,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = 5,
                Parent = SliderFrame
            })
            
            local SliderTrack = Create("Frame", {
                Size = UDim2.new(1, -85, 0, 6),
                Position = UDim2.new(0, 12, 1, -16),
                BackgroundColor3 = Theme.Content,
                BackgroundTransparency = 0.3,
                BorderSizePixel = 0,
                ZIndex = 5,
                Parent = SliderFrame
            })
            
            Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = SliderTrack})
            
            local percentage = math.clamp((CurrentValue - Range[1]) / (Range[2] - Range[1]), 0, 1)
            
            local SliderFill = Create("Frame", {
                Size = UDim2.new(percentage, 0, 1, 0),
                BackgroundColor3 = Theme.Accent,
                BackgroundTransparency = 0.2,
                BorderSizePixel = 0,
                ZIndex = 6,
                Parent = SliderTrack
            })
            
            Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = SliderFill})
            
            local SliderDot = Create("Frame", {
                Size = UDim2.new(0, 14, 0, 14),
                Position = UDim2.new(percentage, -7, 0.5, -7),
                BackgroundColor3 = Theme.Text,
                BorderSizePixel = 0,
                ZIndex = 7,
                Parent = SliderTrack
            })
            
            Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = SliderDot})
            
            local ValueLabel = Create("TextLabel", {
                Size = UDim2.new(0, 60, 0, 20),
                Position = UDim2.new(1, -70, 1, -18),
                BackgroundTransparency = 1,
                Text = tostring(CurrentValue) .. Suffix,
                TextColor3 = Theme.Accent,
                TextSize = 12,
                Font = Enum.Font.GothamBold,
                TextXAlignment = Enum.TextXAlignment.Right,
                ZIndex = 5,
                Parent = SliderFrame
            })
            
            local Dragging = false
            
            local function UpdateSlider(input)
                if not SliderTrack or not SliderTrack.Parent then return end
                local mousePos = input.Position.X
                local trackPos = SliderTrack.AbsolutePosition.X
                local trackSize = SliderTrack.AbsoluteSize.X
                local percent = math.clamp((mousePos - trackPos) / trackSize, 0, 1)
                local value = Range[1] + (Range[2] - Range[1]) * percent
                value = math.floor(value / Increment + 0.5) * Increment
                value = math.clamp(value, Range[1], Range[2])
                
                CurrentValue = value
                ValueLabel.Text = tostring(value) .. Suffix
                Tween(SliderFill, {Size = UDim2.new(percent, 0, 1, 0)}, 0.1)
                Tween(SliderDot, {Position = UDim2.new(percent, -7, 0.5, -7)}, 0.1)
                
                SavedConfig[Flag] = value
                SaveConfig()
                Callback(value)
            end
            
            SliderTrack.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    Dragging = true
                    UpdateSlider(input)
                end
            end)
            
            UserInputService.InputChanged:Connect(function(input)
                if Dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                    UpdateSlider(input)
                end
            end)
            
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    Dragging = false
                end
            end)
            
            pcall(Callback, CurrentValue)
        end
        
        -- TOGGLE + SLIDER
        function Tab:CreateToggleSlider(config)
            config = config or {}
            local Name = config.Name or "Toggle Slider"
            local ToggleFlag = config.ToggleFlag or Name .. "_Toggle"
            local SliderFlag = config.SliderFlag or Name .. "_Slider"
            local ToggleValue = SavedConfig[ToggleFlag]
            if ToggleValue == nil then ToggleValue = config.ToggleValue or false end
            local Range = config.Range or {0, 100}
            local Increment = config.Increment or 1
            local SliderValue = SavedConfig[SliderFlag] or config.SliderValue or Range[1]
            local ToggleCallback = config.ToggleCallback or function() end
            local SliderCallback = config.SliderCallback or function() end
            local Suffix = config.Suffix or ""
            
            local Frame = Create("Frame", {
                Size = UDim2.new(1, 0, 0, 52),
                BackgroundColor3 = Theme.Element,
                BackgroundTransparency = 0.4,
                BorderSizePixel = 0,
                ZIndex = 4,
                Parent = TabContent
            })
            
            Create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = Frame})
            AddShadow(Frame, 0.9)
            
            local Label = Create("TextLabel", {
                Size = UDim2.new(1, -50, 0, 20),
                Position = UDim2.new(0, 12, 0, 8),
                BackgroundTransparency = 1,
                Text = Name,
                TextColor3 = Theme.Text,
                TextSize = 12,
                Font = Enum.Font.GothamSemibold,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = 5,
                Parent = Frame
            })
            
            local ToggleButton = Create("TextButton", {
                Size = UDim2.new(0, 40, 0, 22),
                Position = UDim2.new(1, -46, 0, 6),
                BackgroundColor3 = ToggleValue and Theme.Accent or Theme.Content,
                BackgroundTransparency = 0.2,
                Text = "",
                AutoButtonColor = false,
                ZIndex = 5,
                Parent = Frame
            })
            
            Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = ToggleButton})
            
            local ToggleCircle = Create("Frame", {
                Size = UDim2.new(0, 18, 0, 18),
                Position = ToggleValue and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9),
                BackgroundColor3 = Theme.Text,
                BorderSizePixel = 0,
                ZIndex = 6,
                Parent = ToggleButton
            })
            
            Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = ToggleCircle})
            
            local SliderTrack = Create("Frame", {
                Size = UDim2.new(1, -85, 0, 6),
                Position = UDim2.new(0, 12, 1, -16),
                BackgroundColor3 = Theme.Content,
                BackgroundTransparency = 0.3,
                BorderSizePixel = 0,
                ZIndex = 5,
                Parent = Frame
            })
            
            Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = SliderTrack})
            
            local percentage = math.clamp((SliderValue - Range[1]) / (Range[2] - Range[1]), 0, 1)
            
            local SliderFill = Create("Frame", {
                Size = UDim2.new(percentage, 0, 1, 0),
                BackgroundColor3 = Theme.Accent,
                BackgroundTransparency = 0.2,
                BorderSizePixel = 0,
                ZIndex = 6,
                Parent = SliderTrack
            })
            
            Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = SliderFill})
            
            local SliderDot = Create("Frame", {
                Size = UDim2.new(0, 14, 0, 14),
                Position = UDim2.new(percentage, -7, 0.5, -7),
                BackgroundColor3 = Theme.Text,
                BorderSizePixel = 0,
                ZIndex = 7,
                Parent = SliderTrack
            })
            
            Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = SliderDot})
            
            local ValueLabel = Create("TextLabel", {
                Size = UDim2.new(0, 60, 0, 20),
                Position = UDim2.new(1, -70, 1, -18),
                BackgroundTransparency = 1,
                Text = tostring(SliderValue) .. Suffix,
                TextColor3 = Theme.Accent,
                TextSize = 12,
                Font = Enum.Font.GothamBold,
                TextXAlignment = Enum.TextXAlignment.Right,
                ZIndex = 5,
                Parent = Frame
            })
            
            local ToggleSliderObject = {ToggleValue = ToggleValue, SliderValue = SliderValue}
            
            function ToggleSliderObject:SetToggle(value)
                ToggleValue = value
                ToggleSliderObject.ToggleValue = value
                Tween(ToggleButton, {BackgroundColor3 = ToggleValue and Theme.Accent or Theme.Content}, 0.2)
                Tween(ToggleCircle, {Position = ToggleValue and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)}, 0.2)
                SavedConfig[ToggleFlag] = ToggleValue
                SaveConfig()
                ToggleCallback(ToggleValue)
            end
            
            ToggleButton.MouseButton1Click:Connect(function()
                ToggleValue = not ToggleValue
                ToggleSliderObject.ToggleValue = ToggleValue
                Tween(ToggleButton, {BackgroundColor3 = ToggleValue and Theme.Accent or Theme.Content}, 0.2)
                Tween(ToggleCircle, {Position = ToggleValue and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)}, 0.2)
                SavedConfig[ToggleFlag] = ToggleValue
                SaveConfig()
                ToggleCallback(ToggleValue)
            end)
            
            local Dragging = false
            
            local function UpdateSlider(input)
                if not SliderTrack or not SliderTrack.Parent then return end
                local mousePos = input.Position.X
                local trackPos = SliderTrack.AbsolutePosition.X
                local trackSize = SliderTrack.AbsoluteSize.X
                local percent = math.clamp((mousePos - trackPos) / trackSize, 0, 1)
                local value = Range[1] + (Range[2] - Range[1]) * percent
                value = math.floor(value / Increment + 0.5) * Increment
                value = math.clamp(value, Range[1], Range[2])
                
                SliderValue = value
                ToggleSliderObject.SliderValue = value
                ValueLabel.Text = tostring(value) .. Suffix
                Tween(SliderFill, {Size = UDim2.new(percent, 0, 1, 0)}, 0.1)
                Tween(SliderDot, {Position = UDim2.new(percent, -7, 0.5, -7)}, 0.1)
                
                SavedConfig[SliderFlag] = value
                SaveConfig()
                SliderCallback(value)
            end
            
            SliderTrack.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    Dragging = true
                    UpdateSlider(input)
                end
            end)
            
            UserInputService.InputChanged:Connect(function(input)
                if Dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                    UpdateSlider(input)
                end
            end)
            
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    Dragging = false
                end
            end)
            
            pcall(ToggleCallback, ToggleValue)
            pcall(SliderCallback, SliderValue)
            
            return ToggleSliderObject
        end
        
        -- DROPDOWN
        function Tab:CreateDropdown(config)
            config = config or {}
            local Name = config.Name or "Dropdown"
            local Flag = config.Flag or Name
            local Options = config.Options or {}
            local MultipleOptions = config.MultipleOptions or false
            local shouldSave = not string.find(Flag, "_NOSAVE")
            local CurrentOption = (shouldSave and SavedConfig[Flag]) or config.CurrentOption or (MultipleOptions and {} or {})
            local Callback = config.Callback or function() end
            
            if type(CurrentOption) ~= "table" then CurrentOption = {CurrentOption} end
            
            local DropdownFrame = Create("Frame", {
                Size = UDim2.new(1, 0, 0, 38),
                BackgroundColor3 = Theme.Element,
                BackgroundTransparency = 0.4,
                BorderSizePixel = 0,
                ZIndex = 4,
                Parent = TabContent
            })
            
            Create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = DropdownFrame})
            AddShadow(DropdownFrame, 0.9)
            
            local DropdownButton = Create("TextButton", {
                Size = UDim2.new(1, 0, 0, 38),
                BackgroundTransparency = 1,
                Text = "",
                AutoButtonColor = false,
                ZIndex = 5,
                Parent = DropdownFrame
            })
            
            local DropdownLabel = Create("TextLabel", {
                Size = UDim2.new(1, -40, 1, 0),
                Position = UDim2.new(0, 12, 0, 0),
                BackgroundTransparency = 1,
                Text = Name,
                TextColor3 = Theme.Text,
                TextSize = 12,
                Font = Enum.Font.GothamSemibold,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = 6,
                Parent = DropdownButton
            })
            
            local DropdownIcon = Create("TextLabel", {
                Size = UDim2.new(0, 20, 1, 0),
                Position = UDim2.new(1, -28, 0, 0),
                BackgroundTransparency = 1,
                Text = "▼",
                TextColor3 = Theme.Accent,
                TextSize = 10,
                Font = Enum.Font.Gotham,
                ZIndex = 6,
                Parent = DropdownButton
            })
            
            local DropdownList = Create("ScrollingFrame", {
                Size = UDim2.new(1, 0, 0, 0),
                Position = UDim2.new(0, 0, 0, 42),
                BackgroundColor3 = Theme.Content,
                BackgroundTransparency = 0.15,
                BorderSizePixel = 0,
                Visible = false,
                ScrollBarThickness = 3,
                ScrollBarImageColor3 = Theme.Accent,
                CanvasSize = UDim2.new(0, 0, 0, 0),
                AutomaticCanvasSize = Enum.AutomaticSize.Y,
                ZIndex = 10,
                Parent = DropdownFrame
            })
            
            Create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = DropdownList})
            AddShadow(DropdownList, 0.8)
            
            Create("UIListLayout", {
                Padding = UDim.new(0, 3),
                Parent = DropdownList
            })
            
            Create("UIPadding", {
                PaddingTop = UDim.new(0, 6),
                PaddingBottom = UDim.new(0, 6),
                PaddingLeft = UDim.new(0, 6),
                PaddingRight = UDim.new(0, 6),
                Parent = DropdownList
            })
            
            local Expanded = false
            
            DropdownButton.MouseButton1Click:Connect(function()
                Expanded = not Expanded
                DropdownList.Visible = Expanded
                
                local targetHeight = math.min(#Options * 30 + 12, 150)
                local frameSize = Expanded and UDim2.new(1, 0, 0, 42 + targetHeight) or UDim2.new(1, 0, 0, 38)
                
                Tween(DropdownList, {Size = Expanded and UDim2.new(1, 0, 0, targetHeight) or UDim2.new(1, 0, 0, 0)}, 0.2)
                Tween(DropdownIcon, {Rotation = Expanded and 180 or 0}, 0.2)
                Tween(DropdownFrame, {Size = frameSize}, 0.2)
            end)
            
            for _, option in ipairs(Options) do
                local OptionButton = Create("TextButton", {
                    Size = UDim2.new(1, 0, 0, 28),
                    BackgroundColor3 = Theme.Element,
                    BackgroundTransparency = 0.4,
                    Text = "",
                    AutoButtonColor = false,
                    ZIndex = 11,
                    Parent = DropdownList
                })
                
                Create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = OptionButton})
                
                local OptionLabel = Create("TextLabel", {
                    Size = UDim2.new(1, -14, 1, 0),
                    Position = UDim2.new(0, 8, 0, 0),
                    BackgroundTransparency = 1,
                    Text = option,
                    TextColor3 = Theme.TextDim,
                    TextSize = 11,
                    Font = Enum.Font.Gotham,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ZIndex = 12,
                    Parent = OptionButton
                })
                
                OptionButton.MouseEnter:Connect(function()
                    if not table.find(CurrentOption, option) then
                        Tween(OptionButton, {BackgroundTransparency = 0.2}, 0.1)
                    end
                end)
                
                OptionButton.MouseLeave:Connect(function()
                    if not table.find(CurrentOption, option) then
                        Tween(OptionButton, {BackgroundTransparency = 0.4}, 0.1)
                    end
                end)
                
                OptionButton.MouseButton1Click:Connect(function()
                    if MultipleOptions then
                        local found = table.find(CurrentOption, option)
                        if found then
                            table.remove(CurrentOption, found)
                            Tween(OptionButton, {BackgroundColor3 = Theme.Element, BackgroundTransparency = 0.4}, 0.15)
                            Tween(OptionLabel, {TextColor3 = Theme.TextDim}, 0.15)
                        else
                            table.insert(CurrentOption, option)
                            Tween(OptionButton, {BackgroundColor3 = Theme.Accent, BackgroundTransparency = 0.2}, 0.15)
                            Tween(OptionLabel, {TextColor3 = Theme.Text}, 0.15)
                        end
                    else
                        CurrentOption = {option}
                        for _, btn in ipairs(DropdownList:GetChildren()) do
                            if btn:IsA("TextButton") then
                                Tween(btn, {BackgroundColor3 = Theme.Element, BackgroundTransparency = 0.4}, 0.15)
                                local lbl = btn:FindFirstChildOfClass("TextLabel")
                                if lbl then Tween(lbl, {TextColor3 = Theme.TextDim}, 0.15) end
                            end
                        end
                        Tween(OptionButton, {BackgroundColor3 = Theme.Accent, BackgroundTransparency = 0.2}, 0.15)
                        Tween(OptionLabel, {TextColor3 = Theme.Text}, 0.15)
                    end
                    
                    if shouldSave then
                        SavedConfig[Flag] = CurrentOption
                        SaveConfig()
                    end
                    Callback(MultipleOptions and CurrentOption or CurrentOption[1])
                end)
                
                if table.find(CurrentOption, option) then
                    OptionButton.BackgroundColor3 = Theme.Accent
                    OptionButton.BackgroundTransparency = 0.2
                    OptionLabel.TextColor3 = Theme.Text
                end
            end
        end
        
        -- KEYBIND
        function Tab:CreateKeybind(config)
            config = config or {}
            local Name = config.Name or "Keybind"
            local Flag = config.Flag or Name
            local CurrentKeybind = SavedConfig[Flag] or config.CurrentKeybind or "None"
            local Callback = config.Callback or function() end
            
            local KeybindFrame = Create("Frame", {
                Size = UDim2.new(1, 0, 0, 38),
                BackgroundColor3 = Theme.Element,
                BackgroundTransparency = 0.4,
                BorderSizePixel = 0,
                ZIndex = 4,
                Parent = TabContent
            })
            
            Create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = KeybindFrame})
            AddShadow(KeybindFrame, 0.9)
            
            local KeybindLabel = Create("TextLabel", {
                Size = UDim2.new(1, -85, 1, 0),
                Position = UDim2.new(0, 12, 0, 0),
                BackgroundTransparency = 1,
                Text = Name,
                TextColor3 = Theme.Text,
                TextSize = 12,
                Font = Enum.Font.GothamSemibold,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = 5,
                Parent = KeybindFrame
            })
            
            local KeybindButton = Create("TextButton", {
                Size = UDim2.new(0, 70, 0, 26),
                Position = UDim2.new(1, -78, 0.5, -13),
                BackgroundColor3 = Theme.Content,
                BackgroundTransparency = 0.3,
                Text = CurrentKeybind,
                TextColor3 = Theme.Text,
                TextSize = 11,
                Font = Enum.Font.GothamBold,
                AutoButtonColor = false,
                ZIndex = 5,
                Parent = KeybindFrame
            })
            
            Create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = KeybindButton})
            
            local Binding = false
            local Connection = nil
            
            KeybindButton.MouseEnter:Connect(function()
                if not Binding then
                    Tween(KeybindButton, {BackgroundColor3 = Theme.Element}, 0.15)
                end
            end)
            
            KeybindButton.MouseLeave:Connect(function()
                if not Binding then
                    Tween(KeybindButton, {BackgroundColor3 = Theme.Content}, 0.15)
                end
            end)
            
            KeybindButton.MouseButton1Click:Connect(function()
                if Binding then return end
                Binding = true
                KeybindButton.Text = "..."
                Tween(KeybindButton, {BackgroundColor3 = Theme.Accent}, 0.15)
                
                if Connection then Connection:Disconnect() end
                
                Connection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
                    if Binding and input.UserInputType == Enum.UserInputType.Keyboard then
                        local keyName = input.KeyCode.Name
                        CurrentKeybind = keyName
                        KeybindButton.Text = keyName
                        
                        SavedConfig[Flag] = keyName
                        SaveConfig()
                        
                        Binding = false
                        Tween(KeybindButton, {BackgroundColor3 = Theme.Content}, 0.15)
                        
                        if Connection then
                            Connection:Disconnect()
                            Connection = nil
                        end
                    end
                end)
            end)
            
            if CurrentKeybind ~= "None" and CurrentKeybind ~= "" then
                local keyCode = Enum.KeyCode[CurrentKeybind]
                if keyCode then
                    UserInputService.InputBegan:Connect(function(input, gameProcessed)
                        if not gameProcessed and input.KeyCode == keyCode then
                            Callback()
                        end
                    end)
                end
            end
        end
        
        -- BUTTON
        function Tab:CreateButton(config)
            config = config or {}
            local Name = config.Name or "Button"
            local Callback = config.Callback or function() end
            
            local ButtonFrame = Create("Frame", {
                Size = UDim2.new(1, 0, 0, 38),
                BackgroundColor3 = Theme.Accent,
                BackgroundTransparency = 0.3,
                BorderSizePixel = 0,
                ZIndex = 4,
                Parent = TabContent
            })
            
            Create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = ButtonFrame})
            AddShadow(ButtonFrame, 0.85)
            
            local Button = Create("TextButton", {
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                Text = Name,
                TextColor3 = Theme.Text,
                TextSize = 13,
                Font = Enum.Font.GothamBold,
                AutoButtonColor = false,
                ZIndex = 5,
                Parent = ButtonFrame
            })
            
            Button.MouseEnter:Connect(function()
                Tween(ButtonFrame, {BackgroundTransparency = 0.1}, 0.15)
            end)
            
            Button.MouseLeave:Connect(function()
                Tween(ButtonFrame, {BackgroundTransparency = 0.3}, 0.15)
            end)
            
            Button.MouseButton1Click:Connect(function()
                Callback()
            end)
        end
        
        return Tab
    end
    
    -- NOTIFICATION SYSTEM (FIXED: ЕДИНЫЙ ЦВЕТ ТЕКСТА)
    function Window:Notify(config)
        if not Window.ShowNotifications then return end
        
        config = config or {}
        local Title = config.Title or "Notification"
        local Content = config.Content or ""
        local Duration = config.Duration or 3
        local Type = config.Type or "info"
        
        local NotifContainer = ScreenGui:FindFirstChild("NotifContainer")
        if not NotifContainer then
            NotifContainer = Create("Frame", {
                Name = "NotifContainer",
                Size = UDim2.new(0, 320, 0, 150),
                Position = UDim2.new(1, -335, 1, -165),
                BackgroundTransparency = 1,
                ZIndex = 100,
                Parent = ScreenGui
            })
            
            Create("UIListLayout", {
                Padding = UDim.new(0, 10),
                SortOrder = Enum.SortOrder.LayoutOrder,
                VerticalAlignment = Enum.VerticalAlignment.Bottom,
                Parent = NotifContainer
            })
        end
        
        local typeColors = {
            info = Theme.Accent,
            success = Theme.Success,
            warning = Theme.Warning,
            error = Theme.Error
        }
        
        local Notification = Create("Frame", {
            Size = UDim2.new(1, 0, 0, 0),
            BackgroundColor3 = Theme.Background,
            BackgroundTransparency = 0.1,
            BorderSizePixel = 0,
            ZIndex = 101,
            Parent = NotifContainer
        })
        
        Create("UICorner", {CornerRadius = UDim.new(0, 10), Parent = Notification})
        
        Create("UIGradient", {
            Color = ColorSequence.new{
                ColorSequenceKeypoint.new(0, Theme.Background),
                ColorSequenceKeypoint.new(1, Theme.BackgroundEnd)
            },
            Rotation = 135,
            Parent = Notification
        })
        
        -- SHADOW
        AddShadow(Notification, 0.6)
        
        local AccentLine = Create("Frame", {
            Size = UDim2.new(0, 4, 1, 0),
            BackgroundColor3 = typeColors[Type] or Theme.Accent,
            BackgroundTransparency = 0,
            BorderSizePixel = 0,
            ZIndex = 102,
            Parent = Notification
        })
        
        Create("UICorner", {CornerRadius = UDim.new(0, 10), Parent = AccentLine})
        
        local NotifTitle = Create("TextLabel", {
            Size = UDim2.new(1, -24, 0, 22),
            Position = UDim2.new(0, 14, 0, 10),
            BackgroundTransparency = 1,
            Text = Title,
            TextColor3 = Theme.Text,  -- ЕДИНЫЙ ЦВЕТ
            TextSize = 14,
            Font = Enum.Font.GothamBold,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 102,
            Parent = Notification
        })
        
        local NotifContent = Create("TextLabel", {
            Size = UDim2.new(1, -24, 0, 0),
            Position = UDim2.new(0, 14, 0, 32),
            BackgroundTransparency = 1,
            Text = Content,
            TextColor3 = Theme.TextDim,  -- ЕДИНЫЙ ЦВЕТ
            TextSize = 12,
            Font = Enum.Font.Gotham,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Top,
            TextWrapped = true,
            ZIndex = 102,
            Parent = Notification
        })
        
        local textSize = game:GetService("TextService"):GetTextSize(
            Content,
            12,
            Enum.Font.Gotham,
            Vector2.new(290, math.huge)
        )
        
        local finalHeight = 42 + textSize.Y + 12
        NotifContent.Size = UDim2.new(1, -24, 0, textSize.Y)
        
        Tween(Notification, {Size = UDim2.new(1, 0, 0, finalHeight)}, 0.3)
        
        task.spawn(function()
            task.wait(Duration)
            Tween(Notification, {Size = UDim2.new(1, 0, 0, 0), BackgroundTransparency = 1}, 0.2)
            task.wait(0.2)
            Notification:Destroy()
        end)
    end
    
    return Window
end

return RavynethUI
