local player = game.Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local flying = false
local speed = 50

local bg, bv
local root, hum

local screenGui = Instance.new("ScreenGui")
screenGui.Parent = player:WaitForChild("PlayerGui")
screenGui.ResetOnSpawn = false

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0,150,0,40)
frame.Position = UDim2.new(1,-160,1,-50)
frame.BackgroundColor3 = Color3.fromRGB(30,30,30)
frame.BackgroundTransparency = 0.2
frame.BorderSizePixel = 0
frame.ClipsDescendants = true
frame.Parent = screenGui
frame.Active = true
frame.Draggable = true
frame.AnchorPoint = Vector2.new(0,0)

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0,10)
UICorner.Parent = frame

local UIStroke = Instance.new("UIStroke")
UIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
UIStroke.Thickness = 2
UIStroke.Color = Color3.fromRGB(100,100,255)
UIStroke.Parent = frame

local label = Instance.new("TextLabel")
label.Size = UDim2.new(0,140,0,15)
label.Position = UDim2.new(0,5,0,2)
label.BackgroundTransparency = 1
label.Text = "Fly Speed"
label.TextColor3 = Color3.fromRGB(255,255,255)
label.Font = Enum.Font.Gotham
label.TextSize = 14
label.TextXAlignment = Enum.TextXAlignment.Left
label.Parent = frame

local speedBox = Instance.new("TextBox")
speedBox.Size = UDim2.new(0,140,0,20)
speedBox.Position = UDim2.new(0,5,0,18)
speedBox.BackgroundColor3 = Color3.fromRGB(50,50,50)
speedBox.TextColor3 = Color3.fromRGB(255,255,255)
speedBox.PlaceholderText = tostring(speed)
speedBox.ClearTextOnFocus = true
speedBox.TextScaled = true
speedBox.BorderSizePixel = 0
speedBox.Parent = frame

speedBox.Focused:Connect(function()
    speedBox.BackgroundColor3 = Color3.fromRGB(70,70,120)
end)
speedBox.FocusLost:Connect(function()
    speedBox.BackgroundColor3 = Color3.fromRGB(50,50,50)
end)

local function setupCharacter(char)
    root = char:WaitForChild("HumanoidRootPart")
    hum = char:WaitForChild("Humanoid")

    if flying then
        hum.PlatformStand = true

        bg = Instance.new("BodyGyro", root)
        bg.P = 9e4
        bg.maxTorque = Vector3.new(9e9,9e9,9e9)
        bg.CFrame = root.CFrame

        bv = Instance.new("BodyVelocity", root)
        bv.MaxForce = Vector3.new(9e9,9e9,9e9)
        bv.Velocity = Vector3.new(0,0,0)
    end
end

local function toggleFly()
    flying = not flying
    if flying then
        local char = player.Character or player.CharacterAdded:Wait()
        setupCharacter(char)
    else
        if hum then hum.PlatformStand = false end
        if bg then bg:Destroy() bg = nil end
        if bv then bv:Destroy() bv = nil end
    end
end

RunService.RenderStepped:Connect(function()
    if flying and root and bv and bg then
        local cam = workspace.CurrentCamera
        local dir = Vector3.new(0,0,0)
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir = dir + cam.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir = dir - cam.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir = dir - cam.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir = dir + cam.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.new(0,1,0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then dir = dir - Vector3.new(0,1,0) end

        bv.Velocity = (dir.Magnitude > 0 and dir.Unit * speed) or Vector3.new(0,0,0)
        bg.CFrame = CFrame.new(root.Position, root.Position + cam.CFrame.LookVector)
    end
end)

speedBox.FocusLost:Connect(function(enterPressed)
    if enterPressed then
        local num = tonumber(speedBox.Text)
        if num and num > 0 then
            speed = num
            speedBox.PlaceholderText = tostring(speed)
            speedBox.Text = ""
        else
            speedBox.Text = ""
        end
    end
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.V then
        toggleFly()
    end
end)

player.CharacterAdded:Connect(function(char)
    root = nil
    hum = nil
    if flying then
        setupCharacter(char)
    end
end)

if player.Character then
    setupCharacter(player.Character)
end