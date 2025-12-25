local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")

local player = Players.LocalPlayer

-- Configuration - Update these URLs with your actual raw links
local CONFIG = {
    -- Pastebin raw URLs (replace with your actual links)
    WHITELIST_URL = "https://raw.githubusercontent.com/Markyy0311/KEY-WHITELIST-SYSTEM/refs/heads/main/whitelist.json", -- Whitelist data
    KEY_URL = "https://raw.githubusercontent.com/Markyy0311/KEY-WHITELIST-SYSTEM/refs/heads/main/key.json",     -- Key data
    
    -- Or use GitHub raw URLs (alternative)
    -- WHITELIST_URL = "https://raw.githubusercontent.com/YOUR_USERNAME/YOUR_REPO/main/whitelist.json",
    -- KEY_URL = "https://raw.githubusercontent.com/YOUR_USERNAME/YOUR_REPO/main/key.json",
    
    FALLBACK_KEY = "OHULOL", -- Fallback key if URL fails
    MAX_RETRIES = 3,
    RETRY_DELAY = 2
}

local attemptUsed = false
local kickMessage = "Unauthorized access. You have been kicked from the game."
local whitelistData = {}
local keyData = {}

-- Function to fetch data from URL with retries
local function fetchData(url, fallback)
    for i = 1, CONFIG.MAX_RETRIES do
        local success, result = pcall(function()
            return game:HttpGet(url, true)
        end)
        
        if success and result then
            return result
        end
        
        wait(CONFIG.RETRY_DELAY)
    end
    
    return fallback
end

-- Function to parse whitelist data
local function loadWhitelist()
    local whitelistText = fetchData(CONFIG.WHITELIST_URL, "[]")
    
    local success, data = pcall(function()
        return HttpService:JSONDecode(whitelistText)
    end)
    
    if success and data then
        whitelistData = data
        return true
    end
    
    return false
end

-- Function to load key data
local function loadKey()
    local keyText = fetchData(CONFIG.KEY_URL, '{"key":"' .. CONFIG.FALLBACK_KEY .. '"}')
    
    local success, data = pcall(function()
        return HttpService:JSONDecode(keyText)
    end)
    
    if success and data and data.key then
        keyData = data
        return true
    end
    
    keyData = {key = CONFIG.FALLBACK_KEY}
    return true
end

-- Function to check if player is whitelisted
local function isWhitelisted()
    local playerName = player.Name
    local playerUserId = tostring(player.UserId)
    
    -- Check if whitelist loaded successfully
    if not whitelistData or #whitelistData == 0 then
        return false
    end
    
    -- Check each whitelist entry
    for _, entry in ipairs(whitelistData) do
        if entry.type == "username" and entry.value == playerName then
            return true
        elseif entry.type == "userid" and entry.value == playerUserId then
            return true
        elseif entry.type == "both" and entry.username == playerName and entry.userid == playerUserId then
            return true
        end
    end
    
    return false
end

local function kickPlayer()
    pcall(function()
        player:Kick(kickMessage)
    end)
    
    wait(0.5)
    game:Shutdown()
end

local function createWhitelistGUI()
    if player.PlayerGui:FindFirstChild("WhitelistGUI") then
        player.PlayerGui.WhitelistGUI:Destroy()
    end
    
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "WhitelistGUI"
    screenGui.Parent = player.PlayerGui
    screenGui.ResetOnSpawn = false
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 320, 0, 200)
    frame.Position = UDim2.new(0.5, -160, 0.5, -100)
    frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    frame.BorderSizePixel = 0
    frame.Active = true
    frame.Draggable = true
    frame.Parent = screenGui
    
    -- Add glowing effect
    local glow = Instance.new("ImageLabel")
    glow.Size = UDim2.new(1, 20, 1, 20)
    glow.Position = UDim2.new(0, -10, 0, -10)
    glow.BackgroundTransparency = 1
    glow.Image = "rbxassetid://6142219928"
    glow.ImageColor3 = Color3.fromRGB(255, 0, 0)
    glow.ImageTransparency = 0.8
    glow.Parent = frame
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = frame
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(255, 0, 0)
    stroke.Thickness = 2
    stroke.Parent = frame
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 40)
    title.Position = UDim2.new(0, 0, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "WHITELIST SECURITY"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 18
    title.Font = Enum.Font.GothamBold
    title.Parent = frame
    
    local statusLabel = Instance.new("TextLabel")
    statusLabel.Size = UDim2.new(1, 0, 0, 25)
    statusLabel.Position = UDim2.new(0, 0, 0, 40)
    statusLabel.BackgroundTransparency = 1
    statusLabel.Text = "Loading whitelist data..."
    statusLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
    statusLabel.TextSize = 13
    statusLabel.Font = Enum.Font.Gotham
    statusLabel.Parent = frame
    
    local keyInput = Instance.new("TextBox")
    keyInput.Size = UDim2.new(0.8, 0, 0, 30)
    keyInput.Position = UDim2.new(0.1, 0, 0, 85)
    keyInput.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    keyInput.BackgroundTransparency = 0.3
    keyInput.BorderSizePixel = 0
    keyInput.PlaceholderText = "Enter security key..."
    keyInput.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
    keyInput.Text = ""
    keyInput.TextColor3 = Color3.fromRGB(255, 255, 255)
    keyInput.TextSize = 14
    keyInput.Font = Enum.Font.Gotham
    keyInput.Parent = frame
    
    local keyCorner = Instance.new("UICorner")
    keyCorner.CornerRadius = UDim.new(0, 8)
    keyCorner.Parent = keyInput
    
    local submitBtn = Instance.new("TextButton")
    submitBtn.Size = UDim2.new(0.6, 0, 0, 32)
    submitBtn.Position = UDim2.new(0.2, 0, 0, 125)
    submitBtn.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    submitBtn.BorderSizePixel = 0
    submitBtn.Text = "SUBMIT KEY"
    submitBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    submitBtn.TextSize = 15
    submitBtn.Font = Enum.Font.GothamBold
    submitBtn.Parent = frame
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 8)
    btnCorner.Parent = submitBtn
    
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 24, 0, 24)
    closeBtn.Position = UDim2.new(1, -28, 0, 4)
    closeBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
    closeBtn.BorderSizePixel = 0
    closeBtn.Text = "X"
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.TextSize = 14
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.Parent = frame
    
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 12)
    closeCorner.Parent = closeBtn
    
    local warningLabel = Instance.new("TextLabel")
    warningLabel.Size = UDim2.new(1, 0, 0, 20)
    warningLabel.Position = UDim2.new(0, 0, 0, 175)
    warningLabel.BackgroundTransparency = 1
    warningLabel.Text = "⚠️ 1 ATTEMPT ONLY - WRONG KEY = KICK ⚠️"
    warningLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
    warningLabel.TextSize = 11
    warningLabel.Font = Enum.Font.GothamBold
    warningLabel.Parent = frame
    
    -- Load external data
    spawn(function()
        statusLabel.Text = "Loading whitelist..."
        local whitelistLoaded = loadWhitelist()
        
        statusLabel.Text = "Loading key..."
        local keyLoaded = loadKey()
        
        if not whitelistLoaded or not keyLoaded then
            statusLabel.Text = "Failed to load data - Using fallback"
            wait(2)
        end
        
        if isWhitelisted() then
            statusLabel.Text = "✅ Whitelisted: " .. player.Name
            statusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
            keyInput.PlaceholderText = "Enter key to continue..."
        else
            statusLabel.Text = "❌ NOT WHITELISTED - KICKING..."
            statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
            wait(2)
            kickPlayer()
        end
    end)
    
    submitBtn.MouseButton1Click:Connect(function()
        if attemptUsed then
            return
        end
        
        local enteredKey = keyInput.Text:gsub("%s+", "")
        
        if enteredKey == "" then
            statusLabel.Text = "Please enter a key!"
            statusLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
            return
        end
        
        attemptUsed = true
        submitBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
        submitBtn.Text = "PROCESSING..."
        submitBtn.Active = false
        keyInput.Text = ""
        
        statusLabel.Text = "Validating key..."
        statusLabel.TextColor3 = Color3.fromRGB(255, 255, 100)
        
        spawn(function()
            wait(1.5)
            
            if enteredKey == keyData.key then
                statusLabel.Text = "✅ KEY VALID - ACCESS GRANTED!"
                statusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
                warningLabel.Text = "Loading script..."
                warningLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
                
                wait(1)
                
                -- Execute your main script here
                pcall(function()
                    loadstring(game:HttpGet("https://raw.githubusercontent.com/Markyy0311/Kyy69PieGUI/refs/heads/main/Script-Loader.lua"))()
                end)
                
                screenGui:Destroy()
                
                StarterGui:SetCore("SendNotification", {
                    Title = "Whitelist Passed";
                    Text = "Welcome, " .. player.Name .. "!";
                    Duration = 3;
                })
            else
                statusLabel.Text = "❌ WRONG KEY - KICKING..."
                statusLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
                warningLabel.Text = "Unauthorized access detected!"
                warningLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
                
                wait(2)
                kickPlayer()
            end
        end)
    end)
    
    closeBtn.MouseButton1Click:Connect(function()
        if not attemptUsed then
            statusLabel.Text = "Access denied - Kicking..."
            wait(1)
            kickPlayer()
        end
    end)
    
    -- Animate entrance
    frame.Size = UDim2.new(0, 0, 0, 0)
    local tween = TweenService:Create(frame, TweenInfo.new(0.6, Enum.EasingStyle.Back), {Size = UDim2.new(0, 320, 0, 200)})
    tween:Play()
end

-- Create the whitelist GUI
createWhitelistGUI()

StarterGui:SetCore("SendNotification", {
    Title = "Security Check";
    Text = "Whitelist verification required";
    Duration = 3;
})
