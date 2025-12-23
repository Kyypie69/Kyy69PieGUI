--[[EleriumV2xKYY (ver.69) - Minified]]
local Library=loadstring(game:HttpGet("https://raw.githubusercontent.com/Kyypie69/Library.UI/refs/heads/main/KYY.luau"))()
local Win=Library.new({MainColor=Color3.fromRGB(138,43,226),ToggleKey=Enum.KeyCode.Insert,MinSize=Vector2.new(450,320),CanResize=false})
local Player=game:GetService("Players").LocalPlayer
local RS=game:GetService("ReplicatedStorage")
local Vim=game:GetService("VirtualInputManager")
local muscleEvent=Player:WaitForChild("muscleEvent")
local ls=Player:WaitForChild("leaderstats")
local rebirths=ls:WaitForChild("Rebirths")
local strength=ls:WaitForChild("Strength")
local durability=Player:WaitForChild("Durability")

-- Helper functions
local function fmt(n)
    n=math.abs(n)
    if n>=1e15 then return string.format("%.2fQa",n/1e15) end
    if n>=1e12 then return string.format("%.2fT",n/1e12) end
    if n>=1e9 then return string.format("%.2fB",n/1e9) end
    if n>=1e6 then return string.format("%.2fM",n/1e6) end
    if n>=1e3 then return string.format("%.2fK",n/1e3) end
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
    unequipAll()
    task.wait(.1)
    local tbl={}
    for _,pet in pairs(Player.petsFolder.Unique:GetChildren()) do
        if pet.Name==name then table.insert(tbl,pet) end
    end
    for i=1,math.min(8,#tbl) do
        RS.rEvents.equipPetEvent:FireServer("equipPet",tbl[i])
    end
end

local function toolActivate(toolName,remoteArg)
    local t=Player.Character:FindFirstChild(toolName) or Player.Backpack:FindFirstChild(toolName)
    if t then muscleEvent:FireServer(remoteArg,t) end
end

local function tpJungleLift()
    local char=Player.Character or Player.CharacterAdded:Wait()
    local r=char:WaitForChild("HumanoidRootPart")
    r.CFrame=CFrame.new(-8642.396,6.798,2086.103)
    task.wait(.2)
    Vim:SendKeyEvent(true,Enum.KeyCode.E,false,game)
    task.wait(.05)
    Vim:SendKeyEvent(false,Enum.KeyCode.E,false,game)
end

local function tpJungleSquat()
    local char=Player.Character or Player.CharacterAdded:Wait()
    local r=char:WaitForChild("HumanoidRootPart")
    r.CFrame=CFrame.new(-8371.434,6.798,2858.885)
    task.wait(.2)
    Vim:SendKeyEvent(true,Enum.KeyCode.E,false,game)
    task.wait(.05)
    Vim:SendKeyEvent(false,Enum.KeyCode.E,false,game)
end

local function antiLag()
    for _,v in pairs(workspace:GetDescendants()) do
        if v:IsA("ParticleEmitter") or v:IsA("PointLight") or v:IsA("SpotLight") or v:IsA("SurfaceLight") then
            v:Destroy()
        end
    end
    local l=game:GetService("Lighting")
    for _,s in pairs(l:GetChildren()) do if s:IsA("Sky") then s:Destroy() end end
    local sky=Instance.new("Sky")
    sky.SkyboxBk="rbxassetid://0"
    sky.SkyboxDn="rbxassetid://0"
    sky.SkyboxFt="rbxassetid://0"
    sky.SkyboxLf="rbxassetid://0"
    sky.SkyboxRt="rbxassetid://0"
    sky.SkyboxUp="rbxassetid://0"
    sky.Parent=l
    l.Brightness=0
    l.ClockTime=0
    l.TimeOfDay="00:00:00"
    l.OutdoorAmbient=Color3.new(0,0,0)
    l.Ambient=Color3.new(0,0,0)
    l.FogColor=Color3.new(0,0,0)
    l.FogEnd=100
end

-- Hide frames
local frameBlockList={"strengthFrame","durabilityFrame","agilityFrame"}
local function hideFrames()
    for _,name in ipairs(frameBlockList) do
        local f=RS:FindFirstChild(name)
        if f and f:IsA("GuiObject") then f.Visible=false end
    end
end
RS.ChildAdded:Connect(function(c)
    if table.find(frameBlockList,c.Name) and c:IsA("GuiObject") then c.Visible=false end
end)

-- KILL3R globals
_G.whitelistedPlayers=_G.whitelistedPlayers or {}
_G.blacklistedPlayers=_G.blacklistedPlayers or {}
_G.killAll=false
_G.killBlacklistedOnly=false
_G.whitelistFriends=false
_G.deathRingEnabled=false
_G.showDeathRing=false
_G.deathRingRange=20

local function checkCharacter()
    if not Player.Character then
        repeat task.wait() until Player.Character
    end
    return Player.Character
end

local function gettool()
    for _,v in pairs(Player.Backpack:GetChildren()) do
        if v.Name=="Punch" and Player.Character:FindFirstChild("Humanoid") then
            Player.Character.Humanoid:EquipTool(v)
        end
    end
    muscleEvent:FireServer("punch","leftHand")
    muscleEvent:FireServer("punch","rightHand")
end

local function isPlayerAlive(player)
    return player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and
           player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health>0
end

local function killPlayer(target)
    if not isPlayerAlive(target) then return end
    local character=checkCharacter()
    if character and character:FindFirstChild("LeftHand") then
        pcall(function()
            firetouchinterest(target.Character.HumanoidRootPart,character.LeftHand,0)
            firetouchinterest(target.Character.HumanoidRootPart,character.LeftHand,1)
            gettool()
        end)
    end
end

local function isWhitelisted(player)
    for _,name in ipairs(_G.whitelistedPlayers) do
        if name:lower()==player.Name:lower() then return true end
    end
    return false
end

local function isBlacklisted(player)
    for _,name in ipairs(_G.blacklistedPlayers) do
        if name:lower()==player.Name:lower() then return true end
    end
    return false
end

local function getPlayerDisplayText(player)
    return player.DisplayName.." | "..player.Name
end

-- Create window and tabs
local Main=Win:CreateWindow("KYY HUB 0.69 | POTANG INA MO 🖕🏻","Markyy")
local RebirthTab=Main:CreateTab("        REB1RTH")
local StrengthTab=Main:CreateTab("      STR3NGTH")
local KillerTab=Main:CreateTab("          KILL3R")
local FarmTab=Main:CreateTab("    REB & R0CK")
local TeleportTab=Main:CreateTab("      TEL3PORT")
local ShopTab=Main:CreateTab("         SH0PEE")
local SpectateTab=Main:CreateTab("   PLAY3R ST4TS")

-- Rebirth tab
local rebStartTime=0
local rebElapsed=0
local rebRunning=false
local rebPaceHist={}
local maxHist=20
local rebCount=0
local lastRebTime=tick()
local lastRebVal=rebirths.Value
local initReb=rebirths.Value

local rebTimeLbl=RebirthTab:AddLabel("0d 0h 0m 0s – Inactive")
local rebPaceLbl=RebirthTab:AddLabel("Pace: 0 /h  |  0 /d  |  0 /w")
local rebAvgLbl=RebirthTab:AddLabel("Average: 0 /h  |  0 /d  |  0 /w")
local rebGainLbl=RebirthTab:AddLabel("Rebirths: "..fmt(initReb).."  |  Gained: 0")

local function updateRebDisp()
    local e=rebRunning and (tick()-rebStartTime+rebElapsed) or rebElapsed
    local d,h,m,s=math.floor(e/86400),math.floor(e%86400/3600),math.floor(e%3600/60),math.floor(e%60)
    rebTimeLbl.Text=string.format("%dd %dh %dm %ds – %s",d,h,m,s,rebRunning and "Rebirthing" or "Paused")
end

local function calcRebPace()
    rebCount=rebCount+1
    if rebCount<2 then lastRebTime=tick(); lastRebVal=rebirths.Value; return end
    local now,gained=tick(),rebirths.Value-lastRebVal
    if gained<=0 then return end
    local t=(now-lastRebTime)/gained
    local ph,pd,pw=3600/t,86400/t,604800/t
    rebPaceLbl.Text=string.format("Pace: %s /h  |  %s /d  |  %s /w",fmt(ph),fmt(pd),fmt(pw))
    table.insert(rebPaceHist,{h=ph,d=pd,w=pw})
    if #rebPaceHist>maxHist then table.remove(rebPaceHist,1) end
    local sumH,sumD,sumW=0,0,0
    for _,v in pairs(rebPaceHist) do sumH=sumH+v.h; sumD=sumD+v.d; sumW=sumW+v.w end
    local n=#rebPaceHist
    rebAvgLbl.Text=string.format("Average: %s /h  |  %s /d  |  %s /w",fmt(sumH/n),fmt(sumD/n),fmt(sumW/n))
    lastRebTime=now
    lastRebVal=rebirths.Value
end

rebirths.Changed:Connect(function()
    calcRebPace()
    rebGainLbl.Text="Rebirths: "..fmt(rebirths.Value).."  |  Gained: "..fmt(rebirths.Value-initReb)
end)

local function doRebirth()
    local target=5000+rebirths.Value*2550
    while rebRunning and strength.Value<target do
        local reps=Player.MembershipType==Enum.MembershipType.Premium and 8 or 14
        for _=1,reps do muscleEvent:FireServer("rep") end
        task.wait(0.02)
    end
    if rebRunning and strength.Value>=target then
        equipEight("Tribal Overlord")
        task.wait(0.25)
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
        rebStartTime=tick()
        rebCount=0
        task.spawn(rebLoop)
    else
        rebElapsed=rebElapsed+(tick()-rebStartTime)
        updateRebDisp()
    end
end)

RebirthTab:AddToggle("Hide Frames",false,function(s) if s then hideFrames() end end)
RebirthTab:AddButton("Anti AFK",function() rebAntiAfkEnabled=false end)
RebirthTab:AddButton("Equip 8× Swift Samurai",function() equipEight("Swift Samurai") end)
RebirthTab:AddButton("Anti Lag",antiLag)

-- Position Lock
local lockConn=nil
local lockEnabled=false
local savedPos=nil
local RunService=game:GetService("RunService")

local function stopLock()
    if lockConn then lockConn:Disconnect() end
    lockConn=nil
    local r=Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
    if r then r.Anchored=false end
end

local function startLock()
    local root=Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    savedPos=root.CFrame
    root.Anchored=true
    lockConn=RunService.Heartbeat:Connect(function()
        local r=Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
        if r then
            r.Anchored=true
            r.CFrame=savedPos
        end
    end)
end

local function updatePosLock(state)
    lockEnabled=state
    if state then startLock() else stopLock() end
end

Player.CharacterAdded:Connect(function(char)
    if lockEnabled then
        stopLock()
        task.wait(.2)
        startLock()
    end
end)

RebirthTab:AddToggle("Lock 69 Position",false,updatePosLock)
RebirthTab:AddButton("TP Jungle Lift",tpJungleLift)

-- Auto protein egg
local eggRunning=false
task.spawn(function()
    while true do
        if eggRunning then toolActivate("Protein Egg","proteinEgg"); task.wait(1800)
        else task.wait(1) end
    end
end)
RebirthTab:AddToggle("Auto Protein Egg",false,function(s)
    eggRunning=s
    if s then toolActivate("Protein Egg","proteinEgg") end
end)

-- Strength tab
local strStart=0
local strElapsed=0
local strRun=false
local track=false
local initStr=strength.Value
local initDur=durability.Value
local strHist={}
local durHist={}
local calcInt=10

local strTimeLbl=StrengthTab:AddLabel("0d 0h 0m 0s – Inactive")
local strPaceLbl=StrengthTab:AddLabel("Str Pace: 0 /h  |  0 /d  |  0 /w")
local durPaceLbl=StrengthTab:AddLabel("Dur Pace: 0 /h  |  0 /d  |  0 /w")
local strAvgLbl=StrengthTab:AddLabel("Avg Str: 0 /h  |  0 /d  |  0 /w")
local durAvgLbl=StrengthTab:AddLabel("Avg Dur: 0 /h  |  0 /d  |  0 /w")
local strGainLbl=StrengthTab:AddLabel("Strength: 0  |  Gained: 0")
local durGainLbl=StrengthTab:AddLabel("Durability: 0  |  Gained: 0")

local function updateStrDisp()
    local e=strRun and (tick()-strStart+strElapsed) or strElapsed
    local d,h,m,s=math.floor(e/86400),math.floor(e%86400/3600),math.floor(e%3600/60),math.floor(e%60)
    strTimeLbl.Text=string.format("%dd %dh %dm %ds – %s",d,h,m,s,strRun and "Running" or "Paused")
end

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
    local n=tonumber(v)
    if n and n>0 then repsPerTick=math.floor(n) end
end)

StrengthTab:AddToggle("Fast Strength",false,function(v)
    strRun=v
    if v then
        strStart=tick()
        track=true
        strHist={}
        durHist={}
        task.spawn(fastRep)
    else
        strElapsed=strElapsed+(tick()-strStart)
        track=false
        updateStrDisp()
    end
end)

StrengthTab:AddToggle("Hide Frames",false,function(s) if s then hideFrames() end end)
StrengthTab:AddButton("Anti AFK",function() strAntiAfkEnabled=false end)
StrengthTab:AddButton("Equip 8× Swift Samurai",function() equipEight("Swift Samurai") end)
StrengthTab:AddButton("Anti Lag",antiLag)
StrengthTab:AddButton("TP Jungle Squat",tpJungleSquat)

-- Auto egg + shake
local shakeRunning=false
local eggRunning2=false
task.spawn(function()
    while true do
        if eggRunning2 then toolActivate("Protein Egg","proteinEgg"); task.wait(1800)
        else task.wait(1) end
    end
end)
task.spawn(function()
    while true do
        if shakeRunning then toolActivate("Tropical Shake","tropicalShake"); task.wait(900)
        else task.wait(1) end
    end
end)
StrengthTab:AddToggle("Auto Protein Egg",false,function(s)
    eggRunning2=s
    if s then toolActivate("Protein Egg","proteinEgg") end
end)
StrengthTab:AddToggle("Auto Tropical Shake",false,function(s)
    shakeRunning=s
    if s then toolActivate("Tropical Shake","tropicalShake") end
end)

-- KILL3R tab
local comboActive=false
local eggLoop,characterAddedConn

local function ensureEggEquipped()
    if not comboActive or not Player.Character then return end
    local eggsInHand=0
    for _,item in ipairs(Player.Character:GetChildren()) do
        if item.Name=="Protein Egg" then
            eggsInHand=1
            if eggsInHand>1 then item.Parent=Player.Backpack end
        end
    end
    if eggsInHand==0 then
        local egg=Player.Backpack:FindFirstChild("Protein Egg")
        if egg then egg.Parent=Player.Character end
    end
end

KillerTab:AddToggle("NaN Punch Combo)",false,function(bool)
    comboActive=bool
    if bool then
        if RS:FindFirstChild("rEvents") and RS.rEvents:FindFirstChild("changeSpeedSizeRemote") then
            local changeSpeedSizeRemote=RS.rEvents.changeSpeedSizeRemote
            changeSpeedSizeRemote:InvokeServer("changeSize",0/0)
        end
        eggLoop=task.spawn(function()
            while comboActive do
                ensureEggEquipped()
                task.wait(0.2)
            end
        end)
        characterAddedConn=Player.CharacterAdded:Connect(function(newChar)
            task.wait(0.5)
            ensureEggEquipped()
        end)
        ensureEggEquipped()
    else
        if eggLoop then task.cancel(eggLoop) end
        if characterAddedConn then characterAddedConn:Disconnect() end
    end
end)

KillerTab:AddButton("Disable Eggs",function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/244ihssp/IlIIS/refs/heads/main/1"))()
end)

-- Player dropdowns
local function createPlayerDropdowns()
    local players=game.Players:GetPlayers()
    local whitelistOptions={}
    local blacklistOptions={}
    for _,player in ipairs(players) do
        if player~=Player then
            local displayText=getPlayerDisplayText(player)
            table.insert(whitelistOptions,displayText)
            table.insert(blacklistOptions,displayText)
        end
    end
    
    local whitelistDropdown=KillerTab:AddDropdown("Add to Whitelist",whitelistOptions,function(selectedText)
        local playerName=selectedText:match("| (.+)$")
        if playerName then
            playerName=playerName:gsub("^%s*(.-)%s*$","%1")
            for _,name in ipairs(_G.whitelistedPlayers) do
                if name:lower()==playerName:lower() then return end
            end
            table.insert(_G.whitelistedPlayers,playerName)
        end
    end)

    local blacklistDropdown=KillerTab:AddDropdown("Add to Kill",blacklistOptions,function(selectedText)
        local playerName=selectedText:match("| (.+)$")
        if playerName then
            playerName=playerName:gsub("^%s*(.-)%s*$","%1")
            for _,name in ipairs(_G.blacklistedPlayers) do
                if name:lower()==playerName:lower() then return end
            end
            table.insert(_G.blacklistedPlayers,playerName)
        end
    end)

    return whitelistDropdown,blacklistDropdown
end

local whitelistDropdown,blacklistDropdown=createPlayerDropdowns()

local function refreshDropdowns()
    local players=game.Players:GetPlayers()
    local whitelistOptions={}
    local blacklistOptions={}
    for _,player in ipairs(players) do
        if player~=Player then
            local displayText=getPlayerDisplayText(player)
            table.insert(whitelistOptions,displayText)
            table.insert(blacklistOptions,displayText)
        end
    end
    whitelistDropdown:UpdateDropdown(whitelistOptions)
    blacklistDropdown:UpdateDropdown(blacklistOptions)
end

game.Players.PlayerAdded:Connect(function()
    task.wait(0.5)
    refreshDropdowns()
end)

game.Players.PlayerRemoving:Connect(function()
    task.wait(0.1)
    refreshDropdowns()
end)

-- Kill toggles
KillerTab:AddToggle("Kill Everyone",false,function(bool)
    _G.killAll=bool
    if bool then
        if not _G.killAllConnection then
            _G.killAllConnection=game:GetService("RunService").Heartbeat:Connect(function()
                if _G.killAll then
                    for _,player in ipairs(game:GetService("Players"):GetPlayers()) do
                        if player~=Player and not isWhitelisted(player) then
                            killPlayer(player)
                        end
                    end
                end
            end)
        end
    else
        if _G.killAllConnection then
            _G.killAllConnection:Disconnect()
            _G.killAllConnection=nil
        end
    end
end)

KillerTab:AddToggle("Whitelist Friends",false,function(bool)
    _G.whitelistFriends=bool
    if bool then
        for _,player in pairs(game.Players:GetPlayers()) do
            if player~=Player and player:IsFriendsWith(Player.UserId) then
                local playerName=player.Name
                local alreadyWhitelisted=false
                for _,name in ipairs(_G.whitelistedPlayers) do
                    if name:lower()==playerName:lower() then
                        alreadyWhitelisted=true
                        break
                    end
                end
                if not alreadyWhitelisted then
                    table.insert(_G.whitelistedPlayers,playerName)
                end
            end
        end
    end
end)

KillerTab:AddToggle("Kill Target",false,function(bool)
    _G.killBlacklistedOnly=bool
    if bool then
        if not _G.blacklistKillConnection then
            _G.blacklistKillConnection=game:GetService("RunService").Heartbeat:Connect(function()
                if _G.killBlacklistedOnly then
                    for _,player in ipairs(game:GetService("Players"):GetPlayers()) do
                        if player~=Player and isBlacklisted(player) then
                            killPlayer(player)
                        end
                    end
                end
            end)
        end
    else
        if _G.blacklistKillConnection then
            _G.blacklistKillConnection:Disconnect()
            _G.blacklistKillConnection=nil
        end
    end
end)

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

local function stopSpectate()
    spectating = false
    targetPlayer = nil
    
    if currentTargetConnection then
        currentTargetConnection:Disconnect()
        currentTargetConnection = nil
    end
    
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

local specdropdown = nil

local function createSpectateDropdown()
    -- Get initial player list
    local players = game.Players:GetPlayers()
    local playerOptions = {}
    
    for _, player in ipairs(players) do
        if player ~= Player then
            table.insert(playerOptions, player.DisplayName .. " | " .. player.Name)
        end
    end
    
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

createSpectateDropdown()

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

-- Death Ring
local ringPart=nil
local ringColor=Color3.fromRGB(50,163,255)
local ringTransparency=0.6

local function updateRingSize()
    if not ringPart then return end
    local diameter=(_G.deathRingRange or 20)*2
    ringPart.Size=Vector3.new(0.2,diameter,diameter)
end

local function toggleRingVisual()
    if _G.showDeathRing then
        ringPart=Instance.new("Part")
        ringPart.Shape=Enum.PartType.Cylinder
        ringPart.Material=Enum.Material.Neon
        ringPart.Color=ringColor
        ringPart.Transparency=ringTransparency
        ringPart.Anchored=true
        ringPart.CanCollide=false
        ringPart.CastShadow=false
        updateRingSize()
        ringPart.Parent=workspace
    elseif ringPart then
        ringPart:Destroy()
        ringPart=nil
    end
end

local function updateRingPosition()
    if not ringPart then return end
    local character=checkCharacter()
    local rootPart=character and character:FindFirstChild("HumanoidRootPart")
    if rootPart then
        ringPart.CFrame=rootPart.CFrame*CFrame.Angles(0,0,math.rad(90))
    end
end

KillerTab:AddTextBox("Death Ring Range (1-140)","20",function(text)
    local range=tonumber(text)
    if range then
        _G.deathRingRange=math.clamp(range,1,140)
        updateRingSize()
    end
end)

KillerTab:AddToggle("Death Ring",false,function(bool)
    _G.deathRingEnabled=bool
    if bool then
        if not _G.deathRingConnection then
            _G.deathRingConnection=game:GetService("RunService").Heartbeat:Connect(function()
                if _G.deathRingEnabled then
                    updateRingPosition()
                    local character=checkCharacter()
                    local myPosition=character and character:FindFirstChild("HumanoidRootPart") and character.HumanoidRootPart.Position
                    if not myPosition then return end
                    for _,player in ipairs(game:GetService("Players"):GetPlayers()) do
                        if player~=Player and not isWhitelisted(player) and isPlayerAlive(player) then
                            local distance=(myPosition-player.Character.HumanoidRootPart.Position).Magnitude
                            if distance<=(_G.deathRingRange or 20) then
                                killPlayer(player)
                            end
                        end
                    end
                end
            end)
        end
    else
        if _G.deathRingConnection then
            _G.deathRingConnection:Disconnect()
            _G.deathRingConnection=nil
        end
    end
end)

KillerTab:AddToggle("Show Death Ring",false,function(bool)
    _G.showDeathRing=bool
    toggleRingVisual()
end)

-- Status labels
local whitelistLabel=KillerTab:AddLabel("Whitelist: None")
local blacklistLabel=KillerTab:AddLabel("Killlist: None")

KillerTab:AddButton("Clear Whitelist",function()
    _G.whitelistedPlayers={}
end)

KillerTab:AddButton("Clear Blacklist",function()
    _G.blacklistedPlayers={}
end)

local function updateWhitelistLabel()
    whitelistLabel.Text=#_G.whitelistedPlayers==0 and "Whitelist: None" or "Whitelist: "..table.concat(_G.whitelistedPlayers,", ")
end

local function updateBlacklistLabel()
    blacklistLabel.Text=#_G.blacklistedPlayers==0 and "Killlist: None" or "Killlist: "..table.concat(_G.blacklistedPlayers,", ")
end

task.spawn(function()
    while true do
        updateWhitelistLabel()
        updateBlacklistLabel()
        task.wait(0.2)
    end
end)

KillerTab:AddButton("Anti AFK",function() print("KILL3R Anti-AFK activated") end)

-- Anti Fling
local antiKnockbackEnabled=false
local antiKnockbackConn=nil

local function applyAntiKnockback(character)
    if not character then return end
    local rootPart=character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end
    local existing=rootPart:FindFirstChild("KYYAntiFling")
    if existing then existing:Destroy() end
    local bodyVelocity=Instance.new("BodyVelocity")
    bodyVelocity.Name="KYYAntiFling"
    bodyVelocity.MaxForce=Vector3.new(100000,0,100000)
    bodyVelocity.Velocity=Vector3.new(0,0,0)
    bodyVelocity.P=1250
    bodyVelocity.Parent=rootPart
end

local function removeAntiKnockback(character)
    if not character then return end
    local rootPart=character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end
    local existing=rootPart:FindFirstChild("KYYAntiFling")
    if existing then existing:Destroy() end
end

local function updateAntiKnockback(state)
    antiKnockbackEnabled=state
    if state then
        if Player.Character then applyAntiKnockback(Player.Character) end
        if antiKnockbackConn then antiKnockbackConn:Disconnect() end
        antiKnockbackConn=Player.CharacterAdded:Connect(function(character)
            task.wait(0.1)
            applyAntiKnockback(character)
        end)
    else
        if antiKnockbackConn then
            antiKnockbackConn:Disconnect()
            antiKnockbackConn=nil
        end
        if Player.Character then removeAntiKnockback(Player.Character) end
    end
end

Player.CharacterRemoving:Connect(function(character)
    if not antiKnockbackEnabled then return end
end)

KillerTab:AddToggle("Anti Knock Back",false,function(bool)
    updateAntiKnockback(bool)
end)

KillerTab:AddLabel("Prevents being flung by other players")

-- Update loops
task.spawn(function()
    while true do
        updateRebDisp()
        task.wait(0.1)
    end
end)

task.spawn(function()
    local lastCalc=tick()
    while true do
        local now=tick()
        updateStrDisp()
        strGainLbl.Text="Strength: "..fmt(strength.Value).."  |  Gained: "..fmt(strength.Value-initStr)
        durGainLbl.Text="Durability: "..fmt(durability.Value).."  |  Gained: "..fmt(durability.Value-initDur)

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

-- Anti-AFK
local Players=game:GetService("Players")
local UIS=game:GetService("UserInputService")
local GuiService=game:GetService("GuiService")
local player=Players.LocalPlayer
local rebAntiAfkEnabled=false
local strAntiAfkEnabled=false
local killerAntiAfkEnabled=false

local gui=Instance.new("ScreenGui",player:WaitForChild("PlayerGui"))
gui.Name="AntiAFKOverlay"

local textLabel=Instance.new("TextLabel",gui)
textLabel.Size=UDim2.new(0,200,0,50)
textLabel.Position=UDim2.new(0.5,-100,0,-50)
textLabel.TextColor3=Color3.fromRGB(50,255,50)
textLabel.Font=Enum.Font.GothamBold
textLabel.TextSize=20
textLabel.BackgroundTransparency=1
textLabel.TextTransparency=1
textLabel.Text="ANTI AFK"

local timerLabel=Instance.new("TextLabel",gui)
timerLabel.Size=UDim2.new(0,200,0,30)
timerLabel.Position=UDim2.new(0.5,-100,0,-20)
timerLabel.TextColor3=Color3.fromRGB(255,255,255)
timerLabel.Font=Enum.Font.GothamBold
timerLabel.TextSize=18
timerLabel.BackgroundTransparency=1
timerLabel.TextTransparency=1
timerLabel.Text="00:00:00"

local startTime=tick()
task.spawn(function()
    while true do
        local elapsed=tick()-startTime
        local h=math.floor(elapsed/3600)
        local m=math.floor((elapsed%3600)/60)
        local s=math.floor(elapsed%60)
        timerLabel.Text=string.format("%02d:%02d:%02d",h,m,s)
        task.wait(1)
    end
end)

task.spawn(function()
    while true do
        for i=0,1,0.01 do
            textLabel.TextTransparency=1-i
            timerLabel.TextTransparency=1-i
            task.wait(0.015)
        end
        task.wait(1.5)
        for i=0,1,0.01 do
            textLabel.TextTransparency=i
            timerLabel.TextTransparency=i
            task.wait(0.015)
        end
        task.wait(0.8)
    end
end)

-- Kill Counter GUI
local killStats={totalKills=0,sessionKills=0,killStreak=0,bestStreak=0,startTime=tick(),lastKillTime=0,killsPerMinute=0,killRate=0,leaderboardKills=0,lastLeaderboardCheck=0}
local playerDeaths={}

local killGui=Instance.new("ScreenGui")
killGui.Name="KillCounterGUI"
killGui.Parent=Player:WaitForChild("PlayerGui")
killGui.Enabled=false

local mainFrame=Instance.new("Frame")
mainFrame.Size=UDim2.new(0,280,0,240)
mainFrame.Position=UDim2.new(0.02,0,0.3,0)
mainFrame.BackgroundColor3=Color3.fromRGB(173,216,230)
mainFrame.BorderSizePixel=2
mainFrame.BorderColor3=Color3.fromRGB(135,206,250)
mainFrame.Active=true
mainFrame.Draggable=true
mainFrame.Parent=killGui

local glowFrame=Instance.new("Frame")
glowFrame.Size=UDim2.new(1,12,1,12)
glowFrame.Position=UDim2.new(0,-6,0,-6)
glowFrame.BackgroundColor3=Color3.fromRGB(173,216,230)
glowFrame.BackgroundTransparency=0.7
glowFrame.BorderSizePixel=0
glowFrame.ZIndex=-1
glowFrame.Parent=mainFrame

local glowCorner=Instance.new("UICorner")
glowCorner.CornerRadius=UDim.new(0,12)
glowCorner.Parent=glowFrame

local corner=Instance.new("UICorner")
corner.CornerRadius=UDim.new(0,8)
corner.Parent=mainFrame

local gradient=Instance.new("UIGradient")
gradient.Color=ColorSequence.new({
    ColorSequenceKeypoint.new(0,Color3.fromRGB(135,206,250)),
    ColorSequenceKeypoint.new(0.5,Color3.fromRGB(173,216,230)),
    ColorSequenceKeypoint.new(1,Color3.fromRGB(135,206,250))
})
gradient.Rotation=45
gradient.Parent=mainFrame

local titleLabel=Instance.new("TextLabel")
titleLabel.Size=UDim2.new(1,0,0,25)
titleLabel.Position=UDim2.new(0,0,0,0)
titleLabel.BackgroundTransparency=1
titleLabel.Text="⚔️ KILL COUNTER ⚔️"
titleLabel.TextColor3=Color3.fromRGB(255,255,255)
titleLabel.Font=Enum.Font.Garamond
titleLabel.TextSize=18
titleLabel.TextStrokeTransparency=0
titleLabel.TextStrokeColor3=Color3.fromRGB(0,100,200)
titleLabel.Parent=mainFrame

-- Add separators and other labels...
local timerLabel=Instance.new("TextLabel")
timerLabel.Size=UDim2.new(1,0,0,20)
timerLabel.Position=UDim2.new(0,0,0,27)
timerLabel.BackgroundTransparency=1
timerLabel.Text="Session: 00:00:00"
timerLabel.TextColor3=Color3.fromRGB(255,255,255)
timerLabel.Font=Enum.Font.Garamond
timerLabel.TextSize=14
timerLabel.TextStrokeTransparency=0.5
timerLabel.TextStrokeColor3=Color3.fromRGB(0,0,0)
timerLabel.Parent=mainFrame

local totalKillsLabel=Instance.new("TextLabel")
totalKillsLabel.Size=UDim2.new(1,0,0,25)
totalKillsLabel.Position=UDim2.new(0,0,0,48)
totalKillsLabel.BackgroundTransparency=1
totalKillsLabel.Text="Total Kills: 0"
totalKillsLabel.TextColor3=Color3.fromRGB(255,255,255)
totalKillsLabel.Font=Enum.Font.Garamond
totalKillsLabel.TextSize=18
totalKillsLabel.TextStrokeTransparency=0.5
totalKillsLabel.TextStrokeColor3=Color3.fromRGB(0,0,0)
totalKillsLabel.Parent=mainFrame

local sessionKillsLabel=Instance.new("TextLabel")
sessionKillsLabel.Size=UDim2.new(1,0,0,20)
sessionKillsLabel.Position=UDim2.new(0,0,0,74)
sessionKillsLabel.BackgroundTransparency=1
sessionKillsLabel.Text="Session Kills: 0"
sessionKillsLabel.TextColor3=Color3.fromRGB(0,255,0)
sessionKillsLabel.Font=Enum.Font.Garamond
sessionKillsLabel.TextSize=14
sessionKillsLabel.TextStrokeTransparency=0.5
sessionKillsLabel.TextStrokeColor3=Color3.fromRGB(0,0,0)
sessionKillsLabel.Parent=mainFrame

local leaderboardLabel=Instance.new("TextLabel")
leaderboardLabel.Size=UDim2.new(1,0,0,20)
leaderboardLabel.Position=UDim2.new(0,0,0,95)
leaderboardLabel.BackgroundTransparency=1
leaderboardLabel.Text="Leaderboard: 0"
leaderboardLabel.TextColor3=Color3.fromRGB(255,215,0)
leaderboardLabel.Font=Enum.Font.Garamond
leaderboardLabel.TextSize=14
leaderboardLabel.TextStrokeTransparency=0.5
leaderboardLabel.TextStrokeColor3=Color3.fromRGB(0,0,0)
leaderboardLabel.Parent=mainFrame

local streakLabel=Instance.new("TextLabel")
streakLabel.Size=UDim2.new(1,0,0,20)
streakLabel.Position=UDim2.new(0,0,0,116)
streakLabel.BackgroundTransparency=1
streakLabel.Text="Streak: 0 | Best: 0"
streakLabel.TextColor3=Color3.fromRGB(255,255,0)
streakLabel.Font=Enum.Font.Garamond
streakLabel.TextSize=14
streakLabel.TextStrokeTransparency=0.5
streakLabel.TextStrokeColor3=Color3.fromRGB(0,0,0)
streakLabel.Parent=mainFrame

local kpmLabel=Instance.new("TextLabel")
kpmLabel.Size=UDim2.new(1,0,0,20)
kpmLabel.Position=UDim2.new(0,0,0,137)
kpmLabel.BackgroundTransparency=1
kpmLabel.Text="KPM: 0.0 | Rate: 0.0/h"
kpmLabel.TextColor3=Color3.fromRGB(0,255,255)
kpmLabel.Font=Enum.Font.Garamond
kpmLabel.TextSize=14
kpmLabel.TextStrokeTransparency=0.5
kpmLabel.TextStrokeColor3=Color3.fromRGB(0,0,0)
kpmLabel.Parent=mainFrame

local lastKillLabel=Instance.new("TextLabel")
lastKillLabel.Size=UDim2.new(1,0,0,20)
lastKillLabel.Position=UDim2.new(0,0,0,158)
lastKillLabel.BackgroundTransparency=1
lastKillLabel.Text="Last Kill: Never"
lastKillLabel.TextColor3=Color3.fromRGB(255,165,0)
lastKillLabel.Font=Enum.Font.Garamond
lastKillLabel.TextSize=14
lastKillLabel.TextStrokeTransparency=0.5
lastKillLabel.TextStrokeColor3=Color3.fromRGB(0,0,0)
lastKillLabel.Parent=mainFrame

local syncStatusLabel=Instance.new("TextLabel")
syncStatusLabel.Size=UDim2.new(1,0,0,20)
syncStatusLabel.Position=UDim2.new(0,0,0,179)
syncStatusLabel.BackgroundTransparency=1
syncStatusLabel.Text="Sync: Waiting..."
syncStatusLabel.TextColor3=Color3.fromRGB(255,255,255)
syncStatusLabel.Font=Enum.Font.Garamond
syncStatusLabel.TextSize=14
syncStatusLabel.TextStrokeTransparency=0.5
syncStatusLabel.TextStrokeColor3=Color3.fromRGB(0,0,0)
syncStatusLabel.Parent=mainFrame

local statusLabel=Instance.new("TextLabel")
statusLabel.Size=UDim2.new(1,0,0,20)
statusLabel.Position=UDim2.new(0,0,0,200)
statusLabel.BackgroundTransparency=1
statusLabel.Text="Status: Idle"
statusLabel.TextColor3=Color3.fromRGB(255,255,255)
statusLabel.Font=Enum.Font.Garamond
statusLabel.TextSize=14
statusLabel.TextStrokeTransparency=0.5
statusLabel.TextStrokeColor3=Color3.fromRGB(0,0,0)
statusLabel.Parent=mainFrame

-- Pulsing glow effect
task.spawn(function()
    while true do
        for i=0,1,0.02 do
            local transparency=0.5+(math.sin(i*math.pi*2)*0.3)
            glowFrame.BackgroundTransparency=transparency
            task.wait(0.05)
        end
    end
end)

local function checkLeaderboardKills()
    local success,kills=pcall(function()
        local leaderstats=Player:FindFirstChild("leaderstats")
        if leaderstats then
            local killsStat=leaderstats:FindFirstChild("Kills") or leaderstats:FindFirstChild("kills") or leaderstats:FindFirstChild("KO") or leaderstats:FindFirstChild("Knockouts")
            if killsStat then return killsStat.Value end
        end
        local stats=Player:FindFirstChild("Stats")
        if stats then
            local killsStat=stats:FindFirstChild("Kills") or stats:FindFirstChild("kills")
            if killsStat then return killsStat.Value end
        end
        local dataFolder=Player:FindFirstChild("DataFolder") or Player:FindFirstChild("data")
        if dataFolder then
            local killsStat=dataFolder:FindFirstChild("Kills") or dataFolder:FindFirstChild("kills")
            if killsStat then return killsStat.Value end
        end
        return 0
    end)
    return success and kills or 0
end

local function setupDeathDetection()
    local function monitorPlayerDeath(otherPlayer)
        if otherPlayer==Player then return end
        local function onCharacterAdded(character)
            local humanoid=character:WaitForChild("Humanoid")
            humanoid.Died:Connect(function()
                local deathTime=tick()
                playerDeaths[otherPlayer.Name]=deathTime
                local myCharacter=Player.Character
                local theirCharacter=otherPlayer.Character
                if myCharacter and theirCharacter then
                    local myRoot=myCharacter:FindFirstChild("HumanoidRootPart")
                    local theirRoot=theirCharacter:FindFirstChild("HumanoidRootPart")
                    if myRoot and theirRoot then
                        local distance=(myRoot.Position-theirRoot.Position).Magnitude
                        if distance<=50 then recordKill(otherPlayer.Name) end
                    end
                end
                if _G.killAll or _G.killBlacklistedOnly or _G.deathRingEnabled then
                    task.wait(0.1)
                    recordKill(otherPlayer.Name)
                end
            end)
        end
        if otherPlayer.Character then onCharacterAdded(otherPlayer.Character) end
        otherPlayer.CharacterAdded:Connect(onCharacterAdded)
    end
    
    for _,otherPlayer in ipairs(game.Players:GetPlayers()) do
        if otherPlayer~=Player then monitorPlayerDeath(otherPlayer) end
    end
    game.Players.PlayerAdded:Connect(function(otherPlayer)
        monitorPlayerDeath(otherPlayer)
    end)
end

task.spawn(function()
    while true do
        local elapsed=tick()-killStats.startTime
        local h=math.floor(elapsed/3600)
        local m=math.floor((elapsed%3600)/60)
        local s=math.floor(elapsed%60)
        timerLabel.Text=string.format("Session: %02d:%02d:%02d",h,m,s)
        
        if killStats.sessionKills>0 then
            local minutes=elapsed/60
            killStats.killsPerMinute=killStats.sessionKills/minutes
            killStats.killRate=killStats.sessionKills/(elapsed/3600)
            kpmLabel.Text=string.format("KPM: %.1f | Rate: %.1f/h",killStats.killsPerMinute,killStats.killRate)
        end
        
        if tick()-killStats.lastLeaderboardCheck>5 then
            local leaderboardKills=checkLeaderboardKills()
            if leaderboardKills>killStats.leaderboardKills then
                killStats.leaderboardKills=leaderboardKills
                leaderboardLabel.Text="Leaderboard: "..killStats.leaderboardKills
                syncStatusLabel.Text="Sync: Updated"
            else
                syncStatusLabel.Text="Sync: Standby"
            end
            killStats.lastLeaderboardCheck=tick()
        end
        task.wait(1)
    end
end)

function recordKill(playerName)
    killStats.totalKills=killStats.totalKills+1
    killStats.sessionKills=killStats.sessionKills+1
    killStats.killStreak=killStats.killStreak+1
    killStats.lastKillTime=tick()
    if killStats.killStreak>killStats.bestStreak then killStats.bestStreak=killStats.killStreak end
    totalKillsLabel.Text="Total Kills: "..killStats.totalKills
    sessionKillsLabel.Text="Session Kills: "..killStats.sessionKills
    streakLabel.Text=string.format("Streak: %d | Best: %d",killStats.killStreak,killStats.bestStreak)
    lastKillLabel.Text="Last Kill: "..playerName
    statusLabel.Text="Status: Kill!"
    syncStatusLabel.Text="Sync: Kill Detected"
    task.wait(3)
    statusLabel.Text="Status: Idle"
    syncStatusLabel.Text="Sync: Standby"
end

Player.CharacterAdded:Connect(function()
    killStats.killStreak=0
    streakLabel.Text=string.format("Streak: %d | Best: %d",killStats.killStreak,killStats.bestStreak)
end)

setupDeathDetection()

KillerTab:AddToggle("Show Kill Counter",false,function(bool)
    killGui.Enabled=bool
end)

KillerTab:AddLabel("Kill Counter Session")

KillerTab:AddButton("Reset Session Stats",function()
    killStats.sessionKills=0
    killStats.killStreak=0
    killStats.startTime=tick()
    sessionKillsLabel.Text="Session Kills: 0"
    streakLabel.Text="Streak: 0 | Best: "..killStats.bestStreak
    kpmLabel.Text="KPM: 0.0 | Rate: 0.0/h"
    statusLabel.Text="Session Reset"
    syncStatusLabel.Text="Sync: Reset"
    task.wait(1)
    statusLabel.Text="Status: Idle"
    syncStatusLabel.Text="Sync: Standby"
end)

KillerTab:AddButton("Sync Leaderboard",function()
    local leaderboardKills=checkLeaderboardKills()
    killStats.leaderboardKills=leaderboardKills
    leaderboardLabel.Text="Leaderboard: "..killStats.leaderboardKills
    syncStatusLabel.Text="Sync: Manual Update"
    task.wait(2)
    syncStatusLabel.Text="Sync: Standby"
end)

-- Farm Tab
FarmTab:AddLabel("Auto Farm Tools")
local SelectedTool=nil
local AutoFarm=false

local toolOptions={"Punch","Weight","Pushups","Situps","Handstands","Stomp","Ground Slam"}
local toolDropdown=FarmTab:AddDropdown("Select Tool",toolOptions,function(Value)
    SelectedTool=Value
end)

local autoFarmSwitch=FarmTab:AddToggle("Auto Farm",false,function(Value)
    AutoFarm=Value
    local player=game:GetService("Players").LocalPlayer
    local muscleEvent=player:WaitForChild("muscleEvent")

    if Value then
        task.spawn(function()
            while AutoFarm do
                if SelectedTool and player.Character then
                    if SelectedTool=="Weight" or SelectedTool=="Pushups" or SelectedTool=="Situps" or SelectedTool=="Handstands" then
                        if not player.Character:FindFirstChild(SelectedTool) then
                            local tool=player.Backpack:FindFirstChild(SelectedTool)
                            if tool then player.Character.Humanoid:EquipTool(tool) end
                        end
                        muscleEvent:FireServer("rep")
                    elseif SelectedTool=="Punch" then
                        local punch=player.Backpack:FindFirstChild("Punch")
                        if punch then
                            punch.Parent=player.Character
                            if punch:FindFirstChild("attackTime") then punch.attackTime.Value=0 end
                        end
                        muscleEvent:FireServer("punch","rightHand")
                        muscleEvent:FireServer("punch","leftHand")
                        if player.Character:FindFirstChild("Punch") then player.Character.Punch:Activate() end
                    elseif SelectedTool=="Stomp" then
                        local stomp=player.Backpack:FindFirstChild("Stomp")
                        if stomp then
                            stomp.Parent=player.Character
                            if stomp:FindFirstChild("attackTime") then stomp.attackTime.Value=0 end
                        end
                        muscleEvent:FireServer("stomp")
                        if player.Character:FindFirstChild("Stomp") then player.Character.Stomp:Activate() end
                    elseif SelectedTool=="Ground Slam" then
                        local groundSlam=player.Backpack:FindFirstChild("Ground Slam")
                        if groundSlam then
                            groundSlam.Parent=player.Character
                            if groundSlam:FindFirstChild("attackTime") then groundSlam.attackTime.Value=0 end
                        end
                        muscleEvent:FireServer("slam")
                        if player.Character:FindFirstChild("Ground Slam") then player.Character["Ground Slam"]:Activate() end
                    end
                end
                task.wait()
            end
        end)
    end
end)

-- Auto Rock Farm
FarmTab:AddLabel("Auto Farm Rock")
local selectedRock=nil
local autoRockRunning=false

local rockData={
    ["Tiny Rock"]=0,
    ["Starter Island"]=100,
    ["Punching Rock"]=1000,
    ["Golden Rock"]=5000,
    ["Frost Rock"]=150000,
    ["Mythical Rock"]=400000,
    ["Eternal Rock"]=750000,
    ["Legend Rock"]=1000000,
    ["Muscle King Rock"]=5000000,
    ["Jungle Rock"]=10000000
}

local rockOptions={}
for rockName in pairs(rockData) do table.insert(rockOptions,rockName) end

local rockDropdown=FarmTab:AddDropdown("Select Rock",rockOptions,function(Value)
    selectedRock=Value
end)

local autoRockToggle=FarmTab:AddToggle("Auto Rock",false,function(Value)
    autoRockRunning=Value
    local player=game:GetService("Players").LocalPlayer

    if Value and selectedRock then
        task.spawn(function()
            local requiredDurability=rockData[selectedRock]
            while autoRockRunning do
                task.wait()
                if player.Durability.Value>=requiredDurability then
                    for _,v in pairs(workspace.machinesFolder:GetDescendants()) do
                        if v.Name=="neededDurability" and v.Value==requiredDurability and
                            player.Character:FindFirstChild("LeftHand") and
                            player.Character:FindFirstChild("RightHand") then

                            local rock=v.Parent:FindFirstChild("Rock")
                            if rock then
                                firetouchinterest(rock,player.Character.RightHand,0)
                                firetouchinterest(rock,player.Character.RightHand,1)
                                firetouchinterest(rock,player.Character.LeftHand,0)
                                firetouchinterest(rock,player.Character.LeftHand,1)
                                gettool()
                            end
                        end
                    end
                end
            end
        end)
    end
end)

-- Auto Rebirth
FarmTab:AddLabel("Auto Rebirth")
local targetRebirths=0
local isAutoRebirthing=false

local rebirthStatusLabel=FarmTab:AddLabel("Current Rebirths: 0")
local rebirthTargetLabel=FarmTab:AddLabel("Target: None")

task.spawn(function()
    while true do
        local rebirths=player.leaderstats:FindFirstChild("Rebirths")
        if rebirths then
            rebirthStatusLabel.Text="Current Rebirths: "..tostring(rebirths.Value)
            rebirthTargetLabel.Text="Target: "..(targetRebirths>0 and tostring(targetRebirths) or "None")
        end
        task.wait(0.5)
    end
end)

FarmTab:AddTextBox("Rebirth Target","Enter number",function(Value)
    targetRebirths=tonumber(Value) or 0
end)

local autoRebirthToggle=FarmTab:AddToggle("Auto Rebirth",false,function(Value)
    isAutoRebirthing=Value
    if Value and targetRebirths>0 then
        task.spawn(function()
            local rebirths=player.leaderstats:WaitForChild("Rebirths")
            local rebirthRemote=game:GetService("ReplicatedStorage").rEvents.rebirthRemote
            
            while isAutoRebirthing do
                local currentRebirths=rebirths.Value
                if currentRebirths>=targetRebirths then
                    autoRebirthToggle:Set(false)
                    break
                end
                
                local success=false
                pcall(function()
                    rebirthRemote:InvokeServer("rebirthRequest")
                    success=true
                end)
                
                if not success then
                    pcall(function()
                        rebirthRemote:InvokeServer("rebirth")
                    end)
                end
                
                if not success then
                    pcall(function()
                        rebirthRemote:FireServer("rebirthRequest")
                    end)
                end
                
                task.wait(0.2)
            end
        end)
    elseif Value and targetRebirths<=0 then
        autoRebirthToggle:Set(false)
    end
end)

-- Teleport Tab
TeleportTab:AddLabel("Main Locations")
TeleportTab:AddButton("Tiny Island",function()
    local char=game:GetService("Players").LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        char.HumanoidRootPart.CFrame=CFrame.new(-37.1,9.2,1919)
    end
end)

TeleportTab:AddButton("Main Island",function()
    local char=game:GetService("Players").LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        char.HumanoidRootPart.CFrame=CFrame.new(16.07,9.08,133.8)
    end
end)

TeleportTab:AddButton("Beach",function()
    local char=game:GetService("Players").LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        char.HumanoidRootPart.CFrame=CFrame.new(-8,9,-169.2)
    end
end)

TeleportTab:AddLabel("Gyms")
TeleportTab:AddButton("Muscle King Gym",function()
    local char=game:GetService("Players").LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        char.HumanoidRootPart.CFrame=CFrame.new(-8665.4,17.21,-5792.9)
    end
end)

TeleportTab:AddButton("Jungle Gym",function()
    local char=game:GetService("Players").LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        char.HumanoidRootPart.CFrame=CFrame.new(-8543,6.8,2400)
    end
end)

TeleportTab:AddButton("Legends Gym",function()
    local char=game:GetService("Players").LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        char.HumanoidRootPart.CFrame=CFrame.new(4516,991.5,-3856)
    end
end)

-- Shop Tab
ShopTab:AddLabel("Pet Shop")
local selectedPet="Darkstar Hunter"
local petOptions={"Darkstar Hunter","Neon Guardian","Blue Pheonix","Crimson Falcon","Cybernetic Showdown Dragon","Dark Golem","Dark Legends Manticore","Eternal Strike Leviathan","Frostwave Legends Penguin","Gold Warrior","Golden Viking","Infernal Dragon","Muscle Sensei"}

local petDropdown=ShopTab:AddDropdown("Select Pet",petOptions,function(Value)
    selectedPet=Value
end)

ShopTab:AddToggle("Auto Buy Pet",false,function(Value)
    while Value and selectedPet do
        local petToOpen=game:GetService("ReplicatedStorage").cPetShopFolder:FindFirstChild(selectedPet)
        if petToOpen then
            game:GetService("ReplicatedStorage").cPetShopRemote:InvokeServer(petToOpen)
        end
        task.wait(0.1)
    end
end)

ShopTab:AddLabel("Aura Shop")
local selectedAura="Entropic Blast"
local auraOptions={"Entropic Blast","Muscle King","Astral Electro","Azure Tundra","Dark Electro","Dark Lightning","Dark Storm","Electro","Enchanted Mirage","Eternal Megastrike","Grand Supernova","Inferno","Lightning","Power Lightning","Purple Nova","Supernova"}

local auraDropdown=ShopTab:AddDropdown("Select Aura",auraOptions,function(Value)
    selectedAura=Value
end)

ShopTab:AddToggle("Auto Buy Aura",false,function(Value)
    while Value and selectedAura do
        local auraToOpen=game:GetService("ReplicatedStorage").cPetShopFolder:FindFirstChild(selectedAura)
        if auraToOpen then
            game:GetService("ReplicatedStorage").cPetShopRemote:InvokeServer(auraToOpen)
        end
        task.wait(0.1)
    end
end)

-- Spectate & Stats Tab
local playerToInspect=nil
local selectedPlayerToSpectate=nil
local spectating=false
local currentTargetConnection=nil

local function updateSpectateTarget(player)
    if currentTargetConnection then
        currentTargetConnection:Disconnect()
        currentTargetConnection=nil
    end
    
    if player and player.Character then
        local humanoid=player.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            camera.CameraSubject=humanoid
            currentTargetConnection=player.CharacterAdded:Connect(function(newChar)
                task.wait(0.2)
                local newHumanoid=newChar:FindFirstChildOfClass("Humanoid")
                if newHumanoid then camera.CameraSubject=newHumanoid end
            end)
        end
    end
end

local function getCurrentPlayers()
    local playersList={}
    for _,p in ipairs(game:GetService("Players"):GetPlayers()) do
        table.insert(playersList,p)
    end
    return playersList
end

SpectateTab:AddLabel("Player Stats")
local playerNameLabel=SpectateTab:AddLabel("Name: N/A")
local playerUsernameLabel=SpectateTab:AddLabel("Username: N/A")

local statDefinitions={
    {name="Strength",statName="Strength"},
    {name="Rebirths",statName="Rebirths"},
    {name="Durability",statName="Durability"},
    {name="Agility",statName="Agility"},
    {name="Kills",statName="Kills"},
    {name="Evil Karma",statName="evilKarma"},
    {name="Good Karma",statName="goodKarma"},
    {name="Brawls",statName="Brawls"}
}

local statLabels={}
for _,info in ipairs(statDefinitions) do
    statLabels[info.name]=SpectateTab:AddLabel(info.name..": 0")
end

local function formatNumber(n)
    if n>=1e15 then return string.format("%.1fqa",n/1e15)
    elseif n>=1e12 then return string.format("%.1ft",n/1e12)
    elseif n>=1e9 then return string.format("%.1fb",n/1e9)
    elseif n>=1e6 then return string.format("%.1fm",n/1e6)
    elseif n>=1e3 then return string.format("%.1fk",n/1e3)
    else return tostring(n) end
end

local function updateStatLabels(targetPlayer)
    if not targetPlayer then return end
    playerNameLabel.Text="Name: "..targetPlayer.DisplayName
    playerUsernameLabel.Text="Username: "..targetPlayer.Name
    local leaderstats=targetPlayer:FindFirstChild("leaderstats")
    if not leaderstats then return end
    for _,info in ipairs(statDefinitions) do
        local statObject=leaderstats:FindFirstChild(info.statName) or targetPlayer:FindFirstChild(info.statName)
        if statObject then
            local value=statObject.Value
            statLabels[info.name].Text=info.name..": "..formatNumber(value)
        else
            statLabels[info.name].Text=info.name..": 0"
        end
    end
end

local playerOptions={}
for _,player in ipairs(getCurrentPlayers()) do
    table.insert(playerOptions,player.DisplayName.." | "..player.Name)
end

local specdropdown=SpectateTab:AddDropdown("Select Player",playerOptions,function(Value)
    for _,player in ipairs(getCurrentPlayers()) do
        local optionText=player.DisplayName.." | "..player.Name
        if Value==optionText then
            playerToInspect=player
            selectedPlayerToSpectate=player
            updateStatLabels(playerToInspect)
            break
        end
    end
end)

SpectateTab:AddToggle("Spectate Player",false,function(Value)
    spectating=Value
    if spectating and selectedPlayerToSpectate then
        updateSpectateTarget(selectedPlayerToSpectate)
    else
        if currentTargetConnection then
            currentTargetConnection:Disconnect()
            currentTargetConnection=nil
        end
        local localPlayer=game:GetService("Players").LocalPlayer
        if localPlayer.Character then
            local humanoid=localPlayer.Character:FindFirstChildOfClass("Humanoid")
            if humanoid then camera.CameraSubject=humanoid end
        end
    end
end)

game:GetService("Players").PlayerAdded:Connect(function(player)
    specdropdown:Add(player.DisplayName.." | "..player.Name)
end)

game:GetService("Players").PlayerRemoving:Connect(function(player)
    if selectedPlayerToSpectate and selectedPlayerToSpectate==player then
        selectedPlayerToSpectate=nil
        playerToInspect=nil
        if spectating then
            local localPlayer=game:GetService("Players").LocalPlayer
            if localPlayer.Character then
                local humanoid=localPlayer.Character:FindFirstChildOfClass("Humanoid")
                if humanoid then camera.CameraSubject=humanoid end
            end
        end
    end
    specdropdown:Clear()
    for _,p in ipairs(getCurrentPlayers()) do
        specdropdown:Add(p.DisplayName.." | "..p.Name)
    end
end)

task.spawn(function()
    while true do
        if playerToInspect then updateStatLabels(playerToInspect) end
        task.wait(0.2)
    end
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
