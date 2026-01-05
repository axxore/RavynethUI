-- ╔══════════════════════════════════════════════════════════════╗
-- ║              RAVYNETH UI V5 - PREMIUM STYLE                  ║
-- ║          Black-Purple Gradient Design (Like Website)         ║
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

-- PREMIUM BLACK-PURPLE GRADIENT THEME (LIKE WEBSITE)
local Theme = {
    -- Main Colors (Black-Purple Gradient)
    Background = Color3.fromRGB(10, 8, 15),
    BackgroundGradient = Color3.fromRGB(25, 15, 35),
    Sidebar = Color3.fromRGB(15, 12, 22),
    Content = Color3.fromRGB(18, 14, 26),
    Element = Color3.fromRGB(22, 18, 32),
    ElementHover = Color3.fromRGB(30, 24, 42),
    
    -- Purple Accent (Main Color)
    Accent = Color3.fromRGB(138, 43, 226),
    AccentLight = Color3.fromRGB(168, 73, 255),
    AccentDark = Color3.fromRGB(108, 13, 196),
    AccentGlow = Color3.fromRGB(138, 43, 226),
    
    -- Text Colors
    Text = Color3.fromRGB(255, 255, 255),
    TextDim = Color3.fromRGB(180, 180, 200),
    TextDarker = Color3.fromRGB(120, 120, 140),
    
    -- Status Colors (All Purple Shades)
    Success = Color3.fromRGB(138, 43, 226),
    Warning = Color3.fromRGB(168, 73, 255),
    Error = Color3.fromRGB(148, 33, 216),
    Info = Color3.fromRGB(128, 53, 236),
    
    -- Border
    Border = Color3.fromRGB(60, 40, 80),
    BorderGlow = Color3.fromRGB(138, 43, 226)
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

local function AddGradient(frame, color1, color2, rotation)
    local gradient = Create("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, color1),
            ColorSequenceKeypoint.new(1, color2)
        }),
        Rotation = rotation or 90,
        Parent = frame
    })
    return gradient
end

local function AddGlow(frame, color, transparency)
    local glow = Create("ImageLabel", {
        Name = "Glow",
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = UDim2.new(1, 40, 1, 40),
        BackgroundTransparency = 1,
        Image = "rbxassetid://5554236805",
        ImageColor3 = color or Theme.AccentGlow,
        ImageTransparency = transparency or 0.5,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(23, 23, 277, 277),
        ZIndex = frame.ZIndex - 1,
        Parent = frame
    })
    return glow
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
        Size = UDim2.new(0, 850, 0, 580),
        Position = UDim2.new(0.5, -425, 0.5, -290),
        BackgroundColor3 = Theme.Background,
        BorderSizePixel = 0,
        ClipsDescendants = false,
        ZIndex = 1,
        Parent = ScreenGui
    })
    
    Create("UICorner", {CornerRadius = UDim.new(0, 12), Parent = MainFrame})
    AddGradient(MainFrame, Theme.Background, Theme.BackgroundGradient, 135)
    
    -- Premium Shadow & Glow
    local Shadow = Create("ImageLabel", {
        Name = "Shadow",
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = UDim2.new(1, 80, 1, 80),
        BackgroundTransparency = 1,
        Image = "rbxassetid://5554236805",
        ImageColor3 = Color3.new(0, 0, 0),
        ImageTransparency = 0.2,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(23, 23, 277, 277),
        ZIndex = 0,
        Parent = MainFrame
    })
    
    local PurpleGlow = Create("ImageLabel", {
        Name = "PurpleGlow",
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = UDim2.new(1, 100, 1, 100),
        BackgroundTransparency = 1,
        Image = "rbxassetid://5554236805",
        ImageColor3 = Theme.AccentGlow,
        ImageTransparency = 0.7,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(23, 23, 277, 277),
        ZIndex = 0,
        Parent = MainFrame
    })
    
    -- Drag System (FIXED - doesn't affect children)
    local dragging, dragInput, dragStart, startPos
    
    MainFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            local mousePos = UserInputService:GetMouseLocation()
            local framePos = MainFrame.AbsolutePosition
            local frameSize = MainFrame.AbsoluteSize
            
            -- Check if click is in header area only
            if mousePos.Y - framePos.Y <= 60 then
                dragging = true
                dragStart = input.Position
                startPos = MainFrame.Position
                
                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then
                        dragging = false
                    end
                end)
            end
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
            if dragging then
                local delta = input.Position - dragStart
                MainFrame.Position = UDim2.new(
                    startPos.X.Scale,
                    startPos.X.Offset + delta.X,
                    startPos.Y.Scale,
                    startPos.Y.Offset + delta.Y
                )
            end
        end
    end)
    
    -- Header
    local Header = Create("Frame", {
        Name = "Header",
        Size = UDim2.new(1, 0, 0, 60),
        BackgroundColor3 = Theme.Sidebar,
        BorderSizePixel = 0,
        ClipsDescendants = false,
        ZIndex = 2,
        Parent = MainFrame
    })
    
    Create("UICorner", {CornerRadius = UDim.new(0, 12), Parent = Header})
    AddGradient(Header, Theme.Sidebar, Theme.Background, 90)
    
    -- Fix rounded corners at bottom
    Create("Frame", {
        Size = UDim2.new(1, 0, 0, 12),
        Position = UDim2.new(0, 0, 1, -12),
        BackgroundColor3 = Theme.Sidebar,
        BorderSizePixel = 0,
        ZIndex = 2,
        Parent = Header
    })
    
    AddGradient(Header:GetChildren()[#Header:GetChildren()], Theme.Sidebar, Theme.Background, 90)
    
    -- LOGO (RAVYNETH TEXT WITH GRADIENT)
    local LogoContainer = Create("Frame", {
        Name = "LogoContainer",
        Size = UDim2.new(0, 180, 0, 45),
        Position = UDim2.new(0, 18, 0, 7),
        BackgroundTransparency = 1,
        ZIndex = 3,
        Parent = Header
    })
    
    local LogoText = Create("TextLabel", {
        Name = "LogoText",
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "RAVYNETH",
        TextColor3 = Theme.Text,
        TextSize = 24,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center,
        ZIndex = 3,
        Parent = LogoContainer
    })
    
    -- Gradient on logo text
    AddGradient(LogoText, Theme.AccentLight, Theme.Accent, 90)
    
    -- Add glow effect to logo
    local LogoGlow = Create("ImageLabel", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = UDim2.new(1, 40, 1, 40),
        BackgroundTransparency = 1,
        Image = "rbxassetid://5554236805",
        ImageColor3 = Theme.AccentGlow,
        ImageTransparency = 0.6,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(23, 23, 277, 277),
        ZIndex = 2,
        Parent = LogoContainer
    })
    
    local LogoSubtext = Create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 12),
        Position = UDim2.new(0, 0, 1, -10),
        BackgroundTransparency = 1,
        Text = "ADVANCED SCRIPT HUB",
        TextColor3 = Theme.TextDim,
        TextSize = 9,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 3,
        Parent = LogoContainer
    })
    
    -- Search Bar
    local SearchContainer = Create("Frame", {
        Name = "SearchContainer",
        Size = UDim2.new(0, 260, 0, 38),
        Position = UDim2.new(0, 210, 0, 11),
        BackgroundColor3 = Theme.Element,
        BorderSizePixel = 0,
        ClipsDescendants = false,
        ZIndex = 3,
        Parent = Header
    })
    
    Create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = SearchContainer})
    Create("UIStroke", {Color = Theme.Border, Thickness = 1, Transparency = 0.5, Parent = SearchContainer})
    
    local SearchIcon = Create("ImageLabel", {
        Size = UDim2.new(0, 18, 0, 18),
        Position = UDim2.new(0, 12, 0.5, -9),
        BackgroundTransparency = 1,
        Image = "rbxassetid://3926305904",
        ImageRectOffset = Vector2.new(964, 324),
        ImageRectSize = Vector2.new(36, 36),
        ImageColor3 = Theme.Accent,
        ZIndex = 4,
        Parent = SearchContainer
    })
    
    local SearchBox = Create("TextBox", {
        Name = "SearchBox",
        Size = UDim2.new(1, -45, 1, 0),
        Position = UDim2.new(0, 38, 0, 0),
        BackgroundTransparency = 1,
        Text = "",
        PlaceholderText = "Search...",
        PlaceholderColor3 = Theme.TextDarker,
        TextColor3 = Theme.Text,
        TextSize = 13,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        ClearTextOnFocus = false,
        ZIndex = 4,
        Parent = SearchContainer
    })
    
    -- Search functionality
    SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
        local query = SearchBox.Text:lower()
        Window.SearchQuery = query
        
        if Window.CurrentTab and Window.CurrentTab.Container then
            for _, element in pairs(Window.CurrentTab.Container:GetChildren()) do
                if element:IsA("Frame") and element.Name ~= "UIListLayout" and element.Name ~= "UIPadding" then
                    local textLabel = element:FindFirstChildOfClass("TextLabel")
                    if textLabel then
                        local text = textLabel.Text:lower()
                        element.Visible = query == "" or text:find(query, 1, true) ~= nil
                    end
                end
            end
        end
    end)
    
    SearchContainer.MouseEnter:Connect(function()
        Tween(SearchContainer, {BackgroundColor3 = Theme.ElementHover}, 0.2)
    end)
    
    SearchContainer.MouseLeave:Connect(function()
        Tween(SearchContainer, {BackgroundColor3 = Theme.Element}, 0.2)
    end)
    
    -- Control Buttons
    local ButtonContainer = Create("Frame", {
        Name = "ButtonContainer",
        Size = UDim2.new(0, 80, 0, 38),
        Position = UDim2.new(1, -95, 0, 11),
        BackgroundTransparency = 1,
        ZIndex = 3,
        Parent = Header
    })
    
    Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        HorizontalAlignment = Enum.HorizontalAlignment.Right,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 8),
        Parent = ButtonContainer
    })
    
    -- Minimize Button
    local MinimizeBtn = Create("TextButton", {
        Name = "MinimizeBtn",
        Size = UDim2.new(0, 36, 0, 36),
        BackgroundColor3 = Theme.Element,
        Text = "—",
        TextColor3 = Theme.Text,
        TextSize = 18,
        Font = Enum.Font.GothamBold,
        AutoButtonColor = false,
        ZIndex = 4,
        Parent = ButtonContainer
    })
    
    Create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = MinimizeBtn})
    Create("UIStroke", {Color = Theme.Border, Thickness = 1, Transparency = 0.5, Parent = MinimizeBtn})
    
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
        Size = UDim2.new(0, 36, 0, 36),
        BackgroundColor3 = Theme.Element,
        Text = "✕",
        TextColor3 = Theme.Text,
        TextSize = 16,
        Font = Enum.Font.GothamBold,
        AutoButtonColor = false,
        ZIndex = 4,
        Parent = ButtonContainer
    })
    
    Create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = CloseBtn})
    Create("UIStroke", {Color = Theme.Border, Thickness = 1, Transparency = 0.5, Parent = CloseBtn})
    
    CloseBtn.MouseButton1Click:Connect(function()
        Window:Destroy()
    end)
    
    CloseBtn.MouseEnter:Connect(function()
        Tween(CloseBtn, {BackgroundColor3 = Theme.Accent}, 0.15)
    end)
    
    CloseBtn.MouseLeave:Connect(function()
        Tween(CloseBtn, {BackgroundColor3 = Theme.Element}, 0.15)
    end)
    
    -- Sidebar
    local Sidebar = Create("Frame", {
        Name = "Sidebar",
        Size = UDim2.new(0, 165, 1, -72),
        Position = UDim2.new(0, 12, 0, 65),
        BackgroundColor3 = Theme.Sidebar,
        BorderSizePixel = 0,
        ClipsDescendants = false,
        ZIndex = 2,
        Parent = MainFrame
    })
    
    Create("UICorner", {CornerRadius = UDim.new(0, 10), Parent = Sidebar})
    Create("UIStroke", {Color = Theme.Border, Thickness = 1, Transparency = 0.3, Parent = Sidebar})
    AddGradient(Sidebar, Theme.Sidebar, Theme.Content, 135)
    
    local SidebarList = Create("ScrollingFrame", {
        Name = "SidebarList",
        Size = UDim2.new(1, -12, 1, -12),
        Position = UDim2.new(0, 6, 0, 6),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 4,
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
        PaddingTop = UDim.new(0, 6),
        PaddingBottom = UDim.new(0, 6),
        PaddingLeft = UDim.new(0, 6),
        PaddingRight = UDim.new(0, 6),
        Parent = SidebarList
    })
    
    -- Content Container
    local ContentContainer = Create("Frame", {
        Name = "ContentContainer",
        Size = UDim2.new(1, -199, 1, -72),
        Position = UDim2.new(0, 187, 0, 65),
        BackgroundColor3 = Theme.Content,
        BorderSizePixel = 0,
        ClipsDescendants = false,
        ZIndex = 2,
        Parent = MainFrame
    })
    
    Create("UICorner", {CornerRadius = UDim.new(0, 10), Parent = ContentContainer})
    Create("UIStroke", {Color = Theme.Border, Thickness = 1, Transparency = 0.3, Parent = ContentContainer})
    AddGradient(ContentContainer, Theme.Content, Theme.Element, 135)
    
    -- Window Functions
    function Window:Toggle()
        Window.Visible = not Window.Visible
        if Window.Visible then
            MainFrame.Visible = true
            Tween(MainFrame, {Size = UDim2.new(0, 850, 0, 580)}, 0.3, Enum.EasingStyle.Back)
        else
            Tween(MainFrame, {Size = UDim2.new(0, 0, 0, 0)}, 0.25)
            task.wait(0.25)
            MainFrame.Visible = false
        end
    end
    
    function Window:Minimize()
        Window.Minimized = not Window.Minimized
        if Window.Minimized then
            Tween(MainFrame, {Size = UDim2.new(0, 850, 0, 60)}, 0.25)
            Sidebar.Visible = false
            ContentContainer.Visible = false
        else
            Tween(MainFrame, {Size = UDim2.new(0, 850, 0, 580)}, 0.25)
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
            Size = UDim2.new(1, 0, 0, 42),
            BackgroundColor3 = Theme.Element,
            Text = "",
            AutoButtonColor = false,
            ZIndex = 4,
            Parent = SidebarList
        })
        
        Create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = TabButton})
        Create("UIStroke", {Color = Theme.Border, Thickness = 1, Transparency = 0.5, Parent = TabButton})
        
        local TabLabel = Create("TextLabel", {
            Size = UDim2.new(1, -20, 1, 0),
            Position = UDim2.new(0, 12, 0, 0),
            BackgroundTransparency = 1,
            Text = tabName,
            TextColor3 = Theme.TextDim,
            TextSize = 14,
            Font = Enum.Font.GothamBold,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 5,
            Parent = TabButton
        })
        
        -- Tab Content
        local TabContent = Create("ScrollingFrame", {
            Name = tabName .. "Content",
            Size = UDim2.new(1, -24, 1, -24),
            Position = UDim2.new(0, 12, 0, 12),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ScrollBarThickness = 5,
            ScrollBarImageColor3 = Theme.Accent,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            Visible = false,
            ClipsDescendants = true,
            ZIndex = 3,
            Parent = ContentContainer
        })
        
        Create("UIListLayout", {
            Padding = UDim.new(0, 10),
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
                local stroke = tab.Button:FindFirstChildOfClass("UIStroke")
                if stroke then stroke.Transparency = 0.5 end
            end
            
            TabContent.Visible = true
            TabButton.BackgroundColor3 = Theme.Accent
            TabLabel.TextColor3 = Theme.Text
            local stroke = TabButton:FindFirstChildOfClass("UIStroke")
            if stroke then stroke.Color = Theme.AccentLight stroke.Transparency = 0 end
            Window.CurrentTab = Tab
            
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
            local stroke = TabButton:FindFirstChildOfClass("UIStroke")
            if stroke then stroke.Color = Theme.AccentLight stroke.Transparency = 0 end
            TabContent.Visible = true
            Window.CurrentTab = Tab
        end
        
        -- SECTION
        function Tab:CreateSection(sectionName)
            local SectionFrame = Create("Frame", {
                Name = sectionName,
                Size = UDim2.new(1, 0, 0, 32),
                BackgroundTransparency = 1,
                ZIndex = 4,
                Parent = TabContent
            })
            
            local SectionLabel = Create("TextLabel", {
                Size = UDim2.new(1, -20, 1, 0),
                Position = UDim2.new(0, 10, 0, 0),
                BackgroundTransparency = 1,
                Text = sectionName,
                TextColor3 = Theme.Accent,
                TextSize = 15,
                Font = Enum.Font.GothamBold,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = 5,
                Parent = SectionFrame
            })
            
            AddGradient(SectionLabel, Theme.AccentLight, Theme.Accent, 90)
            
            local Divider = Create("Frame", {
                Size = UDim2.new(1, -20, 0, 2),
                Position = UDim2.new(0, 10, 1, -4),
                BackgroundColor3 = Theme.Accent,
                BorderSizePixel = 0,
                ZIndex = 4,
                Parent = SectionFrame
            })
            
            AddGradient(Divider, Theme.Accent, Theme.AccentDark, 0)
            
            table.insert(Tab.Sections, sectionName)
        end
        
        -- LABEL
        function Tab:CreateLabel(text)
            local LabelFrame = Create("Frame", {
                Size = UDim2.new(1, 0, 0, 30),
                BackgroundTransparency = 1,
                ZIndex = 4,
                Parent = TabContent
            })
            
            local Label = Create("TextLabel", {
                Size = UDim2.new(1, -20, 1, 0),
                Position = UDim2.new(0, 10, 0, 0),
                BackgroundTransparency = 1,
                Text = text,
                TextColor3 = Theme.TextDim,
                TextSize = 13,
                Font = Enum.Font.Gotham,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextWrapped = true,
                ZIndex = 5,
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
                Size = UDim2.new(1, 0, 0, 42),
                BackgroundColor3 = Theme.Element,
                BorderSizePixel = 0,
                ZIndex = 4,
                Parent = TabContent
            })
            
            Create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = ToggleFrame})
            Create("UIStroke", {Color = Theme.Border, Thickness = 1, Transparency = 0.5, Parent = ToggleFrame})
            AddGradient(ToggleFrame, Theme.Element, Theme.Content, 90)
            
            local ToggleLabel = Create("TextLabel", {
                Size = UDim2.new(1, -60, 1, 0),
                Position = UDim2.new(0, 14, 0, 0),
                BackgroundTransparency = 1,
                Text = Name,
                TextColor3 = Theme.Text,
                TextSize = 13,
                Font = Enum.Font.Gotham,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = 5,
                Parent = ToggleFrame
            })
            
            local ToggleButton = Create("TextButton", {
                Size = UDim2.new(0, 42, 0, 22),
                Position = UDim2.new(1, -50, 0.5, -11),
                BackgroundColor3 = CurrentValue and Theme.Accent or Theme.Content,
                Text = "",
                AutoButtonColor = false,
                ZIndex = 5,
                Parent = ToggleFrame
            })
            
            Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = ToggleButton})
            if CurrentValue then
                AddGradient(ToggleButton, Theme.Accent, Theme.AccentDark, 90)
            end
            
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
                
                -- Remove old gradient
                local oldGradient = ToggleButton:FindFirstChildOfClass("UIGradient")
                if oldGradient then oldGradient:Destroy() end
                
                if CurrentValue then
                    ToggleButton.BackgroundColor3 = Theme.Accent
                    AddGradient(ToggleButton, Theme.Accent, Theme.AccentDark, 90)
                else
                    ToggleButton.BackgroundColor3 = Theme.Content
                end
                
                Tween(ToggleCircle, {
                    Position = CurrentValue and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)
                }, 0.2, Enum.EasingStyle.Back)
                
                SavedConfig[Flag] = CurrentValue
                SaveConfig()
                
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
            
            pcall(Callback, CurrentValue)
            
            return ToggleObject
        end
        
        -- SLIDER (FIXED - No drag UI issue!)
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
                Size = UDim2.new(1, 0, 0, 56),
                BackgroundColor3 = Theme.Element,
                BorderSizePixel = 0,
                ClipsDescendants = false,
                ZIndex = 4,
                Parent = TabContent
            })
            
            Create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = SliderFrame})
            Create("UIStroke", {Color = Theme.Border, Thickness = 1, Transparency = 0.5, Parent = SliderFrame})
            AddGradient(SliderFrame, Theme.Element, Theme.Content, 90)
            
            local SliderLabel = Create("TextLabel", {
                Size = UDim2.new(1, -80, 0, 22),
                Position = UDim2.new(0, 14, 0, 10),
                BackgroundTransparency = 1,
                Text = Name,
                TextColor3 = Theme.Text,
                TextSize = 13,
                Font = Enum.Font.Gotham,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = 5,
                Parent = SliderFrame
            })
            
            local ValueLabel = Create("TextLabel", {
                Size = UDim2.new(0, 70, 0, 22),
                Position = UDim2.new(1, -80, 0, 10),
                BackgroundTransparency = 1,
                Text = tostring(CurrentValue) .. Suffix,
                TextColor3 = Theme.Accent,
                TextSize = 13,
                Font = Enum.Font.GothamBold,
                TextXAlignment = Enum.TextXAlignment.Right,
                ZIndex = 5,
                Parent = SliderFrame
            })
            
            local SliderTrack = Create("Frame", {
                Size = UDim2.new(1, -28, 0, 6),
                Position = UDim2.new(0, 14, 1, -18),
                BackgroundColor3 = Theme.Content,
                BorderSizePixel = 0,
                ClipsDescendants = false,
                ZIndex = 5,
                Parent = SliderFrame
            })
            
            Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = SliderTrack})
            
            local SliderFill = Create("Frame", {
                Size = UDim2.new((CurrentValue - Range[1]) / (Range[2] - Range[1]), 0, 1, 0),
                BackgroundColor3 = Theme.Accent,
                BorderSizePixel = 0,
                ClipsDescendants = false,
                ZIndex = 6,
                Parent = SliderTrack
            })
            
            Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = SliderFill})
            AddGradient(SliderFill, Theme.AccentLight, Theme.Accent, 0)
            
            local SliderDot = Create("Frame", {
                Size = UDim2.new(0, 14, 0, 14),
                Position = UDim2.new((CurrentValue - Range[1]) / (Range[2] - Range[1]), -7, 0.5, -7),
                BackgroundColor3 = Theme.Text,
                BorderSizePixel = 0,
                ClipsDescendants = false,
                ZIndex = 7,
                Parent = SliderTrack
            })
            
            Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = SliderDot})
            Create("UIStroke", {Color = Theme.Accent, Thickness = 2, Parent = SliderDot})
            
            local Dragging = false
            local InputConnection = nil
            
            local function UpdateSlider(input)
                if not SliderTrack or not SliderTrack.Parent then return end
                
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
                Tween(SliderDot, {Position = UDim2.new(percentage, -7, 0.5, -7)}, 0.1)
                
                SavedConfig[Flag] = value
                SaveConfig()
                Callback(value)
            end
            
            SliderTrack.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    Dragging = true
                    UpdateSlider(input)
                    Tween(SliderDot, {Size = UDim2.new(0, 18, 0, 18)}, 0.1)
                end
            end)
            
            SliderTrack.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    Dragging = false
                    Tween(SliderDot, {Size = UDim2.new(0, 14, 0, 14)}, 0.1)
                end
            end)
            
            -- FIXED: Proper input handling
            if InputConnection then InputConnection:Disconnect() end
            InputConnection = UserInputService.InputChanged:Connect(function(input)
                if Dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                    UpdateSlider(input)
                end
            end)
            
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    Dragging = false
                    if SliderDot and SliderDot.Parent then
                        Tween(SliderDot, {Size = UDim2.new(0, 14, 0, 14)}, 0.1)
                    end
                end
            end)
            
            SliderFrame.MouseEnter:Connect(function()
                Tween(SliderFrame, {BackgroundColor3 = Theme.ElementHover}, 0.15)
            end)
            
            SliderFrame.MouseLeave:Connect(function()
                Tween(SliderFrame, {BackgroundColor3 = Theme.Element}, 0.15)
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
            
            if type(CurrentOption) ~= "table" then
                CurrentOption = {CurrentOption}
            end
            
            local DropdownFrame = Create("Frame", {
                Size = UDim2.new(1, 0, 0, 42),
                BackgroundColor3 = Theme.Element,
                BorderSizePixel = 0,
                ClipsDescendants = false,
                ZIndex = 4,
                Parent = TabContent
            })
            
            Create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = DropdownFrame})
            Create("UIStroke", {Color = Theme.Border, Thickness = 1, Transparency = 0.5, Parent = DropdownFrame})
            AddGradient(DropdownFrame, Theme.Element, Theme.Content, 90)
            
            local DropdownButton = Create("TextButton", {
                Size = UDim2.new(1, 0, 0, 42),
                BackgroundTransparency = 1,
                Text = "",
                AutoButtonColor = false,
                ZIndex = 5,
                Parent = DropdownFrame
            })
            
            local DropdownLabel = Create("TextLabel", {
                Size = UDim2.new(1, -45, 1, 0),
                Position = UDim2.new(0, 14, 0, 0),
                BackgroundTransparency = 1,
                Text = Name,
                TextColor3 = Theme.Text,
                TextSize = 13,
                Font = Enum.Font.Gotham,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = 6,
                Parent = DropdownButton
            })
            
            local DropdownIcon = Create("TextLabel", {
                Size = UDim2.new(0, 22, 1, 0),
                Position = UDim2.new(1, -32, 0, 0),
                BackgroundTransparency = 1,
                Text = "▼",
                TextColor3 = Theme.Accent,
                TextSize = 11,
                Font = Enum.Font.Gotham,
                ZIndex = 6,
                Parent = DropdownButton
            })
            
            local DropdownList = Create("ScrollingFrame", {
                Size = UDim2.new(1, 0, 0, 0),
                Position = UDim2.new(0, 0, 0, 46),
                BackgroundColor3 = Theme.Content,
                BorderSizePixel = 0,
                ClipsDescendants = true,
                Visible = false,
                ScrollBarThickness = 4,
                ScrollBarImageColor3 = Theme.Accent,
                CanvasSize = UDim2.new(0, 0, 0, 0),
                AutomaticCanvasSize = Enum.AutomaticSize.Y,
                ZIndex = 10,
                Parent = DropdownFrame
            })
            
            Create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = DropdownList})
            Create("UIStroke", {Color = Theme.BorderGlow, Thickness = 2, Parent = DropdownList})
            AddGradient(DropdownList, Theme.Element, Theme.Content, 135)
            
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
                
                local targetHeight = math.min(#Options * 32 + 12, 170)
                local frameSize = Expanded and UDim2.new(1, 0, 0, 46 + targetHeight) or UDim2.new(1, 0, 0, 42)
                
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
                    Size = UDim2.new(1, 0, 0, 30),
                    BackgroundColor3 = Theme.Element,
                    Text = "",
                    AutoButtonColor = false,
                    ZIndex = 11,
                    Parent = DropdownList
                })
                
                Create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = OptionButton})
                
                local OptionLabel = Create("TextLabel", {
                    Size = UDim2.new(1, -16, 1, 0),
                    Position = UDim2.new(0, 10, 0, 0),
                    BackgroundTransparency = 1,
                    Text = option,
                    TextColor3 = Theme.TextDim,
                    TextSize = 12,
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
                            AddGradient(OptionButton, Theme.Accent, Theme.AccentDark, 90)
                        end
                    else
                        CurrentOption = {option}
                        for _, btn in ipairs(DropdownList:GetChildren()) do
                            if btn:IsA("TextButton") then
                                btn.BackgroundColor3 = Theme.Element
                                local grad = btn:FindFirstChildOfClass("UIGradient")
                                if grad then grad:Destroy() end
                                local lbl = btn:FindFirstChildOfClass("TextLabel")
                                if lbl then lbl.TextColor3 = Theme.TextDim end
                            end
                        end
                        OptionButton.BackgroundColor3 = Theme.Accent
                        OptionLabel.TextColor3 = Theme.Text
                        AddGradient(OptionButton, Theme.Accent, Theme.AccentDark, 90)
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
                
                if table.find(CurrentOption, option) then
                    OptionButton.BackgroundColor3 = Theme.Accent
                    OptionLabel.TextColor3 = Theme.Text
                    AddGradient(OptionButton, Theme.Accent, Theme.AccentDark, 90)
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
                Size = UDim2.new(1, 0, 0, 42),
                BackgroundColor3 = Theme.Element,
                BorderSizePixel = 0,
                ZIndex = 4,
                Parent = TabContent
            })
            
            Create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = KeybindFrame})
            Create("UIStroke", {Color = Theme.Border, Thickness = 1, Transparency = 0.5, Parent = KeybindFrame})
            AddGradient(KeybindFrame, Theme.Element, Theme.Content, 90)
            
            local KeybindLabel = Create("TextLabel", {
                Size = UDim2.new(1, -95, 1, 0),
                Position = UDim2.new(0, 14, 0, 0),
                BackgroundTransparency = 1,
                Text = Name,
                TextColor3 = Theme.Text,
                TextSize = 13,
                Font = Enum.Font.Gotham,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = 5,
                Parent = KeybindFrame
            })
            
            local KeybindButton = Create("TextButton", {
                Size = UDim2.new(0, 80, 0, 28),
                Position = UDim2.new(1, -88, 0.5, -14),
                BackgroundColor3 = Theme.Content,
                Text = CurrentKeybind,
                TextColor3 = Theme.Text,
                TextSize = 12,
                Font = Enum.Font.GothamBold,
                AutoButtonColor = false,
                ZIndex = 5,
                Parent = KeybindFrame
            })
            
            Create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = KeybindButton})
            Create("UIStroke", {Color = Theme.Border, Thickness = 1, Transparency = 0.5, Parent = KeybindButton})
            
            local Binding = false
            local Connection = nil
            
            KeybindButton.MouseButton1Click:Connect(function()
                if Binding then return end
                Binding = true
                KeybindButton.Text = "..."
                Tween(KeybindButton, {BackgroundColor3 = Theme.Accent}, 0.15)
                AddGradient(KeybindButton, Theme.Accent, Theme.AccentDark, 90)
                
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
                        local grad = KeybindButton:FindFirstChildOfClass("UIGradient")
                        if grad then grad:Destroy() end
                        
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
                Size = UDim2.new(1, 0, 0, 42),
                BackgroundColor3 = Theme.Accent,
                BorderSizePixel = 0,
                ZIndex = 4,
                Parent = TabContent
            })
            
            Create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = ButtonFrame})
            Create("UIStroke", {Color = Theme.AccentLight, Thickness = 1, Transparency = 0, Parent = ButtonFrame})
            AddGradient(ButtonFrame, Theme.Accent, Theme.AccentDark, 90)
            
            local Button = Create("TextButton", {
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                Text = Name,
                TextColor3 = Theme.Text,
                TextSize = 14,
                Font = Enum.Font.GothamBold,
                AutoButtonColor = false,
                ZIndex = 5,
                Parent = ButtonFrame
            })
            
            Button.MouseButton1Click:Connect(function()
                Callback()
                Tween(ButtonFrame, {BackgroundColor3 = Theme.AccentLight}, 0.1)
                task.wait(0.1)
                Tween(ButtonFrame, {BackgroundColor3 = Theme.Accent}, 0.1)
            end)
            
            Button.MouseEnter:Connect(function()
                Tween(ButtonFrame, {BackgroundColor3 = Theme.AccentLight}, 0.15)
            end)
            
            Button.MouseLeave:Connect(function()
                Tween(ButtonFrame, {BackgroundColor3 = Theme.Accent}, 0.15)
            end)
        end
        
        return Tab
    end
    
    -- NOTIFICATION SYSTEM
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
                Size = UDim2.new(0, 340, 1, 0),
                Position = UDim2.new(1, -355, 0, 20),
                BackgroundTransparency = 1,
                ZIndex = 100,
                Parent = ScreenGui
            })
            
            Create("UIListLayout", {
                Padding = UDim.new(0, 12),
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
            ClipsDescendants = false,
            ZIndex = 101,
            Parent = NotifContainer
        })
        
        Create("UICorner", {CornerRadius = UDim.new(0, 10), Parent = Notification})
        Create("UIStroke", {Color = typeColors[Type] or Theme.Accent, Thickness = 2, Transparency = 0, Parent = Notification})
        AddGradient(Notification, Theme.Element, Theme.Content, 135)
        AddGlow(Notification, typeColors[Type] or Theme.Accent, 0.7)
        
        local NotifTitle = Create("TextLabel", {
            Size = UDim2.new(1, -24, 0, 24),
            Position = UDim2.new(0, 12, 0, 12),
            BackgroundTransparency = 1,
            Text = Title,
            TextColor3 = Theme.Text,
            TextSize = 14,
            Font = Enum.Font.GothamBold,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 102,
            Parent = Notification
        })
        
        local NotifContent = Create("TextLabel", {
            Size = UDim2.new(1, -24, 0, 0),
            Position = UDim2.new(0, 12, 0, 36),
            BackgroundTransparency = 1,
            Text = Content,
            TextColor3 = Theme.TextDim,
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
            Vector2.new(305, math.huge)
        )
        
        local finalHeight = 48 + textSize.Y + 12
        NotifContent.Size = UDim2.new(1, -24, 0, textSize.Y)
        
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
