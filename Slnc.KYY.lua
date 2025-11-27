-- Load KyypieUI Library
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

-- Services
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

-- Player variables
local localPlayer = Players.LocalPlayer
local username = localPlayer.Name
local userId = localPlayer.UserId
local muscleEvent = localPlayer:WaitForChild("muscleEvent")
local leaderstats = localPlayer:WaitForChild("leaderstats")
local rebirthsStat = leaderstats:WaitForChild("Rebirths")

-- Create main window
local Window = Library:CreateWindow({
    Title = " KYYPIE HUB ",
    SubTitle = "Version 6.9 | by Markyy",
    Size = UDim2.fromOffset(500, 350),
    TabWidth = 150,
    Theme = "LightBlue",
    Acrylic = false,
})

-- Format number function
local function formatNumber(num)
    if num >= 1e15 then return string.format("%.2fQ", num/1e15) end
    if num >= 1e12 then return string.format("%.2fT", num/1e12) end
    if num >= 1e9 then return string.format("%.2fB", num/1e9) end
    if num >= 1e6 then return string.format("%.2fM", num/1e6) end
    if num >= 1e3 then return string.format("%.2fK", num/1e3) end
    return string.format("%.0f", num)
end

local rebirthTab = Window:AddTab({Title = "Fast Rebirth", Icon = "lucide-refresh-cw"})
local strengthTab = Window:AddTab({Title = "Fast Strength", Icon = "lucide-zap"})
local infoTab = Window:AddTab({Title = "Info", Icon = "lucide-info"})

-- Fast Rebirth variables
local packSection = rebirthTab:AddSection("PACKS FARM REBIRTH")

local isRunning = false
local startTime = 0
local totalElapsed = 0
local initialRebirths = rebirthsStat.Value
local rebirthCount = 0
local paceHistoryHour = {}
local paceHistoryDay = {}
local paceHistoryWeek = {}
local maxHistoryLength = 20

-- UI Elements for Fast Rebirth
local serverLabel = packSection:AddParagraph("Time:")
serverLabel:SetText("Time:")

local timeLabel = packSection:AddLabel("0d 0h 0m 0s - Inactive")
local paceLabel = packSection:AddLabel("Pace: 0 / Hour | 0 / Day | 0 / Week")
local averagePaceLabel = packSection:AddLabel("Average Pace: 0 / Hour | 0 / Day | 0 / Week")
local rebirthsStatsLabel = packSection:AddLabel("Rebirths: "..formatNumber(rebirthsStat.Value).." | Gained: 0")

-- Functions
local function updateRebirthsLabel()
    local gained = rebirthsStat.Value - initialRebirths
    rebirthsStatsLabel:SetText(string.format("Rebirths: %s | Gained: %s", 
                                           formatNumber(rebirthsStat.Value), 
                                           formatNumber(gained)))
end

local function updateUI()
    local currentTime = tick()
    local elapsed = isRunning and (currentTime - startTime + totalElapsed) or totalElapsed
    
    local days = math.floor(elapsed / 86400)
    local hours = math.floor((elapsed % 86400) / 3600)
    local minutes = math.floor((elapsed % 3600) / 60)
    local seconds = math.floor(elapsed % 60)
    
    timeLabel:SetText(string.format("%dd %dh %dm %ds - %s", days, hours, minutes, seconds,
                                 isRunning and "Rebirthing" or "Paused"))
end

local function calculatePaceOnRebirth()
    rebirthCount = rebirthCount + 1
    
    if rebirthCount < 2 then
        lastRebirthTime = tick()
        lastRebirthValue = rebirthsStat.Value
        return
    end

    local now = tick()
    local gained = rebirthsStat.Value - lastRebirthValue

    if gained > 0 then
        local avgTimePerRebirth = (now - lastRebirthTime) / gained
        local paceHour = 3600 / avgTimePerRebirth
        local paceDay = 86400 / avgTimePerRebirth
        local paceWeek = 604800 / avgTimePerRebirth

        paceLabel:SetText(string.format("Pace: %s / Hour | %s / Day | %s / Week",
            formatNumber(paceHour), formatNumber(paceDay), formatNumber(paceWeek)))

        table.insert(paceHistoryHour, paceHour)
        table.insert(paceHistoryDay, paceDay)
        table.insert(paceHistoryWeek, paceWeek)

        if #paceHistoryHour > maxHistoryLength then
            table.remove(paceHistoryHour, 1)
            table.remove(paceHistoryDay, 1)
            table.remove(paceHistoryWeek, 1)
        end

        local function average(tbl)
            local sum = 0
            for _, v in ipairs(tbl) do
                sum = sum + v
            end
            return #tbl > 0 and (sum / #tbl) or 0
        end

        local avgHour = average(paceHistoryHour)
        local avgDay = average(paceHistoryDay)
        local avgWeek = average(paceHistoryWeek)

        averagePaceLabel:SetText(string.format("Average Pace: %s / Hour | %s / Day | %s / Week",
            formatNumber(avgHour), formatNumber(avgDay), formatNumber(avgWeek)))

        lastRebirthTime = now
        lastRebirthValue = rebirthsStat.Value
    end
end

local function managePets(petName)
    for _, folder in pairs(localPlayer.petsFolder:GetChildren()) do
        if folder:IsA("Folder") then
            for _, pet in pairs(folder:GetChildren()) do
                ReplicatedStorage.rEvents.equipPetEvent:FireServer("unequipPet", pet)
            end
        end
    end
    task.wait(0.1)
    
    for _, pet in pairs(localPlayer.petsFolder.Unique:GetChildren()) do
        if pet.Name == petName then
            ReplicatedStorage.rEvents.equipPetEvent:FireServer("equipPet", pet)
        end
    end
end

local function doRebirth()
    local rebirths = rebirthsStat.Value
    local strengthTarget = 5000 + (rebirths * 2550)
    
    while isRunning and localPlayer.leaderstats.Strength.Value < strengthTarget do
        local reps = localPlayer.MembershipType == Enum.MembershipType.Premium and 8 or 14
        for _ = 1, reps do
            muscleEvent:FireServer("rep")
        end
        task.wait(0.02)
    end
    
    if isRunning and localPlayer.leaderstats.Strength.Value >= strengthTarget then
        managePets("Tribal Overlord")
        task.wait(0.25)
        
        local before = rebirthsStat.Value
        repeat
            ReplicatedStorage.rEvents.rebirthRemote:InvokeServer("rebirthRequest")
            task.wait(0.05)
        until rebirthsStat.Value > before or not isRunning
    end
end

local function fastRebirthLoop()
    while isRunning do
        managePets("Swift Samurai")
        doRebirth()
        task.wait(0.5)
    end
end

-- Fast Rebirth Toggle
packSection:AddToggle("FastRebirth", {
    Title = "Fast Rebirth",
    Default = false,
    Callback = function(state)
        isRunning = state
        
        if state then
            startTime = tick()
            task.spawn(fastRebirthLoop)
        else
            totalElapsed = totalElapsed + (tick() - startTime)
            updateUI()
        end
    end
})

-- Hide frames
local blockedFrames = {
    "strengthFrame",
    "durabilityFrame", 
    "agilityFrame",
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

-- Update UI loop
task.spawn(function()
    while true do
        updateUI()
        task.wait(0.1)
    end
end)

-- Rebirth stat changed
rebirthsStat:GetPropertyChangedSignal("Value"):Connect(function()
    calculatePaceOnRebirth()
    updateRebirthsLabel() 
end)

-- Size Switch
local sizeRunning = false
local sizeThread = nil

packSection:AddToggle("SetSize1", {
    Title = "Set Size 1",
    Default = false,
    Callback = function(bool)
        sizeRunning = bool
        if sizeRunning then
            sizeThread = coroutine.create(function()
                while sizeRunning do
                    game:GetService("ReplicatedStorage").rEvents.changeSpeedSizeRemote:InvokeServer("changeSize", 1)
                    wait(0.01)
                end
            end)
            coroutine.resume(sizeThread)
        end
    end
})

-- Anti Lag Button
packSection:AddButton({
    Title = "Anti Lag",
    Callback = function()
        local player = game.Players.LocalPlayer
        local playerGui = player:WaitForChild("PlayerGui")
        local lighting = game:GetService("Lighting")

        for _, gui in pairs(playerGui:GetChildren()) do
            if gui:IsA("ScreenGui") then
                gui:Destroy()
            end
        end

        local function darkenSky()
            for _, v in pairs(lighting:GetChildren()) do
                if v:IsA("Sky") then
                    v:Destroy()
                end
            end

            local darkSky = Instance.new("Sky")
            darkSky.Name = "DarkSky"
            darkSky.SkyboxBk = "rbxassetid://0"
            darkSky.SkyboxDn = "rbxassetid://0"
            darkSky.SkyboxFt = "rbxassetid://0"
            darkSky.SkyboxLf = "rbxassetid://0"
            darkSky.SkyboxRt = "rbxassetid://0"
            darkSky.SkyboxUp = "rbxassetid://0"
            darkSky.Parent = lighting

            lighting.Brightness = 0
            lighting.ClockTime = 0
            lighting.TimeOfDay = "00:00:00"
            lighting.OutdoorAmbient = Color3.new(0, 0, 0)
            lighting.Ambient = Color3.new(0, 0, 0)
            lighting.FogColor = Color3.new(0, 0, 0)
            lighting.FogEnd = 100

            task.spawn(function()
                while true do
                    wait(5)
                    if not lighting:FindFirstChild("DarkSky") then
                        darkSky:Clone().Parent = lighting
                    end
                    lighting.Brightness = 0
                    lighting.ClockTime = 0
                    lighting.OutdoorAmbient = Color3.new(0, 0, 0)
                    lighting.Ambient = Color3.new(0, 0, 0)
                    lighting.FogColor = Color3.new(0, 0, 0)
                    lighting.FogEnd = 100
                end
            end)
        end

        local function removeParticleEffects()
            for _, obj in pairs(workspace:GetDescendants()) do
                if obj:IsA("ParticleEmitter") then
                    obj:Destroy()
                end
            end
        end

        local function removeLightSources()
            for _, obj in pairs(workspace:GetDescendants()) do
                if obj:IsA("PointLight") or obj:IsA("SpotLight") or obj:IsA("SurfaceLight") then
                    obj:Destroy()
                end
            end
        end

        removeParticleEffects()
        removeLightSources()
        darkenSky()
    end
})

-- Lock Position
local lockRunning = false
local lockThread = nil

packSection:AddToggle("LockPosition", {
    Title = "Lock Position",
    Default = false,
    Callback = function(state)
        lockRunning = state
        if lockRunning then
            local player = game.Players.LocalPlayer
            local char = player.Character or player.CharacterAdded:Wait()
            local hrp = char:WaitForChild("HumanoidRootPart")
            local lockPosition = hrp.Position

            lockThread = coroutine.create(function()
                while lockRunning do
                    hrp.Velocity = Vector3.new(0, 0, 0)
                    hrp.RotVelocity = Vector3.new(0, 0, 0)
                    hrp.CFrame = CFrame.new(lockPosition)
                    wait(0.05) 
                end
            end)

            coroutine.resume(lockThread)
        end
    end
})

-- Auto Shake
local shakeRunning = false

local function activateShake()
    local tool = localPlayer.Character:FindFirstChild("Tropical Shake") or localPlayer.Backpack:FindFirstChild("Tropical Shake")
    if tool then
        muscleEvent:FireServer("tropicalShake", tool)
    end
end

task.spawn(function()
    while true do
        if shakeRunning then
            activateShake()
            task.wait(450)
        else
            task.wait(1)
        end
    end
end)

packSection:AddToggle("AutoShake", {
    Title = "Auto Shake",
    Default = false,
    Callback = function(state)
        shakeRunning = state
        if state then
            activateShake()
        end
    end
})

-- Spin Fortune Wheel
packSection:AddToggle("SpinFortuneWheel", {
    Title = "Spin Fortune Wheel",
    Default = false,
    Callback = function(bool)
        _G.AutoSpinWheel = bool
        
        if bool then
            spawn(function()
                while _G.AutoSpinWheel and wait(1) do
                    game:GetService("ReplicatedStorage").rEvents.openFortuneWheelRemote:InvokeServer("openFortuneWheel", game:GetService("ReplicatedStorage").fortuneWheelChances["Fortune Wheel"])
                end
            end)
        end
    end
})

-- Jungle Lift
packSection:AddButton({
    Title = "Jungle Lift",
    Callback = function()
        local player = game.Players.LocalPlayer
        local char = player.Character or localPlayer.CharacterAdded:wait()
        local hrp = char:WaitForChild("HumanoidRootPart")
        hrp.CFrame = CFrame.new(-8642.396484375, 6.7980651855, 2086.1030273)
        task.wait(0.2)
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
        task.wait(0.05)
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
    end
})

-- Fast Farm Tab
local fastSection = strengthTab:AddSection("PACKS FARM STRENGTH")

local strengthStat = leaderstats:WaitForChild("Strength")
local durabilityStat = localPlayer:WaitForChild("Durability")

-- Fast Farm variables
local runFastRep = false
local trackingStarted = false
local startTime = 0
local pausedElapsedTime = 0
local initialStrength = strengthStat.Value
local initialDurability = durabilityStat.Value

-- UI Elements for Fast Farm
local stopwatchLabel = FarmingTab:AddLabel("0d 0h 0m 0s - Fast Rep Inactive")
local projectedStrengthLabel = FarmingTab:AddLabel("Strength Pace: 0 /Hour | 0 /Day | 0 /Week")
local projectedDurabilityLabel = FarmingTab:AddLabel("Durability Pace: 0 /Hour | 0 /Day | 0 /Week")
local averageStrengthLabel = FarmingTab:AddLabel("Average Strength Pace: 0 /Hour | 0 /Day | 0 /Week")
local averageDurabilityLabel = FarmingTab:AddLabel("Average Durability Pace: 0 /Hour | 0 /Day | 0 /Week")
local strengthLabel = FarmingTab:AddLabel("Strength: 0 | Gained: 0")
local durabilityLabel = FarmingTab:AddLabel("Durability: 0 | Gained: 0")

-- Update labels
task.spawn(function()
    local lastCalcTime = tick()
    local strengthHistory = {}
    local durabilityHistory = {}
    local calculationInterval = 10
    
    while true do
        local currentTime = tick()
        local currentStrength = strengthStat.Value
        local currentDurability = durabilityStat.Value

        strengthLabel:SetText("Strength: " .. formatNumber(currentStrength) .. " | Gained: " .. formatNumber(currentStrength - initialStrength))
        durabilityLabel:SetText("Durability: " .. formatNumber(currentDurability) .. " | Gained: " .. formatNumber(currentDurability - initialDurability))

        if runFastRep then
            if not trackingStarted then
                trackingStarted = true
                startTime = currentTime
                strengthHistory = {}
                durabilityHistory = {}
            end
            local elapsedTime = pausedElapsedTime + (currentTime - startTime)
            local days = math.floor(elapsedTime / (24 * 3600))
            local hours = math.floor((elapsedTime % (24 * 3600)) / 3600)
            local minutes = math.floor((elapsedTime % 3600) / 60)
            local seconds = math.floor(elapsedTime % 60)
            stopwatchLabel:SetText(string.format("%dd %dh %dm %ds - Fast Rep Running", days, hours, minutes, seconds))

            table.insert(strengthHistory, {time = currentTime, value = currentStrength})
            table.insert(durabilityHistory, {time = currentTime, value = currentDurability})

            while #strengthHistory > 0 and currentTime - strengthHistory[1].time > calculationInterval do
                table.remove(strengthHistory, 1)
            end
            while #durabilityHistory > 0 and currentTime - durabilityHistory[1].time > calculationInterval do
                table.remove(durabilityHistory, 1)
            end

            if currentTime - lastCalcTime >= calculationInterval then
                lastCalcTime = currentTime

                if #strengthHistory >= 2 then
                    local strengthDelta = strengthHistory[#strengthHistory].value - strengthHistory[1].value
                    local strengthPerSecond = strengthDelta / calculationInterval
                    local strengthPerHour = strengthPerSecond * 3600
                    local strengthPerDay = strengthPerSecond * 86400
                    local strengthPerWeek = strengthPerSecond * 604800
                    projectedStrengthLabel:SetText("Strength Pace: " .. formatNumber(strengthPerHour) .. "/Hour | " .. formatNumber(strengthPerDay) .. "/Day | " .. formatNumber(strengthPerWeek) .. "/Week")
                end

                if #durabilityHistory >= 2 then
                    local durabilityDelta = durabilityHistory[#durabilityHistory].value - durabilityHistory[1].value
                    local durabilityPerSecond = durabilityDelta / calculationInterval
                    local durabilityPerHour = durabilityPerSecond * 3600
                    local durabilityPerDay = durabilityPerSecond * 86400
                    local durabilityPerWeek = durabilityPerSecond * 604800
                    projectedDurabilityLabel:SetText("Durability Pace: " .. formatNumber(durabilityPerHour) .. "/Hour | " .. formatNumber(durabilityPerDay) .. "/Day | " .. formatNumber(durabilityPerWeek) .. "/Week")
                end

                local totalElapsed = pausedElapsedTime + (currentTime - startTime)
                if totalElapsed > 0 then
                    local avgStrengthPerSecond = (currentStrength - initialStrength) / totalElapsed
                    local avgStrengthPerHour = avgStrengthPerSecond * 3600
                    local avgStrengthPerDay = avgStrengthPerSecond * 86400
                    local avgStrengthPerWeek = avgStrengthPerSecond * 604800
                    averageStrengthLabel:SetText("Average Strength Pace: " .. formatNumber(avgStrengthPerHour) .. "/Hour | " .. formatNumber(avgStrengthPerDay) .. "/Day | " .. formatNumber(avgStrengthPerWeek) .. "/Week")

                    local avgDurabilityPerSecond = (currentDurability - initialDurability) / totalElapsed
                    local avgDurabilityPerHour = avgDurabilityPerSecond * 3600
                    local avgDurabilityPerDay = avgDurabilityPerSecond * 86400
                    local avgDurabilityPerWeek = avgDurabilityPerSecond * 604800
                    averageDurabilityLabel:SetText("Average Durability Pace: " .. formatNumber(avgDurabilityPerHour) .. "/Hour | " .. formatNumber(avgDurabilityPerDay) .. "/Day | " .. formatNumber(avgDurabilityPerWeek) .. "/Week")
                end
            end
        else
            if trackingStarted then
                trackingStarted = false
                pausedElapsedTime = pausedElapsedTime + (currentTime - startTime)
                stopwatchLabel:SetText(string.format("%dd %dh %dm %ds - Fast Rep Stopped", math.floor(pausedElapsedTime / (24 * 3600)), math.floor((pausedElapsedTime % (24 * 3600)) / 3600), math.floor((pausedElapsedTime % 3600) / 60), math.floor(pausedElapsedTime % 60)))

                projectedStrengthLabel:SetText("Strength Pace: 0 /Hour | 0 /Day | 0 /Week")
                projectedDurabilityLabel:SetText("Durability Pace: 0 /Hour | 0 /Day | 0 /Week")
                averageStrengthLabel:SetText("Average Strength Pace: 0 /Hour | 0 /Day | 0 /Week")
                averageDurabilityLabel:SetText("Average Durability Pace: 0 /Hour | 0 /Day | 0 /Week")

                strengthHistory = {}
                durabilityHistory = {}
            end
        end

        task.wait(0.05)
    end
end)

-- Rep Speed Input
local repsPerTick = 1

local function getPing()
    local stats = game:GetService("Stats")
    local pingStat = stats:FindFirstChild("PerformanceStats") and stats.PerformanceStats:FindFirstChild("Ping")
    return pingStat and pingStat:GetValue() or 0
end

fastSection:AddInput("RepSpeed", {
    Title = "Rep Speed",
    Default = "1",
    Numeric = true,
    Finished = true,
    Callback = function(value)
        local num = tonumber(value)
        if num and num > 0 then
            repsPerTick = math.floor(num)
        end
    end
})

-- Fast Rep Toggle
local function fastRepLoop()
    while runFastRep do
        local startTick = tick()
        while tick() - startTick < 0.75 and runFastRep do
            for i = 1, repsPerTick do
                muscleEvent:FireServer("rep")
            end
            task.wait(0.02)
        end
        while runFastRep and getPing() >= 350 do
            task.wait(1)
        end
    end
end

fastSection:AddToggle("FastRep", {
    Title = "Fast Rep",
    Default = false,
    Callback = function(state)
        if state and not runFastRep then
            runFastRep = true
            task.spawn(fastRepLoop)
        elseif not state and runFastRep then
            runFastRep = false
        end
    end
})

-- Auto Egg
local function activateProteinEgg()
    local tool = localPlayer.Character:FindFirstChild("Protein Egg") or localPlayer.Backpack:FindFirstChild("Protein Egg")
    if tool then
        muscleEvent:FireServer("proteinEgg", tool)
    end
end

local eggRunning = false

task.spawn(function()
    while true do
        if eggRunning then
            activateProteinEgg()
            task.wait(1800)
        else
            task.wait(1)
        end
    end
end)

fastSection:AddToggle("AutoEgg", {
    Title = "Auto Egg",
    Default = false,
    Callback = function(state)
        eggRunning = state
        if state then
            activateProteinEgg()
        end
    end
})

-- Auto Shake (duplicate for farming tab)
local shakeRunning2 = false

local function activateShake2()
    local tool = localPlayer.Character:FindFirstChild("Tropical Shake") or localPlayer.Backpack:FindFirstChild("Tropical Shake")
    if tool then
        muscleEvent:FireServer("tropicalShake", tool)
    end
end

task.spawn(function()
    while true do
        if shakeRunning2 then
            activateShake2()
            task.wait(900)
        else
            task.wait(1)
        end
    end
end)

fastSection:AddToggle("AutoShakeFarm", {
    Title = "Auto Shake",
    Default = false,
    Callback = function(state)
        shakeRunning2 = state
        if state then
            activateShake2()
        end
    end
})

-- Spin Fortune Wheel (duplicate for farming tab)
fastSection:AddToggle("SpinFortuneWheelFarm", {
    Title = "Spin Fortune Wheel",
    Default = false,
    Callback = function(bool)
        _G.AutoSpinWheel = bool
        
        if bool then
            spawn(function()
                while _G.AutoSpinWheel and wait(1) do
                    game:GetService("ReplicatedStorage").rEvents.openFortuneWheelRemote:InvokeServer("openFortuneWheel", game:GetService("ReplicatedStorage").fortuneWheelChances["Fortune Wheel"])
                end
            end)
        end
    end
})

-- Jungle Squat
fastSection:AddButton({
    Title = "Jungle Squat",
    Callback = function()
        local player = game.Players.LocalPlayer
        local char = player.Character or localPlayer.CharacterAdded:wait()
        local hrp = char:WaitForChild("HumanoidRootPart")
        hrp.CFrame = CFrame.new(-8371.43359375, 6.79806327, 2858.88525390)
        task.wait(0.2)
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
        task.wait(0.05)
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
    end
})

-- Anti Lag (duplicate for farming tab)
fastSection:AddButton({
    Title = "Anti Lag",
    Callback = function()
        local player = game.Players.LocalPlayer
        local playerGui = player:WaitForChild("PlayerGui")
        local lighting = game:GetService("Lighting")

        for _, gui in pairs(playerGui:GetChildren()) do
            if gui:IsA("ScreenGui") then
                gui:Destroy()
            end
        end

        local function darkenSky()
            for _, v in pairs(lighting:GetChildren()) do
                if v:IsA("Sky") then
                    v:Destroy()
                end
            end

            local darkSky = Instance.new("Sky")
            darkSky.Name = "DarkSky"
            darkSky.SkyboxBk = "rbxassetid://0"
            darkSky.SkyboxDn = "rbxassetid://0"
            darkSky.SkyboxFt = "rbxassetid://0"
            darkSky.SkyboxLf = "rbxassetid://0"
            darkSky.SkyboxRt = "rbxassetid://0"
            darkSky.SkyboxUp = "rbxassetid://0"
            darkSky.Parent = lighting

            lighting.Brightness = 0
            lighting.ClockTime = 0
            lighting.TimeOfDay = "00:00:00"
            lighting.OutdoorAmbient = Color3.new(0, 0, 0)
            lighting.Ambient = Color3.new(0, 0, 0)
            lighting.FogColor = Color3.new(0, 0, 0)
            lighting.FogEnd = 100

            task.spawn(function()
                while true do
                    wait(5)
                    if not lighting:FindFirstChild("DarkSky") then
                        darkSky:Clone().Parent = lighting
                    end
                    lighting.Brightness = 0
                    lighting.ClockTime = 0
                    lighting.OutdoorAmbient = Color3.new(0, 0, 0)
                    lighting.Ambient = Color3.new(0, 0, 0)
                    lighting.FogColor = Color3.new(0, 0, 0)
                    lighting.FogEnd = 100
                end
            end)
        end

        local function removeParticleEffects()
            for _, obj in pairs(workspace:GetDescendants()) do
                if obj:IsA("ParticleEmitter") then
                    obj:Destroy()
                end
            end
        end

        local function removeLightSources()
            for _, obj in pairs(workspace:GetDescendants()) do
                if obj:IsA("PointLight") or obj:IsA("SpotLight") or obj:IsA("SurfaceLight") then
                    obj:Destroy()
                end
            end
        end

        removeParticleEffects()
        removeLightSources()
        darkenSky()
    end
})

-- Equip Swift Samurai
fastSection:AddButton({
    Title = "Equip Swift Samurai",
    Callback = function()
        local function unequipPets()
            for _, folder in pairs(localPlayer.petsFolder:GetChildren()) do
                if folder:IsA("Folder") then
                    for _, pet in pairs(folder:GetChildren()) do
                        ReplicatedStorage.rEvents.equipPetEvent:FireServer("unequipPet", pet)
                    end
                end
            end
            task.wait(0.1)
        end

        local function equipPetsByName(name)
            unequipPets()
            task.wait(0.01)
            for _, pet in pairs(localPlayer.petsFolder.Unique:GetChildren()) do
                if pet.Name == name then
                    ReplicatedStorage.rEvents.equipPetEvent:FireServer("equipPet", pet)
                end
            end
        end
        
        equipPetsByName("Swift Samurai")
    end
})

-- Info Tab
local infSection = infoTab:AddSection("INFORMATION")

infSection:AddLabel("Made by KYY ♥️")
infSection:AddLabel("discord.gg/silencev1")

infSection:AddButton({
    Title = "Copy Invite",
    Callback = function()
        local link = "https://discord.gg/9eFf93Kg8D"
        if setclipboard then
            setclipboard(link)
            game.StarterGui:SetCore("SendNotification", {
                Title = "Link Copied!";
                Text = "You can continue to Discord now.";
                Duration = 3;
            })
        else
            game.StarterGui:SetCore("SendNotification", {
                Title = "Error!";
                Text = "Not Supported.";
                Duration = 3;
            })
        end
    end
})

infSection:AddLabel("VERSION//6.9.6.9")

-- Initialize SaveManager and InterfaceManager
SaveManager:SetLibrary(Library)
InterfaceManager:SetLibrary(Library)
InterfaceManager:SetFolder("SilenceV2Farming")

-- Build interface section
InterfaceManager:BuildInterfaceSection(infoTab)

-- Build config section  
SaveManager:BuildConfigSection(infoTab)

-- Load settings
InterfaceManager:LoadSettings()
SaveManager:LoadAutoloadConfig()

-- Show notification
Library:Notify({
    Title = "Markyy Creampied ur ASS!",
    Content = "Successfully loaded Kyypie-UI!",
    Duration = 5
})
