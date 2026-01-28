local Material = loadstring(game:HttpGet("https://raw.githubusercontent.com/Kyypie69/Library.UI/refs/heads/main/LosV2Lib.lua"))()

local Players = game:GetService("Players")
local player = Players.LocalPlayer
local userId = player.UserId
local thumbType = Enum.ThumbnailType.HeadShot
local thumbSize = Enum.ThumbnailSize.Size420x420
local content, isReady = Players:GetUserThumbnailAsync(userId, thumbType, thumbSize)

-- PINK-THEMED NOTIFICATIONS
game:GetService("StarterGui"):SetCore("SendNotification",{  
    Title = "🌺 JOY 🌺",     
    Text = "Welcome!",
    Icon = "",
    Duration = 3,
    Color = "DarkPink"
})

wait(3)

game:GetService("StarterGui"):SetCore("SendNotification",{  
    Title = "Hello ✨",     
    Text = player.Name,
    Icon = content,
    Duration = 2,
    Color = "DarkPink"
})

wait(3)

local windowTitle = "🌺 JOY 🌺 - Legends Of Speed"

local X = Material.Load({
    Title = windowTitle,
    Style = 3,
    SizeX = 320,
    SizeY = 250,
    Theme = "DarkPink",
    ColorOverrides = {
        MainFrame = Color3.fromRGB(255, 20, 147),
        Glow = Color3.fromRGB(255, 105, 180),
        GlowIntensity = 0.8,
    }
})

local mainTab = X.New({Title = "Main"})
local farmTab = X.New({Title = "Auto Farm"})
local teleportTab = X.New({Title = "Teleport"})
local raceTab = X.New({Title = "Race"})
local crystalTab = X.New({Title = "Crystal"})
local miscTab = X.New({Title = "Misc"})
local creditsTab = X.New({Title = "Credits"})

-- MAIN TAB
mainTab.Label({Text = "Main Features"})

-- FIXED: Claim All Chest functionality
mainTab.Button({
    Text = "Claim All Chest",
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
                Color = "Pink"
            })
        else
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "Error",     
                Text = "No chests found!",
                Duration = 2,
                Color = "Pink"
            })
        end
    end
})

mainTab.Button({
    Text = "Disable Trading",
    Callback = function()
        game:GetService("ReplicatedStorage").rEvents.tradingEvent:FireServer("disableTrading")
    end
})

mainTab.Button({
    Text = "Enable Trading",
    Callback = function()
        game:GetService("ReplicatedStorage").rEvents.tradingEvent:FireServer("enableTrading")
    end
})

-- REMOVED: Spam Chat toggle as requested

local playerList = {}
for i,v in pairs(game:GetService("Players"):GetPlayers()) do
    if v ~= player then
        table.insert(playerList, v.Name)
    end
end

mainTab.Dropdown({
    Text = "Teleport To Player",
    Callback = function(Value)
        if game.Players:FindFirstChild(Value) then
            player.Character.HumanoidRootPart.CFrame = game.Players[Value].Character.HumanoidRootPart.CFrame * CFrame.new(0,2,1)
        end
    end,
    Options = playerList
})

mainTab.Slider({
    Text = "Walk Speed",
    Callback = function(Value)
        player.Character.Humanoid.WalkSpeed = Value
    end,
    Min = 16,
    Max = 1000,
    Def = 16
})

mainTab.Slider({
    Text = "Jump Power",
    Callback = function(Value)
        player.Character.Humanoid.JumpPower = Value
    end,
    Min = 50,
    Max = 1000,
    Def = 50
})

-- AUTO FARM TAB
farmTab.Label({Text = "Auto Farm"})

local selectedOrb = ""
local selectedFarmLocation = "City"

farmTab.Dropdown({
    Text = "Select Orbs",
    Callback = function(Value)
        selectedOrb = Value
    end,
    Options = {"Red Orbs", "Blue Orbs", "Orange Orbs", "Yellow Orbs", "Ethereal Orbs", "Gems"}
})

farmTab.Dropdown({
    Text = "Select Location",
    Callback = function(Value)
        selectedFarmLocation = Value
    end,
    Options = {"City", "Snow City", "Magma City", "Speed Jungle"} -- REMOVED: Jungle City, Speed City | ADDED: Jungle Cave / Speed Jungle
})

-- NEW: Hide Frames Toggle
farmTab.Toggle({
    Text = "Hide Frames",
    Callback = function(Value)
        local rSto = game:GetService("ReplicatedStorage")
        for _, obj in pairs(rSto:GetChildren()) do
            if obj.Name:match("Frame$") then
                obj.Visible = not Value
            end
        end
    end,
    Enabled = false
})

farmTab.Toggle({
    Text = "Farm Selected Orbs",
    Callback = function(Value)
        _G.FarmOrbs = Value
        if Value and selectedOrb ~= "" then
            spawn(function()
                while _G.FarmOrbs do
                    wait()
                    for i = 1, 200 do
                        if selectedOrb == "Red Orbs" then
                            game:GetService("ReplicatedStorage").rEvents.orbEvent:FireServer("collectOrb", "Yellow Orb", selectedFarmLocation)
                        elseif selectedOrb == "Blue Orbs" then
                            game:GetService("ReplicatedStorage").rEvents.orbEvent:FireServer("collectOrb", "Yellow Orb", selectedFarmLocation)
                        elseif selectedOrb == "Orange Orbs" then
                            game:GetService("ReplicatedStorage").rEvents.orbEvent:FireServer("collectOrb", "Red Orb", selectedFarmLocation)
                        elseif selectedOrb == "Yellow Orbs" then
                            game:GetService("ReplicatedStorage").rEvents.orbEvent:FireServer("collectOrb", "Gem", selectedFarmLocation)
                        elseif selectedOrb == "Ethereal Orbs" then
                            game:GetService("ReplicatedStorage").rEvents.orbEvent:FireServer("collectOrb", "Yellow Orb", selectedFarmLocation)
                        elseif selectedOrb == "Gems" then
                            game:GetService("ReplicatedStorage").rEvents.orbEvent:FireServer("collectOrb", "Ethereal Orb", selectedFarmLocation)
                        end
                    end
                end
            end)
        end
    end,
    Enabled = false
})

farmTab.Toggle({
    Text = "Auto Collect Hoops",
    Callback = function(Value)
        _G.AutoHoops = Value
        if Value then
            spawn(function()
                while _G.AutoHoops do
                    wait(0.1)
                    local success, err = pcall(function()
                        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                            local hoopFolder = workspace:FindFirstChild("Hoops")
                            if hoopFolder then
                                for _, child in ipairs(hoopFolder:GetChildren()) do
                                    if child.Name == "Hoop" and child:IsA("BasePart") then
                                        child.CFrame = player.Character.HumanoidRootPart.CFrame
                                    end
                                end
                            end
                        end
                    end)
                    if not success then
                        warn("Hoop collection error: " .. tostring(err))
                    end
                end
            end)
        end
    end,
    Enabled = false
})

farmTab.Label({Text = "Target Rebirth (0 = unlimited)"})

_G.TargetRebirth = 0

farmTab.TextField({
    Text = "Enter Target Rebirth",
    Callback = function(Value)
        local num = tonumber(Value)
        if num and num >= 0 then
            _G.TargetRebirth = math.floor(num)
            print("Target Rebirth set to: " .. _G.TargetRebirth)
        else
            _G.TargetRebirth = 0
            print("Invalid input, set to 0 (unlimited)")
        end
    end,
})

farmTab.Toggle({
    Text = "Auto Rebirth (Target)",
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
                                        Color = "Pink"
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
    end,
    Enabled = false
})

farmTab.Toggle({
    Text = "Auto Rebirth (Normal)",
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
    end,
    Enabled = false
})

-- RACE TAB
raceTab.Label({Text = "Auto Race Settings"})

_G.RaceMethod = "Teleport"

raceTab.Dropdown({
    Text = "Race Method",
    Callback = function(Value)
        _G.RaceMethod = Value
    end,
    Options = {"Teleport", "Smooth"}
})

raceTab.Toggle({
    Text = "Auto Race",
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
    end,
    Enabled = false
})

raceTab.Toggle({
    Text = "Auto Fill Race",
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
    end,
    Enabled = false
})

-- TELEPORT TAB
teleportTab.Label({Text = "Location Teleports"})

local locations = {
    ["City"] = Vector3.new(-9687.19, 59.07, 3096.59),
    ["Snow City"] = Vector3.new(-9677.66, 59.07, 3783.74),
    ["Magma City"] = Vector3.new(-11053.38, 217.03, 4896.11),
    ["Legends Highway"] = Vector3.new(-13097.86, 217.03, 5904.85),
    ["Space"] = Vector3.new(-336.03, 3.94, 592.14),
    ["Desert"] = Vector3.new(2508.40, 14.83, 4352.73),
    ["Speed Jungle"] = Vector3.new(-15271.71, 398.20, 5574.44, -1.00, -0.00, -0.02, -0.00, 1.00, 0.00, 0.02, 0.00, -1.00) -- Actual Speed Jungle entrance after Jungle Cave
}

for locationName, position in pairs(locations) do
    teleportTab.Button({
        Text = locationName,
        Callback = function()
            player.Character:MoveTo(position)
        end
    })
end

-- CRYSTAL TAB
crystalTab.Label({Text = "Crystal Opening"})

local selectedCrystal = ""
crystalTab.Dropdown({
    Text = "Select Crystal",
    Callback = function(Value)
        selectedCrystal = Value
    end,
    Options = {"Jungle Crystal", "Electro Legends Crystal", "Lava Crystal", "Inferno Crystal", "Snow Crystal", "Electro Crystal", "Space Crystal", "Desert Crystal"} -- ADDED: Jungle Crystal
})

crystalTab.Toggle({
    Text = "Auto Open Crystal",
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
    end,
    Enabled = false
})

-- MISC TAB
miscTab.Label({Text = "Miscellaneous Features"})

miscTab.Button({
    Text = "Disable Jump",
    Callback = function()
        player.Character.Humanoid.JumpPower = 0
    end
})

miscTab.Button({
    Text = "Enable Jump",
    Callback = function()
        player.Character.Humanoid.JumpPower = 50
    end
})

-- UPDATED ANTI AFK BUTTON
miscTab.Button({
    Text = "Anti AFK",
    Callback = function()
        local Players = game:GetService("Players")
        local VirtualUser = game:GetService("VirtualUser")
        local player = Players.LocalPlayer
        
        local gui = Instance.new("ScreenGui", player.PlayerGui)
        
        local textLabel = Instance.new("TextLabel", gui)
        textLabel.Size = UDim2.new(0, 200, 0, 50)
        textLabel.Position = UDim2.new(0.5, -100, 0, -50)
        textLabel.TextColor3 = Color3.fromRGB(50, 255, 50)
        textLabel.Font = Enum.Font.GothamBold
        textLabel.TextSize = 20
        textLabel.BackgroundTransparency = 1
        textLabel.TextTransparency = 1
        
        local timerLabel = Instance.new("TextLabel", gui)
        timerLabel.Size = UDim2.new(0, 200, 0, 30)
        timerLabel.Position = UDim2.new(0.5, -100, 0, -20)
        timerLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        timerLabel.Font = Enum.Font.GothamBold
        timerLabel.TextSize = 18
        timerLabel.BackgroundTransparency = 1
        timerLabel.TextTransparency = 1
        timerLabel.Text = "00:00:00"
        
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
        
        textLabel.Text = "ANTI AFK"
    end
})

miscTab.Button({
    Text = "FPS Boost",
    Callback = function()
        local decalsyeeted = true
        local g = game
        local w = g.Workspace
        local l = g.Lighting
        local t = w.Terrain
        t.WaterWaveSize = 0
        t.WaterWaveSpeed = 0
        t.WaterReflectance = 0
        t.WaterTransparency = 0
        l.GlobalShadows = false
        l.FogEnd = 9e9
        l.Brightness = 0
        settings().Rendering.QualityLevel = "Level01"
        for i, v in pairs(g:GetDescendants()) do
            if v:IsA("Part") or v:IsA("Union") or v:IsA("CornerWedgePart") or v:IsA("TrussPart") then
                v.Material = "Plastic"
                v.Reflectance = 0
            elseif v:IsA("Decal") or v:IsA("Texture") and decalsyeeted then
                v.Transparency = 1
            elseif v:IsA("ParticleEmitter") or v:IsA("Trail") then
                v.Lifetime = NumberRange.new(0)
            elseif v:IsA("Explosion") then
                v.BlastPressure = 1
                v.BlastRadius = 1
            elseif v:IsA("Fire") or v:IsA("SpotLight") or v:IsA("Smoke") then
                v.Enabled = false
            elseif v:IsA("MeshPart") then
                v.Material = "Plastic"
                v.Reflectance = 0
                v.TextureID = 10385902758728957
            end
        end
        for i, e in pairs(l:GetChildren()) do
            if e:IsA("BlurEffect") or e:IsA("SunRaysEffect") or e:IsA("ColorCorrectionEffect") or e:IsA("BloomEffect") or e:IsA("DepthOfFieldEffect") then
                e.Enabled = false
            end
        end
    end
})

miscTab.Button({
    Text = "Infinite Jump",
    Callback = function()
        game:GetService("UserInputService").JumpRequest:connect(function()
            game:GetService"Players".LocalPlayer.Character:FindFirstChildOfClass'Humanoid':ChangeState("Jumping")
        end)
    end
})

-- FIXED: Destroy GUI button - now properly finds and destroys the GUI
miscTab.Button({
    Text = "Destroy GUI",
    Callback = function()
        -- Try to find GUI by the title name first
        local guiName = windowTitle
        for i,v in pairs(game.CoreGui:GetChildren()) do
            if v.Name == guiName then
                v:Destroy()
                print("GUI destroyed successfully!")
                return
            end
        end
        
        -- Fallback: Check for OldInstance global
        if getgenv().OldInstance then
            getgenv().OldInstance:Destroy()
            print("GUI destroyed via OldInstance!")
            return
        end
        
        -- Last resort: Look for any ScreenGui with similar naming
        for i,v in pairs(game.CoreGui:GetChildren()) do
            if v:IsA("ScreenGui") and (v.Name:find("JOY") or v.Name:find("Joy")) then
                v:Destroy()
                print("GUI destroyed via fallback search!")
                return
            end
        end
        
        print("Could not find GUI to destroy!")
    end
})

-- CREDITS TAB
creditsTab.Label({Text = "Credits: Markyy"})
creditsTab.Label({Text = "Discord: KYY"})
creditsTab.Button({
    Text = "Copy Discord Link",
    Callback = function()
        setclipboard('https://discord.gg/WMAHNafHqZ       ')
    end
})

creditsTab.Label({Text = "Roblox: KYYY"})
creditsTab.Button({
    Text = "Copy Roblox Profile Link",
    Callback = function()
        setclipboard("https://www.roblox.com/users/2815154822/profile       ")
    end
})

print("Joy HUB Loaded Successfully!")
