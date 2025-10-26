local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local localPlayer = Players.LocalPlayer
local highlights = {}
local enabled = true
local maxDistance = math.huge

local outlineColor = Color3.fromRGB(148,0,211)
local fillColor = Color3.fromRGB(186,85,211)
local fillTransparency = 0.5
local outlineTransparency = 0

local function createESPForCharacter(player)
    local char = player.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local hl = Instance.new("Highlight")
    hl.Name = "DevESPHighlight"
    hl.Adornee = char
    hl.FillColor = fillColor
    hl.OutlineColor = outlineColor
    hl.FillTransparency = fillTransparency
    hl.OutlineTransparency = outlineTransparency
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    hl.Enabled = true
    hl.Parent = localPlayer:WaitForChild("PlayerGui")

    local billboard = Instance.new("BillboardGui")
    billboard.Adornee = hrp
    billboard.Size = UDim2.new(0, 50, 0, 12)
    billboard.StudsOffset = Vector3.new(0, 1.8, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = localPlayer:WaitForChild("PlayerGui")

    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, 0, 1, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = player.Name
    nameLabel.TextColor3 = Color3.fromRGB(186, 85, 211)
    nameLabel.TextStrokeTransparency = 0
    nameLabel.TextScaled = false
    nameLabel.TextSize = 10
    nameLabel.Font = Enum.Font.SourceSansBold
    nameLabel.Parent = billboard

    return {hl, billboard}
end

local function removeESP(player)
    local esp = highlights[player]
    if esp then
        for _, obj in pairs(esp) do
            if obj and obj.Parent then obj:Destroy() end
        end
    end
    highlights[player] = nil
end

local function refreshESPs()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= localPlayer then
            local char = player.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if hrp and localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart") then
                local dist = (hrp.Position - localPlayer.Character.HumanoidRootPart.Position).Magnitude
                if dist <= maxDistance then
                    if not highlights[player] then
                        highlights[player] = createESPForCharacter(player)
                    else
                        local hl, billboard = unpack(highlights[player])
                        if hl.Adornee ~= char then hl.Adornee = char end
                        if billboard.Adornee ~= hrp then billboard.Adornee = hrp end
                    end
                else
                    removeESP(player)
                end
            else
                removeESP(player)
            end
        end
    end
end

local function setEnabled(val)
    enabled = val
    if not enabled then
        for p,_ in pairs(highlights) do removeESP(p) end
    else
        refreshESPs()
    end
end

UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Enum.KeyCode.B then
        setEnabled(not enabled)
        print("ESP toggled:", enabled)
    end
end)

RunService.Heartbeat:Connect(function()
    if enabled then refreshESPs() end
end)

Players.PlayerRemoving:Connect(removeESP)
Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function() if enabled then refreshESPs() end end)
end)

refreshESPs()