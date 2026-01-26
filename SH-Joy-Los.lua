-- Converted to KyypieUI Library
local LIB_URL = "https://raw.githubusercontent.com/Kyypie69/Library.UI/refs/heads/main/KyypieUI.lua    "
local ok, Library = pcall(function()
    local source = game:HttpGet(LIB_URL)
    return loadstring(source)()
end)

if not ok then
    error("Failed to load UI library: " .. tostring(Library))
end

local Players = game:GetService("Players")
local player = Players.LocalPlayer
local userId = player.UserId
local thumbType = Enum.ThumbnailType.HeadShot
local thumbSize = Enum.ThumbnailSize.Size420x420
local content, isReady = Players:GetUserThumbnailAsync(userId, thumbType, thumbSize)

-- PINK-THEMED NOTIFICATIONS
game:GetService("StarterGui"):SetCore("SendNotification",{  
    Title = "KYYY HUB",     
    Text = "Welcome!",
    Icon = "",
    Duration = 3,
})

wait(3)

game:GetService("StarterGui"):SetCore("SendNotification",{  
    Title = "Hello ✨",     
    Text = player.Name,
    Icon = content,
    Duration = 2,
})

wait(3)

local Window = Library:CreateWindow({
    Title = "MARKYY x KYYY - Legends Of Speed",
    SubTitle = "Made | by Markyy",
    Size = UDim2.fromOffset(550, 400),
    TabWidth = 150,
    Theme = "Combat",
    Acrylic = false,
})

-- REFORMATTED TABS
local Home        = Window:AddTab({ Title = "Main",          Icon = "home" })
local farmingTab  = Window:AddTab({ Title = "Farming",       Icon = "leaf" })
local Rebirths    = Window:AddTab({ Title = "Rebirths",      Icon = "repeat" })
local Killer      = Window:AddTab({ Title = "Race",          Icon = "flag" })
local TeleportTab = Window:AddTab({ Title = "Locations",     Icon = "map" })
local Shop        = Window:AddTab({ Title = "Crystals",      Icon = "gem" })
local Misc        = Window:AddTab({ Title = "Miscellaneous", Icon = "menu" })
local Settings    = Window:AddTab({ Title = "Credits",       Icon = "info" })

-- MAIN SECTION
local mainSection = Home:AddSection("Main Features")

-- FIXED: Claim All Chest functionality
mainSection:AddButton({
    Title = "Claim All Chest",
    Description = "Collects all available chests in the game",
    Callback = function()
        local chests = workspace:FindFirstChild("Chests") or workspace:FindFirstChild("chests")
        if chests then
            for _, chest in pairs(chests:GetChildren()) do
                if chest:IsA("BasePart") then
                    game:GetService("ReplicatedStorage"):WaitForChild("rEvents"):WaitForChild("chestEvent"):FireServer("collectChest", chest.Name)
                    wait(0.1)
                end
            end
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "Chests",     
                Text = "Claimed all available chests!",
                Duration = 2,
            })
        else
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "Error",     
                Text = "No chests found!",
                Duration = 2,
            })
        end
    end
})

mainSection:AddButton({
    Title = "Disable Trading",
    Description = "Disables trading functionality",
    Callback = function()
        game:GetService("ReplicatedStorage").rEvents.tradingEvent:FireServer("disableTrading")
    end
})

mainSection:AddButton({
    Title = "Enable Trading",
    Description = "Enables trading functionality",
    Callback = function()
        game:GetService("ReplicatedStorage").rEvents.tradingEvent:FireServer("enableTrading")
    end
})

-- FIXED DROPDOWN: Create with proper initial values
local teleportDropdown
local function createTeleportDropdown()
    local playerList = {}
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= player then
            table.insert(playerList, v.Name)
        end
    end
    table.sort(playerList)
    
    if #playerList == 0 then
        playerList = {"No players found"}
    end
    
    teleportDropdown = mainSection:AddDropdown("TeleportPlayer", {
        Title = "Teleport To Player",
        Description = "Select a player to teleport to",
        Values = playerList,
        Default = 1,
        Callback = function(Value)
            local targetPlayer = Players:FindFirstChild(Value)
            if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
                local character = player.Character
                if character and character:FindFirstChild("HumanoidRootPart") then
                    character.HumanoidRootPart.CFrame = targetPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(0, 2, 1)
                end
            else
                warn("Target player or character not found!")
            end
        end
    })
    
    return teleportDropdown
end

-- Create initial dropdown
createTeleportDropdown()

-- Update function to refresh player list
local function updatePlayerList()
    if teleportDropdown then
        local dropdownInstance = teleportDropdown.Instance
        if dropdownInstance then
            dropdownInstance:Destroy()
        end
    end
    createTeleportDropdown()
end

-- Auto-update when players join or leave
Players.PlayerAdded:Connect(updatePlayerList)
Players.PlayerRemoving:Connect(updatePlayerList)

-- FIXED SLIDER: Added proper parameters with ID
mainSection:AddSlider("WalkSpeed", {
    Title = "Walk Speed",
    Description = "Adjust your character's walk speed",
    Default = 1000000,
    Min = 16,
    Max = 1000,
    Rounding = 0,
    Callback = function(Value)
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            player.Character.Humanoid.WalkSpeed = Value
        end
    end
})

mainSection:AddSlider("JumpPower", {
    Title = "Jump Power",
    Description = "Adjust your character's jump power",
    Default = 1000000,
    Min = 50,
    Max = 1000,
    Rounding = 0,
    Callback = function(Value)
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            player.Character.Humanoid.JumpPower = Value
        end
    end
})

-- MOVED TO MAIN TAB: Infinite Jump Toggle
mainSection:AddToggle("InfiniteJump", {
    Title = "Infinite Jump",
    Description = "Jump infinitely by pressing space",
    Default = false,
    Callback = function(Value)
        if Value then
            _G.InfiniteJumpConn = game:GetService("UserInputService").JumpRequest:Connect(function()
                if player.Character and player.Character:FindFirstChildOfClass("Humanoid") then
                    player.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
                end
            end)
        else
            if _G.InfiniteJumpConn then
                _G.InfiniteJumpConn:Disconnect()
                _G.InfiniteJumpConn = nil
            end
        end
    end
})

-- AUTO FARM SECTION - UPDATED WITH FAST COLLECTING & PERFORMANCE CONTROLS
local farmSection = farmingTab:AddSection("Auto Farm")

local selectedOrb = "Red Orbs"
local selectedFarmLocation = "City"
local collectionSpeed = 10 -- Default speed
local fpsCap = 60 -- Default FPS cap
local pingThreshold = 1000 -- Default ping threshold
local pingProtection = false

-- Cache remote event for better performance
local orbEvent = game:GetService("ReplicatedStorage"):WaitForChild("rEvents"):WaitForChild("orbEvent")

farmSection:AddDropdown("OrbType", {
    Title = "Select Orbs",
    Description = "Choose which orb type to farm",
    Values = {"Red Orbs", "Blue Orbs", "Orange Orbs", "Yellow Orbs", "Ethereal Orbs", "Gems"},
    Default = 1,
    Callback = function(Value)
        selectedOrb = Value
        print("Selected orb: " .. selectedOrb)
    end
})

farmSection:AddDropdown("FarmLocation", {
    Title = "Select Location",
    Description = "Choose farming location",
    Values = {"City", "Snow City", "Magma City", "Speed Jungle"},
    Default = 1,
    Callback = function(Value)
        selectedFarmLocation = Value
        print("Selected location: " .. selectedFarmLocation)
    end
})

-- NEW: Collection Speed Dropdown (300x, 600x, 900x)
farmSection:AddDropdown("CollectionSpeed", {
    Title = "Collection Speed",
    Description = "Select collection multiplier (Higher = Faster)",
    Values = {"300x Collecting", "600x Collecting", "900x Collecting"},
    Default = 5,
    Callback = function(Value)
        if Value == "300x Collecting" then
            collectionSpeed = 100
        elseif Value == "600x Collecting" then
            collectionSpeed = 200
        elseif Value == "900x Collecting" then
            collectionSpeed = 300
        end
        print("Collection speed set to: " .. collectionSpeed .. "x")
    end
})

-- NEW: FPS Cap Dropdown (60-120)
farmSection:AddDropdown("FPSCap", {
    Title = "Max FPS Cap",
    Description = "Limit FPS while farming (reduces lag)",
    Values = {"60 FPS", "120 FPS", "Unlimited"},
    Default = 1,
    Callback = function(Value)
        if Value == "60 FPS" then
            fpsCap = 60
        elseif Value == "120 FPS" then
            fpsCap = 120
        else
            fpsCap = 0 -- Unlimited
        end
        print("FPS Cap set to: " .. Value)
    end
})

-- Connection Enhancer Toggle
local connectionEnhancer = false
farmSection:AddToggle("ConnectionEnhancer", {
    Title = "Connection Enhancer",
    Description = "Optimizes network connection for faster orb collection",
    Default = false,
    Callback = function(Value)
        connectionEnhancer = Value
        if Value then
            settings().Network.IncomingReplicationLag = 0
            if game:GetService("NetworkClient") then
                pcall(function()
                    game:GetService("NetworkClient"):SetOutgoingKBPSLimit(0)
                end)
            end
            print("Connection Enhancer Activated")
        end
    end
})

-- Ping Stabilizer Toggle
local pingStabilizer = false
farmSection:AddToggle("PingStabilizer", {
    Title = "Ping Stabilizer",
    Description = "Stabilizes ping for consistent farming speed",
    Default = false,
    Callback = function(Value)
        pingStabilizer = Value
        if Value then
            pcall(function()
                game:GetService("PhysicsService"):SetSubsteps(1)
                settings().Physics.PhysicsEnvironmentalThrottle = Enum.EnviromentalPhysicsThrottle.Disabled
            end)
            print("Ping Stabilizer Activated")
        end
    end
})

-- NEW: Ping Protection Toggle (1000ms threshold)
farmSection:AddToggle("PingProtection", {
    Title = "Ping Protection (1000ms)",
    Description = "Pauses collection if ping exceeds 1000ms",
    Default = false,
    Callback = function(Value)
        pingProtection = Value
        if Value then
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "Ping Protection",     
                Text = "Active: Max 1000ms threshold",
                Duration = 1,
            })
        end
    end
})

-- Function to get current ping
local function getCurrentPing()
    local stats = game:GetService("Stats")
    if stats and stats.Network then
        local ping = stats.Network.ServerStatsItem["Data Ping"]
        if ping then
            return ping:GetValue()
        end
    end
    return 0
end

-- ENHANCED FAST FARM ORBS WITH FPS CAP & PING PROTECTION (NO NOTIFICATIONS)
farmSection:AddToggle("FarmOrbs", {
    Title = "Farm Selected Orbs",
    Description = "Automatically farm selected orb types at high speed",
    Default = false,
    Callback = function(Value)
        _G.FarmOrbs = Value
        if Value and selectedOrb ~= "" then
            -- Apply FPS cap when farming starts
            if fpsCap > 60 then
                pcall(function()
                    setfpscap(fpsCap)
                end)
                print("FPS capped at: " .. fpsCap)
            end
            
            spawn(function()
                -- Pre-determine orb type string for performance
                local orbType = "Red Orb"
                if selectedOrb == "Red Orbs" then
                    orbType = "Red Orb"
                elseif selectedOrb == "Blue Orbs" then
                    orbType = "Blue Orb"
                elseif selectedOrb == "Orange Orbs" then
                    orbType = "Orange Orb"
                elseif selectedOrb == "Yellow Orbs" then
                    orbType = "Yellow Orb"
                elseif selectedOrb == "Ethereal Orbs" then
                    orbType = "Ethereal Orb"
                elseif selectedOrb == "Gems" then
                    orbType = "Gem"
                end

                while _G.FarmOrbs do
                    game:GetService("RunService").Heartbeat:Wait()
                    
                    -- Check ping if protection is enabled (SILENT - NO NOTIFICATION)
                    local currentPing = getCurrentPing()
                    if pingProtection and currentPing > pingThreshold then
                        -- Skip this cycle if ping is too high (silently)
                        task.wait(0.5) -- Wait a bit before checking again
                        continue
                    end
                    
                    -- Batch fire based on collection speed
                    for i = 1, collectionSpeed do
                        task.spawn(function()
                            orbEvent:FireServer("collectOrb", orbType, selectedFarmLocation)
                        end)
                    end
                    
                    -- Ping stabilizer delay adjustment
                    if pingStabilizer then
                        task.wait(0.01)
                    end
                end
                
                -- Reset FPS cap when farming stops
                pcall(function()
                    setfpscap(60) -- Reset to unlimited
                end)
                print("FPS cap reset to unlimited")
            end)
        else
            -- Reset FPS cap if toggle turned off manually
            pcall(function()
                setfpscap(60)
            end)
        end
    end
})

-- Enhanced Auto Hoops with Connection Optimizer
farmSection:AddToggle("AutoHoops", {
    Title = "Auto Collect Hoops",
    Description = "Automatically collect hoops with enhanced speed",
    Default = false,
    Callback = function(Value)
        _G.AutoHoops = Value
        if Value then
            spawn(function()
                local hoopFolder = workspace:WaitForChild("Hoops")
                local lastUpdate = 0
                
                while _G.AutoHoops do
                    local currentTime = tick()
                    
                    if currentTime - lastUpdate >= 0.1 then
                        lastUpdate = currentTime
                        
                        local success, err = pcall(function()
                            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                                local hrp = player.Character.HumanoidRootPart
                                
                                for _, child in ipairs(hoopFolder:GetChildren()) do
                                    if child.Name == "Hoop" and child:IsA("BasePart") then
                                        task.spawn(function()
                                            child.CFrame = hrp.CFrame
                                        end)
                                    end
                                end
                            end
                        end)
                        
                        if not success then
                            warn("Hoop collection error: " .. tostring(err))
                        end
                    end
                    
                    task.wait()
                end
            end)
        end
    end
})

-- Hide Frames Toggle
farmSection:AddToggle("HideFrames", {
    Title = "Hide Frames",
    Description = "Hide certain UI elements",
    Default = false,
    Callback = function(Value)
        local rSto = game:GetService("ReplicatedStorage")
        for _, obj in pairs(rSto:GetChildren()) do
            if obj.Name:match("Frame$") then
                obj.Visible = not Value
            end
        end
    end
})

-- REBIRTH SECTION
local rebirthSection = Rebirths:AddSection("Auto Rebirth")

rebirthSection:AddInput("TargetRebirth", {
    Title = "Target Rebirth",
    Description = "Set target rebirth (0 = unlimited)",
    Default = "0",
    Numeric = true,
    Finished = true,
    Callback = function(Value)
        local num = tonumber(Value)
        if num and num >= 0 then
            _G.TargetRebirth = math.floor(num)
            print("Target Rebirth set to: " .. _G.TargetRebirth)
        else
            _G.TargetRebirth = 0
            print("Invalid input, set to 0 (unlimited)")
        end
    end
})

rebirthSection:AddToggle("AutoRebirthTarget", {
    Title = "Auto Rebirth (Target)",
    Description = "Auto rebirth until target reached",
    Default = false,
    Callback = function(Value)
        _G.AutoRebirthTarget = Value
        if Value then
            _G.AutoRebirthNormal = false
            spawn(function()
                while _G.AutoRebirthTarget do
                    wait(0.5)
                    if _G.TargetRebirth > 0 then
                        local leaderstats = player:FindFirstChild("leaderstats")
                        if leaderstats then
                            local rebirths = leaderstats:FindFirstChild("Rebirths") or leaderstats:FindFirstChild("Rebirth")
                            if rebirths then
                                local currentRebirths = tonumber(rebirths.Value) or 0
                                if currentRebirths >= _G.TargetRebirth then
                                    _G.AutoRebirthTarget = false
                                    game:GetService("StarterGui"):SetCore("SendNotification",{  
                                        Title = "Auto Rebirth",     
                                        Text = "Target reached: " .. currentRebirths .. " rebirths!",
                                        Duration = 3,
                                    })
                                    print("Auto Rebirth stopped: Target " .. _G.TargetRebirth .. " reached")
                                    break
                                end
                            end
                        end
                    end
                    local success = pcall(function()
                        game.ReplicatedStorage.rEvents.rebirthEvent:FireServer("rebirthRequest")
                    end)
                    if not success then
                        warn("Rebirth event failed")
                        wait(1)
                    end
                end
            end)
        end
    end
})

rebirthSection:AddToggle("AutoRebirthNormal", {
    Title = "Auto Rebirth (Normal)",
    Description = "Auto rebirth continuously",
    Default = false,
    Callback = function(Value)
        _G.AutoRebirthNormal = Value
        if Value then
            _G.AutoRebirthTarget = false
            spawn(function()
                while _G.AutoRebirthNormal do
                    wait(0.5)
                    local success = pcall(function()
                        game.ReplicatedStorage.rEvents.rebirthEvent:FireServer("rebirthRequest")
                    end)
                    if not success then
                        warn("Rebirth event failed")
                        wait(1)
                    end
                end
            end)
        end
    end
})

-- RACE SECTION
local raceSection = Killer:AddSection("Auto Race Settings")

_G.RaceMethod = "Teleport"

raceSection:AddDropdown("RaceMethod", {
    Title = "Race Method",
    Description = "Choose race completion method",
    Values = {"Teleport", "Smooth"},
    Default = 1,
    Callback = function(Value)
        _G.RaceMethod = Value
    end
})

raceSection:AddToggle("AutoRace", {
    Title = "Auto Race",
    Description = "Automatically complete races",
    Default = false,
    Callback = function(Value)
        _G.AutoRace = Value
        if Value then
            spawn(function()
                local raceFired = false
                local teleported = false
                while _G.AutoRace do
                    wait()
                    local raceTimer = game:GetService("ReplicatedStorage"):FindFirstChild("raceTimer")
                    local raceStarted = game:GetService("ReplicatedStorage"):FindFirstChild("raceStarted")
                    if _G.RaceMethod == "Teleport" then
                        local char = game.Players.LocalPlayer.Character
                        if char and char:FindFirstChild("HumanoidRootPart") then
                            char:MoveTo(Vector3.new(1686.07, 36.31, -5946.63))
                            wait(0.1)
                            char:MoveTo(Vector3.new(48.31, 36.31, -8680.45))
                            wait(0.1)
                            char:MoveTo(Vector3.new(1001.33, 36.31, -10986.21))
                            wait(0.1)
                        end
                        if raceTimer and raceTimer:IsA("IntValue") and raceTimer.Value <= 0 then
                            wait(0.5)
                            game:GetService("ReplicatedStorage"):WaitForChild("rEvents"):WaitForChild("raceEvent"):FireServer("joinRace")
                        end
                    elseif _G.RaceMethod == "Smooth" then
                        if raceTimer and raceTimer:IsA("IntValue") and raceTimer.Value <= 0 and not raceFired then
                            wait(0.5)
                            game:GetService("ReplicatedStorage"):WaitForChild("rEvents"):WaitForChild("raceEvent"):FireServer("joinRace")
                            raceFired = true
                            teleported = false
                        end
                        if raceStarted and raceStarted:IsA("BoolValue") and raceStarted.Value == true and not teleported then
                            local finishParts = workspace:GetDescendants()
                            local closestPart = nil
                            local minDist = math.huge
                            local char = game.Players.LocalPlayer.Character
                            if char and char:FindFirstChild("HumanoidRootPart") then
                                for _, part in ipairs(finishParts) do
                                    if part:IsA("BasePart") and part.Name == "finishPart" then
                                        local dist = (char.HumanoidRootPart.Position - part.Position).Magnitude
                                        if dist < minDist then
                                            minDist = dist
                                            closestPart = part
                                        end
                                    end
                                end
                                if closestPart then
                                    char:MoveTo(closestPart.Position)
                                    teleported = true
                                end
                            end
                        end
                        if raceStarted and raceStarted:IsA("BoolValue") and raceStarted.Value == false then
                            raceFired = false
                        end
                    end
                    wait(0.05)
                end
            end)
        end
    end
})

raceSection:AddToggle("AutoFillRace", {
    Title = "Auto Fill Race",
    Description = "Auto join race when available",
    Default = false,
    Callback = function(Value)
        _G.AutoFillRace = Value
        if Value then
            spawn(function()
                local raceEvent = game:GetService("ReplicatedStorage").rEvents.raceEvent
                while _G.AutoFillRace do
                    wait(0.01)
                    raceEvent:FireServer("joinRace")
                end
            end)
        end
    end
})

-- CRYSTAL SECTION
local crystalSection = Shop:AddSection("Crystal Opening")

local selectedCrystal = "Jungle Crystal"
crystalSection:AddDropdown("CrystalType", {
    Title = "Select Crystal",
    Description = "Choose crystal to open",
    Values = {"Jungle Crystal", "Electro Legends Crystal", "Lava Crystal", "Inferno Crystal", "Snow Crystal", "Electro Crystal", "Space Crystal", "Desert Crystal"},
    Default = 1,
    Callback = function(Value)
        selectedCrystal = Value
        print("Selected crystal: " .. selectedCrystal)
    end
})

crystalSection:AddToggle("AutoCrystal", {
    Title = "Auto Open Crystal",
    Description = "Automatically open selected crystals",
    Default = false,
    Callback = function(Value)
        _G.AutoCrystal = Value
        if Value and selectedCrystal ~= "" then
            spawn(function()
                while _G.AutoCrystal do
                    wait()
                    game:GetService("ReplicatedStorage").rEvents.openCrystalRemote:InvokeServer("openCrystal", selectedCrystal)
                end
            end)
        end
    end
})

-- MISC SECTION
local miscSection = Misc:AddSection("Miscellaneous Features")

miscSection:AddButton({
    Title = "Disable Jump",
    Description = "Set jump power to 0",
    Callback = function()
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            player.Character.Humanoid.JumpPower = 0
        end
    end
})

miscSection:AddButton({
    Title = "Enable Jump",
    Description = "Restore jump power to 50",
    Callback = function()
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            player.Character.Humanoid.JumpPower = 50
        end
    end
})

-- Location Teleports
local teleportSection = TeleportTab:AddSection("Location Teleports")

local locations = {
    ["City"] = Vector3.new(-9687.19, 59.07, 3096.59),
    ["Snow City"] = Vector3.new(-9677.66, 59.07, 3783.74),
    ["Magma City"] = Vector3.new(-11053.38, 217.03, 4896.11),
    ["Legends Highway"] = Vector3.new(-13097.86, 217.03, 5904.85),
    ["Space"] = Vector3.new(-336.03, 3.94, 592.14),
    ["Desert"] = Vector3.new(2508.40, 14.83, 4352.73),
    ["Speed Jungle"] = Vector3.new(-15271.71, 398.20, 5574.44, -1.00, -0.00, -0.02, -0.00, 1.00, 0.00, 0.02, 0.00, -1.00)
}

for locationName, position in pairs(locations) do
    teleportSection:AddButton({
        Title = locationName,
        Description = "Teleport to " .. locationName,
        Callback = function()
            if player.Character then
                player.Character:MoveTo(position)
            end
        end
    })
end

-- ANTI AFK BUTTON
miscSection:AddButton({
    Title = "Anti AFK",
    Description = "Prevents being kicked for AFK",
    Callback = function()
        local VirtualUser = game:GetService("VirtualUser")
        
        local gui = Instance.new("ScreenGui")
        gui.Parent = player.PlayerGui
        
        local textLabel = Instance.new("TextLabel")
        textLabel.Size = UDim2.new(0, 200, 0, 50)
        textLabel.Position = UDim2.new(0.5, -100, 0, -50)
        textLabel.TextColor3 = Color3.fromRGB(50, 255, 50)
        textLabel.Font = Enum.Font.GothamBold
        textLabel.TextSize = 20
        textLabel.BackgroundTransparency = 1
        textLabel.TextTransparency = 1
        textLabel.Text = "ANTI AFK"
        textLabel.Parent = gui
        
        local timerLabel = Instance.new("TextLabel")
        timerLabel.Size = UDim2.new(0, 200, 0, 30)
        timerLabel.Position = UDim2.new(0.5, -100, 0, -20)
        timerLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        timerLabel.Font = Enum.Font.GothamBold
        timerLabel.TextSize = 18
        timerLabel.BackgroundTransparency = 1
        timerLabel.TextTransparency = 1
        timerLabel.Text = "00:00:00"
        timerLabel.Parent = gui
        
        local startTime = tick()
        
        task.spawn(function()
            while true do
                local elapsed = tick() - startTime
                local hours = math.floor(elapsed / 3600)
                local minutes = math.floor((elapsed % 3600) / 60)
                local seconds = math.floor(elapsed % 60)
                timerLabel.Text = string.format("%02d:%02d:%02d", hours, minutes, seconds)
                task.wait(1)
            end
        end)
        
        task.spawn(function()
            while true do
                for i = 0, 1, 0.01 do
                    textLabel.TextTransparency = 1 - i
                    timerLabel.TextTransparency = 1 - i
                    task.wait(0.015)
                end
                task.wait(1.5)
                for i = 0, 1, 0.01 do
                    textLabel.TextTransparency = i
                    timerLabel.TextTransparency = i
                    task.wait(0.015)
                end
                task.wait(0.8)
            end
        end)
        
        player.Idled:Connect(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new())
            print("AFK prevention completed!")
        end)
    end
})

-- FPS Boost Section
local fpsSection = Misc:AddSection("FPS Boost")

fpsSection:AddButton({
    Title = "Remove Effects",
    Description = "Toggle off particles, trails, smoke, fire, sparkles",
    Callback = function()
        for _, v in pairs(game:GetDescendants()) do
            if v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Smoke") or v:IsA("Fire") or v:IsA("Sparkles") or v:IsA("Beam") then
                v.Enabled = false
            end
        end
    end
})

fpsSection:AddButton({
    Title = "Remove Decals & Textures",
    Description = "Delete all decals and textures from workspace",
    Callback = function()
        for _, v in pairs(workspace:GetDescendants()) do
            if v:IsA("Texture") or v:IsA("Decal") then
                v:Destroy()
            end
        end
    end
})

fpsSection:AddButton({
    Title = "Mute All Sounds",
    Description = "Set volume to 0 for all Sound objects",
    Callback = function()
        for _, v in pairs(game:GetDescendants()) do
            if v:IsA("Sound") then
                v.Volume = 0
            end
        end
    end
})

fpsSection:AddButton({
    Title = "Low Lighting Mode",
    Description = "Disable shadows and increase fog for performance",
    Callback = function()
        local lighting = game:GetService("Lighting")
        lighting.GlobalShadows = false
        lighting.FogEnd = 9e9
        lighting.Brightness = 0.5
    end
})

fpsSection:AddButton({
    Title = "Remove Accessories",
    Description = "Delete hats, gear, and accessories from character",
    Callback = function()
        local player = game.Players.LocalPlayer
        if player.Character then
            for _, v in pairs(player.Character:GetChildren()) do
                if v:IsA("Accessory") or v:IsA("Hat") or v:IsA("Shirt") or v:IsA("Pants") then
                    v:Destroy()
                end
            end
        end
    end
})

fpsSection:AddButton({
    Title = "Stop Animations",
    Description = "Stop all player animations",
    Callback = function()
        local player = game.Players.LocalPlayer
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            local humanoid = player.Character.Humanoid
            for _, anim in pairs(humanoid:GetPlayingAnimationTracks()) do
                anim:Stop()
            end
        end
    end
})

fpsSection:AddButton({
    Title = "Simplify Materials",
    Description = "Convert parts to SmoothPlastic material",
    Callback = function()
        for _, v in pairs(workspace:GetDescendants()) do
            if v:IsA("BasePart") and not v.Parent:FindFirstChild("Humanoid") then
                v.Material = Enum.Material.SmoothPlastic
            end
        end
    end
})

-- Destroy GUI button
miscSection:AddButton({
    Title = "Destroy GUI",
    Description = "Closes the JOY GUI",
    Callback = function()
        Library:Destroy()
        print("GUI destroyed successfully!")
    end
})

-- CREDITS SECTION
local creditsSection = Settings:AddSection("Credits")

creditsSection:AddParagraph({
    Title = "Credits: Markyy",
    Content = "Roblox: KYYY\nDiscord: KYY"
})

creditsSection:AddButton({
    Title = "Copy Discord Link",
    Description = "Join the Discord server",
    Callback = function()
        setclipboard('https://discord.gg/WMAHNafHqZ    ')
    end
})

creditsSection:AddButton({
    Title = "Copy Roblox Profile Link",
    Description = "Visit the creator's profile",
    Callback = function()
        setclipboard("https://www.roblox.com/users/2815154822/profile    ")
    end
})

-- Initialize the window
Window:SelectTab(1)
print("KYYYY HUB Loaded Successfully!")
