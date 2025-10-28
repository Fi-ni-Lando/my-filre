local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

local enabled = false
local seeThrough = true
local transparency = 0.6
local bodyTransparency = 0.5
local sizeStep = 1
local visualSize = Vector3.new(6,6,6)
local hitboxSize = Vector3.new(8,8,8)
local hitboxes = {}

local function isEnemy(player)
	if player == LocalPlayer then return false end
	if player.Team and LocalPlayer.Team and player.Team == LocalPlayer.Team then
		return false
	end
	return true
end

local function getTeamColor(player)
	if player.Team and player.Team.TeamColor then
		return player.Team.TeamColor.Color
	end
	return Color3.fromRGB(255, 255, 255)
end

local function makeBodySeeThrough(player)
	if not seeThrough or not player.Character then return end
	for _, part in ipairs(player.Character:GetDescendants()) do
		if part:IsA("BasePart") then
			part.LocalTransparencyModifier = bodyTransparency
			part.Material = Enum.Material.ForceField
			part.Color = getTeamColor(player)
		elseif part:IsA("Decal") or part:IsA("Texture") then
			part.Transparency = 1
		end
	end
end

local function resetBody(player)
	if not player.Character then return end
	for _, part in ipairs(player.Character:GetDescendants()) do
		if part:IsA("BasePart") then
			part.LocalTransparencyModifier = 0
			part.Material = Enum.Material.Plastic
		end
	end
end

local function makeUnmissable(player)
	if not player.Character then return end
	local root = player.Character:FindFirstChild("HumanoidRootPart")
	local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
	if not root or not humanoid then return end
	root.Size = hitboxSize
	root.CanCollide = false
end

local function createHitbox(player)
	if not isEnemy(player) or not player.Character then return end
	local root = player.Character:FindFirstChild("HumanoidRootPart")
		or player.Character:FindFirstChild("UpperTorso")
		or player.Character:FindFirstChild("Torso")
	local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
	if not root or not humanoid then return end

	if hitboxes[player] then hitboxes[player]:Destroy() end

	local box = Instance.new("BoxHandleAdornment")
	box.Name = "HitboxAdornment"
	box.Adornee = root
	box.AlwaysOnTop = true
	box.ZIndex = 10
	box.Color3 = getTeamColor(player)
	box.Transparency = transparency
	box.Size = visualSize
	box.Parent = CoreGui
	hitboxes[player] = box

	makeBodySeeThrough(player)
	makeUnmissable(player)

	player:GetPropertyChangedSignal("Team"):Connect(function()
		if hitboxes[player] then
			hitboxes[player].Color3 = getTeamColor(player)
		end
	end)

	humanoid.Died:Once(function()
		if hitboxes[player] then
			hitboxes[player]:Destroy()
			hitboxes[player] = nil
			resetBody(player)
		end
	end)
end

local function removeHitbox(player)
	local box = hitboxes[player]
	if box then box:Destroy() hitboxes[player]=nil end
	resetBody(player)
	if player.Character then
		local root = player.Character:FindFirstChild("HumanoidRootPart")
		if root then root.Size = Vector3.new(2,2,1) end
	end
end

local function onCharacterAdded(player, char)
	if enabled and isEnemy(player) then
		task.wait(0.2)
		createHitbox(player)
	end
end

local function onPlayerAdded(player)
	player.CharacterAdded:Connect(function(char)
		onCharacterAdded(player, char)
	end)
	if player.Character then
		onCharacterAdded(player, player.Character)
	end

	player:GetPropertyChangedSignal("Team"):Connect(function()
		if hitboxes[player] then removeHitbox(player) end
		if enabled and isEnemy(player) then createHitbox(player) end
	end)
end

local function onPlayerRemoving(player)
	removeHitbox(player)
end

for _, p in ipairs(Players:GetPlayers()) do onPlayerAdded(p) end
Players.PlayerAdded:Connect(onPlayerAdded)
Players.PlayerRemoving:Connect(onPlayerRemoving)

LocalPlayer:GetPropertyChangedSignal("Team"):Connect(function()
	for player,_ in pairs(hitboxes) do
		if not isEnemy(player) then removeHitbox(player) end
	end
	if enabled then
		for _, player in ipairs(Players:GetPlayers()) do
			if isEnemy(player) then createHitbox(player) end
		end
	end
end)

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "HitboxGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = CoreGui

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 220, 0, 200)
Frame.Position = UDim2.new(0.05,0,0.65,0)
Frame.BackgroundColor3 = Color3.fromRGB(25,25,25)
Frame.BackgroundTransparency = 0.15
Frame.BorderSizePixel = 0
Frame.Active = true
Frame.Draggable = true
Frame.Parent = ScreenGui
Instance.new("UICorner", Frame).CornerRadius = UDim.new(0,10)

local Title = Instance.new("TextLabel")
Title.Text = "Hitbox Expander"
Title.Size = UDim2.new(1,0,0,25)
Title.TextColor3 = Color3.new(1,1,1)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 14
Title.BackgroundTransparency = 1
Title.Parent = Frame

local function makeButton(name,posY,color)
	local button = Instance.new("TextButton")
	button.Text = name
	button.Size = UDim2.new(0.9,0,0,30)
	button.Position = UDim2.new(0.05,0,0,posY)
	button.BackgroundColor3 = color
	button.TextColor3 = Color3.new(1,1,1)
	button.Font = Enum.Font.GothamBold
	button.TextSize = 13
	button.Parent = Frame
	Instance.new("UICorner", button).CornerRadius = UDim.new(0,6)
	return button
end

local btnHitbox = makeButton("Hitboxes: OFF", 35, Color3.fromRGB(255,80,80))
local btnSee = makeButton("See-Through: ON", 70, Color3.fromRGB(80,255,120))

local sizeFrame = Instance.new("Frame")
sizeFrame.Size = UDim2.new(0.9,0,0,35)
sizeFrame.Position = UDim2.new(0.05,0,0,115)
sizeFrame.BackgroundTransparency = 1
sizeFrame.Parent = Frame

local minus = Instance.new("TextButton")
minus.Text = "-"
minus.Size = UDim2.new(0.25,0,1,0)
minus.BackgroundColor3 = Color3.fromRGB(255,130,130)
minus.TextColor3 = Color3.new(1,1,1)
minus.Font = Enum.Font.GothamBold
minus.TextSize = 18
minus.Parent = sizeFrame
Instance.new("UICorner", minus).CornerRadius = UDim.new(0,6)

local sizeLabel = Instance.new("TextLabel")
sizeLabel.Text = tostring(visualSize.X)
sizeLabel.Size = UDim2.new(0.5,0,1,0)
sizeLabel.Position = UDim2.new(0.25,0,0,0)
sizeLabel.BackgroundTransparency = 1
sizeLabel.TextColor3 = Color3.new(1,1,1)
sizeLabel.Font = Enum.Font.GothamBold
sizeLabel.TextSize = 16
sizeLabel.TextXAlignment = Enum.TextXAlignment.Center
sizeLabel.Parent = sizeFrame

local plus = Instance.new("TextButton")
plus.Text = "+"
plus.Size = UDim2.new(0.25,0,1,0)
plus.Position = UDim2.new(0.75,0,0,0)
plus.BackgroundColor3 = Color3.fromRGB(100,255,130)
plus.TextColor3 = Color3.new(1,1,1)
plus.Font = Enum.Font.GothamBold
plus.TextSize = 18
plus.Parent = sizeFrame
Instance.new("UICorner", plus).CornerRadius = UDim.new(0,6)

local function updateButtons()
	btnHitbox.Text = enabled and "Hitboxes: ON" or "Hitboxes: OFF"
	btnHitbox.BackgroundColor3 = enabled and Color3.fromRGB(80,255,120) or Color3.fromRGB(255,80,80)
	btnSee.Text = seeThrough and "See-Through: ON" or "See-Through: OFF"
	btnSee.BackgroundColor3 = seeThrough and Color3.fromRGB(80,255,120) or Color3.fromRGB(255,80,80)
	sizeLabel.Text = tostring(visualSize.X)
end

local function toggleHitboxes()
	enabled = not enabled
	for _, p in ipairs(Players:GetPlayers()) do
		if isEnemy(p) then
			if enabled then createHitbox(p) else removeHitbox(p) end
		end
	end
	updateButtons()
end

local function toggleSeeThrough()
	seeThrough = not seeThrough
	for _, p in ipairs(Players:GetPlayers()) do
		if isEnemy(p) and p.Character then
			if seeThrough then makeBodySeeThrough(p)
			else resetBody(p) end
		end
	end
	updateButtons()
end

local function resizeHitbox(smaller)
	local newSize = smaller and math.max(2, visualSize.X - sizeStep) or (visualSize.X + sizeStep)
	visualSize = Vector3.new(newSize,newSize,newSize)
	hitboxSize = visualSize + Vector3.new(2,2,2)
	for player, box in pairs(hitboxes) do
		if isEnemy(player) then
			box.Size = visualSize
			makeUnmissable(player)
		end
	end
	updateButtons()
end

btnHitbox.MouseButton1Click:Connect(toggleHitboxes)
btnSee.MouseButton1Click:Connect(toggleSeeThrough)
minus.MouseButton1Click:Connect(function() resizeHitbox(true) end)
plus.MouseButton1Click:Connect(function() resizeHitbox(false) end)

updateButtons()