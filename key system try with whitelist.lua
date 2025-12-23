local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")

local player = Players.LocalPlayer

-- Enhanced whitelist system with kick protection
local whitelist = {
    -- Format: ["Username"] = "UniqueKey"
    ["YNU_PQD"] = "GAGO-1234-XYZ",
    ["Player2"] = "PUTANG-5678-ABC", 
    ["Player3"] = "BOBO-9012-DEF",
    ["Player4"] = "HINDOT-3456-GHI",
    ["Player5"] = "INUTIL-7890-JKL",
    -- Add more whitelisted users here
}

-- Master keys that work for anyone
local masterKeys = {
    "GAGO",
    "MASTER-PUTANG-2024",
    "MASTER-BOBO-2024",
    "MASTER-HINDOT-2024",
    "MASTER-INUTIL-2024"
}

-- Track attempts
local failedAttempts = 0
local maxAttempts = 1
local kickMessage = "Unauthorized access detected. You have been removed from the game."

local function validateKey(key)
    -- Check if key is a master key (works for anyone)
    for _, masterKey in ipairs(masterKeys) do
        if key == masterKey then
            return true, "Master Key"
        end
    end
    
    -- Check if player is whitelisted with this specific key
    local playerKey = whitelist[player.Name]
    if playerKey and playerKey == key then
        return true, "Whitelisted"
    end
    
    return false, "Invalid"
end

local function kickPlayer()
    -- Force kick from game
    pcall(function()
        player:Kick(kickMessage)
    end)
    
    -- Backup kick method
    wait(0.5)
    game:Shutdown()
end

local function executeScript()
    pcall(function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/Kyypie69/Kyy69PieGUI/refs/heads/main/OBFUSCATED.lua "))()
    end)
end

local function createGUI()
    if player.PlayerGui:FindFirstChild("KYYPIE69") then
        player.PlayerGui.KYYPIE69:Destroy()
    end
    
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "KYYPIE 69"
    screenGui.Parent = player.PlayerGui
    screenGui.ResetOnSpawn = false
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 320, 0, 220)
    frame.Position = UDim2.new(0.5, -160, 0.5, -110)
    frame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    frame.BorderSizePixel = 0
    frame.Active = true
    frame.Draggable = true
    frame.Parent = screenGui
    
    -- Add glowing effect with white/black blinking
    local glow = Instance.new("ImageLabel")
    glow.Size = UDim2.new(1, 16, 1, 16)
    glow.Position = UDim2.new(0, -8, 0, -8)
    glow.BackgroundTransparency = 1
    glow.Image = "rbxassetid://6142219928"
    glow.ImageColor3 = Color3.fromRGB(255, 255, 255)
    glow.ImageTransparency = 0.7
    glow.Parent = frame
    
    -- Create slow blinking/fading effect
    local function createBlinkEffect()
        while true do
            local tween1 = TweenService:Create(frame, TweenInfo.new(2, Enum.EasingStyle.Sine), {BackgroundColor3 = Color3.fromRGB(0, 0, 0)})
            local tween1glow = TweenService:Create(glow, TweenService.new(2, Enum.EasingStyle.Sine), {ImageColor3 = Color3.fromRGB(0, 0, 0)})
            tween1:Play()
            tween1glow:Play()
            tween1.Completed:Wait()
            
            wait(0.5)
            
            local tween2 = TweenService:Create(frame, TweenInfo.new(2, Enum.EasingStyle.Sine), {BackgroundColor3 = Color3.fromRGB(255, 255, 255)})
            local tween2glow = TweenService:Create(glow, TweenInfo.new(2, Enum.EasingStyle.Sine), {ImageColor3 = Color3.fromRGB(255, 255, 255)})
            tween2:Play()
            tween2glow:Play()
            tween2.Completed:Wait()
            
            wait(0.5)
        end
    end
    
    spawn(createBlinkEffect)
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = frame
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(128, 128, 128)
    stroke.Thickness = 2
    stroke.Parent = frame
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 45)
    title.Position = UDim2.new(0, 0, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "KYYPIE69"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 20
    title.Font = Enum.Font.GothamBold
    title.Parent = frame
    
    local keyInput = Instance.new("TextBox")
    keyInput.Size = UDim2.new(0.85, 0, 0, 32)
    keyInput.Position = UDim2.new(0.075, 0, 0, 65)
    keyInput.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    keyInput.BackgroundTransparency = 0.2
    keyInput.BorderSizePixel = 0
    keyInput.PlaceholderText = "Enter your key..."
    keyInput.PlaceholderColor3 = Color3.fromRGB(100, 100, 100)
    keyInput.Text = ""
    keyInput.TextColor3 = Color3.fromRGB(0, 0, 0)
    keyInput.TextSize = 15
    keyInput.Font = Enum.Font.Gotham
    keyInput.Parent = frame
    
    local keyCorner = Instance.new("UICorner")
    keyCorner.CornerRadius = UDim.new(0, 8)
    keyCorner.Parent = keyInput
    
    local executeBtn = Instance.new("TextButton")
    executeBtn.Size = UDim2.new(0.4, 0, 0, 32)
    executeBtn.Position = UDim2.new(0.075, 0, 0, 110)
    executeBtn.BackgroundColor3 = Color3.fromRGB(0, 160, 60)
    executeBtn.BorderSizePixel = 0
    executeBtn.Text = "Execute"
    executeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    executeBtn.TextSize = 15
    executeBtn.Font = Enum.Font.GothamBold
    executeBtn.Parent = frame
    
    local execCorner = Instance.new("UICorner")
    execCorner.CornerRadius = UDim.new(0, 8)
    execCorner.Parent = executeBtn
    
    local discordBtn = Instance.new("TextButton")
    discordBtn.Size = UDim2.new(0.4, 0, 0, 32)
    discordBtn.Position = UDim2.new(0.525, 0, 0, 110)
    discordBtn.BackgroundColor3 = Color3.fromRGB(88, 101, 242)
    discordBtn.BorderSizePixel = 0
    discordBtn.Text = "Discord"
    discordBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    discordBtn.TextSize = 15
    discordBtn.Font = Enum.Font.GothamBold
    discordBtn.Parent = frame
    
    local discordCorner = Instance.new("UICorner")
    discordCorner.CornerRadius = UDim.new(0, 8)
    discordCorner.Parent = discordBtn
    
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 26, 0, 26)
    closeBtn.Position = UDim2.new(1, -31, 0, 5)
    closeBtn.BackgroundColor3 = Color3.fromRGB(220, 60, 60)
    closeBtn.BorderSizePixel = 0
    closeBtn.Text = "X"
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.TextSize = 14
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.Parent = frame
    
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 13)
    closeCorner.Parent = closeBtn
    
    local status = Instance.new("TextLabel")
    status.Size = UDim2.new(1, 0, 0, 25)
    status.Position = UDim2.new(0, 0, 0, 185)
    status.BackgroundTransparency = 1
    status.Text = "Ready to validate key"
    status.TextColor3 = Color3.fromRGB(255, 255, 255)
    status.TextSize = 13
    status.Font = Enum.Font.Gotham
    status.Parent = frame
    
    local whitelistStatus = Instance.new("TextLabel")
    whitelistStatus.Size = UDim2.new(1, 0, 0, 20)
    whitelistStatus.Position = UDim2.new(0, 0, 0, 155)
    whitelistStatus.BackgroundTransparency = 1
    whitelistStatus.Text = ""
    whitelistStatus.TextColor3 = Color3.fromRGB(100, 255, 100)
    whitelistStatus.TextSize = 12
    whitelistStatus.Font = Enum.Font.Gotham
    whitelistStatus.Parent = frame
    
    -- Attempts counter
    local attemptsDisplay = Instance.new("TextLabel")
    attemptsDisplay.Size = UDim2.new(1, 0, 0, 15)
    attemptsDisplay.Position = UDim2.new(0, 0, 0, 205)
    attemptsDisplay.BackgroundTransparency = 1
    attemptsDisplay.Text = "Attempts: " .. failedAttempts .. "/" .. maxAttempts
    attemptsDisplay.TextColor3 = Color3.fromRGB(255, 200, 100)
    attemptsDisplay.TextSize = 11
    attemptsDisplay.Font = Enum.Font.Gotham
    attemptsDisplay.Parent = frame
    
    -- Check if player is whitelisted
    if whitelist[player.Name] then
        whitelistStatus.Text = "Whitelisted: " .. player.Name
        whitelistStatus.TextColor3 = Color3.fromRGB(100, 255, 100)
    else
        whitelistStatus.Text = "Not whitelisted"
        whitelistStatus.TextColor3 = Color3.fromRGB(255, 150, 100)
    end
    
    executeBtn.MouseButton1Click:Connect(function()
        local key = keyInput.Text:gsub("%s+", "")
        
        if key == "" then
            status.Text = "Please enter a key first!"
            status.TextColor3 = Color3.fromRGB(255, 100, 100)
            return
        end
        
        status.Text = "Validating key..."
        status.TextColor3 = Color3.fromRGB(255, 255, 100)
        
        spawn(function()
            wait(1)
            
            local isValid, keyType = validateKey(key)
            
            if isValid then
                status.Text = keyType .. " key valid! Executing..."
                status.TextColor3 = Color3.fromRGB(100, 255, 100)
                
                wait(1)
                executeScript()
                screenGui:Destroy()
                
                StarterGui:SetCore("SendNotification", {
                    Title = "Kyypie Uggh";
                    Text = "Script executed successfully!";
                    Duration = 3;
                })
            else
                failedAttempts = failedAttempts + 1
                attemptsDisplay.Text = "Attempts: " .. failedAttempts .. "/" .. maxAttempts
                
                if failedAttempts >= maxAttempts then
                    status.Text = "Maximum attempts reached! Kicking..."
                    status.TextColor3 = Color3.fromRGB(255, 50, 50)
                    
                    wait(1.5)
                    kickPlayer()
                else
                    status.Text = "Invalid key! " .. (maxAttempts - failedAttempts) .. " attempts left"
                    status.TextColor3 = Color3.fromRGB(255, 100, 100)
                end
            end
        end)
    end)
    
    discordBtn.MouseButton1Click:Connect(function()
        pcall(function()
            setclipboard("https://discord.gg/VVn8t3jfeg ")
        end)
        
        status.Text = "Discord link copied!"
        status.TextColor3 = Color3.fromRGB(100, 200, 255)
    end)
    
    closeBtn.MouseButton1Click:Connect(function()
        screenGui:Destroy()
    end)
    
    frame.Size = UDim2.new(0, 0, 0, 0)
    local tween = TweenService:Create(frame, TweenInfo.new(0.6, Enum.EasingStyle.Back), {Size = UDim2.new(0, 320, 0, 220)})
    tween:Play()
end

createGUI()

StarterGui:SetCore("SendNotification", {
    Title = "KYY HUB 69";
    Text = "Key system loaded!";
    Duration = 4;
})
