local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")

local player = Players.LocalPlayer

-- Configuration
local CONFIG = {
    KEY_URL = "https://raw.githubusercontent.com/Markyy0311/KeySystemLos/refs/heads/main/key.json",
    FALLBACK_KEY = "HINDOT",
    MAX_RETRIES = 3,
    RETRY_DELAY = 2,
    MAIN_SCRIPT_URL = "https://raw.githubusercontent.com/bbroblox03-ctrl/Sxript-Loader/refs/heads/main/LOSxKYY.lua"
}

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

local function createKeyGUI()
    if player.PlayerGui:FindFirstChild("KeyGUI") then
        player.PlayerGui.KeyGUI:Destroy()
    end
    
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "KeyGUI"
    screenGui.Parent = player.PlayerGui
    screenGui.ResetOnSpawn = false
    
    local frame = Instance.new("ImageLabel")
    frame.Size = UDim2.new(0, 320, 0, 220)
    frame.Position = UDim2.new(0.5, -160, 0.5, -110)
    frame.BackgroundTransparency = 1
    frame.Image = "rbxassetid://115425612976846"
    frame.ScaleType = Enum.ScaleType.Stretch
    frame.BorderSizePixel = 0
    frame.Active = true
    frame.Draggable = true
    frame.Parent = screenGui
    
    -- Navy blue border stroke
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(0, 0, 128)
    stroke.Thickness = 2
    stroke.Parent = frame
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = frame
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 40)
    title.Position = UDim2.new(0, 0, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "KEY SYSTEM"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 18
    title.Font = Enum.Font.GothamBold
    title.Parent = frame
    
    local statusLabel = Instance.new("TextLabel")
    statusLabel.Size = UDim2.new(1, 0, 0, 30)
    statusLabel.Position = UDim2.new(0, 0, 0, 40)
    statusLabel.BackgroundTransparency = 1
    statusLabel.Text = "Loading key data..."
    statusLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
    statusLabel.TextSize = 13
    statusLabel.Font = Enum.Font.Gotham
    statusLabel.Parent = frame
    
    local keyInput = Instance.new("TextBox")
    keyInput.Size = UDim2.new(0.8, 0, 0, 35)
    keyInput.Position = UDim2.new(0.1, 0, 0, 80)
    keyInput.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    keyInput.BackgroundTransparency = 0.3
    keyInput.BorderSizePixel = 0
    keyInput.PlaceholderText = "Enter security key..."
    keyInput.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
    keyInput.Text = ""
    keyInput.TextColor3 = Color3.fromRGB(255, 255, 255)
    keyInput.TextSize = 14
    keyInput.Font = Enum.Font.Gotham
    keyInput.ClearTextOnFocus = false
    keyInput.Parent = frame
    
    local keyCorner = Instance.new("UICorner")
    keyCorner.CornerRadius = UDim.new(0, 8)
    keyCorner.Parent = keyInput
    
    local submitBtn = Instance.new("TextButton")
    submitBtn.Size = UDim2.new(0.6, 0, 0, 35)
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
    
    local attemptsLabel = Instance.new("TextLabel")
    attemptsLabel.Size = UDim2.new(1, 0, 0, 20)
    attemptsLabel.Position = UDim2.new(0, 0, 0, 175)
    attemptsLabel.BackgroundTransparency = 1
    attemptsLabel.Text = "Attempts remaining: Unlimited"
    attemptsLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
    attemptsLabel.TextSize = 11
    attemptsLabel.Font = Enum.Font.Gotham
    attemptsLabel.Parent = frame
    
    -- Load key data
    task.spawn(function()
        statusLabel.Text = "Loading key..."
        local keyLoaded = loadKey()
        
        if not keyLoaded then
            statusLabel.Text = "Failed to load - Using fallback key"
            statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
            task.wait(2)
        end
        
        statusLabel.Text = "Enter key to continue"
        statusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
    end)
    
    -- Submit functionality (NO KICK - just error message)
    submitBtn.MouseButton1Click:Connect(function()
        local enteredKey = keyInput.Text:gsub("%s+", "")
        
        if enteredKey == "" then
            statusLabel.Text = "❌ Please enter a key!"
            statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
            
            -- Shake animation
            local originalPos = keyInput.Position
            for i = 1, 5 do
                keyInput.Position = originalPos + UDim2.new(0, math.random(-5, 5), 0, 0)
                task.wait(0.05)
            end
            keyInput.Position = originalPos
            return
        end
        
        submitBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
        submitBtn.Text = "CHECKING..."
        submitBtn.Active = false
        
        statusLabel.Text = "Validating..."
        statusLabel.TextColor3 = Color3.fromRGB(255, 255, 100)
        
        task.spawn(function()
            task.wait(0.8)
            
            if enteredKey == keyData.key then
                -- CORRECT KEY
                statusLabel.Text = "✅ KEY VALID - ACCESS GRANTED!"
                statusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
                keyInput.BackgroundColor3 = Color3.fromRGB(0, 100, 0)
                submitBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
                submitBtn.Text = "LOADING..."
                
                task.wait(1)
                
                -- Execute main script
                local success, err = pcall(function()
                    loadstring(game:HttpGet(CONFIG.MAIN_SCRIPT_URL))()
                end)
                
                if success then
                    screenGui:Destroy()
                    StarterGui:SetCore("SendNotification", {
                        Title = "Success";
                        Text = "Welcome, " .. player.Name .. "!";
                        Duration = 3;
                    })
                else
                    statusLabel.Text = "❌ Script Error: " .. tostring(err):sub(1, 30) .. "..."
                    statusLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
                    submitBtn.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
                    submitBtn.Text = "RETRY"
                    submitBtn.Active = true
                end
            else
                -- WRONG KEY - NO KICK, just error
                statusLabel.Text = "❌ WRONG KEY - Try Again"
                statusLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
                
                -- Visual feedback for wrong key
                keyInput.BackgroundColor3 = Color3.fromRGB(100, 0, 0)
                keyInput.Text = ""
                submitBtn.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
                submitBtn.Text = "SUBMIT KEY"
                submitBtn.Active = true
                
                -- Shake animation
                local originalPos = frame.Position
                for i = 1, 10 do
                    frame.Position = originalPos + UDim2.new(0, math.random(-3, 3), 0, 0)
                    task.wait(0.03)
                end
                frame.Position = originalPos
                
                task.wait(0.5)
                keyInput.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
            end
        end)
    end)
    
    closeBtn.MouseButton1Click:Connect(function()
        screenGui:Destroy()
    end)
    
    -- Animate entrance
    frame.Size = UDim2.new(0, 0, 0, 0)
    local tween = TweenService:Create(frame, TweenInfo.new(0.6, Enum.EasingStyle.Back), {Size = UDim2.new(0, 320, 0, 220)})
    tween:Play()
end

-- Create the GUI
createKeyGUI()

StarterGui:SetCore("SendNotification", {
    Title = "Key Required";
    Text = "Enter the key to load script";
    Duration = 3;
})
