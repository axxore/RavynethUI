-- ╔══════════════════════════════════════════════════════════════╗
-- ║                  RAVYNETH UI LIBRARY V2                      ║
-- ║                 Professional & Clean Design                  ║
-- ╚══════════════════════════════════════════════════════════════╝

local RavynethUI = {}
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

-- CONFIG SYSTEM
local ConfigFolder = "RavynethHub"
local ConfigFile = "Config.json"
local SavedConfig = {}

local function SaveConfig()
    local success, err = pcall(function()
        if not isfolder(ConfigFolder) then makefolder(ConfigFolder) end
        writefile(ConfigFolder .. "/" .. ConfigFile, HttpService:JSONEncode(SavedConfig))
    end)
    if not success then
        warn("[Ravyneth UI] Failed to save config:", err)
    end
end

local function LoadConfig()
    if not isfolder(ConfigFolder) then
        makefolder(ConfigFolder)
    end
    
    if isfile(ConfigFolder .. "/" .. ConfigFile) then
        local success, result = pcall(function()
            return HttpService:JSONDecode(readfile(ConfigFolder .. "/" .. ConfigFile))
        end)
        
        if success and type(result) == "table" then
            SavedConfig = result
        end
    end
end

-- THEME (Minimalist & Professional)
local Theme = {
    Background = Color3.fromRGB(15, 15, 18),
    Sidebar = Color3.fromRGB(20, 20, 24),
    Content = Color3.fromRGB(25, 25, 30),
    Element = Color3.fromRGB(30, 30, 36),
    Accent = Color3.fromRGB(120, 80, 200),
    AccentHover = Color3.fromRGB(140, 100, 220),
    Text = Color3.fromRGB(240, 240, 245),
    TextDim = Color3.fromRGB(150, 150, 160),
    Border = Color3.fromRGB(40, 40, 48),
    Success = Color3.fromRGB(50, 200, 100),
    Warning = Color3.fromRGB(255, 180, 0),
    Error = Color3.fromRGB(220, 50, 50)
}

-- UTILITY FUNCTIONS
local function Tween(object, props, duration)
    duration = duration or 0.25
    local tween = TweenService:Create(
        object, 
        TweenInfo.new(duration, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), 
        props
    )
    tween:Play()
    return tween
end

local function CreateElement(class, props)
    local element = Instance.new(class)
    for prop, value in pairs(props) do
        if prop ~= "Parent" then
            element[prop] = value
        end
    end
    if props.Parent then
        element.Parent = props.Parent
    end
    return element
end

-- MAIN WINDOW
function RavynethUI:CreateWindow(config)
    config = config or {}
    local WindowName = config.Name or "Ravyneth Hub"
    local DefaultToggleKey = config.ToggleKey or Enum.KeyCode.RightShift
    
    LoadConfig()
    
    -- Load saved toggle key
    local CurrentToggleKey = SavedConfig.UIToggleKey or DefaultToggleKey
    if type(CurrentToggleKey) == "string" then
        CurrentToggleKey = Enum.KeyCode[CurrentToggleKey] or DefaultToggleKey
    end
    
    local Window = {
        Tabs = {},
        CurrentTab = nil,
        Visible = true,
        Minimized = false,
        ToggleKey = CurrentToggleKey
    }
    
    -- SCREENGUI
    local ScreenGui = CreateElement("ScreenGui", {
        Name = "RavynethUI",
        Parent = PlayerGui,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        ResetOnSpawn = false
    })
    
    -- MAIN FRAME
    local MainFrame = CreateElement("Frame", {
        Name = "MainFrame",
        Size = UDim2.new(0, 750, 0, 520),
        Position = UDim2.new(0.5, -375, 0.5, -260),
        BackgroundColor3 = Theme.Background,
        BorderSizePixel = 0,
        Parent = ScreenGui
    })
    
    CreateElement("UICorner", {CornerRadius = UDim.new(0, 10), Parent = MainFrame})
    CreateElement("UIStroke", {Color = Theme.Border, Thickness = 1.5, Parent = MainFrame})
    
    -- SHADOW EFFECT
    local Shadow = CreateElement("ImageLabel", {
        Name = "Shadow",
        Size = UDim2.new(1, 40, 1, 40),
        Position = UDim2.new(0, -20, 0, -20),
        BackgroundTransparency = 1,
        Image = "rbxassetid://5554236805",
        ImageColor3 = Color3.fromRGB(0, 0, 0),
        ImageTransparency = 0.5,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(23, 23, 277, 277),
        ZIndex = 0,
        Parent = MainFrame
    })
    
    -- DRAG SYSTEM
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
    
    -- HEADER
    local Header = CreateElement("Frame", {
        Name = "Header",
        Size = UDim2.new(1, 0, 0, 45),
        BackgroundColor3 = Theme.Sidebar,
        BorderSizePixel = 0,
        Parent = MainFrame
    })
    
    CreateElement("UICorner", {CornerRadius = UDim.new(0, 10), Parent = Header})
    
    -- Fix corner overlap
    local HeaderCoverBottom = CreateElement("Frame", {
        Size = UDim2.new(1, 0, 0, 10),
        Position = UDim2.new(0, 0, 1, -10),
        BackgroundColor3 = Theme.Sidebar,
        BorderSizePixel = 0,
        Parent = Header
    })
    
    local Title = CreateElement("TextLabel", {
        Name = "Title",
        Size = UDim2.new(0, 250, 1, 0),
        Position = UDim2.new(0, 15, 0, 0),
        BackgroundTransparency = 1,
        Text = WindowName,
        TextColor3 = Theme.Text,
        TextSize = 16,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = Header
    })
    
    -- MINIMIZE BUTTON
    local MinimizeButton = CreateElement("TextButton", {
        Name = "MinimizeButton",
        Size = UDim2.new(0, 35, 0, 35),
        Position = UDim2.new(1, -85, 0, 5),
        BackgroundColor3 = Theme.Element,
        Text = "—",
        TextColor3 = Theme.Text,
        TextSize = 18,
        Font = Enum.Font.GothamBold,
        Parent = Header
    })
    
    CreateElement("UICorner", {CornerRadius = UDim.new(0, 6), Parent = MinimizeButton})
    
    -- CLOSE BUTTON
    local CloseButton = CreateElement("TextButton", {
        Name = "CloseButton",
        Size = UDim2.new(0, 35, 0, 35),
        Position = UDim2.new(1, -45, 0, 5),
        BackgroundColor3 = Theme.Element,
        Text = "✕",
        TextColor3 = Theme.Text,
        TextSize = 16,
        Font = Enum.Font.GothamBold,
        Parent = Header
    })
    
    CreateElement("UICorner", {CornerRadius = UDim.new(0, 6), Parent = CloseButton})
    
    CloseButton.MouseButton1Click:Connect(function()
        Window:Destroy()
    end)
    
    CloseButton.MouseEnter:Connect(function()
        Tween(CloseButton, {BackgroundColor3 = Theme.Error})
    end)
    
    CloseButton.MouseLeave:Connect(function()
        Tween(CloseButton, {BackgroundColor3 = Theme.Element})
    end)
    
    MinimizeButton.MouseButton1Click:Connect(function()
        Window:Minimize()
    end)
    
    MinimizeButton.MouseEnter:Connect(function()
        Tween(MinimizeButton, {BackgroundColor3 = Theme.Border})
    end)
    
    MinimizeButton.MouseLeave:Connect(function()
        Tween(MinimizeButton, {BackgroundColor3 = Theme.Element})
    end)
    
    -- SIDEBAR
    local Sidebar = CreateElement("ScrollingFrame", {
        Name = "Sidebar",
        Size = UDim2.new(0, 160, 1, -55),
        Position = UDim2.new(0, 10, 0, 50),
        BackgroundColor3 = Theme.Sidebar,
        BorderSizePixel = 0,
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = Theme.Accent,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Parent = MainFrame
    })
    
    CreateElement("UICorner", {CornerRadius = UDim.new(0, 8), Parent = Sidebar})
    CreateElement("UIListLayout", {
        Padding = UDim.new(0, 6),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = Sidebar
    })
    CreateElement("UIPadding", {
        PaddingTop = UDim.new(0, 8),
        PaddingBottom = UDim.new(0, 8),
        PaddingLeft = UDim.new(0, 8),
        PaddingRight = UDim.new(0, 8),
        Parent = Sidebar
    })
    
    -- CONTENT CONTAINER
    local ContentContainer = CreateElement("Frame", {
        Name = "ContentContainer",
        Size = UDim2.new(1, -190, 1, -55),
        Position = UDim2.new(0, 180, 0, 50),
        BackgroundColor3 = Theme.Content,
        BorderSizePixel = 0,
        Parent = MainFrame
    })
    
    CreateElement("UICorner", {CornerRadius = UDim.new(0, 8), Parent = ContentContainer})
    
    -- TOGGLE KEY LISTENER
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if not gameProcessed and input.KeyCode == Window.ToggleKey then
            Window:Toggle()
        end
    end)
    
    -- FUNCTIONS
    function Window:Toggle()
        Window.Visible = not Window.Visible
        if Window.Visible then
            MainFrame.Visible = true
            Tween(MainFrame, {Size = UDim2.new(0, 750, 0, 520)}, 0.25)
        else
            Tween(MainFrame, {Size = UDim2.new(0, 0, 0, 0)}, 0.25)
            task.wait(0.25)
            MainFrame.Visible = false
        end
    end
    
    function Window:Minimize()
        Window.Minimized = not Window.Minimized
        if Window.Minimized then
            Tween(MainFrame, {Size = UDim2.new(0, 750, 0, 45)}, 0.25)
            Sidebar.Visible = false
            ContentContainer.Visible = false
        else
            Tween(MainFrame, {Size = UDim2.new(0, 750, 0, 520)}, 0.25)
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
    
    -- CREATE TAB
    function Window:CreateTab(name)
        local Tab = {
            Name = name,
            Elements = {},
            Container = nil
        }
        
        -- TAB BUTTON
        local TabButton = CreateElement("TextButton", {
            Name = name,
            Size = UDim2.new(1, 0, 0, 38),
            BackgroundColor3 = Theme.Element,
            Text = "",
            AutoButtonColor = false,
            Parent = Sidebar
        })
        
        CreateElement("UICorner", {CornerRadius = UDim.new(0, 6), Parent = TabButton})
        
        local TabLabel = CreateElement("TextLabel", {
            Size = UDim2.new(1, -20, 1, 0),
            Position = UDim2.new(0, 10, 0, 0),
            BackgroundTransparency = 1,
            Text = name,
            TextColor3 = Theme.TextDim,
            TextSize = 14,
            Font = Enum.Font.Gotham,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = TabButton
        })
        
        -- TAB CONTENT
        local TabContent = CreateElement("ScrollingFrame", {
            Name = name .. "Content",
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
        
        CreateElement("UIListLayout", {
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
        
        TabButton.MouseEnter:Connect(function()
            if Window.CurrentTab ~= Tab then
                Tween(TabButton, {BackgroundColor3 = Theme.Border})
            end
        end)
        
        TabButton.MouseLeave:Connect(function()
            if Window.CurrentTab ~= Tab then
                Tween(TabButton, {BackgroundColor3 = Theme.Element})
            end
        end)
        
        Tab.Button = TabButton
        Tab.Label = TabLabel
        
        table.insert(Window.Tabs, Tab)
        
        if not Window.CurrentTab then
            TabButton.BackgroundColor3 = Theme.Accent
            TabLabel.TextColor3 = Theme.Text
            TabContent.Visible = true
            Window.CurrentTab = Tab
        end
        
        -- SECTION
        function Tab:CreateSection(name)
            local SectionLabel = CreateElement("TextLabel", {
                Size = UDim2.new(1, 0, 0, 28),
                BackgroundTransparency = 1,
                Text = name,
                TextColor3 = Theme.Accent,
                TextSize = 15,
                Font = Enum.Font.GothamBold,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = TabContent
            })
            
            CreateElement("UIPadding", {
                PaddingLeft = UDim.new(0, 8),
                Parent = SectionLabel
            })
        end
        
        -- LABEL
        function Tab:CreateLabel(text)
            local LabelFrame = CreateElement("Frame", {
                Size = UDim2.new(1, 0, 0, 28),
                BackgroundTransparency = 1,
                Parent = TabContent
            })
            
            local Label = CreateElement("TextLabel", {
                Size = UDim2.new(1, -16, 1, 0),
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
                Label.Text = newText
            end
            
            return LabelObject
        end
        
        -- TOGGLE
        function Tab:CreateToggle(config)
            config = config or {}
            local Name = config.Name or "Toggle"
            local Flag = config.Flag or Name
            local CurrentValue = config.CurrentValue or false
            local Callback = config.Callback or function() end
            
            if SavedConfig[Flag] ~= nil then
                CurrentValue = SavedConfig[Flag]
            end
            
            local ToggleFrame = CreateElement("Frame", {
                Size = UDim2.new(1, 0, 0, 38),
                BackgroundColor3 = Theme.Element,
                BorderSizePixel = 0,
                Parent = TabContent
            })
            
            CreateElement("UICorner", {CornerRadius = UDim.new(0, 6), Parent = ToggleFrame})
            
            local ToggleLabel = CreateElement("TextLabel", {
                Size = UDim2.new(1, -55, 1, 0),
                Position = UDim2.new(0, 10, 0, 0),
                BackgroundTransparency = 1,
                Text = Name,
                TextColor3 = Theme.Text,
                TextSize = 13,
                Font = Enum.Font.Gotham,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = ToggleFrame
            })
            
            local ToggleButton = CreateElement("TextButton", {
                Size = UDim2.new(0, 38, 0, 20),
                Position = UDim2.new(1, -45, 0.5, -10),
                BackgroundColor3 = CurrentValue and Theme.Success or Theme.Border,
                Text = "",
                AutoButtonColor = false,
                Parent = ToggleFrame
            })
            
            CreateElement("UICorner", {CornerRadius = UDim.new(1, 0), Parent = ToggleButton})
            
            local ToggleCircle = CreateElement("Frame", {
                Size = UDim2.new(0, 16, 0, 16),
                Position = CurrentValue and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8),
                BackgroundColor3 = Theme.Text,
                BorderSizePixel = 0,
                Parent = ToggleButton
            })
            
            CreateElement("UICorner", {CornerRadius = UDim.new(1, 0), Parent = ToggleCircle})
            
            local ToggleObject = {Value = CurrentValue}
            
            local function UpdateToggle()
                Tween(ToggleButton, {BackgroundColor3 = CurrentValue and Theme.Success or Theme.Border})
                Tween(ToggleCircle, {Position = CurrentValue and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)})
                SavedConfig[Flag] = CurrentValue
                SaveConfig()
                Callback(CurrentValue)
            end
            
            ToggleButton.MouseButton1Click:Connect(function()
                CurrentValue = not CurrentValue
                ToggleObject.Value = CurrentValue
                UpdateToggle()
            end)
            
            function ToggleObject:Set(value)
                CurrentValue = value
                ToggleObject.Value = value
                UpdateToggle()
            end
            
            UpdateToggle()
            
            return ToggleObject
        end
        
        -- SLIDER
        function Tab:CreateSlider(config)
            config = config or {}
            local Name = config.Name or "Slider"
            local Flag = config.Flag or Name
            local Range = config.Range or {0, 100}
            local Increment = config.Increment or 1
            local CurrentValue = config.CurrentValue or Range[1]
            local Callback = config.Callback or function() end
            
            if SavedConfig[Flag] ~= nil then
                CurrentValue = SavedConfig[Flag]
            end
            
            local SliderFrame = CreateElement("Frame", {
                Size = UDim2.new(1, 0, 0, 55),
                BackgroundColor3 = Theme.Element,
                BorderSizePixel = 0,
                Parent = TabContent
            })
            
            CreateElement("UICorner", {CornerRadius = UDim.new(0, 6), Parent = SliderFrame})
            
            local SliderLabel = CreateElement("TextLabel", {
                Size = UDim2.new(1, -65, 0, 18),
                Position = UDim2.new(0, 10, 0, 6),
                BackgroundTransparency = 1,
                Text = Name,
                TextColor3 = Theme.Text,
                TextSize = 13,
                Font = Enum.Font.Gotham,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = SliderFrame
            })
            
            local ValueLabel = CreateElement("TextLabel", {
                Size = UDim2.new(0, 55, 0, 18),
                Position = UDim2.new(1, -65, 0, 6),
                BackgroundTransparency = 1,
                Text = tostring(CurrentValue),
                TextColor3 = Theme.Accent,
                TextSize = 13,
                Font = Enum.Font.GothamBold,
                TextXAlignment = Enum.TextXAlignment.Right,
                Parent = SliderFrame
            })
            
            local SliderTrack = CreateElement("Frame", {
                Size = UDim2.new(1, -20, 0, 5),
                Position = UDim2.new(0, 10, 1, -14),
                BackgroundColor3 = Theme.Border,
                BorderSizePixel = 0,
                Parent = SliderFrame
            })
            
            CreateElement("UICorner", {CornerRadius = UDim.new(1, 0), Parent = SliderTrack})
            
            local SliderFill = CreateElement("Frame", {
                Size = UDim2.new((CurrentValue - Range[1]) / (Range[2] - Range[1]), 0, 1, 0),
                BackgroundColor3 = Theme.Accent,
                BorderSizePixel = 0,
                Parent = SliderTrack
            })
            
            CreateElement("UICorner", {CornerRadius = UDim.new(1, 0), Parent = SliderFill})
            
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
                ValueLabel.Text = tostring(value)
                Tween(SliderFill, {Size = UDim2.new(percentage, 0, 1, 0)}, 0.1)
                
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
            
            SliderTrack.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    Dragging = false
                end
            end)
            
            UserInputService.InputChanged:Connect(function(input)
                if Dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                    UpdateSlider(input)
                end
            end)
        end
        
        -- DROPDOWN (FIXED!)
        function Tab:CreateDropdown(config)
            config = config or {}
            local Name = config.Name or "Dropdown"
            local Flag = config.Flag or Name
            local Options = config.Options or {}
            local MultipleOptions = config.MultipleOptions or false
            local CurrentOption = config.CurrentOption or {}
            local Callback = config.Callback or function() end
            
            if SavedConfig[Flag] ~= nil then
                CurrentOption = SavedConfig[Flag]
            end
            
            local DropdownFrame = CreateElement("Frame", {
                Size = UDim2.new(1, 0, 0, 38),
                BackgroundColor3 = Theme.Element,
                BorderSizePixel = 0,
                Parent = TabContent
            })
            
            CreateElement("UICorner", {CornerRadius = UDim.new(0, 6), Parent = DropdownFrame})
            
            local DropdownButton = CreateElement("TextButton", {
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                Text = "",
                AutoButtonColor = false,
                Parent = DropdownFrame
            })
            
            local DropdownLabel = CreateElement("TextLabel", {
                Size = UDim2.new(1, -35, 1, 0),
                Position = UDim2.new(0, 10, 0, 0),
                BackgroundTransparency = 1,
                Text = Name,
                TextColor3 = Theme.Text,
                TextSize = 13,
                Font = Enum.Font.Gotham,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = DropdownButton
            })
            
            local DropdownIcon = CreateElement("TextLabel", {
                Size = UDim2.new(0, 25, 1, 0),
                Position = UDim2.new(1, -30, 0, 0),
                BackgroundTransparency = 1,
                Text = "▼",
                TextColor3 = Theme.TextDim,
                TextSize = 11,
                Font = Enum.Font.Gotham,
                Parent = DropdownButton
            })
            
            local DropdownList = CreateElement("ScrollingFrame", {
                Size = UDim2.new(1, 0, 0, 0),
                Position = UDim2.new(0, 0, 1, 4),
                BackgroundColor3 = Theme.Content,
                BorderSizePixel = 0,
                ClipsDescendants = true,
                Visible = false,
                ScrollBarThickness = 3,
                ScrollBarImageColor3 = Theme.Accent,
                CanvasSize = UDim2.new(0, 0, 0, 0),
                AutomaticCanvasSize = Enum.AutomaticSize.Y,
                Parent = DropdownFrame
            })
            
            CreateElement("UICorner", {CornerRadius = UDim.new(0, 6), Parent = DropdownList})
            CreateElement("UIListLayout", {
                Padding = UDim.new(0, 2),
                Parent = DropdownList
            })
            CreateElement("UIPadding", {
                PaddingTop = UDim.new(0, 4),
                PaddingBottom = UDim.new(0, 4),
                PaddingLeft = UDim.new(0, 4),
                PaddingRight = UDim.new(0, 4),
                Parent = DropdownList
            })
            
            local Expanded = false
            
            DropdownButton.MouseButton1Click:Connect(function()
                Expanded = not Expanded
                DropdownList.Visible = Expanded
                
                local targetHeight = math.min(#Options * 30 + 8, 160)
                local targetSize = Expanded and UDim2.new(1, 0, 0, targetHeight) or UDim2.new(1, 0, 0, 0)
                Tween(DropdownList, {Size = targetSize}, 0.2)
                Tween(DropdownIcon, {Rotation = Expanded and 180 or 0}, 0.2)
                Tween(DropdownFrame, {
                    Size = Expanded and UDim2.new(1, 0, 0, 42 + targetHeight) or UDim2.new(1, 0, 0, 38)
                }, 0.2)
            end)
            
            for _, option in ipairs(Options) do
                local OptionButton = CreateElement("TextButton", {
                    Size = UDim2.new(1, 0, 0, 28),
                    BackgroundColor3 = Theme.Element,
                    Text = "",
                    AutoButtonColor = false,
                    Parent = DropdownList
                })
                
                CreateElement("UICorner", {CornerRadius = UDim.new(0, 4), Parent = OptionButton})
                
                local OptionLabel = CreateElement("TextLabel", {
                    Size = UDim2.new(1, -16, 1, 0),
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
                        Tween(OptionButton, {BackgroundColor3 = Theme.Border})
                    end
                end)
                
                OptionButton.MouseLeave:Connect(function()
                    if not table.find(CurrentOption, option) then
                        Tween(OptionButton, {BackgroundColor3 = Theme.Element})
                    end
                end)
                
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
            local CurrentKeybind = config.CurrentKeybind or "None"
            local Callback = config.Callback or function() end
            
            if SavedConfig[Flag] ~= nil then
                CurrentKeybind = SavedConfig[Flag]
            end
            
            local KeybindFrame = CreateElement("Frame", {
                Size = UDim2.new(1, 0, 0, 38),
                BackgroundColor3 = Theme.Element,
                BorderSizePixel = 0,
                Parent = TabContent
            })
            
            CreateElement("UICorner", {CornerRadius = UDim.new(0, 6), Parent = KeybindFrame})
            
            local KeybindLabel = CreateElement("TextLabel", {
                Size = UDim2.new(1, -90, 1, 0),
                Position = UDim2.new(0, 10, 0, 0),
                BackgroundTransparency = 1,
                Text = Name,
                TextColor3 = Theme.Text,
                TextSize = 13,
                Font = Enum.Font.Gotham,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = KeybindFrame
            })
            
            local KeybindButton = CreateElement("TextButton", {
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
            
            CreateElement("UICorner", {CornerRadius = UDim.new(0, 5), Parent = KeybindButton})
            
            local Binding = false
            local CurrentConnection = nil
            
            KeybindButton.MouseButton1Click:Connect(function()
                Binding = true
                KeybindButton.Text = "..."
                
                if CurrentConnection then
                    CurrentConnection:Disconnect()
                end
                
                CurrentConnection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
                    if Binding and input.UserInputType == Enum.UserInputType.Keyboard then
                        local keyName = input.KeyCode.Name
                        CurrentKeybind = keyName
                        KeybindButton.Text = keyName
                        
                        SavedConfig[Flag] = keyName
                        SaveConfig()
                        
                        Binding = false
                        if CurrentConnection then
                            CurrentConnection:Disconnect()
                            CurrentConnection = nil
                        end
                    end
                end)
            end)
            
            -- Setup callback listener
            if CurrentKeybind ~= "None" and CurrentKeybind ~= "" then
                local keyCode = Enum.KeyCode[CurrentKeybind]
                if keyCode then
                    UserInputService.InputBegan:Connect(function(input, gameProcessed)
                        if not gameProcessed and input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == keyCode then
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
            
            local ButtonFrame = CreateElement("Frame", {
                Size = UDim2.new(1, 0, 0, 38),
                BackgroundColor3 = Theme.Accent,
                BorderSizePixel = 0,
                Parent = TabContent
            })
            
            CreateElement("UICorner", {CornerRadius = UDim.new(0, 6), Parent = ButtonFrame})
            
            local Button = CreateElement("TextButton", {
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
                Tween(ButtonFrame, {BackgroundColor3 = Theme.AccentHover})
            end)
            
            Button.MouseLeave:Connect(function()
                Tween(ButtonFrame, {BackgroundColor3 = Theme.Accent})
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
        
        local NotifContainer = ScreenGui:FindFirstChild("NotifContainer")
        if not NotifContainer then
            NotifContainer = CreateElement("Frame", {
                Name = "NotifContainer",
                Size = UDim2.new(0, 280, 1, 0),
                Position = UDim2.new(1, -290, 0, 10),
                BackgroundTransparency = 1,
                Parent = ScreenGui
            })
            
            CreateElement("UIListLayout", {
                Padding = UDim.new(0, 8),
                SortOrder = Enum.SortOrder.LayoutOrder,
                VerticalAlignment = Enum.VerticalAlignment.Top,
                Parent = NotifContainer
            })
        end
        
        local Notification = CreateElement("Frame", {
            Size = UDim2.new(1, 0, 0, 75),
            BackgroundColor3 = Theme.Element,
            BorderSizePixel = 0,
            Parent = NotifContainer
        })
        
        CreateElement("UICorner", {CornerRadius = UDim.new(0, 8), Parent = Notification})
        CreateElement("UIStroke", {Color = Theme.Accent, Thickness = 1.5, Parent = Notification})
        
        local NotifTitle = CreateElement("TextLabel", {
            Size = UDim2.new(1, -20, 0, 22),
            Position = UDim2.new(0, 10, 0, 8),
            BackgroundTransparency = 1,
            Text = Title,
            TextColor3 = Theme.Text,
            TextSize = 14,
            Font = Enum.Font.GothamBold,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = Notification
        })
        
        local NotifContent = CreateElement("TextLabel", {
            Size = UDim2.new(1, -20, 1, -38),
            Position = UDim2.new(0, 10, 0, 30),
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
