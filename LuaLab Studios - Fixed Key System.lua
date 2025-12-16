-- LuaLab Studios Key System
-- Fixed validation server URL

local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")

local player = Players.LocalPlayer

-- Correct validation server URL
local VALIDATION_SERVER = "https://workspace.gamesvictor741.repl.co:4000/api/validate-key/"

local function validateKey(key)
    local success, result = pcall(function()
        local response = HttpService:GetAsync(VALIDATION_SERVER .. key)
        local data = HttpService:JSONDecode(response)
        return data.valid == true
    end)
    return success and result
end

local function executeScript()
    pcall(function()
        loadstring(game:HttpGet("https://rawscripts.net/raw/Grow-a-Garden-NoLag-Hub-no-key-38699"))()
    end)
end

local function createGUI()
    if player.PlayerGui:FindFirstChild("LuaLabStudios") then
        player.PlayerGui.LuaLabStudios:Destroy()
    end
    
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "LuaLabStudios"
    screenGui.Parent = player.PlayerGui
    screenGui.ResetOnSpawn = false
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 380, 0, 220)
    frame.Position = UDim2.new(0.5, -190, 0.5, -110)
    frame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    frame.BorderSizePixel = 0
    frame.Active = true
    frame.Draggable = true
    frame.Parent = screenGui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = frame
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(80, 80, 100)
    stroke.Thickness = 2
    stroke.Parent = frame
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 50)
    title.Position = UDim2.new(0, 0, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "LuaLab Studios"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 22
    title.Font = Enum.Font.GothamBold
    title.Parent = frame
    
    local keyInput = Instance.new("TextBox")
    keyInput.Size = UDim2.new(0.85, 0, 0, 35)
    keyInput.Position = UDim2.new(0.075, 0, 0, 80)
    keyInput.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
    keyInput.BorderSizePixel = 0
    keyInput.PlaceholderText = "Enter your key..."
    keyInput.PlaceholderColor3 = Color3.fromRGB(120, 120, 120)
    keyInput.Text = ""
    keyInput.TextColor3 = Color3.fromRGB(255, 255, 255)
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
    
    local getKeyBtn = Instance.new("TextButton")
    getKeyBtn.Size = UDim2.new(0.4, 0, 0, 35)
    getKeyBtn.Position = UDim2.new(0.525, 0, 0, 130)
    getKeyBtn.BackgroundColor3 = Color3.fromRGB(120, 60, 220)
    getKeyBtn.BorderSizePixel = 0
    getKeyBtn.Text = "Get Key"
    getKeyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    getKeyBtn.TextSize = 16
    getKeyBtn.Font = Enum.Font.GothamBold
    getKeyBtn.Parent = frame
    
    local getKeyCorner = Instance.new("UICorner")
    getKeyCorner.CornerRadius = UDim.new(0, 8)
    getKeyCorner.Parent = getKeyBtn
    
    local status = Instance.new("TextLabel")
    status.Size = UDim2.new(1, 0, 0, 30)
    status.Position = UDim2.new(0, 0, 0, 175)
    status.BackgroundTransparency = 1
    status.Text = "Ready to validate key"
    status.TextColor3 = Color3.fromRGB(255, 200, 100)
    status.TextSize = 14
    status.Font = Enum.Font.Gotham
    status.Parent = frame
    
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
    
    executeBtn.MouseButton1Click:Connect(function()
        local key = keyInput.Text:gsub("%s+", "")
        
        if key == "" then
            status.Text = "Please enter a key first!"
            status.TextColor3 = Color3.fromRGB(255, 100, 100)
            return
        end
        
        status.Text = "Validating key..."
        status.TextColor3 = Color3.fromRGB(255, 200, 100)
        
        spawn(function()
            wait(1)
            
            if validateKey(key) then
                status.Text = "Key valid! Executing..."
                status.TextColor3 = Color3.fromRGB(100, 255, 100)
                
                wait(1)
                executeScript()
                screenGui:Destroy()
                
                StarterGui:SetCore("SendNotification", {
                    Title = "LuaLab Studios";
                    Text = "Script executed successfully!";
                    Duration = 3;
                })
            else
                status.Text = "Invalid or expired key!"
                status.TextColor3 = Color3.fromRGB(255, 100, 100)
            end
        end)
    end)
    
    getKeyBtn.MouseButton1Click:Connect(function()
        pcall(function()
            setclipboard("https://lualabstudios.netlify.app")
        end)
        
        status.Text = "Link copied! Get your key"
        status.TextColor3 = Color3.fromRGB(100, 200, 255)
    end)
    
    closeBtn.MouseButton1Click:Connect(function()
        screenGui:Destroy()
    end)
    
    frame.Size = UDim2.new(0, 0, 0, 0)
    local tween = TweenService:Create(frame, TweenInfo.new(0.6, Enum.EasingStyle.Back), {Size = UDim2.new(0, 380, 0, 220)})
    tween:Play()
end

createGUI()

StarterGui:SetCore("SendNotification", {
    Title = "LuaLab Studios";
    Text = "Key system loaded!";
    Duration = 4;
})