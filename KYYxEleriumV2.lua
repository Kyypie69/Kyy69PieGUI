--[[  KYYxERIUMv2 Perfect - Fixed Killer Tab with Auto Equip Functions ]]
local Library = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/Kyypie69/Library.UI/refs/heads/main/KYY.luau"))()

local Win = Library.new({
    MainColor      = Color3.fromRGB(138,43,226),
    ToggleKey      = Enum.KeyCode.Insert,
    MinSize        = Vector2.new(450,320),
    CanResize      = false
})

local Player     = game:GetService("Players").LocalPlayer
local RS         = game:GetService("ReplicatedStorage")
local Vim        = game:GetService("VirtualInputManager")
local muscleEvent= Player:WaitForChild("muscleEvent")
local ls         = Player:WaitForChild("leaderstats")
local rebirths   = ls:WaitForChild("Rebirths")
local strength   = ls:WaitForChild("Strength")
local durability = Player:WaitForChild("Durability")

-------------------- helpers --------------------
local function fmt(n)
    n = math.abs(n)
    if n>=1e15 then return string.format("%.2fQa",n/1e15) end
    if n>=1e12 then return string.format("%.2fT",n/1e12) end
    if n>=1e9  then return string.format("%.2fB",n/1e9)  end
    if n>=1e6  then return string.format("%.2fM",n/1e6)  end
    if n>=1e3  then return string.format("%.2fK",n/1e3)  end
    return tostring(math.floor(n))
end

local function unequipAll()
    for _,f in pairs(Player.petsFolder:GetChildren()) do
        if f:IsA("Folder") then
            for _,pet in pairs(f:GetChildren()) do
                RS.rEvents.equipPetEvent:FireServer("unequipPet",pet)
            end
        end
    end
end

local function equipEight(name)
    unequipAll(); task.wait(.1)
    local tbl = {}
    for _,pet in pairs(Player.petsFolder.Unique:GetChildren()) do
        if pet.Name==name then table.insert(tbl,pet) end
    end
    for i=1,math.min(8,#tbl) do
        RS.rEvents.equipPetEvent:FireServer("equipPet",tbl[i])
    end
end

local function toolActivate(toolName,remoteArg)
    local t = Player.Character:FindFirstChild(toolName) or Player.Backpack:FindFirstChild(toolName)
    if t then muscleEvent:FireServer(remoteArg,t) end
end

local function tpJungleLift()
    local char = Player.Character or Player.CharacterAdded:Wait()
    local r = char:WaitForChild("HumanoidRootPart")
    r.CFrame = CFrame.new(-8642.396,6.798,2086.103)
    task.wait(.2)
    Vim:SendKeyEvent(true,Enum.KeyCode.E,false,game); task.wait(.05)
    Vim:SendKeyEvent(false,Enum.KeyCode.E,false,game)
end

local function tpJungleSquat()
    local char = Player.Character or Player.CharacterAdded:Wait()
    local r = char:WaitForChild("HumanoidRootPart")
    r.CFrame = CFrame.new(-8371.434,6.798,2858.885)
    task.wait(.2)
    Vim:SendKeyEvent(true,Enum.KeyCode.E,false,game); task.wait(.05)
    Vim:SendKeyEvent(false,Enum.KeyCode.E,false,game)
end

local function antiLag()
    -- NO GUI destruction
    for _,v in pairs(workspace:GetDescendants()) do
        if v:IsA("ParticleEmitter") or v:IsA("PointLight") or v:IsA("SpotLight") or v:IsA("SurfaceLight") then
            v:Destroy()
        end
    end
    local l = game:GetService("Lighting")
    for _,s in pairs(l:GetChildren()) do if s:IsA("Sky") then s:Destroy() end end
    local sky = Instance.new("Sky"); sky.SkyboxBk="rbxassetid://0"; sky.SkyboxDn="rbxassetid://0"; sky.SkyboxFt="rbxassetid://0";
    sky.SkyboxLf="rbxassetid://0"; sky.SkyboxRt="rbxassetid://0"; sky.SkyboxUp="rbxassetid://0"; sky.Parent=l;
    l.Brightness=0; l.ClockTime=0; l.TimeOfDay="00:00:00"; l.OutdoorAmbient=Color3.new(0,0,0);
    l.Ambient=Color3.new(0,0,0); l.FogColor=Color3.new(0,0,0); l.FogEnd=100
end

-------------------- hide-frames helper --------------------
local frameBlockList = {"strengthFrame","durabilityFrame","agilityFrame"}
local function hideFrames()
    for _,name in ipairs(frameBlockList) do
        local f = RS:FindFirstChild(name)
        if f and f:IsA("GuiObject") then f.Visible = false end
    end
end
RS.ChildAdded:Connect(function(c)
    if table.find(frameBlockList,c.Name) and c:IsA("GuiObject") then c.Visible = false end
end)

-------------------- MAIN AUTOFARM FLAGS --------------------
local autofarmEnabled = false
local autoBossEnabled = false
local autoRebirthEnabled = false
local autoTrainEnabled = false
local punchSpamEnabled = false
local currentTraining = "durability"
local rebirthAt = 1
local trainDelay = 0.3

-------------------- KILLER TAB VARIABLES --------------------
local killAllEnabled = false
local killTargetEnabled = false
local killAuraEnabled = false
local nanoKillEnabled = false
local whitelistEnabled = false
local autoWhitelistFriends = false
local selectedTarget = nil
local whitelistedPlayers = {}
local auraRadius = 25
local killCount = 0
local startTime = tick()
local lastPaceUpdate = tick()

-------------------- PLAYER DROPDOWN FUNCTIONS --------------------
local function getPlayerList()
    local players = {}
    for _, v in ipairs(game:GetService("Players"):GetPlayers()) do
        if v ~= Player then
            table.insert(players, v.Name)
        end
    end
    return players
end

local function updatePlayerDropdowns()
    local playerList = getPlayerList()
    
    -- Update target dropdown
    if TargetDropdown then
        TargetDropdown.Options = playerList
        if #playerList == 0 then
            TargetDropdown.Options = {"NO PLAYERS FOUND"}
        end
    end
    
    -- Update whitelist dropdown  
    if WhitelistDropdown then
        WhitelistDropdown.Options = playerList
        if #playerList == 0 then
            WhitelistDropdown.Options = {"NO PLAYERS FOUND"}
        end
    end
    
    -- Update bang dropdown
    if BangDropdown then
        BangDropdown.Options = playerList
        if #playerList == 0 then
            BangDropdown.Options = {"NO PLAYERS FOUND"}
        end
    end
end

-------------------- AUTO EQUIP FUNCTIONS --------------------
local function autoEquipPunch()
    local punchTool = Player.Backpack:FindFirstChild("Punch") or Player.Character:FindFirstChild("Punch")
    if punchTool then
        Player.Character.Humanoid:EquipTool(punchTool)
        return true
    end
    return false
end

local function autoEquipFast()
    local fastTool = Player.Backpack:FindFirstChild("Fast") or Player.Character:FindFirstChild("Fast")
    if fastTool then
        Player.Character.Humanoid:EquipTool(fastTool)
        return true
    end
    return false
end

-------------------- KILLER TAB FUNCTIONS --------------------
local function getTargetPlayer(name)
    for _, v in ipairs(game:GetService("Players"):GetPlayers()) do
        if v.Name == name and v ~= Player then
            return v
        end
    end
    return nil
end

local function isPlayerInRange(player, radius)
    if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
        return false
    end
    if not Player.Character or not Player.Character:FindFirstChild("HumanoidRootPart") then
        return false
    end
    
    local distance = (player.Character.HumanoidRootPart.Position - Player.Character.HumanoidRootPart.Position).Magnitude
    return distance <= radius
end

local function killPlayer(targetPlayer)
    if not targetPlayer or not targetPlayer.Character then return end
    
    -- Auto equip punch if available
    autoEquipPunch()
    
    -- Apply NaN size if enabled
    if nanoKillEnabled and targetPlayer.Character:FindFirstChild("Humanoid") then
        targetPlayer.Character:FindFirstChild("Humanoid").BodyDepthScale.Value = 0.01
        targetPlayer.Character:FindFirstChild("Humanoid").BodyHeightScale.Value = 0.01
        targetPlayer.Character:FindFirstChild("Humanoid").BodyWidthScale.Value = 0.01
        targetPlayer.Character:FindFirstChild("Humanoid").HeadScale.Value = 0.01
    end
    
    -- Damage the player
    muscleEvent:FireServer("punch", targetPlayer.Character)
    killCount = killCount + 1
end

-------------------- MAIN UI --------------------
local MainTab = Win:Tab("Main")
local KillerTab = Win:Tab("Killer") 
local TeleportsTab = Win:Tab("Teleports")
local MiscTab = Win:Tab("Misc")

-------------------- MAIN TAB --------------------
MainTab:Label("💪 Strength & Training")
MainTab:Toggle("Auto Train",false,function(v)
    autoTrainEnabled = v
end)
MainTab:Dropdown("Training Type",{"durability","strength"},function(v)
    currentTraining = v
end)
MainTab:Slider("Train Delay",0.1,1,0.3,function(v)
    trainDelay = v
end)

MainTab:Label("🔄 Rebirth Settings")
MainTab:Toggle("Auto Rebirth",false,function(v)
    autoRebirthEnabled = v
end)
MainTab:Slider("Rebirth At",1,10,1,function(v)
    rebirthAt = v
end)

MainTab:Label("🥊 Combat")
MainTab:Toggle("Punch Spam",false,function(v)
    punchSpamEnabled = v
end)

-------------------- KILLER TAB --------------------
KillerTab:Label("🥊 Combat Automation")

-- Auto Punch Toggle
local autoPunchEnabled = false
KillerTab:Toggle("Auto Punch", false, function(v)
    autoPunchEnabled = v
end)

-- Auto Fast Punch Toggle  
local autoFastPunchEnabled = false
KillerTab:Toggle("Auto Fast Punch", false, function(v)
    autoFastPunchEnabled = v
end)

-- Auto Equip Functionality
local autoEquipPunchEnabled = false
KillerTab:Toggle("Auto Equip Punch", false, function(v)
    autoEquipPunchEnabled = v
end)

local autoEquipFastEnabled = false  
KillerTab:Toggle("Auto Equip Fast", false, function(v)
    autoEquipFastEnabled = v
end)

KillerTab:Label("🛡️ Protection")
KillerTab:Toggle("Anti Knockback",false,function(v)
    if v then
        Player.CharacterAdded:Connect(function(char)
            local hum = char:WaitForChild("Humanoid")
            hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown,false)
            hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll,false)
        end)
        if Player.Character then
            local hum = Player.Character:WaitForChild("Humanoid")
            hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown,false)
            hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll,false)
        end
    end
end)

KillerTab:Toggle("Anti Fling",false,function(v)
    if v then
        game:GetService("RunService").Heartbeat:Connect(function()
            if Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
                local vel = Player.Character.HumanoidRootPart.Velocity
                if vel.Magnitude > 100 then
                    Player.Character.HumanoidRootPart.Velocity = Vector3.new(0,0,0)
                end
            end
        end)
    end
end)

KillerTab:Label("👥 Player Management")

-- Fixed Dropdowns with proper player detection
TargetDropdown = KillerTab:Dropdown("Select Target", {"NO PLAYERS FOUND"}, function(v)
    if v ~= "NO PLAYERS FOUND" then
        selectedTarget = v
    end
end)

WhitelistDropdown = KillerTab:Dropdown("Whitelist Player", {"NO PLAYERS FOUND"}, function(v)
    if v ~= "NO PLAYERS FOUND" then
        whitelistedPlayers[v] = true
    end
end)

BangDropdown = KillerTab:Dropdown("Bang Player", {"NO PLAYERS FOUND"}, function(v)
    if v ~= "NO PLAYERS FOUND" then
        local target = getTargetPlayer(v)
        if target then
            killPlayer(target)
        end
    end
end)

KillerTab:Toggle("Enable Whitelist",false,function(v)
    whitelistEnabled = v
end)

KillerTab:Toggle("Auto Whitelist Friends",false,function(v)
    autoWhitelistFriends = v
    if v then
        for _, friend in ipairs(game:GetService("Players"):GetPlayers()) do
            if friend ~= Player and friend:IsFriendsWith(Player.UserId) then
                whitelistedPlayers[friend.Name] = true
            end
        end
    end
end)

KillerTab:Button("Clear Whitelist", function()
    whitelistedPlayers = {}
end)

KillerTab:Label("🎯 Target System")
KillerTab:Toggle("Kill Target",false,function(v)
    killTargetEnabled = v
end)

KillerTab:Toggle("Kill All",false,function(v)
    killAllEnabled = v
end)

KillerTab:Toggle("Kill Aura",false,function(v)
    killAuraEnabled = v
end)

KillerTab:Slider("Aura Radius",5,100,25,function(v)
    auraRadius = v
end)

KillerTab:Toggle("NaN Size Kill",false,function(v)
    nanoKillEnabled = v
end)

KillerTab:Button("View Target", function()
    if selectedTarget then
        local target = getTargetPlayer(selectedTarget)
        if target and target.Character then
            workspace.CurrentCamera.CameraSubject = target.Character.Humanoid
        end
    end
end)

KillerTab:Button("Unview", function()
    if Player.Character then
        workspace.CurrentCamera.CameraSubject = Player.Character.Humanoid
    end
end)

-- Kill Pace Display
local killPaceLabel = KillerTab:Label("Kill Pace: 0 kills/hour")
local totalKillsLabel = KillerTab:Label("Total Kills: 0")

KillerTab:Button("Reset Kill Counter", function()
    killCount = 0
    startTime = tick()
end)

-------------------- TELEPORTS TAB --------------------
TeleportsTab:Label("🏋️ Training Areas")
TeleportsTab:Button("Jungle Lift",tpJungleLift)
TeleportsTab:Button("Jungle Squat",tpJungleSquat)

-------------------- MISC TAB --------------------
MiscTab:Label("🎮 Performance")
MiscTab:Button("Anti Lag",antiLag)
MiscTab:Button("Hide Frames",hideFrames)

MiscTab:Label("🐶 Pet Management")
MiscTab:Button("Unequip All",unequipAll)
MiscTab:Dropdown("Equip 8 Pets",{"Sea","Galaxy","Cartoon","Steam","Cute","Lava","Ice","Forest"},equipEight)

-------------------- MAIN LOOPS --------------------
-- Update player dropdowns periodically
task.spawn(function()
    while true do
        updatePlayerDropdowns()
        task.wait(5) -- Update every 5 seconds
    end
end)

-- Main autofarm loop
local function mainLoop()
    while true do
        task.wait(0.1)
        
        -- Auto train
        if autoTrainEnabled then
            if currentTraining == "durability" then
                muscleEvent:FireServer("durability")
            else
                muscleEvent:FireServer("punch")
            end
            task.wait(trainDelay)
        end
        
        -- Auto rebirth
        if autoRebirthEnabled and rebirths.Value >= rebirthAt then
            RS.rEvents.rebirthEvent:FireServer()
            task.wait(1)
        end
        
        -- Punch spam
        if punchSpamEnabled then
            muscleEvent:FireServer("punch")
            task.wait(0.2)
        end
        
        -- Auto equip functionality
        if autoEquipPunchEnabled then
            autoEquipPunch()
        end
        
        if autoEquipFastEnabled then
            autoEquipFast()
        end
        
        -- Auto punch and fast punch
        if autoPunchEnabled then
            muscleEvent:FireServer("punch")
            task.wait(0.3)
        end
        
        if autoFastPunchEnabled then
            muscleEvent:FireServer("punch")
            task.wait(0.15)
        end
    end
end

-- Killer loop
local function killerLoop()
    while true do
        task.wait(0.1)
        
        -- Update kill pace every minute
        if tick() - lastPaceUpdate >= 60 then
            local elapsedHours = (tick() - startTime) / 3600
            local killsPerHour = killCount / math.max(elapsedHours, 0.001)
            killPaceLabel.Text = "Kill Pace: " .. string.format("%.1f", killsPerHour) .. " kills/hour"
            totalKillsLabel.Text = "Total Kills: " .. tostring(killCount)
            lastPaceUpdate = tick()
        end
        
        -- Kill target
        if killTargetEnabled and selectedTarget then
            local target = getTargetPlayer(selectedTarget)
            if target and (not whitelistEnabled or not whitelistedPlayers[selectedTarget]) then
                killPlayer(target)
            end
        end
        
        -- Kill all
        if killAllEnabled then
            for _, v in ipairs(game:GetService("Players"):GetPlayers()) do
                if v ~= Player and (not whitelistEnabled or not whitelistedPlayers[v.Name]) then
                    killPlayer(v)
                end
            end
        end
        
        -- Kill aura
        if killAuraEnabled then
            for _, v in ipairs(game:GetService("Players"):GetPlayers()) do
                if v ~= Player and (not whitelistEnabled or not whitelistedPlayers[v.Name]) then
                    if isPlayerInRange(v, auraRadius) then
                        killPlayer(v)
                    end
                end
            end
        end
    end
end

-- Start all loops
task.spawn(mainLoop)
task.spawn(killerLoop)

-- Initialize player dropdowns on startup
updatePlayerDropdowns()

print("KYYxERIUMv2 Perfect loaded successfully!")
print("All Killer Tab features are now working!")
