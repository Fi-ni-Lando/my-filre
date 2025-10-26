local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local localPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local highlights = {}
local enabled = true -- start enabled
local nameColor = Color3.fromRGB(186, 85, 211)
local lineColor = Color3.fromRGB(186, 85, 211)
local maxDistance = math.huge

local function createESPForGun(tool)
    if not tool:IsA("Tool") then return end
    local handle = tool:FindFirstChild("Handle")
    if not handle then return end

    local billboard = Instance.new("BillboardGui")
    billboard.Adornee = handle
    billboard.Size = UDim2.new(0, 80, 0, 20)
    billboard.StudsOffset = Vector3.new(0, 2, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = localPlayer:WaitForChild("PlayerGui")

    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1,0,1,0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = tool.Name
    nameLabel.TextColor3 = nameColor
    nameLabel.TextStrokeColor3 = Color3.new(0,0,0)
    nameLabel.TextStrokeTransparency = 0.3
    nameLabel.TextScaled = true
    nameLabel.Font = Enum.Font.SourceSansBold
    nameLabel.Parent = billboard

    local line = Instance.new("LineHandleAdornment")
    line.Adornee = workspace.Terrain
    line.Thickness = 1
    line.Color3 = lineColor
    line.AlwaysOnTop = true
    line.ZIndex = 10
    line.Parent = workspace

    return {billboard, line, handle}
end

local function removeESP(tool)
    local esp = highlights[tool]
    if esp then
        for i=1,2 do
            if esp[i] and esp[i].Parent then
                esp[i]:Destroy()
            end
        end
    end
    highlights[tool] = nil
end

local function refreshESPs()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= localPlayer and player.Character then
            for _, tool in pairs(player.Character:GetChildren()) do
                if tool:IsA("Tool") and tool:FindFirstChild("Handle") then
                    if not highlights[tool] then
                        highlights[tool] = createESPForGun(tool)
                    end
                end
            end
        end
    end

    for tool, esp in pairs(highlights) do
        if not tool:IsDescendantOf(workspace) or not tool.Parent then
            removeESP(tool)
        end
    end

    for _, esp in pairs(highlights) do
        local line = esp[2]
        local handle = esp[3]
        if line and handle then
            line.From = Camera.CFrame.Position
            line.To = handle.Position
        end
    end
end

UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Enum.KeyCode.L then
        enabled = not enabled
        if not enabled then
            for tool, _ in pairs(highlights) do
                removeESP(tool)
            end
        end
        print("Gun ESP", enabled)
    end
end)

RunService.RenderStepped:Connect(function()
    if enabled then
        refreshESPs()
    end
end)