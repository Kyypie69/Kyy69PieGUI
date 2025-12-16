--[[  EleriumV2xKYY ENHANCED (ver.70)  ]]
local Library = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/Kyypie69/Library.UI/refs/heads/main/KYY.luau"))()

local Win = Library.new({
    MainColor      = Color3.fromRGB(138,43,226),
    ToggleKey      = Enum.KeyCode.Insert,
    MinSize        = Vector2.new(550,400),
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

--------------------------------------------------------------------
--  REAL black-screen: world gone, GUIs stay, sky stays black
--------------------------------------------------------------------
local function antiLag()
    -- 1) destroy every physical instance that the renderer sees
    for _, desc in ipairs(workspace:GetDescendants()) do
        -- skip every kind of GUI so our hub / game menus survive
        if  not desc:IsA("GuiObject")                    and
            not desc:FindFirstChildOfClass("ScreenGui")  and
            not desc:FindFirstChildOfClass("SurfaceGui") and
            not desc:FindFirstChildOfClass("BillboardGui")
        then
            -- anything that can be rendered goes away
            if  desc:IsA("BasePart")        or
                desc:IsA("MeshPart")        or
                desc:IsA("UnionOperation")  or
                desc:IsA("TrussPart")       or
                desc:IsA("CornerWedgePart") or
                desc:IsA("WedgePart")       or
                desc:IsA("SpawnLocation")   or
                desc:IsA("Model")           or
                desc:IsA("Folder")          or
                desc:IsA("ParticleEmitter") or
                desc:IsA("PointLight")      or
                desc:IsA("SpotLight")       or
                desc:IsA("SurfaceLight")    or
                desc:IsA("Sky")             or
                desc:IsA("Decal")           or
                desc:IsA("Texture")
            then
                pcall(function() desc:Destroy() end)
            end
        end
    end

    -- 2) lighting → absolute void
    local l = game:GetService("Lighting")
    for _, sky in ipairs(l:GetChildren()) do
        if sky:IsA("Sky") then sky:Destroy() end
    end
    local blackSky = Instance.new("Sky")
    blackSky.SkyboxBk = "rbxassetid://0"
    blackSky.SkyboxDn = "rbxassetid://0"
    blackSky.SkyboxFt = "rbxassetid://0"
    blackSky.SkyboxLf = "rbxassetid://0"
    blackSky.SkyboxRt = "rbxassetid://0"
    blackSky.SkyboxUp = "rbxassetid://0"
    blackSky.Parent = l

    l.Brightness      = 0
    l.ClockTime       = 0
    l.TimeOfDay       = "00:00:00"
    l.OutdoorAmbient  = Color3.new(0,0,0)
    l.Ambient         = Color3.new(0,0,0)
    l.FogColor        = Color3.new(0,0,0)
    l.FogEnd          = 0
    l.GlobalShadows   = false
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
local Main = Win:CreateWindow("KYY HUB 0.7.0 | ENHANCED KILLER UI","Markyy")
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
--  K1LL3R  –  EleriumV2 style  (replaces old tab)
--------------------------------------------------------
local Players  = game:GetService("Players")
local RunSrv   = game:GetService("RunService")
local Workspace= game:GetService("Workspace")

-- state
local killAll      = false
local killAura     = false
local killBlackOnly= false
local nanoWhile    = false
local removeAnims  = false
local targetPlayer = nil
local spectating   = false
local ringShow     = false
local ringRange    = 20
local ringPart     = nil

-- lists
_G.whitelisted = _G.whitelisted or {}
_G.blacklisted = _G.blacklisted or {}

-- helpers
local function getRoot(p) return p.Character and p.Character:FindFirstChild("HumanoidRootPart") end
local function fmtName(p) return p.DisplayName.." | "..p.Name end
local function alive(p)
    return p.Character and p.Character:FindFirstChildOfClass("Humanoid") and p.Character.Humanoid.Health>0
end
local function whitelisted(p)
    for _,n in ipairs(_G.whitelisted)do if n:lower()==p.Name:lower()then return true end end;return false
end
local function blacklisted(p)
    for _,n in ipairs(_G.blacklisted)do if n:lower()==p.Name:lower()then return true end end;return false
end
local function kill(p)
    if not alive(p)then return end
    local me=Player.Character or Player.CharacterAdded:Wait()
    local hand=me:FindFirstChild("LeftHand")or me:FindFirstChild("RightHand")
    if hand then
        pcall(function()
            firetouchinterest(p.Character.HumanoidRootPart,hand,0)
            firetouchinterest(p.Character.HumanoidRootPart,hand,1)
        end)
    end
    muscleEvent:FireServer("punch","leftHand")
    muscleEvent:FireServer("punch","rightHand")
    if nanoWhile then
        local h=p.Character and p.Character:FindFirstChildOfClass("Humanoid")
        if h then
            for _,s in ipairs({"BodyWidthScale","BodyHeightScale","BodyDepthScale","HeadScale"})do
                local sc=h:FindFirstChild(s)if sc then sc.Value=.01 end
            end
        end
    end
end

-- ring visual
local function updRingSize()if ringPart then ringPart.Size=Vector3.new(.2,ringRange*2,ringRange*2)end end
local function toggleRing()
    if ringShow then
        ringPart=Instance.new("Part")
        ringPart.Shape=Enum.PartType.Cylinder
        ringPart.Material=Enum.Material.Neon
        ringPart.Color=Color3.fromRGB(50,163,255)
        ringPart.Transparency=.6
        ringPart.Anchored=true;ringPart.CanCollide=false;ringPart.CastShadow=false
        updRingSize();ringPart.Parent=Workspace
    elseif ringPart then ringPart:Destroy();ringPart=nil end
end
local function updRingPos()
    if not ringPart then return end
    local r=getRoot(Player)if r then ringPart.CFrame=r.CFrame*CFrame.Angles(0,0,math.rad(90))end
end

-- spectate
local specConn,cam=nil,Workspace.CurrentCamera
local function spectate(p)
    if specConn then specConn:Disconnect()end
    local function set()
        local h=p.Character and p.Character:FindFirstChildOfClass("Humanoid")
        if h then cam.CameraSubject=h end
    end
    set()
    specConn=p.CharacterAdded:Connect(function()wait(.2)set()end)
end
local function unspectate()
    if specConn then specConn:Disconnect();specConn=nil end
    local h=Player.Character and Player.Character:FindFirstChildOfClass("Humanoid")
    if h then cam.CameraSubject=h end
end

-- loops
local function startKillAll()
    while killAll do
        for _,p in ipairs(Players:GetPlayers())do
            if p~=Player and not whitelisted(p)then kill(p)end
        end
        RunSrv.Heartbeat:Wait()
    end
end
local function startKillAura()
    while killAura do
        local myRoot=getRoot(Player)
        if myRoot then
            for _,p in ipairs(Players:GetPlayers())do
                if p~=Player and not whitelisted(p)and alive(p)then
                    local tRoot=getRoot(p)
                    if tRoot and(tRoot.Position-myRoot.Position).Magnitude<=ringRange then kill(p)end
                end
            end
        end
        RunSrv.Heartbeat:Wait()
    end
end
local function startBlackOnly()
    while killBlackOnly do
        for _,p in ipairs(Players:GetPlayers())do
            if p~=Player and blacklisted(p)then kill(p)end
        end
        RunSrv.Heartbeat:Wait()
    end
end
local function startRingPos()
    while ringShow do updRingPos();RunSrv.Heartbeat:Wait()end
end

-- build UI
-- main toggles
Killer:AddToggle("Kill All",false,function(v)
    killAll=v;if v then task.spawn(startKillAll)end
end)
Killer:AddToggle("Kill Aura",false,function(v)
    killAura=v;if v then task.spawn(startKillAura)end
end)
Killer:AddToggle("Nano size while kill",false,function(v)nanoWhile=v end)
Killer:AddToggle("Remove attack animations",false,function(v)removeAnims=v end)--(hook not shown for brevity)

-- whitelist/blacklist
Killer:AddLabel("WHITELIST / BLACKLIST")
local wDrop=Killer:AddDropdown("Add to whitelist",function(txt)
    local name=txt:match("| (.+)$")if name then name=name:gsub("^%s*(.-)%s*$","%1")table.insert(_G.whitelisted,name)end
end)
local bDrop=Killer:AddDropdown("Add to blacklist",function(txt)
    local name=txt:match("| (.+)$")if name then name=name:gsub("^%s*(.-)%s*$","%1")table.insert(_G.blacklisted,name)end
end)
Killer:AddToggle("Kill blacklist only",false,function(v)killBlackOnly=v;if v then task.spawn(startBlackOnly)end end)
Killer:AddToggle("Whitelist friends",false,function(v)
    if v then for _,p in pairs(Players:GetPlayers())do if p~=Player and p:IsFriendsWith(Player.UserId)then table.insert(_G.whitelisted,p.Name)end end end
end)

-- death ring
Killer:AddLabel("DEATH RING")
Killer:AddTextBox("Ring range (1-140)","20",function(t)ringRange=math.clamp(tonumber(t)or 20,1,140)updRingSize()end)
Killer:AddToggle("Show ring",false,function(v)ringShow=v;toggleRing()if v then task.spawn(startRingPos)end end)

-- spectate
Killer:AddLabel("SPECTATE")
local specDrop=Killer:AddDropdown("Spectate player",function(txt)
    for _,p in ipairs(Players:GetPlayers())do if txt==fmtName(p)then targetPlayer=p;if spectating then spectate(p)end break end end
end)
Killer:AddToggle("Spectate",false,function(v)spectating=v;if v and targetPlayer then spectate(targetPlayer)else unspectate()end end)

-- target kill  (DROPDOWN instead of TextBox)
Killer:AddLabel("TARGET KILL")
local tgtDrop=Killer:AddDropdown("Select target",function(txt)
    for _,p in ipairs(Players:GetPlayers())do if txt==fmtName(p)then targetPlayer=p break end end
end)
Killer:AddToggle("Kill target",false,function(v)
    while v and targetPlayer and targetPlayer.Parent do kill(targetPlayer);RunSrv.Heartbeat:Wait()end
end)
Killer:AddButton("View target",function()if targetPlayer then spectate(targetPlayer)end end)
Killer:AddButton("Unview",unspectate)

-- utils
Killer:AddLabel("UTILS")
Killer:AddButton("Clear whitelist",function()_G.whitelisted={}end)
Killer:AddButton("Clear blacklist",function()_G.blacklisted={}end)
Killer:AddButton("Refresh lists",function()
    local t={}for _,p in ipairs(Players:GetPlayers())do if p~=Player then table.insert(t,fmtName(p))end end
    wDrop:Refresh(t);bDrop:Refresh(t);specDrop:Refresh(t);tgtDrop:Refresh(t)
end)

-- fill player lists on load
local list={}for _,p in ipairs(Players:GetPlayers())do if p~=Player then table.insert(list,fmtName(p))end end
wDrop:Refresh(list)bDrop:Refresh(list)specDrop:Refresh(list)tgtDrop:Refresh(list)

-- auto-refresh when players join/leave
Players.PlayerAdded:Connect(function(p)if p~=Player then
    local name=fmtName(p)wDrop:Add(name)bDrop:Add(name)specDrop:Add(name)tgtDrop:Add(name)
end end)
Players.PlayerRemoving:Connect(function(p)if p==targetPlayer then targetPlayer=nil;if spectating then unspectate()end end end)



