local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local workspace = game:GetService("Workspace")

local speed = 0.80
local enabled = true

local function showNotification(text)
    local ScreenGui = PlayerGui:FindFirstChild("RainbowGun") or Instance.new("ScreenGui")
    ScreenGui.Name = "RainbowGun"
    ScreenGui.Parent = PlayerGui

    local notif = Instance.new("TextLabel")
    notif.Size = UDim2.new(0,200,0,40)
    notif.Position = UDim2.new(1,-220,1,-60)
    notif.BackgroundColor3 = Color3.fromRGB(30,30,30)
    notif.TextColor3 = Color3.fromRGB(255,255,255)
    notif.Text = text
    notif.TextScaled = true
    notif.TextWrapped = true
    notif.Parent = ScreenGui
    notif.ZIndex = 10

    local tweenInfo = TweenInfo.new(2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local tween = TweenService:Create(notif, tweenInfo, {BackgroundTransparency = 1, TextTransparency = 1})
    tween:Play()
    tween.Completed:Connect(function()
        notif:Destroy()
    end)
end

local function toggleEnabled()
    enabled = not enabled
    showNotification("Rainbow Gun " .. (enabled and "ON" or "OFF"))
end

UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Enum.KeyCode.K then
        toggleEnabled()
    end
end)

local function getGunParts(model)
    local parts = {}
    for _,v in ipairs(model:GetDescendants()) do
        if v:IsA("BasePart") then
            table.insert(parts,v)
        end
    end
    return parts
end

local function isGun(item)
    return item:IsA("Tool") and item:FindFirstChild("Handle")
end

-- Update loop
RunService.RenderStepped:Connect(function()
    if not enabled then return end

    local color = Color3.fromHSV(tick()*speed % 1,1,1)

    if LocalPlayer.Character then
        for _,tool in ipairs(LocalPlayer.Character:GetChildren()) do
            if isGun(tool) then
                for _,part in ipairs(getGunParts(tool)) do
                    part.Color = color
                end
            end
        end
    end

    for _,tool in ipairs(LocalPlayer.Backpack:GetChildren()) do
        if isGun(tool) then
            for _,part in ipairs(getGunParts(tool)) do
                part.Color = color
            end
        end
    end

    for _,obj in ipairs(workspace:GetChildren()) do
        if isGun(obj) then
            for _,part in ipairs(getGunParts(obj)) do
                part.Color = color
            end
        end
    end
end)