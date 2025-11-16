--  KYY HUB  –  REARRANGED BY TAB  (16 Nov 2025)
--  Every feature lives strictly inside its own tab-block.

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
    Size = UDim2.fromOffset(450, 335),
    TabWidth = 150,
    Theme = "DarkBlue",
    Acrylic = false,
})

--  TABS  --------------------------------------------------------------------
local Home        = Window:AddTab({ Title = "Home / Packs",     Icon = "home" })
local farmingTab  = Window:AddTab({ Title = "Farming",          Icon = "leaf" })
local Rebirths    = Window:AddTab({ Title = "Rebirths",         Icon = "repeat" })
local Killer      = Window:AddTab({ Title = "Killer",           Icon = "skull" })
local Shop        = Window:AddTab({ Title = "Crystals",         Icon = "shopping-cart" })
local Misc        = Window:AddTab({ Title = "Miscellaneous",    Icon = "menu" })
local Settings    = Window:AddTab({ Title = "Settings",         Icon = "save" })
------------------------------------------------------------------------------

--============================================================================
--  TAB 1  –  HOME / PACKS
--============================================================================
Home:AddButton({
    Title = "KYYY Discord Link | Press to Copy |",
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
    Description = "Starts the on-screen timer and prevents idle kicks.",
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

local packSection   = Home:AddSection("PACKS FARM")
local farmThread = nil   -- nil = not running

packSection:AddToggle("Packs Farm", {
    Title = "230K+ per day",
    Default = false,
    Callback = function(state)
        -- state == true  -> user turned it ON
        -- state == false -> user turned it OFF
        if state then   -- START
            farmThread = task.spawn(function()
                local a = game:GetService("ReplicatedStorage")
                local b = game:GetService("Players")
                local c = b.LocalPlayer

                local d = function()
                    local f = c.petsFolder
                    for _, h in pairs(f:GetChildren()) do
                        if h:IsA("Folder") then
                            for _, j in pairs(h:GetChildren()) do
                                a.rEvents.equipPetEvent:FireServer("unequipPet", j)
                            end
                        end
                    end
                    task.wait(.1)
                end

                local k = function(petName)
                    d()
                    task.wait(.01)
                    for _, n in pairs(c.petsFolder.Unique:GetChildren()) do
                        if n.Name == petName then
                            a.rEvents.equipPetEvent:FireServer("equipPet", n)
                            break
                        end
                    end
                end

                local o = function(machine)
                    local q = workspace.machinesFolder:FindFirstChild(machine)
                    if not q then
                        for _, s in pairs(workspace:GetChildren()) do
                            if s:IsA("Folder") and s.Name:find("machines") then
                                q = s:FindFirstChild(machine)
                                if q then break end
                            end
                        end
                    end
                    return q
                end

                local t = function()
                    local vim = game:GetService("VirtualInputManager")
                    vim:SendKeyEvent(true,  "E", false, game)
                    task.wait(.1)
                    vim:SendKeyEvent(false, "E", false, game)
                end

                while true do
                    local v = c.leaderstats.Rebirths.Value
                    local w = 10000 + (5000 * v)
                    if c.ultimatesFolder:FindFirstChild("Golden Rebirth") then
                        local x = c.ultimatesFolder["Golden Rebirth"].Value
                        w = math.floor(w * (1 - (x * 0.1)))
                    end

                    d()
                    task.wait(.1)
                    k("Swift Samurai")

                    while c.leaderstats.Strength.Value < w do
                        for _ = 1, 10 do
                            c.muscleEvent:FireServer("rep")
                        end
                        task.wait()
                    end

                    d()
                    task.wait(.1)
                    k("Tribal Overlord")

                    local z = o("Jungle Bar Lift")
                    if z and z:FindFirstChild("interactSeat") then
                        c.Character.HumanoidRootPart.CFrame =
                            z.interactSeat.CFrame * CFrame.new(0, 3, 0)
                        repeat
                            task.wait(.1)
                            t()
                        until c.Character.Humanoid.Sit
                    end

                    local oldRebirths = c.leaderstats.Rebirths.Value
                    repeat
                        a.rEvents.rebirthRemote:InvokeServer("rebirthRequest")
                        task.wait(.1)
                    until c.leaderstats.Rebirths.Value > oldRebirths

                    task.wait()
                end
            end)

        else            -- STOP
            if farmThread then
                task.cancel(farmThread)
                farmThread = nil
            end
        end
    end
})

packSection:AddToggle("FAST STRENGTH", {
    Title = "Fast Strength",
    Default = false,
    Callback = function(v)
        getgenv()._AutoRepFarmEnabled = v
    end
})

-- Session Stats UI
local player = game.Players.LocalPlayer
local ls = player:WaitForChild("leaderstats")
local strengthStat = ls:WaitForChild("Strength")
local rebirthsStat = ls:WaitForChild("Rebirths")
local durabilityStat = player:WaitForChild("Durability")
local killsStat = ls:WaitForChild("Kills")
local agilityStat = player:WaitForChild("Agility")

local NAVY_BLUE = Color3.fromRGB(30, 58, 138)      -- navy blue text / accents
local GRAY_BG   = Color3.fromRGB(45, 45, 45)       -- main gray background
local DARK_GRAY = Color3.fromRGB(35, 35, 35)       -- title-bar gray

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
main.BackgroundColor3 = GRAY_BG
main.BorderSizePixel = 0
main.Parent = screenGui
main.Active = true
main.Draggable = true

local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 30)
titleBar.BackgroundColor3 = DARK_GRAY
titleBar.Parent = main

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 1, 0)
title.BackgroundTransparency = 1
title.Text = "Session Stats"
title.TextColor3 = NAVY_BLUE
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

local uiList = Instance.new("UIListLayout")
uiList.SortOrder = Enum.SortOrder.LayoutOrder
uiList.Padding = UDim.new(0, 5)
uiList.Parent = scroll

local function AddLabel(text, size)
    local lab = Instance.new("TextLabel")
    lab.Size = UDim2.new(1, -10, 0, size + 5)
    lab.BackgroundTransparency = 1
    lab.Text = text
    lab.TextColor3 = NAVY_BLUE
    lab.Font = Enum.Font.SourceSans
    lab.TextSize = size
    lab.TextXAlignment = Enum.TextXAlignment.Left
    lab.Parent = scroll
    return lab
end

local function AddButton(text, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -10, 0, 30)
    btn.BackgroundColor3 = DARK_GRAY
    btn.TextColor3 = NAVY_BLUE
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 18
    btn.Text = text
    btn.Parent = scroll
    btn.MouseButton1Click:Connect(callback)
    return btn
end

AddLabel("⏱️ Session Stats", 24)
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
AddLabel("Projected Stats", 24)
local projectedStrengthLabel = AddLabel("Strength Pace: -", 18)
local projectedDurabilityLabel = AddLabel("Durability Pace: -", 18)
local projectedRebirthsLabel = AddLabel("Rebirth Pace: -", 18)

AddLabel("------------------", 14)
AddLabel("Leaderboard Stats", 24)
local strengthLabel = AddLabel("Strength: -", 18)
local rebirthsLabel = AddLabel("Rebirths: -", 18)
local killsLabel = AddLabel("Kills: -", 18)

AddLabel("------------------", 14)
AddLabel("Player Stats", 24)
local durabilityLabel = AddLabel("Durability: -", 18)
local agilityLabel = AddLabel("Agility: -", 18)

local startTime = tick()
local initialStrength = strengthStat.Value
local initialDurability = durabilityStat.Value
local initialRebirths = rebirthsStat.Value
local initialKills = killsStat.Value
local initialAgility = agilityStat.Value

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
    end
end)

Home:AddToggle("ShowStats", {
    Title = "Show Stats",
    Default = false,
    Callback = function(state)
        screenGui.Enabled = state
    end
})

-- Block Rebirths
Home:AddButton({
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
Home:AddButton({
    Title = "Block Trades",
    Callback = function()
        game:GetService("ReplicatedStorage").rEvents.tradingEvent:FireServer("disableTrading")
    end,
})

--============================================================================
--  TAB 2  –  FARMING
--============================================================================
local mainSection   = farmingTab:AddSection("Auto Farming")
local toolsSection  = farmingTab:AddSection("Auto Tools")
local rocksSection  = farmingTab:AddSection("Auto Rocks")
local HideSection   = farmingTab:AddSection("Hide Features")

-- MAIN
mainSection:AddParagraph({
    Title = "Auto Machines",
    Content = "Select a machine and toggle Start to teleport and auto lift at that location.",
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
    Description = "Choose the machine to farm",
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
    Description = "Teleport to the selected machine and auto-lift (sends 'rep').",
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

-- TOOLS
toolsSection:AddParagraph({
    Title = "Auto Tools",
    Content = "Automatically use tools like Weight, Pushups, Punch.",
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
    Description = "Continuously move Punch from backpack to character.",
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

-- ROCKS
rocksSection:AddParagraph({
    Title = "Auto Rocks",
    Content = "Select which rock to hit and toggle Start to farm it.",
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
    Callback = function(val) selectedRock = val end,
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

-- Hide Features
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
    Title = "Kill Aura",
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

-- Combo
local comboActive = false
Killer:AddToggle("Punch When Dead | Combo (Protein Egg)", {
    Title = "Punch When Dead | Combo (Protein Egg)",
    Default = false,
    Description = "Single toggle: NaN size, AutoPunch",
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

-- Whitelist
local playerWhitelist = {}
Killer:AddToggle("AutoWhitelistFriends", {
    Title = "Auto Whitelist Friends",
    Default = false,
    Description = "Automatically Whitelist your Friends",
    Callback = function(state)
        local friendWhitelistActive = state
        if state then
            for _, player in ipairs(game:GetService("Players"):GetPlayers()) do
                if player ~= game.Players.LocalPlayer and game.Players.LocalPlayer:IsFriendsWith(player.UserId) then
                    playerWhitelist[player.Name] = true
                end
            end
            game:GetService("Players").PlayerAdded:Connect(function(player)
                if friendWhitelistActive and player ~= game.Players.LocalPlayer and game.Players.LocalPlayer:IsFriendsWith(player.UserId) then
                    playerWhitelist[player.Name] = true
                end
            end)
        else
            for name in pairs(playerWhitelist) do
                local friend = game:GetService("Players"):FindFirstChild(name)
                if friend and game.Players.LocalPlayer:IsFriendsWith(friend.UserId) then
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
        local target = game:GetService("Players"):FindFirstChild(text)
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
        local target = game:GetService("Players"):FindFirstChild(text)
        if target then
            playerWhitelist[target.Name] = nil
            Library:Notify({Title="Whitelist", Content = target.Name .. " removed from whitelist.", Duration = 3})
        else
            Library:Notify({Title="Whitelist", Content = "Player not found: " .. tostring(text), Duration = 3})
        end
    end,
})

-- Kill aura & manual target
Killer:AddToggle("AutoKill", {
    Title = "Auto Kill (Aura)",
    Default = false,
    Description = "Automatically 'kill' player near if applicable.",
    Callback = function(state)
        local autoKill = state
        task.spawn(function()
            while autoKill do
                local character = game.Players.LocalPlayer.Character or game.Players.LocalPlayer.CharacterAdded:Wait()
                local rightHand = character:FindFirstChild("RightHand") or character:FindFirstChild("Right Arm")
                local leftHand = character:FindFirstChild("LeftHand") or character:FindFirstChild("Left Arm")
                local punch = game.Players.LocalPlayer.Backpack and game.Players.LocalPlayer.Backpack:FindFirstChild("Punch")
                if punch and not character:FindFirstChild("Punch") then
                    pcall(function() punch.Parent = character end)
                end
                if rightHand and leftHand then
                    for _, target in ipairs(game:GetService("Players"):GetPlayers()) do
                        if target ~= game.Players.LocalPlayer and not playerWhitelist[target.Name] then
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

local targetPlayerNames = {}
local targetDropdown = Killer:AddDropdown("SelectTarget", {
    Title = "Select Target (add to list)",
    Values = {},
    Default = nil,
    Callback = function(name)
        if name and not table.find(targetPlayerNames, name) then
            table.insert(targetPlayerNames, name)
            Library:Notify({Title="Target", Content = name .. " added to target list.", Duration = 2})
        end
    end,
})

Killer:AddInput("RemoveTargetInput", {
    Title = "Remove Target From List",
    Default = "",
    Placeholder = "PlayerName",
    Callback = function(name)
        for i, v in ipairs(targetPlayerNames) do
            if v == name then
                table.remove(targetPlayerNames, i)
                Library:Notify({Title="Target", Content = name .. " removed.", Duration = 2})
                break
            end
        end
    end,
})

local function refreshTargetDropdown()
    local vals = {}
    for _, plr in ipairs(game:GetService("Players"):GetPlayers()) do
        if plr ~= game.Players.LocalPlayer then table.insert(vals, plr.Name) end
    end
    pcall(function() if targetDropdown and targetDropdown.SetValues then targetDropdown:SetValues(vals) end end)
end
refreshTargetDropdown()
game:GetService("Players").PlayerAdded:Connect(refreshTargetDropdown)
game:GetService("Players").PlayerRemoving:Connect(refreshTargetDropdown)

Killer:AddToggle("StartKillTarget", {
    Title = "Start Kill Target(s)",
    Default = false,
    Description = "Attack players listed in the target list.",
    Callback = function(state)
        local killTarget = state
        task.spawn(function()
            while killTarget do
                local character = game.Players.LocalPlayer.Character or game.Players.LocalPlayer.CharacterAdded:Wait()
                local punch = game.Players.LocalPlayer.Backpack:FindFirstChild("Punch")
                if punch and not character:FindFirstChild("Punch") then
                    pcall(function() punch.Parent = character end)
                end
                local rightHand = character:WaitForChild("RightHand", 5) or character:FindFirstChild("Right Arm")
                local leftHand = character:WaitForChild("LeftHand", 5) or character:FindFirstChild("Left Arm")
                if rightHand and leftHand then
                    for _, name in ipairs(targetPlayerNames) do
                        local target = game:GetService("Players"):FindFirstChild(name)
                        if target and target ~= game.Players.LocalPlayer then
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
                task.wait(0.05)
            end
        end)
    end,
})

-- View / Spy
local spyTargetName = nil
local spyDropdown = Killer:AddDropdown("SelectViewTarget", {
    Title = "Select View Target",
    Values = {},
    Default = nil,
    Callback = function(name)
        spyTargetName = name
        Library:Notify({Title="Spy", Content = "Selected " .. tostring(name) .. " for viewing.", Duration = 2})
    end,
})

local function refreshSpyDropdown()
    local vals = {}
    for _, plr in ipairs(game:GetService("Players"):GetPlayers()) do
        if plr ~= game.Players.LocalPlayer then table.insert(vals, plr.Name) end
    end
    pcall(function() if spyDropdown and spyDropdown.SetValues then spyDropdown:SetValues(vals) end end)
end
refreshSpyDropdown()
game:GetService("Players").PlayerAdded:Connect(refreshSpyDropdown)
game:GetService("Players").PlayerRemoving:Connect(refreshSpyDropdown)

Killer:AddToggle("ViewPlayer", {
    Title = "View / Un-view Player",
    Default = false,
    Description = "Switch camera to follow selected player.",
    Callback = function(bool)
        local cam = workspace.CurrentCamera
        local lp = game.Players.LocalPlayer

        -- user wants to stop spying (or we force-stop for them)
        if not bool then
            pcall(function()
                cam.CameraSubject = (lp.Character and lp.Character:FindFirstChild("Humanoid")) or lp
            end)
            return
        end

        -- start spying
        task.spawn(function()
            while Library.Toggles.ViewPlayer and Library.Toggles.ViewPlayer.Value do
                local target = game.Players:FindFirstChild(spyTargetName)
                if target and target ~= lp then
                    local humanoid = target.Character and target.Character:FindFirstChild("Humanoid")
                    if humanoid then
                        pcall(function() cam.CameraSubject = humanoid end)
                    end
                end
                task.wait(0.1)
            end

            -- loop ended: make sure camera is back on us
            pcall(function()
                cam.CameraSubject = (lp.Character and lp.Character:FindFirstChild("Humanoid")) or lp
            end)
        end)
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

local Players = game:GetService("Players")
local Stats = game:GetService("Stats")
local LocalPlayer = Players.LocalPlayer

local PET_NAME = "Swift Samurai"
local ROCK_NAME = "Rock5M"
local PROTEIN_EGG_NAME = "ProteinEgg"
local PROTEIN_EGG_INTERVAL = 30 * 60 -- 30 min
local REPS_PER_CYCLE = 160
local REP_DELAY = 0.01
local ROCK_INTERVAL = 5
local MAX_PING = 700

local HumanoidRootPart
local lastProteinEggTime = 0
local lastRockTime = 0
local RockRef = workspace:FindFirstChild(ROCK_NAME)

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

local function equipPet()
    local petsFolder = LocalPlayer:FindFirstChild("petsFolder")
    if petsFolder and petsFolder:FindFirstChild("Unique") then
        for _, pet in pairs(petsFolder.Unique:GetChildren()) do
            if pet.Name == PET_NAME then
                ReplicatedStorage.rEvents.equipPetEvent:FireServer("equipPet", pet)
                break
            end
        end
    end
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
        equipPet()
        lastProteinEggTime = tick()
        lastRockTime = tick()

        while true do
            if getgenv()._AutoRepFarmEnabled then
                local ping = getPing()
                if ping > MAX_PING then
                    warn("[Auto Rep Farm] ("..math.floor(ping).."ms), pause 3s...")
                    task.wait(5)
                else
                    if LocalPlayer:FindFirstChild("muscleEvent") then
                        for i = 1, REPS_PER_CYCLE do
                            LocalPlayer.muscleEvent:FireServer("rep")
                        end
                    end

                    if tick() - lastProteinEggTime >= PROTEIN_EGG_INTERVAL then
                        eatProteinEgg()
                        lastProteinEggTime = tick()
                    end

                    if tick() - lastRockTime >= ROCK_INTERVAL then
                        hitRock()
                        lastRockTime = tick()
                    end

                    task.wait(REP_DELAY)
                end
            else
                task.wait(1)
            end
        end
    end)
end
--============================================================================
--  END OF FILE
--============================================================================
