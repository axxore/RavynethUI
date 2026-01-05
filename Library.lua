-- ╔══════════════════════════════════════════════════════════════╗
-- ║    RAVYNETH HUB V13 - FINAL PERFECT (100% WORKING)          ║
-- ╚══════════════════════════════════════════════════════════════╝

local RavynethUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/axxore/RavynethUI/refs/heads/main/Library.lua"))()

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualInputManager = game:GetService("VirtualInputManager")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- Variables
local RemoteFunction = ReplicatedStorage:WaitForChild("Files"):WaitForChild("Framework"):WaitForChild("Network"):WaitForChild("RemoteFunction")

-- Create Window
local Window = RavynethUI:CreateWindow({
    Name = "Ravyneth Hub",
    ToggleKey = Enum.KeyCode.RightShift,
    LogoUrl = "https://github.com/axxore/RavynethUI/blob/main/logo.png?raw=true"
})

Window:Notify({
    Title = "Ravyneth Hub",
    Content = "Successfully loaded!",
    Duration = 4,
    Type = "success"
})

-- ═══════════════════════════════════════════════════════════════
--                          AUTO MISSION TAB
-- ═══════════════════════════════════════════════════════════════

local AutoMissionTab = Window:CreateTab("Auto Mission")

local CONDITIONS = {"Stifle", "Blind Path", "Contract Lock", "Flawless", "Bloodlust"}
local ALL_CHECKPOINTS = {
    {location = "Residential Area", checkpoint = 1, pos = CFrame.new(-1654.05, 0.81, -625.36)},
    {location = "Commercial District", checkpoint = 1, pos = CFrame.new(-1021.71, 0.87, -682.80)},
    {location = "Outskirts", checkpoint = 1, pos = CFrame.new(463.06, 0.81, -1474.03)},
    {location = "Residential Area", checkpoint = 2, pos = CFrame.new(-2821.05, 4.01, -683.34)},
    {location = "Commercial District", checkpoint = 2, pos = CFrame.new(112.80, 2.87, -744.88)},
    {location = "Outskirts", checkpoint = 2, pos = CFrame.new(-502.26, 4.31, -918.68)}
}
local MAIN_BUILDING_POS = CFrame.new(-894.43, 469.94, 752.55)

local selectedCondition = nil
local autoFarmEnabled = false
local AutoFlyForFarm = false

AutoMissionTab:CreateSection("Mission Settings")

AutoMissionTab:CreateDropdown({
    Name = "Select Condition",
    Flag = "MissionCondition",
    Options = CONDITIONS,
    CurrentOption = Window:GetConfig("MissionCondition") or {},
    MultipleOptions = false,
    Callback = function(option)
        selectedCondition = option
        Window:SaveConfig("MissionCondition", option)
    end
})

task.spawn(function()
    task.wait(0.5)
    local savedCondition = Window:GetConfig("MissionCondition")
    if savedCondition and type(savedCondition) == "string" then
        selectedCondition = savedCondition
    end
end)

AutoMissionTab:CreateSection("Auto Farm")

local FarmStatusLabel = AutoMissionTab:CreateLabel("Status: Stopped")

local function teleportTo(position)
    local character = player.Character
    if not character then return false end
    local hrp = character:FindFirstChild('HumanoidRootPart')
    if not hrp or not hrp.Parent then return false end
    local success = pcall(function() hrp.CFrame = position end)
    return success
end

local function pressE()
    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
    task.wait(0.1)
    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
end

local function quickCheckpoint(checkpointPos)
    if not player.Character or not player.Character:FindFirstChild('HumanoidRootPart') then return false end
    if not teleportTo(checkpointPos) then return false end
    task.wait(0.7)
    pressE()
    if not teleportTo(MAIN_BUILDING_POS) then return false end
    return true
end

local function runAllCheckpoints()
    local attempts = 0
    while attempts < 20 do
        if player.Character and player.Character:FindFirstChild('HumanoidRootPart') then break end
        attempts = attempts + 1
        task.wait(0.5)
    end
    if not player.Character or not player.Character:FindFirstChild('HumanoidRootPart') then return false end
    task.wait(2)
    
    for i = 1, 3 do
        if not autoFarmEnabled then break end
        local checkpoint = ALL_CHECKPOINTS[i]
        quickCheckpoint(checkpoint.pos)
        task.wait(1)
    end
    task.wait(5)
    
    for i = 4, 6 do
        if not autoFarmEnabled then break end
        local checkpoint = ALL_CHECKPOINTS[i]
        quickCheckpoint(checkpoint.pos)
        task.wait(1)
    end
    
    if player.Character and player.Character:FindFirstChild('HumanoidRootPart') then
        teleportTo(MAIN_BUILDING_POS)
    end
    task.wait(3)
    return true
end

local function getAvailableLocationIDs()
    local success, result = pcall(function()
        return RemoteFunction:InvokeServer("RequestLocationData", {"Cleanup Duty"})
    end)
    
    if not success then return {} end
    
    local locationIDs = {}
    if type(result) == "table" then
        for uuid, locationName in pairs(result) do
            if type(uuid) == "string" and type(locationName) == "string" then
                table.insert(locationIDs, {name = locationName, id = uuid})
            end
        end
    end
    return locationIDs
end

local function createMissionViaRemote()
    if not teleportTo(MAIN_BUILDING_POS) then return false end
    task.wait(2)
    
    local locationIDs = getAvailableLocationIDs()
    if #locationIDs == 0 then return false end
    
    for _, locationData in ipairs(locationIDs) do
        local conditions = {"Recall", selectedCondition}
        
        local success = pcall(function()
            return RemoteFunction:InvokeServer("OverworldMissions", {
                ["Identification"] = locationData.id,
                ["Conditions"] = conditions,
                ["Directive"] = "Cleanup Duty",
                ["Request"] = "Engage"
            })
        end)
        
        if success then
            task.wait(2)
            return true
        end
        task.wait(1)
    end
    return false
end

AutoMissionTab:CreateToggle({
    Name = "Start Auto Farm",
    Flag = "AutoFarmToggle",
    CurrentValue = false,
    Callback = function(value)
        autoFarmEnabled = value
        
        if value then
            if not selectedCondition then
                FarmStatusLabel:Set("Status: ⚠️ Select condition first!")
                Window:Notify({
                    Title = "Error",
                    Content = "Please select a condition first!",
                    Duration = 3,
                    Type = "error"
                })
                autoFarmEnabled = false
                return
            end
            
            FarmStatusLabel:Set("Status: Running - Recall + " .. selectedCondition)
            
            task.spawn(function()
                while autoFarmEnabled do
                    FarmStatusLabel:Set("Status: Creating mission...")
                    local success = createMissionViaRemote()
                    
                    if success then
                        FarmStatusLabel:Set("Status: Mission loaded!")
                        task.wait(2)
                        AutoFlyForFarm = true
                        FarmStatusLabel:Set("Status: Running checkpoints...")
                        runAllCheckpoints()
                        AutoFlyForFarm = false
                        FarmStatusLabel:Set("Status: Completed! Waiting...")
                        task.wait(5)
                    else
                        FarmStatusLabel:Set("Status: Failed, retrying...")
                        task.wait(10)
                    end
                end
                
                AutoFlyForFarm = false
                FarmStatusLabel:Set("Status: Stopped")
            end)
        else
            FarmStatusLabel:Set("Status: Stopped")
        end
    end
})

-- ═══════════════════════════════════════════════════════════════
--                             PLAYER TAB
-- ═══════════════════════════════════════════════════════════════

local PlayerTab = Window:CreateTab("Player")

-- ═══════════════════════════════════════════════════════════════
--                             ESP SYSTEM
-- ═══════════════════════════════════════════════════════════════

PlayerTab:CreateSection("ESP Settings")

local ESPEnabled = false
local ESPObjects = {}
local ESPOptions = {
    Show2DBox = true,
    ShowName = true,
    ShowHealth = true,
    ShowDistance = true,
    ShowOutline = false
}

local function NewDrawing(type, properties)
    local drawing = Drawing.new(type)
    for property, value in pairs(properties) do drawing[property] = value end
    return drawing
end

local function CreateESP(plr)
    if plr == player then return end
    local espLib = {
        Name = NewDrawing("Text", {Size = 13, Center = true, Outline = true, Color = Color3.fromRGB(255, 255, 255), Visible = false}),
        Distance = NewDrawing("Text", {Size = 13, Center = true, Outline = true, Color = Color3.fromRGB(255, 255, 255), Visible = false}),
        Health = NewDrawing("Text", {Size = 13, Center = true, Outline = true, Color = Color3.fromRGB(0, 255, 0), Visible = false}),
        BoxOutline = NewDrawing("Square", {Thickness = 3, Filled = false, Color = Color3.fromRGB(0, 0, 0), Visible = false}),
        Box = NewDrawing("Square", {Thickness = 1, Filled = false, Color = Color3.fromRGB(255, 0, 0), Visible = false}),
        HealthBarOutline = NewDrawing("Line", {Thickness = 3, Color = Color3.fromRGB(0, 0, 0), Visible = false}),
        HealthBar = NewDrawing("Line", {Thickness = 1.5, Color = Color3.fromRGB(0, 255, 0), Visible = false})
    }
    ESPObjects[plr] = espLib
    
    local function UpdateESP()
        local connection
        connection = RunService.RenderStepped:Connect(function()
            if not ESPEnabled or not plr or not plr.Parent then
                for _, obj in pairs(espLib) do obj.Visible = false end
                if not plr or not plr.Parent then connection:Disconnect() end
                return
            end
            
            local character = plr.Character
            if not character or not character:FindFirstChild("HumanoidRootPart") or not character:FindFirstChild("Humanoid") or character.Humanoid.Health <= 0 then
                for _, obj in pairs(espLib) do obj.Visible = false end
                return
            end
            
            local hrp = character.HumanoidRootPart
            local humanoid = character.Humanoid
            local head = character:FindFirstChild("Head")
            local hrpPos, onScreen = camera:WorldToViewportPoint(hrp.Position)
            
            if onScreen then
                local headPos = camera:WorldToViewportPoint(head.Position)
                local legPos = camera:WorldToViewportPoint(hrp.Position - Vector3.new(0, 3, 0))
                local distanceY = math.abs(headPos.Y - legPos.Y)
                local distanceX = distanceY / 2
                
                if ESPOptions.Show2DBox then
                    espLib.BoxOutline.Size = Vector2.new(distanceX, distanceY)
                    espLib.BoxOutline.Position = Vector2.new(hrpPos.X - distanceX/2, headPos.Y)
                    espLib.BoxOutline.Visible = true
                    espLib.Box.Size = Vector2.new(distanceX, distanceY)
                    espLib.Box.Position = Vector2.new(hrpPos.X - distanceX/2, headPos.Y)
                    espLib.Box.Visible = true
                else
                    espLib.BoxOutline.Visible = false
                    espLib.Box.Visible = false
                end
                
                if ESPOptions.ShowName then
                    espLib.Name.Text = plr.Name
                    espLib.Name.Position = Vector2.new(hrpPos.X, headPos.Y - 20)
                    espLib.Name.Visible = true
                else
                    espLib.Name.Visible = false
                end
                
                if ESPOptions.ShowDistance then
                    local dist = math.floor((player.Character.HumanoidRootPart.Position - hrp.Position).Magnitude)
                    espLib.Distance.Text = dist .. "m"
                    espLib.Distance.Position = Vector2.new(hrpPos.X, legPos.Y + 5)
                    espLib.Distance.Visible = true
                else
                    espLib.Distance.Visible = false
                end
                
                if ESPOptions.ShowHealth then
                    local healthPercent = math.floor((humanoid.Health / humanoid.MaxHealth) * 100)
                    espLib.Health.Text = healthPercent .. "%"
                    espLib.Health.Position = Vector2.new(hrpPos.X, legPos.Y + 20)
                    espLib.Health.Color = Color3.fromRGB(255, 0, 0):Lerp(Color3.fromRGB(0, 255, 0), humanoid.Health / humanoid.MaxHealth)
                    espLib.Health.Visible = true
                    
                    local healthBarHeight = distanceY * (humanoid.Health / humanoid.MaxHealth)
                    espLib.HealthBarOutline.From = Vector2.new(hrpPos.X - distanceX/2 - 6, legPos.Y)
                    espLib.HealthBarOutline.To = Vector2.new(hrpPos.X - distanceX/2 - 6, headPos.Y)
                    espLib.HealthBarOutline.Visible = true
                    espLib.HealthBar.From = Vector2.new(hrpPos.X - distanceX/2 - 6, legPos.Y)
                    espLib.HealthBar.To = Vector2.new(hrpPos.X - distanceX/2 - 6, legPos.Y - healthBarHeight)
                    espLib.HealthBar.Color = Color3.fromRGB(255, 0, 0):Lerp(Color3.fromRGB(0, 255, 0), humanoid.Health / humanoid.MaxHealth)
                    espLib.HealthBar.Visible = true
                else
                    espLib.Health.Visible = false
                    espLib.HealthBarOutline.Visible = false
                    espLib.HealthBar.Visible = false
                end
                
                if ESPOptions.ShowOutline then
                    local highlight = character:FindFirstChild("ESPHighlight")
                    if not highlight then
                        highlight = Instance.new("Highlight")
                        highlight.Name = "ESPHighlight"
                        highlight.Adornee = character
                        highlight.FillColor = Color3.fromRGB(255, 0, 0)
                        highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                        highlight.FillTransparency = 0.5
                        highlight.OutlineTransparency = 0
                        highlight.Parent = character
                    end
                else
                    local highlight = character:FindFirstChild("ESPHighlight")
                    if highlight then highlight:Destroy() end
                end
            else
                for _, obj in pairs(espLib) do obj.Visible = false end
            end
        end)
    end
    coroutine.wrap(UpdateESP)()
end

local function InitESP()
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= player then CreateESP(plr) end
    end
    
    Players.PlayerAdded:Connect(function(plr)
        CreateESP(plr)
    end)
    
    Players.PlayerRemoving:Connect(function(plr)
        if ESPObjects[plr] then
            for _, obj in pairs(ESPObjects[plr]) do obj:Remove() end
            ESPObjects[plr] = nil
        end
    end)
end

InitESP()

local ESPToggleRef = PlayerTab:CreateToggle({
    Name = "Enable ESP",
    Flag = "ESPEnabled",
    CurrentValue = false,
    Callback = function(value)
        ESPEnabled = value
        if not value then
            for _, plr in pairs(Players:GetPlayers()) do
                if plr.Character then
                    local highlight = plr.Character:FindFirstChild("ESPHighlight")
                    if highlight then highlight:Destroy() end
                end
            end
        end
    end
})

PlayerTab:CreateKeybind({
    Name = "ESP Keybind",
    Flag = "ESPKeybind",
    CurrentKeybind = "None",
    Callback = function()
        ESPEnabled = not ESPEnabled
        if ESPToggleRef and ESPToggleRef.Set then
            ESPToggleRef:Set(ESPEnabled)
        end
        if not ESPEnabled then
            for _, plr in pairs(Players:GetPlayers()) do
                if plr.Character then
                    local highlight = plr.Character:FindFirstChild("ESPHighlight")
                    if highlight then highlight:Destroy() end
                end
            end
        end
        Window:Notify({
            Title = "ESP",
            Content = ESPEnabled and "Enabled" or "Disabled",
            Duration = 2,
            Type = "info"
        })
    end
})

PlayerTab:CreateDropdown({
    Name = "ESP Visual Options",
    Flag = "ESPVisuals",
    Options = {"2D Box", "Name", "Health", "Distance", "Outline"},
    CurrentOption = {"2D Box", "Name", "Health", "Distance"},
    MultipleOptions = true,
    Callback = function(options)
        ESPOptions.Show2DBox = table.find(options, "2D Box") ~= nil
        ESPOptions.ShowName = table.find(options, "Name") ~= nil
        ESPOptions.ShowHealth = table.find(options, "Health") ~= nil
        ESPOptions.ShowDistance = table.find(options, "Distance") ~= nil
        ESPOptions.ShowOutline = table.find(options, "Outline") ~= nil
    end
})

-- ═══════════════════════════════════════════════════════════════
--                          MOVEMENT SYSTEM
-- ═══════════════════════════════════════════════════════════════

PlayerTab:CreateSection("Movement")

local MovementSpeedEnabled = false
local CustomWalkSpeed = 16
local OriginalWalkSpeed = 16
local SpeedLoopConnection
local WalkSpeedToggleRef

local function UpdateWalkSpeed()
    if SpeedLoopConnection then SpeedLoopConnection:Disconnect() SpeedLoopConnection = nil end
    if MovementSpeedEnabled then
        SpeedLoopConnection = RunService.Heartbeat:Connect(function()
            local character = player.Character
            if character and character:FindFirstChild("Humanoid") then
                if character.Humanoid.WalkSpeed ~= CustomWalkSpeed then
                    character.Humanoid.WalkSpeed = CustomWalkSpeed
                end
            end
        end)
    else
        local character = player.Character
        if character and character:FindFirstChild("Humanoid") then
            character.Humanoid.WalkSpeed = OriginalWalkSpeed
        end
    end
end

player.CharacterAdded:Connect(function(character)
    character:WaitForChild("Humanoid")
    task.wait(0.5)
    if character.Humanoid then OriginalWalkSpeed = character.Humanoid.WalkSpeed end
    UpdateWalkSpeed()
end)

WalkSpeedToggleRef = PlayerTab:CreateToggleSlider({
    Name = "Walk Speed",
    ToggleFlag = "WalkSpeedEnabled",
    SliderFlag = "WalkSpeedValue",
    ToggleValue = false,
    Range = {16, 200},
    Increment = 1,
    SliderValue = 16,
    Suffix = "",
    ToggleCallback = function(value)
        MovementSpeedEnabled = value
        UpdateWalkSpeed()
    end,
    SliderCallback = function(value)
        CustomWalkSpeed = value
        if MovementSpeedEnabled then UpdateWalkSpeed() end
    end
})

task.spawn(function()
    task.wait(1)
    if player.Character and player.Character:FindFirstChild("Humanoid") then
        OriginalWalkSpeed = player.Character.Humanoid.WalkSpeed
    end
end)

PlayerTab:CreateKeybind({
    Name = "Walk Speed Keybind",
    Flag = "WalkSpeedKeybind",
    CurrentKeybind = "None",
    Callback = function()
        MovementSpeedEnabled = not MovementSpeedEnabled
        if WalkSpeedToggleRef and WalkSpeedToggleRef.SetToggle then
            WalkSpeedToggleRef:SetToggle(MovementSpeedEnabled)
        end
        UpdateWalkSpeed()
        Window:Notify({
            Title = "Walk Speed",
            Content = MovementSpeedEnabled and "Enabled" or "Disabled",
            Duration = 2,
            Type = "info"
        })
    end
})

-- FLY
local FlyEnabled = false
local FlySpeed = 50
local FlyConnection, FlyObjectsConnection
local FlyToggleRef

local function StartFly()
    local character = player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end
    local hrp = character.HumanoidRootPart
    local humanoid = character:FindFirstChild("Humanoid")
    
    local function ensureFlyObjects()
        local bodyVelocity = hrp:FindFirstChild("FlyVelocity")
        local bodyGyro = hrp:FindFirstChild("FlyGyro")
        if not bodyVelocity then
            bodyVelocity = Instance.new("BodyVelocity")
            bodyVelocity.Name = "FlyVelocity"
            bodyVelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)
            bodyVelocity.Velocity = Vector3.new(0, 0, 0)
            bodyVelocity.Parent = hrp
        end
        if not bodyGyro then
            bodyGyro = Instance.new("BodyGyro")
            bodyGyro.Name = "FlyGyro"
            bodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
            bodyGyro.P = 9e4
            bodyGyro.CFrame = hrp.CFrame
            bodyGyro.Parent = hrp
        end
        return bodyVelocity, bodyGyro
    end
    
    ensureFlyObjects()
    
    FlyObjectsConnection = hrp.ChildRemoved:Connect(function(child)
        if (FlyEnabled or AutoFlyForFarm) and (child.Name == "FlyVelocity" or child.Name == "FlyGyro") then
            task.wait(0.1)
            ensureFlyObjects()
        end
    end)
    
    FlyConnection = RunService.Heartbeat:Connect(function()
        if not (FlyEnabled or AutoFlyForFarm) then return end
        local bodyVelocity, bodyGyro = ensureFlyObjects()
        
        if AutoFlyForFarm then
            bodyVelocity.Velocity = Vector3.new(0, 0, 0)
            bodyGyro.CFrame = hrp.CFrame
            if humanoid then humanoid.PlatformStand = true end
            return
        end
        
        local cam = camera
        local moveDirection = Vector3.new(0, 0, 0)
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDirection = moveDirection + (cam.CFrame.LookVector * FlySpeed) end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDirection = moveDirection - (cam.CFrame.LookVector * FlySpeed) end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDirection = moveDirection - (cam.CFrame.RightVector * FlySpeed) end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDirection = moveDirection + (cam.CFrame.RightVector * FlySpeed) end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDirection = moveDirection + (Vector3.new(0, 1, 0) * FlySpeed) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then moveDirection = moveDirection - (Vector3.new(0, 1, 0) * FlySpeed) end
        bodyVelocity.Velocity = moveDirection
        bodyGyro.CFrame = cam.CFrame
        if humanoid then humanoid.PlatformStand = true end
    end)
end

local function StopFly()
    if FlyConnection then FlyConnection:Disconnect() FlyConnection = nil end
    if FlyObjectsConnection then FlyObjectsConnection:Disconnect() FlyObjectsConnection = nil end
    local character = player.Character
    if character then
        local hrp = character:FindFirstChild("HumanoidRootPart")
        if hrp then
            local velocity = hrp:FindFirstChild("FlyVelocity")
            local gyro = hrp:FindFirstChild("FlyGyro")
            if velocity then velocity:Destroy() end
            if gyro then gyro:Destroy() end
        end
        local humanoid = character:FindFirstChild("Humanoid")
        if humanoid then humanoid.PlatformStand = false end
    end
end

FlyToggleRef = PlayerTab:CreateToggleSlider({
    Name = "Fly Speed",
    ToggleFlag = "FlyEnabled",
    SliderFlag = "FlySpeedValue",
    ToggleValue = false,
    Range = {10, 200},
    Increment = 5,
    SliderValue = 50,
    Suffix = "",
    ToggleCallback = function(value)
        FlyEnabled = value
        if value then
            StartFly()
        else
            if not AutoFlyForFarm then StopFly() end
        end
    end,
    SliderCallback = function(value)
        FlySpeed = value
    end
})

PlayerTab:CreateKeybind({
    Name = "Fly Keybind",
    Flag = "FlyKeybind",
    CurrentKeybind = "F",
    Callback = function()
        FlyEnabled = not FlyEnabled
        if FlyToggleRef and FlyToggleRef.SetToggle then
            FlyToggleRef:SetToggle(FlyEnabled)
        end
        if FlyEnabled then
            StartFly()
        else
            if not AutoFlyForFarm then StopFly() end
        end
        Window:Notify({
            Title = "Fly",
            Content = FlyEnabled and "Enabled" or "Disabled",
            Duration = 2,
            Type = "info"
        })
    end
})

-- INFINITE JUMP
local InfiniteJumpEnabled = false
local InfiniteJumpConnection
local InfiniteJumpToggleRef

local function UpdateInfiniteJump()
    if InfiniteJumpConnection then
        InfiniteJumpConnection:Disconnect()
        InfiniteJumpConnection = nil
    end
    
    if InfiniteJumpEnabled then
        InfiniteJumpConnection = UserInputService.JumpRequest:Connect(function()
            local character = player.Character
            if character and character:FindFirstChild("Humanoid") then
                character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end)
    end
end

InfiniteJumpToggleRef = PlayerTab:CreateToggle({
    Name = "Infinite Jump",
    Flag = "InfiniteJump",
    CurrentValue = false,
    Callback = function(value)
        InfiniteJumpEnabled = value
        UpdateInfiniteJump()
    end
})

PlayerTab:CreateKeybind({
    Name = "Infinite Jump Keybind",
    Flag = "InfiniteJumpKeybind",
    CurrentKeybind = "None",
    Callback = function()
        InfiniteJumpEnabled = not InfiniteJumpEnabled
        if InfiniteJumpToggleRef and InfiniteJumpToggleRef.Set then
            InfiniteJumpToggleRef:Set(InfiniteJumpEnabled)
        end
        UpdateInfiniteJump()
        Window:Notify({
            Title = "Infinite Jump",
            Content = InfiniteJumpEnabled and "Enabled" or "Disabled",
            Duration = 2,
            Type = "info"
        })
    end
})

-- NOCLIP
local NoClipEnabled = false
local NoClipConnection
local NoClipToggleRef

local function UpdateNoClip()
    if NoClipConnection then NoClipConnection:Disconnect() NoClipConnection = nil end
    if NoClipEnabled then
        NoClipConnection = RunService.Stepped:Connect(function()
            local character = player.Character
            if character then
                for _, part in pairs(character:GetDescendants()) do
                    if part:IsA("BasePart") then part.CanCollide = false end
                end
            end
        end)
    else
        local character = player.Character
        if character then
            for _, part in pairs(character:GetDescendants()) do
                if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                    part.CanCollide = true
                end
            end
        end
    end
end

NoClipToggleRef = PlayerTab:CreateToggle({
    Name = "No Clip",
    Flag = "NoClip",
    CurrentValue = false,
    Callback = function(value)
        NoClipEnabled = value
        UpdateNoClip()
    end
})

PlayerTab:CreateKeybind({
    Name = "No Clip Keybind",
    Flag = "NoClipKeybind",
    CurrentKeybind = "None",
    Callback = function()
        NoClipEnabled = not NoClipEnabled
        if NoClipToggleRef and NoClipToggleRef.Set then
            NoClipToggleRef:Set(NoClipEnabled)
        end
        UpdateNoClip()
        Window:Notify({
            Title = "No Clip",
            Content = NoClipEnabled and "Enabled" or "Disabled",
            Duration = 2,
            Type = "info"
        })
    end
})

-- OTHER
PlayerTab:CreateSection("Other")

PlayerTab:CreateSlider({
    Name = "FOV",
    Flag = "FOV",
    Range = {70, 120},
    Increment = 1,
    CurrentValue = 70,
    Suffix = "°",
    Callback = function(value)
        workspace.CurrentCamera.FieldOfView = value
    end
})

PlayerTab:CreateButton({
    Name = "Reset Character",
    Callback = function()
        player.Character.Humanoid.Health = 0
        Window:Notify({
            Title = "Reset",
            Content = "Character reset!",
            Duration = 2,
            Type = "warning"
        })
    end
})

PlayerTab:CreateButton({
    Name = "Teleport to Random Player",
    Callback = function()
        local players = Players:GetPlayers()
        local randomPlayer = players[math.random(1, #players)]
        if randomPlayer and randomPlayer ~= player and randomPlayer.Character then
            player.Character.HumanoidRootPart.CFrame = randomPlayer.Character.HumanoidRootPart.CFrame
            Window:Notify({
                Title = "Teleport",
                Content = "Teleported to " .. randomPlayer.Name,
                Duration = 2,
                Type = "info"
            })
        end
    end
})

-- ═══════════════════════════════════════════════════════════════
--                             MISC TAB
-- ═══════════════════════════════════════════════════════════════

local MiscTab = Window:CreateTab("Misc")

-- CODE REDEMPTION
MiscTab:CreateSection("Codes")

local CODES = {"10KLIKES", "20KLIKES", "RELEASE2026", "MELO150K"}
local redeemedCodes = {}

local RedeemStatusLabel = MiscTab:CreateLabel("Status: Ready")

local function redeemCode(code)
    local success, result = pcall(function()
        return RemoteFunction:InvokeServer("RedeemCode", {code})
    end)
    return success, result
end

MiscTab:CreateButton({
    Name = "Redeem All Codes",
    Callback = function()
        RedeemStatusLabel:Set("Status: Redeeming codes...")
        
        task.spawn(function()
            local successCount = 0
            
            for _, code in ipairs(CODES) do
                if not table.find(redeemedCodes, code) then
                    local success, result = redeemCode(code)
                    if success then
                        successCount = successCount + 1
                        table.insert(redeemedCodes, code)
                    end
                    task.wait(1.5)
                end
            end
            
            if successCount > 0 then
                RedeemStatusLabel:Set("Status: ✅ " .. successCount .. " codes redeemed!")
                Window:Notify({
                    Title = "Success",
                    Content = successCount .. " codes redeemed!",
                    Duration = 4,
                    Type = "success"
                })
            else
                RedeemStatusLabel:Set("Status: All codes already used")
                Window:Notify({
                    Title = "Info",
                    Content = "All codes already redeemed",
                    Duration = 3,
                    Type = "info"
                })
            end
        end)
    end
})

-- BLACKMARKET (FIXED: ТАЙМЕР ОБНОВЛЯЕТСЯ ЕЖЕСЕКУНДНО!)
MiscTab:CreateSection("Blackmarket")

local BLACKMARKET_ITEMS = {
    {name = "Eye", price = 4000},
    {name = "Arm", price = 8000},
    {name = "Leg", price = 8000},
    {name = "Heart", price = 10000},
    {name = "Common Devil Flesh", price = 20000},
    {name = "Uncommon Devil Flesh", price = 35000},
    {name = "Rare Devil Flesh", price = 50000},
    {name = "AK-47", price = 200000},
    {name = "Epic Devil Flesh", price = 200000},
    {name = "Curse Devil Flesh", price = 200000},
    {name = "Eraser Devil", price = 300000},
    {name = "Wipe Token", price = 400000},
    {name = "Gun Devil Flesh", price = 500000}
}

local function formatPrice(price)
    if price >= 1000000 then
        return string.format("¥%.1fM", price / 1000000)
    elseif price >= 1000 then
        return string.format("¥%dK", price / 1000)
    else
        return string.format("¥%d", price)
    end
end

local blackmarketOptions = {}
for _, item in ipairs(BLACKMARKET_ITEMS) do
    local displayText = string.format("%s | %s", item.name, formatPrice(item.price))
    table.insert(blackmarketOptions, displayText)
end

local selectedBlackmarketItems = {}
local autoBuyEnabled = false

MiscTab:CreateDropdown({
    Name = "Select Items to Auto-Buy",
    Flag = "BlackmarketItems_NOSAVE",
    Options = blackmarketOptions,
    CurrentOption = {},
    MultipleOptions = true,
    Callback = function(options)
        selectedBlackmarketItems = {}
        if type(options) == "table" then
            for _, option in ipairs(options) do
                table.insert(selectedBlackmarketItems, option)
            end
        end
    end
})

-- FIXED: ТАЙМЕР ОБНОВЛЯЕТСЯ ЕЖЕСЕКУНДНО!
local AutoBuyStatusLabel = MiscTab:CreateLabel("Ready | Currency: ¥ Yen only")
local timerUpdateConnection = nil

local function parseSelectedItems(displayTexts)
    local itemNames = {}
    for _, displayText in ipairs(displayTexts) do
        local itemName = displayText:match("^(.-)%s*|")
        if itemName then
            itemName = itemName:match("^%s*(.-)%s*$")
            table.insert(itemNames, itemName)
        end
    end
    return itemNames
end

local function getBlackmarketView()
    local success, result = pcall(function()
        return RemoteFunction:InvokeServer("BM_GetView")
    end)
    
    if success and result and result.items then
        return result
    else
        return nil
    end
end

local function buyBlackmarketItem(itemId)
    local success, result = pcall(function()
        return RemoteFunction:InvokeServer("BM_Buy", {
            ["itemId"] = itemId,
            ["currency"] = "yen"
        })
    end)
    return success, result
end

local function formatTime(seconds)
    if seconds <= 0 then return "0s" end
    local hours = math.floor(seconds / 3600)
    local minutes = math.floor((seconds % 3600) / 60)
    local secs = seconds % 60
    
    if hours > 0 then
        return string.format("%dh %dm %ds", hours, minutes, secs)
    elseif minutes > 0 then
        return string.format("%dm %ds", minutes, secs)
    else
        return string.format("%ds", secs)
    end
end

local function autoBuyLoop()
    while autoBuyEnabled do
        if #selectedBlackmarketItems == 0 then
            AutoBuyStatusLabel:Set("⚠️ No items selected - waiting...")
            task.wait(5)
        else
            local itemNames = parseSelectedItems(selectedBlackmarketItems)
            
            if #itemNames > 0 then
                AutoBuyStatusLabel:Set("🔄 Fetching stock data...")
                
                local view = getBlackmarketView()
                
                if not view or not view.items then
                    AutoBuyStatusLabel:Set("❌ Failed to fetch stock - retrying in 10s...")
                    task.wait(10)
                else
                    local nextRefreshAt = view.nextRefreshAt or 0
                    local serverTime = view.serverTime or os.time()
                    local timeUntilRefresh = math.max(0, nextRefreshAt - serverTime)
                    
                    local totalBought = 0
                    local allOutOfStock = true
                    
                    for _, itemName in ipairs(itemNames) do
                        if not autoBuyEnabled then break end
                        
                        local itemData = view.items[itemName]
                        
                        if itemData then
                            local remaining = itemData.remaining or 0
                            
                            if remaining > 0 then
                                allOutOfStock = false
                                AutoBuyStatusLabel:Set(string.format("🔄 Buying %s (Stock: %d)", itemName, remaining))
                                
                                local boughtCount = 0
                                for i = 1, remaining do
                                    if not autoBuyEnabled then break end
                                    
                                    local success, result = buyBlackmarketItem(itemName)
                                    
                                    if success then
                                        boughtCount = boughtCount + 1
                                        totalBought = totalBought + 1
                                        AutoBuyStatusLabel:Set(string.format("✅ Bought %dx %s (%d/%d)", boughtCount, itemName, i, remaining))
                                    else
                                        break
                                    end
                                    task.wait(0.5)
                                end
                                task.wait(2)
                            end
                        end
                    end
                    
                    if allOutOfStock then
                        -- FIXED: ЗАПУСКАЕМ ТАЙМЕР ОБНОВЛЕНИЯ ЕЖЕСЕКУНДНО!
                        if timerUpdateConnection then timerUpdateConnection:Disconnect() end
                        
                        timerUpdateConnection = RunService.Heartbeat:Connect(function()
                            if not autoBuyEnabled then
                                if timerUpdateConnection then timerUpdateConnection:Disconnect() end
                                return
                            end
                            
                            local currentTime = os.time()
                            local remainingTime = math.max(0, nextRefreshAt - currentTime)
                            
                            if remainingTime > 0 then
                                AutoBuyStatusLabel:Set(string.format("⏳ Out of stock | Refresh in: %s", formatTime(remainingTime)))
                            else
                                if timerUpdateConnection then timerUpdateConnection:Disconnect() end
                                AutoBuyStatusLabel:Set("🔄 Restock available! Checking...")
                            end
                        end)
                        
                        local waitTime = math.max(timeUntilRefresh + 5, 10)
                        task.wait(waitTime)
                        
                        if timerUpdateConnection then
                            timerUpdateConnection:Disconnect()
                            timerUpdateConnection = nil
                        end
                    else
                        AutoBuyStatusLabel:Set(string.format("✅ Bought %d items total | Checking in 5s...", totalBought))
                        task.wait(5)
                    end
                end
            else
                AutoBuyStatusLabel:Set("❌ Failed to parse items - waiting...")
                task.wait(5)
            end
        end
    end
    
    if timerUpdateConnection then
        timerUpdateConnection:Disconnect()
        timerUpdateConnection = nil
    end
    
    AutoBuyStatusLabel:Set("⏸️ Auto-buy stopped")
end

MiscTab:CreateToggle({
    Name = "Auto Buy Selected Items",
    Flag = "AutoBuy",
    CurrentValue = false,
    Callback = function(value)
        autoBuyEnabled = value
        
        if value then
            if #selectedBlackmarketItems == 0 then
                AutoBuyStatusLabel:Set("⚠️ No items selected!")
                Window:Notify({
                    Title = "Warning",
                    Content = "Please select items first!",
                    Duration = 3,
                    Type = "warning"
                })
                autoBuyEnabled = false
                return
            end
            
            AutoBuyStatusLabel:Set("🔄 Auto-buy enabled...")
            Window:Notify({
                Title = "Auto-Buy Started",
                Content = "Buying all available stock!",
                Duration = 3,
                Type = "success"
            })
            
            task.spawn(autoBuyLoop)
        else
            if timerUpdateConnection then
                timerUpdateConnection:Disconnect()
                timerUpdateConnection = nil
            end
            AutoBuyStatusLabel:Set("⏸️ Auto-buy stopped")
        end
    end
})

-- ═══════════════════════════════════════════════════════════════
--                          SETTINGS TAB
-- ═══════════════════════════════════════════════════════════════

local SettingsTab = Window:CreateTab("Settings")

SettingsTab:CreateSection("UI Settings")

SettingsTab:CreateKeybind({
    Name = "Toggle UI",
    Flag = "UIToggleKey",
    CurrentKeybind = "RightShift",
    Callback = function()
        Window:Toggle()
    end
})

SettingsTab:CreateToggle({
    Name = "Show Notifications",
    Flag = "ShowNotifications",
    CurrentValue = true,
    Callback = function(value)
        Window.ShowNotifications = value
    end
})

SettingsTab:CreateSection("Performance")

SettingsTab:CreateToggle({
    Name = "Reduce Lag",
    Flag = "ReduceLag",
    CurrentValue = false,
    Callback = function(value)
        if value then
            settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
        else
            settings().Rendering.QualityLevel = Enum.QualityLevel.Automatic
        end
    end
})

SettingsTab:CreateSection("About")

SettingsTab:CreateLabel("Ravyneth Hub V13 - Final Perfect")
SettingsTab:CreateLabel("Made with ❤️ by Ravyneth Team")
SettingsTab:CreateLabel("Discord: discord.gg/ravyneth")

SettingsTab:CreateButton({
    Name = "Copy Discord Link",
    Callback = function()
        setclipboard("discord.gg/ravyneth")
        Window:Notify({
            Title = "Discord",
            Content = "Link copied to clipboard!",
            Duration = 3,
            Type = "success"
        })
    end
})

SettingsTab:CreateButton({
    Name = "Destroy UI",
    Callback = function()
        Window:Notify({
            Title = "Goodbye!",
            Content = "UI will be destroyed in 2 seconds...",
            Duration = 2,
            Type = "warning"
        })
        task.wait(2)
        Window:Destroy()
    end
})

print("✅ Ravyneth Hub V13 - FINAL PERFECT VERSION LOADED!")

Window:Notify({
    Title = "Ready!",
    Content = "All features loaded successfully!",
    Duration = 4,
    Type = "success"
})
