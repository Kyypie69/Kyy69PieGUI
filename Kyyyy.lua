local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/Kyypie69/Library.UI/main/KyypieUI.lua"))()
local SaveManager = Library.SaveManager
local InterfaceManager = Library.InterfaceManager

-- Initialize the window
local Window = Library:CreateWindow({
    Title = "Silence | Main",
    SubTitle = "Made by Henne ♥️",
    Size = Vector2.new(500, 300),
    Acrylic = false,
    Theme = "LightBlue",
})

-- Main tab
local MainTab = Window:AddTab("Main")
local KillingTab = Window:AddTab("Killing")
local SpecsTab = Window:AddTab("Specs")
local FarmingTab = Window:AddTab("Farming")
local InventoryTab = Window:AddTab("Inventory")
local PetsTab = Window:AddTab("Pet Shop")
local TeleportTab = Window:AddTab("Teleports")
local StatsTab = Window:AddTab("Stats")
local InfoTab = Window:AddTab("Info")

-- Main tab elements
MainTab:AddLabel("Settings:")
MainTab:AddSwitch("Anti AFK", function(bool)
    if bool then
        game.Players.LocalPlayer.Idled:connect(function()
            virtualUser:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
            wait(1)
            virtualUser:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
        end)
    end
end)
MainTab:AddSwitch("Anti Knockback", function(bool)
    if bool then
        local player = game.Players.LocalPlayer
        local character = player.Character or player.CharacterAdded:Wait()
        local humanoid = character:WaitForChild("Humanoid")
        local bodyVelocity = Instance.new("BodyVelocity")
        bodyVelocity.MaxForce = Vector3.new(100000, 0, 100000)
        bodyVelocity.Velocity = Vector3.new(0, 0, 0)
        bodyVelocity.P = 1250
        bodyVelocity.Parent = humanoid.RootPart
    else
        local character = game.Players.LocalPlayer.Character
        if character then
            local rootPart = character:FindFirstChild("HumanoidRootPart")
            if rootPart then
                local existingVelocity = rootPart:FindFirstChild("BodyVelocity")
                if existingVelocity and existingVelocity.MaxForce == Vector3.new(100000, 0, 100000) then
                    existingVelocity:Destroy()
                end
            end
        end
    end
end)
MainTab:AddSwitch("Lock Position", function(bool)
    if bool then
        local player = game.Players.LocalPlayer
        local character = player.Character or player.CharacterAdded:Wait()
        local hrp = character:WaitForChild("HumanoidRootPart")
        local lockPosition = hrp.Position
        local function lock()
            hrp.Velocity = Vector3.new(0, 0, 0)
            hrp.RotVelocity = Vector3.new(0, 0, 0)
            hrp.CFrame = CFrame.new(lockPosition)
        end
        task.spawn(function()
            while bool do
                lock()
                task.wait(0.05)
            end
        end)
    end
end)
MainTab:AddSwitch("Infinite Jump", function(bool)
    if bool then
        local gamepassFolder = game:GetService("ReplicatedStorage").gamepassIds
        local player = game:GetService("Players").LocalPlayer
        for _, gamepass in pairs(gamepassFolder:GetChildren()) do
            local value = Instance.new("IntValue")
            value.Name = gamepass.Name
            value.Value = gamepass.Value
            value.Parent = player.ownedGamepasses
        end
    else
        local player = game:GetService("Players").LocalPlayer
        if player and player.ownedGamepasses then
            local gamepassFolder = game:GetService("ReplicatedStorage").gamepassIds
            for _, gamepass in pairs(gamepassFolder:GetChildren()) do
                local ownedPass = player.ownedGamepasses:FindFirstChild(gamepass.Name)
                if ownedPass and ownedPass.Value == gamepass.Value then
                    ownedPass:Destroy()
                end
            end
        end
    end
end)
MainTab:AddSwitch("Show Pets", function(bool)
    local player = game:GetService("Players").LocalPlayer
    if player:FindFirstChild("hidePets") then
        player.hidePets.Value = bool
    end
end)
MainTab:AddSwitch("Show Other Pets", function(bool)
    local player = game:GetService("Players").LocalPlayer
    if player:FindFirstChild("showOtherPetsOn") then
        player.showOtherPetsOn.Value = bool
    end
end)
MainTab:AddSwitch("Walk on Water", function(bool)
    for _, part in ipairs(parts) do
        if part and part.Parent then
            part.CanCollide = bool
        end
    end
end)
MainTab:AddSwitch("Spin Fortune Wheel", function(bool)
    if bool then
        spawn(function()
            while _G.AutoSpinWheel and wait(1) do
                game:GetService("ReplicatedStorage").rEvents.openFortuneWheelRemote:InvokeServer("openFortuneWheel", game:GetService("ReplicatedStorage").fortuneWheelChances["Fortune Wheel"])
            end
        end)
    end
end)
MainTab:AddDropdown("Change Time", function(selection)
    local lighting = game:GetService("Lighting")
    if selection == "Night" then
        lighting.ClockTime = 0
    elseif selection == "Day" then
        lighting.ClockTime = 12
    elseif selection == "Midnight" then
        lighting.ClockTime = 6
    end
end)
MainTab:AddLabel("Misc:")
MainTab:AddSwitch("Auto Lift (Gamepass)", function(bool)
    if bool then
        local gamepassFolder = game:GetService("ReplicatedStorage").gamepassIds
        local player = game:GetService("Players").LocalPlayer
        for _, gamepass in pairs(gamepassFolder:GetChildren()) do
            local value = Instance.new("IntValue")
            value.Name = gamepass.Name
            value.Value = gamepass.Value
            value.Parent = player.ownedGamepasses
        end
    else
        local player = game:GetService("Players").LocalPlayer
        if player and player.ownedGamepasses then
            local gamepassFolder = game:GetService("ReplicatedStorage").gamepassIds
            for _, gamepass in pairs(gamepassFolder:GetChildren()) do
                local ownedPass = player.ownedGamepasses:FindFirstChild(gamepass.Name)
                if ownedPass and ownedPass.Value == gamepass.Value then
                    ownedPass:Destroy()
                end
            end
        end
    end
end)
MainTab:AddTextBox("Set Rebirth Target", function(text)
    local rebirths = player.leaderstats:WaitForChild("Rebirths")
    local targetRebirths = tonumber(text)
    if targetRebirths and targetRebirths >= 0 then
        rebirths.Value = targetRebirths
    end
end)
MainTab:AddSwitch("Auto Rebirth", function(enabled)
    if enabled then
        local rebirths = player.leaderstats:WaitForChild("Rebirths")
        local targetRebirths = tonumber(MainTab:GetTextBox("Set Rebirth Target").Value)
        if targetRebirths and rebirths.Value < targetRebirths then
            task.spawn(function()
                while rebirths.Value < targetRebirths do
                    game:GetService("ReplicatedStorage").rEvents.rebirthRemote:InvokeServer("rebirthRequest")
                    task.wait(0.05)
                end
            end)
        end
    end
end)
MainTab:AddSwitch("Auto Size 1", function(bool)
    if bool then
        local character = game.Players.LocalPlayer.Character
        if character then
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                game:GetService("ReplicatedStorage").rEvents.changeSizeRemote:InvokeServer("changeSize", 1)
            end
        end
    end
end)
MainTab:AddSwitch("Auto King", function(bool)
    if bool then
        local targetPosition = CFrame.new(-8665.4, 17.21, -5792.9)
        local char = game.Players.LocalPlayer.Character or game.Players.LocalPlayer.CharacterAdded:Wait()
        local hrp = char:WaitForChild("HumanoidRootPart")
        while bool do
            if (hrp.Position - targetPosition.Position).magnitude > 5 then
                hrp.CFrame = targetPosition
            end
            task.wait(0.05)
        end
    end
end)

-- Killing tab elements
KillingTab:AddDropdown("Select Pet", function(text)
    local petsFolder = game.Players.LocalPlayer.petsFolder
    for _, folder in pairs(petsFolder:GetChildren()) do
        if folder:IsA("Folder") then
            for _, pet in pairs(folder:GetChildren()) do
                game:GetService("ReplicatedStorage").rEvents.equipPetEvent:FireServer("unequipPet", pet)
            end
        end
    end
    task.wait(0.2)

    local petName = text
    local petsToEquip = {}

    for _, pet in pairs(game.Players.LocalPlayer.petsFolder.Unique:GetChildren()) do
        if pet.Name == petName then
            table.insert(petsToEquip, pet)
        end
    end

    for i = 1, math.min(8, #petsToEquip) do
        game:GetService("ReplicatedStorage").rEvents.equipPetEvent:FireServer("equipPet", petsToEquip[i])
        task.wait(0.1)
    end
end)
KillingTab:AddSwitch("Remove Attack Animations", function(bool)
    if bool then
        local blockedAnimations = {
            ["rbxassetid://3638729053"] = true,
            ["rbxassetid://3638767427"] = true,
        }

        local function setupAnimationBlocking()
            local char = game.Players.LocalPlayer.Character
            if not char or not char:FindFirstChild("Humanoid") then return end

            local humanoid = char:FindFirstChild("Humanoid")

            for _, track in pairs(humanoid:GetPlayingAnimationTracks()) do
                if track.Animation then
                    local animId = track.Animation.AnimationId
                    local animName = track.Name:lower()

                    if blockedAnimations[animId] or animName:match("punch") or animName:match("attack") or animName:match("right") then
                        track:Stop()
                    end
                end
            end

            _G.AnimBlockConnection = humanoid.AnimationPlayed:Connect(function(track)
                if track.Animation then
                    local animId = track.Animation.AnimationId
                    local animName = track.Name:lower()

                    if blockedAnimations[animId] or animName:match("punch") or animName:match("attack") or animName:match("right") then
                        track:Stop()
                    end
                end
            end)
        end

        local function processTool(tool)
            if tool and (tool.Name == "Punch" or tool.Name:match("Attack") or tool.Name:match("Right")) then
                if not tool:GetAttribute("ActivatedOverride") then
                    tool:SetAttribute("ActivatedOverride", true)

                    _G.ToolConnections = _G.ToolConnections or {}
                    _G.ToolConnections[tool] = tool.Activated:Connect(function()
                        task.wait(0.05)
                        local char = game.Players.LocalPlayer.Character
                        if char and char:FindFirstChild("Humanoid") then
                            for _, track in pairs(char.Humanoid:GetPlayingAnimationTracks()) do
                                if track.Animation then
                                    local animId = track.Animation.AnimationId
                                    local animName = track.Name:lower()

                                    if blockedAnimations[animId] or animName:match("punch") or animName:match("attack") or animName:match("right") then
                                        track:Stop()
                                    end
                                end
                            end
                        end
                    end)
                end
            end
        end

        local function overrideToolActivation()
            for _, tool in pairs(game.Players.LocalPlayer.Backpack:GetChildren()) do
                processTool(tool)
            end

            local char = game.Players.LocalPlayer.Character
            if char then
                for _, tool in pairs(char:GetChildren()) do
                    if tool:IsA("Tool") then
                        processTool(tool)
                    end
                end
            end

            _G.BackpackAddedConnection = game.Players.LocalPlayer.Backpack.ChildAdded:Connect(function(child)
                if child:IsA("Tool") then
                    task.wait(0.1)
                    processTool(child)
                end
            end)

            if char then
                _G.CharacterToolAddedConnection = char.ChildAdded:Connect(function(child)
                    if child:IsA("Tool") then
                        task.wait(0.1)
                        processTool(child)
                    end
                end)
            end
        end

        _G.AnimMonitorConnection = game:GetService("RunService").Heartbeat:Connect(function()
            if tick() % 0.5 < 0.01 then
                local char = game.Players.LocalPlayer.Character
                if char and char:FindFirstChild("Humanoid") then
                    for _, track in pairs(char.Humanoid:GetPlayingAnimationTracks()) do
                        if track.Animation then
                            local animId = track.Animation.AnimationId
                            local animName = track.Name:lower()

                            if blockedAnimations[animId] or animName:match("punch") or animName:match("attack") or animName:match("right") then
                                track:Stop()
                            end
                        end
                    end
                end
            end
        end)

        _G.CharacterAddedConnection = game.Players.LocalPlayer.CharacterAdded:Connect(function(newChar)
            task.wait(1)
            setupAnimationBlocking()
            overrideToolActivation()

            if _G.CharacterToolAddedConnection then
                _G.CharacterToolAddedConnection:Disconnect()
            end

            _G.CharacterToolAddedConnection = newChar.ChildAdded:Connect(function(child)
                if child:IsA("Tool") then
                    task.wait(0.1)
                    processTool(child)
                end
            end)
        end)

        setupAnimationBlocking()
        overrideToolActivation()
    else
        if _G.AnimBlockConnection then
            _G.AnimBlockConnection:Disconnect()
            _G.AnimBlockConnection = nil
        end

        if _G.AnimMonitorConnection then
            _G.AnimMonitorConnection:Disconnect()
            _G.AnimMonitorConnection = nil
        end

        if _G.CharacterAddedConnection then
            _G.CharacterAddedConnection:Disconnect()
            _G.CharacterAddedConnection = nil
        end

        if _G.BackpackAddedConnection then
            _G.BackpackAddedConnection:Disconnect()
            _G.BackpackAddedConnection = nil
        end

        if _G.CharacterToolAddedConnection then
            _G.CharacterToolAddedConnection:Disconnect()
            _G.CharacterToolAddedConnection = nil
        end

        if _G.ToolConnections then
            for tool, connection in pairs(_G.ToolConnections) do
                if connection then
                    connection:Disconnect()
                end
                if tool and tool:GetAttribute("ActivatedOverride") then
                    tool:SetAttribute("ActivatedOverride", nil)
                end
            end
            _G.ToolConnections = nil
        end
    end
end)
KillingTab:AddSwitch("NaN (Egg+NaN+Punch Combo)", function(bool)
    local player = game.Players.LocalPlayer
    if bool then
        game:GetService("ReplicatedStorage").rEvents.changeSpeedSizeRemote:InvokeServer("changeSize", 0/0)
        local eggLoop = task.spawn(function()
            while bool do
                local eggsInHand = 0
                for _, item in ipairs(player.Character:GetChildren()) do
                    if item.Name == "Protein Egg" then
                        eggsInHand = 1
                        if eggsInHand > 1 then
                            item.Parent = player.Backpack
                        end
                    end
                end

                if eggsInHand == 0 then
                    local egg = player.Backpack:FindFirstChild("Protein Egg")
                    if egg then
                        egg.Parent = player.Character
                    end
                end
                task.wait(0.2)
            end
        end)
        local characterAddedConn = player.CharacterAdded:Connect(function(newChar)
            task.wait(0.5)
            local eggsInHand = 0
            for _, item in ipairs(player.Character:GetChildren()) do
                if item.Name == "Protein Egg" then
                    eggsInHand = 1
                    if eggsInHand > 1 then
                        item.Parent = player.Backpack
                    end
                end
            end

            if eggsInHand == 0 then
                local egg = player.Backpack:FindFirstChild("Protein Egg")
                if egg then
                    egg.Parent = player.Character
                end
            end
        end)
    else
        if eggLoop then task.cancel(eggLoop) end
        if characterAddedConn then characterAddedConn:Disconnect() end
    end
end)
KillingTab:AddButton("Disable Eggs", function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/244ihssp/IlIIS/refs/heads/main/1"))()
end)
KillingTab:AddSwitch("Kill Everyone", function(bool)
    if bool then
        if not _G.killAllConnection then
            _G.killAllConnection = game:GetService("RunService").Heartbeat:Connect(function()
                if _G.killAll then
                    for _, player in ipairs(game:GetService("Players"):GetPlayers()) do
                        if player ~= game.Players.LocalPlayer and not isWhitelisted(player) then
                            killPlayer(player)
                        end
                    end
                end
            end)
        end
    else
        if _G.killAllConnection then
            _G.killAllConnection:Disconnect()
            _G.killAllConnection = nil
        end
    end
end)
KillingTab:AddSwitch("Whitelist Friends", function(bool)
    if bool then
        for _, player in pairs(game.Players:GetPlayers()) do
            if player ~= game.Players.LocalPlayer and player:IsFriendsWith(game.Players.LocalPlayer.UserId) then
                local playerName = player.Name
                local alreadyWhitelisted = false
                for _, name in ipairs(_G.whitelistedPlayers) do
                    if name:lower() == playerName:lower() then
                        alreadyWhitelisted = true
                        break
                    end
                end
                if not alreadyWhitelisted then
                    table.insert(_G.whitelistedPlayers, playerName)
                end
            end
        end

        game.Players.PlayerAdded:Connect(function(player)
            if _G.whitelistFriends and player:IsFriendsWith(game.Players.LocalPlayer.UserId) then
                local playerName = player.Name
                local alreadyWhitelisted = false
                for _, name in ipairs(_G.whitelistedPlayers) do
                    if name:lower() == playerName:lower() then
                        alreadyWhitelisted = true
                        break
                    end
                end
                if not alreadyWhitelisted then
                    table.insert(_G.whitelistedPlayers, playerName)
                end
            end
        end)
    end
end)
KillingTab:AddDropdown("Add to Killlist", function(selectedText)
    local playerName = selectedText:match("| (.+)$")
    if playerName then
        playerName = playerName:gsub("^%s*(.-)%s*$", "%1") 
        for _, name in ipairs(_G.blacklistedPlayers) do
            if name:lower() == playerName:lower() then return end
        end
        table.insert(_G.blacklistedPlayers, playerName)
    end
end)
KillingTab:AddSwitch("Kill List", function(bool)
    _G.killBlacklistedOnly = bool
    if bool then
        if not _G.blacklistKillConnection then
            _G.blacklistKillConnection = game:GetService("RunService").Heartbeat:Connect(function()
                if _G.killBlacklistedOnly then
                    for _, player in ipairs(game:GetService("Players"):GetPlayers()) do
                        if player ~= game.Players.LocalPlayer and isBlacklisted(player) then
                            killPlayer(player)
                        end
                    end
                end
            end)
        end
    else
        if _G.blacklistKillConnection then
            _G.blacklistKillConnection:Disconnect()
            _G.blacklistKillConnection = nil
        end
    end
end)
KillingTab:AddDropdown("Choose Player", function(text)
    local selectedPlayerToSpectate = nil
    for _, player in ipairs(game.Players:GetPlayers()) do
        local optionText = player.DisplayName .. " | " .. player.Name
        if text == optionText then
            selectedPlayerToSpectate = player
            if spectating then
                updateSpectateTarget(player)
            end
            break
        end
    end
end)
KillingTab:AddSwitch("Spectate", function(bool)
    spectating = bool
    if spectating and selectedPlayerToSpectate then
        updateSpectateTarget(selectedPlayerToSpectate)
    else
        if currentTargetConnection then
            currentTargetConnection:Disconnect()
            currentTargetConnection = nil
        end
        local localPlayer = game.Players.LocalPlayer
        if localPlayer.Character then
            local humanoid = localPlayer.Character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                camera.CameraSubject = humanoid
            end
        end
    end
end)
KillingTab:AddTextBox("Range 1-140", function(text)
    local range = tonumber(text)
    if range then
        _G.deathRingRange = math.clamp(range, 1, 140)
        updateRingSize()
    end
end)
KillingTab:AddSwitch("Death Ring", function(bool)
    if bool then
        if not _G.deathRingConnection then
            _G.deathRingConnection = game:GetService("RunService").Heartbeat:Connect(function()
                updateRingPosition()

                local character = checkCharacter()
                local myPosition = character and character:FindFirstChild("HumanoidRootPart") and character.HumanoidRootPart.Position
                if not myPosition then return end

                for _, player in ipairs(game:GetService("Players"):GetPlayers()) do
                    if player ~= game.Players.LocalPlayer and not isWhitelisted(player) and isPlayerAlive(player) then
                        local distance = (myPosition - player.Character.HumanoidRootPart.Position).Magnitude
                        if distance <= (_G.deathRingRange or 20) then
                            killPlayer(player)
                        end
                    end
                end
            end)
        end
    else
        if _G.deathRingConnection then
            _G.deathRingConnection:Disconnect()
            _G.deathRingConnection = nil
        end
    end
end)
KillingTab:AddSwitch("Show Ring", function(bool)
    if bool then
        ringPart = Instance.new("Part")
        ringPart.Shape = Enum.PartType.Cylinder
        ringPart.Material = Enum.Material.Neon
        ringPart.Color = ringColor
        ringPart.Transparency = ringTransparency
        ringPart.Anchored = true
        ringPart.CanCollide = false
        ringPart.CastShadow = false
        updateRingSize()
        ringPart.Parent = workspace
    elseif ringPart then
        ringPart:Destroy()
        ringPart = nil
    end
end)
KillingTab:AddButton("Clear Whitelist", function()
    _G.whitelistedPlayers = {}
end)
KillingTab:AddButton("Clear Blacklist", function()
    _G.blacklistedPlayers = {}
end)

-- Specs tab elements
SpecsTab:AddLabel("Player Stats:")
SpecsTab:AddDropdown("Choose Player", function(text)
    for _, player in ipairs(game.Players:GetPlayers()) do
        local optionText = player.DisplayName .. " | " .. player.Name
        if text == optionText then
            playerToInspect = player
            updateStatLabels(playerToInspect)
            break
        end
    end
end)
SpecsTab:AddLabel("Name: N/A")
SpecsTab:AddLabel("Username: N/A")
SpecsTab:AddLabel("Strength: 0 (0)")
SpecsTab:AddLabel("Rebirths: 0 (0)")
SpecsTab:AddLabel("Durability: 0 (0)")
SpecsTab:AddLabel("Agility: 0 (0)")
SpecsTab:AddLabel("Kills: 0 (0)")
SpecsTab:AddLabel("Evil Karma: 0 (0)")
SpecsTab:AddLabel("Good Karma: 0 (0)")
SpecsTab:AddLabel("Brawls: 0 (0)")
SpecsTab:AddLabel("————————————————————————————")
SpecsTab:AddLabel("Advanced Stats:")
SpecsTab:AddLabel("Enemy Health: N/A")
SpecsTab:AddLabel("Your Damage: N/A")
SpecsTab:AddLabel("Hits to Kill: N/A")

-- Farming tab elements
FarmingTab:AddLabel("Misc")
FarmingTab:AddSwitch("Auto Lift (Gamepass)", function(bool)
    if bool then
        local gamepassFolder = game:GetService("ReplicatedStorage").gamepassIds
        local player = game:GetService("Players").LocalPlayer
        for _, gamepass in pairs(gamepassFolder:GetChildren()) do
            local value = Instance.new("IntValue")
            value.Name = gamepass.Name
            value.Value = gamepass.Value
            value.Parent = player.ownedGamepasses
        end
    else
        local player = game:GetService("Players").LocalPlayer
        if player and player.ownedGamepasses then
            local gamepassFolder = game:GetService("ReplicatedStorage").gamepassIds
            for _, gamepass in pairs(gamepassFolder:GetChildren()) do
                local ownedPass = player.ownedGamepasses:FindFirstChild(gamepass.Name)
                if ownedPass and ownedPass.Value == gamepass.Value then
                    ownedPass:Destroy()
                end
            end
        end
    end
end)
FarmingTab:AddTextBox("Set Rebirth Target", function(text)
    local rebirths = player.leaderstats:WaitForChild("Rebirths")
    local targetRebirths = tonumber(text)
    if targetRebirths and targetRebirths >= 0 then
        rebirths.Value = targetRebirths
    end
end)
FarmingTab:AddSwitch("Auto Rebirth", function(enabled)
    if enabled then
        local rebirths = player.leaderstats:WaitForChild("Rebirths")
        local targetRebirths = tonumber(FarmingTab:GetTextBox("Set Rebirth Target").Value)
        if targetRebirths and rebirths.Value < targetRebirths then
            task.spawn(function()
                while rebirths.Value < targetRebirths do
                    game:GetService("ReplicatedStorage").rEvents.rebirthRemote:InvokeServer("rebirthRequest")
                    task.wait(0.05)
                end
            end)
        end
    end
end)
FarmingTab:AddSwitch("Auto Size 1", function(bool)
    if bool then
        local character = game.Players.LocalPlayer.Character
        if character then
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                game:GetService("ReplicatedStorage").rEvents.changeSizeRemote:InvokeServer("changeSize", 1)
            end
        end
    end
end)
FarmingTab:AddSwitch("Auto King", function(bool)
    if bool then
        local targetPosition = CFrame.new(-8665.4, 17.21, -5792.9)
        local char = game.Players.LocalPlayer.Character or game.Players.LocalPlayer.CharacterAdded:Wait()
        local hrp = char:WaitForChild("HumanoidRootPart")
        while bool do
            if (hrp.Position - targetPosition.Position).magnitude > 5 then
                hrp.CFrame = targetPosition
            end
            task.wait(0.05)
        end
    end
end)
FarmingTab:AddLabel("Tools:")
FarmingTab:AddDropdown("Select Tool", function(selection)
    local SelectedTool = selection
    local AutoFarm = false
    FarmingTab:AddSwitch("Start", function(enabled)
        AutoFarm = enabled

        if enabled then
            task.spawn(function()
                while AutoFarm do
                    local player = game:GetService("Players").LocalPlayer

                    if SelectedTool == "Weight" then
                        if not player.Character:FindFirstChild("Weight") then
                            local weightTool = player.Backpack:FindFirstChild("Weight")
                            if weightTool then
                                player.Character.Humanoid:EquipTool(weightTool)
                            end
                        end
                        player.muscleEvent:FireServer("rep")

                    elseif SelectedTool == "Pushups" then
                        if not player.Character:FindFirstChild("Pushups") then
                            local pushupsTool = player.Backpack:FindFirstChild("Pushups")
                            if pushupsTool then
                                player.Character.Humanoid:EquipTool(pushupsTool)
                            end
                        end
                        player.muscleEvent:FireServer("rep")

                    elseif SelectedTool == "Situps" then
                        if not player.Character:FindFirstChild("Situps") then
                            local situpsTool = player.Backpack:FindFirstChild("Situps")
                            if situpsTool then
                                player.Character.Humanoid:EquipTool(situpsTool)
                            end
                        end
                        player.muscleEvent:FireServer("rep")

                    elseif SelectedTool == "Handstands" then
                        if not player.Character:FindFirstChild("Handstands") then
                            local handstandsTool = player.Backpack:FindFirstChild("Handstands")
                            if handstandsTool then
                                player.Character.Humanoid:EquipTool(handstandsTool)
                            end
                        end
                        player.muscleEvent:FireServer("rep")

                    elseif SelectedTool == "Fast Punch" then
                        local punch = player.Backpack:FindFirstChild("Punch")
                        if punch then
                            punch.Parent = player.Character
                            if punch:FindFirstChild("attackTime") then
                                punch.attackTime.Value = 0
                            end
                        end
                        player.muscleEvent:FireServer("punch", "rightHand")
                        player.muscleEvent:FireServer("punch", "leftHand")

                        if player.Character:FindFirstChild("Punch") then
                            player.Character.Punch:Activate()
                        end

                    elseif SelectedTool == "Stomp" then
                        local stomp = player.Backpack:FindFirstChild("Stomp")
                        if stomp then
                            stomp.Parent = player.Character
                            if stomp:FindFirstChild("attackTime") then
                                stomp.attackTime.Value = 0
                            end
                        end
                        player.muscleEvent:FireServer("stomp")

                        if player.Character:FindFirstChild("Stomp") then
                            player.Character.Stomp:Activate()
                        end

                        if tick() % 6 < 0.1 then
                            local virtualUser = game:GetService("VirtualUser")
                            virtualUser:CaptureController()
                            virtualUser:ClickButton1(Vector2.new(500, 500))
                        end

                    elseif SelectedTool == "Ground Slam" then
                        local groundSlam = player.Backpack:FindFirstChild("Ground Slam")
                        if groundSlam then
                            groundSlam.Parent = player.Character
                            if groundSlam:FindFirstChild("attackTime") then
                                groundSlam.attackTime.Value = 0
                            end
                        end
                        player.muscleEvent:FireServer("slam")

                        if player.Character:FindFirstChild("Ground Slam") then
                            player.Character["Ground Slam"]:Activate()
                        end

                        if tick() % 6 < 0.1 then
                            local virtualUser = game:GetService("VirtualUser")
                            virtualUser:CaptureController()
                            virtualUser:ClickButton1(Vector2.new(500, 500))
                        end
                    end

                    task.wait()
                end
            end)
        else
            local player = game:GetService("Players").LocalPlayer
            if SelectedTool and player.Character:FindFirstChild(SelectedTool) then
                player.Character:FindFirstChild(SelectedTool).Parent = player.Backpack
            end
        end
    end)
end)
FarmingTab:AddLabel("Rocks:")
FarmingTab:AddDropdown("Select Rock", function(selection)
    local selectedRock = selection
    local rockData = {
        ["Tiny Rock"] = 0,
        ["Starter Island"] = 100,
        ["Punching Rock"] = 1000,
        ["Golden Rock"] = 5000,
        ["Frost Rock"] = 150000,
        ["Mythical Rock"] = 400000,
        ["Eternal Rock"] = 750000,
        ["Legend Rock"] = 1000000,
        ["Muscle King Rock"] = 5000000,
        ["Jungle Rock"] = 10000000
    }
    local requiredDurability = rockData[selectedRock]
    local player = game:GetService("Players").LocalPlayer
    if player.Durability.Value >= requiredDurability then
        for _, v in pairs(workspace.machinesFolder:GetDescendants()) do
            if v.Name == "neededDurability" and v.Value == requiredDurability and
                player.Character:FindFirstChild("LeftHand") and
                player.Character:FindFirstChild("RightHand") then

                local rock = v.Parent:FindFirstChild("Rock")
                if rock then
                    firetouchinterest(rock, player.Character.RightHand, 0)
                    firetouchinterest(rock, player.Character.RightHand, 1)
                    firetouchinterest(rock, player.Character.LeftHand, 0)
                    firetouchinterest(rock, player.Character.LeftHand, 1)
                    gettool()
                end
            end
        end
    end
end)
FarmingTab:AddLabel("Machines:")
FarmingTab:AddDropdown("Gym", function(location)
    local selectedLocation = location
    local workoutPositions = {
        ["Jungle Gym"] = {
            ["Bench Press"] = CFrame.new(-8173, 64, 1898),
            ["Squat"] = CFrame.new(-8352, 34, 2878),
            ["Pull Up"] = CFrame.new(-8666, 34, 2070),
            ["Boulder"] = CFrame.new(-8621, 34, 2684)
        },
        ["Muscle King Gym"] = {
            ["Bench Press"] = CFrame.new(-8590.06152, 46.0167427, -6043.34717),
            ["Squat"] = CFrame.new(-8940.12402, 13.1642084, -5699.13477),
            ["Pull Up"] = CFrame.new(-8940.12402, 13.1642084, -5699.13477),
            ["Boulder"] = CFrame.new(-8940.12402, 13.1642084, -5699.13477)
        },
        ["Legend Gym"] = {
            ["Bench Press"] = CFrame.new(4111.91748, 1020.46674, -3799.97217),
            ["Squat"] = CFrame.new(4304.99023, 987.829956, -4124.2334),
            ["Pull Up"] = CFrame.new(4304.99023, 987.829956, -4124.2334),
            ["Boulder"] = CFrame.new(4304.99023, 987.829956, -4124.2334)
        }
    }
    local workoutTypeDropdown = FarmingTab:AddDropdown("Machine", function(machine)
        local selectedWorkout = machine
        local working = false
        local repTask = nil

        local function pressE()
            local vim = game:GetService("VirtualInputManager")
            vim:SendKeyEvent(true, "E", false, game)
            task.wait(0.1)
            vim:SendKeyEvent(false, "E", false, game)
        end

        local function autoLift()
            while working and task.wait() do
                game:GetService("Players").LocalPlayer.muscleEvent:FireServer("rep")
            end
        end

        local function stopAutoLift()
            if repTask then
                repTask:Cancel()  
                repTask = nil
            end
        end

        local function teleportAndStart(machineName, position)
            local char = game.Players.LocalPlayer.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                char.HumanoidRootPart.CFrame = position
                task.wait(0.5)
                pressE()
                if working then
                    repTask = task.spawn(autoLift)
                end
            end
        end

        FarmingTab:AddSwitch("Start", function(enabled)
            working = enabled

            if enabled then
                if selectedLocation and selectedWorkout and workoutPositions[selectedWorkout][selectedLocation] then
                    teleportAndStart(selectedWorkout, workoutPositions[selectedWorkout][selectedLocation])
                end
            else
                stopAutoLift()
            end
        end)
    end)
    workoutTypeDropdown:Add("Bench Press")
    workoutTypeDropdown:Add("Squat")
    workoutTypeDropdown:Add("Pull Up")
    workoutTypeDropdown:Add("Boulder")
end)

-- Inventory tab elements
InventoryTab:AddLabel("Eater:")
InventoryTab:AddSwitch("Egg Devour", function(state)
    if state then
        activateProteinEgg()
    end
end)
InventoryTab:AddSwitch("Eat Everything", function(state)
    if state then
        activateRandomItems(4)
    end
end)

-- Teleport tab elements
TeleportTab:AddLabel("Main:")
TeleportTab:AddButton("Tiny Island", function()
    local char = game.Players.LocalPlayer.Character or game.Players.LocalPlayer.CharacterAdded:Wait()
    local hrp = char:WaitForChild("HumanoidRootPart")
    hrp.CFrame = CFrame.new(-37.1, 9.2, 1919)
end)
TeleportTab:AddButton("Main Island", function()
    local char = game.Players.LocalPlayer.Character or game.Players.LocalPlayer.CharacterAdded:Wait()
    local hrp = char:WaitForChild("HumanoidRootPart")
    hrp.CFrame = CFrame.new(16.07, 9.08, 133.8)
end)
TeleportTab:AddButton("Beach", function()
    local char = game.Players.LocalPlayer.Character or game.Players.LocalPlayer.CharacterAdded:Wait()
    local hrp = char:WaitForChild("HumanoidRootPart")
    hrp.CFrame = CFrame.new(-8, 9, -169.2)
end)
TeleportTab:AddLabel("Gyms:")
TeleportTab:AddButton("Muscle King Gym", function()
    local char = game.Players.LocalPlayer.Character or game.Players.LocalPlayer.CharacterAdded:Wait()
    local hrp = char:WaitForChild("HumanoidRootPart")
    hrp.CFrame = CFrame.new(-8665.4, 17.21, -5792.9)
end)
TeleportTab:AddButton("Jungle Gym", function()
    local char = game.Players.LocalPlayer.Character or game.Players.LocalPlayer.CharacterAdded:Wait()
    local hrp = char:WaitForChild("HumanoidRootPart")
    hrp.CFrame = CFrame.new(-8543, 6.8, 2400)
end)
TeleportTab:AddButton("Legends Gym", function()
    local char = game.Players.LocalPlayer.Character or game.Players.LocalPlayer.CharacterAdded:Wait()
    local hrp = char:WaitForChild("HumanoidRootPart")
    hrp.CFrame = CFrame.new(4516, 991.5, -3856)
end)
TeleportTab:AddButton("Infernal Gym", function()
    local char = game.Players.LocalPlayer.Character or game.Players.LocalPlayer.CharacterAdded:Wait()
    local hrp = char:WaitForChild("HumanoidRootPart")
    hrp.CFrame = CFrame.new(-6759, 7.36, -1284)
end)
TeleportTab:AddButton("Mythical Gym", function()
    local char = game.Players.LocalPlayer.Character or game.Players.LocalPlayer.CharacterAdded:Wait()
    local hrp = char:WaitForChild("HumanoidRootPart")
    hrp.CFrame = CFrame.new(2250, 7.37, 1073.2)
end)
TeleportTab:AddButton("Frost Gym", function()
    local char = game.Players.LocalPlayer.Character or game.Players.LocalPlayer.CharacterAdded:Wait()
    local hrp = char:WaitForChild("HumanoidRootPart")
    hrp.CFrame = CFrame.new(-2623, 7.36, -409)
end)

-- Pets tab elements
PetsTab:AddLabel("Pets:")
PetsTab:AddDropdown("Choose Pet", function(text)
    local selectedPet = text
    local petDropdown = PetsTab:AddDropdown("Choose Pet", function(text)
        selectedPet = text
    end)
    petDropdown:Add("Darkstar Hunter")
    petDropdown:Add("Neon Guardian")
    petDropdown:Add("Blue Birdie")
    petDropdown:Add("Blue Bunny")
    petDropdown:Add("Blue Firecaster")
    petDropdown:Add("Blue Pheonix")
    petDropdown:Add("Crimson Falcon")
    petDropdown:Add("Cybernetic Showdown Dragon")
    petDropdown:Add("Dark Golem")
    petDropdown:Add("Dark Legends Manticore")
    petDropdown:Add("Dark Vampy")
    petDropdown:Add("Eternal Strike Leviathan")
    petDropdown:Add("Frostwave Legends Penguin")
    petDropdown:Add("Gold Warrior")
    petDropdown:Add("Golden Pheonix")
    petDropdown:Add("Golden Viking")
    petDropdown:Add("Green Butterfly")
    petDropdown:Add("Green Firecaster")
    petDropdown:Add("Infernal Dragon")
    petDropdown:Add("Lightning Strike Phantom")
    petDropdown:Add("Magic Butterfly")
    petDropdown:Add("Muscle Sensei")
    petDropdown:Add("Orange Hedgehog")
    petDropdown:Add("Orange Pegasus")
    petDropdown:Add("Phantom Genesis Dragon")
    petDropdown:Add("Purple Dragon")
    petDropdown:Add("Purple Falcon")
    petDropdown:Add("Red Dragon")
    petDropdown:Add("Red Firecaster")
    petDropdown:Add("Red Kitty")
    petDropdown:Add("Silver Dog")
    petDropdown:Add("Ultimate Supernova Pegasus")
    petDropdown:Add("Ultra Birdie")
    petDropdown:Add("White Pegasus")
    petDropdown:Add("White Pheonix")
    petDropdown:Add("Yellow Butterfly")
    PetsTab:AddSwitch("Buy Pet", function(bool)
        if bool then
            spawn(function()
                while _G.AutoHatchPet and selectedPet ~= "" do
                    local petToOpen = game:GetService("ReplicatedStorage").cPetShopFolder:FindFirstChild(selectedPet)
                    if petToOpen then
                        game:GetService("ReplicatedStorage").cPetShopRemote:InvokeServer(petToOpen)
                    end
                    task.wait(0.1)
                end
            end)
        end
    end)
    PetsTab:AddLabel("Auras:")
    local selectedAura = "Entropic Blast"
    local auraDropdown = PetsTab:AddDropdown("Select Aura", function(text)
        selectedAura = text
    end)
    auraDropdown:Add("Entropic Blast")
    auraDropdown:Add("Muscle King")
    auraDropdown:Add("Astral Electro")
    auraDropdown:Add("Azure Tundra")
    auraDropdown:Add("Blue Aura")
    auraDropdown:Add("Dark Electro")
    auraDropdown:Add("Dark Lightning")
    auraDropdown:Add("Dark Storm")
    auraDropdown:Add("Electro")
    auraDropdown:Add("Enchanted Mirage")
    auraDropdown:Add("Eternal Megastrike")
    auraDropdown:Add("Grand Supernova")
    auraDropdown:Add("Green Aura")
    auraDropdown:Add("Inferno")
    auraDropdown:Add("Lightning")
    auraDropdown:Add("Power Lightning")
    auraDropdown:Add("Purple Aura")
    auraDropdown:Add("Purple Nova")
    auraDropdown:Add("Red Aura")
    auraDropdown:Add("Supernova")
    auraDropdown:Add("Ultra Inferno")
    auraDropdown:Add("Ultra Mirage")
    auraDropdown:Add("Unstable Mirage")
    auraDropdown:Add("Yellow Aura")
    PetsTab:AddSwitch("Buy Aura", function(bool)
        if bool then
            spawn(function()
                while _G.AutoHatchAura and selectedAura ~= "" do
                    local auraToOpen = game:GetService("ReplicatedStorage").cPetShopFolder:FindFirstChild(selectedAura)
                    if auraToOpen then
                        game:GetService("ReplicatedStorage").cPetShopRemote:InvokeServer(auraToOpen)
                    end
                    task.wait(0.1)
                end
            end)
        end
    end)
end)

-- Stats tab elements
StatsTab:AddLabel("Time:")
StatsTab:AddLabel("0d 0h 0m 0s")
StatsTab:AddLabel("Stats:")
StatsTab:AddLabel("Strength: 0 (0)")
StatsTab:AddLabel("Rebirths: 0 (0)")
StatsTab:AddLabel("Durability: 0 (0)")
StatsTab:AddLabel("Kills: 0 (0)")
StatsTab:AddLabel("Agility: 0 (0)")
StatsTab:AddLabel("Evil Karma: 0 (0)")
StatsTab:AddLabel("Good Karma: 0 (0)")
StatsTab:AddLabel("Brawls: 0 (0)")

-- Info tab elements
InfoTab:AddLabel("Made by Henne ♥️")
InfoTab:AddLabel("Official Discord: discord.gg/silencev1")
InfoTab:AddButton("Copy Discord Invite", function()
    local link = "https://discord.gg/9eFf93Kg8D"
    if setclipboard then
        setclipboard(link)
        game.StarterGui:SetCore("SendNotification", {
            Title = "Link Copied!";
            Text = "You can continue to Discord now.";
            Duration = 3;
        })
    else
        game.StarterGui:SetCore("SendNotification", {
            Title = "Error!";
            Text = "Not Supported.";
            Duration = 3;
        })
    end
end)
InfoTab:AddLabel("")
InfoTab:AddLabel("VERSION//2.0.0")

-- Initialize SaveManager and InterfaceManager
SaveManager:SetLibrary(Library)
InterfaceManager:SetLibrary(Library)

SaveManager:BuildFolderTree()
InterfaceManager:BuildFolderTree()

SaveManager:LoadAutoloadConfig()
InterfaceManager:LoadSettings()
