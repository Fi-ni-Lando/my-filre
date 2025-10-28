local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local localPlayer = Players.LocalPlayer

local SCAN_INTERVAL = 0.3

local highlights = {}
local enabled = false
local notifyToggle = false
local nameToggle = false
local fillColor = Color3.fromRGB(186, 85, 211)
local outlineColor = Color3.fromRGB(148, 0, 211)
local fillTransparency = 0.5
local outlineTransparency = 0
local notifySound = "rbxassetid://9118828084"
local seenFruits = {}
local scanTimer = 0

local screenGui = Instance.new("ScreenGui")
screenGui.ResetOnSpawn = false
screenGui.Name = "FruitESP_GUI"
screenGui.Parent = localPlayer:WaitForChild("PlayerGui")

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 320, 0, 400)
mainFrame.Position = UDim2.new(0, 10, 0, 10)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
mainFrame.BackgroundTransparency = 0.2
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, 0, 0, 40)
titleLabel.Position = UDim2.new(0, 0, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "Fruit ESP"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.Font = Enum.Font.SourceSansBold
titleLabel.TextScaled = true
titleLabel.Parent = mainFrame

local dragging, dragInput, dragStart, startPos
mainFrame.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true
		dragStart = input.Position
		startPos = mainFrame.Position
		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
			end
		end)
	end
end)

mainFrame.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement then
		dragInput = input
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if input == dragInput and dragging then
		local delta = input.Position - dragStart
		mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end
end)

local function createToggle(name, posY, default, callback)
	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(0.6, 0, 0, 28)
	label.Position = UDim2.new(0.05, 0, posY, 0)
	label.BackgroundTransparency = 1
	label.Text = name
	label.TextColor3 = Color3.fromRGB(255, 255, 255)
	label.Font = Enum.Font.SourceSansBold
	label.TextScaled = true
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = mainFrame

	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(0, 50, 0, 28)
	frame.Position = UDim2.new(0.7, 0, posY, 0)
	frame.BackgroundColor3 = default and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(180, 180, 180)
	frame.BorderSizePixel = 0
	frame.ClipsDescendants = true
	frame.Parent = mainFrame

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 14)
	corner.Parent = frame

	local knob = Instance.new("Frame")
	knob.Size = UDim2.new(0, 24, 0, 24)
	knob.Position = default and UDim2.new(1, -26, 0, 2) or UDim2.new(0, 2, 0, 2)
	knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	knob.BorderSizePixel = 0
	knob.Parent = frame

	local knobCorner = Instance.new("UICorner")
	knobCorner.CornerRadius = UDim.new(0, 12)
	knobCorner.Parent = knob

	frame.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			default = not default
			local goalPos = default and UDim2.new(1, -26, 0, 2) or UDim2.new(0, 2, 0, 2)
			knob:TweenPosition(goalPos, Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.2, true)
			frame.BackgroundColor3 = default and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(180, 180, 180)
			callback(default)
		end
	end)
end

local function createColorPicker(name, posY, defaultColor, callback)
	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(0.6, 0, 0, 28)
	label.Position = UDim2.new(0.05, 0, posY, 0)
	label.BackgroundTransparency = 1
	label.Text = name
	label.TextColor3 = Color3.fromRGB(255, 255, 255)
	label.Font = Enum.Font.SourceSansBold
	label.TextScaled = true
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = mainFrame

	local button = Instance.new("TextButton")
	button.Size = UDim2.new(0, 50, 0, 28)
	button.Position = UDim2.new(0.7, 0, posY, 0)
	button.BackgroundColor3 = defaultColor
	button.BorderSizePixel = 0
	button.Text = ""
	button.Parent = mainFrame

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 6)
	corner.Parent = button

	button.MouseButton1Click:Connect(function()
		local newColor = Color3.fromRGB(math.random(0,255), math.random(0,255), math.random(0,255))
		button.BackgroundColor3 = newColor
		callback(newColor)
	end)
end

local function createDropdown(name, posY, options, default, callback)
	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(0.6, 0, 0, 28)
	label.Position = UDim2.new(0.05, 0, posY, 0)
	label.BackgroundTransparency = 1
	label.Text = name
	label.TextColor3 = Color3.fromRGB(255,255,255)
	label.Font = Enum.Font.SourceSansBold
	label.TextScaled = true
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = mainFrame

	local button = Instance.new("TextButton")
	button.Size = UDim2.new(0, 100, 0, 28)
	button.Position = UDim2.new(0.7, 0, posY, 0)
	button.BackgroundColor3 = Color3.fromRGB(50,50,50)
	button.TextColor3 = Color3.fromRGB(255,255,255)
	button.Text = default
	button.Font = Enum.Font.SourceSansBold
	button.TextScaled = true
	button.Parent = mainFrame

	button.MouseButton1Click:Connect(function()
		local nextIndex = (table.find(options, button.Text) or 0) % #options + 1
		button.Text = options[nextIndex]
		callback(options[nextIndex])
	end)
end

createToggle("ESP Enabled", 0.12, false, function(val) enabled = val end)
createToggle("Notifications", 0.25, false, function(val) notifyToggle = val end)
createToggle("Show Names", 0.38, false, function(val) nameToggle = val end)

createColorPicker("Fill Color", 0.52, fillColor, function(c) fillColor = c end)
createColorPicker("Outline Color", 0.62, outlineColor, function(c) outlineColor = c end)
createDropdown("Notify Sound", 0.72, {"rbxassetid://9118828084","rbxassetid://9118833562"}, notifySound, function(s) notifySound = s end)

local function getFruitName(fruit)
	if fruit:GetAttribute("Name") then return fruit:GetAttribute("Name") end
	if fruit:GetAttribute("FruitName") then return fruit:GetAttribute("FruitName") end
	for _, child in ipairs(fruit:GetDescendants()) do
		if child:IsA("StringValue") then
			local lname = string.lower(child.Name)
			if string.find(lname, "name") or string.find(lname, "fruit") then
				return child.Value
			end
		end
	end
	return fruit.Name
end

local function isFruit(obj)
	if obj:IsA("Model") or obj:IsA("Part") then
		local name = string.lower(obj.Name)
		if string.find(name, "fruit") then return true end
		if obj:GetAttribute("IsFruit") or obj:GetAttribute("FruitName") then return true end
		for _, child in ipairs(obj:GetDescendants()) do
			if child:IsA("StringValue") and string.find(string.lower(child.Name), "fruit") then
				return true
			end
		end
	end
	return false
end

local function getHolder(fruit)
	for _, player in pairs(Players:GetPlayers()) do
		if player.Character then
			for _, item in pairs(player.Character:GetChildren()) do
				if item == fruit then return player end
			end
			local tool = player.Character:FindFirstChildOfClass("Tool")
			if tool == fruit then return player end
		end
	end
	return nil
end

local function removeESP(fruit)
	if highlights[fruit] then
		for _, obj in pairs(highlights[fruit]) do
			if obj and obj.Parent then obj:Destroy() end
		end
		highlights[fruit] = nil
	end
end

local function clearAll()
	for fruit in pairs(highlights) do
		removeESP(fruit)
	end
end

local function createESP(fruit, holder)
	if highlights[fruit] then return end
	local basePart = fruit:IsA("BasePart") and fruit or fruit:FindFirstChildWhichIsA("BasePart")
	if not basePart then return end

	local hl = Instance.new("Highlight")
	hl.Name = "FruitESP"
	hl.Adornee = fruit
	hl.FillColor = fillColor
	hl.OutlineColor = outlineColor
	hl.FillTransparency = fillTransparency
	hl.OutlineTransparency = outlineTransparency
	hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
	hl.Parent = localPlayer:WaitForChild("PlayerGui")

	local billboard = Instance.new("BillboardGui")
	billboard.Adornee = basePart
	billboard.Size = UDim2.new(0, 180, 0, 25)
	billboard.StudsOffset = Vector3.new(0, 4, 0)
	billboard.AlwaysOnTop = true
	billboard.Parent = localPlayer:WaitForChild("PlayerGui")

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, 0, 1, 0)
	label.BackgroundTransparency = 1
	label.TextColor3 = Color3.fromRGB(255, 200, 255)
	label.TextStrokeTransparency = 0
	label.TextScaled = true
	label.Font = Enum.Font.SourceSansBold
	label.Text = nameToggle and (holder and string.format("%s (holding by %s)", getFruitName(fruit), holder.Name) or "" .. getFruitName(fruit)) or ""
	label.Parent = billboard

	highlights[fruit] = {hl, billboard, label}

	fruit.AncestryChanged:Connect(function(_, parent)
		if not parent then removeESP(fruit) end
	end)
end

local function notifySide(message, soundId, side)
	if not notifyToggle then return end
	if soundId then
		local sound = Instance.new("Sound")
		sound.SoundId = soundId
		sound.Volume = 1
		sound.Parent = game.SoundService
		sound:Play()
		sound.Ended:Connect(function() sound:Destroy() end)
	end

	local gui = Instance.new("ScreenGui")
	gui.ResetOnSpawn = false
	gui.Parent = localPlayer:WaitForChild("PlayerGui")

	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(0, 250, 0, 50)
	frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	frame.BackgroundTransparency = 0.2
	frame.BorderSizePixel = 0
	frame.Parent = gui

	if side == "left" then
		frame.Position = UDim2.new(0, 10, 0.5, -25)
	elseif side == "right" then
		frame.Position = UDim2.new(1, -260, 0.5, -25)
	elseif side == "bottomleft" then
		frame.Position = UDim2.new(0, 10, 1, -60)
	else
		frame.Position = UDim2.new(0.5, -125, 1, -60)
	end

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, -10, 1, -10)
	label.Position = UDim2.new(0, 5, 0, 5)
	label.BackgroundTransparency = 1
	label.Text = message
	label.TextColor3 = Color3.fromRGB(255, 255, 255)
	label.TextStrokeTransparency = 0
	label.TextScaled = true
	label.Font = Enum.Font.SourceSansBold
	label.Parent = frame

	task.delay(3, function()
		for i = 1, 10 do
			frame.BackgroundTransparency = frame.BackgroundTransparency + 0.08
			label.TextTransparency = label.TextTransparency + 0.08
			task.wait(0.05)
		end
		gui:Destroy()
	end)
end

RunService.Heartbeat:Connect(function(dt)
	if not enabled then
		clearAll()
		return
	end

	scanTimer = scanTimer + dt
	if scanTimer < SCAN_INTERVAL then return end
	scanTimer = 0

	local tracked = {}
	for _, obj in pairs(Workspace:GetChildren()) do
		if isFruit(obj) then tracked[obj] = getHolder(obj) end
	end

	for _, player in pairs(Players:GetPlayers()) do
		if player.Character then
			for _, item in pairs(player.Character:GetChildren()) do
				if isFruit(item) then tracked[item] = player end
			end
			local tool = player.Character:FindFirstChildOfClass("Tool")
			if tool and isFruit(tool) then tracked[tool] = player end
		end
	end

	for fruit in pairs(highlights) do
		if not tracked[fruit] then
			removeESP(fruit)
			if seenFruits[fruit] then
				notifySide(string.format("%s disappeared", getFruitName(fruit)), notifySound, "bottomleft")
			end
			seenFruits[fruit] = nil
		end
	end

	for fruit, holder in pairs(tracked) do
		if not highlights[fruit] then
			createESP(fruit, holder)
			if not seenFruits[fruit] then
				if holder then
					notifySide(string.format("%s (holding by %s)", getFruitName(fruit), holder.Name), notifySound, "left")
				else
					notifySide("" .. getFruitName(fruit) .. " spawned", notifySound, "right")
				end
				seenFruits[fruit] = true
			end
		else
			local label = highlights[fruit][3]
			if label then
				label.Text = nameToggle and (holder and string.format("%s (holding by %s)", getFruitName(fruit), holder.Name) or "" .. getFruitName(fruit)) or ""
			end
		end
	end
end)