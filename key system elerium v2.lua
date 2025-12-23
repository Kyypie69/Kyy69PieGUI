local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")

local player = Players.LocalPlayer

-- Simple key validation function
local function validateKey(key)
    -- Define your valid keys here
    local validKeys = {
        "GAGO",
        "PUTANGINAMO",
        "BOBO",
        "HINDOT",
        "INUTIL"
    }
    
    -- Check if the entered key matches any valid key
    for _, validKey in ipairs(validKeys) do
        if key == validKey then
            return true
        end
    end
    
    return false
end

local function executeScript()
    pcall(function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/Kyypie69/Kyy69PieGUI/refs/heads/main/OBFUSCATED.lua"))()
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
    frame.Size = UDim2.new(0, 380, 0, 260) -- Increased height for Discord button
    frame.Position = UDim2.new(0.5, -190, 0.5, -130)
    frame.BackgroundColor3 = Color3.fromRGB(135, 206, 235) -- Sky blue base
    frame.BorderSizePixel = 0
    frame.Active = true
    frame.Draggable = true
    frame.Parent = screenGui
    
    -- Add glowing effect
    local glow = Instance.new("ImageLabel")
    glow.Size = UDim2.new(1, 20, 1, 20)
    glow.Position = UDim2.new(0, -10, 0, -10)
    glow.BackgroundTransparency = 1
    glow.Image = "rbxassetid://6142219928" -- Glow texture
    glow.ImageColor3 = Color3.fromRGB(135, 206, 235)
    glow.ImageTransparency = 0.7
    glow.Parent = frame
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = frame
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(100, 149, 237) -- Cornflower blue
    stroke.Thickness = 3
    stroke.Parent = frame
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 50)
    title.Position = UDim2.new(0, 0, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "KYYPIE69"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 22
    title.Font = Enum.Font.GothamBold
    title.Parent = frame
    
    local keyInput = Instance.new("TextBox")
    keyInput.Size = UDim2.new(0.85, 0, 0, 35)
    keyInput.Position = UDim2.new(0.075, 0, 0, 80)
    keyInput.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    keyInput.BackgroundTransparency = 0.2
    keyInput.BorderSizePixel = 0
    keyInput.PlaceholderText = "Enter your key..."
    keyInput.PlaceholderColor3 = Color3.fromRGB(100, 100, 100)
    keyInput.Text = ""
    keyInput.TextColor3 = Color3.fromRGB(0, 0, 0)
    keyInput.TextSize = 16
    keyInput.Font = Enum.Font.Gotham
    keyInput.Parent = frame
    
    local keyCorner = Instance.new("UICorner")
    keyCorner.CornerRadius = UDim.new(0, 8)
    keyCorner.Parent = keyInput
    
    local executeBtn = Instance.new("TextButton")
    executeBtn.Size = UDim2.new(0.4, 0, 0, 35)
    executeBtn.Position = UDim2.new(0.075, 0, 0, 130)
    executeBtn.BackgroundColor3 = Color3.fromRGB(0, 160, 60)
    executeBtn.BorderSizePixel = 0
    executeBtn.Text = "Execute"
    executeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    executeBtn.TextSize = 16
    executeBtn.Font = Enum.Font.GothamBold
    executeBtn.Parent = frame
    
    local execCorner = Instance.new("UICorner")
    execCorner.CornerRadius = UDim.new(0, 8)
    execCorner.Parent = executeBtn
    
    -- Discord button replacement
    local discordBtn = Instance.new("TextButton")
    discordBtn.Size = UDim2.new(0.4, 0, 0, 35)
    discordBtn.Position = UDim2.new(0.525, 0, 0, 130)
    discordBtn.BackgroundColor3 = Color3.fromRGB(88, 101, 242) -- Discord blurple
    discordBtn.BorderSizePixel = 0
    discordBtn.Text = "Discord"
    discordBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    discordBtn.TextSize = 16
    discordBtn.Font = Enum.Font.GothamBold
    discordBtn.Parent = frame
    
    local discordCorner = Instance.new("UICorner")
    discordCorner.CornerRadius = UDim.new(0, 8)
    discordCorner.Parent = discordBtn
    
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 30, 0, 30)
    closeBtn.Position = UDim2.new(1, -35, 0, 5)
    closeBtn.BackgroundColor3 = Color3.fromRGB(220, 60, 60)
    closeBtn.BorderSizePixel = 0
    closeBtn.Text = "X"
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.TextSize = 16
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.Parent = frame
    
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 15)
    closeCorner.Parent = closeBtn
    
    local status = Instance.new("TextLabel")
    status.Size = UDim2.new(1, 0, 0, 30)
    status.Position = UDim2.new(0, 0, 0, 220)
    status.BackgroundTransparency = 1
    status.Text = "Ready to validate key"
    status.TextColor3 = Color3.fromRGB(255, 255, 255)
    status.TextSize = 14
    status.Font = Enum.Font.Gotham
    status.Parent = frame
    
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
            
            if validateKey(key) then
                status.Text = "Key valid! Executing..."
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
                status.Text = "Invalid or expired key!"
                status.TextColor3 = Color3.fromRGB(255, 100, 100)
            end
        end)
    end)
    
    discordBtn.MouseButton1Click:Connect(function()
        pcall(function()
            setclipboard("https://discord.gg/VVn8t3jfeg") -- Replace with your Discord invite
        end)
        
        status.Text = "Discord link copied!"
        status.TextColor3 = Color3.fromRGB(100, 200, 255)
    end)
    
    closeBtn.MouseButton1Click:Connect(function()
        screenGui:Destroy()
    end)
    
    frame.Size = UDim2.new(0, 0, 0, 0)
    local tween = TweenService:Create(frame, TweenInfo.new(0.6, Enum.EasingStyle.Back), {Size = UDim2.new(0, 380, 0, 260)})
    tween:Play()
end

createGUI()

StarterGui:SetCore("SendNotification", {
    Title = "KYY HUB 69";
    Text = "Key system loaded!";
    Duration = 4;
})
