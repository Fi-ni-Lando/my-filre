local P, UIS, RS, Cam = game:GetService("Players"), game:GetService("UserInputService"), game:GetService("RunService"), workspace.CurrentCamera
local LP = P.LocalPlayer

local A = {Enabled=true, Active=false, HoldKey=Enum.KeyCode.V, LockPart="Head", FOV=120}

local FOV = Drawing.new("Circle")
FOV.Visible, FOV.Thickness, FOV.Radius, FOV.Color, FOV.Transparency = true, 1.5, A.FOV, Color3.new(1,1,1), 0.8

local Txt = Drawing.new("Text")
Txt.Size, Txt.Center, Txt.Outline, Txt.Position, Txt.Text, Txt.Color, Txt.Transparency, Txt.Visible = 18, true, true, Vector2.new(Cam.ViewportSize.X-100,50),"Aimbot: OFF", Color3.fromRGB(255,80,80),0,true

local OrigSens, Locked

local function UpdateIndicator()
	Txt.Text, FOV.Color = A.Active and "Aimbot: ON" or "Aimbot: OFF", A.Active and Color3.fromRGB(0,255,0) or Color3.new(1,1,1)
end

local function Closest()
	local t, s = nil, A.FOV
	for _, plr in pairs(P:GetPlayers()) do
		if plr ~= LP and plr.Character then
			local hum = plr.Character:FindFirstChildOfClass("Humanoid")
			local part = plr.Character:FindFirstChild(A.LockPart)
			if hum and hum.Health > 0 and part then
				local pos, onS = Cam:WorldToViewportPoint(part.Position)
				if onS then
					local d = (Vector2.new(pos.X,pos.Y)-UIS:GetMouseLocation()).Magnitude
					if d < s then t, s = plr, d end
				end
			end
		end
	end
	return t
end

local function DisableMouse()
	if not OrigSens then pcall(function() OrigSens = UIS.MouseDeltaSensitivity end) end
	pcall(function() UIS.MouseDeltaSensitivity = 0 end)
end

local function RestoreMouse()
	if OrigSens then pcall(function() UIS.MouseDeltaSensitivity = OrigSens end) OrigSens=nil else pcall(function() UIS.MouseDeltaSensitivity=1 end) end
end

UIS.InputBegan:Connect(function(i,g)
	if g then return end
	if i.KeyCode == A.HoldKey then
		A.Active = true
		DisableMouse()
		UpdateIndicator()
	end
end)

UIS.InputEnded:Connect(function(i)
	if i.KeyCode == A.HoldKey then
		A.Active = false
		Locked = nil
		RestoreMouse()
		UpdateIndicator()
	end
end)

RS.RenderStepped:Connect(function()
	FOV.Position = A.Active and Cam.ViewportSize/2 or UIS:GetMouseLocation()
	Txt.Position = Vector2.new(Cam.ViewportSize.X-100,50)

	if A.Active and A.Enabled then
		if not Locked or not Locked.Character or not Locked.Character:FindFirstChildOfClass("Humanoid") or Locked.Character:FindFirstChildOfClass("Humanoid").Health <= 0 then
			Locked = Closest()
		end
		if Locked and Locked.Character and Locked.Character:FindFirstChild(A.LockPart) then
			Cam.CFrame = CFrame.new(Cam.CFrame.Position, Locked.Character[A.LockPart].Position)
		end
	end
end)

local function Cleanup()
	RestoreMouse()
	if FOV.Remove then pcall(FOV.Remove,FOV) end
	if Txt.Remove then pcall(Txt.Remove,Txt) end
end

if syn and syn.on_script_exit then syn.on_script_exit(Cleanup,true) end
if KRNL_LOADED and krnl and krnl.on_script_reset then krnl.on_script_reset(Cleanup) end