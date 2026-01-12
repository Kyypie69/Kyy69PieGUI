local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")

local localPlayer = Players.LocalPlayer
local displayName = localPlayer.DisplayName
local username = localPlayer.Name
local userId = localPlayer.UserId

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ModernUI"
ScreenGui.Parent = PlayerGui

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 300, 0, 180)
Frame.Position = UDim2.new(0.5, 0, 0.5, 0)
Frame.AnchorPoint = Vector2.new(0.5, 0.5)
Frame.BackgroundColor3 = Color3.fromRGB(135, 206, 235) -- Sky blue base
Frame.BorderSizePixel = 0
Frame.Parent = ScreenGui
Frame.ClipsDescendants = true
Frame.BackgroundTransparency = 0.3 -- Semi-transparent

local UICornerFrame = Instance.new("UICorner")
UICornerFrame.CornerRadius = UDim.new(0, 15)
UICornerFrame.Parent = Frame

local bgGradient = Instance.new("UIGradient")
bgGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(135, 206, 235)), -- Light sky blue
    ColorSequenceKeypoint.new(1, Color3.fromRGB(70, 130, 180)), -- Steel blue
}
bgGradient.Transparency = NumberSequence.new{
    NumberSequenceKeypoint.new(0, 0.3), -- More transparent
    NumberSequenceKeypoint.new(1, 0.3),
}
bgGradient.Parent = Frame

-- Add glow effect
local glow = Instance.new("ImageLabel")
glow.Size = UDim2.new(1.2, 0, 1.2, 0)
glow.Position = UDim2.new(-0.1, 0, -0.1, 0)
glow.BackgroundTransparency = 1
glow.Image = "rbxassetid://5028857084"
glow.ImageTransparency = 0.7
glow.ImageColor3 = Color3.fromRGB(135, 206, 235)
glow.Parent = Frame

local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Position = UDim2.new(0, 0, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "KYY-Loader"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 24
Title.Parent = Frame

-- Rainbow gradient for title
local titleGradient = Instance.new("UIGradient")
titleGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
    ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 165, 0)),
    ColorSequenceKeypoint.new(0.33, Color3.fromRGB(255, 255, 0)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 0)),
    ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0, 255, 255)),
    ColorSequenceKeypoint.new(0.83, Color3.fromRGB(0, 0, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(128, 0, 128)),
}
titleGradient.Parent = Title

-- Slow blinking rainbow effect for title
local rainbowTween = game:GetService("TweenService"):Create(
    titleGradient,
    TweenInfo.new(3, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1),
    {Offset = Vector2.new(1, 0)}
)
rainbowTween:Play()

local function createButton(name, position, parent)
    local button = Instance.new("TextButton")
    button.Name = name
    button.Size = UDim2.new(0, 260, 0, 50)
    button.Position = position
    button.BackgroundTransparency = 0.2
    button.BorderSizePixel = 0
    button.Text = ""          -- leave empty
    button.AutoButtonColor = false
    button.Parent = parent

    local UICornerBtn = Instance.new("UICorner")
    UICornerBtn.CornerRadius = UDim.new(0, 12)
    UICornerBtn.Parent = button

    -- sky-blue background gradient
    local skyGradient = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(135, 206, 235)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(70, 130, 180)),
    }
    local buttonBGGradient = Instance.new("UIGradient")
    buttonBGGradient.Color = skyGradient
    buttonBGGradient.Transparency = NumberSequence.new{
        NumberSequenceKeypoint.new(0, 0.4),
        NumberSequenceKeypoint.new(1, 0.4),
    }
    buttonBGGradient.Parent = button

    -- rainbow text label
    local text = Instance.new("TextLabel")
    text.Size = UDim2.new(1, 0, 1, 0)
    text.BackgroundTransparency = 1
    text.Text = name
    text.TextColor3 = Color3.new(1, 1, 1)
    text.Font = Enum.Font.GothamSemibold
    text.TextSize = 22
    text.Parent = button

    local rainbow = ColorSequence.new{
        ColorSequenceKeypoint.new(0,   Color3.fromRGB(255, 0, 0)),
        ColorSequenceKeypoint.new(0.17,Color3.fromRGB(255, 165, 0)),
        ColorSequenceKeypoint.new(0.33,Color3.fromRGB(255, 255, 0)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 0)),
        ColorSequenceKeypoint.new(0.67,Color3.fromRGB(0, 255, 255)),
        ColorSequenceKeypoint.new(0.83,Color3.fromRGB(0, 0, 255)),
        ColorSequenceKeypoint.new(1,   Color3.fromRGB(128, 0, 128)),
    }
    local textGradient = Instance.new("UIGradient")
    textGradient.Color = rainbow
    textGradient.Parent = text

    -- slow infinite rainbow scroll
    game:GetService("TweenService"):Create(
        textGradient,
        TweenInfo.new(3, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1),
        {Offset = Vector2.new(1, 0)}
    ):Play()

    button.MouseEnter:Connect(function()
        buttonBGGradient.Transparency = NumberSequence.new{
            NumberSequenceKeypoint.new(0, 0.2),
            NumberSequenceKeypoint.new(1, 0.2),
        }
    end)

    button.MouseLeave:Connect(function()
        buttonBGGradient.Transparency = NumberSequence.new{
            NumberSequenceKeypoint.new(0, 0.4),
            NumberSequenceKeypoint.new(1, 0.4),
        }
    end)

    return button
end

-- create the buttons
local mainButton   = createButton("Execute Local Script",   UDim2.new(0, 20, 0, 50),  Frame)
local farmingButton = createButton("Packs Farming", UDim2.new(0, 20, 0, 115), Frame)

mainButton.MouseButton1Click:Connect(function()
    closeUI()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/Markyy0311/Kyy69PieGUI/refs/heads/main/Script-Loader.lua"))()
end)

farmingButton.MouseButton1Click:Connect(function()
    closeUI()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/Markyy0311/Kyy69PieGUI/refs/heads/main/Sxript-Loader2.lua"))()
end)
