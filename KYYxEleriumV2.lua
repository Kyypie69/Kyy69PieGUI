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
local Main = Win:CreateWindow("KYY HUB 0.69 | POTANG INA MO 🖕🏻","Markyy")
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

-- Create dropdowns with proper initialization
local function createPlayerDropdowns()
    -- Get current players
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

    -- Create whitelist dropdown with initial options
    local whitelistDropdown = KillerTab:AddDropdown("Add to Whitelist", whitelistOptions, function(selectedText)
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

    -- Create blacklist dropdown with initial options
    local blacklistDropdown = KillerTab:AddDropdown("Add to Kill", blacklistOptions, function(selectedText)
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

    return whitelistDropdown, blacklistDropdown
end

-- Initialize dropdowns
local whitelistDropdown, blacklistDropdown = createPlayerDropdowns()

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

-- Function to update dropdown options when players join/leave
local function refreshDropdowns()
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
    
    -- Update dropdown options using the proper method
    whitelistDropdown:UpdateDropdown(whitelistOptions)
    blacklistDropdown:UpdateDropdown(blacklistOptions)
end

-- Auto refresh when players join/leave
game.Players.PlayerAdded:Connect(function()
    task.wait(0.5) -- Small delay to ensure player data is loaded
    refreshDropdowns()
end)

game.Players.PlayerRemoving:Connect(function()
    task.wait(0.1)
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

KillerTab:AddToggle("Kill Target", false, function(bool)
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

-- SPECTATE SYSTEM FIXES
local RunService = game:GetService("RunService")
local camera = workspace.CurrentCamera
local originalCameraSubject = nil
local originalCameraType = nil
local spectateConnection = nil
local targetPlayer = nil
local spectating = false
local selectedPlayerToSpectate = nil
local currentTargetConnection = nil

-- Fixed spectate function
local function updateSpectateTarget(player)
    if currentTargetConnection then
        currentTargetConnection:Disconnect()
        currentTargetConnection = nil
    end
    
    if player and player.Character then
        targetPlayer = player
        
        -- Get the humanoid for camera subject
        local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            -- Store original camera settings
            if not originalCameraSubject then
                originalCameraSubject = camera.CameraSubject
                originalCameraType = camera.CameraType
            end
            
            -- Set camera to follow the target
            camera.CameraType = Enum.CameraType.Custom
            camera.CameraSubject = humanoid
            
            -- Set up connection for character respawns
            currentTargetConnection = player.CharacterAdded:Connect(function(newChar)
                task.wait(0.5)
                local newHumanoid = newChar:FindFirstChildOfClass("Humanoid")
                if newHumanoid and spectating then
                    camera.CameraSubject = newHumanoid
                end
            end)
            
            print("Spectating: " .. player.Name)
        else
            print("No humanoid found for: " .. player.Name)
        end
    else
        -- Reset camera if no valid target
        if spectating then
            stopSpectate()
        end
    end
end

-- Function to stop spectating and return to normal
local function stopSpectate()
    spectating = false
    targetPlayer = nil
    
    if currentTargetConnection then
        currentTargetConnection:Disconnect()
        currentTargetConnection = nil
    end
    
    -- Reset camera to original state
    if originalCameraSubject then
        camera.CameraSubject = originalCameraSubject
        camera.CameraType = originalCameraType or Enum.CameraType.Custom
        originalCameraSubject = nil
        originalCameraType = nil
    else
        -- Fallback to local player
        local localPlayer = game.Players.LocalPlayer
        if localPlayer.Character then
            local humanoid = localPlayer.Character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                camera.CameraSubject = humanoid
                camera.CameraType = Enum.CameraType.Custom
            end
        end
    end
    
    print("Spectate stopped")
end

-- Fixed spectate toggle
KillerTab:AddToggle("Spectate", false, function(bool)
    spectating = bool
    print("Spectate: " .. tostring(bool))
    
    if bool then
        if selectedPlayerToSpectate then
            updateSpectateTarget(selectedPlayerToSpectate)
        else
            print("No player selected for spectating")
            spectating = false
        end
    else
        stopSpectate()
    end
end)

-- SPECTATE DROPDOWN FIX
local specdropdown = nil

-- Create the spectate dropdown with proper initialization
local function createSpectateDropdown()
    -- Get initial player list
    local players = game.Players:GetPlayers()
    local playerOptions = {}
    
    for _, player in ipairs(players) do
        if player ~= Player then
            table.insert(playerOptions, player.DisplayName .. " | " .. player.Name)
        end
    end
    
    -- Create dropdown with proper KYY library syntax
    specdropdown = KillerTab:AddDropdown("Spectate Player", playerOptions, function(selectedText)
        for _, player in ipairs(game.Players:GetPlayers()) do
            local optionText = player.DisplayName .. " | " .. player.Name
            if selectedText == optionText then
                selectedPlayerToSpectate = player
                if spectating then
                    updateSpectateTarget(player)
                end
                print("Selected player for spectate: " .. player.Name)
                break
            end
        end
    end)
    
    return specdropdown
end

-- Function to refresh spectate dropdown
local function refreshSpectateDropdown()
    local players = game.Players:GetPlayers()
    local playerOptions = {}
    
    for _, player in ipairs(players) do
        if player ~= Player then
            table.insert(playerOptions, player.DisplayName .. " | " .. player.Name)
        end
    end
    
    -- Update dropdown using proper KYY library method
    if specdropdown then
        specdropdown:UpdateDropdown(playerOptions)
        print("Spectate dropdown refreshed with " .. #playerOptions .. " players")
    end
end

-- Initialize the dropdown
createSpectateDropdown()

-- Auto refresh when players join/leave
game.Players.PlayerAdded:Connect(function(player)
    task.wait(0.5)
    refreshSpectateDropdown()
end)

game.Players.PlayerRemoving:Connect(function(player)
    if selectedPlayerToSpectate and selectedPlayerToSpectate == player then
        selectedPlayerToSpectate = nil
        if spectating then
            stopSpectate()
        end
    end
    refreshSpectateDropdown()
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

local antiKnockbackEnabled = false
local antiKnockbackConn = nil

-- Function to apply anti-knockback to a specific character
local function applyAntiKnockback(character)
    if not character then return end
    
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end
    
    -- Remove existing anti-knockback if it exists
    local existing = rootPart:FindFirstChild("KYYAntiFling")
    if existing then existing:Destroy() end
    
    -- Create new BodyVelocity with unique name
    local bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.Name = "KYYAntiFling"  -- Unique name to identify our anti-fling
    bodyVelocity.MaxForce = Vector3.new(100000, 0, 100000)  -- Only X and Z axis
    bodyVelocity.Velocity = Vector3.new(0, 0, 0)
    bodyVelocity.P = 1250
    bodyVelocity.Parent = rootPart
end

-- Function to remove anti-knockback from a specific character
local function removeAntiKnockback(character)
    if not character then return end
    
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end
    
    local existing = rootPart:FindFirstChild("KYYAntiFling")
    if existing then existing:Destroy() end
end

-- Function to update anti-knockback state
local function updateAntiKnockback(state)
    antiKnockbackEnabled = state
    
    if state then
        -- Apply to current character
        if Player.Character then
            applyAntiKnockback(Player.Character)
        end
        
        -- Set up connection for respawn handling
        if antiKnockbackConn then antiKnockbackConn:Disconnect() end
        antiKnockbackConn = Player.CharacterAdded:Connect(function(character)
            -- Wait for character to fully load
            task.wait(0.1)
            applyAntiKnockback(character)
        end)
    else
        -- Disconnect connection
        if antiKnockbackConn then
            antiKnockbackConn:Disconnect()
            antiKnockbackConn = nil
        end
        
        -- Remove from current character
        if Player.Character then
            removeAntiKnockback(Player.Character)
        end
    end
end

-- Handle character removal (cleanup)
Player.CharacterRemoving:Connect(function(character)
    if not antiKnockbackEnabled then return end
    -- Don't remove here, let the CharacterAdded handle it
end)

-- Add the Anti Fling toggle to Killer Tab
KillerTab:AddToggle("Anti Fling", false, function(bool)
    updateAntiKnockback(bool)
end)

-- Add info label
KillerTab:AddLabel("Prevents being flung by other players")

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

-------------------- STYLED KILL COUNTER GUI --------------------
-- Kill Statistics that sync with actual game deaths
local killStats = {
    totalKills = 0,
    sessionKills = 0,
    killStreak = 0,
    bestStreak = 0,
    startTime = tick(),
    lastKillTime = 0,
    killsPerMinute = 0,
    killRate = 0,
    leaderboardKills = 0,
    lastLeaderboardCheck = 0
}

-- Track actual player deaths instead of just script kills
local playerDeaths = {}
local killConnection = nil
local deathConnection = nil

-- Create Kill Counter GUI with glowing light blue theme
local killGui = Instance.new("ScreenGui")
killGui.Name = "KillCounterGUI"
killGui.Parent = Player:WaitForChild("PlayerGui")
killGui.Enabled = false -- Auto-toggle turned OFF by default

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 280, 0, 240) -- Increased height for separator lines
mainFrame.Position = UDim2.new(0.02, 0, 0.3, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(173, 216, 230) -- Light blue base
mainFrame.BorderSizePixel = 2
mainFrame.BorderColor3 = Color3.fromRGB(135, 206, 250) -- Lighter border
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = killGui

-- Create glowing effect
local glowFrame = Instance.new("Frame")
glowFrame.Size = UDim2.new(1, 12, 1, 12)
glowFrame.Position = UDim2.new(0, -6, 0, -6)
glowFrame.BackgroundColor3 = Color3.fromRGB(173, 216, 230)
glowFrame.BackgroundTransparency = 0.7
glowFrame.BorderSizePixel = 0
glowFrame.ZIndex = -1
glowFrame.Parent = mainFrame

local glowCorner = Instance.new("UICorner")
glowCorner.CornerRadius = UDim.new(0, 12)
glowCorner.Parent = glowFrame

-- Add corner radius to main frame
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = mainFrame

-- Add gradient for glowing effect
local gradient = Instance.new("UIGradient")
gradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(135, 206, 250)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(173, 216, 230)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(135, 206, 250))
})
gradient.Rotation = 45
gradient.Parent = mainFrame

-- Title with calligraphy bold font
local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, 0, 0, 25)
titleLabel.Position = UDim2.new(0, 0, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "⚔️ KILL COUNTER ⚔️"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.Font = Enum.Font.Garamond -- Calligraphy style font
titleLabel.TextSize = 18
titleLabel.TextStrokeTransparency = 0
titleLabel.TextStrokeColor3 = Color3.fromRGB(0, 100, 200)
titleLabel.Parent = mainFrame

-- Separator line 1
local separator1 = Instance.new("Frame")
separator1.Size = UDim2.new(0.9, 0, 0, 1)
separator1.Position = UDim2.new(0.05, 0, 0, 25)
separator1.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
separator1.BackgroundTransparency = 0.5
separator1.BorderSizePixel = 0
separator1.Parent = mainFrame

-- Timer Display with calligraphy bold
local timerLabel = Instance.new("TextLabel")
timerLabel.Size = UDim2.new(1, 0, 0, 20)
timerLabel.Position = UDim2.new(0, 0, 0, 27)
timerLabel.BackgroundTransparency = 1
timerLabel.Text = "Session: 00:00:00"
timerLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
timerLabel.Font = Enum.Font.Garamond
timerLabel.TextSize = 14
timerLabel.TextStrokeTransparency = 0.5
timerLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
timerLabel.Parent = mainFrame

-- Separator line 2
local separator2 = Instance.new("Frame")
separator2.Size = UDim2.new(0.9, 0, 0, 1)
separator2.Position = UDim2.new(0.05, 0, 0, 47)
separator2.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
separator2.BackgroundTransparency = 0.5
separator2.BorderSizePixel = 0
separator2.Parent = mainFrame

-- Total Kills with calligraphy bold (LARGER SIZE)
local totalKillsLabel = Instance.new("TextLabel")
totalKillsLabel.Size = UDim2.new(1, 0, 0, 25) -- Increased height
totalKillsLabel.Position = UDim2.new(0, 0, 0, 48)
totalKillsLabel.BackgroundTransparency = 1
totalKillsLabel.Text = "Total Kills: 0"
totalKillsLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
totalKillsLabel.Font = Enum.Font.Garamond
totalKillsLabel.TextSize = 18 -- Larger text size
totalKillsLabel.TextStrokeTransparency = 0.5
totalKillsLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
totalKillsLabel.Parent = mainFrame

-- Separator line 3
local separator3 = Instance.new("Frame")
separator3.Size = UDim2.new(0.9, 0, 0, 1)
separator3.Position = UDim2.new(0.05, 0, 0, 73)
separator3.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
separator3.BackgroundTransparency = 0.5
separator3.BorderSizePixel = 0
separator3.Parent = mainFrame

-- Session Kills with calligraphy bold
local sessionKillsLabel = Instance.new("TextLabel")
sessionKillsLabel.Size = UDim2.new(1, 0, 0, 20)
sessionKillsLabel.Position = UDim2.new(0, 0, 0, 74)
sessionKillsLabel.BackgroundTransparency = 1
sessionKillsLabel.Text = "Session Kills: 0"
sessionKillsLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
sessionKillsLabel.Font = Enum.Font.Garamond
sessionKillsLabel.TextSize = 14
sessionKillsLabel.TextStrokeTransparency = 0.5
sessionKillsLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
sessionKillsLabel.Parent = mainFrame

-- Separator line 4
local separator4 = Instance.new("Frame")
separator4.Size = UDim2.new(0.9, 0, 0, 1)
separator4.Position = UDim2.new(0.05, 0, 0, 94)
separator4.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
separator4.BackgroundTransparency = 0.5
separator4.BorderSizePixel = 0
separator4.Parent = mainFrame

-- Leaderboard Kills with calligraphy bold
local leaderboardLabel = Instance.new("TextLabel")
leaderboardLabel.Size = UDim2.new(1, 0, 0, 20)
leaderboardLabel.Position = UDim2.new(0, 0, 0, 95)
leaderboardLabel.BackgroundTransparency = 1
leaderboardLabel.Text = "Leaderboard: 0"
leaderboardLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
leaderboardLabel.Font = Enum.Font.Garamond
leaderboardLabel.TextSize = 14
leaderboardLabel.TextStrokeTransparency = 0.5
leaderboardLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
leaderboardLabel.Parent = mainFrame

-- Separator line 5
local separator5 = Instance.new("Frame")
separator5.Size = UDim2.new(0.9, 0, 0, 1)
separator5.Position = UDim2.new(0.05, 0, 0, 115)
separator5.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
separator5.BackgroundTransparency = 0.5
separator5.BorderSizePixel = 0
separator5.Parent = mainFrame

-- Kill Streak with calligraphy bold
local streakLabel = Instance.new("TextLabel")
streakLabel.Size = UDim2.new(1, 0, 0, 20)
streakLabel.Position = UDim2.new(0, 0, 0, 116)
streakLabel.BackgroundTransparency = 1
streakLabel.Text = "Streak: 0 | Best: 0"
streakLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
streakLabel.Font = Enum.Font.Garamond
streakLabel.TextSize = 14
streakLabel.TextStrokeTransparency = 0.5
streakLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
streakLabel.Parent = mainFrame

-- Separator line 6
local separator6 = Instance.new("Frame")
separator6.Size = UDim2.new(0.9, 0, 0, 1)
separator6.Position = UDim2.new(0.05, 0, 0, 136)
separator6.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
separator6.BackgroundTransparency = 0.5
separator6.BorderSizePixel = 0
separator6.Parent = mainFrame

-- Kills Per Minute with calligraphy bold
local kpmLabel = Instance.new("TextLabel")
kpmLabel.Size = UDim2.new(1, 0, 0, 20)
kpmLabel.Position = UDim2.new(0, 0, 0, 137)
kpmLabel.BackgroundTransparency = 1
kpmLabel.Text = "KPM: 0.0 | Rate: 0.0/h"
kpmLabel.TextColor3 = Color3.fromRGB(0, 255, 255)
kpmLabel.Font = Enum.Font.Garamond
kpmLabel.TextSize = 14
kpmLabel.TextStrokeTransparency = 0.5
kpmLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
kpmLabel.Parent = mainFrame

-- Separator line 7
local separator7 = Instance.new("Frame")
separator7.Size = UDim2.new(0.9, 0, 0, 1)
separator7.Position = UDim2.new(0.05, 0, 0, 157)
separator7.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
separator7.BackgroundTransparency = 0.5
separator7.BorderSizePixel = 0
separator7.Parent = mainFrame

-- Last Kill Info with calligraphy bold
local lastKillLabel = Instance.new("TextLabel")
lastKillLabel.Size = UDim2.new(1, 0, 0, 20)
lastKillLabel.Position = UDim2.new(0, 0, 0, 158)
lastKillLabel.BackgroundTransparency = 1
lastKillLabel.Text = "Last Kill: Never"
lastKillLabel.TextColor3 = Color3.fromRGB(255, 165, 0)
lastKillLabel.Font = Enum.Font.Garamond
lastKillLabel.TextSize = 14
lastKillLabel.TextStrokeTransparency = 0.5
lastKillLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
lastKillLabel.Parent = mainFrame

-- Separator line 8
local separator8 = Instance.new("Frame")
separator8.Size = UDim2.new(0.9, 0, 0, 1)
separator8.Position = UDim2.new(0.05, 0, 0, 178)
separator8.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
separator8.BackgroundTransparency = 0.5
separator8.BorderSizePixel = 0
separator8.Parent = mainFrame

-- Sync Status with calligraphy bold
local syncStatusLabel = Instance.new("TextLabel")
syncStatusLabel.Size = UDim2.new(1, 0, 0, 20)
syncStatusLabel.Position = UDim2.new(0, 0, 0, 179)
syncStatusLabel.BackgroundTransparency = 1
syncStatusLabel.Text = "Sync: Waiting..."
syncStatusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
syncStatusLabel.Font = Enum.Font.Garamond
syncStatusLabel.TextSize = 14
syncStatusLabel.TextStrokeTransparency = 0.5
syncStatusLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
syncStatusLabel.Parent = mainFrame

-- Separator line 9
local separator9 = Instance.new("Frame")
separator9.Size = UDim2.new(0.9, 0, 0, 1)
separator9.Position = UDim2.new(0.05, 0, 0, 199)
separator9.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
separator9.BackgroundTransparency = 0.5
separator9.BorderSizePixel = 0
separator9.Parent = mainFrame

-- Status with calligraphy bold
local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, 0, 0, 20)
statusLabel.Position = UDim2.new(0, 0, 0, 200)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "Status: Idle"
statusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
statusLabel.Font = Enum.Font.Garamond
statusLabel.TextSize = 14
statusLabel.TextStrokeTransparency = 0.5
statusLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
statusLabel.Parent = mainFrame

-- Add pulsing glow effect
task.spawn(function()
    while true do
        for i = 0, 1, 0.02 do
            local transparency = 0.5 + (math.sin(i * math.pi * 2) * 0.3)
            glowFrame.BackgroundTransparency = transparency
            task.wait(0.05)
        end
    end
end)

-- Function to check leaderboard for kills
local function checkLeaderboardKills()
    local success, kills = pcall(function()
        -- Try to find kills stat in common locations
        local leaderstats = Player:FindFirstChild("leaderstats")
        if leaderstats then
            local killsStat = leaderstats:FindFirstChild("Kills") or leaderstats:FindFirstChild("kills") or leaderstats:FindFirstChild("KO") or leaderstats:FindFirstChild("Knockouts")
            if killsStat then
                return killsStat.Value
            end
        end
        
        -- Check for other common locations
        local stats = Player:FindFirstChild("Stats")
        if stats then
            local killsStat = stats:FindFirstChild("Kills") or stats:FindFirstChild("kills")
            if killsStat then
                return killsStat.Value
            end
        end
        
        -- Check for DataFolder
        local dataFolder = Player:FindFirstChild("DataFolder") or Player:FindFirstChild("data")
        if dataFolder then
            local killsStat = dataFolder:FindFirstChild("Kills") or dataFolder:FindFirstChild("kills")
            if killsStat then
                return killsStat.Value
            end
        end
        
        return 0
    end)
    
    return success and kills or 0
end

-- Function to detect when someone dies (more reliable than relying on your kills)
local function setupDeathDetection()
    -- Monitor all players for deaths
    local function monitorPlayerDeath(otherPlayer)
        if otherPlayer == Player then return end -- Don't monitor yourself
        
        local function onCharacterAdded(character)
            local humanoid = character:WaitForChild("Humanoid")
            
            humanoid.Died:Connect(function()
                -- Check if this player was recently damaged by you
                local deathTime = tick()
                playerDeaths[otherPlayer.Name] = deathTime
                
                -- Check if you're nearby or have damaged them recently
                local myCharacter = Player.Character
                local theirCharacter = otherPlayer.Character
                
                if myCharacter and theirCharacter then
                    local myRoot = myCharacter:FindFirstChild("HumanoidRootPart")
                    local theirRoot = theirCharacter:FindFirstChild("HumanoidRootPart")
                    
                    if myRoot and theirRoot then
                        local distance = (myRoot.Position - theirRoot.Position).Magnitude
                        
                        -- If you're within 50 studs, count it as your kill
                        if distance <= 50 then
                            recordKill(otherPlayer.Name)
                        end
                    end
                end
                
                -- Also check if you have any active kill connections
                if _G.killAll or _G.killBlacklistedOnly or _G.deathRingEnabled then
                    task.wait(0.1) -- Small delay to ensure our kill function triggered
                    recordKill(otherPlayer.Name)
                end
            end)
        end
        
        if otherPlayer.Character then
            onCharacterAdded(otherPlayer.Character)
        end
        
        otherPlayer.CharacterAdded:Connect(onCharacterAdded)
    end
    
    -- Monitor all existing players
    for _, otherPlayer in ipairs(game.Players:GetPlayers()) do
        if otherPlayer ~= Player then
            monitorPlayerDeath(otherPlayer)
        end
    end
    
    -- Monitor new players
    game.Players.PlayerAdded:Connect(function(otherPlayer)
        monitorPlayerDeath(otherPlayer)
    end)
end

-- Timer Update Loop
task.spawn(function()
    while true do
        local elapsed = tick() - killStats.startTime
        local h = math.floor(elapsed / 3600)
        local m = math.floor((elapsed % 3600) / 60)
        local s = math.floor(elapsed % 60)
        timerLabel.Text = string.format("Session: %02d:%02d:%02d", h, m, s)
        
        -- Update kills per minute
        if killStats.sessionKills > 0 then
            local minutes = elapsed / 60
            killStats.killsPerMinute = killStats.sessionKills / minutes
            killStats.killRate = killStats.sessionKills / (elapsed / 3600)
            kpmLabel.Text = string.format("KPM: %.1f | Rate: %.1f/h", killStats.killsPerMinute, killStats.killRate)
        end
        
        -- Check leaderboard kills every 5 seconds
        if tick() - killStats.lastLeaderboardCheck > 5 then
            local leaderboardKills = checkLeaderboardKills()
            if leaderboardKills > killStats.leaderboardKills then
                killStats.leaderboardKills = leaderboardKills
                leaderboardLabel.Text = "Leaderboard: " .. killStats.leaderboardKills
                syncStatusLabel.Text = "Sync: Updated"
            else
                syncStatusLabel.Text = "Sync: Standby"
            end
            killStats.lastLeaderboardCheck = tick()
        end
        
        task.wait(1)
    end
end)

-- Enhanced record kill function
function recordKill(playerName)
    killStats.totalKills = killStats.totalKills + 1
    killStats.sessionKills = killStats.sessionKills + 1
    killStats.killStreak = killStats.killStreak + 1
    killStats.lastKillTime = tick()
    
    if killStats.killStreak > killStats.bestStreak then
        killStats.bestStreak = killStats.killStreak
    end
    
    -- Update GUI
    totalKillsLabel.Text = "Total Kills: " .. killStats.totalKills
    sessionKillsLabel.Text = "Session Kills: " .. killStats.sessionKills
    streakLabel.Text = string.format("Streak: %d | Best: %d", killStats.killStreak, killStats.bestStreak)
    lastKillLabel.Text = "Last Kill: " .. playerName
    statusLabel.Text = "Status: Kill!"
    syncStatusLabel.Text = "Sync: Kill Detected"
    
    -- Reset status after 3 seconds
    task.wait(3)
    statusLabel.Text = "Status: Idle"
    syncStatusLabel.Text = "Sync: Standby"
end

-- Reset streak when you die
Player.CharacterAdded:Connect(function()
    killStats.killStreak = 0
    streakLabel.Text = string.format("Streak: %d | Best: %d", killStats.killStreak, killStats.bestStreak)
end)

-- Initialize death detection
setupDeathDetection()

-- Add GUI toggle to KillerTab (starts OFF by default)
KillerTab:AddToggle("Show Kill Counter", false, function(bool)
    killGui.Enabled = bool
end)

KillerTab:AddLabel("Kill Counter starts OFF - toggle above to show")

KillerTab:AddButton("Reset Session Stats", function()
    killStats.sessionKills = 0
    killStats.killStreak = 0
    killStats.startTime = tick()
    sessionKillsLabel.Text = "Session Kills: 0"
    streakLabel.Text = "Streak: 0 | Best: " .. killStats.bestStreak
    kpmLabel.Text = "KPM: 0.0 | Rate: 0.0/h"
    statusLabel.Text = "Session Reset"
    syncStatusLabel.Text = "Sync: Reset"
    task.wait(1)
    statusLabel.Text = "Status: Idle"
    syncStatusLabel.Text = "Sync: Standby"
end)

KillerTab:AddButton("Force Sync Leaderboard", function()
    local leaderboardKills = checkLeaderboardKills()
    killStats.leaderboardKills = leaderboardKills
    leaderboardLabel.Text = "Leaderboard: " .. killStats.leaderboardKills
    syncStatusLabel.Text = "Sync: Manual Update"
    task.wait(2)
    syncStatusLabel.Text = "Sync: Standby"
end)

-- Lighting Change
getgenv().Lighting = game:GetService'Lighting'
getgenv().RunService = game:GetService'RunService'

local ColorCorrection = true
local Correction = true
local SunRays = true
-- Change it to On and Off (true & false)

-- Sunset Desert Skybox with vibrant colors
Skybox = Instance.new("Sky", Lighting)
Skybox.SkyboxBk = "rbxassetid://153743489"  -- Desert sunset back
Skybox.SkyboxDn = "rbxassetid://153743503"  -- Desert sand below
Skybox.SkyboxFt = "rbxassetid://153743479"  -- Desert horizon front
Skybox.SkyboxLf = "rbxassetid://153743492"  -- Desert landscape left
Skybox.SkyboxRt = "rbxassetid://153743485"  -- Desert landscape right
Skybox.SkyboxUp = "rbxassetid://153743499"  -- Desert sky above

-- Sunset Color Correction for dramatic warm tones
local SunsetColorCorrection = Instance.new("ColorCorrectionEffect", Lighting)
SunsetColorCorrection.TintColor = Color3.fromRGB(255, 180, 120)  -- Warm sunset orange
SunsetColorCorrection.Brightness = 0.2
SunsetColorCorrection.Contrast = 0.4
SunsetColorCorrection.Enabled = true

-- Enhanced Sunset Sun Rays for 4D depth
local SunsetSunRays = Instance.new("SunRaysEffect", Lighting)
SunsetSunRays.Intensity = 0.6  -- Stronger for sunset
SunsetSunRays.Spread = 0.9
SunsetSunRays.Enabled = true

-- Sunset Atmosphere with 4D movement
local SunsetAtmosphere = Instance.new("Atmosphere", Lighting)
SunsetAtmosphere.Density = 0.4
SunsetAtmosphere.Offset = 0
SunsetAtmosphere.Color = Color3.fromRGB(255, 150, 100)  -- Orange sunset
SunsetAtmosphere.Decay = Color3.fromRGB(255, 120, 80)   -- Deeper orange decay
SunsetAtmosphere.Glare = 0.6  -- Enhanced glare for sunset
SunsetAtmosphere.Haze = 0.8

-- Sunset Lighting Properties
Lighting.Ambient = Color3.fromRGB(180, 120, 80)      -- Warm sunset ambient
Lighting.OutdoorAmbient = Color3.fromRGB(200, 140, 100)  -- Enhanced outdoor ambient
Lighting.ClockTime = 18.5  -- Golden hour sunset time
Lighting.GeographicLatitude = 20  -- Lower latitude for dramatic sunset
Lighting.GlobalShadows = true
Lighting.ShadowSoftness = 0.5  -- Softer shadows for sunset

-- 4D Sunset Effects with dynamic movement
local timeOffset = 0
local sunsetPhase = 0
RunService.Stepped:Connect(function()
   timeOffset = timeOffset + 0.015
   sunsetPhase = sunsetPhase + 0.008
   
   -- Dynamic sunset progression
   local sunsetIntensity = math.sin(sunsetPhase) * 0.3 + 0.7
   
   -- 4D Atmospheric movement
   SunsetAtmosphere.Density = 0.4 + math.sin(timeOffset) * 0.1
   SunsetAtmosphere.Haze = 0.8 + math.cos(timeOffset * 0.7) * 0.15
   SunsetAtmosphere.Glare = 0.6 + math.sin(timeOffset * 1.2) * 0.2
   
   -- Dynamic color shifting for 4D effect
   SunsetColorCorrection.TintColor = Color3.fromRGB(
      255, 
      180 + math.sin(timeOffset * 0.5) * 20, 
      120 + math.cos(timeOffset * 0.3) * 15
   )
   
   -- Enhanced sun rays movement
   SunsetSunRays.Intensity = 0.6 + math.sin(timeOffset * 2) * 0.1
   
   -- Subtle time progression for sunset movement
   Lighting.ClockTime = 18.5 + math.sin(timeOffset * 0.1) * 0.2
   
   if Lighting then
      if Lighting:FindFirstChild"ColorCorrection" then
         if not ColorCorrection then
            Lighting:WaitForChild"ColorCorrection":Destroy()
         else
            return nil
         end
      elseif Lighting:FindFirstChild"Correction" then
         if not Correction then
            Lighting:WaitForChild"Correction":Destroy()
         else
            return nil
         end
      elseif Lighting:FindFirstChildOfClass"SunRaysEffect" then
         if not SunRays then
            Lighting:WaitForChild"SunRaysEffect":Destroy()
         else
            return nil
         end
      end
   end
end)

-- Additional 4D Depth Layer
local BloomEffect = Instance.new("BloomEffect", Lighting)
BloomEffect.Intensity = 0.3
BloomEffect.Size = 0.5
BloomEffect.Threshold = 0.8

getgenv().Lighting = game:GetService'Lighting'
getgenv().RunService = game:GetService'RunService'

local ColorCorrection = false
local Correction = false
local SunRays = false
-- Change it to On and Off (true & false)

-- Sunset Desert Skybox with vibrant colors
Skybox = Instance.new("Sky", Lighting)
Skybox.SkyboxBk = "rbxassetid://153743489"  -- Desert sunset back
Skybox.SkyboxDn = "rbxassetid://153743503"  -- Desert sand below
Skybox.SkyboxFt = "rbxassetid://153743479"  -- Desert horizon front
Skybox.SkyboxLf = "rbxassetid://153743492"  -- Desert landscape left
Skybox.SkyboxRt = "rbxassetid://153743485"  -- Desert landscape right
Skybox.SkyboxUp = "rbxassetid://153743499"  -- Desert sky above

-- Sunset Color Correction for dramatic warm tones
local SunsetColorCorrection = Instance.new("ColorCorrectionEffect", Lighting)
SunsetColorCorrection.TintColor = Color3.fromRGB(255, 180, 120)  -- Warm sunset orange
SunsetColorCorrection.Brightness = 0.2
SunsetColorCorrection.Contrast = 0.4
SunsetColorCorrection.Enabled = true

-- Enhanced Sunset Sun Rays for 4D depth
local SunsetSunRays = Instance.new("SunRaysEffect", Lighting)
SunsetSunRays.Intensity = 0.6  -- Stronger for sunset
SunsetSunRays.Spread = 0.9
SunsetSunRays.Enabled = true

-- Sunset Atmosphere with 4D movement
local SunsetAtmosphere = Instance.new("Atmosphere", Lighting)
SunsetAtmosphere.Density = 0.4
SunsetAtmosphere.Offset = 0
SunsetAtmosphere.Color = Color3.fromRGB(255, 150, 100)  -- Orange sunset
SunsetAtmosphere.Decay = Color3.fromRGB(255, 120, 80)   -- Deeper orange decay
SunsetAtmosphere.Glare = 0.6  -- Enhanced glare for sunset
SunsetAtmosphere.Haze = 0.8

-- Sunset Lighting Properties
Lighting.Ambient = Color3.fromRGB(180, 120, 80)      -- Warm sunset ambient
Lighting.OutdoorAmbient = Color3.fromRGB(200, 140, 100)  -- Enhanced outdoor ambient
Lighting.ClockTime = 18.5  -- Golden hour sunset time
Lighting.GeographicLatitude = 20  -- Lower latitude for dramatic sunset
Lighting.GlobalShadows = true
Lighting.ShadowSoftness = 0.5  -- Softer shadows for sunset

-- 4D Sunset Effects with dynamic movement
local timeOffset = 0
local sunsetPhase = 0
RunService.Stepped:Connect(function()
   timeOffset = timeOffset + 0.015
   sunsetPhase = sunsetPhase + 0.008
   
   -- Dynamic sunset progression
   local sunsetIntensity = math.sin(sunsetPhase) * 0.3 + 0.7
   
   -- 4D Atmospheric movement
   SunsetAtmosphere.Density = 0.4 + math.sin(timeOffset) * 0.1
   SunsetAtmosphere.Haze = 0.8 + math.cos(timeOffset * 0.7) * 0.15
   SunsetAtmosphere.Glare = 0.6 + math.sin(timeOffset * 1.2) * 0.2
   
   -- Dynamic color shifting for 4D effect
   SunsetColorCorrection.TintColor = Color3.fromRGB(
      255, 
      180 + math.sin(timeOffset * 0.5) * 20, 
      120 + math.cos(timeOffset * 0.3) * 15
   )
   
   -- Enhanced sun rays movement
   SunsetSunRays.Intensity = 0.6 + math.sin(timeOffset * 2) * 0.1
   
   -- Subtle time progression for sunset movement
   Lighting.ClockTime = 18.5 + math.sin(timeOffset * 0.1) * 0.2
   
   if Lighting then
      if Lighting:FindFirstChild"ColorCorrection" then
         if not ColorCorrection then
            Lighting:WaitForChild"ColorCorrection":Destroy()
         else
            return nil
         end
      elseif Lighting:FindFirstChild"Correction" then
         if not Correction then
            Lighting:WaitForChild"Correction":Destroy()
         else
            return nil
         end
      elseif Lighting:FindFirstChildOfClass"SunRaysEffect" then
         if not SunRays then
            Lighting:WaitForChild"SunRaysEffect":Destroy()
         else
            return nil
         end
      end
   end
end)

-- Additional 4D Depth Layer
local BloomEffect = Instance.new("BloomEffect", Lighting)
BloomEffect.Intensity = 0.3
BloomEffect.Size = 0.5
BloomEffect.Threshold = 0.8
