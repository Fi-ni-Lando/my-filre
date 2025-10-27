local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local localPlayer = Players.LocalPlayer
local inventoryDisplays = {}
local espEnabled = true

local normalColor = Color3.new(1,1,1)
local equippedColor = Color3.fromRGB(0,255,0)
local noToolColor = Color3.fromRGB(148,0,211)

local function getNameColor(player)
    return player.Team and player.Team.TeamColor.Color or Color3.new(1,1,1)
end

local function updateInventory(player)
    if not espEnabled then return end
    local display = inventoryDisplays[player]
    if not display then return end

    local items = {}
    local backpack = player:FindFirstChild("Backpack")
    if backpack then
        for _, tool in ipairs(backpack:GetChildren()) do
            if tool:IsA("Tool") then
                table.insert(items, "• "..tool.Name)
            end
        end
    end

    if player.Character then
        for _, tool in ipairs(player.Character:GetChildren()) do
            if tool:IsA("Tool") then
                table.insert(items, "<font color='rgb(0,255,0)'>• "..tool.Name.." (Equipped)</font>")
            end
        end
    end

    if #items > 0 then
        display.label.TextColor3 = normalColor
        display.label.Text = table.concat(items, "\n")
    else
        display.label.TextColor3 = noToolColor
        display.label.Text = "No tools"
    end
end

local function createInventoryESP(player)
    local function setupBillboard(character)
        if inventoryDisplays[player] then
            inventoryDisplays[player].gui:Destroy()
            inventoryDisplays[player] = nil
        end

        local head = character:WaitForChild("Head", 5)
        if not head then return end

        local billboard = Instance.new("BillboardGui")
        billboard.Adornee = head
        billboard.Size = UDim2.new(0, 180, 0, 80)
        billboard.StudsOffset = Vector3.new(0, 3, 0)
        billboard.AlwaysOnTop = true
        billboard.Enabled = espEnabled
        billboard.Parent = localPlayer:WaitForChild("PlayerGui")

        local nameLabel = Instance.new("TextLabel")
        nameLabel.Size = UDim2.new(1, 0, 0, 16)
        nameLabel.Position = UDim2.new(0, 0, 0, 0)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Text = player.Name
        nameLabel.TextColor3 = getNameColor(player)
        nameLabel.Font = Enum.Font.SourceSansBold
        nameLabel.TextSize = 12
        nameLabel.TextStrokeTransparency = 1
        nameLabel.TextScaled = false
        nameLabel.Parent = billboard

        local invLabel = Instance.new("TextLabel")
        invLabel.Size = UDim2.new(1, -4, 1, -22)
        invLabel.Position = UDim2.new(0, 2, 0, 18)
        invLabel.BackgroundTransparency = 1
        invLabel.TextColor3 = normalColor
        invLabel.Font = Enum.Font.SourceSans
        invLabel.TextSize = 10
        invLabel.TextStrokeTransparency = 1
        invLabel.TextXAlignment = Enum.TextXAlignment.Left
        invLabel.TextYAlignment = Enum.TextYAlignment.Top
        invLabel.RichText = true
        invLabel.TextWrapped = true
        invLabel.TextScaled = false
        invLabel.Parent = billboard

        inventoryDisplays[player] = {gui = billboard, label = invLabel, nameLabel = nameLabel}

        local function refreshTools(child)
            if child:IsA("Tool") then
                updateInventory(player)
            end
        end

        character.ChildAdded:Connect(refreshTools)
        character.ChildRemoved:Connect(refreshTools)
        local backpack = player:FindFirstChild("Backpack")
        if backpack then
            backpack.ChildAdded:Connect(refreshTools)
            backpack.ChildRemoved:Connect(refreshTools)
        end

        player:GetPropertyChangedSignal("Team"):Connect(function()
            if inventoryDisplays[player] then
                inventoryDisplays[player].nameLabel.TextColor3 = getNameColor(player)
            end
        end)
    end

    local character = player.Character or player.CharacterAdded:Wait()
    setupBillboard(character)

    player.CharacterAdded:Connect(function(char)
        task.wait(0.5)
        setupBillboard(char)
    end)
end

local function removeInventoryESP(player)
    if inventoryDisplays[player] then
        inventoryDisplays[player].gui:Destroy()
        inventoryDisplays[player] = nil
    end
end

local function toggleESP()
    espEnabled = not espEnabled
    for _, display in pairs(inventoryDisplays) do
        if display.gui then
            display.gui.Enabled = espEnabled
        end
    end
end

UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == Enum.KeyCode.L then
        toggleESP()
    end
end)

for _, player in ipairs(Players:GetPlayers()) do
    if player ~= localPlayer then
        createInventoryESP(player)
        updateInventory(player)
    end
end

Players.PlayerAdded:Connect(function(player)
    if player ~= localPlayer then
        createInventoryESP(player)
    end
end)

Players.PlayerRemoving:Connect(removeInventoryESP)

task.spawn(function()
    while true do
        if espEnabled then
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= localPlayer and inventoryDisplays[player] then
                    updateInventory(player)
                end
            end
        end
        task.wait(0.2)
    end
end)