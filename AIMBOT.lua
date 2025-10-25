local P, UIS, RS, Cam = game:GetService("Players"), game:GetService("UserInputService"), game:GetService("RunService"), workspace.CurrentCamera
local LP = P.LocalPlayer

local A = {Enabled=true, Active=false, LockPart="Head", FOV=100}

local FOV = Drawing.new("Circle")
FOV.Visible, FOV.Thickness, FOV.Radius, FOV.Color, FOV.Transparency = true, 1.5, A.FOV, Color3.new(1,1,1), 0.8

local Txt = Drawing.new("Text")
Txt.Size, Txt.Center, Txt.Outline, Txt.Position, Txt.Text, Txt.Color, Txt.Transparency, Txt.Visible =
    18, true, true, Vector2.new(Cam.ViewportSize.X-100,50), "Aimbot: OFF", Color3.fromRGB(255,80,80), 0, true

local OrigSens, Locked

local function UpdateIndicator()
    Txt.Text = A.Active and "Aimbot: ON" or "Aimbot: OFF"
    FOV.Color = A.Active and Color3.fromRGB(0,255,0) or Color3.new(1,1,1)
end

local function ClosestInFOV()
    local target, minDist = nil, A.FOV
    local mousePos = UIS:GetMouseLocation()
    for _, plr in pairs(P:GetPlayers()) do
        if plr ~= LP and plr.Character then
            local hum = plr.Character:FindFirstChildOfClass("Humanoid")
            local part = plr.Character:FindFirstChild(A.LockPart)
            if hum and hum.Health > 0 and part then
                local screenPos, onScreen = Cam:WorldToViewportPoint(part.Position)
                if onScreen then
                    local dist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                    if dist <= A.FOV and dist < minDist then
                        target, minDist = plr, dist
                    end
                end
            end
        end
    end
    return target
end

local function DisableMouse()
    if not OrigSens then pcall(function() OrigSens = UIS.MouseDeltaSensitivity end) end
    pcall(function() UIS.MouseDeltaSensitivity = 0 end)
end

local function RestoreMouse()
    if OrigSens then
        pcall(function() UIS.MouseDeltaSensitivity = OrigSens end)
        OrigSens = nil
    else
        pcall(function() UIS.MouseDeltaSensitivity = 1 end)
    end
end

UIS.InputBegan:Connect(function(i, g)
    if g then return end
    if i.UserInputType == Enum.UserInputType.MouseButton2 then
        local initial = ClosestInFOV()
        if not initial then
            -- No valid target in FOV at press time: do nothing
            return
        end

        A.Active = true
        DisableMouse()
        Locked = initial
        UpdateIndicator()
    end
end)

UIS.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton2 then
        A.Active = false
        Locked = nil
        RestoreMouse()
        UpdateIndicator()
    end
end)

RS.RenderStepped:Connect(function()
    -- Make the FOV circle follow the mouse
    FOV.Position = UIS:GetMouseLocation()
    Txt.Position = Vector2.new(Cam.ViewportSize.X-100,50)

    if A.Active and A.Enabled then
        -- If Locked is invalid (dead/removed) or out of FOV, choose next one inside FOV
        local valid = Locked and Locked.Character and Locked.Character:FindFirstChild(A.LockPart)
        if not valid then
            Locked = ClosestInFOV()
        else
            local part = Locked.Character:FindFirstChild(A.LockPart)
            if part then
                local screenPos = Cam:WorldToViewportPoint(part.Position)
                local dist = (Vector2.new(screenPos.X, screenPos.Y) - UIS:GetMouseLocation()).Magnitude
                if dist > A.FOV then
                    Locked = ClosestInFOV()
                end
            else
                Locked = ClosestInFOV()
            end
        end

        if Locked and Locked.Character and Locked.Character:FindFirstChild(A.LockPart) then
            Cam.CFrame = CFrame.new(Cam.CFrame.Position, Locked.Character[A.LockPart].Position)
        end
    end
end)

local function Cleanup()
    RestoreMouse()
    if FOV.Remove then pcall(FOV.Remove, FOV) end
    if Txt.Remove then pcall(Txt.Remove, Txt) end
end

if syn and syn.on_script_exit then syn.on_script_exit(Cleanup,true) end
if KRNL_LOADED and krnl and krnl.on_script_reset then krnl.on_script_reset(Cleanup) end