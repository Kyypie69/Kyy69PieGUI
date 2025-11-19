local LIB_URL = "https://raw.githubusercontent.com/Kyypie69/Library.UI/refs/heads/main/KyypieUI.lua"
local ok, a, b, c = pcall(function()
    local source = game:HttpGet(LIB_URL)
    return loadstring(source)()
end)
local Library, SaveManager, InterfaceManager
if ok then
    Library, SaveManager, InterfaceManager = a, b, c
else
    if getgenv and getgenv().Fluent then
        Library = getgenv().Fluent
        warn("Loaded library from getgenv().Fluent as fallback.")
    else
        error("Failed to load UI library from URL: " .. tostring(a))
    end
end


local Window = Library:CreateWindow({
    Title = " KYYPIE HUB ",
    SubTitle = "Version 6.9 | by Markyy",
    Size = UDim2.fromOffset(500, 300),
    TabWidth = 150,
    Theme = "DarkBlue",
    Acrylic = false,
})

--  TABS  --------------------------------------------------------------------
local Home        = Window:AddTab({ Title = "Home / Packs",     Icon = "home" })
local viewStats   = Window:AddTab({ Title = "Stats",            Icon = "pie-chart" })
local farmingTab  = Window:AddTab({ Title = "Farming",          Icon = "leaf" })
local Rebirths    = Window:AddTab({ Title = "Rebirths",         Icon = "repeat" })
local Killer      = Window:AddTab({ Title = "Killer",           Icon = "target" })
local Shop        = Window:AddTab({ Title = "Crystals",         Icon = "shopping-cart" })
local Misc        = Window:AddTab({ Title = "Miscellaneous",    Icon = "menu" })
local Settings    = Window:AddTab({ Title = "Settings",         Icon = "save" })
------------------------------------------------------------------------------

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Stats = game:GetService("Stats")
local LocalPlayer = Players.LocalPlayer
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")

local PET_NAME = "Swift Samurai"
local ROCK_NAME = "Rock5M"
local PROTEIN_EGG_NAME = "ProteinEgg"
local PROTEIN_EGG_INTERVAL = 30 * 60
local REPS_PER_CYCLE = 180
local REP_DELAY = 0.003
local ROCK_INTERVAL = 5
local MAX_PING = 1100

local HumanoidRootPart
local lastProteinEggTime = 0
local lastRockTime = 0
local RockRef = workspace:FindFirstChild(ROCK_NAME)
local autoEatEnabled = false
local darkSky

local function getPing()
	local success, ping = pcall(function()
		return Stats.Network.ServerStatsItem["Data Ping"]:GetValue()
	end)
	return success and ping or 999
end

local function updateCharacterRefs()
	local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
	HumanoidRootPart = character:WaitForChild("HumanoidRootPart", 5)
end

local function eatProteinEgg()
    if LocalPlayer:FindFirstChild("Backpack") then
        for _, item in pairs(LocalPlayer.Backpack:GetChildren()) do
            if item.Name == PROTEIN_EGG_NAME then
                ReplicatedStorage.rEvents.eatEvent:FireServer("eat", item)
                break
            end
        end
    end
end

local function unequipAllPets(a, c)
    local f = c:FindFirstChild("petsFolder")
    if not f then return end
    for _, folder in pairs(f:GetChildren()) do
        if folder:IsA("Folder") then
            for _, pet in pairs(folder:GetChildren()) do
                a.rEvents.equipPetEvent:FireServer("unequipPet", pet)
            end
        end
    end
    task.wait(0.1)
end

local function equipPetByName(a, c, name)
    local folderPets = c:FindFirstChild("petsFolder")
    if not folderPets then return end
    for _, folder in pairs(folderPets:GetChildren()) do
        if folder:IsA("Folder") then
            for _, pet in pairs(folder:GetChildren()) do
                if pet.Name == name then
                    a.rEvents.equipPetEvent:FireServer("equipPet", pet)
                end
            end
        end
    end
end

local function getStrengthRequiredForRebirth(c)
    local rebirths = c.leaderstats.Rebirths.Value
    local baseStrength = 10000 + (5000 * rebirths)
    
    local g = c:FindFirstChild("ultimatesFolder")
    local golden = 0
    if g and g:FindFirstChild("Golden Rebirth") then
        golden = g["Golden Rebirth"].Value
    end
    
    if golden >= 1 and golden <= 5 then
        baseStrength = baseStrength * (1 - golden * 0.1)
    end
    return math.floor(baseStrength)
end

local function hitRock()
    if not RockRef or not RockRef.Parent then
        RockRef = workspace:FindFirstChild(ROCK_NAME)
    end
    if RockRef and HumanoidRootPart then
        HumanoidRootPart.CFrame = RockRef.CFrame * CFrame.new(0, 0, -5)
        ReplicatedStorage.rEvents.hitEvent:FireServer("hit", RockRef)
    end
end

if not getgenv()._AutoRepFarmLoop then
    getgenv()._AutoRepFarmLoop = true

    task.spawn(function()
        updateCharacterRefs()
        
        lastProteinEggTime = tick()
        lastRockTime = tick()
        
        while true do
            if getgenv()._AutoRepFarmEnabled then
                local ping = getPing()
                
                if ping > MAX_PING then
                    task.wait(5)
                else
                    if LocalPlayer:FindFirstChild("muscleEvent") then
                        for i = 1, REPS_PER_CYCLE do
                            LocalPlayer.muscleEvent:FireServer("rep")
                            task.wait(REP_DELAY) 
                        end
                    end
                    
                    if not autoEatEnabled and tick() - lastProteinEggTime >= PROTEIN_EGG_INTERVAL then
                        eatProteinEgg()
                        lastProteinEggTime = tick()
                    end

                    if tick() - lastRockTime >= ROCK_INTERVAL then
                        hitRock()
                        lastRockTime = tick()
                    end
                end
            else
                task.wait(1)
            end
        end
    end)
end

task.spawn(function()
    while true do
        if autoEatEnabled then
            eatProteinEgg()
            task.wait(1800)
        else
            task.wait(1)
        end
    end
end)


--============================================================================
--  TAB 1  –  HOME / PACKS
--============================================================================
Home:AddButton({
    Title = "KYYY Discord Link",
	Description = "PRESS TO COPYCAT!",
    Callback = function()
        setclipboard("https://discord.gg/u5tNN8tZcY")
        Library:Notify({Title = "Copied!", Content = "Discord link copied to clipboard.", Duration = 3})
    end
})

local Players     = game:GetService("Players")
local VirtualUser = game:GetService("VirtualUser")
local player      = Players.LocalPlayer

Home:AddButton({
    Title = "Anti-AFK",
    Description = "Prevents Idle Kick.",
    Callback = function()

        -- Destroy any old GUI we might have made
        local old = player:FindFirstChildOfClass("PlayerGui"):FindFirstChild("AntiAfkGui")
        if old then old:Destroy() end

        local gui = Instance.new("ScreenGui")
        gui.Name = "AntiAfkGui"
        gui.Parent = player:FindFirstChildOfClass("PlayerGui")

        -- Main label
        local textLabel = Instance.new("TextLabel")
        textLabel.Size = UDim2.new(0, 200, 0, 50)
        textLabel.Position = UDim2.new(0.5, -100, 0, -50)
        textLabel.TextColor3 = Color3.fromRGB(50, 255, 50)
        textLabel.Font = Enum.Font.GothamBold
        textLabel.TextSize = 20
        textLabel.BackgroundTransparency = 1
        textLabel.TextTransparency = 1
        textLabel.Text = "ANTI AFK"
        textLabel.Parent = gui

        -- Timer label
        local timerLabel = Instance.new("TextLabel")
        timerLabel.Size = UDim2.new(0, 200, 0, 30)
        timerLabel.Position = UDim2.new(0.5, -100, 0, -20)
        timerLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        timerLabel.Font = Enum.Font.GothamBold
        timerLabel.TextSize = 18
        timerLabel.BackgroundTransparency = 1
        timerLabel.TextTransparency = 1
        timerLabel.Text = "00:00:00"
        timerLabel.Parent = gui

        local startTime = tick()

        -- Update timer every second
        task.spawn(function()
            while gui.Parent do
                local elapsed = tick() - startTime
                local h = math.floor(elapsed / 3600)
                local m = math.floor(elapsed % 3600 / 60)
                local s = math.floor(elapsed % 60)
                timerLabel.Text = string.format("%02d:%02d:%02d", h, m, s)
                task.wait(1)
            end
        end)

        -- Fade in / fade out loop
        task.spawn(function()
            while gui.Parent do
                for i = 0, 1, 0.01 do
                    textLabel.TextTransparency   = 1 - i
                    timerLabel.TextTransparency  = 1 - i
                    task.wait(0.015)
                end
                task.wait(1.5)
                for i = 0, 1, 0.01 do
                    textLabel.TextTransparency   = i
                    timerLabel.TextTransparency  = i
                    task.wait(0.015)
                end
                task.wait(0.8)
            end
        end)

        -- Idle kick bypass
        player.Idled:Connect(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new())
            print("AFK prevention completed!")
        end)

        print("Anti-AFK enabled.")
    end
})


Home:AddToggle("ANTI LAG", {
    Title       = "Anti Lag",
    Description = "Removes effects & lighting to boost FPS",
    Default     = false,
    Callback    = function(State)
        local lighting = game:GetService("Lighting")
        local LocalPlayer = game:GetService("Players").LocalPlayer

        if State then
            -- wipe existing guis
            for _, gui in pairs(LocalPlayer.PlayerGui:GetChildren()) do
                if gui:IsA("ScreenGui") then gui:Destroy() end
            end

            -- wipe particles / lights
            for _, obj in pairs(workspace:GetDescendants()) do
                if obj:IsA("ParticleEmitter") or obj:IsA("PointLight")
                   or obj:IsA("SpotLight") or obj:IsA("SurfaceLight") then
                    obj:Destroy()
                end
            end

            -- wipe skies
            for _, v in pairs(lighting:GetChildren()) do
                if v:IsA("Sky") then v:Destroy() end
            end

            -- create dark sky
            local darkSky = Instance.new("Sky")
            darkSky.Name = "DarkSky"
            for _, face in {"SkyboxBk","SkyboxDn","SkyboxFt","SkyboxLf","SkyboxRt","SkyboxUp"} do
                darkSky[face] = "rbxassetid://0"
            end
            darkSky.Parent = lighting

            -- lighting settings
            lighting.Brightness      = 0
            lighting.ClockTime       = 0
            lighting.TimeOfDay       = "00:00:00"
            lighting.OutdoorAmbient  = Color3.new(0,0,0)
            lighting.Ambient         = Color3.new(0,0,0)
            lighting.FogColor        = Color3.new(0,0,0)
            lighting.FogEnd          = 100

            -- sky respawn loop
            task.spawn(function()
                while State do
                    task.wait(5)
                    if not lighting:FindFirstChild("DarkSky") then
                        darkSky:Clone().Parent = lighting
                    end
                end
            end)
        else
            -- restore default sky if desired (optional)
            if lighting:FindFirstChild("DarkSky") then
                lighting.DarkSky:Destroy()
            end
            -- reset any other lighting values here if you want
        end
    end
})

-- Lock Position
Home:AddToggle("LockPosition", {
    Title = "Lock Position",
	Description = "The Man Who Can't Be Move",
    Default = false,
    Callback = function(state)
        if state then
            local currentPos = game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame
            getgenv().posLock = game:GetService("RunService").Heartbeat:Connect(function()
                local hrp = game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if hrp then hrp.CFrame = currentPos end
            end)
        else
            if getgenv().posLock then getgenv().posLock:Disconnect(); getgenv().posLock = nil end
        end
    end
})

Home:AddButton({
    Title = "Jungle Squat",
    Description = "Teleport",
    Callback = function()
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            char:SetPrimaryPartCFrame(CFrame.new(-8374.25586, 34.5933418, 2932.44995))

            local machine = workspace:FindFirstChild("machinesFolder")
            if machine and machine:FindFirstChild("Jungle Squat") then
                local seat = machine["Jungle Squat"]:FindFirstChild("interactSeat")
                if seat then
                    game:GetService("ReplicatedStorage").rEvents.machineInteractRemote:InvokeServer("useMachine", seat)
                end
            end
        end
    end
})

Home:AddButton({
    Title = "Equip 8× Swift Samurai",
    Description = "Equips up to 8 Swift Samurai",
    Callback = function()
        local LocalPlayer       = game:GetService("Players").LocalPlayer
        local ReplicatedStorage = game:GetService("ReplicatedStorage")
        local petsFolder        = LocalPlayer:FindFirstChild("petsFolder")
        if not petsFolder then return end

        -- 1. Unequip everything
        for _, folder in pairs(petsFolder:GetChildren()) do
            if folder:IsA("Folder") then
                for _, pet in pairs(folder:GetChildren()) do
                    ReplicatedStorage.rEvents.equipPetEvent:FireServer("unequipPet", pet)
                end
            end
        end
        task.wait(0.1)

        -- 2. Equip up to 8 Swift Samurai
        local equipped = 0
        local maxEquip = 8
        for _, folder in pairs(petsFolder:GetChildren()) do
            if folder:IsA("Folder") then
                for _, pet in pairs(folder:GetChildren()) do
                    if pet.Name == "Swift Samurai" and equipped < maxEquip then
                        ReplicatedStorage.rEvents.equipPetEvent:FireServer("equipPet", pet)
                        equipped = 1
                        print("Equipped Swift Samurai #" .. equipped)
                    end
                end
            end
        end
    end
})

local packSection = Home:AddSection("PACKS FARM REBIRTH")

packSection:AddToggle("Packs Farm", {
    Title = "230K+ per day",
	Description = "BUGGED AS OF NOW",
    Default = false,
    Callback = function(state)
    getgenv().AutoFarming = state
    if state then
        task.spawn(function()
            local a = ReplicatedStorage
            local c = LocalPlayer
            local function equipPetByName(name)
                local folderPets = c:FindFirstChild("petsFolder")
                if not folderPets then return end
                for _, folder in pairs(folderPets:GetChildren()) do
                    if folder:IsA("Folder") then
                        for _, pet in pairs(folder:GetChildren()) do
                            if pet.Name == name then
                                a.rEvents.equipPetEvent:FireServer("equipPet", pet)
                            end
                        end
                    end
                end
            end
            local function unequipAllPets()
                local f = c:FindFirstChild("petsFolder")
                if not f then return end
                for _, folder in pairs(f:GetChildren()) do
                    if folder:IsA("Folder") then
                        for _, pet in pairs(folder:GetChildren()) do
                            a.rEvents.equipPetEvent:FireServer("unequipPet", pet)
                        end
                    end
                end
                task.wait(0.1)
            end
            local function getGoldenRebirthCount()
                local g = c:FindFirstChild("ultimatesFolder")
                if g and g:FindFirstChild("Golden Rebirth") then
                    return g["Golden Rebirth"].Value
                end
                return 0
            end
            local function getStrengthRequiredForRebirth()
                local rebirths = c.leaderstats.Rebirths.Value
                local baseStrength = 10000 + (5000 * rebirths)
                local golden = getGoldenRebirthCount()
                if golden >= 1 and golden <= 5 then
                    baseStrength = baseStrength * (1 - golden * 0.1)
                end
                return math.floor(baseStrength)
            end
            while getgenv().AutoFarming do
                local requiredStrength = getStrengthRequiredForRebirth()
                unequipAllPets()
                equipPetByName("Swift Samurai")
                while c.leaderstats.Strength.Value < requiredStrength and getgenv().AutoFarming do
                    for _ = 1, 10 do
                        c.muscleEvent:FireServer("rep")
                    end
                    task.wait()
                end
                if getgenv().AutoFarming then
                    unequipAllPets()
                    equipPetByName("Tribal Overlord")
                    local oldRebirths = c.leaderstats.Rebirths.Value
                    repeat
                        a.rEvents.rebirthRemote:InvokeServer("rebirthRequest")
                        task.wait(0.1)
                    until c.leaderstats.Rebirths.Value > oldRebirths or not getgenv().AutoFarming
                end
                task.wait()
            end
        end)
    end
end})


packSection:AddToggle("Packs Farm", {
    Title = "FAST REBIRTHS",
	Description = "Auto Switch Samurai & Overlord.",
    Default = false,
    Callback = function(state)
    getgenv().AutoFarming = state
    if state then
        task.spawn(function()
            local a = ReplicatedStorage
            local c = LocalPlayer
            local function equipPetByName(name)
                local folderPets = c:FindFirstChild("petsFolder")
                if not folderPets then return end
                for _, folder in pairs(folderPets:GetChildren()) do
                    if folder:IsA("Folder") then
                        for _, pet in pairs(folder:GetChildren()) do
                            if pet.Name == name then
                                a.rEvents.equipPetEvent:FireServer("equipPet", pet)
                            end
                        end
                    end
                end
            end
            local function unequipAllPets()
                local f = c:FindFirstChild("petsFolder")
                if not f then return end
                for _, folder in pairs(f:GetChildren()) do
                    if folder:IsA("Folder") then
                        for _, pet in pairs(folder:GetChildren()) do
                            a.rEvents.equipPetEvent:FireServer("unequipPet", pet)
                        end
                    end
                end
                task.wait(0.1)
            end
            local function getGoldenRebirthCount()
                local g = c:FindFirstChild("ultimatesFolder")
                if g and g:FindFirstChild("Golden Rebirth") then
                    return g["Golden Rebirth"].Value
                end
                return 0
            end
            local function getStrengthRequiredForRebirth()
                local rebirths = c.leaderstats.Rebirths.Value
                local baseStrength = 10000 + (5000 * rebirths)
                local golden = getGoldenRebirthCount()
                if golden >= 1 and golden <= 5 then
                    baseStrength = baseStrength * (1 - golden * 0.01)
                end
                return math.floor(baseStrength)
            end
            while getgenv().AutoFarming do
                local requiredStrength = getStrengthRequiredForRebirth()
                unequipAllPets()
                equipPetByName("Swift Samurai")
                while c.leaderstats.Strength.Value < requiredStrength and getgenv().AutoFarming do
                    for _ = 1, 10 do
                        c.muscleEvent:FireServer("rep")
                    end
                    task.wait()
                end
                if getgenv().AutoFarming then
                    unequipAllPets()
                    equipPetByName("Tribal Overlord")
                    local oldRebirths = c.leaderstats.Rebirths.Value
                    repeat
                        a.rEvents.rebirthRemote:InvokeServer("rebirthRequest")
                        task.wait(0.01)
                    until c.leaderstats.Rebirths.Value > oldRebirths or not getgenv().AutoFarming
                end
                task.wait()
            end
        end)
    end
end})

local fastSection = Home:AddSection("PACKS FARM STRENGTH")

local player = game.Players.LocalPlayer
local muscleEvent = player:WaitForChild("muscleEvent")
local runFastRep = false
local repsPerTick = 1

local RepSpeedDropdown = fastSection:AddDropdown("FastRep_Speed", {
	Title = "Rep Speed",
	Description = "Choose how many reps per tick (1–30)",
	Values = {},
	Default = "1",
	Callback = function(value)
		repsPerTick = tonumber(value) or 1
	end,
})

-- Fill dropdown values dynamically
for i = 1, 30 do
	table.insert(RepSpeedDropdown.Values, tostring(i))
end
RepSpeedDropdown:SetValue("1") -- Set default display value

-- Fast Rep Loop Function
local function fastRepLoop()
	while runFastRep do
		for i = 1, repsPerTick do
			muscleEvent:FireServer("rep")
		end
		task.wait(0.02)
	end
end

-- Fast Rep Toggle
fastSection:AddToggle("FastRep_Toggle", {
	Title = "Fast Rep Strength",
	Description = "Rapidly Grind Stats",
	Default = false,
	Callback = function(state)
		runFastRep = state
		if runFastRep then
			task.spawn(fastRepLoop)
		end
	end,
})

fastSection:AddToggle("FAST STRENGTH", {
    Title = "Fast Strength",
	Description = "Farm OP Strength.",
    Default = false,
    Callback = function(v)
        getgenv()._AutoRepFarmEnabled = v
    end
})

local otherSection = Home:AddSection("OTHERS")

-- Session Stats UI
local player = game.Players.LocalPlayer
local ls = player:WaitForChild("leaderstats")
local strengthStat = ls:WaitForChild("Strength")
local rebirthsStat = ls:WaitForChild("Rebirths")
local durabilityStat = player:WaitForChild("Durability")
local killsStat = ls:WaitForChild("Kills")
local agilityStat = player:WaitForChild("Agility")

-- NEW COLOURS
local WHITE        = Color3.fromRGB(255, 255, 255)   -- keep for anything you DON’T want rainbow
local NAVY_BLUE    = Color3.fromRGB(30, 58, 138)     -- main background
local RAINBOW_SPEED = 2                              -- seconds per full cycle

-- RAINBOW TEXT ----------------------------------------------------------
local function RAINBOW_TEXT()          -- call every frame you want rainbow
    local hue = (tick()/RAINBOW_SPEED)%1
    return Color3.fromHSV(hue,0.7,1)   -- same saturation/brightness as title-bar
end
-------------------------------------------------------------------------

local function AbbrevNumber(num)
    local abbrev = {"", "K", "M", "B", "T", "Qa", "Qi"}
    local i = 1
    while num >= 1000 and i < #abbrev do
        num = num / 1000; i = i + 1
    end
    return string.format("%.2f%s", num, abbrev[i])
end


local screenGui = Instance.new("ScreenGui")
screenGui.Name = "StatsUI"
screenGui.Parent = player:WaitForChild("PlayerGui")
screenGui.Enabled = false

local main = Instance.new("Frame")
main.Size = UDim2.new(0, 500, 0, 350)
main.Position = UDim2.new(0.5, -250, 0.5, -175)
main.BackgroundColor3 = NAVY_BLUE
main.BorderSizePixel = 0
main.Parent = screenGui
main.Active = true
main.Draggable = true

local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 30)
titleBar.BackgroundColor3 = Color3.new(1,1,1)   -- placeholder, will be rainbow
titleBar.Parent = main

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 1, 0)
title.BackgroundTransparency = 1
title.Text = "Session Stats"
title.TextColor3 = WHITE
title.Font = Enum.Font.SourceSansBold
title.TextSize = 20
title.Parent = titleBar

local scroll = Instance.new("ScrollingFrame")
scroll.Size = UDim2.new(1, 0, 1, -30)
scroll.Position = UDim2.new(0, 0, 0, 30)
scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
scroll.ScrollBarThickness = 8
scroll.BackgroundTransparency = 1
scroll.Parent = main

local uiList = Instance.new("UI List Layout")
uiList.SortOrder = Enum.SortOrder.LayoutOrder
uiList.Padding = UDim.new(0, 5)
uiList.Parent = scroll

local function AddLabel(text, size)
    local lab = Instance.new("TextLabel")
    lab.Size = UDim2.new(1, -10, 0, size + 5)
    lab.BackgroundTransparency = 1
    lab.Text = text
    lab.TextColor3 = RAINBOW_TEXT()   -- RAINBOW
    lab.Font = Enum.Font.SourceSans
    lab.TextSize = size
    lab.TextXAlignment = Enum.TextXAlignment.Center
    lab.TextYAlignment = Enum.TextYAlignment.Center
    lab.Parent = scroll
    return lab
end

local function AddButton(text, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -10, 0, 30)
    btn.BackgroundColor3 = NAVY_BLUE
    btn.TextColor3 = RAINBOW_TEXT()   -- RAINBOW
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 18
    btn.TextXAlignment = Enum.TextXAlignment.Center
    btn.TextYAlignment = Enum.TextYAlignment.Center
    btn.Parent = scroll
    btn.MouseButton1Click:Connect(callback)
    return btn
end

AddLabel("Session Stats", 24)
local stopwatchLabel = AddLabel("Start Time: 0d 0h 0m 0s", 18)
local customTimerLabel = AddLabel("Timer: Not started", 18)

local isCustomRunning = false
local customStart = 0
local customElapsed = 0

AddButton("Start/Stop Timer", function()
    if not isCustomRunning then
        isCustomRunning = true
        customStart = tick() - customElapsed
    else
        isCustomRunning = false
        customElapsed = tick() - customStart
    end
end)

AddButton("Reset Timer", function()
    isCustomRunning = false
    customStart = 0
    customElapsed = 0
    customTimerLabel.Text = "Custom Timer: Not started"
end)

local resetSession = false
AddButton("Reset Session Stats", function() resetSession = true end)

AddLabel("------------------", 14)
AddLabel("Player Rebirth Stats", 24)
local projectedStrengthLabel = AddLabel("Strength Pace: -", 18)
local projectedDurabilityLabel = AddLabel("Durability Pace: -", 18)
local projectedRebirthsLabel = AddLabel("Rebirth Pace: -", 18)

AddLabel("------------------", 14)
AddLabel("Leaderboard Stats", 24)
local strengthLabel = AddLabel("Strength: -", 18)
local rebirthsLabel = AddLabel("Rebirths: -", 18)
local killsLabel = AddLabel("Kills: -", 18)

AddLabel("------------------", 14)
AddLabel("Player Farm Stats", 24)
local projectedStrengthLabel = AddLabel("Strength Pace: -", 18)
local durabilityLabel = AddLabel("Durability: -", 18)
local agilityLabel = AddLabel("Agility: -", 18)

local startTime = tick()
local initialStrength = strengthStat.Value
local initialDurability = durabilityStat.Value
local initialRebirths = rebirthsStat.Value
local initialKills = killsStat.Value
local initialAgility = agilityStat.Value

-- Rainbow title-bar loop
task.spawn(function()
    while true do
        local hue = (tick() / RAINBOW_SPEED) % 1
        titleBar.BackgroundColor3 = Color3.fromHSV(hue, 0.7, 1)
        task.wait(0.05)
    end
end)

-- Main update loop
task.spawn(function()
    local lastUpdate = 0
    while task.wait(0.2) do
        local elapsedTime = tick() - startTime
        local days = math.floor(elapsedTime / (24 * 3600))
        local hours = math.floor((elapsedTime % (24 * 3600)) / 3600)
        local minutes = math.floor((elapsedTime % 3600) / 60)
        local seconds = math.floor(elapsedTime % 60)
        stopwatchLabel.Text = string.format("Session Time: %dd %dh %dm %ds", days, hours, minutes, seconds)

        if isCustomRunning then
            customElapsed = tick() - customStart
        end
        if customElapsed > 0 then
            local d = math.floor(customElapsed / (24 * 3600))
            local h = math.floor((customElapsed % (24 * 3600)) / 3600)
            local m = math.floor((customElapsed % 3600) / 60)
            local s = math.floor(customElapsed % 60)
            customTimerLabel.Text = string.format("Custom Timer: %dd %dh %dm %ds", d, h, m, s)
        end

        if resetSession then
            startTime = tick()
            initialStrength = strengthStat.Value
            initialDurability = durabilityStat.Value
            initialRebirths = rebirthsStat.Value
            initialKills = killsStat.Value
            initialAgility = agilityStat.Value
            resetSession = false
        end

        local cStr = strengthStat.Value
        local cReb = rebirthsStat.Value
        local cDur = durabilityStat.Value
        local cKills = killsStat.Value
        local cAgi = agilityStat.Value

        local dStr = cStr - initialStrength
        local dDur = cDur - initialDurability
        local dReb = cReb - initialRebirths
        local dKills = cKills - initialKills
        local dAgi = cAgi - initialAgility

        strengthLabel.Text = "Strength: " .. AbbrevNumber(cStr) .. " | +" .. AbbrevNumber(dStr)
        rebirthsLabel.Text = "Rebirths: " .. AbbrevNumber(cReb) .. " | +" .. AbbrevNumber(dReb)
        killsLabel.Text = "Kills: " .. AbbrevNumber(cKills) .. " | +" .. AbbrevNumber(dKills)
        durabilityLabel.Text = "Durability: " .. AbbrevNumber(cDur) .. " | +" .. AbbrevNumber(dDur)
        agilityLabel.Text = "Agility: " .. AbbrevNumber(cAgi) .. " | +" .. AbbrevNumber(dAgi)

        if tick() - lastUpdate >= 6 then
            lastUpdate = tick()
            local sSec = dStr / elapsedTime
            local dSec = dDur / elapsedTime
            local rSec = dReb / elapsedTime
            local h, d = 3600, 86400
            projectedStrengthLabel.Text = "Strength Pace: " .. AbbrevNumber(math.floor(sSec * h)) .. "/h | " .. AbbrevNumber(math.floor(sSec * d)) .. "/d"
            projectedDurabilityLabel.Text = "Durability Pace: " .. AbbrevNumber(math.floor(dSec * h)) .. "/h | " .. AbbrevNumber(math.floor(dSec * d)) .. "/d"
            projectedRebirthsLabel.Text = "Rebirth Pace: " .. AbbrevNumber(math.floor(rSec * h)) .. "/h | " .. AbbrevNumber(math.floor(rSec * d)) .. "/d"
        end

        scroll.CanvasSize = UDim2.new(0, 0, 0, uiList.AbsoluteContentSize.Y + 10)

        -- update rainbow text every frame
        for _,obj in ipairs(scroll:GetChildren()) do
            if obj:IsA("TextLabel") or obj:IsA("TextButton") then
                obj.TextColor3 = RAINBOW_TEXT()
            end
        end
    end
end)

otherSection:AddToggle("ShowStats", {
    Title = "Show Stats",
    Default = false,
    Callback = function(state)
        screenGui.Enabled = state
    end
})

-- Block Rebirths
otherSection:AddButton({
    Title = "Block Rebirths",
    Callback = function()
        local old
        old = hookmetamethod(game, "__namecall", function(self, ...)
            local args = { ... }
            if self.Name == "rebirthRemote" and args[1] == "rebirthRequest" then
                return
            end
            return old(self, unpack(args))
        end)
    end,
})

-- Block Trades
otherSection:AddButton({
    Title = "Block Trades",
    Callback = function()
        game:GetService("ReplicatedStorage").rEvents.tradingEvent:FireServer("disableTrading")
    end,
})

-- Inicializar variables de seguimiento
local sessionStartTime = os.time()
local sessionStartStrength = 0
local sessionStartDurability = 0
local sessionStartKills = 0
local sessionStartRebirths = 0
local sessionStartBrawls = 0
local hasStartedTracking = false

-- Crear una carpeta en farmPlusTab para estadísticas
local statSection = viewStats:AddSection("Stats")

-- Crear etiquetas para las estadísticas solicitadas
statSection:AddLabel("Strength")
local strengthStatsLabel = viewStats:AddLabel("Actual: Waiting...")
local strengthGainLabel = viewStats:AddLabel("Gained: 0")

statSection:AddLabel("Durability")
local durabilityStatsLabel = viewStats:AddLabel("Actual: Waiting...")
local durabilityGainLabel = viewStats:AddLabel("Gained: 0")

statSection:AddLabel("Rebirths")
local rebirthsStatsLabel = viewStats:AddLabel("Actual: Waiting...")
local rebirthsGainLabel = viewStats:AddLabel("Gained: 0")

statSection:AddLabel("Brawls")
local brawlsStatsLabel = viewStats:AddLabel("Actual: Waiting...")
local brawlsGainLabel = viewStats:AddLabel("Gained: 0")

statSection:AddLabel("Time Of Session")
local sessionTimeLabel = viewStats:AddLabel("Time: 00:00:00")

statSection:AddLabel("Kills")
local killsStatsLabel = viewStats:AddLabel("Actual: Waiting...")
local killsGainLabel = viewStats:AddLabel("Gained: 0")

-- Función para formatear números
local function formatNumber(number)
    if number >= 1e15 then return string.format("%.2fQ", number/1e15)
    elseif number >= 1e12 then return string.format("%.2fT", number/1e12)
    elseif number >= 1e9 then return string.format("%.2fB", number/1e9)
    elseif number >= 1e6 then return string.format("%.2fM", number/1e6)
    elseif number >= 1e3 then return string.format("%.2fK", number/1e3)
    end
    return tostring(math.floor(number))
end

local function formatNumberWithCommas(number)
    local formatted = tostring(math.floor(number))
    local k
    while true do
        formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
        if k == 0 then break end
    end
    return formatted
end

local function formatTime(seconds)
    local days = math.floor(seconds / 86400)
    local hours = math.floor((seconds % 86400) / 3600)
    local minutes = math.floor((seconds % 3600) / 60)
    local secs = seconds % 60
    
    if days > 0 then
        return string.format("%dd %02dh %02dm %02ds", days, hours, minutes, secs)
    else
        return string.format("%02d:%02d:%02d", hours, minutes, secs)
    end
end

-- Inicializar seguimiento
local function startTracking()
    if not hasStartedTracking then
        local player = game.Players.LocalPlayer
        sessionStartStrength = player.leaderstats.Strength.Value
        sessionStartDurability = player.Durability.Value
        sessionStartKills = player.leaderstats.Kills.Value
        sessionStartRebirths = player.leaderstats.Rebirths.Value
        sessionStartBrawls = player.leaderstats.Brawls.Value
        sessionStartTime = os.time()
        hasStartedTracking = true
    end
end

-- Función para actualizar estadísticas
local function updateStats()
    local player = game.Players.LocalPlayer
    
    -- Iniciar seguimiento si aún no ha comenzado
    if not hasStartedTracking then
        startTracking()
    end
    
    -- Calcular valores actuales y ganancias
    local currentStrength = player.leaderstats.Strength.Value
    local currentDurability = player.Durability.Value
    local currentKills = player.leaderstats.Kills.Value
    local currentRebirths = player.leaderstats.Rebirths.Value
    local currentBrawls = player.leaderstats.Brawls.Value
    
    local strengthGain = currentStrength - sessionStartStrength
    local durabilityGain = currentDurability - sessionStartDurability
    local killsGain = currentKills - sessionStartKills
    local rebirthsGain = currentRebirths - sessionStartRebirths
    local brawlsGain = currentBrawls - sessionStartBrawls
    
    -- Actualizar valores de estadísticas actuales
    strengthStatsLabel.Text = string.format("Actual: %s", formatNumber(currentStrength))
    durabilityStatsLabel.Text = string.format("Actual: %s", formatNumber(currentDurability))
    rebirthsStatsLabel.Text = string.format("Actual: %s", formatNumber(currentRebirths))
    killsStatsLabel.Text = string.format("Actual: %s", formatNumber(currentKills))
    brawlsStatsLabel.Text = string.format("Actual: %s", formatNumber(currentBrawls))
    
    -- Actualizar valores de ganancias
    strengthGainLabel.Text = string.format("Gained: %s", formatNumber(strengthGain))
    durabilityGainLabel.Text = string.format("Gained: %s", formatNumber(durabilityGain))
    rebirthsGainLabel.Text = string.format("Gained: %s", formatNumber(rebirthsGain))
    killsGainLabel.Text = string.format("Gained: %s", formatNumber(killsGain))
    brawlsGainLabel.Text = string.format("Gained: %s", formatNumber(brawlsGain))
    
    -- Actualizar tiempo de sesión
    local elapsedTime = os.time() - sessionStartTime
    local timeString = formatTime(elapsedTime)
    sessionTimeLabel.Text = string.format("Time: %s", timeString)
end

-- Actualizar estadísticas inicialmente
updateStats()

-- Actualizar estadísticas cada 2 segundos
spawn(function()
    while wait(2) do
        updateStats()
    end
end)

-- Agregar botones para funcionalidades adicionales
statSection:AddButton(
	Title = "Reset",
    Callback = function()
    local player = game.Players.LocalPlayer
    sessionStartStrength = player.leaderstats.Strength.Value
    sessionStartDurability = player.Durability.Value
    sessionStartKills = player.leaderstats.Kills.Value
    sessionStartRebirths = player.leaderstats.Rebirths.Value
    sessionStartBrawls = player.leaderstats.Brawls.Value
    sessionStartTime = os.time()
    
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Statistics Tracking",
        Text = "Session progress tracking has been reset!",
        Duration = 0
    })
end)

statSection:AddButton(
	Title = "Copy Stats",
    Callback = function()
    local player = game.Players.LocalPlayer
    local statsText = "Statistics of Muscle Legends:\n\n"
    
    statsText = statsText .. "Strength: " .. formatNumberWithCommas(player.leaderstats.Strength.Value) .. "\n"
    statsText = statsText .. "Durability: " .. formatNumberWithCommas(player.Durability.Value) .. "\n"
    statsText = statsText .. "Rebirths: " .. formatNumberWithCommas(player.leaderstats.Rebirths.Value) .. "\n"
    statsText = statsText .. "Kills: " .. formatNumberWithCommas(player.leaderstats.Kills.Value) .. "\n"
    statsText = statsText .. "Brawls: " .. formatNumberWithCommas(player.leaderstats.Brawls.Value) .. "\n\n"
    
    -- Agregar estadísticas de sesión si el seguimiento ha comenzado
    if hasStartedTracking then
        local elapsedTime = os.time() - sessionStartTime
        local strengthGain = player.leaderstats.Strength.Value - sessionStartStrength
        local durabilityGain = player.Durability.Value - sessionStartDurability
        local killsGain = player.leaderstats.Kills.Value - sessionStartKills
        local rebirthsGain = player.leaderstats.Rebirths.Value - sessionStartRebirths
        local brawlsGain = player.leaderstats.Brawls.Value - sessionStartBrawls
        
        statsText = statsText .. "--- Session Statistics ---\n"
        statsText = statsText .. "Time Of Session: " .. formatTime(elapsedTime) .. "\n"
        statsText = statsText .. "Strength Gained: " .. formatNumberWithCommas(strengthGain) .. "\n"
        statsText = statsText .. "Durability Gained: " .. formatNumberWithCommas(durabilityGain) .. "\n"
        statsText = statsText .. "Rebirths Gained: " .. formatNumberWithCommas(rebirthsGain) .. "\n"
        statsText = statsText .. "Kills Gained: " .. formatNumberWithCommas(killsGain) .. "\n"
        statsText = statsText .. "Brawls Gained: " .. formatNumberWithCommas(brawlsGain) .. "\n"
    end
    
    setclipboard(statsText)
end)

--============================================================================
--  TAB 2  –  FARMING
--============================================================================
local mainSection   = farmingTab:AddSection("Auto Farming")

--MAIN
mainSection:AddParagraph({
    Title = "Auto Machines",
    Content = "Select Gym",
})

local workoutPositions = {
    ["Jungle Gym - Jungle Bench Press"] = CFrame.new(-8173, 64, 1898),
    ["Jungle Gym - Jungle Squat"] = CFrame.new(-8352, 34, 2878),
    ["Jungle Gym - Jungle Pull Ups"] = CFrame.new(-8666, 34, 2070),
    ["Jungle Gym - Jungle Boulder"] = CFrame.new(-8621, 34, 2684),
    ["Eternal Gym - Bench Press"] = CFrame.new(-7176.19141, 45.394104, -1106.31421),
    ["Legend Gym - Bench Press"] = CFrame.new(4111.91748, 1020.46674, -3799.97217),
    ["Muscle King Gym - Bench Press"] = CFrame.new(-8590.06152, 46.0167427, -6043.34717),
    ["Eternal Gym - Squat"] = CFrame.new(-7176.19141, 45.394104, -1106.31421),
    ["Legend Gym - Squat"] = CFrame.new(4304.99023, 987.829956, -4124.2334),
    ["Muscle King Gym - Squat"] = CFrame.new(-8940.12402, 13.1642084, -5699.13477),
    ["Eternal Gym - Deadlift"] = CFrame.new(-7176.19141, 45.394104, -1106.31421),
    ["Legend Gym - Deadlift"] = CFrame.new(4304.99023, 987.829956, -4124.2334),
    ["Muscle King Gym - Deadlift"] = CFrame.new(-8940.12402, 13.1642084, -5699.13477),
    ["Eternal Gym - Pull Up"] = CFrame.new(-7176.19141, 45.394104, -1106.31421),
    ["Legend Gym - Pull Up"] = CFrame.new(4304.99023, 987.829956, -4124.2334),
    ["Muscle King Gym - Pull Up"] = CFrame.new(-8940.12402, 13.1642084, -5699.13477)
}

local machineValues = {}
for name, _ in pairs(workoutPositions) do
    table.insert(machineValues, name)
end

local selectedMachine = nil
mainSection:AddDropdown("Farming_Machine", {
    Title = "Select Machine",
    Description = "Choose to Farm",
    Values = machineValues,
    Default = machineValues[1],
    Callback = function(val) selectedMachine = val end,
})

getgenv().working = false
local function pressE()
    local VIM = game:GetService("VirtualInputManager")
    if VIM and VIM.SendKeyEvent then
        pcall(function()
            VIM:SendKeyEvent(true, "E", false, game)
            task.wait(0.1)
            VIM:SendKeyEvent(false, "E", false, game)
        end)
    end
end
local function autoLift()
    while getgenv().working do
        pcall(function()
            if game.Players.LocalPlayer and game.Players.LocalPlayer:FindFirstChild("muscleEvent") then
                game.Players.LocalPlayer.muscleEvent:FireServer("rep")
            end
        end)
        task.wait()
    end
end
local function teleportAndStart(cf)
    local char = game.Players.LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        char.HumanoidRootPart.CFrame = cf
        task.wait(0.1)
        pressE()
        task.spawn(autoLift)
    end
end

mainSection:AddToggle("Farming_StartMachine", {
    Title = "Start Auto Machine",
    Default = false,
    Description = "Teleport to the Machine and Start Workout",
    Callback = function(state)
        if getgenv().working and not state then
            getgenv().working = false
            return
        end
        getgenv().working = state
        if state and selectedMachine and workoutPositions[selectedMachine] then
            teleportAndStart(workoutPositions[selectedMachine])
            Library:Notify({ Title = "Auto Machine", Content = "Teleported to: "..tostring(selectedMachine), Duration = 3 })
        end
    end,
})

local toolsSection  = farmingTab:AddSection("Auto Tools")
-- TOOLS
toolsSection:AddParagraph({
    Title = "Auto Tools",
    Content = "Use tools like Weight, Pushups, Punch.",
})

_G.AutoWeight = false
toolsSection:AddToggle("Farming AutoWeight", {
    Title = "Auto Weight",
    Default = false,
    Description = "Equip Weight tool and auto rep.",
    Callback = function(enabled)
        _G.AutoWeight = enabled
        if enabled then
            pcall(function()
                local weightTool = game.Players.LocalPlayer.Backpack:FindFirstChild("Weight")
                if weightTool and game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("Humanoid") then
                    game.Players.LocalPlayer.Character.Humanoid:EquipTool(weightTool)
                end
            end)
            task.spawn(function()
                while _G.AutoWeight do
                    task.wait(0.1)
                    pcall(function()
                        if game.Players.LocalPlayer and game.Players.LocalPlayer:FindFirstChild("muscleEvent") then
                            game.Players.LocalPlayer.muscleEvent:FireServer("rep")
                        end
                    end)
                end
            end)
        else
            pcall(function()
                local char = game.Players.LocalPlayer.Character
                if char and char:FindFirstChild("Weight") then
                    char.Weight.Parent = game.Players.LocalPlayer.Backpack
                end
            end)
        end
    end,
})

_G.AutoPushups = false
toolsSection:AddToggle("Farming AutoPushups", {
    Title = "Auto Pushups",
    Default = false,
    Description = "Equip Pushups tool and auto rep.",
    Callback = function(enabled)
        _G.AutoPushups = enabled
        if enabled then
            pcall(function()
                local pushupsTool = game.Players.LocalPlayer.Backpack:FindFirstChild("Pushups")
                if pushupsTool and game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("Humanoid") then
                    game.Players.LocalPlayer.Character.Humanoid:EquipTool(pushupsTool)
                end
            end)
            task.spawn(function()
                while _G.AutoPushups do
                    task.wait(0.1)
                    pcall(function()
                        if game.Players.LocalPlayer and game.Players.LocalPlayer:FindFirstChild("muscleEvent") then
                            game.Players.LocalPlayer.muscleEvent:FireServer("rep")
                        end
                    end)
                end
            end)
        else
            pcall(function()
                local char = game.Players.LocalPlayer.Character
                if char and char:FindFirstChild("Pushups") then
                    char.Pushups.Parent = game.Players.LocalPlayer.Backpack
                end
            end)
        end
    end,
})

local autoEquipPunch = false
toolsSection:AddToggle("Farming AutoPunchEquip", {
    Title = "Auto Punch Equip",
    Default = false,
    Description = "Continuously Punch.",
    Callback = function(enabled)
        autoEquipPunch = enabled
        if autoEquipPunch then
            task.spawn(function()
                while autoEquipPunch do
                    task.wait(0.1)
                    pcall(function()
                        local punch = game.Players.LocalPlayer.Backpack:FindFirstChild("Punch")
                        if punch and game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("Humanoid") then
                            punch.Parent = game.Players.LocalPlayer.Character
                        end
                    end)
                end
            end)
        end
    end,
})


local function gettool()
    for i, v in pairs(game.Players.LocalPlayer.Backpack:GetChildren()) do
        if v.Name == "Punch" and game.Players.LocalPlayer.Character:FindFirstChild("Humanoid") then
            game.Players.LocalPlayer.Character.Humanoid:EquipTool(v)
        end
    end
    game:GetService("Players").LocalPlayer.muscleEvent:FireServer("punch", "leftHand")
    game:GetService("Players").LocalPlayer.muscleEvent:FireServer("punch", "rightHand")
end


local rocksSection  = farmingTab:AddSection("Auto Rocks")

rocksSection:AddParagraph({
    Title = "Auto Rocks",
    Content = "Select which rock to hit.",
})

local rockData = {
    ["Tiny Rock"] = {Name = "Tiny Island Rock", Durability = 0},
    ["Starter Rock"] = {Name = "Starter Island Rock", Durability = 100},
    ["Legend Beach Rock"] = {Name = "Legend Beach Rock", Durability = 5000},
    ["Frozen Rock"] = {Name = "Frost Gym Rock", Durability = 150000},
    ["Mythical Rock"] = {Name = "Mythical Gym Rock", Durability = 400000},
    ["Eternal Rock"] = {Name = "Eternal Gym Rock", Durability = 750000},
    ["Legend Rock"] = {Name = "Legend Gym Rock", Durability = 1000000},
    ["Muscle King Rock"] = {Name = "Muscle King Gym Rock", Durability = 5000000},
    ["Jungle Rock"] = {Name = "Ancient Jungle Rock", Durability = 10000000},
}

local rockValues = {}
for k, _ in pairs(rockData) do
    table.insert(rockValues, k)
end

local selectedRock = nil
rocksSection:AddDropdown("Farming RockDropdown", {
    Title = "Select Rock",
    Description = "Choose rock to farm",
    Values = rockValues,
    Default = rockValues[1],
    Callback = function(val)
	selectedRock = val end,
})

getgenv().autoFarm = false
local function equipAndPunch()
    pcall(function()
        for _, v in pairs(game.Players.LocalPlayer.Backpack:GetChildren()) do
            if v.Name == "Punch" and game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("Humanoid") then
                game.Players.LocalPlayer.Character.Humanoid:EquipTool(v)
            end
        end
        if game.Players.LocalPlayer and game.Players.LocalPlayer:FindFirstChild("muscleEvent") then
            game.Players.LocalPlayer.muscleEvent:FireServer("punch", "leftHand")
            game.Players.LocalPlayer.muscleEvent:FireServer("punch", "rightHand")
        end
    end)
end

rocksSection:AddToggle("Farming StartRocks", {
    Title = "Start Auto Rocks",
    Default = false,
    Description = "Auto interact with selected rock when durability threshold is met.",
    Callback = function(state)
        getgenv().autoFarm = state
        task.spawn(function()
            while getgenv().autoFarm do
                task.wait()
                if not getgenv().autoFarm or not selectedRock then break end
                local data = rockData[selectedRock]
                if data then
                    local durabilityOK = false
                    pcall(function()
                        if game.Players.LocalPlayer and game.Players.LocalPlayer:FindFirstChild("Durability") and game.Players.LocalPlayer.Durability.Value >= data.Durability then
                            durabilityOK = true
                        end
                    end)
                    if durabilityOK then
                        pcall(function()
                            if workspace:FindFirstChild("machinesFolder") then
                                for _, v in pairs(workspace.machinesFolder:GetDescendants()) do
                                    if v.Name == "neededDurability" and v.Value == data.Durability and v.Parent and v.Parent:FindFirstChild("Rock") then
                                        local char = game.Players.LocalPlayer.Character
                                        if char and char:FindFirstChild("LeftHand") and char:FindFirstChild("RightHand") then
                                            firetouchinterest(v.Parent.Rock, char.RightHand, 0)
                                            firetouchinterest(v.Parent.Rock, char.RightHand, 1)
                                            firetouchinterest(v.Parent.Rock, char.LeftHand, 0)
                                            firetouchinterest(v.Parent.Rock, char.LeftHand, 1)
                                            equipAndPunch()
                                        end
                                    end
                                end
                            end
                        end)
                    end
                end
            end
        end)
    end,
})

local HideSection   = farmingTab:AddSection("Hide Features")
HideSection:AddToggle("Hide Frames", {
    Title = "Hide Frames",
    Description = "Toggle to hide or show all objects ending with 'Frame' in ReplicatedStorage.",
    Default = false,
    Callback = function(state)
        for _, obj in pairs(game:GetService("ReplicatedStorage"):GetChildren()) do
            if obj:IsA("Instance") and obj.Name:match("Frame$") and obj:FindFirstChildWhichIsA("GuiObject") then
                for _, child in pairs(obj:GetDescendants()) do
                    if child:IsA("GuiObject") then
                        child.Visible = not state
                    end
                end
            elseif obj:IsA("GuiObject") and obj.Name:match("Frame$") then
                obj.Visible = not state
            end
        end
    end,
})

HideSection:AddToggle("HidePets", {
    Title = "Hide Pets",
    Default = false,
    Callback = function(state)
        local event = game:GetService("ReplicatedStorage").rEvents.showPetsEvent
        event:FireServer(state and "hidePets" or "showPets")
    end,
})

--============================================================================
--  TAB 3  –  REBIRTHS
--============================================================================
local rebirthSection = Rebirths:AddSection("Auto Rebirth / Size / Teleport")
rebirthSection:AddParagraph({
    Title = "Auto Rebirths",
    Content = "Set target rebirth count or use infinite rebirths.",
})

local targetRebirthValue = 1
rebirthSection:AddInput("Rebirth_TargetInput", {
    Title = "Rebirth Target",
    Placeholder = "Enter target rebirths (number)",
    Default = tostring(targetRebirthValue),
    Callback = function(text)
        local newValue = tonumber(text)
        if newValue and newValue > 0 then
            targetRebirthValue = newValue
            Library:Notify({ Title = "Target Updated", Content = "New rebirth target: "..tostring(targetRebirthValue), Duration = 3 })
        else
            Library:Notify({ Title = "Invalid Value", Content = "Enter a number greater than 0", Duration = 3 })
        end
    end,
})

_G.targetRebirthActive = false
rebirthSection:AddToggle("Farming_TargetRebirth", {
    Title = "Auto Rebirth Until Target",
    Default = false,
    Description = "Automatically invoke rebirth until reaching the target value.",
    Callback = function(enabled)
        _G.targetRebirthActive = enabled
        if enabled then
            _G.infiniteRebirthActive = false
            task.spawn(function()
                while _G.targetRebirthActive do
                    task.wait(0.1)
                    local success, current = pcall(function()
                        return game.Players.LocalPlayer and game.Players.LocalPlayer:FindFirstChild("leaderstats") and game.Players.LocalPlayer.leaderstats:FindFirstChild("Rebirths") and game.Players.LocalPlayer.leaderstats.Rebirths.Value
                    end)
                    if success and current and current >= targetRebirthValue then
                        _G.targetRebirthActive = false
                        Library:Notify({ Title = "Target Reached", Content = "Reached "..tostring(targetRebirthValue).." rebirths.", Duration = 4 })
                        break
                    end
                    pcall(function()
                        if game:GetService("ReplicatedStorage"):FindFirstChild("rEvents") and game:GetService("ReplicatedStorage").rEvents:FindFirstChild("rebirthRemote") then
                            game:GetService("ReplicatedStorage").rEvents.rebirthRemote:InvokeServer("rebirthRequest")
                        end
                    end)
                end
            end)
        end
    end,
})

_G.infiniteRebirthActive = false
rebirthSection:AddToggle("Farming_InfiniteRebirth", {
    Title = "Auto Rebirth (Infinite)",
    Default = false,
    Description = "Continuously send rebirth requests.",
    Callback = function(enabled)
        _G.infiniteRebirthActive = enabled
        if enabled then
            _G.targetRebirthActive = false
            task.spawn(function()
                while _G.infiniteRebirthActive do
                    task.wait(0.1)
                    pcall(function()
                        if game:GetService("ReplicatedStorage"):FindFirstChild("rEvents") and game:GetService("ReplicatedStorage").rEvents:FindFirstChild("rebirthRemote") then
                            game:GetService("ReplicatedStorage").rEvents.rebirthRemote:InvokeServer("rebirthRequest")
                        end
                    end)
                end
            end)
        end
    end,
})

_G.autoSizeActive = false
rebirthSection:AddToggle("Farming_AutoSize1", {
    Title = "Auto Size 1",
    Default = false,
    Description = "Continuously request size 1.",
    Callback = function(enabled)
        _G.autoSizeActive = enabled
        if enabled then
            task.spawn(function()
                while _G.autoSizeActive do
                    task.wait()
                    pcall(function()
                        if game:GetService("ReplicatedStorage"):FindFirstChild("rEvents") and game:GetService("ReplicatedStorage").rEvents:FindFirstChild("changeSpeedSizeRemote") then
                            game:GetService("ReplicatedStorage").rEvents.changeSpeedSizeRemote:InvokeServer("changeSize", 1)
                        end
                    end)
                end
            end)
        end
    end,
})

_G.teleportActive = false
rebirthSection:AddToggle("Farming_TeleportToMK", {
    Title = "Auto Teleport to Muscle King",
    Default = false,
    Description = "Continuously MoveTo the Muscle King position.",
    Callback = function(enabled)
        _G.teleportActive = enabled
        if enabled then
            task.spawn(function()
                while _G.teleportActive do
                    task.wait()
                    if game.Players.LocalPlayer.Character then
                        pcall(function()
                            game.Players.LocalPlayer.Character:MoveTo(Vector3.new(-8646, 17, -5738))
                        end)
                    end
                end
            end)
        end
    end,
})

--============================================================================
--  TAB 4  –  KILLER
--============================================================================
Killer:AddParagraph({
    Title = "Killing Tab",
    Content = "All Killer Features",
})

-- Karma
Killer:AddToggle("AutoGoodKarma", {
    Title = "Auto Good Karma",
    Default = false,
    Description = "Increase Good Karma.",
    Callback = function(state)
        local autoGoodKarma = state
        task.spawn(function()
            while autoGoodKarma do
                local playerChar = game.Players.LocalPlayer.Character
                local rightHand = playerChar and (playerChar:FindFirstChild("RightHand") or playerChar:FindFirstChild("Right Arm"))
                local leftHand = playerChar and (playerChar:FindFirstChild("LeftHand") or playerChar:FindFirstChild("Left Arm"))
                if playerChar and rightHand and leftHand then
                    for _, target in ipairs(game:GetService("Players"):GetPlayers()) do
                        if target ~= game.Players.LocalPlayer then
                            local evilKarma = target:FindFirstChild("evilKarma")
                            local goodKarma = target:FindFirstChild("goodKarma")
                            if evilKarma and goodKarma and evilKarma:IsA("IntValue") and goodKarma:IsA("IntValue") and evilKarma.Value > goodKarma.Value then
                                local rootPart = target.Character and target.Character:FindFirstChild("HumanoidRootPart")
                                if rootPart then
                                    pcall(function()
                                        firetouchinterest(rightHand, rootPart, 1)
                                        firetouchinterest(leftHand, rootPart, 1)
                                        firetouchinterest(rightHand, rootPart, 0)
                                        firetouchinterest(leftHand, rootPart, 0)
                                    end)
                                end
                            end
                        end
                    end
                end
                task.wait(0.01)
            end
        end)
    end,
})

Killer:AddToggle("AutoBadKarma", {
    Title = "Auto Bad Karma",
    Default = false,
    Description = "Increase Evil Karma.",
    Callback = function(state)
        local autoBadKarma = state
        task.spawn(function()
            while autoBadKarma do
                local playerChar = game.Players.LocalPlayer.Character
                local rightHand = playerChar and (playerChar:FindFirstChild("RightHand") or playerChar:FindFirstChild("Right Arm"))
                local leftHand = playerChar and (playerChar:FindFirstChild("LeftHand") or playerChar:FindFirstChild("Left Arm"))
                if playerChar and rightHand and leftHand then
                    for _, target in ipairs(game:GetService("Players"):GetPlayers()) do
                        if target ~= game.Players.LocalPlayer then
                            local evilKarma = target:FindFirstChild("evilKarma")
                            local goodKarma = target:FindFirstChild("goodKarma")
                            if evilKarma and goodKarma and evilKarma:IsA("IntValue") and goodKarma:IsA("IntValue") and goodKarma.Value > evilKarma.Value then
                                local rootPart = target.Character and target.Character:FindFirstChild("HumanoidRootPart")
                                if rootPart then
                                    pcall(function()
                                        firetouchinterest(rightHand, rootPart, 1)
                                        firetouchinterest(leftHand, rootPart, 1)
                                        firetouchinterest(rightHand, rootPart, 0)
                                        firetouchinterest(leftHand, rootPart, 0)
                                    end)
                                end
                            end
                        end
                    end
                end
                task.wait(0.01)
            end
        end)
    end,
})

local function hookResetOnCharacter(char)
	if not char then return end
	local humanoid = char:FindFirstChildOfClass("Humanoid")
	if not humanoid then return end
	safeDisconnect("ResetDeath")
	connections.ResetDeath = humanoid.Died:Connect(function()
		task.wait(0.5)
		respawnPlayer()
	end)
end

Killer:AddToggle("Punch When Dead Combo", {
	Title = "Punch When Dead | Combo with Protein Egg",
	Default = false,
	Description = "NaN Size.",
	Callback = function(state)
		comboActive = state

		-- first cleanup any previous run
		cleanupAll()

		if state then
			-- apply NaN size
			applySizeNaN()

			-- start main features
			startAutoPunch()
			startProteinEggLogic()
			startAntiFly()
			softAntiLagAndSunset()

			-- hook reset on current character and future ones
			if LocalPlayer.Character then
				hookResetOnCharacter(LocalPlayer.Character)
			end
			safeDisconnect("CharacterAddedReset")
			connections.CharacterAddedReset = LocalPlayer.CharacterAdded:Connect(function(char)
				task.wait(0.5)
				hookResetOnCharacter(char)
			end)
		else
			-- disable everything and cleanup
			cleanupAll()
		end
	end,
})

local friendWhitelistActive = false

Killer:AddToggle("AutoWhitelistFriends", {
	Title = "Auto Whitelist Friends",
	Default = false,
	Description = "Automatically whitelist your Roblox friends.",
	Callback = function(state)
		friendWhitelistActive = state
		if state then
			for _, player in ipairs(PlayersService:GetPlayers()) do
				if player ~= LocalPlayer and LocalPlayer:IsFriendsWith(player.UserId) then
					playerWhitelist[player.Name] = true
				end
			end

			PlayersService.PlayerAdded:Connect(function(player)
				if friendWhitelistActive and player ~= LocalPlayer and LocalPlayer:IsFriendsWith(player.UserId) then
					playerWhitelist[player.Name] = true
				end
			end)
		else
			for name in pairs(playerWhitelist) do
				local friend = PlayersService:FindFirstChild(name)
				if friend and LocalPlayer:IsFriendsWith(friend.UserId) then
					playerWhitelist[name] = nil
				end
			end
		end
	end,
})

Killer:AddInput("WhitelistAdd", {
	Title = "Whitelist Player",
	Default = "",
	Placeholder = "PlayerName",
	Callback = function(text)
		local target = PlayersService:FindFirstChild(text)
		if target then
			playerWhitelist[target.Name] = true
			Library:Notify({Title="Whitelist", Content = target.Name .. " added to whitelist.", Duration = 3})
		else
			Library:Notify({Title="Whitelist", Content = "Player not found: " .. tostring(text), Duration = 3})
		end
	end,
})

Killer:AddInput("WhitelistRemove", {
	Title = "UnWhitelist Player",
	Default = "",
	Placeholder = "PlayerName",
	Callback = function(text)
		local target = PlayersService:FindFirstChild(text)
		if target then
			playerWhitelist[target.Name] = nil
			Library:Notify({Title="Whitelist", Content = target.Name .. " removed from whitelist.", Duration = 3})
		else
			Library:Notify({Title="Whitelist", Content = "Player not found: " .. tostring(text), Duration = 3})
		end
	end,
})

Killer:AddToggle("AutoKill", {
	Title = "Auto Kill (AURA)",
	Default = false,
	Description = "Automatically kill player nearby.",
	Callback = function(state)
		autoKill = state
		task.spawn(function()
			while autoKill do
				local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
				local rightHand = character:FindFirstChild("RightHand") or character:FindFirstChild("Right Arm")
				local leftHand = character:FindFirstChild("LeftHand") or character:FindFirstChild("Left Arm")

				local punch = LocalPlayer.Backpack and LocalPlayer.Backpack:FindFirstChild("Punch")
				if punch and not character:FindFirstChild("Punch") then
					pcall(function() punch.Parent = character end)
				end

				if rightHand and leftHand then
					for _, target in ipairs(PlayersService:GetPlayers()) do
						if target ~= LocalPlayer and not playerWhitelist[target.Name] then
							local targetChar = target.Character
							local rootPart = targetChar and (targetChar:FindFirstChild("HumanoidRootPart") or targetChar:FindFirstChild("Torso"))
							if rootPart then
								pcall(function()
									firetouchinterest(rightHand, rootPart, 1)
									firetouchinterest(leftHand, rootPart, 1)
									firetouchinterest(rightHand, rootPart, 0)
									firetouchinterest(leftHand, rootPart, 0)
								end)
							end
						end
					end
				end

				task.wait(0.05)
			end
		end)
	end,
})

local targetDropdown = Killer:AddDropdown("SelectTarget", {
    Title = "Select Target",
    Values = {},
    Default = nil,
    Callback = function(name)
        if name and not table.find(targetPlayerNames, name) then
            table.insert(targetPlayerNames, name)
            Library:Notify({Title="Target", Content = name .. " added to target list.", Duration = 2})
        end
    end,
})

Killer:AddButton({
    Title = "Remove Target From List",
    Callback = function()
        local name = Library:InputDialog({
            Title = "Remove Target",
            Default = "",
            Placeholder = "PlayerName"
        })
        if not name or name == "" then return end

        for i, v in ipairs(targetPlayerNames) do
            if v == name then
                table.remove(targetPlayerNames, i)
                Library:Notify({Title="Target", Content = name .. " removed.", Duration = 2})
                break
            end
        end
    end
})

-- keep the dropdown values synced with players
local function refreshTargetDropdown()
	-- if the dropdown object exposes Clear/Add, use them; otherwise re-create values
	if targetDropdown and type(targetDropdown.Clear) == "function" then
		targetDropdown:Clear()
		for _, plr in ipairs(PlayersService:GetPlayers()) do
			if plr ~= LocalPlayer then
				targetDropdown:Add(plr.Name)
			end
		end
	else
		-- attempt to set values via internal API (some libs use SetValues)
		local vals = {}
		for _, plr in ipairs(PlayersService:GetPlayers()) do
			if plr ~= LocalPlayer then table.insert(vals, plr.Name) end
		end
		-- best-effort: try to replace the dropdown by rebuilding (if API supported)
		-- If not supported, this is non-fatal.
		pcall(function()
			if targetDropdown and targetDropdown.SetValues then
				targetDropdown:SetValues(vals)
			end
		end)
	end
end

refreshTargetDropdown()

PlayersService.PlayerAdded:Connect(function(player)
	if player ~= LocalPlayer then
		if targetDropdown and type(targetDropdown.Add) == "function" then
			pcall(function() targetDropdown:Add(player.Name) end)
		else
			refreshTargetDropdown()
		end
	end
end)

PlayersService.PlayerRemoving:Connect(function(player)
	if targetDropdown and type(targetDropdown.Clear) == "function" then
		pcall(function()
			targetDropdown:Clear()
			for _, plr in ipairs(PlayersService:GetPlayers()) do
				if plr ~= LocalPlayer then
					targetDropdown:Add(plr.Name)
				end
			end
		end)
	else
		refreshTargetDropdown()
	end

	for i = #targetPlayerNames, 1, -1 do
		if targetPlayerNames[i] == player.Name then
			table.remove(targetPlayerNames, i)
		end
	end
end)

Killer:AddToggle("Start to Kill Target", {
	Title = "Kill Target",
	Default = false,
	Description = "Attack players listed in the target list.",
	Callback = function(state)
		killTarget = state
		task.spawn(function()
			while killTarget do
				local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

				local punch = LocalPlayer.Backpack:FindFirstChild("Punch")
				if punch and not character:FindFirstChild("Punch") then
					pcall(function() punch.Parent = character end)
				end

				local rightHand = character:WaitForChild("RightHand", 5) or character:FindFirstChild("Right Arm")
				local leftHand = character:WaitForChild("LeftHand", 5) or character:FindFirstChild("Left Arm")

				if rightHand and leftHand then
					for _, name in ipairs(targetPlayerNames) do
						local target = PlayersService:FindFirstChild(name)
						if target and target ~= LocalPlayer then
							local rootPart = getRootCharacter(target)
							if rootPart then
								pcall(function()
									firetouchinterest(rightHand, rootPart, 1)
									firetouchinterest(leftHand, rootPart, 1)
									firetouchinterest(rightHand, rootPart, 0)
									firetouchinterest(leftHand, rootPart, 0)
								end)
							end
						end
					end
				end

				task.wait(0.05)
			end
		end)
	end,
})

local spyDropdown = Killer:AddDropdown("SelectViewTarget", {
	Title = "Select View Target",
	Values = {},
	Default = nil,
	Callback = function(name)
		spyTargetName = name
		Library:Notify({Title="Spy", Content = "Selected " .. tostring(name) .. " for viewing.", Duration = 2})
	end,
})

-- populate spy dropdown initially
local function refreshSpyDropdown()
	if spyDropdown and type(spyDropdown.Clear) == "function" then
		spyDropdown:Clear()
		for _, plr in ipairs(PlayersService:GetPlayers()) do
			if plr ~= LocalPlayer then spyDropdown:Add(plr.Name) end
		end
	else
		local vals = {}
		for _, plr in ipairs(PlayersService:GetPlayers()) do if plr ~= LocalPlayer then table.insert(vals, plr.Name) end end
		pcall(function() if spyDropdown and spyDropdown.SetValues then spyDropdown:SetValues(vals) end end)
	end
end

refreshSpyDropdown()

PlayersService.PlayerAdded:Connect(function(plr)
	if plr ~= LocalPlayer then
		if spyDropdown and type(spyDropdown.Add) == "function" then
			pcall(function() spyDropdown:Add(plr.Name) end)
		else
			refreshSpyDropdown()
		end
	end
end)

PlayersService.PlayerRemoving:Connect(function(plr)
	refreshSpyDropdown()
end)

Killer:AddToggle("ViewPlayer", {
	Title = "View Player",
	Default = false,
	Description = "Switch camera to follow selected player.",
	Callback = function(bool)
		spying = bool
		local cam = workspace.CurrentCamera
		if not spying then
			pcall(function()
				cam.CameraSubject = (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")) or LocalPlayer
			end)
			return
		end
		task.spawn(function()
			while spying do
				local target = PlayersService:FindFirstChild(spyTargetName)
				if target and target ~= LocalPlayer then
					local humanoid = target.Character and target.Character:FindFirstChild("Humanoid")
					if humanoid then
						pcall(function() workspace.CurrentCamera.CameraSubject = humanoid end)
					end
				end
				task.wait(0.1)
			end
		end)
	end,
})

Killer:AddToggle("UnviewPlayer", {
	Title = "Unview Player",
	Default = false,
	Description = "Reset camera back to local player.",
	Callback = function(bool)
		if bool then
			spying = false
			local cam = workspace.CurrentCamera
			pcall(function()
				cam.CameraSubject = (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")) or LocalPlayer
			end)
		end
	end,
})

Killer:AddToggle("AutoEquipPunch", {
    Title = "Auto Equip Punch",
    Default = false,
    Callback = function(state)
        local autoEquipPunch = state
        task.spawn(function()
            while autoEquipPunch do
                local punch = game.Players.LocalPlayer.Backpack:FindFirstChild("Punch")
                if punch and game.Players.LocalPlayer and game.Players.LocalPlayer.Character then
                    pcall(function() punch.Parent = game.Players.LocalPlayer.Character end)
                end
                task.wait(0.1)
            end
        end)
    end,
})

Killer:AddToggle("AutoPunchNoAnim", {
    Title = "Auto Punch [No Animation]",
    Default = false,
    Callback = function(state)
        local autoPunchNoAnim = state
        task.spawn(function()
            while autoPunchNoAnim do
                local punch = game.Players.LocalPlayer.Backpack:FindFirstChild("Punch") or (game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("Punch"))
                if punch then
                    if punch.Parent ~= game.Players.LocalPlayer.Character then
                        pcall(function() punch.Parent = game.Players.LocalPlayer.Character end)
                    end
                    pcall(function()
                        if game.Players.LocalPlayer:FindFirstChild("muscleEvent") and type(game.Players.LocalPlayer.muscleEvent.FireServer) == "function" then
                            game.Players.LocalPlayer.muscleEvent:FireServer("punch", "rightHand")
                            game.Players.LocalPlayer.muscleEvent:FireServer("punch", "leftHand")
                        end
                    end)
                else
                    autoPunchNoAnim = false
                end
                task.wait(0.01)
            end
        end)
    end,
})

Killer:AddToggle("AutoPunch", {
    Title = "Auto Punch (Fast)",
    Default = false,
    Callback = function(state)
        _G.fastHitActive = state
        if state then
            task.spawn(function()
                while _G.fastHitActive do
                    local punch = game.Players.LocalPlayer.Backpack:FindFirstChild("Punch")
                    if punch then
                        pcall(function()
                            punch.Parent = game.Players.LocalPlayer.Character
                            if punch:FindFirstChild("attackTime") then
                                punch.attackTime.Value = 0
                            end
                        end)
                    end
                    task.wait(0.1)
                end
            end)
            task.spawn(function()
                while _G.fastHitActive do
                    local punch = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("Punch")
                    if punch and type(punch.Activate) == "function" then
                        pcall(function() punch:Activate() end)
                    end
                    task.wait(0.1)
                end
            end)
        else
            local punch = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("Punch")
            if punch then
                pcall(function() punch.Parent = game.Players.LocalPlayer.Backpack end)
            end
        end
    end,
})


-- Anti-Knockback
Killer:AddToggle("AntiKnockback", {
    Title = "Anti Knockback",
    Default = false,
    Callback = function(Value)
        local playerName = game.Players.LocalPlayer.Name
        local rootPart = game.Workspace:FindFirstChild(playerName):FindFirstChild("HumanoidRootPart")
        if Value then
            local bodyVelocity = Instance.new("BodyVelocity")
            bodyVelocity.MaxForce = Vector3.new(100000, 0, 100000)
            bodyVelocity.Velocity = Vector3.new(0, 0, 0)
            bodyVelocity.P = 1250
            bodyVelocity.Parent = rootPart
        else
            local existingVelocity = rootPart:FindFirstChild("BodyVelocity")
            if existingVelocity and existingVelocity.MaxForce == Vector3.new(100000, 0, 100000) then
                existingVelocity:Destroy()
            end
        end
    end,
})

-- Punch animations
Killer:AddButton({
    Title = "Remove Punch Anim",
    Description = "Block punch animations",
    Callback = function()
        -- >>>>  PASTE FULL REMOVE-PUNCH-ANIM CODE  <<<<
    end,
})

Killer:AddButton({
    Title = "Recover Punch Anim",
    Description = "Restore normal behavior.",
    Callback = function()
        -- >>>>  PASTE FULL RECOVER-PUNCH-ANIM CODE  <<<<
    end,
})

--============================================================================
--  TAB 5  –  CRYSTALS (SHOP)
--============================================================================
local PetsSection = Shop:AddSection("Pets & Auras")

-- Pets
local selectedPet = "Neon Guardian"
local petDropdown = PetsSection:AddDropdown("Select Pet", {
    Title = "Select Pet",
    Description = "Choose the pet you want to auto hatch",
    Values = {
        "Neon Guardian","Blue Birdie","Blue Bunny","Blue Firecaster","Blue Pheonix","Crimson Falcon",
        "Cybernetic Showdown Dragon","Dark Golem","Dark Legends Manticore","Dark Vampy","Darkstar Hunter",
        "Eternal Strike Leviathan","Frostwave Legends Penguin","Gold Warrior","Golden Pheonix","Golden Viking",
        "Green Butterfly","Green Firecaster","Infernal Dragon","Lightning Strike Phantom","Magic Butterfly",
        "Muscle Sensei","Orange Hedgehog","Orange Pegasus","Phantom Genesis Dragon","Purple Dragon",
        "Purple Falcon","Red Dragon","Red Firecaster","Red Kitty","Silver Dog","Ultimate Supernova Pegasus",
        "Ultra Birdie","White Pegasus","White Pheonix","Yellow Butterfly"
    },
    Default = selectedPet,
    Callback = function(value) selectedPet = value end,
})

PetsSection:AddToggle("Auto Pet", {
    Title = "Auto Open Pet",
    Description = "Automatically opens the selected pet",
    Default = false,
    Callback = function(state)
        _G.AutoHatchPet = state
        if state then
            task.spawn(function()
                while _G.AutoHatchPet and selectedPet ~= "" do
                    local petToOpen = game:GetService("ReplicatedStorage").cPetShopFolder:FindFirstChild(selectedPet)
                    if petToOpen then
                        game:GetService("ReplicatedStorage").cPetShopRemote:InvokeServer(petToOpen)
                    end
                    task.wait(1)
                end
            end)
        end
    end,
})

-- Auras
local selectedAura = "Muscle King Aura"
local auraDropdown = PetsSection:AddDropdown("Select Aura", {
    Title = "Select Aura",
    Description = "Choose the aura you want to auto hatch",
    Values = {
        "Astral Electro","Azure Tundra","Blue Aura","Dark Electro","Dark Lightning","Dark Storm",
        "Electro","Enchanted Mirage","Entropic Blast","Eternal Megastrike","Grand Supernova","Green Aura",
        "Inferno","Lightning","Muscle King","Power Lightning","Purple Aura","Purple Nova","Red Aura",
        "Supernova","Ultra Inferno","Ultra Mirage","Unstable Mirage","Yellow Aura"
    },
    Default = selectedAura,
    Callback = function(value) selectedAura = value end,
})

PetsSection:AddToggle("Auto_Open_Aura", {
    Title = "Auto Open Aura",
    Description = "Automatically opens the selected aura",
    Default = false,
    Callback = function(state)
        _G.AutoHatchAura = state
        if state then
            task.spawn(function()
                while _G.AutoHatchAura and selectedAura ~= "" do
                    local auraToOpen = game:GetService("ReplicatedStorage").cPetShopFolder:FindFirstChild(selectedAura)
                    if auraToOpen then
                        game:GetService("ReplicatedStorage").cPetShopRemote:InvokeServer(auraToOpen)
                    end
                    task.wait(1)
                end
            end)
        end
    end,
})

--============================================================================
--  TAB 6  –  MISCELLANEOUS
--============================================================================
Misc:AddButton({
    Title = "Remove Portals",
    Callback = function()
        for _, portal in pairs(game:GetDescendants()) do
            if portal.Name == "RobloxForwardPortals" then
                portal:Destroy()
            end
        end
        if _G.AdRemovalConnection then _G.AdRemovalConnection:Disconnect() end
        _G.AdRemovalConnection = game.DescendantAdded:Connect(function(descendant)
            if descendant.Name == "RobloxForwardPortals" then
                descendant:Destroy()
            end
        end)
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Anuncios Eliminados",
            Text = "Los anuncios de Roblox han sido eliminados",
            Duration = 5
        })
    end,
})

Misc:AddToggle("InfJump", {
    Title = "Infinite Jump",
    Default = false,
    Callback = function(state)
        infJumpEnabled = state
    end,
})

Misc:AddToggle("NoClip", {
    Title = "No Clip",
    Default = false,
    Callback = function(state)
        _G.NoClip = state
        if state then
            local conn
            conn = game:GetService("RunService").Stepped:Connect(function()
                if _G.NoClip then
                    for _, part in pairs(game.Players.LocalPlayer.Character:GetDescendants()) do
                        if part:IsA("BasePart") then part.CanCollide = false end
                    end
                else
                    conn:Disconnect()
                end
            end)
        end
    end,
})

Misc:AddToggle("FullWalkOnWater", {
    Title = "Full Walk on Water",
    Default = false,
    Callback = function(bool)
        if bool then
            createParts()
        else
            makePartsWalkthrough()
        end
    end,
})

Misc:AddToggle("AntiKnockback", {
    Title = "Anti Knockback",
    Default = false,
    Callback = function(Value)
        local playerName = game.Players.LocalPlayer.Name
        local rootPart = game.Workspace:FindFirstChild(playerName):FindFirstChild("HumanoidRootPart")
        if Value then
            local bodyVelocity = Instance.new("BodyVelocity")
            bodyVelocity.MaxForce = Vector3.new(100000, 0, 100000)
            bodyVelocity.Velocity = Vector3.new(0, 0, 0)
            bodyVelocity.P = 1250
            bodyVelocity.Parent = rootPart
        else
            local existingVelocity = rootPart:FindFirstChild("BodyVelocity")
            if existingVelocity and existingVelocity.MaxForce == Vector3.new(100000, 0, 100000) then
                existingVelocity:Destroy()
            end
        end
    end,
})

Misc:AddToggle("AutoFortuneWheel", {
    Title = "Auto Fortune Wheel",
    Default = false,
    Callback = function(Value)
        _G.autoFortuneWheelActive = Value
        if Value then
            task.spawn(function()
                while _G.autoFortuneWheelActive do
                    local args = {
                        [1] = "openFortuneWheel",
                        [2] = game:GetService("ReplicatedStorage"):WaitForChild("fortuneWheelChances"):WaitForChild("Fortune Wheel")
                    }
                    game:GetService("ReplicatedStorage"):WaitForChild("rEvents"):WaitForChild("openFortuneWheelRemote"):InvokeServer(unpack(args))
                    task.wait(0)
                end
            end)
        else
            _G.autoFortuneWheelActive = false
        end
    end,
})

Misc:AddToggle("GodModeBrawl", {
    Title = "God Mode (Brawl)",
    Default = false,
    Callback = function(State)
        local godModeToggle = State
        if State then
            task.spawn(function()
                while godModeToggle do
                    game:GetService("ReplicatedStorage").rEvents.brawlEvent:FireServer("joinBrawl")
                    task.wait(0)
                end
            end)
        end
    end,
})

local parts = {}
local partSize = 2048
local totalDistance = 50000
local startPosition = Vector3.new(-2, -9.5, -2)
local numberOfParts = math.ceil(totalDistance / partSize)

local function createParts()
    for x = 0, numberOfParts - 1 do
        for z = 0, numberOfParts - 1 do
            local positions = {
                Vector3.new(x * partSize, 0, z * partSize),
                Vector3.new(-x * partSize, 0, z * partSize),
                Vector3.new(-x * partSize, 0, -z * partSize),
                Vector3.new(x * partSize, 0, -z * partSize)
            }
            for _, offset in ipairs(positions) do
                local p = Instance.new("Part")
                p.Size = Vector3.new(partSize, 1, partSize)
                p.Position = startPosition + offset
                p.Anchored = true
                p.Transparency = 1
                p.CanCollide = true
                p.Parent = workspace
                table.insert(parts, p)
            end
        end
    end
end

local function makePartsWalkthrough()
    for _, part in ipairs(parts) do
        if part and part.Parent then
            part.CanCollide = false
        end
    end
end

local autoEatBoostsEnabled = false
local boostsList = {"ULTRA Shake","TOUGH Bar","Protein Shake","Energy Shake","Protein Bar","Energy Bar","Tropical Shake"}

local function eatAllBoosts()
    local player = game.Players.LocalPlayer
    local backpack = player:WaitForChild("Backpack")
    local character = player.Character or player.CharacterAdded:Wait()
    for _, boostName in ipairs(boostsList) do
        local boost = backpack:FindFirstChild(boostName)
        while boost do
            boost.Parent = character
            pcall(function() boost:Activate() end)
            task.wait(0)
            boost = backpack:FindFirstChild(boostName)
        end
    end
end

task.spawn(function()
    while true do
        if autoEatBoostsEnabled then
            eatAllBoosts()
            task.wait(2)
        else
            task.wait(1)
        end
    end
end)

--============================================================================
--  TAB 7  –  SETTINGS
--============================================================================
Settings:AddToggle("DisableTrades", {
    Title = "Disable Trades",
    Default = false,
    Callback = function(state)
        local event = game:GetService("ReplicatedStorage").rEvents.tradingEvent
        event:FireServer(state and "disableTrading" or "enableTrading")
    end,
})

local infJumpEnabled = false
game:GetService("UserInputService").JumpRequest:Connect(function()
    if infJumpEnabled and game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
        game.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

Settings:AddToggle("AutoClearInventory", {
    Title = "Auto Clear Inventory",
    Default = false,
    Callback = function(state)
        autoEatBoostsEnabled = state
    end,
})

Settings:AddDropdown("ChangeTime", {
    Title = "Change Time",
    Values = {"Night", "Day", "Midnight"},
    Default = "Day",
    Callback = function(selection)
        local lighting = game:GetService("Lighting")
        if selection == "Night" then
            lighting.ClockTime = 0
        elseif selection == "Day" then
            lighting.ClockTime = 12
        elseif selection == "Midnight" then
            lighting.ClockTime = 6
        end
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Hora Cambiada",
            Text = "La hora ha sido cambiada a: " .. selection,
            Duration = 5
        })
    end,
})

local giftSection = Settings:AddSections("Gift Features")

giftSection:AddLabel("Gifting Protein egg:").TextSize = 22

local proteinEggLabel = giftSection:AddLabel("Protein Eggs: 0")
proteinEggLabel.TextSize = 20

local selectedEggPlayer = nil
local eggCount = 0

local eggDropdown = giftSection:AddDropdown("Player to Gift Eggs", function(selectedDisplayName)
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr.DisplayName == selectedDisplayName then
            selectedEggPlayer = plr
            break
        end
    end
end)

for _, plr in ipairs(Players:GetPlayers()) do
    if plr ~= Players.LocalPlayer then
        eggDropdown:Add(plr.DisplayName)
    end
end

Players.PlayerAdded:Connect(function(plr)
    if plr ~= Players.LocalPlayer then
        eggDropdown:Add(plr.DisplayName)
    end
end)

giftSection:AddInput("Amount of Eggs", function(text)
    eggCount = tonumber(text) or 0
end)

giftSection:AddButton("Gift Eggs", function()
    if selectedEggPlayer and eggCount > 0 then
        for i = 1, eggCount do
            local egg = Players.LocalPlayer.consumablesFolder:FindFirstChild("Protein Egg")
            if egg then
                ReplicatedStorage.rEvents.giftRemote:InvokeServer("giftRequest", selectedEggPlayer, egg)
                task.wait(0.1)
            end
        end
    end
end)

giftSection:AddLabel("Gifting Tropical Shakes:").TextSize = 22

local tropicalShakeLabel = giftSection:AddLabel("Tropical Shakes: 0")
tropicalShakeLabel.TextSize = 18

local selectedShakePlayer = nil
local shakeCount = 0

local shakeDropdown = giftSection:AddDropdown("Player to Gift Tropical Shakes", function(selectedDisplayName)
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr.DisplayName == selectedDisplayName then
            selectedShakePlayer = plr
            break
        end
    end
end)

for _, plr in ipairs(Players:GetPlayers()) do
    if plr ~= Players.LocalPlayer then
        shakeDropdown:Add(plr.DisplayName)
    end
end

Players.PlayerAdded:Connect(function(plr)
    if plr ~= Players.LocalPlayer then
        shakeDropdown:Add(plr.DisplayName)
    end
end)

giftSection:AddInput("Tropical Shakes gift", function(text)
    shakeCount = tonumber(text) or 0
end)

giftSection:AddButton("Gift Tropical Shakes", function()
    if selectedShakePlayer and shakeCount > 0 then
        for i = 1, shakeCount do
            local shake = Players.LocalPlayer.consumablesFolder:FindFirstChild("Tropical Shake")
            if shake then
                ReplicatedStorage.rEvents.giftRemote:InvokeServer("giftRequest", selectedShakePlayer, shake)
                task.wait(0.1)
            end
        end
    end
end)

local function updateItemCount()
    local proteinEggCount = 0
    local tropicalShakeCount = 0

    local backpack = Players.LocalPlayer:WaitForChild("Backpack")
    if backpack then
        for _, item in ipairs(backpack:GetChildren()) do
            if item.Name == "Protein Egg" then
                proteinEggCount = proteinEggCount + 1
            elseif item.Name == "Tropical Shake" or item.Name == "PiÃƒÂ±as" then
                tropicalShakeCount = tropicalShakeCount + 1
            end
        end
    end

    proteinEggLabel.Text = "Protein Eggs: " .. proteinEggCount
    tropicalShakeLabel.Text = "Tropical Shakes: " .. tropicalShakeCount
end

task.spawn(function()
    while true do
        updateItemCount()
        task.wait(0.25)
    end
end)


local itemList = {
    "Tropical Shake",
    "Energy Shake",
    "Protein Bar",
    "TOUGH Bar",
    "Protein Shake",
    "ULTRA Shake",
    "Energy Bar"
}

local function formatEventName(itemName)
    local parts = {}
    for word in itemName:gmatch("%S+") do
        table.insert(parts, word:lower())
    end
    for i = 2, #parts do
        parts[i] = parts[i]:sub(1, 1):upper() .. parts[i]:sub(2)
    end
    return table.concat(parts)
end

local function activateRandomItems(count)
    local shuffledItems = {}
    for _, item in ipairs(itemList) do
        table.insert(shuffledItems, item)
    end
    for i = #shuffledItems, 2, -1 do
        local j = math.random(i)
        shuffledItems[i], shuffledItems[j] = shuffledItems[j], shuffledItems[i]
    end
    for i = 1, math.min(count, #shuffledItems) do
        local tool =
            player.Character:FindFirstChild(shuffledItems[i]) or player.Backpack:FindFirstChild(shuffledItems[i])
        if tool then
            local eventName = formatEventName(shuffledItems[i])
            player.muscleEvent:FireServer(eventName, tool)
        end
    end
end

local eatingRunning = false
task.spawn(
    function()
        while true do
            if eatingRunning then
                activateRandomItems(4)
                task.wait(0.5)
            else
                task.wait(0.5)
            end
        end
    end
)

giftShake:AddButton(
    "Eat Everything",
    function(state)
        eatingRunning = state
        if state then
            activateRandomItems(4)
        end
    end
)
--============================================================================
--  END OF FILE
--============================================================================
