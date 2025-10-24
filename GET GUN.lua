local player = game:GetService("Players").LocalPlayer
local workspace = game:GetService("Workspace")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")

-- Gun name to location (you can add more)
local guns = {
    ["ak"] = Vector3.new(-922.312683, 91.2782822, 2051.95361),
    ["so"] = Vector3.new(820.298584, 97.8500061, 2217.39624),
    ["m9"] = Vector3.new(813.698669, 97.8500061, 2217.39624),
    ["m4"] = Vector3.new(847.498596, 97.8500061, 2217.39624),
}

local touchGivers = {}
task.spawn(function()
	for _, part in workspace:GetDescendants() do
		if part:IsA("BasePart") and part.Name == "TouchGiver" then
			table.insert(touchGivers, part)
		end
	end
	print("Cached", #touchGivers, "TouchGivers")
end)

local function getNearestTouchGiver(pos)
	local best, bestDist = nil, 1e9
	for _, tg in ipairs(touchGivers) do
		local d = (tg.Position - pos).Magnitude
		if d < bestDist then
			best = tg
			bestDist = d
		end
	end
	return best
end

local function instantGiveGun(gunName)
	task.spawn(function()
		local char = player.Character or player.CharacterAdded:Wait()
		local hrp = char:WaitForChild("HumanoidRootPart")
		local gunPos = guns[gunName]
		if not gunPos then return warn("❌ Gun not found:", gunName) end

		local tg = getNearestTouchGiver(gunPos)
		if not tg then return warn("❌ No TouchGiver found for", gunName) end

		local item = tg.Parent
		local pivot = item:GetPivot()
		local saved = {}

		for _, p in ipairs(item:GetDescendants()) do
			if p:IsA("BasePart") then
				saved[p] = {p.CanCollide, p.Transparency}
				p.CanCollide = false
				p.Transparency = 1
			end
		end

		item:PivotTo(hrp.CFrame)
		task.wait()
		item:PivotTo(pivot)

		for p, d in pairs(saved) do
			if p:IsA("BasePart") then
				p.CanCollide = d[1]
				p.Transparency = d[2]
			end
		end

		if player.Backpack:FindFirstChild(gunName) then
			print("✅ Instantly got", gunName)
		else
			warn("❌ Failed to get", gunName)
		end
	end)
end

-- 🌀 GUI Setup
local ScreenGui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
ScreenGui.ResetOnSpawn = false
ScreenGui.Name = "GunGiverUI"

local Frame = Instance.new("Frame", ScreenGui)
Frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Frame.Position = UDim2.new(0.5, -150, 0.5, -80)
Frame.Size = UDim2.new(0, 300, 0, 160)
Frame.BackgroundTransparency = 0.15
Frame.BorderSizePixel = 0
Frame.ClipsDescendants = true
Frame.Active, Frame.Draggable = true, true
Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 12)

-- Gradient
local UIGradient = Instance.new("UIGradient", Frame)
UIGradient.Color = ColorSequence.new{
	ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 200, 255)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 255, 140))
}
UIGradient.Rotation = 45

-- Title
local Title = Instance.new("TextLabel", Frame)
Title.Text = "ak so m9 m4"
Title.Font = Enum.Font.GothamBold
Title.TextSize = 22
Title.TextColor3 = Color3.new(1, 1, 1)
Title.BackgroundTransparency = 1
Title.Size = UDim2.new(1, 0, 0, 40)
Title.TextStrokeTransparency = 0.7

-- Input Box
local TextBox = Instance.new("TextBox", Frame)
TextBox.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
TextBox.Position = UDim2.new(0.08, 0, 0.35, 0)
TextBox.Size = UDim2.new(0.84, 0, 0.25, 0)
TextBox.Font = Enum.Font.GothamBold
TextBox.PlaceholderText = "Enter gun name..."
TextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
TextBox.TextScaled = true
Instance.new("UICorner", TextBox).CornerRadius = UDim.new(0, 8)

-- Button
local Button = Instance.new("TextButton", Frame)
Button.BackgroundColor3 = Color3.fromRGB(0, 255, 170)
Button.Position = UDim2.new(0.08, 0, 0.68, 0)
Button.Size = UDim2.new(0.84, 0, 0.22, 0)
Button.Font = Enum.Font.GothamBold
Button.Text = "GET GUN"
Button.TextColor3 = Color3.new(0, 0, 0)
Button.TextScaled = true
Instance.new("UICorner", Button).CornerRadius = UDim.new(0, 8)

-- Click animation + sound
local ClickSound = Instance.new("Sound", SoundService)
ClickSound.SoundId = "rbxassetid://9118823101"
ClickSound.Volume = 1

Button.MouseEnter:Connect(function()
	TweenService:Create(Button, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(0, 255, 255)}):Play()
end)

Button.MouseLeave:Connect(function()
	TweenService:Create(Button, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(0, 255, 170)}):Play()
end)

Button.MouseButton1Click:Connect(function()
	local name = TextBox.Text:lower()
	if name == "" then
		warn("⚠️ Enter a gun name")
	else
		ClickSound:Play()
		TweenService:Create(Button, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(0, 150, 255)}):Play()
		instantGiveGun(name)
		task.wait(0.15)
		TweenService:Create(Button, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(0, 255, 170)}):Play()
	end
end)

-- Toggle GUI with "B"
UIS.InputBegan:Connect(function(input, gpe)
	if not gpe and input.KeyCode == Enum.KeyCode.B then
		Frame.Visible = not Frame.Visible
	end
end)