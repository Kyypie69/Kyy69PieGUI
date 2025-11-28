-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualInputManager = game:GetService("VirtualInputManager")

-- Player
local player = Players.LocalPlayer
local leaderstats = player:WaitForChild("leaderstats")
local rebirthsStat = leaderstats:WaitForChild("Rebirths")
local strengthStat = leaderstats:WaitForChild("Strength")
local durabilityStat = player:WaitForChild("Durability")
local muscleEvent = player:WaitForChild("muscleEvent")

-- UI Library
local LIB_URL = "https://raw.githubusercontent.com/Kyypie69/Library.UI/refs/heads/main/KyypieUI.lua"
local ok, Library, SaveManager, InterfaceManager = pcall(function()
    return loadstring(game:HttpGet(LIB_URL))()
end)

if not ok then
    if getgenv and getgenv().Fluent then
        Library = getgenv().Fluent
        warn("Fallback: Loaded from getgenv().Fluent")
    else
        error("Failed to load UI library: " .. tostring(Library))
    end
end

-- Window
local window = Library:AddWindow("Silence | Farming", {
    main_color = Color3.fromRGB(138, 0, 0),
    min_size = Vector2.new(600, 600),
    can_resize = false
})

-- Utility Functions
local function formatNumber(num)
    local abs = math.abs(num)
    if abs >= 1e15 then return string.format("%.2fQ", num / 1e15) end
    if abs >= 1e12 then return string.format("%.2fT", num / 1e12) end
    if abs >= 1e9 then return string.format("%.2fB", num / 1e9) end
    if abs >= 1e6 then return string.format("%.2fM", num / 1e6) end
    if abs >= 1e3 then return string.format("%.2fK", num / 1e3) end
    return string.format("%.0f", num)
end

local function unequipAllPets()
    for _, folder in pairs(player.petsFolder:GetChildren()) do
        if folder:IsA("Folder") then
            for _, pet in pairs(folder:GetChildren()) do
                ReplicatedStorage.rEvents.equipPetEvent:FireServer("unequipPet", pet)
            end
        end
    end
end

local function equipPetByName(name)
    unequipAllPets()
    task.wait(0.1)
    for _, pet in pairs(player.petsFolder.Unique:GetChildren()) do
        if pet.Name == name then
            ReplicatedStorage.rEvents.equipPetEvent:FireServer("equipPet", pet)
        end
    end
end

-- Anti Lag
local function applyAntiLag()
    local playerGui = player:WaitForChild("PlayerGui")
    local lighting = game:GetService("Lighting")

    for _, gui in pairs(playerGui:GetChildren()) do
        if gui:IsA("ScreenGui") then gui:Destroy() end
    end

    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("ParticleEmitter") or obj:IsA("PointLight") or obj:IsA("SpotLight") or obj:IsA("SurfaceLight") then
            obj:Destroy()
        end
    end

    for _, sky in pairs(lighting:GetChildren()) do
        if sky:IsA("Sky") then sky:Destroy() end
    end

    local darkSky = Instance.new("Sky")
    darkSky.Name = "DarkSky"
    for _, prop in {"SkyboxBk", "SkyboxDn", "SkyboxFt", "SkyboxLf", "SkyboxRt", "SkyboxUp"} do
        darkSky[prop] = "rbxassetid://0"
    end
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
            task.wait(5)
            if not lighting:FindFirstChild("DarkSky") then darkSky:Clone().Parent = lighting end
            lighting.Brightness = 0
            lighting.ClockTime = 0
            lighting.OutdoorAmbient = Color3.new(0, 0, 0)
            lighting.Ambient = Color3.new(0, 0, 0)
            lighting.FogColor = Color3.new(0, 0, 0)
            lighting.FogEnd = 100
        end
    end)
end

-- Tabs
local FastRebTab = window:AddTab("Fast Rebirth")
local FarmingTab = window:AddTab("Fast Farm")
local InfoTab = window:AddTab("Info")
InfoTab:Show()

-- Fast Rebirth Logic
local isRebirthRunning = false
local rebirthStartTime = 0
local totalRebirthElapsed = 0
local initialRebirths = rebirthsStat.Value
local lastRebirthTime = tick()
local lastRebirthValue = rebirthsStat.Value
local paceHistory = {hour = {}, day = {}, week = {}}
local rebirthCount = 0

-- Labels
local timeLabel = FastRebTab:AddLabel("0d 0h 0m 0s - Inactive")
local paceLabel = FastRebTab:AddLabel("Pace: 0 / Hour | 0 / Day | 0 / Week")
local avgPaceLabel = FastRebTab:AddLabel("Average Pace: 0 / Hour | 0 / Day | 0 / Week")
local rebirthsLabel = FastRebTab:AddLabel("Rebirths: 0 | Gained: 0")

local function updateRebirthLabels()
    local gained = rebirthsStat.Value - initialRebirths
    rebirthsLabel.Text = string.format("Rebirths: %s | Gained: %s", formatNumber(rebirthsStat.Value), formatNumber(gained))
end

local function updateRebirthUI()
    local elapsed = isRebirthRunning and (tick() - rebirthStartTime + totalRebirthElapsed) or totalRebirthElapsed
    local d, h, m, s = math.floor(elapsed / 86400), math.floor(elapsed % 86400 / 3600), math.floor(elapsed % 3600 / 60), math.floor(elapsed % 60)
    timeLabel.Text = string.format("%dd %dh %dm %ds - %s", d, h, m, s, isRebirthRunning and "Rebirthing" or "Paused")
    timeLabel.TextColor3 = isRebirthRunning and Color3.fromRGB(50, 255, 50) or Color3.fromRGB(255, 50, 50)
end

local function calculateRebirthPace()
    rebirthCount += 1
    if rebirthCount < 2 then
        lastRebirthTime = tick()
        lastRebirthValue = rebirthsStat.Value
        return
    end

    local gained = rebirthsStat.Value - lastRebirthValue
    if gained <= 0 then return end

    local now = tick()
    local avg = (now - lastRebirthTime) / gained
    local ph, pd, pw = 3600 / avg, 86400 / avg, 604800 / avg

    paceLabel.Text = string.format("Pace: %s / Hour | %s / Day | %s / Week", formatNumber(ph), formatNumber(pd), formatNumber(pw))

    table.insert(paceHistory.hour, ph)
    table.insert(paceHistory.day, pd)
    table.insert(paceHistory.week, pw)
    if #paceHistory.hour > 20 then
        table.remove(paceHistory.hour, 1)
        table.remove(paceHistory.day, 1)
        table.remove(paceHistory.week, 1)
    end

    local avgH = 0
    for _, v in ipairs(paceHistory.hour) do avgH = avgH + v end
    avgH = #paceHistory.hour > 0 and avgH / #paceHistory.hour or 0
    local avgD = 0
    for _, v in ipairs(paceHistory.day) do avgD = avgD + v end
    avgD = #paceHistory.day > 0 and avgD / #paceHistory.day or 0
    local avgW = 0
    for _, v in ipairs(paceHistory.week) do avgW = avgW + v end
    avgW = #paceHistory.week > 0 and avgW / #paceHistory.week or 0

    avgPaceLabel.Text = string.format("Average Pace: %s / Hour | %s / Day | %s / Week", formatNumber(avgH), formatNumber(avgD), formatNumber(avgW))

    lastRebirthTime = now
    lastRebirthValue = rebirthsStat.Value
end

local function doRebirth()
    local target = 5000 + rebirthsStat.Value * 2550
    while isRebirthRunning and strengthStat.Value < target do
        local reps = player.MembershipType == Enum.MembershipType.Premium and 8 or 14
        for _ = 1, reps do muscleEvent:FireServer("rep") end
        task.wait(0.02)
    end
    if isRebirthRunning and strengthStat.Value >= target then
        equipPetByName("Tribal Overlord")
        task.wait(0.25)
        local before = rebirthsStat.Value
        repeat
            ReplicatedStorage.rEvents.rebirthRemote:InvokeServer("rebirthRequest")
            task.wait(0.05)
        until rebirthsStat.Value > before or not isRebirthRunning
    end
end

local function fastRebirthLoop()
    while isRebirthRunning do
        equipPetByName("Swift Samurai")
        doRebirth()
        task.wait(0.5)
    end
end

-- UI
FastRebTab:AddLabel("Rebirthing:").TextSize = 20
FastRebTab:AddSwitch("Fast Rebirth", function(state)
    isRebirthRunning = state
    if state then
        rebirthStartTime = tick()
        task.spawn(fastRebirthLoop)
    else
        totalRebirthElapsed += tick() - rebirthStartTime
        updateRebirthUI()
    end
end)

FastRebTab:AddSwitch("Set Size 1", function(bool)
    while bool do
        ReplicatedStorage.rEvents.changeSpeedSizeRemote:InvokeServer("changeSize", 1)
        task.wait(0.01)
    end
end)

FastRebTab:AddButton("Anti Lag", applyAntiLag)

FastRebTab:AddLabel("Misc:").TextSize = 20

FastRebTab:AddSwitch("Lock Position", function(state)
    local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local pos = hrp.Position
    while state do
        hrp.Velocity = Vector3.new(0, 0, 0)
        hrp.RotVelocity = Vector3.new(0, 0, 0)
        hrp.CFrame = CFrame.new(pos)
        task.wait(0.05)
    end
end)

local shakeRunning = false
task.spawn(function()
    while true do
        if shakeRunning then
            local tool = player.Character:FindFirstChild("Tropical Shake") or player.Backpack:FindFirstChild("Tropical Shake")
            if tool then muscleEvent:FireServer("tropicalShake", tool) end
            task.wait(450)
        else
            task.wait(1)
        end
    end
end)

FastRebTab:AddSwitch("Auto Shake", function(state)
    shakeRunning = state
    if state then
        local tool = player.Character:FindFirstChild("Tropical Shake") or player.Backpack:FindFirstChild("Tropical Shake")
        if tool then muscleEvent:FireServer("tropicalShake", tool) end
    end
end)

FastRebTab:AddSwitch("Spin Fortune Wheel", function(bool)
    _G.AutoSpinWheel = bool
    while _G.AutoSpinWheel do
        ReplicatedStorage.rEvents.openFortuneWheelRemote:InvokeServer("openFortuneWheel", ReplicatedStorage.fortuneWheelChances["Fortune Wheel"])
        task.wait(1)
    end
end)

FastRebTab:AddButton("Jungle Lift", function()
    local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if hrp then
        hrp.CFrame = CFrame.new(-8642.396484375, 6.7980651855, 2086.1030273)
        task.wait(0.2)
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
        task.wait(0.05)
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
    end
end)

-- Farming Tab
local farmStartTime = 0
local farmPausedTime = 0
local farmRunning = false
local farmTracking = false
local initialStrength = strengthStat.Value
local initialDurability = durabilityStat.Value
local strengthHist = {}
local durabilityHist = {}
local calcInterval = 10

local farmTimeLabel = FarmingTab:AddLabel("0d 0h 0m 0s - Fast Rep Inactive")
local strPaceLabel = FarmingTab:AddLabel("Strength Pace: 0 /Hour | 0 /Day | 0 /Week")
local durPaceLabel = FarmingTab:AddLabel("Durability Pace: 0 /Hour | 0 /Day | 0 /Week")
local avgStrPaceLabel = FarmingTab:AddLabel("Average Strength Pace: 0 /Hour | 0 /Day | 0 /Week")
local avgDurPaceLabel = FarmingTab:AddLabel("Average Durability Pace: 0 /Hour | 0 /Day | 0 /Week")
local strLabel = FarmingTab:AddLabel("Strength: 0 | Gained: 0")
local durLabel = FarmingTab:AddLabel("Durability: 0 | Gained: 0")

local function updateFarmLabels()
    local str = strengthStat.Value
    local dur = durabilityStat.Value
    strLabel.Text = "Strength: " .. formatNumber(str) .. " | Gained: " .. formatNumber(str - initialStrength)
    durLabel.Text = "Durability: " .. formatNumber(dur) .. " | Gained: " .. formatNumber(dur - initialDurability)
end

local function updateFarmUI()
    local elapsed = farmRunning and (tick() - farmStartTime + farmPausedTime) or farmPausedTime
    local d, h, m, s = math.floor(elapsed / 86400), math.floor(elapsed % 86400 / 3600), math.floor(elapsed % 3600 / 60), math.floor(elapsed % 60)
    farmTimeLabel.Text = string.format("%dd %dh %dm %ds - %s", d, h, m, s, farmRunning and "Fast Rep Running" or "Fast Rep Stopped")
    farmTimeLabel.TextColor3 = farmRunning and Color3.fromRGB(50, 255, 50) or Color3.fromRGB(255, 165, 0)
end

local function calcFarmPace()
    local now = tick()
    local str = strengthStat.Value
    local dur = durabilityStat.Value

    table.insert(strengthHist, {time = now, value = str})
    table.insert(durabilityHist, {time = now, value = dur})

    while #strengthHist > 0 and now - strengthHist[1].time > calcInterval do table.remove(strengthHist, 1) end
    while #durabilityHist > 0 and now - durabilityHist[1].time > calcInterval do table.remove(durabilityHist, 1) end

    if #strengthHist >= 2 then
        local delta = strengthHist[#strengthHist].value - strengthHist[1].value
        local perSec = delta / calcInterval
        strPaceLabel.Text = string.format("Strength Pace: %s /Hour | %s /Day | %s /Week", formatNumber(perSec * 3600), formatNumber(perSec * 86400), formatNumber(perSec * 604800))
    end

    if #durabilityHist >= 2 then
        local delta = durabilityHist[#durabilityHist].value - durabilityHist[1].value
        local perSec = delta / calcInterval
        durPaceLabel.Text = string.format("Durability Pace: %s /Hour | %s /Day | %s /Week", formatNumber(perSec * 3600), formatNumber(perSec * 86400), formatNumber(perSec * 604800))
    end

    local total = farmPausedTime + (now - farmStartTime)
    if total > 0 then
        local strPerSec = (str - initialStrength) / total
        local durPerSec = (dur - initialDurability) / total
        avgStrPaceLabel.Text = string.format("Average Strength Pace: %s /Hour | %s /Day | %s /Week", formatNumber(strPerSec * 3600), formatNumber(strPerSec * 86400), formatNumber(strPerSec * 604800))
        avgDurPaceLabel.Text = string.format("Average Durability Pace: %s /Hour | %s /Day | %s /Week", formatNumber(durPerSec * 3600), formatNumber(durPerSec * 86400), formatNumber(durPerSec * 604800))
    end
end

task.spawn(function()
    local lastCalc = tick()
    while true do
        updateFarmLabels()
        if farmRunning then
            if not farmTracking then
                farmTracking = true
                farmStartTime = tick()
                strengthHist = {}
                durabilityHist = {}
            end
            updateFarmUI()
            if tick() - lastCalc >= calcInterval then
                lastCalc = tick()
                calcFarmPace()
            end
        else
            if farmTracking then
                farmTracking = false
                farmPausedTime += tick() - farmStartTime
                updateFarmUI()
                strPaceLabel.Text = "Strength Pace: 0 /Hour | 0 /Day | 0 /Week"
                durPaceLabel.Text = "Durability Pace: 0 /Hour | 0 /Day | 0 /Week"
                avgStrPaceLabel.Text = "Average Strength Pace: 0 /Hour | 0 /Day | 0 /Week"
                avgDurPaceLabel.Text = "Average Durability Pace: 0 /Hour | 0 /Day | 0 /Week"
            end
        end
        task.wait(0.05)
    end
end)

FarmingTab:AddLabel("Fast Farm (Recommended Speed: 20)").TextSize = 20

local repsPerTick = 1
FarmingTab:AddTextBox("Rep Speed", function(val)
    local n = tonumber(val)
    if n and n > 0 then repsPerTick = math.floor(n) end
end, { placeholder = "1" })

local function getPing()
    local stats = game:GetService("Stats")
    local ping = stats:FindFirstChild("PerformanceStats") and stats.PerformanceStats:FindFirstChild("Ping")
    return ping and ping:GetValue() or 0
end

local function fastRepLoop()
    while farmRunning do
        local start = tick()
        while tick() - start < 0.75 and farmRunning do
            for i = 1, repsPerTick do muscleEvent:FireServer("rep") end
            task.wait(0.02)
        end
        while farmRunning and getPing() >= 350 do task.wait(1) end
    end
end

FarmingTab:AddSwitch("Fast Rep", function(state)
    if state and not farmRunning then
        farmRunning = true
        task.spawn(fastRepLoop)
    elseif not state and farmRunning then
        farmRunning = false
    end
end)

FarmingTab:AddLabel("Misc:").TextSize = 20

local eggRunning = false
task.spawn(function()
    while true do
        if eggRunning then
            local tool = player.Character:FindFirstChild("Protein Egg") or player.Backpack:FindFirstChild("Protein Egg")
            if tool then muscleEvent:FireServer("proteinEgg", tool) end
            task.wait(1800)
        else
            task.wait(1)
        end
    end
end)

FarmingTab:AddSwitch("Auto Egg", function(state)
    eggRunning = state
    if state then
        local tool = player.Character:FindFirstChild("Protein Egg") or player.Backpack:FindFirstChild("Protein Egg")
        if tool then muscleEvent:FireServer("proteinEgg", tool) end
    end
end)

local shakeRunning2 = false
task.spawn(function()
    while true do
        if shakeRunning2 then
            local tool = player.Character:FindFirstChild("Tropical Shake") or player.Backpack:FindFirstChild("Tropical Shake")
            if tool then muscleEvent:FireServer("tropicalShake", tool) end
            task.wait(900)
        else
            task.wait(1)
        end
    end
end)

FarmingTab:AddSwitch("Auto Shake", function(state)
    shakeRunning2 = state
    if state then
        local tool = player.Character:FindFirstChild("Tropical Shake") or player.Backpack:FindFirstChild("Tropical Shake")
        if tool then muscleEvent:FireServer("tropicalShake", tool) end
    end
end)

FarmingTab:AddSwitch("Spin Fortune Wheel", function(bool)
    _G.AutoSpinWheel = bool
    while _G.AutoSpinWheel do
        ReplicatedStorage.rEvents.openFortuneWheelRemote:InvokeServer("openFortuneWheel", ReplicatedStorage.fortuneWheelChances["Fortune Wheel"])
        task.wait(1)
    end
end)

FarmingTab:AddButton("Jungle Squat", function()
    local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if hrp then
        hrp.CFrame = CFrame.new(-8371.43359375, 6.79806327, 2858.88525390)
        task.wait(0.2)
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
        task.wait(0.05)
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
    end
end)

FarmingTab:AddButton("Anti Lag", applyAntiLag)

FarmingTab:AddButton("Equip Swift Samurai", function()
    equipPetByName("Swift Samurai")
end)

-- Info Tab
InfoTab:AddLabel("Made by Henne ♥️").TextSize = 20
InfoTab:AddLabel("discord.gg/silencev1").TextSize = 20
InfoTab:AddButton("Copy Invite", function()
    local link = "https://discord.gg/9eFf93Kg8D"
    if setclipboard then
        setclipboard(link)
        game.StarterGui:SetCore("SendNotification", {Title = "Link Copied!", Text = "You can continue to Discord now.", Duration = 3})
    else
        game.StarterGui:SetCore("SendNotification", {Title = "Error!", Text = "Not Supported.", Duration = 3})
    end
end)

InfoTab:AddLabel("")
local wLabel = InfoTab:AddLabel("VERSION//2.0.0")
wLabel.TextSize = 40
wLabel.Font = Enum.Font.Arcade
