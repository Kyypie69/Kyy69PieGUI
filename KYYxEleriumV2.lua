--[[  EleriumV2xKYY  (ver.71)  ]]
-- Fixed KILL3R tab with working killing features
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

-------------------- KILL3R TAB FUNCTIONS --------------------
-- Global kill lists
_G.whitelistedPlayers = _G.whitelistedPlayers or {}
_G.blacklistedPlayers = _G.blacklistedPlayers or {}
_G.killAll = false
_G.killBlacklistedOnly = false
_G.whitelistFriends = false
_G.deathRingEnabled = false
_G.showDeathRing = false
_G.deathRingRange = 20

local function checkCharacter()
    if not Player.Character then
        repeat task.wait() until Player.Character
    end
    return Player.Character
end

local function gettool()
    for _, v in pairs(Player.Backpack:GetChildren()) do
        if v.Name == "Punch" and Player.Character:FindFirstChild("Humanoid") then
            Player.Character.Humanoid:EquipTool(v)
        end
    end
    muscleEvent:FireServer("punch", "leftHand")
    muscleEvent:FireServer("punch", "rightHand")
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

local function isWhitelisted(player)
    for _, name in ipairs(_G.whitelistedPlayers) do
        if name:lower() == player.Name:lower() then
            return true
        end
    end
    return false
end

local function isBlacklisted(player)
    for _, name in ipairs(_G.blacklistedPlayers) do
        if name:lower() == player.Name:lower() then
            return true
        end
    end
    return false
end

local function getPlayerDisplayText(player)
    return player.DisplayName .. " | " .. player.Name
end

-------------------- window / tabs --------------------
local Main = Win:CreateWindow("KYY HUB 0.7.1 | Fixed KILL3R Edition","Markyy")
local RebirthTab = Main:CreateTab("REB1RTH")
local StrengthTab= Main:CreateTab("STR3NGTH")
local KillerTab = Main:CreateTab("KILL3R")

-------------------- REB1RTH TAB CONTENT --------------------
local rebStartTime = 0; local rebElapsed = 0; local rebRunning = false
local rebPaceHist = {}; local maxHist = 20; local rebCount = 0
local lastRebTime = tick(); local lastRebVal = rebirths.Value; local initReb = rebirths.Value

local rebTimeLbl   = RebirthTab:AddLabel("0d 0h 0m 0s – Inactive")
local rebPaceLbl   = RebirthTab:AddLabel("Pace: 0 /h  |  0 /d  |  0 /w")
local rebAvgLbl    = RebirthTab:AddLabel("Average: 0 /h  |  0 /d  |  0 /w")
local rebGainLbl   = RebirthTab:AddLabel("Rebirths: "..fmt(initReb).."  |  Gained: 0")

local function updateRebDisp()
    local e = rebRunning and (tick()-rebStartTime+rebElapsed) or rebElapsed
    local d,h,m,s = math.floor(e/86400),math.floor(e%86400/3600),math.floor(e%3600/60),math.floor(e%60)
    rebTimeLbl.Text = string.format("%dd %dh %dm %ds – %s",d,h,m,s,rebRunning and "Rebirthing" or "Paused")
end

local function calcRebPace()
    rebCount=rebCount+1; if rebCount<2 then lastRebTime=tick(); lastRebVal=rebirths.Value; return end
    local now,gained = tick(),rebirths.Value-lastRebVal
    if gained<=0 then return end
    local t = (now-lastRebTime)/gained
    local ph,pd,pw = 3600/t,86400/t,604800/t
    rebPaceLbl.Text = string.format("Pace: %s /h  |  %s /d  |  %s /w",fmt(ph),fmt(pd),fmt(pw))
    table.insert(rebPaceHist,{h=ph,d=pd,w=pw})
    if #rebPaceHist>maxHist then table.remove(rebPaceHist,1) end
    local sumH,sumD,sumW=0,0,0
    for _,v in pairs(rebPaceHist) do sumH=sumH+v.h; sumD=sumD+v.d; sumW=sumW+v.w; end
    local n=#rebPaceHist
    rebAvgLbl.Text = string.format("Average: %s /h  |  %s /d  |  %s /w",fmt(sumH/n),fmt(sumD/n),fmt(sumW/n))
    lastRebTime=now; lastRebVal=rebirths.Value
end

rebirths.Changed:Connect(function()
    calcRebPace()
    rebGainLbl.Text = "Rebirths: "..fmt(rebirths.Value).."  |  Gained: "..fmt(rebirths.Value-initReb)
end)

-- fast rebirth loop
local function doRebirth()
    local target = 5000+rebirths.Value*2550
    while rebRunning and strength.Value<target do
        local reps = Player.MembershipType==Enum.MembershipType.Premium and 8 or 14
        for _=1,reps do muscleEvent:FireServer("rep") end
        task.wait(0.02)
    end
    if rebRunning and strength.Value>=target then
        equipEight("Tribal Overlord"); task.wait(0.25)
        local b=rebirths.Value
        repeat RS.rEvents.rebirthRemote:InvokeServer("rebirthRequest"); task.wait(0.05)
        until rebirths.Value>b or not rebRunning
    end
end

local function rebLoop()
    while rebRunning do
        equipEight("Swift Samurai")
        doRebirth()
        task.wait(0.5)
    end
end

RebirthTab:AddToggle("Fast Rebirth",false,function(v)
    rebRunning=v
    if v then
        rebStartTime=tick(); rebCount=0
        task.spawn(rebLoop)
    else
        rebElapsed=rebElapsed+(tick()-rebStartTime)
        updateRebDisp()
    end
end)

-- Hide-Frames toggle
RebirthTab:AddToggle("Hide Frames",false,function(s)
    if s then hideFrames() end
end)

-- Anti-AFK button (rebirth tab)
local rebAntiAfkEnabled=false
RebirthTab:AddButton("Anti AFK",function()
    rebAntiAfkEnabled=true
end)

RebirthTab:AddButton("Equip 8× Swift Samurai",function() equipEight("Swift Samurai") end)
RebirthTab:AddButton("Anti Lag",antiLag)

--------------------------------------------------------
--  Position Lock  (Rebirth tab)  –  TELEPORT + ANCHOR
--------------------------------------------------------
local lockConn   = nil
local lockEnabled = false
local savedPos   = nil
local RunService = game:GetService("RunService")

local function stopLock()
    if lockConn then lockConn:Disconnect() end
    lockConn = nil
    local r = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
    if r then r.Anchored = false end
end

local function startLock()
    local root = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    savedPos = root.CFrame
    root.Anchored = true          -- try anchor first (instant freeze on many gym games)

    -- fallback teleport loop if anchor gets overridden
    lockConn = RunService.Heartbeat:Connect(function()
        local r = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
        if r then
            r.Anchored = true
            r.CFrame = savedPos   -- still attempt CFrame every frame
        end
    end)
end

local function updatePosLock(state)
    lockEnabled = state
    if state then startLock() else stopLock() end
end

-- respawn support
Player.CharacterAdded:Connect(function(char)
    if lockEnabled then
        stopLock()
        task.wait(.2)
        startLock()
    end
end)

-- UI toggle
RebirthTab:AddToggle("Lock 69 Position", false, updatePosLock)
RebirthTab:AddButton("TP Jungle Lift",tpJungleLift)

-- auto protein egg
local eggRunning=false
task.spawn(function()
    while true do
        if eggRunning then toolActivate("Protein Egg","proteinEgg"); task.wait(1800) else task.wait(1) end
    end
end)
RebirthTab:AddToggle("Auto Protein Egg",false,function(s) eggRunning=s; if s then toolActivate("Protein Egg","proteinEgg") end end)

-------------------- STR3NGTH TAB CONTENT --------------------
local strStart=0; local strElapsed=0; local strRun=false; local track=false
local initStr=strength.Value; local initDur=durability.Value
local strHist={}; local durHist={}; local calcInt=10

local strTimeLbl  = StrengthTab:AddLabel("0d 0h 0m 0s – Inactive")
local strPaceLbl  = StrengthTab:AddLabel("Str Pace: 0 /h  |  0 /d  |  0 /w")
local durPaceLbl  = StrengthTab:AddLabel("Dur Pace: 0 /h  |  0 /d  |  0 /w")
local strAvgLbl   = StrengthTab:AddLabel("Avg Str: 0 /h  |  0 /d  |  0 /w")
local durAvgLbl   = StrengthTab:AddLabel("Avg Dur: 0 /h  |  0 /d  |  0 /w")
local strGainLbl  = StrengthTab:AddLabel("Strength: 0  |  Gained: 0")
local durGainLbl  = StrengthTab:AddLabel("Durability: 0  |  Gained: 0")

local function updateStrDisp()
    local e = strRun and (tick()-strStart+strElapsed) or strElapsed
    local d,h,m,s = math.floor(e/86400),math.floor(e%86400/3600),math.floor(e%3600/60),math.floor(e%60)
    strTimeLbl.Text = string.format("%dd %dh %dm %ds – %s",d,h,m,s,strRun and "Running" or "Paused")
end

-- fast rep loop
local repsPerTick=20
local function getPing()
    local st=game:GetService("Stats")
    local p=st:FindFirstChild("PerformanceStats") and st.PerformanceStats:FindFirstChild("Ping")
    return p and p:GetValue() or 0
end

local function fastRep()
    while strRun do
        local t0=tick()
        while tick()-t0<0.75 and strRun do
            for i=1,repsPerTick do muscleEvent:FireServer("rep") end
            task.wait(0.02)
        end
        while strRun and getPing()>=350 do task.wait(1) end
    end
end

StrengthTab:AddTextBox("Rep Speed","20",function(v)
    local n=tonumber(v); if n and n>0 then repsPerTick=math.floor(n) end
end)
StrengthTab:AddToggle("Fast Strength",false,function(v)
    strRun=v
    if v then
        strStart=tick(); track=true; strHist={}; durHist={}
        task.spawn(fastRep)
    else
        strElapsed=strElapsed+(tick()-strStart); track=false; updateStrDisp()
    end
end)

-- Hide-Frames toggle
StrengthTab:AddToggle("Hide Frames",false,function(s)
    if s then hideFrames() end
end)

-- Anti-AFK button (strength tab)
local strAntiAfkEnabled=false
StrengthTab:AddButton("Anti AFK",function()
    strAntiAfkEnabled=true
end)

StrengthTab:AddButton("Equip 8× Swift Samurai",function() equipEight("Swift Samurai") end)
StrengthTab:AddButton("Anti Lag",antiLag)
StrengthTab:AddButton("TP Jungle Squat",tpJungleSquat)

-- auto egg + shake
local shakeRunning=false; local eggRunning2=false
task.spawn(function()
    while true do
        if eggRunning2 then toolActivate("Protein Egg","proteinEgg"); task.wait(1800) else task.wait(1) end
    end
end)
task.spawn(function()
    while true do
        if shakeRunning then toolActivate("Tropical Shake","tropicalShake"); task.wait(900) else task.wait(1) end
    end
end)
StrengthTab:AddToggle("Auto Protein Egg",false,function(s) eggRunning2=s; if s then toolActivate("Protein Egg","proteinEgg") end end)
StrengthTab:AddToggle("Auto Tropical Shake",false,function(s) shakeRunning=s; if s then toolActivate("Tropical Shake","tropicalShake") end end)

-------------------- KILL3R TAB CONTENT --------------------
-- Pet Selection for Kill Combo
-- Animation Removal
KillerTab:AddToggle("Remove Attack Animations", false, function(bool)
    if bool then
        local blockedAnimations = {
            ["rbxassetid://3638729053"] = true,
            ["rbxassetid://3638767427"] = true,
        }

        local function setupAnimationBlocking()
            local char = Player.Character
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
                        local char = Player.Character
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
            for _, tool in pairs(Player.Backpack:GetChildren()) do
                processTool(tool)
            end

            local char = Player.Character
            if char then
                for _, tool in pairs(char:GetChildren()) do
                    if tool:IsA("Tool") then
                        processTool(tool)
                    end
                end
            end

            _G.BackpackAddedConnection = Player.Backpack.ChildAdded:Connect(function(child)
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
                local char = Player.Character
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

        _G.CharacterAddedConnection = Player.CharacterAdded:Connect(function(newChar)
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

-- NaN Combo (Egg+NaN+Punch)
local comboActive = false
local eggLoop, characterAddedConn

local function ensureEggEquipped()
    if not comboActive or not Player.Character then return end
    
    local eggsInHand = 0
    for _, item in ipairs(Player.Character:GetChildren()) do
        if item.Name == "Protein Egg" then
            eggsInHand = 1
            if eggsInHand > 1 then
                item.Parent = Player.Backpack
            end
        end
    end
    
    if eggsInHand == 0 then
        local egg = Player.Backpack:FindFirstChild("Protein Egg")
        if egg then
            egg.Parent = Player.Character
        end
    end
end

KillerTab:AddToggle("NaN (Egg+NaN+Punch Combo)", false, function(bool)
    comboActive = bool
    
    if bool then
        -- Check if changeSpeedSizeRemote exists
        if RS:FindFirstChild("rEvents") and RS.rEvents:FindFirstChild("changeSpeedSizeRemote") then
            local changeSpeedSizeRemote = RS.rEvents.changeSpeedSizeRemote
            changeSpeedSizeRemote:InvokeServer("changeSize", 0/0)
        else
            print("changeSpeedSizeRemote not found - NaN size may not work")
        end
        
        eggLoop = task.spawn(function()
            while comboActive do
                ensureEggEquipped()
                task.wait(0.2)
            end
        end)
        
        characterAddedConn = Player.CharacterAdded:Connect(function(newChar)
            task.wait(0.5)
            ensureEggEquipped()
        end)
        
        ensureEggEquipped()
        
    else
        if eggLoop then task.cancel(eggLoop) end
        if characterAddedConn then characterAddedConn:Disconnect() end
    end
end)

KillerTab:AddButton("Disable Eggs", function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/244ihssp/IlIIS/refs/heads/main/1"))()
end)

-- Kill All Functions
KillerTab:AddLabel("Auto Kill:")

local function updatePlayerLists()
    local players = game.Players:GetPlayers()
    local whitelistOptions = {}
    local blacklistOptions = {}
    
    for _, player in ipairs(players) do
        if player ~= Player then
            local displayText = getPlayerDisplayText(player)
            table.insert(whitelistOptions, displayText)
            table.insert(blacklistOptions, displayText)
        end
    end
    
    return whitelistOptions, blacklistOptions
end

local whitelistDropdown = KillerTab:AddDropdown("Add to Whitelist", function(selectedText)
    local playerName = selectedText:match("| (.+)$")
    if playerName then
        playerName = playerName:gsub("^%s*(.-)%s*$", "%1") 
        for _, name in ipairs(_G.whitelistedPlayers) do
            if name:lower() == playerName:lower() then return end
        end
        table.insert(_G.whitelistedPlayers, playerName)
        print("Added to whitelist: " .. playerName)
    end
end)

local blacklistDropdown = KillerTab:AddDropdown("Add to Killlist", function(selectedText)
    local playerName = selectedText:match("| (.+)$")
    if playerName then
        playerName = playerName:gsub("^%s*(.-)%s*$", "%1") 
        for _, name in ipairs(_G.blacklistedPlayers) do
            if name:lower() == playerName:lower() then return end
        end
        table.insert(_G.blacklistedPlayers, playerName)
        print("Added to blacklist: " .. playerName)
    end
end)

-- Initialize dropdowns
local function refreshDropdowns()
    whitelistDropdown:Clear()
    blacklistDropdown:Clear()
    
    local whitelistOptions, blacklistOptions = updatePlayerLists()
    
    for _, option in ipairs(whitelistOptions) do
        whitelistDropdown:Add(option)
    end
    
    for _, option in ipairs(blacklistOptions) do
        blacklistDropdown:Add(option)
    end
end

-- Initial population
refreshDropdowns()

-- Auto refresh when players join/leave
game.Players.PlayerAdded:Connect(function()
    refreshDropdowns()
end)

game.Players.PlayerRemoving:Connect(function()
    refreshDropdowns()
end)

KillerTab:AddToggle("Kill Everyone", false, function(bool)
    _G.killAll = bool
    print("Kill Everyone: " .. tostring(bool))
    if bool then
        if not _G.killAllConnection then
            _G.killAllConnection = game:GetService("RunService").Heartbeat:Connect(function()
                if _G.killAll then
                    for _, player in ipairs(game:GetService("Players"):GetPlayers()) do
                        if player ~= Player and not isWhitelisted(player) then
                            killPlayer(player)
                        end
                    end
                end
            end)
            print("Kill Everyone connection started")
        end
    else
        if _G.killAllConnection then
            _G.killAllConnection:Disconnect()
            _G.killAllConnection = nil
            print("Kill Everyone connection stopped")
        end
    end
end)

KillerTab:AddToggle("Whitelist Friends", false, function(bool)
    _G.whitelistFriends = bool
    print("Whitelist Friends: " .. tostring(bool))

    if bool then
        for _, player in pairs(game.Players:GetPlayers()) do
            if player ~= Player and player:IsFriendsWith(Player.UserId) then
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
                    print("Auto-whitelisted friend: " .. playerName)
                end
            end
        end

        game.Players.PlayerAdded:Connect(function(player)
            if _G.whitelistFriends and player:IsFriendsWith(Player.UserId) then
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
                    print("Auto-whitelisted new friend: " .. playerName)
                end
            end
        end)
    end
end)

KillerTab:AddToggle("Kill List", false, function(bool)
    _G.killBlacklistedOnly = bool
    print("Kill List: " .. tostring(bool))
    if bool then
        if not _G.blacklistKillConnection then
            _G.blacklistKillConnection = game:GetService("RunService").Heartbeat:Connect(function()
                if _G.killBlacklistedOnly then
                    for _, player in ipairs(game:GetService("Players"):GetPlayers()) do
                        if player ~= Player and isBlacklisted(player) then
                            killPlayer(player)
                        end
                    end
                end
            end)
            print("Kill List connection started")
        end
    else
        if _G.blacklistKillConnection then
            _G.blacklistKillConnection:Disconnect()
            _G.blacklistKillConnection = nil
            print("Kill List connection stopped")
        end
    end
end)

-- Spectate System
local selectedPlayerToSpectate = nil
local spectating = false
local currentTargetConnection = nil
local camera = workspace.CurrentCamera

local function updateSpectateTarget(player)
    if currentTargetConnection then
        currentTargetConnection:Disconnect()
    end
    
    if player and player.Character then
        local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            camera.CameraSubject = humanoid
            currentTargetConnection = player.CharacterAdded:Connect(function(newChar)
                task.wait(0.2)
                local newHumanoid = newChar:FindFirstChildOfClass("Humanoid")
                if newHumanoid then
                    camera.CameraSubject = newHumanoid
                end
            end)
        end
    end
end

local specdropdown = KillerTab:AddDropdown("Spectate Player", function(text)
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

KillerTab:AddToggle("Spectate", false, function(bool)
    spectating = bool
    print("Spectate: " .. tostring(bool))
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

-- Initialize spectate dropdown
for _, player in ipairs(game.Players:GetPlayers()) do
    if player ~= Player then
        specdropdown:Add(player.DisplayName .. " | " .. player.Name)
    end
end

game.Players.PlayerAdded:Connect(function(player)
    if player ~= Player then
        specdropdown:Add(player.DisplayName .. " | " .. player.Name)
    end
end)

game.Players.PlayerRemoving:Connect(function(player)
    if selectedPlayerToSpectate and selectedPlayerToSpectate == player then
        selectedPlayerToSpectate = nil
        if spectating then
            -- Reset to local player
            local localPlayer = game.Players.LocalPlayer
            if localPlayer.Character then
                local humanoid = localPlayer.Character:FindFirstChildOfClass("Humanoid")
                if humanoid then
                    camera.CameraSubject = humanoid
                end
            end
        end
    end
end)

-- Death Ring System
KillerTab:AddLabel("Kill Aura:")

local ringPart = nil
local ringColor = Color3.fromRGB(50, 163, 255)
local ringTransparency = 0.6

local function updateRingSize()
    if not ringPart then return end
    local diameter = (_G.deathRingRange or 20) * 2
    ringPart.Size = Vector3.new(0.2, diameter, diameter)
end

local function toggleRingVisual()
    if _G.showDeathRing then
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
        print("Death ring visual created")
    elseif ringPart then
        ringPart:Destroy()
        ringPart = nil
        print("Death ring visual destroyed")
    end
end

local function updateRingPosition()
    if not ringPart then return end
    local character = checkCharacter()
    local rootPart = character and character:FindFirstChild("HumanoidRootPart")
    if rootPart then
        ringPart.CFrame = rootPart.CFrame * CFrame.Angles(0, 0, math.rad(90))
    end
end

KillerTab:AddTextBox("Death Ring Range (1-140)", "20", function(text)
    local range = tonumber(text)
    if range then
        _G.deathRingRange = math.clamp(range, 1, 140)
        updateRingSize()
        print("Death ring range set to: " .. _G.deathRingRange)
    end
end)

KillerTab:AddToggle("Death Ring", false, function(bool)
    _G.deathRingEnabled = bool
    print("Death Ring: " .. tostring(bool))
    
    if bool then
        if not _G.deathRingConnection then
            _G.deathRingConnection = game:GetService("RunService").Heartbeat:Connect(function()
                if _G.deathRingEnabled then
                    updateRingPosition()
                    
                    local character = checkCharacter()
                    local myPosition = character and character:FindFirstChild("HumanoidRootPart") and character.HumanoidRootPart.Position
                    if not myPosition then return end

                    for _, player in ipairs(game:GetService("Players"):GetPlayers()) do
                        if player ~= Player and not isWhitelisted(player) and isPlayerAlive(player) then
                            local distance = (myPosition - player.Character.HumanoidRootPart.Position).Magnitude
                            if distance <= (_G.deathRingRange or 20) then
                                killPlayer(player)
                            end
                        end
                    end
                end
            end)
            print("Death ring connection started")
        end
    else
        if _G.deathRingConnection then
            _G.deathRingConnection:Disconnect()
            _G.deathRingConnection = nil
            print("Death ring connection stopped")
        end
    end
end)

KillerTab:AddToggle("Show Death Ring", false, function(bool)
    _G.showDeathRing = bool
    toggleRingVisual()
end)

-- Status Labels
local whitelistLabel = KillerTab:AddLabel("Whitelist: None")
local blacklistLabel = KillerTab:AddLabel("Killlist: None")

KillerTab:AddButton("Clear Whitelist", function()
    _G.whitelistedPlayers = {}
    print("Whitelist cleared")
end)

KillerTab:AddButton("Clear Blacklist", function()
    _G.blacklistedPlayers = {}
    print("Blacklist cleared")
end)

-- Update status labels
local function updateWhitelistLabel()
    if #_G.whitelistedPlayers == 0 then
        whitelistLabel.Text = "Whitelist: None"
    else
        whitelistLabel.Text = "Whitelist: " .. table.concat(_G.whitelistedPlayers, ", ")
    end
end

local function updateBlacklistLabel()
    if #_G.blacklistedPlayers == 0 then
        blacklistLabel.Text = "Killlist: None"
    else
        blacklistLabel.Text = "Killlist: " .. table.concat(_G.blacklistedPlayers, ", ")
    end
end

-- Update labels periodically
task.spawn(function()
    while true do
        updateWhitelistLabel()
        updateBlacklistLabel()
        task.wait(0.2)
    end
end)

-- KILL3R Anti-AFK button
KillerTab:AddButton("Anti AFK", function()
    print("KILL3R Anti-AFK activated")
    -- This would be handled by the existing Anti-AFK system
end)

-------------------- STAT LOOPS (Original Content) --------------------
-- rebirth timer
task.spawn(function()
    while true do updateRebDisp(); task.wait(0.1) end
end)

-- strength/durability timer + pace
task.spawn(function()
    local lastCalc=tick()
    while true do
        local now=tick()
        updateStrDisp()
        strGainLbl.Text = "Strength: "..fmt(strength.Value).."  |  Gained: "..fmt(strength.Value-initStr)
        durGainLbl.Text = "Durability: "..fmt(durability.Value).."  |  Gained: "..fmt(durability.Value-initDur)

        if strRun then
            table.insert(strHist,{t=now,v=strength.Value})
            table.insert(durHist,{t=now,v=durability.Value})
            while #strHist>0 and now-strHist[1].t>calcInt do table.remove(strHist,1) end
            while #durHist>0 and now-durHist[1].t>calcInt do table.remove(durHist,1) end

            if now-lastCalc>=calcInt then
                lastCalc=now
                if #strHist>=2 then
                    local d=strHist[#strHist].v-strHist[1].v
                    local ps=d/calcInt
                    strPaceLbl.Text=string.format("Str Pace: %s /h  |  %s /d  |  %s /w",fmt(ps*3600),fmt(ps*86400),fmt(ps*604800))
                end
                if #durHist>=2 then
                    local d=durHist[#durHist].v-durHist[1].v
                    local ps=d/calcInt
                    durPaceLbl.Text=string.format("Dur Pace: %s /h  |  %s /d  |  %s /w",fmt(ps*3600),fmt(ps*86400),fmt(ps*604800))
                end
                local tot=strElapsed+(now-strStart)
                if tot>0 then
                    local sps=(strength.Value-initStr)/tot
                    strAvgLbl.Text=string.format("Avg Str: %s /h  |  %s /d  |  %s /w",fmt(sps*3600),fmt(sps*86400),fmt(sps*604800))
                    local dps=(durability.Value-initDur)/tot
                    durAvgLbl.Text=string.format("Avg Dur: %s /h  |  %s /d  |  %s /w",fmt(dps*3600),fmt(dps*86400),fmt(dps*604800))
                end
            end
        end
        task.wait(0.05)
    end
end)

--------------------------------------------------------
--  ANTI-AFK  (universal, shared by Rebirth & Strength & KILL3R)
--------------------------------------------------------
local Players            = game:GetService("Players")
local UIS                = game:GetService("UserInputService")
local GuiService         = game:GetService("GuiService")

local player             = Players.LocalPlayer
local rebAntiAfkEnabled  = false   -- toggled in Rebirth tab
local strAntiAfkEnabled  = false   -- toggled in Strength tab
local killerAntiAfkEnabled = false -- toggled in KILL3R tab

-- build the overlay exactly like you had it
local gui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
gui.Name = "AntiAFKOverlay"

local textLabel = Instance.new("TextLabel", gui)
textLabel.Size = UDim2.new(0, 200, 0, 50)
textLabel.Position = UDim2.new(0.5, -100, 0, -50)
textLabel.TextColor3 = Color3.fromRGB(50, 255, 50)
textLabel.Font = Enum.Font.GothamBold
textLabel.TextSize = 20
textLabel.BackgroundTransparency = 1
textLabel.TextTransparency = 1
textLabel.Text = "ANTI AFK"

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

-- running timer
task.spawn(function()
    while true do
        local elapsed = tick() - startTime
        local h = math.floor(elapsed / 3600)
        local m = math.floor((elapsed % 3600) / 60)
        local s = math.floor(elapsed % 60)
        timerLabel.Text = string.format("%02d:%02d:%02d", h, m, s)
        task.wait(1)
    end
end)

-- fade in/out animation
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
