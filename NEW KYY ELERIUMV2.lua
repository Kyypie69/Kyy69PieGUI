--[[  EleriumV2xKYY  (ver.69)  ]]
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

-- PASTE INTO COMMAND BAR OR NEW SCRIPT
local lock = false
local con  = nil
local saved = game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame

con = game:GetService("RunService").Heartbeat:Connect(function()
    if not lock then con:Disconnect() return end
    game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = saved
end)

-- turn on/off by typing these two lines in console
-- lock = true     -- freeze
-- lock = false    -- release

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
local KillerTab  = Main:CreateTab("K1LL3R")
local FarmingTab = Main:CreateTab("F4RM1NG")  -- NEW FARMING TAB
local TeleportTab= Main:CreateTab("T3LEPORT") -- NEW TELEPORT TAB
local PetsTab    = Main:CreateTab("P3TS")     -- NEW PETS TAB

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

-- FIXED ANTI-AFK button (rebirth tab)
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

-- NEW: Spin Fortune Wheel
local spinWheelEnabled = false
RebirthTab:AddToggle("Spin Fortune Wheel", false, function(bool)
    spinWheelEnabled = bool
    
    if bool then
        task.spawn(function()
            while spinWheelEnabled do
                pcall(function()
                    RS.rEvents.openFortuneWheelRemote:InvokeServer("openFortuneWheel", RS.fortuneWheelChances["Fortune Wheel"])
                end)
                task.wait(1)
            end
        end)
    end
end)

-- NEW: Change Time
local timeDropdown = RebirthTab:AddDropdown("Change Time", function(selection)
    local lighting = game:GetService("Lighting")
    
    if selection == "Night" then
        lighting.ClockTime = 0
    elseif selection == "Day" then
        lighting.ClockTime = 12
    elseif selection == "Midnight" then
        lighting.ClockTime = 6
    end
end)

timeDropdown:Add("Night")
timeDropdown:Add("Day")
timeDropdown:Add("Midnight")

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

--------------------------------------------------------
--  KILLER TAB - ANTI KNOCKBACK (ANTI FLING)
--------------------------------------------------------

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

--------------------------------------------------------
--  FARMING TAB - AUTO FARM NORMAL
--------------------------------------------------------

-- Auto Lift (Gamepass)
FarmingTab:AddToggle("Auto Lift (Gamepass)", false, function(bool)
    if bool then
        local gamepassFolder = RS.gamepassIds
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
            local gamepassFolder = RS.gamepassIds
            for _, gamepass in pairs(gamepassFolder:GetChildren()) do
                local ownedPass = player.ownedGamepasses:FindFirstChild(gamepass.Name)
                if ownedPass and ownedPass.Value == gamepass.Value then
                    ownedPass:Destroy()
                end
            end
        end
    end
end)

-- Rebirth tracking labels
local rebirthLabel = FarmingTab:AddLabel("Rebirths:")
rebirthLabel.TextSize = 22

local rebirthValueLabel = FarmingTab:AddLabel("Rebirths: 0")
rebirthValueLabel.TextSize = 17

local targetLabel = FarmingTab:AddLabel("Target: None")
targetLabel.TextSize = 17

-- Format number function
local function formatNumber(num)
    local numStr = tostring(num)
    local formatted = ""
    local counter = 0

    for i = #numStr, 1, -1 do
        counter = counter + 1
        formatted = numStr:sub(i, i) .. formatted
        if counter % 3 == 0 and i > 1 then
            formatted = "," .. formatted
        end
    end
    
    return formatted
end

-- Auto Rebirth system
local targetRebirths = 0
local isAutoRebirthing = false
local rebirthSwitch

local function autoRebirth()
    isAutoRebirthing = true
    while isAutoRebirthing and rebirths.Value < targetRebirths do
        RS.rEvents.rebirthRemote:InvokeServer("rebirthRequest")
        task.wait(0.05)
    end
    isAutoRebirthing = false
    if rebirthSwitch then
        rebirthSwitch:Set(false)
    end
end

FarmingTab:AddTextBox("Set Rebirth Target", function(text)
    local val = tonumber(text)
    if val and val >= 0 then
        targetRebirths = val
        print("Target set to:" .. targetRebirths)
    else
        print("Invalid.")
    end
end)

rebirthSwitch = FarmingTab:AddToggle("Auto Rebirth", function(enabled)
    if enabled then
        if targetRebirths > 0 and rebirths.Value < targetRebirths then
            task.spawn(autoRebirth)
        else
            rebirthSwitch:Set(false)
        end
    else
        isAutoRebirthing = false
    end
end)

-- Update rebirth labels
task.spawn(function()
    while true do
        rebirthValueLabel.Text = "Rebirths: " .. formatNumber(rebirths.Value)
        targetLabel.Text = "Target Rebirths: " .. formatNumber(targetRebirths)
        task.wait(0.2)
    end
end)

-- Auto Size 1
local sizeActive = false

local oneswitch = FarmingTab:AddToggle("Auto Size 1", function(bool)
    sizeActive = bool
end)

oneswitch:Set(false)

task.spawn(function()
    while true do
        if sizeActive then
            local character = Player.Character
            if character then
                local humanoid = character:FindFirstChildOfClass("Humanoid")
                if humanoid then
                    muscleEvent:FireServer("changeSize", 1)
                end
            end
        end
        task.wait(0.05)
    end
end)

-- Auto King
local targetPosition = CFrame.new(-8665.4, 17.21, -5792.9)
local teleportActive = false

local autokingswitch = FarmingTab:AddToggle("Auto King", function(enabled)
    teleportActive = enabled
end)

task.spawn(function()
    local char = Player.Character or Player.CharacterAdded:Wait()
    local hrp = char:WaitForChild("HumanoidRootPart")

    while true do
        if teleportActive then
            if (hrp.Position - targetPosition.Position).magnitude > 5 then
                hrp.CFrame = targetPosition
            end
        end
        task.wait(0.05)
    end
end)

-- Tools Section
FarmingTab:AddLabel("Tools:").TextSize = 22

local SelectedTool = nil
local AutoFarm = false

local toolDropdown = FarmingTab:AddDropdown("Select Tool", function(selection)
    SelectedTool = selection
end)
toolDropdown:Add("Weight")
toolDropdown:Add("Pushups")
toolDropdown:Add("Situps")
toolDropdown:Add("Handstands")
toolDropdown:Add("Fast Punch")
toolDropdown:Add("Stomp")
toolDropdown:Add("Ground Slam")

local autoFarmSwitch = FarmingTab:AddToggle("Start", function(enabled)
    AutoFarm = enabled

    if enabled then
        task.spawn(function()
            while AutoFarm do
                if SelectedTool == "Weight" then
                    if not Player.Character:FindFirstChild("Weight") then
                        local weightTool = Player.Backpack:FindFirstChild("Weight")
                        if weightTool then
                            Player.Character.Humanoid:EquipTool(weightTool)
                        end
                    end
                    muscleEvent:FireServer("rep")

                elseif SelectedTool == "Pushups" then
                    if not Player.Character:FindFirstChild("Pushups") then
                        local pushupsTool = Player.Backpack:FindFirstChild("Pushups")
                        if pushupsTool then
                            Player.Character.Humanoid:EquipTool(pushupsTool)
                        end
                    end
                    muscleEvent:FireServer("rep")

                elseif SelectedTool == "Situps" then
                    if not Player.Character:FindFirstChild("Situps") then
                        local situpsTool = Player.Backpack:FindFirstChild("Situps")
                        if situpsTool then
                            Player.Character.Humanoid:EquipTool(situpsTool)
                        end
                    end
                    muscleEvent:FireServer("rep")

                elseif SelectedTool == "Handstands" then
                    if not Player.Character:FindFirstChild("Handstands") then
                        local handstandsTool = Player.Backpack:FindFirstChild("Handstands")
                        if handstandsTool then
                            Player.Character.Humanoid:EquipTool(handstandsTool)
                        end
                    end
                    muscleEvent:FireServer("rep")

                elseif SelectedTool == "Fast Punch" then
                    local punch = Player.Backpack:FindFirstChild("Punch")
                    if punch then
                        punch.Parent = Player.Character
                        if punch:FindFirstChild("attackTime") then
                            punch.attackTime.Value = 0
                        end
                    end
                    muscleEvent:FireServer("punch", "rightHand")
                    muscleEvent:FireServer("punch", "leftHand")

                    if Player.Character:FindFirstChild("Punch") then
                        Player.Character.Punch:Activate()
                    end

                elseif SelectedTool == "Stomp" then
                    local stomp = Player.Backpack:FindFirstChild("Stomp")
                    if stomp then
                        stomp.Parent = Player.Character
                        if stomp:FindFirstChild("attackTime") then
                            stomp.attackTime.Value = 0
                        end
                    end
                    muscleEvent:FireServer("stomp")

                    if Player.Character:FindFirstChild("Stomp") then
                        Player.Character.Stomp:Activate()
                    end

                    if tick() % 6 < 0.1 then
                        local virtualUser = game:GetService("VirtualUser")
                        virtualUser:CaptureController()
                        virtualUser:ClickButton1(Vector2.new(500, 500))
                    end

                elseif SelectedTool == "Ground Slam" then
                    local groundSlam = Player.Backpack:FindFirstChild("Ground Slam")
                    if groundSlam then
                        groundSlam.Parent = Player.Character
                        if groundSlam:FindFirstChild("attackTime") then
                            groundSlam.attackTime.Value = 0
                        end
                    end
                    muscleEvent:FireServer("slam")

                    if Player.Character:FindFirstChild("Ground Slam") then
                        Player.Character["Ground Slam"]:Activate()
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
        if SelectedTool and Player.Character:FindFirstChild(SelectedTool) then
            Player.Character:FindFirstChild(SelectedTool).Parent = Player.Backpack
        end
    end
end)

-- Rocks Section
FarmingTab:AddLabel("Rocks:").TextSize = 22

local function gettool()
    for _, v in pairs(Player.Backpack:GetChildren()) do
        if v.Name == "Punch" and Player.Character:FindFirstChild("Humanoid") then
            Player.Character.Humanoid:EquipTool(v)
        end
    end
    muscleEvent:FireServer("punch", "leftHand")
    muscleEvent:FireServer("punch", "rightHand")
end

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

local selectedRock = nil

local rockDropdown = FarmingTab:AddDropdown("Select Rock", function(selection)
    selectedRock = selection
end)

for rockName in pairs(rockData) do
    rockDropdown:Add(rockName)
end

local autoRockSwitch = FarmingTab:AddToggle("Auto Rock", function(enabled)
    getgenv().RockFarmRunning = enabled

    if enabled and selectedRock then
        task.spawn(function()
            local requiredDurability = rockData[selectedRock]

            while getgenv().RockFarmRunning do
                task.wait()
                if Player.Durability.Value >= requiredDurability then
                    for _, v in pairs(workspace.machinesFolder:GetDescendants()) do
                        if v.Name == "neededDurability" and v.Value == requiredDurability and
                            Player.Character:FindFirstChild("LeftHand") and
                            Player.Character:FindFirstChild("RightHand") then

                            local rock = v.Parent:FindFirstChild("Rock")
                            if rock then
                                firetouchinterest(rock, Player.Character.RightHand, 0)
                                firetouchinterest(rock, Player.Character.RightHand, 1)
                                firetouchinterest(rock, Player.Character.LeftHand, 0)
                                firetouchinterest(rock, Player.Character.LeftHand, 1)
                                gettool()
                            end
                        end
                    end
                end
            end
        end)
    end
end)

-- Machines Section
FarmingTab:AddLabel("Machines:").TextSize = 22

local selectedLocation = nil
local selectedWorkout = nil
local working = false
local workoutTypeDropdown
local machineDropdown
local repTask = nil

local function pressE()
    local vim = game:GetService("VirtualInputManager")
    vim:SendKeyEvent(true, "E", false, game)
    task.wait(0.1)
    vim:SendKeyEvent(false, "E", false, game)
end

local function autoLift()
    while working and task.wait() do
        muscleEvent:FireServer("rep")
    end
end

local function stopAutoLift()
    if repTask then
        repTask:Cancel()  
        repTask = nil
    end
end

local function teleportAndStart(machineName, position)
    local char = Player.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        char.HumanoidRootPart.CFrame = position
        task.wait(0.5)
        pressE()
        if working then
            repTask = task.spawn(autoLift)
        end
    end
end

local workoutPositions = {
    ["Bench Press"] = {
        ["Jungle Gym"] = CFrame.new(-8173, 64, 1898),
        ["Muscle King Gym"] = CFrame.new(-8590.06152, 46.0167427, -6043.34717),
        ["Legend Gym"] = CFrame.new(4111.91748, 1020.46674, -3799.97217)
    },
    ["Squat"] = {
        ["Jungle Gym"] = CFrame.new(-8352, 34, 2878),
        ["Muscle King Gym"] = CFrame.new(-8940.12402, 13.1642084, -5699.13477),
        ["Legend Gym"] = CFrame.new(4304.99023, 987.829956, -4124.2334)
    },
    ["Pull Up"] = {
        ["Jungle Gym"] = CFrame.new(-8666, 34, 2070),
        ["Muscle King Gym"] = CFrame.new(-8940.12402, 13.1642084, -5699.13477),
        ["Legend Gym"] = CFrame.new(4304.99023, 987.829956, -4124.2334)
    },
    ["Boulder"] = {
        ["Jungle Gym"] = CFrame.new(-8621, 34, 2684),
        ["Muscle King Gym"] = CFrame.new(-8940.12402, 13.1642084, -5699.13477),
        ["Legend Gym"] = CFrame.new(4304.99023, 987.829956, -4124.2334)
    }
}

local workoutLocations = {
    "Jungle Gym", "Muscle King Gym", "Legend Gym"
}

FarmingTab:AddToggle("Start", function(enabled)
    working = enabled

    if enabled then
        if selectedLocation and selectedWorkout and workoutPositions[selectedWorkout][selectedLocation] then
            teleportAndStart(selectedWorkout, workoutPositions[selectedWorkout][selectedLocation])
        end
    else
        stopAutoLift()
    end
end)

local locationDropdown = FarmingTab:AddDropdown("Gym", function(location)
    selectedLocation = location

    if machineDropdown then
        machineDropdown:Clear()
    end

    if location == "Jungle Gym" then
        machineDropdown = FarmingTab:AddDropdown("Machine", function(machine)
            selectedWorkout = machine
        end)
        machineDropdown:Add("Bench Press")
        machineDropdown:Add("Squat")
        machineDropdown:Add("Pull Up")
        machineDropdown:Add("Boulder")
    elseif location == "Muscle King Gym" then
        machineDropdown = FarmingTab:AddDropdown("Machine", function(machine)
            selectedWorkout = machine
        end)
        machineDropdown:Add("Bench Press")
        machineDropdown:Add("Squat")
        machineDropdown:Add("Pull Up")
        machineDropdown:Add("Boulder")
    elseif location == "Legend Gym" then
        machineDropdown = FarmingTab:AddDropdown("Machine", function(machine)
            selectedWorkout = machine
        end)
        machineDropdown:Add("Bench Press")
        machineDropdown:Add("Squat")
        machineDropdown:Add("Pull Up")
        machineDropdown:Add("Boulder")
    end
end)

for _, location in ipairs(workoutLocations) do
    locationDropdown:Add(location)
end

--------------------------------------------------------
--  TELEPORT / SHOP TAB
--------------------------------------------------------

TeleportTab:AddLabel("Main:").TextSize = 22

TeleportTab:AddButton("Tiny Island",function()
    local char = Player.Character or Player.CharacterAdded:Wait()
    local hrp = char:WaitForChild("HumanoidRootPart")
    hrp.CFrame = CFrame.new(-37.1, 9.2, 1919)
end)

TeleportTab:AddButton("Main Island",function()
    local char = Player.Character or Player.CharacterAdded:Wait()
    local hrp = char:WaitForChild("HumanoidRootPart")
    hrp.CFrame = CFrame.new(16.07, 9.08, 133.8)
end)

TeleportTab:AddButton("Beach",function()
    local char = Player.Character or Player.CharacterAdded:Wait()
    local hrp = char:WaitForChild("HumanoidRootPart")
    hrp.CFrame = CFrame.new(-8, 9, -169.2)
end)

TeleportTab:AddLabel("Gyms:").TextSize = 22

TeleportTab:AddButton("Muscle King Gym",function()
    local char = Player.Character or Player.CharacterAdded:Wait()
    local hrp = char:WaitForChild("HumanoidRootPart")
    hrp.CFrame = CFrame.new(-8665.4, 17.21, -5792.9)
end)

TeleportTab:AddButton("Jungle Gym",function()
    local char = Player.Character or Player.CharacterAdded:Wait()
    local hrp = char:WaitForChild("HumanoidRootPart")
    hrp.CFrame = CFrame.new(-8543, 6.8, 2400)
end)

TeleportTab:AddButton("Legends Gym",function()
    local char = Player.Character or Player.CharacterAdded:Wait()
    local hrp = char:WaitForChild("HumanoidRootPart")
    hrp.CFrame = CFrame.new(4516, 991.5, -3856)
end)

TeleportTab:AddButton("Infernal Gym",function()
    local char = Player.Character or Player.CharacterAdded:Wait()
    local hrp = char:WaitForChild("HumanoidRootPart")
    hrp.CFrame = CFrame.new(-6759, 7.36, -1284)
end)

TeleportTab:AddButton("Mythical Gym",function()
    local char = Player.Character or Player.CharacterAdded:Wait()
    local hrp = char:WaitForChild("HumanoidRootPart")
    hrp.CFrame = CFrame.new(2250, 7.37, 1073.2)
end)

TeleportTab:AddButton("Frost Gym",function()
    local char = Player.Character or Player.CharacterAdded:Wait()
    local hrp = char:WaitForChild("HumanoidRootPart")
    hrp.CFrame = CFrame.new(-2623, 7.36, -409)
end)

--------------------------------------------------------
--  PETS TAB
--------------------------------------------------------

PetsTab:AddLabel("Pets:").TextSize = 22

local selectedPet = "Darkstar Hunter"
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

PetsTab:AddToggle("Buy Pet", function(bool)
    _G.AutoHatchPet = bool
    if bool then
        task.spawn(function()
            while _G.AutoHatchPet do
                pcall(function()
                    local petToOpen = RS.cPetShopFolder:FindFirstChild(selectedPet)
                    if petToOpen then
                        RS.cPetShopRemote:InvokeServer(petToOpen)
                    end
                end)
                task.wait(0.1)
            end
        end)
    end
end)

PetsTab:AddLabel("Auras:").TextSize = 22

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

PetsTab:AddToggle("Buy Aura", function(bool)
    _G.AutoHatchAura = bool
    
    if bool then
        task.spawn(function()
            while _G.AutoHatchAura do
                pcall(function()
                    local auraToOpen = RS.cPetShopFolder:FindFirstChild(selectedAura)
                    if auraToOpen then
                        RS.cPetShopRemote:InvokeServer(auraToOpen)
                    end
                end)
                task.wait(0.1)
            end
        end)
    end
end)

--------------------------------------------------------
--  ANTI-AFK  (universal, shared by Rebirth & Strength)
--------------------------------------------------------
local Players            = game:GetService("Players")
local UIS                = game:GetService("UserInputService")
local GuiService         = game:GetService("GuiService")

local player             = Players.LocalPlayer
local rebAntiAfkEnabled  = false   -- toggled in Rebirth tab
local strAntiAfkEnabled  = false   -- toggled in Strength tab

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
