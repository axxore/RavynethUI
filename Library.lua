-- ╔══════════════════════════════════════════════════════════════╗
-- ║         RAVYNETH UI V9 - PRODUCTION (FULLY FIXED)            ║
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

-- CLEAN THEME (NO OUTLINES, NO GLOWS)
local Theme = {
    Background = Color3.fromRGB(18, 18, 22),
    Sidebar = Color3.fromRGB(22, 22, 28),
    Content = Color3.fromRGB(20, 20, 26),
    Element = Color3.fromRGB(28, 28, 35),
    
    Accent = Color3.fromRGB(138, 43, 226),
    AccentDark = Color3.fromRGB(108, 33, 196),
    
    Text = Color3.fromRGB(255, 255, 255),
    TextDim = Color3.fromRGB(180, 180, 200),
    
    Success = Color3.fromRGB(76, 175, 80),
    Warning = Color3.fromRGB(255, 152, 0),
    Error = Color3.fromRGB(244, 67, 54),
    Info = Color3.fromRGB(33, 150, 243)
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

function RavynethUI:CreateWindow(config)
    config = config or {}
    local WindowName = config.Name or "Ravyneth Hub"
    local DefaultKey = config.ToggleKey or Enum.KeyCode.RightShift
    
    LoadConfig()
    
    local Window = {
        Tabs = {},
        CurrentTab = nil,
        Visible = true,
        Minimized = false,
        ToggleKey = SavedConfig.UIToggleKey and Enum.KeyCode[SavedConfig.UIToggleKey] or DefaultKey
    }
    
    local ScreenGui = Create("ScreenGui", {
        Name = "RavynethUI_" .. HttpService:GenerateGUID(false),
        Parent = CoreGui,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        ResetOnSpawn = false
    })
    
    -- Main Frame (680x480)
    local MainFrame = Create("Frame", {
        Name = "MainFrame",
        Size = UDim2.new(0, 680, 0, 480),
        Position = UDim2.new(0.5, -340, 0.5, -240),
        BackgroundColor3 = Theme.Background,
        BackgroundTransparency = 0.05,
        BorderSizePixel = 0,
        Active = true,
        Parent = ScreenGui
    })
    
    Create("UICorner", {CornerRadius = UDim.new(0, 12), Parent = MainFrame})
    
    -- Shadow
    local Shadow = Create("ImageLabel", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = UDim2.new(1, 40, 1, 40),
        BackgroundTransparency = 1,
        Image = "rbxassetid://5554236805",
        ImageColor3 = Color3.new(0, 0, 0),
        ImageTransparency = 0.6,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(23, 23, 277, 277),
        ZIndex = 0,
        Parent = MainFrame
    })
    
    -- DRAG SYSTEM (FIXED)
    local dragging = false
    local dragStart = nil
    local startPos = nil
    
    MainFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
        end
    end)
    
    MainFrame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement and dragging then
            local delta = input.Position - dragStart
            MainFrame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    -- Header (50px)
    local Header = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 50),
        BackgroundColor3 = Theme.Sidebar,
        BackgroundTransparency = 0.3,
        BorderSizePixel = 0,
        Parent = MainFrame
    })
    
    Create("UICorner", {CornerRadius = UDim.new(0, 12), Parent = Header})
    
    Create("Frame", {
        Size = UDim2.new(1, 0, 0, 12),
        Position = UDim2.new(0, 0, 1, -12),
        BackgroundColor3 = Theme.Sidebar,
        BackgroundTransparency = 0.3,
        BorderSizePixel = 0,
        Parent = Header
    })
    
    -- LOGO (IMAGE + TEXT)
    local LogoContainer = Create("Frame", {
        Size = UDim2.new(0, 180, 1, 0),
        Position = UDim2.new(0, 15, 0, 0),
        BackgroundTransparency = 1,
        Parent = Header
    })
    
    -- LOGO IMAGE (REAL IMAGE)
    local LogoImage = Create("ImageLabel", {
        Size = UDim2.new(0, 32, 0, 32),
        Position = UDim2.new(0, 0, 0.5, -16),
        BackgroundTransparency = 1,
        Image = "rbxassetid://18793128361", -- RAVYNETH LOGO
        ScaleType = Enum.ScaleType.Fit,
        Parent = LogoContainer
    })
    
    local LogoText = Create("TextLabel", {
        Size = UDim2.new(1, -40, 0, 24),
        Position = UDim2.new(0, 40, 0, 6),
        BackgroundTransparency = 1,
        Text = "RAVYNETH",
        TextColor3 = Theme.Text,
        TextSize = 18,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = LogoContainer
    })
    
    local LogoSubtext = Create("TextLabel", {
        Size = UDim2.new(1, -40, 0, 12),
        Position = UDim2.new(0, 40, 0, 28),
        BackgroundTransparency = 1,
        Text = "ADVANCED SCRIPT HUB",
        TextColor3 = Theme.TextDim,
        TextSize = 8,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = LogoContainer
    })
    
    -- Search Bar
    local SearchContainer = Create("Frame", {
        Size = UDim2.new(0, 220, 0, 32),
        Position = UDim2.new(0, 210, 0, 9),
        BackgroundColor3 = Theme.Element,
        BorderSizePixel = 0,
        Parent = Header
    })
    
    Create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = SearchContainer})
    
    local SearchIcon = Create("ImageLabel", {
        Size = UDim2.new(0, 16, 0, 16),
        Position = UDim2.new(0, 10, 0.5, -8),
        BackgroundTransparency = 1,
        Image = "rbxassetid://3926305904",
        ImageRectOffset = Vector2.new(964, 324),
        ImageRectSize = Vector2.new(36, 36),
        ImageColor3 = Theme.Accent,
        Parent = SearchContainer
    })
    
    local SearchBox = Create("TextBox", {
        Size = UDim2.new(1, -40, 1, 0),
        Position = UDim2.new(0, 32, 0, 0),
        BackgroundTransparency = 1,
        Text = "",
        PlaceholderText = "Search...",
        PlaceholderColor3 = Theme.TextDim,
        TextColor3 = Theme.Text,
        TextSize = 12,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        ClearTextOnFocus = false,
        Parent = SearchContainer
    })
    
    -- Buttons
    local ButtonContainer = Create("Frame", {
        Size = UDim2.new(0, 70, 0, 32),
        Position = UDim2.new(1, -80, 0, 9),
        BackgroundTransparency = 1,
        Parent = Header
    })
    
    Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        HorizontalAlignment = Enum.HorizontalAlignment.Right,
        Padding = UDim.new(0, 6),
        Parent = ButtonContainer
    })
    
    local MinimizeBtn = Create("TextButton", {
        Size = UDim2.new(0, 32, 0, 32),
        BackgroundColor3 = Theme.Element,
        Text = "━",
        TextColor3 = Theme.Text,
        TextSize = 14,
        Font = Enum.Font.GothamBold,
        AutoButtonColor = false,
        Parent = ButtonContainer
    })
    
    Create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = MinimizeBtn})
    
    local CloseBtn = Create("TextButton", {
        Size = UDim2.new(0, 32, 0, 32),
        BackgroundColor3 = Theme.Element,
        Text = "×",
        TextColor3 = Theme.Text,
        TextSize = 22,
        Font = Enum.Font.GothamBold,
        AutoButtonColor = false,
        Parent = ButtonContainer
    })
    
    Create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = CloseBtn})
    
    CloseBtn.MouseButton1Click:Connect(function()
        Window:Destroy()
    end)
    
    -- MINIMIZE/EXPAND LOGIC (FIXED)
    MinimizeBtn.MouseButton1Click:Connect(function()
        Window.Minimized = not Window.Minimized
        
        if Window.Minimized then
            -- Minimize to logo only
            Tween(MainFrame, {Size = UDim2.new(0, 200, 0, 50)}, 0.3)
            task.wait(0.1)
            
            -- Hide everything except header
            for _, child in pairs(MainFrame:GetChildren()) do
                if child ~= Header and child ~= Shadow and not child:IsA("UICorner") then
                    child.Visible = false
                end
            end
            
            SearchContainer.Visible = false
            ButtonContainer.Visible = false
            
            -- Make logo clickable to expand
            local ExpandClickFrame = Create("TextButton", {
                Name = "ExpandClick",
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                Text = "",
                ZIndex = 10,
                Parent = LogoContainer
            })
            
            ExpandClickFrame.MouseButton1Click:Connect(function()
                Window.Minimized = false
                ExpandClickFrame:Destroy()
                
                -- Show everything
                SearchContainer.Visible = true
                ButtonContainer.Visible = true
                
                for _, child in pairs(MainFrame:GetChildren()) do
                    child.Visible = true
                end
                
                Tween(MainFrame, {Size = UDim2.new(0, 680, 0, 480)}, 0.3)
            end)
        end
    end)
    
    -- Sidebar
    local Sidebar = Create("Frame", {
        Size = UDim2.new(0, 130, 1, -60),
        Position = UDim2.new(0, 10, 0, 55),
        BackgroundColor3 = Theme.Sidebar,
        BorderSizePixel = 0,
        Parent = MainFrame
    })
    
    Create("UICorner", {CornerRadius = UDim.new(0, 10), Parent = Sidebar})
    
    local SidebarList = Create("ScrollingFrame", {
        Size = UDim2.new(1, -10, 1, -10),
        Position = UDim2.new(0, 5, 0, 5),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = Theme.Accent,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Parent = Sidebar
    })
    
    Create("UIListLayout", {
        Padding = UDim.new(0, 5),
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
        Size = UDim2.new(1, -155, 1, -60),
        Position = UDim2.new(0, 145, 0, 55),
        BackgroundColor3 = Theme.Content,
        BorderSizePixel = 0,
        Parent = MainFrame
    })
    
    Create("UICorner", {CornerRadius = UDim.new(0, 10), Parent = ContentContainer})
    
    -- Window Functions
    function Window:Toggle()
        Window.Visible = not Window.Visible
        MainFrame.Visible = Window.Visible
    end
    
    function Window:Destroy()
        Tween(MainFrame, {BackgroundTransparency = 1}, 0.3)
        Tween(Shadow, {ImageTransparency = 1}, 0.3)
        task.wait(0.3)
        ScreenGui:Destroy()
    end
    
    function Window:SetToggleKey(newKey)
        Window.ToggleKey = newKey
        SavedConfig.UIToggleKey = tostring(newKey)
        SaveConfig()
    end
    
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
            Size = UDim2.new(1, 0, 0, 36),
            BackgroundColor3 = Theme.Element,
            Text = "",
            AutoButtonColor = false,
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
            Parent = ContentContainer
        })
        
        Create("UIListLayout", {
            Padding = UDim.new(0, 8),
            SortOrder = Enum.SortOrder.LayoutOrder,
            Parent = TabContent
        })
        
        Tab.Container = TabContent
        
        TabButton.MouseButton1Click:Connect(function()
            for _, tab in pairs(Window.Tabs) do
                tab.Container.Visible = false
                tab.Button.BackgroundColor3 = Theme.Element
                tab.Label.TextColor3 = Theme.TextDim
            end
            
            TabContent.Visible = true
            TabButton.BackgroundColor3 = Theme.Accent
            TabLabel.TextColor3 = Theme.Text
            Window.CurrentTab = Tab
        end)
        
        Tab.Button = TabButton
        Tab.Label = TabLabel
        
        table.insert(Window.Tabs, Tab)
        
        if #Window.Tabs == 1 then
            TabButton.BackgroundColor3 = Theme.Accent
            TabLabel.TextColor3 = Theme.Text
            TabContent.Visible = true
            Window.CurrentTab = Tab
        end
        
        -- SECTION
        function Tab:CreateSection(sectionName)
            local SectionFrame = Create("Frame", {
                Size = UDim2.new(1, 0, 0, 28),
                BackgroundTransparency = 1,
                Parent = TabContent
            })
            
            local SectionLabel = Create("TextLabel", {
                Size = UDim2.new(1, -16, 1, 0),
                Position = UDim2.new(0, 8, 0, 0),
                BackgroundTransparency = 1,
                Text = sectionName,
                TextColor3 = Theme.Accent,
                TextSize = 14,
                Font = Enum.Font.GothamBold,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = SectionFrame
            })
            
            local Divider = Create("Frame", {
                Size = UDim2.new(1, -16, 0, 2),
                Position = UDim2.new(0, 8, 1, -3),
                BackgroundColor3 = Theme.Accent,
                BackgroundTransparency = 0.7,
                BorderSizePixel = 0,
                Parent = SectionFrame
            })
        end
        
        -- LABEL
        function Tab:CreateLabel(text)
            local LabelFrame = Create("Frame", {
                Size = UDim2.new(1, 0, 0, 26),
                BackgroundTransparency = 1,
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
                Size = UDim2.new(1, 0, 0, 36),
                BackgroundColor3 = Theme.Element,
                BorderSizePixel = 0,
                Parent = TabContent
            })
            
            Create("UICorner", {CornerRadius = UDim.new(0, 7), Parent = ToggleFrame})
            
            local ToggleLabel = Create("TextLabel", {
                Size = UDim2.new(1, -50, 1, 0),
                Position = UDim2.new(0, 12, 0, 0),
                BackgroundTransparency = 1,
                Text = Name,
                TextColor3 = Theme.Text,
                TextSize = 12,
                Font = Enum.Font.Gotham,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = ToggleFrame
            })
            
            local ToggleButton = Create("TextButton", {
                Size = UDim2.new(0, 38, 0, 20),
                Position = UDim2.new(1, -44, 0.5, -10),
                BackgroundColor3 = CurrentValue and Theme.Accent or Theme.Content,
                Text = "",
                AutoButtonColor = false,
                Parent = ToggleFrame
            })
            
            Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = ToggleButton})
            
            local ToggleCircle = Create("Frame", {
                Size = UDim2.new(0, 16, 0, 16),
                Position = CurrentValue and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8),
                BackgroundColor3 = Theme.Text,
                BorderSizePixel = 0,
                Parent = ToggleButton
            })
            
            Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = ToggleCircle})
            
            local ToggleObject = {Value = CurrentValue}
            
            local function Update()
                if not ToggleButton or not ToggleButton.Parent then return end
                ToggleButton.BackgroundColor3 = CurrentValue and Theme.Accent or Theme.Content
                Tween(ToggleCircle, {Position = CurrentValue and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)}, 0.2)
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
                Size = UDim2.new(1, 0, 0, 50),
                BackgroundColor3 = Theme.Element,
                BorderSizePixel = 0,
                Parent = TabContent
            })
            
            Create("UICorner", {CornerRadius = UDim.new(0, 7), Parent = SliderFrame})
            
            local SliderLabel = Create("TextLabel", {
                Size = UDim2.new(1, -16, 0, 18),
                Position = UDim2.new(0, 12, 0, 8),
                BackgroundTransparency = 1,
                Text = Name,
                TextColor3 = Theme.Text,
                TextSize = 12,
                Font = Enum.Font.Gotham,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = SliderFrame
            })
            
            local SliderTrack = Create("Frame", {
                Size = UDim2.new(1, -85, 0, 5),
                Position = UDim2.new(0, 12, 1, -16),
                BackgroundColor3 = Theme.Content,
                BorderSizePixel = 0,
                Parent = SliderFrame
            })
            
            Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = SliderTrack})
            
            local percentage = math.clamp((CurrentValue - Range[1]) / (Range[2] - Range[1]), 0, 1)
            
            local SliderFill = Create("Frame", {
                Size = UDim2.new(percentage, 0, 1, 0),
                BackgroundColor3 = Theme.Accent,
                BorderSizePixel = 0,
                Parent = SliderTrack
            })
            
            Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = SliderFill})
            
            local SliderDot = Create("Frame", {
                Size = UDim2.new(0, 12, 0, 12),
                Position = UDim2.new(percentage, -6, 0.5, -6),
                BackgroundColor3 = Theme.Text,
                BorderSizePixel = 0,
                Parent = SliderTrack
            })
            
            Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = SliderDot})
            
            local ValueLabel = Create("TextLabel", {
                Size = UDim2.new(0, 60, 0, 18),
                Position = UDim2.new(1, -70, 1, -18),
                BackgroundTransparency = 1,
                Text = tostring(CurrentValue) .. Suffix,
                TextColor3 = Theme.Accent,
                TextSize = 12,
                Font = Enum.Font.GothamBold,
                TextXAlignment = Enum.TextXAlignment.Right,
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
                Tween(SliderDot, {Position = UDim2.new(percent, -6, 0.5, -6)}, 0.1)
                
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
        end
        
        -- TOGGLE + SLIDER COMBO
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
                Size = UDim2.new(1, 0, 0, 50),
                BackgroundColor3 = Theme.Element,
                BorderSizePixel = 0,
                Parent = TabContent
            })
            
            Create("UICorner", {CornerRadius = UDim.new(0, 7), Parent = Frame})
            
            local Label = Create("TextLabel", {
                Size = UDim2.new(1, -50, 0, 18),
                Position = UDim2.new(0, 12, 0, 8),
                BackgroundTransparency = 1,
                Text = Name,
                TextColor3 = Theme.Text,
                TextSize = 12,
                Font = Enum.Font.Gotham,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = Frame
            })
            
            local ToggleButton = Create("TextButton", {
                Size = UDim2.new(0, 38, 0, 20),
                Position = UDim2.new(1, -44, 0, 6),
                BackgroundColor3 = ToggleValue and Theme.Accent or Theme.Content,
                Text = "",
                AutoButtonColor = false,
                Parent = Frame
            })
            
            Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = ToggleButton})
            
            local ToggleCircle = Create("Frame", {
                Size = UDim2.new(0, 16, 0, 16),
                Position = ToggleValue and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8),
                BackgroundColor3 = Theme.Text,
                BorderSizePixel = 0,
                Parent = ToggleButton
            })
            
            Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = ToggleCircle})
            
            local SliderTrack = Create("Frame", {
                Size = UDim2.new(1, -85, 0, 5),
                Position = UDim2.new(0, 12, 1, -16),
                BackgroundColor3 = Theme.Content,
                BorderSizePixel = 0,
                Parent = Frame
            })
            
            Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = SliderTrack})
            
            local percentage = math.clamp((SliderValue - Range[1]) / (Range[2] - Range[1]), 0, 1)
            
            local SliderFill = Create("Frame", {
                Size = UDim2.new(percentage, 0, 1, 0),
                BackgroundColor3 = Theme.Accent,
                BorderSizePixel = 0,
                Parent = SliderTrack
            })
            
            Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = SliderFill})
            
            local SliderDot = Create("Frame", {
                Size = UDim2.new(0, 12, 0, 12),
                Position = UDim2.new(percentage, -6, 0.5, -6),
                BackgroundColor3 = Theme.Text,
                BorderSizePixel = 0,
                Parent = SliderTrack
            })
            
            Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = SliderDot})
            
            local ValueLabel = Create("TextLabel", {
                Size = UDim2.new(0, 60, 0, 18),
                Position = UDim2.new(1, -70, 1, -18),
                BackgroundTransparency = 1,
                Text = tostring(SliderValue) .. Suffix,
                TextColor3 = Theme.Accent,
                TextSize = 12,
                Font = Enum.Font.GothamBold,
                TextXAlignment = Enum.TextXAlignment.Right,
                Parent = Frame
            })
            
            ToggleButton.MouseButton1Click:Connect(function()
                ToggleValue = not ToggleValue
                ToggleButton.BackgroundColor3 = ToggleValue and Theme.Accent or Theme.Content
                Tween(ToggleCircle, {Position = ToggleValue and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)}, 0.2)
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
                ValueLabel.Text = tostring(value) .. Suffix
                Tween(SliderFill, {Size = UDim2.new(percent, 0, 1, 0)}, 0.1)
                Tween(SliderDot, {Position = UDim2.new(percent, -6, 0.5, -6)}, 0.1)
                
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
        end
        
        -- DROPDOWN
        function Tab:CreateDropdown(config)
            config = config or {}
            local Name = config.Name or "Dropdown"
            local Flag = config.Flag or Name
            local Options = config.Options or {}
            local MultipleOptions = config.MultipleOptions or false
            local CurrentOption = SavedConfig[Flag] or config.CurrentOption or (MultipleOptions and {} or {})
            local Callback = config.Callback or function() end
            
            if type(CurrentOption) ~= "table" then CurrentOption = {CurrentOption} end
            
            local DropdownFrame = Create("Frame", {
                Size = UDim2.new(1, 0, 0, 36),
                BackgroundColor3 = Theme.Element,
                BorderSizePixel = 0,
                Parent = TabContent
            })
            
            Create("UICorner", {CornerRadius = UDim.new(0, 7), Parent = DropdownFrame})
            
            local DropdownButton = Create("TextButton", {
                Size = UDim2.new(1, 0, 0, 36),
                BackgroundTransparency = 1,
                Text = "",
                AutoButtonColor = false,
                Parent = DropdownFrame
            })
            
            local DropdownLabel = Create("TextLabel", {
                Size = UDim2.new(1, -40, 1, 0),
                Position = UDim2.new(0, 12, 0, 0),
                BackgroundTransparency = 1,
                Text = Name,
                TextColor3 = Theme.Text,
                TextSize = 12,
                Font = Enum.Font.Gotham,
                TextXAlignment = Enum.TextXAlignment.Left,
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
                Parent = DropdownButton
            })
            
            local DropdownList = Create("ScrollingFrame", {
                Size = UDim2.new(1, 0, 0, 0),
                Position = UDim2.new(0, 0, 0, 40),
                BackgroundColor3 = Theme.Content,
                BorderSizePixel = 0,
                Visible = false,
                ScrollBarThickness = 3,
                ScrollBarImageColor3 = Theme.Accent,
                CanvasSize = UDim2.new(0, 0, 0, 0),
                AutomaticCanvasSize = Enum.AutomaticSize.Y,
                ZIndex = 10,
                Parent = DropdownFrame
            })
            
            Create("UICorner", {CornerRadius = UDim.new(0, 7), Parent = DropdownList})
            
            Create("UIListLayout", {
                Padding = UDim.new(0, 2),
                Parent = DropdownList
            })
            
            Create("UIPadding", {
                PaddingTop = UDim.new(0, 5),
                PaddingBottom = UDim.new(0, 5),
                PaddingLeft = UDim.new(0, 5),
                PaddingRight = UDim.new(0, 5),
                Parent = DropdownList
            })
            
            local Expanded = false
            
            DropdownButton.MouseButton1Click:Connect(function()
                Expanded = not Expanded
                DropdownList.Visible = Expanded
                
                local targetHeight = math.min(#Options * 28 + 10, 150)
                local frameSize = Expanded and UDim2.new(1, 0, 0, 40 + targetHeight) or UDim2.new(1, 0, 0, 36)
                
                Tween(DropdownList, {Size = Expanded and UDim2.new(1, 0, 0, targetHeight) or UDim2.new(1, 0, 0, 0)}, 0.2)
                Tween(DropdownIcon, {Rotation = Expanded and 180 or 0}, 0.2)
                Tween(DropdownFrame, {Size = frameSize}, 0.2)
            end)
            
            for _, option in ipairs(Options) do
                local OptionButton = Create("TextButton", {
                    Size = UDim2.new(1, 0, 0, 26),
                    BackgroundColor3 = Theme.Element,
                    Text = "",
                    AutoButtonColor = false,
                    ZIndex = 11,
                    Parent = DropdownList
                })
                
                Create("UICorner", {CornerRadius = UDim.new(0, 5), Parent = OptionButton})
                
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
                
                OptionButton.MouseButton1Click:Connect(function()
                    if MultipleOptions then
                        local found = table.find(CurrentOption, option)
                        if found then
                            table.remove(CurrentOption, found)
                            OptionButton.BackgroundColor3 = Theme.Element
                            OptionLabel.TextColor3 = Theme.TextDim
                        else
                            table.insert(CurrentOption, option)
                            OptionButton.BackgroundColor3 = Theme.Accent
                            OptionLabel.TextColor3 = Theme.Text
                        end
                    else
                        CurrentOption = {option}
                        for _, btn in ipairs(DropdownList:GetChildren()) do
                            if btn:IsA("TextButton") then
                                btn.BackgroundColor3 = Theme.Element
                                local lbl = btn:FindFirstChildOfClass("TextLabel")
                                if lbl then lbl.TextColor3 = Theme.TextDim end
                            end
                        end
                        OptionButton.BackgroundColor3 = Theme.Accent
                        OptionLabel.TextColor3 = Theme.Text
                    end
                    
                    SavedConfig[Flag] = CurrentOption
                    SaveConfig()
                    Callback(MultipleOptions and CurrentOption or CurrentOption[1])
                end)
                
                if table.find(CurrentOption, option) then
                    OptionButton.BackgroundColor3 = Theme.Accent
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
                Size = UDim2.new(1, 0, 0, 36),
                BackgroundColor3 = Theme.Element,
                BorderSizePixel = 0,
                Parent = TabContent
            })
            
            Create("UICorner", {CornerRadius = UDim.new(0, 7), Parent = KeybindFrame})
            
            local KeybindLabel = Create("TextLabel", {
                Size = UDim2.new(1, -85, 1, 0),
                Position = UDim2.new(0, 12, 0, 0),
                BackgroundTransparency = 1,
                Text = Name,
                TextColor3 = Theme.Text,
                TextSize = 12,
                Font = Enum.Font.Gotham,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = KeybindFrame
            })
            
            local KeybindButton = Create("TextButton", {
                Size = UDim2.new(0, 70, 0, 24),
                Position = UDim2.new(1, -78, 0.5, -12),
                BackgroundColor3 = Theme.Content,
                Text = CurrentKeybind,
                TextColor3 = Theme.Text,
                TextSize = 11,
                Font = Enum.Font.GothamBold,
                AutoButtonColor = false,
                Parent = KeybindFrame
            })
            
            Create("UICorner", {CornerRadius = UDim.new(0, 5), Parent = KeybindButton})
            
            local Binding = false
            local Connection = nil
            
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
                Size = UDim2.new(1, 0, 0, 36),
                BackgroundColor3 = Theme.Accent,
                BorderSizePixel = 0,
                Parent = TabContent
            })
            
            Create("UICorner", {CornerRadius = UDim.new(0, 7), Parent = ButtonFrame})
            
            local Button = Create("TextButton", {
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                Text = Name,
                TextColor3 = Theme.Text,
                TextSize = 13,
                Font = Enum.Font.GothamBold,
                AutoButtonColor = false,
                Parent = ButtonFrame
            })
            
            Button.MouseButton1Click:Connect(function()
                Callback()
            end)
        end
        
        return Tab
    end
    
    -- NOTIFICATION
    function Window:Notify(config)
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
            info = Theme.Info,
            success = Theme.Success,
            warning = Theme.Warning,
            error = Theme.Error
        }
        
        local Notification = Create("Frame", {
            Size = UDim2.new(1, 0, 0, 0),
            BackgroundColor3 = Theme.Element,
            BorderSizePixel = 0,
            ZIndex = 101,
            Parent = NotifContainer
        })
        
        Create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = Notification})
        
        local AccentLine = Create("Frame", {
            Size = UDim2.new(0, 3, 1, 0),
            BackgroundColor3 = typeColors[Type] or Theme.Accent,
            BorderSizePixel = 0,
            ZIndex = 102,
            Parent = Notification
        })
        
        Create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = AccentLine})
        
        local NotifTitle = Create("TextLabel", {
            Size = UDim2.new(1, -24, 0, 20),
            Position = UDim2.new(0, 12, 0, 10),
            BackgroundTransparency = 1,
            Text = Title,
            TextColor3 = typeColors[Type] or Theme.Accent,
            TextSize = 13,
            Font = Enum.Font.GothamBold,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 102,
            Parent = Notification
        })
        
        local NotifContent = Create("TextLabel", {
            Size = UDim2.new(1, -24, 0, 0),
            Position = UDim2.new(0, 12, 0, 30),
            BackgroundTransparency = 1,
            Text = Content,
            TextColor3 = Theme.TextDim,
            TextSize = 11,
            Font = Enum.Font.Gotham,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Top,
            TextWrapped = true,
            ZIndex = 102,
            Parent = Notification
        })
        
        local textSize = game:GetService("TextService"):GetTextSize(
            Content,
            11,
            Enum.Font.Gotham,
            Vector2.new(290, math.huge)
        )
        
        local finalHeight = 40 + textSize.Y + 10
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
