local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local localPlayer = Players.LocalPlayer
local inventoryDisplays = {}
local espEnabled = true

local nameColor = Color3.fromRGB(186, 85, 211)
local normalColor = Color3.new(1,1,1)
local equippedColor = Color3.fromRGB(255,70,70)

local function updateInventory(player)
	if not espEnabled then return end
	local display = inventoryDisplays[player]
	if not display then return end
	local invLabel = display.label

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
				table.insert(items,"<font color='rgb(255,70,70)'>• "..tool.Name.." (Equipped)</font>")
			end
		end
	end

	invLabel.Text = (#items > 0) and table.concat(items,"\n") or "No tools"
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
		billboard.Size = UDim2.new(0, 160, 0, 50)
		billboard.StudsOffset = Vector3.new(0, 2.5, 0)
		billboard.AlwaysOnTop = true
		billboard.Enabled = espEnabled
		billboard.Parent = localPlayer:WaitForChild("PlayerGui")

		local nameLabel = Instance.new("TextLabel")
		nameLabel.Size = UDim2.new(1,0,0,12)
		nameLabel.BackgroundTransparency = 1
		nameLabel.Text = player.Name .. " Inv"
		nameLabel.TextColor3 = nameColor
		nameLabel.Font = Enum.Font.SourceSansBold
		nameLabel.TextSize = 11
		nameLabel.Parent = billboard

		local invLabel = Instance.new("TextLabel")
		invLabel.Size = UDim2.new(1,-6,1,-18)
		invLabel.Position = UDim2.new(0,3,0,16)
		invLabel.BackgroundTransparency = 1
		invLabel.TextColor3 = normalColor
		invLabel.Font = Enum.Font.SourceSans
		invLabel.TextSize = 10
		invLabel.TextXAlignment = Enum.TextXAlignment.Left
		invLabel.TextYAlignment = Enum.TextYAlignment.Top
		invLabel.RichText = true
		invLabel.Parent = billboard

		inventoryDisplays[player] = {gui = billboard, label = invLabel}

		local function refreshTools(child)
			if child:IsA("Tool") then updateInventory(player) end
		end
		character.ChildAdded:Connect(refreshTools)
		character.ChildRemoved:Connect(refreshTools)

		local backpack = player:FindFirstChild("Backpack")
		if backpack then
			backpack.ChildAdded:Connect(refreshTools)
			backpack.ChildRemoved:Connect(refreshTools)
		end
	end

	local character = player.Character or player.CharacterAdded:Wait()
	setupBillboard(character)

	player.CharacterAdded:Connect(function(char)
		task.wait(0.5)
		setupBillboard(char)
	end)
end

local function removeInventoryESP(player)
	local display = inventoryDisplays[player]
	if display then
		display.gui:Destroy()
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
	if input.UserInputType == Enum.UserInputType.Keyboard then
		if input.KeyCode == Enum.KeyCode.L then
			toggleESP()
		end
	end
end)

for _, player in ipairs(Players:GetPlayers()) do
	if player ~= localPlayer then
		createInventoryESP(player)
		updateInventory(player)
	end
end

Players.PlayerAdded:Connect(function(player)
	createInventoryESP(player)
end)
Players.PlayerRemoving:Connect(removeInventoryESP)

RunService.Heartbeat:Connect(function()
	if not espEnabled then return end
	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= localPlayer then
			if not inventoryDisplays[player] then
				createInventoryESP(player)
			end
			updateInventory(player)
		end
	end
end)