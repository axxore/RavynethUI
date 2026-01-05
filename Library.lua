-- ╔══════════════════════════════════════════════════════════════╗
-- ║                  RAVYNETH UI LIBRARY V4                      ║
-- ║            Professional Premium Design - FIXED               ║
-- ╚══════════════════════════════════════════════════════════════╝

local RavynethUI = {}
RavynethUI.__index = RavynethUI

-- Services
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

-- Config System
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

-- Premium Theme (Like SolixHub)
local Theme = {
    -- Main Colors
    Background = Color3.fromRGB(16, 16, 20),
    Sidebar = Color3.fromRGB(20, 20, 25),
    Content = Color3.fromRGB(24, 24, 30),
    Element = Color3.fromRGB(30, 30, 36),
    ElementHover = Color3.fromRGB(36, 36, 42),
    
    -- Accent Colors
    Accent = Color3.fromRGB(138, 43, 226),
    AccentHover = Color3.fromRGB(155, 60, 240),
    AccentDark = Color3.fromRGB(120, 30, 200),
    
    -- Text Colors
    Text = Color3.fromRGB(250, 250, 255),
    TextDim = Color3.fromRGB(155, 155, 165),
    TextDarker = Color3.fromRGB(115, 115, 125),
    
    -- Status Colors
    Success = Color3.fromRGB(46, 204, 113),
    Warning = Color3.fromRGB(241, 196, 15),
    Error = Color3.fromRGB(231, 76, 60),
    Info = Color3.fromRGB(52, 152, 219),
    
    -- Border
    Border = Color3.fromRGB(40, 40, 48),
    BorderDark = Color3.fromRGB(30, 30, 36)
}

-- Utility Functions
local function Tween(object, properties, duration, easingStyle, easingDirection)
    if not object or not object.Parent then return end
    duration = duration or 0.2
    easingStyle = easingStyle or Enum.EasingStyle.Quart
    easingDirection = easingDirection or Enum.EasingDirection.Out
    
    local tween = TweenService:Create(
        object,
        TweenInfo.new(duration, easingStyle, easingDirection),
        properties
    )
    tween:Play()
    return tween
end

local function Create(class, properties)
    local instance = Instance.new(class)
    for property, value in pairs(properties) do
        if property ~= "Parent" then
            pcall(function()
                instance[property] = value
            end)
        end
    end
    if properties.Parent then
        instance.Parent = properties.Parent
    end
    return instance
end

-- Main Window Creation
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
        ToggleKey = SavedConfig.UIToggleKey and Enum.KeyCode[SavedConfig.UIToggleKey] or DefaultKey,
        SearchQuery = ""
    }
    
    -- ScreenGui
    local ScreenGui = Create("ScreenGui", {
        Name = "RavynethUI_" .. HttpService:GenerateGUID(false),
        Parent = CoreGui,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        ResetOnSpawn = false
    })
    
    -- Main Container
    local MainFrame = Create("Frame", {
        Name = "MainFrame",
        Size = UDim2.new(0, 820, 0, 560),
        Position = UDim2.new(0.5, -410, 0.5, -280),
        BackgroundColor3 = Theme.Background,
        BorderSizePixel = 0,
        Parent = ScreenGui
    })
    
    Create("UICorner", {CornerRadius = UDim.new(0, 10), Parent = MainFrame})
    
    -- Premium Shadow Effect
    local Shadow = Create("ImageLabel", {
        Name = "Shadow",
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = UDim2.new(1, 60, 1, 60),
        BackgroundTransparency = 1,
        Image = "rbxassetid://5554236805",
        ImageColor3 = Color3.new(0, 0, 0),
        ImageTransparency = 0.3,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(23, 23, 277, 277),
        ZIndex = 0,
        Parent = MainFrame
    })
    
    -- Drag System
    local dragging, dragInput, dragStart, startPos
    
    MainFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    MainFrame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            MainFrame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
    
    -- Header
    local Header = Create("Frame", {
        Name = "Header",
        Size = UDim2.new(1, 0, 0, 55),
        BackgroundColor3 = Theme.Sidebar,
        BorderSizePixel = 0,
        Parent = MainFrame
    })
    
    Create("UICorner", {CornerRadius = UDim.new(0, 10), Parent = Header})
    
    -- Fix rounded corners at bottom
    Create("Frame", {
        Size = UDim2.new(1, 0, 0, 10),
        Position = UDim2.new(0, 0, 1, -10),
        BackgroundColor3 = Theme.Sidebar,
        BorderSizePixel = 0,
        Parent = Header
    })
    
    -- Logo Container
    local LogoContainer = Create("Frame", {
        Name = "LogoContainer",
        Size = UDim2.new(0, 150, 0, 40),
        Position = UDim2.new(0, 15, 0, 8),
        BackgroundTransparency = 1,
        Parent = Header
    })
    
    -- Try loading logo image
    local Logo = Create("ImageLabel", {
        Name = "Logo",
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Image = "rbxassetid://0",
        ScaleType = Enum.ScaleType.Fit,
        Visible = false,
        Parent = LogoContainer
    })
    
    -- Fallback text title
    local TitleText = Create("TextLabel", {
        Name = "TitleText",
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = WindowName,
        TextColor3 = Theme.Text,
        TextSize = 18,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = LogoContainer
    })
    
    -- Try to load logo from URL
    task.spawn(function()
        pcall(function()
            local success = pcall(function()
                Logo.Image = "https://raw.githubusercontent.com/axxore/RavynethUI/main/logo.png"
            end)
            if success then
                task.wait(0.5)
                if Logo.Image ~= "" and Logo.Image ~= "rbxassetid://0" then
                    Logo.Visible = true
                    TitleText.Visible = false
                end
            end
        end)
    end)
    
    -- Search Bar
    local SearchContainer = Create("Frame", {
        Name = "SearchContainer",
        Size = UDim2.new(0, 240, 0, 34),
        Position = UDim2.new(0, 175, 0, 10),
        BackgroundColor3 = Theme.Element,
        BorderSizePixel = 0,
        Parent = Header
    })
    
    Create("UICorner", {CornerRadius = UDim.new(0, 7), Parent = SearchContainer})
    
    local SearchIcon = Create("ImageLabel", {
        Size = UDim2.new(0, 18, 0, 18),
        Position = UDim2.new(0, 10, 0.5, -9),
        BackgroundTransparency = 1,
        Image = "rbxassetid://3926305904",
        ImageRectOffset = Vector2.new(964, 324),
        ImageRectSize = Vector2.new(36, 36),
        ImageColor3 = Theme.TextDim,
        Parent = SearchContainer
    })
    
    local SearchBox = Create("TextBox", {
        Name = "SearchBox",
        Size = UDim2.new(1, -40, 1, 0),
        Position = UDim2.new(0, 35, 0, 0),
        BackgroundTransparency = 1,
        Text = "",
        PlaceholderText = "Search...",
        PlaceholderColor3 = Theme.TextDarker,
        TextColor3 = Theme.Text,
        TextSize = 13,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        ClearTextOnFocus = false,
        Parent = SearchContainer
    })
    
    -- Search functionality
    SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
        local query = SearchBox.Text:lower()
        Window.SearchQuery = query
        
        if Window.CurrentTab and Window.CurrentTab.Container then
            for _, element in pairs(Window.CurrentTab.Container:GetChildren()) do
                if element:IsA("Frame") or element:IsA("TextLabel") then
                    local textLabel = element:FindFirstChildOfClass("TextLabel")
                    if textLabel then
                        local text = textLabel.Text:lower()
                        element.Visible = query == "" or text:find(query, 1, true) ~= nil
                    end
                end
            end
        end
    end)
    
    -- Control Buttons
    local ButtonContainer = Create("Frame", {
        Name = "ButtonContainer",
        Size = UDim2.new(0, 75, 0, 34),
        Position = UDim2.new(1, -90, 0, 10),
        BackgroundTransparency = 1,
        Parent = Header
    })
    
    Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        HorizontalAlignment = Enum.HorizontalAlignment.Right,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 6),
        Parent = ButtonContainer
    })
    
    -- Minimize Button
    local MinimizeBtn = Create("TextButton", {
        Name = "MinimizeBtn",
        Size = UDim2.new(0, 34, 0, 34),
        BackgroundColor3 = Theme.Element,
        Text = "—",
        TextColor3 = Theme.Text,
        TextSize = 18,
        Font = Enum.Font.GothamBold,
        AutoButtonColor = false,
        Parent = ButtonContainer
    })
    
    Create("UICorner", {CornerRadius = UDim.new(0, 7), Parent = MinimizeBtn})
    
    MinimizeBtn.MouseButton1Click:Connect(function()
        Window:Minimize()
    end)
    
    MinimizeBtn.MouseEnter:Connect(function()
        Tween(MinimizeBtn, {BackgroundColor3 = Theme.ElementHover}, 0.15)
    end)
    
    MinimizeBtn.MouseLeave:Connect(function()
        Tween(MinimizeBtn, {BackgroundColor3 = Theme.Element}, 0.15)
    end)
    
    -- Close Button
    local CloseBtn = Create("TextButton", {
        Name = "CloseBtn",
        Size = UDim2.new(0, 34, 0, 34),
        BackgroundColor3 = Theme.Element,
        Text = "✕",
        TextColor3 = Theme.Text,
        TextSize = 16,
        Font = Enum.Font.GothamBold,
        AutoButtonColor = false,
        Parent = ButtonContainer
    })
    
    Create("UICorner", {CornerRadius = UDim.new(0, 7), Parent = CloseBtn})
    
    CloseBtn.MouseButton1Click:Connect(function()
        Window:Destroy()
    end)
    
    CloseBtn.MouseEnter:Connect(function()
        Tween(CloseBtn, {BackgroundColor3 = Theme.Error}, 0.15)
    end)
    
    CloseBtn.MouseLeave:Connect(function()
        Tween(CloseBtn, {BackgroundColor3 = Theme.Element}, 0.15)
    end)
    
    -- Sidebar
    local Sidebar = Create("Frame", {
        Name = "Sidebar",
        Size = UDim2.new(0, 155, 1, -67),
        Position = UDim2.new(0, 10, 0, 60),
        BackgroundColor3 = Theme.Sidebar,
        BorderSizePixel = 0,
        Parent = MainFrame
    })
    
    Create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = Sidebar})
    
    local SidebarList = Create("ScrollingFrame", {
        Name = "SidebarList",
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
        PaddingBottom = UDim.new(0, 5),
        PaddingLeft = UDim.new(0, 5),
        PaddingRight = UDim.new(0, 5),
        Parent = SidebarList
    })
    
    -- Content Container
    local ContentContainer = Create("Frame", {
        Name = "ContentContainer",
        Size = UDim2.new(1, -185, 1, -67),
        Position = UDim2.new(0, 175, 0, 60),
        BackgroundColor3 = Theme.Content,
        BorderSizePixel = 0,
        Parent = MainFrame
    })
    
    Create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = ContentContainer})
    
    -- Window Functions
    function Window:Toggle()
        Window.Visible = not Window.Visible
        if Window.Visible then
            MainFrame.Visible = true
            Tween(MainFrame, {Size = UDim2.new(0, 820, 0, 560)}, 0.3, Enum.EasingStyle.Back)
        else
            Tween(MainFrame, {Size = UDim2.new(0, 0, 0, 0)}, 0.25)
            task.wait(0.25)
            MainFrame.Visible = false
        end
    end
    
    function Window:Minimize()
        Window.Minimized = not Window.Minimized
        if Window.Minimized then
            Tween(MainFrame, {Size = UDim2.new(0, 820, 0, 55)}, 0.25)
            Sidebar.Visible = false
            ContentContainer.Visible = false
        else
            Tween(MainFrame, {Size = UDim2.new(0, 820, 0, 560)}, 0.25)
            Sidebar.Visible = true
            ContentContainer.Visible = true
        end
    end
    
    function Window:Destroy()
        Tween(MainFrame, {Size = UDim2.new(0, 0, 0, 0)}, 0.2)
        task.wait(0.2)
        ScreenGui:Destroy()
    end
    
    function Window:SetToggleKey(newKey)
        Window.ToggleKey = newKey
        SavedConfig.UIToggleKey = tostring(newKey)
        SaveConfig()
    end
    
    -- Toggle Key Listener
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if not gameProcessed and input.KeyCode == Window.ToggleKey then
            Window:Toggle()
        end
    end)
    
    -- Create Tab Function
    function Window:CreateTab(tabName)
        local Tab = {
            Name = tabName,
            Elements = {},
            Sections = {},
            Container = nil
        }
        
        -- Tab Button
        local TabButton = Create("TextButton", {
            Name = tabName,
            Size = UDim2.new(1, 0, 0, 38),
            BackgroundColor3 = Theme.Element,
            Text = "",
            AutoButtonColor = false,
            Parent = SidebarList
        })
        
        Create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = TabButton})
        
        local TabLabel = Create("TextLabel", {
            Size = UDim2.new(1, -20, 1, 0),
            Position = UDim2.new(0, 10, 0, 0),
            BackgroundTransparency = 1,
            Text = tabName,
            TextColor3 = Theme.TextDim,
            TextSize = 13,
            Font = Enum.Font.Gotham,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = TabButton
        })
        
        -- Tab Content
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
        
        -- Tab Click Handler
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
            
            -- Reset search when switching tabs
            SearchBox.Text = ""
        end)
        
        TabButton.MouseEnter:Connect(function()
            if Window.CurrentTab ~= Tab then
                Tween(TabButton, {BackgroundColor3 = Theme.ElementHover}, 0.15)
            end
        end)
        
        TabButton.MouseLeave:Connect(function()
            if Window.CurrentTab ~= Tab then
                Tween(TabButton, {BackgroundColor3 = Theme.Element}, 0.15)
            end
        end)
        
        Tab.Button = TabButton
        Tab.Label = TabLabel
        
        table.insert(Window.Tabs, Tab)
        
        -- Auto-select first tab
        if #Window.Tabs == 1 then
            TabButton.BackgroundColor3 = Theme.Accent
            TabLabel.TextColor3 = Theme.Text
            TabContent.Visible = true
            Window.CurrentTab = Tab
        end
        
        -- SECTION
        function Tab:CreateSection(sectionName)
            local SectionFrame = Create("Frame", {
                Name = sectionName,
                Size = UDim2.new(1, 0, 0, 30),
                BackgroundTransparency = 1,
                Parent = TabContent
            })
            
            local SectionLabel = Create("TextLabel", {
                Size = UDim2.new(1, -15, 1, 0),
                Position = UDim2.new(0, 8, 0, 0),
                BackgroundTransparency = 1,
                Text = sectionName,
                TextColor3 = Theme.Accent,
                TextSize = 15,
                Font = Enum.Font.GothamBold,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = SectionFrame
            })
            
            local Divider = Create("Frame", {
                Size = UDim2.new(1, -15, 0, 1),
                Position = UDim2.new(0, 8, 1, -2),
                BackgroundColor3 = Theme.Border,
                BorderSizePixel = 0,
                Parent = SectionFrame
            })
            
            table.insert(Tab.Sections, sectionName)
        end
        
        -- LABEL
        function Tab:CreateLabel(text)
            local LabelFrame = Create("Frame", {
                Size = UDim2.new(1, 0, 0, 28),
                BackgroundTransparency = 1,
                Parent = TabContent
            })
            
            local Label = Create("TextLabel", {
                Size = UDim2.new(1, -15, 1, 0),
                Position = UDim2.new(0, 8, 0, 0),
                BackgroundTransparency = 1,
                Text = text,
                TextColor3 = Theme.TextDim,
                TextSize = 13,
                Font = Enum.Font.Gotham,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextWrapped = true,
                Parent = LabelFrame
            })
            
            local LabelObject = {}
            
            function LabelObject:Set(newText)
                if Label and Label.Parent then
                    Label.Text = newText
                end
            end
            
            return LabelObject
        end
        
        -- TOGGLE
        function Tab:CreateToggle(config)
            config = config or {}
            local Name = config.Name or "Toggle"
            local Flag = config.Flag or Name
            local CurrentValue = SavedConfig[Flag]
            if CurrentValue == nil then
                CurrentValue = config.CurrentValue or false
            end
            local Callback = config.Callback or function() end
            
            local ToggleFrame = Create("Frame", {
                Size = UDim2.new(1, 0, 0, 38),
                BackgroundColor3 = Theme.Element,
                BorderSizePixel = 0,
                Parent = TabContent
            })
            
            Create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = ToggleFrame})
            
            local ToggleLabel = Create("TextLabel", {
                Size = UDim2.new(1, -55, 1, 0),
                Position = UDim2.new(0, 12, 0, 0),
                BackgroundTransparency = 1,
                Text = Name,
                TextColor3 = Theme.Text,
                TextSize = 13,
                Font = Enum.Font.Gotham,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = ToggleFrame
            })
            
            local ToggleButton = Create("TextButton", {
                Size = UDim2.new(0, 38, 0, 20),
                Position = UDim2.new(1, -45, 0.5, -10),
                BackgroundColor3 = CurrentValue and Theme.Success or Theme.BorderDark,
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
                Tween(ToggleButton, {BackgroundColor3 = CurrentValue and Theme.Success or Theme.BorderDark}, 0.2)
                Tween(ToggleCircle, {
                    Position = CurrentValue and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
                }, 0.2, Enum.EasingStyle.Back)
                SavedConfig[Flag] = CurrentValue
                SaveConfig()
                
                -- Notification
                Window:Notify({
                    Title = Name,
                    Content = CurrentValue and "Enabled" or "Disabled",
                    Duration = 2,
                    Type = CurrentValue and "success" or "info"
                })
                
                Callback(CurrentValue)
            end
            
            ToggleButton.MouseButton1Click:Connect(function()
                CurrentValue = not CurrentValue
                ToggleObject.Value = CurrentValue
                Update()
            end)
            
            ToggleFrame.MouseEnter:Connect(function()
                Tween(ToggleFrame, {BackgroundColor3 = Theme.ElementHover}, 0.15)
            end)
            
            ToggleFrame.MouseLeave:Connect(function()
                Tween(ToggleFrame, {BackgroundColor3 = Theme.Element}, 0.15)
            end)
            
            function ToggleObject:Set(value)
                CurrentValue = value
                ToggleObject.Value = value
                Update()
            end
            
            -- Don't notify on initial load
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
                BorderSizePixel = 0,
                Parent = TabContent
            })
            
            Create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = SliderFrame})
            
            local SliderLabel = Create("TextLabel", {
                Size = UDim2.new(1, -75, 0, 20),
                Position = UDim2.new(0, 12, 0, 8),
                BackgroundTransparency = 1,
                Text = Name,
                TextColor3 = Theme.Text,
                TextSize = 13,
                Font = Enum.Font.Gotham,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = SliderFrame
            })
            
            local ValueLabel = Create("TextLabel", {
                Size = UDim2.new(0, 65, 0, 20),
                Position = UDim2.new(1, -75, 0, 8),
                BackgroundTransparency = 1,
                Text = tostring(CurrentValue) .. Suffix,
                TextColor3 = Theme.Accent,
                TextSize = 13,
                Font = Enum.Font.GothamBold,
                TextXAlignment = Enum.TextXAlignment.Right,
                Parent = SliderFrame
            })
            
            local SliderTrack = Create("Frame", {
                Size = UDim2.new(1, -24, 0, 5),
                Position = UDim2.new(0, 12, 1, -16),
                BackgroundColor3 = Theme.BorderDark,
                BorderSizePixel = 0,
                Parent = SliderFrame
            })
            
            Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = SliderTrack})
            
            local SliderFill = Create("Frame", {
                Size = UDim2.new((CurrentValue - Range[1]) / (Range[2] - Range[1]), 0, 1, 0),
                BackgroundColor3 = Theme.Accent,
                BorderSizePixel = 0,
                Parent = SliderTrack
            })
            
            Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = SliderFill})
            
            local SliderDot = Create("Frame", {
                Size = UDim2.new(0, 11, 0, 11),
                Position = UDim2.new((CurrentValue - Range[1]) / (Range[2] - Range[1]), -5.5, 0.5, -5.5),
                BackgroundColor3 = Theme.Text,
                BorderSizePixel = 0,
                Parent = SliderTrack
            })
            
            Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = SliderDot})
            
            local Dragging = false
            
            local function UpdateSlider(input)
                local mousePos = input.Position.X
                local trackPos = SliderTrack.AbsolutePosition.X
                local trackSize = SliderTrack.AbsoluteSize.X
                local percentage = math.clamp((mousePos - trackPos) / trackSize, 0, 1)
                local value = Range[1] + (Range[2] - Range[1]) * percentage
                value = math.floor(value / Increment + 0.5) * Increment
                value = math.clamp(value, Range[1], Range[2])
                
                CurrentValue = value
                ValueLabel.Text = tostring(value) .. Suffix
                Tween(SliderFill, {Size = UDim2.new(percentage, 0, 1, 0)}, 0.1)
                Tween(SliderDot, {Position = UDim2.new(percentage, -5.5, 0.5, -5.5)}, 0.1)
                
                SavedConfig[Flag] = value
                SaveConfig()
                Callback(value)
            end
            
            SliderTrack.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    Dragging = true
                    UpdateSlider(input)
                    Tween(SliderDot, {Size = UDim2.new(0, 15, 0, 15), Position = SliderDot.Position - UDim2.new(0, 2, 0, 2)}, 0.1)
                end
            end)
            
            SliderTrack.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    Dragging = false
                    Tween(SliderDot, {Size = UDim2.new(0, 11, 0, 11), Position = SliderDot.Position + UDim2.new(0, 2, 0, 2)}, 0.1)
                end
            end)
            
            UserInputService.InputChanged:Connect(function(input)
                if Dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                    UpdateSlider(input)
                end
            end)
            
            SliderFrame.MouseEnter:Connect(function()
                Tween(SliderFrame, {BackgroundColor3 = Theme.ElementHover}, 0.15)
            end)
            
            SliderFrame.MouseLeave:Connect(function()
                Tween(SliderFrame, {BackgroundColor3 = Theme.Element}, 0.15)
            end)
        end
        
        -- DROPDOWN (WORKING & FIXED!)
        function Tab:CreateDropdown(config)
            config = config or {}
            local Name = config.Name or "Dropdown"
            local Flag = config.Flag or Name
            local Options = config.Options or {}
            local MultipleOptions = config.MultipleOptions or false
            local CurrentOption = SavedConfig[Flag] or config.CurrentOption or (MultipleOptions and {} or {})
            local Callback = config.Callback or function() end
            
            -- Ensure CurrentOption is a table
            if type(CurrentOption) ~= "table" then
                CurrentOption = {CurrentOption}
            end
            
            local DropdownFrame = Create("Frame", {
                Size = UDim2.new(1, 0, 0, 38),
                BackgroundColor3 = Theme.Element,
                BorderSizePixel = 0,
                ClipsDescendants = false,
                Parent = TabContent
            })
            
            Create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = DropdownFrame})
            
            local DropdownButton = Create("TextButton", {
                Size = UDim2.new(1, 0, 0, 38),
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
                TextSize = 13,
                Font = Enum.Font.Gotham,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = DropdownButton
            })
            
            local DropdownIcon = Create("TextLabel", {
                Size = UDim2.new(0, 20, 1, 0),
                Position = UDim2.new(1, -28, 0, 0),
                BackgroundTransparency = 1,
                Text = "▼",
                TextColor3 = Theme.TextDim,
                TextSize = 10,
                Font = Enum.Font.Gotham,
                Parent = DropdownButton
            })
            
            local DropdownList = Create("ScrollingFrame", {
                Size = UDim2.new(1, 0, 0, 0),
                Position = UDim2.new(0, 0, 0, 42),
                BackgroundColor3 = Theme.Content,
                BorderSizePixel = 0,
                ClipsDescendants = true,
                Visible = false,
                ScrollBarThickness = 3,
                ScrollBarImageColor3 = Theme.Accent,
                CanvasSize = UDim2.new(0, 0, 0, 0),
                AutomaticCanvasSize = Enum.AutomaticSize.Y,
                ZIndex = 10,
                Parent = DropdownFrame
            })
            
            Create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = DropdownList})
            Create("UIStroke", {Color = Theme.Border, Thickness = 1, Parent = DropdownList})
            
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
                
                local targetHeight = math.min(#Options * 30 + 10, 160)
                local frameSize = Expanded and UDim2.new(1, 0, 0, 42 + targetHeight) or UDim2.new(1, 0, 0, 38)
                
                Tween(DropdownList, {Size = Expanded and UDim2.new(1, 0, 0, targetHeight) or UDim2.new(1, 0, 0, 0)}, 0.2)
                Tween(DropdownIcon, {Rotation = Expanded and 180 or 0}, 0.2)
                Tween(DropdownFrame, {Size = frameSize}, 0.2)
            end)
            
            DropdownFrame.MouseEnter:Connect(function()
                if not Expanded then
                    Tween(DropdownFrame, {BackgroundColor3 = Theme.ElementHover}, 0.15)
                end
            end)
            
            DropdownFrame.MouseLeave:Connect(function()
                if not Expanded then
                    Tween(DropdownFrame, {BackgroundColor3 = Theme.Element}, 0.15)
                end
            end)
            
            for _, option in ipairs(Options) do
                local OptionButton = Create("TextButton", {
                    Size = UDim2.new(1, 0, 0, 28),
                    BackgroundColor3 = Theme.Element,
                    Text = "",
                    AutoButtonColor = false,
                    Parent = DropdownList
                })
                
                Create("UICorner", {CornerRadius = UDim.new(0, 5), Parent = OptionButton})
                
                local OptionLabel = Create("TextLabel", {
                    Size = UDim2.new(1, -15, 1, 0),
                    Position = UDim2.new(0, 8, 0, 0),
                    BackgroundTransparency = 1,
                    Text = option,
                    TextColor3 = Theme.TextDim,
                    TextSize = 12,
                    Font = Enum.Font.Gotham,
                    TextXAlignment = Enum.TextXAlignment.Left,
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
                
                OptionButton.MouseEnter:Connect(function()
                    if not table.find(CurrentOption, option) then
                        Tween(OptionButton, {BackgroundColor3 = Theme.ElementHover}, 0.15)
                    end
                end)
                
                OptionButton.MouseLeave:Connect(function()
                    if not table.find(CurrentOption, option) then
                        Tween(OptionButton, {BackgroundColor3 = Theme.Element}, 0.15)
                    end
                end)
                
                -- Set initial state
                if table.find(CurrentOption, option) then
                    OptionButton.BackgroundColor3 = Theme.Accent
                    OptionLabel.TextColor3 = Theme.Text
                end
            end
        end
        
        -- KEYBIND (FIXED!)
        function Tab:CreateKeybind(config)
            config = config or {}
            local Name = config.Name or "Keybind"
            local Flag = config.Flag or Name
            local CurrentKeybind = SavedConfig[Flag] or config.CurrentKeybind or "None"
            local Callback = config.Callback or function() end
            
            local KeybindFrame = Create("Frame", {
                Size = UDim2.new(1, 0, 0, 38),
                BackgroundColor3 = Theme.Element,
                BorderSizePixel = 0,
                Parent = TabContent
            })
            
            Create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = KeybindFrame})
            
            local KeybindLabel = Create("TextLabel", {
                Size = UDim2.new(1, -90, 1, 0),
                Position = UDim2.new(0, 12, 0, 0),
                BackgroundTransparency = 1,
                Text = Name,
                TextColor3 = Theme.Text,
                TextSize = 13,
                Font = Enum.Font.Gotham,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = KeybindFrame
            })
            
            local KeybindButton = Create("TextButton", {
                Size = UDim2.new(0, 75, 0, 26),
                Position = UDim2.new(1, -82, 0.5, -13),
                BackgroundColor3 = Theme.Content,
                Text = CurrentKeybind,
                TextColor3 = Theme.Text,
                TextSize = 12,
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
            
            KeybindFrame.MouseEnter:Connect(function()
                Tween(KeybindFrame, {BackgroundColor3 = Theme.ElementHover}, 0.15)
            end)
            
            KeybindFrame.MouseLeave:Connect(function()
                Tween(KeybindFrame, {BackgroundColor3 = Theme.Element}, 0.15)
            end)
            
            -- Setup callback
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
                BorderSizePixel = 0,
                Parent = TabContent
            })
            
            Create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = ButtonFrame})
            
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
                Tween(ButtonFrame, {BackgroundColor3 = Theme.AccentHover}, 0.1)
                task.wait(0.1)
                Tween(ButtonFrame, {BackgroundColor3 = Theme.Accent}, 0.1)
            end)
            
            Button.MouseEnter:Connect(function()
                Tween(ButtonFrame, {BackgroundColor3 = Theme.AccentHover}, 0.15)
            end)
            
            Button.MouseLeave:Connect(function()
                Tween(ButtonFrame, {BackgroundColor3 = Theme.Accent}, 0.15)
            end)
        end
        
        return Tab
    end
    
    -- NOTIFICATION SYSTEM (FIXED!)
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
                Size = UDim2.new(0, 320, 1, 0),
                Position = UDim2.new(1, -330, 0, 15),
                BackgroundTransparency = 1,
                Parent = ScreenGui
            })
            
            Create("UIListLayout", {
                Padding = UDim.new(0, 10),
                SortOrder = Enum.SortOrder.LayoutOrder,
                VerticalAlignment = Enum.VerticalAlignment.Top,
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
            Parent = NotifContainer
        })
        
        Create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = Notification})
        Create("UIStroke", {Color = typeColors[Type] or Theme.Info, Thickness = 2, Parent = Notification})
        
        local NotifTitle = Create("TextLabel", {
            Size = UDim2.new(1, -20, 0, 22),
            Position = UDim2.new(0, 10, 0, 10),
            BackgroundTransparency = 1,
            Text = Title,
            TextColor3 = Theme.Text,
            TextSize = 14,
            Font = Enum.Font.GothamBold,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = Notification
        })
        
        local NotifContent = Create("TextLabel", {
            Size = UDim2.new(1, -20, 0, 0),
            Position = UDim2.new(0, 10, 0, 32),
            BackgroundTransparency = 1,
            Text = Content,
            TextColor3 = Theme.TextDim,
            TextSize = 12,
            Font = Enum.Font.Gotham,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Top,
            TextWrapped = true,
            Parent = Notification
        })
        
        -- Calculate content height
        local textSize = game:GetService("TextService"):GetTextSize(
            Content,
            12,
            Enum.Font.Gotham,
            Vector2.new(290, math.huge)
        )
        
        local finalHeight = 42 + textSize.Y + 10
        NotifContent.Size = UDim2.new(1, -20, 0, textSize.Y)
        
        Tween(Notification, {Size = UDim2.new(1, 0, 0, finalHeight)}, 0.3, Enum.EasingStyle.Back)
        
        task.spawn(function()
            task.wait(Duration)
            Tween(Notification, {Size = UDim2.new(1, 0, 0, 0)}, 0.2)
            task.wait(0.2)
            Notification:Destroy()
        end)
    end
    
    return Window
end

return RavynethUI
