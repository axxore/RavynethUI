-- ╔══════════════════════════════════════════════════════════════╗
-- ║                    RAVYNETH UI LIBRARY                       ║
-- ║              Modern UI with Sidebar Navigation               ║
-- ╚══════════════════════════════════════════════════════════════╝

local RavynethUI = {}
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

-- ✨ CONFIG SYSTEM
local ConfigFolder = "RavynethHub"
local ConfigFile = "Config.json"
local SavedConfig = {}

local function SaveConfig()
    local success, err = pcall(function()
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

-- 🎨 THEME
local Theme = {
    Background = Color3.fromRGB(20, 20, 25),
    Sidebar = Color3.fromRGB(25, 25, 30),
    Content = Color3.fromRGB(30, 30, 35),
    Accent = Color3.fromRGB(138, 43, 226), -- Purple
    AccentHover = Color3.fromRGB(155, 89, 230),
    Text = Color3.fromRGB(255, 255, 255),
    TextDim = Color3.fromRGB(170, 170, 170),
    Border = Color3.fromRGB(40, 40, 45),
    Success = Color3.fromRGB(46, 204, 113),
    Warning = Color3.fromRGB(241, 196, 15),
    Error = Color3.fromRGB(231, 76, 60)
}

-- 🎭 UTILITY FUNCTIONS
local function Tween(object, props, duration)
    duration = duration or 0.3
    local tween = TweenService:Create(object, TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props)
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
    element.Parent = props.Parent
    return element
end

-- 🏗️ MAIN WINDOW CREATION
function RavynethUI:CreateWindow(config)
    config = config or {}
    local WindowName = config.Name or "Ravyneth Hub"
    local ToggleKey = config.ToggleKey or Enum.KeyCode.K
    
    LoadConfig()
    
    local Window = {
        Tabs = {},
        CurrentTab = nil,
        Visible = true
    }
    
    -- 📦 SCREENGU CREATE
    local ScreenGui = CreateElement("ScreenGui", {
        Name = "RavynethUI",
        Parent = PlayerGui,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        ResetOnSpawn = false
    })
    
    -- 🖼️ MAIN FRAME
    local MainFrame = CreateElement("Frame", {
        Name = "MainFrame",
        Size = UDim2.new(0, 700, 0, 500),
        Position = UDim2.new(0.5, -350, 0.5, -250),
        BackgroundColor3 = Theme.Background,
        BorderSizePixel = 0,
        Parent = ScreenGui
    })
    
    CreateElement("UICorner", {
        CornerRadius = UDim.new(0, 12),
        Parent = MainFrame
    })
    
    CreateElement("UIStroke", {
        Color = Theme.Border,
        Thickness = 1,
        Parent = MainFrame
    })
    
    -- 🎯 DRAG SYSTEM
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
            Tween(MainFrame, {
                Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            }, 0.1)
        end
    end)
    
    -- 📋 HEADER
    local Header = CreateElement("Frame", {
        Name = "Header",
        Size = UDim2.new(1, 0, 0, 50),
        BackgroundColor3 = Theme.Sidebar,
        BorderSizePixel = 0,
        Parent = MainFrame
    })
    
    CreateElement("UICorner", {
        CornerRadius = UDim.new(0, 12),
        Parent = Header
    })
    
    local Title = CreateElement("TextLabel", {
        Name = "Title",
        Size = UDim2.new(0, 200, 1, 0),
        Position = UDim2.new(0, 20, 0, 0),
        BackgroundTransparency = 1,
        Text = WindowName,
        TextColor3 = Theme.Text,
        TextSize = 20,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = Header
    })
    
    local CloseButton = CreateElement("TextButton", {
        Name = "CloseButton",
        Size = UDim2.new(0, 40, 0, 40),
        Position = UDim2.new(1, -50, 0, 5),
        BackgroundColor3 = Theme.Content,
        Text = "✕",
        TextColor3 = Theme.Text,
        TextSize = 20,
        Font = Enum.Font.GothamBold,
        Parent = Header
    })
    
    CreateElement("UICorner", {CornerRadius = UDim.new(0, 8), Parent = CloseButton})
    
    CloseButton.MouseButton1Click:Connect(function()
        Window:Toggle()
    end)
    
    CloseButton.MouseEnter:Connect(function()
        Tween(CloseButton, {BackgroundColor3 = Theme.Error})
    end)
    
    CloseButton.MouseLeave:Connect(function()
        Tween(CloseButton, {BackgroundColor3 = Theme.Content})
    end)
    
    -- 📂 SIDEBAR
    local Sidebar = CreateElement("ScrollingFrame", {
        Name = "Sidebar",
        Size = UDim2.new(0, 180, 1, -60),
        Position = UDim2.new(0, 10, 0, 55),
        BackgroundColor3 = Theme.Sidebar,
        BorderSizePixel = 0,
        ScrollBarThickness = 4,
        ScrollBarImageColor3 = Theme.Accent,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Parent = MainFrame
    })
    
    CreateElement("UICorner", {CornerRadius = UDim.new(0, 8), Parent = Sidebar})
    CreateElement("UIListLayout", {
        Padding = UDim.new(0, 5),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = Sidebar
    })
    CreateElement("UIPadding", {
        PaddingTop = UDim.new(0, 5),
        PaddingBottom = UDim.new(0, 5),
        PaddingLeft = UDim.new(0, 5),
        PaddingRight = UDim.new(0, 5),
        Parent = Sidebar
    })
    
    -- 📄 CONTENT AREA
    local ContentContainer = CreateElement("Frame", {
        Name = "ContentContainer",
        Size = UDim2.new(1, -210, 1, -60),
        Position = UDim2.new(0, 200, 0, 55),
        BackgroundColor3 = Theme.Content,
        BorderSizePixel = 0,
        Parent = MainFrame
    })
    
    CreateElement("UICorner", {CornerRadius = UDim.new(0, 8), Parent = ContentContainer})
    
    -- ⌨️ TOGGLE KEY
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if not gameProcessed and input.KeyCode == ToggleKey then
            Window:Toggle()
        end
    end)
    
    -- 🔄 TOGGLE FUNCTION
    function Window:Toggle()
        Window.Visible = not Window.Visible
        Tween(MainFrame, {
            Size = Window.Visible and UDim2.new(0, 700, 0, 500) or UDim2.new(0, 0, 0, 0)
        }, 0.3)
    end
    
    -- 📑 CREATE TAB
    function Window:CreateTab(name, icon)
        icon = icon or "📋"
        
        local Tab = {
            Name = name,
            Elements = {},
            Container = nil
        }
        
        -- 🏷️ TAB BUTTON
        local TabButton = CreateElement("TextButton", {
            Name = name,
            Size = UDim2.new(1, 0, 0, 40),
            BackgroundColor3 = Theme.Content,
            Text = "",
            Parent = Sidebar
        })
        
        CreateElement("UICorner", {CornerRadius = UDim.new(0, 6), Parent = TabButton})
        
        local TabLabel = CreateElement("TextLabel", {
            Size = UDim2.new(1, -10, 1, 0),
            Position = UDim2.new(0, 10, 0, 0),
            BackgroundTransparency = 1,
            Text = name,
            TextColor3 = Theme.TextDim,
            TextSize = 14,
            Font = Enum.Font.Gotham,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = TabButton
        })
        
        -- 📜 SCROLLING CONTENT
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
            Padding = UDim.new(0, 10),
            SortOrder = Enum.SortOrder.LayoutOrder,
            Parent = TabContent
        })
        
        Tab.Container = TabContent
        
        TabButton.MouseButton1Click:Connect(function()
            for _, tab in pairs(Window.Tabs) do
                tab.Container.Visible = false
                tab.Button.BackgroundColor3 = Theme.Content
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
                Tween(TabButton, {BackgroundColor3 = Theme.Content})
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
        
        -- 📌 SECTION
        function Tab:CreateSection(name)
            local SectionLabel = CreateElement("TextLabel", {
                Size = UDim2.new(1, 0, 0, 30),
                BackgroundTransparency = 1,
                Text = name,
                TextColor3 = Theme.Accent,
                TextSize = 16,
                Font = Enum.Font.GothamBold,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = TabContent
            })
            
            CreateElement("UIPadding", {
                PaddingLeft = UDim.new(0, 10),
                Parent = SectionLabel
            })
        end
        
        -- 🏷️ LABEL
        function Tab:CreateLabel(text)
            local LabelFrame = CreateElement("Frame", {
                Size = UDim2.new(1, 0, 0, 30),
                BackgroundTransparency = 1,
                Parent = TabContent
            })
            
            local Label = CreateElement("TextLabel", {
                Size = UDim2.new(1, -10, 1, 0),
                Position = UDim2.new(0, 10, 0, 0),
                BackgroundTransparency = 1,
                Text = text,
                TextColor3 = Theme.TextDim,
                TextSize = 14,
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
        
        -- 🔘 TOGGLE
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
                Size = UDim2.new(1, 0, 0, 40),
                BackgroundColor3 = Theme.Sidebar,
                BorderSizePixel = 0,
                Parent = TabContent
            })
            
            CreateElement("UICorner", {CornerRadius = UDim.new(0, 6), Parent = ToggleFrame})
            
            local ToggleLabel = CreateElement("TextLabel", {
                Size = UDim2.new(1, -60, 1, 0),
                Position = UDim2.new(0, 10, 0, 0),
                BackgroundTransparency = 1,
                Text = Name,
                TextColor3 = Theme.Text,
                TextSize = 14,
                Font = Enum.Font.Gotham,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = ToggleFrame
            })
            
            local ToggleButton = CreateElement("TextButton", {
                Size = UDim2.new(0, 40, 0, 22),
                Position = UDim2.new(1, -50, 0.5, -11),
                BackgroundColor3 = CurrentValue and Theme.Success or Theme.Border,
                Text = "",
                Parent = ToggleFrame
            })
            
            CreateElement("UICorner", {CornerRadius = UDim.new(1, 0), Parent = ToggleButton})
            
            local ToggleCircle = CreateElement("Frame", {
                Size = UDim2.new(0, 18, 0, 18),
                Position = CurrentValue and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9),
                BackgroundColor3 = Theme.Text,
                BorderSizePixel = 0,
                Parent = ToggleButton
            })
            
            CreateElement("UICorner", {CornerRadius = UDim.new(1, 0), Parent = ToggleCircle})
            
            local ToggleObject = {Value = CurrentValue}
            
            local function UpdateToggle()
                Tween(ToggleButton, {BackgroundColor3 = CurrentValue and Theme.Success or Theme.Border})
                Tween(ToggleCircle, {Position = CurrentValue and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)})
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
        
        -- 🎚️ SLIDER
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
                Size = UDim2.new(1, 0, 0, 60),
                BackgroundColor3 = Theme.Sidebar,
                BorderSizePixel = 0,
                Parent = TabContent
            })
            
            CreateElement("UICorner", {CornerRadius = UDim.new(0, 6), Parent = SliderFrame})
            
            local SliderLabel = CreateElement("TextLabel", {
                Size = UDim2.new(1, -70, 0, 20),
                Position = UDim2.new(0, 10, 0, 5),
                BackgroundTransparency = 1,
                Text = Name,
                TextColor3 = Theme.Text,
                TextSize = 14,
                Font = Enum.Font.Gotham,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = SliderFrame
            })
            
            local ValueLabel = CreateElement("TextLabel", {
                Size = UDim2.new(0, 60, 0, 20),
                Position = UDim2.new(1, -70, 0, 5),
                BackgroundTransparency = 1,
                Text = tostring(CurrentValue),
                TextColor3 = Theme.Accent,
                TextSize = 14,
                Font = Enum.Font.GothamBold,
                TextXAlignment = Enum.TextXAlignment.Right,
                Parent = SliderFrame
            })
            
            local SliderTrack = CreateElement("Frame", {
                Size = UDim2.new(1, -20, 0, 6),
                Position = UDim2.new(0, 10, 1, -15),
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
        
        -- 📦 DROPDOWN
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
                Size = UDim2.new(1, 0, 0, 40),
                BackgroundColor3 = Theme.Sidebar,
                BorderSizePixel = 0,
                Parent = TabContent
            })
            
            CreateElement("UICorner", {CornerRadius = UDim.new(0, 6), Parent = DropdownFrame})
            
            local DropdownButton = CreateElement("TextButton", {
                Size = UDim2.new(1, 0, 0, 40),
                BackgroundTransparency = 1,
                Text = "",
                Parent = DropdownFrame
            })
            
            local DropdownLabel = CreateElement("TextLabel", {
                Size = UDim2.new(1, -40, 1, 0),
                Position = UDim2.new(0, 10, 0, 0),
                BackgroundTransparency = 1,
                Text = Name,
                TextColor3 = Theme.Text,
                TextSize = 14,
                Font = Enum.Font.Gotham,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = DropdownButton
            })
            
            local DropdownIcon = CreateElement("TextLabel", {
                Size = UDim2.new(0, 30, 1, 0),
                Position = UDim2.new(1, -40, 0, 0),
                BackgroundTransparency = 1,
                Text = "▼",
                TextColor3 = Theme.TextDim,
                TextSize = 12,
                Font = Enum.Font.Gotham,
                Parent = DropdownButton
            })
            
            local DropdownList = CreateElement("Frame", {
                Size = UDim2.new(1, 0, 0, 0),
                Position = UDim2.new(0, 0, 1, 5),
                BackgroundColor3 = Theme.Content,
                BorderSizePixel = 0,
                ClipsDescendants = true,
                Visible = false,
                Parent = DropdownFrame
            })
            
            CreateElement("UICorner", {CornerRadius = UDim.new(0, 6), Parent = DropdownList})
            CreateElement("UIListLayout", {
                Padding = UDim.new(0, 2),
                Parent = DropdownList
            })
            
            local Expanded = false
            
            DropdownButton.MouseButton1Click:Connect(function()
                Expanded = not Expanded
                DropdownList.Visible = Expanded
                
                local targetSize = Expanded and UDim2.new(1, 0, 0, math.min(#Options * 35, 200)) or UDim2.new(1, 0, 0, 0)
                Tween(DropdownList, {Size = targetSize})
                Tween(DropdownIcon, {Rotation = Expanded and 180 or 0})
                Tween(DropdownFrame, {Size = Expanded and UDim2.new(1, 0, 0, 45 + math.min(#Options * 35, 200)) or UDim2.new(1, 0, 0, 40)}, 0.2)
            end)
            
            for _, option in ipairs(Options) do
                local OptionButton = CreateElement("TextButton", {
                    Size = UDim2.new(1, 0, 0, 33),
                    BackgroundColor3 = Theme.Sidebar,
                    Text = "",
                    Parent = DropdownList
                })
                
                CreateElement("UICorner", {CornerRadius = UDim.new(0, 4), Parent = OptionButton})
                
                local OptionLabel = CreateElement("TextLabel", {
                    Size = UDim2.new(1, -10, 1, 0),
                    Position = UDim2.new(0, 10, 0, 0),
                    BackgroundTransparency = 1,
                    Text = option,
                    TextColor3 = Theme.TextDim,
                    TextSize = 13,
                    Font = Enum.Font.Gotham,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = OptionButton
                })
                
                OptionButton.MouseButton1Click:Connect(function()
                    if MultipleOptions then
                        local found = table.find(CurrentOption, option)
                        if found then
                            table.remove(CurrentOption, found)
                            OptionButton.BackgroundColor3 = Theme.Sidebar
                        else
                            table.insert(CurrentOption, option)
                            OptionButton.BackgroundColor3 = Theme.Accent
                        end
                    else
                        CurrentOption = {option}
                        for _, btn in ipairs(DropdownList:GetChildren()) do
                            if btn:IsA("TextButton") then
                                btn.BackgroundColor3 = Theme.Sidebar
                            end
                        end
                        OptionButton.BackgroundColor3 = Theme.Accent
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
                        Tween(OptionButton, {BackgroundColor3 = Theme.Sidebar})
                    end
                end)
                
                if table.find(CurrentOption, option) then
                    OptionButton.BackgroundColor3 = Theme.Accent
                end
            end
        end
        
        -- 🔑 KEYBIND
        function Tab:CreateKeybind(config)
            config = config or {}
            local Name = config.Name or "Keybind"
            local Flag = config.Flag or Name
            local CurrentKeybind = config.CurrentKeybind or ""
            local Callback = config.Callback or function() end
            
            if SavedConfig[Flag] ~= nil then
                CurrentKeybind = SavedConfig[Flag]
            end
            
            local KeybindFrame = CreateElement("Frame", {
                Size = UDim2.new(1, 0, 0, 40),
                BackgroundColor3 = Theme.Sidebar,
                BorderSizePixel = 0,
                Parent = TabContent
            })
            
            CreateElement("UICorner", {CornerRadius = UDim.new(0, 6), Parent = KeybindFrame})
            
            local KeybindLabel = CreateElement("TextLabel", {
                Size = UDim2.new(1, -100, 1, 0),
                Position = UDim2.new(0, 10, 0, 0),
                BackgroundTransparency = 1,
                Text = Name,
                TextColor3 = Theme.Text,
                TextSize = 14,
                Font = Enum.Font.Gotham,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = KeybindFrame
            })
            
            local KeybindButton = CreateElement("TextButton", {
                Size = UDim2.new(0, 80, 0, 28),
                Position = UDim2.new(1, -90, 0.5, -14),
                BackgroundColor3 = Theme.Content,
                Text = CurrentKeybind ~= "" and CurrentKeybind or "None",
                TextColor3 = Theme.Text,
                TextSize = 13,
                Font = Enum.Font.GothamBold,
                Parent = KeybindFrame
            })
            
            CreateElement("UICorner", {CornerRadius = UDim.new(0, 6), Parent = KeybindButton})
            
            local Binding = false
            
            KeybindButton.MouseButton1Click:Connect(function()
                Binding = true
                KeybindButton.Text = "..."
                
                local connection
                connection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
                    if Binding and input.UserInputType == Enum.UserInputType.Keyboard then
                        local keyName = input.KeyCode.Name
                        CurrentKeybind = keyName
                        KeybindButton.Text = keyName
                        
                        SavedConfig[Flag] = keyName
                        SaveConfig()
                        
                        Binding = false
                        connection:Disconnect()
                    end
                end)
            end)
            
            if CurrentKeybind ~= "" then
                UserInputService.InputBegan:Connect(function(input, gameProcessed)
                    if not gameProcessed and input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode.Name == CurrentKeybind then
                        Callback()
                    end
                end)
            end
        end
        
        -- 🔘 BUTTON
        function Tab:CreateButton(config)
            config = config or {}
            local Name = config.Name or "Button"
            local Callback = config.Callback or function() end
            
            local ButtonFrame = CreateElement("Frame", {
                Size = UDim2.new(1, 0, 0, 40),
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
                TextSize = 14,
                Font = Enum.Font.GothamBold,
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
    
    -- 🔔 NOTIFICATION SYSTEM
    function Window:Notify(config)
        config = config or {}
        local Title = config.Title or "Notification"
        local Content = config.Content or ""
        local Duration = config.Duration or 3
        
        local NotifContainer = ScreenGui:FindFirstChild("NotifContainer") or CreateElement("Frame", {
            Name = "NotifContainer",
            Size = UDim2.new(0, 300, 1, 0),
            Position = UDim2.new(1, -310, 0, 10),
            BackgroundTransparency = 1,
            Parent = ScreenGui
        })
        
        CreateElement("UIListLayout", {
            Padding = UDim.new(0, 10),
            SortOrder = Enum.SortOrder.LayoutOrder,
            Parent = NotifContainer
        })
        
        local Notification = CreateElement("Frame", {
            Size = UDim2.new(1, 0, 0, 80),
            BackgroundColor3 = Theme.Sidebar,
            BorderSizePixel = 0,
            Parent = NotifContainer
        })
        
        CreateElement("UICorner", {CornerRadius = UDim.new(0, 8), Parent = Notification})
        CreateElement("UIStroke", {Color = Theme.Accent, Thickness = 2, Parent = Notification})
        
        local NotifTitle = CreateElement("TextLabel", {
            Size = UDim2.new(1, -20, 0, 25),
            Position = UDim2.new(0, 10, 0, 10),
            BackgroundTransparency = 1,
            Text = Title,
            TextColor3 = Theme.Text,
            TextSize = 15,
            Font = Enum.Font.GothamBold,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = Notification
        })
        
        local NotifContent = CreateElement("TextLabel", {
            Size = UDim2.new(1, -20, 1, -45),
            Position = UDim2.new(0, 10, 0, 35),
            BackgroundTransparency = 1,
            Text = Content,
            TextColor3 = Theme.TextDim,
            TextSize = 13,
            Font = Enum.Font.Gotham,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextWrapped = true,
            Parent = Notification
        })
        
        task.spawn(function()
            task.wait(Duration)
            Tween(Notification, {Size = UDim2.new(1, 0, 0, 0)}, 0.3)
            task.wait(0.3)
            Notification:Destroy()
        end)
    end
    
    return Window
end

return RavynethUI
