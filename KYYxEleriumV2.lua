--[[  EleriumV2xKYY  (ver.69) Final Enhanced with All Killer Tab Features ]]
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

-------------------- window / tabs --------------------
local Main = Win:CreateWindow("KYY HUB 0.6.9 pos  |  PACKS Farming UI","Markyy")
local RebirthTab = Main:CreateTab("REB1RTH")
local StrengthTab= Main:CreateTab("STR3NGTH")
local Killer   = Main:CreateTab("K1LLER")

-------------------- Fast Rebirth --------------------
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
RebirthTab:AddButton("Anti AFK (ON)",function()
    rebAntiAfkEnabled=true
end)

RebirthTab:AddButton("Equip 8× Swift Samurai",function() equipEight("Swift Samurai") end)
RebirthTab:AddButton("Anti Lag",antiLag)
RebirthTab:AddButton("TP Jungle Lift",tpJungleLift)

-- auto protein egg
local eggRunning=false
task.spawn(function()
    while true do
        if eggRunning then toolActivate("Protein Egg","proteinEgg"); task.wait(1800) else task.wait(1) end
    end
end)
RebirthTab:AddToggle("Auto Protein Egg",false,function(s) eggRunning=s; if s then toolActivate("Protein Egg","proteinEgg") end end)

-------------------- Fast Strength --------------------
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
StrengthTab:AddButton("Anti AFK (ON)",function()
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

-------------------- stat loops --------------------
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

-- universal anti-afk (triggers when any button pressed)
local GC=game:GetService("GuiService")
local UIS=game:GetService("UserInputService")
GC.MenuOpened:Connect(function() GC:CloseMenu() end)
task.spawn(function()
    while true do
        if rebAntiAfkEnabled or strAntiAfkEnabled then
            UIS:SendKeyEvent(false,Enum.KeyCode.LeftShift,false,game)
        end
        task.wait(120)
    end
end)

--------------------------------------------------------
--  KILLER TAB - COMPLETE ENHANCED WITH ALL FEATURES
--------------------------------------------------------
local Players  = game:GetService("Players")
local RunSrv   = game:GetService("RunService")

-- storage
local killAll      = false
local killTarg     = false
local killAura     = false
local nanoWhile    = false
local targetPlayer = nil
local viewConnection= nil
local killAuraRadius = 25
local whitelistEnabled = false
local whitelistedPlayers = {}
local killCount = 0
local killPaceStart = tick()
local killPaceHist = {}
local maxKillHist = 20

-- NEW FEATURES STORAGE
local autoWhitelistFriends = false
local autoPunchEnabled = false
local autoFastEnabled = false
local antiKnockbackEnabled = false
local antiFlingEnabled = false
local bangTarget = nil
local bangConnection = nil
local originalCFrame = nil

-- quick wrappers
local function getRoot(p)
    return p.Character and p.Character:FindFirstChild("HumanoidRootPart")
end
local function dealDmg(p)
    local r = getRoot(p)
    if r then
        muscleEvent:FireServer("rep")        -- any remote that damages
        -- optional: fire a second time for faster kill
        muscleEvent:FireServer("rep")
        
        -- Track kill count for pace calculation
        killCount = killCount + 1
    end
end
local function setBodyScale(p,size)
    local human = p.Character and p.Character:FindFirstChildOfClass("Humanoid")
    if human then
        human:FindFirstChild("BodyWidthScale").Value  = size
        human:FindFirstChild("BodyHeightScale").Value = size
        human:FindFirstChild("BodyDepthScale").Value  = size
        human:FindFirstChild("HeadScale").Value       = size
    end
end

-- check if player is whitelisted
local function isWhitelisted(player)
    return whitelistEnabled and whitelistedPlayers[player.Name]
end

-- NEW: Auto whitelist friends
local function autoWhitelistFriendsFunc()
    if autoWhitelistFriends then
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= Player then
                local success, isFriend = pcall(function()
                    return Player:IsFriendsWith(player.UserId)
                end)
                if success and isFriend then
                    whitelistedPlayers[player.Name] = true
                end
            end
        end
        updateWhitelistDisplay()
    end
end

-- NEW: Anti knockback/fling functions
local function enableAntiKnockback()
    if antiKnockbackEnabled and Player.Character then
        local humanoid = Player.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
            humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
        end
    end
end

local function disableAntiKnockback()
    if Player.Character then
        local humanoid = Player.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, true)
            humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, true)
        end
    end
end

-- NEW: Bang player function
local function bangPlayer(target)
    if bangConnection then bangConnection:Disconnect() end
    if not target or not target.Character then return end
    
    local targetRoot = getRoot(target)
    if not targetRoot then return end
    
    -- Store original position
    originalCFrame = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") and Player.Character.HumanoidRootPart.CFrame
    
    bangConnection = RunSrv.Heartbeat:Connect(function()
        if not target.Parent or not target.Character then
            bangConnection:Disconnect()
            bangConnection = nil
            return
        end
        
        local targetRoot = getRoot(target)
        if targetRoot and Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
            -- Position player above target
            local newPos = targetRoot.Position + Vector3.new(0, 3, 0)
            Player.Character.HumanoidRootPart.CFrame = CFrame.new(newPos)
            
            -- Apply damage
            dealDmg(target)
        end
    end)
end

local function stopBang()
    if bangConnection then
        bangConnection:Disconnect()
        bangConnection = nil
    end
    
    -- Return to original position if stored
    if originalCFrame and Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
        Player.Character.HumanoidRootPart.CFrame = originalCFrame
    end
end

-- kill-all loop (with whitelist support)
task.spawn(function()
    while true do
        if killAll then
            for _,v in ipairs(Players:GetPlayers()) do
                if v~=Player and not isWhitelisted(v) then dealDmg(v) end
            end
        end
        RunSrv.Heartbeat:Wait()
    end
end)

-- single-target loop
task.spawn(function()
    while true do
        if killTarg and targetPlayer and targetPlayer.Parent then
            dealDmg(targetPlayer)
            if nanoWhile then setBodyScale(targetPlayer,0.01) end
        end
        RunSrv.Heartbeat:Wait()
    end
end)

-- kill-aura loop (configurable radius)
task.spawn(function()
    while true do
        if killAura then
            local myRoot = getRoot(Player)
            if myRoot then
                for _,v in ipairs(Players:GetPlayers()) do
                    if v~=Player and not isWhitelisted(v) then
                        local tRoot = getRoot(v)
                        if tRoot and (tRoot.Position-myRoot.Position).Magnitude<=killAuraRadius then
                            dealDmg(v)
                        end
                    end
                end
            end
        end
        RunSrv.Heartbeat:Wait()
    end
end)

-- NEW: Auto punch/fast loop
task.spawn(function()
    while true do
        if autoPunchEnabled or autoFastEnabled then
            muscleEvent:FireServer("rep")
            if autoFastEnabled then
                muscleEvent:FireServer("rep") -- Double for fast mode
            end
        end
        task.wait(autoFastEnabled and 0.1 or 0.2) -- Faster interval for fast mode
    end
end)

-- NEW: Anti-fling protection loop
task.spawn(function()
    while true do
        if antiFlingEnabled and Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
            local root = Player.Character.HumanoidRootPart
            local velocity = root.Velocity
            
            -- Detect extreme velocity (fling attempt)
            if velocity.Magnitude > 100 then
                root.Velocity = Vector3.new(0, 0, 0)
                root.RotVelocity = Vector3.new(0, 0, 0)
            end
        end
        RunSrv.Heartbeat:Wait()
    end
end)

-- kill pace calculation
task.spawn(function()
    while true do
        task.wait(60) -- calculate every minute
        if killCount > 0 then
            local elapsed = tick() - killPaceStart
            local killsPerMin = killCount / (elapsed / 60)
            
            table.insert(killPaceHist, {time = tick(), kills = killCount, pace = killsPerMin})
            if #killPaceHist > maxKillHist then table.remove(killPaceHist, 1) end
            
            -- Update kill pace display
            local totalKills = 0
            for _, data in ipairs(killPaceHist) do
                totalKills = totalKills + data.kills
            end
            
            local avgPace = totalKills / (#killPaceHist * 60) * 3600 -- kills per hour
            killPaceLbl.Text = string.format("Kill Pace: %s/h | Total: %s", fmt(avgPace), fmt(killCount))
        end
    end
end)

-- view / unview
local function viewPlayer(p)
    if viewConnection then viewConnection:Disconnect() end
    local cam = workspace.CurrentCamera
    viewConnection = RunSrv.RenderStepped:Connect(function()
        local r = getRoot(p)
        if r then
            cam.CFrame = CFrame.new(r.Position+Vector3.new(0,5,10), r.Position)
        else
            viewConnection:Disconnect(); viewConnection=nil
        end
    end)
end
local function unview()
    if viewConnection then viewConnection:Disconnect(); viewConnection=nil end
    workspace.CurrentCamera.CameraSubject = Player.Character.Humanoid
end

-- UI elements - COMPLETE ENHANCED KILLER TAB
-- Section: Combat Automation
Killer:AddLabel("=== COMBAT AUTOMATION ===")

-- Auto Punch/Fast toggles
Killer:AddToggle("Auto Punch", false, function(v)
    autoPunchEnabled = v
    if v and autoFastEnabled then
        autoFastEnabled = false
    end
end)

Killer:AddToggle("Auto Fast Punch", false, function(v)
    autoFastEnabled = v
    if v and autoPunchEnabled then
        autoPunchEnabled = false
    end
end)

-- Auto whitelist friends toggle
Killer:AddToggle("Auto Whitelist Friends", false, function(v)
    autoWhitelistFriends = v
    if v then
        autoWhitelistFriendsFunc()
    end
end)

-- Section: Protection
Killer:AddLabel("=== PROTECTION ===")

-- Anti knockback/fling toggles
Killer:AddToggle("Anti Knockback", false, function(v)
    antiKnockbackEnabled = v
    if v then
        enableAntiKnockback()
    else
        disableAntiKnockback()
    end
end)

Killer:AddToggle("Anti Fling", false, function(v)
    antiFlingEnabled = v
end)

-- Section: Whitelist Management
Killer:AddLabel("=== WHITELIST MANAGEMENT ===")

-- Whitelist dropdown
local whitelistDropdown = Killer:AddDropdown("Whitelist Player", {}, function(selectedPlayer)
    if selectedPlayer and selectedPlayer ~= "" then
        whitelistedPlayers[selectedPlayer] = true
        whitelistEnabled = true
        whitelistToggle:SetValue(true)
        updateWhitelistDisplay()
    end
end)

-- Update whitelist dropdown options
local function updateWhitelistOptions()
    local playerNames = {}
    for _, v in ipairs(Players:GetPlayers()) do
        if v ~= Player then
            table.insert(playerNames, v.Name)
        end
    end
    whitelistDropdown:RefreshOptions(playerNames)
end

-- Auto refresh player list
Players.PlayerAdded:Connect(updateWhitelistOptions)
Players.PlayerRemoving:Connect(updateWhitelistOptions)

-- Whitelist enabled toggle
local whitelistToggle = Killer:AddToggle("Enable Whitelist", false, function(v)
    whitelistEnabled = v
end)

-- Whitelist display and management
local whitelistDisplay = Killer:AddLabel("Whitelisted: None")

local function updateWhitelistDisplay()
    local names = {}
    for name, _ in pairs(whitelistedPlayers) do
        table.insert(names, name)
    end
    
    if #names > 0 then
        whitelistDisplay.Text = "Whitelisted: " .. table.concat(names, ", ")
    else
        whitelistDisplay.Text = "Whitelisted: None"
    end
end

-- Clear whitelist button
Killer:AddButton("Clear Whitelist", function()
    whitelistedPlayers = {}
    updateWhitelistDisplay()
    whitelistToggle:SetValue(false)
end)

-- Section: Target System
Killer:AddLabel("=== TARGET SYSTEM ===")

-- Auto Kill All toggle
Killer:AddToggle("Auto Kill All", false, function(v) killAll = v end)

-- Auto kill target dropdown
local targetDropdown = Killer:AddDropdown("Select Target", {}, function(selectedPlayer)
    if selectedPlayer and selectedPlayer ~= "" then
        for _, v in ipairs(Players:GetPlayers()) do
            if v.Name == selectedPlayer then
                targetPlayer = v
                targetNameLbl.Text = "Target: " .. selectedPlayer
                break
            end
        end
    end
end)

-- Update target dropdown options
local function updateTargetOptions()
    local playerNames = {}
    for _, v in ipairs(Players:GetPlayers()) do
        if v ~= Player then
            table.insert(playerNames, v.Name)
        end
    end
    targetDropdown:RefreshOptions(playerNames)
end

-- Auto refresh target list
Players.PlayerAdded:Connect(updateTargetOptions)
Players.PlayerRemoving:Connect(updateTargetOptions)

-- Target display
local targetNameLbl = Killer:AddLabel("Target: None")

-- View/Unview controls
Killer:AddButton("View Target", function() 
    if targetPlayer then 
        viewPlayer(targetPlayer) 
    else
        -- Try to get selected target from dropdown
        local selected = targetDropdown:GetValue()
        if selected and selected ~= "" then
            for _, v in ipairs(Players:GetPlayers()) do
                if v.Name == selected then
                    targetPlayer = v
                    viewPlayer(v)
                    break
                end
            end
        end
    end
end)

Killer:AddButton("Unview", unview)

-- Kill target toggle
Killer:AddToggle("Kill Target", false, function(v) killTarg = v end)

-- Section: Area Control
Killer:AddLabel("=== AREA CONTROL ===")

-- Kill aura with configurable radius
Killer:AddToggle("Kill Aura", false, function(v) killAura = v end)

local auraRadiusSlider = Killer:AddSlider("Aura Radius", 25, 5, 100, function(v)
    killAuraRadius = v
end)

-- Section: Special Features
Killer:AddLabel("=== SPECIAL FEATURES ===")

-- NaN size kill while dead
Killer:AddToggle("NaN Size Kill", false, function(v) nanoWhile = v end)

-- Bang players dropdown
local bangDropdown = Killer:AddDropdown("Bang Player", {}, function(selectedPlayer)
    if selectedPlayer and selectedPlayer ~= "" then
        for _, v in ipairs(Players:GetPlayers()) do
            if v.Name == selectedPlayer then
                bangTarget = v
                bangPlayer(v)
                break
            end
        end
    end
end)

-- Update bang dropdown options
local function updateBangOptions()
    local playerNames = {}
    for _, v in ipairs(Players:GetPlayers()) do
        if v ~= Player then
            table.insert(playerNames, v.Name)
        end
    end
    bangDropdown:RefreshOptions(playerNames)
end

-- Stop bang button
Killer:AddButton("Stop Bang", function()
    stopBang()
    bangTarget = nil
end)

-- Kill pace tracking
local killPaceLbl = Killer:AddLabel("Kill Pace: 0/h | Total: 0")

-- Reset kill counter button
Killer:AddButton("Reset Kill Counter", function()
    killCount = 0
    killPaceStart = tick()
    killPaceHist = {}
    killPaceLbl.Text = "Kill Pace: 0/h | Total: 0"
end)

-- Character added connections for anti-knockback
Player.CharacterAdded:Connect(function(char)
    if antiKnockbackEnabled then
        enableAntiKnockback()
    end
end)

-- Initialize player lists
updateWhitelistOptions()
updateTargetOptions()
updateBangOptions()

-- Auto refresh lists periodically
task.spawn(function()
    while true do
        task.wait(30) -- refresh every 30 seconds
        updateWhitelistOptions()
        updateTargetOptions()
        updateBangOptions()
        
        -- Refresh friends whitelist if enabled
        if autoWhitelistFriends then
            autoWhitelistFriendsFunc()
        end
    end
end)
