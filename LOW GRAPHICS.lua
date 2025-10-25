local Lighting = game:GetService("Lighting")
local Terrain = workspace:FindFirstChildOfClass("Terrain")
local UIS = game:GetService("UserInputService")
local Player = game:GetService("Players").LocalPlayer
local MaterialService = game:GetService("MaterialService")

local ScreenGui = Instance.new("ScreenGui", Player:WaitForChild("PlayerGui"))
ScreenGui.Name = "LowGraphics"

local Button = Instance.new("TextButton", ScreenGui)
Button.Size = UDim2.new(0, 240, 0, 40)
Button.Position = UDim2.new(1, -260, 1, -60)
Button.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Button.TextColor3 = Color3.fromRGB(255, 255, 255)
Button.Text = "Low Graphics (OFF)"
Button.Font = Enum.Font.SourceSansBold
Button.TextSize = 18
Button.AnchorPoint = Vector2.new(0, 0)
Button.BorderSizePixel = 0
Button.AutoButtonColor = true
Button.ZIndex = 5

local UltraLow = false

local function removeTextures()
	for _, obj in pairs(workspace:GetDescendants()) do
		if obj:IsA("SurfaceAppearance") or obj:IsA("Texture") or obj:IsA("Decal") then
			obj:Destroy()
		elseif obj:IsA("BasePart") then
			obj.Material = Enum.Material.SmoothPlastic
			obj.Reflectance = 0
		end
	end
end

local function applyUltraLow()
	print("[LowGraphics]")

	for _, v in pairs(Lighting:GetChildren()) do
		if v:IsA("BlurEffect") or v:IsA("SunRaysEffect") or v:IsA("ColorCorrectionEffect")
			or v:IsA("BloomEffect") or v:IsA("DepthOfFieldEffect") then
			v.Enabled = false
		end
	end

	local atmosphere = Lighting:FindFirstChildOfClass("Atmosphere")
	if atmosphere then
		atmosphere.Density = 0
		atmosphere.Offset = 0
		atmosphere.Glare = 0
		atmosphere.Haze = 0
	end

	Lighting.GlobalShadows = false
	Lighting.EnvironmentSpecularScale = 0
	Lighting.EnvironmentDiffuseScale = 0
	Lighting.FogEnd = 999999
	Lighting.FogStart = 0
	settings().Rendering.QualityLevel = Enum.QualityLevel.Level01

	if Terrain then
		Terrain.WaterWaveSize = 0
		Terrain.WaterWaveSpeed = 0
		Terrain.WaterReflectance = 0
		Terrain.WaterTransparency = 1
	end

	for _, material in pairs(Enum.Material:GetEnumItems()) do
		pcall(function()
			MaterialService:SetBaseMaterialOverride(material, Enum.Material.SmoothPlastic)
		end)
	end

	removeTextures()

	print("[LowGraphics]")
end

local function resetGraphics()
	print("[LowGraphics]")

	Lighting.GlobalShadows = true
	Lighting.EnvironmentSpecularScale = 1
	Lighting.EnvironmentDiffuseScale = 1
	settings().Rendering.QualityLevel = Enum.QualityLevel.Automatic

	for _, material in pairs(Enum.Material:GetEnumItems()) do
		pcall(function()
			MaterialService:SetBaseMaterialOverride(material, nil)
		end)
	end
end

local function toggleUltraLow()
	UltraLow = not UltraLow
	if UltraLow then
		applyUltraLow()
		Button.Text = "Low Graphics (ON)"
		Button.BackgroundColor3 = Color3.fromRGB(60, 120, 60)
	else
		resetGraphics()
		Button.Text = "Low Graphics (OFF)"
		Button.BackgroundColor3 = Color3.fromRGB(120, 60, 60)
	end
end

Button.MouseButton1Click:Connect(toggleUltraLow)

UIS.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if input.KeyCode == Enum.KeyCode.J then
		toggleUltraLow()
	end
end)