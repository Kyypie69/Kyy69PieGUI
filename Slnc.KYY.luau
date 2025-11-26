-- SilenceV2Farming with KyypieUI
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualUser = game:GetService("VirtualUser")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local UserInputService = game:GetService("UserInputService")

local localPlayer = Players.LocalPlayer
local username = localPlayer.Name
local userId = localPlayer.UserId

local muscleEvent = localPlayer:WaitForChild("muscleEvent")
local changeSpeedSizeRemote = ReplicatedStorage.rEvents.changeSpeedSizeRemote

-- Load KyypieUI Library
local Library, SaveManager, InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/Kyypie69/Library.UI/refs/heads/main/KyypieUI.lua"))()

-- Create Window
local Window = Library:CreateWindow({
    Title = "KYY HUB",
    SubTitle = "Kyypie UI",
    TabWidth = 150,
    Size = UDim2.fromOffset(500, 320),
    Acrylic = true, -- Set to true if you want acrylic effect
    Theme = "LightBlue", -- You can change this to any available theme
})

-- Anti AFK
local function setupAntiAFK()
    local antiAFKConnection
    antiAFKConnection = localPlayer.Idled:Connect(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end)
end
setupAntiAFK()

-- Portal Removal
local function removePortals()
    for _, portal in pairs(game:GetDescendants()) do
        if portal.Name == "RobloxForwardPortals" then
            portal:Destroy()
        end
    end
    
    if _G.AdRemovalConnection then
        _G.AdRemovalConnection:Disconnect()
    end
    
    _G.AdRemovalConnection = game.DescendantAdded:Connect(function(descendant)
        if descendant.Name == "RobloxForwardPortals" then
            descendant:Destroy()
        end
    end)
end
removePortals()

-- Block Frames
local blockedFrames = {
    "strengthFrame",
    "durabilityFrame", 
    "agilityFrame",
    "evilKarmaFrame",
    "goodKarmaFrame",
}

for _, name in ipairs(blockedFrames) do
    local frame = ReplicatedStorage:FindFirstChild(name)
    if frame and frame:IsA("GuiObject") then
        frame.Visible = false
    end
end

ReplicatedStorage.ChildAdded:Connect(function(child)
    if table.find(blockedFrames, child.Name) and child:IsA("GuiObject") then
        child.Visible = false
    end
end)

-- Create Tabs
local MainTab = Window:AddTab({Title = "Main", Icon = "settings"})
local KillingTab = Window:AddTab({Title = "Killing", Icon = "sword"})
local SpecsTab = Window:AddTab({Title = "Specs", Icon = "user"})
local FarmingTab = Window:AddTab({Title = "Farming", Icon = "dumbbell"})
local InventoryTab = Window:AddTab({Title = "Inventory", Icon = "package"})
local PetsTab = Window:AddTab({Title = "Pet Shop", Icon = "paw-print"})
local TeleportTab = Window:AddTab({Title = "Teleports", Icon = "map-pin"})
local StatsTab = Window:AddTab({Title = "Stats", Icon = "bar-chart"})

-- Main Tab Functions
local userSize = 2
local sizeActive = false
local userSpeed = 120
local speedActive = false

-- Size Control
MainTab:AddSlider("SizeSlider", {
    Title = "Size",
    Description = "Adjust player size",
    Default = 2,
    Min = 0.1,
    Max = 50,
    Rounding = 1,
    Callback = function(Value)
        userSize = Value
    end
})

MainTab:AddToggle("SetSizeToggle", {
    Title = "Set Size",
    Description = "Enable size modification",
    Default = false,
    Callback = function(Value)
        sizeActive = Value
    end
})

-- Speed Control
MainTab:AddSlider("SpeedSlider", {
    Title = "Speed",
    Description = "Adjust player speed",
    Default = 120,
    Min = 16,
    Max = 500,
    Rounding = 0,
    Callback = function(Value)
        userSpeed = Value
    end
})

MainTab:AddToggle("SetSpeedToggle", {
    Title = "Set Speed",
    Description = "Enable speed modification",
    Default = false,
    Callback = function(Value)
        speedActive = Value
    end
})

-- Anti Fling
MainTab:AddToggle("AntiFlingToggle", {
    Title = "Anti Fling",
    Description = "Prevent being flung",
    Default = true,
    Callback = function(Value)
        if Value then
            local character = Workspace:FindFirstChild(localPlayer.Name)
            if character then
                local rootPart = character:FindFirstChild("HumanoidRootPart")
                if rootPart then
                    local bodyVelocity = Instance.new("BodyVelocity")
                    bodyVelocity.MaxForce = Vector3.new(100000, 0, 100000)
                    bodyVelocity.Velocity = Vector3.new(0, 0, 0)
                    bodyVelocity.P = 1250
                    bodyVelocity.Parent = rootPart
                end
            end
        else
            local character = Workspace:FindFirstChild(localPlayer.Name)
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
    end
})

-- Lock Position
local lockRunning = false
MainTab:AddToggle("LockPositionToggle", {
    Title = "Lock Position",
    Description = "Lock your character position",
    Default = false,
    Callback = function(Value)
        lockRunning = Value
        if Value then
            local player = localPlayer
            local char = player.Character or player.CharacterAdded:Wait()
            local hrp = char:WaitForChild("HumanoidRootPart")
            local lockPosition = hrp.Position
            
            spawn(function()
                while lockRunning do
                    hrp.Velocity = Vector3.new(0, 0, 0)
                    hrp.RotVelocity = Vector3.new(0, 0, 0)
                    hrp.CFrame = CFrame.new(lockPosition)
                    wait(0.05)
                end
            end)
        end
    end
})

-- Infinite Jump
MainTab:AddToggle("InfiniteJumpToggle", {
    Title = "Infinite Jump",
    Description = "Enable infinite jumping",
    Default = false,
    Callback = function(Value)
        _G.InfiniteJump = Value
        
        if Value then
            local InfiniteJumpConnection
            InfiniteJumpConnection = UserInputService.JumpRequest:Connect(function()
                if _G.InfiniteJump then
                    localPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
                else
                    InfiniteJumpConnection:Disconnect()
                end
            end)
        end
    end
})

-- Walk on Water
local parts = {}
local partSize = 2048
local totalDistance = 50000
local startPosition = Vector3.new(-2, -9.5, -2)

local function createAllParts()
    local numberOfParts = math.ceil(totalDistance / partSize)
    
    for x = 0, numberOfParts - 1 do
        for z = 0, numberOfParts - 1 do
            local function createPart(pos, name)
                local part = Instance.new("Part")
                part.Size = Vector3.new(partSize, 1, partSize)
                part.Position = pos
                part.Anchored = true
                part.Transparency = 1
                part.CanCollide = true
                part.Name = name
                part.Parent = Workspace
                return part
            end
            
            table.insert(parts, createPart(startPosition + Vector3.new(x*partSize,0,z*partSize), "Part_Side_"..x.."_"..z))
            table.insert(parts, createPart(startPosition + Vector3.new(-x*partSize,0,z*partSize), "Part_LeftRight_"..x.."_"..z))
            table.insert(parts, createPart(startPosition + Vector3.new(-x*partSize,0,-z*partSize), "Part_UpLeft_"..x.."_"..z))
            table.insert(parts, createPart(startPosition + Vector3.new(x*partSize,0,-z*partSize), "Part_UpRight_"..x.."_"..z))
        end
    end
end
createAllParts()

MainTab:AddToggle("WalkOnWaterToggle", {
    Title = "Walk on Water",
    Description = "Enable walking on water parts",
    Default = true,
    Callback = function(Value)
        for _, part in ipairs(parts) do
            if part and part.Parent then
                part.CanCollide = Value
            end
        end
    end
})

-- Time Control
MainTab:AddDropdown("TimeDropdown", {
    Title = "Change Time",
    Description = "Change the time of day",
    Values = {"Night", "Day", "Midnight"},
    Default = "Day",
    Callback = function(Value)
        if Value == "Night" then
            Lighting.ClockTime = 0
        elseif Value == "Day" then
            Lighting.ClockTime = 12
        elseif Value == "Midnight" then
            Lighting.ClockTime = 6
        end
    end
})

-- Auto Update Loops
spawn(function()
    while true do
        if sizeActive then
            local character = localPlayer.Character
            if character then
                local humanoid = character:FindFirstChildOfClass("Humanoid")
                if humanoid then
                    changeSpeedSizeRemote:InvokeServer("changeSize", userSize)
                end
            end
        end
        wait(0.15)
    end
end)

spawn(function()
    while true do
        if speedActive then
            local character = localPlayer.Character
            if character then
                local humanoid = character:FindFirstChildOfClass("Humanoid")
                if humanoid then
                    changeSpeedSizeRemote:InvokeServer("changeSpeed", userSpeed)
                end
            end
        end
        wait(0.15)
    end
end)

SpecsTab:AddLabel("Player Stats", 24)

local playerToInspect = nil

local emojiMap = {
    ["Time"] = utf8.char(0x1F55B),
    ["Stats"] = utf8.char(0x1F4CA),
    ["Strength"] = utf8.char(0x1F4AA),
    ["Rebirths"] = utf8.char(0x1F504),
    ["Durability"] = utf8.char(0x1F6E1),
    ["Kills"] = utf8.char(0x1F480),
    ["Agility"] = utf8.char(0x1F3C3),
    ["Evil Karma"] = utf8.char(0x1F608),
    ["Good Karma"] = utf8.char(0x1F607),
    ["Brawls"] = utf8.char(0x1F94A)
}

local statDefinitions = {
    { name = "Strength", statName = "Strength" },
    { name = "Rebirths", statName = "Rebirths" },
    { name = "Durability", statName = "Durability" },
    { name = "Agility", statName = "Agility" },
    { name = "Kills", statName = "Kills" },
    { name = "Evil Karma", statName = "evilKarma" },
    { name = "Good Karma", statName = "goodKarma" },
    { name = "Brawls", statName = "Brawls" }
}

local function getCurrentPlayers()
    local playersList = {}
    for _, p in ipairs(Players:GetPlayers()) do
        table.insert(playersList, p)
    end
    return playersList
end

local specdropdown = SpecsTab:AddDropdown("Choose Player", function(text) 
    for _, player in ipairs(getCurrentPlayers()) do
        local optionText = player.DisplayName .. " | " .. player.Name
        if text == optionText then
            playerToInspect = player
            updateStatLabels(playerToInspect)
            break
        end
    end
end)

for _, player in ipairs(getCurrentPlayers()) do
    specdropdown:Add(player.DisplayName .. " | " .. player.Name)
end

Players.PlayerAdded:Connect(function(player)
    specdropdown:Add(player.DisplayName .. " | " .. player.Name)
end)

Players.PlayerRemoving:Connect(function(player)
    specdropdown:Clear()
    for _, p in ipairs(getCurrentPlayers()) do
        specdropdown:Add(p.DisplayName .. " | " .. p.Name)
    end
end)

local playerNameLabel = SpecsTab:AddLabel("Name: N/A")
playerNameLabel.TextSize = 20

local playerUsernameLabel = SpecsTab:AddLabel("Username: N/A")
playerUsernameLabel.TextSize = 20

local statLabels = {}
for _, info in ipairs(statDefinitions) do
    statLabels[info.name] = SpecsTab:AddLabel(emojiMap[info.name] .. " " .. info.name .. ": 0 (0)")
    statLabels[info.name].TextSize = 20
end

local function formatNumber(n)
    if n >= 1e15 then
        return string.format("%.1fqa", n/1e15)
    elseif n >= 1e12 then
        return string.format("%.1ft", n/1e12)
    elseif n >= 1e9 then
        return string.format("%.1fb", n/1e9)
    elseif n >= 1e6 then
        return string.format("%.1fm", n/1e6)
    elseif n >= 1e3 then
        return string.format("%.1fk", n/1e3)
    else
        return tostring(n)
    end
end

local function formatWithCommas(n)
    local formatted = tostring(math.floor(n))
    while true do
        formatted, k = formatted:gsub("^(-?%d+)(%d%d%d)", '%1,%2')
        if k == 0 then break end
    end
    return formatted
end


local function updateStatLabels(targetPlayer)
    if not targetPlayer then return end

    playerNameLabel.Text = "Name: " .. targetPlayer.DisplayName
    playerUsernameLabel.Text = "Username: " .. targetPlayer.Name

    local leaderstats = targetPlayer:FindFirstChild("leaderstats")
    if not leaderstats then return end

    for _, info in ipairs(statDefinitions) do
        local statObject

        if leaderstats:FindFirstChild(info.statName) then
            statObject = leaderstats:FindFirstChild(info.statName)
        elseif targetPlayer:FindFirstChild(info.statName) then
            statObject = targetPlayer:FindFirstChild(info.statName)
        end

        if statObject then
            local value = statObject.Value
            local emoji = emojiMap[info.name] or ""
            statLabels[info.name].Text = string.format(
                "%s %s: %s (%s)",
                emoji,
                info.name,
                formatNumber(value),
                formatWithCommas(value)
            )
        else
            statLabels[info.name].Text = emojiMap[info.name] .. " " .. info.name .. ": 0 (0)"
        end
    end
end

task.spawn(function()
    while true do
        if playerToInspect then
            updateStatLabels(playerToInspect)
        end
        task.wait(0.2)
    end
end)

SpecsTab:AddLabel("————————————————————————————")

SpecsTab:AddLabel("Advanced Stats:").TextSize = 24

local enemyHealthLabel = SpecsTab:AddLabel("Enemy Health: N/A")
enemyHealthLabel.TextSize = 20
enemyHealthLabel.TextColor3 = Color3.fromRGB(0, 140, 255)

local playerDamageLabel = SpecsTab:AddLabel("Your Damage: N/A")
playerDamageLabel.TextSize = 20
playerDamageLabel.TextColor3 = Color3.fromRGB(255, 0, 0)

local hitsToKillLabel = SpecsTab:AddLabel("Hits to Kill: N/A")
hitsToKillLabel.TextSize = 20
hitsToKillLabel.TextColor3 = Color3.fromRGB(255, 0, 0)



local function calculateEnemyHealth(targetPlayer)
    if not targetPlayer then return 0 end

    local baseDura = 0
    local durabilityStat = targetPlayer:FindFirstChild("Durability") 
        or (targetPlayer:FindFirstChild("leaderstats") and targetPlayer.leaderstats:FindFirstChild("Durability"))
    if durabilityStat then
        baseDura = durabilityStat.Value
    end

    local totalMultiplier = 1

    local ultFolder = targetPlayer:FindFirstChild("ultimatesFolder")
    if ultFolder then
        local infernalHealth = ultFolder:FindFirstChild("Infernal Health")
        if infernalHealth then
            local upgrades = infernalHealth.Value or 0
            totalMultiplier = totalMultiplier + 0.15 * upgrades
        end
    end

    local equippedPetsFolder = targetPlayer:FindFirstChild("equippedPets")
    if equippedPetsFolder then
        local petBonus = 0
        for _, petValue in ipairs(equippedPetsFolder:GetChildren()) do
            if petValue:IsA("ObjectValue") and petValue.Value then
                local petNameLower = string.lower(petValue.Value.Name)
                if petNameLower:match("mighty") and petNameLower:match("monster") then
                    petBonus = petBonus + 0.5
                end
            end
        end
        totalMultiplier = totalMultiplier + petBonus
    end

    local totalHealth = baseDura * totalMultiplier
    return totalHealth
end

local function calculateLocalPlayerDamage()
    local strengthStat = nil
    local leaderstats = Player:FindFirstChild("leaderstats")
    if leaderstats then
        strengthStat = leaderstats:FindFirstChild("Strength")
    end
    if not strengthStat then return 0 end

    local baseDamage = strengthStat.Value * 0.0667
    local totalMultiplier = 1

    local ultFolder = Player:FindFirstChild("ultimatesFolder")
    if ultFolder then
        local demonDamage = ultFolder:FindFirstChild("Demon Damage")
        if demonDamage then
            local upgrades = demonDamage.Value or 0
            totalMultiplier = totalMultiplier + 0.1 * upgrades
        end
    end

local equippedPetsFolder = Player:FindFirstChild("equippedPets")
    if equippedPetsFolder then
        local petBonus = 0
        for _, petValue in ipairs(equippedPetsFolder:GetChildren()) do
            if petValue:IsA("ObjectValue") and petValue.Value then
                local petNameLower = string.lower(petValue.Value.Name)
                if petNameLower:match("wild") and petNameLower:match("wizard") then
                    petBonus = petBonus + 0.5
                end
            end
        end
        totalMultiplier = totalMultiplier + petBonus
    end

    baseDamage = baseDamage * totalMultiplier
    return baseDamage
end



local function calculateHitsToKill(health, damage)
    if damage <= 0 then return "∞" end
    local hits = math.ceil(health / damage)
    if hits > 100 then
        return "∞"
    elseif hits < 1 then
        return 1
    else
        return hits
    end
end

local function updateAdvancedStats(targetPlayer)
    if not targetPlayer then
        enemyHealthLabel.Text = "Enemy Health: N/A"
        playerDamageLabel.Text = "Your Damage: N/A"
        hitsToKillLabel.Text = "Hits to Kill: N/A"
        return
    end
    local enemyHealth = calculateEnemyHealth(targetPlayer)
    local playerDamage = calculateLocalPlayerDamage()
    local hitsToKill = calculateHitsToKill(enemyHealth, playerDamage)
    enemyHealthLabel.Text = string.format("Enemy Health: %s (%s)", formatNumber(enemyHealth), formatWithCommas(enemyHealth))
    playerDamageLabel.Text = string.format("Your Damage: %s (%s)", formatNumber(playerDamage), formatWithCommas(playerDamage))
    hitsToKillLabel.Text = string.format("Hits to Kill: %s", tostring(hitsToKill))
end

task.spawn(function()
    while true do
        if playerToInspect then
            updateAdvancedStats(playerToInspect)
        else
            updateAdvancedStats(nil)
        end
        task.wait(0.1)
    end
end)

local function checkCharacter()
    if not game.Players.LocalPlayer.Character then
        repeat task.wait() until game.Players.LocalPlayer.Character
    end
    return game.Players.LocalPlayer.Character
end

local function gettool()
    for _, v in pairs(game.Players.LocalPlayer.Backpack:GetChildren()) do
        if v.Name == "Punch" and game.Players.LocalPlayer.Character:FindFirstChild("Humanoid") then
            game.Players.LocalPlayer.Character.Humanoid:EquipTool(v)
        end
    end
    game.Players.LocalPlayer.muscleEvent:FireServer("punch", "leftHand")
    game.Players.LocalPlayer.muscleEvent:FireServer("punch", "rightHand")
end

local function isPlayerAlive(player)
    return player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and
           player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0
end

local function killPlayer(target)
    if not isPlayerAlive(target) then return end
    local character = checkCharacter()
    if character and character:FindFirstChild("LeftHand") then
        pcall(function()
            firetouchinterest(target.Character.HumanoidRootPart, character.LeftHand, 0)
            firetouchinterest(target.Character.HumanoidRootPart, character.LeftHand, 1)
            gettool()
        end)
    end
end

-- Killing Tab
KillingTab:AddDropdown("SelectPetDropdown", {
    Title = "Select Pet",
    Description = "Choose your pet",
    Values = {"Wild Wizard", "Mighty Monster"},
    Default = "Wild Wizard",
    Callback = function(Value)
        local petsFolder = localPlayer.petsFolder
        for _, folder in pairs(petsFolder:GetChildren()) do
            if folder:IsA("Folder") then
                for _, pet in pairs(folder:GetChildren()) do
                    ReplicatedStorage.rEvents.equipPetEvent:FireServer("unequipPet", pet)
                end
            end
        end
        wait(0.2)

        local petName = Value
        local petsToEquip = {}

        for _, pet in pairs(localPlayer.petsFolder.Unique:GetChildren()) do
            if pet.Name == petName then
                table.insert(petsToEquip, pet)
            end
        end

        for i = 1, math.min(8, #petsToEquip) do
            ReplicatedStorage.rEvents.equipPetEvent:FireServer("equipPet", petsToEquip[i])
            wait(0.1)
        end
    end
})

KillingTab:AddToggle("RemoveAnimationsToggle", {
    Title = "Remove Attack Animations",
    Description = "Disable attack animations",
    Default = false,
    Callback = function(Value)
        if value then
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
    end
})

G.BackpackAddedConnection = game.Players.LocalPlayer.Backpack.ChildAdded:Connect(function(child)
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

switch:Set(false)


local player = game:GetService("Players").LocalPlayer

local comboActive = false
local eggLoop, characterAddedConn

local function ensureEggEquipped()
    if not comboActive or not player.Character then return end
    
    local eggsInHand = 0
    for _, item in ipairs(player.Character:GetChildren()) do
        if item.Name == "Protein Egg" then
            eggsInHand += 1
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
end

local comboSwitch = KillingTab:AddToggle("NaNToggle", {
Title = "NaN Egg+NaN+Punch Combo",
    Description = "Disable attack animations",
    Default = false,
    Callback = function(Value)
    comboActive = value
    
    if value then
        changeSpeedSizeRemote:InvokeServer("changeSize", 0/0)
        
        eggLoop = task.spawn(function()
            while comboActive do
                ensureEggEquipped()
                task.wait(0.2)
            end
        end)
        
        characterAddedConn = player.CharacterAdded:Connect(function(newChar)
            task.wait(0.5)
            ensureEggEquipped()
        end)
        
        ensureEggEquipped()
        
    else
        if eggLoop then task.cancel(eggLoop) end
        if characterAddedConn then characterAddedConn:Disconnect() end
    end
end)}

comboSwitch:Set(false)

-- Kill Everyone
KillingTab:AddToggle("KillEveryoneToggle", {
    Title = "Kill Everyone",
    Description = "Attack all players",
    Default = false,
    Callback = function(Value)
        _G.killAll = Value
        if Value then
            if not _G.killAllConnection then
                _G.killAllConnection = game:GetService("RunService").Heartbeat:Connect(function()
                    if _G.killAll then
                        for _, player in ipairs(Players:GetPlayers()) do
                            if player ~= localPlayer then
                                -- Kill player logic would go here
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
    end
})

-- Death Ring
KillingTab:AddSlider("DeathRingRange", {
    Title = "Death Ring Range",
    Description = "Set death ring range (1-140)",
    Default = 20,
    Min = 1,
    Max = 140,
    Rounding = 0,
    Callback = function(Value)
        _G.deathRingRange = Value
    end
})

KillingTab:AddToggle("DeathRingToggle", {
    Title = "Death Ring",
    Description = "Enable death ring",
    Default = false,
    Callback = function(Value)
        _G.deathRingEnabled = Value
        -- Death ring logic would go here
    end
})

-- Farming Tab
local autoFarmRunning = false
local selectedTool = "Weight"

FarmingTab:AddDropdown("ToolDropdown", {
    Title = "Select Tool",
    Description = "Choose farming tool",
    Values = {"Weight", "Pushups", "Situps", "Handstands", "Fast Punch", "Stomp", "Ground Slam"},
    Default = "Weight",
    Callback = function(Value)
        selectedTool = Value
    end
})

FarmingTab:AddToggle("AutoFarmToggle", {
    Title = "Start Auto Farm",
    Description = "Start automatic farming",
    Default = false,
    Callback = function(Value)
        autoFarmRunning = Value
        if Value then
            spawn(function()
                while autoFarmRunning do
                    local player = localPlayer
                    
                    if selectedTool == "Weight" then
                        if not player.Character:FindFirstChild("Weight") then
                            local weightTool = player.Backpack:FindFirstChild("Weight")
                            if weightTool then
                                player.Character.Humanoid:EquipTool(weightTool)
                            end
                        end
                        muscleEvent:FireServer("rep")
                    elseif selectedTool == "Pushups" then
                        -- Similar logic for other tools
                        muscleEvent:FireServer("rep")
                    elseif selectedTool == "Situps" then
                        muscleEvent:FireServer("rep")
                    elseif selectedTool == "Handstands" then
                        muscleEvent:FireServer("rep")
                    elseif selectedTool == "Fast Punch" then
                        local punch = player.Backpack:FindFirstChild("Punch")
                        if punch then
                            punch.Parent = player.Character
                            if punch:FindFirstChild("attackTime") then
                                punch.attackTime.Value = 0
                            end
                        end
                        muscleEvent:FireServer("punch", "rightHand")
                        muscleEvent:FireServer("punch", "leftHand")
                        if player.Character:FindFirstChild("Punch") then
                            player.Character.Punch:Activate()
                        end
                    elseif selectedTool == "Stomp" then
                        local stomp = player.Backpack:FindFirstChild("Stomp")
                        if stomp then
                            stomp.Parent = player.Character
                            if stomp:FindFirstChild("attackTime") then
                                stomp.attackTime.Value = 0
                            end
                        end
                        muscleEvent:FireServer("stomp")
                        if player.Character:FindFirstChild("Stomp") then
                            player.Character.Stomp:Activate()
                        end
                    elseif selectedTool == "Ground Slam" then
                        local groundSlam = player.Backpack:FindFirstChild("Ground Slam")
                        if groundSlam then
                            groundSlam.Parent = player.Character
                            if groundSlam:FindFirstChild("attackTime") then
                                groundSlam.attackTime.Value = 0
                            end
                        end
                        muscleEvent:FireServer("slam")
                        if player.Character:FindFirstChild("Ground Slam") then
                            player.Character["Ground Slam"]:Activate()
                        end
                    end
                    
                    wait()
                end
            end)
        end
    end
})

-- Auto Rebirth
local targetRebirths = 0
local rebirths = localPlayer.leaderstats:WaitForChild("Rebirths")

FarmingTab:AddInput("RebirthTargetInput", {
    Title = "Set Rebirth Target",
    Description = "Target number of rebirths",
    Default = "0",
    Numeric = true,
    Callback = function(Value)
        targetRebirths = tonumber(Value) or 0
    end
})

FarmingTab:AddToggle("AutoRebirthToggle", {
    Title = "Auto Rebirth",
    Description = "Automatically rebirth when possible",
    Default = false,
    Callback = function(Value)
        if Value then
            spawn(function()
                while Value and rebirths.Value < targetRebirths do
                    ReplicatedStorage.rEvents.rebirthRemote:InvokeServer("rebirthRequest")
                    wait(0.05)
                end
            end)
        end
    end
})

-- Teleport Tab
local teleportLocations = {
    ["Tiny Island"] = CFrame.new(-37.1, 9.2, 1919),
    ["Main Island"] = CFrame.new(16.07, 9.08, 133.8),
    ["Beach"] = CFrame.new(-8, 9, -169.2),
    ["Muscle King Gym"] = CFrame.new(-8665.4, 17.21, -5792.9),
    ["Jungle Gym"] = CFrame.new(-8543, 6.8, 2400),
    ["Legends Gym"] = CFrame.new(4516, 991.5, -3856),
    ["Infernal Gym"] = CFrame.new(-6759, 7.36, -1284),
    ["Mythical Gym"] = CFrame.new(2250, 7.37, 1073.2),
    ["Frost Gym"] = CFrame.new(-2623, 7.36, -409),
}

for name, cframe in pairs(teleportLocations) do
    TeleportTab:AddButton({
        Title = name,
        Description = "Teleport to " .. name,
        Callback = function()
            local char = localPlayer.Character or localPlayer.CharacterAdded:Wait()
            local hrp = char:WaitForChild("HumanoidRootPart")
            hrp.CFrame = cframe
        end
    })
end

-- Stats Tab
local function formatNumber(n)
    if n >= 1e15 then
        return string.format("%.1fqa", n/1e15)
    elseif n >= 1e12 then
        return string.format("%.1ft", n/1e12)
    elseif n >= 1e9 then
        return string.format("%.1fb", n/1e9)
    elseif n >= 1e6 then
        return string.format("%.1fm", n/1e6)
    elseif n >= 1e3 then
        return string.format("%.1fk", n/1e3)
    else
        return tostring(n)
    end
end

local function formatWithCommas(n)
    local formatted = tostring(math.floor(n))
    while true do
        formatted, k = formatted:gsub("^(-?%d+)(%d%d%d)", '%1,%2')
        if k == 0 then break end
    end
    return formatted
end

-- Create stat displays
local leaderstats = localPlayer:WaitForChild("leaderstats")
local strengthStat = leaderstats:WaitForChild("Strength")
local rebirthsStat = leaderstats:WaitForChild("Rebirths")
local durabilityStat = localPlayer:WaitForChild("Durability")
local killsStat = leaderstats:WaitForChild("Kills")
local agilityStat = localPlayer:WaitForChild("Agility")
local evilKarmaStat = localPlayer:WaitForChild("evilKarma")
local goodKarmaStat = localPlayer:WaitForChild("goodKarma")
local brawlsStat = leaderstats:WaitForChild("Brawls")

local emojiMap = {
    ["Time"] = "⏰",
    ["Stats"] = "📊",
    ["Strength"] = "💪",
    ["Rebirths"] = "🔄",
    ["Durability"] = "🛡️",
    ["Kills"] = "💀",
    ["Agility"] = "🏃",
    ["Evil Karma"] = "😈",
    ["Good Karma"] = "😇",
    ["Brawls"] = "🥊"
}

local stats = {
    { name = emojiMap["Strength"] .. " Strength", stat = strengthStat },
    { name = emojiMap["Rebirths"] .. " Rebirths", stat = rebirthsStat },
    { name = emojiMap["Durability"] .. " Durability", stat = durabilityStat },
    { name = emojiMap["Agility"] .. " Agility", stat = agilityStat },
    { name = emojiMap["Kills"] .. " Kills", stat = killsStat },
    { name = emojiMap["Evil Karma"] .. " Evil Karma", stat = evilKarmaStat },
    { name = emojiMap["Good Karma"] .. " Good Karma", stat = goodKarmaStat },
    { name = emojiMap["Brawls"] .. " Brawls", stat = brawlsStat }
}

local initialValues = {}
local statLabels = {}

for _, info in ipairs(stats) do
    initialValues[info.name] = info.stat.Value
    local label = StatsTab:AddParagraph({
        Title = info.name,
        Content = "Loading..."
    })
    statLabels[info.name] = label
end

-- Update stats loop
spawn(function()
    while true do
        for _, info in ipairs(stats) do
            local currentValue = info.stat.Value
            local gained = currentValue - initialValues[info.name]
            
            local displayText = string.format(
                "%s: %s (%s) | Gained: %s (%s)",
                info.name,
                formatNumber(currentValue),
                formatWithCommas(currentValue),
                formatNumber(gained),
                formatWithCommas(gained)
            )
            
            statLabels[info.name]:SetDesc(displayText)
        end
        wait(0.1)
    end
end)

-- Time Display
local startTime = tick()
local timeLabel = StatsTab:AddParagraph({
    Title = emojiMap["Time"] .. " Time:",
    Content = "0d 0h 0m 0s"
})

spawn(function()
    while true do
        local currentTime = tick()
        local elapsedTime = currentTime - startTime

        local days = math.floor(elapsedTime / (24 * 3600))
        local hours = math.floor((elapsedTime % (24 * 3600)) / 3600)
        local minutes = math.floor((elapsedTime % 3600) / 60)
        local seconds = math.floor(elapsedTime % 60)

        timeLabel:SetDesc(string.format("%dd %dh %dm %ds", days, hours, minutes, seconds))
        wait(0.1)
    end
end)

-- Interface Settings
InterfaceManager:SetFolder("SilenceV2Farming")
InterfaceManager:BuildInterfaceSection(MainTab)

-- Save Manager
SaveManager:SetFolder("SilenceV2Farming/Saves")
SaveManager:BuildConfigSection(MainTab)

-- Notification
Library:Notify({
    Title = "SilenceV2 Farming",
    Content = "Successfully loaded with KyypieUI!",
    Duration = 5
})

-- Select first tab
Window:SelectTab(1)
