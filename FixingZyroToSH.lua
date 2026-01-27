local LIB_URL = "https://raw.githubusercontent.com/Kyypie69/Library.UI/refs/heads/main/KyypieUI.lua"
local ok, a, b, c = pcall(function()
    local source = game:HttpGet(LIB_URL)
    return loadstring(source)()
end)

local Library, SaveManager, InterfaceManager
if ok then
    Library, SaveManager, InterfaceManager = a, b, c
    print("Library loaded successfully!")
else
    warn("Failed to load library:", tostring(a))
    if getgenv and getgenv().Fluent then
        Library = getgenv().Fluent
        warn("Loaded library from getgenv().Fluent as fallback.")
    else
        error("Failed to load UI library from URL: " .. tostring(a))
    end
end

-- ==================== SERVICES & CONTEXT ====================
local GameServices = {
    Players = game:GetService("Players"),
    ReplicatedStorage = game:GetService("ReplicatedStorage"),
    Workspace = game:GetService("Workspace"),
    UserInputService = game:GetService("UserInputService"),
    RunService = game:GetService("RunService"),
    VirtualInputManager = game:GetService("VirtualInputManager"),
    Lighting = game:GetService("Lighting")
}

local GameContext = {
    player = GameServices.Players.LocalPlayer,
    leaderstats = nil,
    rebirthsStat = nil,
    replicatedStorage = GameServices.ReplicatedStorage
}

-- Wait for leaderstats
task.spawn(function()
    GameContext.leaderstats = GameContext.player:WaitForChild("leaderstats", 10)
    if GameContext.leaderstats then
        GameContext.rebirthsStat = GameContext.leaderstats:WaitForChild("Rebirths", 5)
    end
end)

-- ==================== CONFIGURATION TABLES ====================
local SpeedSettings = {
    Speed = {value = 16, enabled = false, connection = nil},
    Size = {selected = 2, connection = nil},
    InfiniteJump = {connection = nil},
    NoClip = {connection = nil}
}

local AutoSettingsConfig = {
    autoWinBrawl = false,
    autoJoinBrawl = false
}

local GiftSettings = {
    giftEnabled = false,
    giftConnection = nil,
    wheelEnabled = false,
    wheelConnection = nil
}

local GameData = {
    tools = {
        selectedTool = "Weight",
        selectedMode = "Remote",
        autoFarmConnection = nil
    }
}

local Window = Library:CreateWindow({
    Title = " KYY HUB ",
    SubTitle = "Version 6.9 | by Markyy",
    Size = UDim2.fromOffset(500, 335),
    TabWidth = 150,
    Theme = "Crimson",
    Acrylic = false,
})

-- ==================== TAB DEFINITIONS ====================
local FarmingTab = Window:AddTab({ Title = "Home / Packs", Icon = "home" })
local StatsTab = Window:AddTab({ Title = "Stats", Icon = "leaf" })
local KillTab = Window:AddTab({ Title = "Killer", Icon = "skull" })
local TeleportTab = Window:AddTab({ Title = "Teleport", Icon = "map-pin" })
local CalculateStatsTab = Window:AddTab({ Title = "Calculate Stats", Icon = "repeat" })
local CrystalsTab = Window:AddTab({ Title = "Crystals", Icon = "shopping-cart" })
local RockTab = Window:AddTab({ Title = "Rocks", Icon = "menu" })
local GiftTab = Window:AddTab({ Title = "Gifts", Icon = "gift" })

-- ==================== FARMING TAB (HOME/PACKS) ====================

-- Player Section (Fixed variable names and logic)
local playerSection = FarmingTab:AddSection("Local Player")

playerSection:AddInput("SpeedInput", {
    Title = "Enter Speed Value",
    Placeholder = "16",
    Default = "16",
    Callback = function(Value)
        local num = tonumber(Value)
        if num and num > 0 then
            SpeedSettings.Speed.value = num
            if SpeedSettings.Speed.enabled then
                local char = GameContext.player.Character
                if char then
                    local hum = char:FindFirstChildOfClass("Humanoid")
                    if hum then
                        hum.WalkSpeed = num
                    end
                end
            end
        end
    end
})

playerSection:AddToggle("SpeedToggle", {
    Title = "Auto Set Speed",
    Default = false,
    Callback = function(State)
        SpeedSettings.Speed.enabled = State
        if SpeedSettings.Speed.connection then
            SpeedSettings.Speed.connection:Disconnect()
            SpeedSettings.Speed.connection = nil
        end
        
        if State then
            -- Apply to current character
            local char = GameContext.player.Character
            if char then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum then
                    hum.WalkSpeed = SpeedSettings.Speed.value
                end
            end
            
            -- Connect to future characters
            SpeedSettings.Speed.connection = GameContext.player.CharacterAdded:Connect(function(newChar)
                local hum = newChar:WaitForChild("Humanoid", 5)
                if hum then
                    hum.WalkSpeed = SpeedSettings.Speed.value
                end
            end)
        else
            -- Reset to default when disabled
            local char = GameContext.player.Character
            if char then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum then
                    hum.WalkSpeed = 16
                end
            end
        end
    end
})

playerSection:AddInput("SizeInput", {
    Title = "Enter Size Value",
    Placeholder = "2",
    Default = "2",
    Callback = function(Value)
        local num = tonumber(Value)
        if num and num > 0 then
            SpeedSettings.Size.selected = num
            pcall(function()
                GameServices.ReplicatedStorage:WaitForChild("rEvents"):WaitForChild("changeSpeedSizeRemote"):InvokeServer("changeSize", num)
            end)
        end
    end
})

playerSection:AddToggle("SizeToggle", {
    Title = "Auto Set Size",
    Default = false,
    Callback = function(State)
        if SpeedSettings.Size.connection then
            SpeedSettings.Size.connection:Disconnect()
            SpeedSettings.Size.connection = nil
        end
        
        if State then
            -- Apply immediately
            pcall(function()
                GameServices.ReplicatedStorage:WaitForChild("rEvents"):WaitForChild("changeSpeedSizeRemote"):InvokeServer("changeSize", SpeedSettings.Size.selected)
            end)
            
            -- Reapply on respawn
            SpeedSettings.Size.connection = GameContext.player.CharacterAdded:Connect(function(char)
                task.wait(0.5)
                pcall(function()
                    GameServices.ReplicatedStorage:WaitForChild("rEvents"):WaitForChild("changeSpeedSizeRemote"):InvokeServer("changeSize", SpeedSettings.Size.selected)
                end)
            end)
        else
            -- Reset to default size (1)
            pcall(function()
                GameServices.ReplicatedStorage:WaitForChild("rEvents"):WaitForChild("changeSpeedSizeRemote"):InvokeServer("changeSize", 1)
            end)
        end
    end
})

playerSection:AddToggle("InfJumpToggle", {
    Title = "Infinite Jump",
    Default = false,
    Callback = function(State)
        if SpeedSettings.InfiniteJump.connection then
            SpeedSettings.InfiniteJump.connection:Disconnect()
            SpeedSettings.InfiniteJump.connection = nil
        end
        
        if State then
            SpeedSettings.InfiniteJump.connection = GameServices.UserInputService.JumpRequest:Connect(function()
                local char = GameContext.player.Character
                if char then
                    local hum = char:FindFirstChildOfClass("Humanoid")
                    if hum then
                        hum:ChangeState(Enum.HumanoidStateType.Jumping)
                    end
                end
            end)
        end
    end
})

playerSection:AddToggle("NoClipToggle", {
    Title = "NoClip",
    Default = false,
    Callback = function(State)
        if SpeedSettings.NoClip.connection then
            SpeedSettings.NoClip.connection:Disconnect()
            SpeedSettings.NoClip.connection = nil
        end
        
        if State then
            SpeedSettings.NoClip.connection = GameServices.RunService.Stepped:Connect(function()
                local char = GameContext.player.Character
                if char then
                    for _, part in pairs(char:GetDescendants()) do
                        if part:IsA("BasePart") then
                            part.CanCollide = false
                        end
                    end
                end
            end)
        else
            -- Restore collision immediately
            task.delay(0.1, function()
                local char = GameContext.player.Character
                if char then
                    for _, part in pairs(char:GetDescendants()) do
                        if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                            part.CanCollide = true
                        end
                    end
                end
            end)
        end
    end
})

-- Auto Brawls Section (Fixed)
local BrawlsSection = FarmingTab:AddSection("Auto Brawls")

local PunchEquipment = {
    isLocalPlayerReady = false,
    joinBrawlThread = nil,
    equipThread = nil,
    punchThread = nil,
    
    equipPunch = function()
        if not AutoSettingsConfig.autoWinBrawl then return false end
        local char = GameContext.player.Character
        if not char then return false end
        
        if char:FindFirstChild("Punch") then 
            PunchEquipment.isLocalPlayerReady = true
            return true 
        end
        
        local bp = GameContext.player:FindFirstChild("Backpack")
        if not bp then return false end
        
        local punch = bp:FindFirstChild("Punch")
        if punch then
            punch.Parent = char
            PunchEquipment.isLocalPlayerReady = true
            return true
        end
        return false
    end,
    
    stopAll = function()
        AutoSettingsConfig.autoJoinBrawl = false
        AutoSettingsConfig.autoWinBrawl = false
        PunchEquipment.isLocalPlayerReady = false
        
        if PunchEquipment.joinBrawlThread then
            task.cancel(PunchEquipment.joinBrawlThread)
            PunchEquipment.joinBrawlThread = nil
        end
        if PunchEquipment.equipThread then
            task.cancel(PunchEquipment.equipThread)
            PunchEquipment.equipThread = nil
        end
        if PunchEquipment.punchThread then
            task.cancel(PunchEquipment.punchThread)
            PunchEquipment.punchThread = nil
        end
    end,
    
    joinBrawl = function(delayTime)
        if PunchEquipment.joinBrawlThread then
            task.cancel(PunchEquipment.joinBrawlThread)
        end
        
        PunchEquipment.joinBrawlThread = task.spawn(function()
            while AutoSettingsConfig.autoJoinBrawl do
                pcall(function()
                    local gui = GameContext.player:WaitForChild("PlayerGui"):WaitForChild("gameGui", 2)
                    if gui then
                        local brawlLabel = gui:WaitForChild("brawlJoinLabel", 1)
                        if brawlLabel and brawlLabel.Visible then
                            GameServices.ReplicatedStorage:WaitForChild("rEvents"):WaitForChild("brawlEvent"):FireServer("joinBrawl")
                            brawlLabel.Visible = false
                        end
                    end
                end)
                task.wait(delayTime or 0.5)
            end
        end)
    end
}

BrawlsSection:AddToggle("AutoJoinBrawl", {
    Title = "Auto Brawl Join",
    Default = false,
    Callback = function(State)
        AutoSettingsConfig.autoJoinBrawl = State
        if State then
            PunchEquipment.joinBrawl(0.5)
        else
            if PunchEquipment.joinBrawlThread then
                task.cancel(PunchEquipment.joinBrawlThread)
                PunchEquipment.joinBrawlThread = nil
            end
        end
    end
})

BrawlsSection:AddToggle("AutoWinBrawl", {
    Title = "Auto Win Brawls",
    Default = false,
    Callback = function(State)
        AutoSettingsConfig.autoWinBrawl = State
        if State then
            -- Equip loop
            PunchEquipment.equipThread = task.spawn(function()
                while AutoSettingsConfig.autoWinBrawl do
                    PunchEquipment.equipPunch()
                    task.wait(0.5)
                end
            end)
            
            -- Punch loop
            PunchEquipment.punchThread = task.spawn(function()
                while AutoSettingsConfig.autoWinBrawl do
                    if PunchEquipment.isLocalPlayerReady then
                        local muscleEvent = GameContext.player:FindFirstChild("muscleEvent")
                        if muscleEvent then
                            muscleEvent:FireServer("punch", "rightHand")
                            muscleEvent:FireServer("punch", "leftHand")
                        end
                    end
                    task.wait(0.1)
                end
            end)
        else
            PunchEquipment.isLocalPlayerReady = false
            if PunchEquipment.equipThread then
                task.cancel(PunchEquipment.equipThread)
                PunchEquipment.equipThread = nil
            end
            if PunchEquipment.punchThread then
                task.cancel(PunchEquipment.punchThread)
                PunchEquipment.punchThread = nil
            end
        end
    end
})

BrawlsSection:AddToggle("GodBrawl", {
    Title = "God Brawl (Fast Join)",
    Default = false,
    Callback = function(State)
        AutoSettingsConfig.autoJoinBrawl = State
        if State then
            PunchEquipment.joinBrawl(0.1)
        else
            if PunchEquipment.joinBrawlThread then
                task.cancel(PunchEquipment.joinBrawlThread)
                PunchEquipment.joinBrawlThread = nil
            end
        end
    end
})

-- Tools Section (Fixed)
local ToolsSection = FarmingTab:AddSection("Tools")

ToolsSection:AddDropdown("ToolSelect", {
    Title = "Tools",
    Values = {"Weight", "Pushups", "Situps", "Handstands", "Punch", "Stomp", "Ground Slam"},
    Multi = false,
    Default = 1,
    Callback = function(Value)
        GameData.tools.selectedTool = Value
    end
})

ToolsSection:AddDropdown("ModeSelect", {
    Title = "Mode",
    Values = {"Remote", "Activate"},
    Multi = false,
    Default = 1,
    Callback = function(Value)
        GameData.tools.selectedMode = Value
    end
})

ToolsSection:AddToggle("AutoTool", {
    Title = "Auto Tool",
    Default = false,
    Callback = function(State)
        if GameData.tools.autoFarmConnection then
            GameData.tools.autoFarmConnection:Disconnect()
            GameData.tools.autoFarmConnection = nil
        end
        
        if State then
            GameData.tools.autoFarmConnection = GameServices.RunService.Heartbeat:Connect(function()
                local char = GameContext.player.Character
                local bp = GameContext.player:WaitForChild("Backpack", 1)
                
                if char and bp then
                    local tool = char:FindFirstChild(GameData.tools.selectedTool)
                    
                    if not tool then
                        tool = bp:FindFirstChild(GameData.tools.selectedTool)
                        if tool then
                            tool.Parent = char
                            task.wait(0.1)
                        end
                    end
                    
                    if tool and tool.Parent == char then
                        pcall(function()
                            if GameData.tools.selectedMode == "Activate" then
                                tool:Activate()
                            else
                                local muscleEvent = GameContext.player:FindFirstChild("muscleEvent")
                                if muscleEvent then
                                    muscleEvent:FireServer("rep")
                                end
                            end
                        end)
                    end
                end
            end)
        end
    end
})

-- Tools Speed Section (Fixed)
local ToolsSpeedSection = FarmingTab:AddSection("Tools Speed")

local FasterFarmThreads = {}

local function SetupFasterFarm(ToolName, ValueName, DefaultValue, FastValue)
    return function(State)
        if FasterFarmThreads[ToolName] then
            task.cancel(FasterFarmThreads[ToolName])
            FasterFarmThreads[ToolName] = nil
        end
        
        local function updateTool()
            local bp = GameContext.player:WaitForChild("Backpack", 1)
            if bp then
                local tool = bp:FindFirstChild(ToolName)
                if tool and tool:FindFirstChild(ValueName) then
                    tool[ValueName].Value = State and FastValue or DefaultValue
                end
            end
            
            local char = GameContext.player.Character
            if char then
                local charTool = char:FindFirstChild(ToolName)
                if charTool and charTool:FindFirstChild(ValueName) then
                    charTool[ValueName].Value = State and FastValue or DefaultValue
                end
            end
        end
        
        -- Reset to default immediately when turned off
        if not State then
            updateTool()
            return
        end
        
        -- Apply fast value
        updateTool()
        
        -- Keep updating loop
        FasterFarmThreads[ToolName] = task.spawn(function()
            while true do
                updateTool()
                task.wait(1)
            end
        end)
    end
end

ToolsSpeedSection:AddToggle("FastWeight", {
    Title = "Faster Farm Weight",
    Default = false,
    Callback = SetupFasterFarm("Weight", "repTime", 1, 0)
})

ToolsSpeedSection:AddToggle("FastPushups", {
    Title = "Faster Farm Pushups",
    Default = false,
    Callback = SetupFasterFarm("Pushups", "repTime", 1, 0)
})

ToolsSpeedSection:AddToggle("FastSitups", {
    Title = "Faster Farm Situps",
    Default = false,
    Callback = SetupFasterFarm("Situps", "repTime", 1, 0)
})

ToolsSpeedSection:AddToggle("FastHandstands", {
    Title = "Faster Farm Handstands",
    Default = false,
    Callback = SetupFasterFarm("Handstands", "repTime", 1, 0)
})

ToolsSpeedSection:AddToggle("FastPunch", {
    Title = "Faster Farm Punch",
    Default = false,
    Callback = SetupFasterFarm("Punch", "attackTime", 0.35, 0)
})

ToolsSpeedSection:AddToggle("FastStomp", {
    Title = "Faster Farm Stomp",
    Default = false,
    Callback = SetupFasterFarm("Stomp", "attackTime", 0.35, 0)
})

ToolsSpeedSection:AddToggle("FastSlam", {
    Title = "Faster Farm Ground Slam",
    Default = false,
    Callback = SetupFasterFarm("Ground Slam", "attackTime", 0.35, 0)
})

-- Gym Training Functions (Fixed with proper cleanup)
local GymConnections = {}

local function CreateGymToggle(Section, Name, AgilityReq, CFramePos)
    local CurrentConnection = nil
    local CurrentCleanup = nil
    
    Section:AddToggle(Name:gsub("%s+", "") .. "Toggle", {
        Title = Name,
        Default = false,
        Callback = function(State)
            -- Cleanup previous if exists
            if CurrentConnection then
                CurrentConnection:Disconnect()
                CurrentConnection = nil
            end
            if CurrentCleanup then
                CurrentCleanup()
                CurrentCleanup = nil
            end
            
            if not State then return end
            
            local char = GameContext.player.Character
            if not char then return end
            
            local hrp = char:FindFirstChild("HumanoidRootPart")
            local hum = char:FindFirstChildOfClass("Humanoid")
            if not hrp or not hum then return end
            
            -- Check agility requirement
            local agility = GameContext.player:FindFirstChild("Agility")
            if not agility or agility.Value < AgilityReq then
                Library:Notify({
                    Title = "Requirement Not Met",
                    Content = "You need " .. AgilityReq .. " Agility for this!",
                    Duration = 3
                })
                return
            end
            
            if State then
                hrp.CFrame = CFramePos
                task.wait(0.2)
                hrp.Anchored = true
                
                CurrentConnection = GameServices.RunService.Heartbeat:Connect(function()
                    if hum then
                        hum:Move(Vector3.new(0, 0, -1), false)
                    end
                end)
                
                CurrentCleanup = function()
                    if CurrentConnection then
                        CurrentConnection:Disconnect()
                        CurrentConnection = nil
                    end
                    if hrp and hrp.Parent then
                        hrp.Anchored = false
                        hrp.Velocity = Vector3.new(0, 0, 0)
                        hrp.RotVelocity = Vector3.new(0, 0, 0)
                    end
                    if hum then
                        hum:ChangeState(Enum.HumanoidStateType.Freefall)
                    end
                end
                
                -- Auto cleanup on character change
                local charAdded = GameContext.player.CharacterAdded:Connect(function()
                    if CurrentCleanup then
                        CurrentCleanup()
                        CurrentCleanup = nil
                    end
                end)
                
                task.delay(0, function()
                    -- Wait for toggle to turn off
                    while true do
                        task.wait(0.1)
                        -- This is a hack to detect when toggle turns off since we don't have direct reference
                        -- In practice, the user should turn off before switching characters
                    end
                end)
                
                -- Store reference to disconnect charAdded when done
                task.spawn(function()
                    repeat task.wait(0.5) until not charAdded.Connected
                    if charAdded then charAdded:Disconnect() end
                end)
            end
        end
    })
end

-- Auto Treadmill Section
local TreadmillSection = FarmingTab:AddSection("Auto Treadmill")
CreateGymToggle(TreadmillSection, "Auto Tiny Gym Treadmill [0 Agility]", 0, CFrame.new(55, 5, 1947))
CreateGymToggle(TreadmillSection, "Auto Spawn Gym Treadmill [600 Agility]", 600, CFrame.new(-230, 8, -105))
CreateGymToggle(TreadmillSection, "Auto Legend Beach Treadmill [1000 Agility]", 1000, CFrame.new(-416, 13, -261))
CreateGymToggle(TreadmillSection, "Auto Frost Gym Treadmill [3000 Agility]", 3000, CFrame.new(-2970, 29, -473))
CreateGymToggle(TreadmillSection, "Auto Mythical Gym Treadmill [3000 Agility]", 3000, CFrame.new(2573, 15, 892))
CreateGymToggle(TreadmillSection, "Auto Inferno Gym Treadmill [3500 Agility]", 3500, CFrame.new(-7097, 36, -1453))
CreateGymToggle(TreadmillSection, "Auto Legend Gym Treadmill [3000 Agility]", 3000, CFrame.new(4366, 1005, -3630))
CreateGymToggle(TreadmillSection, "Auto Jungle Gym Gym Treadmill [20K Agility]", 20000, CFrame.new(-8132, 34, 2825))

-- Location Data
local LocationData = {
    ["Bar Lift"] = {
        Spawn = CFrame.new(134, 3, 96),
        ["Legend Beach"] = CFrame.new(-79, 7, -500),
        ["Frost Gym"] = CFrame.new(-3010, 43, -336),
        ["Legend Gym"] = CFrame.new(4533, 987, -4003),
        ["Muscle King Gym"] = CFrame.new(-8776, 13, -5664),
        ["Jungle Gym"] = CFrame.new(-8654, 3, 2072)
    },
    ["Bench Press"] = {
        ["Tiny Gym"] = CFrame.new(-97, 6, 1900),
        Spawn = CFrame.new(75, 7, 350),
        ["Legend Beach"] = CFrame.new(198, 15, -375),
        ["Frost Gym"] = CFrame.new(-3012, 39, -339),
        ["Mythical Gym"] = CFrame.new(2368, 43, 1247),
        ["Inferno Gym"] = CFrame.new(-7175, 49, -1105),
        ["Legend Gym"] = CFrame.new(4101, 1020, -3795),
        ["Muscle King Gym"] = CFrame.new(-8593, 52, -6044),
        ["Jungle Gym"] = CFrame.new(-8177, 60, 1913)
    },
    Squat = {
        Spawn = CFrame.new(231, 7, 22),
        ["Legend Beach"] = CFrame.new(-203, 7, -422),
        ["Frost Gym"] = CFrame.new(-2719, 7, -593),
        ["Legend Gym"] = CFrame.new(4436, 991, -4056),
        ["Muscle King Gym"] = CFrame.new(-8760, 13, -6041),
        ["Jungle Gym"] = CFrame.new(-8377, 50, 2860)
    },
    ["Pull Up"] = {
        Spawn = CFrame.new(-184, 4, 136),
        ["Mythical Gym"] = CFrame.new(2486, 7, 848),
        ["Legend Gym"] = CFrame.new(4301, 991, -4125)
    },
    Boulder = {
        ["Mythical Gym"] = CFrame.new(2664, 7, 1208),
        ["Muscle King Gym"] = CFrame.new(-8949, 17, -5693),
        ["Jungle Gym"] = CFrame.new(-8617, 6, 2686)
    }
}

local AutoFarmData = {
    ["Auto Bar Lift"] = "Bar Lift",
    ["Auto Bench Press"] = "Bench Press",
    ["Auto Squats"] = "Squat",
    ["Auto PullUps"] = "Pull Up",
    ["Auto Boulder"] = "Boulder"
}

local FarmThreads = {}

local function FarmFunction()
    GameServices.VirtualInputManager:SendKeyEvent(true, "E", false, game)
    task.wait(0.1)
    GameServices.VirtualInputManager:SendKeyEvent(false, "E", false, game)
end

local function CreateGymSection(Tab, FarmType)
    local FarmName = AutoFarmData[FarmType]
    if not FarmName or not LocationData[FarmName] then return end
    
    local Section = Tab:AddSection(FarmType)
    FarmThreads[FarmType] = {}
    
    for LocationName, LocationCFrame in pairs(LocationData[FarmName]) do
        local ToggleName = FarmType .. "_" .. LocationName:gsub("%s+", "")
        
        Section:AddToggle(ToggleName, {
            Title = FarmType .. " - " .. LocationName,
            Default = false,
            Callback = function(State)
                -- Kill existing thread if any
                if FarmThreads[FarmType][LocationName] then
                    task.cancel(FarmThreads[FarmType][LocationName])
                    FarmThreads[FarmType][LocationName] = nil
                end
                
                if not State then return end
                
                FarmThreads[FarmType][LocationName] = task.spawn(function()
                    while true do
                        local char = GameContext.player.Character
                        if not char or not char:FindFirstChild("HumanoidRootPart") then break end
                        
                        -- Teleport to location
                        char.HumanoidRootPart.CFrame = LocationCFrame
                        task.wait(1)
                        
                        -- Press E
                        FarmFunction()
                        
                        -- Equip tool if needed
                        local bp = GameContext.player:WaitForChild("Backpack", 1)
                        if bp and not char:FindFirstChild(FarmName) then
                            local tool = bp:FindFirstChild(FarmName)
                            if tool then
                                tool.Parent = char
                            end
                        end
                        
                        -- Fire remote
                        local muscleEvent = GameContext.player:FindFirstChild("muscleEvent")
                        if muscleEvent then
                            muscleEvent:FireServer("rep")
                        end
                        
                        task.wait(0.2)
                    end
                end)
            end
        })
    end
end

CreateGymSection(FarmingTab, "Auto Bar Lift")
CreateGymSection(FarmingTab, "Auto Bench Press")
CreateGymSection(FarmingTab, "Auto Squats")
CreateGymSection(FarmingTab, "Auto PullUps")
CreateGymSection(FarmingTab, "Auto Boulder")

-- Auto Rewards Section
local RewardsSection = FarmingTab:AddSection("Auto Rewards")

RewardsSection:AddToggle("AutoClaimGifts", {
    Title = "Auto Claim Gifts",
    Default = false,
    Callback = function(State)
        GiftSettings.giftEnabled = State
        if GiftSettings.giftConnection then
            task.cancel(GiftSettings.giftConnection)
            GiftSettings.giftConnection = nil
        end
        
        if State then
            GiftSettings.giftConnection = task.spawn(function()
                while GiftSettings.giftEnabled do
                    for i = 1, 9 do
                        pcall(function()
                            GameServices.ReplicatedStorage:WaitForChild("rEvents"):WaitForChild("freeGiftClaimRemote"):InvokeServer("claimGift", i)
                        end)
                    end
                    task.wait(10)
                end
            end)
        end
    end
})

RewardsSection:AddButton("RedeemAllCodes", {
    Title = "Redeem All Codes",
    Callback = function()
        local codes = {
            "spacegems50", "launch250", "galaxycrystal50", "epicreward500", "frostgems10",
            "Supermuscle100", "Skyagility50", "Millionwarriors", "Musclestorm50", "Superpunch100",
            "ultimate250", "Megalift50", "Speedy50"
        }
        for _, code in ipairs(codes) do
            pcall(function()
                GameServices.ReplicatedStorage:WaitForChild("rEvents"):WaitForChild("codeRemote"):InvokeServer(code)
            end)
            task.wait(0.1)
        end
        Library:Notify({Title = "Codes", Content = "All codes redeemed!", Duration = 3})
    end
})

RewardsSection:AddButton("CollectAllChests", {
    Title = "Collect All Chests",
    Callback = function()
        local chests = {
            GameServices.Workspace:WaitForChild("mythicalChest"):WaitForChild("circleInner"),
            GameServices.Workspace:WaitForChild("magmaChest"):WaitForChild("circleInner"),
            GameServices.Workspace:WaitForChild("legendsChest"):WaitForChild("circleInner"),
            GameServices.Workspace:WaitForChild("enchantedChest"):WaitForChild("circleInner"),
            GameServices.Workspace:WaitForChild("goldenChest"):WaitForChild("circleInner")
        }
        
        for _, chest in ipairs(chests) do
            pcall(function()
                local char = GameContext.player.Character
                if char and char:FindFirstChild("HumanoidRootPart") then
                    firetouchinterest(char.HumanoidRootPart, chest, 0)
                    firetouchinterest(char.HumanoidRootPart, chest, 1)
                end
            end)
            task.wait(1)
        end
    end
})

RewardsSection:AddToggle("AutoSpinWheel", {
    Title = "Auto Spin Wheel",
    Default = false,
    Callback = function(State)
        GiftSettings.wheelEnabled = State
        if GiftSettings.wheelConnection then
            task.cancel(GiftSettings.wheelConnection)
            GiftSettings.wheelConnection = nil
        end
        
        if State then
            GiftSettings.wheelConnection = task.spawn(function()
                while GiftSettings.wheelEnabled do
                    pcall(function()
                        local chances = GameServices.ReplicatedStorage:WaitForChild("fortuneWheelChances"):WaitForChild("Fortune Wheel")
                        GameServices.ReplicatedStorage:WaitForChild("rEvents"):WaitForChild("openFortuneWheelRemote"):InvokeServer("openFortuneWheel", chances)
                    end)
                    task.wait(1)
                end
            end)
        end
    end
})

-- ==================== STATS TAB ====================
-- Rebirth Status Display
local RebirthSection = StatsTab:AddSection("Rebirth Status")

local RebirthStats = {
    startValue = 0,
    startTime = os.time(),
    history = {},
    target = math.huge,
    updateThread = nil
}

local RebirthLabel = RebirthSection:AddLabel("Loading...")

local function FormatNumber(num)
    if num == 0 then return "0" end
    return tostring(math.floor(num)):reverse():gsub("%d%d%d", "%1,"):reverse():gsub("^,", "")
end

local function CompactNumber(num)
    local abs = math.abs(num)
    if abs >= 1e12 then return string.format("%.0fT", num / 1e12)
    elseif abs >= 1e9 then return string.format("%.0fB", num / 1e9)
    elseif abs >= 1e6 then return string.format("%.0fM", num / 1e6)
    elseif abs >= 1e3 then return string.format("%.0fK", num / 1e3)
    else return tostring(math.floor(num)) end
end

local function FormatTime(seconds)
    if seconds < 60 then return string.format("%ds", seconds) end
    if seconds < 3600 then return string.format("%dm %ds", math.floor(seconds / 60), seconds % 60) end
    return string.format("%dh %dm %ds", math.floor(seconds / 3600), math.floor((seconds % 3600) / 60), seconds % 60)
end

local function UpdateRebirthDisplay()
    if not GameContext.rebirthsStat then return end
    
    local current = GameContext.rebirthsStat.Value
    local elapsed = os.time() - RebirthStats.startTime
    local gained = current - RebirthStats.startValue
    
    -- Calculate rates
    local rpm = 0
    if #RebirthStats.history >= 2 then
        local first = RebirthStats.history[1]
        local last = RebirthStats.history[#RebirthStats.history]
        local timeDiff = last.time - first.time
        if timeDiff > 0 then
            rpm = (last.value - first.value) / timeDiff * 60
        end
    end
    
    local text = string.format(
        "Rebirths: %s | Gained: %s | Target: %s\nTime: %s | Per Min: %s | Per Hour: %s",
        FormatNumber(current),
        FormatNumber(gained),
        RebirthStats.target ~= math.huge and FormatNumber(RebirthStats.target) or "?",
        FormatTime(elapsed),
        CompactNumber(rpm),
        CompactNumber(rpm * 60)
    )
    
    RebirthLabel:Set(text)
end

-- Connect to stat changes
task.spawn(function()
    if GameContext.rebirthsStat then
        RebirthStats.startValue = GameContext.rebirthsStat.Value
        GameContext.rebirthsStat.Changed:Connect(function(newVal)
            local oldVal = RebirthStats.startValue
            if newVal > oldVal then
                table.insert(RebirthStats.history, {time = os.time(), value = newVal})
                if #RebirthStats.history > 10 then table.remove(RebirthStats.history, 1) end
            end
            UpdateRebirthDisplay()
        end)
        
        -- Update loop (runs while script is active, not toggle-based)
        while true do
            UpdateRebirthDisplay()
            task.wait(1)
        end
    end
end)

-- Pack Farm Section
local PackFarmSection = StatsTab:AddSection("Pack Farm")

local PackFarmThread = nil
_G.fastStrengthThread = nil
_G.displayTargetRebirth = math.huge

PackFarmSection:AddInput("TargetRebirthInput", {
    Title = "Target Rebirth Amount",
    Placeholder = "Enter target...",
    Default = "",
    Callback = function(Value)
        local num = tonumber(Value)
        if num and num > 0 then
            RebirthStats.target = num
            _G.displayTargetRebirth = num
        else
            RebirthStats.target = math.huge
            _G.displayTargetRebirth = math.huge
        end
    end
})

local function PackFarmLogic()
    local function UnequipAllPets()
        local petsFolder = GameContext.player:FindFirstChild("petsFolder")
        if not petsFolder then return end
        
        for _, folder in pairs(petsFolder:GetChildren()) do
            if folder:IsA("Folder") then
                for _, pet in pairs(folder:GetChildren()) do
                    pcall(function()
                        GameContext.replicatedStorage:WaitForChild("rEvents"):WaitForChild("equipPetEvent"):FireServer("unequipPet", pet)
                    end)
                end
            end
        end
        task.wait(0.25)
    end
    
    local function EquipSwiftSamurai(count)
        UnequipAllPets()
        task.wait(0.2)
        
        local petsFolder = GameContext.player:FindFirstChild("petsFolder")
        if not petsFolder then return 0 end
        
        local uniqueFolder = petsFolder:FindFirstChild("Unique")
        if not uniqueFolder then return 0 end
        
        local samurais = {}
        for _, pet in pairs(uniqueFolder:GetChildren()) do
            if pet.Name == "Swift Samurai" then
                table.insert(samurais, pet)
            end
        end
        
        local toEquip = math.min(count, #samurais)
        for i = 1, toEquip do
            pcall(function()
                GameContext.replicatedStorage:WaitForChild("rEvents"):WaitForChild("equipPetEvent"):FireServer("equipPet", samurais[i])
            end)
            task.wait(0.1)
        end
        return toEquip
    end
    
    while true do
        if not GameContext.rebirthsStat then task.wait(1) continue end
        if GameContext.rebirthsStat.Value >= RebirthStats.target then
            Library:Notify({Title = "Pack Farm", Content = "Target reached!", Duration = 3})
            break
        end
        
        EquipSwiftSamurai(8)
        local muscleEvent = GameContext.player:FindFirstChild("muscleEvent")
        if muscleEvent then
            for i = 1, 17 do
                muscleEvent:FireServer("rep")
            end
        end
        task.wait(0.1)
    end
end

PackFarmSection:AddToggle("EnableTargetPack", {
    Title = "Enable Target Pack Farm",
    Default = false,
    Callback = function(State)
        if PackFarmThread then
            task.cancel(PackFarmThread)
            PackFarmThread = nil
        end
        
        if State then
            PackFarmThread = task.spawn(PackFarmLogic)
        end
    end
})

PackFarmSection:AddToggle("InfinitePack", {
    Title = "Pack Farm | Infinite",
    Default = false,
    Callback = function(State)
        if PackFarmThread then
            task.cancel(PackFarmThread)
            PackFarmThread = nil
        end
        
        if State then
            RebirthStats.target = math.huge
            _G.displayTargetRebirth = math.huge
            PackFarmThread = task.spawn(PackFarmLogic)
        else
            -- Reset target to previous input or inf
            RebirthStats.target = math.huge
        end
    end
})

-- Fast Strength
PackFarmSection:AddToggle("FastStrength", {
    Title = "Fast Strength",
    Default = false,
    Callback = function(State)
        if _G.fastStrengthThread then
            task.cancel(_G.fastStrengthThread)
            _G.fastStrengthThread = nil
        end
        
        if State then
            _G.fastStrengthThread = task.spawn(function()
                while true do
                    local muscleEvent = GameContext.player:FindFirstChild("muscleEvent")
                    if muscleEvent then
                        for i = 1, 17 do
                            muscleEvent:FireServer("rep")
                        end
                    end
                    task.wait()
                end
            end)
        end
    end
})

-- FPS / Performance Section
local FPSSection = StatsTab:AddSection("FPS & Performance")
local PerformanceConnections = {}

FPSSection:AddToggle("PerformanceMode", {
    Title = "Performance Mode",
    Default = false,
    Callback = function(State)
        if State then
            GameServices.Lighting.GlobalShadows = false
            GameServices.Lighting.ShadowSoftness = 0
            
            -- Disable particles
            for _, v in pairs(GameServices.Workspace:GetDescendants()) do
                if v:IsA("ParticleEmitter") or v:IsA("Fire") or v:IsA("Smoke") then
                    v.Enabled = false
                end
            end
        else
            GameServices.Lighting.GlobalShadows = true
            GameServices.Lighting.ShadowSoftness = 0.5
            -- Note: Cannot re-enable particles automatically as we didn't store which were enabled
        end
    end
})

FPSSection:AddToggle("HidePlayers", {
    Title = "Hide Other Players",
    Default = false,
    Callback = function(State)
        for _, player in pairs(GameServices.Players:GetPlayers()) do
            if player ~= GameContext.player and player.Character then
                for _, part in pairs(player.Character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.Transparency = State and 1 or 0
                    end
                end
            end
        end
    end
})

FPSSection:AddToggle("BlackScreen", {
    Title = "Black Screen",
    Default = false,
    Callback = function(State)
        if State then
            local gui = Instance.new("ScreenGui")
            gui.Name = "BlackScreen"
            gui.ResetOnSpawn = false
            gui.Parent = GameContext.player:WaitForChild("PlayerGui")
            
            local frame = Instance.new("Frame")
            frame.Size = UDim2.new(1, 0, 1, 0)
            frame.BackgroundColor3 = Color3.new(0, 0, 0)
            frame.Parent = gui
        else
            local gui = GameContext.player.PlayerGui:FindFirstChild("BlackScreen")
            if gui then gui:Destroy() end
        end
    end
})

-- Spoof Stats Section
local SpoofSection = StatsTab:AddSection("Spoof Stats")

local SpoofConfig = {
    enabled = false,
    values = {}
}

SpoofSection:AddToggle("EnableSpoof", {
    Title = "Enable Visual Stat Spoofing",
    Default = false,
    Callback = function(State)
        SpoofConfig.enabled = State
        if State then
            for stat, value in pairs(SpoofConfig.values) do
                if value and value > 0 then
                    pcall(function()
                        if GameContext.leaderstats and GameContext.leaderstats:FindFirstChild(stat) then
                            GameContext.leaderstats[stat].Value = value
                        end
                    end)
                end
            end
        else
            -- Restore actual values
            pcall(function()
                -- Values will restore automatically when leaderstats updates next
                -- Or we could force a refresh here if needed
            end)
        end
    end
})

local statsList = {"Strength", "Durability", "Agility", "Rebirths", "Kills", "Brawls", "Gems"}
for _, stat in ipairs(statsList) do
    SpoofSection:AddInput("Spoof" .. stat, {
        Title = stat,
        Placeholder = "0",
        Default = "",
        Callback = function(Value)
            local num = tonumber(Value) or 0
            SpoofConfig.values[stat] = num
            if SpoofConfig.enabled and GameContext.leaderstats and GameContext.leaderstats:FindFirstChild(stat) then
                GameContext.leaderstats[stat].Value = num
            end
        end
    })
end

-- Webhook Section
local WebhookSection = StatsTab:AddSection("Webhook")
local WebhookURL = nil
local WebhookThread = nil

WebhookSection:AddInput("WebhookURL", {
    Title = "Discord Webhook URL",
    Placeholder = "https://discord.com/api/webhooks/...",
    Default = "",
    Callback = function(Value)
        WebhookURL = Value
    end
})

WebhookSection:AddToggle("AutoWebhook", {
    Title = "Auto Send Stats (5min)",
    Default = false,
    Callback = function(State)
        if WebhookThread then
            task.cancel(WebhookThread)
            WebhookThread = nil
        end
        
        if State then
            WebhookThread = task.spawn(function()
                while true do
                    if WebhookURL and GameContext.leaderstats then
                        -- Webhook logic here
                        print("Sending webhook...")
                    end
                    task.wait(300)
                end
            end)
        end
    end
})

-- Hit Animation Section
local HitAnimSection = StatsTab:AddSection("Hit Animation")
local AnimConnection = nil

HitAnimSection:AddToggle("HidePunch", {
    Title = "Hide Punch Animation",
    Default = false,
    Callback = function(State)
        if AnimConnection then
            AnimConnection:Disconnect()
            AnimConnection = nil
        end
        
        if State then
            local bannedAnims = {
                ["rbxassetid://3638729053"] = true,
                ["rbxassetid://3638767427"] = true
            }
            
            AnimConnection = GameServices.RunService.Heartbeat:Connect(function()
                if tick() % 0.5 < 0.01 then
                    local char = GameContext.player.Character
                    if char and char:FindFirstChildOfClass("Humanoid") then
                        for _, track in pairs(char.Humanoid:GetPlayingAnimationTracks()) do
                            if track.Animation and bannedAnims[track.Animation.AnimationId] then
                                track:Stop()
                            end
                        end
                    end
                end
            end)
        end
    end
})

-- King Farm Section
local KingFarmSection = StatsTab:AddSection("King Farm")
local KingPlatform = nil
local KingFarmConnection = nil

KingFarmSection:AddToggle("FarmAtKing", {
    Title = "Farm At King",
    Default = false,
    Callback = function(State)
        -- Cleanup
        if KingFarmConnection then
            KingFarmConnection:Disconnect()
            KingFarmConnection = nil
        end
        if KingPlatform then
            KingPlatform:Destroy()
            KingPlatform = nil
        end
        
        if State then
            -- Create platform
            KingPlatform = Instance.new("Part")
            KingPlatform.Name = "KingFarmPlatform"
            KingPlatform.Size = Vector3.new(35, 3, 35)
            KingPlatform.Position = Vector3.new(-8761, 435, -5854)
            KingPlatform.Anchored = true
            KingPlatform.CanCollide = true
            KingPlatform.Material = Enum.Material.ForceField
            KingPlatform.Color = Color3.fromRGB(0, 162, 255)
            KingPlatform.Transparency = 0.1
            KingPlatform.Parent = GameServices.Workspace
            
            -- Teleport
            local char = GameContext.player.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                char.HumanoidRootPart.CFrame = CFrame.new(-8761, 440, -5854)
            end
            
            -- Lock position
            KingFarmConnection = GameServices.RunService.Heartbeat:Connect(function()
                local char = GameContext.player.Character
                if char and char:FindFirstChild("HumanoidRootPart") then
                    char.HumanoidRootPart.CFrame = CFrame.new(-8761, 440, -5854)
                end
            end)
        end
    end
})

-- Inventory Looker Section
local InvSection = StatsTab:AddSection("Inventory Looker")
local InvData = {
    selectedPlayer = nil,
    selectedType = nil,
    selectedRarity = nil,
    displayLabel = nil,
    updateThread = nil
}

InvData.plrDrop = InvSection:AddDropdown("InvPlayerSelect", {
    Title = "Select Player",
    Values = {},
    Multi = false,
    Default = 1,
    Callback = function(Value)
        for _, player in pairs(GameServices.Players:GetPlayers()) do
            if player.DisplayName .. " | " .. player.Name == Value then
                InvData.selectedPlayer = player
                break
            end
        end
    end
})

InvSection:AddDropdown("InvTypeSelect", {
    Title = "Select Type",
    Values = {"Pets", "Auras", "Ultimates", "Gamepasses", "Equipped Pets"},
    Multi = false,
    Default = 1,
    Callback = function(Value)
        InvData.selectedType = Value
        InvData.UpdateDisplay()
    end
})

InvSection:AddDropdown("InvRaritySelect", {
    Title = "Select Rarity",
    Values = {"Basic", "Advanced", "Rare", " Epic", "Unique"},
    Multi = false,
    Default = 1,
    Callback = function(Value)
        InvData.selectedRarity = Value
        InvData.UpdateDisplay()
    end
})

InvData.displayLabel = InvSection:AddLabel("Select options to view inventory")

function InvData.UpdateDisplay()
    if not InvData.selectedPlayer or not InvData.selectedType then
        InvData.displayLabel:Set("Select a player and type")
        return
    end
    
    local player = InvData.selectedPlayer
    
    if InvData.selectedType == "Equipped Pets" then
        local equipped = player:FindFirstChild("equippedPets")
        if equipped then
            local list = {}
            local count = 0
            for i = 1, 8 do
                local pet = equipped:FindFirstChild("pet" .. i)
                if pet and pet.Value then
                    table.insert(list, pet.Value.Name)
                    count = count + 1
                end
            end
            InvData.displayLabel:Set(count > 0 and "Equipped (" .. count .. "):\n" .. table.concat(list, "\n") or "No pets equipped")
        else
            InvData.displayLabel:Set("No equipped pets found")
        end
        
    elseif InvData.selectedType == "Ultimates" then
        local ultFolder = player:FindFirstChild("ultimatesFolder")
        if ultFolder then
            local list = {}
            for _, ultimate in pairs(ultFolder:GetChildren()) do
                if ultimate:IsA("IntValue") then
                    table.insert(list, ultimate.Name .. ": " .. ultimate.Value)
                end
            end
            InvData.displayLabel:Set(#list > 0 and table.concat(list, "\n") or "No ultimates")
        else
            InvData.displayLabel:Set("No ultimates folder")
        end
        
    elseif InvData.selectedType == "Gamepasses" then
        local passes = player:FindFirstChild("ownedGamepasses")
        if passes then
            local list = {}
            for _, pass in pairs(passes:GetChildren()) do
                if pass:IsA("IntValue") then
                    table.insert(list, pass.Name)
                end
            end
            InvData.displayLabel:Set(#list > 0 and "Gamepasses:\n" .. table.concat(list, "\n") or "No gamepasses")
        else
            InvData.displayLabel:Set("No gamepasses folder")
        end
        
    else
        -- Pets or Auras
        if not InvData.selectedRarity then
            InvData.displayLabel:Set("Select a rarity")
            return
        end
        
        local folderName = InvData.selectedType == "Pets" and "petsFolder" or "powerUpsFolder"
        local folder = player:FindFirstChild(folderName)
        
        if folder then
            local rarityFolder = folder:FindFirstChild(InvData.selectedRarity)
            if rarityFolder then
                local counts = {}
                local total = 0
                for _, item in pairs(rarityFolder:GetChildren()) do
                    if item:IsA("StringValue") then
                        counts[item.Name] = (counts[item.Name] or 0) + 1
                        total = total + 1
                    end
                end
                
                local list = {}
                for name, count in pairs(counts) do
                    table.insert(list, name .. " x" .. count)
                end
                
                InvData.displayLabel:Set(total > 0 and InvData.selectedRarity .. " " .. InvData.selectedType .. " (" .. total .. "):\n" .. table.concat(list, "\n") or "No " .. InvData.selectedRarity .. " items")
            else
                InvData.displayLabel:Set("No " .. InvData.selectedRarity .. " folder")
            end
        else
            InvData.displayLabel:Set("No " .. folderName)
        end
    end
end

-- Update player lists
task.spawn(function()
    while true do
        local players = {}
        for _, p in pairs(GameServices.Players:GetPlayers()) do
            table.insert(players, p.DisplayName .. " | " .. p.Name)
        end
        
        if InvData.plrDrop then
            InvData.plrDrop:SetValues(players)
        end
        
        task.wait(5)
    end
end)

-- Auto-update inventory display
task.spawn(function()
    while true do
        if InvData.selectedPlayer and InvData.selectedType then
            InvData.UpdateDisplay()
        end
        task.wait(2)
    end
end)

-- Misc Section
local MiscSection = StatsTab:AddSection("Miscellaneous")
local MiscConnections = {}

MiscSection:AddToggle("HideFrames", {
    Title = "Hide Frames",
    Default = false,
    Callback = function(State)
        for _, obj in pairs(GameServices.ReplicatedStorage:GetChildren()) do
            if obj:IsA("Frame") or obj.Name:match("Frame$") then
                obj.Visible = not State
            end
        end
    end
})

MiscSection:AddToggle("LockPosition", {
    Title = "Lock Position",
    Default = false,
    Callback = function(State)
        local char = GameContext.player.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hrp or not hum then return end
        
        if State then
            local cf = hrp.CFrame
            hrp.Anchored = true
            hum.PlatformStand = true
            hrp.CFrame = cf
        else
            hrp.Anchored = false
            hum.PlatformStand = false
        end
    end
})

MiscSection:AddToggle("AntiAFK", {
    Title = "Anti-AFK",
    Default = false,
    Callback = function(State)
        if MiscConnections.AntiAFK then
            MiscConnections.AntiAFK:Disconnect()
            MiscConnections.AntiAFK = nil
        end
        
        if State then
            MiscConnections.AntiAFK = GameServices.RunService.Heartbeat:Connect(function()
                local VirtualUser = game:GetService("VirtualUser")
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.new())
            end)
        end
    end
})

MiscSection:AddToggle("AntiKnockback", {
    Title = "Anti-Knockback",
    Default = false,
    Callback = function(State)
        local char = GameContext.player.Character
        if not char then return end
        
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        
        if State then
            local bv = Instance.new("BodyVelocity")
            bv.Name = "AntiKnockback"
            bv.MaxForce = Vector3.new(100000, 0, 100000)
            bv.Velocity = Vector3.new(0, 0, 0)
            bv.P = 1250
            bv.Parent = hrp
        else
            local bv = hrp:FindFirstChild("AntiKnockback")
            if bv then bv:Destroy() end
        end
    end
})

MiscSection:AddToggle("RemovePortals", {
    Title = "Remove Portals",
    Default = false,
    Callback = function(State)
        if State then
            for _, obj in pairs(game:GetDescendants()) do
                if obj.Name == "RobloxForwardPortals" then
                    obj:Destroy()
                end
            end
            MiscConnections.PortalRemoval = game.DescendantAdded:Connect(function(desc)
                if desc.Name == "RobloxForwardPortals" then
                    desc:Destroy()
                end
            end)
        else
            if MiscConnections.PortalRemoval then
                MiscConnections.PortalRemoval:Disconnect()
                MiscConnections.PortalRemoval = nil
            end
        end
    end
})

MiscSection:AddToggle("WalkOnWater", {
    Title = "Walk on Water",
    Default = false,
    Callback = function(State)
        if State then
            _G.WalkOnWaterParts = {}
            local startPos = Vector3.new(-2, -9.5, -2)
            local size = 2048
            local steps = math.ceil(50000 / size)
            
            for x = 0, steps - 1 do
                for z = 0, steps - 1 do
                    for _, offset in pairs({
                        Vector3.new(x * size, 0, z * size),
                        Vector3.new(-x * size, 0, z * size),
                        Vector3.new(x * size, 0, -z * size),
                        Vector3.new(-x * size, 0, -z * size)
                    }) do
                        local part = Instance.new("Part")
                        part.Size = Vector3.new(size, 1, size)
                        part.Position = startPos + offset
                        part.Anchored = true
                        part.CanCollide = true
                        part.Transparency = 1
                        part.Name = "WaterWalkPart"
                        part.Parent = GameServices.Workspace
                        table.insert(_G.WalkOnWaterParts, part)
                    end
                end
            end
        else
            if _G.WalkOnWaterParts then
                for _, part in ipairs(_G.WalkOnWaterParts) do
                    if part then part:Destroy() end
                end
                _G.WalkOnWaterParts = {}
            end
        end
    end
})

-- ==================== KILL TAB ====================
local KillerSystem = {
    Players = GameServices.Players,
    LocalPlayer = GameContext.player,
    Whitelist = {},
    Blacklist = {},
    TargetedPlayers = {},
    Config = {
        killAuraRange = 50,
        killMethod = "Normal",
        spyTarget = nil
    },
    State = {
        isKilling = false,
        killAuraEnabled = false,
        spyEnabled = false
    },
    Threads = {}
}

-- Whitelist Section
local WhitelistSection = KillTab:AddSection("Whitelist")

WhitelistSection:AddToggle("AutoWhitelistFriends", {
    Title = "Auto Whitelist Friends",
    Default = false,
    Callback = function(State)
        if KillerSystem.Threads.WhitelistFriends then
            task.cancel(KillerSystem.Threads.WhitelistFriends)
            KillerSystem.Threads.WhitelistFriends = nil
        end
        
        if State then
            KillerSystem.Threads.WhitelistFriends = task.spawn(function()
                while true do
                    for _, player in pairs(KillerSystem.Players:GetPlayers()) do
                        if player:IsFriendsWith(KillerSystem.LocalPlayer.UserId) then
                            KillerSystem.Whitelist[player.UserId] = true
                        end
                    end
                    task.wait(5)
                end
            end)
        end
    end
})

local WhitelistDropdown = WhitelistSection:AddDropdown("WhitelistSelect", {
    Title = "Add Players to Whitelist",
    Values = {},
    Multi = true,
    Default = {},
    Callback = function(Values)
        for _, name in ipairs(Values) do
            for _, player in pairs(KillerSystem.Players:GetPlayers()) do
                if player.Name == name then
                    KillerSystem.Whitelist[player.UserId] = true
                    break
                end
            end
        end
    end
})

WhitelistSection:AddButton("ClearWhitelist", {
    Title = "Clear Whitelist",
    Callback = function()
        KillerSystem.Whitelist = {}
        Library:Notify({Title = "Whitelist", Content = "Cleared!", Duration = 2})
    end
})

-- Blacklist Section
local BlacklistSection = KillTab:AddSection("Blacklist")

local BlacklistDropdown = BlacklistSection:AddDropdown("BlacklistSelect", {
    Title = "Add Players to Blacklist",
    Values = {},
    Multi = true,
    Default = {},
    Callback = function(Values)
        for _, name in ipairs(Values) do
            for _, player in pairs(KillerSystem.Players:GetPlayers()) do
                if player.Name == name then
                    KillerSystem.Blacklist[player.UserId] = true
                    break
                end
            end
        end
    end
})

BlacklistSection:AddButton("ClearBlacklist", {
    Title = "Clear Blacklist",
    Callback = function()
        KillerSystem.Blacklist = {}
        Library:Notify({Title = "Blacklist", Content = "Cleared!", Duration = 2})
    end
})

-- Killer Section
local KillerSection = KillTab:AddSection("Killer")

KillerSection:AddDropdown("KillMethod", {
    Title = "Combat Method",
    Values = {"Normal", "Teleporting"},
    Multi = false,
    Default = 1,
    Callback = function(Value)
        KillerSystem.Config.killMethod = Value
    end
})

KillerSection:AddToggle("CombatMode", {
    Title = "Combat Mode",
    Default = false,
    Callback = function(State)
        KillerSystem.State.isKilling = State
        if KillerSystem.Threads.Combat then
            task.cancel(KillerSystem.Threads.Combat)
            KillerSystem.Threads.Combat = nil
        end
        
        if State then
            KillerSystem.Threads.Combat = task.spawn(function()
                while true do
                    local char = KillerSystem.LocalPlayer.Character
                    if char then
                        local tool = char:FindFirstChild("Punch") or KillerSystem.LocalPlayer.Backpack:FindFirstChild("Punch")
                        if tool and tool.Parent ~= char then
                            tool.Parent = char
                        end
                        
                        local muscleEvent = KillerSystem.LocalPlayer:FindFirstChild("muscleEvent")
                        if muscleEvent then
                            muscleEvent:FireServer("punch", "rightHand")
                            muscleEvent:FireServer("punch", "leftHand")
                        end
                    end
                    task.wait(0.1)
                end
            end)
        end
    end
})

-- Kill Aura Section
local KillAuraSection = KillTab:AddSection("Kill Aura")

KillAuraSection:AddSlider("AuraRange", {
    Title = "Kill Aura Range",
    Min = 10,
    Max = 100,
    Default = 50,
    Callback = function(Value)
        KillerSystem.Config.killAuraRange = Value
    end
})

KillAuraSection:AddToggle("KillAura", {
    Title = "Kill Aura",
    Default = false,
    Callback = function(State)
        KillerSystem.State.killAuraEnabled = State
        if KillerSystem.Threads.KillAura then
            task.cancel(KillerSystem.Threads.KillAura)
            KillerSystem.Threads.KillAura = nil
        end
        
        if State then
            KillerSystem.Threads.KillAura = task.spawn(function()
                while true do
                    local char = KillerSystem.LocalPlayer.Character
                    if char and char:FindFirstChild("HumanoidRootPart") then
                        local root = char.HumanoidRootPart
                        
                        for _, player in pairs(KillerSystem.Players:GetPlayers()) do
                            if player ~= KillerSystem.LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                                if not KillerSystem.Whitelist[player.UserId] then
                                    local targetRoot = player.Character.HumanoidRootPart
                                    if (root.Position - targetRoot.Position).Magnitude <= KillerSystem.Config.killAuraRange then
                                        local leftHand = char:FindFirstChild("LeftHand")
                                        local rightHand = char:FindFirstChild("RightHand")
                                        
                                        if leftHand then
                                            firetouchinterest(targetRoot, leftHand, 0)
                                            firetouchinterest(targetRoot, leftHand, 1)
                                        end
                                        if rightHand then
                                            firetouchinterest(targetRoot, rightHand, 0)
                                            firetouchinterest(targetRoot, rightHand, 1)
                                        end
                                    end
                                end
                            end
                        end
                    end
                    task.wait(0.05)
                end
            end)
        end
    end
})

-- Target Section
local TargetSection = KillTab:AddSection("Target Player")

local TargetDropdown = TargetSection:AddDropdown("TargetSelect", {
    Title = "Select Players to Target",
    Values = {},
    Multi = true,
    Default = {},
    Callback = function(Values)
        KillerSystem.TargetedPlayers = {}
        for _, name in ipairs(Values) do
            for _, player in pairs(KillerSystem.Players:GetPlayers()) do
                if player.Name == name then
                    KillerSystem.TargetedPlayers[player.UserId] = player
                    break
                end
            end
        end
    end
})

TargetSection:AddToggle("AutoKillTarget", {
    Title = "Auto Kill Targeted Players",
    Default = false,
    Callback = function(State)
        if KillerSystem.Threads.AutoKill then
            task.cancel(KillerSystem.Threads.AutoKill)
            KillerSystem.Threads.AutoKill = nil
        end
        
        if State then
            KillerSystem.Threads.AutoKill = task.spawn(function()
                while true do
                    for userId, player in pairs(KillerSystem.TargetedPlayers) do
                        if player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                            local char = KillerSystem.LocalPlayer.Character
                            if char and char:FindFirstChild("HumanoidRootPart") then
                                local targetRoot = player.Character.HumanoidRootPart
                                local leftHand = char:FindFirstChild("LeftHand")
                                local rightHand = char:FindFirstChild("RightHand")
                                
                                if leftHand then
                                    firetouchinterest(targetRoot, leftHand, 0)
                                    firetouchinterest(targetRoot, leftHand, 1)
                                end
                                if rightHand then
                                    firetouchinterest(targetRoot, rightHand, 0)
                                    firetouchinterest(targetRoot, rightHand, 1)
                                end
                            end
                        end
                    end
                    task.wait(0.1)
                end
            end)
        end
    end
})

-- Spectate Section
local SpySection = KillTab:AddSection("Spectate")

local SpyDropdown = SpySection:AddDropdown("SpySelect", {
    Title = "Spy Player Selection",
    Values = {},
    Multi = false,
    Default = 1,
    Callback = function(Value)
        for _, player in pairs(KillerSystem.Players:GetPlayers()) do
            if player.Name == Value then
                KillerSystem.Config.spyTarget = player
                break
            end
        end
    end
})

SpySection:AddToggle("SpyMode", {
    Title = "Enable Spy Mode",
    Default = false,
    Callback = function(State)
        KillerSystem.State.spyEnabled = State
        if State and KillerSystem.Config.spyTarget and KillerSystem.Config.spyTarget.Character then
            local hum = KillerSystem.Config.spyTarget.Character:FindFirstChildOfClass("Humanoid")
            workspace.CurrentCamera.CameraSubject = hum or KillerSystem.Config.spyTarget.Character
        else
            local char = KillerSystem.LocalPlayer.Character
            if char then
                workspace.CurrentCamera.CameraSubject = char:FindFirstChildOfClass("Humanoid") or char
            end
        end
    end
})

-- Update player lists for Kill Tab
local function UpdateKillTabPlayers()
    local players = {}
    for _, p in pairs(GameServices.Players:GetPlayers()) do
        if p ~= GameContext.player then
            table.insert(players, p.Name)
        end
    end
    
    if WhitelistDropdown then WhitelistDropdown:SetValues(players) end
    if BlacklistDropdown then BlacklistDropdown:SetValues(players) end
    if TargetDropdown then TargetDropdown:SetValues(players) end
    if SpyDropdown then SpyDropdown:SetValues(players) end
end

GameServices.Players.PlayerAdded:Connect(UpdateKillTabPlayers)
GameServices.Players.PlayerRemoving:Connect(UpdateKillTabPlayers)
task.spawn(function()
    task.wait(1)
    UpdateKillTabPlayers()
end)

-- ==================== TELEPORT TAB ====================
local TeleportSection = TeleportTab:AddSection("Locations")

local TeleportLocations = {
    {Name = "Spawn", CFrame = CFrame.new(2, 8, 115)},
    {Name = "Secret", CFrame = CFrame.new(1947, 2, 6191)},
    {Name = "Tiny", CFrame = CFrame.new(-34, 7, 1903)},
    {Name = "Frozen", CFrame = CFrame.new(-2600, 3, -403)},
    {Name = "Mythical", CFrame = CFrame.new(2255, 7, 1071)},
    {Name = "Inferno", CFrame = CFrame.new(-6768, 7, -1287)},
    {Name = "Legend", CFrame = CFrame.new(4604, 991, -3887)},
    {Name = "Muscle King", CFrame = CFrame.new(-8646, 17, -5738)},
    {Name = "Jungle", CFrame = CFrame.new(-8659, 6, 2384)},
    {Name = "Lava Brawl", CFrame = CFrame.new(4471, 119, -8836)},
    {Name = "Desert Brawl", CFrame = CFrame.new(960, 17, -7398)},
    {Name = "Beach Brawl", CFrame = CFrame.new(-1849, 20, -6335)}
}

for _, loc in ipairs(TeleportLocations) do
    TeleportSection:AddButton("TP" .. loc.Name, {
        Title = "Teleport to " .. loc.Name,
        Callback = function()
            local char = GameContext.player.Character or GameContext.player.CharacterAdded:Wait()
            local hrp = char:WaitForChild("HumanoidRootPart")
            hrp.CFrame = loc.CFrame
        end
    })
end

TeleportSection:AddButton("TPSecretIsland", {
    Title = "Secret Island (High)",
    Callback = function()
        local char = GameContext.player.Character or GameContext.player.CharacterAdded:Wait()
        local hrp = char:WaitForChild("HumanoidRootPart")
        hrp.CFrame = CFrame.new(50000, 50010, 400000)
    end
})

-- ==================== CALCULATE STATS TAB ====================
local CalcSection = CalculateStatsTab:AddSection("Rebirth Calculator")

_G.SelectedRarity = "Unique"
_G.RebirthNumber = 0

local PetTable = {
    ["Unique Pet"] = {0, 1250, 3750, 7500, 12500, 18750, 26250, 35000, 45000, 56250, 68750, 82500, 97500, 113750, 131250, 150000, 170000, 191250, 213750, 237500},
    ["Epic Pet"] = {0, 1000, 3000, 6000, 10000, 15000, 21000, 28000, 36000, 45000, 55000, 66000, 78000, 91000, 105000, 120000, 136000, 153000, 171000, 190000, 210000},
    ["Basic Pet"] = {0, 250, 750, 1500, 2500, 3750, 5250, 7000, 9000, 11250, 13750, 16500, 19500, 22750, 26250, 30000, 34000, 38250, 42750, 47500, 52500},
    ["Unique Aura"] = {0, 3000, 7500, 13500, 21000, 30000, 40500, 52500, 66000, 81000, 97500, 115500, 135000, 156000, 178500, 202500, 228000, 255000, 283500, 313500, 345000},
}

CalcSection:AddDropdown("CalcRarity", {
    Title = "Rarity",
    Values = {"Basic", "Advanced", "Rare", "Epic", "Unique"},
    Multi = false,
    Default = 5,
    Callback = function(Value)
        _G.SelectedRarity = Value
    end
})

CalcSection:AddInput("CalcRebirth", {
    Title = "Rebirth Number",
    Placeholder = "0",
    Default = "",
    Callback = function(Value)
        _G.RebirthNumber = tonumber(Value) or 0
    end
})

local CalcResultLabel = CalcSection:AddLabel("Enter values to calculate")

local RockTable = {
    {"Jungle Rock", 16.25},
    {"Muscle King Rock", 12.5},
    {"Legends Rock", 2.5},
    {"Inferno Rock", 1.125},
    {"Mythical Rock", 0.75},
    {"Frost Rock", 0.375},
    {"Golden Rock", 0.2},
    {"Large Rock", 0.075},
    {"Punching Rock", 0.05},
    {"Tiny Rock", 0.025}
}

local function CalculateAuraStats(rebirths, petType, rarityMultiplier)
    local data = PetTable[petType]
    if not data then return 0 end
    
    if petType:find("Aura") and petType:find("Unique") then
        local level = 0
        for i = 2, #data do
            if data[i] > rebirths then break end
            level = level + 1
        end
        return (level + 1) * rarityMultiplier
    end
    
    if not petType:find("Aura") then
        local level = 1
        for i, val in ipairs(data) do
            if val > rebirths then break end
            level = i
        end
        return (level - 1) * rarityMultiplier
    end
    
    local level = 0
    for i = 2, #data do
        if data[i] > rebirths then break end
        level = level + 1
    end
    return level * rarityMultiplier
end

local function CalculateSingle(rockName, multiplier, petType, rarityMultiplier)
    local petData = PetTable[petType]
    if not petData then return rockName .. ": Invalid type" end
    
    local targetRebirths = (_G.RebirthNumber or 0 + 20) * multiplier
    if targetRebirths ~= math.floor(targetRebirths) or petData[#petData] < targetRebirths then
        return rockName .. ": Not Glitchable"
    end
    
    local exactRebirths = math.floor(targetRebirths)
    
    -- Check exact match
    for _, val in ipairs(petData) do
        if exactRebirths == val then
            return rockName .. ": Level 1, 0xp | " .. CalculateAuraStats(exactRebirths, petType, rarityMultiplier) .. " Stats"
        end
    end
    
    -- Find closest lower level
    local lowerBound = nil
    for _, val in ipairs(petData) do
        if exactRebirths < val then break end
        lowerBound = val
    end
    
    if not lowerBound then return rockName .. ": Not Glitchable" end
    
    local xp = lowerBound - exactRebirths
    local remaining = xp
    local level = 1
    
    for i = 2, #petData do
        if petData[i] >= remaining then break end
        remaining = remaining - petData[i]
        level = i
    end
    
    return rockName .. ": Level " .. level .. ", " .. remaining .. "xp | " .. CalculateAuraStats(exactRebirths, petType, rarityMultiplier) .. " Stats"
end

local function UpdateCalc()
    local rebirthNum = _G.RebirthNumber or 0
    if rebirthNum <= 0 then
        CalcResultLabel:Set("Enter a rebirth number")
        return
    end
    
    local rarity = _G.SelectedRarity or "Unique"
    local multipliers = {Basic = 1, Advanced = 2, Rare = 3, Epic = 4, Unique = 5}
    local rm = multipliers[rarity] or 5
    
    local petName = rarity .. " Pet"
    local auraName = rarity .. " Aura"
    
    local result = "PETS:\n"
    for _, rock in ipairs(RockTable) do
        result = result .. CalculateSingle(rock[1], rock[2], petName, rm) .. "\n"
    end
    
    result = result .. "\nAURAS:\n"
    for _, rock in ipairs(RockTable) do
        result = result .. CalculateSingle(rock[1], rock[2], auraName, rm) .. "\n"
    end
    
    CalcResultLabel:Set(result)
end

-- Auto-update calculator
task.spawn(function()
    while true do
        UpdateCalc()
        task.wait(2)
    end
end)

-- Combat Calculator Section
local CombatCalcSection = CalculateStatsTab:AddSection("Combat Calculator")

local function GetPlayerDamage(player)
    if not player then return 0 end
    local stats = player:FindFirstChild("leaderstats")
    if stats and stats:FindFirstChild("Strength") then
        return stats.Strength.Value * 0.0667
    end
    return 0
end

local function GetPlayerHealth(player)
    if not player then return 100 end
    local stats = player:FindFirstChild("leaderstats")
    if stats and stats:FindFirstChild("Durability") then
        return stats.Durability.Value
    end
    return 100
end

local CombatPlayerDropdown = CombatCalcSection:AddDropdown("CombatPlayer", {
    Title = "Select Player",
    Values = {},
    Multi = false,
    Default = 1,
    Callback = function(Value)
        local target = nil
        for _, p in pairs(GameServices.Players:GetPlayers()) do
            if p.Name == Value then
                target = p
                break
            end
        end
        
        if not target then
            CombatResultLabel:Set("Player not found")
            return
        end
        
        local myDmg = GetPlayerDamage(GameContext.player)
        local myHp = GetPlayerHealth(GameContext.player)
        local theirDmg = GetPlayerDamage(target)
        local theirHp = GetPlayerHealth(target)
        
        local result = string.format(
            "YOU vs %s\n\nYour Damage: %.1f\nYour Health: %.0f\n\nTheir Damage: %.1f\nTheir Health: %.0f\n\n",
            target.Name, myDmg, myHp, theirDmg, theirHp
        )
        
        if myDmg > theirDmg then
            result = result .. "You deal more damage!"
        elseif theirDmg > myDmg then
            result = result .. "They deal more damage!"
        else
            result = result .. "Equal damage!"
        end
        
        CombatResultLabel:Set(result)
    end
})

local CombatResultLabel = CombatCalcSection:AddLabel("Select a player to compare")

-- Update combat players
task.spawn(function()
    while true do
        local players = {}
        for _, p in pairs(GameServices.Players:GetPlayers()) do
            if p ~= GameContext.player then
                table.insert(players, p.Name)
            end
        end
        if CombatPlayerDropdown then CombatPlayerDropdown:SetValues(players) end
        task.wait(5)
    end
end)

-- ==================== CRYSTALS TAB ====================
local ShopSection = CrystalsTab:AddSection("Pet Shop")

local CrystalData = {
    ["Blue Crystal"] = {"Blue Birdie | Basic", "Orange Hedgehog | Basic", "Blue Aura | Basic"},
    ["Green Crystal"] = {"Silver Dog | Basic", "Electro | Advanced", "Purple Nova | Advanced"},
    ["Frost Crystal"] = {"Electro | Advanced", "Purple Nova | Advanced", "Yellow Butterfly | Advanced"},
    ["Mythical Crystal"] = {"Astral Electro | Rare", "Dark Electro | Rare", "Power Lightning | Rare"},
    ["Inferno Crystal"] = {"Azure Tundra | Epic", "Enchanted Mirage | Epic", "Grand Supernova | Epic"},
    ["Legends Crystal"] = {"Azure Tundra | Epic", "Enchanted Mirage | Epic", "Grand Supernova | Epic"},
}

local CrystalList = {}
for k in pairs(CrystalData) do table.insert(CrystalList, k) end
table.sort(CrystalList)

local SelectedCrystal = CrystalList[1]
local SelectedPet = nil
local AutoBuyThread = nil

ShopSection:AddDropdown("CrystalSelect", {
    Title = "Crystal",
    Values = CrystalList,
    Multi = false,
    Default = 1,
    Callback = function(Value)
        SelectedCrystal = Value
    end
})

local PetDropdown = ShopSection:AddDropdown("PetSelect", {
    Title = "Pet",
    Values = CrystalData[SelectedCrystal] or {},
    Multi = false,
    Default = {},
    Callback = function(Value)
        SelectedPet = Value and Value:match("^(.-) |") or Value
    end
})

-- Update pets when crystal changes
task.spawn(function()
    while true do
        if SelectedCrystal and PetDropdown then
            PetDropdown:SetValues(CrystalData[SelectedCrystal] or {})
        end
        task.wait(1)
    end
end)

ShopSection:AddToggle("AutoBuyPet", {
    Title = "Auto Buy Selected Pet",
    Default = false,
    Callback = function(State)
        if AutoBuyThread then
            task.cancel(AutoBuyThread)
            AutoBuyThread = nil
        end
        
        if State then
            AutoBuyThread = task.spawn(function()
                while SelectedPet do
                    pcall(function()
                        local folder = GameServices.ReplicatedStorage:WaitForChild("cPetShopFolder")
                        local pet = folder:FindFirstChild(SelectedPet)
                        if pet then
                            GameServices.ReplicatedStorage:WaitForChild("cPetShopRemote"):InvokeServer(pet)
                        end
                    end)
                    task.wait(1)
                end
            end)
        end
    end
})

-- Ultimates Section
local UltimatesSection = CrystalsTab:AddSection("Ultimates")
local SelectedUltimate = nil
local AutoUltimateThread = nil

UltimatesSection:AddDropdown("UltimateSelect", {
    Title = "Ultimate",
    Values = {"+1 Daily Spin", "+1 Pet Slot", "+10 Item Capacity", "+5% Rep Speed", "Demon Damage", "Galaxy Gains"},
    Multi = false,
    Default = 1,
    Callback = function(Value)
        SelectedUltimate = Value
    end
})

UltimatesSection:AddToggle("AutoUpgradeUlt", {
    Title = "Auto Upgrade Ultimate",
    Default = false,
    Callback = function(State)
        if AutoUltimateThread then
            task.cancel(AutoUltimateThread)
            AutoUltimateThread = nil
        end
        
        if State then
            AutoUltimateThread = task.spawn(function()
                while SelectedUltimate do
                    pcall(function()
                        GameServices.ReplicatedStorage:WaitForChild("rEvents"):WaitForChild("ultimatesRemote"):InvokeServer("upgradeUltimate", SelectedUltimate)
                    end)
                    task.wait(1)
                end
            end)
        end
    end
})

-- Equip Pets Section
local EquipSection = CrystalsTab:AddSection("Equip Pets")
local PetNames = {"Swift Samurai", "Wild Wizard", "Tribal Overlord", "Mighty Monster", "Sarge", "Small Fry", "Speedy Sally", "Chaos Sorcerer"}

for _, pet in ipairs(PetNames) do
    EquipSection:AddButton("Equip" .. pet, {
        Title = "Equip " .. pet,
        Callback = function()
            pcall(function()
                GameServices.ReplicatedStorage:WaitForChild("rEvents"):WaitForChild("equipPetEvent"):FireServer("unequipAll")
                task.wait(0.1)
                GameServices.ReplicatedStorage:WaitForChild("rEvents"):WaitForChild("equipPetEvent"):FireServer("equipPet", pet)
            end)
        end
    })
end

-- ==================== ROCK TAB ====================
local RockSection = RockTab:AddSection("Auto Rock")

local RockData = {
    {name = "Tiny Rock", durability = 0},
    {name = "Punching Rock", durability = 10},
    {name = "Large Rock", durability = 100},
    {name = "Golden Rock", durability = 5000},
    {name = "Frost Rock", durability = 150000},
    {name = "Mythical Rock", durability = 400000},
    {name = "Inferno Rock", durability = 750000},
    {name = "Legend Rock", durability = 1000000},
    {name = "Muscle King Rock", durability = 5000000},
    {name = "Jungle Rock", durability = 10000000}
}

local RockNames = {}
for _, v in ipairs(RockData) do table.insert(RockNames, v.name) end

local RockConfig = {
    selected = nil,
    autoFarmThread = nil
}

RockSection:AddDropdown("RockSelect", {
    Title = "Select Rock",
    Values = RockNames,
    Multi = false,
    Default = 1,
    Callback = function(Value)
        RockConfig.selected = Value
    end
})

RockSection:AddToggle("AutoRockFarm", {
    Title = "Auto Rock Farm",
    Default = false,
    Callback = function(State)
        if RockConfig.autoFarmThread then
            task.cancel(RockConfig.autoFarmThread)
            RockConfig.autoFarmThread = nil
        end
        
        if not (State and RockConfig.selected) then return end
        
        local rockInfo = nil
        for _, v in ipairs(RockData) do
            if v.name == RockConfig.selected then
                rockInfo = v
                break
            end
        end
        if not rockInfo then return end
        
        RockConfig.autoFarmThread = task.spawn(function()
            while true do
                local char = GameContext.player.Character
                local backpack = GameContext.player:WaitForChild("Backpack", 1)
                local durability = GameContext.player:FindFirstChild("Durability")
                
                if char and durability and durability.Value >= rockInfo.durability then
                    local machines = GameServices.Workspace:FindFirstChild("machinesFolder")
                    if machines then
                        for _, machine in ipairs(machines:GetChildren()) do
                            local needed = machine:FindFirstChild("neededDurability")
                            local rock = machine:FindFirstChild("Rock")
                            
                            if needed and rock and needed.Value == rockInfo.durability then
                                -- Equip punch
                                if not char:FindFirstChild("Punch") and backpack and backpack:FindFirstChild("Punch") then
                                    backpack.Punch.Parent = char
                                    task.wait(0.1)
                                end
                                
                                local punch = char:FindFirstChild("Punch")
                                if punch then
                                    local left = char:FindFirstChild("LeftHand")
                                    local right = char:FindFirstChild("RightHand")
                                    
                                    if left and right then
                                        for i = 1, 3 do
                                            firetouchinterest(left, rock, 0)
                                            firetouchinterest(left, rock, 1)
                                            firetouchinterest(right, rock, 0)
                                            firetouchinterest(right, rock, 1)
                                        end
                                        
                                        local muscleEvent = GameContext.player:FindFirstChild("muscleEvent")
                                        if muscleEvent then
                                            muscleEvent:FireServer("punch", "leftHand")
                                            muscleEvent:FireServer("punch", "rightHand")
                                        end
                                        punch:Activate()
                                    end
                                end
                                break
                            end
                        end
                    end
                end
                task.wait(0.1)
            end
        end)
    end
})

-- ==================== GIFT TAB ====================
local SnacksSection = GiftTab:AddSection("Snacks Eater")

local SnackData = {
    selected = {},
    eatingThread = nil,
    specialSnack = nil,
    quantity = 1
}

SnacksSection:AddDropdown("SnackSelect", {
    Title = "Select Snacks",
    Values = {"Energy Bar", "Protein Bar", "Protein Shake", "TOUGH Bar", "ULTRA Shake", "Protein Egg", "Tropical Shake"},
    Multi = true,
    Default = {},
    Callback = function(Values)
        SnackData.selected = Values
    end
})

SnacksSection:AddDropdown("SpecialSnack", {
    Title = "Special Snack",
    Values = {"Protein Egg", "Tropical Shake"},
    Multi = false,
    Default = 1,
    Callback = function(Value)
        SnackData.specialSnack = Value
    end
})

SnacksSection:AddInput("SnackQty", {
    Title = "Quantity",
    Placeholder = "1",
    Default = "1",
    Callback = function(Value)
        SnackData.quantity = tonumber(Value) or 1
    end
})

SnacksSection:AddButton("EatSpecial", {
    Title = "Eat Special Snacks",
    Callback = function()
        if not SnackData.specialSnack then return end
        for i = 1, SnackData.quantity do
            local char = GameContext.player.Character
            local bp = GameContext.player:WaitForChild("Backpack", 1)
            local item = (char and char:FindFirstChild(SnackData.specialSnack)) or (bp and bp:FindFirstChild(SnackData.specialSnack))
            
            if not item then break end
            
            local muscleEvent = GameContext.player:FindFirstChild("muscleEvent")
            if muscleEvent then
                local cleanName = SnackData.specialSnack:gsub(" ", ""):lower()
                muscleEvent:FireServer(cleanName, item)
            end
            task.wait(0.1)
        end
    end
})

SnacksSection:AddToggle("AutoEatSnacks", {
    Title = "Auto Eat Snacks",
    Default = false,
    Callback = function(State)
        if SnackData.eatingThread then
            task.cancel(SnackData.eatingThread)
            SnackData.eatingThread = nil
        end
        
        if State then
            SnackData.eatingThread = task.spawn(function()
                while true do
                    if #SnackData.selected > 0 then
                        for _, snack in ipairs(SnackData.selected) do
                            local char = GameContext.player.Character
                            local bp = GameContext.player:WaitForChild("Backpack", 1)
                            local item = (char and char:FindFirstChild(snack)) or (bp and bp:FindFirstChild(snack))
                            
                            if item then
                                local muscleEvent = GameContext.player:FindFirstChild("muscleEvent")
                                if muscleEvent then
                                    muscleEvent:FireServer(snack:gsub(" ", ""):lower(), item)
                                end
                            end
                        end
                    end
                    task.wait(0.5)
                end
            end)
        end
    end
})

-- Gift Section
local GiftSection = GiftTab:AddSection("Gift Items")

local GiftData = {
    eggPlayer = nil,
    eggCount = 1,
    shakePlayer = nil,
    shakeCount = 1,
    autoEatThread = nil
}

local function GetPlayers()
    local list = {}
    for _, p in pairs(GameServices.Players:GetPlayers()) do
        if p ~= GameContext.player then
            table.insert(list, p.Name)
        end
    end
    return list
end

local EggPlayerDropdown = GiftSection:AddDropdown("EggPlayer", {
    Title = "Choose Player (Eggs)",
    Values = GetPlayers(),
    Multi = false,
    Default = 1,
    Callback = function(Value)
        GiftData.eggPlayer = GameServices.Players:FindFirstChild(Value)
    end
})

GiftSection:AddInput("EggQty", {
    Title = "Amount (Eggs)",
    Placeholder = "1",
    Default = "1",
    Callback = function(Value)
        GiftData.eggCount = tonumber(Value) or 1
    end
})

GiftSection:AddButton("GiftEggs", {
    Title = "Start Gifting Eggs",
    Callback = function()
        if GiftData.eggPlayer and GiftData.eggCount > 0 then
            for i = 1, GiftData.eggCount do
                pcall(function()
                    local folder = GameContext.player:WaitForChild("consumablesFolder", 1)
                    if folder then
                        local egg = folder:FindFirstChild("Protein Egg")
                        if egg then
                            GameServices.ReplicatedStorage:WaitForChild("rEvents"):WaitForChild("giftRemote"):InvokeServer("giftRequest", GiftData.eggPlayer, egg)
                        end
                    end
                end)
                task.wait(0.1)
            end
        end
    end
})

local ShakePlayerDropdown = GiftSection:AddDropdown("ShakePlayer", {
    Title = "Choose Player (Shakes)",
    Values = GetPlayers(),
    Multi = false,
    Default = 1,
    Callback = function(Value)
        GiftData.shakePlayer = GameServices.Players:FindFirstChild(Value)
    end
})

GiftSection:AddInput("ShakeQty", {
    Title = "Amount (Shakes)",
    Placeholder = "1",
    Default = "1",
    Callback = function(Value)
        GiftData.shakeCount = tonumber(Value) or 1
    end
})

GiftSection:AddButton("GiftShakes", {
    Title = "Start Gifting Shakes",
    Callback = function()
        if GiftData.shakePlayer and GiftData.shakeCount > 0 then
            for i = 1, GiftData.shakeCount do
                pcall(function()
                    local folder = GameContext.player:WaitForChild("consumablesFolder", 1)
                    if folder then
                        local shake = folder:FindFirstChild("Tropical Shake")
                        if shake then
                            GameServices.ReplicatedStorage:WaitForChild("rEvents"):WaitForChild("giftRemote"):InvokeServer("giftRequest", GiftData.shakePlayer, shake)
                        end
                    end
                end)
                task.wait(0.1)
            end
        end
    end
})

GiftSection:AddToggle("AutoEatEggs", {
    Title = "Auto Eat Protein Eggs",
    Default = false,
    Callback = function(State)
        if GiftData.autoEatThread then
            task.cancel(GiftData.autoEatThread)
            GiftData.autoEatThread = nil
        end
        
        if State then
            GiftData.autoEatThread = task.spawn(function()
                while true do
                    local char = GameContext.player.Character
                    local bp = GameContext.player:WaitForChild("Backpack", 1)
                    local egg = (char and char:FindFirstChild("Protein Egg")) or (bp and bp:FindFirstChild("Protein Egg"))
                    
                    if egg then
                        local muscleEvent = GameContext.player:FindFirstChild("muscleEvent")
                        if muscleEvent then
                            muscleEvent:FireServer("proteinEgg", egg)
                        end
                    end
                    task.wait(0.25)
                end
            end)
        end
    end
})

-- Update player lists for Gift Tab
GameServices.Players.PlayerAdded:Connect(function()
    local players = GetPlayers()
    if EggPlayerDropdown then EggPlayerDropdown:SetValues(players) end
    if ShakePlayerDropdown then ShakePlayerDropdown:SetValues(players) end
end)

GameServices.Players.PlayerRemoving:Connect(function()
    local players = GetPlayers()
    if EggPlayerDropdown then EggPlayerDropdown:SetValues(players) end
    if ShakePlayerDropdown then ShakePlayerDropdown:SetValues(players) end
end)
